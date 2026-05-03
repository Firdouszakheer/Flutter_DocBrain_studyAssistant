import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/document_model.dart';

class DocumentService extends ChangeNotifier {
  DocumentModel? _currentDocument;
  bool _isLoading = false;
  String _error = '';

  DocumentModel? get currentDocument => _currentDocument;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasDocument => _currentDocument != null;

  Future<void> pickAndLoadDocument() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'docx', 'md'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;
        final name = file.name;
        final ext = name.split('.').last.toLowerCase();

        if (bytes != null) {
          String content = '';

          if (ext == 'txt' || ext == 'md') {
            content = String.fromCharCodes(bytes);
          } else if (ext == 'pdf') {
            content = await _extractPdfText(bytes);
          } else if (ext == 'docx') {
            content = await _extractDocxText(bytes);
          }

          if (content.trim().isEmpty) {
            content = 'Could not extract text from this file. Please try a TXT or MD file.';
          }

          final wordCount = content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

          _currentDocument = DocumentModel(
            name: name,
            content: content,
            type: ext.toUpperCase(),
            wordCount: wordCount,
            uploadedAt: DateTime.now(),
          );
        }
      }
    } catch (e) {
      _error = 'Failed to load document: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String> _extractPdfText(Uint8List bytes) async {
    try {
      // Simple PDF text extraction - look for readable text in bytes
      // For full PDF support, syncfusion_flutter_pdf is needed
      // This is a basic fallback
      final text = String.fromCharCodes(bytes.where((b) => b >= 32 && b < 127));
      // Filter readable text
      final lines = text.split('\n')
          .where((line) => line.trim().length > 3)
          .where((line) => !line.contains('\x00'))
          .toList();
      return lines.join('\n');
    } catch (e) {
      return 'PDF text extraction requires syncfusion_flutter_pdf package. Error: $e';
    }
  }

  Future<String> _extractDocxText(Uint8List bytes) async {
    try {
      // Basic DOCX extraction - DOCX files are ZIP archives with XML inside
      // For full support, a dedicated package is needed
      final text = String.fromCharCodes(bytes.where((b) => b >= 32 && b < 127));
      // Extract text between XML tags (basic approach)
      final regex = RegExp(r'<w:t[^>]*>([^<]+)</w:t>');
      final matches = regex.allMatches(text);
      final extracted = matches.map((m) => m.group(1) ?? '').join(' ');
      return extracted.isNotEmpty ? extracted : 'Could not extract DOCX text. Try saving as TXT.';
    } catch (e) {
      return 'DOCX extraction error: $e';
    }
  }

  void clearDocument() {
    _currentDocument = null;
    _error = '';
    notifyListeners();
  }

  // For demo/testing - load sample document
  void loadSampleDocument() {
    _currentDocument = DocumentModel(
      name: 'sample_ai_overview.txt',
      type: 'TXT',
      wordCount: 450,
      uploadedAt: DateTime.now(),
      content: '''
Artificial Intelligence: A Comprehensive Overview

Artificial Intelligence (AI) refers to the simulation of human intelligence processes by computer systems. These processes include learning (acquiring information and rules for using the information), reasoning (using rules to reach approximate or definite conclusions), and self-correction.

History of AI
The field of AI was formally founded in 1956 at the Dartmouth Conference, where John McCarthy coined the term "Artificial Intelligence." Early AI research focused on problem-solving and symbolic methods. The 1970s brought AI winters—periods of reduced funding and interest due to unmet high expectations.

Machine Learning Revolution
The 21st century brought a revolution with machine learning (ML), where algorithms learn from data rather than being explicitly programmed. Deep learning, a subset of ML using neural networks with many layers, has produced breakthroughs in image recognition, natural language processing, and game playing.

Key AI Applications
1. Natural Language Processing (NLP): Enables computers to understand, interpret, and generate human language. Examples include chatbots, translation services, and voice assistants.

2. Computer Vision: Allows machines to interpret and understand visual information from the world. Used in facial recognition, medical imaging, and autonomous vehicles.

3. Robotics: Combines AI with physical machines to create systems that can interact with the physical world autonomously.

4. Expert Systems: AI programs that mimic the decision-making ability of a human expert in a specific domain.

Large Language Models
Recent years have seen the emergence of Large Language Models (LLMs) like GPT-4 and Claude. These models are trained on vast amounts of text data and can generate human-like text, answer questions, write code, and engage in complex reasoning tasks.

Ethical Considerations
AI raises important ethical questions including privacy concerns, algorithmic bias, job displacement, and the existential risk from superintelligent AI. Researchers and policymakers are working on AI safety and alignment to ensure AI systems behave as intended.

Future of AI
The future holds promise for Artificial General Intelligence (AGI)—AI that can perform any intellectual task a human can. While AGI remains theoretical, narrow AI continues to advance rapidly, transforming industries from healthcare to finance to education.
      ''',
    );
    notifyListeners();
  }
}
