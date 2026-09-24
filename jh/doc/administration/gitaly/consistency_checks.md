---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 仓库一致性检查
---

Gitaly 在以下情况下运行仓库一致性检查：

- 触发仓库检查时。
- 从镜像仓库获取变更时。
- 用户向仓库推送变更时。

这些一致性检查验证仓库具有所有必需的对象并且这些对象是有效的对象。它们可以分为：

- 基础检查，断言仓库不会损坏。这包括连通性检查和对象是否可解析的检查。
- 安全检查，识别适合利用 Git 中以往安全相关错误的对象。
- 修饰性检查，验证所有对象元数据是否有效。较旧的 Git 版本和其他 Git 实现可能产生具有无效元数据的对象，但较新版本可以解释这些格式不正确的对象。

移除未通过一致性检查的格式不正确的对象需要重写仓库的历史记录，这通常难以实现。因此，Gitaly 默认[禁用了对一系列不影响仓库一致性的修饰性问题的检查](#disabled-checks)。

默认情况下，Gitaly 不禁用基础或安全相关检查，以避免分发可能触发 Git 客户端已知漏洞的对象。这也限制了导入包含此类对象的仓库的能力，即使项目没有恶意意图。

<a id="override-repository-consistency-checks"></a>

## 覆盖仓库一致性检查

实例管理员如果必须处理未通过一致性检查的仓库，可以覆盖一致性检查。

对于 Linux 安装包方式，编辑 `/etc/gitlab/gitlab.rb` 并设置以下键（在此示例中，允许旧提交中的错误电子邮件头，并禁用 `hasDotgit` 和 `gitmodulesUrl` 一致性检查）：

```ruby
ignored_blobs = "/etc/gitlab/instance_wide_ignored_git_blobs.txt"

gitaly['configuration'] = {
  # ...
  git: {
    # ...
    config: [
      # 允许旧提交中的错误电子邮件头
      # （填充一个文件，每行一个未缩写的 SHA-1。
      #  参见 https://git-scm.com/docs/git-config#Documentation/git-config.txt-fsckskipList）
      { key: "fsck.skipList", value: ignored_blobs },
      { key: "fetch.fsck.skipList", value: ignored_blobs },
      { key: "receive.fsck.skipList", value: ignored_blobs },
      { key: "fsck.missingSpaceBeforeEmail", value: "ignore" },

      # 忽略特定的一致性检查
      # 参见 https://git-scm.com/docs/git-fsck.html#_fsck_messages
      { key: "fsck.hasDotgit", value: "ignore" },
      { key: "fetch.fsck.hasDotgit", value: "ignore" },
      { key: "receive.fsck.hasDotgit", value: "ignore" },
      { key: "fsck.gitmodulesUrl", value: "ignore" },
      { key: "fetch.fsck.gitmodulesUrl", value: "ignore" },
    ],
  },
}
```

对于自编译安装方式，编辑 Gitaly 配置文件 (`gitaly.toml`) 以实现等效配置：

```toml
[[git.config]]
key = "fsck.hasDotgit"
value = "ignore"

[[git.config]]
key = "fetch.fsck.hasDotgit"
value = "ignore"

[[git.config]]
key = "receive.fsck.hasDotgit"
value = "ignore"

[[git.config]]
key = "fsck.missingSpaceBeforeEmail"
value = "ignore"

[[git.config]]
key = "fetch.fsck.missingSpaceBeforeEmail"
value = "ignore"

[[git.config]]
key = "receive.fsck.missingSpaceBeforeEmail"
value = "ignore"

[[git.config]]
key = "fsck.gitmodulesUrl"
value = "ignore"

[[git.config]]
key = "fetch.fsck.gitmodulesUrl"
value = "ignore"

[[git.config]]
key = "fsck.skipList"
value = "/etc/gitlab/instance_wide_ignored_git_blobs.txt"

[[git.config]]
key = "fetch.fsck.skipList"
value = "/etc/gitlab/instance_wide_ignored_git_blobs.txt"

[[git.config]]
key = "receive.fsck.skipList"
value = "/etc/gitlab/instance_wide_ignored_git_blobs.txt"
```

<a id="disabled-checks"></a>

## 已禁用的检查

为了使 Gitaly 仍能处理具有某些不影响安全性或 Gitaly 客户端的不规范特征的仓库，Gitaly 默认禁用了[修饰性检查的子集](https://jihulab.com/gitlab-cn/gitaly/-/blob/79643229c351d39a7b16d90b6023ebe5f8108c16/internal/git/command_description.go#L483-524)。

有关一致性检查的完整列表，请参见 [Git 文档](https://git-scm.com/docs/git-fsck#_fsck_messages)。

<a id="badtimezone"></a>

### `badTimezone` 检查

`badTimezone` 检查被禁用，因为 Git 中存在一个错误，导致用户创建了时区无效的提交。结果，一些 Git 日志包含不符合规范的提交。由于 Gitaly 默认对接收到的 `packfiles` 运行 `fsck`，任何包含此类提交的推送都将被拒绝。

<a id="missingspacebeforedate"></a>

### `missingSpaceBeforeDate` 检查

`missingSpaceBeforeDate` 检查被禁用，因为当签名在邮件和日期之间缺少空格，或者日期完全缺失时，`git-fsck(1)` 会失败。这可能由多种问题引起，包括行为不当的 Git 客户端。

<a id="zeropaddedfilemode"></a>

### `zeroPaddedFilemode` 检查

`zeroPaddedFilemode` 检查被禁用，因为较旧的 Git 版本曾经对一些文件模式进行零填充。例如，文件模式 `40000`，树对象可能会将文件模式编码为 `040000`。

