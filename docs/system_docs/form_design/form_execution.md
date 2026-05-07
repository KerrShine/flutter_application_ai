# 表單預覽與執行（Browse & Run）

涵蓋模組：form_browse / form_run

---

## 1. form_browse — 表單預覽

**路由：** `/home/form-browse`

**功能：** 唯讀預覽表單的完整結構，檢視各區塊與欄位的屬性細節。

| 操作 | 說明 |
|------|------|
| 檢視區塊列表 | 左側列出所有區塊 |
| 選擇區塊 | 中央顯示該區塊的渲染預覽 |
| 選擇欄位 | 右側顯示欄位屬性詳情 |
| 展開欄位 | 切換欄位詳細資訊的展開/收合 |

**BLoC Events：**
- `InitEvent(formId, initialSections)` — 載入
- `SelectSectionEvent(sectionId)` — 切換區塊
- `SelectFieldEvent(sectionId, itemId)` — 選擇欄位
- `ToggleFieldExpandEvent(sectionId, itemId)` — 展開/收合

**State：**
- `sections: List<SectionModel>`
- `selectedSectionId` — 目前選中的區塊
- `selectedFieldKey` — 目前選中的欄位（`section::item` 格式）
- `expandedFieldKey` — 目前展開的欄位

**Service：** `form_browse_service.dart`
- `loadSections(formId)` → `Result<List<SectionModel>>`

**Key Widgets：**
- FormBrowseBodyWidget — 主容器
- FormBrowseSectionListWidget — 區塊列表
- SectionPreviewWidget — 區塊預覽渲染
- FormBrowsePropertyPanelWidget — 欄位屬性面板
- FormWidgetFactory — 依 DesignerItemType 渲染對應元件

---

## 2. form_run — 表單執行

**路由：** `/home/form-run`

**功能：** 載入已綁定的表單，渲染可互動的表單元件，執行使用者操作觸發的動作鏈。

### 執行流程

```
1. 載入表單區塊 + 綁定草稿（含欄位映射 + 事件設定）
2. 載入 API 定義（button API + dropdown API）
3. 初始化欄位值（fieldValues）
4. 還原已儲存的草稿值（localStorage）
5. 自動觸發所有 dropdown 的 dropdownLoaded 事件
6. 使用者操作（填值 / 選擇 / 按按鈕）
7. 根據事件設定依序執行 action chain
```

### 操作

| 操作 | 觸發事件 | 說明 |
|------|----------|------|
| 修改文字欄位 | FormRunFieldChangedEvent | 更新 fieldValues |
| 選擇下拉選項 | FormRunDropdownChangedEvent | 更新 fieldValues |
| 下拉元件載入 | FormRunDropdownLoadedEvent（自動） | 查找 loadDropdownOptions action → 載入選項 |
| 按下按鈕 | FormRunButtonPressedEvent | 依序執行該按鈕的 action chain |

### 按鈕動作鏈（Action Chain）

當按鈕被按下時，BLoC 依 `order` 排序執行所有綁定的動作：

| 動作 | 執行邏輯 | 狀態 |
|------|----------|------|
| callApi | 呼叫 API（目前 mock 800ms） | ✅ 結構完成，mock |
| submitForm | 呼叫 API + 導頁 | ✅ 結構完成，mock |
| navigate | 依 navigateRoute 導頁 | ✅ 完成 |
| saveDraft | 將 fieldValues 存入 localStorage | ✅ 完成 |
| loadDropdownOptions | 從 JSON 讀取下拉選項 | ✅ 完成（讀 sample JSON） |
| setFieldValue | — | ❌ 尚未實作（break） |
| refreshTarget | — | ❌ 尚未實作（break） |

### 下拉選項載入流程

```
dropdown 元件載入
    ↓
FormRunDropdownLoadedEvent(itemId)
    ↓
BLoC 查找 actions: sourceItemId == itemId && triggerType == dropdownLoaded && actionType == loadDropdownOptions
    ↓
有 apiId → Service.executeLoadDropdownOptions(action, apiMap)
    ↓
讀取 dropdown_options_sample.json → 找到 apiId 對應的 source
    ↓
用 action.parameterName（優先）或 source.dataSourceKey 作為 key 取出選項陣列
    ↓
emit dropdownOptionsOverride → UI 更新下拉選項
```

### 導航處理

| 路由值 | 行為 |
|--------|------|
| `_stay` | 留在本頁（RouteCatalog.stayPath） |
| `_back` | 回上一頁（RouteCatalog.backPath） |
| 其他 | GoRouter.go(route) |
| 空值 | 顯示提示「未設定目標頁面」 |

---

## BLoC Events（6 個）

| Event | 說明 |
|-------|------|
| FormRunInitEvent(formId, bindingId) | 初始化載入 |
| FormRunFieldChangedEvent(itemId, value) | 欄位值變更 |
| FormRunButtonPressedEvent(itemId) | 按鈕觸發 |
| FormRunDropdownLoadedEvent(itemId) | 下拉載入 |
| FormRunDropdownChangedEvent(itemId, value) | 下拉選項變更 |
| FormRunDismissResultEvent | 清除結果訊息 |

## State 重要欄位

| 欄位 | 說明 |
|------|------|
| status | init / loading / ready / executingAction / actionSuccess / actionFailure / navigating |
| sections | 表單區塊結構 |
| draft | 綁定草稿（含 actions） |
| apiMap | API 定義對照表（button + dropdown API 合併） |
| fieldValues | `Map<String, FormRunFieldValue>` 目前欄位值 |
| dropdownOptionsOverride | `Map<String, List<String>>` 動態下拉選項 |
| pendingNavigateRoute | 待導航路由 |
| lastApiResponse | 最後一次 API 回應 |

## FormRunFieldValue 模型

| 欄位 | 說明 |
|------|------|
| itemId | 元件 ID |
| outputKey | 輸出鍵名 |
| value | 目前值 |
| valueType | string / number / date / file |
| nullStrategy | skip / custom |
| customDefaultValue | 預設值 |
| effectiveValue | 計算值（value 或 customDefaultValue） |

---

## Service

**檔案：** `form_run_service.dart`

| 方法 | 說明 |
|------|------|
| `initialize(formId, bindingId)` | 載入區塊 + 綁定 + API 定義 + 初始化欄位值 |
| `buildApiParams(fieldValues)` | 將欄位值轉為 API 參數 Map |
| `executeCallApi(action, apiMap, params)` | 呼叫 API（目前 mock） |
| `executeLoadDropdownOptions(action, apiMap)` | 讀取下拉選項（目前讀 JSON） |
| `executeSaveDraft(formId, bindingId, fieldValues)` | 儲存草稿到 localStorage |

**初始化資料（FormRunInitialData）：**
- sections — 區塊清單
- draft — 綁定草稿
- apiMap — API 對照表（button + dropdown 合併）
- fieldValues — 初始欄位值

**Key Widgets：**
- FormRunBodyWidget — 主捲動區
- FormRunSectionWidget — 單一區塊渲染
- FormRunTextFieldWidget — 文字輸入
- FormRunDropdownWidget — 下拉選單（支援單選/多選）
- FormRunWidgetFactory — 依元件類型分派互動式 Widget

---

## 目前狀態

| 項目 | 狀態 | 備註 |
|------|------|------|
| 表單預覽 | ✅ 完成 | 唯讀渲染 |
| 欄位值輸入 | ✅ 完成 | text / textarea / dropdown / datePicker |
| 按鈕動作鏈 | ✅ 結構完成 | callApi / submitForm 為 mock |
| 下拉選項載入 | ✅ 完成 | 讀 sample JSON，支援 parameterName |
| 導航 | ✅ 完成 | GoRouter |
| 草稿儲存/還原 | ✅ 完成 | localStorage |

**尚未實作：**
- `executeCallApi` / `executeLoadDropdownOptions` 接真實 DioClient
- `dropdownChanged` 觸發後續 action chain
- `setFieldValue` 動作執行（帶入欄位值）
- `refreshTarget` 動作執行（重新整理目標下拉元件）
