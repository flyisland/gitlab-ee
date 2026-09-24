---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 AWS Cognito 作为 OAuth 2.0 身份验证提供者
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Amazon Web Services (AWS) Cognito 允许您让新用户创建账户、登录并访问您的极狐GitLab 实例。
以下文档介绍了如何将 AWS Cognito 启用为 OAuth 2.0 提供者。

<a id="configure-aws-cognito"></a>

## 配置 AWS Cognito

要将 [AWS Cognito](https://aws.amazon.com/cognito/) OAuth 2.0 OmniAuth 提供者启用，请在 Cognito 中注册您的应用程序。此过程会为您的应用程序生成客户端 ID 和客户端密钥。
要启用 AWS Cognito 作为身份验证提供者，请完成以下步骤。您可以稍后修改任何已配置的设置。

1. 登录 [AWS 控制台](https://console.aws.amazon.com/console/home)。
1. 从 **服务** 菜单中选择 **Cognito**。
1. 选择 **管理用户池**，然后在右上角选择 **创建用户池**。
1. 输入用户池名称，然后选择 **逐步设置**。
1. 在 **您希望您的最终用户如何登录？** 下，选择 **电子邮件地址或电话号码** 和 **允许电子邮件地址**。
1. 在 **您想要求哪些标准属性？** 下，选择 **电子邮件**。
1. 根据您的需求配置其余设置。在基本设置中，这些设置不会影响极狐GitLab 配置。
1. 在 **应用客户端** 设置中：
   1. 选择 **添加应用客户端**。
   1. 添加 **应用客户端名称**。
   1. 选中 **启用基于用户名/密码的身份验证** 复选框。
1. 选择 **创建应用客户端**。
1. 设置用于发送电子邮件的 AWS Lambda 函数并完成用户池的创建。
1. 创建用户池后，前往 **应用客户端设置** 并提供所需信息：

   - **启用的身份提供商** - 选择全部
   - **回调 URL** - `https://<your_gitlab_instance_url>/users/auth/cognito/callback`
   - **允许的 OAuth 流程** - 授权码授予
   - **允许的 OAuth 2.0 范围** - `email`、`openid` 和 `profile`

1. 保存应用客户端设置的更改。
1. 在 **域名** 下，提供您的 AWS Cognito 应用程序的 AWS 域名。
1. 在 **应用客户端** 下，找到您的应用客户端 ID。选择 **显示详细信息** 以显示应用客户端密钥。这些值对应于 OAuth 2.0 客户端 ID 和客户端密钥。请保存这些值。

<a id="configure-gitlab"></a>

## 配置极狐GitLab

1. 配置 [通用设置](../../integration/omniauth.md#configure-common-settings)
   以将 `cognito` 添加为单点登录提供者。这可为尚无极狐GitLab 账户的用户启用即时账户创建。
1. 在您的极狐GitLab 服务器上，打开配置文件。对于 Linux 软件包安装：

   ```shell
   sudo editor /etc/gitlab/gitlab.rb
   ```

1. 在以下代码块中，在对应参数中输入您的 AWS Cognito 应用程序信息：

   - `app_id`：您的客户端 ID。
   - `app_secret`：您的客户端密钥。
   - `site`：您的 Amazon 域和区域。

   将以下代码块包含在 `/etc/gitlab/gitlab.rb` 文件中：

   ```ruby
   gitlab_rails['omniauth_allow_single_sign_on'] = ['cognito']
   gitlab_rails['omniauth_providers'] = [
     {
       name: "cognito",
       label: "Provider name", # 登录按钮的可选标签，默认为 "Cognito"
       icon: nil,   # 可选的图标 URL
       app_id: "<client_id>",
       app_secret: "<client_secret>",
       args: {
         scope: "openid profile email",
         client_options: {
           site: "https://<your_domain>.auth.<your_region>.amazoncognito.com",
           authorize_url: "/oauth2/authorize",
           token_url: "/oauth2/token",
           user_info_url: "/oauth2/userInfo"
         },
         user_response_structure: {
           root_path: [],
           id_path: ["sub"],
           attributes: { nickname: "email", name: "email", email: "email" }
         },
         name: "cognito",
         strategy_class: "OmniAuth::Strategies::OAuth2Generic"
       }
     }
   ]
   ```

1. 保存配置文件。
1. 保存文件并 [重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation) 极狐GitLab 以使更改生效。

您的登录页面现在应在常规登录表单下方显示一个 Cognito 选项。
选择此选项即可开始身份验证过程。
AWS Cognito 随后会要求您登录并授权极狐GitLab 应用程序。
如果授权成功，您将被重定向并登录到您的极狐GitLab 实例。

更多信息，请参见 [配置通用设置](../../integration/omniauth.md#configure-common-settings)。