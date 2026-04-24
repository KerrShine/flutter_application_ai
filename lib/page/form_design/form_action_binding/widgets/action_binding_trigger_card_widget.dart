import 'package:flutter/material.dart';
import 'package:flutter_application_ai/service/form_action_binding_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

/// 單一觸發事件選項卡（例如「點擊事件」、「載入完成事件」）。
/// 顯示事件名稱與說明，被選取時以 accent 色框標示，點選後回傳事件名稱。
class ActionBindingTriggerCardWidget extends StatelessWidget {
  final FormActionSourceItem selected;
  final String trigger;
  final bool isSelected;
  final VoidCallback onTap;

  const ActionBindingTriggerCardWidget({
    super.key,
    required this.selected,
    required this.trigger,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final accentColor = selected.sourceType == 'button'
        ? colors.actionButtonAccent
        : colors.actionDropdownAccent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.8)
                : theme.colorScheme.outline.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.circle_outlined,
              size: 18,
              color: isSelected
                  ? accentColor
                  : theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _triggerTitle(trigger),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _triggerDescription(trigger),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _triggerTitle(String trigger) {
    switch (trigger) {
      case 'buttonPressed':
        return '點擊事件';
      case 'dropdownChanged':
        return '選項變更事件';
      case 'dropdownLoaded':
        return '載入完成事件';
      default:
        return trigger;
    }
  }

  String _triggerDescription(String trigger) {
    switch (trigger) {
      case 'buttonPressed':
        return '使用者點擊按鈕時觸發此事件。';
      case 'dropdownChanged':
        return '使用者調整下拉選項後觸發此事件。';
      case 'dropdownLoaded':
        return '下拉元件初始化完成後觸發此事件。';
      default:
        return '此事件可用於案件互動設定。';
    }
  }
}
