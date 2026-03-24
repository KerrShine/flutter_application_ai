import 'dart:convert';

import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/data/tempData/temp_data_storage.dart';
import 'package:flutter_application_ai/model/org_design_config_model.dart';
import 'package:flutter_application_ai/repositories/interface/org_design_repository.dart';
import 'package:flutter_application_ai/unit/result.dart';

class OrgDesignRepositoryImpl implements OrgDesignRepository {
  static const String _orgDesignConfigKey = 'org_design_config_key';
  static const String _treeDesignFileName = 'tree_design.json';

  final LocalStorage _localStorage;
  final TempDataStorage _tempDataStorage;

  OrgDesignRepositoryImpl(this._localStorage, this._tempDataStorage);

  @override
  Future<Result<OrgDesignConfigModel>> loadConfig() async {
    try {
      final raw = _localStorage.getString(_orgDesignConfigKey);
      if (raw == null || raw.isEmpty) {
        return Result.success(_defaultConfig());
      }

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return Result.success(OrgDesignConfigModel.fromMap(decoded));
    } catch (error) {
      return Result.failure(error.toString());
    }
  }

  @override
  Future<Result<bool>> saveConfig(OrgDesignConfigModel config) async {
    try {
      await _localStorage.setString(
        _orgDesignConfigKey,
        jsonEncode(config.toMap()),
      );
      return Result.success(true);
    } catch (error) {
      return Result.failure(error.toString());
    }
  }

  @override
  Future<Result<bool>> deleteConfig() async {
    try {
      await _localStorage.remove(_orgDesignConfigKey);
      return Result.success(true);
    } catch (error) {
      return Result.failure(error.toString());
    }
  }

  @override
  Future<Result<OrgDesignConfigModel?>> loadTreeDesignFile() async {
    try {
      final raw = await _tempDataStorage.readJson(_treeDesignFileName);
      if (raw == null || raw.isEmpty) {
        return Result.success(null);
      }

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return Result.success(OrgDesignConfigModel.fromMap(decoded));
    } catch (error) {
      return Result.failure(error.toString());
    }
  }

  @override
  Future<Result<bool>> saveTreeDesignFile(OrgDesignConfigModel config) async {
    try {
      await _tempDataStorage.writeJson(
        fileName: _treeDesignFileName,
        content: const JsonEncoder.withIndent('  ').convert(config.toMap()),
      );
      return Result.success(true);
    } catch (error) {
      return Result.failure(error.toString());
    }
  }

  @override
  Future<Result<bool>> deleteTreeDesignFile() async {
    try {
      await _tempDataStorage.deleteJson(_treeDesignFileName);
      return Result.success(true);
    } catch (error) {
      return Result.failure(error.toString());
    }
  }

  OrgDesignConfigModel _defaultConfig() {
    return OrgDesignConfigModel(
      orgId: 'default_org',
      orgName: '簽核系統組織',
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
}
