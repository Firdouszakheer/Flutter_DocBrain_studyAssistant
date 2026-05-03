import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../services/ai_service.dart';
import '../utils/theme.dart';
import 'neon_button.dart';

class QuizView extends StatefulWidget {
  const QuizView({super.key});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  int _currentQuestion = 0;
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    final aiService = context.watch<AIService>();

    if (aiService.isLoadingQuiz) {
      return _LoadingState(
        label: 'GENERATING QUIZ',
        color: DocBrainTheme.neonPink,
      );
    }

    if (aiService.questions.isEmpty) {
      return _EmptyState(
        icon: Icons.quiz_rounded,
        title: 'Quiz Generator',
        subtitle: 'Upload a document and tap\n"Generate MCQs" to create a quiz',
        color: DocBrainTheme.neonPink,
      );
    }

    if (_showResult || aiService.quizCompleted) {
      return _ResultsView(
        aiService: aiService,
        onRetry: () => setState(() {
          _showResult = false;
          _currentQuestion = 0;
        }),
      );
    }

    final question = aiService.questions[_currentQuestion];
    final total = aiService.questions.length;
    final progress = _currentQuestion / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'QUESTION ${_currentQuestion + 1} OF $total',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 11,
                color: DocBrainTheme.neonPink,
                letterSpacing: 2,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _showResult = true),
              child: Text(
                'View Results',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 12,
                  color: DocBrainTheme.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: DocBrainTheme.bgCardLight,
            valueColor: AlwaysStoppedAnimation(DocBrainTheme.neonPink),
            minHeight: 4,
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 24),

        // Question card
        GlowingCard(
          glowColor: DocBrainTheme.neonPink,
          child: Text(
            question.question,
            style: TextStyle(
              fontFamily: 'Exo 2',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DocBrainTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0),

        const SizedBox(height: 16),

        // Options
        ...List.generate(
          question.options.length,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OptionTile(
              label: String.fromCharCode(65 + i), // A, B, C, D
              text: question.options[i],
              isSelected: question.selectedIndex == i,
              isCorrect: question.isAnswered && i == question.correctIndex,
              isWrong: question.isAnswered &&
                  question.selectedIndex == i &&
                  i != question.correctIndex,
              onTap: question.isAnswered
                  ? null
                  : () {
                      aiService.answerQuestion(_currentQuestion, i);
                    },
            ).animate().fadeIn(
                  delay: Duration(milliseconds: 100 * i),
                  duration: 300.ms,
                ),
          ),
        ),

        // Explanation
        if (question.isAnswered) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (question.isCorrect
                      ? DocBrainTheme.neonGreen
                      : DocBrainTheme.neonPink)
                  .withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (question.isCorrect
                        ? DocBrainTheme.neonGreen
                        : DocBrainTheme.neonPink)
                    .withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  question.isCorrect
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  color: question.isCorrect
                      ? DocBrainTheme.neonGreen
                      : DocBrainTheme.neonPink,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    question.explanation,
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 13,
                      color: DocBrainTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
        ],

        // Navigation
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentQuestion > 0)
              NeonButton(
                label: 'PREVIOUS',
                icon: Icons.arrow_back_rounded,
                color: DocBrainTheme.textSecondary,
                onTap: () => setState(() => _currentQuestion--),
              )
            else
              const SizedBox(),
            if (_currentQuestion < total - 1)
              NeonButton(
                label: 'NEXT',
                icon: Icons.arrow_forward_rounded,
                color: DocBrainTheme.neonPink,
                onTap: () => setState(() => _currentQuestion++),
              )
            else
              NeonButton(
                label: 'FINISH',
                icon: Icons.flag_rounded,
                color: DocBrainTheme.neonGreen,
                onTap: () => setState(() => _showResult = true),
              ),
          ],
        ),
      ],
    );
  }
}

class _OptionTile extends StatefulWidget {
  final String label;
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    this.onTap,
  });

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> {
  bool _hover = false;

  Color get _borderColor {
    if (widget.isCorrect) return DocBrainTheme.neonGreen;
    if (widget.isWrong) return DocBrainTheme.neonPink;
    if (widget.isSelected) return DocBrainTheme.neonCyan;
    return _hover
        ? DocBrainTheme.neonCyan.withOpacity(0.5)
        : DocBrainTheme.borderGlow;
  }

  Color get _bgColor {
    if (widget.isCorrect) return DocBrainTheme.neonGreen.withOpacity(0.1);
    if (widget.isWrong) return DocBrainTheme.neonPink.withOpacity(0.1);
    if (widget.isSelected) return DocBrainTheme.neonCyan.withOpacity(0.08);
    return _hover ? DocBrainTheme.bgCardLight : DocBrainTheme.bgCard;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _borderColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _borderColor.withOpacity(0.5)),
                ),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _borderColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 14,
                    color: DocBrainTheme.textPrimary,
                    fontWeight: widget.isSelected || widget.isCorrect
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              if (widget.isCorrect)
                Icon(Icons.check_circle,
                    color: DocBrainTheme.neonGreen, size: 20),
              if (widget.isWrong)
                Icon(Icons.cancel, color: DocBrainTheme.neonPink, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  final AIService aiService;
  final VoidCallback onRetry;

  const _ResultsView({required this.aiService, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final score = aiService.quizScore;
    final total = aiService.questions.length;
    final pct = aiService.quizPercentage;

    Color scoreColor;
    String grade;
    if (pct >= 80) {
      scoreColor = DocBrainTheme.neonGreen;
      grade = 'EXCELLENT';
    } else if (pct >= 60) {
      scoreColor = DocBrainTheme.neonCyan;
      grade = 'GOOD';
    } else if (pct >= 40) {
      scoreColor = DocBrainTheme.neonOrange;
      grade = 'FAIR';
    } else {
      scoreColor = DocBrainTheme.neonPink;
      grade = 'NEEDS WORK';
    }

    return Column(
      children: [
        Text(
          'QUIZ RESULTS',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: DocBrainTheme.textPrimary,
            letterSpacing: 3,
          ),
        ).animate().fadeIn().slideY(begin: -0.2),
        const SizedBox(height: 24),
        CircularPercentIndicator(
          radius: 80,
          lineWidth: 10,
          percent: pct / 100,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${pct.round()}%',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: scoreColor,
                ),
              ),
              Text(
                grade,
                style: TextStyle(
                  fontFamily: 'Exo 2',
                  fontSize: 10,
                  color: scoreColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          progressColor: scoreColor,
          backgroundColor: DocBrainTheme.bgCardLight,
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: 1000,
        ).animate().fadeIn(delay: 200.ms).scale(),
        const SizedBox(height: 20),
        Text(
          '$score / $total Correct',
          style: TextStyle(
            fontFamily: 'Exo 2',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DocBrainTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        // Question breakdown
        ...aiService.questions.asMap().entries.map(
              (e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: (e.value.isCorrect
                          ? DocBrainTheme.neonGreen
                          : DocBrainTheme.neonPink)
                      .withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (e.value.isCorrect
                            ? DocBrainTheme.neonGreen
                            : DocBrainTheme.neonPink)
                        .withOpacity(0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      e.value.isCorrect ? Icons.check_circle : Icons.cancel,
                      color: e.value.isCorrect
                          ? DocBrainTheme.neonGreen
                          : DocBrainTheme.neonPink,
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Q${e.key + 1}: ${e.value.question}',
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontSize: 13,
                          color: DocBrainTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 20),
        NeonButton(
          label: 'RETAKE QUIZ',
          icon: Icons.refresh_rounded,
          color: DocBrainTheme.neonPink,
          onTap: onRetry,
          width: double.infinity,
        ),
      ],
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
          const SizedBox(height: 8),
          Text(
            'Powered by Claude AI',
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 12,
              color: DocBrainTheme.textSecondary,
            ),
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
