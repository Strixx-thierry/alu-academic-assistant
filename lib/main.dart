import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await AppStorage.isLoggedIn();
  runApp(AluAcademicAssistant(isLoggedIn: isLoggedIn));
}

class AluAcademicAssistant extends StatelessWidget {
  final bool isLoggedIn;
  const AluAcademicAssistant({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Academic Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AluColors.primaryBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AluColors.primaryBlue,
          primary: AluColors.primaryBlue,
          secondary: AluColors.primaryRed,
        ),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
    );
  }
}
