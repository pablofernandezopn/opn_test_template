import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.label, super.key,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.suffixIconOnTap,
    this.validator,
    this.error = false,
    this.controller
  });

  final String label;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? suffixIconOnTap;
  final FormFieldValidator<String>? validator;
  final bool error;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller ?? TextEditingController(),
          textCapitalization: textCapitalization,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
          textInputAction: TextInputAction.next,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
          decoration: InputDecoration(
            suffixIcon: InkWell(
              onTap: suffixIconOnTap,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(suffixIcon, size: 24),
              ),
            ),
            labelText: label,
            labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: error ? colorScheme.error : colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
