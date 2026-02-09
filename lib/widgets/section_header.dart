import 'package:flutter/material.dart';
import 'package:alu_academic_assistant/theme/app_colors.dart';

/// A reusable section header widget to maintain consistency across the app.
///
/// Design Decision: Encapsulating the header style in a widget ensures that
/// all screens (Dashboard, Assignments, Schedule) have a uniform appearance
/// for section titles, adhering to the brand's visual hierarchy.
class SectionHeader extends StatelessWidget {
  final String title;
  final Color? color;
  final bool showIndicator;

  const SectionHeader({
    super.key,
    required this.title,
    this.color,
    this.showIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AluColors.primaryBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          if (showIndicator)
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: textColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          if (showIndicator) const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
