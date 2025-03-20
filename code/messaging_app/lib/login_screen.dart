import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'chat_list_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Show a loading dialog or indicator
            showDialog(
              context: context,
              barrierDismissible:
                  false, // Prevent dismissing the dialog by tapping outside
              builder:
                  (context) => const Center(child: CircularProgressIndicator()),
            );

            // Sign in with Google
            final user = await AuthService().signInWithGoogle();

            // Close the loading dialog
            Navigator.pop(context);

            if (user != null) {
              // If the user signed in successfully, navigate to the chat screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ChatListScreen()),
              );
            } else {
              // Show an error message if sign-in failed
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sign-in failed. Please try again.'),
                ),
              );
            }
          },
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
