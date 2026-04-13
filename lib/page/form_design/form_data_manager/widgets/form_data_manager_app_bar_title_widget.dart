import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class FormDataManagerAppBarTitleWidget extends StatelessWidget {
  final String formName;

  const FormDataManagerAppBarTitleWidget({
    super.key,
    required this.formName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FormDesignThemeColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formName.isEmpty ? '表單綁定資料管理' : formName),
        Text(
          '管理同模板下的多份綁定資料、版本與匯出設定',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.faintText,
              ),
        ),
      ],
    );
  }
}
