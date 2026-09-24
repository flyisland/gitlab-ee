---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Google OAuth 2.0 作为 OAuth 2.0 认证提供者
---

{{< details >}}

- Tier: 基础版、专业版、旗舰版
- Offering: 私有化部署

{{< /details >}}

要启用 Google OAuth 2.0 OmniAuth 提供者，您必须向 Google 注册您的应用程序。Google 会生成一个客户端 ID 和密钥供您使用。

要启用 Google OAuth，您需要配置以下内容：

- Google Cloud Resource Manager
- Google API Console
- 极狐GitLab 服务器

<a id="configure-the-google-cloud-resource-manager"></a>

## 配置 Google Cloud Resource Manager

1. 访问 [Google Cloud Resource Manager](https://console.cloud.google.com/cloud-resource-manager)。
1. 选择 **CREATE PROJECT**。
1. 在 **Project name** 中，输入 `GitLab`。
1. 在 **Project ID** 中，Google 默认会提供一个随机生成的项目 ID。您可以使用这个随机生成的 ID 或创建一个新的 ID。如果创建新的 ID，它必须在所有 Google Developer 注册的应用程序中唯一。

刷新页面，即可在列表中看到您的新项目。

<a id="configure-the-google-api-console"></a>

## 配置 Google API Console

1. 访问 [Google API Console](https://console.developers.google.com/apis/dashboard)。
1. 在左上角，选择您之前创建的项目。
1. 选择 **OAuth consent screen** 并填写相应字段。
1. 选择 **Credentials** > **Create credentials** > **OAuth client ID**。
1. 填写以下字段：
   - **Application type**：选择 **Web application**。
   - **Name**：使用默认名称或输入您自己的名称。
   - **Authorized JavaScript origins**：输入 `https://gitlab.example.com`。
   - **Authorized redirect URIs**：输入您的域名，后跟回调 URI，每次输入一个：

     ```plaintext
     https://gitlab.example.com/users/auth/google_oauth2/callback
     https://gitlab.example.com/-/google_api/auth/callback
     ```

1. 您应该会看到客户端 ID 和客户端密钥。请记下它们，或保持此页面打开，因为稍后会用到。
1. 要使项目能够访问 [Google Kubernetes Engine](../user/infrastructure/clusters/_index.md)，您还必须启用以下 API：
   - Google Kubernetes Engine API
   - Cloud Resource Manager API
   - Cloud Billing API

   具体步骤如下：

   1. 访问 [Google API Console](https://console.developers.google.com/apis/dashboard)。
   1. 在页面顶部选择 **ENABLE APIS AND SERVICES**。
   1. 找到前面提到的每个 API。在每个 API 页面上，选择 **ENABLE**。API 完全生效可能需要几分钟时间。

<a id="configure-the-gitlab-server"></a>

## 配置极狐GitLab 服务器

1. 打开配置文件。

   对于 Linux 软件包安装：

   ```shell
   sudo editor /etc/gitlab/gitlab.rb
   ```

   对于自行编译的安装：

   ```shell
   cd /home/git/gitlab
   sudo -u git -H editor config/gitlab.yml
   ```

1. 配置[通用设置](omniauth.md#configure-common-settings)，将 `google_oauth2` 添加为单点登录提供者。这将为尚无极狐GitLab 账户的用户启用即时账户供应。
1. 添加提供者配置。

   对于 Linux 软件包安装：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "google_oauth2",
       # label: "提供者名称", # 登录按钮的可选标签，默认为 "Google"
       app_id: "<YOUR_APP_ID>",
       app_secret: "<YOUR_APP_SECRET>",
       args: { access_type: "offline", approval_prompt: "" }
     }
   ]
   ```

   对于自行编译的安装：

   ```yaml
   - { name: 'google_oauth2',
       # label: '提供者名称', # 登录按钮的可选标签，默认为 "Google"
       app_id: 'YOUR_APP_ID',
       app_secret: 'YOUR_APP_SECRET',
       args: { access_type: 'offline', approval_prompt: '' } }
   ```

1. 将 `<YOUR_APP_ID>` 替换为 Google 开发者页面中的客户端 ID。
1. 将 `<YOUR_APP_SECRET>` 替换为 Google 开发者页面中的客户端密钥。
1. 确保将极狐GitLab 配置为使用完全限定域名，因为 Google 不接受原始 IP 地址。

   对于 Linux 软件包安装：

   ```ruby
   external_url 'https://gitlab.example.com'
   ```

   对于自行编译的安装：

   ```yaml
   gitlab:
     host: https://gitlab.example.com
   ```

1. 保存配置文件。
1. 为使更改生效：
   - 如果您使用 Linux 软件包安装，请[重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)。
   - 如果您是自行编译安装，请[重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations)。

在登录页面，常规登录表单下方现在应该会显示一个 Google 图标。选择该图标即可开始认证过程。Google 会要求用户登录并授权极狐GitLab 应用程序。如果一切顺利，用户将被返回至极狐GitLab 并登录成功。