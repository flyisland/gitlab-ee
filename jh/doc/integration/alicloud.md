---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 AliCloud 作为 OmniAuth 认证提供者
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以启用 AliCloud OAuth 2.0 OmniAuth 提供者，并使用你的 AliCloud 账户登录极狐GitLab。

<a id="create-an-alicloud-application"></a>

## 创建 AliCloud 应用

登录 AliCloud 平台并在其上创建应用。AliCloud 会生成客户端 ID 和密钥（secret key）供你使用。

1. 登录 [AliCloud 平台](https://account.aliyun.com/login/login.htm)。
1. 前往 [OAuth 应用管理页面](https://ram.console.aliyun.com/applications)。
1. 选择 **创建应用**。
1. 填写应用详情：

   - **应用名称**：任意命名。
   - **显示名称**：任意命名。
   - **回调 URL**：该 URL 格式应为 `'极狐GitLab 实例 URL' + '/users/auth/alicloud/callback'`。例如，`http://test.jihulab.com/users/auth/alicloud/callback`。

   选择 **保存**。
1. 在应用详情页面添加 OAuth 范围：

   1. 在 **应用名称** 列下，选择你创建的应用名称。应用详情页面会打开。
   1. 在 **应用 OAuth 范围** 标签页下，选择 **添加 OAuth 范围**。
   1. 勾选 **aliuid** 和 **profile** 复选框。
   1. 选择 **确定**。

   ![AliCloud OAuth 范围](img/alicloud_scope_v14_10.png)
1. 在应用详情页面创建密钥：

   1. 在 **密钥信息** 标签页下，选择 **创建密钥**。
   1. 复制生成的 **SecretValue**。

<a id="enable-alicloud-oauth-in-gitlab"></a>

## 在极狐GitLab 中启用 AliCloud OAuth

1. 在极狐GitLab 服务器上，打开配置文件。

   - 对于 Linux 软件包安装：

     ```shell
     sudo editor /etc/gitlab/gitlab.rb
     ```

   - 对于自行编译的安装：

     ```shell
     cd /home/git/gitlab

     sudo -u git -H editor config/gitlab.yml
     ```

1. 配置[通用设置](omniauth.md#configure-common-settings)将 `alicloud` 添加为单点登录提供者。这会为没有极狐GitLab 账户的用户启用即时（Just-In-Time）账户配置。
1. 添加提供者配置。将 `YOUR_APP_ID` 替换为应用详情页面上的 ID，并将 `YOUR_APP_SECRET` 替换为注册 AliCloud 应用时获得的 **SecretValue**。

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

   - 对于自行编译的安装：

     ```yaml
     - { name: 'alicloud',
         app_id: 'YOUR_APP_ID',
         app_secret: 'YOUR_APP_SECRET' }
     ```

1. 保存配置文件。
1. 如果使用 Linux 软件包安装，请[重新配置极狐GitLab](../administration/restart_gitlab.md#reconfigure-a-linux-package-installation)；如果从源代码安装，请[重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations)。