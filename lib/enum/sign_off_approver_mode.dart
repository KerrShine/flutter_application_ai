/// 簽核人來源模式。
enum SignOffApproverMode {
  /// 此部門主管 — 拖曳預設，由節點所屬部門主管簽核（絕對位置）
  hierarchyManager,

  /// 同層互簽 — 指向另一個畫布節點（絕對位置）
  crossLevel,

  /// 指定角色 — 跨業務線（HR / Finance）（絕對位置）
  designatedRole,

  /// 指定員工 — 固定特定員工簽核（絕對位置）
  designatedEmployee,

  /// 申請人本人 — 執行時直接帶入申請人為簽核人（相對申請人）
  applicantSelf,

  /// 申請人上 N 層主管 — 從申請人所屬部門沿 parentDepartmentId 走 N 步取主管（相對申請人）
  applicantAncestorManager,

  /// 申請人指定層級主管 — 沿 parent 鏈往上找第一個 depthLevel == applicantTargetDepthLevel 的祖先部門主管。
  /// 解決不對稱組織樹下「BU 主管 / 事業群主管」這類邏輯角色定位（相對申請人）
  applicantManagerAtDepth,
}

extension SignOffApproverModeX on SignOffApproverMode {
  String get code {
    switch (this) {
      case SignOffApproverMode.hierarchyManager:
        return 'hierarchyManager';
      case SignOffApproverMode.crossLevel:
        return 'crossLevel';
      case SignOffApproverMode.designatedRole:
        return 'designatedRole';
      case SignOffApproverMode.designatedEmployee:
        return 'designatedEmployee';
      case SignOffApproverMode.applicantSelf:
        return 'applicantSelf';
      case SignOffApproverMode.applicantAncestorManager:
        return 'applicantAncestorManager';
      case SignOffApproverMode.applicantManagerAtDepth:
        return 'applicantManagerAtDepth';
    }
  }

  String get label {
    switch (this) {
      case SignOffApproverMode.hierarchyManager:
        return '此部門主管';
      case SignOffApproverMode.crossLevel:
        return '同層互簽';
      case SignOffApproverMode.designatedRole:
        return '指定角色';
      case SignOffApproverMode.designatedEmployee:
        return '指定員工';
      case SignOffApproverMode.applicantSelf:
        return '申請人本人';
      case SignOffApproverMode.applicantAncestorManager:
        return '申請人上 N 層主管';
      case SignOffApproverMode.applicantManagerAtDepth:
        return '申請人指定層級主管';
    }
  }

  /// 是否為「相對申請人」模式 — 不綁定畫布節點的 departmentId，執行時依申請人動態解析。
  bool get isRelativeToApplicant {
    return this == SignOffApproverMode.applicantSelf ||
        this == SignOffApproverMode.applicantAncestorManager ||
        this == SignOffApproverMode.applicantManagerAtDepth;
  }

  static SignOffApproverMode fromCode(String? code) {
    switch (code) {
      case 'crossLevel':
        return SignOffApproverMode.crossLevel;
      case 'designatedRole':
        return SignOffApproverMode.designatedRole;
      case 'designatedEmployee':
        return SignOffApproverMode.designatedEmployee;
      case 'applicantSelf':
        return SignOffApproverMode.applicantSelf;
      case 'applicantAncestorManager':
        return SignOffApproverMode.applicantAncestorManager;
      case 'applicantManagerAtDepth':
        return SignOffApproverMode.applicantManagerAtDepth;
      case 'hierarchyManager':
      default:
        return SignOffApproverMode.hierarchyManager;
    }
  }
}
