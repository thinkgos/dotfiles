# AGENTS.md

## 概览

这是一个使用 [chezmoi](https://www.chezmoi.io/) 管理的**个人 dotfiles 仓库**。配置是版本控制和可复现的。项目使用 [mise](https://mise.jdx.dev/) 作为版本管理器来锁定工具版本。

**目标位置**: `$HOME` (chezmoi 的目标位置)

## 核心概念

- **源文件 vs 目标文件**: chezmoi 源文件位于此仓库中。运行 `chezmoi apply` 时，文件会被链接/模板化到 `$HOME`。
- **文件命名**: dotfiles 使用 `dot_` 前缀（例如 `dot_zshrc` → `~/.zshrc`）。
- **模板变量**: `{{ .chezmoi.version }}`, `{{ .Env.HOME }}` 等。重构时移除不必要的模板。
- **版本管理**: 所有 CLI 工具的版本都固定在 `dot_config/mise/conf.d/mise.toml` 中。

## 仓库结构

```sh
.
├── dot_zshrc              # Zsh 配置（插件、别名、初始化）
├── dot_zshenv             # Zsh 环境变量和 fpath
├── dot_vimrc              # Vim 配置
├── .mise.toml             # Mise 工具版本 + 自定义任务
├── playbook.yml           # Ansible 剧本（远程服务器）
├── ansible.cfg            # Ansible 配置
├── hosts                  # Ansible 清单
├── ISSUE.md               # 已知问题
├── README.md              # 面向用户的文档
└── dot_config/
    ├── starship.toml      # Starship 提示符配置
    ├── mise/conf.d/mise.toml  # 工具版本
    └── zellij/zellij.kdl  # Zellij 布局
```

## 项目工作指引

### 修改配置文件

1. **直接编辑**此仓库中的源文件（chezmoi source）。
2. 更改后，运行 `chezmoi apply -S .` 同步到 `$HOME`。
3. 应用前使用 `chezmoi diff` 预览更改。
4. 使用 `chezmoi edit <target>` 编辑 `$HOME` 中的文件，更改会自动同步回仓库。

### 更新工具版本

- 编辑 `dot_config/mise/conf.d/mise.toml` 来提升版本。
- 运行 `mise upgrade --bump --cd dot_config/mise/conf.d` 或 `mise run bump-tools`。

### 测试更改

- **Zsh 配置**: `source ~/.zshrc` (检查错误)
- **Vim 配置**: 打开 vim，运行 `:source ~/.vimrc`
- **Starship**: 在任何目录运行 `starship prompt`
- **Mise**: `mise ls` 验证已安装工具
- **chezmoi**: `chezmoi diff` 和 `chezmoi apply --dry-run`

### 常用命令

```bash
chezmoi apply -S .              # 应用配置
chezmoi diff                    # 预览更改
chezmoi edit .zshrc             # 编辑目标并同步回
mise run apply-dotfiles         # 通过 mise 任务应用
mise run use-starship           # 设置 starship 配置
ansible-playbook playbook.yml  # 配置远程服务器（可选）
```

## 代码风格与约定

- **Shell 脚本**: 使用 `#!/usr/bin/env zsh`，优先使用 `[[ ]]` 而不是 `[ ]`。
- **别名/函数**: 用注释文档化；在 `dot_zshrc` 中逻辑分组。
- **Vim**: 保持配置简洁；禁用方向键（`nnoremap <ArrowKeys> <NOP>`）。
- **Ansible**: 遵循 YAML 最佳实践；避免在 Ubuntu 25.10+ 上使用 `sudo-rs`（见 ISSUE.md）。

## 特别注意事项

- **Ubuntu 25.10+ 兼容性**: Ansible sudo 任务可能因 `sudo-rs` 不兼容而失败。见 ISSUE.md。
- **Kitty/Ghostty TERM 修复**: 已在 `dot_zshrc` 中通过 TERM 检测处理。
- **自定义主题**: `assets/starship/` 中的 starship 主题可以复制到 `dot_config/starship.toml`。
- **Yazi 集成**: `yy()` 函数启动 yazi，退出后自动 `cd`。

## 提交指南

- 保持提交聚焦：每个提交一个逻辑更改。
- 更改结构或添加功能时更新相关文档（README.md, AGENTS.md）。
- 不要提交密钥或机器特定的文件。

## 非生产环境使用

这是**个人** dotfiles 配置。未经审查不要应用于共享系统。根据不同的环境进行调整。
