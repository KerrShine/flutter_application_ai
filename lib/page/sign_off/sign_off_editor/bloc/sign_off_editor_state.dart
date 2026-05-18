part of 'sign_off_editor_bloc.dart';

enum SignOffEditorStatus { init, ready, saving, saved, failure }

/// 模擬發起預覽下，每個簽核節點的時點狀態。
enum SimulationStatus {
  /// 該節點預期的截止日已通過 → 視為已完成（綠）
  completed,

  /// 已抵達該節點但尚未到期（黃）
  inProgress,

  /// 已抵達且超過 slaDays（紅）
  expired,

  /// 尚未輪到此節點（灰）
  pending,

  /// slaDays = 0，代表不限期；模擬模式下也視為「已通過」處理（綠）
  unlimited,
}

class SignOffEditorState extends Equatable {
  final SignOffEditorStatus status;
  final SignOffTemplateModel template;
  final List<FormModel> availableForms;
  final List<FormLaunchPermissionModel> permissions;
  final List<OrgDepartmentNode> departments;
  final List<EmpRoleModel> roles;
  final List<EmployeeModel> employees;

  final String? selectedNodeId;
  final String? availableHighlightId;
  final double canvasScale;
  final List<double> canvasTransformValues;
  final int canvasTransformRequestId;
  final double viewportWidth;
  final double viewportHeight;
  final bool showHierarchyConnections;

  /// 模擬發起預覽是否啟用。
  final bool simulationMode;

  /// 模擬「發起 N 天前」的天數。
  final int simulationDaysAgo;

  /// 當前選中表單的可作為條件的欄位列表（透過 SignOffService.loadFormFields 載入）。
  /// 來源：form_data_binding 的 saved draft（不是 form_section_design）。
  /// 空 list 可能代表「表單未做 form_data_binding」— UI 應提示使用者前往綁定。
  final List<SignOffConditionFieldChoice> formFields;
  final bool formFieldsLoading;

  /// Path rule 預覽模式：開啟時，依使用者輸入的 fieldId→value 即時計算
  /// 哪些節點被啟用、Canvas 上的節點視覺暗化非啟用節點。
  final bool rulePreviewMode;
  final Map<String, String> rulePreviewValues;

  /// 對應表單的 form_condition_field 狀態摘要 — key = formId。
  /// 由 InitSignOffEditorEvent 一次載齊；SelectFormForTemplateEvent 後刷新單筆。
  /// 用於 header dropdown 圖示與 chip 顯示。
  final Map<String, SignOffConditionFieldSummary> conditionFieldStatuses;

  final String message;
  final int messageRequestId;

  /// 匯出 JSON 的內容（由 RequestExportJsonEvent 觸發後填入）。
  final String exportJson;

  /// 匯出 JSON dialog 顯示計數 — page 透過 BlocListener 比對前後值決定是否 showDialog。
  final int exportDialogRequestId;

  /// 待導航的路由名稱（空字串 = 無）。
  final String navigateRoute;

  /// 待導航攜帶的 extra（如 formId / formName）。
  final Map<String, dynamic> navigateExtra;

  static final List<double> defaultCanvasTransformValues =
      List<double>.unmodifiable([
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0,
  ]);

  SignOffEditorState({
    this.status = SignOffEditorStatus.init,
    this.template = const SignOffTemplateModel(),
    this.availableForms = const [],
    this.permissions = const [],
    this.departments = const [],
    this.roles = const [],
    this.employees = const [],
    this.selectedNodeId,
    this.availableHighlightId,
    this.canvasScale = 1.0,
    List<double>? canvasTransformValues,
    this.canvasTransformRequestId = 0,
    this.viewportWidth = 0,
    this.viewportHeight = 0,
    this.showHierarchyConnections = true,
    this.simulationMode = false,
    this.simulationDaysAgo = 0,
    this.formFields = const [],
    this.formFieldsLoading = false,
    this.rulePreviewMode = false,
    this.rulePreviewValues = const {},
    this.conditionFieldStatuses = const {},
    this.message = '',
    this.messageRequestId = 0,
    this.exportJson = '',
    this.exportDialogRequestId = 0,
    this.navigateRoute = '',
    this.navigateExtra = const {},
  }) : canvasTransformValues =
            canvasTransformValues ?? defaultCanvasTransformValues;

  /// 取目前選中表單的條件欄位摘要；無則 empty (none 狀態)。
  SignOffConditionFieldSummary get currentConditionFieldSummary {
    final formId = template.formId;
    if (formId.isEmpty) return SignOffConditionFieldSummary.empty;
    return conditionFieldStatuses[formId] ?? SignOffConditionFieldSummary.empty;
  }

  SignOffCanvasNode? get selectedNode {
    if (selectedNodeId == null) return null;
    return template.canvasNodes.cast<SignOffCanvasNode?>().firstWhere(
          (n) => n?.nodeId == selectedNodeId,
          orElse: () => null,
        );
  }

  /// 取得目前已選表單對應的權限（若有）。
  FormLaunchPermissionModel? get currentPermission {
    if (template.formId.isEmpty) return null;
    return permissions.cast<FormLaunchPermissionModel?>().firstWhere(
          (p) => p?.formId == template.formId,
          orElse: () => null,
        );
  }

  /// 模擬發起預覽下，每個節點的狀態 map。
  ///
  /// 演算法：
  ///   - 依 sortOrder 取得 approver nodes（排除 isApplicantOrigin）
  ///   - 假設每個節點都「剛好用滿 slaDays」推進到下一節點；slaDays = 0 視為 1 天最小消耗
  ///   - n = simulationDaysAgo
  ///   - 一旦遇到「目前停留節點」（inProgress / unlimited / pending），後續節點一律 pending
  ///   - 若 n 超過所有節點 deadline（無 currentNode）→ 最後一個 sla>0 的節點標為 expired
  ///   - 申請起點固定 completed
  Map<String, SimulationStatus> get simulationStatusByNodeId {
    if (!simulationMode) return const {};

    final result = <String, SimulationStatus>{};
    final approverNodes = template.canvasNodes
        .where((n) => !n.isApplicantOrigin)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final n = simulationDaysAgo;
    var cumulative = 0;
    var stuck = false;
    SignOffCanvasNode? currentNode;

    for (final node in approverNodes) {
      if (stuck) {
        result[node.nodeId] = SimulationStatus.pending;
        continue;
      }

      final sla = node.slaDays;
      final consumed = sla > 0 ? sla : 1;
      final arrival = cumulative;
      final deadline = arrival + consumed;
      cumulative += consumed;

      if (n < arrival) {
        result[node.nodeId] = SimulationStatus.pending;
        stuck = true;
      } else if (sla == 0) {
        result[node.nodeId] = SimulationStatus.unlimited;
        currentNode = node;
        stuck = true;
      } else if (n < deadline) {
        result[node.nodeId] = SimulationStatus.inProgress;
        currentNode = node;
        stuck = true;
      } else {
        result[node.nodeId] = SimulationStatus.completed;
      }
    }

    // 若所有 approver 都 completed（沒有 currentNode）→ 最後一個是真正過期的
    if (currentNode == null && approverNodes.isNotEmpty) {
      final last = approverNodes.last;
      if (last.slaDays > 0 &&
          result[last.nodeId] == SimulationStatus.completed) {
        result[last.nodeId] = SimulationStatus.expired;
      }
    }

    for (final node in template.canvasNodes) {
      if (node.isApplicantOrigin) {
        result[node.nodeId] = SimulationStatus.completed;
      }
    }

    return result;
  }

  /// Path rule 預覽模式下，依 rulePreviewValues 算出當前命中 rule 的啟用節點集合。
  /// 非預覽模式回 const {}（canvas 不暗化任何節點）。
  Set<String> get activatedNodeIdsByPreview {
    if (!rulePreviewMode) return const {};
    return SignOffService.resolveActivatedNodeIds(template, rulePreviewValues);
  }

  /// 取得指定節點在模擬模式下「已停留 / 已過期 X 天」的偏移天數。
  /// - inProgress: 已停留天數 (n - arrivalDay)
  /// - expired: 已過期天數 (n - deadlineDay)
  /// - 其他狀態回傳 0
  int simulationOffsetDaysFor(String nodeId) {
    if (!simulationMode) return 0;
    final approverNodes = template.canvasNodes
        .where((nd) => !nd.isApplicantOrigin)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    var cumulative = 0;
    for (final node in approverNodes) {
      final sla = node.slaDays;
      final consumed = sla > 0 ? sla : 1;
      final arrival = cumulative;
      final deadline = arrival + consumed;
      cumulative += consumed;

      if (node.nodeId == nodeId) {
        final status = simulationStatusByNodeId[nodeId];
        if (status == SimulationStatus.inProgress) {
          return simulationDaysAgo - arrival;
        }
        if (status == SimulationStatus.expired) {
          return simulationDaysAgo - deadline;
        }
        return 0;
      }
    }
    return 0;
  }

  SignOffEditorState copyWith({
    SignOffEditorStatus? status,
    SignOffTemplateModel? template,
    List<FormModel>? availableForms,
    List<FormLaunchPermissionModel>? permissions,
    List<OrgDepartmentNode>? departments,
    List<EmpRoleModel>? roles,
    List<EmployeeModel>? employees,
    String? selectedNodeId,
    String? availableHighlightId,
    double? canvasScale,
    List<double>? canvasTransformValues,
    int? canvasTransformRequestId,
    double? viewportWidth,
    double? viewportHeight,
    bool? showHierarchyConnections,
    bool? simulationMode,
    int? simulationDaysAgo,
    List<SignOffConditionFieldChoice>? formFields,
    bool? formFieldsLoading,
    bool? rulePreviewMode,
    Map<String, String>? rulePreviewValues,
    Map<String, SignOffConditionFieldSummary>? conditionFieldStatuses,
    String? message,
    int? messageRequestId,
    String? exportJson,
    int? exportDialogRequestId,
    String? navigateRoute,
    Map<String, dynamic>? navigateExtra,
    bool clearSelectedNode = false,
  }) {
    return SignOffEditorState(
      status: status ?? this.status,
      template: template ?? this.template,
      availableForms: availableForms ?? this.availableForms,
      permissions: permissions ?? this.permissions,
      departments: departments ?? this.departments,
      roles: roles ?? this.roles,
      employees: employees ?? this.employees,
      selectedNodeId:
          clearSelectedNode ? null : (selectedNodeId ?? this.selectedNodeId),
      availableHighlightId: availableHighlightId ?? this.availableHighlightId,
      canvasScale: canvasScale ?? this.canvasScale,
      canvasTransformValues:
          canvasTransformValues ?? this.canvasTransformValues,
      canvasTransformRequestId:
          canvasTransformRequestId ?? this.canvasTransformRequestId,
      viewportWidth: viewportWidth ?? this.viewportWidth,
      viewportHeight: viewportHeight ?? this.viewportHeight,
      showHierarchyConnections:
          showHierarchyConnections ?? this.showHierarchyConnections,
      simulationMode: simulationMode ?? this.simulationMode,
      simulationDaysAgo: simulationDaysAgo ?? this.simulationDaysAgo,
      formFields: formFields ?? this.formFields,
      formFieldsLoading: formFieldsLoading ?? this.formFieldsLoading,
      rulePreviewMode: rulePreviewMode ?? this.rulePreviewMode,
      rulePreviewValues: rulePreviewValues ?? this.rulePreviewValues,
      conditionFieldStatuses: conditionFieldStatuses ?? this.conditionFieldStatuses,
      message: message ?? this.message,
      messageRequestId: messageRequestId ?? this.messageRequestId,
      exportJson: exportJson ?? this.exportJson,
      exportDialogRequestId:
          exportDialogRequestId ?? this.exportDialogRequestId,
      navigateRoute: navigateRoute ?? this.navigateRoute,
      navigateExtra: navigateExtra ?? this.navigateExtra,
    );
  }

  @override
  List<Object?> get props => [
        status,
        template,
        availableForms,
        permissions,
        departments,
        roles,
        employees,
        selectedNodeId,
        availableHighlightId,
        canvasScale,
        canvasTransformValues,
        canvasTransformRequestId,
        viewportWidth,
        viewportHeight,
        showHierarchyConnections,
        simulationMode,
        simulationDaysAgo,
        formFields,
        formFieldsLoading,
        rulePreviewMode,
        rulePreviewValues,
        conditionFieldStatuses,
        message,
        messageRequestId,
        exportJson,
        exportDialogRequestId,
        navigateRoute,
        navigateExtra,
      ];
}
