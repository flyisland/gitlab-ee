---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Integrate GitLab with Beyond Identity to verify GPG keys added to user accounts.
title: Beyond Identity
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.9 引入。

{{< /history >}}

在极狐GitLab中，用户可以在[将 GPG 密钥添加到其个人资料](../repository/signed_commits/gpg.md)后签名其提交。
极狐GitLab 与 [Beyond Identity](https://www.beyondidentity.com/) 的集成扩展了此功能。

配置后，此集成使用 Beyond Identity 验证用户添加到其个人资料的任何新 GPG 密钥。
未通过验证的密钥将被拒绝，用户必须上传新密钥。

当用户将签名的提交推送到极狐GitLab 实例时，极狐GitLab 会运行预接收检查，根据存储在用户个人资料中的 GPG 密钥来验证这些提交。
这确保只有使用已验证密钥签名的提交才会被接受。

<a id="set-up-the-beyond-identity-integration-for-your-instance"></a>

## 为您的实例设置 Beyond Identity 集成

先决条件：

- 您必须拥有极狐GitLab 实例的管理员访问权限。
- 极狐GitLab 个人资料中使用的电子邮件地址必须与 Beyond Identity Authenticator 中分配给密钥的电子邮件相同。
- 您必须拥有 Beyond Identity API 令牌。您可以从他们的销售工程师处申请。

要为您的实例启用 Beyond Identity 集成：

1. 以管理员身份登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Beyond Identity**。
1. 在 **启用集成** 下，勾选 **活跃** 复选框。
1. 在 **API 令牌**中，粘贴您从 Beyond Identity 收到的 API 令牌。
1. 选择 **保存更改**。

您的实例的 Beyond Identity 集成现已启用。

<a id="gpg-key-verification"></a>

## GPG 密钥验证

当用户将 GPG 密钥添加到其个人资料时，密钥会被验证：

- 如果密钥不是由 Beyond Identity Authenticator 签发的，则被接受。
- 如果密钥是由 Beyond Identity Authenticator 签发的，但密钥无效，则被拒绝。
  例如：用户在极狐GitLab 个人资料中使用的电子邮件与 Beyond Identity Authenticator 中分配给密钥的电子邮件不同。

当用户推送提交时，极狐GitLab 会检查该提交是否由上传到用户个人资料中的 GPG 签名所签名。
如果签名无法验证，则推送被拒绝。
Web 提交无需签名即可被接受。

<a id="skip-push-check-for-service-accounts"></a>

## 跳过服务账号的推送检查

{{< history >}}

- 在极狐GitLab 16.11 引入。

{{< /history >}}

先决条件：

- 您必须拥有极狐GitLab 实例的管理员访问权限。

要跳过[服务账号](../../profile/service_accounts.md)的推送检查：

1. 以管理员身份登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Beyond Identity**。
1. 勾选 **排除服务账号** 复选框。
1. 选择 **保存更改**。

<a id="exclude-groups-or-projects-from-the-beyond-identity-check"></a>

## 从 Beyond Identity 检查中排除群组或项目

{{< history >}}

- 在极狐GitLab 17.0 引入，带有名为 `beyond_identity_exclusions` 的功能标志。默认启用。
- 排除群组的选项在极狐GitLab 17.1 引入。
- 在极狐GitLab 17.7 中 GA，功能标志 `beyond_identity_exclusions` 被移除。

{{< /history >}}

先决条件：

- 您必须拥有极狐GitLab 实例的管理员访问权限。

要从 Beyond Identity 检查中排除群组或项目：

1. 以管理员身份登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Beyond Identity**。
1. 选择 **排除** 标签页。
1. 选择 **添加排除**。
1. 在抽屉中，搜索并选择要排除的群组或项目。
1. 选择 **添加排除**。