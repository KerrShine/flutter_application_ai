part of 'form_design_bloc.dart';

class FormDesignEvent extends Equatable {
  const FormDesignEvent();
  @override
  List<Object> get props => [];
}

/// 初始化：載入指定 formId 的 Form 與所有可用 Sections
class InitFormDesignEvent extends FormDesignEvent {
  final String formId;
  const InitFormDesignEvent(this.formId);
  @override
  List<Object> get props => [formId];
}

/// 將 Section 加入表單畫布（右側）
class AddSectionToFormEvent extends FormDesignEvent {
  final SectionModel section;
  const AddSectionToFormEvent(this.section);
  @override
  List<Object> get props => [section];
}

/// 從表單畫布移除 Section
class RemoveSectionFromFormEvent extends FormDesignEvent {
  final String sectionId;
  const RemoveSectionFromFormEvent(this.sectionId);
  @override
  List<Object> get props => [sectionId];
}

/// 重排畫布上的 Section 順序
class ReorderSectionEvent extends FormDesignEvent {
  final int oldIndex;
  final int newIndex;
  const ReorderSectionEvent(this.oldIndex, this.newIndex);
  @override
  List<Object> get props => [oldIndex, newIndex];
}

/// 儲存目前的 sectionIds 排序到 FormModel
class SaveFormDesignEvent extends FormDesignEvent {
  const SaveFormDesignEvent();
}

/// 導航至新建 Section（Phase 3）
class NavigateToCreateSectionEvent extends FormDesignEvent {
  const NavigateToCreateSectionEvent();
}

class NavigateToEditSectionEvent extends FormDesignEvent {
  final String sectionId;

  const NavigateToEditSectionEvent(this.sectionId);

  @override
  List<Object> get props => [sectionId];
}

class SaveFormDraftEvent extends FormDesignEvent {
  const SaveFormDraftEvent();
}

class PreviewFormJsonEvent extends FormDesignEvent {
  const PreviewFormJsonEvent();
}

class NavigateToBrowseEvent extends FormDesignEvent {
  const NavigateToBrowseEvent();
}

class NavigateToBrowseSectionEvent extends FormDesignEvent {
  final SectionModel section;

  const NavigateToBrowseSectionEvent(this.section);

  @override
  List<Object> get props => [section];
}

/// 請求刪除可用 Section（觸發確認 Dialog）
class RequestDeleteAvailableSectionEvent extends FormDesignEvent {
  final String sectionId;
  const RequestDeleteAvailableSectionEvent(this.sectionId);
  @override
  List<Object> get props => [sectionId];
}

/// 確認刪除可用 Section
class ConfirmDeleteAvailableSectionEvent extends FormDesignEvent {
  final String sectionId;
  const ConfirmDeleteAvailableSectionEvent(this.sectionId);

  @override
  List<Object> get props => [sectionId];
}

/// 取消刪除可用 Section（Dialog 按取消時使用）
class CancelConfirmDeleteSectionEvent extends FormDesignEvent {
  const CancelConfirmDeleteSectionEvent();
}
