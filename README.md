# 🧠 DocBrain — AI Study Assistant

A professional, industry-ready Flutter Web application that transforms documents into interactive learning experiences using Claude AI.

## ✨ Features

| Feature | Description |
|---------|-------------|
| 📄 Document Upload | PDF, DOCX, TXT, MD support |
| 🤖 AI Chat | Ask any question about your document |
| 📝 Auto MCQ Generation | 10 intelligent multiple-choice questions |
| 📊 Smart Summary | Structured markdown summaries |
| 💡 Key Insights | 6 key insights + document analytics |
| 🎨 Neon UI | Neural network animated background |
| 📱 Responsive | Desktop + Mobile layouts |

## 🚀 Quick Start

### 1. Prerequisites
```bash
# Install Flutter (if not already installed)
# Download from: https://docs.flutter.dev/get-started/install
flutter --version  # Should be 3.x.x
```

### 2. Get Your FREE Anthropic API Key
1. Go to https://console.anthropic.com
2. Sign up / Log in
3. Navigate to **API Keys**
4. Create a new key — you get **free credits** to start!

### 3. Setup Project
```bash
# Clone/copy the project to your machine
cd docbrain

# Install dependencies
flutter pub get
```

### 4. Add Your API Key
Open `lib/services/ai_service.dart` and replace:
```dart
static const String _apiKey = 'YOUR_ANTHROPIC_API_KEY_HERE';
```
with your actual key:
```dart
static const String _apiKey = 'sk-ant-api03-...';
```

### 5. Run in Browser
```bash
# Run on Chrome (recommended)
flutter run -d chrome

# Or run on any available browser
flutter run -d web-server --web-port 5000
```

Then open: **http://localhost:5000**

## 🏗️ Project Structure

```
docbrain/
├── lib/
│   ├── main.dart                  # App entry point
│   ├── models/
│   │   └── document_model.dart    # Data models
│   ├── services/
│   │   ├── ai_service.dart        # Claude API integration
│   │   └── document_service.dart  # File handling
│   ├── screens/
│   │   └── home_screen.dart       # Main screen + navigation
│   ├── widgets/
│   │   ├── neural_background.dart # Animated neural network
│   │   ├── upload_panel.dart      # Document upload sidebar
│   │   ├── quiz_view.dart         # MCQ quiz interface
│   │   ├── summary_view.dart      # Document summary
│   │   ├── chat_view.dart         # AI chat interface
│   │   ├── insights_view.dart     # Key insights + stats
│   │   └── neon_button.dart       # Reusable UI components
│   └── utils/
│       └── theme.dart             # Neon dark theme
├── web/
│   ├── index.html                 # Custom loading screen
│   └── manifest.json             # PWA manifest
└── pubspec.yaml                   # Dependencies
```

## 🎨 Tech Stack

- **Framework**: Flutter 3.x (Web)
- **AI Model**: Claude Haiku 4.5 (fastest, most affordable)
- **State Management**: Provider
- **Animations**: flutter_animate
- **Fonts**: Orbitron + Exo 2 + Rajdhani (Google Fonts)
- **Markdown**: flutter_markdown
- **Charts**: percent_indicator

## 💡 AI Model Choice

Uses **claude-haiku-4-5-20251001** — optimal because:
- ⚡ Fastest response time (~1-2 seconds)
- 💰 Most cost-effective (free tier friendly)
- 🎯 Excellent for document Q&A tasks
- 🔒 Same quality as larger models for structured tasks

## 🔒 Security Note

For production, move the API key to a backend server. Never expose API keys in production client-side code.

## 🎮 How to Use

1. **Upload** a document (PDF, TXT, DOCX, or MD) — or click "load sample document"
2. Click **Generate MCQs** to create a 10-question quiz
3. Click **Summarize** to get an AI-structured summary  
4. Click **Key Insights** to extract intelligence + stats
5. Type in the **Ask AI** tab to chat with your document

## 🔧 Customization

### Change Quiz Question Count
In `ai_service.dart`, modify:
```dart
Future<void> generateQuiz(String documentContent, {int count = 10})
```

### Change AI Model
```dart
static const String _model = 'claude-haiku-4-5-20251001';
// Options: 'claude-sonnet-4-6' (smarter), 'claude-opus-4-6' (most capable)
```

### Add More File Types
In `document_service.dart`, extend `_extractPdfText()` or add new handlers.

## 📦 Build for Production

```bash
flutter build web --release
# Output in: build/web/
```

Deploy to Firebase Hosting, Netlify, or any static host.

---

**Built with ❤️ using Flutter + Claude AI**
