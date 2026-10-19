---
stage: Tutorial
group: Tutorial
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 从极狐GitLab Duo Pro 或 Enterprise 迁移到极狐GitLab Duo Agent Platform。
title: 过渡到极狐GitLab Duo Agent Platform
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

当您从极狐GitLab Duo（非 Agentic）过渡到 Agent Platform 时，您可以在整个软件开发生命周期中使用多个助手（称为 Agent）。

要将您的实例过渡到 Agent Platform，请完成以下步骤：

1. 设置您的环境
1. 验证您的配置
1. 配置 Agent Platform 设置

<a id="features-available-after-transition"></a>

## 过渡后可用的功能

下表列出了极狐GitLab Duo 非 Agentic 功能以及用户迁移到 Agent Platform 后可访问的 Agentic 版本。有关 Agent Platform 中功能的完整列表，请参阅[正式发布的功能](../../../user/duo_agent_platform/_index.md#generally-available-features)和[测试版和实验性功能](../../../user/duo_agent_platform/_index.md#beta-and-experimental-features-that-dont-consume-credits)。

| 非 Agentic 功能 | Agent Platform |
|---------------------|----------------|
| GitLab Duo Non-Agentic Chat | [Agentic Chat](../../../user/gitlab_duo_chat/agentic_chat.md) <br /> 回答复杂问题，并自主创建和编辑文件。可连接到计划者 Agent 和安全分析 Agent。合并请求摘要、讨论摘要、重构代码和测试生成现在已成为 Agentic Chat 的一部分。 |
| 极狐GitLab Duo 代码评审 | [代码评审任务流](../../../user/duo_agent_platform/flows/foundational_flows/code_review/_index.md)[^runner-configured-execute]  <br /> 自动执行代码评审任务，并在整个团队中强制执行编码标准。 |
| 根本原因分析 | [修复 CI/CD 流水线任务流](../../../ci/pipelines/fix_pipeline.md)[^runner-configured-execute] <br /> 诊断并自动修复失败的 CI/CD 流水线。 |
| 漏洞解释和解决 | [SAST 漏洞解决任务流](../../../user/duo_agent_platform/flows/foundational_flows/agentic_sast_vulnerability_resolution.md)[^runner-configured-execute] <br /> 自动为 SAST 漏洞生成修复和补救步骤。 |

[^runner-configured-execute]: 需要 Runner [配置为执行任务流](#set-up-your-environment)。如果您未配置 Runner，则在过渡到 Agent Platform 后，这些功能对之前在极狐GitLab Duo（非 Agentic）中依赖它们的用户将显示为不可用。

<a id="before-you-begin"></a>

## 先决条件

您必须使用极狐GitLab 19.0 或更高版本。

<a id="set-up-your-environment"></a>

## 设置您的环境

与极狐GitLab Duo（非 Agentic）不同，Agent Platform 在 Runner 上运行任务流，并使用服务账号创建提交和流水线。这需要非 Agentic 功能所没有的配置。

要为 Agent Platform 设置您的环境：

1. [配置您的实例](_index.md)。
1. [配置您的网络](_index.md#allow-outbound-connections-from-the-gitlab-instance-to-gitlab-duo)，以允许从您的极狐GitLab 实例发起出站连接。
1. [配置实例或群组 Runner](../../../user/duo_agent_platform/flows/execution/_index.md#configure-runners-to-execute-flows) 以使用任务流。使用 CI/CD 的任务流在 Runner 上执行。Agentic Chat 不需要 Runner。
1. [允许连接](_index.md#allow-connections-from-the-runner)从 Runner 到您的极狐GitLab 实例。
1. 如果您有在线许可证，请[同步您的订阅数据](../../../subscriptions/manage_subscription.md#manually-synchronize-subscription-data)。

<a id="validate-your-configuration"></a>

## 验证您的配置

设置好环境后，运行以下诊断检查：

- [极狐GitLab Duo 健康检查](_index.md#run-a-health-check-for-gitlab-duo)
- [配置诊断脚本](../../../user/duo_agent_platform/troubleshooting.md#run-the-configuration-diagnostic-script)

<a id="configure-agent-platform-settings"></a>

## 配置 Agent Platform 设置

设置好环境后，配置以下设置：

1. [开启 Agent Platform](../../../user/duo_agent_platform/turn_on_off.md#turn-gitlab-duo-agent-platform-on-or-off)。
1. [开启内置任务流](../../../user/duo_agent_platform/flows/foundational_flows/_index.md)。
1. 为内置任务流使用的服务账号[配置推送规则](../../../user/duo_agent_platform/troubleshooting.md#configure-push-rules-to-allow-a-service-account)。
1. [设置默认的极狐GitLab Duo 命名空间](../../../user/profile/preferences.md#set-a-default-gitlab-duo-namespace)。
1. 可选。为保持一致并控制成本，请[为功能选择模型](../../../user/duo_agent_platform/model_selection.md#select-a-model-for-a-feature)，以便所有用户都使用该模型。如果您不确定哪种模型适合您的需求，请参阅[选择合适的模型](../../../user/duo_agent_platform/model_selection.md#select-a-model-for-a-feature)。

<a id="common-issues-during-transition"></a>

## 过渡期间的常见问题

当您首次将实例过渡到 Agent Platform 时，可能会遇到以下问题。

| 问题 | 可能原因 | 解决方案 |
|---------|--------------|------------|
| 任务流在 UI 中不可见 | 未开启极狐GitLab Duo 或任务流执行，群组没有使用任务流的权限，或者未在项目级别启用该任务流。 | [任务流在 UI 中不可见](../../../user/duo_agent_platform/troubleshooting.md#flows-not-visible-in-the-ui) |
| 由于没有 Runner 获取作业，任务流无法运行 | 没有 Runner 具有 `gitlab--duo` 标签，或者 Runner 未针对任务流进行配置。 | [配置 Runner](../../../user/duo_agent_platform/flows/execution/_index.md#configure-runners-to-execute-flows) |
| 会话卡在 `created` 状态 | 推送规则阻止了服务账号。不允许提交作者邮箱或 `duo/feature/` 分支前缀。 | [配置推送规则以允许服务账号](../../../user/duo_agent_platform/troubleshooting.md#configure-push-rules-to-allow-a-service-account) |
| `Error in creating workload: Insufficient permissions to create a new pipeline` | 内置任务流服务账号是在导入或模板化项目存在之前设置的。 | [为导入的项目创建新流水线的权限不足](../../../user/duo_agent_platform/troubleshooting.md#insufficient-permissions-to-create-a-new-pipeline-for-imported-projects) |
| 内置任务流已开启但没有任何操作 | 未创建服务账号，或者群组成员资格锁定阻止将其添加到项目。 | [未创建内置任务流服务账号](../../../user/duo_agent_platform/troubleshooting.md#foundational-flow-service-account-not-created)和[群组成员资格已锁定](../../../user/duo_agent_platform/troubleshooting.md#group-membership-locked) |
| Agent Platform 已关闭，或出现 `Something went wrong while requesting a review from GitLab Duo` | 该用户属于多个极狐GitLab Duo 命名空间，且未设置默认命名空间。 | [未设置默认的极狐GitLab Duo 命名空间](../../../user/duo_agent_platform/troubleshooting.md#default-gitlab-duo-namespace-not-set) |
| `Your request was valid but Workflow failed to complete it` | 代码仓库没有任何提交，因此任务流无法找到默认分支。 | [错误：Your request was valid but Workflow failed to complete it](../../../user/duo_agent_platform/troubleshooting.md#error-your-request-was-valid-but-workflow-failed-to-complete-it) |
| `SSL certificate OpenSSL verify result: unable to get local issuer certificate (20)` | 在使用自定义或自签名 CA 的极狐GitLab 私有化部署上，沙箱强化会在 `git clone` 期间阻止 Runner 的 CA 注入。 | [错误：SSL certificate OpenSSL verify result](../../../user/duo_agent_platform/troubleshooting.md#error-ssl-certificate-openssl-verify-result-unable-to-get-local-issuer-certificate-20) |
| 过渡后所有用户的极狐GitLab Duo 功能立即全部失败 | 已开启静默模式，这会阻止极狐GitLab 访问 AI 网关。 | [关闭静默模式](../../silent_mode/_index.md#turn-off-silent-mode) |
| 健康检查网络测试失败，或过渡后极狐GitLab Duo 功能不可用 | 到 `cloud.jihulab.com`、`customers.jihulab.com` 或 `duo-workflow-svc.runway.gitlab.net`的出站 HTTPS 被防火墙或代理阻止。 | [允许从极狐GitLab 实例到极狐GitLab Duo 的出站连接](_index.md#allow-outbound-connections-from-the-gitlab-instance-to-gitlab-duo) |
