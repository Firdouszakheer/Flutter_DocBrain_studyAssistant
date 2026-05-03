import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/ai_service.dart';
import '../utils/theme.dart';

class InsightsView extends StatelessWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final aiService = context.watch<AIService>();

    if (aiService.isLoadingInsights) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    AlwaysStoppedAnimation(DocBrainTheme.neonOrange),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'EXTRACTING INSIGHTS',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 13,
                color: DocBrainTheme.neonOrange,
                letterSpacing: 3,
              ),
            ).animate().shimmer(
                  duration: 1500.ms,
                  color: DocBrainTheme.neonOrange.withOpacity(0.8),
                ),
          ],
        ),
      );
    }

    if (aiService.keyInsights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline_rounded,
                    size: 56, color: DocBrainTheme.neonOrange.withOpacity(0.3))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 2000.ms,
                ),
            const SizedBox(height: 16),
            Text(
              'Key Insights',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DocBrainTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Upload a document and tap\n"Key Insights" to extract intelligence',
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          if (aiService.docStats.isNotEmpty) ...[
            Text(
              'DOCUMENT ANALYSIS',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 11,
                color: DocBrainTheme.neonOrange,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                _StatCard(
                  label: 'READING TIME',
                  value: aiService.docStats['readingTime']?.toString() ?? '—',
                  color: DocBrainTheme.neonCyan,
                  icon: Icons.timer_outlined,
                ),
                _StatCard(
                  label: 'COMPLEXITY',
                  value: aiService.docStats['complexity']?.toString() ?? '—',
                  color: DocBrainTheme.neonPurple,
                  icon: Icons.analytics_outlined,
                ),
                _StatCard(
                  label: 'MAIN TOPIC',
                  value: aiService.docStats['mainTopic']?.toString() ?? '—',
                  color: DocBrainTheme.neonOrange,
                  icon: Icons.topic_outlined,
                ),
                _StatCard(
                  label: 'SENTIMENT',
                  value: aiService.docStats['sentiment']?.toString() ?? '—',
                  color: DocBrainTheme.neonGreen,
                  icon: Icons.sentiment_satisfied_outlined,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Key insights
          Text(
            'KEY INSIGHTS',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 11,
              color: DocBrainTheme.neonOrange,
              letterSpacing: 2,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 14),
          ...aiService.keyInsights.asMap().entries.map(
                (e) => _InsightCard(
                  index: e.key,
                  text: e.value,
                ).animate().fadeIn(
                      delay: Duration(milliseconds: 100 * e.key),
                      duration: 400.ms,
                    ).slideX(begin: 0.1, end: 0),
              ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 8,
                    color: DocBrainTheme.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Exo 2',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }
}

class _InsightCard extends StatelessWidget {
  final int index;
  final String text;

  const _InsightCard({required this.index, required this.text});

  static const List<Color> _colors = [
    DocBrainTheme.neonCyan,
    DocBrainTheme.neonPurple,
    DocBrainTheme.neonPink,
    DocBrainTheme.neonGreen,
    DocBrainTheme.neonOrange,
    DocBrainTheme.neonCyan,
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DocBrainTheme.bgCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 14,
                color: DocBrainTheme.textSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
