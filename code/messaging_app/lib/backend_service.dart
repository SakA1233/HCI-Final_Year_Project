import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class BackendService {
  final String baseUrl = 'http://localhost:3000';

  // Get the current user's ID token for authentication
  Future<String> _getIdToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
  }

  // Send a message through the backend
  Future<bool> sendMessage(String chatId, String message) async {
    try {
      final token = await _getIdToken();
      final response = await http.post(
        Uri.parse('$baseUrl/send-message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'chatId': chatId, 'text': message}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error sending message: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception sending message: $e');
      return false;
    }
  }

  // Fetch messages for a chat
  Future<List<Map<String, dynamic>>> fetchMessages(String chatId) async {
    try {
      final token = await _getIdToken();
      final response = await http.get(
        Uri.parse('$baseUrl/messages/$chatId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final messages = data['messages'] as List<dynamic>;
        return messages
            .map<Map<String, dynamic>>(
              (msg) => {
                'id': msg['id'],
                'text': msg['text'],
                'timestamp': msg['timestamp'],
                'isMine': msg['isMine'],
              },
            )
            .toList();
      } else {
        print('Error fetching messages: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception fetching messages: $e');
      return [];
    }
  }

  // Create a new chat
  Future<String?> createChat(String chatName) async {
    try {
      final token = await _getIdToken();
      final response = await http.post(
        Uri.parse('$baseUrl/create-chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': chatName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['chatId'];
      } else {
        print('Error creating chat: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception creating chat: $e');
      return null;
    }
  }

  // Update chat name
  Future<bool> updateChatName(String chatId, String newName) async {
    try {
      final token = await _getIdToken();
      final response = await http.post(
        Uri.parse('$baseUrl/update-chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'chatId': chatId, 'name': newName}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error updating chat name: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception updating chat name: $e');
      return false;
    }
  }

  // Delete a chat
  Future<bool> deleteChat(String chatId) async {
    try {
      final token = await _getIdToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/delete-chat/$chatId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error deleting chat: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception deleting chat: $e');
      return false;
    }
  }
}
