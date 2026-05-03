import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';

class NeonButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isActive;
  final double? width;

  const NeonButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.isLoading = false,
    this.isActive = false,
    this.width,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onTap,
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            final glowOpacity = widget.isActive
                ? 0.4 + _glowController.value * 0.3
                : _isHovered
                    ? 0.3
                    : 0.15;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.width,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: widget.isActive
                    ? widget.color.withOpacity(0.15)
                    : _isHovered
                        ? widget.color.withOpacity(0.1)
                        : DocBrainTheme.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.color.withOpacity(
                    widget.isActive ? 0.8 : _isHovered ? 0.6 : 0.3,
                  ),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(glowOpacity),
                    blurRadius: widget.isActive ? 20 : _isHovered ? 15 : 8,
                    spreadRadius: widget.isActive ? 2 : 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(widget.color),
                      ),
                    )
                  else
                    Icon(widget.icon, color: widget.color, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontFamily: 'Exo 2',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: widget.isActive ? widget.color : DocBrainTheme.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }
}

class GlowingCard extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final EdgeInsets? padding;
  final double borderRadius;

  const GlowingCard({
    super.key,
    required this.child,
    this.glowColor,
    this.padding,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DocBrainTheme.bgCard,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: (glowColor ?? DocBrainTheme.neonCyan).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (glowColor ?? DocBrainTheme.neonCyan).withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

class ScanlineOverlay extends StatelessWidget {
  const ScanlineOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: List.generate(
              30,
              (i) => i % 2 == 0
                  ? Colors.transparent
                  : Colors.black.withOpacity(0.03),
            ),
          ),
        ),
      ),
    );
  }
}
