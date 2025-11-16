import 'package:flutter/material.dart';


class HideKeyboard extends StatelessWidget {
  const HideKeyboard({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
