import 'package:flutter_application_ai/repositories/interface/section_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_repository.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/unit/result.dart';

class FormDesignService {
  final SectionRepository _sectionRepository;
  final FormRepository _formRepository;

  FormDesignService(this._sectionRepository, this._formRepository);

  /// 讀取所有已儲存的 Section 列表
  Future<Result<List<SectionModel>>> loadSections() async {
    try {
      return await _sectionRepository.loadSections();
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  /// 讀取單一 Form（含 sectionIds）
  Future<Result<FormModel?>> loadForm(String formId) async {
    try {
      return await _formRepository.loadFormById(formId);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  /// 更新 Form 的 sectionIds 排序並儲存
  Future<Result<bool>> updateFormSections(
    String formId,
    List<String> orderedSectionIds,
  ) async {
    try {
      final formResult = await _formRepository.loadFormById(formId);
      if (!formResult.isSuccess || formResult.data == null) {
        return Result.failure('找不到表單');
      }
      final updated = formResult.data!.copyWith(sectionIds: orderedSectionIds);
      return await _formRepository.saveDraftForm(updated);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  /// 刪除指定 Section（從可用清單永久移除）
  Future<Result<bool>> deleteSection(String sectionId) async {
    try {
      return await _sectionRepository.deleteSection(sectionId);
    } catch (ex) {
      return Result.failure('刪除 Section 失敗：${ex.toString()}');
    }
  }
}
