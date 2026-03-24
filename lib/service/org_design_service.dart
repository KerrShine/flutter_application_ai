import 'dart:convert';

import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/model/org_design_config_model.dart';
import 'package:flutter_application_ai/model/org_tree_canvas_node.dart';
import 'package:flutter_application_ai/repositories/interface/org_design_repository.dart';
import 'package:flutter_application_ai/unit/result.dart';

class OrgDesignService {
  final OrgDesignRepository _orgDesignRepository;

  OrgDesignService(this._orgDesignRepository);

  Future<Result<bool>> initData() async {
    final loadResult = await _orgDesignRepository.loadConfig();
    if (!loadResult.isSuccess) {
      return Result.failure(loadResult.error ?? '初始化失敗');
    }

    final saveResult = await _orgDesignRepository.saveConfig(loadResult.data!);
    if (!saveResult.isSuccess) {
      return Result.failure(saveResult.error ?? '初始化失敗');
    }

    return Result.success(true);
  }

  Future<Result<OrgDesignConfigModel>> loadConfig() async {
    final result = await _orgDesignRepository.loadConfig();
    if (!result.isSuccess) {
      return Result.failure(result.error ?? '讀取組織設定失敗');
    }

    final sortedNodes = _sortNodes(result.data!.departmentNodes);
    return Result.success(
      result.data!.copyWith(departmentNodes: sortedNodes),
    );
  }

  Future<Result<OrgDesignConfigModel>> loadTreeDesignConfig() async {
    final configResult = await loadConfig();
    if (!configResult.isSuccess || configResult.data == null) {
      return Result.failure(configResult.error ?? '讀取組織設定失敗');
    }

    final fileResult = await _orgDesignRepository.loadTreeDesignFile();
    if (!fileResult.isSuccess) {
      return Result.failure(fileResult.error ?? '讀取組織圖檔案失敗');
    }

    final fileConfig = fileResult.data;
    if (fileConfig == null) {
      return Result.success(configResult.data!);
    }

    final mergedDepartments = _mergeTreeDepartments(
      baseNodes: configResult.data!.departmentNodes,
      treeNodes: fileConfig.departmentNodes,
    );

    return Result.success(
      configResult.data!.copyWith(
        updatedAt: fileConfig.updatedAt.isEmpty
            ? configResult.data!.updatedAt
            : fileConfig.updatedAt,
        departmentNodes: _sortNodes(mergedDepartments),
        treeCanvasNodes:
            List<OrgTreeCanvasNode>.from(fileConfig.treeCanvasNodes),
      ),
    );
  }

  Future<Result<OrgDesignConfigModel>> createDepartmentNode({
    required String name,
    required String code,
    required String parentId,
    required int status,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return Result.failure('請輸入部門名稱');
    }

    final trimmedCode = code.trim();

    final loadResult = await _orgDesignRepository.loadConfig();
    if (!loadResult.isSuccess || loadResult.data == null) {
      return Result.failure(loadResult.error ?? '讀取組織設定失敗');
    }

    final config = loadResult.data!;
    final nodes = List<OrgDepartmentNode>.from(config.departmentNodes);

    if (trimmedCode.isNotEmpty &&
        nodes.any((node) =>
            node.departmentCode.toLowerCase() == trimmedCode.toLowerCase())) {
      return Result.failure('部門代碼不可重複');
    }

    OrgDepartmentNode? parentNode;
    if (parentId.isNotEmpty) {
      try {
        parentNode = nodes.firstWhere((node) => node.departmentId == parentId);
      } catch (_) {
        return Result.failure('上層部門不存在');
      }
    }

    final now = DateTime.now().toIso8601String();
    final newNode = OrgDepartmentNode(
      departmentId: DateTime.now().microsecondsSinceEpoch.toString(),
      departmentCode: trimmedCode,
      name: trimmedName,
      parentDepartmentId: parentId,
      depthLevel: parentNode == null ? 0 : parentNode.depthLevel + 1,
      status: status,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );

    final updatedConfig = config.copyWith(
      updatedAt: now,
      departmentNodes: _sortNodes([...nodes, newNode]),
    );

    final saveResult = await _orgDesignRepository.saveConfig(updatedConfig);
    if (!saveResult.isSuccess) {
      return Result.failure(saveResult.error ?? '新增部門節點失敗');
    }

    return Result.success(updatedConfig);
  }

  Future<Result<OrgDesignConfigModel>> updateDepartmentNode({
    required String departmentId,
    required String name,
    required String code,
    required String parentDepartmentId,
    required int status,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return Result.failure('請輸入部門名稱');
    }

    final trimmedCode = code.trim();
    final loadResult = await _orgDesignRepository.loadConfig();
    if (!loadResult.isSuccess || loadResult.data == null) {
      return Result.failure(loadResult.error ?? '讀取組織設定失敗');
    }

    final config = loadResult.data!;
    final nodes = List<OrgDepartmentNode>.from(config.departmentNodes);
    final targetIndex = nodes.indexWhere(
      (node) => node.departmentId == departmentId,
    );
    if (targetIndex == -1) {
      return Result.failure('找不到部門節點');
    }

    if (parentDepartmentId == departmentId) {
      return Result.failure('上層部門不可為自己');
    }

    if (_createsCycle(
      nodes: nodes,
      departmentId: departmentId,
      parentDepartmentId: parentDepartmentId,
    )) {
      return Result.failure('上層部門設定錯誤，會造成循環');
    }

    if (trimmedCode.isNotEmpty &&
        nodes.any((node) =>
            node.departmentId != departmentId &&
            node.departmentCode.toLowerCase() == trimmedCode.toLowerCase())) {
      return Result.failure('部門代碼不可重複');
    }

    OrgDepartmentNode? parentNode;
    if (parentDepartmentId.isNotEmpty) {
      try {
        parentNode = nodes.firstWhere(
          (node) => node.departmentId == parentDepartmentId,
        );
      } catch (_) {
        return Result.failure('上層部門不存在');
      }
    }

    final now = DateTime.now().toIso8601String();
    final currentNode = nodes[targetIndex];
    final updatedNode = currentNode.copyWith(
      departmentCode: trimmedCode,
      name: trimmedName,
      parentDepartmentId: parentDepartmentId,
      depthLevel: parentNode == null ? 0 : parentNode.depthLevel + 1,
      status: status,
      updatedAt: now,
    );

    nodes[targetIndex] = updatedNode;
    final reLeveledNodes = _recalculateDepthLevels(nodes);
    final updatedConfig = config.copyWith(
      updatedAt: now,
      departmentNodes: _sortNodes(reLeveledNodes),
    );

    final saveResult = await _orgDesignRepository.saveConfig(updatedConfig);
    if (!saveResult.isSuccess) {
      return Result.failure(saveResult.error ?? '更新部門節點失敗');
    }

    return Result.success(updatedConfig);
  }

  Future<Result<OrgDesignConfigModel>> saveOrgTreeDesign({
    required String orgName,
    required List<OrgDepartmentNode> departmentNodes,
    required List<OrgTreeCanvasNode> treeCanvasNodes,
  }) async {
    final loadResult = await _orgDesignRepository.loadConfig();
    if (!loadResult.isSuccess || loadResult.data == null) {
      return Result.failure(loadResult.error ?? '讀取組織設定失敗');
    }

    final trimmedOrgName = orgName.trim();
    if (trimmedOrgName.isEmpty) {
      return Result.failure('請輸入組織名稱');
    }

    final now = DateTime.now().toIso8601String();
    final updatedConfig = loadResult.data!.copyWith(
      schemaVersion: 3,
      orgName: trimmedOrgName,
      updatedAt: now,
      departmentNodes: _sortNodes(_recalculateDepthLevels(departmentNodes)),
      treeCanvasNodes: List<OrgTreeCanvasNode>.from(treeCanvasNodes),
    );

    final saveResult = await _orgDesignRepository.saveConfig(updatedConfig);
    if (!saveResult.isSuccess) {
      return Result.failure(saveResult.error ?? '儲存組織樹設定失敗');
    }

    final saveFileResult =
        await _orgDesignRepository.saveTreeDesignFile(updatedConfig);
    if (!saveFileResult.isSuccess) {
      return Result.failure(saveFileResult.error ?? '儲存組織圖檔案失敗');
    }

    return Result.success(updatedConfig);
  }

  Future<Result<OrgDesignConfigModel>> importOrgTreeDesignJson(
    String jsonData,
  ) async {
    try {
      final decoded = jsonDecode(jsonData) as Map<String, dynamic>;
      final importConfig = OrgDesignConfigModel.fromMap(decoded);
      final normalizedConfig = importConfig.copyWith(
        departmentNodes: _sortNodes(
          _recalculateDepthLevels(
            List<OrgDepartmentNode>.from(importConfig.departmentNodes),
          ),
        ),
        treeCanvasNodes:
            List<OrgTreeCanvasNode>.from(importConfig.treeCanvasNodes),
      );

      final saveConfigResult =
          await _orgDesignRepository.saveConfig(normalizedConfig);
      if (!saveConfigResult.isSuccess) {
        return Result.failure(saveConfigResult.error ?? '匯入組織設定失敗');
      }

      final saveFileResult =
          await _orgDesignRepository.saveTreeDesignFile(normalizedConfig);
      if (!saveFileResult.isSuccess) {
        return Result.failure(saveFileResult.error ?? '匯入組織圖檔案失敗');
      }

      return Result.success(normalizedConfig);
    } catch (_) {
      return Result.failure('匯入資料格式錯誤');
    }
  }

  Future<Result<OrgDesignConfigModel>> deleteOrganization() async {
    final deleteConfigResult = await _orgDesignRepository.deleteConfig();
    if (!deleteConfigResult.isSuccess) {
      return Result.failure(deleteConfigResult.error ?? '刪除組織失敗');
    }

    final deleteTreeFileResult =
        await _orgDesignRepository.deleteTreeDesignFile();
    if (!deleteTreeFileResult.isSuccess) {
      return Result.failure(deleteTreeFileResult.error ?? '刪除組織圖失敗');
    }

    final defaultConfigResult = await _orgDesignRepository.loadConfig();
    if (!defaultConfigResult.isSuccess || defaultConfigResult.data == null) {
      return Result.failure(defaultConfigResult.error ?? '重建預設組織失敗');
    }

    final saveDefaultResult =
        await _orgDesignRepository.saveConfig(defaultConfigResult.data!);
    if (!saveDefaultResult.isSuccess) {
      return Result.failure(saveDefaultResult.error ?? '重建預設組織失敗');
    }

    return Result.success(defaultConfigResult.data!);
  }

  List<OrgDepartmentNode> _mergeTreeDepartments({
    required List<OrgDepartmentNode> baseNodes,
    required List<OrgDepartmentNode> treeNodes,
  }) {
    final treeLookup = {
      for (final node in treeNodes) node.departmentId: node,
    };

    return baseNodes.map((node) {
      final treeNode = treeLookup[node.departmentId];
      if (treeNode == null) {
        return node;
      }

      return node.copyWith(
        parentDepartmentId: treeNode.parentDepartmentId,
        depthLevel: treeNode.depthLevel,
        updatedAt: treeNode.updatedAt,
      );
    }).toList();
  }

  List<OrgDepartmentNode> _sortNodes(List<OrgDepartmentNode> nodes) {
    final sorted = List<OrgDepartmentNode>.from(nodes)
      ..sort((left, right) {
        final sortCompare = left.sortOrder.compareTo(right.sortOrder);
        if (sortCompare != 0) {
          return sortCompare;
        }

        final codeCompare = left.departmentCode.compareTo(right.departmentCode);
        if (codeCompare != 0) {
          return codeCompare;
        }

        return left.name.compareTo(right.name);
      });
    return sorted;
  }

  bool _createsCycle({
    required List<OrgDepartmentNode> nodes,
    required String departmentId,
    required String parentDepartmentId,
  }) {
    if (parentDepartmentId.isEmpty) {
      return false;
    }

    var currentParentId = parentDepartmentId;
    final lookup = {
      for (final node in nodes) node.departmentId: node,
    };

    while (currentParentId.isNotEmpty) {
      if (currentParentId == departmentId) {
        return true;
      }
      final currentNode = lookup[currentParentId];
      if (currentNode == null) {
        return false;
      }
      currentParentId = currentNode.parentDepartmentId;
    }

    return false;
  }

  List<OrgDepartmentNode> _recalculateDepthLevels(
      List<OrgDepartmentNode> nodes) {
    final lookup = {
      for (final node in nodes) node.departmentId: node,
    };

    int resolveDepth(String departmentId, Set<String> visiting) {
      final node = lookup[departmentId];
      if (node == null || node.parentDepartmentId.isEmpty) {
        return 0;
      }
      if (visiting.contains(departmentId)) {
        return 0;
      }
      visiting.add(departmentId);
      final depth = resolveDepth(node.parentDepartmentId, visiting) + 1;
      visiting.remove(departmentId);
      return depth;
    }

    return nodes.map((node) {
      final depth = resolveDepth(node.departmentId, <String>{});
      return node.copyWith(depthLevel: depth);
    }).toList();
  }
}
