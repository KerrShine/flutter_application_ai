# 簽核流程 — 實作現狀與 Phase A/B 功能對照

> **目的**：當你回來看簽核流程的程式碼，**先讀這份**，避免把「設定欄位」誤當「已實作功能」。
>
> **背景**：依 [sign_off_system.md](../system_docs/system/sign_off_system.md) 切分為三階段：
>
> - **Phase A 簽核設定** ✅ 已完成 — 模板編輯器 + 節點 / 規則 / 條件「資料」
> - **Phase B 執行簽核** ❌ 待做 — 任務派發 / 動作 / 退回 / SLA 計時 / 會簽收斂
> - **Phase C 歸檔 / 報表** ❌ 待做
>
> Phase A 的本質**就是**設定階段，所有節點欄位都是「待 Phase B 消費的資料」。這份文件清楚標示哪些已經能跑、哪些只是存在 model 裡。

---

## 1. 已可用的功能（Phase A 範圍）

| 功能 | 狀態 | 備註 |
|------|------|------|
| 模板 CRUD | ✅ | manager 列表 / editor 新增、編輯、刪除、啟用切換、匯出 JSON |
| 模板持久化 | ✅ | LocalStorage key: `sign_off_templates_key` |
| `validateTemplate` | ✅ | 設定階段檢查（節點未綁部門、Rule 引用失效節點、between 缺 valueMax 等） |
| `resolveApproverChain` | ✅ | 純函式可解析「假設這申請人 + form data → 該簽哪些人」**但無 UI 觸發** |
| 編輯器 SLA 過期預覽 | ✅ | 輸入「N 天前」即時看節點過期 chip |
| 編輯器 Path Rule 預覽 | ✅ | 輸入欄位值即時看哪些節點被啟用 / 暗化 |
| 完整鏈解析預覽 dialog | ✅ | 模擬「假設申請人 + form data」呼叫 `resolveApproverChain`，顯示 ResolvedApprover 卡片列（詳見 §7） |
| 對應表單條件欄位狀態指示 | ✅ | Header 表單下拉 + chip 顯示 ✅/❌ 條件欄位定義狀態，引導使用者先去「表單條件欄位」定義 fieldKey 才能設條件 |
| 表單條件欄位 (form_condition_field) 模組 | ✅ | 獨立模組，per-form 一筆 draft；提供 Direct / DateDiff / Sum / Concat 4 種計算函式；sign_off path rule 從此模組消費 fieldKey 列表（詳見 §4.10） |

---

## 2. 節點欄位 audit — 設定 vs 真實功能

狀態符號：
- ✅ **完整功能**：設定 + 執行邏輯都有
- ⚠️ **半功能**：設定 + 部分視覺，但無真實執行
- ❌ **純設定資料**：欄位存在但執行邏輯尚未實作，等 Phase B

| 欄位 / 概念 | 設定 UI | 解析功能 | 執行邏輯 | 註記 |
|------------|---------|---------|---------|------|
| `nodeType.approve` | ✅ | ✅ | ❌ | 沒有「同意/拒絕/退回」動作執行 |
| `nodeType.countersign` | ✅ | ✅ | ❌ | 沒有多人收斂 |
| `nodeType.notify` | ✅ | ✅ | ❌ | 沒有「不影響流程，僅通知」執行 |
| `approverMode.hierarchyManager` | ✅ | ✅ | ❌ | 解析正確，無人接收結果 |
| `approverMode.crossLevel` | ✅ | ✅ | ❌ | 同上 |
| `approverMode.designatedRole` | ✅ | ✅ | ❌ | 同上 |
| `approverMode.designatedEmployee` | ✅ | ✅ | ❌ | 同上 |
| `approverMode.applicantSelf` | ✅ | ✅ | ❌ | 同上 |
| `approverMode.applicantAncestorManager` | ✅ | ✅ | ❌ | 同上 |
| `approverMode.applicantManagerAtDepth` | ✅ | ✅ | ❌ | 同上 |
| `multiStrategy` (all/any/sequential) | ✅ | — | ❌ | 純設定，無多人收斂執行 |
| `returnPolicy` + `returnTargetNodeId` | ✅ | — | ❌ | 沒有「退回 → 跳到 X 關」執行 |
| `slaDays` | ✅ | — | ⚠️ | 編輯器有過期預覽 chip；無真實計時 / 提醒 / 升級 |
| `allowAddSigner` | ❌ | — | ❌ | 規劃 v2，UI 未做 |
| `applicantAncestorOffset` | ✅ | ✅ | ❌ | 解析功能完整 |
| `applicantTargetDepthLevel` | ✅ | ✅ | ❌ | 解析功能完整 |
| `pathRules` (整套規則路由) | ✅ | ✅ (純函式) | ⚠️ | 編輯器有規則預覽；無真實「提交時凍結」 |

---

## 3. Phase B 待實作清單（依 sign_off_system.md §基礎簽核流程）

### 3.1 申請中心 — 申請人視角
- [ ] 表單提交入口：依 `form_launch_permission` 過濾可用表單
- [ ] 提交時呼叫 `SignOffService.resolveActivatedNodeIds(template, formData)` 凍結 path
- [ ] 提交時呼叫 `SignOffService.resolveApproverChain(template, applicantId, formData)` 凍結 approver chain
- [ ] 持久化「簽核任務實例」(`SignOffInstance`) — 凍結後的 path + 簽核人 + 表單快照
- [ ] 申請人列表：我的申請（進行中 / 已結案）
- [ ] 申請進度檢視

### 3.2 簽核任務列表 — 簽核人視角
- [ ] 「我的待辦」列表
- [ ] 篩選 / 排序 / 搜尋
- [ ] 點擊任務 → 進入詳情頁

### 3.3 簽核動作（核心）
- [ ] 同意 → 推進下一節點
- [ ] 拒絕 → 流程終止
- [ ] 退回 → 依 `returnPolicy` 跳到對應節點
  - `toApplicant` → 退到申請人補件
  - `toPrevious` → 上一關
  - `toSpecific` + `returnTargetNodeId` → 指定關
- [ ] 補件 / 補充說明
- [ ] 加簽（v2）
- [ ] 轉派（v2）

### 3.4 會簽收斂（`multiStrategy` 才會用到）
- [ ] `all` — 收齊所有同意才推進
- [ ] `any` — 任一同意即推進
- [ ] `sequential` — 依序進行，前一人完成才通知下一人

### 3.5 SLA 計時 / 提醒 / 升級
- [ ] 任務啟動時打 timestamp
- [ ] 排程：定期 check 是否超 `slaDays`
- [ ] 過期通知（推播 / Email / In-app）
- [ ] v2: 自動升級給上層主管

### 3.6 知會節點 (notify) 行為
- [ ] 流程到 notify 節點時：推送通知給該節點對應人，**不阻擋**直接推進下一節點
- [ ] 留痕（誰被通知了、何時）

### 3.7 歷程留痕（為 Phase C 鋪路）
- [ ] 每次動作 append-only 記錄
- [ ] 不可修改 / 不可刪除

---

## 4. 容易混淆的點 — 看到先警覺

### 4.1 「我設了 SLA 3 天，為什麼沒有提醒？」
SLA 目前**只在編輯器內**用模擬預覽 chip 顯示。真實計時 / 提醒要等 Phase B SLA 模組（§3.5）。

### 4.2 「我設了退回策略，怎麼沒有退回按鈕？」
`returnPolicy` 是設定資料。退回動作要等 Phase B 簽核動作模組（§3.3）。

### 4.3 「我設了 Path Rules，提交申請時走哪條規則了？」
目前**沒有提交申請的入口**。Phase B 申請中心建好後，提交時才會呼叫 `SignOffService.resolveActivatedNodeIds()` 凍結。

### 4.4 「會簽多人策略改了還是只算一人」
`multiStrategy` 純設定，多人收斂在 Phase B 執行階段做（§3.4）。

### 4.5 「拖了部門到畫布、設了相對申請人模式，這些到底會不會被用到」
**會**，但要等 Phase B。所有 approverMode 的解析邏輯（`resolveApproverChain`）已實作，Phase B 只要在提交時呼叫即可。

### 4.6 「`crossLevel` 同層互簽連線畫出來了，會自動執行嗎？」
不會。同層互簽連線只是**設定 + 視覺**，提交後實際依「同層互簽 → 該節點主管」做解析（已實作），但「同時間派發 / 收斂」要等 Phase B。

### 4.7 「規則預覽到底在預覽什麼？」
模擬「假設使用者真的提交一份這樣的表單，會走哪些節點」。**只算路徑啟用 / 跳過，不算簽核人是誰**。
完整說明見 §6「規則預覽功能詳解」。

### 4.9 「下拉選表單時看到 ✅/❌ 圖示是什麼意思？」
代表該表單在「**表單條件欄位 (form_condition_field)**」的定義狀態：
- ✅ 已定義：draft 中至少有 1 個 ConditionFieldDefinition → 可設 path rule 條件
- ❌ 未定義：draft 不存在或 definitions 為空 → 條件功能無欄位可選

選了表單後 header 會顯示 chip（含定義個數），點擊跳轉至「表單條件欄位」編輯器。
未定義條件欄位的表單**仍可**作純線性簽核（不需 path rules），只是無法做條件路由。

### 4.8 「為什麼設了 path rule 條件還是只走 default？」
歷史變遷：
- **早期 v0**：`condition.fieldId` 存 `DesignerItem.id`（UUID）；form data 的 key 是 outputKey → 對不上、永不命中
- **過渡 v1**：改用 form_data_binding 的 outputKey（解決 key 對應問題）；但無法處理計算欄位（如「請假天數」需從 start/end 算）
- **目前 v2**：condition.fieldId = form_condition_field 的 **fieldKey**（穩定 + 含計算邏輯）

現在 `loadFormFields` 改從 `ConditionFieldService.loadDraft(formId)` 取資料，condition.fieldId = fieldKey。
**設條件前必須先到「表單條件欄位」定義 fieldKey + 計算公式** — 沒定義時 dialog 顯示 banner +
跳轉按鈕引導使用者前往。

舊測試資料（fieldId = outputKey 或 id 的 condition）會因 key 對不上而永不命中，**重設即可**。

### 4.10 「為什麼條件欄位不在 form_data_binding 而是另一個地方？」
**功能解耦原則**：
- `form_data_binding`：定義「表單欄位 → 提交 / API 鍵」對應，主要消費者是 runtime 提交
- `form_condition_field`：定義「條件比對用的衍生欄位（含計算公式）」，主要消費者是 sign_off path rule（將來：報表 / 通知條件等）

若塞同一處：
- form_data_binding 結構複雜化（多了「計算欄位」概念）
- 提交流程必須跳過計算欄位（噪音）
- 將來其他「條件消費者」（報表篩選、通知條件）只能繞道讀 binding，語意混亂

獨立 module 讓條件邏輯成為一等公民，跨消費者共用更乾淨。完整設計見
[docs/planning/form_condition_field_planning.md](form_condition_field_planning.md)。

---

## 5. 開始 Phase B 之前建議先做的事

1. ~~**驗證 Phase A 解析正確性**：加 `PreviewApproverChainEvent` UI~~ ✅ **已完成** — 見 §7「完整鏈解析預覽 dialog」
   - ~~dialog 輸入「假設申請人」+「假設 form data」→ 顯示完整 `ResolvedApprover[]`~~
   - ~~確保 `resolveApproverChain` 在各 mode 組合下解析正確~~
   - ~~工程量小、CP 值高~~
2. **設計 `SignOffInstance` model**：「簽核任務實例」結構
   - 凍結 template snapshot + form data + approver chain + 各節點當前狀態
3. **設計 `SignOffActionLog` model**：append-only 動作歷程
4. **盤點 Repository 介面**：`SignOffInstanceRepository` / `SignOffActionLogRepository`

---

## 6. 規則預覽（Rule Preview）功能詳解

> 編輯器 header 右上角的「規則預覽」toggle。這是 Phase A 階段最容易被誤解的功能，所以單獨開一節說清楚。

### 6.1 解決什麼問題

設定者在屬性面板上設了一堆 path rules（例：請假天數 <= 7、<= 30、default），但**設定當下無法驗證**：
- 規則順序對嗎？
- 用 `>` 還是 `>=`？
- default rule 真的有 fallback 嗎？
- 哪些節點被啟用、哪些被跳過？

正常情境下要等 **Phase B 申請中心**做完，使用者真實提交申請後才看得到結果。但 Phase B 還沒做，**設定錯了無從察覺**。

規則預覽就是在編輯器內模擬「假設使用者真的提交一份這樣的表單，會走哪些節點」。

### 6.2 怎麼用

1. 編輯器 header 右上角有兩個 toggle，第二個就是「規則預覽」
2. 開啟後展開：依當前選中的表單，列出所有可條件比對的欄位輸入框（請假天數、金額、類型...）
3. 任何一格輸入即時觸發：
   - 評估所有 pathRules（依 sortOrder 由上而下）
   - 找出第一個命中的 rule
   - 取該 rule 的 `activatedNodeIds`
4. 畫布上：**被啟用節點正常顯示、被跳過節點暗化（opacity 0.35）**

### 6.3 具體例子

請假流程模板：
```
Origin pathRules:
  Rule 1 「短假」: 請假天數 <= 7  → [Node1 直屬, Node2 BU]
  Rule 2 「中假」: 請假天數 <= 30 → [Node1 直屬, Node2 BU, Node3 事業群]
  Rule 3 default               → [Node1, Node2, Node3, Node4 總經理]
```

| 預覽輸入「請假天數」 | 命中規則 | 畫布狀態 |
|---|---|---|
| `5` | Rule 1 短假 | Node1, Node2 正常；Node3, Node4 **暗化** |
| `15` | Rule 2 中假 | Node1~3 正常；Node4 **暗化** |
| `60` | Rule 3 default | 全部正常 |
| `(空白)` | Rule 3 default | 全部正常（rules 1, 2 的數值比較對空字串都 false） |

### 6.4 它「不」做什麼

| 你以為它會 | 實際情況 |
|------------|---------|
| 顯示「實際簽核人是誰」 | ❌ 只顯示哪些「節點」被啟用，不解析人。要看人需另外加 `PreviewApproverChainEvent` UI（§5 已列） |
| 模擬「申請真的送出」 | ❌ 純前端視覺；不會寫入任何任務 / 不會通知任何人 |
| 同時模擬 SLA 過期 | ❌ 是另一個 toggle「過期預覽」，獨立運作 |
| 模擬退回 / 加簽 / 會簽收斂 | ❌ 那些是 Phase B 執行邏輯，預覽只能看「初始凍結 path」 |
| 跨 form 比對 | ❌ 只列**目前選中表單**的欄位 |

### 6.5 與「SLA 過期預覽」的差異

| 項目 | 過期預覽 | 規則預覽 |
|------|---------|---------|
| 模擬什麼 | 時間（N 天前發起） | 表單值（fieldId → value） |
| 視覺效果 | 節點 chip 變紅 / 黃 / 綠 | 節點整體暗化 / 正常 |
| 用到的純函式 | `simulationStatusByNodeId` getter | `resolveActivatedNodeIds`（與 Phase B 將共用） |
| 影響的節點 | 全部 approver 節點 | 視 `Rule.activatedNodeIds` 而定 |

兩個 toggle 可同時開 → 「假設 N 天前發起且填了這些表單值」→ 同時看到啟用節點與其過期狀態。

### 6.6 實作關鍵保證

UI 預覽呼叫的是 `SignOffService.resolveActivatedNodeIds` **純函式**，與將來 Phase B 真實提交會呼叫的是**同一支**。

**Key 對齊保證**：condition.fieldId 儲存的是 form_data_binding 設的 **outputKey**，
與 [`form_run_service.dart:163-164`](../../lib/service/form_run_service.dart) `params[fv.outputKey] = effective`
真實提交時用的 key 完全一致。

所以你在預覽看到的結果 = Phase B 上線後真實送出申請的結果（前提：表單值相同）。**預覽通過 = 邏輯通過**，不會有「設定時看起來對、上線後跑起來不對」的落差。

### 6.7 程式碼位置

| 角色 | 檔案 |
|------|------|
| 計算（純函式 + state getter） | [`lib/page/sign_off/sign_off_editor/bloc/sign_off_editor_state.dart`](../../lib/page/sign_off/sign_off_editor/bloc/sign_off_editor_state.dart) — `activatedNodeIdsByPreview` |
| 純函式本體 | [`lib/service/sign_off_service.dart`](../../lib/service/sign_off_service.dart) — `resolveActivatedNodeIds` / `evaluatePathRule` / `evaluatePathCondition` |
| 視覺（節點暗化） | [`lib/page/sign_off/sign_off_editor/widgets/units/sign_off_node_card.dart`](../../lib/page/sign_off/sign_off_editor/widgets/units/sign_off_node_card.dart) — `isInactivatedByRulePreview` prop |
| UI 控制列（toggle + 欄位輸入） | [`lib/page/sign_off/sign_off_editor/sign_off_editor_page.dart`](../../lib/page/sign_off/sign_off_editor/sign_off_editor_page.dart) — `_buildRulePreviewControls` |

---

## 7. 完整鏈解析預覽 Dialog

> 編輯器 header 右上角的「預覽簽核鏈」按鈕（與「過期預覽」「規則預覽」並列為第 3 個工具）。

### 7.1 解決什麼問題

`SignOffService.resolveApproverChain` 已實作 6 種 `approverMode` + Path Rules 的解析，但若無 UI，設定者無法驗證：
- 6 種 mode 在不同申請人位置下，真的解出**對的**人嗎？
- Path Rules 過濾後最終鏈是哪幾關？
- 哪些節點解不到人（部門無主管 / 組織樹中斷 / 指定員工不存在）？

Phase B 還沒做，所以這個 dialog 是設定階段「驗證解析正確性」的唯一管道。

### 7.2 怎麼用

1. 編輯器 header 點「預覽簽核鏈」→ 開 dialog
2. 選申請人（dropdown 顯示在職員工 + 角色）
3. 填表單欄位假設值（依當前選中表單動態列）
4. 按「執行解析」→ async 呼叫 service → 結果卡片列
5. 想試別組合 → 改參數 → 再按一次

### 7.3 結果卡片狀態

| 顯示 | 意義 |
|------|------|
| 🟢 綠卡 + ✓ + approver 名稱 / 角色 | 節點已成功解析出人 |
| 🔴 紅卡 + ✗ + `unresolvedReason` | 解析失敗（部門無主管 / 組織樹不足 / 員工不存在等） |
| 灰色徽章「限 X 天」 | 節點有設 SLA |

### 7.4 它「不」做什麼

- **不**列出被 path rules 過濾掉的節點 — service 已內部過濾。想看哪些被過濾，請另外開「規則預覽」toggle 看 canvas 暗化
- **不**模擬「點同意推進到下一節點」— 那是 Phase B 執行邏輯
- **不**寫入任何任務、不通知任何人
- **不**自動解析（避免每次輸入都觸發 async）— 手動按按鈕

### 7.5 與其他預覽功能的整體分工

| 工具 | 模擬什麼 | 核心函式 | 結果呈現 |
|------|---------|---------|---------|
| 過期預覽 | 時間 N 天前 | `simulationStatusByNodeId` | Canvas chip 變色 |
| 規則預覽 | 表單值 | `resolveActivatedNodeIds` | Canvas 節點暗化 |
| **預覽簽核鏈** | 申請人 + 表單值 | `resolveApproverChain` (async) | Dialog 卡片列 |

三者可組合使用：開「規則預覽」看哪些節點被啟用 → 開「預覽簽核鏈」看那些節點各自解出誰 → 開「過期預覽」看誰會超時。

### 7.6 程式碼位置

| 角色 | 檔案 |
|------|------|
| Dialog widget（含 state + 解析觸發 + 結果渲染） | [`lib/page/sign_off/sign_off_editor/widgets/units/sign_off_preview_chain_dialog.dart`](../../lib/page/sign_off/sign_off_editor/widgets/units/sign_off_preview_chain_dialog.dart) |
| Header 按鈕觸發 | [`lib/page/sign_off/sign_off_editor/sign_off_editor_page.dart`](../../lib/page/sign_off/sign_off_editor/sign_off_editor_page.dart) — `_buildHeaderRow` 內呼叫 `showSignOffPreviewChainDialog` |
| 解析核心 | [`lib/service/sign_off_service.dart`](../../lib/service/sign_off_service.dart) — `resolveApproverChain` |

### 7.7 進 Phase B 後的演進

Phase B 上線後，使用者真實提交申請會呼叫**同一支** `resolveApproverChain`。
**預覽通過 = 真實提交也會解出同樣結果**（前提：申請人 + form data 相同）。

Dialog 角色不變 — 仍是設定者驗證工具，只是真實使用情境多了一個「真的提交」的路徑。

---

## 維護指引

- 每次新增節點欄位時，**回來這份文件補一列** §2
- Phase B 完成某項時，把對應欄位的「執行邏輯」狀態從 ❌ 改成 ✅
- Phase A 本身有改動（如新 approverMode / 新 enum value）也要更新 §2 表格
- 「容易混淆的點」§4 — 自己踩到的坑就補上一條，幫助未來的自己 / 隊友
- 「規則預覽」邏輯改動時（如新增 operator、新 fieldType）→ 同步更新 §6.3 範例 / §6.6 純函式說明
