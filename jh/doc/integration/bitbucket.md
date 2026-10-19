---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将您的极狐GitLab 服务器与 Bitbucket Cloud 集成
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以将 Bitbucket.org 设置为 OAuth 2.0 提供商，使用您的 Bitbucket.org 账号凭据登录极狐GitLab。您还可以从 Bitbucket.org 导入项目。

- 要将 Bitbucket.org 用作 OmniAuth 提供商，请遵循
  [Bitbucket OmniAuth 提供商](#use-bitbucket-as-an-oauth-20-authentication-provider)部分。
- 要从 Bitbucket 导入项目，请同时遵循
  [Bitbucket OmniAuth 提供商](#use-bitbucket-as-an-oauth-20-authentication-provider)和
  [Bitbucket 项目导入](#bitbucket-project-import)部分。

<a id="use-bitbucket-as-an-oauth-20-authentication-provider"></a>

## 将 Bitbucket 用作 OAuth 2.0 身份验证提供商

要启用 Bitbucket OmniAuth 提供商，您必须在 Bitbucket.org 上注册您的应用程序。Bitbucket 会为您生成应用程序 ID 和密钥，供您使用。

1. 登录 [Bitbucket.org](https://bitbucket.org)。
1. 前往您的个人用户设置（**Bitbucket 设置**）或团队设置（**管理团队**），具体取决于您希望如何注册该应用程序。以个人或团队身份注册应用程序均可。
1. 在左侧菜单的 **访问管理** 下，选择 **OAuth**。
1. 选择 **添加消费者**。
1. 提供所需详细信息：

   - **名称**：可以是任意名称。可以考虑类似 `<Organization>'s GitLab`
     或 `<Your Name>'s GitLab` 或其他具有描述性的名称。
   - **应用程序描述**：可选。如有需要可填写。
   - **回调 URL**：（必填）
     输入以下两个 URL，并将 `gitlab.example.com` 替换为您的
     极狐GitLab 安装的 URL：

     - 使用 Bitbucket 登录：`https://gitlab.example.com/users/auth/bitbucket/callback`
     - 从 Bitbucket 导入项目：`https://gitlab.example.com/users/auth/-/import/bitbucket/callback`

     将此字段留空会导致出现 `Invalid redirect_uri` 消息。

     > [!warning]
     > 为帮助防止 [OAuth 2 隐蔽重定向](https://oauth.net/advisories/2014-1-covert-redirect/)
     > 攻击，请输入完整的回调 URL，包括 `/bitbucket/callback` 和
     > `/-/import/bitbucket/callback` 端点。

   - **URL**：您的极狐GitLab 安装的 URL，例如 `https://gitlab.example.com`。

1. 至少授予以下权限：

   - **账号**：`Email`、`Read`
   - **项目**：`Read`
   - **仓库**：`Read`
   - **拉取请求**：`Read`
   - **议题**：`Read`
   - **Wiki**：`Read and write`

1. 选择 **保存**。
1. 选择您新建的 OAuth 消费者，此时您应该会在 OAuth 消费者列表中看到 **键** 和
   **密钥**。在继续配置时请保持此页面打开。
1. 在您的极狐GitLab 服务器上，打开配置文件：

   ```shell
   # For Omnibus packages
   sudo editor /etc/gitlab/gitlab.rb

   # For installations from source
   sudo -u git -H editor /home/git/gitlab/config/gitlab.yml
   ```

1. 添加 Bitbucket 提供商配置：

   对于 Linux 软件包安装：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "bitbucket",
       # label: "Provider name", # optional label for login button, defaults to "Bitbucket"
       app_id: "<bitbucket_app_key>",
       app_secret: "<bitbucket_app_secret>",
       url: "https://bitbucket.org/"
     }
   ]
   ```

   对于自行编译安装：

   ```yaml
   omniauth:
     enabled: true
     providers:
       - { name: 'bitbucket',
           # label: 'Provider name', # optional label for login button, defaults to "Bitbucket"
           app_id: '<bitbucket_app_key>',
           app_secret: '<bitbucket_app_secret>',
           url: 'https://bitbucket.org/'
         }
   ```

   其中 `<bitbucket_app_key>` 是 Bitbucket 应用程序页面中的 **键**，`<bitbucket_app_secret>` 是 **密钥**。
1. 保存配置文件。
1. 要使更改生效，如果您使用 Linux 软件包安装，请[重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)；
   如果您是自行编译安装，请[重启](../administration/restart_gitlab.md#self-compiled-installations)。

现在，登录页面的常规登录表单下方应该会显示一个 Bitbucket 图标。选择该图标以开始身份验证流程。Bitbucket 会要求用户登录并授权极狐GitLab 应用程序。如果成功，用户将返回极狐GitLab 并完成登录。

> [!note]
> 对于多节点架构，Bitbucket 提供商配置还必须包含在 Sidekiq 节点上，以便能够导入项目。

<a id="bitbucket-project-import"></a>

## Bitbucket 项目导入

完成上述配置后，您可以使用 Bitbucket 登录极狐GitLab 并[开始导入您的项目](../user/import/bitbucket_cloud.md)。

如果您想从 Bitbucket 导入项目，但不想启用登录，您可以[在**管理**区域中禁用登录](omniauth.md#enable-or-disable-sign-in-with-an-omniauth-provider-without-disabling-import-sources)。
