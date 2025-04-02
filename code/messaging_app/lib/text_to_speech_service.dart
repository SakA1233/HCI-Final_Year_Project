import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  factory TextToSpeechService() => _instance;
  TextToSpeechService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isInitializing = false;

  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;

    _isInitializing = true;

    try {
      // Initialization
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Check if TTS is available
      try {
        var engines = await _flutterTts.getEngines;
        print("Available TTS engines: $engines");
        if (engines.isEmpty) {
          print("No TTS engines available on this device");
        }
      } catch (e) {
        print("Warning: Could not check TTS engines: $e");
      }

      // Add completion listener
      _flutterTts.setCompletionHandler(() {
        print("TTS Completed");
      });

      // Add error listener
      _flutterTts.setErrorHandler((error) {
        print("TTS Error: $error");
      });

      _isInitialized = true;
      print("TTS initialized successfully");
    } catch (e) {
      print("Error initializing TTS: $e");
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.isEmpty) {
      print("Empty text provided to TTS, skipping");
      return;
    }

    try {
      try {
        await _flutterTts.stop();
      } catch (e) {
        print("Warning: Could not stop previous TTS: $e");
      }

      // Set max speech input length to avoid issues
      if (text.length > 4000) {
        text = text.substring(0, 4000);
      }

      // Speak the text
      print(
        "Attempting to speak: ${text.substring(0, Math.min(50, text.length))}...",
      );
      var result = await _flutterTts.speak(text);
      print("TTS Speak result: $result");
    } catch (e) {
      print("Error speaking text: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print("Error stopping TTS: $e");
    }
  }

  void dispose() {
    try {
      _flutterTts.stop();
    } catch (e) {
      print("Error disposing TTS: $e");
    }
  }
}

// Helper class to avoid importing dart:math
class Math {
  static int min(int a, int b) => a < b ? a : b;
}
