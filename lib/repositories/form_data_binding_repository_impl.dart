import 'dart:convert';

import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/repositories/interface/form_data_binding_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class FormDataBindingRepositoryImpl implements FormDataBindingRepository {
  final LocalStorage _localStorage;

  FormDataBindingRepositoryImpl(this._localStorage);

  static const String _draftsKey = 'form_data_binding_drafts_key';

  @override
  Future<Result<FormDataBindingDraft?>> loadDraftByBindingId(
    String formId,
    String bindingId,
  ) async {
    try {
      final drafts = await _loadAllDrafts();
      final found = drafts.cast<FormDataBindingDraft?>().firstWhere(
            (draft) => draft?.formId == formId && draft?.bindingId == bindingId,
            orElse: () => null,
          );
      return Result.success(found);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<List<FormDataBindingDraft>>> loadDraftsByFormId(
    String formId,
  ) async {
    try {
      final drafts = await _loadAllDrafts();
      return Result.success(
        drafts.where((draft) => draft.formId == formId).toList(),
      );
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<bool>> saveDraft(FormDataBindingDraft draft) async {
    try {
      final drafts = await _loadAllDrafts();
      final current = List<FormDataBindingDraft>.from(drafts);
      final normalizedDraft = _normalizeDraft(draft);
      final index = current.indexWhere(
        (item) => item.bindingId == normalizedDraft.bindingId,
      );
      if (index == -1) {
        current.add(normalizedDraft);
      } else {
        current[index] = normalizedDraft;
      }

      await _localStorage.setString(
        _draftsKey,
        jsonEncode(current.map((item) => item.toMap()).toList()),
      );

      return Result.success(true);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  Future<List<FormDataBindingDraft>> _loadAllDrafts() async {
    final raw = _localStorage.getString(_draftsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final jsonList = jsonDecode(raw) as List<dynamic>;
    return jsonList
        .map((item) => _normalizeDraft(
              FormDataBindingDraft.fromMap(item as Map<String, dynamic>),
            ))
        .toList();
  }

  FormDataBindingDraft _normalizeDraft(FormDataBindingDraft draft) {
    final resolvedBindingId =
        draft.bindingId.isEmpty ? '${draft.formId}__default' : draft.bindingId;
    final resolvedBindingName = draft.bindingName.isEmpty
        ? (draft.formName.isEmpty ? '未命名綁定' : '${draft.formName} 綁定')
        : draft.bindingName;
    final resolvedBindingDescription = draft.bindingDescription.isEmpty
        ? '表單資料綁定設定'
        : draft.bindingDescription;

    return draft.copyWith(
      bindingId: resolvedBindingId,
      bindingName: resolvedBindingName,
      bindingDescription: resolvedBindingDescription,
      templateVersion: draft.templateVersion <= 0 ? 1 : draft.templateVersion,
    );
  }
}
