import 'package:flutter/material.dart';
import 'package:flutter_application_ai/service/form_application_service.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';

class ApplicationFormGridWidget extends StatelessWidget {
  final List<AvailableFormItem> forms;
  final void Function(String formId, String bindingId) onSelectForm;

  const ApplicationFormGridWidget({
    super.key,
    required this.forms,
    required this.onSelectForm,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors =
        Theme.of(context).extension<FormApplicationThemeColors>()!;

    if (forms.isEmpty) {
      return Center(
        child: Text(
          '目前沒有可發起的表單',
          style: TextStyle(fontSize: 16, color: themeColors.emptyText),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
                ? 2
                : 1;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
          ),
          itemCount: forms.length,
          itemBuilder: (context, index) {
            final form = forms[index];
            return Card(
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelectForm(form.formId, form.bindingId),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description,
                              color: themeColors.formIcon, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              form.formName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '點擊開始填寫申請',
                        style:
                            TextStyle(fontSize: 13, color: themeColors.hintText),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
