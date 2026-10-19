---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 解决 Jira 议题集成的议题链接和评论权限错误。
title: 故障排除 Jira 议题集成
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 [Jira 议题集成](configure.md)时，您可能会遇到以下问题。

<a id="gitlab-cannot-link-to-a-jira-issue"></a>

## 极狐GitLab 无法链接到 Jira 议题

当您在极狐GitLab 中提及 Jira 议题 ID 时，议题链接可能会缺失。[`sidekiq.log`](../../administration/logs/_index.md#sidekiq-logs)中可能包含以下异常：

```plaintext
No Link Issue Permission for issue 'JIRA-1234'
```

要解决此问题，请确保您为 [Jira 议题集成](configure.md)创建的 Jira 用户具有链接议题的权限。

<a id="gitlab-cannot-comment-on-a-jira-issue"></a>

## 极狐GitLab 无法评论 Jira 议题

如果极狐GitLab 无法评论 Jira 议题，请确保您为 [Jira 议题集成](configure.md)创建的 Jira 用户具有以下权限：

- 在 Jira 议题上发布评论。
- 转换 Jira 议题。

当 [GitLab 议题跟踪器](../external-issue-tracker.md)关闭时，Jira 议题引用和评论将无法正常工作。如果您[限制 Jira 访问的 IP 地址](https://support.atlassian.com/security-and-access-policies/docs/specify-ip-addresses-for-product-access/)，请确保将您的极狐GitLab 私有化部署 IP 地址或 [JihuLab.com IP 地址](../../user/jihulab_com/_index.md#ip-range)添加到 Jira 的允许名单中。

要了解根本原因，请检查 [`integrations_json.log`](../../administration/logs/_index.md#integrations_jsonlog) 文件。当极狐GitLab 尝试评论 Jira 议题时，可能会出现 `Error sending message` 日志条目。

发生错误时，`integrations_json.log` 文件会在发往 Jira 的 API 请求中包含 `client_*` 键。您可以使用 `client_*` 键查阅 [Atlassian API 文档](https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-group-issues)，了解错误发生的原因。

在以下示例中，Jira 响应 `404 Not Found`。此错误可能在以下情况下发生：

- 您为 Jira 议题集成创建的 Jira 用户没有查看该议题的权限。
- 您指定的 Jira 议题 ID 不存在。

```json
{
  "severity": "ERROR",
  "time": "2023-07-25T21:38:56.510Z",
  "message": "Error sending message",
  "client_url": "https://my-jira-cloud.atlassian.net",
  "client_path": "/rest/api/2/issue/ALPHA-1",
  "client_status": "404",
  "exception.class": "JIRA::HTTPError",
  "exception.message": "Not Found",
}
```

有关返回状态码的更多信息，请参阅 [Jira Cloud 平台 REST API 文档](https://developer.atlassian.com/cloud/jira/platform/rest/v2/api-group-issues/#api-rest-api-2-issue-issueidorkey-get-response)。

<a id="using-curl-to-verify-access-to-a-jira-issue"></a>

### 使用 `curl` 验证对 Jira 议题的访问权限

要验证 Jira 用户能否访问特定的 Jira 议题，请运行以下脚本：

```shell
curl --verbose --user "$USER:$API_TOKEN" "https://$ATLASSIAN_SUBDOMAIN.atlassian.net/rest/api/2/issue/$JIRA_ISSUE"
```

如果该用户可以访问该议题，Jira 会响应 `200 OK`，并且返回的 JSON 中包含 Jira 议题详情。

<a id="verify-gitlab-can-post-a-comment-to-a-jira-issue"></a>

### 验证极狐GitLab 能否向 Jira 议题发布评论

> [!warning]
> 更改数据的命令如果未正确运行或在不当条件下运行，可能会造成损害。请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

为帮助您对 Jira 议题集成进行故障排除，您可以使用项目的 Jira 集成设置检查极狐GitLab 能否向 Jira 议题发布评论。

为此：

- 在 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session)中，
  运行以下命令：

  ```ruby
  jira_issue_id = "ALPHA-1" # Change to your Jira issue ID
  project = Project.find_by_full_path("group/project") # Change to your project's path

  integration = project.integrations.find_by(type: "Integrations::Jira")
  jira_issue = integration.client.Issue.find(jira_issue_id)
  jira_issue.comments.build.save!(body: 'This is a test comment from GitLab via the Rails console')
  ```

如果命令执行成功，则会向该 Jira 议题添加一条评论。

<a id="gitlab-cannot-create-a-jira-issue"></a>

## 极狐GitLab 无法创建 Jira 议题

当您尝试从漏洞创建 Jira 议题时，可能会看到“field is required”错误。例如，`Components is required`，因为缺少名为“Components”的字段。出现此问题是因为 Jira 配置了一些必填字段，而极狐GitLab 未传递这些字段。要变通解决此问题：

1. 在 Jira 实例中创建一个新的“Vulnerability”[议题类型](https://support.atlassian.com/jira-cloud-administration/docs/what-are-issue-types/)。
1. 将新议题类型分配给该项目。
1. 将项目中的所有“Vulnerabilities”的字段方案改为不需要该缺失字段。

<a id="gitlab-cannot-close-a-jira-issue"></a>

## 极狐GitLab 无法关闭 Jira 议题

如果极狐GitLab 无法关闭 Jira 议题：

- 确保您在 Jira 设置中设置的转换 ID 与您的项目关闭议题所必须使用的转换 ID 一致。更多信息，请参阅
  [自动议题转换](issues.md#automatic-issue-transitions)和[自定义议题转换](issues.md#custom-issue-transitions)。
- 确保该 Jira 议题尚未标记为已解决：
  - 检查 Jira 议题的解决字段未设置。
  - 检查该议题在 Jira 列表中未被划掉。

<a id="captcha-after-failed-sign-in-attempts"></a>

## 登录失败尝试后出现 CAPTCHA

连续多次登录失败尝试后可能会触发 CAPTCHA。这些失败尝试在测试 Jira 议题集成设置时可能会导致 `401 Unauthorized`。
如果已触发 CAPTCHA，您将无法使用 Jira REST API
向 Jira 站点进行身份验证。

要解决此问题，请登录您的 Jira 实例并完成 CAPTCHA。

<a id="integration-does-not-work-for-an-imported-project"></a>

## 集成对导入的项目不起作用

在极狐GitLab 19.0 及更早版本中，Jira 议题集成可能对导入的项目不起作用。更多信息，请参阅[议题 341571](https://gitlab.com/gitlab-org/gitlab/-/issues/341571)。

要解决此问题，请先关闭该集成，然后再重新开启。

<a id="not-all-jira-issues-appear-in-the-development-panel"></a>

## 并非所有 Jira 议题都显示在开发面板中

如果某个提交、分支、合并请求、构建、部署或功能标志引用了许多 Jira 议题，则其中一些被引用的议题可能会从 Jira 开发面板中缺失。

对于单个提交、分支、合并请求、构建、部署或功能标志，Jira 最多接受 500 个 Jira 议题键。当极狐GitLab 从这些实体之一中提取超过 500 个不同的 Jira 议题键时，它只会将前 500 个发送给 Jira。这是 Jira 平台的限制，而非极狐GitLab 的缺陷。

要解决此问题，请减少单个提交、分支、合并请求、构建、部署或功能标志中引用的不同 Jira 议题键的数量。

<a id="error-certificate-verify-failed"></a>

## 错误：`certificate verify failed`

当您测试 Jira 议题集成设置时，可能会收到以下错误：

```plaintext
Connection failed. Check your integration settings. SSL_connect returned=1 errno=0 peeraddr=<jira.example.com> state=error: certificate verify failed (unable to get local issuer certificate)
```

此错误也可能出现在 [`integrations_json.log`](../../administration/logs/_index.md#integrations_jsonlog) 文件中：

```json
{
  "severity":"ERROR",
  "integration_class":"Integrations::Jira",
  "message":"Error sending message",
  "exception.class":"OpenSSL::SSL::SSLError",
  "exception.message":"SSL_connect returned=1 errno=0 peeraddr=x.x.x.x:443 state=error: certificate verify failed (unable to get local issuer certificate)",
}
```

出现此错误是因为 Jira 证书不受公开信任，或者证书链不完整。在此问题解决之前，极狐GitLab 不会连接到 Jira。

要解决此问题，请参阅[常见 SSL 错误](https://gitlab.cn/docs/omnibus/settings/ssl/ssl_troubleshooting/#common-ssl-errors)。

<a id="change-all-jira-projects-to-instance-level-or-group-level-values"></a>

## 将所有 Jira 项目更改为实例级或群组级值

> [!warning]
> 更改数据的命令如果未正确运行或在不当条件下运行，可能会造成损害。请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

<a id="change-all-projects-on-an-instance"></a>

### 更改实例上的所有项目

要将所有 Jira 项目更改为使用该实例的集成设置：

1. 在 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session)中，运行以下命令：

   ```ruby
   Integrations::Jira.where(active: true, instance: false, inherit_from_id: nil).find_each do |integration|
     default_integration = Integration.default_integration(integration.type, integration.project)

     integration.inherit_from_id = default_integration.id

     if integration.save(context: :manual_change)
       if Gitlab.version_info >= Gitlab::VersionInfo.new(16, 9)
         Integrations::Propagation::BulkUpdateService.new(default_integration, [integration]).execute
       else
         BulkUpdateIntegrationService.new(default_integration, [integration]).execute
       end
     end
   end
   ```

1. 从 UI 中修改并保存该实例的集成，以将更改传播到所有群组和项目集成。

<a id="change-all-projects-in-a-group"></a>

### 更改群组中的所有项目

要将群组（及其子群组）中的所有 Jira 项目更改为使用该群组的集成设置：

- 在 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session)中，运行以下命令：

  ```ruby
  def reset_integration(target)
    integration = target.integrations.find_by(type: Integrations::Jira)

    return if integration.nil? # Skip if the project has no Jira issues integration
    return unless integration.inherit_from_id.nil? # Skip integrations that are already inheriting

    default_integration = Integration.default_integration(integration.type, target)

    integration.inherit_from_id = default_integration.id

    if integration.save(context: :manual_change)
      if Gitlab.version_info >= Gitlab::VersionInfo.new(16, 9)
        Integrations::Propagation::BulkUpdateService.new(default_integration, [integration]).execute
      else
        BulkUpdateIntegrationService.new(default_integration, [integration]).execute
      end
    end
  end

  parent_group = Group.find_by_full_path('top-level-group') # Add the full path of your top-level group
  current_user = User.find_by_username('admin-user') # Add the username of a user with administrator access

  unless parent_group.nil?
    groups = GroupsFinder.new(current_user, { parent: parent_group, include_parent_descendants: true }).execute

    # Reset any projects in subgroups to use the parent group integration settings
    groups.find_each do |group|
      reset_integration(group)

      group.projects.find_each do |project|
        reset_integration(project)
      end
    end

    # Reset any direct projects in the parent group to use the parent group integration settings
    parent_group.projects.find_each do |project|
      reset_integration(project)
    end
  end
  ```

<a id="update-the-integration-password-for-all-projects"></a>

## 更新所有项目的集成密码

> [!warning]
> 更改数据的命令如果未正确运行或在不当条件下运行，可能会造成损害。请始终先在测试环境中运行命令，并准备好可恢复的备份实例。

要为所有启用了 Jira 议题集成的项目重置 Jira 用户的密码，请在 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session)中运行以下命令：

```ruby
p = Project.find_by_sql("SELECT p.id FROM projects p LEFT JOIN integrations i ON p.id = i.project_id WHERE i.type_new = 'Integrations::Jira' AND i.active = true")

p.each do |project|
  project.jira_integration.update_attribute(:password, '<your-new-password>')
end
```

<a id="jira-issue-list"></a>

## Jira 议题列表

在极狐GitLab 中[查看 Jira 议题](configure.md#view-jira-issues)时，您可能会遇到以下问题。

<a id="error-500-were-sorry"></a>

### 错误：`500 We're sorry`

当您在极狐GitLab 中访问 Jira 议题时，可能会收到 `500 We're sorry. Something went wrong on our end` 错误。请检查 [`production.log`](../../administration/logs/_index.md#productionlog)，查看该文件中是否包含以下异常：

```plaintext
:NoMethodError (undefined method 'duedate' for #<JIRA::Resource::Issue:0x00007f406d7b3180>)
```

如果是这种情况，请确保 **截止日期** 文本框在集成的 Jira 项目中[对议题可见](https://confluence.atlassian.com/jirakb/due-date-field-is-missing-189431917.html)。

<a id="error-an-error-occurred-while-requesting-data-from-jira"></a>

### 错误：`An error occurred while requesting data from Jira`

当您尝试在极狐GitLab 中查看 Jira 议题列表或创建 Jira 议题时，可能会收到以下错误之一：

```plaintext
An error occurred while requesting data from Jira
```

```plaintext
An error occurred while fetching issue list. Connection failed. Check your integration settings.
```

这些错误在 Jira 议题集成的身份验证不完整或不正确时发生。

要解决此问题，请[重新配置 Jira 议题集成](configure.md#configure-the-integration)。确保身份验证详情正确，重新输入您的 API 令牌或密码，然后保存更改。

<a id="errors-with-jira-credentials"></a>

### Jira 凭据错误

当您尝试在极狐GitLab 中查看 Jira 议题列表时，可能会看到以下错误之一。

<a id="error-the-value-project-does-not-exist-for-the-field-project"></a>

#### 错误：`The value '<project>' does not exist for the field 'project'`

如果您为 Jira 安装使用了错误的身份验证凭据，可能会看到此错误：

```plaintext
An error occurred while requesting data from Jira:
The value '<project>' does not exist for the field 'project'.
Check your Jira issues integration configuration and try again.
```

身份验证凭据取决于您的 Jira 安装类型：

- **对于 Jira Cloud**，您必须拥有 Jira Cloud API 令牌
  以及您用于创建该令牌的电子邮件地址。
- **对于 Jira Data Center 或 Jira Server**，您必须拥有 Jira 用户名和密码
  或 Jira 个人访问令牌。

更多信息，请参阅 [Jira 议题集成](configure.md)。

要解决此问题，请更新身份验证凭据，使其与您的 Jira 安装相匹配。

<a id="error-the-credentials-for-accessing-jira-are-not-allowed-to-access-the-data"></a>

#### 错误：`The credentials for accessing Jira are not allowed to access the data`

如果您的 Jira 凭据无法访问您在 [Jira 议题集成](configure.md#configure-the-integration)中指定的 Jira 项目键，可能会看到此错误：

```plaintext
The credentials for accessing Jira are not allowed to access the data.
Check your Jira issues integration credentials and try again.
```

> [!warning]
> Atlassian 已于 2024 年 10 月 31 日弃用 Jira Cloud 的旧版 JQL 搜索端点
> （`GET/POST /rest/api/2/search`），并计划于 2025 年 5 月 1 日移除。
> Jira Server 和 Data Center 继续使用 `/rest/api/2/search` 端点。
> 更多信息，请参阅 [Atlassian 弃用通知](https://developer.atlassian.com/changelog/#CHANGE-2046)。

要解决此问题，请确保您在 Jira 议题集成中配置的 Jira 用户具有查看与指定 Jira 项目键关联的议题的权限。

要验证该 Jira 用户是否具有此权限，请执行以下操作之一：

{{< tabs >}}

{{< tab title="Jira Cloud" >}}

- 在浏览器中，使用您在 Jira 议题集成中配置的用户登录 Jira。由于 Jira API 支持
  基于 cookie 的身份验证，您可以查看浏览器中是否返回了任何议题：

  ```plaintext
  https://<ATLASSIAN_SUBDOMAIN>.atlassian.net/rest/api/3/search/jql?jql=project=<JIRA_PROJECT_KEY>
  ```

- 使用 `curl` 进行 HTTP 基本身份验证以访问 API，并查看是否返回了任何议题：

  ```shell
  curl --verbose --user "$JIRA_EMAIL:$JIRA_API_TOKEN" \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --request POST \
    --data '{"jql":"project='$JIRA_PROJECT_KEY'"}' \
    "https://$ATLASSIAN_SUBDOMAIN.atlassian.net/rest/api/3/search/jql" | jq
  ```

API 响应会返回一个 JSON 响应：

- `issues` 包含与 Jira 项目键匹配的议题数组。
- 如果有更多结果需要获取，则会提供 `nextPageToken`。

有关返回状态码和 API 详情的更多信息，请参阅
[使用 JQL 增强搜索搜索议题（POST）](https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-search/#api-rest-api-3-search-jql-post)。

{{< /tab >}}

{{< tab title="Jira Server/Data Center" >}}

- 在浏览器中，使用您在 Jira 议题集成中配置的用户登录 Jira。由于 Jira API 支持
  基于 cookie 的身份验证，您可以查看浏览器中是否返回了任何议题：

  ```plaintext
  <JIRA_SERVER_URL>/rest/api/2/search?jql=project=<JIRA_PROJECT_KEY>
  ```

- 使用 `curl` 进行 HTTP 基本身份验证以访问 API，并查看是否返回了任何议题：

  ```shell
  curl --verbose --header 'Authorization: Bearer '$JIRA_API_TOKEN'' \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --request POST \
    --data '{"jql":"project='$JIRA_PROJECT_KEY'"}' \
    "$JIRA_SERVER_URL/rest/api/2/search" | jq
  ```

API 响应会返回一个 JSON 响应：

- `issues` 包含与 Jira 项目键匹配的议题数组。
- 如果有更多结果需要获取，则会提供 `total`。

有关返回状态码和 API 详情的更多信息，请参阅
[使用 JQL 执行搜索（POST）](https://developer.atlassian.com/server/jira/platform/rest/v10007/api-group-search/#api-api-2-search-post)。

{{< /tab >}}

{{< /tabs >}}
