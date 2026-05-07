import 'dart:convert';

import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/model/sign_off_template_model.dart';
import 'package:flutter_application_ai/repositories/interface/sign_off_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class SignOffRepositoryImpl implements SignOffRepository {
  static const String _storageKey = 'sign_off_templates_key';

  final LocalStorage _localStorage;

  SignOffRepositoryImpl(this._localStorage);

  @override
  Future<Result<List<SignOffTemplateModel>>> loadAll() async {
    try {
      final raw = _localStorage.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        return Result.success([]);
      }

      final list = (jsonDecode(raw) as List)
          .map((item) =>
              SignOffTemplateModel.fromMap(item as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<List<SignOffTemplateModel>>> loadByFormId(String formId) async {
    final result = await loadAll();
    if (!result.isSuccess) return Result.failure(result.error ?? '讀取失敗');

    final filtered =
        result.data!.where((item) => item.formId == formId).toList();
    return Result.success(filtered);
  }

  @override
  Future<Result<SignOffTemplateModel?>> loadById(String templateId) async {
    final result = await loadAll();
    if (!result.isSuccess) return Result.failure(result.error ?? '讀取失敗');

    final found = result.data!.cast<SignOffTemplateModel?>().firstWhere(
          (item) => item?.templateId == templateId,
          orElse: () => null,
        );
    return Result.success(found);
  }

  @override
  Future<Result<bool>> save(SignOffTemplateModel template) async {
    try {
      final currentResult = await loadAll();
      final currentList = currentResult.isSuccess
          ? List<SignOffTemplateModel>.from(currentResult.data ?? const [])
          : <SignOffTemplateModel>[];

      final index = currentList.indexWhere(
        (item) => item.templateId == template.templateId,
      );

      if (index == -1) {
        currentList.add(template);
      } else {
        currentList[index] = template;
      }

      return saveAll(currentList);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<bool>> saveAll(List<SignOffTemplateModel> templates) async {
    try {
      final payload = templates.map((item) => item.toMap()).toList();
      await _localStorage.setString(_storageKey, jsonEncode(payload));
      return Result.success(true);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<bool>> delete(String templateId) async {
    try {
      final currentResult = await loadAll();
      final currentList = currentResult.isSuccess
          ? List<SignOffTemplateModel>.from(currentResult.data ?? const [])
          : <SignOffTemplateModel>[];

      currentList.removeWhere((item) => item.templateId == templateId);
      return saveAll(currentList);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }
}
