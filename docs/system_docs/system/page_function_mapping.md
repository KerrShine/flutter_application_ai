# Page 對應功能清單

## 說明
- 本文件整理目前 `lib/page` 下已實作頁面與對應功能。

## Page 與功能對照

| 模組 | Page 名稱 | 對應功能 |
|---|---|---|
| 系統 | `login_page.dart` | 使用者登入 |
| 系統 | `home_page.dart` | 主框架頁（承載內部子頁） |
| 系統 | `main_page.dart` | 首頁 |
| 組織 | `org_manager_page.dart` | 組織管理入口 |
| 組織 | `org_design_config_page.dart` | 組織設定 |
| 組織 | `org_tree_design_page.dart` | 組織樹設計 |
| 員工 | `emp_manager_page.dart` | 人員管理入口 |
| 員工 | `emp_manager_guide_page.dart` | 人員管理指引 |
| 員工 | `emp_role_page.dart` | 職位/角色設定 |
| 員工 | `emp_agent_page.dart` | 員工代理人設定 |
| 員工 | `emp_dep_page.dart` | 部門管理 |
| 員工 | `emp_info_page.dart` | 員工資料管理 |
| 表單設計 | `form_section_design_page.dart` | 表單區塊設計 |
| 表單設計 | `form_manage_page.dart` | 表單管理入口 |
| 表單設計 | `form_create_page.dart` | 建立/編輯表單 |
| 表單設計 | `form_select_page.dart` | 選擇表單 |
| 表單設計 | `form_data_binding_page.dart` | 表單資料綁定（給 runtime 提交 / API 用的 outputKey 對應） |
| 表單設計 | `form_action_binding_page.dart` | 表單動作綁定 |
| 表單設計 | `form_data_manager_page.dart` | 表單資料源管理 |
| 表單設計 | `form_design_page.dart` | 表單編排/設計器 |
| 表單設計 | `form_launch_permission_page.dart` | 表單發起權限設定（列表） |
| 表單設計 | `form_launch_permission_editor_page.dart` | 表單發起權限編輯 |
| 表單設計 | `form_condition_field_page.dart` | 表單條件欄位定義（per-form 的 fieldKey + 計算公式 Direct/DateDiff/Sum/Concat，給 sign_off path rule 條件比對消費；入口僅從 sign_off_editor header chip 進） |
| 表單應用 | `form_run_page.dart` | 執行表單 |
| 表單應用 | `form_browse_page.dart` | 預覽表單 |
| 表單應用 | `form_application_center_page.dart` | 表單申請中心 |
| 簽核 | `sign_off_manager_page.dart` | 簽核流程模板管理 |
| 簽核 | `sign_off_editor_page.dart` | 簽核流程模板編輯 |

## 更新原則
- 新增 page 時，需同步補上本清單。
