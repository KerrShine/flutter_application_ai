import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/form_submission_model.dart';
import 'package:flutter_application_ai/theme/form_application_center_theme_colors.dart';

class ApplicationSubmissionSectionWidget extends StatelessWidget {
  final List<FormSubmissionModel> submissions;

  const ApplicationSubmissionSectionWidget({
    super.key,
    required this.submissions,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormApplicationCenterThemeColors>()!;

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '我的申請紀錄（${submissions.length}）',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                final sub = submissions[index];
                return Card(
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      sub.isSubmitted
                          ? Icons.check_circle
                          : Icons.hourglass_empty,
                      color: sub.isSubmitted
                          ? themeColors.submittedIcon
                          : themeColors.pendingIcon,
                      size: 20,
                    ),
                    title: Text(sub.formName),
                    subtitle: Text(sub.submittedAt),
                    trailing: Chip(
                      label: Text(
                        sub.status,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
