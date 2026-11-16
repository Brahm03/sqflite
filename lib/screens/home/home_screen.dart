import 'package:exam_cache/screens/profile/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/common.dart';
import '../add/add_transaction_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = context.select<AuthProvider, String>(
      (a) => a.user?.name ?? '',
    );
    final expenses = context.watch<ExpenseProvider>();
    expenses.hisoblash();

    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: Text(name.isEmpty ? 'Overview' : 'Hi, $name'),
            ),
            border: null,
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(44, 44),
              onPressed: () => showAddTransaction(context),
              child: const Icon(
                CupertinoIcons.add_circled_solid,
                size: 30,
                semanticLabel: 'Add transaction',
              ),
            ),
          ),
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              await context.read<ExpenseProvider>().load();
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.l, Gap.s, Gap.l, 0),
              child: _BalanceCard(
                balance: expenses.balance,
                income: expenses.totalIncome,
                expense: expenses.totalExpense,
              ),
            ),
          ),
          if (expenses.loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CupertinoActivityIndicator()),
            )
          else if (expenses.items.isEmpty)
            SliverToBoxAdapter(
              child: EmptyState(
                icon: CupertinoIcons.tray,
                title: 'No transactions yet',
                message:
                    'Add your first income or expense to start seeing where your money goes.',
                action: CupertinoButton.tinted(
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => showAddTransaction(context),
                  child: const Text('Add Transaction'),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: CupertinoListSection.insetGrouped(
                header: Text('RECENT · ${expenses.items.length}'),
                hasLeading: true,
                additionalDividerMargin: 8,
                children: [for (final e in expenses.items) TransactionTile(e)],
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: Gap.xxl)),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expense,
  });

  final double balance;
  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    const white = CupertinoColors.white;
    return Container(
      padding: const EdgeInsets.all(Gap.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.heroGradient.last.withValues(alpha: 0.30),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Total balance',
                style: TextStyle(
                  color: white.withValues(alpha: 0.85),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                CupertinoIcons.creditcard_fill,
                color: white.withValues(alpha: 0.85),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          TweenAnimationBuilder<double>(
            tween: Tween(end: balance),
            duration: MediaQuery.of(context).disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                Fmt.money(v),
                style: const TextStyle(
                  color: white,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  fontFeatures: tabular,
                ),
              ),
            ),
          ),
          const SizedBox(height: Gap.xl),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  icon: CupertinoIcons.arrow_down_left,
                  label: 'Income',
                  value: income,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: white.withValues(alpha: 0.25),
              ),
              const SizedBox(width: Gap.l),
              Expanded(
                child: _Stat(
                  icon: CupertinoIcons.arrow_up_right,
                  label: 'Expenses',
                  value: expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    const white = CupertinoColors.white;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: white, size: 16),
        ),
        const SizedBox(width: Gap.s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  Fmt.money(value),
                  style: const TextStyle(
                    color: white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFeatures: tabular,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
