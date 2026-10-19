---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Google OAuth 2.0 作为 OAuth 2.0 身份验证提供商
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要启用 Google OAuth 2.0 OmniAuth 提供商，您必须在 Google 注册您的应用程序。
Google 会生成一个客户端 ID 和密钥供您使用。

要启用 Google OAuth，您必须配置：

- Google Cloud Resource Manager
- Google API Console
- 极狐GitLab 服务器

<a id="configure-the-google-cloud-resource-manager"></a>

## 配置 Google Cloud Resource Manager

1. 转到 [Google Cloud Resource Manager](https://console.cloud.google.com/cloud-resource-manager)。
1. 选择 **创建项目**。
1. 在 **项目名称**中，输入 `GitLab`。
1. 在 **项目 ID**中，Google 默认提供一个随机生成的项目 ID。
   您可以使用这个随机生成的 ID，也可以创建一个新的 ID。如果您创建新的
   ID，它必须在所有 Google 开发者注册的应用程序中唯一。

要在此列表中看到您的新项目，请刷新页面。

<a id="configure-the-google-api-console"></a>

## 配置 Google API Console

1. 转到 [Google API Console](https://console.developers.google.com/apis/dashboard)。
1. 在左上角，选择您之前创建的项目。
1. 选择 **OAuth 同意屏幕** 并填写各字段。
1. 选择 **凭据** > **创建凭据** > **OAuth 客户端 ID**。
1. 填写各字段：
   - **应用类型**：选择 **Web 应用**。
   - **名称**：使用默认名称或输入您自己的名称。
   - **已获授权的 JavaScript 来源**：输入 `https://gitlab.example.com`。
   - **已获授权的重定向 URI**：输入您的域名，后跟回调 URI，一次输入一个：

     ```plaintext
     https://gitlab.example.com/users/auth/google_oauth2/callback
     https://gitlab.example.com/-/google_api/auth/callback
     ```

1. 您应该会看到一个客户端 ID 和客户端密钥。请记下它们，或保持此页面打开，因为稍后需要用到。
1. 要允许项目访问 [Google Kubernetes Engine](../user/infrastructure/clusters/_index.md)，
   您还必须启用：
   - Google Kubernetes Engine API
   - Cloud Resource Manager API
   - Cloud Billing API

   为此：

   1. 转到 [Google API Console](https://console.developers.google.com/apis/dashboard)。
   1. 选择页面顶部的 **ENABLE APIS AND SERVICES**。
   1. 找到前面提到的每个 API。在 API 的页面上，选择 **ENABLE**。
      API 可能需要几分钟才能完全生效。

<a id="configure-the-gitlab-server"></a>

## 配置极狐GitLab 服务器

1. 打开配置文件。

   对于 Linux 软件包安装：

   ```shell
   sudo editor /etc/gitlab/gitlab.rb
   ```

   对于自行编译安装：

   ```shell
   cd /home/git/gitlab
   sudo -u git -H editor config/gitlab.yml
   ```

1. 配置[通用设置](omniauth.md#configure-common-settings)
   以添加 `google_oauth2` 作为单点登录提供商。这将为没有现有极狐GitLab 账号的用户启用即时账号预配。
1. 添加提供商配置。

   对于 Linux 软件包安装：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "google_oauth2",
       # label: "Provider name", # optional label for login button, defaults to "Google"
       app_id: "<YOUR_APP_ID>",
       app_secret: "<YOUR_APP_SECRET>",
       args: { access_type: "offline", approval_prompt: "" }
     }
   ]
   ```

   对于自行编译安装：

   ```yaml
   - { name: 'google_oauth2',
       # label: 'Provider name', # optional label for login button, defaults to "Google"
       app_id: 'YOUR_APP_ID',
       app_secret: 'YOUR_APP_SECRET',
       args: { access_type: 'offline', approval_prompt: '' } }
   ```

1. 将 `<YOUR_APP_ID>` 替换为 Google 开发者页面中的客户端 ID。
1. 将 `<YOUR_APP_SECRET>` 替换为 Google 开发者页面中的客户端密钥。
1. 确保将极狐GitLab 配置为使用完全限定域名，因为
   Google 不接受原始 IP 地址。

   对于 Linux 软件包安装：

   ```ruby
   external_url 'https://gitlab.example.com'
   ```

   对于自行编译安装：

   ```yaml
   gitlab:
     host: https://gitlab.example.com
   ```

1. 保存配置文件。
1. 要使更改生效：
   - 如果您使用 Linux 软件包安装，请[重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)。
   - 如果您自行编译安装，请[重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations)。

现在，登录页面上常规登录表单下方应该会显示一个 Google 图标。选择该图标以开始身份验证过程。Google 会要求用户登录并授权极狐GitLab 应用程序。如果一切顺利，用户将返回极狐GitLab 并完成登录。
