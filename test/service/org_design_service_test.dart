import 'package:flutter_application_ai/data/tempData/org_temp_data.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/model/org_design_config_model.dart';
import 'package:flutter_application_ai/model/org_tree_canvas_node.dart';
import 'package:flutter_application_ai/repositories/interface/org_design_repository.dart';
import 'package:flutter_application_ai/service/org_design_service.dart';
import 'package:flutter_application_ai/unit/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrgDesignRepository extends Mock implements OrgDesignRepository {}

class FakeOrgDesignConfigModel extends Fake implements OrgDesignConfigModel {}

void main() {
  late MockOrgDesignRepository repository;
  late OrgDesignService service;

  setUpAll(() {
    registerFallbackValue(FakeOrgDesignConfigModel());
  });

  setUp(() {
    repository = MockOrgDesignRepository();
    service = OrgDesignService(repository);
  });

  group('loadTreeDesignConfig', () {
    test('uses tree_design.json data to restore tree state', () async {
      final baseConfig = OrgDesignConfigModel(
        orgId: 'org-1',
        orgName: '測試組織',
        updatedAt: 'base-time',
        departmentNodes: const [
          OrgDepartmentNode(
            departmentId: 'root',
            departmentCode: 'A01',
            name: '總部',
          ),
          OrgDepartmentNode(
            departmentId: 'child',
            departmentCode: 'B01',
            name: '資訊部',
          ),
        ],
      );
      final treeFileConfig = OrgDesignConfigModel(
        orgId: 'org-1',
        orgName: '測試組織',
        updatedAt: 'file-time',
        departmentNodes: const [
          OrgDepartmentNode(
            departmentId: 'root',
            departmentCode: 'A01',
            name: '總部',
            depthLevel: 0,
          ),
          OrgDepartmentNode(
            departmentId: 'child',
            departmentCode: 'B01',
            name: '資訊部',
            parentDepartmentId: 'root',
            depthLevel: 1,
            updatedAt: 'tree-updated',
          ),
        ],
        treeCanvasNodes: const [
          OrgTreeCanvasNode(
            departmentId: 'root',
            offsetDx: 120,
            offsetDy: 80,
          ),
          OrgTreeCanvasNode(
            departmentId: 'child',
            offsetDx: 120,
            offsetDy: 220,
          ),
        ],
      );

      when(() => repository.loadConfig())
          .thenAnswer((_) async => Result.success(baseConfig));
      when(() => repository.loadTreeDesignFile())
          .thenAnswer((_) async => Result.success(treeFileConfig));

      final result = await service.loadTreeDesignConfig();

      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.updatedAt, 'file-time');
      expect(result.data!.treeCanvasNodes, treeFileConfig.treeCanvasNodes);
      expect(
        result.data!.departmentNodes
            .firstWhere(
              (node) => node.departmentId == 'child',
            )
            .parentDepartmentId,
        'root',
      );
      expect(
        result.data!.departmentNodes
            .firstWhere(
              (node) => node.departmentId == 'child',
            )
            .depthLevel,
        1,
      );
    });
  });

  group('saveOrgTreeDesign', () {
    test('keeps current storage and writes tree_design.json together',
        () async {
      final baseConfig = OrgDesignConfigModel(
        orgId: 'org-1',
        orgName: '測試組織',
        updatedAt: 'base-time',
        departmentNodes: const [
          OrgDepartmentNode(
            departmentId: 'root',
            departmentCode: 'A01',
            name: '總部',
          ),
        ],
      );
      const treeNodes = [
        OrgTreeCanvasNode(
          departmentId: 'root',
          offsetDx: 100,
          offsetDy: 200,
        ),
      ];

      when(() => repository.loadConfig())
          .thenAnswer((_) async => Result.success(baseConfig));
      when(() => repository.saveConfig(any()))
          .thenAnswer((_) async => Result.success(true));
      when(() => repository.saveTreeDesignFile(any()))
          .thenAnswer((_) async => Result.success(true));

      final result = await service.saveOrgTreeDesign(
        departmentNodes: baseConfig.departmentNodes,
        treeCanvasNodes: treeNodes,
        orgName: '測試組織',
      );

      expect(result.isSuccess, isTrue);
      verify(() => repository.saveConfig(any())).called(1);
      verify(() => repository.saveTreeDesignFile(any())).called(1);
      expect(result.data!.treeCanvasNodes, treeNodes);
    });
  });

  group('importOrgTreeDesignJson', () {
    test('imports sample json and writes config and tree file', () async {
      when(() => repository.saveConfig(any()))
          .thenAnswer((_) async => Result.success(true));
      when(() => repository.saveTreeDesignFile(any()))
          .thenAnswer((_) async => Result.success(true));

      final result =
          await service.importOrgTreeDesignJson(TempOrgDataStorage.jsonData);

      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.orgName, '偉盟科技');
      expect(result.data!.departmentNodes, isNotEmpty);
      expect(result.data!.treeCanvasNodes, isNotEmpty);
      verify(() => repository.saveConfig(any())).called(1);
      verify(() => repository.saveTreeDesignFile(any())).called(1);
    });
  });
}
