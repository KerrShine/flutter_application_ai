# 表單事件綁定（Action Binding）

涵蓋模組：form_action_binding

---

## 概念

事件綁定定義「表單元件在特定觸發時機下要執行什麼行為」。
與資料綁定共用同一份 `FormDataBindingDraft`，設定寫入 `draft.actions`。

目前定位為**事件行為宣告編輯器**，定義 action 規格，由後續執行層（form_run 或後端）實際執行。

### 事件來源
目前只有兩種元件類型可作為事件來源：
- **button** — 流程動作型事件來源
- **dropdown** — 資料事件型事件來源

---

## form_action_binding — 事件行為設定

**路由：** `/home/form-manage/form-data-binding/form-action-binding`

**入口：** 從 form_data_binding 頁點選事件型元件（button / dropdown）進入

### UI 佈局

| 區域 | Widget | 說明 |
|------|--------|------|
| 左側 | ActionBindingSourceListWidget | 事件來源清單（buttons + dropdowns），可搜尋 |
| 中央 | ActionBindingPlannerWidget | 選定來源的觸發器與動作設定 |
| 右側 | ActionBindingInspectorWidget | 動作詳細資訊 / 提示 |

### 操作

| 操作 | 說明 |
|------|------|
| 選擇事件來源 | 選擇 button 或 dropdown 元件 |
| 選擇觸發器 | buttonPressed / dropdownLoaded / dropdownChanged |
| 選擇動作類型 | navigate / callApi / loadDropdownOptions 等 |
| 新增動作 | 同一觸發器可設多個動作（依序執行） |
| 刪除動作 | 移除已設定的動作 |
| 排序動作 | 上移/下移調整執行順序 |
| 設定 API | 從 API Picker 選擇目標 API |
| 設定路由 | 從 Route Picker 選擇導航目標 |
| 設定參數名稱 | loadDropdownOptions 專用，指定 response 取值 key |
| 儲存設定 | 寫回 draft.actions |
| 匯出預覽 | JSON 預覽目前設定 |

### 觸發器類型（ActionTriggerType）

| 觸發器 | 適用元件 | 說明 |
|--------|----------|------|
| buttonPressed | button | 按鈕點擊 |
| dropdownLoaded | dropdown | 下拉元件載入完成 |
| dropdownChanged | dropdown | 下拉選項變更 |

### 動作類型（ActionType）

| 動作 | 說明 | 需要的額外欄位 |
|------|------|----------------|
| navigate | 頁面跳轉 | navigateRoute |
| saveDraft | 儲存草稿 | — |
| submitForm | 送出表單 | apiId + navigateRoute |
| callApi | 呼叫 API | apiId |
| loadDropdownOptions | 載入下拉選項 | apiId + parameterName |
| refreshTarget | 重新整理目標元件 | targetItemId |
| setFieldValue | 帶入欄位值 | targetItemId |
| other | 其他 | — |

### API 來源分流

| 動作類型 | API 清單來源 | JSON 檔案 |
|----------|-------------|-----------|
| callApi / submitForm | form_button_action_api_sample.json | 按鈕/送出用 API |
| loadDropdownOptions | dropdown_options_sample.json | 下拉選單用 API |

---

## BLoC Events（15 個）

| Event | 說明 |
|-------|------|
| InitEvent(formId, bindingId, initialSourceItemId) | 載入設定 |
| SelectSourceItemEvent(itemId) | 選擇事件來源 |
| SelectTriggerEvent(trigger) | 選擇觸發器 |
| SelectActionEvent(action) | 選擇動作（替換） |
| AddActionEvent(action) | 新增動作（追加） |
| RemoveActionEvent(actionId) | 刪除動作 |
| MoveActionUpEvent(actionId) | 上移 |
| MoveActionDownEvent(actionId) | 下移 |
| UpdateActionApiIdEvent(actionId, apiId) | 設定 API |
| UpdateActionNavigateRouteEvent(actionId, route) | 設定路由 |
| UpdateActionParameterNameEvent(actionId, parameterName) | 設定參數名稱 |
| UpdateSearchKeywordEvent(keyword) | 搜尋來源 |
| SaveActionSettingsEvent | 儲存 |
| RequestExportPreviewEvent | 匯出預覽 |
| CompleteStatusEvent | 重設狀態 |

## State 重要欄位

| 欄位 | 說明 |
|------|------|
| sourceItems | 所有可用事件來源（含 availableTriggers, suggestedActions） |
| selectedSourceItemId | 目前選中的來源 |
| selectedTrigger | 目前選中的觸發器 |
| actions | 所有已設定的動作清單 |
| selectedTriggerActions | 目前觸發器下的動作（computed） |
| apiList | 按鈕/送出 API 清單 |
| dropdownApiList | 下拉選單 API 清單 |

---

## 動作資料模型：FormActionBindingDraft

```
FormActionBindingDraft
├── actionId          — 唯一 ID
├── sourceItemId      — 事件來源元件 ID
├── sourceLabel       — 來源顯示名稱
├── sourceType        — button / dropdown
├── triggerType       — buttonPressed / dropdownLoaded / dropdownChanged
├── actionType        — navigate / callApi / loadDropdownOptions 等
├── enabled           — 啟停開關
├── targetItemId      — 目標元件 ID（setFieldValue / refreshTarget）
├── targetLabel       — 目標顯示名稱
├── navigateRoute     — 導航路由路徑
├── description       — 自動產生的描述（如「點擊事件 -> 呼叫API」）
├── apiId             — API 定義 ID
├── parameterName     — response 取值 key（loadDropdownOptions 專用）
└── order             — 執行順序（同 source + trigger 內排序）
```

---

## Service

**檔案：** `form_action_binding_service.dart`

| 方法 | 說明 |
|------|------|
| `initialize(formId, bindingId)` | 載入 draft + 建立事件來源清單 + 載入 API 清單 |
| `saveActionSettings(draft, actions)` | 將 actions 寫回 draft 並儲存 |
| `buildActionPlanPreviewJson(...)` | 產生 JSON 預覽 |
| `buildActionPlanPreviewJsonFromState(...)` | 從 state 直接產生預覽 |

**初始化資料（FormActionBindingInitialData）：**
- draft — 綁定草稿
- actionSources — 事件來源清單
- previewJson — JSON 預覽
- apiList — 按鈕 API
- dropdownApiList — 下拉 API

---

## 目前狀態

| 項目 | 狀態 |
|------|------|
| 事件來源識別 | ✅ button + dropdown |
| 觸發器選擇 | ✅ 3 種 |
| 動作設定 | ✅ 8 種動作類型 |
| 多動作排序 | ✅ 同觸發器下多動作依序 |
| API Picker | ✅ 含分流（button API / dropdown API） |
| Route Picker | ✅ 含系統路由清單 |
| 參數名稱設定 | ✅ loadDropdownOptions 專用 |
| 儲存/匯出 | ✅ localStorage |

**尚未實作：**
- refreshTarget / setFieldValue 的 targetItemId picker UI（目前可手動填入但無選擇器）
