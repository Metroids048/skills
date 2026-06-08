# 发布到 GitHub

本仓库已在本地 commit。推送前需 **一次** GitHub 登录。

## 1. 登录 GitHub CLI

```powershell
gh auth login
```

按提示选择 GitHub.com → HTTPS → 浏览器登录（或 paste token）。

## 2. 创建远程仓库并推送

在仓库根目录执行：

```powershell
cd "C:\Users\win\Desktop\ai-global-config"
powershell -ExecutionPolicy Bypass -File scripts/publish-to-github.ps1
```

或手动：

```powershell
gh repo create ai-global-config --private --source=. --remote=origin --push --description "Cursor/Codex/Claude global AI config sync"
```

若仓库已在 GitHub 上创建过，仅推送：

```powershell
git remote add origin https://github.com/YOUR_USER/ai-global-config.git
git push -u origin main
```

> 若默认分支是 `master`：`git branch -M main` 后再 push。

## 3. 另一台设备安装

```powershell
git clone https://github.com/YOUR_USER/ai-global-config.git
cd ai-global-config
powershell -ExecutionPolicy Bypass -File install.ps1
```

然后按 `secrets/README.md` 配置 token 与 API 代理，重启三端。

## 4. 本机有变更时同步

```powershell
powershell -ExecutionPolicy Bypass -File scripts/export-from-local.ps1 -Force
git add -A
git commit -m "chore: sync global config from local"
git push
```
