---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 定时流水线
description: 创建和管理计划，使用 cron 模式自动运行 CI/CD 流水线。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

创建流水线计划，按 cron 模式定期运行流水线。对于需要按时间计划运行、而不是由代码变更触发的任务，请使用流水线计划。

与由提交或合并请求触发的流水线不同，定时流水线独立于代码变更运行。因此，它们适合那些无论开发活动如何都需要执行的任务，例如保持部署为最新状态，或运行定期维护。

当项目或群组被标记为删除时，定时流水线会停止运行。

<a id="create-a-pipeline-schedule"></a>

## 创建流水线计划

创建流水线计划后，您将成为该计划的所有者。该流水线以您的权限运行，可以访问[受保护环境](../environments/protected_environments.md)，并根据您的访问级别使用 [CI/CD 作业令牌](../jobs/ci_job_token.md)。

先决条件：

- 您必须拥有该项目的开发者、维护者或所有者角色。
- 您的主要电子邮件地址必须已验证。
- 对于以[受保护分支](../../user/project/repository/branches/protected.md#protect-a-branch)为目标的计划，
  您必须对目标分支拥有合并权限。
- 您的`.gitlab-ci.yml` 文件必须语法有效。您可以在创建计划前[验证配置](../yaml/lint.md)。

创建流水线计划：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**构建** > **流水线计划**。
1. 选择**新建计划**。
1. 填写各字段。
   - **间隔模式**：选择某个预配置的间隔，或使用 [cron 表示法](../../topics/cron/_index.md)输入自定义
     间隔。您可以使用任意 cron 值，
     但定时流水线的运行频率不能高于实例的
     [最大定时流水线频率](../../administration/cicd/limits.md#maximum-scheduled-pipeline-frequency)。
   - **目标分支或标签**：选择该流水线的分支或标签。
   - **输入**：为流水线的 `spec:inputs` 部分中定义的任何[输入](../inputs/_index.md)设置值。
     这些输入值会在每次运行定时流水线时使用。一个计划最多可以有 20 个输入。
   - **变量**：向该计划添加任意数量的 [CI/CD 变量](../variables/_index.md)。
     这些变量仅在运行定时流水线时可用，
     在其他任何流水线运行中都不可用。建议使用输入而不是变量来配置流水线，
     因为输入具有更好的安全性和灵活性。

如果项目已达到[流水线计划数量上限](../../administration/cicd/limits.md#number-of-pipeline-schedules)，请先删除未使用的计划，然后再添加新的计划。

<a id="edit-a-pipeline-schedule"></a>

## 编辑流水线计划

先决条件：

- 您必须是该计划的所有者，或取得该计划的所有权。
- 您必须拥有该项目的开发者、维护者或所有者角色。
- 对于以[受保护分支](../../user/project/repository/branches/protected.md#protect-a-branch)为目标的计划，
  您必须对目标分支拥有合并权限。
- 对于在[受保护标签](../../user/project/protected_tags.md#configure-protected-tags)上运行的计划，
  您必须被允许创建受保护标签。

编辑流水线计划：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**构建** > **流水线计划**。
1. 在该计划旁边，选择**编辑**（{{< icon name="pencil" >}}）。
1. 进行更改，然后选择**保存更改**。

<a id="run-manually"></a>

## 手动运行

您可以每分钟手动运行一次定时流水线。手动运行定时流水线时，它使用您的权限，而不是计划所有者的权限。

要立即触发流水线计划，而不是等待下一个计划时间：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**构建** > **流水线计划**。
1. 在该计划旁边，选择**运行**（{{< icon name="play" >}}）。

<a id="take-ownership"></a>

## 取得所有权

如果流水线计划因原所有者不可用而变为非活跃状态，您可以取得其所有权。

定时流水线以拥有该计划的用户的权限执行。

先决条件：

- 您必须拥有该项目的维护者或所有者角色。

取得计划的所有权：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**构建** > **流水线计划**。
1. 在该计划旁边，选择**取得所有权**。

<a id="view-your-scheduled-pipelines"></a>

## 查看您的定时流水线

要查看您在所有项目中拥有的活跃流水线计划：

1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 选择**帐户**。
1. 滚动到**您拥有的定时流水线**。

<a id="troubleshooting"></a>

## 故障排除

使用流水线计划时，您可能会遇到以下问题。

<a id="scheduled-pipeline-becomes-inactive"></a>

### 定时流水线变为非活跃状态

如果定时流水线的状态意外变为 `Inactive`，则计划所有者可能已被阻止或从项目中移除。

取得该计划的所有权以重新激活它。

<a id="distribute-pipeline-schedules-to-prevent-system-load"></a>

### 分散流水线计划以避免系统负载

为避免过多流水线同时启动造成过大负载，请检查并分散您的流水线计划：

1. 运行以下命令以提取并格式化计划数据：

   ```shell
   outfile=/tmp/gitlab_ci_schedules.tsv
   sudo gitlab-psql --command "
    COPY (SELECT
        ci_pipeline_schedules.cron,
        ci_pipeline_schedules.cron_timezone,
        namespaces.path AS group,
        projects.path   AS project,
        users.email
    FROM ci_pipeline_schedules
    JOIN projects ON projects.id = ci_pipeline_schedules.project_id
    JOIN namespaces ON namespaces.id = projects.namespace_id
    JOIN users    ON users.id    = ci_pipeline_schedules.owner_id
    WHERE ci_pipeline_schedules.active = 't'
    ) TO '$outfile' CSV HEADER DELIMITER E'\t' ;"
   sort  "$outfile" | uniq -c | sort -n
   ```

1. 检查输出，找出使用较多的 `cron` 模式。
   例如，许多计划可能都在每小时开始时运行（`0 * * * *`）。
1. 调整计划，创建错开的 [`cron` 模式](../../topics/cron/_index.md#cron-syntax)，对于大型代码仓库尤其如此。
   例如，不要让多个计划都在每小时开始时运行，
   而是将它们分散到整个小时中（`5 * * * *`、`15 * * * *`、`25 * * * *`）。
