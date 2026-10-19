---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解复合身份如何将服务账号与人类用户组合为单个令牌，从而实现安全、可追溯的 Agent 操作。
title: 复合身份
---

复合身份是一种身份验证和授权机制，它将两个身份组合为单个令牌：

- 服务账号。执行实际操作的 Agent。
- 人类用户。发起请求的人。

所有服务账号都具有复合身份，因为它们执行的每项操作都由人类用户发起。

复合身份已自动包含在极狐GitLab Duo Agent Platform 中。

这种双重身份方式解决了一个关键难题：Agent 执行操作时所需的访问权限，既不能超出触发它的用户的访问权限，也不能超出授予该服务账号的访问权限，同时还要保持一个独立的身份，清楚地表明该操作是由 Agent 执行的，而不是由人类用户直接执行的。

<a id="why-composite-identity-matters"></a>

## 复合身份的重要性

复合身份之所以重要，是因为它有助于确保：

- 可追溯性：所有 Agent 活动都明确归属于某个服务账号，
  从而便于在审计日志和提交历史中识别自动化操作。
- 安全性：Agent 只能执行服务账号和触发用户都有权执行的操作。这种交集式访问可防止权限提升。
- 可问责性：人类用户的身份嵌入在令牌中，形成审计事件记录，
  将 Agent 操作关联回发起这些操作的人。

例如，当您让 Agent 为您的代码创建测试时，生成的提交会显示它们是由服务账号代表您创建的。

<a id="where-composite-identity-is-used"></a>

## 复合身份的使用场景

当任务流和 Agent 在 Runner 上执行时会使用复合身份。包括：

- 内置任务流。
- 自定义任务流。
- 外部 Agent。
- 通过端点 `api/v4/ai/duo_workflows/workflows` 启动的任何任务流。

复合身份不适用于 UI 和 IDE 中的极狐GitLab Duo Agentic Chat。

<a id="how-composite-identity-works"></a>

## 复合身份的工作原理

用于对请求进行身份验证的令牌由两个身份组合而成：

- 主要作者：启动 Agent 或任务流的人类用户。
  人类用户的 `id` 通过[动态作用域](https://github.com/doorkeeper-gem/doorkeeper/pull/1739)包含在令牌的作用域中。
- 次要作者：一个[服务账号](../profile/service_accounts.md)，
  它是该令牌的所有者，并具有开发者角色。

这种复合身份可确保由极狐GitLab Duo Agent Platform 创建的任何活动
都归属于人类用户，同时防止人类用户或服务账号进行[权限提升](https://en.wikipedia.org/wiki/Privilege_escalation)。

<a id="composite-identity-workflow"></a>

## 复合身份工作流

复合身份是工作流的一部分。

1. 在 AI 目录中创建任务流。
   - 不会发生与复合身份相关的更改。
1. 为项目启用该任务流。
   - 在顶级群组中创建一个服务账号。（名称类似于 `ai-flowname-groupname`。）
   - 将该服务账号以开发者角色添加到项目中。
1. 用户执行该任务流。
   - 该任务流由一次性复合身份执行。
     该身份同时具有用户的角色和服务账号的开发者角色，
     以其中限制更严格者为准。因此，如果用户是维护者，
     但服务账号是开发者，则使用开发者角色。
   - 该任务流可以访问同时满足以下两个条件的项目：
     - 用户有权访问。
     - 服务账号已被添加到该项目。

     例如，如果该服务账号已被添加到其他项目，
     并且用户有权访问这些项目，
     那么即使该用户之前未在这些项目中使用过该任务流，该任务流也可以访问这些项目。

<a id="token-permissions-for-ai-catalog-flows"></a>

## AI 目录任务流的令牌权限

AI 目录任务流使用具有不同权限作用域的不同令牌类型：

- AI 工作流中用于复合身份的 OAuth 令牌，其访问权限仅限于 `ai_workflows` 和 `mcp` 作用域。
  该 OAuth 令牌会传递给 AI 网关以运行任务流。
- 作为任务流的一部分触发的 CI 作业令牌，其权限进一步受
  [可用的作业令牌权限](../../ci/jobs/ci_job_token.md#job-token-access)限制。

由于这些是作用域不同的令牌类型，CI/CD 作业的权限与 OAuth 令牌不同。

<a id="compliance-considerations-for-merge-requests"></a>

## 合并请求的合规注意事项

当任务流创建合并请求时，该合并请求归属于触发该任务流的人类用户，而不是服务账号。这样做是为了遵循要求职责分离的合规框架，包括：

- SOC 2（系统与组织控制 2）
- SOX（萨班斯-奥克斯利法案）
- ISO 27001（信息安全管理）
- FedRAMP（联邦风险与授权管理计划）

这些框架通常要求用户不能既编写代码变更，又批准这些变更以部署到生产环境。

<a id="understanding-the-attribution-model"></a>

### 了解归属模型

即使服务账号创建了提交并打开了合并请求，人类用户仍被视为作者，因为：

- 是人类用户指示服务账号创建这些变更的。
- 从合规角度看，提示 AI 系统编写代码等同于您自己编写代码。
- 服务账号充当人类用户意图的代理。
