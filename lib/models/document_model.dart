class DocumentModel {
  final String name;
  final String content;
  final String type;
  final int wordCount;
  final DateTime uploadedAt;

  DocumentModel({
    required this.name,
    required this.content,
    required this.type,
    required this.wordCount,
    required this.uploadedAt,
  });

  String get preview {
    if (content.length > 300) {
      return '${content.substring(0, 300)}...';
    }
    return content;
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  int? selectedIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.selectedIndex,
  });

  bool get isAnswered => selectedIndex != null;
  bool get isCorrect => selectedIndex == correctIndex;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
}

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}
