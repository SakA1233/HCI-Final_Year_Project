import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_conversation_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Keep track of which bottom nav tab is selected
  int _currentIndex = 0;

  // Show chat list if index=0, else show a profile placeholder
  Widget _buildBody() {
    if (_currentIndex == 0) {
      // === Existing Chat List code ===
      return StreamBuilder<QuerySnapshot>(
        stream:
            firestore
                .collection('conversations')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No conversations yet.'));
          }

          var chats = snapshot.data!.docs;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var chat = chats[index];
              var data = chat.data() as Map<String, dynamic>;

              bool isUnread = data['unread'] ?? false;
              String conversationName = data['name'] ?? 'Unnamed Chat';
              String lastMessage = data['lastMessage'] ?? 'No messages yet';

              return ListTile(
                title: Text(
                  conversationName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing:
                    isUnread
                        ? const Icon(Icons.circle, color: Colors.blue, size: 10)
                        : null,
                onTap: () async {
                  try {
                    // Mark as read before navigating
                    await firestore
                        .collection('conversations')
                        .doc(chat.id)
                        .update({'unread': false});

                    // Navigate to conversation screen
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ChatConversationScreen(chatId: chat.id),
                      ),
                    );
                  } catch (e) {
                    print('Error updating unread status: $e');
                  }
                },
              );
            },
          );
        },
      );
    } else {
      // placeholder for profile tab
      return const Center(
        child: Text(
          'Profile Screen (Coming Soon)',
          style: TextStyle(fontSize: 20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat List')),
      body: _buildBody(),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                onPressed: () async {
                  try {
                    // Create a new conversation document
                    var newChat = await firestore
                        .collection('conversations')
                        .add({
                          'name': 'New Chat',
                          'lastMessage': 'Hello there!',
                          'timestamp': FieldValue.serverTimestamp(),
                          'unread': true,
                        });

                    print('Created new chat: ${newChat.id}');

                    await firestore
                        .collection('conversations')
                        .doc(newChat.id)
                        .collection('messages')
                        .add({
                          'text': 'Hello there!',
                          'timestamp': FieldValue.serverTimestamp(),
                          'isMine': false,
                        });
                  } catch (e) {
                    print('Error creating new chat: $e');
                  }
                },
                child: const Icon(Icons.add),
              )
              : null,
      // BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
