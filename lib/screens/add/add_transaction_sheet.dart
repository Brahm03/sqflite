import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/categories.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/common.dart';

Future<void> showAddTransaction(BuildContext context) {
  HapticFeedback.lightImpact();
  return showCupertinoSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => const AddTransactionSheet(),
  );
}

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _income = false;
  String _type = Categories.expense.first.name;
  bool _saving = false;

  double? get _value => double.tryParse(_amount.text.replaceAll(',', '.'));
  bool get _valid => (_value ?? 0) > 0;

  List<Category> get _cats => _income ? Categories.income : Categories.expense;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_valid || _saving) return;
    setState(() => _saving = true);
    await context.read<ExpenseProvider>().add(
      price: _value!,
      note: _note.text.trim(),
      type: _type,
      income: _income,
    );
    HapticFeedback.mediumImpact();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tone = _income ? AppColors.income : AppColors.expense;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        border: null,
        backgroundColor: AppColors.background,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        middle: const Text('New Transaction'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _valid && !_saving ? _save : null,
          child: _saving
              ? const CupertinoActivityIndicator()
              : const Text(
                  'Add',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(vertical: Gap.l),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.l),
              child: CupertinoSlidingSegmentedControl<bool>(
                groupValue: _income,
                children: const {
                  false: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Expense'),
                  ),
                  true: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Income'),
                  ),
                },
                onValueChanged: (v) {
                  if (v == null) return;
                  HapticFeedback.selectionClick();
                  setState(() {
                    _income = v;
                    _type = _cats.first.name;
                  });
                },
              ),
            ),
            const SizedBox(height: Gap.xxl),
            // Big amount input
            Column(
              children: [
                Text(
                  'AMOUNT',
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 0.5,
                    color: AppColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
                  child: CupertinoTextField.borderless(
                    controller: _amount,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*[.,]?\d{0,2}'),
                      ),
                    ],
                    placeholder: '0.00',
                    prefix: Text(
                      Fmt.currency,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tertiaryLabel.resolveFrom(context),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                      fontFeatures: tabular,
                      color: tone.resolveFrom(context),
                    ),
                    placeholderStyle: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                      color: AppColors.tertiaryLabel.resolveFrom(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.xl),
            _SectionLabel('CATEGORY'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.l),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: GridView.count(
                  key: ValueKey(_income),
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: Gap.s,
                  crossAxisSpacing: Gap.s,
                  childAspectRatio: 0.9,
                  children: [
                    for (final c in _cats)
                      _CategoryChip(
                        category: c,
                        selected: c.name == _type,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _type = c.name);
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Gap.l),
            CupertinoListSection.insetGrouped(
              header: const Text('NOTE'),
              children: [
                CupertinoTextField.borderless(
                  controller: _note,
                  placeholder: 'What was it for? (optional)',
                  padding: const EdgeInsets.symmetric(
                    horizontal: Gap.l,
                    vertical: 14,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  maxLength: 60,
                  onSubmitted: (_) => _save(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(36, 0, Gap.l, Gap.s),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: AppColors.secondaryLabel.resolveFrom(context),
      ),
    ),
  );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = CupertinoDynamicColor.resolve(category.color, context);
    return Semantics(
      button: true,
      selected: selected,
      label: category.name,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.14)
                : AppColors.surface.resolveFrom(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : const Color(0x00000000),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CategoryIcon(category, size: 36),
              const SizedBox(height: 6),
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: AppColors.label.resolveFrom(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
