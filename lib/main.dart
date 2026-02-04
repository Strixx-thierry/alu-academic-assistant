import 'package:flutter/material.dart';
import 'colors.dart';
import 'dashboard_screen.dart';

void main() {
  runApp(const AluAcademicAssistant());
}

class AluAcademicAssistant extends StatelessWidget {
  const AluAcademicAssistant({super.key});

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
          secondary: AluColors.secondaryRed,
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
