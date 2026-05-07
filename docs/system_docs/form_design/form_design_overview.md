# 動態表單系統（Form Design）總覽

## 模組定位

動態表單系統是電子簽核的核心子系統，負責「申請資料本身」的結構、規則與執行。
目前 Flutter 端定位為**規格編輯器**，定義表單映射與事件規格，尚未直接執行後端 API。

## 子模組清單

| 子模組 | 路由 | 功能 | 文件 |
|--------|------|------|------|
| form_manage | `/home/form-manage` | 表單管理中心 | [form_creation_and_design.md](form_creation_and_design.md) |
| form_create | `/home/form-manage/form-create` | 建立新表單 | 同上 |
| form_composer | `/home/form-manage/form-design` | 表單區塊組裝 | 同上 |
| form_section_design | `/home/form-section-design` | 區塊元件設計 | 同上 |
| form_select | `/home/form-manage/form-select` | 選擇表單進入綁定 | [form_data_binding.md](form_data_binding.md) |
| form_data_manager | `/home/form-manage/form-data-manager` | 綁定清單管理 | 同上 |
| form_data_binding | `/home/form-manage/form-data-binding` | 欄位資料綁定 | 同上 |
| form_action_binding | `.../form-action-binding` | 事件行為綁定 | [form_action_binding.md](form_action_binding.md) |
| form_browse | `/home/form-browse` | 表單預覽 | [form_execution.md](form_execution.md) |
| form_run | `/home/form-run` | 表單執行 | 同上 |

## 操作流程

```
1. 建立表單 (form_create)
       ↓
2. 設計區塊 (form_section_design)
       ↓
3. 組裝表單 (form_composer) ←→ 預覽 (form_browse)
       ↓
4. 選擇表單 (form_select)
       ↓
5. 綁定管理 (form_data_manager)
       ↓
6. 資料綁定 (form_data_binding) ←→ 事件綁定 (form_action_binding)
       ↓
7. 表單執行 (form_run)
```

## 共用資料模型

### FormModel（表單）
| 欄位 | 說明 |
|------|------|
| id | 表單 ID |
| name | 表單名稱 |
| size | 紙張大小（A4 等） |
| sectionIds | 區塊 ID 順序 |

### SectionModel（區塊）
| 欄位 | 說明 |
|------|------|
| id | 區塊 ID |
| name | 區塊名稱 |
| description | 描述 |
| items | List\<DesignerItem\> 元件清單 |

### DesignerItem（表單元件）
支援 9 種元件類型：label / textField / textArea / button / dropdown / checkbox / radio / datePicker / fileUpload

核心屬性（46 個）：
- 基本：id, type, text, fieldName, placeholder
- 佈局：widthPercentage, rowIndex, alignment, padding, fontSize, isBold
- 按鈕：buttonWidthMode, buttonWidth, buttonColorHex, buttonTextColorHex
- 選項：options, isGrouped, optionLayout, optionSpacing
- 輸入：maxLength, required, readonly, inputType
- 資料來源：dataSourceUrl, dataSourceKey
- 日期：dateFormat
- 檔案：allowedTypes, maxSize

### FormDataBindingDraft（綁定草稿 — 核心主模型）
同時承載資料綁定與事件綁定，詳見各子文件。

## 技術架構

- **狀態管理：** BLoC（Event → BLoC → State → UI）
- **Model：** Equatable + copyWith + toMap/fromMap
- **錯誤處理：** Result\<T\>（isSuccess / data / error）
- **DI：** GetIt service locator
- **路由：** GoRouter
- **儲存：** LocalStorage（SharedPreferences）/ TempDataStorage（檔案）

## 目前狀態

| 指標 | 數值 |
|------|------|
| 子模組數 | 10 |
| Widget 檔案數 | 約 53 |
| BLoC 事件總數 | 約 100+ |
| 資料來源 | 全部 LocalStorage（尚未接後端） |
