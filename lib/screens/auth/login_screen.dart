import 'package:flutter/material.dart';
import 'package:alu_academic_assistant/theme/app_colors.dart';
import 'package:alu_academic_assistant/models/models.dart';
import 'package:alu_academic_assistant/services/storage_service.dart';
import 'package:alu_academic_assistant/screens/main_screen.dart';
import 'package:alu_academic_assistant/screens/auth/signup_screen.dart';

/// Entry point screen for user authentication.
///
/// Design Decision: Using a card-based layout with a clear brand logo and
/// bold typography to create a professional first impression. The login
/// state is handled via the StorageService.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  /// Validates credentials and initiates the user session.
  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = await AppStorage.authenticateUser(username, password);
    setState(() => _isLoading = false);

    if (user != null) {
      await AppStorage.saveCurrentUser(user);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid username or password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Logs in as a guest with demo data for testing/exploration.
  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);

    // Create a guest user
    final guestUser = User(
      id: 'guest-user-id',
      username: 'guest',
      password: 'guest123',
      fullName: 'Guest User',
      year: 'Year 2',
      trimester: 'Trimester 1',
    );

    // Save guest session
    await AppStorage.saveCurrentUser(guestUser);

    // Create demo sessions for guest
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final demoSessions = [
      Session(
        title: 'Introduction to Computer Science',
        startTime: today.add(const Duration(hours: 9)),
        endTime: today.add(const Duration(hours: 11)),
        location: 'Room 101',
        type: 'Lecture',
      ),
      Session(
        title: 'Leadership Workshop',
        startTime: today.add(const Duration(days: 1, hours: 14)),
        endTime: today.add(const Duration(days: 1, hours: 16)),
        location: 'Conference Hall',
        type: 'Workshop',
      ),
    ];

    final demoAssignments = [
      Assignment(
        title: 'Final Project Proposal',
        courseName: 'Software Engineering',
        dueDate: today.add(const Duration(days: 3)),
        priority: 'High',
      ),
      Assignment(
        title: 'Weekly Reading Summary',
        courseName: 'Leadership Studies',
        dueDate: today.add(const Duration(days: 7)),
        priority: 'Medium',
      ),
    ];

    await AppStorage.saveSessions(demoSessions);
    await AppStorage.saveAssignments(demoAssignments);

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AluColors.primaryBlue,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.school,
                    size: 60,
                    color: AluColors.primaryBlue,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ALU Academic Assistant',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AluColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AluColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Login',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    ),
                    child: const Text(
                      'Create an account',
                      style: TextStyle(color: AluColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[400])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGuestLogin,
                    icon: const Icon(Icons.person_outline),
                    label: const Text('Continue as Guest'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AluColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AluColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
