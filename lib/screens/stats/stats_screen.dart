import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/categories.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/common.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _income = false;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpenseProvider>();
    final data = p.breakdown(income: _income);
    final total = _income ? p.totalIncome : p.totalExpense;

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Insights'),
            border: null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.l, Gap.s, Gap.l, 0),
              child: CupertinoSlidingSegmentedControl<bool>(
                groupValue: _income,
                children: const {
                  false: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Spending'),
                  ),
                  true: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Income'),
                  ),
                },
                onValueChanged: (v) {
                  if (v == null) return;
                  HapticFeedback.selectionClick();
                  setState(() => _income = v);
                },
              ),
            ),
          ),
          if (data.isEmpty)
            SliverToBoxAdapter(
              child: EmptyState(
                icon: CupertinoIcons.chart_pie,
                title: _income ? 'No income yet' : 'No spending yet',
                message:
                    'Once you add transactions, you’ll see a breakdown by category here.',
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: _SummaryCard(total: total, data: data, income: _income),
            ),
            SliverToBoxAdapter(
              child: CupertinoListSection.insetGrouped(
                header: const Text('BY CATEGORY'),
                hasLeading: true,
                children: [
                  for (final e in data)
                    _CategoryRow(
                      category: Categories.of(e.key, income: _income),
                      amount: e.value,
                      share: total == 0 ? 0 : e.value / total,
                    ),
                ],
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: Gap.xxl)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.data,
    required this.income,
  });

  final double total;
  final List<MapEntry<String, double>> data;
  final bool income;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(Gap.l, Gap.l, Gap.l, 0),
      padding: const EdgeInsets.all(Gap.l + 4),
      decoration: BoxDecoration(
        color: AppColors.surface.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            income ? 'Total income' : 'Total spent',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryLabel.resolveFrom(context),
            ),
          ),
          const SizedBox(height: Gap.xs),
          Text(
            Fmt.money(total),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              fontFeatures: tabular,
            ),
          ),
          const SizedBox(height: Gap.l),
          // Stacked share bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  for (final e in data)
                    Expanded(
                      flex: (e.value / total * 1000).round().clamp(1, 1000),
                      child: Container(
                        margin: const EdgeInsets.only(right: 2),
                        color: CupertinoDynamicColor.resolve(
                          Categories.of(e.key, income: income).color,
                          context,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gap.m),
          Text(
            data.length == 1
                ? 'All in ${data.first.key}'
                : 'Top: ${data.first.key} · ${(data.first.value / total * 100).round()}%',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.share,
  });

  final Category category;
  final double amount;
  final double share;

  @override
  Widget build(BuildContext context) {
    final color = CupertinoDynamicColor.resolve(category.color, context);
    return CupertinoListTile(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
      leadingSize: 36,
      leading: CategoryIcon(category, size: 36),
      title: Row(
        children: [
          Expanded(child: Text(category.name)),
          Text(
            Fmt.money(amount),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFeatures: tabular,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: share),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => Stack(
                    children: [
                      Container(
                        height: 6,
                        color: AppColors.fill.resolveFrom(context),
                      ),
                      FractionallySizedBox(
                        widthFactor: v,
                        child: Container(height: 6, color: color),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: Gap.m),
            SizedBox(
              width: 40,
              child: Text(
                '${(share * 100).round()}%',
                textAlign: TextAlign.right,
                style: const TextStyle(fontFeatures: tabular),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
