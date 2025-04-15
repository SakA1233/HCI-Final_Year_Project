import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// A mock implementation of voice command service for testing UI flows
/// without requiring actual microphone access
class MockVoiceCommandService {
  static final MockVoiceCommandService _instance =
      MockVoiceCommandService._internal();
  factory MockVoiceCommandService() => _instance;
  MockVoiceCommandService._internal();

  bool _isInitialized = true;
  bool _isListening = false;
  Timer? _mockRecognitionTimer;
  final Random _random = Random();

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  // List of mock responses
  final List<String> _mockResponses = [
    "Go to settings",
    "Open settings",
    "Open chat with John",
    "Chat with John",
    "I want to chat with John",
    "Settings please",
  ];

  // Initialize mock service (always succeeds)
  Future<bool> initialize() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate initialization delay
    _isInitialized = true;
    print('Mock speech recognition initialized');
    return true;
  }

  // Start mock listening
  Future<bool> startListening({
    required Function(String) onResult,
    String? localeId,
  }) async {
    if (_isListening) {
      print('Already listening (mock)');
      return true;
    }

    _isListening = true;
    print('Started mock listening');

    // Simulate speech recognition with a random delay
    _mockRecognitionTimer = Timer(
      Duration(seconds: 1 + _random.nextInt(2)),
      () {
        if (_isListening) {
          // Select a random mock response
          final response =
              _mockResponses[_random.nextInt(_mockResponses.length)];
          onResult(response);

          // Automatically stop listening after delivering the result
          stopListening();
        }
      },
    );

    return true;
  }

  // Stop mock listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    _mockRecognitionTimer?.cancel();
    _isListening = false;
    print('Stopped mock listening');
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
