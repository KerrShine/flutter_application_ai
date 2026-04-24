import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/service/form_data_manager_service.dart';

part 'form_data_manager_event.dart';
part 'form_data_manager_state.dart';

class FormDataManagerBloc
    extends Bloc<FormDataManagerEvent, FormDataManagerState> {
  final FormDataManagerService formDataManagerService;

  FormDataManagerBloc(this.formDataManagerService)
      : super(const FormDataManagerState()) {
    on<CompleteDeleteDialogEvent>(_onCompleteDeleteDialogEvent);
    on<CompleteExportJsonPreviewEvent>(_onCompleteExportJsonPreviewEvent);
    on<CompleteNavigationEvent>(_onCompleteNavigationEvent);
    on<DeleteBindingEvent>(_onDeleteBindingEvent);
    on<ExportJsonEvent>(_onExportJsonEvent);
    on<InitEvent>(_onInitEvent);
    on<NavigateToDataBindingEvent>(_onNavigateToDataBindingEvent);
    on<PreviewApiExportEvent>(_onPreviewApiExportEvent);
    on<RequestDeleteBindingEvent>(_onRequestDeleteBindingEvent);
    on<SelectBindingEvent>(_onSelectBindingEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<FormDataManagerState> emit,
  ) async {
    emit(state.copyWith(
      status: FormDataManagerStatus.loading,
      formId: event.formId,
    ));

    final result = await formDataManagerService.initialize(event.formId);
    if (result.isSuccess) {
      final initialData = result.data;
      final form = initialData?.form;
      final bindingDrafts =
          initialData?.bindingDrafts ?? const <FormDataBindingDraft>[];
      final bindings = _buildBindings(bindingDrafts);
      final selectedBindingId = bindings.isEmpty ? '' : bindings.first.id;
      final latestTemplateVersion = bindings.fold<int>(
        0,
        (current, item) =>
            item.templateVersion > current ? item.templateVersion : current,
      );
      emit(state.copyWith(
        status: FormDataManagerStatus.success,
        formId: event.formId,
        formName: form?.name ?? '',
        templateId: event.formId,
        latestTemplateVersion: latestTemplateVersion,
        bindings: bindings,
        selectedBindingId: selectedBindingId,
        bindingDrafts: bindingDrafts,
        fieldBindings: _buildFieldBindings(
          _findDraft(bindingDrafts, selectedBindingId),
          latestTemplateVersion,
        ),
        pendingDeleteBindingId: '',
        pendingDeleteBindingName: '',
        message: '',
      ));
      return;
    }

    emit(state.copyWith(
      status: FormDataManagerStatus.failure,
      formId: event.formId,
      message: result.error ?? '讀取表單綁定資料管理設定失敗',
    ));
  }

  void _onSelectBindingEvent(
    SelectBindingEvent event,
    Emitter<FormDataManagerState> emit,
  ) {
    final draft = _findDraft(state.bindingDrafts, event.bindingId);
    emit(state.copyWith(
      status: FormDataManagerStatus.success,
      selectedBindingId: event.bindingId,
      fieldBindings: _buildFieldBindings(draft, state.latestTemplateVersion),
      message: '',
    ));
  }

  void _onRequestDeleteBindingEvent(
    RequestDeleteBindingEvent event,
    Emitter<FormDataManagerState> emit,
  ) {
    final binding = state.bindings.cast<BindingSummary?>().firstWhere(
          (item) => item?.id == event.bindingId,
          orElse: () => null,
        );
    if (binding == null) {
      emit(state.copyWith(
        status: FormDataManagerStatus.failure,
        message: '找不到要刪除的綁定資料',
      ));
      return;
    }

    emit(state.copyWith(
      status: FormDataManagerStatus.confirmDeleteBinding,
      pendingDeleteBindingId: binding.id,
      pendingDeleteBindingName: binding.name,
      message: '',
    ));
  }

  Future<void> _onDeleteBindingEvent(
    DeleteBindingEvent event,
    Emitter<FormDataManagerState> emit,
  ) async {
    emit(state.copyWith(
      status: FormDataManagerStatus.loading,
      message: '',
    ));

    final result = await formDataManagerService.deleteBinding(
      state.formId,
      event.bindingId,
    );
    if (!result.isSuccess) {
      emit(state.copyWith(
        status: FormDataManagerStatus.failure,
        message: result.error ?? '刪除綁定資料失敗',
      ));
      return;
    }

    final remainingDrafts = List<FormDataBindingDraft>.from(state.bindingDrafts)
      ..removeWhere((draft) => draft.bindingId == event.bindingId);
    final bindings = _buildBindings(remainingDrafts);
    final selectedBindingId = bindings.isEmpty
        ? ''
        : (state.selectedBindingId == event.bindingId
            ? bindings.first.id
            : state.selectedBindingId);
    final latestTemplateVersion = bindings.fold<int>(
      0,
      (current, item) =>
          item.templateVersion > current ? item.templateVersion : current,
    );

    emit(state.copyWith(
      status: FormDataManagerStatus.deleteSuccess,
      bindings: bindings,
      bindingDrafts: remainingDrafts,
      latestTemplateVersion: latestTemplateVersion,
      selectedBindingId: selectedBindingId,
      fieldBindings: _buildFieldBindings(
        _findDraft(remainingDrafts, selectedBindingId),
        latestTemplateVersion,
      ),
      pendingDeleteBindingId: '',
      pendingDeleteBindingName: '',
      message: '已刪除綁定資料',
    ));
  }

  void _onExportJsonEvent(
    ExportJsonEvent event,
    Emitter<FormDataManagerState> emit,
  ) {
    final selectedBinding = state.selectedBinding;
    final selectedDraft =
        _findDraft(state.bindingDrafts, state.selectedBindingId);
    if (selectedBinding == null) {
      emit(state.copyWith(
        status: FormDataManagerStatus.failure,
        message: '目前沒有可匯出的 Json 設定',
      ));
      return;
    }

    if (!selectedBinding.isEnabled) {
      emit(state.copyWith(
        status: FormDataManagerStatus.failure,
        message: '此綁定已停用，無法匯出 Json',
      ));
      return;
    }

    if (selectedDraft == null) {
      emit(state.copyWith(
        status: FormDataManagerStatus.failure,
        message: '找不到目前綁定對應的 Json 資料',
      ));
      return;
    }

    // 依 sourceItemId + triggerType 分組，群組內依 order 排序
    final actionGroups = <String, List<FormActionBindingDraft>>{};
    for (final a in selectedDraft.actions) {
      final key = '${a.sourceItemId}__${a.triggerType.name}';
      actionGroups.putIfAbsent(key, () => []).add(a);
    }
    final actionBindings = actionGroups.values.map((group) {
      group.sort((a, b) => a.order.compareTo(b.order));
      final first = group.first;
      return {
        'sourceItemId': first.sourceItemId,
        'sourceLabel': first.sourceLabel,
        'sourceType': first.sourceType,
        'triggerType': first.triggerType.name,
        'steps': group
            .map((action) => {
                  'sequence': action.order + 1,
                  'actionId': action.actionId,
                  'actionType': action.actionType.name,
                  'apiId': action.apiId,
                  'navigateRoute': action.navigateRoute,
                  'enabled': action.enabled,
                  'description': action.description,
                })
            .toList(),
      };
    }).toList();

    final preview = const JsonEncoder.withIndent('  ').convert({
      'bindingId': selectedDraft.bindingId,
      'bindingName': selectedDraft.bindingName,
      'bindingDescription': selectedDraft.bindingDescription,
      'templateVersion': selectedDraft.templateVersion,
      'formId': selectedDraft.formId,
      'formName': selectedDraft.formName,
      'formSize': selectedDraft.formSize,
      'updatedAt': selectedDraft.updatedAt,
      'sections': selectedDraft.sections.map((section) {
        return {
          'sectionId': section.sectionId,
          'sectionName': section.sectionName,
          'description': section.description,
          'fields': section.fields.map((field) {
            return {
              'itemId': field.itemId,
              'label': field.label,
              'fieldName': field.fieldName,
              'fieldKind': field.fieldKind.name,
              'type': field.valueType.name,
              'required': field.required,
              'outputKey': field.outputKey,
              'nullStrategy': field.nullStrategy.name,
              'defaultValue': field.nullStrategy == BindingNullStrategy.skip
                  ? field.systemDefaultValue
                  : field.customDefaultValue,
            };
          }).toList(),
        };
      }).toList(),
      'actionBindings': actionBindings,
    });

    emit(state.copyWith(
      status: FormDataManagerStatus.exportJsonPreview,
      exportedJson: preview,
    ));
  }

  void _onPreviewApiExportEvent(
    PreviewApiExportEvent event,
    Emitter<FormDataManagerState> emit,
  ) {
    final selectedBinding = state.selectedBinding;
    final selectedDraft =
        _findDraft(state.bindingDrafts, state.selectedBindingId);
    if (selectedBinding == null) {
      emit(state.copyWith(
        status: FormDataManagerStatus.failure,
        message: '目前沒有可預覽的 API 匯出設定',
      ));
      return;
    }

    if (!selectedBinding.isEnabled) {
      emit(state.copyWith(
        status: FormDataManagerStatus.failure,
        message: '此綁定已停用，無法預覽 API 匯出',
      ));
      return;
    }

    if (selectedDraft == null) {
      emit(state.copyWith(
        status: FormDataManagerStatus.failure,
        message: '找不到目前綁定對應的匯出資料',
      ));
      return;
    }

    final preview = _buildApiExportPreview(selectedDraft);

    emit(state.copyWith(
      status: FormDataManagerStatus.exportApiPreview,
      exportedJson: preview,
    ));
  }

  void _onCompleteExportJsonPreviewEvent(
    CompleteExportJsonPreviewEvent event,
    Emitter<FormDataManagerState> emit,
  ) {
    emit(state.copyWith(
      status: FormDataManagerStatus.success,
      message: '',
    ));
  }

  void _onCompleteDeleteDialogEvent(
    CompleteDeleteDialogEvent event,
    Emitter<FormDataManagerState> emit,
  ) {
    emit(state.copyWith(
      status: FormDataManagerStatus.success,
      pendingDeleteBindingId: '',
      pendingDeleteBindingName: '',
      message: '',
    ));
  }

  void _onCompleteNavigationEvent(
    CompleteNavigationEvent event,
    Emitter<FormDataManagerState> emit,
  ) {
    emit(state.copyWith(
      status: FormDataManagerStatus.success,
      navigateFormId: '',
      navigateBindingId: '',
      message: '',
    ));
  }

  void _onNavigateToDataBindingEvent(
    NavigateToDataBindingEvent event,
    Emitter<FormDataManagerState> emit,
  ) {
    final targetBindingId = event.bindingId.isEmpty
        ? _buildBindingId(event.formId)
        : event.bindingId;

    emit(state.copyWith(
      status: FormDataManagerStatus.navigateToDataBinding,
      navigateFormId: event.formId,
      navigateBindingId: targetBindingId,
      message: '',
    ));
  }

  String _buildApiExportPreview(FormDataBindingDraft draft) {
    final payload = <String, dynamic>{};

    for (final section in draft.sections) {
      for (final field in section.fields) {
        if (field.fieldKind == BindingFieldKind.button) {
          continue;
        }

        final outputKey = field.outputKey.trim();
        if (outputKey.isEmpty) {
          continue;
        }

        payload[outputKey] = _resolveExportValue(field);
      }
    }

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  dynamic _resolveExportValue(FormDataBindingFieldDraft field) {
    final rawValue = field.nullStrategy == BindingNullStrategy.custom
        ? field.customDefaultValue
        : field.systemDefaultValue;

    switch (field.valueType) {
      case BindingFieldValueType.number:
        return num.tryParse(rawValue) ?? 0;
      case BindingFieldValueType.date:
      case BindingFieldValueType.file:
      case BindingFieldValueType.string:
        return rawValue;
    }
  }

  List<BindingSummary> _buildBindings(List<FormDataBindingDraft> drafts) {
    if (drafts.isEmpty) {
      return const [];
    }

    final latestTemplateVersion = drafts.fold<int>(
      0,
      (current, draft) =>
          draft.templateVersion > current ? draft.templateVersion : current,
    );

    return drafts.map((draft) {
      final unmappedCount = draft.sections.fold<int>(
        0,
        (total, section) =>
            total +
            section.fields
                .where((field) => field.outputKey.trim().isEmpty)
                .length,
      );
      final warningCount =
          draft.templateVersion < latestTemplateVersion ? 1 : 0;

      return BindingSummary(
        id: draft.bindingId,
        name: draft.bindingName,
        description: draft.bindingDescription.isEmpty
            ? (draft.updatedAt.isEmpty
                ? '已載入 local storage 暫存資料'
                : '最後更新 ${draft.updatedAt}')
            : draft.bindingDescription,
        isEnabled: draft.isEnabled,
        templateVersion: draft.templateVersion,
        healthStatus: draft.templateVersion < latestTemplateVersion
            ? BindingHealthStatus.outdated
            : unmappedCount > 0
                ? BindingHealthStatus.warning
                : BindingHealthStatus.healthy,
        unmappedCount: unmappedCount,
        warningCount: warningCount,
      );
    }).toList();
  }

  List<FieldBindingItem> _buildFieldBindings(
    FormDataBindingDraft? draft,
    int latestTemplateVersion,
  ) {
    if (draft == null) {
      return const [];
    }

    return draft.sections
        .expand(
          (section) => section.fields.map(
            (field) => FieldBindingItem(
              sectionName: section.sectionName,
              label: field.label,
              itemId: field.itemId,
              fieldType: field.displayTypeLabel,
              required: field.required,
              outputKey: field.outputKey,
              nullStrategy: field.nullStrategyLabel,
              enabled: field.outputKey.trim().isNotEmpty,
              sourceHint: field.fieldName.isEmpty
                  ? section.description
                  : field.fieldName,
              issueStatus: draft.templateVersion < latestTemplateVersion
                  ? FieldBindingIssueStatus.versionMismatch
                  : field.outputKey.trim().isEmpty
                      ? FieldBindingIssueStatus.unmapped
                      : FieldBindingIssueStatus.mapped,
            ),
          ),
        )
        .toList();
  }

  FormDataBindingDraft? _findDraft(
    List<FormDataBindingDraft> drafts,
    String bindingId,
  ) {
    if (bindingId.isEmpty) {
      return null;
    }

    return drafts.cast<FormDataBindingDraft?>().firstWhere(
          (draft) => draft?.bindingId == bindingId,
          orElse: () => null,
        );
  }

  String _buildBindingId(String formId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return '${formId}_$now';
  }
}
