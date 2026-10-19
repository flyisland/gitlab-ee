---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 修复 CI/CD 流水线任务流
---

{{< details >}}

- Tier: [基础版](../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

修复 CI/CD 流水线任务流可诊断极狐GitLab CI/CD 流水线中的问题并提出修复方案。为诊断失败原因，该任务流会检查：

- 流水线日志，包括错误消息、失败的作业输出和退出码。
- 可能导致失败的合并请求变更。
- 代码仓库内容，以识别语法、lint 或导入错误。
- 脚本错误，包括命令失败、可执行文件缺失或权限问题。

任务流如何应用修复取决于流水线的上下文：

- 如果流水线与某个合并请求关联，任务流会在源分支上应用行内代码建议。
  您可以直接在合并请求中审阅并应用这些建议。
  - 如果修复需要更改当前合并请求差异之外的文件，任务流会改为创建一个新的合并请求。
- 如果流水线未与合并请求关联，任务流会创建一个包含修复内容的新合并请求。

在某些情况下，任务流不会尝试修复，而是发布一条评论，说明失败原因和可能的后续步骤。当流水线与合并请求关联时会出现这种情况，例如：

- 上下文不足，无法确定可靠的修复方案。
- 该失败涉及安全敏感信息，应由人工审阅。
- 该失败类别无法由任务流处理。

会话启动并完成后，任务流会在合并请求中发布系统评论，其中包含指向该会话的链接。此任务流仅在极狐GitLab UI 中可用。

如果您使用极狐GitLab Duo Agent Platform 并希望自动修复失败的流水线，推荐使用此任务流。它与[根因分析](../../user/gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis)是不同的体验，后者是极狐GitLab Duo Chat 中用于排查单个作业失败的功能。

<a id="prerequisites"></a>

## 先决条件

- 满足[极狐GitLab Duo Agent Platform 的先决条件](../../user/duo_agent_platform/_index.md#prerequisites)。
- [为顶级群组](../../user/duo_agent_platform/flows/foundational_flows/_index.md#turn-foundational-flows-on-or-off)开启 **允许内置任务流**和 **修复 CI/CD 流水线**。
- 拥有该项目的开发者、维护者或所有者角色。
- 存在一个失败的流水线。
- [配置推送规则以允许服务账号](../../user/duo_agent_platform/troubleshooting.md#configure-push-rules-to-allow-a-service-account)。
- [配置您自己的 runner](../../user/duo_agent_platform/flows/execution/_index.md#configure-runners-to-execute-flows)，或为您的项目开启[极狐GitLab 托管 runner](../runners/hosted_runners/_index.md)。
- 推荐。创建 [Agent 配置文件](../../user/duo_agent_platform/flows/execution/_index.md#create-the-agent-configuration-file)，以便任务流可以访问您项目的工具链和依赖项。

<a id="fix-the-pipeline-in-a-merge-request"></a>

## 在合并请求中修复流水线

要在合并请求中修复 CI/CD 流水线：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**代码** > **合并请求**，然后打开您的合并请求。
1. 使用以下方法之一修复流水线：
   - 选择**概览**标签页，然后在失败的流水线下，选择
     **使用 Duo 修复流水线**。
   - 选择**流水线**标签页，然后在最右侧一列中，选择
     **使用 Duo 修复流水线**（{{< icon name="tanuki-ai" >}}）。
   - 在极狐GitLab Duo 侧边栏中，打开新的或现有的 Agentic Chat 对话。
     让 Agentic Chat 修复流水线。
1. 要监控进度，请在左侧边栏中，选择 **AI** > **会话**。

   如果您在 Agentic Chat 中，还可以执行以下操作：
   - 在 Chat 对话中查看进度。
   - 在对话中选择 **查看 Agent 会话**。

会话完成后，任务流会向合并请求添加代码建议，或发布一条评论说明可能的后续步骤。

<a id="fix-other-cicd-pipelines"></a>

## 修复其他 CI/CD 流水线

要修复未与合并请求关联的 CI/CD 流水线：

1. 选择**构建** > **流水线**。
1. 选择您失败的流水线。
1. 在右上角，选择**使用 Duo 修复流水线**。
1. 要监控进度，请选择 **AI** > **会话**。

<a id="use-agentsmd-to-customize-the-flow"></a>

## 使用 `AGENTS.md` 自定义任务流

任务流会从代码仓库中的 [`AGENTS.md`](../../user/duo_agent_platform/customize/agents_md.md) 文件读取特定于代码仓库的指令。您可以使用 `AGENTS.md` 自定义以下行为：

- 任务流提交变更时使用的提交消息格式。
- 任务流创建的合并请求的元数据，例如标记和描述。
- 如何对特定类型的失败进行分类和处理。
- 如何处理同一类型的重复失败，以避免任务流多次执行同样不成功的修复。

例如：

```markdown
## Fix pipeline merge requests

When opening a merge request as part of the Fix Pipeline flow (the title contains [FixPipeline]),
apply labels based on the following failed pipeline scenarios:

- Pipeline failed on merge_request: apply "pipeline::tier-1". This runs the cheaper tier-1
  pipeline instead of the full default pipeline.
- Pipeline failed on the default_branch (main): apply both "pipeline::expedited" and
  "main:broken". Do not apply pipeline::tier-1 in this case.
- Pipeline failed on other branches: apply "pipeline::tier-1". Same treatment as the
  merge_request case.
```

例如，要处理迁移失败：

```markdown
## Migration failures

If a pipeline fails because of a database migration:

- Run `bin/rails db:migrate:status` to check the current migration state before attempting
  a fix.
- Do not edit or delete past migration files.
- If the migration cannot be safely reversed, post a comment describing the issue instead
  of attempting a fix.
```

<a id="known-issues"></a>

## 已知问题

- AI 网关仅处理作业日志的最后 150 KiB。如果您的作业产生大量输出，任务流可能无法捕获日志中较早出现的相关失败信息。
  有关变通方法，请参见下一节。
- 任务流无法始终在沙盒运行时环境中验证软件包安装。
  如果缺少依赖项，您可以自定义默认任务流镜像。请参见
  [更改默认 Docker 镜像](../../user/duo_agent_platform/flows/execution/images.md#change-the-default-docker-image)。
- `AGENTS.md`中的代码仓库指令会影响任务流的行为，但不保证在所有情况下都被遵循。

<a id="troubleshooting"></a>

## 故障排除

使用修复 CI/CD 流水线任务流时，您可能会遇到以下问题。

<a id="flow-cannot-identify-the-root-cause-of-a-failure"></a>

### 任务流无法确定失败的根因

任务流可能无法确定流水线失败的根因。

当作业日志超过 150 KiB 时会出现此问题。AI 网关仅处理最后 150 KiB，因此可能无法捕获日志中较早出现的相关失败信息。

要变通解决此问题，请尝试以下方法：

- 移除调试日志和进度指示器，以减少冗长输出。
- 使用 shell 重定向（`> /dev/null`）重定向非关键输出。
- 在脚本末尾添加一个汇总步骤，输出关键错误消息。
- 使用 `after_script` 在主脚本完成后输出诊断信息。
- 将冗长的作业拆分为更小、更专注且日志更简洁的作业。

<a id="session-failed-to-start"></a>

### 会话启动失败

修复 CI/CD 流水线任务流的会话失败，并且在会话页面（**AI** > **会话**）上出现 `Session failed to start` 警报。

这里涉及两个流水线：失败的流水线，以及任务流为修复它而创建的[工作负载流水线](pipeline_types.md#workload-pipeline)。请检查工作负载流水线中作业的状态。

有关原因及解决方法，请参见[任务流的作业或会话启动失败](../../user/duo_agent_platform/troubleshooting.md#a-flows-job-or-session-fails-to-start)。

<a id="fix-pipeline-with-duo-button-does-not-appear"></a>

### 未显示使用 Duo 修复流水线按钮

您已满足[先决条件](#prerequisites)，但未显示**使用 Duo 修复流水线**按钮。

出现此问题是因为该按钮依赖于三个独立页面（极狐GitLab
Duo、Agent Platform 和内置任务流）中的设置。
在某一层级开启的设置并不保证其下每个层级都已开启。

要解决此问题，请重新检查每项要求：

- 已开启[极狐GitLab Duo](../../user/duo_agent_platform/turn_on_off.md#turn-gitlab-duo-on-or-off) 或
  [极狐GitLab Duo Core](../../user/duo_agent_platform/turn_on_off.md#turn-gitlab-duo-core-on-or-off)。
- 已[开启 Agent Platform](../../user/duo_agent_platform/turn_on_off.md#turn-gitlab-duo-agent-platform-on-or-off)。
- 已为顶级群组开启 **允许内置任务流**和 **修复 CI/CD 流水线**，
  并且在极狐GitLab 私有化部署上，已为实例开启。

<a id="give-feedback"></a>

## 提供反馈

团队正在积极改进修复 CI/CD 流水线任务流。要报告问题或提出改进建议，请在[反馈议题 601991](https://gitlab.com/gitlab-org/gitlab/-/work_items/601991)中留下您的反馈。
