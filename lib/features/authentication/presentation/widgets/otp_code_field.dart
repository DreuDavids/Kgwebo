import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/validation/auth_validators.dart';
import '../../../../shared/widgets/kgwebo_text_field.dart';

class OtpCodeField extends StatelessWidget {
  const OtpCodeField({
    super.key,
    required this.controller,
    this.errorText,
    this.enabled = true,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return KgweboTextField(
      controller: controller,
      label: '6-character code',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.oneTimeCode],
      errorText: errorText,
      enabled: enabled,
      autocorrect: false,
      enableSuggestions: false,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(authOtpLength),
      ],
      onSubmitted: onSubmitted,
    );
  }
}
