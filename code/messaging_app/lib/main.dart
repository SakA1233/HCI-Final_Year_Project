import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'theme_provider.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initializePlugins();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

Future<void> _initializePlugins() async {
  try {
    await SharedPreferences.getInstance();

    // Initialize FlutterTts
    FlutterTts flutterTts = FlutterTts();
    await flutterTts.setLanguage("en-US");

    print("Plugins initialized successfully");
  } catch (e) {
    print("Error initializing plugins: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Chat App',
          theme: themeProvider.getTheme(),
          builder: (context, child) {
            // Apply text scaling to the entire app
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(themeProvider.textScaleFactor),
              ),
              child: child!,
            );
          },
          home: const LoginScreen(),
        );
      },
    );
  }
}

class MockVoiceCommandService {
  final List<String> _mockResponses = [
    "Hello, I'm a mock voice command.",
    "This is a test message from the simulator.",
    "Send hello to everyone in the chat.",
    "Create a new chat please.",
    "Go to settings",
    // ... more responses
  ];

  Timer? _mockRecognitionTimer;
  final Random _random = Random();
  bool _isListening = false;

  void startListening(Function(String) onResult) {
    _isListening = true;
    _mockRecognitionTimer = Timer(
      Duration(seconds: 1 + _random.nextInt(2)),
      () {
        if (_isListening) {
          // Select a random mock response
          final response =
              _mockResponses[_random.nextInt(_mockResponses.length)];
          onResult(response);
          stopListening();
        }
      },
    );
  }

  void stopListening() {
    _isListening = false;
    _mockRecognitionTimer?.cancel();
  }
}
