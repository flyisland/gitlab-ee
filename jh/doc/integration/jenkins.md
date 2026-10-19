---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Jenkins
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[Jenkins](https://www.jenkins.io/) 是一款开源自动化服务器，支持构建、部署和自动化项目。

在以下情况下，您应该使用 Jenkins 与极狐GitLab 的集成：

- 您计划将来把 CI 从 Jenkins 迁移到[极狐GitLab CI/CD](../ci/_index.md)，但需要一个过渡方案。
- 您已深度使用 [Jenkins 插件](https://plugins.jenkins.io/)，并选择继续使用 Jenkins 构建您的应用。

当有变更推送到极狐GitLab 时，此集成可以触发 Jenkins 构建。

您无法使用此集成从 Jenkins 触发极狐GitLab CI/CD 流水线。请改为在 Jenkins 作业中使用[流水线触发器 API 端点](../api/pipeline_triggers.md)，并通过[流水线触发器令牌](../ci/triggers/_index.md#create-a-pipeline-trigger-token)进行身份验证。

配置 Jenkins 集成后，当您将代码推送到代码仓库或在极狐GitLab 中创建合并请求时，就会触发 Jenkins 构建。Jenkins 流水线状态会显示在合并请求小组件和极狐GitLab 项目主页上。


要将 Jenkins 与极狐GitLab 集成，请进行配置：

- 授予 Jenkins 访问极狐GitLab 项目的权限。
- 配置 Jenkins 服务器。
- 配置 Jenkins 项目。
- 配置极狐GitLab 项目。

<a id="grant-jenkins-access-to-the-gitlab-project"></a>

## 授予 Jenkins 访问极狐GitLab 项目的权限

1. 创建个人、项目或群组访问令牌。

   - [创建个人访问令牌](../user/profile/personal_access_tokens.md#create-a-personal-access-token)，
     以便将该令牌用于该用户的所有 Jenkins 集成。
   - [创建项目访问令牌](../user/project/settings/project_access_tokens.md#create-a-project-access-token)，
     以便仅在项目级别使用该令牌。例如，您可以在某个项目中撤销该令牌，而不影响其他项目中的 Jenkins 集成。
   - [创建群组访问令牌](../user/group/settings/group_access_tokens.md#create-a-group-access-token)，
     以便将该令牌用于该群组所有项目中的所有 Jenkins 集成。

1. 将访问令牌范围设置为 **API**。
1. 复制访问令牌值，用于配置 Jenkins 服务器。

<a id="configure-the-jenkins-server"></a>

## 配置 Jenkins 服务器

安装并配置 Jenkins 插件，以授权与极狐GitLab 的连接。

1. 在 Jenkins 服务器上，选择**管理 Jenkins** > **管理插件**。
1. 选择 **Available** 标签页。搜索 `gitlab-plugin` 并选择它以进行安装。
   有关安装该插件的其他方式，请参阅 [Jenkins GitLab 文档](https://plugins.jenkins.io/gitlab-plugin/)。
1. 选择**管理 Jenkins** > **配置系统**。
1. 在 **GitLab** 部分，选择**为 '/project' 端点启用认证**。
1. 选择 **Add**，然后选择**Jenkins 凭证提供者**。
1. 选择**GitLab API 令牌**作为令牌类型。
1. 在**API 令牌**中，[粘贴您从极狐GitLab 复制的访问令牌值](#grant-jenkins-access-to-the-gitlab-project)，
   然后选择 **Add**。
1. 在**GitLab 主机 URL**中输入极狐GitLab 服务器的 URL。
1. 要测试连接，请选择**测试连接**。

有关更多信息，请参阅
[Jenkins 到极狐GitLab 的身份验证](https://github.com/jenkinsci/gitlab-plugin#jenkins-to-gitlab-authentication)。

<a id="configure-the-jenkins-project"></a>

## 配置 Jenkins 项目

设置您打算在其上运行构建的 Jenkins 项目。

1. 在您的 Jenkins 实例上，选择**新建项目**。
1. 输入项目名称。
1. 选择 **自由风格项目** 或**流水线**，然后选择 **OK**。
   您应该选择 自由风格项目，因为 Jenkins 插件会更新极狐GitLab 上的构建状态。在流水线项目中，您必须配置脚本来更新极狐GitLab 上的状态。
1. 从下拉列表中选择您的极狐GitLab 连接。
1. 选择**当变更推送到极狐GitLab 时构建**。
1. 选择以下复选框：
   - **接受的合并请求事件**
   - **已关闭的合并请求事件**
1. 指定如何将构建状态报告给极狐GitLab：
   - 如果您创建的是 自由风格项目，请在**构建后操作**部分中，
     选择**发布构建状态到极狐GitLab**。
   - 如果您创建的是流水线项目，则必须使用 Jenkins 流水线脚本
     来更新极狐GitLab 上的状态。

     Jenkins 流水线脚本示例：

     ```groovy
     pipeline {
        agent any

        stages {
           stage('gitlab') {
              steps {
                 echo 'Notify GitLab'
                 updateGitlabCommitStatus name: 'build', state: 'pending'
                 updateGitlabCommitStatus name: 'build', state: 'success'
              }
           }
        }
     }
     ```

     有关更多 Jenkins 流水线脚本示例，请参阅
     [GitHub 上的 Jenkins GitLab 插件代码仓库](https://github.com/jenkinsci/gitlab-plugin#scripted-pipeline-jobs)。

<a id="configure-the-gitlab-project"></a>

## 配置极狐GitLab 项目

通过以下方式之一配置极狐GitLab 与 Jenkins 的集成。

<a id="with-a-jenkins-server-url"></a>

### 使用 Jenkins 服务器 URL

如果您可以向极狐GitLab 提供 Jenkins 服务器 URL 和身份验证信息，则应该对 Jenkins 集成使用此方法。

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Jenkins**。
1. 选择**活跃**复选框。
1. 选择您希望极狐GitLab 触发 Jenkins 构建的事件：
   - 推送
   - 合并请求
   - 标签推送
1. 输入**Jenkins 服务器 URL**。
1. 可选。清除**启用 SSL 验证**复选框以禁用 [SSL 验证](../user/project/integrations/_index.md#ssl-verification)。
1. 输入**项目名称**。
   项目名称应适合 URL，其中空格应替换为下划线。为确保项目名称有效，请在查看 Jenkins 项目时从浏览器地址栏中复制它。
1. 如果您的 Jenkins 服务器需要身份验证，请输入 **Username** 和 **Password**。
1. 可选。选择**测试设置**。
1. 选择**保存更改**。

<a id="with-a-webhook"></a>

### 使用 webhook

如果您无法[向极狐GitLab 提供 Jenkins 服务器 URL 和身份验证信息](#with-a-jenkins-server-url)，则可以配置 webhook 来集成极狐GitLab 和 Jenkins。

1. 在 Jenkins 作业的配置中，在 GitLab 配置部分，选择 **Advanced**。
1. 在**密钥令牌**下，选择 **Generate**。
1. 复制令牌，并保存作业配置。
1. 在极狐GitLab 中：
   - [为您的项目创建 webhook](../user/project/integrations/webhooks.md#configure-webhooks)。
   - 输入触发 URL（例如 `https://JENKINS_URL/project/YOUR_JOB`）。
   - 将令牌粘贴到**密钥令牌**中。
1. 要测试 webhook，请选择 **Test**。

<a id="troubleshooting"></a>

## 故障排除

<a id="error-connection-failed-please-check-your-settings"></a>

### 错误：`Connection failed. Please check your settings`

配置极狐GitLab 时，您可能会收到错误 `Connection failed. Please check your settings`。

此问题有多种可能的原因和解决方案：

| 原因                                                            | 变通方法  |
|------------------------------------------------------------------|-------------|
| 极狐GitLab 无法通过该地址访问您的 Jenkins 实例。  | 对于极狐GitLab 私有化部署，请在极狐GitLab 实例上提供的域名处 ping Jenkins 实例。 |
| Jenkins 实例位于本地地址，且未包含在[极狐GitLab 安装的允许名单](../security/webhooks.md#allow-outbound-requests-to-certain-ip-addresses-and-domains)中。 | 将该实例添加到极狐GitLab 安装的允许名单中。 |
| Jenkins 实例的凭证没有足够的访问权限或无效。 | 为凭证授予足够的访问权限，或创建有效的凭证。 |
| 在您的 [Jenkins 插件配置](#configure-the-jenkins-server)中未选择 **Enable authentication for `/project` end-point** 复选框 | 选择该复选框。 |

<a id="error-could-not-connect-to-the-ci-server"></a>

### 错误：`Could not connect to the CI server`

如果极狐GitLab 未通过
[提交状态 API](../api/commits.md#commit-status) 收到来自 Jenkins 的构建状态更新，您可能会在合并请求中收到错误 `Could not connect to the CI server`。

当 Jenkins 未正确配置，或通过 API 报告状态时出错，就会出现此问题。

要修复此问题：

1. [配置 Jenkins 服务器](#configure-the-jenkins-server)以访问极狐GitLab API。
1. [配置 Jenkins 项目](#configure-the-jenkins-project)，并确保
   如果您创建的是 自由风格项目，请选择 "Publish build status to GitLab"
   构建后操作。

<a id="merge-request-event-does-not-trigger-a-jenkins-pipeline"></a>

### 合并请求事件未触发 Jenkins 流水线

当请求超过 [webhook 超时限制](../user/jihulab_com/_index.md#webhooks)时，可能会出现此问题，
该限制默认设置为 10 秒。

对于此问题，请检查：

- 集成 webhook 日志中的请求失败记录。
- `/var/log/gitlab/gitlab-rails/production.log`中是否有类似以下内容的消息：

  ```plaintext
  WebHook Error => Net::ReadTimeout
  ```

  或

  ```plaintext
  WebHook Error => execution expired
  ```

在极狐GitLab 私有化部署上，您可以通过[增大 webhook 超时值](../administration/instance_limits.md#webhook-timeout)来修复此问题。

<a id="enable-job-logs-in-jenkins"></a>

### 在 Jenkins 中启用作业日志

要对集成问题进行故障排除，您可以在 Jenkins 中启用作业日志，以获取有关构建的更多详细信息。

要在 Jenkins 中启用作业日志：

1. 转到 **Dashboard** > **管理 Jenkins** > **系统日志**。
1. 选择**添加新的日志记录器**。
1. 输入日志记录器的名称。
1. 在下一个屏幕上，选择 **Add** 并输入 `com.dabsquared.gitlabjenkins`。
1. 确保日志级别为 **All**，然后选择 **Save**。

要查看日志：

1. 运行一次构建。
1. 转到 **Dashboard** > **管理 Jenkins** > **系统日志**。
1. 选择您的日志记录器并检查日志。
