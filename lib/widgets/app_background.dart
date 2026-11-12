import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// A imagem é opcional: caso ainda não exista, o gradiente continua visível.
class AppBackground extends StatelessWidget {
  final String imagePath;
  final Widget child;

  const AppBackground({
    super.key,
    required this.imagePath,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF171034), AppTheme.background, Color(0xFF071B31)],
            ),
          ),
        ),
        Positioned.fill(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.background.withValues(alpha: 0.88),
                  const Color(0xFF170C32).withValues(alpha: 0.81),
                  const Color(0xFF071929).withValues(alpha: 0.89),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
