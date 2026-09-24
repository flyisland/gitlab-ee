---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 仓库检查
---

<a id="repository-checks"></a>

仓库检查

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用 [`git fsck`](https://git-scm.com/docs/git-fsck) 验证提交到仓库的所有数据的完整性。极狐GitLab 管理员可以：

- [手动为项目触发此检查](#check-a-projects-repository-using-gitlab-ui)。
- [安排此检查](#enable-repository-checks-for-all-projects) 以自动对所有项目运行。
- [从命令行运行此检查](#run-a-check-using-the-command-line)。
- 运行一个 [Rake 任务](raketasks/check.md#repository-integrity) 来检查 Git 仓库，该任务可用于对所有仓库运行 `git fsck` 并生成仓库校验和，以便比较不同服务器上的仓库。

未在命令行上手动运行的检查将通过 Gitaly 节点执行。有关 Gitaly 仓库一致性检查、某些已禁用的检查以及如何配置一致性检查的信息，请参阅
[仓库一致性检查](gitaly/consistency_checks.md)。

<a id="check-a-projects-repository-using-gitlab-ui"></a>

## 使用 极狐GitLab UI 检查项目仓库

要使用 极狐GitLab UI 检查项目仓库：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **概览** > **项目**。
1. 选择要检查的项目。
1. 在 **仓库检查** 部分，选择 **触发仓库检查**。

检查是异步运行的，因此可能需要几分钟时间才能在 **管理员** 区域的项目页面上看到检查结果。如果检查失败，请参阅[如何处理](#what-to-do-if-a-check-failed)。

<a id="enable-repository-checks-for-all-projects"></a>

## 为所有项目启用仓库检查

您可以配置 极狐GitLab 定期运行检查，而无需手动检查仓库：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **仓库**。
1. 展开 **仓库维护**。
1. 启用 **启用仓库检查**。

启用后，极狐GitLab 会定期对所有项目仓库和 Wiki 仓库运行仓库检查，以检测可能的数据损坏。每个项目每月检查不超过一次，新项目在至少 24 小时内不会被检查。

极狐GitLab 私有化部署管理员可以配置仓库检查的频率。要编辑频率：

- 对于 Linux 软件包安装，编辑 `/etc/gitlab/gitlab.rb` 中的 `gitlab_rails['repository_check_worker_cron']`。
- 对于从源代码安装，编辑 `/home/git/gitlab/config/gitlab.yml` 中的 `[gitlab.cron_jobs.repository_check_worker]`。

如果有任何项目的仓库检查失败，所有 极狐GitLab 管理员都会收到有关该情况的电子邮件通知。默认情况下，此通知在周日开始的午夜每周发送一次。

可以在 `/admin/projects?last_repository_check_failed=true` 找到已知检查失败的仓库。

<a id="run-a-check-using-the-command-line"></a>

## 使用命令行运行检查

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

您可以在 [Gitaly 服务器](gitaly/_index.md) 上使用命令行对仓库运行 [`git fsck`](https://git-scm.com/docs/git-fsck)。要定位仓库：

1. 前往仓库的存储位置：
   - 对于 Linux 软件包安装，默认情况下仓库存储在 `/var/opt/gitlab/git-data/repositories` 目录中。
   - 对于 极狐GitLab Helm Chart 安装，默认情况下仓库存储在 Gitaly pod 内的 `/home/git/repositories` 目录中。
1. [识别包含您需要检查的仓库的子目录](repository_storage_paths.md#from-project-name-to-hashed-path)。
1. 运行检查。例如：

   ```shell
   sudo -u git /opt/gitlab/embedded/bin/git \
      -C /var/opt/gitlab/git-data/repositories/@hashed/0b/91/0b91...f9.git fsck --no-dangling
   ```

   错误 `fatal: detected dubious ownership in repository` 表示您使用了错误的帐户运行命令。例如，`root` 用户。

<a id="what-to-do-if-a-check-failed"></a>

## 如果检查失败该怎么做

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

如果仓库检查失败，请在磁盘上找到 [`repocheck.log` 文件](logs/_index.md#repochecklog) 中的错误，位置在：

- 对于 Linux 软件包安装，在 `/var/log/gitlab/gitlab-rails` 中。
- 对于自编译安装，在 `/home/git/gitlab/log` 中。
- 对于 极狐GitLab Helm Chart 安装，在 Sidekiq pod 的 `/var/log/gitlab` 中。

如果定期仓库检查导致误报，您可以清除所有仓库检查状态：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **仓库**。
1. 展开 **仓库维护**。
1. 选择 **清除所有仓库检查**。

<a id="troubleshooting"></a>

## 故障排除

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

在处理仓库检查时，您可能会遇到以下问题。

<a id="error-failed-to-parse-commit-commit-sha-from-object-database-for-commit-graph"></a>

### 错误：`failed to parse commit <commit SHA> from object database for commit-graph`

您可能会在仓库检查日志中看到 `failed to parse commit <commit SHA> from object database for commit-graph` 错误。如果您的 `commit-graph` 缓存已过时，则会出现此错误。`commit-graph` 缓存是一个辅助缓存，常规 Git 操作不需要它。

虽然可以安全地忽略此消息。

<a id="dangling-commit-tag-or-blob-messages"></a>

### Dangling commit、tag 或 blob 消息

仓库检查输出通常包含必须修剪的标签、blob 和提交：

```plaintext
dangling tag 5c6886c774b713a43158aae35c4effdb03a3ceca
dangling blob 3e268c23fcd736db92e89b31d9f267dd4a50ac4b
dangling commit 919ff61d8d78c2e3ea9a32701dff70ecbefdd1d7
```

这在 Git 仓库中很常见。它们是由诸如强制推送到分支之类的操作生成的，因为这会在仓库中生成一个不再被引用（ref）或其他提交引用的提交。

如果仓库检查失败，输出中很可能包含这些警告。

请忽略这些消息，并从其他输出中找出仓库检查失败的根本原因。

极狐GitLab 15.8 及更高版本在检查输出中不再包含这些消息。从命令行运行时，可以使用 `--no-dangling` 选项来抑制它们。