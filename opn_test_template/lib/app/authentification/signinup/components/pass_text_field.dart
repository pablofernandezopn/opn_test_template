import 'package:flutter/material.dart';
import 'package:opn_test_template/app/authentification/signinup/components/text_field.dart';
import '../../../config/theme/app_icons.dart';



class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    required this.label, super.key,
    this.onChanged,
    this.validator,
    this.error = false,
    this.controller
  });

  final TextEditingController? controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool error;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      label: widget.label,
      keyboardType: TextInputType.visiblePassword,
      obscureText: obscureText,
      validator: widget.validator,
      suffixIcon: obscureText ? AppIcons.lockIcon : AppIcons.unlockIcon,
      suffixIconOnTap: () => setState(() => obscureText = !obscureText),
      onChanged: widget.onChanged,
      error: widget.error,
    );
  }
}
