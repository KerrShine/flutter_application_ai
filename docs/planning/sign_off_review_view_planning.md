# 簽核審核檢視功能規劃 — Phase A（純檢視 + 結構快照）

## Context

**為什麼**：
- 已有「我的申請」(`my_application_page`) 與「待我簽核」(`sign_off_pending_page`) 兩個入口，但 submission 點擊後無動作、無詳情頁、無檢視機制
- 簽核流程需要讓「申請人 / 簽核者 / 後續關卡審查者」用同一套機制檢視送出的表單內容
- 表單支援動態欄位（fieldName / type / options / readonly / computedFieldKey），檢視頁不能為單一表單寫死

**目標**：
建立一個**泛用的 submission 唯讀檢視層**，讓任何表單（請假 / 報帳 / 出差 / 後續所有新表單）送出後都能在「我的申請」與「待我簽核」用同一頁面看到內容，且為 Phase B（簽核動作面板）預留擴充點。

**v1 範圍**（已與使用者確認）：
- 渲染方案：**抽離 form_browse 的 readonly 渲染為通用元件層**（不擴 form_run 設計、不自建第三套）
- 結構快照：**submission 送出時存當下 sections 結構**（避免設計變更後舊申請錯位）
- 簽核動作：**純檢視**（同意/拒絕/退回/加簽/補件/轉派 6 種動作延至 Phase B）

---

## 一、現況對照

| 模組 | 狀態 | 路徑 / 備註 |
|---|---|---|
| Form Run 渲染（含 readonly 旗標） | ✅ | `form_run_widget_factory.dart` — TextField/Dropdown/DatePicker 已檢查 `item.readonly` |
| Form Browse readonly 渲染 | ✅ | `form_browse/` 有 `buildReadOnlyWidget()`，但綁設計器 UI（含 property panel） |
| Radio/Checkbox readonly 支援 | ❌ | `ChoiceGroupWidget` 未檢查 readonly（form_run 與 form_browse 都缺） |
| `FormSubmissionModel` 結構快照 | ❌ | 僅存 fieldValues / computedFields |
| Submission 詳情路由 | ❌ | 無 `/home/submission/:id` |
| `my_application_page` 點擊行為 | ❌ | ListTile 缺 `onTap` |
| `sign_off_pending_page` | ⚠️ | 空殼（`SignOffPendingEmptyStateWidget`），v1 維持 |

---

## 二、核心設計

### 2.1 三層架構

```
┌─────────────────────────────────────────────────────┐
│ Layer 3 — 頁面情境                                    │
│  submission_view_page (我的申請點進來)                  │
│  ※ Phase B: submission_review_page (待我簽核點進來)    │
│  ※ form_browse_page 仍為設計器預覽用                    │
└─────────────────────────────────────────────────────┘
              ↓ 共用
┌─────────────────────────────────────────────────────┐
│ Layer 2 — 通用唯讀渲染器                              │
│  lib/widgets/form_readonly/                          │
│    read_only_form_renderer.dart                      │
│    read_only_section_widget.dart                     │
│    read_only_field_widget_factory.dart               │
│  輸入: sections + fieldValues + computedFields       │
│  輸出: 完整唯讀表單 UI                                  │
└─────────────────────────────────────────────────────┘
              ↓ 重用
┌─────────────────────────────────────────────────────┐
│ Layer 1 — 既有資產                                    │
│  SectionModel / DesignerItem (含 readonly / type)    │
│  DynamicFormFieldTheme（樣式）                        │
│  form_browse 既有 buildReadOnlyWidget → 萃取          │
└─────────────────────────────────────────────────────┘
```

### 2.2 通用 ReadOnlyFormRenderer 介面

```dart
class ReadOnlyFormRenderer extends StatelessWidget {
  final List<SectionModel> sections;
  final Map<String, dynamic> fieldValues;
  final Map<String, String> computedFields;
  final EdgeInsets padding;
  // 不接受 onChanged / onSubmit — 唯讀本質
}
```

**設計原則**：
- **無 BLoC、無事件**：純展示元件，呼叫端決定資料來源
- **與表單種類解耦**：給定 sections + values 即可渲染，不論請假/報帳/簽呈
- **欄位型別擴展點集中於 factory**：未來新增 designer item type 只改 factory 一處

### 2.3 ReadOnlyFieldWidgetFactory 欄位涵蓋

| 型別 | v1 渲染方式 |
|---|---|
| `label` | 純文字（支援 `computedFieldKey` 取代顯示，例如「共 N 天」） |
| `textField` | `TextField(readOnly: true)` 顯示值，保留樣式與標籤 |
| `textArea` | 多行 `TextField(readOnly: true)` |
| `dropdown` | `Text` 顯示已選的 label（不渲染 dropdown UI，避免誤點） |
| `radio` | 顯示已選 option 文字 + 「✓」前綴 |
| `checkbox` | 顯示已勾選 options 的逗號串接清單 |
| `datePicker` | `Text` 顯示格式化日期字串 |
| `button` | **隱藏**（按鈕在唯讀模式無意義） |
| `fileUpload` | **顯示「已上傳 N 個檔案」+ 檔名清單**（不提供下載，v1 不涉入檔案儲存） |

### 2.4 結構快照欄位

```
FormSubmissionModel
├── ...既有欄位
└── sectionsSnapshot : List<Map<String, dynamic>>   ← 新增
       (序列化自 List<SectionModel> via toMap())
```

**為什麼選 `List<Map>` 而非 `List<SectionModel>`**：
- Model 層只負責資料容器；反序列化在檢視時才執行，避免 model 互相依賴擴散
- 與 LocalStorage JSON 來回轉換無痛
- 後續換 API/DB 仍直接序列化

---

## 三、需建立 / 修改的檔案

### 3.1 新建（共用層）

```
lib/widgets/form_readonly/
├── read_only_form_renderer.dart         ← 主元件，迭代 sections + 排版
├── read_only_section_widget.dart        ← 單一 section 渲染（含 rowIndex 分行）
└── read_only_field_widget_factory.dart  ← 欄位型別工廠（萃取自 form_browse）
```

### 3.2 新建（submission 檢視頁）

```
lib/page/form_application/submission_view/
├── submission_view_page.dart
├── bloc/
│   ├── submission_view_bloc.dart
│   ├── submission_view_event.dart       ← InitEvent / CompleteStatusEvent / RefreshEvent
│   └── submission_view_state.dart       ← status/message/submission/sections/fieldValues/computedFields
└── widgets/
    └── submission_meta_card_widget.dart ← 顯示 submissionId / applicantName / submittedAt / status
```

### 3.3 修改（既有檔）

| 檔案 | 變更 |
|---|---|
| `lib/model/form_submission_model.dart` | 加 `sectionsSnapshot` 欄位 + copyWith/toMap/fromMap/props |
| `lib/service/form_application_service.dart` | `submitForm()` 新增 `List<SectionModel> currentSections` 參數，序列化為 snapshot 寫入 |
| `lib/service/form_application_service.dart` | 加 `loadSubmissionById(submissionId)` |
| `lib/repositories/interface/form_submission_repository.dart` | 加 `loadById(submissionId)` 介面 |
| `lib/repositories/form_submission_repository_impl.dart` | 實作 `loadById`（既有 storage 中按 submissionId 找） |
| `lib/page/form_design/form_run/bloc/form_run_bloc.dart` | submit handler 把 `state.sections` 一起傳給 service |
| `lib/page/form_application/my_application/widgets/application_submission_section_widget.dart` | ListTile 加 `onTap` → `context.go('/home/submission/$submissionId')` |
| `lib/route/app_router.dart` | 加 `RouteName.submissionViewPage = '/home/submission/:submissionId'` + GoRoute |
| `lib/injection/dependency_injection.dart` | 註冊 `SubmissionViewBloc` |

### 3.4 補強（既有但缺 readonly）

| 檔案 | 變更 |
|---|---|
| `form_run` 的 `ChoiceGroupWidget`（Radio/Checkbox） | 補檢查 `item.readonly` — 唯讀時禁用 onChanged 並視覺降淡 |
| 確保補強不破壞既有 form_run 設計時 readonly 行為（無 readonly 時行為不變） |

---

## 四、SubmissionViewBloc 事件設計

```
SubmissionViewEvent
├── InitEvent(submissionId)             ← 載入單筆 submission + 解析 sectionsSnapshot
├── CompleteStatusEvent()               ← 清 message / 結束 loading
└── RefreshEvent()                      ← 重新載入（給 Phase B 簽核後刷新預留）

SubmissionViewState
├── status: idle / loading / success / failure
├── message: String?
├── submission: FormSubmissionModel?
├── sections: List<SectionModel>       ← 反序列化自 submission.sectionsSnapshot
├── fieldValues: Map<String, dynamic>
└── computedFields: Map<String, String>
```

**載入流程**：
1. `InitEvent(submissionId)` → `service.loadSubmissionById(submissionId)`
2. 反序列化 `submission.sectionsSnapshot` → `List<SectionModel>`
3. emit success(submission, sections, fieldValues, computedFields)
4. Page 用 `BlocBuilder` 把 state 餵給 `ReadOnlyFormRenderer`

**符合 BLoC skill 規則**：
- 所有邏輯由 Event 觸發
- Bloc 只接 Service，不直接調 Repository
- Service 負責「載入 submission + 解快照」業務邏輯

---

## 五、與既有模組銜接

| 既有模組 | 銜接方式 |
|---|---|
| `FormApplicationService` | 加 `loadSubmissionById`、`submitForm` 加 sections 參數 |
| `FormSubmissionRepository` | 既有 save / loadByApplicantId 不變，加 `loadById(submissionId)` |
| `MyApplicationPage` | ListTile 點擊 → `context.go('/home/submission/$submissionId')` |
| `FormRunPage` 送出流程 | 送出 event 帶上 `state.sections` → service 序列化進 snapshot |
| `SignOffPendingPage` | v1 維持空殼；Phase B 實作 list + 點擊也導同一個 submission_view（或新建 review 版） |
| `form_browse_page` 設計時預覽 | v1 不重構；Phase B 後可選改用 `ReadOnlyFormRenderer` 消除重複 |

---

## 六、建議開發順序

```
Phase A — Submission 唯讀檢視 + 結構快照
├── A1. 共用唯讀層
│   ├── 1.1 ReadOnlyFieldWidgetFactory（萃取 form_browse 邏輯 + 補 Radio/Checkbox）
│   ├── 1.2 ReadOnlySectionWidget（rowIndex 分行排版）
│   └── 1.3 ReadOnlyFormRenderer（容器，迭代 sections）
├── A2. FormSubmissionModel 結構快照
│   ├── 2.1 加 sectionsSnapshot 欄位 + copyWith / toMap / fromMap / props
│   ├── 2.2 FormApplicationService.submitForm 加 sections 參數，序列化寫入
│   └── 2.3 FormRunBloc submit handler 傳 state.sections 進 service
├── A3. Submission 載入鏈
│   ├── 3.1 FormSubmissionRepository loadById(submissionId)
│   └── 3.2 FormApplicationService loadSubmissionById
├── A4. SubmissionViewPage + Bloc
│   ├── 4.1 Event / State / Bloc 三檔
│   ├── 4.2 SubmissionMetaCardWidget
│   └── 4.3 Page UI（ApplicationHeaderWidget + Meta Card + ReadOnlyFormRenderer）
├── A5. 路由 + DI 註冊
│   ├── 5.1 RouteName.submissionViewPage
│   ├── 5.2 GoRoute with submissionId path param
│   └── 5.3 sl.registerFactory<SubmissionViewBloc>
└── A6. my_application 點擊導向
    └── 6.1 ListTile.onTap → context.go(...)

【驗收】v1 結束時：
- 任何已送出的 submission，從「我的申請」點進去可看完整內容
- 表單設計變更後，舊申請仍正確顯示送出當下的欄位結構
- flutter analyze --no-pub 0 errors
```

**Phase B（不在 v1 範圍，僅列出後續路線）**：
- 簽核流程模板引擎（sign_off_editor_page → workflow 模板資料模型 + service.resolveApproverChain）
- SubmissionReviewPage（或於 submission_view_page 加 mode 參數：viewer / reviewer）
- 簽核動作面板（同意/拒絕/退回/加簽/補件/轉派）
- sign_off_pending 真實清單接入

---

## 七、技術一致性

| 面向 | 既有模式 | Phase A 沿用 |
|---|---|---|
| State management | BLoC + Equatable | ✅ SubmissionViewBloc 同模式 |
| Storage | LocalStorage / Repository | ✅ FormSubmissionRepository 加 loadById |
| Navigation | GoRouter + RouteName | ✅ 新增 RouteName 常數 |
| Theme | ThemeExtension + ThemeColors | ✅ ReadOnlyForm 沿用 DynamicFormFieldTheme |
| DI | get_it sl.registerFactory | ✅ |
| UI Pattern | ApplicationHeaderWidget + Shell | ✅ submission_view_page 用相同頁首 |
| BLoC skill | Event 觸發 / Bloc 只接 Service / 業務邏輯在 Service | ✅ loadSubmissionById 與 sections 反序列化都在 service |

---

## 八、驗證

1. **編譯**：`flutter analyze --no-pub` 回報 0 errors
2. **送出→檢視 golden path**：
   - 在 form_run 送出一張請假表單
   - 至「我的申請」看到新一筆 → 點擊 → 進 submission_view_page
   - 確認所有欄位（label / textField / dropdown / datePicker / radio / checkbox）正確顯示送出值
3. **結構快照測試**：
   - 送出 submission → 至 form_create_page 修改表單（刪一個欄位）→ 回我的申請點原 submission
   - 應顯示**送出當下**的完整欄位結構，不受設計變更影響
4. **唯讀互動**：
   - 點 dropdown 不展開、點 button 不渲染、TextField 不能編輯、Radio/Checkbox 無法切換
5. **DateRange / Computed Label**：
   - 開始/結束日期 + 「共 N 天」computed label 仍正常顯示

---

## 九、待確認事項

- [ ] **「我的申請」與「待我簽核」是否共用同一個 submission_view_page？**
      建議方案 — 是，v1 只用 viewer 模式（即「我的申請」入口）；Phase B 在同頁加 `mode` 參數區分 viewer / reviewer，避免兩頁邏輯重複。

- [ ] **submission 列表是否一併顯示 sectionsSnapshot 摘要？**
      建議方案 — 否，列表只顯示 formName / submittedAt / status，摘要留給詳情頁，避免列表 query 拖慢。

- [ ] **是否同步重構 form_browse_page 改用 ReadOnlyFormRenderer 消除重複？**
      建議方案 — Phase A 不重構（避免影響設計器穩定性），Phase B 完成後再評估。

- [ ] **Header actions 是否提供「匯出此筆 JSON」按鈕？**
      建議方案 — 否，現有「我的申請」頁已有整批匯出；單筆匯出留給 Phase B 簽核軌跡需要時再加。

- [ ] **檔案上傳欄位的顯示細節**：
      建議方案 — 顯示「已上傳 N 個檔案」+ 檔名清單，不提供下載按鈕（v1 不涉入檔案儲存層）。

---

## 不在範圍

- 簽核動作面板（同意/拒絕/退回/加簽/補件/轉派）
- sign_off_pending 真實清單
- 簽核流程模板引擎與條件路由（path rules）
- 檔案上傳欄位的下載/預覽
- 列表頁的查詢/篩選功能
- form_browse_page 的同步重構

---

## 十、實際完成項目（vs 原計畫）

對照 Phase A 計畫的 6 個步驟（A1-A6）：

| 計畫 | 實際 | 重要差異 |
|---|---|---|
| A1 共用唯讀層 | ✅ 完成 | 位置從原計畫 `lib/widgets/form_readonly/` 改到 `lib/page/form_design/form_readonly/` |
| A2 FormSubmissionModel.sectionsSnapshot | ✅ 改用 LeaveSignOffModel | 決策：避免 FormSubmissionModel / LeaveSignOffModel 雙重維護，sectionsSnapshot 直接放在 LeaveSignOffModel |
| A3 loadSubmissionById | ✅ 完成（loadSignOffById） | 同 A2 改用 LeaveSignOffModel |
| A4 submission_view_page | ✅ 完成 | 含 bloc / event / state / SubmissionMetaCardWidget |
| A5 路由 + DI | ✅ 完成 | `/home/submission/:signOffId` |
| A6 my_application 點擊導向 | ✅ 完成 | Card.onTap + 編輯 IconButton（pending only） |

---

## 十一、Phase A 後續演進（超出原計畫範圍）

實作過程中加入的功能：

### 1. form_run 編輯模式

Pending status 可從詳情頁 / 列表卡進入編輯：
- 新增 `FormRunService.executeUpdateSignOff`（by-id 替換、保留 signOffId / submittedAt、更新 updatedAt + sectionsSnapshot）
- `FormRunInitEvent` 加 signOffId 參數、AppBar 顯示「編輯模式」橙 chip
- 限制：只有 `status == pending` 可編輯（service 層攔截，回 failure「此申請已進入流程，無法編輯」）
- 結構策略：用當前最新 form 設計（不用舊 snapshot）— itemId 不匹配的舊值丟棄

### 2. SignOffStatusWidget — 詳情頁第二區

[lib/page/form_application/submission_view/widgets/sign_off_status_widget.dart](lib/page/form_application/submission_view/widgets/sign_off_status_widget.dart)

- **整體狀態 / 目前簽核者 / 最新意見** 三張 stat card
- **完整簽核流程** chain section：呼叫 `resolveApproverChain` 顯示所有簽核關卡 + 當前進度標記（已完成 ✓ / 進行中 / 待處理）
- **簽核軌跡** history section：顯示 actionHistory list（Phase B 接入動作後生效）
- 風格參照 form_launch_permission_editor 的 sidebar pattern

### 3. templateId 串接

- `LeaveSignOffModel` 加 `templateId` 欄位 + 序列化
- 測試寫入時 `FormRunService._resolveActiveTemplateId(formId)` 自動找 active 模板（fallback 取第一筆）
- `FormApplicationService.resolveSignOffChain(signOff)` 串接 `SignOffService.resolveApproverChain`
- `SubmissionViewBloc` init 後 state 攜帶 `List<ResolvedApprover> resolvedChain`
- 詳情頁顯示「[簽核者名稱]｜[節點描述]」格式

### 4. 部門主管 fallback — `SignOffService._resolveDepartmentManager`

兩層 fallback：
- **L1**：優先 `dept.departmentHeadUserId`（組織管理頁明確指定）
- **L2**：為空時掃描部門員工，找 `EmployeeModel.isManagerLevel`（roleType==1）的第一個

與 `emp_dep_employee_card_widget` 一致 — 主管身份由員工自身 roleType 決定。套用範圍：
- `hierarchyManager`
- `crossLevel`（同層互簽找目標部門主管）
- `applicantAncestorManager`（申請人上 N 層主管）
- `applicantManagerAtDepth`（申請人指定 depth 主管）

### 5. 簽核 model 擴充

| 新增 | 路徑 |
|---|---|
| `LeaveSignOffStatus` enum | [lib/enum/leave_sign_off_status.dart](lib/enum/leave_sign_off_status.dart) — pending / inReview / approved / rejected / withdrawn |
| `SignOffActionType` enum | [lib/enum/sign_off_action_type.dart](lib/enum/sign_off_action_type.dart) — approve / reject / returnBack / requestSupplement / transfer / addApprover |
| `SignOffActionRecord` model | [lib/model/sign_off_action_record.dart](lib/model/sign_off_action_record.dart) — recordId / actionType / approverId / approverName / comment / actionAt / targetRef |
| `LeaveSignOffModel.actionHistory` | [lib/model/leave_sign_off_model.dart](lib/model/leave_sign_off_model.dart) — `List<SignOffActionRecord>` |

### 6. UI / Theme 增強

- `FormApplicationThemeColors` 擴 8 個欄位：inReviewIcon / withdrawnIcon / cardBackground / cardBorder / listTitleText / listSubtitleText / chipBackground（+ 對應 light/dark）
- meta card 新增 4 列（依 sectionsSnapshot label 關鍵字動態找）：開始日期 / 結束日期 / 請假天數 / 代理人
- 我的申請列表卡片視覺升級（圓角卡 + 狀態 chip + 編輯 icon）
- 匯出單筆 JSON 按鈕（SubmissionViewPage AppBar code icon）
- form_run 編輯模式 chip 橙色徽章

### 7. API 動作分流（測試寫入特例）

- `assets/form_button_action_api_sample.json` 加 `test_write_to_storage_api` 條目（method=LOCAL_STORAGE）
- `api_picker_dialog` 用紫色徽章 + 🧪 圖示 + 「測試工具」section header 將測試類 API 與正式 API 視覺隔開
- form_run_bloc 偵測 apiId == `test_write_to_storage_api` 走特例分支：呼叫 `executeTestWriteSignOff` 構造 LeaveSignOffModel 寫入 LocalStorage
- applicantId / Name / departmentId 從 CurrentEmployeeBloc 帶入

### 8. 共用唯讀層搬遷

- 從 `lib/widgets/form_readonly/` 移到 [lib/page/form_design/form_readonly/](lib/page/form_design/form_readonly/)
- 三檔：read_only_form_renderer / read_only_section_widget / read_only_field_widget_factory
- 真正唯讀（Container + Text，非 `TextField enabled:false`）— 修正視覺一致性與 4px 溢出

---

## 十二、目前已知缺口（未來方向）

- **Phase B：簽核動作面板** — 同意 / 拒絕 / 退回 / 補件 / 轉派 / 加簽 6 種動作 UI 與 service 邏輯
- **Phase B：actionHistory 寫入機制** — 目前 list 永遠為空，需在簽核動作執行時 append
- **Phase B：sign_off_pending_page 真實清單** — 目前空殼，需依 `resolveApproverChain` 結果反查當前簽核者，列出該登入者待簽筆
- **Phase B：currentApproverId / Name 自動寫入** — 送出時依鏈寫入第一關，簽核完成後推進至下一關
- **模板版本控制** — 編輯簽核流程模板後既有 signOff 是否套新版？（v1 用送出當下的 templateId 凍結，需明確策略）
- **L2 fallback 多主管** — 部門有多個 isManagerLevel 員工時目前只取第一個，未來可考量會簽策略



