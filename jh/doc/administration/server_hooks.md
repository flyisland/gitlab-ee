---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Git 服务器钩子
description: Configure Git server hooks.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.6 中，从服务器钩子重命名为 Git 服务器钩子。

{{< /history >}}

Git 服务器钩子在极狐GitLab 服务器上运行自定义逻辑。您可以使用它们来运行与 Git 相关的任务，例如：

- 强制执行特定的提交策略。
- 基于仓库状态执行任务。

Git 服务器钩子使用 `pre-receive`、`post-receive` 和 `update` Git 服务器端钩子。

极狐GitLab 管理员使用 `gitaly` 命令配置服务器钩子，该命令还可以：

- 用于启动 Gitaly 服务器。
- 提供多个子命令。
- 连接到 Gitaly gRPC API。

如果您无法访问 `gitaly` 命令，服务器钩子的替代方案包括：

- [Webhooks](../user/project/integrations/webhooks.md)。
- [极狐GitLab CI/CD](../ci/_index.md)。
- [推送规则](../user/project/repository/push_rules.md)，用于用户可配置的 Git 钩子界面。

对于极狐GitLab Helm chart 实例，请参阅 [Gitaly chart 中的全局服务器钩子](https://gitlab.cn/docs/charts/charts/gitlab/gitaly/#global-server-hooks)。

> [!note]
> [Geo](geo/_index.md) 不会将服务器钩子复制到次要节点。

<a id="prerequisites"></a>

## 先决条件

- [存储名称](gitaly/configure_gitaly.md#gitlab-requires-a-default-repository-storage)、Gitaly 配置文件的路径（在 Linux 软件包实例上默认为 `/var/opt/gitlab/gitaly/config.toml`）以及仓库的 [仓库相对路径](repository_storage_paths.md#from-project-name-to-hashed-path)。
- 钩子所需的任何语言运行时和实用程序必须安装在运行 Gitaly 的每个服务器上。

<a id="set-server-hooks-for-a-repository"></a>

## 为仓库设置服务器钩子

要为仓库设置服务器钩子：

1. 创建包含自定义钩子的 tarball：
   1. 编写代码使服务器钩子按预期运行。Git 服务器钩子可以使用任何编程语言。确保顶部的 shebang 反映语言类型。例如，如果脚本是 Ruby，shebang 可能是 `#!/usr/bin/env ruby`。

      - 要创建单个服务器钩子，创建一个名称与钩子类型匹配的文件。例如，对于 `pre-receive` 服务器钩子，文件名应为 `pre-receive`，无扩展名。
      - 要创建多个服务器钩子，创建一个与钩子类型匹配的目录。例如，对于 `pre-receive` 服务器钩子，目录名应为 `pre-receive.d`。将钩子文件放入该目录。

   1. 确保服务器钩子文件可执行，并且不匹配备份文件模式（`*~`）。服务器钩子应位于 tarball 根目录下的 `custom_hooks` 目录中。
   1. 使用 tar 命令创建自定义钩子存档。例如，`tar -cf custom_hooks.tar custom_hooks`。
1. 运行 `hooks set` 子命令并附带所需选项，为仓库设置 Git 钩子。例如：

   ```shell
   cat custom_hooks.tar | sudo -u git -- /opt/gitlab/embedded/bin/gitaly hooks set --storage <storage> --repository <relative path> --config <config path>
   ```

   - 需要提供节点的有效 Gitaly 配置路径以连接到该节点，并通过 `--config` 标志提供。
   - 自定义钩子 tarball 必须通过 `stdin` 传递。例如：

     ```shell
     cat custom_hooks.tar | sudo -u git -- /opt/gitlab/embedded/bin/gitaly hooks set --storage <storage> --repository <relative path> --config <config path>
     ```

1. 如果您使用 Gitaly 集群（Praefect），则必须在所有 Gitaly 节点上运行 `hooks set` 子命令。

如果服务器钩子代码实现正确，它应在下次触发 Git 钩子时执行。

<a id="server-hooks-on-a-gitaly-cluster-praefect"></a>

### 在 Gitaly 集群（Praefect）上的服务器钩子

如果您使用 Gitaly 集群（Praefect），单个仓库可能会被复制到 Praefect 中的多个 Gitaly 存储。因此，钩子脚本必须复制到每个拥有仓库副本的 Gitaly 节点。为此，请按照为适用版本设置自定义仓库钩子的相同步骤操作，并对每个存储重复执行。

复制脚本的位置取决于仓库的存储位置。新仓库使用 Praefect 生成的副本路径创建，该路径不是哈希存储路径。要识别副本路径，请 [查询 Praefect 仓库元数据](gitaly/praefect/troubleshooting.md#view-repository-metadata)，使用 `-relative-path` 选项指定预期的极狐GitLab 哈希存储路径。

<a id="create-global-server-hooks-for-all-repositories"></a>

## 为所有仓库创建全局服务器钩子

要创建适用于所有仓库的 Git 钩子，请设置全局服务器钩子。全局服务器钩子也适用于：

- 项目和群组 Wiki 仓库。它们的存储目录名称格式为 `<id>.wiki.git`。
- 项目下的设计管理仓库。它们的存储目录名称格式为 `<id>.design.git`。

<a id="choose-a-server-hook-directory"></a>

### 选择服务器钩子目录

在创建全局服务器钩子之前，您必须为其选择一个目录。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

目录在 `gitlab.rb` 中的 `gitaly['configuration'][:hooks][:custom_hooks_dir]` 下设置。您可以：

- 通过取消注释使用默认建议的 `/var/opt/gitlab/gitaly/custom_hooks` 目录。
- 添加您自己的设置。

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

- 目录在 `gitaly/config.toml` 的 `[hooks]` 部分下设置。但是，如果 `gitaly/config.toml` 中的值为空或不存在，极狐GitLab 会遵循 `gitlab-shell/config.yml` 中的 `custom_hooks_dir` 值。
- 默认目录是 `/home/git/gitlab-shell/hooks`。

{{< /tab >}}

{{< /tabs >}}

<a id="create-the-global-server-hook"></a>

### 创建全局服务器钩子

要为所有仓库创建全局服务器钩子：

1. 在极狐GitLab 服务器上，进入配置的全局服务器钩子目录。
1. 在配置的全局服务器钩子目录中，创建一个与钩子类型匹配的目录。例如，对于 `pre-receive` 服务器钩子，目录名应为 `pre-receive.d`。
1. 在此新目录内，添加您的服务器钩子。Git 服务器钩子可以使用任何编程语言。确保顶部的 shebang (`#!`) 反映语言类型。例如，如果脚本是 Ruby，shebang 可能是 `#!/usr/bin/env ruby`。
1. 使钩子文件可执行，确保其属于 Git 用户，并确保它不匹配备份文件模式 (`*~`)。

如果服务器钩子代码正确实现，它应在下次触发 Git 钩子时执行。钩子在钩子类型子目录中按文件名字母顺序执行。

<a id="remove-server-hooks-for-a-repository"></a>

## 移除仓库的服务器钩子

要移除服务器钩子，向 `hook set` 传递一个空的 tarball，以指示仓库不应包含任何钩子。例如：

```shell
cat empty_hooks.tar | sudo -u git -- /opt/gitlab/embedded/bin/gitaly hooks set --storage <storage> --repository <relative path> --config <config path>
```

<a id="chained-server-hooks"></a>

## 链式服务器钩子

极狐GitLab 可以链式执行服务器钩子。极狐GitLab 按以下顺序搜索并执行服务器钩子：

- 内置的极狐GitLab 服务器钩子。这些服务器钩子不可由用户自定义。
- `<project>.git/custom_hooks/<hook_name>`：每个项目的钩子。保留此位置是为了向后兼容。
- `<project>.git/custom_hooks/<hook_name>.d/*`：每个项目的钩子位置。
- `<custom_hooks_dir>/<hook_name>.d/*`：所有可执行全局钩子文件的位置，编辑器备份文件除外。

在服务器钩子目录中，钩子：

- 按字母顺序执行。
- 当某个钩子以非零值退出时停止执行。

<a id="environment-variables-available-to-server-hooks"></a>

## 服务器钩子可用的环境变量

您可以向服务器钩子传递任何环境变量，但应仅依赖受支持的环境变量。

所有服务器钩子支持以下极狐GitLab 环境变量：

| 环境变量 | 描述 |
|:---------------------|:------------|
| `GL_ID`              | 发起推送的用户或 SSH 密钥的极狐GitLab 标识符。例如，`user-2234` 或 `key-4`。 |
| `GL_PROJECT_PATH`    | 极狐GitLab 项目路径。 |
| `GL_PROTOCOL`        | 用于此更改的协议。以下之一：`http`（使用 HTTP 的 Git `push`）、`ssh`（使用 SSH 的 Git `push`）或 `web`（所有其他操作）。 |
| `GL_REPOSITORY`      | 带有 `project-` 前缀的极狐GitLab 项目 ID。例如，`project-1234` |
| `GL_USERNAME`        | 发起推送的用户的极狐GitLab 用户名。 |

`pre-receive` 和 `post-receive` 服务器钩子支持以下 Git 环境变量：

| 环境变量 | 描述 |
|:-----------------------------------|:------------|
| `GIT_ALTERNATE_OBJECT_DIRECTORIES` | [隔离环境](https://git-scm.com/docs/git-receive-pack#_quarantine_environment)中的备用对象目录。 |
| `GIT_OBJECT_DIRECTORY`             | 隔离环境中的极狐GitLab 项目路径。 |
| `GIT_PUSH_OPTION_COUNT`            | [推送选项](../topics/git/commit.md#push-options)的数量。 |
| `GIT_PUSH_OPTION_<i>`              | 特定推送选项的值，其中 `<i>` 从 `0` 到 `GIT_PUSH_OPTION_COUNT` 定义的值减一。 |

<a id="custom-error-messages"></a>

## 自定义错误消息

当服务器钩子拒绝推送时，提供清晰的错误消息，以帮助用户了解推送被拒绝的原因以及如何解决问题。当钩子拒绝推送时，自定义错误消息会显示在极狐GitLab UI 和用户的终端中。

如果没有自定义错误消息，用户只会看到类似 `(pre-receive hook declined)` 的通用消息。清晰的错误消息有助于用户：

- 了解他们的推送被拒绝的原因。
- 无需联系管理员即可解决问题。
- 减少支持请求。

要显示自定义错误消息，您的脚本必须：

- 将自定义错误消息发送到脚本的 `stdout` 或 `stderr`。
- 在每个消息前加上 `GL-HOOK-ERR:`，且前缀前不能有任何字符。

例如：

```shell
# Bad: Generic message
echo "GL-HOOK-ERR: Commit rejected.";

# Good: Specific message with action
echo "GL-HOOK-ERR: Commit rejected: Commit message must include an issue reference (for example, #1234).";
```

<a id="related-topics"></a>

## 相关主题

- [系统钩子](system_hooks.md)
- [文件钩子](file_hooks.md)
- [Praefect 生成的副本路径](gitaly/praefect/_index.md#praefect-generated-replica-paths)

<a id="troubleshooting"></a>

## 故障排除

在使用 Git 服务器钩子时，您可能会遇到以下问题。

<a id="error-pre-receive-hook-declined"></a>

### 错误：`pre-receive hook declined`

当用户推送到极狐GitLab 仓库时，他们可能会收到包含 `(pre-receive hook declined)` 的错误消息。例如：

```plaintext
! [remote rejected] main (pre-receive hook declined)
error: failed to push some refs to 'https://gitlab.example.com/group/project'
```

此错误表示 pre-receive 钩子拒绝了推送。Pre-receive 钩子在仓库中的任何引用更新之前运行。Git 提供了三个可以拒绝推送的服务器端钩子：

- `pre-receive`：在任何引用更新之前运行。可以拒绝整个推送。
- `update`：每个被更新的分支运行一次。可以拒绝单个分支。
- `post-receive`：在所有引用更新之后运行。不能拒绝推送，但如果钩子失败可能会导致错误。

`(pre-receive hook declined)` 错误通常来自 `pre-receive` 或 `update` 钩子。要确定问题：

1. 检查 `(pre-receive hook declined)` 消息之前的输出。输出通常包含有关推送被拒绝原因的信息。例如：

   ```plaintext
   remote: GitLab: The default branch of a project cannot be deleted.
   ! [remote rejected] main (pre-receive hook declined)
   ```

1. 检查 Gitaly 日志以获取有关钩子失败原因的更多详细信息：

   ```shell
   sudo grep PreReceiveHook /var/log/gitlab/gitaly/current | jq .
   ```

1. 如果仓库配置了自定义服务器钩子，请检查自定义钩子代码是否有问题。

以下是 pre-receive 钩子失败的常见原因：

- 默认分支保护：删除或强制更新默认分支的推送会被拒绝。当源仓库的默认分支与目标仓库不同时，使用 `git push --mirror` 会发生这种情况。
- 推送规则：推送违反了配置的推送规则，例如提交消息要求、文件大小限制或作者电子邮件限制。
- 自定义服务器钩子：自定义服务器钩子脚本拒绝了推送。检查您的自定义钩子代码和错误消息。
- 超时：钩子运行时间过长并被终止。检查 Gitaly 日志中的超时错误。
- LFS 对象：仓库中缺少必需的 Git LFS 对象。

为了帮助用户理解钩子失败，请使用 [自定义错误消息](#custom-error-messages) 提供有关推送被拒绝原因的清晰反馈。自定义错误消息显示在极狐GitLab UI 和用户的终端中。