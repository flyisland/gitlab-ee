---
stage: AI 驱动
group: Agent 基础
info: 要确定与此页面相关的阶段/群组所指派的技术文档撰写者，请参阅 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解复合身份如何将服务账号和人类用户合并到单个令牌中，以实现安全、可追溯的代理操作。
title: 复合身份
---

{{< history >}}

- 于极狐GitLab 18.3 引入，[伴随一个功能标志](../../administration/feature_flags/_index.md) 名为 `duo_workflow_use_composite_identity`，默认禁用。
- GA 于极狐GitLab 18.8。
- 复合身份自动包含在极狐GitLab Duo Agent Platform 中，用于开启或关闭复合身份的设置在极狐GitLab 18.9 中被移除。

{{< /history >}}

复合身份是一种身份验证和授权机制，它将两个身份合并到单个令牌中：

- 服务账号。执行实际操作的系统用户。
- 人类用户。发起请求的个人。

复合身份自动包含在极狐GitLab Duo Agent Platform 中。

这种双身份方法解决了一个关键挑战：
代理需要以不超过触发它们的用户所拥有的访问权限或不超过服务账号被授予的访问权限来执行操作，
同时保持一个独特的身份，清晰地表明操作是由代理执行的，而不是直接由人类用户执行的。

<a id="why-composite-identity-matters"></a>

## 为什么复合身份很重要

复合身份很重要，因为它有助于确保：

- 可追溯性：所有代理活动都明确归属于服务账号，
  从而在审计日志和提交历史中轻松识别自动化操作。
- 安全性：代理只能执行服务账号和触发用户都有权执行的操作。这种交集访问防止了权限提升。
- 问责性：人类用户的身份被嵌入令牌中，创建了一条审计跟踪，
  将代理操作追溯到发起操作的个人。

例如，当你要求代理为你的代码创建测试时，
生成的提交将显示它们是由服务账号代表你创建的。

<a id="where-composite-identity-is-used"></a>

## 复合身份的使用场景

复合身份用于流程和代理在 runner 上执行的情况。该列表包括：

- 内置任务流。
- 自定义流程。
- 外部代理。
- 任何通过端点 `api/v4/ai/duo_workflows/workflows` 启动的流程。

复合身份不适用于 UI 和 IDE 中的极狐GitLab Duo Agentic Chat。

<a id="how-composite-identity-works"></a>

## 复合身份的工作原理

用于认证请求的令牌是两个身份的复合体：

- 主要作者：启动代理或流程的人类用户。
  通过使用[动态作用域](https://github.com/doorkeeper-gem/doorkeeper/pull/1739)，人类用户的 `id` 被包含在令牌的作用域中。
- 次要作者：一个[服务账号](../profile/service_accounts.md)，
  它是令牌的所有者，并具有开发者角色。

这种复合身份确保由极狐GitLab Duo Agent Platform 执行的所有活动都被归因于人类用户，同时防止人类用户或服务账号进行[权限提升](https://en.wikipedia.org/wiki/Privilege_escalation)。

<a id="composite-identity-workflow"></a>

## 复合身份工作流

复合身份是工作流的一部分。

1. 在 AI 目录中创建一个流程。
   - 不会发生与复合身份相关的更改。
1. 为项目启用该流程。
   - 在顶级群组中创建一个服务账号。（名称类似于 `ai-flowname-groupname`。）
   - 该服务账号被添加到项目中，角色为开发者。
1. 用户执行该流程。
   - 该流程由一次性复合身份执行。
     此身份结合了用户的角色和服务账号的开发者角色，
     取其中更严格的那个。因此，如果用户是维护者，
     但服务账号是开发者，则使用开发者角色。
   - 该流程可以访问以下所有项目：
     - 用户有权访问的项目。
     - 服务账号被添加到的项目。

     例如，如果服务账号已被添加到其他项目，
     并且用户有权访问这些项目，
     即使该用户之前未在这些项目中使用过该流程，该流程也可以访问这些项目。

<a id="token-permissions-for-ai-catalog-flows"></a>

## AI 目录流程的令牌权限

AI 目录流程使用具有不同权限作用域的不同令牌类型：

- 用于 AI 工作流中复合身份的 OAuth 令牌的访问权限限制在 `ai_workflows` 和 `mcp` 作用域内。
  此 OAuth 令牌被传递给 AI 网关以运行流程。
- 作为流程一部分触发的 CI 作业令牌的权限进一步受到
  [可用的作业令牌权限](../../ci/jobs/ci_job_token.md#job-token-access) 的限制。

由于这些是不同的令牌类型且具有不同的作用域，CI/CD 作业的权限与 OAuth 令牌的权限不同。

<a id="compliance-considerations-for-merge-requests"></a>

## 合并请求的合规性考量

当流程创建合并请求时，该合并请求归属于触发流程的人类用户，而非服务账号。这样做是为了遵循要求职责分离的合规框架，包括：

- SOC 2（系统与组织控制 2）
- SOX（萨班斯-奥克斯利法案）
- ISO 27001（信息安全管理）
- FedRAMP（联邦风险和授权管理计划）

这些框架通常要求用户不能既编写代码更改，又批准这些更改用于生产部署。

### 理解归属模型

尽管服务账号创建了提交并开启了合并请求，但人类用户被视为作者，因为：

- 人类用户指示服务账号创建更改。
- 从合规角度看，提示 AI 系统编写代码等同于自己编写代码。
- 服务账号作为人类用户意图的代理。