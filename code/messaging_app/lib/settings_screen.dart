import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'text_to_speech_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextToSpeechService _tts = TextToSpeechService();
  final AuthService _authService = AuthService();

  // Text size options
  final List<Map<String, dynamic>> textSizeOptions = [
    {'label': 'Small', 'value': 0.85},
    {'label': 'Medium', 'value': 1.0},
    {'label': 'Large', 'value': 1.15},
    {'label': 'Extra Large', 'value': 1.3},
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  // Initialize text-to-speech
  Future<void> _initTts() async {
    await _tts.initialize();
  }

  // Test text-to-speech
  Future<void> _speak(String text) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attempting to speak text...')),
    );

    await _tts.speak(text);
  }

  // Sign out and navigate to login screen
  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Appearance section
              _buildSectionHeader('Appearance'),

              // Dark Mode Toggle
              _buildSwitchTile(
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark themes',
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleDarkMode();
                },
              ),

              // High Contrast Toggle
              _buildSwitchTile(
                title: 'High Contrast',
                subtitle: 'Increase contrast for better visibility',
                value: themeProvider.isHighContrast,
                onChanged: (value) {
                  themeProvider.toggleHighContrast();
                },
              ),

              const Divider(),

              // Text Size section
              _buildSectionHeader('Text Size'),

              // Text Size Slider
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    const Text('A', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Slider(
                        value: themeProvider.textScaleFactor,
                        min: 0.8,
                        max: 1.5,
                        divisions: 7,
                        label: themeProvider.textScaleFactor.toStringAsFixed(2),
                        onChanged: (value) {
                          themeProvider.setTextScaleFactor(value);
                        },
                      ),
                    ),
                    const Text('A', style: TextStyle(fontSize: 24)),
                  ],
                ),
              ),

              // Text Size Presets
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 8.0,
                  children:
                      textSizeOptions.map((option) {
                        return ChoiceChip(
                          label: Text(option['label']),
                          selected:
                              (themeProvider.textScaleFactor - option['value'])
                                  .abs() <
                              0.05,
                          onSelected: (selected) {
                            if (selected) {
                              themeProvider.setTextScaleFactor(option['value']);
                            }
                          },
                        );
                      }).toList(),
                ),
              ),

              // Sample Text
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Text(
                    'This is a sample text to preview your selected text size.',
                    style: TextStyle(
                      fontSize: 16 * themeProvider.textScaleFactor,
                    ),
                  ),
                ),
              ),

              const Divider(),

              // Accessibility section
              _buildSectionHeader('Accessibility'),

              // Text-to-Speech Toggle
              _buildSwitchTile(
                title: 'Text-to-Speech',
                subtitle: 'Read messages aloud',
                value: themeProvider.isTextToSpeechEnabled,
                onChanged: (value) {
                  themeProvider.toggleTextToSpeech();
                },
              ),

              // Test TTS Button
              if (themeProvider.isTextToSpeechEnabled)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _speak(
                            "This is a test of the text to speech feature. If you can hear this, text to speech is working correctly.",
                          );
                        },
                        child: const Text('Test Text-to-Speech'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Note: Make sure your device volume is turned up and not on silent mode.',
                        style: TextStyle(
                          fontSize: 12 * themeProvider.textScaleFactor,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

              const Divider(),

              // Account section
              _buildSectionHeader('Account'),

              // Logout Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Log Out'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to build section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18 * Provider.of<ThemeProvider>(context).textScaleFactor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper method to build switch tiles
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final textScaleFactor = Provider.of<ThemeProvider>(context).textScaleFactor;

    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 16 * textScaleFactor)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14 * textScaleFactor),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
