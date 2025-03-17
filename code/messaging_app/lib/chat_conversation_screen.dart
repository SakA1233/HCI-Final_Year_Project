import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversationScreen extends StatefulWidget {
  final String chatId;

  const ChatConversationScreen({Key? key, required this.chatId})
    : super(key: key);

  @override
  _ChatConversationScreenState createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Conversation')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
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
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message =
                        messages[index].data() as Map<String, dynamic>;
                    String text = message['text'] ?? '';
                    var timestamp =
                        message['timestamp']?.toDate().toString() ?? '';

                    return ListTile(
                      title: Text(text),
                      subtitle: Text(
                        timestamp,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
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
                  icon: const Icon(Icons.send),
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

    // Add new message in subcollection
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.chatId)
        .collection('messages')
        .add({'text': messageText, 'timestamp': FieldValue.serverTimestamp()});

    // Update conversation's lastMessage and set unread to true
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.chatId)
        .update({
          'lastMessage': messageText,
          'timestamp': FieldValue.serverTimestamp(),
          'unread': true,
        });

    _messageController.clear();
  }
}
