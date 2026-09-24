---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将你的极狐GitLab 服务器与 Bitbucket Cloud 集成
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

你可以将 Bitbucket.org 设置为 OAuth 2.0 提供商，以便使用你的 Bitbucket.org 帐户凭证登录极狐GitLab。你也可以从 Bitbucket.org 导入你的项目。

- 要将 Bitbucket.org 用作 OmniAuth 提供商，请按照 [Bitbucket OmniAuth 提供商](#use-bitbucket-as-an-oauth-20-authentication-provider) 部分的说明操作。
- 要从 Bitbucket 导入项目，请同时按照 [Bitbucket OmniAuth 提供商](#use-bitbucket-as-an-oauth-20-authentication-provider) 和 [Bitbucket 项目导入](#bitbucket-project-import) 部分的说明操作。

<a id="use-bitbucket-as-an-oauth-20-authentication-provider"></a>

## 使用 Bitbucket 作为 OAuth 2.0 认证提供商

要启用 Bitbucket OmniAuth 提供商，你必须向 Bitbucket.org 注册你的应用程序。Bitbucket 会为你生成应用程序 ID 和密钥以供使用。

1. 登录 [Bitbucket.org](https://bitbucket.org)。
1. 根据你想要注册应用程序的方式，转到你的个人用户设置（**Bitbucket 设置**）或团队设置（**管理团队**）。应用程序是以个人还是团队身份注册无关紧要，这可完全由你决定。
1. 在左侧菜单的 **访问管理** 下，选择 **OAuth**。
1. 选择 **添加消费者**。
1. 提供所需的详细信息：

   - **名称**：可任意设置。可考虑诸如 `<Organization>'的极狐GitLab` 或 `<Your Name>'的极狐GitLab` 等描述性名称。
   - **应用程序描述**：可选。如果需要，可填写此项。
   - **回调 URL**：（在极狐GitLab 8.15 及更高版本中为必填项）
     你的极狐GitLab 安装的 URL，例如 `https://gitlab.example.com/users/auth`。如果将此字段留空，会出现 `Invalid redirect_uri` 消息。

     > [!warning]
     > 为帮助防止 [OAuth 2 隐蔽重定向](https://oauth.net/advisories/2014-1-covert-redirect/) 攻击，请将 `/users/auth` 附加到你的 Bitbucket 授权回调 URL 的末尾。你必须包含此授权端点才能使用 Bitbucket 进行身份验证并导入 Bitbucket 仓库中的数据。

   - **URL**：你的极狐GitLab 安装的 URL，例如 `https://gitlab.example.com`。

1. 至少授予以下权限：

   - **帐户**：`Email`、`Read`
   - **项目**：`Read`
   - **仓库**：`Read`
   - **合并请求**：`Read`
   - **议题**：`Read`
   - **维基**：`Read and write`

1. 选择 **保存**。
1. 选择新创建的 OAuth 消费者，现在你应该会在 OAuth 消费者列表中看到一个 **密钥** 和一个 **密钥**。继续配置时请保持此页面打开。
1. 在你的极狐GitLab 服务器上，打开配置文件：

   ```shell
   # 对于 Omnibus 软件包
   sudo editor /etc/gitlab/gitlab.rb

   # 对于从源代码安装
   sudo -u git -H editor /home/git/gitlab/config/gitlab.yml
   ```

1. 添加 Bitbucket 提供商配置：

   对于 Linux 软件包安装：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "bitbucket",
       # label: "提供商名称", # 登录按钮的可选标签，默认值为 "Bitbucket"
       app_id: "<bitbucket_app_key>",
       app_secret: "<bitbucket_app_secret>",
       url: "https://bitbucket.org/"
     }
   ]
   ```

   对于自行编译的安装：

   ```yaml
   omniauth:
     enabled: true
     providers:
       - { name: 'bitbucket',
           # label: '提供商名称', # 登录按钮的可选标签，默认值为 "Bitbucket"
           app_id: '<bitbucket_app_key>',
           app_secret: '<bitbucket_app_secret>',
           url: 'https://bitbucket.org/'
         }
   ```

   其中 `<bitbucket_app_key>` 是 Bitbucket 应用程序页面上的 **密钥**，`<bitbucket_app_secret>` 是 **密钥**。
1. 保存配置文件。
1. 要使更改生效，如果你使用 Linux 软件包安装，请[重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)；如果你自行编译安装，请[重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations)。

现在，在登录页面上，常规登录表单下方应该会出现一个 Bitbucket 图标。选择该图标以开始身份验证过程。Bitbucket 会要求用户登录并授权极狐GitLab 应用程序。如果成功，用户将返回到极狐GitLab 并登录。

> [!note]
> 对于多节点架构，必须将 Bitbucket 提供商配置也包含在 Sidekiq 节点上，才能导入项目。

<a id="bitbucket-project-import"></a>

## Bitbucket 项目导入

完成上述配置后，你可以使用 Bitbucket 登录极狐GitLab 并[开始导入你的项目](../user/import/bitbucket_cloud.md)。

如果你想从 Bitbucket 导入项目，但不希望启用登录功能，你可以[在 **管理员** 区域禁用登录](omniauth.md#enable-or-disable-sign-in-with-an-omniauth-provider-without-disabling-import-sources)。