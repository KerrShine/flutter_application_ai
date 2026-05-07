# 表單資料綁定（Data Binding）

涵蓋模組：form_select / form_data_manager / form_data_binding

---

## 概念

資料綁定定義「表單欄位如何輸出資料」：
- 每個欄位對應一個 outputKey（JSON 輸出鍵名）
- 可設定空值策略（跳過 / 自訂預設值）
- 一份表單可有多份綁定草稿（多種輸出規格）
- 綁定草稿同時承載事件行為設定（actions）

**核心模型：FormDataBindingDraft**（詳見下方）

---

## 1. form_select — 選擇表單

**路由：** `/home/form-manage/form-select`

**功能：** 選擇要進行綁定管理的表單。

| 操作 | 說明 |
|------|------|
| 格狀檢視 | 響應式 1~3 欄表單卡片 |
| 搜尋篩選 | 關鍵字即時篩選表單 |
| 選擇表單 | 跳轉 form_data_manager |

**BLoC Events：**
- `InitEvent` — 載入所有表單
- `UpdateSearchQueryEvent(query)` — 搜尋
- `NavigateToBindingEvent(formId)` — 跳轉
- `CompleteNavigationEvent` — 重設導航狀態

**Service：** `form_select_service.dart`
- `loadForms()` → `Result<List<FormModel>>`

---

## 2. form_data_manager — 綁定清單管理

**路由：** `/home/form-manage/form-data-manager`

**功能：** 管理單一表單下的所有綁定草稿。

| 操作 | 說明 |
|------|------|
| 檢視綁定清單 | 左側 sidebar 列出所有綁定，含健康狀態指標 |
| 選擇綁定 | 右側顯示欄位綁定對照表 |
| 新增/編輯綁定 | 跳轉 form_data_binding |
| 刪除綁定 | 確認後刪除 |
| 匯出 JSON | 匯出所有綁定設定 |
| API 匯出預覽 | 預覽 API 格式輸出 |

### 綁定健康狀態（BindingHealthStatus）
| 狀態 | 說明 |
|------|------|
| healthy | 所有欄位已綁定 |
| warning | 有未綁定欄位 |
| outdated | 模板版本不一致 |

**BLoC Events（10 個）：**
- `InitEvent(formId)` — 載入表單 + 綁定清單
- `SelectBindingEvent(bindingId)` — 切換綁定
- `NavigateToDataBindingEvent(formId, bindingId)` — 編輯
- `RequestDeleteBindingEvent(bindingId) / DeleteBindingEvent(bindingId)` — 刪除流程
- `ExportJsonEvent / PreviewApiExportEvent` — 匯出
- `CompleteNavigationEvent / CompleteDeleteDialogEvent / CompleteExportJsonPreviewEvent` — 狀態重設

**State 特殊欄位：**
- `bindings: List<BindingSummary>` — 含 id, name, isEnabled, healthStatus, unmappedCount, warningCount
- `fieldBindings: List<FieldBindingItem>` — 每個欄位的綁定狀態

**Service：** `form_data_manager_service.dart`
- `initialize(formId)` → `Result<FormDataManagerInitialData>`
- `deleteBinding(formId, bindingId)` → `Result<bool>`

---

## 3. form_data_binding — 欄位資料綁定

**路由：** `/home/form-manage/form-data-binding`

**功能：** 編輯單一綁定草稿中每個欄位的輸出規格。

| 操作 | 說明 |
|------|------|
| 設定 outputKey | 欄位輸出的 JSON 鍵名 |
| 設定空值策略 | skip（跳過）/ custom（自訂預設值） |
| 設定自訂預設值 | 空值時填入的替代值 |
| 啟用/停用綁定 | 整份綁定的總開關 |
| 前往事件綁定 | 跳轉 form_action_binding，帶入 sourceItemId |
| 儲存草稿 | 驗證後存入 localStorage |
| 匯出 JSON | 預覽綁定設定 |

**BLoC Events（11 個）：**
- `InitEvent(formId, bindingId)` — 載入
- `UpdateOutputKeyEvent(sectionId, itemId, outputKey)` — 設定輸出鍵
- `UpdateNullStrategyEvent(sectionId, itemId, nullStrategy)` — 空值策略
- `UpdateCustomDefaultValueEvent(sectionId, itemId, value)` — 預設值
- `UpdateBindingEnabledEvent(isEnabled)` — 啟停
- `RequestSaveDraftEvent / ConfirmSaveDraftEvent(bindingName)` — 儲存流程
- `RequestNavigateToActionBindingEvent(sourceItemId)` — 前往事件綁定
- `ExportJsonPreviewEvent` — 匯出
- `CompleteStatusEvent / CompleteNavigationEvent` — 狀態重設

**驗證規則（validateDraft）：**
- outputKey 格式檢查
- 自訂預設值型別檢查（number/date 格式）
- 回傳 `Map<String, String>` 欄位錯誤

**Service：** `form_data_binding_service.dart`
- `initialize(formId, bindingId)` → `Result<FormDataBindingDraft>`
- `saveDraft(draft)` → `Result<bool>`
- `buildExportPreviewJson(draft)` → `String`
- `validateDraft(draft)` → `Map<String, String>`
- `validateCustomDefault(valueType, value)` → `String?`

---

## 核心資料模型：FormDataBindingDraft

```
FormDataBindingDraft（頂層）
├── bindingId, bindingName, bindingDescription
├── isEnabled（啟用開關）
├── templateVersion
├── formId, formName, formSize
├── updatedAt（ISO 8601）
├── sections: List<FormDataBindingSectionDraft>
│   ├── sectionId, sectionName, description
│   └── fields: List<FormDataBindingFieldDraft>
│       ├── itemId, label, fieldName, sourceType
│       ├── fieldKind（value / button）
│       ├── valueType（string / number / date / file）
│       ├── required
│       ├── outputKey（JSON 輸出鍵名）
│       ├── nullStrategy（skip / custom）
│       └── customDefaultValue
└── actions: List<FormActionBindingDraft>
    └── （詳見 form_action_binding.md）
```

**Storage Key：** 透過 `FormDataBindingRepository`
- `loadDraftsByFormId(formId)` — 載入指定表單的所有綁定
- `saveDraft(draft)` — 儲存綁定
- `deleteDraftByBindingId(formId, bindingId)` — 刪除綁定
- `loadDraftByBindingId(formId, bindingId)` — 載入指定綁定

---

## 目前狀態

| 子模組 | 完整度 | 備註 |
|--------|--------|------|
| form_select | ✅ 完成 | 選擇表單入口 |
| form_data_manager | ✅ 完成 | 多綁定管理 + 健康狀態 |
| form_data_binding | ✅ 完成 | 欄位映射 + 驗證 |

**所有資料存於 LocalStorage，尚未接後端 API。**
