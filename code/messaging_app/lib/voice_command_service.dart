import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

class VoiceCommandService {
  static final VoiceCommandService _instance = VoiceCommandService._internal();
  factory VoiceCommandService() => _instance;
  VoiceCommandService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  // Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          print('Speech recognition status: $status');
        },
        onError: (errorNotification) {
          print('Speech recognition error: $errorNotification');
        },
      );

      print('Speech recognition initialized: $_isInitialized');
      return _isInitialized;
    } catch (e) {
      print('Error initializing speech recognition: $e');
      _isInitialized = false;
      return false;
    }
  }

  // Start listening for speech
  Future<bool> startListening({
    required Function(String) onResult,
    String? localeId,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      print('Cannot start listening: speech recognition not initialized');
      return false;
    }

    if (_isListening) {
      print('Already listening');
      return true;
    }

    try {
      _isListening = await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          onResult(result.recognizedWords);
        },
        localeId: localeId,
        listenMode: stt.ListenMode.confirmation,
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
      );

      print('Started listening: $_isListening');
      return _isListening;
    } catch (e) {
      print('Error starting speech recognition: $e');
      _isListening = false;
      return false;
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      _speech.stop();
      _isListening = false;
      print('Stopped listening');
    } catch (e) {
      print('Error stopping speech recognition: $e');
    }
  }

  // Process recognized text for commands
  bool processCommand(
    String text,
    BuildContext context, {
    required Function() onGoToSettings,
    required Function() onOpenChatWithJohn,
  }) {
    final lowerText = text.toLowerCase();

    // Command: Go to settings
    if (lowerText.contains('go to settings') ||
        lowerText.contains('open settings') ||
        lowerText.contains('settings please')) {
      onGoToSettings();
      return true;
    }
    // Command: Open chat with John
    else if (lowerText.contains('chat with john') ||
        lowerText.contains('open chat with john')) {
      onOpenChatWithJohn();
      return true;
    }

    // Not a command
    return false;
  }
}
