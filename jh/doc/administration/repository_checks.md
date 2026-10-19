---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 代码仓库检查
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以使用 [`git fsck`](https://git-scm.com/docs/git-fsck) 来验证提交到代码仓库的所有数据的完整性。极狐GitLab 管理员可以：

- [手动为项目触发此检查](#check-a-projects-repository-using-gitlab-ui)。
- [安排此检查](#enable-repository-checks-for-all-projects)对所有项目自动运行。
- [从命令行运行此检查](#run-a-check-using-the-command-line)。
- 运行 [Rake 任务](raketasks/check.md#repository-integrity)来检查 Git 代码仓库，该任务可用于对所有代码仓库运行
  `git fsck` 并生成代码仓库校验和，以便比较不同服务器上的代码仓库。

未在命令行中手动运行的检查会通过 Gitaly 节点执行。有关 Gitaly 代码仓库一致性检查、部分已禁用的检查以及如何配置一致性检查的信息，请参阅[代码仓库一致性检查](gitaly/consistency_checks.md)。

<a id="check-a-projects-repository-using-gitlab-ui"></a>

## 使用极狐GitLab UI 检查项目的代码仓库

要使用极狐GitLab UI 检查项目的代码仓库：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **项目**。
1. 选择要检查的项目。
1. 在**代码仓库检查**部分，选择**触发代码仓库检查**。

检查会异步运行，因此可能需要几分钟，检查结果才会显示在**管理**区域中的项目页面上。如果检查失败，请参阅[该怎么做](#what-to-do-if-a-check-failed)。

<a id="enable-repository-checks-for-all-projects"></a>

## 为所有项目启用代码仓库检查

除了手动检查代码仓库外，还可以将极狐GitLab 配置为定期运行检查：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**代码仓库维护**。
1. 启用**启用代码仓库检查**。

启用后，极狐GitLab 会定期对所有项目代码仓库和 Wiki 代码仓库运行代码仓库检查，以检测可能的数据损坏。每个项目每月最多检查一次，新项目在至少 24 小时内不会被检查。

极狐GitLab 私有化部署管理员可以配置代码仓库检查的频率。要编辑频率：

- 对于 Linux 软件包安装，请编辑
  `/etc/gitlab/gitlab.rb`中的 `gitlab_rails['repository_check_worker_cron']`。
- 对于基于源码的安装，请编辑
  `/home/git/gitlab/config/gitlab.yml`中的 `[gitlab.cron_jobs.repository_check_worker]`。

如果有任何项目的代码仓库检查失败，所有极狐GitLab 管理员都会收到一封关于该情况的电子邮件通知。默认情况下，此通知每周发送一次，时间为周日开始时的午夜。

存在已知检查失败的代码仓库可在 `/admin/projects?last_repository_check_failed=true`中找到。

<a id="run-a-check-using-the-command-line"></a>

## 使用命令行运行检查

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

您可以在 [Gitaly 服务器](gitaly/_index.md)上的代码仓库中使用命令行运行 [`git fsck`](https://git-scm.com/docs/git-fsck)。要定位代码仓库：

1. 转到代码仓库的存储位置：
   - 对于 Linux 软件包安装，代码仓库默认存储在 `/var/opt/gitlab/git-data/repositories` 目录中。
   - 对于 GitLab Helm chart 安装，代码仓库默认存储在 Gitaly pod 内的 `/home/git/repositories` 目录中。
1. [确定包含您需要检查的代码仓库的子目录](repository_storage_paths.md#from-project-name-to-hashed-path)。
1. 运行检查。例如：

   ```shell
   sudo -u git /opt/gitlab/embedded/bin/git \
      -C /var/opt/gitlab/git-data/repositories/@hashed/0b/91/0b91...f9.git fsck --no-dangling
   ```

   `--no-dangling` 选项会抑制 `dangling commit`、`dangling tag` 和 `dangling blob`
   消息。这些消息在 Git 代码仓库中很常见，由强制推送到分支等操作生成，可以忽略。

   错误 `fatal: detected dubious ownership in repository` 表示您使用了错误的账号运行该命令。
   例如，`root`。

<a id="what-to-do-if-a-check-failed"></a>

## 检查失败时该怎么做

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

如果代码仓库检查失败，请在磁盘上的 [`repocheck.log` 文件](logs/_index.md#repochecklog)中定位错误，位置如下：

- Linux 软件包安装：`/var/log/gitlab/gitlab-rails`。
- 自行编译安装：`/home/git/gitlab/log`。
- GitLab Helm chart 安装：Sidekiq pod 中的 `/var/log/gitlab`。

如果定期代码仓库检查导致误报，您可以清除所有代码仓库检查状态：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**代码仓库维护**。
1. 选择**清除所有代码仓库检查**。

<a id="troubleshooting"></a>

## 故障排除

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

使用代码仓库检查时，您可能会遇到以下问题。

<a id="error-failed-to-parse-commit--from-object-database-for-commit-graph"></a>

### 错误：`failed to parse commit <commit SHA> from object database for commit-graph`

您可能会在代码仓库检查日志中看到 `failed to parse commit <commit SHA> from object database for commit-graph` 错误。如果您的 `commit-graph` 缓存已过期，就会出现此错误。`commit-graph` 缓存是辅助缓存，常规 Git 操作并不需要它。

虽然可以安全地忽略该消息，但更多详情请参阅议题 [error: Could not read from object database for commit-graph](https://gitlab.com/gitlab-org/gitaly/-/issues/2359)。
