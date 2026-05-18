# 2026-05 變更摘要 — git 版本控管 snapshot

本檔為本輪（2026-05）所有變更的 commit 規劃 snapshot，提供完成清單、未完成清單與建議 commit 分組。

詳細未完成項目持續追蹤見 [remaining_work_audit.md](remaining_work_audit.md)。

---

## ✅ 已完成項目

| # | 項目 | 範圍 | 主要檔案 |
|---|---|---|---|
| 1 | **A6. AppColors 重命名** | theme | app_colors.dart / theme.dart（`appCenter*` → `appFormApplication*` 32 常數）|
| 2 | **A4. 待簽列表 篩選/排序/搜尋** | UI + bloc | application_sign_off_pending bloc/event/state + pending_filter_bar_widget + sign_off_pending_sort_order enum |
| 3 | **A7. SignOffInstance 重構** | model | 新 sign_off_instance.dart 取代 leave_sign_off_model.dart；class 重命名；11 個 import 引用點同步 |
| 4 | **A1. multiStrategy 會簽收斂執行** | service | ResolvedApprover 加 multiStrategy 欄位 + 序列化；SignOffInstance 加 nodeStates；_executeAction approve/reject 加收斂邏輯；新 node_approval_state.dart |
| 5 | **A2. notify 知會節點不阻擋推進** | service + UI | autoNotify enum、ResolvedApprover.nodeType、_appendAutoNotifyAndAdvance、applyLeadingNotifySkip、form_run_service 整合、loadPendingForApprover 過濾 |
| 6 | **Canvas 連線色辨識（A2 附帶 UX）** | theme + canvas | 3 個 flow 色票（綠/紫/琥珀）+ painter 改 Map<NodeType,Color> + 新 sign_off_canvas_legend_widget |
| 7 | **emp_agent 匯出按鈕 Provider 修復** | UI | emp_agent_page.dart 改用 `_bloc.add(...)` 避免 context scope 問題 |
| 8 | **form_action_binding_service 註解補強** | doc | 加 `///` doc comments 給 class / public method / DTO |
| 9 | **sign_off_status_widget 私有元件拆分** | UI cleanup | 主檔 746 → 366 行；抽出 SignOffStatCard / SignOffChainStepRow / SignOffHistoryRow |
| 10 | **預設_指定 (injected) 策略** | service + UI | InjectedDataSource enum、providedDataKey 欄位、runtime 解析 |
| 11 | **文件同步** | docs | remaining_work_audit.md 新建 + sign_off_implementation_status.md 同步至 2026-05 真實狀態 |

---

## ❌ 未完成項目

| 優先 | 項目 | 規模 | 備註 |
|---|---|---|---|
| **P2** | A5. 模板版本控制策略 | 中 | 含設計決策（凍結 snapshot vs version 號）；建議 A 方案 |
| **P3** | A3. SLA 計時 / 提醒 | 大 | 需排程基礎建設 + 通知系統，可暫緩 |
| 小 | 會簽進度 N/M chip（A1 後續 UI） | 小 | 純前端，nodeStates 資料就緒 |
| 小 | sign_off_status_widget「已知會」徽章 | 小 | autoNotify 軌跡專屬視覺 |
| 小 | preview chain dialog notify 標籤 | 小 | 設定者預覽時辨識 notify |
| 小 | application_my 同步加 filter | 小 | 複製 A4 模式 |
| v2 | Phase C — 歸檔 / 報表 / 通知系統 | 大 | 與 A3 SLA 緊耦合 |

---

## ⚠️ 待驗證

- 退回 `returnPolicy` 三分支（toApplicant / toPrevious / toSpecific）執行細節未深入驗證
- notify 邊界（末端 / 全 notify 模板）— 已處理但建議手動測試

---

## 建議 commit 分組

| commit | 範圍 | 主要檔案數 |
|---|---|---|
| 1. `chore(theme): rename AppColors appCenter* → appFormApplication*` | theme | ~3 |
| 2. `feat(form_data_binding): add injected (預設_指定) value strategy` | binding | ~5 |
| 3. `feat(sign_off_pending): add search / sort / filter to pending list` | application_sign_off_pending | ~5 |
| 4. `refactor(sign_off): rename LeaveSignOffModel → SignOffInstance + nodeStates` | model + 11 引用點 | ~13 |
| 5. `feat(sign_off): implement multiStrategy convergence (A1)` | service | ~3 |
| 6. `feat(sign_off): notify auto-skip + canvas connection color legend (A2)` | service + canvas | ~7 |
| 7. `fix(emp_agent): bloc Provider scope on export button` | UI | 1 |
| 8. `refactor(submission_view): split sign_off_status_widget private widgets` | UI | 4 |
| 9. `docs(planning): sync to 2026-05 actual state` | docs | 2-3 |

> 或視團隊 git 習慣合併為單一大 commit。

---

## git status 變更總覽

| 類型 | 數量 |
|---|---|
| Modified | ~50+ |
| Added (untracked) | ~14 |
| Deleted | 1（leave_sign_off_model.dart）|

---

## 驗證

- `flutter analyze --no-pub` → 0 errors（剩 23 條 info 全為預先存在）
- `flutter test --no-pub` → exit 0
