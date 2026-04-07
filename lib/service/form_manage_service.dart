import 'package:flutter_application_ai/repositories/interface/form_repository.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class FormManageService {
  final FormRepository _formRepository;

  FormManageService(this._formRepository);

  /// 讀取所有草稿表單列表
  Future<Result<List<FormModel>>> loadForms() async {
    try {
      return await _formRepository.loadDraftForms();
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  /// 刪除特定表單（依 id）
  Future<Result<bool>> deleteForm(String formId) async {
    try {
      return await _formRepository.deleteDraftForm(formId);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }
}
