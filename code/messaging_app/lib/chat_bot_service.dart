import 'package:cloud_firestore/cloud_firestore.dart';

class ChatBotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listen for user messages and respond to them
  void startListening() {
    print("ChatBotService: Starting to listen for messages...");

    _firestore
        .collection('conversations')
        .snapshots()
        .listen(
          (snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.modified) {
                _checkForNewMessages(change.doc.id);
              }
            }
          },
          onError: (error) {
            print("ChatBotService: Error listening to conversations: $error");
          },
        );
  }

  // Check for new messages in a conversation
  Future<void> _checkForNewMessages(String chatId) async {
    try {
      // Get the most recent message
      QuerySnapshot snapshot =
          await _firestore
              .collection('conversations')
              .doc(chatId)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) return;

      var lastMessage = snapshot.docs.first;
      Map<String, dynamic> data = lastMessage.data() as Map<String, dynamic>;

      // Only respond to user messages
      if (data['isMine'] == true) {
        String text = data['text'] ?? '';
        print("ChatBotService: Received message: '$text'");

        // Generate a response
        String response = _generateResponse(text);
        print("ChatBotService: Generated response: '$response'");

        // Add a small delay to make it feel more natural
        await Future.delayed(const Duration(seconds: 1));

        // Send the response
        await _sendResponse(chatId, response);
      }
    } catch (e) {
      print("ChatBotService: Error checking for new messages: $e");
    }
  }

  // Generate a response based on the user's message
  String _generateResponse(String userMessage) {
    userMessage = userMessage.toLowerCase();

    // Simple responses
    if (userMessage.contains('hello') || userMessage.contains('hi')) {
      return 'Hello there! How can I help you today?';
    } else if (userMessage.contains('how are you')) {
      return 'I\'m doing well, thank you for asking! How about you?';
    } else if (userMessage.contains('help')) {
      return 'I\'m here to help! You can ask me about the app, or just chat with me.';
    } else if (userMessage.contains('thank')) {
      return 'You\'re welcome! Is there anything else I can help with?';
    } else if (userMessage.contains('bye') || userMessage.contains('goodbye')) {
      return 'Goodbye! Have a great day!';
    } else {
      // Default responses
      List<String> defaultResponses = [
        'That\'s interesting! Tell me more.',
        'I understand. What else is on your mind?',
        'I see. How can I help with that?',
        'Thanks for sharing that with me.',
        'I\'m processing what you said. Can you elaborate?',
      ];

      // Return a random default response
      return defaultResponses[DateTime.now().millisecond %
          defaultResponses.length];
    }
  }

  // Send a response message
  Future<void> _sendResponse(String chatId, String message) async {
    try {
      // Add the message to the chat
      await _firestore
          .collection('conversations')
          .doc(chatId)
          .collection('messages')
          .add({
            'text': message,
            'timestamp': FieldValue.serverTimestamp(),
            'isMine': false, // Bot messages are not from the user
          });

      // Update the conversation's last message
      await _firestore.collection('conversations').doc(chatId).update({
        'lastMessage': message,
        'timestamp': FieldValue.serverTimestamp(),
        'unread': true,
      });

      print("ChatBotService: Response sent successfully");
    } catch (e) {
      print("ChatBotService: Error sending response: $e");
    }
  }
}
