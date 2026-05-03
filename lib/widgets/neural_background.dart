import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class NeuralNetworkPainter extends CustomPainter {
  final double animationValue;
  final List<Offset> nodes;
  final Random _random = Random(42);

  NeuralNetworkPainter({required this.animationValue, required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw connections
    final linePaint = Paint()
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final dist = (nodes[i] - nodes[j]).distance;
        if (dist < size.width * 0.25) {
          final opacity = (1 - dist / (size.width * 0.25)) * 0.3;
          final pulse = sin(animationValue * 2 * pi + i * 0.5) * 0.5 + 0.5;

          linePaint.color = Color.lerp(
            DocBrainTheme.neonCyan.withOpacity(opacity * 0.5),
            DocBrainTheme.neonPurple.withOpacity(opacity * 0.5),
            pulse,
          )!;

          canvas.drawLine(
            _getAnimatedNode(nodes[i], i, size),
            _getAnimatedNode(nodes[j], j, size),
            linePaint,
          );
        }
      }
    }

    // Draw nodes
    final nodePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < nodes.length; i++) {
      final animatedPos = _getAnimatedNode(nodes[i], i, size);
      final pulse = sin(animationValue * 2 * pi + i * 0.7) * 0.5 + 0.5;
      final radius = 2.0 + pulse * 2.0;

      // Glow
      nodePaint.color = DocBrainTheme.neonCyan.withOpacity(0.1 + pulse * 0.1);
      canvas.drawCircle(animatedPos, radius * 3, nodePaint);

      // Core
      nodePaint.color = Color.lerp(
        DocBrainTheme.neonCyan,
        DocBrainTheme.neonPurple,
        (i % 3) / 2.0,
      )!
          .withOpacity(0.6 + pulse * 0.4);
      canvas.drawCircle(animatedPos, radius, nodePaint);
    }

    // Draw traveling particles on connections
    _drawParticles(canvas, size);
  }

  Offset _getAnimatedNode(Offset base, int index, Size size) {
    final floatX = sin(animationValue * 2 * pi + index * 1.1) * 3;
    final floatY = cos(animationValue * 2 * pi + index * 0.9) * 3;
    return Offset(
      (base.dx * size.width + floatX).clamp(0, size.width),
      (base.dy * size.height + floatY).clamp(0, size.height),
    );
  }

  void _drawParticles(Canvas canvas, Size size) {
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < nodes.length; i += 3) {
      if (i + 1 < nodes.length) {
        final start = _getAnimatedNode(nodes[i], i, size);
        final end = _getAnimatedNode(nodes[i + 1], i + 1, size);

        final t = (animationValue + i * 0.15) % 1.0;
        final particlePos = Offset.lerp(start, end, t)!;

        final pulse = sin(animationValue * 6 * pi) * 0.5 + 0.5;
        particlePaint.color = DocBrainTheme.neonGreen.withOpacity(0.8 * pulse);
        canvas.drawCircle(particlePos, 1.5, particlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(NeuralNetworkPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class NeuralBackground extends StatefulWidget {
  const NeuralBackground({super.key});

  @override
  State<NeuralBackground> createState() => _NeuralBackgroundState();
}

class _NeuralBackgroundState extends State<NeuralBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Offset> _nodes;
  final Random _random = Random(42);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Generate fixed node positions (normalized 0-1)
    _nodes = List.generate(
      50,
      (_) => Offset(_random.nextDouble(), _random.nextDouble()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: NeuralNetworkPainter(
            animationValue: _controller.value,
            nodes: _nodes,
          ),
          child: Container(),
        );
      },
    );
  }
}
