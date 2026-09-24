---
stage: 创建
group: 源代码
info: 要确定与此页面相关的阶段/组的技术文档撰写者，请参见 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用代码所有者来定义代码库的专家，并根据文件类型或位置设置审核要求。
title: 排查代码所有者问题
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在使用代码所有者时，您可能会遇到以下问题。

关于代码所有者功能如何处理错误的更多信息，请参见[错误处理](advanced.md#error-handling)。

<a id="validate-your-codeowners-file"></a>

## 验证您的 CODEOWNERS 文件

{{< history >}}

- 引入于 极狐GitLab 17.11，引入了一个名为 `accessible_code_owners_validation` 的[功能标志](../../../administration/feature_flags/_index.md)。默认关闭。
- [在 极狐GitLab 18.1 中于 JihuLab.com 启用](https://gitlab.com/gitlab-org/gitlab/-/issues/524437)。
- [在 极狐GitLab 18.2 中正式发布](https://gitlab.com/gitlab-org/gitlab/-/issues/549626)。功能标志 `accessible_code_owners_validation` 已移除。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史。

在查看 [`CODEOWNERS` 文件](_index.md#codeowners-file)时，极狐GitLab 会运行验证来帮助您发现语法和权限问题。如果没有发现语法问题，极狐GitLab 会：

- 不再对该文件运行更多验证器。
- 对文件中找到的前 200 个唯一用户和群组引用运行更多的权限验证。

其工作方式如下：

1. 查找所有可以访问项目的引用。如果添加了某个用户或群组引用，但该引用没有项目访问权限，则显示错误。
1. 对于每个有效的用户引用，检查该用户是否有权在项目中批准合并请求。如果该用户没有该权限，则显示错误。
1. 对于每个有效的群组引用，检查其最高角色值是否为开发者或更高。对于角色值低于开发者的群组引用，显示错误。
1. 对于每个有效的群组引用，检查该群组是否包含至少一个有权限批准合并请求的用户。对于包含零个有权限批准合并请求的用户的群组引用，显示错误。

<a id="approvals-do-not-show"></a>

## 批准不显示

[`CODEOWNERS` 文件](_index.md#codeowners-file)必须在目标分支中存在，且在合并请求创建之前。

代码所有者批准规则仅在合并请求创建时更新。如果您更新了 `CODEOWNERS` 文件，请关闭合并请求并创建一个新的。

<a id="approvals-shown-as-optional"></a>

## 批准显示为可选

在以下任一条件下，代码所有者批准规则将成为可选：

- 用户或群组不是项目的成员。代码所有者[不能从父群组继承成员](https://gitlab.com/gitlab-org/gitlab/-/issues/288851/)。
- 用户或群组[格式不正确或无法访问](advanced.md#malformed-owners)。
- 尚未在[受保护分支上设置代码所有者批准](../repository/branches/protected.md#require-code-owner-approval)。
- 该部分被[标记为可选](reference.md#optional-sections)。
- 由于与其他[合并请求批准设置](../merge_requests/approvals/settings.md)冲突，没有符合条件的代码所有者可以批准该合并请求。

<a id="user-not-shown-as-possible-approver"></a>

## 用户未显示为可能的批准者

在以下任一条件下，用户可能不会在代码所有者合并请求批准规则中显示为批准者：

- 某条规则阻止该特定用户批准合并请求。请检查项目的[合并请求批准](../merge_requests/approvals/settings.md#edit-merge-request-approval-settings)设置。
- 代码所有者群组的可见性为私有，且当前用户不是该代码所有者群组的成员。
- 特定用户名拼写错误或在 `CODEOWNERS` 文件中[格式不正确](advanced.md#malformed-owners)。
- 当前用户是外部用户，没有访问内部代码所有者群组的权限。

<a id="approval-rule-is-invalid"></a>

## 批准规则无效

您可能会遇到如下错误信息：

```plaintext
批准规则无效。
极狐GitLab 已自动批准此规则以解除合并请求的阻塞。
```

当批准规则使用的代码所有者不是项目的直接成员时，会出现此问题。

解决方法是检查该群组或用户是否已被邀请加入项目。

<a id="codeowners-not-updated-when-user-or-group-names-change"></a>

## 当用户或群组名称更改时 `CODEOWNERS` 未更新

当用户或群组更改名称时，`CODEOWNERS` 不会自动更新为新名称。要输入新名称，您必须编辑该文件。

使用 SAML SSO 的组织可以[设置用户名](../../../integration/saml.md#set-a-username)，以防止用户更改其用户名。

<a id="incompatibility-with-global-group-memberships-locks"></a>

## 与全局群组成员锁定不兼容

代码所有者功能要求群组直接成为项目成员。启用全局群组成员锁定后，会阻止将群组作为直接成员邀请到项目中，导致这两个功能不兼容。

当启用了全局 [SAML](../../group/saml_sso/group_sync.md#global-saml-group-memberships-lock) 或 [LDAP](../../../administration/auth/ldap/ldap_synchronization.md#global-ldap-group-memberships-lock) 群组成员锁定时，您不能使用群组或子群组作为代码所有者。

如果启用了全局 SAML 或 LDAP 群组成员锁定，您有以下选项：

- 使用单个用户而不是群组作为代码所有者。
- 如果基于群组的代码所有者优先级更高，则禁用全局群组成员锁定。