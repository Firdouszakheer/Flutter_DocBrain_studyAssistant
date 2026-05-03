import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/document_service.dart';
import '../services/ai_service.dart';
import '../utils/theme.dart';
import 'neon_button.dart';

class UploadPanel extends StatefulWidget {
  const UploadPanel({super.key});

  @override
  State<UploadPanel> createState() => _UploadPanelState();
}

class _UploadPanelState extends State<UploadPanel>
    with SingleTickerProviderStateMixin {
  bool _isDragOver = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docService = context.watch<DocumentService>();
    final aiService = context.watch<AIService>();
    final doc = docService.currentDocument;

    return Column(
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: DocBrainTheme.neonCyan,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: DocBrainTheme.neonCyan.withOpacity(0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'UPLOAD DOCUMENT',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: DocBrainTheme.textSecondary,
                letterSpacing: 2,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 16),

        // Drop zone
        if (!docService.hasDocument)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return GestureDetector(
                onTap: docService.pickAndLoadDocument,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isDragOver = true),
                  onExit: (_) => setState(() => _isDragOver = false),
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 160,
                    decoration: BoxDecoration(
                      color: _isDragOver
                          ? DocBrainTheme.neonCyan.withOpacity(0.05)
                          : DocBrainTheme.bgCardLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isDragOver
                            ? DocBrainTheme.neonCyan.withOpacity(0.8)
                            : DocBrainTheme.neonCyan.withOpacity(
                                0.2 + _pulseController.value * 0.15),
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                      boxShadow: _isDragOver
                          ? [
                              BoxShadow(
                                color: DocBrainTheme.neonCyan.withOpacity(0.2),
                                blurRadius: 20,
                              ),
                            ]
                          : [],
                    ),
                    child: docService.isLoading
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                      DocBrainTheme.neonCyan),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'ANALYZING...',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 11,
                                    color: DocBrainTheme.neonCyan,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file_rounded,
                                size: 42,
                                color: DocBrainTheme.neonCyan.withOpacity(
                                    0.5 + _pulseController.value * 0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Drop your file here',
                                style: TextStyle(
                                  fontFamily: 'Exo 2',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: DocBrainTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'PDF • DOCX • TXT • MD',
                                style: TextStyle(
                                  fontFamily: 'Rajdhani',
                                  fontSize: 12,
                                  color: DocBrainTheme.textSecondary,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: DocBrainTheme.neonCyan
                                          .withOpacity(0.4)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'CLICK TO BROWSE',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 9,
                                    color: DocBrainTheme.neonCyan,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

        // Sample doc button
        if (!docService.hasDocument) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: docService.loadSampleDocument,
            child: Text(
              '— or load sample document —',
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 12,
                color: DocBrainTheme.textSecondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],

        // Document loaded state
        if (doc != null) ...[
          _DocumentCard(doc: doc),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              docService.clearDocument();
              aiService.clearAll();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 14, color: DocBrainTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Upload different file',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 12,
                    color: DocBrainTheme.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // AI Actions
        Row(
          children: [
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: DocBrainTheme.neonPurple,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: DocBrainTheme.neonPurple.withOpacity(0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'AI ACTIONS',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: DocBrainTheme.textSecondary,
                letterSpacing: 2,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 14),

        // Action buttons
        _ActionButtons(enabled: docService.hasDocument),
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final dynamic doc;

  const _DocumentCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DocBrainTheme.bgCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DocBrainTheme.neonGreen.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: DocBrainTheme.neonGreen.withOpacity(0.1),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: DocBrainTheme.neonCyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: DocBrainTheme.neonCyan.withOpacity(0.4)),
                ),
                child: Text(
                  doc.type,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 9,
                    color: DocBrainTheme.neonCyan,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  doc.name,
                  style: TextStyle(
                    fontFamily: 'Exo 2',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DocBrainTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: DocBrainTheme.neonGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${doc.wordCount} words',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 11,
                    color: DocBrainTheme.neonGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            doc.preview,
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 12,
              color: DocBrainTheme.textSecondary,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _ActionButtons extends StatelessWidget {
  final bool enabled;

  const _ActionButtons({required this.enabled});

  @override
  Widget build(BuildContext context) {
    final docService = context.watch<DocumentService>();
    final aiService = context.watch<AIService>();
    final doc = docService.currentDocument;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            label: 'GENERATE MCQs',
            icon: Icons.quiz_rounded,
            color: DocBrainTheme.neonPink,
            isLoading: aiService.isLoadingQuiz,
            onTap: enabled && doc != null
                ? () => aiService.generateQuiz(doc.content)
                : null,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            label: 'SUMMARIZE',
            icon: Icons.auto_awesome_rounded,
            color: DocBrainTheme.neonCyan,
            isLoading: aiService.isLoadingSummary,
            onTap: enabled && doc != null
                ? () => aiService.generateSummary(doc.content)
                : null,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            label: 'KEY INSIGHTS',
            icon: Icons.lightbulb_outline_rounded,
            color: DocBrainTheme.neonOrange,
            isLoading: aiService.isLoadingInsights,
            onTap: enabled && doc != null
                ? () => aiService.generateKeyInsights(doc.content)
                : null,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            label: 'ASK AI',
            icon: Icons.chat_bubble_outline_rounded,
            color: DocBrainTheme.neonGreen,
            onTap: enabled ? null : null, // chat is inline
          ),
        ),
      ],
    );
  }
}
