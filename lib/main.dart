import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/document_service.dart';
import 'services/ai_service.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DocumentService()),
        ChangeNotifierProvider(create: (_) => AIService()),
      ],
      child: const DocBrainApp(),
    ),
  );
}

class DocBrainApp extends StatelessWidget {
  const DocBrainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocBrain — AI Study Assistant',
      debugShowCheckedModeBanner: false,
      theme: DocBrainTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
