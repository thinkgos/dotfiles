# dotfiles

基于`chezmoi`的用户级配置管理, `ansible`管理系统包和github应用.

- [Issue](ISSUES.md) 问题及解决方法

## **使用指南**

### minimal模式

在部署前, 确保系统已安装以下基础依赖：

- [mise](https://mise.jdx.dev/)
- [oh-my-zsh](https://ohmyz.sh/)
- `tmux 3.3+`: `apt install tmux`
- `zsh 5.9+`: `apt install zsh`

> 💡 **提示** `chezmoi` 也可以由 `mise` 统一管理, 位于`.mise.toml`.

#### 部署

```bash
git clone https://github.com/thinkgos/dotfiles.git ~/.local/share/chezmoi

cd ~/.local/share/chezmoi

# 应用 dotfiles 配置
mise run apply-minimal-dotfiles

# 设置 starship 提示符
mise run use-starship
```

### full模式

在部署前, 确保系统已安装以下基础依赖：

- [oh-my-zsh](https://ohmyz.sh/)

> 💡 **提示**: 本地机器需要安装[ansible](https://www.ansible.com), 远程机器只需要支持`python3.x`即可.

#### 布署

ansible playbook 标签:

- `system`: 安装系统包
- `github`: 安装github应用

```shell
# 本地机器
ansible-playbook site.yml -u <username> --tags system,github -K

# 远程机器(新机器)
chezmoi init --apply thinkgos

# 远程机器(已有配置机器)
chezmoi git pull
chezmoi apply
```

### 设置默认shell为zsh

```shell
# 设置默认shell为zsh
sudo chsh -s /usr/bin/zsh $USER
```

## 🐛 已知问题

- **Ubuntu 25.10+ Ansible sudo 任务失败**: 因 `sudo-rs` 不兼容导致, 详见 [ISSUE.md](ISSUE.md) 解决方案
- **zs 5.9+**: 旧版本系统需要先升级 zsh

---

## 📝 许可证

MIT License - 详见 LICENSE 文件
