import 'dart:convert';

import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/model/condition_field_draft.dart';
import 'package:flutter_application_ai/repositories/interface/condition_field_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class ConditionFieldRepositoryImpl implements ConditionFieldRepository {
  final LocalStorage _localStorage;

  ConditionFieldRepositoryImpl(this._localStorage);

  static const String _draftsKey = 'condition_field_drafts_key';

  @override
  Future<Result<ConditionFieldDraft?>> loadDraft(String formId) async {
    try {
      final drafts = await _loadAllDrafts();
      final found = drafts.cast<ConditionFieldDraft?>().firstWhere(
            (draft) => draft?.formId == formId,
            orElse: () => null,
          );
      return Result.success(found);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<List<ConditionFieldDraft>>> loadAllDrafts() async {
    try {
      return Result.success(await _loadAllDrafts());
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<bool>> saveDraft(ConditionFieldDraft draft) async {
    try {
      final drafts = await _loadAllDrafts();
      final current = List<ConditionFieldDraft>.from(drafts);
      final index = current.indexWhere((item) => item.formId == draft.formId);
      if (index == -1) {
        current.add(draft);
      } else {
        current[index] = draft;
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

  @override
  Future<Result<bool>> deleteDraft(String formId) async {
    try {
      final drafts = await _loadAllDrafts();
      final current = List<ConditionFieldDraft>.from(drafts);
      final lengthBefore = current.length;
      current.removeWhere((item) => item.formId == formId);
      if (current.length == lengthBefore) {
        return Result.failure('找不到要刪除的條件欄位 draft');
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

  Future<List<ConditionFieldDraft>> _loadAllDrafts() async {
    final raw = _localStorage.getString(_draftsKey);
    if (raw == null || raw.isEmpty) return const [];
    final jsonList = jsonDecode(raw) as List<dynamic>;
    return jsonList
        .map((item) =>
            ConditionFieldDraft.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
