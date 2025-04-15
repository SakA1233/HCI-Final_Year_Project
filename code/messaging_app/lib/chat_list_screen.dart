import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'chat_conversation_screen.dart';
import 'settings_screen.dart';
import 'theme_provider.dart';
import 'text_to_speech_service.dart';
import 'backend_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextToSpeechService _tts = TextToSpeechService();
  final TextEditingController _chatNameController = TextEditingController();
  final BackendService _backendService = BackendService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _chats = [];

  // Keep track of which bottom nav tab is selected
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadChats();
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

  // Update chat name in Firestore via backend service
  Future<void> _updateChatName(String chatId, String newName) async {
    if (newName.isEmpty) return;

    try {
      final success = await _backendService.updateChatName(chatId, newName);

      if (success) {
        await _loadChats(); // Refresh the chat list
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Chat renamed to "$newName"')));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to rename chat')));
      }
    } catch (e) {
      print('Error updating chat name: $e');
      if (!mounted) return;
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
        final success = await _backendService.deleteChat(chatId);

        if (success) {
          setState(() {
            _chats.removeWhere((chat) => chat['id'] == chatId);
          });
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Chat deleted')));
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete chat')),
          );
        }
      } catch (e) {
        print('Error deleting chat: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to delete chat')));
      }
    }
  }

  Future<void> _loadChats() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final chats = await _backendService.fetchChats();
      if (!mounted) return;

      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading chats: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load chats: $e'),
          action: SnackBarAction(label: 'Retry', onPressed: _loadChats),
        ),
      );
    }
  }

  // Simple method: show chat list if index=0, else show settings
  Widget _buildBody() {
    if (_currentIndex == 0) {
      if (_isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_chats.isEmpty) {
        return const Center(child: Text('No conversations yet.'));
      }

      return ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          final String chatId = chat['id'] ?? '';
          final bool isUnread = chat['unread'] ?? false;
          final String conversationName = chat['name'] ?? 'Unnamed Chat';
          final String lastMessage = chat['lastMessage'] ?? 'No messages yet';

          return Dismissible(
            key: Key(chatId),
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
              try {
                final success = await _backendService.deleteChat(chatId);
                if (success) {
                  setState(() {
                    _chats.removeWhere((chat) => chat['id'] == chatId);
                  });
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Chat deleted')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete chat')),
                  );
                }
              } catch (e) {
                print('Error deleting chat: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete chat')),
                );
              }
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
                              _showEditChatNameDialog(chatId, conversationName);
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
                            onTap: () async {
                              Navigator.pop(dialogContext);
                              try {
                                final success = await _backendService
                                    .deleteChat(chatId);
                                if (success) {
                                  setState(() {
                                    _chats.removeWhere(
                                      (chat) => chat['id'] == chatId,
                                    );
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Chat deleted'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to delete chat'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                print('Error deleting chat: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to delete chat'),
                                  ),
                                );
                              }
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
                        ? const Icon(Icons.circle, color: Colors.blue, size: 10)
                        : null,
                onTap: () async {
                  // Speak the conversation name if TTS is enabled
                  _speakIfEnabled("Opening chat with $conversationName");

                  try {
                    // Mark as read using backend service
                    await _backendService.updateChatName(
                      chatId,
                      conversationName,
                    );

                    // Navigate to conversation screen
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ChatConversationScreen(chatId: chatId),
                      ),
                    ).then((_) => _loadChats()); // Refresh list when returning
                  } catch (e) {
                    print('Error updating unread status: $e');
                  }
                },
              ),
            ),
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

  // Create a new chat with a custom name using backend service
  Future<void> _createNewChat(String chatName) async {
    if (chatName.isEmpty) {
      chatName = 'New Chat';
    }

    try {
      final chatId = await _backendService.createChat(chatName);

      if (chatId != null) {
        await _loadChats(); // Refresh the chat list
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Created chat: $chatName')));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to create chat')));
      }
    } catch (e) {
      print('Error creating new chat: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to create chat')));
    }
  }
}
