---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 定时流水线
description: Create and manage schedules to run CI/CD pipelines automatically using cron patterns.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

创建流水线计划，以基于 cron 模式按常规间隔运行流水线。使用流水线计划执行需要按时间计划运行的任务，而不是由代码变更触发的任务。

与由提交或合并请求触发的流水线不同，定时流水线独立于代码变更运行。这使它们适用于无论开发活动如何都需要执行的任务，例如保持部署最新或运行定期维护。

当项目或群组被标记为删除时，定时流水线停止运行。

## 查看你的定时流水线

<a id="view-your-scheduled-pipelines"></a>

{{< history >}}

- 在极狐GitLab 18.4 中引入。

{{< /history >}}

要查看你在所有项目中拥有的活跃流水线计划：

1. 在右上角，选择你的头像。
1. 选择 **编辑个人资料**。
1. 选择 **账户**。
1. 滚动到 **你拥有的定时流水线**。

## 创建流水线计划

<a id="create-a-pipeline-schedule"></a>

{{< history >}}

- 输入选项在极狐GitLab 17.11 中引入。

{{< /history >}}

当你创建流水线计划时，你将成为计划所有者。流水线使用你的权限运行，并可以根据你的访问级别访问 [受保护的环境](../environments/protected_environments.md) 并使用 [CI/CD 作业令牌](../jobs/ci_job_token.md)。

先决条件：

- 你必须拥有项目的 开发者、维护者 或 所有者 角色。
- 你的主要电子邮件地址必须已验证。
- 对于针对 [受保护分支](../../user/project/repository/branches/protected.md#protect-a-branch) 的计划，你必须具有目标分支的合并权限。
- 你的 `.gitlab-ci.yml` 文件必须具有有效的语法。你可以在计划之前 [验证你的配置](../yaml/lint.md)。

要创建流水线计划：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **构建** > **流水线计划**。
1. 选择 **新建计划**。
1. 填写字段。
   - **间隔模式**：选择一个预配置的间隔，或输入自定义的 [cron 记法](../../topics/cron/_index.md) 间隔。你可以使用任何 cron 值，但定时流水线的运行频率不能超过实例的 [最大定时流水线频率](../../administration/cicd/_index.md#change-maximum-scheduled-pipeline-frequency)。
   - **目标分支或标签**：选择流水线的分支或标签。
   - **输入**：设置在流水线的 `spec:inputs` 部分中定义的任何 [输入](../inputs/_index.md) 的值。这些输入值在每次运行定时流水线时使用。一个计划最多可以有 20 个输入。
   - **变量**：向计划添加任意数量的 [CI/CD 变量](../variables/_index.md)。这些变量仅在运行定时流水线时可用，而在其他流水线运行中不可用。建议使用输入而不是变量来配置流水线，因为它们提供了更高的安全性和灵活性。

如果项目已达到 [最大流水线计划数](../../administration/instance_limits.md#number-of-pipeline-schedules)，请在添加另一个计划之前删除未使用的计划。

## 编辑流水线计划

<a id="edit-a-pipeline-schedule"></a>

先决条件：

- 你必须是计划的所有者，或者接管计划的所有权。
- 你必须拥有项目的 开发者、维护者 或 所有者 角色。
- 对于针对 [受保护分支](../../user/project/repository/branches/protected.md#protect-a-branch) 的计划，你必须具有目标分支的合并权限。
- 对于在 [受保护标签](../../user/project/protected_tags.md#configure-protected-tags) 上运行的计划，你必须被允许创建受保护标签。

要编辑流水线计划：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **构建** > **流水线计划**。
1. 在计划旁边，选择 **编辑** ({{< icon name="pencil" >}})。
1. 做出更改，然后选择 **保存更改**。

## 手动运行

<a id="run-manually"></a>

你可以每分钟手动运行一次定时流水线。当你手动运行定时流水线时，它会使用你的权限而不是计划所有者的权限。

要立即触发流水线计划，而不是等待下一个计划时间：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **构建** > **流水线计划**。
1. 在计划旁边，选择 **运行** ({{< icon name="play" >}})。

## 接管所有权

<a id="take-ownership"></a>

如果由于原始所有者不可用而导致流水线计划变为非活跃，你可以接管所有权。

定时流水线以拥有该计划的用户的权限执行。

先决条件：

- 你必须具有该项目的维护者或所有者角色。

要接管计划的所有权：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **构建** > **流水线计划**。
1. 在计划旁边，选择 **接管所有权**。

## 相关主题

<a id="related-topics"></a>

- [CI/CD 流水线](_index.md)
- [为定时流水线运行作业](../jobs/job_rules.md#run-jobs-for-scheduled-pipelines)
- [流水线计划 API](../../api/pipeline_schedules.md)
- [流水线效率](pipeline_efficiency.md#reduce-how-often-jobs-run)

## 故障排除

<a id="troubleshooting"></a>

在使用流水线计划时，你可能会遇到以下问题。

### 定时流水线变为非活跃

<a id="scheduled-pipeline-becomes-inactive"></a>

如果定时流水线状态意外变为 `Inactive`，则计划所有者可能已被阻止或从项目中移除。

接管计划的所有权以重新激活它。

### 分布流水线计划以防系统负载

<a id="distribute-pipeline-schedules-to-prevent-system-load"></a>

为了防止过多流水线同时启动造成过度负载，请审查并分布你的流水线计划：

1. 运行以下命令以提取和格式化计划数据：

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

1. 审查输出以识别流行的 `cron` 模式。例如，许多计划可能在每小时开始时运行（`0 * * * *`）。
1. 调整计划以创建交错 [`cron` 模式](../../topics/cron/_index.md#cron-syntax)，尤其是对于大型仓库。例如，不将多个计划安排在每个小时的开始，而是将它们分布在整个小时内（`5 * * * *`、`15 * * * *`、`25 * * * *`）。