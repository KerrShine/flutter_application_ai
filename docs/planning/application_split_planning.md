# 申請中心拆分規劃 — 新增申請 / 我的申請 / 待我簽核

## 規劃背景

### 已完成項目總覽

| 子系統 | 模組 | 狀態 | 對應路徑 |
|------|------|------|---------|
| 申請容器 | form_application（外層資料夾）| ✅ | [lib/page/form_application/](../../lib/page/form_application/) |
| 申請整合頁 | form_application_center | ⚠️ 同頁面承擔多職責、待拆 | [form_application_center/](../../lib/page/form_application/form_application_center/) |
| 申請服務 | FormApplicationService | ✅ initialize / submitForm / buildExportJson 已具備 | [lib/service/form_application_service.dart](../../lib/service/form_application_service.dart) |
| 身分切換 | CurrentEmployeeBloc | ✅ home shell 已 provide，全域可讀 | [lib/bloc/current_employee/](../../lib/bloc/current_employee/) |
| Sign_off 簽核流程 | sign_off_manager / editor | ⚠️ 模板編輯已有，無「待簽實例」資料層 | [lib/page/sign_off/](../../lib/page/sign_off/) |
| Sign_off 待簽資料 | SignOffInstance / Pending API | ❌ 完全不存在 | — |

### 目前 form_application_center 結構快照

```
form_application_center/
├── form_application_center_page.dart    ← 一頁同時 render header + searchBar + formGrid + submissionList
├── bloc/
│   ├── form_application_center_bloc.dart  ← 6 events 處理兩條業務線
│   ├── form_application_center_event.dart
│   └── form_application_center_state.dart ← 11 欄位混合兩條業務 state
└── widgets/
    ├── application_header_widget.dart       ← 共用（標題 + 匯出按鈕）
    ├── application_search_bar_widget.dart   ← 屬「新增申請」
    ├── application_form_grid_widget.dart    ← 屬「新增申請」
    └── application_submission_section_widget.dart  ← 屬「我的申請」
```

---

## 一、要解決什麼問題

| 痛點 | 影響 |
|------|------|
| 一個 page 同時 render 「可申請表單 grid」+「我送的單列表」+ 「Header / 匯出工具」 | 螢幕擁擠、scroll 路徑長、UX 混雜 |
| Bloc state 11 欄位橫跨兩條業務線（availableForms / mySubmissions / 共用） | 變更其一就觸發另一邊 rebuild、職責不單一 |
| Drawer 只一個「申請中心」入口 — 使用者想直接「看我送的單」也得先進中介頁、scroll 到下半 | 不符合使用者心智（不同任務不同入口） |
| 「待我簽核」未來要加 — 沒地方放，只能再塞進同一個中介頁，惡化問題 | 拆早不拆晚，避免越積越深 |
| service 已支援 submission 與 available 分開讀，但 bloc 還是一次 init 全部載入 | IO 浪費、未來各自加 paging / refresh 困難 |

---

## 二、關鍵設計取捨

### 2.1 三頁獨立、不共用 bloc

✓ **選擇**：三個獨立 page + 三個獨立 bloc。
✗ 不選 TabBar：使用者明確要「兩種入口」（其實是 3 種），TabBar 只算一個入口。
- 理由：每頁有自己的 init / refresh / search / export 行為，職責劃清；未來各自演進不互相影響。

### 2.2 Service 不拆，但加聚焦 method

✓ **選擇**：保留單一 `FormApplicationService`，加兩個聚焦讀取 method。
✗ 不拆成 `ApplicationCreateService` + `MyApplicationService`：兩者共用同一個 employee / permission resolver，過早拆會重複；service 內部已有充分內聚。

新增的聚焦 method（v1）：
- `Future<Result<List<AvailableFormItem>>> loadAvailableForms(String employeeId)`
- `Future<Result<List<FormSubmissionModel>>> loadMySubmissions(String employeeId)`

兩者皆從既有 `initialize()` 內部抽出公共邏輯，避免兩 page init 載入時都吃下整份。原 `initialize()` 維持但標註為 deprecated（給舊 page 過渡用）；舊 page 廢棄後一併移除。

### 2.3 Theme 不拆、但重命名

✓ **選擇**：把 `form_application_center_theme_colors.dart` **檔名 + class 名重命名**為 `form_application_theme_colors.dart` / `FormApplicationThemeColors`，三頁共用。
- 理由：視覺一致；新增申請與我的申請的色票本來就高度重疊；拆三份維護成本高。
- AppColors 內 `appCenterXxx*` 常數一併重命名為 `appFormApplicationXxx*`（見 [lib/theme/app_colors.dart](../../lib/theme/app_colors.dart) 第 515 行起）。

### 2.4 共用 widget 放哪

✓ **選擇**：把 `application_header_widget.dart` 搬到 `lib/page/form_application/widgets/`，三頁共用。
- 三頁 header 行為一致（顯示當前員工 + 標題 + 可選右側操作 button），共用一份。

### 2.5 「待我簽核」純空殼

✓ **選擇**：建立完整的 page + bloc + state + event 骨架，但**不接任何真實 service 資料**。
- bloc init 時直接 emit `EmpAgentStatus.success` + 空 list；
- page UI 顯示「待我簽核功能將於 sign_off 完成後上線」+ 引導訊息。
- 理由：sign_off 還沒有 SignOffInstance / Pending API；空殼確保架構就位，未來只需替換 service 實作。

### 2.6 form_application_center 完全廢棄

✓ **選擇**：Phase 完成後刪除整個 `form_application_center/` 資料夾、刪 RouteName / route 註冊 / DI。
- 不留 hub 頁、不保留 redirect — 三個獨立入口已是最終形態。

---

## 三、核心設計

### 3.1 三頁職責對照

| Page | 職責 | 顯示 | 動作 |
|------|------|------|------|
| **新增申請** | 列出當前員工**可發起**的表單 | `availableForms` grid + 搜尋框 | 點 → 跳 form_run 填表 |
| **我的申請** | 列出當前員工**送出過**的 submission | `mySubmissions` list + 狀態 chip | 匯出 JSON / 點某筆看詳情（v2） |
| **待我簽核** | 列出當前員工**作為 approver** 待簽的 submission | 空殼提示 | （v2）核准 / 退件 |

### 3.2 身分上下文

三頁都從 `CurrentEmployeeBloc.state.current.employeeId` 取登入身分（既有全域 bloc，[home_page.dart](../../lib/page/home/home_page.dart) shell 已 provide）。

切換身分時：
- page 內加 `BlocListener<CurrentEmployeeBloc, CurrentEmployeeState>`，監聽 `current.employeeId` 變化 → 重新 emit `InitEvent`
- 與既有 form_application_center [page L31-35 模式](../../lib/page/form_application/form_application_center/form_application_center_page.dart) 一致

### 3.3 路由與 drawer 入口

新增 3 條路由（同層、與既有 `formApplicationCenterPage` 並列）：

```
RouteName.applicationCreatePage    = '/home/form-apply/new'
RouteName.myApplicationPage        = '/home/form-apply/my'
RouteName.signOffPendingPage       = '/home/sign-off-pending'
```

Drawer ExpansionTile「待辦事項」內，原本 1 個 ListTile（申請中心）改為 3 個：
```diff
- ListTile('申請中心') → formApplicationCenterPage
+ ListTile('新增申請') → applicationCreatePage
+ ListTile('我的申請') → myApplicationPage
+ ListTile('待我簽核') → signOffPendingPage
```

`formApplicationCenterPage` 常數與路由註冊同時刪除。

---

## 四、資料模型

無新 model — 三頁皆重用既有：

```
FormApplicationCenterState 拆解：
─────────────────────────────────────
共用（三頁皆有）：
  status / message / messageRequestId
  employeeId / currentEmployee

新增申請專屬：
  availableForms : List<AvailableFormItem>
  searchQuery    : String

我的申請專屬：
  mySubmissions       : List<FormSubmissionModel>
  exportJson          : String
  exportDialogRequestId : int

待我簽核專屬：
  pendingItems : List<dynamic>  ← v1 永遠空 list

navigation 共用（新增申請會用）：
  navigateRoute  : String
  navigateExtra  : Map<String, dynamic>
```

---

## 五、需新增的模組

### 5.1 新增申請（application_create）

- **定位**：員工選表單發起申請的入口
- **路由**：`/home/form-apply/new`
- **drawer 名稱**：「新增申請」（icon: `Icons.note_add` 或 `Icons.add_circle_outline`）
- **核心 widget**：search bar + form grid

### 5.2 我的申請（my_application）

- **定位**：員工查看自己送過的申請與狀態
- **路由**：`/home/form-apply/my`
- **drawer 名稱**：「我的申請」（icon: `Icons.list_alt`）
- **核心 widget**：submission list + 匯出工具

### 5.3 待我簽核（sign_off_pending）

- **定位**：員工作為 approver 的待簽列表（v1 空殼）
- **路由**：`/home/sign-off-pending`
- **drawer 名稱**：「待我簽核」（icon: `Icons.assignment_turned_in_outlined`）
- **核心 widget**：空狀態提示 widget

---

## 六、與現有模組的銜接

| 現有模組 | 銜接方式 |
|---------|---------|
| [FormApplicationService](../../lib/service/form_application_service.dart) | 新增 `loadAvailableForms` / `loadMySubmissions` 兩個聚焦 method；`submitForm` 維持給 form_run；`buildExportJson` 給「我的申請」匯出 |
| [CurrentEmployeeBloc](../../lib/bloc/current_employee/current_employee_bloc.dart) | 三頁 init / 身分切換 listen，從 `state.current.employeeId` 取 ID |
| [form_run](../../lib/page/form_design/form_run/) | 「新增申請」點表單後 push `RouteName.formRunPage`（沿用現有 SelectFormToApplyEvent → navigate 模式） |
| [HomePage drawer](../../lib/page/home/home_page.dart) | ExpansionTile「待辦事項」展開 3 個 ListTile（取代原「申請中心」單一項目） |
| [FormApplicationThemeColors](../../lib/theme/form_application_center_theme_colors.dart)（將更名） | 三頁共用同一份 ThemeExtension |
| [sign_off_service](../../lib/service/sign_off_service.dart) | 待我簽 v1 不接；v2 將呼叫（未來）`loadPendingByApprover(approverId)` |

---

## 七、檔案結構

```
lib/page/form_application/
├── widgets/                                     ← 跨頁共用 widget
│   └── application_header_widget.dart           ← 從 form_application_center 搬來
│
├── application_create/
│   ├── application_create_page.dart
│   ├── bloc/
│   │   ├── application_create_bloc.dart
│   │   ├── application_create_event.dart
│   │   └── application_create_state.dart
│   └── widgets/
│       ├── application_search_bar_widget.dart   ← 從舊資料夾搬
│       └── application_form_grid_widget.dart    ← 從舊資料夾搬
│
├── my_application/
│   ├── my_application_page.dart
│   ├── bloc/
│   │   ├── my_application_bloc.dart
│   │   ├── my_application_event.dart
│   │   └── my_application_state.dart
│   └── widgets/
│       └── application_submission_section_widget.dart  ← 從舊資料夾搬
│
└── sign_off_pending/
    ├── sign_off_pending_page.dart
    ├── bloc/
    │   ├── sign_off_pending_bloc.dart
    │   ├── sign_off_pending_event.dart
    │   └── sign_off_pending_state.dart
    └── widgets/
        └── sign_off_pending_empty_state_widget.dart  ← 「尚未實作」UI

刪除：
└── form_application_center/                     ← 整包刪掉

修改：
├── lib/service/form_application_service.dart   ← 加 2 method
├── lib/theme/form_application_theme_colors.dart ← 重命名 file + class
├── lib/theme/app_colors.dart                    ← appCenter* → appFormApplication*
├── lib/theme/theme.dart                         ← ThemeExtension 註冊跟著改名
├── lib/route/app_router.dart                    ← +3 RouteName +3 GoRoute；-1 舊路由
├── lib/injection/dependency_injection.dart      ← +3 bloc 註冊；-1 舊 bloc
└── lib/page/home/home_page.dart                 ← drawer 由 1 ListTile → 3 ListTile
```

---

## 八、BLoC 事件設計

### 8.1 ApplicationCreateBloc

```
Events:
  InitEvent(employeeId)               ← 載入 availableForms
  RefreshEvent                        ← 手動重抓
  UpdateSearchQueryEvent(query)       ← 過濾 grid
  SelectFormToApplyEvent(formId, bindingId)  ← 跳 form_run
  NavigationHandledEvent              ← 清 navigateRoute
  CompleteStatusEvent                 ← 清 message / status

State 欄位：
  status / message / messageRequestId
  employeeId / currentEmployee
  availableForms / searchQuery
  navigateRoute / navigateExtra
  filteredForms (getter)
```

### 8.2 MyApplicationBloc

```
Events:
  InitEvent(employeeId)               ← 載入 mySubmissions
  RefreshEvent                        ← 手動重抓
  RequestExportJsonEvent              ← 觸發匯出
  CompleteStatusEvent                 ← 清 message / status

State 欄位：
  status / message / messageRequestId
  employeeId / currentEmployee
  mySubmissions
  exportJson / exportDialogRequestId
```

### 8.3 SignOffPendingBloc（空殼）

```
Events:
  InitEvent(employeeId)               ← v1 直接 emit 空 list

State 欄位：
  status / message
  employeeId / currentEmployee
  pendingItems : List<dynamic>        ← v1 永遠空
```

handler 邏輯：
```
_onInit():
  emit(success, pendingItems: [])
```

---

## 九、建議開發順序

```
Phase A — 基礎設施（共用層先就位）
  ├── A1: Service 加兩個聚焦 method
  │     ├── loadAvailableForms(employeeId)
  │     └── loadMySubmissions(employeeId)
  ├── A2: Theme 重命名（檔名 + class + AppColors 常數）
  ├── A3: Route 常數新增（applicationCreatePage / myApplicationPage / signOffPendingPage）
  ├── A4: 共用 widget 搬到 lib/page/form_application/widgets/
  │     └── application_header_widget.dart
  └── A5: flutter analyze 0 errors（確認重命名 / 加常數沒打壞既有）

Phase B — 三個 page 實作
  ├── B1: application_create
  │     ├── 1.1 bloc/event/state（重用既有事件名稱）
  │     ├── 1.2 page（搬 search_bar + form_grid widget）
  │     ├── 1.3 DI 註冊 ApplicationCreateBloc
  │     ├── 1.4 GoRoute 註冊
  │     └── 1.5 smoke test：navigate to → bloc init → grid render
  ├── B2: my_application
  │     ├── 2.1 bloc/event/state
  │     ├── 2.2 page（搬 submission widget）
  │     ├── 2.3 DI 註冊 MyApplicationBloc
  │     ├── 2.4 GoRoute 註冊
  │     └── 2.5 smoke test：navigate to → bloc init → list + export 都正常
  └── B3: sign_off_pending（空殼）
        ├── 3.1 bloc/event/state（最簡：init 直接 emit 空 list）
        ├── 3.2 page（empty_state widget 顯示「尚未實作」）
        ├── 3.3 DI 註冊 SignOffPendingBloc
        ├── 3.4 GoRoute 註冊
        └── 3.5 smoke test：navigate to → 看到提示

Phase C — 整合與清理
  ├── C1: HomePage drawer 改造（1 → 3 ListTile）
  ├── C2: 端到端 smoke
  │     ├── drawer 點三項都能進對應 page
  │     ├── 切換身分後三頁都會重新 init
  │     └── 「新增申請」→ form_run → 送單 → 回「我的申請」可看到該筆
  ├── C3: 刪除 form_application_center 整個資料夾
  ├── C4: 刪 RouteName.formApplicationCenterPage 常數 + GoRoute + DI 註冊
  ├── C5: 刪 FormApplicationService.initialize（已被聚焦 method 取代）
  └── C6: flutter analyze 0 errors（最終驗證）
```

每個葉節點步驟可獨立驗證（編譯 + 手動 smoke），都應該 ≤ 半天。

---

## 十、待確認事項

- [ ] **Service 拆分粒度** — 建議方案：保留 `FormApplicationService` 單一服務，新增兩個聚焦 method（不拆三 service）。**若你偏好嚴格 1 page = 1 service，可改為拆三個 service，但會引入欄位重複與重整成本。**
- [ ] **Theme 重命名範圍** — 建議方案：檔名 + class 名 + AppColors 常數一次改完（lossy 一次性遷移）。**若擔心多處 git 衝突，可只改 class 名、檔名留 form_application_center_theme_colors.dart。**
- [ ] **共用 ApplicationHeaderWidget 的位置** — 建議方案：`lib/page/form_application/widgets/`（頁面 group 共用）。**若覺得「跨頁共用」門檻不該用 widgets/，可考慮放 lib/widgets/global/。**
- [ ] **「待我簽核」UI 提示文案** — 建議方案：「待我簽核功能將於簽核流程模組完成後上線」+ 連結到 sign_off 規劃文件。
- [ ] **drawer 三個 entry 排序** — 建議方案：新增申請 → 我的申請 → 待我簽核（依使用頻率 / 流程順序）。
- [ ] **是否保留 `FormApplicationService.initialize` 為向下相容** — 建議方案：Phase C5 一併刪除（沒人引用時就清掉）。
- [ ] **「新增申請」送單後的回流體驗** — 建議方案：form_run 送單成功 → snack bar「已送出」+ pop 回 application_create（不主動跳 my_application；使用者自己決定下一步）。
- [ ] **「我的申請」是否提供 detail 子頁** — 建議方案：v1 不做（list 顯示 status chip 即可）；v2 點某筆進 detail。
- [ ] **「待我簽核」要不要先預備 SignOffPendingService 介面** — 建議方案：v1 不建，bloc 內直接 emit 空 list；等 sign_off 完成再加 service。

---

## 十一、後續階段（v2 以後）

- **「我的申請」detail 子頁** — 點某筆 submission 看欄位內容、簽核進度、退件原因
- **「待我簽核」實作** — 配合 sign_off_initiation 完成，新增：
  - `SignOffInstance` model（誰送的、目前在哪一節點）
  - `SignOffPendingItem` model（給我簽的個別任務）
  - `SignOffService.loadPendingByApprover(approverId)`
  - 通過 / 退件 / 加簽 action handler
- **未讀計數 badge** — drawer 三個 entry 各自顯示 unread badge（待我簽幾筆、我的單最近狀態變化）
- **真 API 串接** — 三個 service method 換成 DioClient 呼叫；mock 過渡
- **paging / filter** — 大量資料時 list 加分頁與多維過濾
