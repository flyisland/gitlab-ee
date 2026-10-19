---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用阿里云作为 OmniAuth 身份验证提供商
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以启用阿里云 OAuth 2.0 OmniAuth 提供商，并使用您的阿里云账号登录极狐GitLab。

<a id="create-an-alicloud-application"></a>

## 创建阿里云应用

登录阿里云平台并创建一个应用。阿里云会为您生成客户端 ID 和密钥，供您使用。

1. 登录[阿里云平台](https://account.aliyun.com/login/login.htm)。
1. 前往 [OAuth 应用管理页面](https://ram.console.aliyun.com/applications)。
1. 选择**创建应用**。
1. 填写应用详细信息：

   - **应用名称**：可以是任意内容。
   - **显示名称**：可以是任意内容。
   - **回调 URL**：此 URL 的格式应为 `'GitLab instance URL' + '/users/auth/alicloud/callback'`。例如，`http://test.gitlab.com/users/auth/alicloud/callback`。

   选择**保存**。
1. 在应用详情页面中添加 OAuth 范围：

   1. 在**应用名称**列下，选择您创建的应用的名称。此时会打开该应用的详情页面。
   1. 在**应用 OAuth 范围**标签页下，选择**添加 OAuth 范围**。
   1. 选中 **aliuid** 和 **profile** 复选框。
   1. 选择**确定**。

   ![阿里云 OAuth 范围](img/alicloud_scope_v14_10.png)
1. 在应用详情页面中创建密钥：

   1. 在**应用密钥**标签页下，选择**创建密钥**。
   1. 复制生成的 SecretValue。

<a id="enable-alicloud-oauth-in-gitlab"></a>

## 在极狐GitLab 中启用阿里云 OAuth

1. 在您的极狐GitLab 服务器上，打开配置文件。

   - 对于 Linux 软件包安装：

     ```shell
     sudo editor /etc/gitlab/gitlab.rb
     ```

   - 对于自行编译安装：

     ```shell
     cd /home/git/gitlab

     sudo -u git -H editor config/gitlab.yml
     ```

1. 配置[通用设置](omniauth.md#configure-common-settings)
   以添加 `alicloud` 作为单点登录提供商。这将为没有现有极狐GitLab 账号的用户启用即时账号预配。
1. 添加提供商配置。将 `YOUR_APP_ID` 替换为应用详情页面上的 ID，
   将 `YOUR_APP_SECRET` 替换为您注册阿里云应用时获得的 **SecretValue**。

   - 对于 Linux 软件包安装：

     ```ruby
       gitlab_rails['omniauth_providers'] = [
         {
           name: "alicloud",
           app_id: "YOUR_APP_ID",
           app_secret: "YOUR_APP_SECRET"
         }
       ]
     ```

   - 对于自行编译安装：

     ```yaml
     - { name: 'alicloud',
         app_id: 'YOUR_APP_ID',
         app_secret: 'YOUR_APP_SECRET' }
     ```

1. 保存配置文件。
1. 如果您使用 Linux 软件包安装，请[重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)；
   如果您从源代码安装，请[重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations)。
