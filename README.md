# dotfiles

基于`chezmoi`的用户级配置管理, `ansible`管理系统包和github应用.

- [Issue](ISSUES.md) 问题及解决方法

## **使用指南**

在布署前, 确保系统已安装以下基础依赖：

方式1: 本地机器需要安装[ansible](https://www.ansible.com), 远程机器只需要支持`python3.x`即可.
方式2: 执行`bootstrap.sh`脚本

### 布署

ansible playbook 标签:

- `system`: 安装系统包
- `github`: 安装github应用

方式1:

```shell
# 本地机器
ansible-playbook site.yml -u <username> --tags system,github -K

# 远程机器(新机器)
chezmoi init --apply thinkgos

# 远程机器(已有配置机器)
chezmoi git pull
chezmoi apply
```

方式2:

```shell
# 远程机器(新机器)
git clone https://github.com/thinkgos/dotfiles.git ~/.local/share/chezmoi

# 远程机器(已有配置机器)
chezmoi git pull

sudo ~/.local/share/chezmoi/bootstrap.sh
chezmoi apply
```

### 设置默认shell为zsh

```shell
# 设置默认shell为zsh
sudo chsh -s /usr/bin/zsh $USER
```

## 🐛 已知问题

- **Ubuntu 26.04+ Ansible sudo 任务失败**: 因 `sudo-rs` 不兼容导致, 详见 [ISSUE.md](ISSUE.md) 解决方案
- **zsh 5.9+**: 旧版本系统需要先升级 zsh

---

## 📝 许可证

MIT License - 详见 LICENSE 文件
