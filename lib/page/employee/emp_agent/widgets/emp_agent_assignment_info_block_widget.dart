import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/emp_agent_theme_colors.dart';

class EmpAgentAssignmentInfoBlockWidget extends StatelessWidget {
  final String title;
  final List<String> lines;

  const EmpAgentAssignmentInfoBlockWidget({
    super.key,
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).extension<EmpAgentThemeColors>()!;

    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: themeColors.infoBlockTitle,
            ),
          ),
          const SizedBox(height: 6),
          ...lines.where((line) => line.trim().isNotEmpty).map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    line,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeColors.infoBlockText,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
