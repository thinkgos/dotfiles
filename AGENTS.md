# AGENTS.md

## 项目概述

这是一个使用 [chezmoi](https://www.chezmoi.io/) 管理的**个人 dotfiles 仓库**. 它管理 Shell、编辑器和开发环境配置. 仓库使用 [mise](https://mise.jdx.dev/) 作为版本管理器来固定常用软件的工具版本.

**核心组件：**

- **Shell**: zsh 5.9+ 配合 oh-my-zsh、zinit(zsh插件管理器)和 starship 提示符
- **编辑器**: vim 基础配置
- **终端多路复用器**: zellij
- **现代 CLI 工具**: bat, eza, fzf, ripgrep, fd, carapace, atuin, zoxide, direnv, yazi 等

## 前置条件

确保系统已安装以下基础依赖：

| 工具 | 安装方式 | 最低版本 |
| ------ | ------ | ------ |
| **zsh** | `apt install zsh` / `brew install zsh` | 5.9+ |
| **oh-my-zsh** | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"` | latest |
| **tmux** | `apt install tmux` / `brew install tmux` | 3.3+ |
| **mise** | `curl https://mise.run \| sh` | latest |
| **chezmoi**(可选) | `curl -sfL https://get.chezmoi.io \| sh` | latest |

> 💡 **提示**: `chezmoi` 也可通过 `mise` 统一管理。

## 常用工作流

### 首次部署（从零开始）

```bash
# 1. 安装基础依赖（见前置条件表格）

# 2. 克隆仓库到 chezmoi 目录
git clone https://github.com/thinkgos/dotfiles.git ~/.local/share/chezmoi

# 3. 进入仓库目录
cd ~/.local/share/chezmoi

# 4. 应用配置（chezmoi 会将配置文件链接到 $HOME）
chezmoi apply -S .

# 或通过 mise 任务
mise run apply-dotfiles
```

### 更新与维护

```bash
# 拉取仓库最新变更
git pull origin main

# 重新应用配置
chezmoi apply -S .

# 查看变更（应用前先预览）
chezmoi diff

# 编辑特定配置
chezmoi edit .zshrc  # 编辑 zsh 配置
chezmoi edit .vimrc  # 编辑 vim 配置
```

### 运行 Ansible 剧本（可选）

主要管理远程服务器系统软件和基本配置

```bash
ansible-playbook playbook.yml
```

> ⚠️ **注意**: 在 Ubuntu 25.10+ 上，由于 `sudo-rs` 不兼容性，Ansible 的 sudo 任务可能失败。详见 [ISSUE.md](ISSUE.md) 解决方案。

### 工具链版本管理

```bash
# 升级所有工具到最新版本
mise upgrade --bump --cd dot_config/mise/conf.d
# 或通过 mise 任务
mise run bump-tools

# 查看当前安装的工具版本
mise ls

# 查看特定工具的版本
mise ls -f zsh
```

### 配置管理

```bash
# 设置 starship 提示符
mise run use-starship

# 更新后重新加载 zsh 配置
source ~/.zshrc

# 验证 direnv 集成（在项目目录中会有自动加载）
direnv allow
```

## 架构与结构

```sh
.
├── dot_zshrc          # 主要 zsh 配置(插件、别名、初始化)
├── dot_zshenv         # Zsh 环境变量和 fpath 设置
├── dot_vimrc          # Vim 配置(语法、缩进、键位映射)
├── .mise.toml         # Mise：工具版本 + 自定义任务
├── playbook.yml       # Ansible 剧本(远程服务器设置)
├── ansible.cfg        # Ansible 配置
├── hosts              # Ansible  inventory
├── ISSUE.md           # 已知问题与解决方案
├── README.md          # 项目概览(中文)
├── assets/
│   └── starship/      # Starship 主题模板
└── dot_config/
    ├── starship.toml  # 当前 starship 提示符配置
    ├── mise/
    │   └── conf.d/
    │       └── mise.toml  # 额外的 mise 配置
    └── zellij/
        └── zellij.kdl  # Zellij 终端多路复用器布局/配置
```

### Zsh 配置(dot_zshrc)

- 使用 **oh-my-zsh** 配合 agnoster 主题
- 插件：git, cp, tmux, extract
- **zinit** 加载额外插件：
  - zsh-autosuggestions
  - fast-syntax-highlighting
- 集成工具：mise, carapace, zoxide, atuin, starship, direnv, fzf
- 自定义 `yy()` 函数：启动 yazi 文件管理器并在退出后 cd
- Kitty/Ghostty TERM 兼容性修复

### Mise 配置(.mise.toml)

- 固定所有 CLI 工具版本(见 `dot_config/mise/conf.d/mise.toml`)
- 定义便捷任务：`apply-dotfiles`, `bump-tools`, `use-starship`
- 工具通过 shell 中的 mise 安装/激活

### Starship 提示符(dot_config/starship.toml)

- 自定义分段区块格式
- 显示：目录、git 分支/状态、语言运行时、时间
- Powerline 风格分隔符，Tokyo Night 配色方案
- 启用 Vim 模式指示器

## 重要说明

- 此仓库是**个人**配置，针对特定工作流定制.
- Ansible 剧本以 `cors.thinkgos.cn` 为目标进行服务器配置.
- 部分配置(如 starship 主题)可在 assets/ 中替换.
- vim 中的 `nnoremap <ArrowKeys> <NOP>` 禁用方向键以鼓励使用 hjkl 导航.
