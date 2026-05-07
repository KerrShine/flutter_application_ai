# 表單資料綁定與事件綁定說明

## 文件目的

此文件整理目前 `form_data_binding` 與 `form_action_binding` 的實作目的、操作流程、資料結構與責任分工。

目前 Flutter 端的定位為：

- 前後端分離
- 前端先定義表單映射規格與事件行為規格
- 前端暫不實際執行 API 或 DB 寫入
- 後續由後端或執行層依照既有 action 屬性進行實際綁定與執行

因此，目前系統主要是在維護「規格」與「宣告」，不是直接執行流程。

## 核心概念

目前整體設計是以同一份 `FormDataBindingDraft` 作為主資料模型。

此模型同時承載兩類資訊：

1. 資料綁定規格
2. 事件行為規格

也就是說，`form_data_binding` 與 `form_action_binding` 不是兩套分離設定，而是同一份草稿的兩個編輯入口。

## 目前模組分工

### 1. form_data_binding

用途：定義表單資料輸出規格。

主要負責內容：

- 載入指定表單的欄位資訊
- 建立或讀取既有綁定草稿
- 編輯欄位對應的輸出 key
- 設定空值策略
- 設定自訂預設值
- 切換整份綁定的啟用 / 停用狀態
- 顯示某些元件是否已設定事件綁定

主要結論：

- 這一層本質上是「資料映射規格編輯器」
- 主要關心欄位值如何輸出與缺值時如何處理

### 2. form_action_binding

用途：定義特定元件的事件行為規格。

主要負責內容：

- 從同一份 draft 中找出可當作事件來源的元件
- 讓使用者選擇 trigger
- 讓使用者選擇 action 類型
- 將設定結果寫回 draft.actions
- 匯出目前事件規格預覽

主要結論：

- 這一層本質上是「事件行為宣告編輯器」
- 目前只定義 action 屬性，不直接執行 action

## 共用資料模型

主要模型為 `FormDataBindingDraft`，內含：

- `sections`
  - 每個 section 內的欄位定義
- `actions`
  - 事件綁定結果清單

其中欄位定義包含：

- `outputKey`
- `nullStrategy`
- `customDefaultValue`
- `fieldKind`
- `valueType`

其中事件綁定定義包含：

- `sourceItemId`
- `sourceType`
- `triggerType`
- `actionType`
- `enabled`
- `description`
- 預留後續可延伸的 target / route 等欄位

## 目前操作流程

### A. 綁定清單階段

入口頁面會先載入指定表單下既有的綁定草稿清單。

使用者可以：

- 選擇既有綁定
- 新增一份綁定
- 編輯既有綁定
- 刪除既有綁定
- 切換檢視某份綁定內容

這一段主要由 `form_data_manager` 承接。

### B. 資料綁定階段

使用者進入 `form_data_binding` 後：

1. 系統載入表單與 section
2. 系統載入指定 binding draft
3. 將欄位整理為可編輯的 binding field
4. 使用者逐欄編輯輸出 key、空值策略、預設值
5. 若欄位為事件型元件，則顯示事件綁定入口
6. 儲存後寫回 local storage

### C. 事件綁定階段

當使用者由資料綁定頁點進事件綁定頁時：

1. 帶入 `formId`
2. 帶入 `bindingId`
3. 帶入目前點選的 `sourceItemId`
4. 重新載入同一份 `FormDataBindingDraft`
5. 從 draft 中建立可用的事件來源清單
6. 使用者選擇事件 trigger 與 action
7. 將結果寫回 `draft.actions`
8. 儲存後回寫 local storage
9. 回到資料綁定頁重新初始化並顯示結果

## 為什麼 dropdown 可以列入事件綁定

一般表單欄位的本質是資料輸入，但 `dropdown` 是目前的特例。

原因不是因為它和按鈕同樣屬於流程操作元件，而是因為它可能同時具備資料事件特性：

- 載入時可能需要取得 API 選項資料
- 選項變更時可能需要刷新其他欄位
- 選項變更時可能需要帶入其他欄位值

因此目前把 `dropdown` 納入 `action binding`，其本質更接近：

- 資料事件綁定
- 欄位相依規格綁定

不是單純的流程動作元件。

## 目前允許的事件來源

目前程式中只有兩種元件會進入 action source：

1. `button`
2. `dropdown`

其中對應 trigger 為：

- `buttonPressed`
- `dropdownLoaded`
- `dropdownChanged`

## 目前允許的 action 類型

目前 action 主要是行為語意代碼，用來描述未來可執行的行為，不代表 Flutter 端現在就會真的執行：

- `navigate`
- `saveDraft`
- `submitForm`
- `callApi`
- `loadDropdownOptions`
- `refreshTarget`
- `setFieldValue`
- `other`

這些值目前的用途是：

- 作為前端可編輯的事件規格屬性
- 作為後續後端 / 執行層綁定依據
- 作為預覽輸出與設定保存內容

## 目前 Flutter 端的責任

Flutter 端目前負責：

1. 載入表單欄位資訊
2. 建立綁定草稿
3. 編輯資料映射規格
4. 編輯事件行為規格
5. 驗證欄位必填與預設值格式
6. 儲存至 local storage
7. 匯出目前設定內容預覽

Flutter 端目前不負責：

1. 實際呼叫 API 執行 action
2. 真正將資料送入 DB
3. 真正執行流程跳轉編排
4. 真正執行欄位間資料同步

## 後續後端 / 執行層責任

後續後端或其他執行層可依照目前已儲存的 action 屬性進行真正的綁定。

可承接的方向包含：

1. 依 `actionType` 綁定對應 API
2. 依 `triggerType` 建立實際事件執行規則
3. 依 `sourceItemId` 與 `targetItemId` 建立欄位相依更新
4. 依 `navigateRoute` 或其他擴充欄位執行頁面跳轉
5. 將目前 local storage 規格改為後端持久化結構

## 與流程圖的符合狀況

### 已符合部分

1. 有既有綁定清單
2. 可新增 / 編輯 / 刪除綁定
3. 可進行欄位映射設定
4. 可區分事件型元件與一般欄位
5. 可設定事件 trigger 與 action 行為
6. 可儲存整份映射規格
7. 可管理啟用 / 停用狀態

### 尚未完整落地部分

1. 尚未真正上傳 DB
2. 尚未真正執行 API
3. 目前 `exportApiPreview` 仍屬預覽用途
4. `templateVersion` 目前有欄位，但版本升級策略尚未完整定義

## 目前較準確的系統定位

如果用一句話定義目前系統：

> Flutter 端目前是表單映射與事件規格的宣告編輯器，而非最終執行引擎。

## 建議事項

### 1. 文件與 UI 語意建議

建議在文件與 UI 上把 `button` 與 `dropdown` 的意義區分得更清楚：

- `button`：流程動作型事件來源
- `dropdown`：資料事件型事件來源

避免兩者在語意上被使用者理解成完全相同的互動類型。

### 2. action 命名建議

若目前不會直接執行 API，可考慮將 `callApi` 類文案在 UI 說明中明確標示為：

- API 行為定義
- API 規格綁定

降低誤解為 Flutter 端當下會直接打 API 的風險。

### 3. 版本控管建議

未來若流程圖中的版本控管要落地，建議補明確規則：

- 何時升版
- 哪些欄位變更視為新版本
- action 調整是否算版本變更
- 舊版與新版的比較方式

### 4. 後續擴充建議

若後續還要支援更多元件納入 action bind，建議先定義它們是屬於：

- 流程動作事件
- 資料事件
- 純輸入欄位

避免 action bind 持續混入不屬於事件來源的欄位。
