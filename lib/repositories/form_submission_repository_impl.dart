import 'dart:convert';

import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/model/form_submission_model.dart';
import 'package:flutter_application_ai/repositories/interface/form_submission_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class FormSubmissionRepositoryImpl implements FormSubmissionRepository {
  static const String _storageKey = 'form_submissions_key';

  final LocalStorage _localStorage;

  FormSubmissionRepositoryImpl(this._localStorage);

  @override
  Future<Result<List<FormSubmissionModel>>> loadAll() async {
    try {
      final raw = _localStorage.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        return Result.success([]);
      }

      final list = (jsonDecode(raw) as List)
          .map((item) =>
              FormSubmissionModel.fromMap(item as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<List<FormSubmissionModel>>> loadByApplicantId(
      String applicantId) async {
    final result = await loadAll();
    if (!result.isSuccess) return Result.failure(result.error ?? '讀取失敗');

    final filtered =
        result.data!.where((item) => item.applicantId == applicantId).toList();
    return Result.success(filtered);
  }

  @override
  Future<Result<FormSubmissionModel?>> loadById(String submissionId) async {
    final result = await loadAll();
    if (!result.isSuccess) return Result.failure(result.error ?? '讀取失敗');

    final found = result.data!.cast<FormSubmissionModel?>().firstWhere(
          (item) => item?.submissionId == submissionId,
          orElse: () => null,
        );
    return Result.success(found);
  }

  @override
  Future<Result<bool>> save(FormSubmissionModel submission) async {
    try {
      final currentResult = await loadAll();
      final currentList = currentResult.isSuccess
          ? List<FormSubmissionModel>.from(currentResult.data ?? const [])
          : <FormSubmissionModel>[];

      final index = currentList.indexWhere(
        (item) => item.submissionId == submission.submissionId,
      );

      if (index == -1) {
        currentList.add(submission);
      } else {
        currentList[index] = submission;
      }

      return saveAll(currentList);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<bool>> saveAll(List<FormSubmissionModel> submissions) async {
    try {
      final payload = submissions.map((item) => item.toMap()).toList();
      await _localStorage.setString(_storageKey, jsonEncode(payload));
      return Result.success(true);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }
}
