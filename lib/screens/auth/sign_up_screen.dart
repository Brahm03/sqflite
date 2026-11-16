import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/form_field_row.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    for (final c in [_name, _lastName, _email, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.mediumImpact();
    await context.read<AuthProvider>().signUp(
      name: _name.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim(),
      password: _password.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select<AuthProvider, bool>((a) => a.busy);

    return CupertinoPageScaffold(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          slivers: [
            SliverSafeArea(
              bottom: false,
              sliver: SliverToBoxAdapter(child: _Header()),
            ),
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    children: [
                      CupertinoFormSection.insetGrouped(
                        header: const Text('PROFILE'),
                        children: [
                          FormFieldRow(
                            label: 'First name',
                            controller: _name,
                            placeholder: 'Required',
                            capitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.givenName],
                            validator: (v) =>
                                v.isEmpty ? 'Enter your first name' : null,
                          ),
                          FormFieldRow(
                            label: 'Last name',
                            controller: _lastName,
                            placeholder: 'Required',
                            capitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.familyName],
                            validator: (v) =>
                                v.isEmpty ? 'Enter your last name' : null,
                          ),
                        ],
                      ),
                      CupertinoFormSection.insetGrouped(
                        header: const Text('ACCOUNT'),
                        footer: const Text(
                          'Your passcode is numbers only and is stored on this device.',
                        ),
                        children: [
                          FormFieldRow(
                            label: 'Email',
                            controller: _email,
                            placeholder: 'name@example.com',
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            validator: (v) {
                              if (v.isEmpty) return 'Enter your email';
                              if (!_emailRe.hasMatch(v)) {
                                return 'That doesn’t look like an email — check for typos';
                              }
                              return null;
                            },
                          ),
                          FormFieldRow(
                            label: 'Passcode',
                            controller: _password,
                            placeholder: '4+ digits',
                            obscure: true,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(12),
                            ],
                            onSubmitted: (_) => _submit(),
                            validator: (v) =>
                                v.length < 4 ? 'Use at least 4 digits' : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverSafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(Gap.xl, Gap.xl, Gap.xl, Gap.l),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 54,
                  child: CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(14),
                    onPressed: busy ? null : _submit,
                    child: busy
                        ? const CupertinoActivityIndicator(
                            color: CupertinoColors.white,
                          )
                        : const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.xxl, Gap.xl, Gap.s),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.heroGradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.heroGradient.first.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.creditcard_fill,
              color: CupertinoColors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: Gap.xl),
          Text(
            'Welcome to Ledger',
            textAlign: TextAlign.center,
            style: CupertinoTheme.of(
              context,
            ).textTheme.navLargeTitleTextStyle.copyWith(fontSize: 32),
          ),
          const SizedBox(height: Gap.s),
          Text(
            'Track every income and expense in one calm, simple place.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              height: 1.35,
              color: AppColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}
