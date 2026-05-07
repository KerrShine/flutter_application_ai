# 簽核設定（Sign Off）規劃 — 畫布拖曳式流程設計

> ⚠️ **回來開發前先讀**：[sign_off_implementation_status.md](sign_off_implementation_status.md)
> — Phase A 已完成範圍、節點欄位「設定 vs 真實功能」audit、Phase B 待實作清單、容易混淆的點。
> 避免把「設定欄位」誤當「已實作功能」。

## 規劃背景

### 已完成項目總覽

| 子系統 | 模組 | 狀態 |
|--------|------|------|
| 動態表單屬性 | 組織規劃、職員設定、代理人、表單設計、欄位綁定、事件綁定 | ✅ 完成 |
| 權限設置 | 表單發起權限（form_launch_permission） | ✅ 完成 |
| **權限設置** | **設定簽核邏輯 → 簽核級別（本文件規劃）** | ❌ 待開發 |
| 發起 / 執行簽核 | 申請中心、簽核任務、審批動作 | ❌ 待開發 |
| 歸檔 / 報表 | 歸檔列表、報表顯示 | ❌ 待開發 |

### 流程位置

```
表單建立 ✅ → 資料連結 ✅ → 發起權限 ✅ → 簽核設定 ← 目前位置 → 執行簽核 → 歸檔
```

### 入口位置

首頁側邊欄 Drawer →「簽核設定」群組（目前為 placeholder）→ 新增「簽核流程」子項目

```
home_page.dart 既有結構：
  ExpansionTile('簽核設定')
    └── ListTile('項目')   ← 改為「簽核流程」並串接 RouteName.signOffManagerPage
```

---

## 一、要解決什麼問題

### 1.1 三種簽核流向

| 流向 | 情境 | 範例 |
|------|------|------|
| **垂直向上** | 子層級往父層級送 | 員工 → 組長 → 部門主管 → 事業群主管 → 總經理 |
| **同層級互送** | 跨部門但同層級的審核 | 事業發展組 → 行政支援中心 |
| **跨業務線** | 不在組織直線上的部門參與審核 | 採購單需 HR 與 Finance 會簽 |

### 1.2 操作體驗

採畫布拖曳式設計：從左側「組織架構面板」拖曳部門到中央畫布，自動依組織父子關係連線，視覺化完整簽核流向；同層互簽於右側屬性面板手動設定。

---

## 二、釐清模糊地帶

> **重要釐清：** 架構圖中「設定簽核邏輯 → 發起設定」與既有「表單發起權限」是同一功能。
>
> 對照 `docs/system_docs/system/sign_off_system.md` 的「建立簽核流程模板」章節，模板包含兩部分：
> - **發起資格（權限相關）** — 即既有 `form_launch_permission`，本計畫不重做，只引用
> - **流程節點定義** — 即「簽核級別」，本計畫實作
>
> 在簽核流程編輯器中，「發起設定」步驟以 Tab 形式引用既有 `FormLaunchPermissionModel`，唯讀展示 + 跳轉編輯既有權限。

---

## 三、核心設計

### 3.1 簽核人來源模式（SignOffApproverMode）

| 模式 | 識別碼 | 解析依據 | 解決流向 | 綁定 |
|------|--------|---------|---------|------|
| 此部門主管 | `hierarchyManager` | 拖曳到畫布的部門其主管 | 垂直向上（拖曳預設） | 絕對 |
| 同層互簽 | `crossLevel` | 指向另一個畫布節點 | 同層級互送 | 絕對 |
| 指定角色 | `designatedRole` | 預先指定的 `roleId` 持有者 | 跨業務線 | 絕對 |
| 指定員工 | `designatedEmployee` | 預先指定的 `employeeId` | 固定簽核人 | 絕對 |
| **申請人本人** | `applicantSelf` | 執行時直接帶入申請人 | 補件 / 確認 | **相對申請人** |
| **申請人上 N 層主管** | `applicantAncestorManager` | 申請人所屬部門沿 `parentDepartmentId` 走 `applicantAncestorOffset` 步取主管 | 通用「向上 N 層」 | **相對申請人** |
| **申請人指定層級主管** | `applicantManagerAtDepth` | 沿 parent 鏈往上找第一個 `depthLevel == applicantTargetDepthLevel` 的祖先部門主管 | 跨不對稱組織樹的 BU / 事業群 / 總管理 | **相對申請人** |

> **絕對 / 相對的差異：**
> - 絕對位置：節點綁定具體 `departmentId`，所有申請人走同一條鏈
> - 相對位置：節點不綁部門，執行時依申請人動態解析；一張模板可服全公司（如請假流程）
> - 兩類可在同一張模板混用（例如「請假向上 N 層 + 採購會簽 HR」）

> **不對稱組織樹：** `applicantAncestorManager`（相對步數）在 BU3 (4 層) vs BU5 (3 層) 這種樹深度不一致時，無法穩定指向同一個邏輯角色（如「BU 主管」）。改用 `applicantManagerAtDepth`（絕對 depthLevel）即可解決，因為 depthLevel 在全公司有一致的組織意義（0=總管理、1=事業群、2=BU、3+=子部門）。

### 3.2 節點類型（SignOffNodeType）

| 類型 | 識別碼 | 行為 |
|------|--------|------|
| 審核 | `approve` | 單一節點，一人決策（同意/拒絕/退回） |
| 會簽 | `countersign` | 多人決策，依 `multiStrategy` 收斂 |
| 知會 | `notify` | 只通知不影響流程，留痕 |

> 條件分支（`condition`）v1 不實作，移至「待確認事項」。

### 3.3 會簽多人策略（SignOffMultiStrategy）

- `all` — 全部同意（AND）
- `any` — 任一同意（OR）
- `sequential` — 依序簽核

### 3.4 退回策略（SignOffReturnPolicy）

- `toApplicant` — 退回申請人
- `toPrevious` — 退回上一關
- `toSpecific` — 退回指定關卡（指定 nodeId）

### 3.5a Path Rules（條件式路由）

**問題**：線性流程無法表達「請 1 天 vs 請 1 個月」這類**依表單值決定走哪幾關**的情境。

**設計**：申請起點（origin）變成 path router，模板加 `pathRules`：
- 每條規則 = 名稱 + 條件（field + operator + value）+ 啟用 nodeIds
- First-match：依 sortOrder 評估，第一個命中即用
- 無命中 → fallback 全部節點啟用（向後相容；舊模板無 rules 行為不變）
- Default rule：condition = null 永遠 match，通常排最後

**Operator 範圍**：
| fieldType | 可用 |
|-----------|------|
| number | `==, !=, >, >=, <, <=, between` |
| string | `==, !=, contains` |
| date | `==, !=, >, >=, <, <=, between` |

**fieldId 語意**：condition.fieldId = **form_condition_field 定義的 fieldKey**（不是 DesignerItem.id 或 form_data_binding outputKey），與條件比對用 key 一致。
依賴：表單必須先在「表單條件欄位」定義 fieldKey + 計算公式才能設條件 — UI 上未定義時顯示 banner + 跳轉連結。

完整模組設計見 [form_condition_field_planning.md](form_condition_field_planning.md)。

**範例（請假）**：
```
Origin pathRules:
  Rule 1 「短假」: 請假天數 <= 7  → [Node1, Node2]
  Rule 2 「中假」: 請假天數 <= 30 → [Node1, Node2, Node3]
  Rule 3 default               → [Node1~4]
```

申請 1 天 → Rule 1 → 跑 2 關  
申請 60 天 → fallthrough → 跑 4 關

**規則預覽**：編輯器 header 加「規則預覽」toggle，輸入假設表單值，canvas 即時暗化非啟用節點。

### 3.5 完整流程範例

> 申請人：事業發展組 員工A
>
> 1. **Node 1** — 此部門主管（事業發展組） → 組長
> 2. **Node 2** — 此部門主管（事業發展中心） → 中心主任
> 3. **Node 3** — 此部門主管（行政支援中心） → 跨部門簽核（同層級互送 from Node 2）
> 4. **Node 4** — 指定角色（HR） → HR 主管（會簽）
> 5. **Node 5** — 此部門主管（總管理） → 總經理

---

## 四、資料模型

### 4.1 SignOffTemplateModel（簽核流程模板）

```
SignOffTemplate
├── templateId          : String
├── formId              : String       — 對應表單
├── permissionId        : String       — 引用既有 form_launch_permission
├── name                : String       — 流程名稱
├── status              : String       — draft / active / disabled
├── canvasNodes         : List<SignOffCanvasNode>
├── canvasTransform     : List<double>?    — Matrix4.storage（縮放/平移狀態）
├── version             : int
└── createdAt / updatedAt
```

### 4.2 SignOffCanvasNode（畫布節點）

```
SignOffCanvasNode
├── nodeId                    : String
├── departmentId              : String?      — 引用組織部門 ID（拖曳來源）；相對 mode 時為空
├── offsetDx                  : double       — 畫布 X 座標
├── offsetDy                  : double       — 畫布 Y 座標
├── sortOrder                 : int          — 簽核順序（申請起點固定 0，其他依拖入順序遞增）
├── isApplicantOrigin         : bool         — 是否為申請起點
├── nodeType                  : SignOffNodeType
├── approverMode              : SignOffApproverMode
├── crossLevelTargetNodeId    : String?      — 同層互簽目標 nodeId
├── designatedRoleId          : String?
├── designatedEmployeeId      : String?
├── multiStrategy             : SignOffMultiStrategy?
├── returnPolicy              : SignOffReturnPolicy
├── returnTargetNodeId        : String?
├── allowAddSigner            : bool         — 加簽（v2 預設 false）
├── slaDays                   : int          — 簽核期限天數（0 = 不限期，僅 approve/countersign 用）
├── applicantAncestorOffset   : int          — 相對申請人「上 N 層」的層數（僅 applicantAncestorManager 用）
└── applicantTargetDepthLevel : int          — 申請人指定組織層級（depthLevel；僅 applicantManagerAtDepth 用）
```

```
SignOffPathRule
├── ruleId
├── name                  : 規則名稱
├── condition             : SignOffPathCondition?（null = default rule）
├── activatedNodeIds      : 命中時要啟用的 nodeId 清單
└── sortOrder             : first-match 評估順序

SignOffPathCondition
├── fieldId               : form_condition_field 的 fieldKey（穩定 key + 計算邏輯來源）
├── fieldName             : 顯示用 snapshot
├── fieldType             : number / string / date
├── operator              : ==, !=, >, >=, <, <=, between, contains
├── value                 : 字串編碼
└── valueMax              : between 用
```

### 4.3 連線（不獨立儲存）

連線由節點屬性派生：
- 垂直連線：依 `OrgDepartmentNode.parentDepartmentId` 計算
- 同層互簽連線：依 `crossLevelTargetNodeId` 計算

---

## 五、需新增的模組

### 5.1 sign_off_manager — 流程模板列表

**定位：** 顯示所有已建立的簽核流程模板。

| 功能 | 說明 |
|------|------|
| 流程清單 | 卡片：表單名稱 + 流程名稱 + 節點數 + 狀態 |
| 新增 / 編輯 / 刪除 | 標準 CRUD |
| 啟用切換 | draft / active / disabled |
| 匯出 JSON | 匯出所有模板 |

**路由：** `/home/sign-off/sign-off-manager`

### 5.2 sign_off_editor — 畫布拖曳編輯器

**定位：** 視覺化設定簽核流程，依組織架構自動串連。

**版面：頂部 Tab 切換**

| Tab | 內容 |
|-----|------|
| **發起設定** | 引用既有 `FormLaunchPermissionModel`（唯讀展示 + 「前往編輯權限」按鈕跳轉至既有編輯器） |
| **簽核級別** | 三欄畫布拖曳編輯器 |

**簽核級別 Tab 三欄結構：**

| 區塊 | 對應 widget | 功能 |
|------|------------|------|
| 左欄 | `sign_off_org_source_panel_widget.dart` | 組織架構來源面板（樹狀展開、搜尋、Draggable） |
| 中央 | `sign_off_canvas_panel_widget.dart` | 拖曳畫布（InteractiveViewer + DragTarget + ConnectionPainter） |
| 右欄 | `sign_off_node_property_panel_widget.dart` | 節點屬性面板 |

**路由：** `/home/sign-off/sign-off-manager/editor`

### 5.3 SignOffService（業務邏輯層）

| 方法 | 說明 |
|------|------|
| `loadAllTemplates()` | 載入所有流程模板 |
| `loadByFormId(formId)` | 取得特定表單的流程模板 |
| `saveTemplate(template)` | 建立或更新模板 |
| `deleteTemplate(templateId)` | 刪除模板 |
| `resolveApproverChain(templateId, applicantId)` | 解析特定申請人的完整簽核鏈 |
| `validateTemplate(template)` | 驗證流程合法性（無循環、有起點、有終點） |

---

## 六、與現有模組的銜接

| 現有模組 | 銜接方式 |
|----------|---------|
| `form_launch_permission` | 提供「發起資格」設定，被流程模板引用 |
| `org_design` | 提供部門樹，作為左欄拖曳來源；解析向上層級時使用 |
| `org_tree_design` | **複用其畫布、連線、拖曳的設計模式**（參考 `lib/page/org_design/org_tree_design/`） |
| `emp_info` | 解析簽核人時使用（含部門主管、指定員工） |
| `emp_role` | 指定角色簽核時使用 |
| `emp_agent` | 後續整合代理人機制（v2） |
| `home_page` 側邊欄 | 「簽核設定」placeholder 改為「簽核流程」並串接路由 |

### 與 org_tree_design 的差異

| 項目 | org_tree_design | sign_off_editor |
|------|----------------|-----------------|
| 節點意義 | 組織部門本體 | 簽核關卡（每個關卡指向部門/角色/員工） |
| 連線意義 | 組織父子關係 | 簽核流向 |
| 連線建立 | 屬性面板選父部門 | **拖曳時自動依組織關係連線** |
| 額外連線 | 無 | 同層互簽（藍色虛線、雙向） |
| 節點屬性 | 部門資料 | 節點類型 / 簽核人模式 / 退回策略 |

---

## 七、檔案結構

```
lib/
├── enum/
│   ├── sign_off_node_type.dart           — SignOffNodeType enum
│   ├── sign_off_approver_mode.dart       — SignOffApproverMode enum
│   ├── sign_off_multi_strategy.dart      — SignOffMultiStrategy enum
│   └── sign_off_return_policy.dart       — SignOffReturnPolicy enum
│
├── model/
│   ├── sign_off_template_model.dart
│   └── sign_off_canvas_node.dart
│
├── repositories/
│   ├── interface/
│   │   └── sign_off_repository.dart
│   └── sign_off_repository_impl.dart     — LocalStorage 持久化
│
├── service/
│   └── sign_off_service.dart             — 含 resolveApproverChain
│
├── theme/
│   └── sign_off_theme_colors.dart        — ThemeExtension（畫布 + 節點 + 連線色）
│
└── page/sign_off/
    ├── sign_off_manager/
    │   ├── sign_off_manager_page.dart
    │   ├── bloc/
    │   │   ├── sign_off_manager_bloc.dart
    │   │   ├── sign_off_manager_event.dart
    │   │   └── sign_off_manager_state.dart
    │   └── widgets/
    │       ├── sign_off_manager_header_widget.dart
    │       └── sign_off_manager_list_widget.dart
    │
    └── sign_off_editor/
        ├── sign_off_editor_page.dart
        ├── bloc/
        │   ├── sign_off_editor_bloc.dart
        │   ├── sign_off_editor_event.dart
        │   └── sign_off_editor_state.dart
        └── widgets/
            ├── sign_off_editor_launch_permission_tab_widget.dart   — 發起設定 Tab
            ├── sign_off_editor_levels_tab_widget.dart              — 簽核級別 Tab 容器
            ├── sign_off_org_source_panel_widget.dart               — 左欄
            ├── sign_off_canvas_panel_widget.dart                   — 中央畫布
            ├── sign_off_node_property_panel_widget.dart            — 右欄
            └── units/
                ├── sign_off_node_card.dart
                ├── sign_off_connection_painter.dart
                ├── sign_off_grid_painter.dart
                ├── sign_off_zoom_controls.dart
                ├── sign_off_approver_mode_selector.dart
                └── sign_off_cross_level_target_picker.dart
```

---

## 八、BLoC 事件設計（編輯器）

| 事件 | 說明 |
|------|------|
| `InitSignOffEditorEvent({String? templateId})` | 載入流程模板與組織資料 |
| `SelectFormEvent(String formId)` | 選取表單，過濾組織架構與權限 |
| **拖曳相關** | |
| `SelectAvailableDepartmentEvent(String departmentId)` | 標記來源面板選中項目 |
| `DropDepartmentToCanvasEvent(String departmentId, double dx, double dy)` | 拖曳到畫布，自動連線父層 |
| `MoveCanvasNodeEvent(String nodeId, double deltaDx, double deltaDy)` | 拖動畫布節點 |
| `ConfirmAutoFillParentChainEvent(String departmentId, bool accept)` | 確認自動補父層 |
| `RemoveCanvasNodeEvent(String nodeId)` | 刪除畫布節點 |
| **節點屬性** | |
| `SelectCanvasNodeEvent(String nodeId)` | 選取畫布節點，顯示屬性 |
| `UpdateNodeTypeEvent(String nodeId, SignOffNodeType type)` | 修改節點類型 |
| `UpdateApproverModeEvent(String nodeId, SignOffApproverMode mode)` | 修改簽核人模式 |
| `SetCrossLevelTargetEvent(String nodeId, String targetNodeId)` | 設定同層互簽目標 |
| `UpdateMultiStrategyEvent(String nodeId, SignOffMultiStrategy strategy)` | 修改會簽策略 |
| `UpdateReturnPolicyEvent(String nodeId, SignOffReturnPolicy policy)` | 修改退回策略 |
| `MarkAsApplicantOriginEvent(String nodeId)` | 標記為申請起點 |
| **畫布操作** | |
| `SyncCanvasTransformEvent(List<double> values)` | 同步縮放/平移狀態 |
| `ZoomInCanvasEvent` / `ZoomOutCanvasEvent` / `CenterCanvasEvent` | 縮放控制 |
| **儲存** | |
| `SaveTemplateEvent` | 驗證並儲存模板 |
| `PreviewApproverChainEvent(String employeeId)` | 模擬解析簽核鏈 |

---

## 九、建議開發順序

```
Phase A — 簽核設定（本計畫範圍）
  ├── A1: Enums + Models + Repository
  │     ├── SignOffNodeType / SignOffApproverMode / SignOffMultiStrategy / SignOffReturnPolicy
  │     ├── SignOffTemplateModel / SignOffCanvasNode
  │     └── SignOffRepository + LocalStorage 實作
  │
  ├── A2: Service 業務邏輯
  │     ├── CRUD 流程模板
  │     ├── resolveApproverChain（核心解析）
  │     └── validateTemplate（合法性檢查）
  │
  ├── A3: Theme + DI 註冊
  │     ├── SignOffThemeColors ThemeExtension（畫布 + 節點 + 連線色）
  │     ├── 在 lib/theme/theme.dart 註冊
  │     └── 在 lib/injection/dependency_injection.dart 註冊 Repository / Service / BLoC
  │
  ├── A4: 流程模板列表頁（sign_off_manager）
  │     ├── A4.1 BLoC + State
  │     ├── A4.2 Header + List 卡片清單
  │     └── A4.3 CRUD / 啟用切換 / 匯出
  │
  ├── A5: 畫布拖曳編輯器（sign_off_editor）
  │     ├── A5.1 三欄 Scaffold + Tab 切換
  │     ├── A5.2 發起設定 Tab（引用既有 form_launch_permission）
  │     ├── A5.3 左欄組織來源面板（複用 org_tree_source 模式）
  │     ├── A5.4 中央畫布
  │     │     ├── InteractiveViewer + DragTarget
  │     │     ├── 自動連線父層邏輯（DropDepartmentToCanvasEvent）
  │     │     ├── ConnectionPainter（垂直 + 同層互簽兩種樣式）
  │     │     └── 節點卡片 + 縮放控制
  │     ├── A5.5 右欄屬性面板
  │     │     ├── 節點類型切換
  │     │     ├── 簽核人模式選擇（含同層互簽 picker）
  │     │     ├── 多人策略 + 退回策略
  │     │     └── 申請起點標記
  │     └── A5.6 儲存與驗證
  │
  └── A6: Drawer 整合
        ├── 修改 lib/page/home/home_page.dart 「簽核設定」ExpansionTile
        ├── 將「項目」改為「簽核流程」
        └── onTap 串接 RouteName.signOffManagerPage
```

每個葉節點步驟可獨立驗證（compile + manual smoke test）。

---

## 十、技術架構一致性

| 層次 | 沿用既有模式 |
|------|------------|
| State Management | BLoC + Equatable |
| Storage | LocalStorage（key: `sign_off_templates_key`） |
| Navigation | GoRouter + RouteName 常數（kebab-case） |
| Theme | ThemeExtension（仿 `FormDesignThemeColors`） |
| DI | GetIt service locator（`dependency_injection.dart`） |
| UI Pattern | 漸層背景 + GlowOrb + Shell + Panel（與 form_design 一致） |
| 拖曳畫布 | 複用 `org_tree_design` 的 InteractiveViewer + Draggable + DragTarget + CustomPaint 模式 |

---

## 十一、驗證方式

1. **編譯檢查：** 每個 Phase 完成後執行 `flutter analyze --no-pub` 確認 0 errors
2. **Smoke test 走查：**
   - A4 完成：能進入列表頁、看到卡片、新增空白模板、刪除
   - A5.4 完成：能拖曳部門到畫布、自動連線、移動節點、刪除節點
   - A5.5 完成：能切換節點類型、設定同層互簽、儲存後重啟資料一致
   - A6 完成：從 Drawer 點擊可進入列表頁
3. **整合驗證：** 設定完一條完整流程後，呼叫 `resolveApproverChain` 確認解析出正確的簽核人鏈

---

## 十二、待確認事項

- [ ] **「申請起點」是否必須是真實部門節點？**
  - 建議方案：**虛擬節點**，因為發起人因 `form_launch_permission` 而異，畫布上以特殊「申請起點」icon 表示，不對應實際部門。
- [ ] **同層互簽是否支援多目標？**
  - 建議方案：**v1 單目標**，v2 擴充。
- [ ] **代理人是否在 `resolveApproverChain` 即套用？**
  - 建議方案：**執行階段才解析**（簽核時才取代），避免設定階段資料變動造成快取錯誤。
- [ ] **流程版本控制：編輯既有 active 流程時是否要建立新版本？**
  - 建議方案：**v1 直接覆蓋**，v2 加入版本歷史與稽核。
- [ ] **預覽模擬員工選擇來源：模擬預覽時，員工從哪個資料源取得？**
  - 建議方案：**從符合 `form_launch_permission` 的員工清單中選**，避免選到無法發起的員工造成困惑。
- [ ] **加簽 / SLA / 條件分支是否在 v1 實作？**
  - 建議方案：**v2 再做**，v1 聚焦在三種主要簽核流向 + 基本退回。
- [ ] **拖曳父部門時是否自動帶子部門進畫布？**
  - 建議方案：**不自動帶**，子部門需獨立拖曳（避免不可控的批量加入）。

---

## 十三、後續階段

| 階段 | 模組 | 重點功能 |
|------|------|---------|
| **Phase B — 發起 & 執行簽核** | `sign_off_task_list`, `sign_off_task_detail` | 申請人送出 → 凍結路徑 → 產生任務 → 簽核人審批 |
| **Phase C — 歸檔 & 報表** | `sign_off_archive_list`, `sign_off_archive_detail` | 完成歸檔、表單快照、簽核歷程、統計報表 |
