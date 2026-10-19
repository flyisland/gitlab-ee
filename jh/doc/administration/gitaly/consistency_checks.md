---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 代码仓库一致性检查
---

Gitaly 会运行代码仓库一致性检查：

- 触发代码仓库检查时。
- 从镜像代码仓库获取变更时。
- 用户将变更推送到代码仓库时。

这些一致性检查会验证代码仓库是否包含所有必需的对象，以及这些对象是否为有效对象。它们可以分为以下几类：

- 基础检查，用于断言代码仓库不会损坏。这包括连通性检查以及对象可解析性检查。
- 安全检查，用于识别可能被用来利用 Git 以往安全相关缺陷的对象。
- 外观检查，用于验证所有对象元数据是否有效。较旧的 Git 版本和其他 Git 实现可能会生成元数据无效的对象，但较新的版本可以解析这些格式错误的对象。

要移除未通过一致性检查的格式错误对象，需要重写代码仓库的历史记录，而这通常无法做到。因此，对于一系列不会对代码仓库一致性产生负面影响的外观问题，Gitaly 默认[禁用一致性检查](#disabled-checks)。

默认情况下，Gitaly 不会禁用基础检查或安全相关检查，以免分发可能触发 Git 客户端中已知漏洞的对象。这也限制了导入包含此类对象的代码仓库的能力，即使该项目并无恶意意图。

<a id="override-repository-consistency-checks"></a>

## 覆盖代码仓库一致性检查

如果实例管理员必须处理未通过一致性检查的代码仓库，可以覆盖一致性检查。

对于 Linux 软件包安装，请编辑 `/etc/gitlab/gitlab.rb` 并设置以下键（在本示例中，允许旧提交中存在错误的电子邮件标头，并禁用 `hasDotgit` 和 `gitmodulesUrl` 一致性检查）：

```ruby
ignored_blobs = "/etc/gitlab/instance_wide_ignored_git_blobs.txt"

gitaly['configuration'] = {
  # ...
  git: {
    # ...
    config: [
      # Allow bad email headers in old commits
      # (Populate a file with one unabbreviated SHA-1 per line.
      #  See https://git-scm.com/docs/git-config#Documentation/git-config.txt-fsckskipList)
      { key: "fsck.skipList", value: ignored_blobs },
      { key: "fetch.fsck.skipList", value: ignored_blobs },
      { key: "receive.fsck.skipList", value: ignored_blobs },
      { key: "fsck.missingSpaceBeforeEmail", value: "ignore" },

      # Ignore specific consistency checks
      # See https://git-scm.com/docs/git-fsck.html#_fsck_messages
      { key: "fsck.hasDotgit", value: "ignore" },
      { key: "fetch.fsck.hasDotgit", value: "ignore" },
      { key: "receive.fsck.hasDotgit", value: "ignore" },
      { key: "fsck.gitmodulesUrl", value: "ignore" },
      { key: "fetch.fsck.gitmodulesUrl", value: "ignore" },
    ],
  },
}
```

对于自行编译的安装，请编辑 Gitaly 配置（`gitaly.toml`）以执行等效操作：

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

为了让 Gitaly 仍能处理具有某些不影响安全性或 Gitaly 客户端的格式错误特征的代码仓库，Gitaly 默认禁用了一[部分外观检查](https://gitlab.com/gitlab-org/gitaly/-/blob/79643229c351d39a7b16d90b6023ebe5f8108c16/internal/git/command_description.go#L483-524)。

有关一致性检查的完整列表，请参阅 [Git 文档](https://git-scm.com/docs/git-fsck#_fsck_messages)。

<a id="badtimezone"></a>

### `badTimezone`

`badTimezone` 检查被禁用，因为 Git 中曾有一个缺陷，导致用户创建了时区无效的提交。因此，某些 Git 日志中包含不符合规范的提交。由于 Gitaly 默认会对收到的 `packfiles` 运行 `fsck`，任何包含此类提交的推送都会被拒绝。

<a id="missingspacebeforedate"></a>

### `missingSpaceBeforeDate`

`missingSpaceBeforeDate` 检查被禁用，因为当签名中邮件与日期之间没有空格，或日期完全缺失时，`git-fsck(1)` 会失败。这可能由多种问题引起，包括行为异常的 Git 客户端。

<a id="zeropaddedfilemode"></a>

### `zeroPaddedFilemode`

`zeroPaddedFilemode` 检查被禁用，因为较旧的 Git 版本曾对某些文件模式进行零填充。例如，树对象不会将文件模式编码为 `40000`，而是编码为 `040000`。
