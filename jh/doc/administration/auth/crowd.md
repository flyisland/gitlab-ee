---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Atlassian Crowd 作为认证提供者
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用 Atlassian Crowd OmniAuth 提供者向极狐GitLab 进行认证。启用此提供者还允许对 Git-over-https 请求进行 Crowd 认证。

<a id="configure-a-new-crowd-application"></a>

## 配置一个新的 Crowd 应用程序

1. 在顶部菜单上，选择 **应用程序** > **添加应用程序**。
1. 执行 **添加应用程序** 步骤，输入适当的信息。
1. 完成后，选择 **添加应用程序**。

<a id="configure-gitlab"></a>

## 配置极狐GitLab

1. 在您的极狐GitLab 服务器上，打开配置文件。

   - Linux 软件包安装方式：

     ```shell
     sudo editor /etc/gitlab/gitlab.rb
     ```

   - 源码编译安装方式：

     ```shell
     cd /home/git/gitlab

     sudo -u git -H editor config/gitlab.yml
     ```

1. 配置 [通用设置](../../integration/omniauth.md#configure-common-settings) 以添加 `crowd` 作为单点登录提供者。这将为没有极狐GitLab 账户的用户启用即时账户配置。
1. 添加提供者配置：

   - Linux 软件包安装方式：

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

   - 源码编译安装方式：

     ```yaml
        - { name: 'crowd',
            args: {
              crowd_server_url: 'CROWD_SERVER_URL',
              application_name: 'YOUR_APP_NAME',
              application_password: 'YOUR_APP_PASSWORD' } }
     ```

1. 将 `CROWD_SERVER_URL` 更改为 [您的 Crowd 服务器的基 URL](https://confluence.atlassian.com/crowdkb/how-to-change-the-crowd-base-url-245827278.html)。
1. 将 `YOUR_APP_NAME` 更改为 Crowd 应用程序页面上的应用程序名称。
1. 将 `YOUR_APP_PASSWORD` 更改为您设置的应用程序密码。
1. 保存配置文件。
1. [重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation)（Linux 软件包安装方式）或 [重启](../restart_gitlab.md#self-compiled-installations)（源码编译安装方式）以使更改生效。

现在，登录页面的登录表单中应该会有一个 Crowd 选项卡。

<a id="troubleshooting"></a>

## 故障排查

<a id="error-could-not-authorize-you-from-crowd-because-invalid-credentials"></a>

### 错误：`无法从 Crowd 为您授权，因为凭证无效`

当用户尝试使用 Crowd 进行认证时，有时会出现此错误。Crowd 管理员应查阅 Crowd 日志文件，以了解此错误消息的确切原因。

确保必须登录极狐GitLab 的 Crowd 用户在 **授权** 步骤中已获得对 [应用程序](#configure-a-new-crowd-application) 的授权。可以通过尝试 Crowd 的“认证测试”（自 2.11 起）进行验证。

![Crowd 中的授权阶段设置](img/crowd_application_authorisation_v10_4.png)