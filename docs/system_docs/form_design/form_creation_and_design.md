# 表單建立與設計（Creation & Design）

涵蓋模組：form_manage / form_create / form_composer / form_section_design

---

## 1. form_manage — 表單管理中心

**路由：** `/home/form-manage`

**功能：** 表單清單入口，負責瀏覽、刪除、導航至各功能頁。

| 操作 | 說明 |
|------|------|
| 載入表單清單 | 顯示所有已建立的草稿表單 |
| 刪除表單 | 刪除指定表單 |
| 前往建立 | 導航至 form_create |
| 前往設計 | 導航至 form_composer |

**BLoC Events：**
- `LoadFormsEvent` — 載入所有表單
- `DeleteFormEvent(formId)` — 刪除表單

**Service：** `form_manage_service.dart`
- `loadForms()` → `Result<List<FormModel>>`
- `deleteForm(formId)` → `Result<bool>`

**Storage Key：** 透過 `FormRepository` 操作

---

## 2. form_create — 建立新表單

**路由：** `/home/form-manage/form-create`

**功能：** 建立一份新的空白表單草稿。

| 操作 | 說明 |
|------|------|
| 輸入表單名稱 | 必填 |
| 選擇紙張大小 | A4 等（FormCreateConstants） |
| 送出建立 | 產生 FormModel，ID 為 timestamp |

**BLoC Events：**
- `InitEvent` — 初始化
- `SubmitFormCreateEvent(formName, formSize)` — 建立表單

**Service：** `form_create_service.dart`
- `createDraftForm(name, size)` → `Result<FormModel>`

---

## 3. form_composer — 表單區塊組裝

**路由：** `/home/form-manage/form-design`

**功能：** 將已設計的區塊（SectionModel）組裝到表單中，決定排列順序。

### 三欄式 UI 佈局
| 區域 | Widget | 說明 |
|------|--------|------|
| 左側 | AvailableSectionPanelWidget | 所有已儲存的區塊清單，可搜尋 |
| 中央 | FormSectionCanvasWidget | 表單畫布，拖拽排序區塊 |
| 右側 | FormDesignInfoPanelWidget | 操作面板（儲存/預覽/匯出） |

### 操作

| 操作 | 說明 |
|------|------|
| 新增區塊到表單 | 從左側清單加入 |
| 移除區塊 | 從畫布移除 |
| 拖拽排序 | 調整區塊順序 |
| 搜尋區塊 | 關鍵字篩選左側清單 |
| 前往設計區塊 | 跳轉 form_section_design（新增或編輯） |
| 前往預覽 | 跳轉 form_browse |
| 刪除區塊（全域） | 從所有表單移除 + 永久刪除，有確認提示 |
| 儲存草稿 | 儲存表單的區塊順序 |
| JSON 預覽 | 匯出目前設計為 JSON |

**BLoC Events（15 個）：**
- `InitFormDesignEvent(formId)` — 載入表單 + 區塊
- `AddSectionToFormEvent(section)` — 加入區塊
- `RemoveSectionFromFormEvent(sectionId)` — 移除區塊
- `ReorderSectionEvent(oldIndex, newIndex)` — 排序
- `SaveFormDesignEvent / SaveFormDraftEvent` — 儲存
- `NavigateToCreateSectionEvent / NavigateToEditSectionEvent(sectionId)` — 設計區塊
- `NavigateToBrowseEvent / NavigateToBrowseSectionEvent(section)` — 預覽
- `UpdateAvailableSectionSearchEvent(query)` — 搜尋
- `PreviewFormJsonEvent` — JSON 預覽
- `RequestDeleteAvailableSectionEvent / ConfirmDeleteAvailableSectionEvent / CancelConfirmDeleteSectionEvent` — 刪除確認流程

**Service：** `form_design_service.dart`
- `loadSections()` → `Result<List<SectionModel>>`
- `loadForm(formId)` → `Result<FormModel?>`
- `updateFormSections(formId, orderedSectionIds)` → `Result<bool>`
- `deleteSection(sectionId)` → `Result<bool>`

---

## 4. form_section_design — 區塊元件設計

**路由：** `/home/form-section-design`

**功能：** 設計單一區塊的內部元件（DesignerItem），支援多列佈局與豐富的屬性編輯。

### 三欄式 UI 佈局
| 區域 | 說明 |
|------|------|
| 左側（Palette） | 元件類型選擇器，可拖入畫布 |
| 中央（Canvas） | 多列佈局畫布，支援拖拽排序 |
| 右側（Properties） | 選中元件的屬性編輯面板 |

### 支援的元件類型（DesignerItemType）
| 類型 | 說明 |
|------|------|
| label | 純文字標籤 |
| textField | 單行文字輸入 |
| textArea | 多行文字輸入 |
| button | 按鈕 |
| dropdown | 下拉選單 |
| checkbox | 核取方塊 |
| radio | 單選按鈕 |
| datePicker | 日期選擇器 |
| fileUpload | 檔案上傳 |

### 操作

| 操作 | 說明 |
|------|------|
| 新增元件 | 拖拽或點選加入指定列 |
| 插入元件 | 在指定位置插入 |
| 移動元件 | 拖拽到不同列或重新排序 |
| 刪除元件 | 移除單一元件 |
| 批量新增 | 一次加入多個元件 |
| 清空 | 清除所有元件 |
| 新增列 / 刪除列 | 管理佈局列數 |
| 選取元件 | 點選後在右側編輯屬性 |
| 儲存草稿 | 輸入區塊名稱與描述後儲存 |
| 匯出 JSON | 匯出元件結構 |

### 屬性編輯（26 種屬性更新事件）
- **文字相關：** text, fieldName, placeholder, fontSize, isBold
- **佈局相關：** widthPercentage, alignment, padding
- **按鈕相關：** buttonWidthMode, buttonWidth, buttonColorHex, buttonTextColorHex
- **選項相關：** isGrouped, optionsText, optionLayout, optionSpacing
- **輸入相關：** maxLength, required, readonly, inputType
- **特殊：** textAreaHeight, dateFormat, allowedTypes, maxSize, dataSourceUrl, dataSourceKey

**BLoC Events（37 個）：** 含初始化、元件 CRUD、26 個屬性更新、儲存、匯出

**Service：** `form_section_design_service.dart`
- `loadSection(sectionId)` → `Result<SectionModel?>`
- `loadDraft(sectionId)` → `Result<FormSectionDesignDraftModel?>`
- `saveDraft(sectionId, formName, description, items, rowCount)` → `Result<void>`

**Draft Model：FormSectionDesignDraftModel**
| 欄位 | 說明 |
|------|------|
| sectionId | 區塊 ID |
| formName | 區塊名稱 |
| description | 描述 |
| rowCount | 列數 |
| items | List\<DesignerItem\> |

---

## 目前狀態

| 子模組 | 完整度 | 備註 |
|--------|--------|------|
| form_manage | ✅ 完成 | 清單 + 刪除 |
| form_create | ✅ 完成 | 建立草稿 |
| form_composer | ✅ 完成 | 拖拽組裝 + 全域刪除 |
| form_section_design | ✅ 完成 | 9 種元件、26 種屬性、多列佈局 |
