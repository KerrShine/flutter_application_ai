import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

import 'binding_header_cell_widget.dart';

class BindingHeaderRowWidget extends StatelessWidget {
  const BindingHeaderRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FormDesignThemeColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.infoRowBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: const Row(
        children: [
          BindingHeaderCellWidget(flex: 36, text: '欄位名稱'),
          BindingHeaderCellWidget(flex: 12, text: '型別'),
          BindingHeaderCellWidget(flex: 30, text: '輸出 key'),
          BindingHeaderCellWidget(flex: 22, text: '空值策略'),
        ],
      ),
    );
  }
}
