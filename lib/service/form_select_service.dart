import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/repositories/interface/form_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class FormSelectService {
  final FormRepository formRepository;

  FormSelectService(this.formRepository);

  Future<Result<List<FormModel>>> loadForms() async {
    try {
      return await formRepository.loadDraftForms();
    } catch (ex) {
      return Result.failure('讀取表單清單失敗：${ex.toString()}');
    }
  }
}
