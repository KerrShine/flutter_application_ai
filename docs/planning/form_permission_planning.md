# 表單權限規劃 — 聚焦表單發起

## 規劃背景

### 已完成項目總覽

| 子系統 | 模組 | 狀態 | 說明 |
|--------|------|------|------|
| 表單設計 | form_create / form_section_design / form_composer / form_browse | ✅ | 9 種元件、46 屬性、多列佈局、拖拽組裝 |
| 資料綁定 | form_select / form_data_manager / form_data_binding | ✅ | 多綁定管理、欄位映射、健康狀態 |
| 事件綁定 | form_action_binding | ✅ | 8 種動作、3 種觸發器、API 分流 |
| 表單執行 | form_run | ✅ 結構完成 | 渲染、輸入、動作鏈（API 為 mock） |
| 人員管理 | emp_role / emp_info / emp_dep / emp_agent | ✅ | 角色、員工、部門綁定、代理人 |

### 原始流程進度

```
表單建立 ✅ → 資料連結 ✅ → 發起權限控管 ← 目前位置 → 簽核流程 → 歸檔
```

表單設計系統已初具規模，下一步是建立「表單發起」機制：
讓已設計好的表單能被正確的人看到、填寫、送出。

---

## 一、表單發起要解決什麼問題

| 問題 | 說明 |
|------|------|
| 誰能看到這張表單？ | 使用者登入後，可用表單清單應依權限過濾 |
| 誰能填寫這張表單？ | 點進表單後，系統需驗證發起資格 |
| 填完之後送去哪？ | 送出後進入簽核流程（本階段先處理「送出」，簽核另案） |
| 用哪一份綁定？ | 一張表單可能有多份綁定，需決定使用者拿到的是哪一份 |

---

## 二、發起流程設計

```
使用者登入
    ↓
進入「申請中心」（新模組）
    ↓
系統依發起資格過濾 → 顯示可用表單清單
    ↓
選擇表單
    ↓
系統載入表單結構 + 啟用中的綁定
    ↓
渲染可填寫表單（複用 form_run）
    ↓
使用者填寫欄位
    ↓
送出前驗證（必填、格式、發起資格再次檢查）
    ↓
產生申請單（FormSubmission）
    ↓
儲存申請紀錄 → 後續進入簽核（下一階段）
```

---

## 三、發起資格設定（管理端）

### 3.1 資格條件類型

| 條件類型 | 說明 | 對應現有資料 |
|----------|------|-------------|
| 角色 | 指定哪些角色可發起 | emp_role.roleId |
| 部門 | 指定哪些部門可發起 | emp_dep.departmentId |
| 在職狀態 | 僅在職員工可發起 | emp_info.status = 1 |
| 主管級 | 僅主管可發起 | emp_role.roleType = 1 |

### 3.2 條件組合邏輯

建議第一版採用簡單模型：

```
發起資格 = 角色清單（OR） + 部門清單（OR） + 身份條件
```

**範例：**
- 採購申請單：角色 = [採購人員, 行政人員]，部門 = 不限，身份 = 在職
- 費用報銷單：角色 = 不限，部門 = [財務部]，身份 = 在職
- 全員公告回覆：角色 = 不限，部門 = 不限，身份 = 在職

### 3.3 資格設定 Model（建議）

```
FormLaunchPermission
├── permissionId        — 唯一 ID
├── formId              — 對應表單
├── bindingId           — 對應綁定（或 null = 所有啟用綁定）
├── allowedRoleIds      — 允許的角色清單（空 = 不限）
├── allowedDepartmentIds — 允許的部門清單（空 = 不限）
├── requireActiveStatus — 是否需在職（預設 true）
├── requireManagerRole  — 是否限主管級（預設 false）
├── isEnabled           — 啟停開關
├── createdAt / updatedAt
```

**判斷邏輯：**
```
canLaunch(employee, permission) =
    (permission.allowedRoleIds 為空 OR employee.roleId IN allowedRoleIds)
    AND (permission.allowedDepartmentIds 為空 OR employee.departmentId IN allowedDepartmentIds)
    AND (requireActiveStatus == false OR employee.status == 1)
    AND (requireManagerRole == false OR employee.roleType == 1)
```

---

## 四、需新增的模組

### 4.1 form_launch_permission — 發起資格設定（管理端）

**定位：** 在表單完成綁定後，設定誰可以使用這張表單發起申請。

| 功能 | 說明 |
|------|------|
| 選擇表單 | 從已建立的表單中選擇 |
| 設定角色 | 多選允許的角色（從 emp_role 載入） |
| 設定部門 | 多選允許的部門（從組織架構載入） |
| 設定身份條件 | 在職/主管級 toggle |
| 啟停開關 | 控制此權限是否生效 |
| 預覽符合人員 | 依目前條件列出符合資格的員工清單 |
| 儲存 | 存入 localStorage（後續接 API） |

**建議路由：** `/home/form-manage/form-launch-permission`

### 4.2 form_application_center — 申請中心（使用者端）

**定位：** 使用者的表單入口，僅顯示自己有權限發起的表單。

| 功能 | 說明 |
|------|------|
| 可用表單清單 | 依登入者身份過濾 |
| 搜尋/篩選 | 依名稱、類型篩選 |
| 發起申請 | 選擇表單 → 進入 form_run 填寫 |
| 我的申請 | 檢視自己已送出的申請（後續階段） |

**建議路由：** `/home/form-apply`

### 4.3 form_submission — 申請單管理

**定位：** 記錄每一筆「已送出的申請」。

```
FormSubmission
├── submissionId        — 唯一 ID
├── formId              — 表單模板 ID
├── bindingId           — 使用的綁定 ID
├── applicantId         — 申請人（employee ID）
├── applicantName       — 申請人姓名
├── departmentId        — 申請時所屬部門
├── fieldValues         — 填寫的欄位值 snapshot
├── status              — draft / submitted / approved / rejected / cancelled
├── submittedAt         — 送出時間
├── createdAt / updatedAt
```

---

## 五、與現有模組的銜接

| 現有模組 | 銜接方式 |
|----------|---------|
| form_run | 複用為申請填寫頁，加上「送出申請」動作 |
| form_data_binding | 提供綁定資料，決定欄位如何輸出 |
| emp_role | 提供角色清單給資格設定 UI |
| emp_dep | 提供部門清單給資格設定 UI |
| emp_info | 提供登入者身份，用於資格判斷 |

### form_run 需調整項目

| 項目 | 說明 |
|------|------|
| 來源區分 | 區分「設計預覽模式」vs「正式申請模式」 |
| 送出動作 | 申請模式下，submitForm 產生 FormSubmission |
| 申請人資訊 | 帶入當前登入者的員工資料 |
| 資格驗證 | 送出前再次驗證發起資格 |

---

## 六、建議開發順序

```
Step 1 — FormLaunchPermission Model + Repository
  → 資料模型建立
  → localStorage 存取

Step 2 — form_launch_permission UI（管理端）
  → 選擇表單 + 設定角色/部門/身份條件
  → 預覽符合人員
  → 儲存資格設定

Step 3 — form_application_center（使用者端）
  → 可用表單清單（依資格過濾）
  → 選擇表單 → 導向 form_run

Step 4 — FormSubmission Model + 送出流程
  → 申請單資料模型
  → form_run 加入「送出申請」流程
  → 產生申請紀錄

Step 5 — 我的申請清單
  → 檢視已送出的申請
  → 為後續簽核流程做準備
```

---

## 七、待確認事項

- [ ] 一張表單是否只有一份「啟用中的綁定」可被申請？還是使用者可選擇綁定？
- [ ] 是否需要「申請草稿」功能（填到一半先存，之後再送出）？
- [ ] 發起資格第一版是否只做角色+部門+在職，不做複雜條件組合？
- [ ] 是否需要「登入者」概念？目前系統似乎沒有登入機制。
- [ ] form_run 的「設計預覽」與「正式申請」是否分兩個路由，還是同路由帶 mode 參數？
