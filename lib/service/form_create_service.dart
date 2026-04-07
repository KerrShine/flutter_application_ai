import 'package:flutter_application_ai/repositories/interface/form_repository.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class FormCreateService {
  final FormRepository _formRepository;

  FormCreateService(this._formRepository);

  Future<Result<FormModel>> createDraftForm(String name, String size) async {
    try {
      final newForm = FormModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        size: size,
      );

      final result = await _formRepository.saveDraftForm(newForm);
      if (result.isSuccess) {
        return Result.success(newForm);
      } else {
        return Result.failure(result.error ?? '建立表單失敗');
      }
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }
}
