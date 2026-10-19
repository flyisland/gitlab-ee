---
stage: AI Coding
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab 中最常见的合并请求流程使用 forks、受保护分支，或两者兼用。
title: 合并请求工作流
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 合并请求通常遵循以下流程之一：

- 在单个代码仓库中使用[受保护分支](../repository/branches/protected.md)。
- 使用权威项目的 forks。

<a id="protected-branch-flow"></a>

## 受保护分支流程

在受保护分支流程中，所有人都在同一个极狐GitLab 项目中工作，而不是使用 forks。

项目维护者拥有维护者角色，普通开发者拥有开发者角色。

维护者将权威分支标记为“受保护”。

开发者将功能分支推送到项目，并创建合并请求，以便其功能分支得到评审并合并到某个受保护分支中。

默认情况下，只有拥有维护者角色的用户才能将更改合并到受保护分支。

- 优点：
  - 项目更少，意味着更少的杂乱。
  - 开发者只需考虑一个远程代码仓库。
- 缺点：
  - 每个新项目都需要手动设置受保护分支。

要设置受保护分支流程：

1. 首先确保您的默认分支受到[默认分支保护](../repository/branches/default.md)的保护。
1. 如果您的团队有多个分支，并且您希望管理谁可以合并更改，以及谁
   明确有权推送或强制推送，请考虑将这些分支设为受保护分支：

   - [管理和保护分支](../repository/branches/_index.md#manage-and-protect-branches)
   - [受保护分支](../repository/branches/protected.md)

1. 对代码的每次更改都以提交的形式进入。
   您可以通过推送规则指定格式和安全措施，例如要求对进入代码库的更改
   进行 SSH 密钥签名：

   - [推送规则](../repository/push_rules.md)

1. 为确保代码由团队中合适的人员评审和检查，请使用：

   - [代码所有者](../codeowners/_index.md)
   - [合并请求审批规则](approvals/rules.md)

旗舰版中还提供：

- [状态检查](status_checks.md)
- [安全审批](approvals/rules.md#security-approvals)

<a id="forking-workflow"></a>

## Forking 工作流

在 forking 工作流中，维护者在权威代码仓库上拥有维护者角色，普通开发者在权威代码仓库上拥有报告者角色，这禁止他们向其推送任何更改。

开发者创建权威项目的 forks，并将他们的功能分支推送到自己的 forks。

要将其更改合并到默认分支，他们需要跨 forks 创建合并请求。

- 优点：
  - 在配置得当的极狐GitLab 群组中，新项目会自动获得
    普通开发者所需的访问限制：为新项目配置授权的手动步骤
    更少。
- 缺点：
  - 项目需要保持其 forks 为最新状态，这需要更高级的
    Git 技能（管理多个远程仓库）。
