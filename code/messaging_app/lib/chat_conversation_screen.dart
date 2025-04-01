import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'text_to_speech_service.dart';

class ChatConversationScreen extends StatefulWidget {
  final String chatId;

  const ChatConversationScreen({Key? key, required this.chatId})
    : super(key: key);

  @override
  _ChatConversationScreenState createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextToSpeechService _tts = TextToSpeechService();

  @override
  void initState() {
    super.initState();
    _initTts();
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Chat Conversation')),
      body: Column(
        children: [
          // Display messages in real-time
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  firestore
                      .collection('conversations')
                      .doc(widget.chatId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // Newest messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message =
                        messages[index].data() as Map<String, dynamic>;
                    bool isMine = message['isMine'] ?? false;
                    String messageText = message['text'] ?? '';

                    return GestureDetector(
                      onLongPress: () {
                        // Speak the message text when long-pressed
                        _speakIfEnabled(messageText);
                      },
                      child: Align(
                        alignment:
                            isMine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
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
                                message['timestamp']?.toDate().toString() ?? '',
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
              },
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
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    await firestore
        .collection('conversations')
        .doc(widget.chatId)
        .collection('messages')
        .add({
          'text': messageText,
          'timestamp': FieldValue.serverTimestamp(),
          'isMine': true, // Placeholder for now
        });

    // Update conversation's lastMessage and set unread to true
    await firestore.collection('conversations').doc(widget.chatId).update({
      'lastMessage': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'unread': true,
    });

    _messageController.clear();
  }
}
