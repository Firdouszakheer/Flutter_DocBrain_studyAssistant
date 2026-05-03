import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/ai_service.dart';
import '../utils/theme.dart';

class SummaryView extends StatelessWidget {
  const SummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final aiService = context.watch<AIService>();

    if (aiService.isLoadingSummary) {
      return const _LoadingState(
        label: 'GENERATING SUMMARY',
        color: DocBrainTheme.neonCyan,
      );
    }

    if (aiService.summary.isEmpty) {
      return const _EmptyState(
        icon: Icons.auto_awesome_rounded,
        title: 'Document Summary',
        subtitle:
            'Upload a document and tap\n"Summarize" to generate a summary',
        color: DocBrainTheme.neonCyan,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AI SUMMARY',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: DocBrainTheme.neonCyan,
                letterSpacing: 2,
              ),
            ),
            _CopyButton(text: aiService.summary),
          ],
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: DocBrainTheme.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DocBrainTheme.neonCyan.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: DocBrainTheme.neonCyan.withOpacity(0.05),
                blurRadius: 20,
              ),
            ],
          ),
          child: MarkdownBody(
            data: aiService.summary,
            styleSheet: MarkdownStyleSheet(
              h1: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: DocBrainTheme.neonCyan,
              ),
              h2: TextStyle(
                fontFamily: 'Exo 2',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DocBrainTheme.neonPurple,
              ),
              h3: TextStyle(
                fontFamily: 'Exo 2',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DocBrainTheme.textPrimary,
              ),
              p: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 14,
                color: DocBrainTheme.textSecondary,
                height: 1.7,
              ),
              listBullet: TextStyle(
                color: DocBrainTheme.neonCyan,
                fontSize: 14,
              ),
              strong: TextStyle(
                fontFamily: 'Exo 2',
                fontWeight: FontWeight.w700,
                color: DocBrainTheme.textPrimary,
              ),
              code: TextStyle(
                fontFamily: 'Courier',
                fontSize: 12,
                color: DocBrainTheme.neonGreen,
                backgroundColor: DocBrainTheme.bgCardLight,
              ),
              blockquote: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 14,
                color: DocBrainTheme.neonCyan,
                fontStyle: FontStyle.italic,
              ),
              blockquoteDecoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: DocBrainTheme.neonCyan,
                    width: 3,
                  ),
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0),
      ],
    );
  }
}

class _CopyButton extends StatefulWidget {
  final String text;

  const _CopyButton({required this.text});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Copy to clipboard
        setState(() => _copied = true);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _copied = false);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: DocBrainTheme.neonCyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: DocBrainTheme.neonCyan.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              _copied ? Icons.check : Icons.copy,
              size: 14,
              color: DocBrainTheme.neonCyan,
            ),
            const SizedBox(width: 6),
            Text(
              _copied ? 'COPIED' : 'COPY',
              style: TextStyle(
                fontFamily: 'Exo 2',
                fontSize: 11,
                color: DocBrainTheme.neonCyan,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  final String label;
  final Color color;

  const _LoadingState({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 13,
              color: color,
              letterSpacing: 3,
            ),
          ).animate().shimmer(
                duration: 1500.ms,
                color: color.withOpacity(0.8),
              ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: color.withOpacity(0.3))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 2000.ms,
              ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: DocBrainTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 14,
              color: DocBrainTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
