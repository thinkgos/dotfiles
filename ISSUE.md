# Issue

## 1. Ansible 无法执行提权(sudo)的任务

原因: ubuntu25.10 使用了`rust`的`sudo-rs`, 而`ansible`暂未适配.

在`/etc/sudoers`中让用户无需密码即可提权:

```sh
<cors> ALL=(ALL) NOPASSWD: ALL
```

**NOTE**: 该提权有风险, 不建议在生产环境中使用. 注意使用后进行撤销.
