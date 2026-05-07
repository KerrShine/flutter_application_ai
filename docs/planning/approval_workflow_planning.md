# 簽核流程規劃 — 畫布拖曳式設計

## 規劃背景

### 已完成項目總覽

| 子系統 | 模組 | 狀態 |
|--------|------|------|
| 動態表單屬性 | 組織規劃、職員設定、代理人、表單設計、欄位綁定、事件綁定 | ✅ 完成 |
| 權限設置 | 表單發起權限（form_launch_permission） | ✅ 完成 |
| 權限設置 | 設定簽核邏輯 → 簽核級別 | ❌ 待開發 ← 本文件 |
| 發起 / 執行簽核 | 申請中心、簽核任務、審批動作 | ❌ 待開發 |
| 歸檔 / 報表 | 歸檔列表、報表顯示 | ❌ 待開發 |

### 流程位置

```
表單建立 ✅ → 資料連結 ✅ → 發起權限 ✅ → 簽核邏輯 ← 目前位置 → 執行簽核 → 歸檔
```

---

## 一、要解決什麼問題

### 1.1 三種簽核流向

| 流向 | 情境 | 範例 |
|------|------|------|
| **垂直向上** | 子層級往父層級送 | 員工 → 組長 → 部門主管 → 事業群主管 → 總經理 |
| **同層級互送** | 跨部門但同層級的審核 | 事業發展組 → 行政支援中心 |
| **跨業務線** | 不在組織直線上的部門參與審核 | 採購單需 HR 與 Finance 會簽 |

### 1.2 操作體驗痛點

傳統表單式簽核流程設計需手動下拉選擇「向上 N 層」、「指定部門」，使用者難以視覺化整體簽核路徑。

**改採畫布拖曳式設計：** 直接從組織架構面板拖曳部門到畫布，自動依組織父子關係連線，視覺化完整簽核流向。

---

## 二、核心操作流程

### 步驟 1：選取表單
頂部選單選擇要設定簽核流程的表單，畫面下方顯示該表單對應的編輯器。

### 步驟 2：拖曳已有組織架構
從左側「組織架構來源面板」拖曳部門節點到中央畫布。每個部門節點代表一個簽核關卡（由該部門主管簽核）。

### 步驟 3：預設自動連線父層資料
當部門 A 被拖到畫布上時：
- 若 A 的父部門已在畫布上 → 自動繪製 A → 父部門的連線（垂直向上簽核）
- 若 A 的父部門未在畫布上 → 顯示「自動補上父層？」提示，點擊後自動加入 A 的所有上層部門並串連
- 若 A 是申請來源（畫布上第一個節點） → 標記為「申請起點」

### 步驟 4：屬性設定可設為同層互簽
點擊畫布上的節點 → 右側屬性面板可設定：
- 節點類型（審核 / 會簽 / 知會）
- 簽核模式（依組織層級向上 / **同層互簽** / 指定角色 / 指定員工）
- 同層互簽時：可在畫布上選擇另一個節點作為「互簽目標」，繪製水平連線
- 多人策略（會簽時：全部同意 / 任一同意 / 依序）
- 退回策略

---

## 三、畫面設計（參考 org_tree_design 三欄式布局）

```
┌─────────────────────────────────────────────────────────────────────────┐
│ 頂部：選擇表單下拉選單 + 流程名稱輸入 + 儲存/匯出按鈕                    │
│ Tab: [發起設定] [簽核級別 ←]                                            │
├──────────────┬─────────────────────────────────────┬──────────────────┤
│              │                                     │                  │
│  左欄：       │  中央：簽核流程畫布                  │  右欄：           │
│  組織架構     │  (InteractiveViewer + DragTarget)   │  節點屬性面板     │
│  來源面板     │                                     │                  │
│              │   ┌──────────┐                      │  選取節點：       │
│  搜尋框       │   │ 事業發展組│ ←申請起點            │  事業發展組       │
│              │   └────┬─────┘                      │                  │
│  □ 總管理     │        │ (auto)                    │  節點類型：       │
│   ▼          │   ┌────▼─────┐                      │  ◉ 審核          │
│   □ 事業群    │   │  組長    │                      │  ○ 會簽          │
│    ▼         │   └────┬─────┘                      │  ○ 知會          │
│    □ 中心    │        │ (auto)                    │                  │
│     ▼        │   ┌────▼─────┐    ┌──────────┐      │  簽核模式：       │
│     ■ 事業發展│   │ 中心主任  │←──→│行政支援中心│      │  ○ 依組織向上    │
│     □ 行政支援│   └────┬─────┘ 同層│  主任     │      │  ◉ 同層互簽 ←    │
│              │        │      互簽└──────────┘      │     目標部門：    │
│  [拖曳項目]   │   ┌────▼─────┐                      │     [行政支援中心]│
│              │   │ 事業群主管│                      │                  │
│              │   └──────────┘                      │  多人策略：       │
│              │                                     │  (僅會簽顯示)     │
│              │   [+ 縮放控制]                       │                  │
│              │                                     │  退回策略：       │
│              │                                     │  [退回上一關 ▼]   │
│              │                                     │                  │
│              │                                     │  [刪除節點]       │
└──────────────┴─────────────────────────────────────┴──────────────────┘
```

### 視覺元素

**節點卡片（畫布上的部門）**
- 顯示部門名稱 + 部門代碼
- 角落 icon 標示節點類型（審核 / 會簽 / 知會）
- 「申請起點」節點以特殊邊框與標記顯示
- 選取狀態：高亮邊框 + 陰影加深

**連線**
- **垂直向上連線（自動產生）：** 灰色實線，箭頭朝上，沿用 `_ConnectionPainter` 的右角型路徑
- **同層互簽連線（手動屬性設定）：** 藍色虛線，雙向箭頭，水平繪製
- **指定角色簽核：** 不畫連線，節點卡片顯示「角色：HR」標籤
- **會簽分支：** 節點以「會簽框」包裹，內部多個簽核人

---

## 四、自動連線父層邏輯

### 拖曳放下時的流程（`DropDepartmentToCanvasEvent`）

```
1. 從 OrgDepartmentNode 取得被拖曳部門 A 的 parentDepartmentId
2. 檢查父部門是否已在畫布上：
   ├── 已在畫布 → 直接建立 A → 父部門的連線（autoConnected = true）
   └── 未在畫布 → 觸發 SuggestAutoFillParentChainEvent
                  ├── 對話框：「是否自動補上父層部門？」
                  │     ├── 是 → 沿 parentDepartmentId 鏈向上補完，全部加入畫布並串連
                  │     └── 否 → A 設為「申請起點」(isApplicantOrigin = true)
                  └── 對話框可記住選擇（不再詢問）
3. 自動分配位置（avoidance：避免與既有節點重疊）
   - 父部門 Y - 120 為新節點 Y
   - X 取父部門相同 X，若有衝突則向右偏移 200
```

### 重要規則

- **連線只在組織父子關係上建立** — 拖曳時自動連線，使用者無需手動拉線
- **同層互簽不在拖曳階段處理** — 改在屬性面板手動設定（避免拖曳邏輯複雜）
- **拖曳父部門不會自動帶子部門** — 子部門需獨立拖曳（避免不可控的批量加入）

---

## 五、資料模型

### 5.1 ApprovalWorkflowTemplate（簽核流程模板）

```
ApprovalWorkflowTemplate
├── templateId          : String
├── formId              : String       — 對應表單
├── permissionId        : String       — 引用既有 form_launch_permission
├── name                : String       — 流程名稱
├── status              : String       — draft / active / disabled
├── canvasNodes         : List<ApprovalCanvasNode>  — 畫布節點 + 位置
├── canvasTransform     : List<double>?             — 畫布縮放/平移狀態
├── version             : int
└── createdAt / updatedAt
```

### 5.2 ApprovalCanvasNode（畫布節點 — 一個節點 = 一個簽核關卡）

```
ApprovalCanvasNode
├── nodeId              : String
├── departmentId        : String?      — 引用的組織部門 ID（拖曳來源）
├── offsetDx            : double       — 畫布 X 座標
├── offsetDy            : double       — 畫布 Y 座標
├── isApplicantOrigin   : bool         — 是否為申請起點
├── nodeType            : NodeType     — approve / countersign / notify
│
├── approverMode        : ApproverMode — 簽核人解析模式
│   ├── hierarchyManager   — 此部門主管（依組織向上）
│   ├── crossLevel         — 同層互簽（指向另一節點）
│   ├── designatedRole     — 指定角色（不依部門）
│   └── designatedEmployee — 指定員工（不依部門）
│
├── crossLevelTargetNodeId : String?   — 同層互簽目標 nodeId
├── designatedRoleId       : String?   — 指定角色時使用
├── designatedEmployeeId   : String?   — 指定員工時使用
│
├── multiStrategy       : MultiStrategy?  — 會簽多人策略
├── returnPolicy        : ReturnPolicy
├── returnTargetNodeId  : String?      — 退回指定關卡
└── allowAddSigner      : bool         — 加簽（v2）
```

### 5.3 連線解析（不獨立儲存，由節點屬性派生）

連線資訊由 `canvasNodes` 動態計算：

```
ConnectionPainter:
  for each node:
    1. 垂直向上連線：依 OrgDepartmentNode.parentDepartmentId 連線到上層節點
    2. 同層互簽連線：依 crossLevelTargetNodeId 繪製水平連線
```

### 5.4 Enum 定義

```dart
enum NodeType {
  approve,      // 審核
  countersign,  // 會簽
  notify,       // 知會
}

enum ApproverMode {
  hierarchyManager,    // 此部門主管（拖曳預設）
  crossLevel,          // 同層互簽
  designatedRole,      // 指定角色
  designatedEmployee,  // 指定員工
}

enum MultiStrategy {
  all,         // 全部同意
  any,         // 任一同意
  sequential,  // 依序簽核
}

enum ReturnPolicy {
  toApplicant,
  toPrevious,
  toSpecific,
}
```

---

## 六、需新增的模組

### 6.1 approval_workflow_manager — 流程模板列表

**定位：** 顯示所有已設定的簽核流程模板。

| 功能 | 說明 |
|------|------|
| 流程清單 | 卡片：表單名稱 + 流程名稱 + 節點數 + 狀態 |
| 新增 / 編輯 / 刪除 | 標準 CRUD |
| 啟用切換 | draft / active / disabled |
| 匯出 JSON | 匯出全部流程設定 |

**路由：** `/home/approval-design/approval-workflow-manager`

### 6.2 approval_workflow_editor — 畫布拖曳編輯器

**定位：** 視覺化設定簽核流程，依組織架構自動串連。

**版面：頂部 Tab 切換**
- **發起設定 Tab** — 引用既有 `form_launch_permission`（唯讀展示 + 編輯連結）
- **簽核級別 Tab** — 三欄畫布拖曳編輯器（本規劃重點）

**簽核級別 Tab 三欄結構：**

| 區塊 | 對應 widget | 功能 |
|------|------------|------|
| 左欄 | `approval_org_source_panel_widget.dart` | 組織架構來源面板（樹狀展開、搜尋、Draggable） |
| 中央 | `approval_canvas_panel_widget.dart` | 拖曳畫布（InteractiveViewer + DragTarget + ConnectionPainter） |
| 右欄 | `approval_node_property_panel_widget.dart` | 節點屬性面板 |

**路由：** `/home/approval-design/approval-workflow-manager/editor`

### 6.3 ApprovalWorkflowService（業務邏輯層）

| 方法 | 說明 |
|------|------|
| `loadAllTemplates()` | 載入所有流程模板 |
| `loadByFormId(formId)` | 取得特定表單的流程模板 |
| `saveTemplate(template)` | 建立或更新模板 |
| `deleteTemplate(templateId)` | 刪除模板 |
| `resolveApproverChain(templateId, applicantId)` | 解析特定申請人的完整簽核鏈，回傳每節點的實際簽核人 |
| `validateTemplate(template)` | 驗證流程合法性（無循環、有起點、有終點） |

---

## 七、與現有模組的銜接

| 現有模組 | 銜接方式 |
|----------|---------|
| `form_launch_permission` | 提供「發起資格」設定，被流程模板引用 |
| `org_design` | 提供部門樹，作為左欄拖曳來源；解析向上層級時使用 |
| `org_tree_design` | **複用其畫布、連線、拖曳的設計模式** |
| `emp_info` | 解析簽核人時使用（含部門主管、指定員工） |
| `emp_role` | 指定角色簽核時使用 |
| `emp_agent` | 後續整合代理人機制（v2） |

### 與 org_tree_design 的差異

| 項目 | org_tree_design | approval_workflow_editor |
|------|----------------|-------------------------|
| 節點意義 | 組織部門本體 | 簽核關卡（每個關卡指向一個部門/角色/員工） |
| 連線意義 | 組織父子關係 | 簽核流向 |
| 連線建立 | 屬性面板選父部門 | **拖曳時自動依組織關係連線** |
| 額外連線 | 無 | 同層互簽（屬性面板設定，水平繪製） |
| 節點屬性 | 部門資料 | 節點類型 / 簽核人模式 / 退回策略 |

---

## 八、檔案結構

```
lib/
├── enum/
│   ├── approval_node_type.dart           — NodeType enum
│   ├── approver_mode.dart                — ApproverMode enum
│   ├── multi_strategy.dart               — MultiStrategy enum
│   └── return_policy.dart                — ReturnPolicy enum
│
├── model/
│   ├── approval_workflow_template_model.dart
│   └── approval_canvas_node.dart         — 畫布節點（含位置與屬性）
│
├── repositories/
│   ├── interface/
│   │   └── approval_workflow_repository.dart
│   └── approval_workflow_repository_impl.dart
│
├── service/
│   └── approval_workflow_service.dart    — 含 resolveApproverChain
│
└── page/approval_design/
    ├── approval_workflow_manager/
    │   ├── approval_workflow_manager_page.dart
    │   ├── bloc/
    │   │   ├── approval_workflow_manager_bloc.dart
    │   │   ├── approval_workflow_manager_event.dart
    │   │   └── approval_workflow_manager_state.dart
    │   └── widgets/
    │       ├── workflow_header_widget.dart
    │       └── workflow_list_widget.dart
    │
    └── approval_workflow_editor/
        ├── approval_workflow_editor_page.dart       — 三欄式 Scaffold
        ├── bloc/
        │   ├── approval_workflow_editor_bloc.dart
        │   ├── approval_workflow_editor_event.dart
        │   └── approval_workflow_editor_state.dart
        └── widgets/
            ├── editor_launch_permission_tab_widget.dart  — 發起設定 Tab
            ├── editor_approval_levels_tab_widget.dart    — 簽核級別 Tab 容器
            ├── approval_org_source_panel_widget.dart     — 左欄：組織來源
            ├── approval_canvas_panel_widget.dart         — 中央：畫布
            ├── approval_node_property_panel_widget.dart  — 右欄：屬性
            └── units/
                ├── approval_node_card.dart               — 節點卡片
                ├── approval_connection_painter.dart      — 連線繪製（垂直 + 同層互簽）
                ├── approval_grid_painter.dart            — 背景格線
                ├── approval_zoom_controls.dart           — 縮放控制
                ├── approver_mode_selector.dart           — 簽核人模式選擇器
                └── cross_level_target_picker.dart        — 同層互簽目標選擇器
```

---

## 九、BLoC 事件設計（編輯器）

| 事件 | 說明 |
|------|------|
| `InitEditorEvent(templateId?)` | 載入流程模板與組織資料 |
| `SelectFormEvent(formId)` | 選取表單，過濾組織架構與權限 |
| **拖曳相關** | |
| `SelectAvailableDepartmentEvent(departmentId)` | 標記來源面板選中項目 |
| `DropDepartmentToCanvasEvent(departmentId, dx, dy)` | 拖曳到畫布，自動連線父層 |
| `MoveCanvasNodeEvent(nodeId, deltaDx, deltaDy)` | 拖動畫布節點 |
| `SuggestAutoFillParentChainEvent(departmentId)` | 詢問是否自動補上父層 |
| `ConfirmAutoFillParentChainEvent(departmentId, accept)` | 確認自動補父層 |
| `RemoveCanvasNodeEvent(nodeId)` | 刪除畫布節點 |
| **節點屬性** | |
| `SelectCanvasNodeEvent(nodeId)` | 選取畫布節點，顯示屬性 |
| `UpdateNodeTypeEvent(nodeId, NodeType)` | 修改節點類型 |
| `UpdateApproverModeEvent(nodeId, ApproverMode)` | 修改簽核人模式 |
| `SetCrossLevelTargetEvent(nodeId, targetNodeId)` | 設定同層互簽目標 |
| `UpdateMultiStrategyEvent(nodeId, MultiStrategy)` | 修改會簽策略 |
| `UpdateReturnPolicyEvent(nodeId, ReturnPolicy)` | 修改退回策略 |
| `MarkAsApplicantOriginEvent(nodeId)` | 標記為申請起點 |
| **畫布操作** | |
| `SyncCanvasTransformEvent(values)` | 同步縮放/平移狀態 |
| `ZoomInCanvasEvent` / `ZoomOutCanvasEvent` / `CenterCanvasEvent` | 縮放控制 |
| **儲存** | |
| `SaveTemplateEvent` | 驗證並儲存模板 |
| `PreviewApproverChainEvent(employeeId)` | 模擬解析簽核鏈 |

---

## 十、建議開發順序

```
Step 1 — Enums + Models + Repository
  ├── NodeType / ApproverMode / MultiStrategy / ReturnPolicy enums
  ├── ApprovalWorkflowTemplate / ApprovalCanvasNode models
  └── LocalStorage 持久化

Step 2 — Service 業務邏輯
  ├── CRUD 流程模板
  ├── resolveApproverChain（核心解析）
  └── validateTemplate（合法性檢查）

Step 3 — 流程模板列表頁
  ├── BLoC + State
  └── 卡片清單 / CRUD / 啟用切換

Step 4 — 畫布拖曳編輯器（重頭戲，分子任務）
  ├── 4.1 三欄 Scaffold + Tab 切換
  ├── 4.2 發起設定 Tab（引用既有 form_launch_permission）
  ├── 4.3 左欄組織來源面板（複用 org_tree_source 模式）
  ├── 4.4 中央畫布
  │     ├── InteractiveViewer + DragTarget
  │     ├── 自動連線父層邏輯（DropDepartmentToCanvasEvent）
  │     ├── ConnectionPainter（垂直 + 同層互簽兩種樣式）
  │     └── 節點卡片 + 縮放控制
  ├── 4.5 右欄屬性面板
  │     ├── 節點類型切換
  │     ├── 簽核人模式選擇（含同層互簽 picker）
  │     ├── 多人策略 + 退回策略
  │     └── 申請起點標記
  └── 4.6 儲存與驗證

Step 5 — 整合
  ├── 首頁側邊欄「簽核設定」新增「簽核流程」子項目
  ├── 路由註冊
  └── DI 註冊（Repository / Service / BLoC）
```

---

## 十一、待確認事項

- [ ] **「申請起點」是否必須是真實部門節點？** 還是可允許虛擬「申請人」節點（根據實際發起人動態決定）？建議方案：**虛擬節點**，因為發起人因表單發起權限而異
- [ ] **同層互簽是否支援多目標？** 一個節點同時送給多個同層部門？建議方案：**v1 單目標**，v2 擴充
- [ ] **代理人是否在 resolveApproverChain 即套用？** 還是執行階段才解析？建議方案：**執行階段才解析**（簽核時才取代）
- [ ] **流程版本控制：** 編輯既有 active 流程時是否要建立新版本？建議方案：**v1 直接覆蓋**，v2 加入版本歷史
- [ ] **預覽模擬員工選擇來源：** 從哪個資料源選？建議方案：**從符合 form_launch_permission 的員工清單中選**
- [ ] **加簽 / SLA / 條件分支：** v1 是否實作？建議方案：**v2 再做**

---

## 十二、後續階段

| 階段 | 模組 | 重點功能 |
|------|------|---------|
| **發起 & 執行簽核** | `approval_task_list`, `approval_task_detail` | 申請人送出 → 凍結路徑 → 產生任務 → 簽核人審批 |
| **歸檔 & 報表** | `archive_list`, `archive_detail` | 完成歸檔、表單快照、簽核歷程、統計報表 |
