---
name: create-version-control
description: "協助執行 Git 版本控管前的檢查、commit message 規劃與 push 流程。Use when: git commit、git push、版本控管、提交變更、推送分支、檢查 git status、整理 commit 訊息；任何 commit 或 push 動作執行前都必須先取得使用者明確確認。"
---

# Create Version Control Skill (版本控管流程)

此 Skill 協助在本專案中整理 Git 版本控管流程，包含檢查變更、規劃 commit message、準備 commit 與 push。所有真正會改變版本歷史或遠端狀態的動作，執行前都必須先向使用者確認。

## 使用時機 (When to use this skill)

- 當使用者要求協助執行 `git commit`、`git push` 或版本控管相關工作時。
- 當需要檢查目前工作區變更，例如 `git status`、`git diff`、`git log` 時。
- 當需要整理 staged / unstaged 變更、建議 commit message 或拆分提交時。
- 當使用者要求「幫我提交」、「幫我 push」、「版本控管」、「commit message」或「推送分支」時。

## 核心原則 (Mandatory Rules)

1. **不得自行執行版本控管**
   - 不可以在未確認的情況下執行 `git commit`。
   - 不可以在未確認的情況下執行 `git push`。
   - 不可以自行建立 tag、rebase、merge、reset、checkout 還原檔案，除非使用者明確要求並再次確認。

2. **commit 與 push 需分開確認**
   - 執行 `git commit` 前，必須先提供將提交的檔案摘要與 commit message，並等待使用者明確回覆確認。
   - 執行 `git push` 前，必須再次提供目標 remote / branch 與將推送的 commit 摘要，並等待使用者明確回覆確認。
   - 使用者只確認 commit，不代表同意 push。
   - 使用者只確認 push，不代表可以修改 commit 內容。

3. **確認必須明確**
   - 可接受的確認語意包含：「確認 commit」、「可以提交」、「執行 commit」、「確認 push」、「可以 push」、「執行 push」。
   - 若使用者語意模糊，例如「看起來可以」、「應該沒問題」、「你處理」，仍需再次詢問。
   - 不得把先前對其他任務的同意視為本次 commit 或 push 的授權。

4. **保護使用者既有變更**
   - 若工作區有非本次任務造成的變更，不得自行還原、覆蓋或納入 commit。
   - 若需要提交部分檔案，必須清楚列出要 staging 的檔案並取得確認。
   - 若發現衝突、未追蹤檔案或不確定來源的變更，需先回報並等待使用者決策。

## 建議流程 (Recommended Workflow)

### 1. 檢查狀態

可先執行不會改變狀態的檢查命令：

```powershell
git status --short
git diff --stat
git diff --cached --stat
git branch --show-current
```

檢查後需摘要：

- 目前分支
- staged 檔案
- unstaged 檔案
- untracked 檔案
- 是否有疑似非本次任務的變更

### 2. 準備 commit

在執行任何 staging 或 commit 前，先向使用者說明：

- 預計納入 commit 的檔案清單
- 不會納入 commit 的檔案清單，如有
- 建議 commit message
- 是否需要拆成多個 commit

確認句建議：

```text
請確認是否要將上述檔案加入 staged 並執行 git commit，commit message 為：「...」。
```

只有在使用者明確確認後，才可執行：

```powershell
git add <confirmed-files>
git commit -m "<confirmed-message>"
```

### 3. 準備 push

commit 完成後，不可直接 push。需再次確認：

- 目前分支
- 目標 remote / branch
- 即將推送的 commit 摘要

確認句建議：

```text
commit 已完成。請確認是否要 push 到 origin/<branch>。
```

只有在使用者明確確認後，才可執行：

```powershell
git push origin <branch>
```

## 禁止行為 (Do Not)

- 不得因使用者要求「幫我處理版本控管」就直接 commit 或 push。
- 不得使用 `git add .`，除非使用者明確確認所有變更都要納入。
- 不得自行修改 commit message 後直接提交；message 需先給使用者看過。
- 不得自行執行 `git reset --hard`、`git checkout -- <file>`、`git clean`、`git rebase`、`git merge` 等可能破壞或改寫狀態的命令。
- 不得在 push 失敗後自行 force push；`--force` 或 `--force-with-lease` 必須由使用者明確要求並再次確認。

## 回報格式 (Response Pattern)

檢查完版本狀態後，優先使用以下格式回報：

```text
目前分支：<branch>
Staged：<files>
Unstaged：<files>
Untracked：<files>

建議 commit message：<message>

請確認是否要執行 commit。
```

push 前使用以下格式回報：

```text
準備 push：origin/<branch>
即將推送 commit：<short-hash> <message>

請確認是否要執行 push。
```

## 預期輸出 (Expected Output)

當使用此 Skill 時，應優先產出以下結果：

- 清楚列出目前 Git 狀態與風險。
- 提供可讀、符合變更內容的 commit message 建議。
- 在 commit 前取得使用者明確確認。
- 在 push 前再次取得使用者明確確認。
- 若使用者未確認，停止在準備階段，不執行版本控管命令。