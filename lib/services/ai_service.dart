import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/document_model.dart';

class AIService extends ChangeNotifier {
  // Use a Groq OpenAI-compatible model suitable for document understanding.
  // If you want a heavier model later, replace this with a supported Groq model ID.
  static const String _model = 'llama-3.1-8b-instant';
  static const String _apiBase = 'https://api.groq.com/openai/v1';

  // IMPORTANT: Replace with your actual Groq API key.
  // Get one at https://console.groq.com/keys
  static const String _apiKey =
      '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';

  String _summary = '';
  List<QuizQuestion> _questions = [];
  List<ChatMessage> _chatHistory = [];
  List<String> _keyInsights = [];
  Map<String, dynamic> _docStats = {};

  bool _isLoadingSummary = false;
  bool _isLoadingQuiz = false;
  bool _isLoadingChat = false;
  bool _isLoadingInsights = false;

  String get summary => _summary;
  List<QuizQuestion> get questions => _questions;
  List<ChatMessage> get chatHistory => _chatHistory;
  List<String> get keyInsights => _keyInsights;
  Map<String, dynamic> get docStats => _docStats;

  bool get isLoadingSummary => _isLoadingSummary;
  bool get isLoadingQuiz => _isLoadingQuiz;
  bool get isLoadingChat => _isLoadingChat;
  bool get isLoadingInsights => _isLoadingInsights;

  void clearAll() {
    _summary = '';
    _questions = [];
    _chatHistory = [];
    _keyInsights = [];
    _docStats = {};
    notifyListeners();
  }

  Future<String> _callAPI(String systemPrompt, String userMessage,
      {int maxTokens = 1024}) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBase/responses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'input': userMessage,
          'instructions': systemPrompt,
          'max_output_tokens': maxTokens,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseGroqResponse(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
            'API Error ${response.statusCode}: ${error['message'] ?? error.toString()}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  String _parseGroqResponse(Map<String, dynamic> data) {
    String collectText(dynamic content) {
      if (content is String) return content;
      if (content is Map<String, dynamic>) {
        if (content['text'] is String) return content['text'] as String;
        if (content['content'] != null) return collectText(content['content']);
      }
      if (content is List) {
        return content.map(collectText).join();
      }
      return '';
    }

    if (data['output'] is List && data['output'].isNotEmpty) {
      final outputs = data['output'] as List<dynamic>;
      final buffer = StringBuffer();
      for (final output in outputs) {
        buffer.write(collectText(output));
      }
      final text = buffer.toString().trim();
      if (text.isNotEmpty) return text;
    }

    if (data['choices'] is List && data['choices'].isNotEmpty) {
      final choices = data['choices'] as List<dynamic>;
      final buffer = StringBuffer();
      for (final choice in choices) {
        if (choice is Map<String, dynamic>) {
          final message = choice['message'];
          if (message is Map<String, dynamic>) {
            buffer.write(collectText(message['content']));
          }
          buffer.write(collectText(choice['text']));
        }
      }
      final text = buffer.toString().trim();
      if (text.isNotEmpty) return text;
    }

    if (data['output_text'] is String) {
      return data['output_text'] as String;
    }

    if (data['text'] is String) {
      return data['text'] as String;
    }

    return jsonEncode(data);
  }

  String _extractJsonArray(String text) {
    final start = text.indexOf('[');
    if (start == -1) return text;

    int depth = 0;
    for (int i = start; i < text.length; i++) {
      final char = text[i];
      if (char == '[') {
        depth++;
      } else if (char == ']') {
        depth--;
        if (depth == 0) {
          return text.substring(start, i + 1);
        }
      }
    }

    return text;
  }

  String _repairJsonString(String text) {
    final result = StringBuffer();
    bool inString = false;
    bool escaped = false;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (!escaped && char == '"') {
        inString = !inString;
        result.write(char);
        continue;
      }

      if (inString && !escaped) {
        if (char == '\n') {
          result.write(r'\n');
          continue;
        }
        if (char == '\r') {
          result.write(r'\r');
          continue;
        }
        if (char == '\t') {
          result.write(r'\t');
          continue;
        }
      }

      if (!escaped && char == '\\') {
        escaped = true;
        result.write(char);
        continue;
      }

      result.write(char);
      escaped = escaped && char == '\\';
    }

    return result.toString();
  }

  String _removeTrailingCommas(String json) {
    return json.replaceAllMapped(
      RegExp(r',\s*(?=[}\]])'),
      (m) => '',
    );
  }

  Future<void> generateSummary(String documentContent) async {
    _isLoadingSummary = true;
    _summary = '';
    notifyListeners();

    try {
      final result = await _callAPI(
        '''You are DocBrain, an expert document analyst. Generate a comprehensive, well-structured summary.
Use markdown formatting with ## headers, **bold** for key terms, and bullet points.
Be thorough but concise. Highlight the most important concepts.''',
        '''Analyze and summarize this document comprehensively:

$documentContent

Provide:
1. ## Executive Summary (2-3 sentences)
2. ## Key Topics Covered (bullet points)
3. ## Detailed Summary (structured paragraphs)
4. ## Important Takeaways (bullet points)''',
      );
      _summary = result;
    } catch (e) {
      _summary = _summary =
          '## Error\n\nFailed to generate summary: $e\n\nPlease check your Groq API key.';
    }

    _isLoadingSummary = false;
    notifyListeners();
  }

  Future<void> generateQuiz(String documentContent, {int count = 10}) async {
    _isLoadingQuiz = true;
    _questions = [];
    notifyListeners();

    try {
      final result = await _callAPI(
        '''You are DocBrain quiz generator. Generate challenging multiple choice questions.
CRITICAL: Respond with ONLY valid JSON array, no markdown, no explanation.
Format: [{"question":"...","options":["A","B","C","D"],"correctIndex":0,"explanation":"..."}]''',
        '''Generate $count multiple choice quiz questions from this document.
Make questions test deep understanding, not just surface facts.
Mix difficulty levels. Include tricky distractors.

Document:
$documentContent

Return ONLY a JSON array of $count questions.''',
      );

      // Parse JSON
      String cleanJson = result.trim();
      if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson
            .replaceAll(RegExp(r'```json?\n?'), '')
            .replaceAll('```', '')
            .trim();
      }

      cleanJson = _extractJsonArray(cleanJson);
      cleanJson = _repairJsonString(cleanJson);
      dynamic parsed;
      try {
        parsed = jsonDecode(cleanJson);
      } catch (_) {
        final repairedJson = _removeTrailingCommas(cleanJson);
        parsed = jsonDecode(repairedJson);
      }

      if (parsed is! List) {
        throw Exception(
            'Unexpected quiz response format: ${parsed.runtimeType}');
      }

      _questions = parsed
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Generate fallback question
      _questions = [
        QuizQuestion(
          question: 'Failed to generate quiz. Error: $e',
          options: [
            'Check API Key',
            'Check Network',
            'Try Again',
            'Contact Support'
          ],
          correctIndex: 0,
          explanation: 'Please ensure your Groq API key is valid.',
        ),
      ];
    }

    _isLoadingQuiz = false;
    notifyListeners();
  }

  Future<void> generateKeyInsights(String documentContent) async {
    _isLoadingInsights = true;
    _keyInsights = [];
    _docStats = {};
    notifyListeners();

    try {
      final result = await _callAPI(
        '''You are DocBrain insight extractor. Extract key insights and analyze document stats.
CRITICAL: Respond with ONLY valid JSON, no markdown.
Format: {"insights":["insight1","insight2",...],"stats":{"readingTime":"X min","complexity":"Medium","mainTopic":"...","sentiment":"..."}}''',
        '''Extract 6 key insights and stats from this document:

$documentContent

Return ONLY JSON with "insights" array (6 items) and "stats" object.''',
      );

      String cleanJson = result.trim();
      if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson
            .replaceAll(RegExp(r'```json?\n?'), '')
            .replaceAll('```', '')
            .trim();
      }

      final Map<String, dynamic> parsed = jsonDecode(cleanJson);
      _keyInsights = List<String>.from(parsed['insights'] ?? []);
      _docStats = Map<String, dynamic>.from(parsed['stats'] ?? {});
    } catch (e) {
      _keyInsights = [
        'Failed to extract insights. Please check your Groq API key.'
      ];
      _docStats = {'error': e.toString()};
    }

    _isLoadingInsights = false;
    notifyListeners();
  }

  Future<void> chat(String userMessage, String documentContent) async {
    _chatHistory.add(ChatMessage(
      content: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isLoadingChat = true;
    notifyListeners();

    try {
      // Build conversation context
      final recentHistory = _chatHistory.length > 10
          ? _chatHistory.sublist(_chatHistory.length - 10)
          : _chatHistory;

      final List<Map<String, dynamic>> messages = [
        {
          'role': 'system',
          'content':
              'You are DocBrain, an expert AI assistant for document analysis. Answer user questions clearly and helpfully, using markdown when appropriate.'
        },
        {'role': 'system', 'content': 'DOCUMENT CONTENT:\n$documentContent'}
      ];
      for (final msg in recentHistory) {
        messages.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.content,
        });
      }

      final response = await http.post(
        Uri.parse('$_apiBase/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.3,
          'max_tokens': 512,
          'n': 1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'] as List<dynamic>?;
        final aiResponse = choices != null && choices.isNotEmpty
            ? (choices[0]['message']?['content'] as String? ??
                _parseGroqResponse(data))
            : _parseGroqResponse(data);

        _chatHistory.add(ChatMessage(
          content: aiResponse.trim(),
          isUser: false,
          timestamp: DateTime.now(),
        ));
      } else {
        final data = jsonDecode(response.body);
        final errorText = data['error']?['message'] ?? jsonEncode(data);
        _chatHistory.add(ChatMessage(
          content: 'Error: $errorText',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      _chatHistory.add(ChatMessage(
        content: 'Network error: $e',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }

    _isLoadingChat = false;
    notifyListeners();
  }

  void clearChat() {
    _chatHistory = [];
    notifyListeners();
  }

  void answerQuestion(int questionIndex, int answerIndex) {
    if (questionIndex < _questions.length) {
      _questions[questionIndex].selectedIndex = answerIndex;
      notifyListeners();
    }
  }

  int get quizScore {
    if (_questions.isEmpty) return 0;
    return _questions.where((q) => q.isCorrect).length;
  }

  double get quizPercentage {
    if (_questions.isEmpty) return 0;
    final answered = _questions.where((q) => q.isAnswered).length;
    if (answered == 0) return 0;
    return (quizScore / answered) * 100;
  }

  bool get quizCompleted =>
      _questions.isNotEmpty && _questions.every((q) => q.isAnswered);
}
