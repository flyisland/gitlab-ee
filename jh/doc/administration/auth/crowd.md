---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Atlassian Crowd 作为身份验证提供商
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用 Atlassian Crowd OmniAuth 提供商向极狐GitLab 进行身份验证。启用此提供商后，还可为 Git-over-https 请求启用 Crowd 身份验证。

<a id="configure-a-new-crowd-application"></a>

## 配置新的 Crowd 应用

1. 在顶部菜单中，选择 **应用程序** > **添加应用程序**。
1. 按照 **添加应用程序** 步骤操作，输入相应的详细信息。
1. 完成后，选择 **添加应用程序**。

<a id="configure-gitlab"></a>

## 配置极狐GitLab

1. 在极狐GitLab 服务器上，打开配置文件。

   - Linux 软件包安装：

     ```shell
     sudo editor /etc/gitlab/gitlab.rb
     ```

   - 自编译安装：

     ```shell
     cd /home/git/gitlab

     sudo -u git -H editor config/gitlab.yml
     ```

1. 配置[通用设置](../../integration/omniauth.md#configure-common-settings)，将 `crowd` 添加为单点登录提供商。这样可为没有现有极狐GitLab 账号的用户启用即时账号预配。

1. 添加提供商配置：

   - Linux 软件包安装：

     ```ruby
       gitlab_rails['omniauth_providers'] = [
         {
           name: "crowd",
           args: {
             crowd_server_url: "CROWD_SERVER_URL",
             application_name: "YOUR_APP_NAME",
             application_password: "YOUR_APP_PASSWORD"
           }
         }
       ]
     ```

   - 自编译安装：

     ```yaml
        - { name: 'crowd',
            args: {
              crowd_server_url: 'CROWD_SERVER_URL',
              application_name: 'YOUR_APP_NAME',
              application_password: 'YOUR_APP_PASSWORD' } }
     ```

1. 将 `CROWD_SERVER_URL` 更改为 [Crowd 服务器的基础 URL](https://confluence.atlassian.com/crowdkb/how-to-change-the-crowd-base-url-245827278.html)。
1. 将 `YOUR_APP_NAME` 更改为 Crowd 应用页面中的应用名称。
1. 将 `YOUR_APP_PASSWORD` 更改为您设置的应用密码。
1. 保存配置文件。
1. [重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation)（Linux 软件包安装）或[重启](../restart_gitlab.md#self-compiled-installations)（自编译安装），以使更改生效。

现在，登录页面的登录表单中应显示一个 Crowd 标签页。

<a id="troubleshooting"></a>

## 故障排除

<a id="error-could-not-authorize-you-from-crowd-because-invalid-credentials"></a>

### 错误：`could not authorize you from Crowd because invalid credentials`

当用户尝试通过 Crowd 进行身份验证时，有时会出现此错误。Crowd 管理员应查阅 Crowd 日志文件，以了解此错误消息的确切原因。

确保必须登录极狐GitLab 的 Crowd 用户在 **授权** 步骤中已获得该[应用](#configure-a-new-crowd-application)的授权。可以通过尝试 Crowd 的“认证测试”来验证这一点（自 2.11 起）。

![Crowd 中的 授权阶段设置](img/crowd_application_authorisation_v10_4.png)
