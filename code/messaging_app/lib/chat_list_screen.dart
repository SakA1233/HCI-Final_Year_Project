import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'chat_conversation_screen.dart';
import 'settings_screen.dart';
import 'theme_provider.dart';
import 'text_to_speech_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextToSpeechService _tts = TextToSpeechService();
  final TextEditingController _chatNameController = TextEditingController();

  // Keep track of which bottom nav tab is selected
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  @override
  void dispose() {
    _chatNameController.dispose();
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
      _tts.speak(text);
    }
  }

  // Show dialog to edit chat name
  void _showEditChatNameDialog(String chatId, String currentName) {
    _chatNameController.text = currentName;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Chat Name'),
            content: TextField(
              controller: _chatNameController,
              decoration: const InputDecoration(
                labelText: 'Chat Name',
                hintText: 'Enter a new name for this chat',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _updateChatName(chatId, _chatNameController.text.trim());
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  // Update chat name in Firestore
  Future<void> _updateChatName(String chatId, String newName) async {
    if (newName.isEmpty) return;

    try {
      await firestore.collection('conversations').doc(chatId).update({
        'name': newName,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Chat renamed to "$newName"')));
    } catch (e) {
      print('Error updating chat name: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to rename chat')));
    }
  }

  // Confirm deletion of chat
  Future<void> _confirmDeleteChat(String chatId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you want to delete this chat?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        // Delete the messages subcollection first
        var messages =
            await firestore
                .collection('conversations')
                .doc(chatId)
                .collection('messages')
                .get();

        for (var message in messages.docs) {
          await firestore
              .collection('conversations')
              .doc(chatId)
              .collection('messages')
              .doc(message.id)
              .delete();
        }

        // Then delete the conversation document
        await firestore.collection('conversations').doc(chatId).delete();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Chat deleted')));
      } catch (e) {
        print('Error deleting chat: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to delete chat')));
      }
    }
  }

  // Simple method: show chat list if index=0, else show a profile placeholder or settings
  Widget _buildBody() {
    if (_currentIndex == 0) {
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

              return Dismissible(
                key: Key(chat.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm"),
                        content: const Text(
                          "Are you sure you want to delete this chat?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) async {
                  _confirmDeleteChat(chat.id);
                },
                child: GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text("Chat Options"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text("Edit Name"),
                                onTap: () {
                                  Navigator.pop(dialogContext);
                                  _showEditChatNameDialog(
                                    chat.id,
                                    conversationName,
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                title: const Text(
                                  "Delete Chat",
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () {
                                  Navigator.pop(dialogContext);
                                  _confirmDeleteChat(chat.id);
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text("Cancel"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: ListTile(
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
                            ? const Icon(
                              Icons.circle,
                              color: Colors.blue,
                              size: 10,
                            )
                            : null,
                    onTap: () async {
                      // Speak the conversation name if TTS is enabled
                      _speakIfEnabled("Opening chat with $conversationName");

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
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      return const SettingsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Chat List' : 'Settings'),
      ),
      body: _buildBody(),
      // Add a floating action button only on the Chats tab
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                onPressed: () => _showCreateChatDialog(),
                child: const Icon(Icons.add),
              )
              : null,
      // Updated BottomNavigationBar with Settings instead of Profile
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
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
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  // Show dialog to create a new chat
  void _showCreateChatDialog() {
    _chatNameController.clear();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New Chat'),
            content: TextField(
              controller: _chatNameController,
              decoration: const InputDecoration(
                labelText: 'Chat Name',
                hintText: 'Enter a name for the new chat',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _createNewChat(_chatNameController.text.trim());
                  Navigator.pop(context);
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  // Create a new chat with a custom name
  Future<void> _createNewChat(String chatName) async {
    if (chatName.isEmpty) {
      chatName = 'New Chat';
    }

    try {
      // Create a new conversation document
      var newChat = await firestore.collection('conversations').add({
        'name': chatName,
        'lastMessage': 'Chat created',
        'timestamp': FieldValue.serverTimestamp(),
        'unread': true,
      });

      // Immediately create a message doc in the 'messages' subcollection
      await firestore
          .collection('conversations')
          .doc(newChat.id)
          .collection('messages')
          .add({
            'text': 'Welcome to $chatName!',
            'timestamp': FieldValue.serverTimestamp(),
            'isMine': false,
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Created chat: $chatName')));
    } catch (e) {
      print('Error creating new chat: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to create chat')));
    }
  }
}
