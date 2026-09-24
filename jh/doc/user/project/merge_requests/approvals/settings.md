---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Define approval rules and limits in GitLab with merge request approval settings. Options include preventing author approval, requiring re-authentication, and removing approvals on new commits.
title: 合并请求审批设置
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以配置[合并请求审批](_index.md)设置，以确保审批规则满足你的使用需求。你还可以配置[审批规则](rules.md)，这些规则定义了在合并之前必须审批工作的用户数量和类型。合并请求审批设置定义了如何在合并请求向完成推进时应用这些规则。

你可以组合使用以下设置来配置合并请求的审批限制：

- [**阻止合并请求作者审批**](#prevent-approval-by-merge-request-creator)：阻止合并请求的作者审批自己的合并请求。
- [**阻止添加提交的用户审批**](#prevent-approvals-by-users-who-add-commits)：阻止向合并请求添加提交的用户同时审批该合并请求。
- [**阻止在合并请求中编辑审批规则**](#prevent-editing-approval-rules-in-merge-requests)：阻止用户在合并请求中覆盖项目审批规则。
- [**要求用户重新认证（密码或 SAML）才能审批**](#require-user-re-authentication-to-approve)：强制潜在审批者首先通过密码或 SAML 进行认证。
- 代码所有者审批移除：定义当提交添加到合并请求时，现有审批会发生什么变化。
  - **保留审批**：不移除任何审批。
  - [**移除所有审批**](#remove-all-approvals-when-commits-are-added-to-the-source-branch)：移除所有现有审批。
  - [**如果代码所有者的文件发生更改，则移除其审批**](#remove-approvals-by-code-owners-if-their-files-changed)：如果代码所有者审批了合并请求，但随后的提交更改了他们所负责的文件，则其审批将被移除。

<a id="edit-merge-request-approval-settings"></a>

## 编辑合并请求审批设置

要查看或编辑单个项目的合并请求审批设置：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **合并请求**。
1. 展开 **审批**。

<a id="cascade-settings-from-the-instance-or-top-level-group"></a>

### 从实例或顶级群组级联设置

为了简化审批规则设置的管理，请尽可能广泛地配置它们。设置配置如下：

- [针对你的实例](../../../../administration/merge_requests_approvals.md) 的设置适用于实例上的所有群组和项目。
- 针对[顶级群组](../../../group/manage.md#group-merge-request-approval-settings) 的设置适用于其子群组和项目。

设置的级联方式取决于其配置位置：

- 为你的实例配置的设置会锁定所有群组和项目中的等效设置。你无法在群组或项目中更改继承的设置。
- 为顶级群组配置的设置会级联到其子群组和项目：
  - 当为群组启用了阻止设置时，等效的项目设置将被锁定。项目维护者无法更改它。
  - 当为群组禁用了阻止设置时，项目维护者可以为各个项目配置它。

<a id="prevent-approval-by-merge-request-creator"></a>

## 阻止合并请求作者审批

默认情况下，合并请求的创建者（作者）不能审批它。要更改此设置：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **合并请求**。
1. 在 **合并请求审批** 部分中，滚动到 **审批设置** 并清除 **阻止合并请求作者（作者）审批** 复选框。
1. 选择 **保存更改**。

合并请求创建者可以在单个合并请求中编辑审批规则并覆盖此设置，除非你配置了以下选项之一：

- [为你的项目阻止覆盖默认审批](#prevent-editing-approval-rules-in-merge-requests)。
- *（仅限私有化部署实例）* 阻止覆盖实例的默认审批 [针对你的实例](../../../../administration/merge_requests_approvals.md)。当为你的实例配置此设置后，你将无法在项目或单个合并请求中编辑此设置。

<a id="prevent-approvals-by-users-who-add-commits"></a>

## 阻止添加提交的用户审批

{{< history >}}

- 在 极狐GitLab 16.3 中添加了功能标志 `keep_merge_commits_for_approvals`，以在此检查中也包含合并提交。
- 在 极狐GitLab 16.5 中移除了功能标志 `keep_merge_commits_for_approvals`。此检查现在包含合并提交。

{{< /history >}}

默认情况下，向合并请求提交的用户（提交者）仍然可以审批它。要阻止项目（或实例）中的提交者审批部分属于自己的合并请求：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **合并请求**。
1. 在 **合并请求审批** 部分中，滚动到 **审批设置** 并选择 **阻止添加提交的用户审批**。如果此复选框未选中，则表示管理员已[针对你的实例](../../../../administration/merge_requests_approvals.md)禁用它，因此你无法为你的项目更改它。
1. 选择 **保存更改**。

如果合并请求影响了代码所有者所拥有的文件，那么向合并请求提交的[代码所有者](../../codeowners/_index.md)将无法审批它。

有关更多信息，请参阅[官方 Git 文档](https://git-scm.com/book/en/v2/Git-Basics-Viewing-the-Commit-History)。

> [!warning]
> 如果合并请求是由最初提交更改的用户以外的其他人进行变基的，那么提交历史将被重写，由新的提交者提交。这可能会使之前曾在合并请求中提交过更改的用户现在能够审批其中的更改，因为他们不再是提交者。
>
> 另请参阅[变基后的审批](../../../../topics/git/git_rebase.md#approving-after-rebase)

<a id="prevent-editing-approval-rules-in-merge-requests"></a>

## 阻止在合并请求中编辑审批规则

默认情况下，用户可以按合并请求覆盖你[为项目创建的](rules.md)审批规则。如果你不希望用户在合并请求中更改审批规则，可以禁用此设置：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **合并请求**。
1. 在 **合并请求审批** 部分中，滚动到 **审批设置** 并选择 **阻止在合并请求中编辑审批规则**。
1. 选择 **保存更改**。

> [!note]
> 此设置在各个级别的作用范围不同。对于项目或群组，它阻止每个合并请求的审批规则覆盖。项目设置中的审批规则列表仍然可以编辑。要同时阻止项目维护者编辑审批规则列表，管理员必须为你的实例启用 [**阻止在项目和合并请求中编辑审批规则**](../../../../administration/merge_requests_approvals.md)。
> 当你更改此字段时，根据设置，它可能会影响所有打开的合并请求：
>
> - 如果用户之前可以编辑审批规则，而你禁用了此行为，极狐GitLab 会更新所有打开的合并请求以强制执行审批规则。
> - 如果用户之前无法编辑审批规则，而你启用了审批规则编辑，打开的合并请求将保持不变。这会保留这些合并请求中已对审批规则所做的任何更改。

<a id="require-user-re-authentication-to-approve"></a>

## 要求用户重新认证才能审批

{{< history >}}

- 在 极狐GitLab 16.6 中，针对 JihuLab.com 群组引入通过 SAML 认证要求重新认证的功能，[带有功能标志](../../../../administration/feature_flags/_index.md) `ff_require_saml_auth_to_approve`。默认禁用。
- 在 极狐GitLab 16.7 中，针对私有化部署实例引入通过 SAML 认证要求重新认证的功能，[带有功能标志](../../../../administration/feature_flags/_index.md) `ff_require_saml_auth_to_approve`。默认禁用。
- 在 极狐GitLab 16.8 中，为 JihuLab.com 默认启用 `ff_require_saml_auth_to_approve`。
- 功能标志在 极狐GitLab 18.3 中移除。

{{< /history >}}

> [!flag]
> 在私有化部署实例上，默认可以通过 SAML 认证要求重新认证。要隐藏此功能，管理员可以[禁用功能标志](../../../../administration/feature_flags/_index.md) `ff_require_saml_auth_to_approve`。在 JihuLab.com 上，此功能可用。

你可以强制潜在审批者首先通过 SAML 或密码进行认证。此权限为审批启用了电子签名，例如 [美国联邦法规 (CFR) 第 11 部分](https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfcfr/CFRSearch.cfm?CFRPart=11&showFR=1&subpartNode=21:1.0.1.1.8.3) 中定义的电子签名。

Prerequisites:

- 此设置仅在顶级群组上可用。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 启用密码认证和 SAML 认证。有关以下内容的更多信息：
   - 密码认证，请参阅[登录限制文档](../../../../administration/settings/sign_in_restrictions.md#password-and-passkey-authentication)。
   - JihuLab.com 群组的 SAML 认证，请参阅 [JihuLab.com 群组的 SAML SSO 文档](../../../group/saml_sso/_index.md)。
   - 私有化部署实例的 SAML 认证，请参阅[私有化部署的 SAML SSO](../../../../integration/saml.md)。
1. 在左侧边栏中，选择 **设置** > **合并请求**。
1. 在 **合并请求审批** 部分中，滚动到 **审批设置** 并选择 **要求用户重新认证（密码或 SAML）才能审批**。
1. 选择 **保存更改**。

<a id="remove-all-approvals-when-commits-are-added-to-the-source-branch"></a>

## 在向源分支添加提交时移除所有审批

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

默认情况下，当你在审批后添加更多更改时，合并请求上的审批将被移除。

极狐GitLab 使用 [`git patch-id`](https://git-scm.com/docs/git-patch-id) 来识别合并请求中的差异。此值是一个相当稳定且唯一的标识符，能够在合并请求中做出更明智的审批重置决策。当你向合并请求推送新更改时，`patch-id` 会与之前的 `patch-id` 比较，以确定是否应重置审批。这使得极狐GitLab 在功能分支上执行诸如 `git rebase` 或 `git merge <target>` 等命令时，能够做出更好的重置决策。

要在合并请求中添加更多更改后保留现有审批：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **合并请求**。
1. 在 **合并请求审批** 部分中，滚动到 **审批设置** 并清除 **移除所有审批** 复选框。
1. 选择 **保存更改**。

如果你自动化创建和审批合并请求，请构建逻辑以确保在审批合并请求之前完全处理提交。这可以防止意外的审批重置。有关更多信息，请参阅[处理自动审批的时间问题](../../../../api/merge_request_approvals.md#prevent-approval-resets-in-automated-merge-requests)。

<a id="remove-approvals-by-code-owners-if-their-files-changed"></a>

## 如果代码所有者的文件发生更改，则移除其审批

要仅从在新提交中文件发生更改的代码所有者那里移除审批：

Prerequisites:

- 你必须拥有项目的维护者或所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **合并请求**。
1. 在 **合并请求审批** 部分中，滚动到 **审批设置** 并选择 **如果代码所有者的文件发生更改，则移除其审批**。
1. 选择 **保存更改**。