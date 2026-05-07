# 表單發起權限（Form Launch Permission）

## 模組定位

表單發起權限是「動態表單屬性」與「流程引擎」之間的橋樑，負責控制**誰可以使用哪張表單發起申請**。

在系統架構中的位置：

```
設定表單 → 表單設計 → 欄位綁定 → 執行事件綁定
                ↓
            權限設定 → 【表單發起權限】 ← 目前模組
                ↓
          設定簽核邏輯 → 簽核級別 → 發起設定（下一階段）
```

---

## 功能影響範疇

### 直接影響

| 影響對象 | 說明 |
|----------|------|
| **申請中心** (`form_application_center`) | 使用者看到的可用表單清單，完全依據發起權限過濾 |
| **表單送出** (`form_submission`) | 送出前再次驗證申請人是否符合發起資格 |

### 依賴來源

| 依賴模組 | 提供資料 |
|----------|---------|
| **表單管理** (`form_manage`) | 表單清單（`FormModel`） |
| **角色設定** (`emp_role`) | 員工角色清單（`EmpRoleModel`） |
| **部門組織** (`org_design`) | 組織架構樹（`OrgDepartmentNode`） |
| **員工資料** (`emp_info`) | 員工身份資料，用於資格判斷 |

### 後續銜接

| 下游模組 | 銜接方式 |
|----------|---------|
| **簽核流程** (尚未實作) | 知道「誰發起、填什麼」後，才能解析簽核路徑 |
| **歸檔** (尚未實作) | 權限紀錄作為稽核依據 |

---

## 操作方式

### 管理端：設定發起權限

**入口：** 首頁側邊欄 → 表單管理 → 表單權限設定

#### 權限列表頁

```
路由：/home/form-manage/form-launch-permission
```

| 操作 | 說明 |
|------|------|
| 檢視權限清單 | 以卡片方式顯示所有已設定的權限，包含表單名稱、角色/部門標籤、狀態 |
| 新增權限 | 進入編輯器（建立模式） |
| 編輯權限 | 進入編輯器（編輯模式），帶入既有設定 |
| 刪除權限 | 確認對話框後移除 |
| 匯出 JSON | 將所有權限設定匯出為 JSON 格式 |

#### 權限編輯器

```
路由：/home/form-manage/form-launch-permission/editor
```

**版面配置：** 左側摘要面板（240px）+ 右側設定區塊

**左側 — 設定摘要面板：**
- 即時顯示已選表單、角色數量、部門數量
- 符合人員數量 + 「查看名單」按鈕

**右側 — 設定區塊（由上至下）：**

1. **選擇表單**（必填）
   - 下拉選單列出所有草稿表單
   
2. **允許角色**
   - Checkbox 列表，多選
   - 未選任何角色 = 不限角色，所有角色皆可發起
   - 「清除選擇」按鈕

3. **允許部門**
   - 組織樹階層展開式 ListView
   - 排除最上層總管理部門（depthLevel 0），從事業群層級（depthLevel 1）開始
   - 父節點 Checkbox 為三態（全選/部分/未選），點擊父節點自動勾選/取消所有子部門
   - 「全選」/「清除」按鈕
   - 儲存時至少需選擇一個部門

4. **其他設定**（可收合面板）
   - 全部允許：忽略角色與部門限制，所有人皆可發起
   - 須在職：僅在職員工可發起（預設開啟）
   - 僅限主管：僅主管級員工可發起
   - 啟用：控制此權限是否生效

**App Bar 操作：**
- 預覽符合人員：依目前條件計算符合資格的員工清單
- 儲存變更：驗證後儲存，成功自動返回列表頁

### 使用者端：申請中心

**入口：** 首頁側邊欄 → 待辦事項 → 申請中心

```
路由：/home/form-apply/form-application-center
```

系統依登入者的角色、部門、在職狀態，自動過濾出該員工有權限發起的表單清單。

---

## 資料模型

### FormLaunchPermissionModel

```dart
FormLaunchPermissionModel
├── permissionId        : String    — 唯一識別（格式：perm_{timestamp}）
├── formId              : String    — 對應表單 ID
├── formName            : String    — 表單名稱（快取）
├── bindingId           : String    — 資料綁定 ID（保留欄位）
├── allowedRoleIds      : List<String> — 允許角色 ID 清單（空 = 不限）
├── allowedDepartmentIds: List<String> — 允許部門 ID 清單（空 = 不限）
├── allowAll            : bool      — 全部允許（忽略角色/部門限制）
├── requireActiveStatus : bool      — 須在職（預設 true）
├── requireManagerRole  : bool      — 僅限主管（預設 false）
├── isEnabled           : int       — 啟用狀態（1=啟用, 0=停用）
├── createdAt           : String    — 建立時間（UTC ISO8601）
└── updatedAt           : String    — 更新時間（UTC ISO8601）
```

### 資格判斷邏輯

```
canLaunch(employee, permission) =
    permission.isEnabled == 1
    AND (allowAll == true
         OR (
             (allowedRoleIds 為空 OR employee.roleId IN allowedRoleIds)
             AND (allowedDepartmentIds 為空 OR employee.departmentId IN allowedDepartmentIds)
             AND (requireActiveStatus == false OR employee.status == 在職)
             AND (requireManagerRole == false OR employee.roleType == 主管)
         ))
```

---

## 檔案結構

```
lib/
├── model/
│   └── form_launch_permission_model.dart          — 資料模型
│
├── repositories/
│   ├── interface/
│   │   └── form_launch_permission_repository.dart  — Repository 介面
│   └── form_launch_permission_repository_impl.dart — LocalStorage 實作
│
├── service/
│   └── form_launch_permission_service.dart         — 業務邏輯層
│       ├── initialize()                — 載入表單/權限/角色/部門
│       ├── savePermission()            — 建立或更新權限
│       ├── deletePermission()          — 刪除權限
│       ├── previewEligibleEmployees()  — 預覽符合人員
│       └── buildExportJson()           — 匯出 JSON
│
├── page/form_design/
│   ├── form_launch_permission/                     — 權限列表頁
│   │   ├── form_launch_permission_page.dart
│   │   ├── bloc/
│   │   │   ├── form_launch_permission_bloc.dart
│   │   │   ├── form_launch_permission_event.dart
│   │   │   └── form_launch_permission_state.dart
│   │   └── widgets/
│   │       ├── permission_header_widget.dart        — 標題列 + 操作按鈕
│   │       └── permission_list_widget.dart           — 權限卡片清單
│   │
│   └── form_launch_permission_editor/              — 權限編輯器
│       ├── form_launch_permission_editor_page.dart
│       ├── bloc/
│       │   ├── form_launch_permission_editor_bloc.dart
│       │   ├── form_launch_permission_editor_event.dart
│       │   └── form_launch_permission_editor_state.dart
│       └── widgets/
│           ├── editor_form_section_widget.dart       — 表單選擇區塊
│           ├── editor_role_section_widget.dart        — 角色選擇區塊
│           ├── editor_department_section_widget.dart  — 部門樹選擇區塊
│           ├── editor_options_section_widget.dart     — 其他設定區塊
│           └── editor_summary_sidebar_widget.dart     — 摘要側邊欄
│
├── injection/
│   └── dependency_injection.dart                    — GetIt 服務註冊
│
└── route/
    └── route_catalog.dart                           — 路由定義
```

---

## 目前實作項目

### 已完成

| 項目 | 狀態 | 說明 |
|------|------|------|
| 資料模型 | ✅ | `FormLaunchPermissionModel` 含完整序列化 |
| Repository | ✅ | LocalStorage CRUD（key: `form_launch_permissions_key`） |
| Service 層 | ✅ | 初始化、儲存、刪除、預覽、匯出 |
| 權限列表頁 | ✅ | 卡片清單、狀態標示、編輯/刪除操作 |
| 權限編輯器 | ✅ | 表單選擇、角色勾選、部門樹、選項設定、摘要面板 |
| 部門樹選擇 | ✅ | 遞迴展開、三態 Checkbox、排除總管理 |
| 預覽符合人員 | ✅ | 依條件計算並顯示員工名單 |
| JSON 匯出 | ✅ | 全部權限匯出為結構化 JSON |
| 申請中心整合 | ✅ | `form_application_center` 依權限過濾可用表單 |
| 主題整合 | ✅ | 使用 `FormDesignThemeColors` ThemeExtension |
| DI 註冊 | ✅ | GetIt 註冊 Repository / Service |
| 路由定義 | ✅ | 列表頁 + 編輯器兩條路由 |

### 儲存方式

目前使用 **LocalStorage** 持久化，尚未對接後端 API。

儲存格式（JSON Array）：
```json
[
  {
    "permission_id": "perm_1234567890",
    "form_id": "form_001",
    "form_name": "請假申請單",
    "allowed_role_ids": ["role_001", "role_002"],
    "allowed_department_ids": ["dept_001", "dept_003"],
    "allow_all": false,
    "require_active_status": true,
    "require_manager_role": false,
    "is_enabled": 1,
    "created_at": "2026-04-20T10:30:00.000Z",
    "updated_at": "2026-04-27T14:00:00.000Z"
  }
]
```

---

## 後續實作項目

### 近期（銜接簽核流程）

| 項目 | 說明 |
|------|------|
| **bindingId 啟用** | 目前為空字串保留欄位，未來一張表單可能對應多份綁定，需決定使用者拿到的是哪一份 |
| **條件組合邏輯** | 目前為簡單 AND 組合，後續可擴充為 AND/OR 條件式組合（對應 sign_off_system.md 的「條件式組合」） |
| **後端 API 對接** | 將 LocalStorage 替換為 REST API 呼叫，Repository 介面無需修改 |

### 中期（設定簽核邏輯）

| 項目 | 說明 |
|------|------|
| **簽核流程模板** | 在權限設定之後，為每張表單定義簽核路徑（審核/會簽/知會節點） |
| **簽核級別設定** | 定義簽核人來源：直屬主管 N 層、指定角色、部門主管、表單欄位指定人 |
| **發起設定** | 整合發起權限 + 簽核流程 = 完整的「發起條件」，申請人送出時自動解析路徑 |

### 遠期（執行簽核 & 歸檔）

| 項目 | 說明 |
|------|------|
| **發起簽核** | 申請人送出表單時，驗證發起資格 → 凍結簽核路徑 → 產生簽核任務 |
| **執行簽核** | 簽核人待辦列表、審批動作（同意/拒絕/退回/補件/轉派/加簽） |
| **歸檔 & 報表** | 簽核完成後自動歸檔，提供歷史查詢與統計報表 |

---

## BLoC 事件總覽

### 列表頁（FormLaunchPermissionBloc）

| 事件 | 說明 |
|------|------|
| `InitEvent` | 載入所有權限 + 表單/角色/部門資料 |
| `DeletePermissionEvent` | 刪除指定權限 |
| `RequestExportJsonEvent` | 產生 JSON 匯出內容 |

### 編輯器（FormLaunchPermissionEditorBloc）

| 事件 | 說明 |
|------|------|
| `InitEditorEvent` | 初始化編輯器（新增/編輯模式） |
| `SelectFormEvent` | 選擇表單 |
| `ToggleRoleEvent` | 勾選/取消角色 |
| `ClearAllRolesEvent` | 清除所有角色 |
| `ToggleDepartmentEvent` | 勾選/取消單一部門 |
| `ToggleDepartmentTreeEvent` | 勾選/取消整個子樹（遞迴） |
| `SelectAllDepartmentsEvent` | 全選部門（排除 depthLevel 0） |
| `ClearAllDepartmentsEvent` | 清除所有部門 |
| `UpdateAllowAllEvent` | 切換「全部允許」 |
| `UpdateRequireActiveStatusEvent` | 切換「須在職」 |
| `UpdateRequireManagerRoleEvent` | 切換「僅限主管」 |
| `UpdateIsEnabledEvent` | 切換啟用狀態 |
| `SavePermissionEvent` | 驗證並儲存（部門不可為空） |
| `PreviewEligibleEmployeesEvent` | 預覽符合資格員工 |
