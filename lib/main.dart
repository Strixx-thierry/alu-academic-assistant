import 'package:flutter/material.dart';
import 'colors.dart';
import 'onboarding_screen.dart';
import 'main_screen.dart';
import 'storage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await AppStorage.loadUserConfig();
  runApp(AluAcademicAssistant(isLoggedIn: config != null));
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
      home: isLoggedIn ? const MainScreen() : const OnboardingScreen(),
    );
  }
}
