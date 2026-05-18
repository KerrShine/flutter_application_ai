# 剩餘工作審計 — 2026-05

## 背景

`docs/planning/` 內既有規劃文件（特別是 `sign_off_implementation_status.md`）大幅落後實作進度。本文以**程式碼為真相**重新整理剩餘工作清單，作為後續規劃依據。

審計方式：Explore 代理人 + service 層 grep 驗證 + 每輪實作後同步更新。

---

## 一、未完成清單（按優先級）

### P2 — A5. 模板版本控制策略 ❌

**規模**：中（含設計決策）  
**現況**：[SignOffInstance](../../lib/model/sign_off_instance.dart) 有 `templateId` 但無 `templateSnapshot`；編輯模板後既有 signOff 沒有明確策略。

**設計問題**：
- A 方案：送出時凍結 templateSnapshot（與 sectionsSnapshot 一致）— 已結案不變
- B 方案：永遠跟最新版 — 簡單但簽核中改模板會混亂
- C 方案：版本號 `templateVersion`，模板加 version 欄位，凍結 version 而非整份 snapshot

**建議**：先實作 A 方案（與既有 snapshot 模式一致），待出現版本管理需求再演進 C。

---

### P3 — A3. SLA 計時 / 提醒 ❌

**規模**：大（需基礎建設）  
**現況**：`slaDays` 在 service 層 grep 0 命中；編輯器有過期預覽 chip，但無真實計時。

**需做**：
- 任務啟動時打 `nodeStartedAt` timestamp
- 排程：定期 check 是否超 `slaDays`
- 過期通知（推播 / Email / In-app — 需通知系統）
- v2: 自動升級給上層主管

**先決條件**：需先做通知系統 + 排程基礎建設；可暫緩。

---

### 後續 UI 增強（小規模、純前端、獨立性高）

- [ ] **會簽進度 N/M chip** — 待簽列表 / submission view 顯示「節點內 2/3 已簽」（A1 的 nodeStates 資料就緒，純 UI 拼裝）
- [ ] **sign_off_status_widget「已知會」徽章** — autoNotify 軌跡列加專屬視覺辨識
- [ ] **preview chain dialog notify 標籤** — 預覽鏈解析結果對 notify 節點顯示「（自動通知）」灰色 chip
- [ ] **application_my 套同模式 filter** — 把 A4 的 search / sort / filter pattern 複製給「我的申請」頁

---

### v2 — Phase C 歸檔 / 報表 ❌

- [ ] 歸檔機制（已結案案件移轉）
- [ ] 簽核報表 / 統計
- [ ] 通知系統（推播 / Email / In-app — 與 A3 SLA 緊耦合）

---

## 二、待驗證 / 技術債

- ⚠️ 退回 `returnPolicy` 三分支（toApplicant / toPrevious / toSpecific）執行細節未深入驗證 — 若懷疑 bug 再個案調查
- ⚠️ notify 節點若放在流程末端 → 結案；若放在分支內 → 跟線性處理（已驗證）
- ⚠️ 整份模板都是 notify → 直接結案（已實作 `applyLeadingNotifySkip` 處理）

---

## 三、已完成記錄（按時間倒序）

### 2026-05

#### A2. notify 知會節點不阻擋推進 ✅

**Service 端**：
- [SignOffActionType.autoNotify](../../lib/enum/sign_off_action_type.dart) 新 enum case（label「自動通知」）
- [ResolvedApprover.nodeType](../../lib/service/sign_off_service.dart) 新欄位 + 序列化（後處理迴圈注入，同 multiStrategy 模式）
- [`_executeAction`](../../lib/service/form_application_service.dart) approve 推進加 `_appendAutoNotifyAndAdvance` 迴圈：連續 notify 自動 skip + append autoNotify 軌跡
- [`applyLeadingNotifySkip`](../../lib/service/form_application_service.dart)（top-level function）— 建單時若首節點是 notify 立即 skip；全 notify 模板 → 結案
- [`executeTestWriteSignOff` / `executeUpdateSignOff`](../../lib/service/form_run_service.dart) 寫入前呼叫 helper
- [`loadPendingForApprover`](../../lib/service/form_application_service.dart) 過濾保險（notify 不入待簽列表）

**Canvas UX 增強（同輪附帶）**：
- ThemeExtension 加 `signOffFlowApprove / Countersign / Notify` 3 個色票（綠 / 紫 / 琥珀）
- [connection_painter](../../lib/page/sign_off/sign_off_editor/widgets/units/sign_off_connection_painter.dart) 流向線改依目標節點 nodeType 取色
- 新 [legend widget](../../lib/page/sign_off/sign_off_editor/widgets/units/sign_off_canvas_legend_widget.dart) — canvas 左下角浮動圖例

#### sign_off_status_widget 私有元件拆分 ✅（cleanup）

[sign_off_status_widget.dart](../../lib/page/form_application/application_submission_view/widgets/sign_off_status_widget.dart) 從 746 行瘦身到 366 行，3 個私有 widget 升公開並抽出：
- [SignOffStatCard](../../lib/page/form_application/application_submission_view/widgets/sign_off_stat_card_widget.dart) — 三張通用 stat card
- [SignOffChainStepRow](../../lib/page/form_application/application_submission_view/widgets/sign_off_chain_step_row_widget.dart) — 完整流程節點列每一格
- [SignOffHistoryRow](../../lib/page/form_application/application_submission_view/widgets/sign_off_history_row_widget.dart) — 軌跡列每一筆（含代簽 / 轉派 / 加簽 chip 與 _actionColor / _formatTimestamp helper）

#### A1. multiStrategy 會簽收斂執行 ✅（與 A7 合併）

- [ResolvedApprover.multiStrategy](../../lib/service/sign_off_service.dart) 新欄位，由 `resolveApproverChain` 後處理迴圈從 `node.multiStrategy` 注入（單點修改，覆蓋所有 _resolve* 來源）
- toMap/fromMap 序列化 enum name，舊 snapshot 缺欄位時 fallback `.any`
- [_executeAction approve 分支](../../lib/service/form_application_service.dart) 改為依 multiStrategy 收斂：
  - `all`：approvedBy 含所有 approverEmployeeIds 才推進
  - `any`：首人簽完即推進（單人節點等效）
  - `sequential`：approvedBy 依序對應 approverEmployeeIds 全簽完才推進
- reject 採嚴格策略：三策略下任一拒絕即終止流程
- transfer 換人時清掉當前節點 nodeStates；returnBack 同樣清除
- 兩個 helper：`_shouldAdvanceOnApprove` / `_nextPendingSignerInNode`

#### A7. 獨立 SignOffInstance model ✅（與 A1 合併）

- 新檔 [lib/model/sign_off_instance.dart](../../lib/model/sign_off_instance.dart) 取代 `leave_sign_off_model.dart`
- class 重命名 `LeaveSignOffModel` → `SignOffInstance`
- 新欄位 `nodeStates: Map<String, NodeApprovalState>`（多人會簽進度追蹤）
- 新 model [lib/model/node_approval_state.dart](../../lib/model/node_approval_state.dart) — 含 `approvedBy` / `rejectedBy` 兩個 list
- 批次重命名 11 個引用點（service / bloc / widget / model）
- toMap snake_case key 不動 + fromMap 維持 camelCase 相容，舊資料可讀

#### A4. application_sign_off_pending 篩選 / 排序 / 搜尋 ✅

- 新 enum [sign_off_pending_sort_order.dart](../../lib/enum/sign_off_pending_sort_order.dart) — 4 case（submittedAt / updatedAt × Desc / Asc）
- state 加 `searchQuery` / `sortOrder` / `formNameFilter` + `availableFormNames` / `filteredItems` getter
- bloc 加 `UpdateSearchQueryEvent` / `UpdateSortOrderEvent` / `UpdateFormNameFilterEvent`，Init 時重置
- 新 widget [pending_filter_bar_widget.dart](../../lib/page/form_application/application_sign_off_pending/widgets/pending_filter_bar_widget.dart) — search + sort dropdown + formName filter
- page 改用 `filteredItems`、空態文案分流（無資料 vs filter 後無結果）

#### A6. AppColors 常數重命名 ✅（cleanup）

`appCenter*` → `appFormApplication*`（application_split_planning A2 漏改），32 個常數 + 32 個引用點。

---

## 四、原 planning doc 落後對照（保留為歷史記錄）

[sign_off_implementation_status.md](sign_off_implementation_status.md) §3 Phase B 大量項目實際已完成，文件未同步：

| Doc 標記 | 真實狀態 |
|---|---|
| §3.1 提交時凍結 path / approver chain | ✅ resolvedChainSnapshot |
| §3.1 SignOffInstance 持久化 | ✅（2026-05 完成，已重命名）|
| §3.1 申請人列表 / 進度檢視 | ✅ application_my + application_submission_view |
| §3.2 待簽列表 | ✅ loadPendingForApprover |
| §3.3 同意 / 拒絕 / 退回 / 補件 / 加簽 / 轉派 | ✅ 全做完 |
| §3.4 multiStrategy 收斂 | ✅（2026-05）|
| §3.6 notify 不阻擋 | ✅（2026-05）|
| §3.7 actionHistory append-only | ✅ |
| §3.5 SLA 計時 | ❌（仍未做，列 A3）|

[sign_off_review_view_planning.md](sign_off_review_view_planning.md) §十二 缺口 — 已收斂：
- ✅ actionHistory 寫入機制
- ✅ currentApproverId 自動推進
- ❌ 模板版本控制策略（列 A5）

[application_split_planning.md](application_split_planning.md) — 完成
- ✅ 四頁全建好
- ✅ 路由 / drawer / 舊資料夾刪除
- ✅ AppColors 常數重命名

---

## 五、注意事項

- 既有 `sign_off_implementation_status.md` 不刪除，作為歷史記錄；本文件作為**現況真相**
- 後續若實作未完成項目，應更新本文件對應 section 為 ✅，並補上實作要點
- 本文件結構：**未完成在前**（規劃用） / **已完成記錄在後**（追溯用）
