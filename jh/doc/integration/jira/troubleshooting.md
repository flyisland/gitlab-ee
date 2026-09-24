---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 Jira 议题集成问题
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 [Jira 议题集成](configure.md) 时，您可能会遇到以下问题。

<a id="gitlab-cannot-link-to-a-jira-issue"></a>

## 极狐GitLab 无法链接到 Jira 议题

当您在极狐GitLab 中提及 Jira 议题 ID 时，议题链接可能会丢失。[`sidekiq.log`](../../administration/logs/_index.md#sidekiq-logs) 可能包含以下异常：

```plaintext
对于议题 'JIRA-1234'，没有链接议题的权限
```

要解决此问题，请确保您为 [Jira 议题集成](configure.md) 创建的 Jira 用户具有链接议题的权限。

<a id="gitlab-cannot-comment-on-a-jira-issue"></a>

## 极狐GitLab 无法对 Jira 议题进行评论

如果极狐GitLab 无法对 Jira 议题进行评论，请确保您为 [Jira 议题集成](configure.md) 创建的 Jira 用户具有以下权限：

- 在 Jira 议题上发布评论。
- 转换 Jira 议题。

当 [极狐GitLab 议题跟踪器](../external-issue-tracker.md) 被禁用时，Jira 议题引用和评论将不起作用。
如果您 [限制 Jira 访问的 IP 地址](https://support.atlassian.com/security-and-access-policies/docs/specify-ip-addresses-for-product-access/)，请确保将您的极狐GitLab 私有化部署的 IP 地址或 [极狐GitLab IP 地址](../../user/jihulab_com/_index.md#ip-range) 添加到 Jira 的允许列表中。

要查找根本原因，请检查 [`integrations_json.log`](../../administration/logs/_index.md#integrations_jsonlog) 文件。当极狐GitLab 尝试对 Jira 议题进行评论时，可能会显示 `发送消息错误` 日志条目。

在极狐GitLab 16.1 及更高版本中，当发生错误时，`integrations_json.log` 文件会在发往 Jira 的传出 API 请求中包含 `client_*` 键。您可以使用 `client_*` 键来查阅 [Atlassian API 文档](https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-group-issues) 以了解发生错误的原因。

在以下示例中，Jira 返回了 `404 未找到`。如果出现以下情况，可能会发生此错误：

- 您为 Jira 议题集成创建的 Jira 用户无权查看该议题。
- 您指定的 Jira 议题 ID 不存在。

```json
{
  "severity": "ERROR",
  "time": "2023-07-25T21:38:56.510Z",
  "message": "发送消息错误",
  "client_url": "https://my-jira-cloud.atlassian.net",
  "client_path": "/rest/api/2/issue/ALPHA-1",
  "client_status": "404",
  "exception.class": "JIRA::HTTPError",
  "exception.message": "未找到"
}
```

有关返回状态码的更多信息，请参阅 [Jira Cloud 平台 REST API 文档](https://developer.atlassian.com/cloud/jira/platform/rest/v2/api-group-issues/#api-rest-api-2-issue-issueidorkey-get-response)。

<a id="using-curl-to-verify-access-to-a-jira-issue"></a>

### 使用 `curl` 验证对 Jira 议题的访问权限

要验证 Jira 用户能否访问特定的 Jira 议题，请运行以下脚本：

```shell
curl --verbose --user "$USER:$API_TOKEN" "https://$ATLASSIAN_SUBDOMAIN.atlassian.net/rest/api/2/issue/$JIRA_ISSUE"
```

如果用户可以访问该议题，Jira 会返回 `200 成功`，且返回的 JSON 中包含 Jira 议题的详细信息。

<a id="verify-gitlab-can-post-a-comment-to-a-jira-issue"></a>

### 验证极狐GitLab 能否向 Jira 议题发布评论

> [!warning]
> 如果命令未正确运行或在适当条件下运行，更改数据的命令可能会造成损害。请务必先在测试环境中运行命令，并准备好备份实例以便恢复。

为了帮助排查您的 Jira 议题集成问题，您可以检查极狐GitLab 是否能够使用项目的 Jira 集成设置向 Jira 议题发布评论。

为此：

- 在 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session) 中，运行以下命令：

  ```ruby
  jira_issue_id = "ALPHA-1" # 更改为您的 Jira 议题 ID
  project = Project.find_by_full_path("group/project") # 更改为您的项目路径

  integration = project.integrations.find_by(type: "Integrations::Jira")
  jira_issue = integration.client.Issue.find(jira_issue_id)
  jira_issue.comments.build.save!(body: '这是通过 Rails 控制台从极狐GitLab 发送的测试评论')
  ```

如果命令成功，评论会添加到 Jira 议题中。

<a id="gitlab-cannot-create-a-jira-issue"></a>

## 极狐GitLab 无法创建 Jira 议题

当您尝试从漏洞创建 Jira 议题时，可能会看到“字段为必填项”错误。例如，`Components 为必填项`，因为名为“Components”的字段缺失。发生这种情况是因为 Jira 配置了一些必填字段，但极狐GitLab 未传递这些字段。要解决此问题：

1. 在 Jira 实例中创建一个新的“Vulnerability” [议题类型](https://support.atlassian.com/jira-cloud-administration/docs/what-are-issue-types/)。
1. 将新的议题类型分配给项目。
1. 修改项目中所有“Vulnerabilities”的字段方案，使其不要求缺失的字段。

<a id="gitlab-cannot-close-a-jira-issue"></a>

## 极狐GitLab 无法关闭 Jira 议题

如果极狐GitLab 无法关闭 Jira 议题：

- 确保您在 Jira 设置中设置的转换 ID 与项目关闭议题所需的转换 ID 匹配。有关更多信息，请参阅 [自动议题转换](issues.md#automatic-issue-transitions) 和 [自定义议题转换](issues.md#custom-issue-transitions)。
- 确保 Jira 议题尚未标记为已解决：
  - 检查 Jira 议题的解决字段未设置。
  - 检查议题在 Jira 列表中未被划掉。

<a id="captcha-after-failed-sign-in-attempts"></a>

## 登录尝试失败后出现 CAPTCHA

连续登录尝试失败后可能会触发 CAPTCHA。在测试 Jira 议题集成设置时，这些失败的尝试可能会导致 `401 未授权`。如果触发了 CAPTCHA，则无法使用 Jira REST API 对 Jira 站点进行身份验证。

要解决此问题，请登录您的 Jira 实例并完成 CAPTCHA。

<a id="integration-does-not-work-for-an-imported-project"></a>

## 集成对导入的项目不起作用

Jira 议题集成可能对已导入的项目不起作用。

要解决此问题，请先禁用集成，然后再重新启用。

<a id="error-certificate-verify-failed"></a>

## 错误：`证书验证失败`

当您测试 Jira 议题集成设置时，您可能会看到以下错误：

```plaintext
连接失败。请检查您的集成设置。SSL_connect 返回=1 errno=0 peeraddr=<jira.example.com> state=error: 证书验证失败（无法获取本地颁发者证书）
```

该错误也可能出现在 [`integrations_json.log`](../../administration/logs/_index.md#integrations_jsonlog) 文件中：

```json
{
  "severity":"ERROR",
  "integration_class":"Integrations::Jira",
  "message":"发送消息错误",
  "exception.class":"OpenSSL::SSL::SSLError",
  "exception.message":"SSL_connect 返回=1 errno=0 peeraddr=x.x.x.x:443 state=error: 证书验证失败（无法获取本地颁发者证书）"
}
```

该错误发生的原因是 Jira 证书不受公共信任或证书链不完整。在此问题解决之前，极狐GitLab 不会连接到 Jira。

要解决此问题，请参阅 [常见的 SSL 错误](https://gitlab.cn/docs/omnibus/settings/ssl/ssl_troubleshooting/#common-ssl-errors)。

<a id="change-all-jira-projects-to-instance-level-or-group-level-values"></a>

## 将所有 Jira 项目更改为实例级或群组级的值

> [!warning]
> 如果命令未正确运行或在适当条件下运行，更改数据的命令可能会造成损害。请务必先在测试环境中运行命令，并准备好备份实例以便恢复。

<a id="change-all-projects-on-an-instance"></a>

### 更改实例上的所有项目

要将所有 Jira 项目更改为使用实例级集成设置：

1. 在 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session) 中，运行以下命令：

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

1. 从 UI 修改并保存实例级集成，以将更改传播到所有群组级和项目级集成。

<a id="change-all-projects-in-a-group"></a>

### 更改群组中的所有项目

要将群组（及其子群组）中的所有 Jira 项目更改为使用群组级集成设置：

- 在 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session) 中，运行以下命令：

  ```ruby
  def reset_integration(target)
    integration = target.integrations.find_by(type: Integrations::Jira)

    return if integration.nil? # 如果项目没有 Jira 议题集成，则跳过
    return unless integration.inherit_from_id.nil? # 跳过已经继承的集成

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

  parent_group = Group.find_by_full_path('top-level-group') # 添加您的顶级群组的完整路径
  current_user = User.find_by_username('admin-user') # 添加具有管理员访问权限的用户的用户名

  unless parent_group.nil?
    groups = GroupsFinder.new(current_user, { parent: parent_group, include_parent_descendants: true }).execute

    # 重置子群组中的任何项目以使用父群组集成设置
    groups.find_each do |group|
      reset_integration(group)

      group.projects.find_each do |project|
        reset_integration(project)
      end
    end

    # 重置父群组中的直属项目以使用父群组集成设置
    parent_group.projects.find_each do |project|
      reset_integration(project)
    end
  end
  ```

<a id="update-the-integration-password-for-all-projects"></a>

## 更新所有项目的集成密码

> [!warning]
> 如果命令未正确运行或在适当条件下运行，更改数据的命令可能会造成损害。请务必先在测试环境中运行命令，并准备好备份实例以便恢复。

要重置具有活跃 Jira 议题集成的所有项目的 Jira 用户密码，请在 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session) 中运行以下命令：

```ruby
p = Project.find_by_sql("SELECT p.id FROM projects p LEFT JOIN integrations i ON p.id = i.project_id WHERE i.type_new = 'Integrations::Jira' AND i.active = true")

p.each do |project|
  project.jira_integration.update_attribute(:password, '<您的新密码>')
end
```

<a id="jira-issue-list"></a>

## Jira 议题列表

当在极狐GitLab 中 [查看 Jira 议题](configure.md#view-jira-issues) 时，您可能会遇到以下问题。

<a id="error-500-were-sorry"></a>

### 错误：`500 抱歉`

当您在极狐GitLab 中访问 Jira 议题时，可能会遇到 `500 抱歉，我们这边出了问题` 错误。
检查 [`production.log`](../../administration/logs/_index.md#productionlog) 文件，查看是否包含以下异常：

```plaintext
:NoMethodError (对于 #<JIRA::Resource::Issue:0x00007f406d7b3180>，未定义的方法 'duedate')
```

如果确实如此，请确保集成的 Jira 项目中 **截止日期** 字段 [对议题可见](https://confluence.atlassian.com/jirakb/due-date-field-is-missing-189431917.html)。

<a id="error-an-error-occurred-while-requesting-data-from-jira"></a>

### 错误：`从 Jira 请求数据时发生错误`

当您尝试在极狐GitLab 中查看 Jira 议题列表或创建 Jira 议题时，可能会遇到以下错误之一：

```plaintext
从 Jira 请求数据时发生错误
```

```plaintext
获取议题列表时发生错误。连接失败。请检查您的集成设置。
```

当 Jira 议题集成的身份验证未完成或不正确时，会出现这些错误。
要解决此问题，请再次 [配置 Jira 议题集成](configure.md#configure-the-integration)。确保身份验证详细信息正确，重新输入您的 API 令牌或密码，然后保存更改。

如果项目键包含保留的 JQL 单词，Jira 议题列表将不会加载。您的 Jira 项目键不得包含 [限制的单词和字符](https://confluence.atlassian.com/jirasoftwareserver/advanced-searching-939938733.html#Advancedsearching-restrictionsRestrictedwordsandcharacters)。

<a id="errors-with-jira-credentials"></a>

### Jira 凭据错误

当您尝试在极狐GitLab 中查看 Jira 议题列表时，可能会看到以下错误之一。

<a id="error-the-value-project-does-not-exist-for-the-field-project"></a>

#### 错误：`值 '<project>' 对于字段 'project' 不存在`

如果您为 Jira 安装使用错误的身份验证凭据，您可能会看到此错误：

```plaintext
从 Jira 请求数据时发生错误：
字段 'project' 的值 '<project>' 不存在。
请检查您的 Jira 议题集成配置，然后重试。
```

身份验证凭据取决于您的 Jira 安装类型：

- **对于 Jira Cloud**，您必须有 Jira Cloud API 令牌和用于创建令牌的电子邮件地址。
- **对于 Jira Data Center 或 Jira Server**，您必须有 Jira 用户名和密码，或者，在极狐GitLab 16.0 及更高版本中，使用 Jira 个人访问令牌。

有关更多信息，请参阅 [Jira 议题集成](configure.md)。

要解决此问题，请更新身份验证凭据以匹配您的 Jira 安装。

<a id="error-the-credentials-for-accessing-jira-are-not-allowed-to-access-the-data"></a>

#### 错误：`访问 Jira 的凭据不被允许访问数据`

如果您的 Jira 凭据无法访问您在 [Jira 议题集成](configure.md#configure-the-integration) 中指定的 Jira 项目键，您可能会看到此错误：

```plaintext
访问 Jira 的凭据不被允许访问数据。
请检查您的 Jira 议题集成凭据，然后重试。
```

> [!warning]
> Atlassian 已于 2024 年 10 月 31 日弃用了 Jira Cloud 的旧 JQL 搜索端点 (`GET/POST /rest/api/2/search`)，并计划于 2025 年 5 月 1 日移除。Jira Server 和 Data Center 继续使用 `/rest/api/2/search` 端点。更多信息，请参阅 [Atlassian 弃用通知](https://developer.atlassian.com/changelog/#CHANGE-2046)。

要解决此问题，请确保您在 Jira 议题集成中配置的 Jira 用户有权查看与指定 Jira 项目键关联的议题。

要验证 Jira 用户拥有此权限，请执行以下操作之一：

{{< tabs >}}

{{< tab title="Jira Cloud" >}}

- 在浏览器中，使用您在 Jira 议题集成中配置的用户登录 Jira。由于 Jira API 支持基于 cookie 的身份验证，您可以在浏览器中查看是否返回任何议题：

  ```plaintext
  https://<ATLASSIAN_SUBDOMAIN>.atlassian.net/rest/api/3/search/jql?jql=project=<JIRA_PROJECT_KEY>
  ```

- 使用 `curl` 进行 HTTP 基本认证以访问 API，查看是否返回任何议题：

  ```shell
  curl --verbose --user "$JIRA_EMAIL:$JIRA_API_TOKEN" \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --request POST \
    --data '{"jql":"project='$JIRA_PROJECT_KEY'"}' \
    "https://$ATLASSIAN_SUBDOMAIN.atlassian.net/rest/api/3/search/jql" | jq
  ```

API 响应返回一个 JSON 响应：

- `issues` 包含一个匹配 Jira 项目键的议题数组。
- 如果有更多结果需要获取，则会提供 `nextPageToken`。

有关返回状态码和 API 详细信息的更多信息，请参阅 [使用 JQL 增强搜索 (POST) 搜索议题](https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-search/#api-rest-api-3-search-jql-post)。

{{< /tab >}}

{{< tab title="Jira Server/Data Center" >}}

- 在浏览器中，使用您在 Jira 议题集成中配置的用户登录 Jira。由于 Jira API 支持基于 cookie 的身份验证，您可以在浏览器中查看是否返回任何议题：

  ```plaintext
  <JIRA_SERVER_URL>/rest/api/2/search?jql=project=<JIRA_PROJECT_KEY>
  ```

- 使用 `curl` 进行 HTTP 基本认证以访问 API，查看是否返回任何议题：

  ```shell
  curl --verbose --header 'Authorization: Bearer '$JIRA_API_TOKEN'' \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --request POST \
    --data '{"jql":"project='$JIRA_PROJECT_KEY'"}' \
    "$JIRA_SERVER_URL/rest/api/2/search" | jq
  ```

API 响应返回一个 JSON 响应：

- `issues` 包含一个匹配 Jira 项目键的议题数组。
- 如果有更多结果需要获取，则会提供 `total`。

有关返回状态码和 API 详细信息的更多信息，请参阅 [使用 JQL 执行搜索 (POST)](https://developer.atlassian.com/server/jira/platform/rest/v10007/api-group-search/#api-api-2-search-post)。

{{< /tab >}}

{{< /tabs >}}