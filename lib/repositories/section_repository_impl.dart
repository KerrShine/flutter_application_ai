import 'dart:convert';
import 'package:flutter_application_ai/repositories/interface/section_repository.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/unit/result.dart';

class SectionRepositoryImpl implements SectionRepository {
  final LocalStorage _localStorage;
  static const String _sectionsKey = 'sections_key';

  SectionRepositoryImpl(this._localStorage);

  @override
  Future<Result<bool>> saveSection(SectionModel section) async {
    try {
      final loadResult = await loadSections();
      final current = loadResult.isSuccess ? List<SectionModel>.from(loadResult.data!) : <SectionModel>[];
      final idx = current.indexWhere((s) => s.id == section.id);
      if (idx != -1) {
        current[idx] = section;
      } else {
        current.add(section);
      }
      await _localStorage.setString(_sectionsKey, jsonEncode(current.map((s) => s.toMap()).toList()));
      return Result.success(true);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<SectionModel>>> loadSections() async {
    try {
      final raw = _localStorage.getString(_sectionsKey);
      if (raw == null || raw.isEmpty) return Result.success([]);
      final list = (jsonDecode(raw) as List).map((e) => SectionModel.fromMap(e as Map<String, dynamic>)).toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<SectionModel?>> loadSectionById(String sectionId) async {
    final result = await loadSections();
    if (!result.isSuccess) return Result.success(null);
    final found = result.data!.cast<SectionModel?>().firstWhere(
      (s) => s?.id == sectionId,
      orElse: () => null,
    );
    return Result.success(found);
  }

  @override
  Future<Result<bool>> deleteSection(String sectionId) async {
    try {
      final loadResult = await loadSections();
      if (!loadResult.isSuccess) return Result.failure(loadResult.error ?? '讀取失敗');
      final current = List<SectionModel>.from(loadResult.data!);
      current.removeWhere((s) => s.id == sectionId);
      await _localStorage.setString(_sectionsKey, jsonEncode(current.map((s) => s.toMap()).toList()));
      return Result.success(true);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
