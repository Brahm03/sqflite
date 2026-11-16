import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final ok = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Log out?'),
        message: const Text(
          'Your profile will be removed from this device. Your transactions stay saved.',
        ),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AuthProvider>().logOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final count = context.select<ExpenseProvider, int>((p) => p.items.length);
    final balance = context.select<ExpenseProvider, double>((p) => p.balance);

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Profile'),
            border: null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Gap.l),
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.heroGradient,
                      ),
                    ),
                    child: Text(
                      user?.initials ?? '',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: Gap.m),
                  Text(
                    user?.fullName ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Gap.xs),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: CupertinoListSection.insetGrouped(
              header: const Text('ACCOUNT'),
              children: [
                _InfoTile(
                  icon: CupertinoIcons.person_fill,
                  color: CupertinoColors.systemBlue,
                  title: 'Name',
                  value: user?.fullName ?? '',
                ),
                _InfoTile(
                  icon: CupertinoIcons.mail_solid,
                  color: CupertinoColors.systemTeal,
                  title: 'Email',
                  value: user?.email ?? '',
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: CupertinoListSection.insetGrouped(
              header: const Text('ACTIVITY'),
              children: [
                _InfoTile(
                  icon: CupertinoIcons.list_bullet,
                  color: CupertinoColors.systemOrange,
                  title: 'Transactions',
                  value: '$count',
                ),
                _InfoTile(
                  icon: CupertinoIcons.money_dollar_circle_fill,
                  color: CupertinoColors.systemGreen,
                  title: 'Balance',
                  value: Fmt.money(balance),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  onTap: () => _confirmLogout(context),
                  title: Center(
                    child: Text(
                      'Log Out',
                      style: TextStyle(
                        color: AppColors.expense.resolveFrom(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Gap.xxl)),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      leading: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(color, context),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, color: CupertinoColors.white, size: 17),
      ),
      title: Text(title),
      additionalInfo: Text(
        value,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontFeatures: tabular),
      ),
    );
  }
}
