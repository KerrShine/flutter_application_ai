# Model 總覽 — lib/model dataclass 索引

> 整理 [`lib/model/`](../../../lib/model/) 下 30 個 dataclass，依用途分九組。
> 簽核相關 model 已有獨立詳述文件 [`sign_off_models.md`](../sign_off/sign_off_models.md)，本文件 J 節僅做索引。

## 資料流概覽

```
[認證]                    [組織]                  [員工 / 代理]
UserModel ────────► OrgDesignConfigModel ────► EmployeeModel ───► EmpAgentAssignment
                    │  ├ OrgDepartmentNode       │  └ EmpRoleModel       │
                    │  └ OrgTreeCanvasNode       │                        │
                    │                            └────────► EmpDepBindingViewData
                    │                                                     │
                    │                                                     ▼
[表單設計]                                            [表單發起權限]
FormModel ──► SectionModel ──► DesignerItem ─────────► FormLaunchPermissionModel
                                                              │
                                                              ▼
[資料 / 行為綁定]                                       [條件欄位]
FormDataBindingDraft ◄─ ApiDefinition           ConditionFieldDraft
  ├ SectionDraft                                  └ ConditionFieldDefinition
  ├ FieldDraft                                          │
  └ ActionBindingDraft                                  ▼
                                                  SignOffConditionFieldChoice
                                                  SignOffConditionFieldSummary
                                                              │
[表單填寫]                                                    │
FormRunFieldValue ──► FormSubmissionModel ◄───────────────────┤
                              │                               │
                              ▼                               │
[簽核]                                                        │
LeaveSignOffModel ◄──► SignOffTemplateModel ◄─────────────────┤
  └ SignOffActionRecord       ├ SignOffCanvasNode             │
                              └ SignOffPathRule ──► SignOffPathCondition
```

---

## A. 認證 / 使用者

### `UserModel` — [`lib/model/user_model.dart`](../../../lib/model/user_model.dart)

| 欄位 | 型別 | 用途 |
|------|------|------|
| `id` | `String` | 使用者唯一 ID |
| `email` | `String` | 登入帳號 |
| `displayName` | `String` | 顯示名稱 |

- **用途**：登入後維持的最小使用者識別資料。
- **特性**：Equatable；具 `fromJson` / `toJson`（JSON 風格，非 snake_case）。
- **依賴**：無。

---

## B. 組織架構

### `OrgDepartmentNode` — [`lib/model/org_department_node.dart`](../../../lib/model/org_department_node.dart)

| 欄位 | 型別 | 用途 |
|------|------|------|
| `departmentId` | `String` | 部門唯一 ID |
| `departmentCode` | `String` | 部門代碼 |
| `name` | `String` | 部門名稱 |
| `parentDepartmentId` | `String` | 父部門 ID（組織樹遞迴） |
| `departmentHeadUserId` | `String` | 部門主管 employeeId（部門主管 fallback 第一層） |
| `depthLevel` | `int` | 0=總管理、1=事業群、2=BU、3+ 子部門 |
| `status` | `int` | 狀態（1 為 active） |
| `sortOrder` | `int` | 排序 |
| `createdAt` | `String` | 建立時間 |
| `updatedAt` | `String` | 更新時間 |

- **getter**：`isActive` (`status == 1`)
- **被誰使用**：`OrgDesignConfigModel.departmentNodes`、所有員工 / 簽核解析的部門資料來源。
- **特性**：Equatable；具 `fromMap` / `toMap`，鍵採 snake_case + camelCase 雙向相容。

### `OrgTreeCanvasNode` — [`lib/model/org_tree_canvas_node.dart`](../../../lib/model/org_tree_canvas_node.dart)

| 欄位 | 型別 | 用途 |
|------|------|------|
| `departmentId` | `String` | 對應 `OrgDepartmentNode.departmentId` |
| `offsetDx` | `double` | 組織畫布上節點的 X 座標 |
| `offsetDy` | `double` | 組織畫布上節點的 Y 座標 |

- **用途**：純畫布座標 — 與業務邏輯解耦，僅供 [`org_design_page`](../../../lib/page/org_design/) 拖曳記憶。

### `OrgDesignConfigModel` — [`lib/model/org_design_config_model.dart`](../../../lib/model/org_design_config_model.dart)

| 欄位 | 型別 | 用途 |
|------|------|------|
| `orgId` | `String` | 組織唯一 ID |
| `orgName` | `String` | 組織顯示名稱 |
| `schemaVersion` | `int` | Schema 版本（預設 3） |
| `updatedAt` | `String` | 更新時間 |
| `departmentNodes` | `List<OrgDepartmentNode>` | 部門節點集合 |
| `treeCanvasNodes` | `List<OrgTreeCanvasNode>` | 畫布座標集合 |

- **用途**：整個組織結構的根模型，被 `OrgDesignRepository` 載入 / 儲存。
- **依賴**：`OrgDepartmentNode`、`OrgTreeCanvasNode`

---

## C. 員工與角色

### `EmployeeModel` — [`lib/model/employee_model.dart`](../../../lib/model/employee_model.dart)

| 欄位 | 型別 | 用途 |
|------|------|------|
| `employeeId` | `String` | 員工唯一 ID |
| `employeeCode` | `String` | 員工代碼 |
| `employeeName` | `String` | 員工姓名 |
| `account` | `String` | 登入帳號 |
| `departmentId` | `String` | 隸屬部門 |
| `roleId` | `String` | 角色 ID |
| `roleName` | `String` | 角色顯示名稱 |
| `roleType` | `int` | 0=一般、1=管理級 |
| `status` | `int` | 1=在職、0=離職 |
| `hireDate` | `String` | 入職日期 |
| `leaveDate` | `String` | 離職日期 |
| `createdDate` | `String` | 建立日期 |
| `createdTime` | `String` | 建立時間 |
| `createdBy` | `String` | 建立者 ID |
| `createdByName` | `String` | 建立者姓名 |
| `updatedDate` | `String` | 更新日期 |
| `updatedTime` | `String` | 更新時間 |
| `updatedBy` | `String` | 更新者 ID |
| `updatedByName` | `String` | 更新者姓名 |

- **getter**：`isActive`、`isManagerLevel`（`roleType == 1`，部門主管 fallback 第二層用）
- **被誰使用**：登入身份切換 (`CurrentEmployeeBloc`)、簽核者解析 (`SignOffService`)、發起權限過濾 (`FormLaunchPermissionService._canLaunch`)、代理人指派等。

### `EmpRoleModel` — [`lib/model/emp_role_model.dart`](../../../lib/model/emp_role_model.dart)

| 欄位 | 型別 | 用途 |
|------|------|------|
| `roleId` | `String` | 角色唯一 ID |
| `roleCode` | `String` | 角色代碼 |
| `roleName` | `String` | 角色顯示名稱 |
| `roleType` | `int` | 0=一般、1=管理級 |
| `status` | `int` | 1=啟用 |
| `createdAt` | `String` | 建立時間 |
| `updatedAt` | `String` | 更新時間 |

- **getter**：`isActive`、`isManagerLevel`
- **被誰使用**：表單發起權限的 `allowedRoleIds` 來源；簽核 `designatedRole` 模式選項。

---

## D. 代理人

### `EmpAgentAssignmentModel` — [`lib/model/emp_agent_assignment_model.dart`](../../../lib/model/emp_agent_assignment_model.dart)

| 欄位 | 型別 | 用途 |
|------|------|------|
| `assignmentId` | `String` | 唯一 ID |
| `principalDepartmentId` | `String` | 被代理人（本人）所屬部門 |
| `principalEmployeeId` | `String` | 被代理人（本人）員工 ID |
| `agentDepartmentId` | `String` | 代理人所屬部門 |
| `agentEmployeeId` | `String` | 代理人員工 ID |
| `status` | `int` | 啟用狀態 |
| `createdDate` | `String` | 建立日期 |
| `createdTime` | `String` | 建立時間 |
| `createdBy` | `String` | 建立者 ID |
| `createdByName` | `String` | 建立者姓名 |
| `updatedDate` | `String` | 更新日期 |
| `updatedTime` | `String` | 更新時間 |
| `updatedBy` | `String` | 更新者 ID |
| `updatedByName` | `String` | 更新者姓名 |

- **用途**：簽核代理 — 本人不在時誰代簽。
- **持久化**：snake_case key，LocalStorage 儲存。

### `EmpAgentAssignmentViewModel` — [`lib/model/emp_agent_assignment_view_model.dart`](../../../lib/model/emp_agent_assignment_view_model.dart)

| 欄位 | 型別 | 用途 |
|------|------|------|
| `assignmentId` | `String` | 對應的 EmpAgentAssignmentModel.assignmentId |
| `principalDepartmentName` | `String` | 被代理人部門名稱 |
| `principalEmployeeName` | `String` | 被代理人姓名 |
| `principalEmployeeCode` | `String` | 被代理人員工代碼 |
| `principalRoleName` | `String` | 被代理人角色 |
| `principalEmploymentPeriod` | `String` | 被代理人任職期間字串 |
| `agentDepartmentName` | `String` | 代理人部門名稱 |
| `agentEmployeeName` | `String` | 代理人姓名 |
| `agentEmployeeCode` | `String` | 代理人員工代碼 |
| `agentRoleName` | `String` | 代理人角色 |
| `agentEmploymentPeriod` | `String` | 代理人任職期間字串 |

- **用途**：純顯示用 — 把多個 source 拼接成列表頁可直接渲染的字串。
- **無持久化** — 純記憶體 view model。

### `EmpAgentViewData` — [`lib/model/emp_agent_view_data.dart`](../../../lib/model/emp_agent_view_data.dart)

代理人指派頁的「UI 聚合 state container」：

| 欄位 | 型別 | 用途 |
|------|------|------|
| `departments` | `List<OrgDepartmentNode>` | 部門原始資料 |
| `employees` | `List<EmployeeModel>` | 員工原始資料 |
| `assignments` | `List<EmpAgentAssignmentModel>` | 代理人指派原始資料 |
| `principalDepartmentId` | `String` | 被代理人選中的部門 ID |
| `principalEmployees` | `List<EmployeeModel>` | 被代理人下拉候選 |
| `principalEmployeeId` | `String` | 被代理人選中的員工 ID |
| `selectedPrincipalEmployee` | `EmployeeModel` | 被代理人完整資料 |
| `agentDepartmentId` | `String` | 代理人選中的部門 ID |
| `agentCandidates` | `List<EmployeeModel>` | 代理人下拉候選 |
| `agentEmployeeId` | `String` | 代理人選中的員工 ID |
| `selectedAgentEmployee` | `EmployeeModel` | 代理人完整資料 |
| `assignmentRows` | `List<EmpAgentAssignmentViewModel>` | 已渲染好的列表 |

### `EmpDepBindingViewData` — [`lib/model/emp_dep_binding_view_data.dart`](../../../lib/model/emp_dep_binding_view_data.dart)

「員工-部門綁定」頁的 UI 聚合 state container：

| 欄位 | 型別 | 用途 |
|------|------|------|
| `departments` | `List<OrgDepartmentNode>` | 部門原始資料 |
| `employees` | `List<EmployeeModel>` | 員工原始資料 |
| `selectedDepartmentId` | `String` | 當前選中部門 ID |
| `selectedDepartmentDisplayName` | `String` | 當前選中部門顯示名稱 |
| `focusedEmployeeId` | `String` | 當前 focus 員工 |
| `employeeKeyword` | `String` | 搜尋字串 |
| `selectedDepartmentEmployees` | `List<EmployeeModel>` | 該部門下員工 |
| `filteredEmployees` | `List<EmployeeModel>` | 搜尋過濾後員工 |
| `departmentEmployeeCounts` | `Map<String, int>` | 各部門員工數量 |
| `departmentDisplayNames` | `Map<String, String>` | 部門 ID → 顯示名稱對照 |

> View Data 類別共同特徵：**無 fromMap / toMap，只在 UI / BLoC 內流動**，不持久化。

---

## E. 表單設計

### `FormModel` — [`lib/model/form_model.dart`](../../../lib/model/form_model.dart)

| 欄位 | 型別 | 用途 |
|------|------|------|
| `id` | `String` | 表單唯一 ID |
| `name` | `String` | 表單名稱 |
| `size` | `String` | 螢幕尺寸標籤（如 mobile、tablet） |
| `sectionIds` | `List<String>` | 引用的 SectionModel ID 列表 |

- **持久化**：JSON 風 key（非 snake_case）。
- **被誰使用**：表單清單、表單發起、簽核模板的 `formId` 來源。

### `SectionModel` — [`lib/model/section_model.dart`](../../../lib/model/section_model.dart)

| 欄位 | 型別 | 用途 |
|------|------|------|
| `id` | `String` | 區塊唯一 ID |
| `name` | `String` | 區塊名稱 |
| `description` | `String` | 區塊描述 |
| `items` | `List<DesignerItem>` | 區塊內的元件清單 |

- **用途**：表單的次層容器（一個 form → 多 sections → 多 items）。
- **fromMap**：負責完整還原內含的 `DesignerItem`，is the 完整 form structure persistence entry。

### `DesignerItem` — [`lib/model/designer_item.dart`](../../../lib/model/designer_item.dart)

表單畫布上的單一元件（label / textfield / dropdown / radio / file / date / button 等）。共 30 個欄位：

| 分類 | 欄位 | 型別 | 用途 |
|------|------|------|------|
| 識別 | `id` | `String` | 元件唯一 ID |
| 識別 | `type` | `DesignerItemType` | 元件型別（label/textField/dropdown/radio/file/date/button...） |
| 識別 | `text` | `String` | 顯示文字 / 預設文字 |
| 識別 | `fieldName` | `String` | 欄位名稱（給 binding outputKey 對應） |
| 文字 | `placeholder` | `String` | 提示文字 |
| 文字 | `maxLength` | `int` | 最大字數（0 = 不限） |
| 文字 | `isBold` | `bool` | 是否粗體 |
| 文字 | `inputType` | `TextInputTypeMode` | 鍵盤型別（text/number/email...） |
| 佈局 | `widthPercentage` | `double` | 寬度佔比（0–1） |
| 佈局 | `rowIndex` | `int` | 所屬列 |
| 佈局 | `alignment` | `DesignerItemAlignment` | 對齊方式 |
| 佈局 | `padding` | `double` | 內距 |
| 佈局 | `isGrouped` | `bool` | 是否與下個元件共組 |
| 按鈕 | `buttonWidthMode` | `ButtonWidthMode` | fill / fixed |
| 按鈕 | `buttonWidth` | `double` | fixed 模式的寬度 |
| 按鈕 | `buttonColorHex` | `String` | 背景色 hex |
| 按鈕 | `buttonTextColorHex` | `String` | 文字色 hex |
| 多行 | `textAreaHeight` | `double` | 多行文字框高度 |
| 選項 | `options` | `List<String>` | radio / dropdown 選項 |
| 選項 | `optionLayout` | `DesignerItemOptionLayout` | 垂直 / 水平 |
| 選項 | `optionSpacing` | `double` | 選項間距 |
| 日期 | `dateFormat` | `String` | 日期格式 pattern |
| 字型 | `fontSize` | `double` | 字級 |
| 檔案 | `allowedTypes` | `String` | 允許副檔名（逗號分隔） |
| 檔案 | `maxSize` | `int` | 最大檔案大小（bytes） |
| 驗證 | `required` | `bool` | 是否必填 |
| 驗證 | `readonly` | `bool` | 是否唯讀 |
| 外部資料 | `dataSourceUrl` | `String` | 動態下拉資料來源 URL |
| 外部資料 | `dataSourceKey` | `String` | 對應 ApiDefinition.apiId |
| 條件欄位 | `computedFieldKey` | `String` | 綁定 `ConditionFieldDefinition.fieldKey`，由衍生值取代 text 顯示 |

- **匯出**：透過 `export` 把 `DesignerItemType` / `DesignerItemAlignment` 等多個 enum 一併匯出，外界 import 一檔即可。
- **被誰使用**：FormSectionDesignDraftModel、SectionModel、FormBrowseFieldMeta、FormDataBindingDraft（透過 `outputKey` 對應）。

### `FormSectionDesignDraftModel` — [`lib/model/form_section_design_draft_model.dart`](../../../lib/model/form_section_design_draft_model.dart)

| 欄位 | 型別 | 用途 |
|------|------|------|
| `sectionId` | `String` | Section 唯一 ID |
| `formName` | `String` | 所屬表單名稱（snapshot） |
| `description` | `String` | Section 描述 |
| `rowCount` | `int` | 預設列數 |
| `items` | `List<DesignerItem>` | 元件清單 |

- **用途**：Section 編輯器的 draft 容器 — `formName` 在此屬 section 級的快取，方便獨立編輯。
- **fromMap**：先 normalize 成 `SectionModel.fromMap` 可吃的形態，再轉。

### `FormBrowseFieldMeta` — [`lib/model/form_browse_field_meta.dart`](../../../lib/model/form_browse_field_meta.dart)

```
{ section: SectionModel, item: DesignerItem }
```

- **用途**：表單欄位瀏覽器（dropdown / picker）的 pair 結構 — 同時帶 section 與 item 上下文。
- **無持久化**。

---

## F. 表單資料綁定 + 行為綁定

### `FormDataBindingDraft` — [`lib/model/form_data_binding_draft.dart`](../../../lib/model/form_data_binding_draft.dart)

整份檔案匯出 **5 個 enum + 3 個 class**，是表單資料層的核心。

#### 內部 enum

| Enum | 值 |
|------|---|
| `BindingFieldValueType` | `string` / `number` / `date` / `file` |
| `BindingFieldKind` | `value` / `button` |
| `BindingNullStrategy` | `skip` / `custom` |
| `ActionTriggerType` | `buttonPressed` / `dropdownChanged` / `dropdownLoaded` |
| `ActionType` | `navigate` / `saveDraft` / `submitForm` / `callApi` / `loadDropdownOptions` / `refreshTarget` / `setFieldValue` / `other` |

#### `FormActionBindingDraft` — 行為綁定

| 欄位 | 型別 | 用途 |
|------|------|------|
| `actionId` | `String` | 唯一 ID |
| `sourceItemId` | `String` | 觸發來源元件 ID |
| `sourceLabel` | `String` | 觸發來源元件顯示名 |
| `sourceType` | `String` | 觸發來源元件型別 |
| `triggerType` | `ActionTriggerType` | 觸發類型（buttonPressed/dropdownChanged/dropdownLoaded） |
| `actionType` | `ActionType` | 動作類型（navigate/saveDraft/submitForm/callApi/loadDropdownOptions/refreshTarget/setFieldValue/other） |
| `enabled` | `bool` | 是否啟用 |
| `targetItemId` | `String` | 目標元件 ID（setFieldValue / refreshTarget 用） |
| `targetLabel` | `String` | 目標元件顯示名 |
| `navigateRoute` | `String` | navigate 動作目標路由 |
| `apiId` | `String` | callApi 動作的 API ID |
| `parameterName` | `String` | callApi 動作傳遞參數名 |
| `description` | `String` | 動作說明 |
| `order` | `int` | 同元件多動作排序 |

#### `FormDataBindingFieldDraft` — 欄位綁定

| 欄位 | 型別 | 用途 |
|------|------|------|
| `itemId` | `String` | 對應 DesignerItem.id |
| `label` | `String` | 顯示用 label |
| `fieldName` | `String` | 欄位名稱（debug / fallback） |
| `outputKey` | `String` | 給後端 API 的 key（提交時使用） |
| `sourceType` | `String` | 來源元件型別字串 |
| `fieldKind` | `BindingFieldKind` | value / button |
| `valueType` | `BindingFieldValueType` | string / number / date / file |
| `required` | `bool` | 是否必填 |
| `nullStrategy` | `BindingNullStrategy` | skip / custom |
| `customDefaultValue` | `String` | nullStrategy=custom 時的預設值 |

Getter：
- `displayTypeLabel` — UI 顯示用的型別字串
- `nullStrategyLabel` — 空值策略中文標籤
- `systemDefaultValue` — 系統預設值（依 valueType 推導，date 為今天）

#### `FormDataBindingSectionDraft` — Section 容器

`{ sectionId, sectionName, description, fields: List<FormDataBindingFieldDraft> }`

#### `FormDataBindingDraft` — 根模型

| 欄位 | 型別 | 用途 |
|------|------|------|
| `bindingId` | `String` | 綁定唯一 ID |
| `bindingName` | `String` | 綁定名稱 |
| `bindingDescription` | `String` | 綁定說明 |
| `isEnabled` | `bool` | 是否啟用 |
| `templateVersion` | `int` | 範本版本號 |
| `formId` | `String` | 對應表單 ID |
| `formName` | `String` | 對應表單名稱 |
| `formSize` | `String` | 對應表單尺寸標籤 |
| `updatedAt` | `String` | 更新時間 |
| `sections` | `List<FormDataBindingSectionDraft>` | section + fields |
| `actions` | `List<FormActionBindingDraft>` | 行為綁定 |

Getter / method：
- `totalFields` — 所有 section 內 fields 數量加總
- `totalActions` — actions 數量
- `updateField(sectionId, itemId, transform)` — 巢狀深層欄位更新便利方法

- **用途**：完整描述「表單 → 後端」的資料與行為對映；表單可有多個 binding（一份表單對多個 API 流程）。

### `FormRunFieldValue` — [`lib/model/form_run_field_value.dart`](../../../lib/model/form_run_field_value.dart)

| 欄位 | 型別 | 用途 |
|------|------|------|
| `itemId` | `String` | 對應 DesignerItem.id |
| `outputKey` | `String` | 對應 FieldDraft.outputKey（送出 key） |
| `value` | `String` | 使用者輸入值（字串編碼） |
| `valueType` | `BindingFieldValueType` | 型別資訊 |
| `nullStrategy` | `BindingNullStrategy` | 空值策略 |
| `customDefaultValue` | `String` | nullStrategy=custom 時的預設值 |

Getter：
- `effectiveValue` — 空值時依 nullStrategy 取代為 default

- **用途**：form_run 階段每個欄位的執行時值 — 比 `FormSubmissionModel.fieldValues` 多帶綁定 metadata。

---

## G. API 定義

### `ApiDefinition` — [`lib/model/api_definition.dart`](../../../lib/model/api_definition.dart)

| 欄位 | 型別 | 用途 |
|------|------|------|
| `apiId` | `String` | API 唯一 ID |
| `apiName` | `String` | API 顯示名稱 |
| `method` | `String` | GET / POST 等（預設 `POST`） |
| `path` | `String` | URL path |
| `timeoutMs` | `int` | 逾時毫秒（預設 30000） |
| `headers` | `Map<String, String>` | 自訂 header |

- **用途**：定義可被 form_data_binding 的 `callApi` action 引用的 API；assets 內 `form_button_action_api_sample.json` 即此格式。

---

## H. 表單發起權限

### `FormLaunchPermissionModel` — [`lib/model/form_launch_permission_model.dart`](../../../lib/model/form_launch_permission_model.dart)

| 欄位 | 型別 | 用途 |
|------|------|------|
| `permissionId` | `String` | 唯一 ID |
| `formId` | `String` | 對應的表單 ID |
| `formName` | `String` | 對應的表單名稱 |
| `bindingId` | `String` | 綁定的 FormDataBindingDraft |
| `allowedRoleIds` | `List<String>` | 允許的角色 ID（空 = 不限） |
| `allowedDepartmentIds` | `List<String>` | 允許的部門 ID（空 = 不限） |
| `requireActiveStatus` | `bool` | 是否限制 active 員工（預設 true） |
| `requireManagerRole` | `bool` | 是否限制管理級 |
| `isEnabled` | `int` | 啟用狀態 |
| `createdAt` | `String` | 建立時間 |
| `updatedAt` | `String` | 更新時間 |

- **getter**：`isActive` (`isEnabled == 1`)
- **被誰使用**：`FormApplicationService.loadAvailableForms` 過濾 [`application_create`](../../../lib/page/form_application/application_create/) 的可發起表單；簽核模板 `permissionId` 引用此 model。

---

## I. 條件欄位（Condition Field）

### `ConditionFieldDefinition` — [`lib/model/condition_field_definition.dart`](../../../lib/model/condition_field_definition.dart)

| 欄位 | 型別 | 用途 |
|------|------|------|
| `fieldKey` | `String` | 條件比對 stable key — sign_off path rule 的 `condition.fieldId` 引用此值 |
| `label` | `String` | 顯示用名稱 |
| `outputType` | `ConditionFieldType` (enum) | 計算結果型別 |
| `function` | `ConditionComputeFunction` (enum) | 計算函式（如 `diffDays`、`sum`） |
| `argDesignerItemIds` | `List<String>` | 引數 — 同 form 內 DesignerItem 的 id（v1 不跨 form） |

- **用途**：定義「從一組欄位算出衍生條件值」— 例如「開始 → 結束 → 天數」。
- **被誰使用**：DesignerItem.computedFieldKey 引用；form_run 即時計算；sign_off path rule 條件比對。

### `ConditionFieldDraft` — [`lib/model/condition_field_draft.dart`](../../../lib/model/condition_field_draft.dart)

| 欄位 | 型別 | 用途 |
|------|------|------|
| `formId` | `String` | unique key — 一份 form 對應一份 draft |
| `formName` | `String` | 表單名稱快取 |
| `definitions` | `List<ConditionFieldDefinition>` | 條件欄位定義集 |
| `updatedAt` | `String` | 更新時間 |

---

## J. 簽核相關（索引 — 詳述見 sign_off_models.md）

> 完整欄位與規則請見 [`docs/system_docs/sign_off/sign_off_models.md`](../sign_off/sign_off_models.md)。
> 本節僅列名稱與一行用途，避免重複。

### J.1 模板層

| Model | 檔案 | 用途 |
|-------|------|------|
| `SignOffTemplateModel` | [`sign_off_template_model.dart`](../../../lib/model/sign_off_template_model.dart) | 簽核流程模板 — 一份 form 對應一份 active template |
| `SignOffCanvasNode` | [`sign_off_canvas_node.dart`](../../../lib/model/sign_off_canvas_node.dart) | 流程畫布上的單一節點（一個簽核關卡） |
| `SignOffPathRule` | [`sign_off_path_rule.dart`](../../../lib/model/sign_off_path_rule.dart) | path 路由規則 — 依 condition first-match 決定走哪些節點 |
| `SignOffPathCondition` | [`sign_off_path_condition.dart`](../../../lib/model/sign_off_path_condition.dart) | path rule 的條件表達式（field + operator + value） |

### J.2 條件欄位整合（給簽核 path rule 用）

| Model | 檔案 | 用途 |
|-------|------|------|
| `SignOffConditionFieldChoice` | [`sign_off_condition_field_choice.dart`](../../../lib/model/sign_off_condition_field_choice.dart) | UI 顯示用 — 給編輯器 dropdown 選擇條件欄位 |
| `SignOffConditionFieldSummary` | [`sign_off_condition_field_summary.dart`](../../../lib/model/sign_off_condition_field_summary.dart) | header chip 摘要（status + count） |

### J.3 runtime（執行時）

| Model | 檔案 | 用途 |
|-------|------|------|
| `FormSubmissionModel` | [`form_submission_model.dart`](../../../lib/model/form_submission_model.dart) | 表單送出資料（status: draft / submitted） |
| `LeaveSignOffModel` | [`leave_sign_off_model.dart`](../../../lib/model/leave_sign_off_model.dart) | 簽核資料模型 — 申請 + 流程狀態 + sectionsSnapshot + actionHistory |
| `SignOffActionRecord` | [`sign_off_action_record.dart`](../../../lib/model/sign_off_action_record.dart) | 單筆簽核動作軌跡（approve/reject/returnBack/...） |

**重點 getter**：
- `LeaveSignOffModel.isEditableByApplicant` — 申請人是否可編輯（pending 且未被簽核或被退回）
- `SignOffTemplateModel.isActive` / `isDraft` / `isDisabled`
- `SignOffPathRule.isDefault` — condition 為 null

---

## 統計

| 指標 | 數量 |
|------|------|
| Model 檔案數 | **30** |
| Equatable 採用 | **30 / 30**（全部） |
| 具 `fromMap` / `toMap` 持久化 | **24**（六個純 view data：`EmpAgentAssignmentViewModel`、`EmpAgentViewData`、`EmpDepBindingViewData`、`FormBrowseFieldMeta`、`SignOffConditionFieldChoice`、`SignOffConditionFieldSummary` 無 fromMap） |
| 具 `copyWith` | **25**（純 view data 通常無；getter-only 摘要無） |
| 引用 enum 的 model | 條件欄位、簽核、表單綁定族（各引用 1–4 個 enum） |

## 命名慣例

- **資料模型** → `*Model`（如 `FormModel`、`EmployeeModel`、`LeaveSignOffModel`）
- **草稿（編輯中可被改寫）** → `*Draft`（如 `FormDataBindingDraft`、`ConditionFieldDraft`）
- **顯示用 view model（不持久化）** → `*ViewModel` 或 `*ViewData`
- **元件 / 節點** → `*Item` / `*Node`（如 `DesignerItem`、`OrgDepartmentNode`、`SignOffCanvasNode`）
- **動作 / 紀錄** → `*Record`（如 `SignOffActionRecord`）
- **規則 / 條件** → `*Rule` / `*Condition` / `*Definition`

## 持久化序列化慣例

- **舊員工 / 組織族**（`EmployeeModel`、`EmpRoleModel`、`OrgDepartmentNode`、`EmpAgentAssignmentModel`、`FormLaunchPermissionModel`、`FormSubmissionModel`、`LeaveSignOffModel`、`SignOffActionRecord`）→ map key 採 **snake_case**，fromMap 支援 camelCase 雙向相容。
- **表單設計 / 簽核流程族**（`FormModel`、`SectionModel`、`DesignerItem`、`FormDataBindingDraft`、`SignOffTemplateModel`、`SignOffCanvasNode`、`ApiDefinition`、`OrgDesignConfigModel` 等）→ map key 採 **camelCase**。
- 兩種風格並存因為來源不同（前者模擬資料庫表；後者 LocalStorage JSON）。

## 交叉引用

- 簽核流程設計：[`sign_off_system.md`](sign_off_system.md)
- 簽核 model 詳述：[`sign_off_models.md`](../sign_off/sign_off_models.md)
- 表單發起權限規格：[`permission/form_launch_permission.md`](../permission/form_launch_permission.md)
- 頁面 ↔ 模組對照：[`page_function_mapping.md`](page_function_mapping.md)
