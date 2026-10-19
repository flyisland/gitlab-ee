---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 升级前
description: Steps to take before you upgrade.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在升级极狐GitLab 实例之前，您必须：

1. 收集升级前信息，为升级做好准备。
1. 在升级极狐GitLab 本身之前执行升级前步骤。

<a id="gather-pre-upgrade-information"></a>

## 收集升级前信息

在规划升级时：

1. 查阅 [极狐GitLab 发布和维护策略](../policy/maintenance.md)。
1. 查阅不同极狐GitLab 版本的 [极狐GitLab 升级说明](versions/_index.md) 以确保兼容性。
1. 如果相关，检查 [目标极狐GitLab 版本的操作系统兼容性](../install/package/_index.md)。
1. 如果您使用 Geo：
   - 查阅 [Geo 升级文档](../administration/geo/replication/upgrading_the_geo_sites.md)。
   - 查阅 [极狐GitLab 升级说明](versions/_index.md) 中的 Geo 特定信息。
   - 查阅 [升级数据库](https://gitlab.cn/docs/omnibus/settings/database/#upgrading-a-geo-instance) 时的 Geo 特定步骤。
   - 为每个 Geo 站点（主站点和每个次要站点）创建升级和回滚计划。
1. 确定适合您实例的 [升级路径](upgrade_paths.md)，包括所有要求的升级停留点。
   升级停留点可能要求您执行多次升级。
1. 运行 [升级健康检查](#run-upgrade-health-checks)，以便尽早发现并解决潜在问题。
1. 创建一个升级计划，记录：
   - 升级实例所需的步骤，如果可能且需要，包括 [零停机时间升级](zero_downtime.md)。
   - 如果升级过程不顺利，需要采取的步骤，包括如何 [在必要时回滚极狐GitLab](#create-a-rollback-plan-and-backup)。
1. 在生产环境的克隆体中测试您的升级计划。
   这有助于降低计划外停机的风险，并帮助您测量 [可能长时间运行的迁移](background_migrations.md#execute-a-migration) 的持续时间。

收集完所有升级前信息后，您可以继续执行升级前步骤。

<a id="create-a-rollback-plan-and-backup"></a>

### 创建回滚计划和备份

升级过程中可能会出现一些问题，因此拥有一份回滚计划至关重要。合适的回滚计划能清晰地指明将极狐GitLab 实例恢复到上次正常工作状态的路径，包括：

- 备份实例的过程。
- 恢复实例的过程。

您应该在需要之前测试回滚计划。有关回滚所需步骤的概述，请参阅 [回滚到更早的极狐GitLab 版本](package/downgrade.md)。

<a id="create-a-gitlab-backup"></a>

#### 创建极狐GitLab 备份

为了在升级出现问题时能够回滚极狐GitLab，您可以：

- 创建 [极狐GitLab 备份](../administration/backup_restore/_index.md)。您必须根据安装方法遵循相应说明，并确保备份 [密钥和配置文件](../administration/backup_restore/backup_gitlab.md#storing-configuration-files)。
- 创建实例的快照。如果您的实例是多节点安装，您必须为每个节点创建快照。
  **此过程不在极狐GitLab 支持范围内**。

<a id="roll-back-gitlab"></a>

#### 回滚极狐GitLab

如果您有一个模拟生产环境的测试环境，请测试恢复过程，以确保一切按预期工作。

要恢复极狐GitLab 备份：

1. 请参考 [恢复前提条件](../administration/backup_restore/restore_gitlab.md#restore-prerequisites)。最重要的是，备份后的版本和新极狐GitLab 实例的版本必须相同。
1. 根据安装方法，按照说明 [恢复极狐GitLab](../administration/backup_restore/_index.md#restore-gitlab)。
1. 确认 [密钥和配置文件](../administration/backup_restore/backup_gitlab.md#storing-configuration-files) 也已恢复。

如果是从快照恢复，您必须已经知道如何操作。**此过程不在极狐GitLab 支持范围内**。

<a id="perform-pre-upgrade-steps"></a>

## 执行升级前步骤

在升级前不久：

1. 重新运行 [升级健康检查](#run-upgrade-health-checks)。
1. 对您使用的任何可选功能执行 [升级](#upgrades-for-optional-features)。

<a id="run-upgrade-health-checks"></a>

### 运行升级健康检查

在升级前后立即运行升级健康检查，以确保极狐GitLab 的主要组件正常工作：

1. [检查常规配置](../administration/raketasks/maintenance.md#check-gitlab-configuration)：

   ```shell
   sudo gitlab-rake gitlab:check
   ```

1. 检查所有 [后台数据库迁移](background_migrations.md) 的状态。每次升级前，所有迁移都必须运行完毕。您必须在主要和次要版本之间分散升级，以便留出时间让后台迁移完成。
1. 确认加密的数据库值 [能够被解密](../administration/raketasks/check.md#verify-database-values-can-be-decrypted-using-the-current-secrets)：

   ```shell
   sudo gitlab-rake gitlab:doctor:secrets
   ```

1. 在极狐GitLab UI 中，检查以下内容：
   - 用户可以登录。
   - 项目列表可见。
   - 可以访问项目议题和合并请求。
   - 用户可以从极狐GitLab 克隆仓库。
   - 用户可以推送提交到极狐GitLab。

1. 对于极狐GitLab CI/CD，检查：
   - Runner 能获取作业。
   - Docker 镜像可以推送到注册表或从注册表拉取。

1. 如果使用 Geo，在主站点和每个次要站点上运行相关检查：

   ```shell
   sudo gitlab-rake gitlab:geo:check
   ```

1. 如果使用 Elasticsearch，验证搜索是否成功。

如果出现问题，请 [获取支持](#get-support)。

<a id="upgrades-for-optional-features"></a>

### 可选功能的升级

根据您的极狐GitLab 实例配置，您可能需要在升级极狐GitLab 之前执行以下附加步骤：

1. 如果使用外部 Gitaly 服务器，请在升级极狐GitLab 本身之前将 Gitaly 服务器升级到新版本。这样可以避免应用服务器上的 gRPC 客户端发送旧版 Gitaly 不支持的 RPC。
1. 如果您已将 Kubernetes 集群与极狐GitLab 连接，请 [升级您的极狐GitLab Kubernetes Agent](../user/clusters/agent/install/_index.md#update-the-agent-version) 以匹配新的极狐GitLab 版本。
1. 如果您使用高级搜索（Elasticsearch），请通过 [检查待处理的迁移](background_migrations.md#check-for-pending-advanced-search-migrations) 确认高级搜索迁移已完成。

   升级极狐GitLab 后，您可能需要升级 [与新版本兼容性破坏的 Elasticsearch](../integration/advanced_search/elasticsearch.md#version-compatibility)。更新 Elasticsearch **不在极狐GitLab 支持范围内**。

<a id="pause-cicd-pipelines-and-jobs"></a>

## 暂停 CI/CD 流水线和作业

对于大多数类型的极狐GitLab 实例，您应该在升级期间暂停 CI/CD 流水线和作业。

如果在极狐GitLab Runner 处理作业时升级极狐GitLab 实例，跟踪更新将失败。当极狐GitLab 重新上线时，跟踪更新应能自我修复。如果跟踪更新没有自我修复，根据错误的不同，极狐GitLab Runner 要么重试，要么终止作业处理。

极狐GitLab Runner 会尝试上传作业产物三次，之后作业将失败。

要暂停 CI/CD 流水线和作业：

1. 暂停 Runner。
1. 通过在 `/etc/gitlab/gitlab.rb` 文件中添加以下内容来阻止新作业启动：

   ```ruby
   nginx['custom_gitlab_server_config'] = "location = /api/v4/jobs/request {\n deny all;\n return 503;\n}\n"
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 等待所有作业完成。

极狐GitLab 升级完成后：

1. 取消暂停 Runner。
1. 通过还原之前的 `/etc/gitlab/gitlab.rb` 更改，允许新作业启动。

<a id="working-with-support"></a>

## 与支持团队合作

如果您 [正在与支持团队合作](https://gitlab.cn/support/scheduling-upgrade-assistance/) 审查升级计划，请记录并分享以下问题的答案：

- 极狐GitLab 是如何安装的？
- 节点的操作系统是什么？检查 [支持的平台](../install/package/_index.md#supported-platforms) 以确认后续更新是否可用。
- 是单节点还是多节点设置？如果是多节点，请记录并分享有关每个节点的架构详细信息。使用了哪些外部组件？例如 Gitaly、PostgreSQL 或 Redis？
- 您是否在使用 [Geo](../administration/geo/_index.md)？如果是，请记录并分享有关每个次要站点的架构详细信息。
- 您的设置中还有哪些独特或有趣的方面可能很重要？
- 您当前版本的极狐GitLab 是否遇到任何已知问题？

<a id="get-support"></a>

## 获取支持

如果升级过程中出现问题：

1. 复制所有错误并收集所有日志以供后续分析。使用以下工具帮助您收集数据：
   - 如果您使用 Linux 软件包或 Docker 安装了极狐GitLab，请使用 [`gitlabsos`](https://gitlab.com/gitlab-com/support/toolbox/gitlabsos)。
   - 如果您使用 Helm Chart 安装了极狐GitLab，请使用 [`kubesos`](https://gitlab.com/gitlab-com/support/toolbox/kubesos/)。
1. 回滚到上一个正常工作版本。

获取支持的方式：

- [联系极狐GitLab 支持](https://support.gitlab.com/hc/en-us) 以及您的客户成功经理（如果有的话）。
- 如果 [情况符合](https://gitlab.cn/support/#definitions-of-support-impact) 并且 [您的计划包含紧急支持](https://gitlab.cn/support/#priority-support)，请创建紧急工单。