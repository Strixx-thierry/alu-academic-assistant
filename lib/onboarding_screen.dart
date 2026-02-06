import 'package:flutter/material.dart';
import 'colors.dart';
import 'models.dart';
import 'storage.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  String _selectedYear = 'Year 2';
  String _selectedTrimester = 'Trimester 1';

  final List<String> _years = ['Year 1', 'Year 2', 'Year 3'];
  final List<String> _trimesters = [
    'Trimester 1',
    'Trimester 2',
    'Trimester 3',
  ];

  bool _isCreating = false;

  void _finishOnboarding() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    final config = UserConfig(
      studentName: _nameController.text,
      year: _selectedYear,
      trimester: _selectedTrimester,
    );

    await AppStorage.saveUserConfig(config);

    // Mock "pulling" subjects based on trimester
    final sessions = _getMockSessions(_selectedYear, _selectedTrimester);
    await AppStorage.saveSessions(sessions);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  List<Session> _getMockSessions(String year, String trimester) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      Session(
        id: '1',
        title: 'Core Fundamentals ($year $trimester)',
        startTime: today.add(const Duration(hours: 9)),
        endTime: today.add(const Duration(hours: 11)),
        location: 'Kigali Campus - Room 202',
        type: 'Lecture',
      ),
      Session(
        id: '2',
        title: 'Software Development Lab',
        startTime: today.add(const Duration(hours: 13)),
        endTime: today.add(const Duration(hours: 15)),
        location: 'Innovation Hub',
        type: 'Practical',
      ),
      Session(
        id: '3',
        title: 'Leadership Workshop',
        startTime: today.add(const Duration(days: 1, hours: 10)),
        endTime: today.add(const Duration(days: 1, hours: 12)),
        location: 'Online Zoom',
        type: 'Workshop',
      ),
      Session(
        id: '4',
        title: 'Business Communication',
        startTime: today.add(const Duration(days: 2, hours: 14)),
        endTime: today.add(const Duration(days: 2, hours: 16)),
        location: 'B-Block Room 1',
        type: 'Lecture',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AluColors.primaryBlue,
              AluColors.primaryBlue.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/en/thumb/3/35/African_Leadership_University_logo.png/220px-African_Leadership_University_logo.png',
                        height: 60,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.school,
                              size: 60,
                              color: AluColors.primaryBlue,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isCreating ? 'Create Account' : 'Welcome Back',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AluColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your Academic Success Starts Here',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      if (!_isCreating) ...[
                        ElevatedButton(
                          onPressed: () {
                            _nameController.text = "Thierry";
                            _finishOnboarding();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AluColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Select Active Account (Thierry)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => setState(() => _isCreating = true),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            side: const BorderSide(
                              color: AluColors.primaryBlue,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Create New Account',
                            style: TextStyle(
                              color: AluColors.primaryBlue,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ] else ...[
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedYear,
                          decoration: InputDecoration(
                            labelText: 'Academic Year',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: _years
                              .map(
                                (y) =>
                                    DropdownMenuItem(value: y, child: Text(y)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedYear = val!),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedTrimester,
                          decoration: InputDecoration(
                            labelText: 'Trimester',
                            prefixIcon: const Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: _trimesters
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedTrimester = val!),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _finishOnboarding,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AluColors.primaryRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Get My Schedule',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() => _isCreating = false),
                          child: const Text('Already have an account? Login'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
