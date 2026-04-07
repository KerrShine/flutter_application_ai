import 'dart:convert';
import 'package:flutter_application_ai/repositories/interface/form_repository.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class FormRepositoryImpl implements FormRepository {
  final LocalStorage localStorage;

  FormRepositoryImpl(this.localStorage);

  static const String _draftFormsKey = 'draft_forms_key';

  @override
  Future<Result<bool>> saveDraftForm(FormModel model) async {
    try {
      final formsResult = await loadDraftForms();
      List<FormModel> currentForms = [];
      if (formsResult.isSuccess) {
        currentForms = formsResult.data ?? [];
      }

      // Update or completely new
      final index =
          currentForms.indexWhere((element) => element.id == model.id);
      if (index != -1) {
        currentForms[index] = model;
      } else {
        currentForms.add(model);
      }

      final jsonList = currentForms.map((e) => e.toMap()).toList();
      await localStorage.setString(_draftFormsKey, jsonEncode(jsonList));
      return Result.success(true);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<FormModel>>> loadDraftForms() async {
    try {
      final jsonString = localStorage.getString(_draftFormsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return Result.success([]);
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final list = jsonList
          .map((e) => FormModel.fromMap(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<bool>> saveAllDraftForms(List<FormModel> forms) async {
    try {
      final jsonList = forms.map((e) => e.toMap()).toList();
      await localStorage.setString(_draftFormsKey, jsonEncode(jsonList));
      return Result.success(true);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<bool>> deleteDraftForm(String formId) async {
    try {
      final formsResult = await loadDraftForms();
      if (!formsResult.isSuccess) {
        return Result.failure(formsResult.error ?? '讀取失敗');
      }
      final currentForms = List<FormModel>.from(formsResult.data ?? []);
      currentForms.removeWhere((f) => f.id == formId);
      return await saveAllDraftForms(currentForms);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<FormModel?>> loadFormById(String formId) async {
    try {
      final formsResult = await loadDraftForms();
      if (!formsResult.isSuccess) return Result.success(null);
      final found = formsResult.data!.cast<FormModel?>().firstWhere(
            (f) => f?.id == formId,
            orElse: () => null,
          );
      return Result.success(found);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
