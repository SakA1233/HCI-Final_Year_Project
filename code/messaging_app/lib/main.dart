import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'theme_provider.dart';
import 'firebase_options.dart';
import 'chat_bot_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initializePlugins();

  // Initialize and start the ChatBotService
  ChatBotService().startListening();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

Future<void> _initializePlugins() async {
  try {
    await SharedPreferences.getInstance();

    // Initialize FlutterTts
    FlutterTts flutterTts = FlutterTts();
    await flutterTts.setLanguage("en-US");

    print("Plugins initialized successfully");
  } catch (e) {
    print("Error initializing plugins: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Chat App',
          theme: themeProvider.getTheme(),
          builder: (context, child) {
            // Apply text scaling to the entire app
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaleFactor: themeProvider.textScaleFactor),
              child: child!,
            );
          },
          home: const LoginScreen(),
        );
      },
    );
  }
}
