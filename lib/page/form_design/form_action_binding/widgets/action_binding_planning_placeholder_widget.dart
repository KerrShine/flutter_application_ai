import 'package:flutter/material.dart';
import 'package:flutter_application_ai/service/form_action_binding_service.dart';

class ActionBindingPlanningPlaceholderWidget extends StatelessWidget {
  final FormActionSourceItem selected;
  final String selectedActionName;
  final String selectedTrigger;
  final ValueChanged<String> onSelectAction;

  const ActionBindingPlanningPlaceholderWidget({
    super.key,
    required this.selected,
    required this.selectedActionName,
    required this.selectedTrigger,
    required this.onSelectAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final triggerTitle = selectedTrigger.isEmpty
        ? '尚未選擇事件'
        : formActionTriggerDisplayName(selectedTrigger);
    final visibleActions = _resolveVisibleActions();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedTrigger.isEmpty ? '尚未選擇事件' : '目前選擇：$triggerTitle',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedTrigger.isEmpty
                ? '請從上方選擇事件節點。'
                : '請為 ${selected.label} 的 $triggerTitle 挑選要記錄的互動行為。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          if (selectedTrigger.isEmpty)
            Text(
              '尚未選擇事件節點。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleActions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = visibleActions[index];
                final isSelected = selectedActionName == item;

                return InkWell(
                  onTap: () {
                    onSelectAction(item);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.55)
                            : theme.colorScheme.outline.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            formActionDisplayName(item),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isSelected ? '啟用' : '未啟用',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.45),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          if (selectedTrigger.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              selectedActionName.isEmpty
                  ? '目前尚未記錄任何行為。'
                  : '目前已啟用：${formActionDisplayName(selectedActionName)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _resolveVisibleActions() {
    if (selectedTrigger.isEmpty) {
      return const [];
    }

    switch (selectedTrigger) {
      case 'buttonPressed':
        return selected.suggestedActions
            .where(
              (item) => [
                'navigate',
                'saveDraft',
                'submitForm',
                'callApi',
                'other'
              ].contains(item),
            )
            .toList();
      case 'dropdownLoaded':
        return selected.suggestedActions
            .where(
              (item) => ['loadDropdownOptions', 'setFieldValue', 'other']
                  .contains(item),
            )
            .toList();
      case 'dropdownChanged':
        return selected.suggestedActions
            .where(
              (item) => ['refreshTarget', 'setFieldValue', 'callApi', 'other']
                  .contains(item),
            )
            .toList();
      default:
        return selected.suggestedActions;
    }
  }
}
