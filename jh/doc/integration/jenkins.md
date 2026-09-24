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

{{< history >}}

- 在 13.7 中移至 极狐GitLab 基础版。

{{< /history >}}

[Jenkins](https://www.jenkins.io/) 是一个开源的自动化服务器，支持构建、部署和自动化项目。

你应在以下场景使用 Jenkins 与 极狐GitLab 的集成：

- 你计划将来将 CI 从 Jenkins 迁移到 [极狐GitLab CI/CD](../ci/_index.md)，但需要一个过渡方案。
- 你已投入 [Jenkins 插件](https://plugins.jenkins.io/) 并选择继续使用 Jenkins 构建你的应用。

此集成可以在变更推送到 极狐GitLab 时触发 Jenkins 构建。

你不能使用此集成从 Jenkins 触发 极狐GitLab CI/CD 流水线。相反，应在 Jenkins 作业中使用 [流水线触发器 API 端点](../api/pipeline_triggers.md)，并使用 [流水线触发令牌](../ci/triggers/_index.md#create-a-pipeline-trigger-token) 进行认证。

配置 Jenkins 集成后，当你推送代码到仓库或在 极狐GitLab 中创建合并请求时，会触发 Jenkins 中的构建。Jenkins 流水线状态会显示在合并请求组件和 极狐GitLab 项目的主页上。

要配置 Jenkins 与 极狐GitLab 的集成：

- 授予 Jenkins 对 极狐GitLab 项目的访问权限。
- 配置 Jenkins 服务器。
- 配置 Jenkins 项目。
- 配置 极狐GitLab 项目。

## 授予 Jenkins 对 极狐GitLab 项目的访问权限

1. 创建个人、项目或群组访问令牌。

   - [创建个人访问令牌](../user/profile/personal_access_tokens.md#create-a-personal-access-token) 以便为该用户的所有 Jenkins 集成使用令牌。
   - [创建项目访问令牌](../user/project/settings/project_access_tokens.md#create-a-project-access-token) 仅在项目级别使用令牌。例如，你可以在项目中撤销令牌，而不影响其他项目中的 Jenkins 集成。
   - [创建群组访问令牌](../user/group/settings/group_access_tokens.md#create-a-group-access-token) 为该群组内所有项目的所有 Jenkins 集成使用令牌。

1. 将访问令牌范围设置为 **API**。
1. 复制访问令牌值以配置 Jenkins 服务器。

## 配置 Jenkins 服务器

安装并配置 Jenkins 插件以授权与 极狐GitLab 的连接。

1. 在 Jenkins 服务器上，选择 **管理 Jenkins** > **管理插件**。
1. 选择 **可用** 选项卡。搜索 `gitlab-plugin` 并选择安装。
   有关其他安装插件的方法，请参阅 [Jenkins GitLab 文档](https://plugins.jenkins.io/gitlab-plugin/)。
1. 选择 **管理 Jenkins** > **配置系统**。
1. 在 **GitLab** 部分，选择 **为 '/project' 端点启用认证**。
1. 选择 **添加**，然后选择 **Jenkins 凭证提供者**。
1. 选择 **GitLab API 令牌** 作为令牌类型。
1. 在 **API 令牌** 中，[粘贴你从 极狐GitLab 复制的访问令牌值](#grant-jenkins-access-to-the-gitlab-project) 并选择 **添加**。
1. 在 **GitLab 主机 URL** 中输入 极狐GitLab 服务器的 URL。
1. 要测试连接，选择 **测试连接**。

更多信息，请参阅
[Jenkins 到 GitLab 的认证](https://github.com/jenkinsci/gitlab-plugin#jenkins-to-gitlab-authentication)。

## 配置 Jenkins 项目

设置你打算运行构建的 Jenkins 项目。

1. 在你的 Jenkins 实例上，选择 **新建项目**。
1. 输入项目名称。
1. 选择 **自由风格** 或 **流水线** 并选择 **确定**。
   你应该选择自由风格项目，因为 Jenkins 插件会在 极狐GitLab 上更新构建状态。在流水线项目中，你必须配置一个脚本以在 极狐GitLab 上更新状态。
1. 从下拉列表中选择你的 极狐GitLab 连接。
1. 选择 **当变更推送到 极狐GitLab 时构建**。
1. 选择以下复选框：
   - **接受的合并请求事件**
   - **关闭的合并请求事件**
1. 指定如何将构建状态报告给 极狐GitLab：
   - 如果你创建了自由风格项目，在 **构建后操作** 部分，
     选择 **发布构建状态到 极狐GitLab**。
   - 如果你创建了流水线项目，你必须使用 Jenkins 流水线脚本在 极狐GitLab 上更新状态。

     Jenkins 流水线脚本示例：

      ```groovy
      pipeline {
         agent any

         stages {
            stage('gitlab') {
               steps {
                  echo '通知 极狐GitLab'
                  updateGitlabCommitStatus name: 'build', state: 'pending'
                  updateGitlabCommitStatus name: 'build', state: 'success'
               }
            }
         }
      }
      ```

      更多 Jenkins 流水线脚本示例，请参阅
      [GitHub 上的 Jenkins GitLab 插件仓库](https://github.com/jenkinsci/gitlab-plugin#scripted-pipeline-jobs)。

## 配置 极狐GitLab 项目

通过以下方式之一配置 极狐GitLab 与 Jenkins 的集成。

### 使用 Jenkins 服务器 URL

如果你可以向 极狐GitLab 提供 Jenkins 服务器 URL 和认证信息，应使用此方法进行 Jenkins 集成。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Jenkins**。
1. 选中 **启用** 复选框。
1. 选择你希望 极狐GitLab 触发 Jenkins 构建的事件：
   - 推送
   - 合并请求
   - 标签推送
1. 输入 **Jenkins 服务器 URL**。
1. 可选。清除 **启用 SSL 验证** 复选框以禁用 [SSL 验证](../user/project/integrations/_index.md#ssl-verification)。
1. 输入 **项目名称**。
   项目名称应是 URL 友好的，空格替换为下划线。为确保项目名称有效，请在查看 Jenkins 项目时从浏览器地址栏复制它。
1. 如果你的 Jenkins 服务器需要认证，输入 **用户名** 和 **密码**。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

### 使用 Webhook

如果你无法 [向 极狐GitLab 提供 Jenkins 服务器 URL 和认证信息](#with-a-jenkins-server-url)，可以配置 Webhook 来集成 极狐GitLab 和 Jenkins。

1. 在 Jenkins 作业的配置中，在 GitLab 配置部分，选择 **高级**。
1. 在 **密钥令牌** 下，选择 **生成**。
1. 复制令牌，并保存作业配置。
1. 在 极狐GitLab 中：
   - [为你的项目创建 Webhook](../user/project/integrations/webhooks.md#configure-webhooks)。
   - 输入触发 URL（例如 `https://JENKINS_URL/project/YOUR_JOB`）。
   - 在 **密钥令牌** 中粘贴令牌。
1. 要测试 Webhook，选择 **测试**。

## 故障排查

### 错误：`Connection failed. Please check your settings`

配置 极狐GitLab 时，你可能会收到错误 `Connection failed. Please check your settings`。

此问题有多种可能的原因和解决方案：

| 原因                                                            | 解决方法  |
|------------------------------------------------------------------|-------------|
| 极狐GitLab 无法访问给定地址的 Jenkins 实例。  | 对于 极狐GitLab 私有化部署，在 极狐GitLab 实例上 ping 所提供的域上的 Jenkins 实例。 |
| Jenkins 实例位于本地地址，且未包含在 [极狐GitLab 安装的允许列表](../security/webhooks.md#allow-outbound-requests-to-certain-ip-addresses-and-domains) 中。 | 将该实例添加到 极狐GitLab 安装的允许列表中。 |
| Jenkins 实例的凭证没有足够的访问权限或无效。 | 授予凭证足够的访问权限或创建有效凭证。 |
| 在你的 [Jenkins 插件配置](#configure-the-jenkins-server) 中未选中 **为 `/project` 端点启用认证** 复选框。 | 选中该复选框。 |

### 错误：`Could not connect to the CI server`

如果 极狐GitLab 未通过 [提交状态 API](../api/commits.md#commit-status) 从 Jenkins 收到构建状态更新，你可能会在合并请求中收到错误 `Could not connect to the CI server`。

当 Jenkins 未正确配置或通过 API 报告状态时出错，会出现此问题。

要修复此问题：

1. 为 极狐GitLab API 访问 [配置 Jenkins 服务器](#configure-the-jenkins-server)。
1. [配置 Jenkins 项目](#configure-the-jenkins-project)，并确保如果你创建了自由风格项目，选择了“发布构建状态到 极狐GitLab”构建后操作。

### 合并请求事件未触发 Jenkins 流水线

当请求超过 [Webhook 超时限制](../user/jihulab_com/_index.md#webhooks)（默认设置为 10 秒）时，可能会出现此问题。

对于此问题，请检查：

- 集成 Webhook 日志中是否有请求失败。
- `/var/log/gitlab/gitlab-rails/production.log` 中是否有类似以下的消息：

  ```plaintext
  WebHook 错误 => Net::ReadTimeout
  ```

  或

  ```plaintext
  WebHook 错误 => 执行超时
  ```

在 极狐GitLab 私有化部署上，你可以通过 [增加 Webhook 超时值](../administration/instance_limits.md#webhook-timeout) 来修复此问题。

### 在 Jenkins 中启用作业日志

要排查集成问题，你可以在 Jenkins 中启用作业日志以获取有关构建的更多详细信息。

要在 Jenkins 中启用作业日志：

1. 转到 **仪表板** > **管理 Jenkins** > **系统日志**。
1. 选择 **添加新的日志记录器**。
1. 输入日志记录器的名称。
1. 在下一个屏幕上，选择 **添加** 并输入 `com.dabsquared.gitlabjenkins`。
1. 确保日志级别为 **全部** 并选择 **保存**。

要查看日志：

1. 运行一次构建。
1. 转到 **仪表板** > **管理 Jenkins** > **系统日志**。
1. 选择你的日志记录器并检查日志。