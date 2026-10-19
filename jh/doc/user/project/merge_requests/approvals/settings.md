---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在极狐GitLab 中使用合并请求审批设置定义审批规则和限制。选项包括禁止作者批准、要求重新认证，以及在新提交时移除审批。
title: 合并请求审批设置
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以配置[合并请求审批](_index.md)的设置，以确保审批规则符合您的使用场景。您还可以配置[审批规则](rules.md)，这些规则定义了在合并之前必须批准相关工作的用户数量和类型。合并请求审批设置定义了当合并请求逐步完成时如何应用这些规则。

您可以使用这些设置的任意组合来配置合并请求的审批限制：

- [**防止合并请求创建者批准**](#prevent-approval-by-merge-request-creator)：
  禁止合并请求的作者批准该合并请求。
- [**阻止添加提交的用户批准**](#prevent-approvals-by-users-who-add-commits)：
  禁止向合并请求添加提交的用户同时批准该合并请求。
- [**禁止在合并请求中编辑审批规则**](#prevent-editing-approval-rules-in-merge-requests)：
  禁止用户在合并请求中覆盖项目审批规则。
- [**要求用户重新认证（密码或 SAML）才能批准**](#require-user-re-authentication-to-approve)：
  强制潜在的审批人先使用密码或 SAML 进行认证。
- 代码所有者审批移除：定义当合并请求中添加提交时，现有审批会如何处理。
  - **保留审批**：不移除任何审批。
  - [**移除所有审批**](#remove-all-approvals-when-commits-are-added-to-the-source-branch)：
    移除所有现有审批。
  - [**如果代码所有者的文件发生变更，则移除其审批**](#remove-approvals-by-code-owners-if-their-files-changed)：
    如果代码所有者批准了某个合并请求，而后续提交更改了他们作为代码所有者的文件，
    则其审批会被移除。

<a id="edit-merge-request-approval-settings"></a>

## 编辑合并请求审批设置

要查看或编辑单个项目的合并请求审批设置：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **合并请求**。
1. 展开**审批**。

<a id="cascade-settings-from-the-instance-or-top-level-group"></a>

### 从实例或顶级群组级联设置

为了简化审批规则设置的管理，请尽可能广泛地配置它们。配置的设置：

- [针对您的实例](../../../../administration/merge_requests_approvals.md)的设置适用于该实例上的所有群组
  和项目。
- 针对[顶级群组](../../../group/manage.md#group-merge-request-approval-settings)的设置适用于
  其子群组和项目。

设置的级联方式取决于其配置位置：

- 为您的实例配置的设置会锁定所有群组和项目的等效设置。
  您无法在群组或项目中更改继承的设置。
- 为顶级群组配置的设置会级联到其子群组和项目：
  - 为群组启用某项禁止设置时，等效的项目设置会被
    锁定。项目维护者无法更改它。
  - 为群组禁用某项禁止设置时，项目维护者可以为
    单个项目配置它。

<a id="prevent-approval-by-merge-request-creator"></a>

## 防止合并请求创建者批准

默认情况下，合并请求的创建者（作者）无法批准该合并请求。要更改此设置：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **合并请求**。
1. 在**合并请求审批**部分，滚动到**审批设置**，然后
   清除**防止合并请求创建者（作者）批准**复选框。
1. 选择**保存更改**。

合并请求创建者可以在单个合并请求中编辑审批规则并覆盖此设置，除非您配置了以下选项之一：

- 为您的项目[禁止覆盖默认审批](#prevent-editing-approval-rules-in-merge-requests)。
- *（仅限极狐GitLab 私有化部署实例）*[为您的实例](../../../../administration/merge_requests_approvals.md)
  禁止覆盖默认审批。为您的实例配置后，您无法在项目或单个
  合并请求上编辑此设置。

<a id="prevent-approvals-by-users-who-add-commits"></a>

## 阻止添加提交的用户批准

默认情况下，向合并请求提交的用户（提交者）仍然可以批准该合并请求。要禁止您项目（或您的实例）中的提交者批准部分由自己提交的合并请求：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **合并请求**。
1. 在**合并请求审批**部分，滚动到**审批设置**，然后
   选择**阻止添加提交的用户批准**。
   如果此复选框已清除，则管理员已
   [为您的实例](../../../../administration/merge_requests_approvals.md)禁用了它，
   您无法为您的项目更改它。
1. 选择**保存更改**。

如果合并请求影响了[代码所有者](../../codeowners/_index.md)拥有的文件，则向该合并请求提交的代码所有者无法批准它。

有关更多信息，请参阅[官方 Git 文档](https://git-scm.com/book/en/v2/Git-Basics-Viewing-the-Commit-History)。

> [!warning]
> 如果合并请求由最初提交更改的用户以外的人执行变基，
> 提交历史会以新的提交者重写。这可能会使之前在合并请求中提交更改的用户
> 现在可以批准其中的更改，因为他们不再是提交者。
>
> 另请参阅[变基后批准](../../../../topics/git/git_rebase.md#approving-after-rebase)

<a id="prevent-editing-approval-rules-in-merge-requests"></a>

## 禁止在合并请求中编辑审批规则

默认情况下，用户可以在单个合并请求上覆盖您[为项目创建](rules.md)的审批规则。如果您不希望用户更改合并请求上的审批规则，可以禁用此设置：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **合并请求**。
1. 在**合并请求审批**部分，滚动到**审批设置**，然后
   选择**禁止在合并请求中编辑审批规则**。
1. 选择**保存更改**。

> [!note]
> 此设置在每个层级的作用范围不同。对于项目或群组，它会阻止按合并请求
> 覆盖审批规则。项目设置中的审批规则列表仍可编辑。
> 若要同时阻止项目维护者编辑审批规则列表，管理员必须
> 为您的实例启用
> [**禁止在项目和合并请求中编辑审批规则**](../../../../administration/merge_requests_approvals.md)。
当您更改此字段时，根据设置的不同，它可能会影响所有打开的合并请求：

- 如果用户之前可以编辑审批规则，而您禁用了此行为，
  极狐GitLab 会更新所有打开的合并请求以强制执行审批规则。
- 如果用户之前无法编辑审批规则，而您启用了审批规则
  编辑，打开的合并请求保持不变。这会保留这些合并请求中
  已对审批规则所做的任何更改。

<a id="require-user-re-authentication-to-approve"></a>

## 要求用户重新认证才能批准

> [!flag]
> 在极狐GitLab 私有化部署上，默认情况下可使用 SAML 认证要求重新认证。要隐藏该功能，管理员可以
> [禁用功能标志](../../../../administration/feature_flags/_index.md) `ff_require_saml_auth_to_approve`。在 JihuLab.com 上，此功能可用。

您可以强制潜在的审批人先使用 SAML 或密码进行认证。此权限可为审批启用电子签名，例如[美国联邦法规 (CFR) 第 11 部分](https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfcfr/CFRSearch.cfm?CFRPart=11&showFR=1&subpartNode=21:1.0.1.1.8.3)所定义的电子签名。

先决条件：

- 此设置仅在顶级群组上可用。

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 启用密码认证和 SAML 认证。有关以下内容的更多信息：
   - 密码认证，请参阅
     [登录限制文档](../../../../administration/settings/sign_in_restrictions.md#password-and-passkey-authentication)。
   - JihuLab.com 群组的 SAML 认证，请参阅
     [JihuLab.com 群组的 SAML SSO 文档](../../../group/saml_sso/_index.md)。
   - 极狐GitLab 私有化部署实例的 SAML 认证，请参阅
     [极狐GitLab 私有化部署的 SAML SSO](../../../../integration/saml.md)。
1. 在左侧边栏中，选择**设置** > **合并请求**。
1. 在**合并请求审批**部分，滚动到**审批设置**，然后
   选择**要求用户重新认证（密码或 SAML）才能批准**。
1. 选择**保存更改**。

<a id="remove-all-approvals-when-commits-are-added-to-the-source-branch"></a>

## 当提交添加到源分支时移除所有审批

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

默认情况下，当您在审批后添加更多更改时，合并请求上的审批会被移除。

极狐GitLab 使用 [`git patch-id`](https://git-scm.com/docs/git-patch-id) 来识别合并请求中的差异。此值是一个相当稳定且唯一的标识符，它使极狐GitLab 能更明智地判断是否重置合并请求内的审批。当您将新更改推送到合并请求时，会将 `patch-id` 与之前的 `patch-id` 进行比较，以确定是否应重置审批。这使极狐GitLab 在您对功能分支执行 `git rebase` 或 `git merge <target>`等命令时，能够做出更好的重置决策。

要在向合并请求添加更多更改后保留现有审批：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **合并请求**。
1. 在**合并请求审批**部分，滚动到**审批设置**，然后
   清除**移除所有审批**复选框。
1. 选择**保存更改**。

如果您自动化创建和批准合并请求，请加入逻辑以确保在批准合并请求之前提交已完全处理。这可以防止意外的审批重置。有关更多信息，请参阅[处理自动审批的时序问题](../../../../api/merge_request_approvals.md#prevent-approval-resets-in-automated-merge-requests)。

<a id="remove-approvals-by-code-owners-if-their-files-changed"></a>

## 如果代码所有者的文件发生变更，则移除其审批

要仅移除在新提交中文件发生变更的代码所有者的审批：

先决条件：

- 您必须拥有项目的维护者或所有者角色。

为此：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **合并请求**。
1. 在**合并请求审批**部分，滚动到**审批设置**，然后
   选择**如果代码所有者的文件发生变更，则移除其审批**。
1. 选择**保存更改**。
