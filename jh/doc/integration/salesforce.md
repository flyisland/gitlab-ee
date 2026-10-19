---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: 使用 Salesforce 作为 OAuth 2.0 身份验证提供商
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以将极狐GitLab 实例与 [Salesforce](https://www.salesforce.com/) 集成，使用户能够使用其 Salesforce 账号登录您的极狐GitLab 实例。

<a id="create-a-salesforce-connected-app"></a>

## 创建 Salesforce 连接应用

要启用 Salesforce OmniAuth 提供商，您必须为极狐GitLab 实例使用 Salesforce 凭据。
要获取凭据（一对客户端 ID 和客户端密钥），您必须在 Salesforce 上[创建连接应用](https://help.salesforce.com/s/articleView?language=en_US&id=sf.connected_app_create.htm&type=5)。

1. 登录 [Salesforce](https://login.salesforce.com/)。
1. 在设置中，在快速查找框中输入 `App Manager`，选择 **应用管理器**，然后选择 **新建连接应用**。
1. 在以下字段中填写应用详情：
   - **连接应用名称** 和 **API 名称**：可设置为任意值，但建议使用类似 `<Organization>'s GitLab`、`<Your Name>'s GitLab` 或其他具有描述性的名称。
   - **联系电子邮件**：输入 Salesforce 在联系您或您的支持团队时使用的联系邮箱。
   - **描述**：应用的描述。

   ![Salesforce 应用详情](img/salesforce_app_details_v11_11.png)
1. 选择 **API（启用 OAuth 设置）**，然后选择 **启用 OAuth 设置**。
1. 在以下字段中填写应用详情：
   - **回调 URL**：您极狐GitLab 安装实例的回调 URL。例如，`https://gitlab.example.com/users/auth/salesforce/callback`。
   - **选定的 OAuth 范围**：将 `Access your basic information (id, profile, email, address, phone)` 和 `Allow access to your unique identifier (openid)` 移到右侧列。

   ![Salesforce OAuth 应用详情](img/salesforce_oauth_app_details_v11_11.png)
1. 选择 **保存**。
1. 在您的极狐GitLab 服务器上，打开配置文件。

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
   以将 `salesforce` 添加为单点登录提供商。这将为没有现有极狐GitLab 账号的用户启用即时
   账号预配。
1. 添加提供商配置。
   对于 Linux 软件包安装：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "salesforce",
       # label: "Provider name", # optional label for login button, defaults to "Salesforce"
       app_id: "SALESFORCE_CLIENT_ID",
       app_secret: "SALESFORCE_CLIENT_SECRET"
     }
   ]
   ```

   对于自行编译安装：

   ```yaml
   - { name: 'salesforce',
       # label: 'Provider name', # optional label for login button, defaults to "Salesforce"
       app_id: 'SALESFORCE_CLIENT_ID',
       app_secret: 'SALESFORCE_CLIENT_SECRET'
   }
   ```

1. 将 `SALESFORCE_CLIENT_ID` 更改为 Salesforce 连接应用页面中的客户端 ID（Consumer Key）。
1. 将 `SALESFORCE_CLIENT_SECRET` 更改为 Salesforce 连接应用页面中的客户端密钥（Consumer Secret）。

   ![Salesforce 应用密钥详情](img/salesforce_app_secret_details_v11_11.png)
1. 保存配置文件。
1. 要使更改生效：
   - 如果您使用 Linux 软件包安装，请[重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)。
   - 如果您自行编译安装，请[重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations)。

在登录页面上，常规登录表单下方现在应显示一个 Salesforce 图标。选择该图标以开始身份验证流程。Salesforce 会要求用户登录并授权极狐GitLab 应用。如果一切顺利，用户将返回极狐GitLab 并完成登录。

> [!note]
> 极狐GitLab 需要每个新用户的邮箱地址。用户使用 Salesforce
> 登录后，极狐GitLab 会将用户重定向到个人资料页面，用户必须在该页面
> 提供邮箱并验证邮箱。
