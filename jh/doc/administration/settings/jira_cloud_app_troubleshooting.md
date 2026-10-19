---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 管理极狐GitLab for Jira Cloud 应用时，解决安装、登录和数据同步错误。
title: 极狐GitLab for Jira Cloud 应用管理故障排查
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

管理极狐GitLab for Jira Cloud 应用时，您可能会遇到以下问题。

有关用户故障排查，请参阅 [极狐GitLab for Jira Cloud 应用](../../integration/jira/connect-app.md#troubleshooting)。

<a id="sign-in-message-displayed-when-already-signed-in"></a>

## 已登录时仍显示登录消息

您可能会收到以下消息，提示您登录 JihuLab.com，即使您已经登录：

```plaintext
Sign in or sign up before continuing.
```

极狐GitLab for Jira Cloud 应用使用 iframe 在设置页面上添加群组。某些浏览器会阻止跨站 Cookie，这可能导致此问题。

要解决此问题，请设置 [OAuth 身份验证](jira_cloud_app.md#set-up-oauth-authentication)。

<a id="manual-installation-fails"></a>

## 手动安装失败

如果您已从官方市场列表安装极狐GitLab for Jira Cloud 应用，并将其替换为[手动安装](jira_cloud_app.md#install-the-gitlab-for-jira-cloud-app-manually)，则可能会遇到以下错误之一：

```plaintext
The app "gitlab-jira-connect-gitlab.com" could not be installed as a local app as it has previously been installed from Atlassian Marketplace
```

```plaintext
The app host returned HTTP response code 401 when we tried to contact it during installation. Please try again later or contact the app vendor.
```

要解决此问题，请关闭 **Jira Connect 代理 URL** 设置。

先决条件：

- 管理员访问权限。

要关闭 **Jira Connect 代理 URL** 设置：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **极狐GitLab for Jira 应用**。
1. 清除 **Jira Connect 代理 URL** 文本框。
1. 选择 **保存更改**。

如果问题仍然存在，请确认您的实例可以连接到
`connect-install-keys.atlassian.com` 以从 Atlassian 获取公钥。
要测试连接，请运行以下命令：

```shell
# A `404 Not Found` is expected because you're not passing a token
curl --head "https://connect-install-keys.atlassian.com"
```

<a id="review-installation-changes-to-the-gitlab-for-jira-cloud-app"></a>

## 查看极狐GitLab for Jira Cloud 应用的安装更改

有几种方法可以查看极狐GitLab for Jira Cloud 应用的任何安装更改。有关更多信息，请参阅官方 [Jira 文档](https://support.atlassian.com/jira/kb/how-to-check-who-installed-enabled-disabled-uninstalled-plugin-in-jira/)。

<a id="data-sync-fails-with-invalid-jwt"></a>

## 数据同步失败并显示 `Invalid JWT`

如果极狐GitLab for Jira Cloud 应用持续无法从您的实例同步数据，则密钥令牌可能已过期。Atlassian 可以向极狐GitLab 发送新的密钥令牌。
如果极狐GitLab 无法处理或存储这些令牌，则会发生 `Invalid JWT` 错误。

要解决此问题：

- 确认实例可公开访问：
  - JihuLab.com（如果您[从官方 Atlassian 市场列表安装了应用](jira_cloud_app.md#install-the-gitlab-for-jira-cloud-app-from-the-atlassian-marketplace)）。
  - Jira Cloud（如果您[手动安装了应用](jira_cloud_app.md#install-the-gitlab-for-jira-cloud-app-manually)）。
- 确保在安装应用时发送到 `/-/jira_connect/events/installed` 端点的令牌请求可从 Jira 访问。
  以下命令应返回 `401 Unauthorized`：

  ```shell
  curl --include --request POST "https://gitlab.example.com/-/jira_connect/events/installed"
  ```

- 如果您的实例已[配置 SSL](https://gitlab.cn/docs/omnibus/settings/ssl/)，请检查您的
  [证书是否有效且受公开信任](https://gitlab.cn/docs/omnibus/settings/ssl/ssl_troubleshooting/#useful-openssl-debugging-commands)。

根据您安装应用的方式，您可能需要检查以下内容：

- 如果您[从官方 Atlassian 市场列表安装了应用](jira_cloud_app.md#install-the-gitlab-for-jira-cloud-app-from-the-atlassian-marketplace)，
  请在极狐GitLab for Jira Cloud 应用中切换极狐GitLab 版本：

  <!-- markdownlint-disable MD044 -->

  1. 在 Jira 中，选择 **应用** 旁边的水平省略号 ({{< icon name="ellipsis_h" >}})，然后选择 **管理您的应用**。

  1. 使用以下方法之一转到该应用：

     **对于使用集中式应用管理的实例**：

     1. 如果您看到“应用管理已移至管理”，请选择 **带我去**。否则，请按照下面的 **对于使用旧版应用管理的实例** 说明操作。
     1. 在 **已安装的应用** 选项卡中，找到 **极狐GitLab for Jira (gitlab.com)** 应用，选择水平省略号 ({{< icon name="ellipsis_h" >}})，然后选择 **开始使用**。

     **对于使用旧版应用管理的实例**：

     1. 找到 **极狐GitLab for Jira (gitlab.com)** 应用，选择 V 形符号 ({{< icon name="chevron-right" >}})，然后选择 **开始使用**。

  1. 选择 **更改极狐GitLab 版本**。
  1. 选择 **JihuLab.com (SaaS)**，然后选择 **保存**。
  1. 再次选择 **更改极狐GitLab 版本**。
  1. 选择 **极狐GitLab（私有化部署）**，然后选择 **下一步**。
  1. 选中所有复选框，然后选择 **下一步**。
  1. 输入您的 **极狐GitLab 实例 URL**，然后选择 **保存**。

  <!-- markdownlint-enable MD044 -->

  如果此方法无效，且您是专业版或旗舰版客户，请[提交支持工单](https://support.gitlab.com/hc/en-us/requests/new)。
  请提供您的极狐GitLab 实例 URL 和 Jira URL。极狐GitLab 支持团队可以尝试运行以下脚本来解决问题：

  ```ruby
  # Check if GitLab.com can connect to the GitLab Self-Managed instance
  checker = Gitlab::TcpChecker.new("gitlab.example.com", 443)

  # Returns `true` if successful
  checker.check

  # Returns an error if the check fails
  checker.error
  ```

  ```ruby
  # Locate the installation record for the GitLab Self-Managed instance
  installation = JiraConnectInstallation.find_by_instance_url("https://gitlab.example.com")

  # Try to send the token again from GitLab.com to the GitLab Self-Managed instance
  ProxyLifecycleEventService.execute(installation, :installed, installation.instance_url)
  ```

- 如果您[手动安装了应用](jira_cloud_app.md#install-the-gitlab-for-jira-cloud-app-manually)：
  - 请[联系 Jira Cloud 支持](https://support.atlassian.com/jira-software-cloud/)，以验证 Jira 是否可以连接到您的
    实例。
  - [重新安装应用](jira_cloud_app.md#install-the-gitlab-for-jira-cloud-app-manually)。此方法可能会从 [Jira 开发面板](../../integration/jira/development_panel.md) 中移除所有[已同步的数据](../../integration/jira/connect-app.md#gitlab-data-synced-to-jira)。

<a id="error-failed-to-update-the-gitlab-instance"></a>

## 错误：`Failed to update the GitLab instance`

当您设置极狐GitLab for Jira Cloud 应用时，在输入您的极狐GitLab 私有化部署实例 URL 后，可能会收到 `Failed to update the GitLab instance` 错误。

要解决此问题，请确保您的安装方法的所有先决条件均已满足：

- [连接极狐GitLab for Jira Cloud 应用的先决条件](jira_cloud_app.md#prerequisites)
- [手动安装极狐GitLab for Jira Cloud 应用的先决条件](jira_cloud_app.md#prerequisites-1)

如果您已配置 Jira Connect 代理 URL，并且在检查先决条件后问题仍然存在，请查看 [调试 Jira Connect 代理问题](#debugging-jira-connect-proxy-issues)。

<a id="error-invalid-audience"></a>

### 错误：`Invalid audience`

如果您使用[反向代理](jira_cloud_app.md#using-a-reverse-proxy)，
[`exceptions_json.log`](../logs/_index.md#exceptions_jsonlog) 可能包含如下消息：

```plaintext
Invalid audience. Expected https://proxy.example.com/-/jira_connect, received https://gitlab.example.com/-/jira_connect
```

要解决此问题，请将反向代理 FQDN 设置为
[附加 JWT 受众](jira_cloud_app.md#set-an-additional-jwt-audience)。

<a id="debugging-jira-connect-proxy-issues"></a>

### 调试 Jira Connect 代理问题

如果您在[设置实例](jira_cloud_app.md#set-up-your-instance-for-atlassian-marketplace-installation)时将 **Jira Connect 代理 URL** 设置为 `https://gitlab.com`，您可以：

- 检查浏览器开发工具中的网络流量。
- 重现 `Failed to update the GitLab instance` 错误以获取更多信息。

您应该会看到对 `https://gitlab.com/-/jira_connect/installations` 的 `GET` 请求。

此请求应返回 `200 OK`，但如果出现问题，它可能会返回 `422 Unprocessable Entity`。
您可以检查响应正文中的错误。

如果您无法解决问题并且您是极狐GitLab 客户，请联系 [极狐GitLab 支持](https://support.gitlab.com/) 寻求帮助。
请向极狐GitLab 支持提供：

- 您的极狐GitLab 私有化部署实例 URL。
- 您的 JihuLab.com 用户名。
- 可选。对 `https://gitlab.com/-/jira_connect/installations` 的失败 `GET`
  请求的 `X-Request-Id` 响应头。
- 可选。您已使用 [`harcleaner`](https://gitlab.com/gitlab-com/support/toolbox/harcleaner) 处理的 [HAR 文件](https://support.zendesk.com/hc/en-us/articles/4408828867098-Workflow-Generating-a-HAR-file-for-troubleshooting)，其中捕获了该问题。

然后，极狐GitLab 支持团队可以在 JihuLab.com 服务器日志中调查该问题。

<a id="gitlab-support"></a>

#### 极狐GitLab 支持

> [!note]
> 这些步骤只能由极狐GitLab 支持团队完成。

对 Jira Connect 代理 URL `https://gitlab.com/-/jira_connect/installations` 发出的每个 `GET` 请求都会生成两条日志条目。

要在 Kibana 中定位相关日志条目，请执行以下任一操作：

- 如果您有对 `https://gitlab.com/-/jira_connect/installations` 的 `GET` 请求的 `X-Request-Id` 值或关联 ID，则
  [Kibana](https://log.gprd.gitlab.net/app/r/s/0FdPP) 日志应过滤
  `json.meta.caller_id: JiraConnect::InstallationsController#update`、`NOT json.status: 200`
  和 `json.correlation_id: <X-Request-Id>`。这应返回两条日志条目。

- 如果您有客户的极狐GitLab 私有化部署 URL：
  1. [Kibana](https://log.gprd.gitlab.net/app/r/s/QVsD4) 日志应过滤
     `json.meta.caller_id: JiraConnect::InstallationsController#update`、`NOT json.status: 200`
     和 `json.params.value: {"instance_url"=>"https://gitlab.example.com"}`。极狐GitLab 私有化部署 URL
     不得有前导斜杠。这应返回其中一条日志条目。
  1. 将 `json.correlation_id` 添加到过滤器。
  1. 移除 `json.params.value` 过滤器。这应返回另一条日志条目。

对于第一条日志：

- `json.status` 为 `422 Unprocessable Entity`。
- `json.params.value` 应与极狐GitLab 私有化部署 URL `[[FILTERED], {"instance_url"=>"https://gitlab.example.com"}]` 匹配。

对于第二条日志，您可能会遇到以下情况之一：

- 场景 1：
  - `json.message`、`json.jira_status_code` 和 `json.jira_body` 存在。
  - `json.message` 为 `Proxy lifecycle event received error response` 或类似内容。
  - `json.jira_status_code` 和 `json.jira_body` 可能包含从极狐GitLab 私有化部署实例或实例前面的代理收到的响应。
  - 如果 `json.jira_status_code` 为 `401 Unauthorized` 且 `json.jira_body` 为 `(empty)`：
    - [**Jira Connect 代理 URL**](jira_cloud_app.md#set-up-your-instance-for-atlassian-marketplace-installation) 可能未设置为 `https://gitlab.com`。
    - 极狐GitLab 私有化部署实例可能阻止了出站连接。确保您的
      极狐GitLab 私有化部署实例可以同时连接到 `connect-install-keys.atlassian.com`
      和 `gitlab.com`。
    - 极狐GitLab 私有化部署实例无法解密来自 Jira 的 JWT 令牌。
      [`exceptions_json.log`](../logs/_index.md#exceptions_jsonlog) 包含有关该错误的更多信息。
    - 如果您的极狐GitLab 私有化部署实例前面有[反向代理](jira_cloud_app.md#using-a-reverse-proxy)，
      则发送到极狐GitLab 私有化部署实例的 `Host` 头可能与反向代理 FQDN 不匹配。
      检查极狐GitLab 私有化部署实例上的 [Workhorse 日志](../logs/_index.md#workhorse-logs)：

      ```shell
      grep /-/jira_connect/events/installed /var/log/gitlab/gitlab-workhorse/current
      ```

      输出可能包含以下内容：

      ```json
      {
        "host":"gitlab.mycompany.com:443", // The host should match the reverse proxy FQDN entered into the GitLab for Jira Cloud app
        "remote_ip":"34.74.226.3", // This IP should be within the GitLab.com IP range https://docs.gitlab.com/user/gitlab_com/#ip-range
        "status":401,
        "uri":"/-/jira_connect/events/installed"
      }
      ```

  - 如果 `json.jira_status_code` 为 `404 Not Found` 且 `json.jira_body` 包含典型极狐GitLab 404 页面的 HTML，请确认
    极狐GitLab 私有化部署实例上的[集成允许列表](project_integration_management.md#integration-allowlist)允许极狐GitLab for Jira Cloud 应用。

- 场景 2：
  - `json.exception.class` 和 `json.exception.message` 存在。
  - `json.exception.class` 和 `json.exception.message` 指示在联系极狐GitLab 私有化部署实例时是否出现问题。

<a id="error-the-jira-user-is-not-a-site-or-organization-administrator"></a>

## 错误：`The Jira user is not a site or organization administrator`

当您尝试关联极狐GitLab 群组时，可能会收到以下错误之一：

```plaintext
The Jira user is not a site or organization administrator. Check the permissions in Jira and try again.
```

```plaintext
Failed to link group. Please try again.
```

当 Jira 用户不是 `site-admins` 或
`org-admins` 群组的成员时，会出现此问题。极狐GitLab 通过调用 Jira API
端点 `/rest/api/3/user?expand=groups` 并验证用户是否属于
这两个群组之一来检查群组成员资格。

用户可以在
[Atlassian 组织](https://admin.atlassian.com) 中显示为站点管理员并拥有完整
管理员权限，但如果未明确将其添加到 `site-admins` 或
`org-admins` 群组，则极狐GitLab 权限检查会失败。这也意味着
通过自定义群组或特定产品角色分配的管理员权限
不会被极狐GitLab 检测到。

要解决此问题，请将 Jira 用户添加到 `org-admins` 或 `site-admins`
群组：

1. 登录您的 [Atlassian 组织](https://admin.atlassian.com)。
1. 转到 **目录** > **群组**。
1. 选择 `org-admins` 群组（推荐）或 `site-admins` 群组。
   如果该群组不存在，请
   [创建它](https://support.atlassian.com/user-management/docs/create-groups/)。
1. 将 Jira 用户添加到该群组。

有关 Jira 用户要求的更多信息，请参阅
[Jira 用户要求](jira_cloud_app.md#jira-user-requirements)。

由于 OAuth 范围限制，极狐GitLab 无法直接使用 Jira 权限 API 检查管理员状态。有关更多背景信息，请参阅
[议题 #420687](https://gitlab.com/gitlab-org/gitlab/-/issues/420687)
和
[合并请求 !135771](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/135771)。

<a id="error-failed-to-link-group"></a>

## 错误：`Failed to link group`

当您关联群组时，可能会收到以下错误：

```plaintext
Failed to link group. Please try again.
```

此错误可能由多种原因导致。

- 如果因权限不足而无法从 Jira 获取用户信息，则可能返回 `403 Forbidden`。
  要解决此问题，请确保安装和配置应用的 Jira 用户
  满足某些[要求](jira_cloud_app.md#jira-user-requirements)。

- 如果您对[反向代理](jira_cloud_app.md#using-a-reverse-proxy)使用 `rewrite` 或 `sub_filter` 指令，也可能出现此错误。
  请求中使用的应用密钥包含部分服务器主机名，某些反向代理过滤器可能会捕获该主机名。
  Atlassian 和极狐GitLab 中的应用密钥必须匹配，身份验证才能正常工作。

- 如果首次安装极狐GitLab for Jira Cloud 应用时极狐GitLab 实例最初配置错误，则可能发生此错误。在这种情况下，可能需要删除 `jira_connect_installation`
  表中的数据。只有确定不需要保留任何现有的
  极狐GitLab for Jira 应用安装时，才应删除此数据。

  1. 从任何 Jira 项目中卸载极狐GitLab for Jira Cloud 应用。
  1. 要删除记录，请在 [GitLab Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 中运行此命令：

     ```ruby
     JiraConnectInstallation.delete_all
     ```

<a id="error-failed-to-load-jira-connect-application-id"></a>

## 错误：`Failed to load Jira Connect Application ID`

当您将应用指向您的极狐GitLab 私有化部署实例后登录极狐GitLab for Jira Cloud 应用时，可能会收到以下错误：

```plaintext
Failed to load Jira Connect Application ID. Please try again.
```

当您检查浏览器控制台时，可能还会看到以下消息：

```plaintext
Cross-Origin Request Blocked: The Same Origin Policy disallows reading the remote resource at https://gitlab.example.com/-/jira_connect/oauth_application_id. (Reason: CORS header 'Access-Control-Allow-Origin' missing). Status code: 403.
```

要解决此问题：

1. 确保 `/-/jira_connect/oauth_application_id` 可公开访问并返回 JSON 响应：

   ```shell
   curl --include "https://gitlab.example.com/-/jira_connect/oauth_application_id"
   ```

1. 如果您[从官方 Atlassian 市场列表安装了应用](jira_cloud_app.md#install-the-gitlab-for-jira-cloud-app-from-the-atlassian-marketplace)，
   请确保 [**Jira Connect 代理 URL**](jira_cloud_app.md#set-up-your-instance-for-atlassian-marketplace-installation) 设置为 `https://gitlab.com`，且没有尾随斜杠。

<a id="error-missing-required-parameter-client_id"></a>

## 错误：`Missing required parameter: client_id`

当您将应用指向您的极狐GitLab 私有化部署实例后登录极狐GitLab for Jira Cloud 应用时，可能会收到以下错误：

```plaintext
Missing required parameter: client_id
```

要解决此问题，请确保您的安装方法的所有先决条件均已满足：

- [连接极狐GitLab for Jira Cloud 应用的先决条件](jira_cloud_app.md#prerequisites)
- [手动安装极狐GitLab for Jira Cloud 应用的先决条件](jira_cloud_app.md#prerequisites-1)

<a id="error-failed-to-sign-in-to-gitlab"></a>

## 错误：`Failed to sign in to GitLab`

当您将应用指向您的极狐GitLab 私有化部署实例后登录极狐GitLab for Jira Cloud 应用时，可能会收到以下错误：

```plaintext
Failed to sign in to GitLab
```

要解决此问题，请确保为应用创建的 [OAuth 应用](jira_cloud_app.md#set-up-oauth-authentication) 中的 **受信任** 和 **机密** 复选框已清除。
如果错误仍然存在，请参阅 [议题 581765](https://gitlab.com/gitlab-org/gitlab/-/work_items/581765)。

<a id="chrome-142-and-later-blocks-local-network-requests"></a>

### Chrome 142 及更高版本阻止本地网络请求

如果您的极狐GitLab 私有化部署实例位于本地或专用网络上，则 Chrome
142 及更高版本会因其
[本地网络访问](https://developer.chrome.com/blog/local-network-access)
策略而阻止来自 Jira Cloud 的连接。Chrome 会将此显示为 `Failed to sign in to GitLab` 消息，或在
开发者控制台中显示为 `ERR_BLOCKED_BY_PRIVATE_NETWORK_ACCESS_CHECKS`。

极狐GitLab 无法从极狐GitLab 侧解决此限制，因为
Jira Cloud 中的父 iframe 必须授予该权限。要在限制持续存在时继续使用该
应用，请使用以下变通方法之一：

- 从 Firefox 或 Safari 登录，它们不强制执行本地网络访问。
- 请您的管理员为 `*.atlassian.net` 部署 Chrome 企业策略
  [`LocalNetworkAllowedForUrls`](https://chromeenterprise.google/policies/#LocalNetworkAllowedForUrls)，以便绕过提示。

有关跟踪，请参阅 [议题 581765](https://gitlab.com/gitlab-org/gitlab/-/work_items/581765)。
