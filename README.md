# Dotfiles

> **Developer Environment Configuration Management** 🛠️

个人开发环境配置管理仓库, 基于[chezmoi](https://www.chezmoi.io/) 实现跨平台、版本化的 dotfiles 管理. 集成现代开发工具链, 提供一致且高效的终端工作流.

[![zsh](https://img.shields.io/badge/zsh-5.9+-blue)](https://www.zsh.org/)[![mise](https://img.shields.io/badge/mise-2024+-orange)](https://mise.jdx.dev/)[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## 📋 目录

- [Dotfiles](#dotfiles)
  - [📋 目录](#-目录)
  - [✨ 核心特性](#-核心特性)
  - [🏗️ 架构概览](#️-架构概览)
  - [📦 技术栈](#-技术栈)
  - [🚀 快速开始](#-快速开始)
    - [远程服务器配置(可选)](#远程服务器配置可选)
    - [前置依赖](#前置依赖)
    - [安装部署](#安装部署)
      - [方式一：chezmoi 直接应用](#方式一chezmoi-直接应用)
      - [方式二：通过 mise 任务应用](#方式二通过-mise-任务应用)
      - [方式三：手动安装依赖 + 应用配置](#方式三手动安装依赖--应用配置)
  - [🛠️ 工具链管理](#️-工具链管理)
    - [升级工具版本](#升级工具版本)
    - [查看当前工具版本](#查看当前工具版本)
  - [⚙️ 配置详解](#️-配置详解)
    - [Shell 环境 (zsh)](#shell-环境-zsh)
    - [编辑器 (vim)](#编辑器-vim)
    - [终端复用器 (zellij)](#终端复用器-zellij)
    - [Starship 提示符](#starship-提示符)
    - [Mise 版本管理](#mise-版本管理)
  - [🔄 工作流](#-工作流)
    - [常见操作](#常见操作)
  - [🐛 已知问题](#-已知问题)
  - [📝 许可证](#-许可证)

---

## ✨ 核心特性

- **声明式配置**: 所有配置文件通过 `chezmoi` 统一管理, 支持版本控制和回滚.
- **工具版本锁定**: 使用 mise 固定所有 CLI 工具版本, 确保环境一致性
- **现代化工具链**: 集成终端增强工具, 提供语法高亮、智能补全、模糊搜索等能力
- **跨平台兼容**: 适配不同终端的 TERM 兼容性问题（Kitty/Ghostty）

---

## 🏗️ 架构概览

```sh
.
├── dot_zshrc              # Zsh 核心配置（插件、别名、初始化）
├── dot_zshenv            # Zsh 环境变量与 fpath 设置
├── dot_vimrc             # Vim 编辑器配置
├── .mise.toml            # Mise 工具版本管理与自定义任务
├── playbook.yml          # Ansible 剧本（远程服务器配置）
├── ansible.cfg           # Ansible 配置
├── hosts                 # Ansible 清单文件
├── ISSUE.md              # 已知问题与解决方案
├── README.md             # 项目文档（本文件）
└── dot_config/
    ├── starship.toml     # Starship 提示符配置
    ├── mise/
    │   └── conf.d/
    │       └── mise.toml  # Mise 扩展配置
    └── zellij/
        └── zellij.kdl     # Zellij 终端多路复用器布局
```

---

## 📦 技术栈

| 类别 | 工具 | 版本 | 用途 |
| ------ | ------ | ------ | ------ |
| **Shell** | [zsh](https://www.zsh.org/) | 5.9+ | 主 Shell, 支持插件系统 |
| | [oh-my-zsh](https://ohmyz.sh/) | latest | 插件框架与主题系统 |
| | [zinit](https://github.com/zinit-zsh/zinit) | latest | Zsh 插件管理器 |
| **Prompt** | [starship](https://starship.rs/) | latest | 跨 Shell 提示符 |
| **编辑器** | [vim](https://www.vim.org/) | 9.x | 基础编辑器 |
| **复用器** | [zellij](https://zellij.dev/) | latest | 终端多路复用器 |
| **版本管理** | [mise](https://mise.jdx.dev/) | latest | 多工具版本管理器 |
| **文件管理** | [yazi](https://github.com/sxyazi/yazi) | latest | 终端文件管理器（集成 Ranger 风格操作） |
| **工具增强** | [fzf](https://github.com/junegunn/fzf) | latest | 模糊搜索与历史过滤 |
| | [ripgrep (rg)](https://github.com/BurntSushi/ripgrep) | latest | 高性能代码搜索 |
| | [fd](https://github.com/sharkdp/fd) | latest | 简单快速的 `find` 替代 |
| | [bat](https://github.com/sharkdp/bat) | latest | 代码高亮 cat 替代 |
| | [eza](https://github.com/eza-community/eza) | latest | 现代化 `ls` 替代 |
| | [atuin](https://atuin.sh/) | latest | Shell 历史搜索与同步 |
| | [zoxide](https://github.com/zoxide-io/zoxide) | latest | 智能目录跳转 |
| | [direnv](https://direnv.net/) | latest | 目录环境变量加载 |
| | [carapace](https://github.com/carapace-sh/carapace) | latest | 多命令补全规范 |
| **配置管理** | [chezmoi](https://www.chezmoi.io/) | latest | 配置文件管理 |
| | [ansible](https://www.ansible.com/) | latest | 服务器自动化配置 |

---

## 🚀 快速开始

### 远程服务器配置(可选)

使用 Ansible 剧本统一配置远程服务器：

```bash
# 查看 ansible 清单
cat hosts

# 运行剧本
ansible-playbook playbook.yml
```

> ⚠️ **注意**: 在 Ubuntu 25.10+ 上, 由于 `sudo-rs` 不兼容性, Ansible 的 sudo 任务可能失败. 详见 [ISSUE.md](ISSUE.md).

### 前置依赖

在部署前, 确保系统已安装以下基础依赖：

| 工具 | 安装方式 | 最低版本 |
| ------ | ------ | ------ |
| **zsh** | `apt install zsh` / `brew install zsh` | 5.9+ |
| **oh-my-zsh** | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"` | latest |
| **tmux** | `apt install tmux` / `brew install tmux` | 3.3+ |
| **mise** | `curl https://mise.run \| sh` | latest |
| **chezmoi**(可选) | `curl -sfL https://get.chezmoi.io \| sh` | latest |

> 💡 **提示**: 首次安装后请重启终端或执行 `exec zsh` 切换 Shell.
> 💡 **提示** `chezmoi` 也可以由 `mise` 统一管理.

### 安装部署

#### 方式一：chezmoi 直接应用

```bash
chezmoi apply -S .
```

#### 方式二：通过 mise 任务应用

```bash
# 应用 dotfiles 配置
mise run apply-dotfiles

# 设置 starship 提示符
mise run use-starship
```

#### 方式三：手动安装依赖 + 应用配置

```bash
# 1. 安装基础依赖
# Ubuntu/Debian
sudo apt update && sudo apt install -y zsh tmux git curl

# macOS
brew install zsh tmux git

# 2. 安装 chezmoi
sh -c "$(curl -fsLS https://get.chezmoi.io)"

# 3. 创建 chezmoi 目录
mkdir -p ~/.local/share/chezmoi

# 4. 克隆仓库
git clone https://github.com/thinkgos/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi

# 5. 应用配置
chezmoi apply -S .
```

---

## 🛠️ 工具链管理

### 升级工具版本

使用 mise 统一升级所有工具版本：

```bash
# 方式一：直接运行 mise upgrade
mise upgrade --bump --cd dot_config/mise/conf.d

# 方式二：通过任务
mise run bump-tools
```

### 查看当前工具版本

```bash
# 列出所有配置的工具及其版本
mise ls

# 查看特定工具的版本
mise ls -f bash
```

---

## ⚙️ 配置详解

### Shell 环境 (zsh)

**核心配置文件**: `dot_zshrc`

- **oh-my-zsh**: 提供插件框架, 使用 `agnoster` 主题
- **内置插件**: `git`, `cp`, `tmux`, `extract`
- **zinit 管理插件**:
  - `zsh-autosuggestions` - 命令历史智能建议
  - `fast-syntax-highlighting` - 实时语法高亮
- **集成工具**: `mise`, `carapace`, `zoxide`, `atuin`, `starship`, `direnv`, `fzf`
- **自定义函数**:
  - `yy()` - 启动 yazi 文件管理器, 退出后自动 `cd` 到目标目录

**环境变量配置**: `dot_zshenv`

- 设置 `fpath` 路径, 支持自定义函数与脚本加载
- 初始化 PATH 和关键环境变量

---

### 编辑器 (vim)

**配置文件**: `dot_vimrc`

- 基础语法高亮与缩进优化
- 禁用方向键（强制使用 hjkl 导航）
- 行号显示与搜索高亮
- 文件类型检测与对应配置

---

### 终端复用器 (zellij)

**配置文件**: `dot_config/zellij/zellij.kdl`

自定义布局配置, 支持多面板、会话保持、键位映射.

---

### Starship 提示符

**配置文件**: `dot_config/starship.toml`

- **自定义分段**: 目录、Git 状态、运行时环境、时间
- **视觉风格**: Powerline 分隔符, Tokyo Night 配色方案
- **Vim 模式**: 显示当前编辑模式（normal/insert）

---

### Mise 版本管理

**主配置**: `.mise.toml`

定义工具版本和便捷任务：

- `apply-dotfiles` - 应用配置文件
- `bump-tools` - 批量升级工具
- `use-starship` - 配置 starship 提示符

**扩展配置**: `dot_config/mise/conf.d/mise.toml`

详细定义每个工具的版本号与安装源.

---

## 🔄 工作流

### 常见操作

```bash
# 应用配置变更
chezmoi apply -S .

# 更新工具版本
mise upgrade --bump --cd dot_config/mise/conf.d

# 查看配置差异（应用前先查看）
chezmoi diff

# 编辑配置
chezmoi edit .zshrc  # 示例：编辑 zsh 配置
```

---

## 🐛 已知问题

- **Ubuntu 25.10+ Ansible sudo 任务失败**: 因 `sudo-rs` 不兼容导致, 详见 [ISSUE.md](ISSUE.md) 解决方案
- **Kitty/Ghostty TERM 兼容性**: 已通过 `dot_zshrc` 中的 TERM 检测修复
- **mise 安装要求 zsh 5.9+**: 旧版本系统需要先升级 zsh

---

## 📝 许可证

MIT License - 详见 LICENSE 文件（如适用）
