import 'package:flutter/material.dart';
import 'package:alu_academic_assistant/theme/app_colors.dart';
import 'package:alu_academic_assistant/models/models.dart';
import 'package:alu_academic_assistant/services/storage_service.dart';
import 'package:alu_academic_assistant/screens/main_screen.dart';

/// Module for new user registration and initial data setup.
/// Design Decision: Onboarding includes creating mock sessions based on
/// the selected trimester, providing a "cold start" experience that demonstrates the app's value immediately after registration.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedYear = 'Year 2';
  String _selectedTrimester = 'Trimester 1';

  final List<String> _years = ['Year 1', 'Year 2', 'Year 3'];
  final List<String> _trimesters = [
    'Trimester 1',
    'Trimester 2',
    'Trimester 3',
  ];

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  /// Validates input and creates a new user account with sample data.
  Future<void> _handleSignup() async {
    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (fullName.isEmpty || username.isEmpty || password.isEmpty) {
      _showError('All fields are required');
      return;
    }

    if (password != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    final user = User(
      username: username,
      password: password,
      fullName: fullName,
      year: _selectedYear,
      trimester: _selectedTrimester,
    );

    final success = await AppStorage.registerUser(user);
    if (!success) {
      setState(() => _isLoading = false);
      _showError('Username already taken');
      return;
    }

    await AppStorage.saveCurrentUser(user);

    // Seed initial data for a better first-time experience
    final sessions = _getMockSessions(_selectedYear, _selectedTrimester);
    await AppStorage.saveSessions(sessions);

    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  List<Session> _getMockSessions(String year, String trimester) {
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);

    return [
      Session(
        title: 'Core Fundamentals ($year $trimester)',
        startTime: dateOnly.add(const Duration(hours: 9)),
        endTime: dateOnly.add(const Duration(hours: 11)),
        location: 'Kigali Campus - Room 202',
        type: 'Lecture',
      ),
      Session(
        title: 'Leadership Workshop',
        startTime: dateOnly.add(const Duration(days: 1, hours: 10)),
        endTime: dateOnly.add(const Duration(days: 1, hours: 12)),
        location: 'In-person / Online',
        type: 'Workshop',
      ),
    ];
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
                children: [
                  const Text(
                    'Join ALU Assistant',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AluColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    _fullNameController,
                    'Full Name',
                    Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _usernameController,
                    'Username',
                    Icons.account_circle,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _passwordController,
                    'Password',
                    Icons.lock,
                    obscure: _obscurePassword,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _confirmPasswordController,
                    'Confirm Password',
                    Icons.lock_outline,
                    obscure: _obscureConfirmPassword,
                    isConfirmPassword: true,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    'Academic Year',
                    _selectedYear,
                    _years,
                    (val) => setState(() => _selectedYear = val!),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    'Trimester',
                    _selectedTrimester,
                    _trimesters,
                    (val) => setState(() => _selectedTrimester = val!),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AluColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Register Account'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
    bool isPassword = false,
    bool isConfirmPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword || isConfirmPassword
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    if (isPassword) {
                      _obscurePassword = !_obscurePassword;
                    } else if (isConfirmPassword) {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    }
                  });
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
