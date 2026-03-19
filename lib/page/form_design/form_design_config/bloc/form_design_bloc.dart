import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/service/form_design_service.dart';
import 'package:flutter_application_ai/model/section_model.dart';

part 'form_design_event.dart';
part 'form_design_state.dart';

class FormDesignBloc extends Bloc<FormDesignEvent, FormDesignState> {
  final FormDesignService _formDesignService;

  FormDesignBloc(this._formDesignService) : super(const FormDesignState()) {
    on<InitFormDesignEvent>(_onInit);
    on<AddSectionToFormEvent>(_onAddSection);
    on<RemoveSectionFromFormEvent>(_onRemoveSection);
    on<ReorderSectionEvent>(_onReorderSection);
    on<SaveFormDesignEvent>(_onSave);
    on<SaveFormDraftEvent>(_onSaveDraft);
    on<PreviewFormJsonEvent>(_onPreviewFormJson);
    on<NavigateToBrowseEvent>(_onNavigateToBrowse);
    on<NavigateToBrowseSectionEvent>(_onNavigateToBrowseSection);
    on<NavigateToCreateSectionEvent>(_onNavigateToCreateSection);
    on<NavigateToEditSectionEvent>(_onNavigateToEditSection);
    on<RequestDeleteAvailableSectionEvent>(_onRequestDeleteAvailableSection);
    on<ConfirmDeleteAvailableSectionEvent>(_onConfirmDeleteAvailableSection);
    on<CancelConfirmDeleteSectionEvent>(_onCancelConfirmDeleteSection);
  }

  Future<void> _onInit(
    InitFormDesignEvent event,
    Emitter<FormDesignState> emit,
  ) async {
    emit(state.copyWith(status: FormDesignStatus.loading));

    final formResult = await _formDesignService.loadForm(event.formId);
    final sectionsResult = await _formDesignService.loadSections();

    if (!formResult.isSuccess || formResult.data == null) {
      emit(state.copyWith(status: FormDesignStatus.failure, message: '找不到表單'));
      return;
    }

    final form = formResult.data!;
    final allSections =
        sectionsResult.isSuccess ? sectionsResult.data! : <SectionModel>[];

    // 依 sectionIds 順序建出已選 sections
    final selectedSections = form.sectionIds
        .map((id) => allSections.cast<SectionModel?>().firstWhere(
              (s) => s?.id == id,
              orElse: () => null,
            ))
        .whereType<SectionModel>()
        .toList();

    emit(state.copyWith(
      status: FormDesignStatus.success,
      formId: form.id,
      formName: form.name,
      availableSections: allSections,
      selectedSections: selectedSections,
    ));
  }

  void _onAddSection(
    AddSectionToFormEvent event,
    Emitter<FormDesignState> emit,
  ) {
    final already = state.selectedSections.any((s) => s.id == event.section.id);
    if (already) return;
    final updated = List<SectionModel>.from(state.selectedSections)
      ..add(event.section);
    emit(state.copyWith(selectedSections: updated));
  }

  void _onRemoveSection(
    RemoveSectionFromFormEvent event,
    Emitter<FormDesignState> emit,
  ) {
    final updated =
        state.selectedSections.where((s) => s.id != event.sectionId).toList();
    emit(state.copyWith(selectedSections: updated));
  }

  void _onReorderSection(
    ReorderSectionEvent event,
    Emitter<FormDesignState> emit,
  ) {
    int newIdx = event.newIndex;
    int oldIdx = event.oldIndex;
    if (newIdx > oldIdx) newIdx -= 1;
    final updated = List<SectionModel>.from(state.selectedSections);
    final moved = updated.removeAt(oldIdx);
    updated.insert(newIdx, moved);
    emit(state.copyWith(selectedSections: updated));
  }

  Future<void> _onSave(
    SaveFormDesignEvent event,
    Emitter<FormDesignState> emit,
  ) async {
    emit(state.copyWith(status: FormDesignStatus.loading));
    final sectionIds = state.selectedSections.map((s) => s.id).toList();
    final result =
        await _formDesignService.updateFormSections(state.formId, sectionIds);
    if (result.isSuccess) {
      emit(state.copyWith(status: FormDesignStatus.saved));
      emit(state.copyWith(status: FormDesignStatus.success));
    } else {
      emit(state.copyWith(
          status: FormDesignStatus.failure, message: result.error ?? '儲存失敗'));
    }
  }

  Future<void> _onSaveDraft(
    SaveFormDraftEvent event,
    Emitter<FormDesignState> emit,
  ) async {
    emit(state.copyWith(status: FormDesignStatus.loading));
    final sectionIds = state.selectedSections.map((s) => s.id).toList();
    final result =
        await _formDesignService.updateFormSections(state.formId, sectionIds);
    if (result.isSuccess) {
      emit(state.copyWith(status: FormDesignStatus.draftSaved));
      emit(state.copyWith(status: FormDesignStatus.success));
    } else {
      emit(state.copyWith(
          status: FormDesignStatus.failure, message: result.error ?? '暫存失敗'));
    }
  }

  void _onPreviewFormJson(
    PreviewFormJsonEvent event,
    Emitter<FormDesignState> emit,
  ) {
    final payload = {
      'formId': state.formId,
      'formName': state.formName,
      'sectionIds': state.selectedSections.map((s) => s.id).toList(),
      'sections': state.selectedSections.map((s) => s.toMap()).toList(),
    };

    final prettyJson = const JsonEncoder.withIndent('  ').convert(payload);
    emit(state.copyWith(
      status: FormDesignStatus.showJsonPreview,
      jsonPreview: prettyJson,
    ));
    emit(state.copyWith(status: FormDesignStatus.success));
  }

  void _onNavigateToBrowse(
    NavigateToBrowseEvent event,
    Emitter<FormDesignState> emit,
  ) {
    emit(state.copyWith(
      status: FormDesignStatus.navigateToBrowse,
      browseSections: state.selectedSections,
    ));
    emit(state.copyWith(status: FormDesignStatus.success));
  }

  void _onNavigateToBrowseSection(
    NavigateToBrowseSectionEvent event,
    Emitter<FormDesignState> emit,
  ) {
    emit(state.copyWith(
      status: FormDesignStatus.navigateToBrowse,
      browseSections: [event.section],
    ));
    emit(state.copyWith(status: FormDesignStatus.success));
  }

  void _onNavigateToCreateSection(
    NavigateToCreateSectionEvent event,
    Emitter<FormDesignState> emit,
  ) {
    emit(state.copyWith(
      status: FormDesignStatus.navigateToSection,
      editingSectionId: '',
    ));
    emit(state.copyWith(status: FormDesignStatus.success));
  }

  void _onNavigateToEditSection(
    NavigateToEditSectionEvent event,
    Emitter<FormDesignState> emit,
  ) {
    emit(state.copyWith(
      status: FormDesignStatus.navigateToSection,
      editingSectionId: event.sectionId,
    ));
    emit(state.copyWith(status: FormDesignStatus.success));
  }

  /// 觸發確認 Dialog，不進行二次 emit，
  /// 等使用者回應後由 Confirm/Cancel 事件各自轉態。
  void _onRequestDeleteAvailableSection(
    RequestDeleteAvailableSectionEvent event,
    Emitter<FormDesignState> emit,
  ) {
    final inUse = state.selectedSections.any((s) => s.id == event.sectionId);
    emit(state.copyWith(
      status: FormDesignStatus.confirmDeleteSection,
      pendingDeleteSectionId: event.sectionId,
      isDeleteSectionInUse: inUse,
    ));
  }

  Future<void> _onConfirmDeleteAvailableSection(
    ConfirmDeleteAvailableSectionEvent event,
    Emitter<FormDesignState> emit,
  ) async {
    emit(state.copyWith(status: FormDesignStatus.loading));
    final result = await _formDesignService.deleteSection(event.sectionId);
    if (!result.isSuccess) {
      emit(state.copyWith(
        status: FormDesignStatus.failure,
        message: result.error ?? '刪除失敗',
      ));
      return;
    }
    final updatedAvailable =
        state.availableSections.where((s) => s.id != event.sectionId).toList();
    final updatedSelected =
        state.selectedSections.where((s) => s.id != event.sectionId).toList();
    emit(state.copyWith(
      status: FormDesignStatus.success,
      availableSections: updatedAvailable,
      selectedSections: updatedSelected,
      pendingDeleteSectionId: '',
      isDeleteSectionInUse: false,
    ));
  }

  void _onCancelConfirmDeleteSection(
    CancelConfirmDeleteSectionEvent event,
    Emitter<FormDesignState> emit,
  ) {
    emit(state.copyWith(
      status: FormDesignStatus.success,
      pendingDeleteSectionId: '',
      isDeleteSectionInUse: false,
    ));
  }
}
