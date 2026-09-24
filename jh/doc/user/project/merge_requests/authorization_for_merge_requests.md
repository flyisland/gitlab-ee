---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: The most common merge request flows in GitLab use forks, protected branches, or both.
title: 合并请求工作流
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 合并请求通常遵循以下流程之一：

- 在单个代码仓中使用[受保护分支](../repository/branches/protected.md)。
- 与权威项目的派生项目协作。

<a id="protected-branch-flow"></a>

受保护分支流程

在受保护分支流程中，所有人都在同一个极狐GitLab 项目中工作，而不是使用派生。

项目维护者获得维护者角色，普通开发者获得开发者角色。

维护者将权威分支标记为“受保护”。

开发者将功能分支推送到项目中，并创建合并请求，以便对他们的功能分支进行审查，并合并到一个受保护分支中。

默认情况下，只有具有维护者角色的用户才能将更改合并到受保护分支中。

- 优点：
  - 更少的项目意味着更少的杂乱。
  - 开发者只需考虑一个远程代码仓。
- 缺点：
  - 每个新项目都需要手动设置受保护分支

要设置受保护分支流程：

1. 首先确保你的默认分支受到[默认分支保护](../repository/branches/default.md)的保护。
1. 如果你的团队有多个分支，并且你想管理谁可以合并更改，以及谁明确有推送或强制推送的选项，考虑将这些分支设为受保护：
   - [管理和保护分支](../repository/branches/_index.md#manage-and-protect-branches)
   - [受保护分支](../repository/branches/protected.md)
1. 每次对代码的更改都以提交的形式出现。你可以使用推送规则来指定格式和安全措施，例如要求对进入代码库的更改进行 SSH 密钥签名：
   - [推送规则](../repository/push_rules.md)
1. 为确保你的团队中合适的人员审查和检查代码，请使用：
   - [代码所有者](../codeowners/_index.md)
   - [合并请求批准规则](approvals/rules.md)

在旗舰版中也可用：

- [状态检查](status_checks.md)
- [安全批准](approvals/rules.md#security-approvals)

<a id="forking-workflow"></a>

派生工作流

在派生工作流中，维护者获得维护者角色，普通开发者在权威代码仓中获得报告者角色，这禁止他们向权威代码仓推送任何更改。

开发者创建权威项目的派生，并将他们的功能分支推送到自己的派生中。

要将他们的更改纳入默认分支，他们需要创建一个跨派生的合并请求。

- 优点：
  - 在适当配置的极狐GitLab 群组中，新项目会自动为普通开发者设置所需的访问限制：更少的手动步骤来配置新项目的授权。
- 缺点：
  - 项目需要保持其派生为最新状态，这要求更高级的 Git 技能（管理多个远程代码仓）。