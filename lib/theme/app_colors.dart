import 'package:flutter/material.dart';

/// AluColors contains the centralized brand identity colors for the ALU Academic Assistant.
///
/// Design Decision: Centralizing theme tokens ensures visual consistency across
/// different modules developed by various team members. It also simplifies
/// future theme updates (e.g., implementing Dark Mode).
class AluColors {
  // ALU Brand Primary Blue: Used for headers, primary buttons, and navigation.
  static const Color primaryBlue = Color(0xFF003366);

  // ALU Brand Primary Red: Used for warnings, overdue assignments, and focus elements.
  static const Color primaryRed = Color(0xFFA32638);

  // Light background color for a clean, professional academic aesthetic.
  static const Color backgroundGrey = Color(0xFFF5F5F5);

  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
