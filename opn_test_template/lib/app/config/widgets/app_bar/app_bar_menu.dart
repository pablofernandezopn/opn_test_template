import 'package:flutter/material.dart';

class AppBarMenu extends StatefulWidget implements PreferredSizeWidget {
  const AppBarMenu({
    super.key,
    this.title,
    this.actions,
    this.onBack,
    this.leadingIcon,
    this.titleStyle,
  });

  final String? title;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final Widget? leadingIcon; // Customizable leading icon
  final TextStyle? titleStyle; // Customizable title style

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AppBarMenu> createState() => _AppBarMenuState();
}

class _AppBarMenuState extends State<AppBarMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _logoAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colors.surface,
      elevation: 2, // Subtle shadow for depth
      shadowColor: colors.onSurface.withOpacity(0.1), // Soft shadow
      surfaceTintColor: Colors.transparent, // Prevent tint overlay
      leading: Navigator.canPop(context)
          ? IconButton(
        icon: widget.leadingIcon ??
            Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colors.onSurface,
              size: 24,
            ),
        onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        splashRadius: 20, // Smaller splash for elegance
        tooltip: 'Back', // Accessibility
      )
          : null,
      titleSpacing: 8, // Adjusted for better spacing
      title: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _logoAnimation,
            builder: (context, _) => Transform.scale(
              scale: _logoAnimation.value,
              child: Image.asset(
                'assets/images/opn_logos/opn-logo-shadow.png',
                width: 32, // Slightly smaller for elegance
                height: 32,
              ),
            ),
          ),
          if (widget.title != null) ...[
            const SizedBox(width: 8), // Space between logo and title
            Flexible(
              child: Text(
                widget.title!,
                style: widget.titleStyle ??
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                      fontSize: 18, // Slightly smaller for refinement
                    ),
                overflow: TextOverflow.ellipsis, // Handle long titles
              ),
            ),
          ],
        ],
      ),
      actions: widget.actions,
    );
  }
}