import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_application_ai/model/api_definition.dart';
import 'package:flutter_application_ai/repositories/interface/api_catalog_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class ApiCatalogRepositoryImpl implements ApiCatalogRepository {
  static const String _assetPath =
      'assets/form_button_action_api_sample.json';
  static const String _dropdownAssetPath =
      'lib/data/tempData/dropdown_options_sample.json';

  @override
  Future<Result<List<ApiDefinition>>> loadApiList() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final rawList = map['apiList'] as List<dynamic>? ?? [];
      final list = rawList
          .map((e) => ApiDefinition.fromMap(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (ex) {
      return Result.failure('載入 API 清單失敗: ${ex.toString()}');
    }
  }

  @override
  Future<Result<List<ApiDefinition>>> loadDropdownApiList() async {
    try {
      final raw = await rootBundle.loadString(_dropdownAssetPath);
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final sources = map['sources'] as List<dynamic>? ?? [];
      final list = sources.map((e) {
        final src = e as Map<String, dynamic>;
        return ApiDefinition(
          apiId: src['apiId'] as String? ?? '',
          apiName: src['apiName'] as String? ?? '',
        );
      }).toList();
      return Result.success(list);
    } catch (ex, st) {
      // ignore: avoid_print
      print('[ApiCatalogRepositoryImpl] loadDropdownApiList failed: $ex\n$st');
      return Result.failure('載入下拉 API 清單失敗: ${ex.toString()}');
    }
  }
}
