# 表單條件欄位 (form_condition_field) 模組設計

## 模組存在意義

簽核流程的 path rule 條件比對（如「請假天數 > 7」「總金額 > 5 萬」）需要**穩定 key + 計算邏輯**：
- DesignerItem.id 不穩定（重新設計即變動），無法當條件 key
- form_data_binding 的 outputKey 是「提交給 runtime / API 的鍵」，與「條件比對用的鍵」混在一起會強耦合表單提交流程
- 表單常缺少「條件想用」的衍生欄位（請假表單只有 start_date / end_date，但條件想用「天數」；採購表單有 unit_price + quantity，但條件想用「總金額」）

`form_condition_field` 是獨立模組，提供：
1. **fieldKey**：條件比對 stable key（sign_off path rule `condition.fieldId` 引用此值）
2. **計算函式**：把表單欄位組合 / 衍生為條件用值（Direct / DateDiff / Sum / Concat）

## 解耦原則

```
form_section_design (DesignerItem 設計)
   ├──→ form_data_binding (outputKey) ──→ 提交 / API
   └──→ form_condition_field (fieldKey + 計算) ──→ sign_off path rule
```

兩條路徑互不依賴：
- form_data_binding 改 outputKey 不影響 sign_off
- sign_off 改 condition fields 不影響表單提交
- DesignerItem.id 變動 → form_condition_field 的 args 失效（會在 validate 時提示），不影響 form_data_binding

## v1 函式庫

| Function | 參數 | 輸出型別 | 範例 |
|----------|------|---------|------|
| `direct` | 1 個 DesignerItem | 同 item type | leave_reason ← 請假事由（textField） |
| `dateDiff` | 2 個 datePicker | number（天數） | leave_days = end_date - start_date |
| `sum` | ≥2 個 number 欄位 | number | total_amount = unit_price + shipping_fee |
| `concat` | ≥2 個 string 欄位 | string | event_full_name = department + event_short_name |

未來可擴充：IfThen、ratio、avg、count、conditional aggregation 等；但 v1 不開放自由公式語法（避免變成迷你 Excel）。

## 與 sign_off 銜接

### Phase A — 設計階段（v1 完成）
- `SignOffService.loadFormFields(formId)` → 讀 `ConditionFieldDraft.definitions` → 轉 `SignOffConditionFieldChoice` 給 path rule editor 用
- `SignOffService.loadConditionFieldStatus(formId)` → 算 chip 顯示用的狀態（none / ready）
- sign_off chip click → push `RouteName.formConditionFieldPage` extra: `{formId, formName}`
- path rule editor banner「無欄位」→ 跳轉 form_condition_field

### Phase B — 執行階段（規劃中）
`ConditionFieldService.evaluate(formId, rawFormData)` 已實作（v1 寫好但 UI 未接）：
1. 使用者送出 form → rawFormData = `Map<DesignerItem.id, value>`
2. `evaluate` 逐個 definition 計算，輸出 `Map<fieldKey, computedValue>`
3. sign_off `resolveActivatedNodeIds` 用 fieldKey-keyed map 查值、命中 path rules

## 資料儲存

- LocalStorage key: `condition_field_drafts_key`
- 結構：`List<ConditionFieldDraft>`，每個 form 至多一筆（formId 為 unique）
- 每個 draft 包含 `definitions: List<ConditionFieldDefinition>`

## 入口設計（v1）

只走 sign_off chip 入口：
- form 已選 → chip 顯示條件欄位狀態
- chip click → 跳此頁帶 formId

**未開放**的入口（將來再評估）：
- drawer 獨立入口
- form_manage 內嵌入口
- 跨表單條件欄位共用（v1 每個 form 自有 draft）

## 為什麼條件欄位獨立而不放 form_data_binding？

關鍵理由：**功能解耦 + 跨模組共用準備**。

| 議題 | form_data_binding | form_condition_field |
|------|-------------------|----------------------|
| 主要消費者 | runtime 提交 / API | sign_off path rule（將來：報表 / 統計 / 通知…）|
| 改動成本 | 改 outputKey 影響 API 整合 | 改 fieldKey 只影響 sign_off rule 表達 |
| 計算邏輯 | 不需要（提交即原值） | 必要（DateDiff / Sum 等） |
| 一個 form 幾筆？ | 多筆（不同 binding 給不同 API） | 一筆（per-form 唯一） |

如果硬塞進 form_data_binding：
- binding 結構複雜化（多了「計算欄位」概念）
- 提交流程必須跳過計算欄位（噪音）
- 將來其他「條件消費者」（報表篩選、通知條件）只能繞道讀 binding，語意混亂

獨立 module 讓條件邏輯成為「一等公民」，跨消費者複用更乾淨。
