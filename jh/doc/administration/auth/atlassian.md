---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Atlassian 作为 OAuth 2.0 认证提供程序
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要启用 Atlassian OmniAuth 提供程序以实现无密码认证，您必须在 Atlassian 中注册应用。

<a id="atlassian-application-registration"></a>

## Atlassian 应用注册

1. 前往 [Atlassian 开发者控制台](https://developer.atlassian.com/console/myapps/) 并使用 Atlassian 账户登录以管理应用。
1. 选择 **创建新应用**。
1. 选择应用名称，例如 ‘极狐GitLab’，然后选择 **创建**。
1. 记下 `Client ID` 和 `Secret` 以备后续 [极狐GitLab 配置](#gitlab-configuration) 步骤使用。
1. 在左侧边栏的 **API 和功能** 下，选择 **OAuth 2.0 (3LO)**。
1. 输入极狐GitLab 回调 URL，格式为 `https://gitlab.example.com/users/auth/atlassian_oauth2/callback`，然后选择 **保存更改**。
1. 在左侧边栏的 **API 和功能** 下选择 **+ 添加**。
1. 为 **Jira 平台 REST API** 选择 **添加**，然后选择 **配置**。
1. 在以下权限范围旁选择 **添加**：
   - **查看 Jira 议题数据**
   - **查看用户资料**
   - **创建和管理议题**

<a id="gitlab-configuration"></a>

## 极狐GitLab 配置

1. 在您的极狐GitLab 服务器上，打开配置文件：

   对于 Linux 软件包安装方式：

   ```shell
   sudo editor /etc/gitlab/gitlab.rb
   ```

   对于自编译安装方式：

   ```shell
   sudo -u git -H editor /home/git/gitlab/config/gitlab.yml
   ```

1. 配置 [通用设置](../../integration/omniauth.md#configure-common-settings) 以添加 `atlassian_oauth2` 作为单点登录提供程序。这将为尚无 极狐GitLab 账户的用户启用即时账户开通。
1. 添加 Atlassian 的提供程序配置：

   对于 Linux 软件包安装方式：

   ```ruby
   gitlab_rails['omniauth_providers'] = [
     {
       name: "atlassian_oauth2",
       # label: "提供程序名称", # 登录按钮的可选标签，默认为 "Atlassian"
       app_id: "<your_client_id>",
       app_secret: "<your_client_secret>",
       args: { scope: "offline_access read:jira-user read:jira-work", prompt: "consent" }
     }
   ]
   ```

   对于自编译安装方式：

   ```yaml
   - { name: "atlassian_oauth2",
       # label: "提供程序名称", # 登录按钮的可选标签，默认为 "Atlassian"
       app_id: "<your_client_id>",
       app_secret: "<your_client_secret>",
       args: { scope: "offline_access read:jira-user read:jira-work", prompt: "consent" }
    }
   ```

1. 将 `<your_client_id>` 和 `<your_client_secret>` 替换为在 [应用注册](#atlassian-application-registration) 过程中收到的客户端凭据。
1. 保存配置文件。
1. 使更改生效：
   - 如果您使用 Linux 软件包安装，请 [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
   - 如果您是自编译安装，请 [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。

在登录页面，常规登录表单下方应出现一个 Atlassian 图标。选择该图标以开始认证流程。

如果一切顺利，用户将使用其 Atlassian 凭据登录到极狐GitLab。