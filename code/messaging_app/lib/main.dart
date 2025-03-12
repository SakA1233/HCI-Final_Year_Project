import 'package:flutter/material.dart'; // Flutter UI components
import 'package:firebase_core/firebase_core.dart'; // Firebase core setup
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database
import 'firebase_options.dart'; // Firebase config

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is ready
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Init Firebase
  runApp(const MyApp()); // Run the app
}

// Main app widget
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      initialRoute: '/',
      routes: {
        '/': (context) => const ChatListScreen(), // Home screen
        '/chat': (context) => const ChatConversationScreen(), // Chat screen
      },
    );
  }
}

// Chat list screen
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat List')), // Screen title
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('List of chats will go here.'), // Placeholder
            const SizedBox(height: 20), // Spacing
            ElevatedButton(
              onPressed: () async {
                // Add a test message to Firestore
                await FirebaseFirestore.instance.collection('chats').add({
                  'message': 'Hello from Flutter!',
                  'timestamp': FieldValue.serverTimestamp(),
                });
                print('Test message added to Firestore!');
              },
              child: const Text('Test Firestore Write'), // Button to write data
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the chat screen
                Navigator.pushNamed(context, '/chat');
              },
              child: const Text(
                'Go to Chat Conversation',
              ), // Button to open chat
            ),
          ],
        ),
      ),
    );
  }
}

// Chat conversation screen
class ChatConversationScreen extends StatelessWidget {
  const ChatConversationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Conversation')), // Screen title
      body: const Center(
        child: Text('Conversation details here.'),
      ), // Placeholder
    );
  }
}
