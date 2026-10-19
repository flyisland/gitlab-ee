---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 将极狐GitLab 与 Beyond Identity 集成，以验证添加到用户账号的 GPG 密钥。
title: Beyond Identity
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在极狐GitLab 中，用户可以在[向其个人资料添加 GPG 密钥](../repository/signed_commits/gpg.md)后对提交进行签名。
极狐GitLab 与 [Beyond Identity](https://www.beyondidentity.com/)的集成扩展了此功能。

配置后，此集成会使用 Beyond Identity 验证用户添加到其个人资料的任何新 GPG 密钥。未通过验证的密钥会被拒绝，用户必须上传新密钥。

当用户将已签名的提交推送到极狐GitLab 实例时，极狐GitLab 会运行 预接收检查，根据用户个人资料中存储的 GPG 密钥验证这些提交。这确保只有使用已验证密钥签名的提交才会被接受。

<a id="set-up-the-beyond-identity-integration-for-your-instance"></a>

## 为您的实例设置 Beyond Identity 集成

先决条件：

- 您必须拥有极狐GitLab 实例的管理员访问权限。
- 极狐GitLab 个人资料中使用的电子邮件地址必须与 Beyond Identity Authenticator 中分配给该密钥的电子邮件地址相同。
- 您必须拥有 Beyond Identity API 令牌。您可以向其销售工程师索取。

要为您的实例启用 Beyond Identity 集成：

1. 以管理员身份登录极狐GitLab。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Beyond Identity**。
1. 在**启用集成**下，选中**活跃**复选框。
1. 在 **API 令牌**中，粘贴您从 Beyond Identity 收到的 API 令牌。
1. 选择**保存更改**。

您的实例的 Beyond Identity 集成现已启用。

<a id="gpg-key-verification"></a>

## GPG 密钥验证

当用户向其个人资料添加 GPG 密钥时，该密钥会被验证：

- 如果该密钥不是由 Beyond Identity Authenticator 签发的，则会被接受。
- 如果该密钥是由 Beyond Identity Authenticator 签发的，但该密钥无效，则会被拒绝。
  例如：用户在极狐GitLab 个人资料中使用的电子邮件地址与 Beyond Identity Authenticator 中分配给该密钥的电子邮件地址不同。

当用户推送提交时，极狐GitLab 会检查该提交是否由上传到用户个人资料的 GPG 签名所签名。如果无法验证该签名，则推送会被拒绝。Web 提交无需签名即可被接受。

<a id="skip-push-check-for-service-accounts"></a>

## 跳过服务账号的推送检查

先决条件：

- 您必须拥有极狐GitLab 实例的管理员访问权限。

要跳过[服务账号](../../profile/service_accounts.md)的推送检查：

1. 以管理员身份登录极狐GitLab。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Beyond Identity**。
1. 选中**排除服务账号**复选框。
1. 选择**保存更改**。

<a id="exclude-groups-or-projects-from-the-beyond-identity-check"></a>

## 从 Beyond Identity 检查中排除群组或项目

先决条件：

- 您必须拥有极狐GitLab 实例的管理员访问权限。

要从 Beyond Identity 检查中排除群组或项目：

1. 以管理员身份登录极狐GitLab。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Beyond Identity**。
1. 选择**排除项**标签页。
1. 选择**添加排除项**。
1. 在抽屉中，搜索并选择要排除的群组或项目。
1. 选择**添加排除项**。
