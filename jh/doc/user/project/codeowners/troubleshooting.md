---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用代码所有者定义代码库的专家，并根据文件类型或位置设置评审要求。
title: 代码所有者故障排除
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用代码所有者时，您可能会遇到以下问题。

有关代码所有者功能如何处理错误的更多信息，请参阅[错误处理](advanced.md#error-handling)。

<a id="validate-your-codeowners-file"></a>

## 验证您的 CODEOWNERS 文件

> [!flag]
> 此功能的可用性由功能标志控制。

查看 [`CODEOWNERS` 文件](_index.md#codeowners-file)时，极狐GitLab 会运行验证，帮助您发现语法和权限问题。如果未发现语法问题，极狐GitLab：

- 不再对该文件运行更多验证器。
- 对该文件中找到的前 200 个唯一用户和群组引用运行更多权限验证。

其工作方式如下：

1. 查找所有可以访问该项目的引用。如果添加了某个用户或群组引用，但该引用没有项目访问权限，则显示错误。
1. 对于每个有效的用户引用，检查该用户是否有权批准项目中的合并请求。如果该用户没有该权限，则显示错误。
1. 对于每个有效的群组引用，检查其最大角色值是否为开发者或更高。对于每个角色值低于开发者的群组引用，显示错误。
1. 对于每个有效的群组引用，检查该群组是否至少包含一名有权批准合并请求的用户。对于任何包含零名有权批准合并请求的用户的群组引用，显示错误。

<a id="approvals-do-not-show"></a>

## 审批未显示

在创建合并请求之前，[`CODEOWNERS` 文件](_index.md#codeowners-file)必须已存在于目标分支中。

代码所有者审批规则仅在创建合并请求时更新。如果您更新了 `CODEOWNERS` 文件，请关闭该合并请求并创建一个新的合并请求。

<a id="approvals-shown-as-optional"></a>

## 审批显示为可选

如果满足以下任一条件，则代码所有者审批规则为可选：

- 该用户或群组不是项目成员。
  代码所有者[无法从父群组继承成员](https://gitlab.com/gitlab-org/gitlab/-/issues/288851/)。
- 该用户或群组[格式错误或无法访问](advanced.md#malformed-owners)。
- 尚未设置[受保护分支上的代码所有者审批](../repository/branches/protected.md#require-code-owner-approval)。
- 该部分[标记为可选](reference.md#optional-sections)。
- 由于与其他[合并请求审批设置](../merge_requests/approvals/settings.md)冲突，没有符合条件的代码所有者可以批准该合并请求。

<a id="user-not-shown-as-possible-approver"></a>

## 用户未显示为可能的审批人

如果满足以下任一条件，则用户可能不会在代码所有者合并请求审批规则中显示为审批人：

- 某条规则阻止该特定用户批准该合并请求。
  请检查项目的[合并请求审批](../merge_requests/approvals/settings.md#edit-merge-request-approval-settings)设置。
- 某个代码所有者群组的可见性为私有，且当前用户不是该代码所有者群组的成员。
- 该特定用户名拼写错误，或在 [`CODEOWNERS` 文件中格式错误](advanced.md#malformed-owners)。
- 当前用户是外部用户，没有访问内部代码所有者群组的权限。

<a id="approval-rule-is-invalid"></a>

## 审批规则无效

您可能会收到如下错误：

```plaintext
Approval rule is invalid.
GitLab has approved this rule automatically to unblock the merge request.
```

当审批规则使用的代码所有者不是项目的直接成员时，会出现此问题。

变通方法是检查该群组或用户是否已被邀请加入项目。

<a id="codeowners-not-updated-when-user-or-group-names-change"></a>

## 用户或群组名称更改时 `CODEOWNERS` 未更新

当用户或群组更改其名称时，`CODEOWNERS` 不会自动更新为新名称。要输入新名称，您必须编辑该文件。

使用 SAML SSO 的组织可以[设置用户名](../../../integration/saml.md#set-a-username)，以防止用户更改其用户名。

<a id="incompatibility-with-global-group-memberships-locks"></a>

## 与全局群组成员关系锁定不兼容

代码所有者功能要求群组直接成为项目成员。启用全局群组成员关系锁定后，会阻止群组作为直接成员被邀请加入项目。这会导致这两个功能之间不兼容。

启用全局 [SAML](../../group/saml_sso/group_sync.md#global-saml-group-memberships-lock) 或 [LDAP](../../../administration/auth/ldap/ldap_synchronization.md#global-ldap-group-memberships-lock) 群组成员关系锁定后，您无法将群组或子群组用作代码所有者。

如果您启用了全局 SAML 或 LDAP 群组成员关系锁定，可以选择以下方案：

- 使用单个用户而非群组作为代码所有者。
- 如果基于群组的代码所有者优先级更高，请禁用全局群组成员关系锁定。

对继承群组成员的支持已在[议题 288851](https://gitlab.com/gitlab-org/gitlab/-/issues/288851)中提出。
