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

1. [启用 OIDC/OAuth](#enable-oidcoauth-in-gitlab)
1. [使用您的客户端应用程序测试 OIDC/OAuth](#test-oidcoauth-with-your-client-application)
1. [验证 OIDC/OAuth 身份验证](#verify-oidcoauth-authentication)

<a id="prerequisites"></a>

## 先决条件

在极狐GitLab 上测试 OIDC/OAuth 之前，您必须：

- 拥有一个可公开访问的实例。
- 是该实例的管理员。
- 拥有一个要用于测试 OIDC/OAuth 的客户端应用程序。

<a id="enable-oidcoauth-in-gitlab"></a>

## 在极狐GitLab 中启用 OIDC/OAuth

首先，您必须在极狐GitLab 实例上创建一个 OIDC/OAuth 应用程序。为此：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**应用**。
1. 选择**新建应用**。
1. 填写客户端应用程序的详细信息，包括名称、重定向 URI 和允许的范围。
1. 确保已启用 `openid` 范围。
1. 选择**保存应用**以创建新的 OAuth 应用程序。

<a id="test-oidcoauth-with-your-client-application"></a>

## 使用您的客户端应用程序测试 OIDC/OAuth

在极狐GitLab 中创建 OAuth 应用程序后，您可以使用它来测试 OIDC/OAuth：

1. 您可以使用 <https://openidconnect.net> 作为 OIDC/OAuth 演练场。
1. 退出极狐GitLab。
1. 访问您的客户端应用程序，并使用上一步中创建的极狐GitLab OAuth 应用程序发起 OIDC/OAuth 流程。
1. 按照提示登录极狐GitLab，并授权该客户端应用程序访问您的极狐GitLab 账号。
1. 完成 OIDC/OAuth 流程后，您的客户端应用程序应已收到一个访问令牌，可用于向极狐GitLab 进行身份验证。

<a id="verify-oidcoauth-authentication"></a>

## 验证 OIDC/OAuth 身份验证

要验证 OIDC/OAuth 身份验证在极狐GitLab 上是否正常工作，您可以执行以下检查：

1. 检查上一步中收到的访问令牌是否有效，以及是否可用于向极狐GitLab 进行身份验证。您可以通过向极狐GitLab 发起测试 API 请求，并使用该访问令牌进行身份验证来完成此操作。例如：

   ```shell
   curl --header "Authorization: Bearer <access_token>" https://mygitlabinstance.com/api/v4/user
   ```

   将 `<access_token>` 替换为上一步中收到的实际访问令牌。如果 API 请求成功并返回已通过身份验证的用户信息，则说明 OIDC/OAuth 身份验证工作正常。

1. 检查您在 OAuth 应用程序中指定的范围是否被正确强制执行。您可以通过发起需要特定范围的 API 请求，并检查它们是否按预期成功或失败来完成此操作。

就是这样！通过上述步骤，您应该能够使用客户端应用程序在极狐GitLab 实例上测试 OIDC/OAuth 身份验证。
