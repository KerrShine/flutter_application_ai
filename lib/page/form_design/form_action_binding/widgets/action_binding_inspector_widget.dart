import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/form_design/form_action_binding/bloc/form_action_binding_bloc.dart';
import 'package:flutter_application_ai/service/form_action_binding_service.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

import 'action_binding_hint_card_widget.dart';

class ActionBindingInspectorWidget extends StatelessWidget {
  final FormActionBindingState state;
  final bool isSaving;
  final VoidCallback onExportPreview;
  final VoidCallback onSaveSettings;

  const ActionBindingInspectorWidget({
    super.key,
    required this.state,
    required this.isSaving,
    required this.onExportPreview,
    required this.onSaveSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;
    final selected = state.selectedSourceItem;
    final issues = _buildPlanningHints(state);
    final actionDescriptions = _buildApprovalActionDescriptions(state);

    return Container(
      decoration: BoxDecoration(
        color: colors.infoPanelBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.panelBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('互動摘要', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Text(
                      selected == null ? '尚未選取元件' : selected.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.headerAccentForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      selected == null
                          ? '請從左側選擇一個來源元件。'
                          : '${_sourceTypeLabel(selected.sourceType)}的案件互動摘要。',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.faintText,
                        height: 1.5,
                      ),
                    ),
                    if (selected != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        state.selectedTrigger.isEmpty
                            ? '尚未選擇事件節點'
                            : '目前事件：${_triggerLabel(state.selectedTrigger)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.headerAccentForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Text('電子簽核可執行行為', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(
                      _buildActionSectionDescription(selected),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.faintText,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (actionDescriptions.isEmpty)
                      ActionBindingHintCardWidget(
                        text: _buildEmptyActionDescription(state),
                        tone: FormActionBindingHintTone.info,
                      )
                    else
                      ...actionDescriptions.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ActionBindingHintCardWidget(
                            text: item.text,
                            tone: item.tone,
                          ),
                        );
                      }),
                    if (issues.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('補充提醒', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 10),
                      ...issues.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ActionBindingHintCardWidget(
                            text: item.text,
                            tone: item.tone,
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: isSaving ? null : onExportPreview,
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('匯出設定預覽'),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: isSaving ? null : onSaveSettings,
                  icon: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(isSaving ? '儲存中' : '儲存設定'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<FormActionBindingHintItem> _buildPlanningHints(
    FormActionBindingState state,
  ) {
    final selected = state.selectedSourceItem;
    if (selected == null) {
      return const [
        FormActionBindingHintItem(
          '請先選擇來源元件。',
          FormActionBindingHintTone.warning,
        ),
      ];
    }

    final hints = <FormActionBindingHintItem>[];

    if (state.selectedTrigger.isEmpty) {
      hints.add(
        const FormActionBindingHintItem(
          '此元件尚未選擇事件節點。',
          FormActionBindingHintTone.warning,
        ),
      );
    }

    if (selected.sourceType == 'button') {
      hints.add(
        const FormActionBindingHintItem(
          '按鈕可使用點擊事件建立案件互動內容。',
          FormActionBindingHintTone.info,
        ),
      );
    }

    if (selected.sourceType == 'dropdown') {
      hints.add(
        const FormActionBindingHintItem(
          '下拉選單可使用載入事件與變更事件建立案件互動內容。',
          FormActionBindingHintTone.info,
        ),
      );
    }

    if (state.selectedTrigger.isNotEmpty) {
      hints.add(
        const FormActionBindingHintItem(
          '已選擇事件節點。',
          FormActionBindingHintTone.success,
        ),
      );
    }

    return hints;
  }

  List<FormActionBindingHintItem> _buildApprovalActionDescriptions(
    FormActionBindingState state,
  ) {
    final selected = state.selectedSourceItem;
    if (selected == null) {
      return const [];
    }

    final selectedTrigger = state.selectedTrigger;
    final selectedAction = state.selectedActionName;
    if (selectedTrigger.isEmpty || selectedAction.isEmpty) {
      return const [];
    }

    final description = _approvalActionDescription(
      selected: selected,
      trigger: selectedTrigger,
      action: selectedAction,
    );
    if (description == null) {
      return const [];
    }

    return [
      FormActionBindingHintItem(
        description,
        _approvalActionTone(selectedAction),
      ),
    ];
  }

  String _buildActionSectionDescription(FormActionSourceItem? selected) {
    if (selected == null) {
      return '選取元件後顯示此元件在電子簽核流程中可配置的互動行為。';
    }

    return '依目前點選的事件節點，顯示 ${selected.label} 在電子簽核中可執行的功能說明。';
  }

  String _buildEmptyActionDescription(FormActionBindingState state) {
    if (state.selectedSourceItem == null) {
      return '目前尚未選取元件。';
    }

    if (state.selectedTrigger.isEmpty) {
      return '請先點選中間欄位的事件節點，再查看對應的電子簽核功能說明。';
    }

    if (state.selectedActionName.isEmpty) {
      return '請從中間清單選擇一個要啟用的行為。';
    }

    return '目前事件沒有可顯示的電子簽核功能說明。';
  }

  String? _approvalActionDescription({
    required FormActionSourceItem selected,
    required String trigger,
    required String action,
  }) {
    switch (action) {
      case 'navigate':
        return '頁面跳轉：在電子簽核中可於${_resolveTriggerContext(trigger, fallback: '按鈕點擊後')}導向指定頁面，例如簽核明細、附件頁或補件畫面。';
      case 'saveDraft':
        return '暫存草稿：在簽核人尚未完成操作前，先保留目前輸入與選項，供後續回到流程時續編。';
      case 'submitForm':
        return '送出表單：於簽核操作完成後正式送出資料，可作為送審、核准、退回或結案流程的觸發點。';
      case 'callApi':
        return '呼叫API：於${_resolveTriggerContext(trigger, fallback: '事件觸發後')}串接外部流程或簽核 API，例如寫入簽核紀錄、同步狀態或通知下一關。';
      case 'loadDropdownOptions':
        return '載入選項：在電子簽核頁面初始化或條件切換時，動態取得可選的簽核意見、部門、流程節點或處理原因。';
      case 'refreshTarget':
        return '更新目標欄位：當${_resolveTriggerContext(trigger, fallback: '下拉選項變更後')}，同步刷新其他欄位內容，例如簽核路徑、顯示區塊或可編輯狀態。';
      case 'setFieldValue':
        return '帶入欄位值：依目前選項自動填入電子簽核所需欄位，例如預設簽核人、意見範本、狀態碼或節點代號。';
      case 'other':
        return '其他：保留給後續新增的自訂簽核行為，可用於尚未明確定義的流程控制、資料轉換或外部擴充。';
      default:
        return null;
    }
  }

  FormActionBindingHintTone _approvalActionTone(String action) {
    switch (action) {
      case 'submitForm':
      case 'callApi':
        return FormActionBindingHintTone.warning;
      case 'navigate':
      case 'saveDraft':
        return FormActionBindingHintTone.success;
      case 'other':
        return FormActionBindingHintTone.info;
      default:
        return FormActionBindingHintTone.info;
    }
  }

  String _resolveTriggerContext(String trigger, {required String fallback}) {
    switch (trigger) {
      case 'buttonPressed':
        return '按下按鈕時';
      case 'dropdownChanged':
        return '選項變更時';
      case 'dropdownLoaded':
        return '選項載入完成時';
      default:
        return fallback;
    }
  }

  String _sourceTypeLabel(String sourceType) {
    switch (sourceType) {
      case 'button':
        return '按鈕';
      case 'dropdown':
        return '下拉選單';
      default:
        return sourceType;
    }
  }

  String _triggerLabel(String trigger) {
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
}
