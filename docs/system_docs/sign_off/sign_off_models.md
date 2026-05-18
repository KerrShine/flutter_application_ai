# 簽核系統 — Model 總覽

## 模組定位

簽核系統的所有資料結構（model + enum）集中文件化於本頁。
分為五大類：**執行期申請主體 / 模板設定 / 設定輔助 / Enum 常數 / 被引用的相鄰 model**。

> 規格設計參考：[`docs/system_docs/system/sign_off_system.md`](../system/sign_off_system.md)
> 實作執行流程：[`SignOffService.resolveApproverChain`](../../../lib/service/sign_off_service.dart)

---

## A. 執行期 Model（Runtime — 申請與簽核狀態）

### A1. `LeaveSignOffModel`

**檔案**：[`lib/model/leave_sign_off_model.dart`](../../../lib/model/leave_sign_off_model.dart)

**角色**：申請主體。所有送出的請假申請以此存於 LocalStorage（key=`form_run_test_write_log`）。

| 區塊 | 欄位 | 說明 |
|---|---|---|
| 識別 | `signOffId` | `test_signoff_${microsecondsSinceEpoch}` |
| 識別 | `submissionId` | 對應原 form_submission 結構（v1 = `${signOffId}_sub`） |
| 識別 | `templateId` | 對應 `SignOffTemplateModel.templateId`；空字串 = 未綁定 |
| Form | `formId` / `formName` | 表單識別與顯示名稱 |
| Form | `applicantId` / `applicantName` / `departmentId` | 申請人資訊 |
| Form | `fieldValues: Map<String, dynamic>` | itemId → 欄位值 |
| Form | `computedFields: Map<String, String>` | computedFieldKey → 計算結果（如「leave_days = -1」） |
| Form | `sectionsSnapshot: List<Map<String, dynamic>>` | 送出當下的 sections 結構快照 |
| 簽核 | `status: LeaveSignOffStatus` | pending / inReview / approved / rejected / withdrawn |
| 簽核 | `currentStepIndex: int` | 0-based；-1 = 結案 / 在申請人手上 |
| 簽核 | `currentApproverId` / `currentApproverName` | 目前簽核者識別（多人時取第一個） |
| 簽核 | `latestComment` | 最近一筆簽核意見 |
| 簽核 | `actionHistory: List<SignOffActionRecord>` | 軌跡（時間順序） |
| 時間 | `submittedAt` / `updatedAt` | ISO 8601 |
| 衍生 | `isEditableByApplicant` (getter) | `status==pending && (actionHistory 空 OR last 是 returnBack)` |

### A2. `SignOffActionRecord`

**檔案**：[`lib/model/sign_off_action_record.dart`](../../../lib/model/sign_off_action_record.dart)

**角色**：單筆簽核動作軌跡；嵌入 `LeaveSignOffModel.actionHistory`。

| 欄位 | 說明 |
|---|---|
| `recordId` | `act_${microsecondsSinceEpoch}` |
| `actionType: SignOffActionType` | 6 種動作之一 |
| `approverId` / `approverName` | 執行動作者 |
| `comment` | 簽核意見（拒絕 / 退回必填、同意可選） |
| `actionAt` | ISO 8601 時間戳 |
| `targetRef` | 退回時：目標 nodeId；轉派/加簽時：目標 employeeId；其他為空 |

---

## B. 模板期 Model（Designer — 簽核流程設定）

### B1. `SignOffTemplateModel`

**檔案**：[`lib/model/sign_off_template_model.dart`](../../../lib/model/sign_off_template_model.dart)

**角色**：簽核流程模板。一張表單對應 1 個 active template。

| 欄位 | 說明 |
|---|---|
| `templateId` | 主鍵 |
| `formId` / `formName` | 對應的表單 |
| `permissionId` | 引用既有 `FormLaunchPermissionModel`，可空 |
| `name` | 模板顯示名稱 |
| `status` | `draft / active / disabled` |
| `canvasNodes: List<SignOffCanvasNode>` | 節點清單 |
| `pathRules: List<SignOffPathRule>` | 條件路由規則（first-match） |
| `canvasTransform: List<double>` | 畫布 Matrix4 縮放/平移狀態（16 doubles） |
| `version` / `createdAt` / `updatedAt` | 元資訊 |

### B2. `SignOffCanvasNode`

**檔案**：[`lib/model/sign_off_canvas_node.dart`](../../../lib/model/sign_off_canvas_node.dart)

**角色**：單一簽核節點 — 一個關卡。

| 區塊 | 欄位 | 說明 |
|---|---|---|
| 識別 | `nodeId` | 主鍵 |
| 識別 | `isApplicantOrigin` | true = 申請起點（虛擬節點） |
| 順序 | `sortOrder` | 整數；申請起點為 0、其餘遞增 |
| 位置 | `offsetDx` / `offsetDy` | 畫布座標 |
| 部門 | `departmentId` | 引用部門（hierarchyManager 模式必填） |
| 類型 | `nodeType: SignOffNodeType` | approve / countersign / notify |
| 簽核人 | `approverMode: SignOffApproverMode` | 7 種模式之一 |
| 互簽 | `crossLevelTargetNodeId` | crossLevel 模式：目標節點 |
| 角色 | `designatedRoleId` | designatedRole 模式：指定角色 |
| 員工 | `designatedEmployeeId` | designatedEmployee 模式：指定員工 |
| 會簽 | `multiStrategy: SignOffMultiStrategy` | countersign 用：all / any / sequential |
| 退回 | `returnPolicy: SignOffReturnPolicy` | toApplicant / toPrevious / toSpecificNode |
| 退回 | `returnTargetNodeId` | toSpecificNode 用 |
| 加簽 | `allowAddSigner` | v1 預設 false |
| SLA | `slaDays` | 簽核期限天數；0 = 不限期 |
| 申請人 | `applicantAncestorOffset` | applicantAncestorManager 模式：往上 N 層 |
| 申請人 | `applicantTargetDepthLevel` | applicantManagerAtDepth 模式：目標 depthLevel |

### B3. `SignOffPathRule`

**檔案**：[`lib/model/sign_off_path_rule.dart`](../../../lib/model/sign_off_path_rule.dart)

**角色**：條件路由規則。送出時依 sortOrder first-match 評估，命中即取其 `activatedNodeIds`。

| 欄位 | 說明 |
|---|---|
| `ruleId` | 主鍵 |
| `name` | 顯示名稱（如「短假流程」） |
| `condition: SignOffPathCondition?` | null = 預設規則（永遠匹配） |
| `activatedNodeIds: List<String>` | 本規則啟用的節點 |
| `sortOrder` | 評估順序 |
| `isDefault` (getter) | `condition == null` |

### B4. `SignOffPathCondition`

**檔案**：[`lib/model/sign_off_path_condition.dart`](../../../lib/model/sign_off_path_condition.dart)

**角色**：路由條件表達式。

| 欄位 | 說明 |
|---|---|
| `fieldId` | 條件欄位 ID（對應 `condition_field_definition.fieldKey`） |
| `fieldName` | 顯示名稱快照 |
| `fieldType: ConditionFieldType` | string / number / date |
| `operator: SignOffConditionOperator` | 8 種運算子之一 |
| `value` | 比對值（字串編碼） |
| `valueMax` | between 運算子的上限 |
| `summary` (getter) | 顯示用摘要：「請假天數 >= 7」「介於 5 ~ 30」 |

---

## C. 設定輔助 Model（編輯器 UI 中介）

### C1. `SignOffConditionFieldChoice`

**檔案**：[`lib/model/sign_off_condition_field_choice.dart`](../../../lib/model/sign_off_condition_field_choice.dart)

**角色**：path rule 條件欄位 dropdown 選項中介。從 form_condition_field draft 映射，UI 只認此結構。

| 欄位 | 說明 |
|---|---|
| `outputKey` | runtime 提交時的 key |
| `label` | UI 顯示名稱 |
| `fieldName` | 原始 fieldName（fallback） |
| `fieldType: ConditionFieldType` | 比對型別 |

### C2. `SignOffConditionFieldSummary`

**檔案**：[`lib/model/sign_off_condition_field_summary.dart`](../../../lib/model/sign_off_condition_field_summary.dart)

**角色**：給 sign_off_editor header chip / dropdown 圖示用的條件欄位狀態摘要。

| 欄位 | 說明 |
|---|---|
| `status: SignOffConditionFieldStatus` | none / ready |
| `definitionCount` | draft 中已定義數量 |
| `SignOffConditionFieldSummary.empty` | 預設空摘要常數 |

---

## D. Enum（型別常數）

| Enum | 檔案 | 值 |
|---|---|---|
| `LeaveSignOffStatus` | [`lib/enum/leave_sign_off_status.dart`](../../../lib/enum/leave_sign_off_status.dart) | pending / inReview / approved / rejected / withdrawn |
| `SignOffActionType` | [`lib/enum/sign_off_action_type.dart`](../../../lib/enum/sign_off_action_type.dart) | approve / reject / returnBack / requestSupplement / transfer / addApprover |
| `SignOffNodeType` | [`lib/enum/sign_off_node_type.dart`](../../../lib/enum/sign_off_node_type.dart) | approve / countersign / notify |
| `SignOffApproverMode` | [`lib/enum/sign_off_approver_mode.dart`](../../../lib/enum/sign_off_approver_mode.dart) | hierarchyManager / crossLevel / designatedRole / designatedEmployee / applicantSelf / applicantAncestorManager / applicantManagerAtDepth |
| `SignOffMultiStrategy` | [`lib/enum/sign_off_multi_strategy.dart`](../../../lib/enum/sign_off_multi_strategy.dart) | all / any / sequential |
| `SignOffReturnPolicy` | [`lib/enum/sign_off_return_policy.dart`](../../../lib/enum/sign_off_return_policy.dart) | toApplicant / toPrevious / toSpecificNode |
| `SignOffConditionOperator` | [`lib/enum/sign_off_condition_operator.dart`](../../../lib/enum/sign_off_condition_operator.dart) | equal / notEqual / contains / greaterThan / greaterThanOrEqual / lessThan / lessThanOrEqual / between |
| `SignOffConditionFieldStatus` | [`lib/enum/sign_off_condition_field_status.dart`](../../../lib/enum/sign_off_condition_field_status.dart) | none / ready |
| `SubmissionViewMode` | [`lib/enum/submission_view_mode.dart`](../../../lib/enum/submission_view_mode.dart) | viewer / reviewer（詳情頁顯示模式） |

---

## E. 被簽核流程「引用」的相鄰 Model（非簽核專屬）

簽核引擎執行時需要這些 model：

| Model | 在簽核中扮演 |
|---|---|
| [`FormLaunchPermissionModel`](../../../lib/model/form_launch_permission_model.dart) | `SignOffTemplateModel.permissionId` 引用 — 可發起此流程的對象 |
| [`FormModel`](../../../lib/model/form_model.dart) | `SignOffTemplateModel.formId` 引用 |
| [`EmployeeModel`](../../../lib/model/employee_model.dart) | `resolveApproverChain` 取主管 / 員工；`isManagerLevel` (roleType==1) 給部門主管 fallback 用 |
| [`OrgDepartmentNode`](../../../lib/model/org_department_node.dart) | 解析 `departmentHeadUserId` / 沿 `parentDepartmentId` 上推 |
| [`EmpRoleModel`](../../../lib/model/emp_role_model.dart) | designatedRole 模式找符合角色的員工 |
| [`ConditionFieldDefinition`](../../../lib/model/condition_field_definition.dart) | path rule 條件欄位的真實定義來源 |
| [`SectionModel`](../../../lib/model/section_model.dart) / [`DesignerItem`](../../../lib/model/designer_item.dart) | sectionsSnapshot 序列化來源 |

---

## F. 整體關係圖

```
┌──────────────────────────────────────────────────────────────┐
│ 模板期（設計）                                                  │
│  SignOffTemplateModel                                         │
│    ├── canvasNodes: List<SignOffCanvasNode>                  │
│    │     └── (引用 OrgDepartmentNode / EmpRoleModel /          │
│    │          EmployeeModel)                                  │
│    └── pathRules: List<SignOffPathRule>                      │
│          └── condition: SignOffPathCondition                  │
│                └── (引用 ConditionFieldDefinition)              │
└─────────────────────────────┬────────────────────────────────┘
                              │ templateId
                              ▼
┌──────────────────────────────────────────────────────────────┐
│ 執行期（申請）                                                  │
│  LeaveSignOffModel                                            │
│    ├── form 資料 + sectionsSnapshot                            │
│    │     └── (序列化自 SectionModel + DesignerItem)            │
│    ├── 簽核狀態（status + currentStepIndex                       │
│    │            + currentApproverId/Name）                     │
│    └── actionHistory: List<SignOffActionRecord>                │
│          └── actionType: SignOffActionType                    │
└──────────────────────────────────────────────────────────────┘
```

---

## G. 數量總結

| 類別 | 數量 |
|---|---|
| 簽核專屬 Model | **8** 個（A: 2 + B: 4 + C: 2） |
| 簽核專屬 Enum | **9** 個（D） |
| 被引用相鄰 Model | 7 個（E，非簽核 owner） |

---

## 更新原則

- 新增簽核相關 model 或 enum 時，同步補上本清單對應區塊
- 移除或重構時，同步更新欄位表與關係圖
