import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/ai_service.dart';
import '../services/document_service.dart';
import '../models/document_model.dart';
import '../utils/theme.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestions = [
    'Summarize the main argument',
    'What are the key concepts?',
    'Explain the most complex part',
    'What conclusions were drawn?',
    'List the important dates',
    'Who are the main figures?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;
    final docService = context.read<DocumentService>();
    final aiService = context.read<AIService>();

    if (docService.currentDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please upload a document first',
            style: TextStyle(fontFamily: 'Rajdhani'),
          ),
          backgroundColor: DocBrainTheme.neonPink,
        ),
      );
      return;
    }

    _controller.clear();
    aiService.chat(message, docService.currentDocument!.content);

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiService = context.watch<AIService>();
    final docService = context.watch<DocumentService>();
    final hasDoc = docService.hasDocument;

    return Column(
      children: [
        // Chat header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ASK AI',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: DocBrainTheme.neonGreen,
                letterSpacing: 2,
              ),
            ),
            if (aiService.chatHistory.isNotEmpty)
              GestureDetector(
                onTap: aiService.clearChat,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: DocBrainTheme.neonPink.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'CLEAR',
                    style: TextStyle(
                      fontFamily: 'Exo 2',
                      fontSize: 10,
                      color: DocBrainTheme.neonPink,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
          ],
        ).animate().fadeIn(),
        const SizedBox(height: 16),

        // Messages list
        Expanded(
          child: aiService.chatHistory.isEmpty
              ? _EmptyChatState(
                  hasDoc: hasDoc,
                  suggestions: _suggestions,
                  onSuggestionTap: _sendMessage,
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: aiService.chatHistory.length +
                      (aiService.isLoadingChat ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == aiService.chatHistory.length) {
                      return _TypingIndicator();
                    }
                    final msg = aiService.chatHistory[index];
                    return _MessageBubble(message: msg)
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.1, end: 0);
                  },
                ),
        ),

        const SizedBox(height: 12),

        // Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: hasDoc && !aiService.isLoadingChat,
                onSubmitted: _sendMessage,
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontSize: 14,
                  color: DocBrainTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: hasDoc
                      ? 'Ask about the document...'
                      : 'Upload a document first',
                  hintStyle: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 13,
                    color: DocBrainTheme.textSecondary,
                  ),
                  filled: true,
                  fillColor: DocBrainTheme.bgCardLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: DocBrainTheme.borderGlow),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: DocBrainTheme.borderGlow),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: DocBrainTheme.neonGreen, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _sendMessage(_controller.text),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: DocBrainTheme.neonGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: DocBrainTheme.neonGreen.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: DocBrainTheme.neonGreen.withOpacity(0.2),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: DocBrainTheme.neonGreen,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: DocBrainTheme.neonGreen.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: DocBrainTheme.neonGreen.withOpacity(0.4)),
              ),
              child: Icon(Icons.psychology,
                  color: DocBrainTheme.neonGreen, size: 18),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser
                    ? DocBrainTheme.neonGreen.withOpacity(0.12)
                    : DocBrainTheme.bgCardLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                border: Border.all(
                  color: isUser
                      ? DocBrainTheme.neonGreen.withOpacity(0.3)
                      : DocBrainTheme.borderGlow,
                ),
              ),
              child: isUser
                  ? Text(
                      message.content,
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 14,
                        color: DocBrainTheme.textPrimary,
                        height: 1.5,
                      ),
                    )
                  : MarkdownBody(
                      data: message.content,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontSize: 14,
                          color: DocBrainTheme.textSecondary,
                          height: 1.6,
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
                          backgroundColor: DocBrainTheme.bgCard,
                        ),
                        h2: TextStyle(
                          fontFamily: 'Exo 2',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: DocBrainTheme.neonGreen,
                        ),
                      ),
                    ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: DocBrainTheme.neonGreen.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: DocBrainTheme.neonGreen.withOpacity(0.4)),
              ),
              child: Icon(Icons.person,
                  color: DocBrainTheme.neonGreen, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: DocBrainTheme.neonGreen.withOpacity(0.15),
            shape: BoxShape.circle,
            border:
                Border.all(color: DocBrainTheme.neonGreen.withOpacity(0.4)),
          ),
          child: Icon(Icons.psychology,
              color: DocBrainTheme.neonGreen, size: 18),
        ),
        const SizedBox(width: 10),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              children: List.generate(3, (i) {
                return Container(
                  margin: const EdgeInsets.only(right: 4),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: DocBrainTheme.neonGreen.withOpacity(
                        (i == 0
                                ? _controller.value
                                : i == 1
                                    ? (_controller.value + 0.3) % 1
                                    : (_controller.value + 0.6) % 1)
                            .clamp(0.2, 1.0)),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  final bool hasDoc;
  final List<String> suggestions;
  final Function(String) onSuggestionTap;

  const _EmptyChatState({
    required this.hasDoc,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.chat_bubble_outline_rounded,
          size: 48,
          color: DocBrainTheme.neonGreen.withOpacity(0.3),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.08, 1.08),
              duration: 2000.ms,
            ),
        const SizedBox(height: 14),
        Text(
          hasDoc ? 'Ask anything about your document' : 'Upload a document to start chatting',
          style: TextStyle(
            fontFamily: 'Exo 2',
            fontSize: 14,
            color: DocBrainTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        if (hasDoc) ...[
          const SizedBox(height: 20),
          Text(
            'SUGGESTED QUESTIONS',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10,
              color: DocBrainTheme.textSecondary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: suggestions.map((s) {
              return GestureDetector(
                onTap: () => onSuggestionTap(s),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: DocBrainTheme.neonGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: DocBrainTheme.neonGreen.withOpacity(0.25)),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 12,
                      color: DocBrainTheme.neonGreen,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
