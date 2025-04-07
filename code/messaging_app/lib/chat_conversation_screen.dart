import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'text_to_speech_service.dart';
import 'backend_service.dart';

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

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
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
    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await _backendService.fetchMessages(widget.chatId);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading messages: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    _messageController.clear();

    // Add message to UI
    setState(() {
      _messages.insert(0, {
        'text': messageText,
        'timestamp': DateTime.now().toIso8601String(),
        'isMine': true,
      });
    });

    try {
      // Send through backend instead of directly to Firestore
      final success = await _backendService.sendMessage(
        widget.chatId,
        messageText,
      );

      if (!success) {
        // Handle failure - show an error and retry option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message. Tap to retry.'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed:
                  () => _backendService.sendMessage(widget.chatId, messageText),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error sending message: $e');
      // Show error to user
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Chat Conversation')),
      body: Column(
        children: [
          // Display messages
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMessageList(themeProvider),
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
