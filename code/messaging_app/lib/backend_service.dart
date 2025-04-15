import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class BackendService {
  // Use your computer's local IP address instead of localhost
  // You can find this by running 'ipconfig' on Windows or 'ifconfig' on Mac/Linux
  final String baseUrl =
      'http://192.168.0.47:3000'; // Replace with your actual IP address and port
  final Duration timeout = const Duration(seconds: 10);
  final int maxRetries = 2;
  String? _lastMessageTimestamp;

  // Get the current user's ID token for authentication
  Future<String> _getIdToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
  }

  // Helper method to create HTTP client with timeout
  http.Client _createClient() {
    return http.Client();
  }

  // Helper method to handle HTTP requests with retry logic
  Future<http.Response> _makeRequest(
    Future<http.Response> Function() request,
  ) async {
    http.Client client = _createClient();
    int attempts = 0;

    try {
      while (attempts < maxRetries) {
        try {
          final response = await request().timeout(timeout);
          return response;
        } on SocketException catch (e) {
          attempts++;
          if (attempts >= maxRetries) rethrow;
          await Future.delayed(Duration(seconds: 1 * attempts));
          continue;
        } on TimeoutException catch (e) {
          attempts++;
          if (attempts >= maxRetries) rethrow;
          await Future.delayed(Duration(seconds: 1 * attempts));
          continue;
        }
      }
      throw Exception('Failed after $maxRetries attempts');
    } finally {
      client.close();
    }
  }

  // Send a message through the backend
  Future<bool> sendMessage(String chatId, String message) async {
    try {
      final token = await _getIdToken();

      final response = await _makeRequest(
        () => http.post(
          Uri.parse('$baseUrl/send-message'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'chatId': chatId, 'text': message}),
        ),
      );

      if (response.statusCode == 200) {
        // Reset the last message timestamp to force a refresh
        _lastMessageTimestamp = null;
        return true;
      } else {
        print('Error sending message: ${response.body}');
        return false;
      }
    } on SocketException catch (e) {
      print('Connection error sending message: $e');
      return false;
    } on TimeoutException catch (e) {
      print('Timeout sending message: $e');
      return false;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // Fetch messages for a chat
  Future<List<Map<String, dynamic>>> fetchMessages(String chatId) async {
    try {
      final token = await _getIdToken();
      print('Fetching messages for chat: $chatId');

      final response = await _makeRequest(
        () => http.get(
          Uri.parse('$baseUrl/messages/$chatId'),
          headers: {
            'Authorization': 'Bearer $token',
            if (_lastMessageTimestamp != null)
              'If-Modified-Since': _lastMessageTimestamp!,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final messages = data['messages'] as List<dynamic>;
        print('Received ${messages.length} messages from server');

        if (messages.isNotEmpty) {
          _lastMessageTimestamp = messages.first['timestamp'];
          print('Updated last message timestamp to: $_lastMessageTimestamp');
        }

        final processedMessages =
            messages
                .map<Map<String, dynamic>>(
                  (msg) => {
                    'id': msg['id'],
                    'text': msg['text'],
                    'timestamp': msg['timestamp'],
                    'isMine': msg['isMine'],
                  },
                )
                .toList();

        print('Processed ${processedMessages.length} messages');
        return processedMessages;
      } else if (response.statusCode == 304) {
        // No new messages, return null to indicate no change needed
        print('No new messages (304 response)');
        return []; // This will be handled by the UI to keep existing messages
      } else {
        print('Error fetching messages: ${response.body}');
        throw Exception('Server returned ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('Connection error fetching messages: $e');
      throw Exception(
        'Cannot connect to server. Please check your connection.',
      );
    } on TimeoutException catch (e) {
      print('Timeout fetching messages: $e');
      throw Exception('Server request timed out. Please try again.');
    } catch (e) {
      print('Error fetching messages: $e');
      throw Exception('Failed to fetch messages: $e');
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

  // Fetch all chats
  Future<List<Map<String, dynamic>>> fetchChats() async {
    try {
      final token = await _getIdToken();
      final response = await http.get(
        Uri.parse('$baseUrl/chats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final chats = data['chats'] as List<dynamic>;
        return chats
            .map<Map<String, dynamic>>((chat) => chat as Map<String, dynamic>)
            .toList();
      } else {
        print('Error fetching chats: ${response.body}');
        throw Exception('Failed to fetch chats: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching chats: $e');
      throw Exception('Failed to fetch chats: $e');
    }
  }
}
