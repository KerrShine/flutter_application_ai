import 'dart:convert';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/model/form_section_design_draft_model.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/repositories/interface/form_section_design_repository.dart';
import 'package:flutter_application_ai/repositories/interface/section_repository.dart';
import 'package:flutter_application_ai/unit/result.dart';

class FormSectionDesignService {
  final FormSectionDesignRepository formSectionDesignRepository;
  final SectionRepository sectionRepository;

  FormSectionDesignService(
    this.formSectionDesignRepository,
    this.sectionRepository,
  );

  Future<Result<SectionModel?>> loadSection(String sectionId) async {
    try {
      return await sectionRepository.loadSectionById(sectionId);
    } catch (ex) {
      return Result.failure('讀取 Section 失敗：${ex.toString()}');
    }
  }

  Future<Result<FormSectionDesignDraftModel?>> loadDraft(
      String sectionId) async {
    try {
      final rawDraft = formSectionDesignRepository.loadDraft();
      if (rawDraft == null || rawDraft.isEmpty) {
        return Result.success(null);
      }

      final draftMap = jsonDecode(rawDraft) as Map<String, dynamic>;
      final draft = FormSectionDesignDraftModel.fromMap(draftMap);

      if (sectionId.isNotEmpty && draft.sectionId != sectionId) {
        return Result.success(null);
      }

      return Result.success(draft);
    } catch (ex) {
      return Result.failure('讀取草稿失敗：${ex.toString()}');
    }
  }

  Future<Result<void>> saveDraft(
    String sectionId,
    String formName,
    List<DesignerItem> items,
    int rowCount,
  ) async {
    try {
      final payload = jsonEncode({
        'sectionId': sectionId,
        'formName': formName,
        'rowCount': rowCount,
        'items': items.map((e) => e.toMap()).toList(),
      });

      await formSectionDesignRepository.saveDraft(payload);

      final sectionsResult = await sectionRepository.loadSections();
      if (!sectionsResult.isSuccess) {
        return Result.failure(sectionsResult.error ?? '讀取 Section 失敗');
      }

      final section = SectionModel(
        id: sectionId.isNotEmpty
            ? sectionId
            : 'section_${DateTime.now().microsecondsSinceEpoch}',
        name: formName,
        items: items,
      );

      final saveSectionResult = await sectionRepository.saveSection(section);
      if (!saveSectionResult.isSuccess) {
        return Result.failure(saveSectionResult.error ?? '暫存 Section 失敗');
      }

      return Result.success(null);
    } catch (ex) {
      return Result.failure('暫存失敗：${ex.toString()}');
    }
  }
}
