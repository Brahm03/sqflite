import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';

/// iOS-Settings style form row: label on the left, input on the right,
/// error text directly under the row.
class FormFieldRow extends StatefulWidget {
  const FormFieldRow({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.inputFormatters,
    this.obscure = false,
    this.capitalization = TextCapitalization.none,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final String? Function(String)? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscure;
  final TextCapitalization capitalization;
  final ValueChanged<String>? onSubmitted;

  @override
  State<FormFieldRow> createState() => _FormFieldRowState();
}

class _FormFieldRowState extends State<FormFieldRow> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.controller.text,
      validator: (_) => widget.validator?.call(widget.controller.text.trim()),
      builder: (field) {
        return CupertinoFormRow(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 6, 6, 6),
          prefix: SizedBox(
            width: 92,
            child: Text(widget.label, style: const TextStyle(fontSize: 17)),
          ),
          error: field.errorText == null
              ? null
              : Row(
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_circle_fill,
                      size: 14,
                      color: AppColors.expense,
                    ),
                    const SizedBox(width: Gap.xs),
                    Flexible(child: Text(field.errorText!)),
                  ],
                ),
          child: CupertinoTextField.borderless(
            controller: widget.controller,
            placeholder: widget.placeholder,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            inputFormatters: widget.inputFormatters,
            obscureText: _hidden,
            textCapitalization: widget.capitalization,
            autocorrect: false,
            padding: const EdgeInsets.symmetric(vertical: 10),
            style: const TextStyle(fontSize: 17),
            onChanged: (v) {
              field.didChange(v);
              if (field.hasError) field.validate();
            },
            onSubmitted: widget.onSubmitted,
            suffix: widget.obscure
                ? CupertinoButton(
                    padding: const EdgeInsets.all(10),
                    minimumSize: const Size(44, 44),
                    onPressed: () => setState(() => _hidden = !_hidden),
                    child: Icon(
                      _hidden ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                      size: 20,
                      color: AppColors.secondaryLabel,
                      semanticLabel: _hidden
                          ? 'Show passcode'
                          : 'Hide passcode',
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
