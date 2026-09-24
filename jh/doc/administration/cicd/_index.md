---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab CI/CD 实例配置
description: 管理极狐GitLab CI/CD 配置。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 管理员可以管理其实例的极狐GitLab CI/CD 配置。

<a id="disable-gitlab-cicd-in-new-projects"></a>

## 在新项目中禁用极狐GitLab CI/CD

极狐GitLab CI/CD 在实例的所有新项目中默认启用。您可以通过修改以下设置，将 CI/CD 设置为在新项目中默认禁用：

- 自编译安装：`gitlab.yml`
- Linux 软件包安装：`gitlab.rb`

已启用 CI/CD 的现有项目不受影响。此外，此设置仅更改项目默认值，因此项目所有者[仍可在项目设置中启用 CI/CD](../../ci/pipelines/settings.md#disable-gitlab-cicd-pipelines)。

对于自编译安装：

1. 使用编辑器打开 `gitlab.yml`，并将 `builds` 设置为 `false`：

   ```yaml
   ## Default project features settings
   default_projects_features:
     issues: true
     merge_requests: true
     wiki: true
     snippets: false
     builds: false
   ```

1. 保存 `gitlab.yml` 文件。
1. 重启极狐GitLab：

   ```shell
   sudo service gitlab restart
   ```

对于 Linux 软件包安装：

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加此行：

   ```ruby
   gitlab_rails['gitlab_default_projects_features_builds'] = false
   ```

1. 保存 `/etc/gitlab/gitlab.rb` 文件。
1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="disaster-recovery"></a>

## 灾难恢复

在持续停机期间，您可以禁用应用程序中某些重要但计算成本较高的部分，以减轻数据库压力。

<a id="disable-fair-scheduling-on-instance-runners"></a>

### 禁用实例 Runner 上的公平调度

当清理大量积压作业时，您可以临时启用 `ci_queueing_disaster_recovery_disable_fair_scheduling` [功能标志](../feature_flags/_index.md)。此标志会禁用实例 Runner 上的公平调度，从而减少 `jobs/request` 端点上的系统资源使用。

启用后，作业将按照进入系统的顺序进行处理，而不是在多个项目之间进行平衡。

<a id="disable-compute-quota-enforcement"></a>

### 禁用计算配额执行

要禁用实例 Runner 上[计算分钟配额](compute_minutes.md)的执行，您可以临时启用 `ci_queueing_disaster_recovery_disable_quota` [功能标志](../feature_flags/_index.md)。此标志可减少 `jobs/request` 端点上的系统资源使用。

启用后，过去一小时内创建的作业可以在超出配额的项目中运行。较早的作业已被周期性后台工作进程（`StuckCiJobsWorker`）取消。
