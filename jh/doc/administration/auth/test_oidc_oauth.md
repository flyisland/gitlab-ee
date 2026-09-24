---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在极狐GitLab 中测试 OIDC/OAuth
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要在极狐GitLab 中测试 OIDC/OAuth，您必须：

1. [在极狐GitLab 中启用 OIDC/OAuth](#enable-oidcoauth-in-gitlab)
1. [使用客户端应用程序测试 OIDC/OAuth](#test-oidcoauth-with-your-client-application)
1. [验证 OIDC/OAuth 认证](#verify-oidcoauth-authentication)

<a id="prerequisites"></a>

## 前提条件

在极狐GitLab 上测试 OIDC/OAuth 之前，您必须：

- 拥有一个可公开访问的实例。
- 是该实例的管理员。
- 拥有一个想要用来测试 OIDC/OAuth 的客户端应用程序。

<a id="enable-oidcoauth-in-gitlab"></a>

## 在极狐GitLab 中启用 OIDC/OAuth

首先，您必须在您的极狐GitLab 实例上创建 OIDC/OAuth 应用程序。操作步骤如下：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **应用**。
1. 选择 **添加新应用**。
1. 填写客户端应用程序的详细信息，包括名称、重定向 URI 和允许的范围。
1. 确保启用了 `openid` 范围。
1. 选择 **保存应用** 以创建新的 OAuth 应用程序。

<a id="test-oidcoauth-with-your-client-application"></a>

## 使用客户端应用程序测试 OIDC/OAuth

在极狐GitLab 中创建 OAuth 应用程序后，您可以使用它来测试 OIDC/OAuth：

1. 您可以使用 <https://openidconnect.net> 作为 OIDC/OAuth 测试平台。
1. 退出极狐GitLab 登录。
1. 访问您的客户端应用程序，并使用上一步中创建的极狐GitLab OAuth 应用程序来启动 OIDC/OAuth 流程。
1. 按照提示登录极狐GitLab，并授权客户端应用程序访问您的极狐GitLab 账户。
1. 完成 OIDC/OAuth 流程后，您的客户端应用程序应该已收到一个访问令牌，可用其对极狐GitLab 进行身份认证。

<a id="verify-oidcoauth-authentication"></a>

## 验证 OIDC/OAuth 认证

要验证 OIDC/OAuth 认证在极狐GitLab 上是否正确工作，您可以执行以下检查：

1. 检查上一步中收到的访问令牌是否有效，并且可以用于向极狐GitLab 进行身份认证。您可以通过向极狐GitLab 发起测试 API 请求，并使用该访问令牌进行认证来实现。例如：

   ```shell
   curl --header "Authorization: Bearer <access_token>" https://mygitlabinstance.com/api/v4/user
   ```

   将 `<access_token>` 替换为您在上一步中实际收到的访问令牌。如果 API 请求成功并返回已认证用户的信息，则表明 OIDC/OAuth 认证工作正常。

1. 检查您在 OAuth 应用程序中指定的范围是否被正确执行。您可以发起需要特定范围的 API 请求，并检查它们是否按预期成功或失败。

就是这样！通过这些步骤，您应该能够使用客户端应用程序在您的极狐GitLab 实例上测试 OIDC/OAuth 认证。

