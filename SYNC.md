# TownWave Director 跨电脑同步指南

这个 skill 已经是一个 git 仓库，真相源在 GitHub。两台电脑（A / B）都从同一个仓库拉取/推送，就能保持同步。

> **版本：1.1.0** — 已加入「阶段 00 · 启动同步」：每次使用 skill 时自动 `git pull --ff-only` 拉取最新版，无需手动记着 pull。

## 〇、自动更新（最省心，默认开启）

skill 被调用时，**任何创作流程之前**会自动跑一次拉取（`auto-update.bat` → `git pull --ff-only --prune`）：

- 已是最新 → 静默继续。
- 有更新 → 提示你「已更新到 commit xxx」，并建议本轮结束后重开会话加载最新指令。
- 无网络 / 需登录 / 本地有未推送改动 → **不阻塞**，用本地版继续，稍后手动 `sync-pull.bat` 或先 `sync-push.bat`。

> 想自己手动拉：双击 `sync-pull.bat`。想禁用自动拉取：把 SKILL.md 里「阶段 00」整段删掉即可（不推荐）。



## 一、本机已经做好的事

- 在 skill 目录就地 `git init`（默认分支 `main`）
- 提交了初始版本 `v1.0.0`（SKILL.md + references/ + templates/ + agents/）
- 忽略了 `_user_meta.json`（每台机器导入时生成的安装元数据，不同步）

> 仓库位置：`%USERPROFILE%\.workbuddy\skills\townwave-director`
> WorkBuddy 照常从这个路径加载 skill，git 仓库和它互不干扰。

## 二、把仓库推到 GitHub（只需做一次）

> 注意：连上的 GitHub MCP 集成账号**没有建仓库的权限范围**（实测创建返回 403），所以仓库要你手动建；但 `remote` 已经帮你加好了，推送直接用脚本。

1. 打开 https://github.com/new 新建一个**空仓库**：
   - 仓库名：`townwave-director`
   - 选 **Private（私有）**
   - **不要**勾选 "Add a README" / .gitignore / License，保持空仓库（否则首次 push 会因历史不一致报错）
2. 仓库地址（已写进 remote，照抄备用）：`https://github.com/GaoJiedot/townwave-director.git`
3. 在本机 skill 目录里**双击 `sync-push.bat`**（或终端执行 `git push -u origin main`）。
   - 第一次会弹浏览器让你登录 GitHub（OAuth）。登录一次后，Git Credential Manager 会记住，之后 `sync-push.bat` / `sync-pull.bat` 全自动，无需再登。
   - 登录完成后，初始提交就上了 GitHub，仓库变成真相源。

## 三、另一台电脑（机器 B）首次获取

机器 B 上 WorkBuddy 如果已经导入过同名 skill，先把它清空/删掉，再克隆：

```bat
# 删掉旧的（确认里面没有你独有的未备份改动）
rmdir /s /q "%USERPROFILE%\.workbuddy\skills\townwave-director"
# 克隆仓库到 skills 目录
git clone https://github.com/GaoJiedot/townwave-director.git "%USERPROFILE%\.workbuddy\skills\townwave-director"
```

克隆完，WorkBuddy 重启（或刷新技能）即可加载到最新版 skill。

## 四、日常同步（最常用）

- **结束在某一台电脑的改动后** → 双击 `sync-push.bat`
  它会：`git add -A` → `git commit`（备注含时间）→ `git push`
- **换到另一台电脑开始干活前** → 双击 `sync-pull.bat`
  它会：`git pull` 把最新改动拉下来

> 约定：永远「先 pull 再改，改完就 push」。这样两台机器不会同时改出冲突。

## 五、冲突了怎么办

如果两台机器都改了同一份文件再 push/pull，git 会报冲突：

1. 打开报冲突的文件，找 `<<<<<<<` / `=======` / `>>>>>>>` 标记，手动合并成你想要的版本。
2. 保存后执行：
   ```bat
   git add -A
   git commit -m "resolve conflict"
   git push
   ```
3. 另一台机器 `git pull` 即可。

## 六、提交身份（可选，但建议做）

本机初始提交用的是占位身份 `gaojie <gaojie@townwave.local>`，GitHub 不会把它关联到你的账号。
想让提交显示你的头像，把邮箱改成你在 GitHub 上**已验证**的邮箱（或 GitHub 提供的 no-reply 邮箱）：

```bat
git config user.email "你的GitHub邮箱"
git config user.name "你的GitHub用户名"
```

## 七、注意事项

- `_user_meta.json` 已被忽略，不会进仓库，两台机器各自保留自己的安装元数据，互不覆盖。
- 改 skill 后**务必 push**，否则另一台机器拉不到。
- 视频生成、bible/ledger 这类「项目产物」不属于 skill 本体，不进这个仓库（它们是具体项目的数据）。
