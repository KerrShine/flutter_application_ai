import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/form_design/form_action_binding/bloc/form_action_binding_bloc.dart';
import 'package:flutter_application_ai/service/form_action_binding_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

import 'action_binding_source_group_widget.dart';

class ActionBindingSourceListWidget extends StatelessWidget {
  final FormActionBindingState state;
  final ValueChanged<String> onSelectSourceItem;
  final ValueChanged<String> onSearchKeywordChanged;

  const ActionBindingSourceListWidget({
    super.key,
    required this.state,
    required this.onSelectSourceItem,
    required this.onSearchKeywordChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final groupedSourceItems = _groupSourceItems(state.filteredSourceItems);

    return Container(
      decoration: BoxDecoration(
        color: colors.sectionPanelBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.headerAccentBackground,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '互動來源元件',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.headerAccentForeground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '選擇來源元件並查看可用事件。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.subtleText,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              onChanged: onSearchKeywordChanged,
              decoration: InputDecoration(
                isDense: true,
                hintText: '搜尋元件名稱或代碼...',
                prefixIcon: const Icon(Icons.search, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: state.filteredSourceItems.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        state.searchKeyword.trim().isEmpty
                            ? '這份綁定目前沒有可配置互動的元件。'
                            : '找不到符合搜尋條件的元件。',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.faintText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    children: [
                      ActionBindingSourceGroupWidget(
                        title: '按鈕',
                        items: groupedSourceItems['button'] ?? const [],
                        state: state,
                        iconText: '按',
                        accentColor: colors.actionButtonAccent,
                        onSelectSourceItem: onSelectSourceItem,
                      ),
                      const SizedBox(height: 12),
                      ActionBindingSourceGroupWidget(
                        title: '下拉選單',
                        items: groupedSourceItems['dropdown'] ?? const [],
                        state: state,
                        iconText: '選',
                        accentColor: colors.actionDropdownAccent,
                        onSelectSourceItem: onSelectSourceItem,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Map<String, List<FormActionSourceItem>> _groupSourceItems(
    List<FormActionSourceItem> sourceItems,
  ) {
    final grouped = <String, List<FormActionSourceItem>>{
      'button': <FormActionSourceItem>[],
      'dropdown': <FormActionSourceItem>[],
    };

    for (final item in sourceItems) {
      grouped.putIfAbsent(item.sourceType, () => <FormActionSourceItem>[])
        ..add(item);
    }

    return grouped;
  }
}
