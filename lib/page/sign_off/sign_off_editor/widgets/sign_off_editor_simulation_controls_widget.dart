import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/bloc/sign_off_editor_bloc.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

/// 簽核流程編輯器頂部的「過期預覽」控制 — 切換 simulationMode 與輸入「發起 N 天前」推算各節點狀態（completed/inProgress/expired）。
class SignOffEditorSimulationControlsWidget extends StatelessWidget {
  final bool simulationMode;
  final int simulationDaysAgo;

  const SignOffEditorSimulationControlsWidget({
    super.key,
    required this.simulationMode,
    required this.simulationDaysAgo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
      fontWeight: FontWeight.w700,
      color: colors.headerChipText,
    );
    final bloc = context.read<SignOffEditorBloc>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.headerChipBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 16, color: colors.headerChipText),
          const SizedBox(width: 4),
          Text('過期預覽', style: labelStyle),
          const SizedBox(width: 4),
          Switch.adaptive(
            value: simulationMode,
            onChanged: (value) {
              bloc.add(value
                  ? const EnterSimulationEvent()
                  : const ExitSimulationEvent());
            },
          ),
          if (simulationMode) ...[
            const SizedBox(width: 4),
            SizedBox(
              width: 110,
              child: TextFormField(
                key: ValueKey('sim_days_$simulationMode'),
                initialValue: '$simulationDaysAgo',
                keyboardType: TextInputType.number,
                style: labelStyle,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '0',
                  suffixText: '天前',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
                onChanged: (value) {
                  final parsed = int.tryParse(value.trim()) ?? 0;
                  bloc.add(UpdateSimulationDaysEvent(parsed));
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
