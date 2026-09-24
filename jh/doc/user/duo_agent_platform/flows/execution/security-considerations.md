---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解 CI/CD 中任务流的安全模型、Agent 配置文件的风险以及推荐的保护措施。
title: 任务流执行的安全注意事项
---

{{< details >}}

- Tier: [基础版](../../../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当任务流在极狐GitLab CI/CD 中执行时：

- 它们使用[复合身份](../../composite_identity.md)来限制访问权限。
- 它们会创建一个临时的[工作负载流水线](../../../../ci/pipelines/pipeline_types.md#workload-pipeline)，该流水线在任务流完成后会被移除。
- 它们可用的工具仅限于任务流的目的所需。这些工具可能包括创建合并请求或在执行环境中运行本地 shell 命令。

默认情况下，任务流只能通过网络访问极狐GitLab 实例。
有关网络访问规则的更多信息，请参阅[如何配置网络策略](../../environment_sandbox.md#configure-a-network-policy)。
这种独立的环境可以防止运行 shell 命令带来的意外后果。

为防止任务流在极狐GitLab UI 中自主运行，您可以[关闭任务流执行](../foundational_flows/_index.md#turn-foundational-flows-on-or-off)。

<a id="security-implications-of-agent-configyml"></a>

## `agent-config.yml` 的安全影响

`.gitlab/duo/agent-config.yml` 文件控制任务流在 CI/CD 中的执行方式，包括在 `setup_script` 中运行的命令。由于任务流的运行方式，对此文件的更改影响的不仅仅是提交更改的用户。

<a id="cross-user-execution"></a>

### 跨用户执行

任务流通过[复合身份](../../composite_identity.md)以触发它们的用户身份运行。
`setup_script` 中的命令使用触发用户的复合身份凭据执行，而不是提交配置的用户的凭据。

对 `.gitlab/duo/agent-config.yml` 具有写入权限的用户可以影响其他用户的 Runner 环境中运行的内容。对此文件的修改会影响项目中后续触发任务流的每个用户的执行上下文。

<a id="exposed-environment-variables"></a>

### 暴露的环境变量

在 `setup_script` 执行期间（在 Anthropic Sandbox Runtime (SRT) 之外运行），环境中存在以下敏感变量：

- `GITLAB_OAUTH_TOKEN` 和 `GITLAB_TOKEN`：通过复合身份获取的触发用户的 OAuth 令牌。
- `DUO_WORKFLOW_GIT_HTTP_PASSWORD`：Git HTTP 密码。
- `DUO_WORKFLOW_SERVICE_TOKEN`：服务令牌。
- `DUO_WORKFLOW_GIT_USER_EMAIL` 和 `DUO_WORKFLOW_GIT_USER_NAME`：触发用户的电子邮件和姓名。

有关暴露变量的完整列表，请参阅[任务流执行变量](execution-variables.md)。

<a id="recommended-protections"></a>

### 推荐的保护措施

为降低对 `.gitlab/duo/agent-config.yml` 文件进行未经授权更改的风险：

- [保护您的默认分支](../../../project/repository/branches/protected.md)以防止直接推送。
- 使用[代码所有者](../../../project/codeowners/_index.md)要求在合并对 `.gitlab/duo/agent-config.yml` 的更改之前获得特定所有者的批准。
  例如，将以下内容添加到您的 `CODEOWNERS` 文件中：

  ```plaintext
  .gitlab/duo/agent-config.yml @your-group/security-reviewers
  ```

- 配置[审批规则](../../../project/merge_requests/approvals/rules.md)，要求修改此文件的合并请求必须经过受信任维护者的审查。
