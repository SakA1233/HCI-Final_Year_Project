import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'chat_list_screen.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isHighContrast = themeProvider.isHighContrast;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Name
              Text(
                'Lumina',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color:
                      isHighContrast
                          ? (isDark ? Colors.white : Colors.black)
                          : Colors.lightBlue[700],
                ),
              ),
              const SizedBox(height: 16.0),

              // Caption
              Text(
                'Empowering Conversations',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 40.0),

              // Email TextField
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'example@domain.com',
                  prefixIcon: Icon(
                    Icons.email,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Password TextField
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Sign In with Email
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            setState(() => _isLoading = true);
                            // Loading
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (_) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            );

                            // Email sign-in
                            final user = await AuthService().signInWithEmail(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );

                            Navigator.pop(context);
                            setState(() => _isLoading = false);

                            if (user != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChatListScreen(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Email sign-in failed. Please try again.',
                                  ),
                                ),
                              );
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isHighContrast
                            ? (isDark ? Colors.white : Colors.black)
                            : Colors.lightBlue,
                    foregroundColor:
                        isHighContrast
                            ? (isDark ? Colors.black : Colors.white)
                            : Colors.white,
                    textStyle: const TextStyle(fontSize: 18),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Sign In with Email'),
                ),
              ),
              const SizedBox(height: 8.0),

              // Sign Up with Email
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            setState(() => _isLoading = true);
                            // Loading
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (_) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            );

                            final user = await AuthService().signUpWithEmail(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );

                            Navigator.pop(context);
                            setState(() => _isLoading = false);

                            if (user != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChatListScreen(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Email sign-up failed. Please try again.',
                                  ),
                                ),
                              );
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isHighContrast
                            ? (isDark ? Colors.grey[300] : Colors.grey[700])
                            : Colors.lightBlue[300],
                    foregroundColor:
                        isHighContrast
                            ? (isDark ? Colors.black : Colors.white)
                            : Colors.white,
                    textStyle: const TextStyle(fontSize: 18),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Sign Up with Email'),
                ),
              ),
              const SizedBox(height: 24.0),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Sign in with Google
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            setState(() => _isLoading = true);
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (_) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            );

                            final user = await AuthService().signInWithGoogle();

                            Navigator.pop(context);
                            setState(() => _isLoading = false);

                            if (user != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChatListScreen(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Google sign-in failed. Please try again.',
                                  ),
                                ),
                              );
                            }
                          },
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                    textStyle: const TextStyle(fontSize: 18),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.black12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              Text(
                'By continuing, you agree to our Terms and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
