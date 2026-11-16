import 'package:flutter/cupertino.dart';

import '../core/app_theme.dart';
import '../core/categories.dart';
import '../utils/database_service.dart';

/// Rounded-square tinted icon like the ones in iOS Settings / Wallet.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon(this.category, {super.key, this.size = 40});
  final Category category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = CupertinoDynamicColor.resolve(category.color, context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        category.icon,
        color: CupertinoColors.white,
        size: size * 0.52,
      ),
    );
  }
}

/// Subtle scale-down on press (0.97) – iOS-like tactile feedback.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, required this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down && !reduce ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _down ? 0.85 : 1,
          duration: const Duration(milliseconds: 120),
          child: widget.child,
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  const TransactionTile(this.item, {super.key});
  final ExpenseModel item;

  @override
  Widget build(BuildContext context) {
    final cat = Categories.of(item.type, income: item.income);
    final amountColor = item.income
        ? AppColors.income.resolveFrom(context)
        : AppColors.label.resolveFrom(context);

    return CupertinoListTile(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 10),
      leadingSize: 40,
      leading: CategoryIcon(cat),
      title: Text(
        item.note.isEmpty ? cat.name : item.note,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('${cat.name} · ${item.income ? 'Income' : 'Expense'}'),
      trailing: Text(
        Fmt.money(item.price, signed: true, income: item.income),
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: amountColor,
          fontFeatures: tabular,
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.xxl, vertical: 48),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.fill.resolveFrom(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: AppColors.secondaryLabel.resolveFrom(context),
            ),
          ),
          const SizedBox(height: Gap.l),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: Gap.s),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppColors.secondaryLabel.resolveFrom(context),
            ),
          ),
          if (action != null) ...[const SizedBox(height: Gap.xl), action!],
        ],
      ),
    );
  }
}
