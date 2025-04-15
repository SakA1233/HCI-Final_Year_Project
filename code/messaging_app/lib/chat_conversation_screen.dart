import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'text_to_speech_service.dart';
import 'backend_service.dart';
import 'dart:async';

class ChatConversationScreen extends StatefulWidget {
  final String chatId;

  const ChatConversationScreen({Key? key, required this.chatId})
    : super(key: key);

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final BackendService _backendService = BackendService();
  final TextToSpeechService _tts = TextToSpeechService();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  bool _isRefreshing = false;
  int _errorCount = 0;
  static const int _maxErrorCount = 3;
  static const Duration _refreshInterval = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadMessages();
    // Set up periodic refresh with a longer interval
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (mounted && !_isRefreshing && _errorCount < _maxErrorCount) {
        _loadMessages();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Initialize text-to-speech
  Future<void> _initTts() async {
    await _tts.initialize();
  }

  // Speak text if TTS is enabled
  void _speakIfEnabled(String text) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (themeProvider.isTextToSpeechEnabled) {
      // Show a small tooltip or snackbar to indicate TTS is active
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Speaking: ${text.length > 30 ? text.substring(0, 30) + '...' : text}',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
      _tts.speak(text);
    }
  }

  Future<void> _loadMessages() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    print('Starting to load messages...');

    try {
      final messages = await _backendService.fetchMessages(widget.chatId);
      print('Fetched ${messages.length} messages from backend service');

      if (mounted) {
        setState(() {
          // Only update messages if we received new ones (not a 304 response)
          if (messages.isNotEmpty) {
            _messages = messages;
            print('Updated state with ${_messages.length} messages');
          } else {
            print(
              'No new messages, keeping existing ${_messages.length} messages',
            );
          }
          _isLoading = false;
          _errorCount = 0; // Reset error count on successful fetch
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorCount++;
          print('Error count increased to: $_errorCount');
        });

        // Only show error message if we haven't exceeded the max error count
        if (_errorCount < _maxErrorCount) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load messages. Retrying...'),
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (_errorCount == _maxErrorCount) {
          // Show final error message when max errors reached
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Connection issues detected. Pull down to refresh.',
              ),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  _errorCount = 0;
                  _loadMessages();
                },
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        _isRefreshing = false;
      }
    }
  }

  Future<void> _sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    _messageController.clear();

    // Immediately add the message to the UI with a temporary ID
    final temporaryMessage = {
      'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'text': messageText,
      'timestamp': DateTime.now().toIso8601String(),
      'isMine': true,
    };

    setState(() {
      _messages = [temporaryMessage, ..._messages];
    });

    try {
      final success = await _backendService.sendMessage(
        widget.chatId,
        messageText,
      );

      if (success) {
        // Reset error count and load messages to get the bot's response
        _errorCount = 0;
        _loadMessages();
      } else {
        // Remove the temporary message if sending failed
        setState(() {
          _messages.removeWhere((msg) => msg['id'] == temporaryMessage['id']);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message. Tap to retry.'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                _backendService.sendMessage(widget.chatId, messageText).then((
                  success,
                ) {
                  if (success) {
                    _loadMessages();
                  }
                });
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Remove the temporary message if sending failed
      setState(() {
        _messages.removeWhere((msg) => msg['id'] == temporaryMessage['id']);
      });

      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message. Please try again.'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _sendMessage(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Chat Conversation')),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _errorCount = 0; // Reset error count on manual refresh
                await _loadMessages();
              },
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildMessageList(themeProvider),
            ),
          ),

          // Message input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ThemeProvider themeProvider) {
    if (_messages.isEmpty) {
      return const Center(child: Text('No messages yet.'));
    }

    return ListView.builder(
      reverse: true, // Newest messages at the bottom
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final bool isMine = message['isMine'] ?? false;
        final String messageText = message['text'] ?? '';
        final String timestamp = message['timestamp'] ?? '';

        // Parse timestamp
        DateTime? messageTime;
        try {
          messageTime = DateTime.parse(timestamp);
        } catch (e) {
          // Handle parsing error
        }

        return GestureDetector(
          onLongPress: () {
            // Speak the message text when long-pressed
            _speakIfEnabled(messageText);
          },
          child: Align(
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isMine
                        ? Theme.of(context).colorScheme.primary
                        : (themeProvider.isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[300]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageText,
                    style: TextStyle(
                      color:
                          isMine
                              ? Colors.white
                              : (themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    messageTime != null
                        ? '${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}'
                        : '',
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          isMine
                              ? Colors.white.withOpacity(0.7)
                              : (themeProvider.isDarkMode
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
