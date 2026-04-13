import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/repositories/interface/form_data_binding_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_repository.dart';
import 'package:flutter_application_ai/service/form_data_binding_service.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class FormDataManagerService {
  final FormRepository formRepository;
  final FormDataBindingRepository formDataBindingRepository;
  final FormDataBindingService formDataBindingService;

  FormDataManagerService(
    this.formRepository,
    this.formDataBindingRepository,
    this.formDataBindingService,
  );

  Future<Result<FormDataManagerInitialData>> initialize(String formId) async {
    try {
      if (formId.isEmpty) {
        return Result.failure('找不到要管理綁定資料的表單');
      }

      final formResult = await formRepository.loadFormById(formId);
      if (!formResult.isSuccess) {
        return Result.failure(formResult.error ?? '讀取表單失敗');
      }

      final form = formResult.data;
      if (form == null) {
        return Result.failure('找不到要管理綁定資料的表單');
      }

      final bindingDraftResult =
          await formDataBindingRepository.loadDraftsByFormId(formId);
      if (!bindingDraftResult.isSuccess) {
        return Result.failure(bindingDraftResult.error ?? '讀取資料綁定暫存失敗');
      }

      final savedDrafts =
          bindingDraftResult.data ?? const <FormDataBindingDraft>[];
      final normalizedDrafts = <FormDataBindingDraft>[];
      for (final savedDraft in savedDrafts) {
        final normalizedResult = await formDataBindingService.initialize(
          formId,
          bindingId: savedDraft.bindingId,
        );
        if (!normalizedResult.isSuccess) {
          return Result.failure(
            normalizedResult.error ?? '讀取資料綁定暫存失敗',
          );
        }

        final normalizedDraft = normalizedResult.data;
        if (normalizedDraft != null) {
          normalizedDrafts.add(normalizedDraft);
        }
      }

      return Result.success(
        FormDataManagerInitialData(
          form: form,
          bindingDrafts: normalizedDrafts,
        ),
      );
    } catch (ex) {
      return Result.failure('讀取表單綁定資料管理設定失敗：${ex.toString()}');
    }
  }

  Future<Result<bool>> deleteBinding(String formId, String bindingId) async {
    try {
      if (formId.isEmpty || bindingId.isEmpty) {
        return Result.failure('找不到要刪除的綁定資料');
      }

      final result = await formDataBindingRepository.deleteDraftByBindingId(
        formId,
        bindingId,
      );
      if (!result.isSuccess) {
        return Result.failure(result.error ?? '刪除綁定資料失敗');
      }

      return Result.success(true);
    } catch (ex) {
      return Result.failure('刪除綁定資料失敗：${ex.toString()}');
    }
  }
}

class FormDataManagerInitialData {
  final FormModel form;
  final List<FormDataBindingDraft> bindingDrafts;

  const FormDataManagerInitialData({
    required this.form,
    required this.bindingDrafts,
  });
}
