# 人員管理模組（Employee Module）功能摘要

## 模組總覽

人員管理模組由 5 個子模組組成，負責員工、角色、部門綁定與代理人設定。
所有資料目前儲存於 LocalStorage（尚未接後端 API）。

### 模組依賴順序

```
emp_role（建立角色）
    ↓
emp_info（建立員工，需選擇角色）
    ↓
emp_dep（員工綁定部門，需有員工 + 組織部門）
    ↓
emp_agent（代理人指派，需有已綁定部門的員工）
```

---

## 1. emp_manager — 人員管理中心

**路由：** `/home/emp-manager`

**功能：** 導航中心，無資料操作
- 前往員工資訊管理（emp_info）
- 前往角色設定（emp_role）
- 前往部門綁定（emp_dep）
- 前往代理人指派（emp_agent）
- 操作指引頁面（guide）

---

## 2. emp_role — 角色設定

**路由：** `/home/emp-role`

**功能：** 定義系統中的角色（如：採購人員、財務、HR）

| 操作 | 說明 |
|------|------|
| 檢視角色清單 | 顯示所有角色，含類型（一般/主管）與狀態 |
| 新增角色 | 設定角色代碼、名稱、類型（roleType: 0=一般, 1=主管）、狀態 |
| 編輯角色 | 修改既有角色 |
| 匯出 JSON | 匯出所有角色資料 |

**驗證規則：**
- 角色代碼：必填、唯一、自動轉大寫
- 角色名稱：必填

**Model：EmpRoleModel**
| 欄位 | 說明 |
|------|------|
| roleId | 自動產生 `role_{timestamp}` |
| roleCode | 角色代碼 |
| roleName | 角色名稱 |
| roleType | 0=一般, 1=主管級 |
| status | 1=啟用, 0=停用 |
| createdAt / updatedAt | 時間戳 |

**Storage Key：** `emp_roles_key`

---

## 3. emp_info — 員工資訊管理

**路由：** `/home/emp-info`

**功能：** 完整的員工生命週期管理

| 操作 | 說明 |
|------|------|
| 檢視員工清單 | 顯示所有員工，含角色、部門、狀態 |
| 關鍵字搜尋 | 跨欄位即時篩選（代碼、姓名、帳號、角色、日期等） |
| 新增員工 | 填寫代碼、姓名、帳號、部門、角色、到職日等 |
| 編輯員工 | 修改既有員工資料 |
| 刪除員工 | 移除員工紀錄 |
| 前往部門綁定 | 帶入選中員工，跳轉 emp_dep |
| 匯出 JSON | 匯出所有員工資料 |

**驗證規則：**
- 員工代碼：必填、唯一、自動轉大寫
- 姓名、帳號：必填
- 角色：必填且必須為啟用中的角色
- 到職日：必填、格式 YYYY-MM-DD
- 離職日：選填，須晚於到職日

**Model：EmployeeModel**
| 欄位 | 說明 |
|------|------|
| employeeId | 自動產生 `emp_{timestamp}` |
| employeeCode | 員工代碼 |
| employeeName | 姓名 |
| account | 帳號 |
| departmentId | 所屬部門 ID |
| roleId / roleName / roleType | 角色資訊 |
| status | 1=在職, 0=停用 |
| hireDate / leaveDate | 到職日 / 離職日 |
| 稽核欄位 | createdDate/Time/By/ByName, updatedDate/Time/By/ByName |

**Storage Key：** `employees_key`

---

## 4. emp_dep — 部門綁定

**路由：** `/home/emp-dep`（支援 query params: `departmentId`, `employeeId`）

**功能：** 將員工綁定到組織部門

| 操作 | 說明 |
|------|------|
| 選擇部門 | 從組織架構中選擇部門，顯示該部門已綁定的員工 |
| 綁定員工 | 將未綁定的員工指派到選定部門 |
| 解除綁定 | 將員工從部門移除 |
| 搜尋員工 | 關鍵字篩選所有員工 |
| 聚焦員工 | 帶入特定員工 ID，自動定位到其所屬部門 |
| 匯出 JSON | 匯出綁定摘要（含未綁定員工） |
| 前往代理人 | 跳轉 emp_agent |

**驗證規則：**
- 員工必須為在職狀態才能綁定
- 同一員工只能綁定一個部門
- 不可重複綁定已綁定的員工

**View Model：EmpDepBindingViewData**
- 部門清單 + 各部門員工數
- 已選部門的員工列表
- 關鍵字篩選後的員工列表
- 未綁定員工追蹤

**資料來源：**
- 部門資料：從 `OrgDesignRepository` 讀取（組織架構模組）
- 員工資料：從 `EmpInfoRepository` 讀取

---

## 5. emp_agent — 代理人指派

**路由：** `/home/emp-agent`

**功能：** 建立員工之間的代理人關係（避免簽核因請假/出差造成流程中斷）

| 操作 | 說明 |
|------|------|
| 選擇委託人 | 先選部門，再選該部門內的員工作為「委託人」 |
| 選擇代理人 | 先選部門，再選該部門內的員工作為「代理人」 |
| 建立指派 | 確認委託人-代理人關係 |
| 刪除指派 | 移除代理人關係 |
| 檢視指派 | 顯示所選委託人的所有代理人指派紀錄 |

**驗證規則：**
- 委託人/代理人必須存在且為在職狀態
- 兩者皆須已設定到職日
- 兩者須屬於各自所選的部門
- 不可指派自己為自己的代理人
- 不可建立重複的指派關係

**Model：EmpAgentAssignmentModel**
| 欄位 | 說明 |
|------|------|
| assignmentId | 自動產生 `agent_{timestamp}` |
| principalDepartmentId | 委託人部門 |
| principalEmployeeId | 委託人 |
| agentDepartmentId | 代理人部門 |
| agentEmployeeId | 代理人 |
| status | 1=啟用, 0=停用 |
| 稽核欄位 | created/updated Date/Time/By/ByName |

**Storage Key：** `emp_agent_assignments_key`

---

## 目前狀態

| 子模組 | 功能完整度 | 資料來源 |
|--------|-----------|---------|
| emp_manager | ✅ 完成 | — |
| emp_role | ✅ 完成 | LocalStorage |
| emp_info | ✅ 完成 | LocalStorage |
| emp_dep | ✅ 完成 | LocalStorage |
| emp_agent | ✅ 完成 | LocalStorage |

**共通特性：**
- 全部使用 BLoC 架構（Event → BLoC → State → UI）
- Model 皆為 Equatable + copyWith + toMap/fromMap
- 使用 `Result<T>` 統一錯誤處理
- 支援 JSON 匯出
- 資料存於 LocalStorage，尚未接後端 API

---

## 尚未實作

- 代理人有效期限（目前為永久生效，無起訖日期）
- 代理人範圍（全域 vs. 特定表單類型）
- 員工多角色支援（目前一人一角色）
- 員工多部門支援（目前一人一部門）
- 後端 API 整合
