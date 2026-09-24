---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 应用限制
description: 在实例上配置限制。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

与大多数大型应用程序一样，极狐GitLab 在某些功能中实施限制，以维持最低性能质量。允许某些功能不受限制可能会影响安全性、性能、数据，甚至可能耗尽为应用程序分配的资源。

<a id="instance-configuration"></a>

## 实例配置

在实例配置页面中，您可以找到有关当前极狐GitLab 实例中使用的一些设置的信息。

根据您配置的限制，您可以看到：

- SSH 主机密钥信息
- [CI/CD 限制](cicd/limits.md)
- GitLab Pages 限制
- 软件包仓库限制
- 速率限制
- 大小限制

由于此页面对所有用户可见，未认证用户只能看到与他们相关的信息。

要访问实例配置页面：

1. 在左侧边栏中，选择 **帮助** ({{< icon name="question-o" >}}) > **帮助**。
1. 在帮助页面上，选择 **检查当前实例配置**。

直接 URL 为 `<gitlab_url>/help/instance_configuration`。对于 JihuLab.com，您可以访问 <https://gitlab.com/help/instance_configuration>。

<a id="rate-limits"></a>

## 速率限制

速率限制可用于提高极狐GitLab 的安全性和持久性。

有关速率限制的完整列表以及如何更改每个限制，请参阅[速率限制](../rate_limits/_index.md)。

<a id="by-protected-path"></a>

### 按受保护路径

此设置限制特定路径上的请求速率。

极狐GitLab 默认对以下路径的 POST 请求进行速率限制：

```plaintext
'/users/password',
'/users/sign_in',
'/api/#{API::API.version}/session.json',
'/api/#{API::API.version}/session',
'/users',
'/users/confirmation',
'/unsubscribes/',
'/import/github/personal_access_token',
'/admin/session'
```

极狐GitLab 默认对以下路径的 GET 请求进行速率限制：

```plaintext
'/users/sign_in_path'
```

详细了解[受保护路径速率限制](settings/protected_paths.md)。

- **默认速率限制**：在 10 次请求后，客户端必须等待 60 秒才能再次尝试。

<a id="import-and-export"></a>

### 导入和导出

这些设置限制群组和项目的文件导入和导出。

| 限制                   | 默认值（每分钟每用户） |
|:------------------------|:------------------------------|
| 项目导入          | 6 次导入请求             |
| 项目导出          | 6 次导出请求             |
| 项目导出下载 | 1 次下载请求            |
| 群组导入            | 6 次导入请求             |
| 群组导出            | 6 次导出请求             |
| 群组导出下载   | 1 次下载请求            |

这些设置[可以配置](settings/import_export_rate_limits.md)。

<a id="direct-transfer-migration"></a>

#### 直接转移迁移

以下限制适用于通过直接转移进行的迁移。

| 限制                                                                      | 默认值     | 可配置 |
|:---------------------------------------------------------------------------|:------------|:-------------|
| 目标极狐GitLab 实例每分钟每用户的迁移次数。 | 6           | {{< no >}}   |
| 等待解压归档文件的时间。                            | 210 秒 | {{< no >}}   |
| NDJSON 行的长度。                                                   | 50 MB       | {{< no >}}   |
| 源实例上引发空导出状态的时间。            | 5 分钟   | {{< no >}}   |
| 可从源实例下载的关系大小。             | 5 GiB       | {{< yes >}}  |
| 解压归档的大小。                                            | 10 GiB      | {{< yes >}}  |

有关更改可配置限制的更多信息，请参阅[导入和导出设置](settings/import_and_export_settings.md)。

<a id="member-invitations"></a>

### 成员邀请

限制每个群组层级每天允许的最大成员邀请数。

- JihuLab.com：基础版成员每天可邀请 20 名成员，专业版试用和旗舰版试用成员每天可邀请 50 名成员。
- 极狐GitLab 私有化部署：邀请不受限制。

<a id="webhook-rate-limit"></a>

### Webhook 速率限制

限制顶级命名空间中的 Webhook 每分钟可被调用的次数。该命名空间中的所有项目和群组 Webhook 共享此限制。

超过速率限制的调用会记录在 `auth.log` 中。

要为极狐GitLab 私有化部署实例设置此限制，请使用 [Plan Limits API](../api/plan_limits.md) 或在 [GitLab Rails 控制台](operations/rails_console.md#starting-a-rails-console-session) 中运行以下命令：

```ruby
# If limits don't exist for the default plan, you can create one with:
# Plan.default.create_limits!

Plan.default.actual_limits.update!(web_hook_calls: 10)
```

将限制设置为 `0` 以禁用它。

- **默认速率限制**：禁用（无限制）。

<a id="search-rate-limit"></a>

### 搜索速率限制

此设置限制搜索请求，如下所示：

| 限制                | 默认值（每分钟请求数） |
|----------------------|-------------------------------|
| 已认证用户   | 30                            |
| 未认证用户 | 10                            |

每分钟超过搜索速率限制的搜索请求将返回以下错误：

```plaintext
This endpoint has been requested too many times. Try again later.
```

<a id="autocomplete-users-rate-limit"></a>

### 自动补全用户速率限制

此设置限制自动补全用户请求，如下所示：

| 限制                | 默认值（每分钟请求数） |
|----------------------|-------------------------------|
| 已认证用户   | 300                           |
| 未认证用户 | 100                           |

每分钟超过自动补全速率限制的自动补全请求将返回以下错误：

```plaintext
This endpoint has been requested too many times. Try again later.
```

<a id="gitaly-concurrency-limit"></a>

## Gitaly 并发限制

克隆流量可能会给您的 Gitaly 服务带来巨大压力。为防止此类工作负载压垮您的 Gitaly 服务器，您可以在 Gitaly 配置文件中设置并发限制。

详细了解 [Gitaly 并发限制](gitaly/concurrency_limiting.md#limit-rpc-concurrency)。

- **默认速率限制**：禁用。

<a id="number-of-comments-per-issue-merge-request-or-commit"></a>

## 每个议题、合并请求或提交的评论数

在议题、合并请求或提交上可以提交的评论数量有限制。达到限制后，仍然可以添加系统评论，以便不丢失事件历史，但用户提交的评论会失败。

- **最大限制**：5,000 条评论。

<a id="size-of-comments-and-descriptions-of-issues-merge-requests-and-epics"></a>

## 议题、合并请求和史诗的评论和描述的大小

议题、合并请求和史诗的评论和描述的大小有限制。尝试添加超过限制大小的文本主体会导致错误，并且该项也不会被创建。

此限制将来可能会降低。

- **最大大小**：约 100 万字符 / 约 1 MB。

<a id="size-of-commit-titles-and-descriptions"></a>

## 提交标题和描述的大小

具有任意大消息的提交可以推送到极狐GitLab，但以下显示限制适用：

- **标题** - 提交消息的第一行。限制为 1 KiB。
- **描述** - 提交消息的其余部分。限制为 1 MiB。

推送提交时，极狐GitLab 会处理标题和描述，以将议题 (`#123`) 和合并请求 (`!123`) 的引用替换为指向这些议题和合并请求的链接。

当推送包含大量提交的分支时，仅处理最后 100 个提交。

<a id="size-during-rebase-operations"></a>

### 变基操作期间的大小

当您变基提交时，超过大小限制的提交消息会被截断。此限制独立于提交标题和描述的大小限制。

- **限制**：10,240 字节（10 KB）。

<a id="number-of-issues-in-the-milestone-overview"></a>

## 里程碑概览中的议题数

里程碑概览页面上加载的最大议题数为 500。当数量超过限制时，页面会显示警报，并链接到里程碑中所有议题的分页[议题列表](../user/project/issues/managing_issues.md)。

- **限制**：500 个议题。

<a id="retention-of-activity-history"></a>

## 活动历史保留

项目和用户个人资料的活动历史限制为三年。

<a id="number-of-embedded-metrics"></a>

## 嵌入指标数量

出于性能原因，在极狐GitLab 风格 Markdown (GLFM) 中嵌入指标时有限制。

- **最大限制**：100 个嵌入。

<a id="http-response-limits"></a>

## HTTP 响应限制

<a id="maximum-gzip-compressed-size"></a>

### 最大 Gzip 压缩大小

此设置限制 Gzip 压缩的 HTTP 响应解压后允许的最大大小（以 MiB 为单位）。

默认最大大小为 100 MiB。要禁用此限制，请将该值设置为 0。

您可以使用 GitLab Rails 控制台或使用[应用程序设置 API](../api/settings.md) 更改此限制。

 ```ruby
 ApplicationSetting.update(max_http_decompressed_size: 50)
 ```

<a id="maximum-http-responses-size-from-outbound-requests"></a>

### 出站请求的最大 HTTP 响应大小

此设置限制解压后的 HTTP 响应允许的最大大小（以 MiB 为单位）。它适用于集成、导入器和 Webhook。

默认最大大小为 100 MiB。要禁用此限制，请将该值设置为 0。

您可以使用 GitLab Rails 控制台或使用[应用程序设置 API](../api/settings.md) 更改此限制。

 ```ruby
 ApplicationSetting.update(max_http_response_size_limit: 60)
 ```

<a id="maximum-allowed-object-count-in-json-http-responses-from-outbound-requests"></a>

### 出站请求的 JSON HTTP 响应中允许的最大对象数

此设置限制出站请求的 JSON HTTP 响应中允许的最大对象数。对象数根据响应中 `:`、`,`、`{` 和 `[` 的出现次数来估算。

默认最大计数为 1,000,000 个对象。要禁用此限制，请将该值设置为 0。

您可以使用 GitLab Rails 控制台或使用[应用程序设置 API](../api/settings.md) 更改此限制：

```ruby
ApplicationSetting.update(max_http_response_json_structural_chars: 500000)
```

<a id="maximum-allowed-nesting-depth-in-json-http-responses-from-outbound-requests"></a>

### 出站请求的 JSON HTTP 响应中允许的最大嵌套深度

此设置限制出站请求的 JSON HTTP 响应中允许的最大嵌套深度。

默认最大嵌套深度为 32。

您可以使用 GitLab Rails 控制台或使用[应用程序设置 API](../api/settings.md) 更改此限制：

```ruby
ApplicationSetting.update(max_http_response_json_depth: 100)
```

<a id="maximum-allowed-object-count-in-xml-http-responses-from-outbound-requests"></a>

### 出站请求的 XML HTTP 响应中允许的最大对象数

此设置限制出站请求的 XML HTTP 响应中允许的最大对象数。对象数根据响应中 `<`、`=` 的出现次数来估算。

默认最大计数为 250,000 个对象。要禁用此限制，请将该值设置为 0。

您可以使用 GitLab Rails 控制台或使用[应用程序设置 API](../api/settings.md) 更改此限制：

```ruby
ApplicationSetting.update(max_http_response_xml_structural_chars: 500000)
```

<a id="maximum-allowed-object-count-in-csv-http-responses-from-outbound-requests"></a>

### 出站请求的 CSV HTTP 响应中允许的最大对象数

此设置限制出站请求的 CSV HTTP 响应中允许的最大对象数。对象数根据响应中 `,`、`;`、`\t`、`\r` 和 `\n` 的出现次数来估算。

默认最大计数为 250,000 个对象。要禁用此限制，请将该值设置为 0。

您可以使用 GitLab Rails 控制台或使用[应用程序设置 API](../api/settings.md) 更改此限制：

```ruby
ApplicationSetting.update(max_http_response_csv_structural_chars: 500000)
```

<a id="http-request-limits"></a>

## HTTP 请求限制

默认情况下，请求中的 JSON 参数受到限制。有关更多信息，请参阅[按端点的 JSON 验证限制](#json-validation-limits-by-endpoint)。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

要禁用此检查：

1. 在所有运行 Puma 的节点上设置 `GITLAB_JSON_GLOBAL_VALIDATION_MODE` 环境变量：

   ```shell
   sudo -e /etc/gitlab/gitlab.rb
   ```

   ```ruby
   gitlab_rails['env'] = { 'GITLAB_JSON_GLOBAL_VALIDATION_MODE' => 'disabled' }
   ```

1. 重新配置更新后的节点以使更改生效：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

要禁用此检查，您可以使用 `--set gitlab.webservice.extraEnv.GITLAB_JSON_GLOBAL_VALIDATION_MODE="disabled"`，或在您的 values 文件中指定以下内容：

```yaml
gitlab:
  webservice:
    extraEnv:
      GITLAB_JSON_GLOBAL_VALIDATION_MODE: "disabled"
```

{{< /tab >}}

{{< /tabs >}}

<a id="json-validation-limits-by-endpoint"></a>

### 按端点的 JSON 验证限制

某些 API 端点具有特定的 JSON 验证限制。

| 端点                                                                                     | 描述           | 方法 | 最大深度 | 最大数组大小 | 最大哈希大小 | 最大总元素数 | 最大 JSON 大小 | 模式 |
|:---------------------------------------------------------------------------------------------|:----------------------|:--------|:----------|:---------------|:--------------|:-------------------|:--------------|:-----|
| 所有其他路径                                                                              | 默认               | 全部     | 32        | 50,000         | 50,000        | 100,000            | 0（禁用）  | enforced |
| `/api/v4/projects/{id}/terraform/state/`                                                     | Terraform 状态       | POST    | 64        | 50,000         | 50,000        | 250,000            | 50 MB         | logging <sup>1</sup> |
| `/api/v4/packages/npm/-/npm/v1/security/`<br/>`{advisories/bulk\|audits/quick}`               | NPM 实例软件包 | POST    | 32        | 50,000         | 50,000        | 250,000            | 50 MB         | enforced |
| `/api/v4/groups/{id}/-/packages/npm/-/npm/v1/security/`<br/>`{advisories/bulk\|audits/quick}` | NPM 群组软件包    | POST    | 32        | 50,000         | 50,000        | 250,000            | 50 MB         | enforced |
| `/api/v4/projects/{id}/packages/npm/-/npm/v1/security/`<br/>`{advisories/bulk\|audits/quick}` | NPM 项目软件包  | POST    | 32        | 50,000         | 50,000        | 250,000            | 50 MB         | enforced |
| `/api/v4/internal/*`                                                                         | 内部 API          | POST    | 32        | 50,000         | 50,000        | 0（禁用）       | 10 MB         | enforced |
| `/api/v4/ai/duo_workflows/workflows/*`                                                        | 极狐GitLab Duo Workflow API      | POST    | 32        | 5,000          | 5,000         | 0（禁用）       | 25 MB         | enforced |

**脚注**：

1. Terraform 状态最大大小限制可以通过使用[应用程序设置 API](../api/settings.md) 设置 `max_terraform_state_size_bytes` 来配置。

<a id="environment-variable-configuration"></a>

### 环境变量配置

以下环境变量修改默认限制和验证模式：

| 环境变量                 | 用途                     | 默认值      | 范围 |
|:-------------------------------------|:----------------------------|:-------------|:------|
| `GITLAB_JSON_MAX_DEPTH`              | 默认最大嵌套深度   | 32           | 仅默认限制 |
| `GITLAB_JSON_MAX_ARRAY_SIZE`         | 默认最大数组元素数  | 50,000       | 仅默认限制 |
| `GITLAB_JSON_MAX_HASH_SIZE`          | 默认最大哈希键数       | 50,000       | 仅默认限制 |
| `GITLAB_JSON_MAX_TOTAL_ELEMENTS`     | 默认最大总元素数  | 100,000      | 仅默认限制 |
| `GITLAB_JSON_MAX_JSON_SIZE_BYTES`    | 默认最大请求体大小       | 0（禁用） | 仅默认限制 |
| `GITLAB_JSON_VALIDATION_MODE`        | 默认验证模式     | `enforced`   | 仅默认限制 |
| `GITLAB_JSON_GLOBAL_VALIDATION_MODE` | 覆盖所有端点模式 | 未设置      | 所有端点（全局覆盖） |

`GITLAB_JSON_GLOBAL_VALIDATION_MODE` 环境变量可以设置为以下模式之一。

| 模式       | 描述 |
|:-----------|:------------|
| `enforced` | 验证并阻止超过限制的请求（返回 HTTP 400）。用于生产环境防护。 |
| `logging`  | 验证并记录违规但允许请求通过。用于监控和调试。所有端点仅记录，这会覆盖 `enforced`。 |
| disabled   | 完全跳过验证。用作紧急绕过。 |

使用 `GITLAB_JSON_GLOBAL_VALIDATION_MODE` 时：

- 特定于路由的配置会覆盖默认限制，但不会覆盖全局验证模式。
- 在 enforced 模式下超过限制时，响应为 HTTP 400 并带有 JSON 错误消息。
- 总元素数包括整个 JSON 结构中数组和哈希中的所有元素。

<a id="webhook-limits"></a>

## Webhook 限制

另请参阅 [Webhook 速率限制](#webhook-rate-limit)。

<a id="number-of-webhooks"></a>

### Webhook 数量

要为极狐GitLab 私有化部署实例设置群组或项目 Webhook 的最大数量，请在 [GitLab Rails 控制台](operations/rails_console.md#starting-a-rails-console-session) 中运行以下命令：

```ruby
# If limits don't exist for the default plan, you can create one with:
# Plan.default.create_limits!

# For project webhooks
Plan.default.actual_limits.update!(project_hooks: 200)

# For group webhooks
Plan.default.actual_limits.update!(group_hooks: 100)
```

将限制设置为 `0` 以禁用它。

默认最大 Webhook 数为每个项目 `100` 个，每个群组 `50` 个。子群组中的 Webhook 不计入其父群组的 Webhook 限制。

对于 JihuLab.com，请参阅 [JihuLab.com 的 Webhook 限制](../user/jihulab_com/_index.md#webhooks)。

<a id="webhook-payload-size"></a>

### Webhook 负载大小

最大 Webhook 负载大小为 25 MB。

<a id="webhook-timeout"></a>

### Webhook 超时

极狐GitLab 在发送 Webhook 后等待 HTTP 响应的秒数。

要更改 Webhook 超时值：

1. 在所有运行 Sidekiq 的极狐GitLab 节点上编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['webhook_timeout'] = 60
   ```

1. 保存文件。
1. 重新配置并重启极狐GitLab 以使更改生效：

   ```shell
   gitlab-ctl reconfigure
   gitlab-ctl restart
   ```

另请参阅 [JihuLab.com 的 Webhook 限制](../user/jihulab_com/_index.md#other-limits)。

<a id="recursive-webhooks"></a>

### 递归 Webhook

极狐GitLab 检测并阻止递归的 Webhook 或超过可从其他 Webhook 触发的 Webhook 数量限制的 Webhook。这使极狐GitLab 能够继续支持使用 Webhook 非递归地调用 API 或不会触发不合理数量的其他 Webhook 的工作流。

当 Webhook 配置为调用其自身的极狐GitLab 实例（例如 API）时，可能会发生递归。该调用随后会触发相同的 Webhook 并创建无限循环。

由一系列触发其他 Webhook 的 Webhook 对实例发出的最大请求数为 100。达到限制后，极狐GitLab 会阻止该系列将触发的任何进一步 Webhook。

被阻止的递归 Webhook 调用会记录在 `auth.log` 中，并带有消息 `"Recursive webhook blocked from executing"`。

<a id="import-placeholder-user-limits"></a>

## 导入占位用户限制

导入期间创建的[占位用户](../user/import/mapping/post_migration_mapping.md#placeholder-users)数量可以按顶级命名空间进行限制。

[极狐GitLab 私有化部署](../subscriptions/manage_subscription.md) 的默认限制为 `0`（无限制）。

要为极狐GitLab 私有化部署实例更改此限制，请在 [GitLab Rails 控制台](operations/rails_console.md#starting-a-rails-console-session) 中运行以下命令：

```ruby
# If limits don't exist for the default plan, you can create one with:
# Plan.default.create_limits!

Plan.default.actual_limits.update!(import_placeholder_user_limit_tier_1: 200)
```

将限制设置为 `0` 以禁用它。

<a id="pull-mirroring-interval"></a>

## 拉取镜像间隔

[拉取刷新之间的最小等待时间](../user/project/repository/mirror/_index.md)默认为 300 秒（5 分钟）。例如，无论您触发多少次，拉取刷新在给定的 300 秒内只运行一次。

此设置适用于通过使用 [projects API](../api/project_pull_mirroring.md#start-the-pull-mirroring-process-for-a-project) 调用的拉取刷新，或在 **设置** > **代码仓库** > **镜像仓库** 中选择 **立即更新** ({{< icon name="retry" >}}) 强制更新时。此设置对 Sidekiq 用于[拉取镜像](../user/project/repository/mirror/pull.md)的自动 30 分钟间隔计划没有影响。

要为极狐GitLab 私有化部署实例更改此限制，请在 [GitLab Rails 控制台](operations/rails_console.md#starting-a-rails-console-session) 中运行以下命令：

```ruby
# If limits don't exist for the default plan, you can create one with:
# Plan.default.create_limits!

Plan.default.actual_limits.update!(pull_mirror_interval_seconds: 200)
```

<a id="incoming-emails-from-auto-responders"></a>

## 来自自动回复器的入站电子邮件

极狐GitLab 通过查找 `X-Autoreply` 标头来忽略所有来自自动回复器的入站电子邮件。此类电子邮件不会在议题或合并请求上创建评论。

<a id="amount-of-data-sent-from-sentry-through-error-tracking"></a>

## 通过错误跟踪从 Sentry 发送的数据量

发送到极狐GitLab 的 Sentry 负载有 1 MB 的最大限制，这既出于安全原因，也为了限制内存消耗。

<a id="max-offset-allowed-by-the-rest-api-for-offset-based-pagination"></a>

## REST API 基于偏移的分页允许的最大偏移量

在 REST API 中使用基于偏移的分页时，对结果集中请求的最大偏移量有限制。此限制仅适用于也支持基于键集分页的端点。有关分页选项的更多信息，请参阅 [API 文档中的分页部分](../api/rest/_index.md#pagination)。

要为极狐GitLab 私有化部署实例设置此限制，请在 [GitLab Rails 控制台](operations/rails_console.md#starting-a-rails-console-session) 中运行以下命令：

```ruby
# If limits don't exist for the default plan, you can create one with:
# Plan.default.create_limits!

Plan.default.actual_limits.update!(offset_pagination_limit: 10000)
```

- **默认偏移分页限制**：`50000`。

将限制设置为 `0` 以禁用它。

<a id="gitlab-pages-limits"></a>

## GitLab Pages 限制

<a id="number-of-files-per-gitlab-pages-website"></a>

### 每个 GitLab Pages 网站的文件数

每个 GitLab Pages 网站的文件条目总数（包括目录和符号链接）限制为 `200,000` 个。

这是 [极狐GitLab 私有化部署和 JihuLab.com](https://gitlab.cn/pricing) 的默认限制。

要在您的极狐GitLab 私有化部署实例中更新限制，请使用 [GitLab Rails 控制台](operations/rails_console.md#starting-a-rails-console-session)。例如，要将限制更改为 `100`：

```ruby
Plan.default.actual_limits.update!(pages_file_entries: 100)
```

<a id="number-of-custom-domains-per-gitlab-pages-website"></a>

### 每个 GitLab Pages 网站的自定义域数量

对于 [JihuLab.com](../subscriptions/manage_seats.md#gitlabcom-billing-and-usage)，每个 GitLab Pages 网站的自定义域总数限制为 `150` 个。

[极狐GitLab 私有化部署](../subscriptions/manage_subscription.md) 的默认限制为 `0`（无限制）。要在您的实例上设置限制，请使用 [**管理**区域](pages/_index.md#set-maximum-number-of-gitlab-pages-custom-domains-for-a-project)。

<a id="number-of-parallel-pages-deployments"></a>

### 并行 Pages 部署数量

使用[并行 Pages 部署](../user/project/pages/parallel_deployments.md)时，顶级命名空间允许的并行 Pages 部署总数为 1000。

当项目启用了[唯一域](../user/project/pages/_index.md#unique-domains)时，该项目的唯一域被视为其自己的顶级命名空间，并具有单独的 1000 次部署限制。

<a id="instance-monitoring-and-metrics"></a>

## 实例监控和指标

<a id="limit-inbound-incident-management-alerts"></a>

### 限制入站事件管理警报

此设置限制一段时间内的入站警报负载数量。

详细了解[事件管理速率限制](settings/incident_management_rate_limits.md)。

<a id="prometheus-alert-json-payloads"></a>

### Prometheus 警报 JSON 负载

发送到 `notify.json` 端点的 Prometheus 警报负载大小限制为 1 MB。

<a id="generic-alert-json-payloads"></a>

### 通用警报 JSON 负载

发送到 `notify.json` 端点的警报负载大小限制为 1 MB。

<a id="environment-dashboard-limits"></a>

## 环境仪表板限制

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

有关显示项目的最大数量，请参阅[环境仪表板](../ci/environments/environments_dashboard.md#adding-a-project-to-the-dashboard)。

<a id="environment-data-on-deploy-boards"></a>

## 部署面板上的环境数据

[部署面板](../user/project/deploy_boards.md)从 Kubernetes 加载有关 Pod 和 Deployment 的信息。但是，从 Kubernetes 读取的特定环境的超过 10 MB 的数据不会显示。

<a id="merge-requests"></a>

## 合并请求

<a id="diff-limits"></a>

### 差异限制

极狐GitLab 对以下方面有限制：

- 单个文件的补丁大小。[这可以在极狐GitLab 私有化部署上配置](diff_limits.md)。
- 合并请求的所有差异的总大小。

以下每一项都适用上限和下限：

- 更改的文件数。
- 更改的行数。
- 显示的更改的累计大小。

较低的限制会导致额外的差异被折叠。较高的限制会阻止渲染更多更改。有关这些限制的更多信息，请阅读有关处理差异的 GitLab 开发文档。

<a id="diff-version-limit"></a>

### 差异版本限制

极狐GitLab 将每个合并请求限制为 1000 个[差异版本](../user/project/merge_requests/versions.md)。达到此限制的合并请求无法进一步更新。相反，请关闭受影响的合并请求并创建新的合并请求。

要配置此限制，请参阅[差异限制管理](diff_limits.md)。

<a id="merge-request-reports-size-limit"></a>

### 合并请求报告大小限制

超过 20 MB 限制的报告不会加载。受影响的报告：

- [合并请求安全报告](../ci/testing/_index.md#security-reports)
- [CI/CD 参数 `artifacts:expose_as`](../ci/yaml/_index.md#artifactsexpose_as)
- [单元测试报告](../ci/testing/unit_test_reports.md)

<a id="advanced-search-limits"></a>

## 高级搜索限制

<a id="maximum-file-size-indexed"></a>

### 索引的最大文件大小

您可以对 Elasticsearch 中索引的代码仓库文件内容设置限制。任何大于此限制的文件仅索引文件名。文件内容既不会被索引，也不可搜索。

设置限制有助于减少索引进程的内存使用和整体索引大小。此值默认为 `1024 KiB`（1 MiB），因为任何大于此的文本文件可能并非供人类阅读。

您必须设置限制，因为不支持无限制的文件大小。将此值设置为大于极狐GitLab Sidekiq 节点上的内存量会导致极狐GitLab Sidekiq 节点内存不足，因为此内存量在索引期间会预先分配。

<a id="maximum-field-length"></a>

### 最大字段长度

您可以对为高级搜索索引的文本字段内容设置限制。设置最大值有助于减少索引进程的负载。如果任何文本字段超过此限制，则文本将被截断为此字符数。文本的其余部分不会被索引，也不可搜索。这适用于所有索引数据，但被索引的代码仓库文件除外，它们有单独的限制。有关更多信息，请阅读[索引的最大文件大小](#maximum-file-size-indexed)。

- 在 JihuLab.com 上，字段长度限制为 20,000 个字符。
- 对于极狐GitLab 私有化部署实例，字段长度默认无限制。

您可以在[启用 Elasticsearch](../integration/advanced_search/elasticsearch.md#enable-advanced-search) 时为极狐GitLab 私有化部署实例配置此限制。将限制设置为 `0` 以禁用它。

<a id="math-rendering-limits"></a>

## 数学渲染限制

极狐GitLab 在 Markdown 字段中渲染数学时施加默认限制。这些限制提供了更好的安全性和性能。

议题、合并请求、史诗、Wiki 和代码仓库文件的限制：

- 宏展开的最大数量：`1000`。
- 以 [em](https://en.wikipedia.org/wiki/Em_(typography)) 为单位的用户指定最大大小：`20`。
- 渲染的最大节点数：`1000`。
- 数学块中的最大字符数：`1000`。
- 最大渲染时间：`2000 ms`。

当您运行极狐GitLab 私有化部署并信任用户输入时，可以禁用这些限制。

使用 [GitLab Rails 控制台](operations/rails_console.md#starting-a-rails-console-session)：

```ruby
ApplicationSetting.update(math_rendering_limits_enabled: false)
```

这些限制也可以使用 GraphQL 或 REST API 按群组禁用。

如果禁用这些限制，则在议题、合并请求、史诗、Wiki 和代码仓库文件中渲染数学时几乎没有限制。这意味着恶意行为者可以添加数学内容，在浏览器中查看时可能导致 DoS。您必须确保只有您信任的人才能添加内容。

<a id="wiki-limits"></a>

## Wiki 限制

- [Wiki 页面内容大小限制](wikis/_index.md#wiki-page-content-size-limit)。
- [文件和目录名称的长度限制](../user/project/wiki/_index.md#length-restrictions-for-file-and-directory-names)。

<a id="snippets-limits"></a>

## 代码片段限制

请参阅[关于代码片段设置的文档](snippets/_index.md)。

<a id="design-management-limits"></a>

## 设计管理限制

请参阅[向议题添加设计](../user/project/issues/design_management.md#add-a-design-to-an-issue)部分中的限制。

<a id="push-event-limits"></a>

## 推送事件限制

<a id="max-push-size"></a>

### 最大推送大小

允许的最大[推送大小](settings/account_and_limit_settings.md#max-push-size)。

在极狐GitLab 私有化部署上默认未设置。对于 JihuLab.com，请参阅[账户和限制设置](../user/jihulab_com/_index.md#account-and-limit-settings)。

<a id="webhooks-and-project-services"></a>

### Webhook 和项目服务

单次推送中的更改（分支或标签）总数。如果更改超过指定限制，则不会执行钩子。

有关更多信息，请参阅：

- [Webhook 推送事件](../user/project/integrations/webhook_events.md#push-events)
- [项目集成的推送钩子限制](../user/project/integrations/_index.md#push-hook-limit)

<a id="activities"></a>

### 活动

单次推送中的更改（分支或标签）总数，用于确定是创建单个推送事件还是批量推送事件。

更多信息可以在[推送事件活动限制和批量推送事件文档](settings/push_event_activities_limit.md)中找到。

<a id="package-registry-limits"></a>

## 软件包仓库限制

<a id="file-size-limits"></a>

### 文件大小限制

上传到 [GitLab 软件包仓库](../user/packages/package_registry/_index.md)的软件包的默认最大文件大小因格式而异：

- Cargo：5 GB
- Conan：3 GB
- Generic：5 GB
- Helm：5 MB
- Maven：3 GB
- npm：500 MB
- NuGet：500 MB
- PyPI：3 GB
- Terraform：1 GB

[JihuLab.com 上的最大文件大小](../user/jihulab_com/_index.md#package-registry-limits)可能不同。

要为极狐GitLab 私有化部署实例设置这些限制，您可以通过 [**管理**区域](settings/continuous_integration.md#set-package-file-size-limits) 或在 [GitLab Rails 控制台](operations/rails_console.md#starting-a-rails-console-session) 中运行以下命令：

```ruby
# File size limit is stored in bytes

# For Cargo Packages
Plan.default.actual_limits.update!(cargo_max_file_size: 100.megabytes)

# For Conan Packages
Plan.default.actual_limits.update!(conan_max_file_size: 100.megabytes)

# For npm Packages
Plan.default.actual_limits.update!(npm_max_file_size: 100.megabytes)

# For NuGet Packages
Plan.default.actual_limits.update!(nuget_max_file_size: 100.megabytes)

# For Maven Packages
Plan.default.actual_limits.update!(maven_max_file_size: 100.megabytes)

# For PyPI Packages
Plan.default.actual_limits.update!(pypi_max_file_size: 100.megabytes)

# For Debian Packages
Plan.default.actual_limits.update!(debian_max_file_size: 100.megabytes)

# For Helm Charts
Plan.default.actual_limits.update!(helm_max_file_size: 100.megabytes)

# For Generic Packages
Plan.default.actual_limits.update!(generic_packages_max_file_size: 100.megabytes)
```

将限制设置为 `0` 以允许任何文件大小。

<a id="package-versions-returned"></a>

### 返回的软件包版本

当请求给定 NuGet 软件包名称的版本时，GitLab 软件包仓库最多返回 300 个版本。

<a id="dependency-proxy-limits"></a>

## 依赖代理限制

缓存在[依赖代理](../user/packages/dependency_proxy/_index.md)中的镜像的最大文件大小因文件类型而异：

- 镜像 blob：5 GB
- 镜像清单：10 MB

<a id="maximum-number-of-assignees-and-reviewers"></a>

## 最大指派人数和审核人数

议题和合并请求强制执行以下最大值：

- 最大指派人数：200
- 最大审核人数：200

<a id="maximum-number-of-project-push-mirrors"></a>

## 项目推送镜像的最大数量

每个项目最多可以有 10 个启用的推送镜像。此限制可防止过多的并发同步作业导致性能问题。

如果您需要更多镜像，您可以：

- 禁用未使用的镜像。
- 通过将多个目标合并到单个镜像中来整合镜像。

<a id="cdn-based-limits-on-gitlabcom"></a>

## JihuLab.com 上基于 CDN 的限制

除了基于应用程序的限制外，JihuLab.com 还配置为使用 Cloudflare 的标准 DDoS 保护和 Spectrum 来保护基于 SSH 的 Git。Cloudflare 终止客户端 TLS 连接，但不感知应用程序，不能用于与用户或群组相关的限制。Cloudflare 页面规则和速率限制是使用 Terraform 配置的。这些配置不公开，因为它们包含检测恶意活动的安全和滥用实施，公开它们会破坏这些操作。

<a id="container-repository-tag-deletion-limit"></a>

## 容器仓库标签删除限制

容器仓库标签位于容器镜像仓库中，因此每次删除标签都会触发对容器镜像仓库的网络请求。因此，我们将单个 API 调用可以删除的标签数限制为 20。

<a id="project-level-secure-files-api-limits"></a>

## 项目级安全文件 API 限制

[安全文件 API](../api/secure_files.md) 强制执行以下限制：

- 文件必须小于 5 MB。
- 项目不能拥有超过 100 个安全文件。

<a id="changelog-api-limits"></a>

## Changelog API 限制

[changelog API](../api/repositories.md#add-changelog-data-to-file) 强制执行以下限制：

- `from` 和 `to` 之间的提交范围不能超过 15000 个提交。

<a id="value-stream-analytics-limits"></a>

## 价值流分析限制

- 每个命名空间（例如群组或项目）最多可以有 50 个价值流。
- 每个价值流最多可以有 15 个阶段。

<a id="audit-events-streaming-destination-limits"></a>

## 审计事件流式传输目标限制

<a id="custom-http-endpoint"></a>

### 自定义 HTTP 端点

- 每个顶级群组最多可以有 5 个自定义 HTTP 流式传输目标。

<a id="google-cloud-logging"></a>

### Google Cloud Logging

- 每个顶级群组最多可以有 5 个 Google Cloud Logging 流式传输目标。

<a id="amazon-s3"></a>

### Amazon S3

- 每个顶级群组最多可以有 5 个 Amazon S3 流式传输目标。

<a id="dependency-scanning-using-sbom-limits"></a>

## 使用 SBOM 的依赖扫描限制

[使用 SBOM 的依赖扫描功能](../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md) 使用具有以下限制的内部 API：

- 每个项目每小时的最大上传请求数：400
- 每个项目每小时的最大下载请求数：6000

您可以使用[依赖扫描设置](settings/security_and_compliance.md#sbom-scan-api-limits)为极狐GitLab 私有化部署实例配置这些限制。

<a id="commits-and-files-api-limits"></a>

## 提交和文件 API 限制

提交和文件 API 对以下端点强制执行最大大小和速率限制：

- `POST /projects/:id/repository/commits` - [创建提交](../api/commits.md#create-a-commit)
- `POST /projects/:id/repository/files/:file_path` - [在代码仓库中创建文件](../api/repository_files.md#create-a-file-in-a-repository)
- `PUT /projects/:id/repository/files/:file_path` - [更新代码仓库中的文件](../api/repository_files.md#update-a-file-in-a-repository)
- **最大请求大小**：超过此限制的请求会收到 `413 Request Entity Too Large` 错误，并带有以下消息：`RequestBody: upload failed: the upload size <size> is over maximum of 314572800 bytes: entity is too large`。默认值为 300 MB（314,572,800 字节）。
- **速率限制**：对于超过 20 MB 的请求，每 30 秒 3 个请求。

最大请求大小可在极狐GitLab 私有化部署上通过设置 `GITLAB_COMMITS_MAX_REQUEST_SIZE_BYTES` 环境变量进行配置。此变量以字节为单位设置最大请求大小。有关如何设置环境变量的说明，请参阅 [HTTP 请求限制](#http-request-limits)。

<a id="list-all-instance-limits"></a>

## 列出所有实例限制

要从 [GitLab Rails 控制台](operations/rails_console.md#starting-a-rails-console-session) 列出所有实例限制值，请运行以下命令：

```ruby
Plan.default.actual_limits
```

示例输出：

```ruby
id: 1,
plan_id: 1,
ci_pipeline_size: 0,
ci_active_jobs: 0,
project_hooks: 100,
group_hooks: 50,
ci_project_subscriptions: 3,
ci_pipeline_schedules: 10,
offset_pagination_limit: 50000,
ci_instance_level_variables: "[FILTERED]",
storage_size_limit: 0,
ci_max_artifact_size_lsif: 200,
ci_max_artifact_size_archive: 0,
ci_max_artifact_size_metadata: 0,
ci_max_artifact_size_trace: "[FILTERED]",
ci_max_artifact_size_junit: 0,
ci_max_artifact_size_sast: 0,
ci_max_artifact_size_dependency_scanning: 350,
ci_max_artifact_size_container_scanning: 150,
ci_max_artifact_size_dast: 0,
ci_max_artifact_size_codequality: 0,
ci_max_artifact_size_license_management: 0,
ci_max_artifact_size_license_scanning: 100,
ci_max_artifact_size_performance: 0,
ci_max_artifact_size_metrics: 0,
ci_max_artifact_size_metrics_referee: 0,
ci_max_artifact_size_network_referee: 0,
ci_max_artifact_size_dotenv: 0,
ci_max_artifact_size_cobertura: 0,
ci_max_artifact_size_terraform: 5,
ci_max_artifact_size_accessibility: 0,
ci_max_artifact_size_cluster_applications: 0,
ci_max_artifact_size_secret_detection: "[FILTERED]",
ci_max_artifact_size_requirements: 0,
ci_max_artifact_size_coverage_fuzzing: 0,
ci_max_artifact_size_browser_performance: 0,
ci_max_artifact_size_load_performance: 0,
ci_needs_size_limit: 2,
cargo_max_file_size: 5368709120,
conan_max_file_size: 3221225472,
maven_max_file_size: 3221225472,
npm_max_file_size: 524288000,
nuget_max_file_size: 524288000,
pypi_max_file_size: 3221225472,
generic_packages_max_file_size: 5368709120,
golang_max_file_size: 104857600,
debian_max_file_size: 3221225472,
project_feature_flags: 200,
ci_max_artifact_size_api_fuzzing: 0,
ci_pipeline_deployments: 500,
pull_mirror_interval_seconds: 300,
daily_invites: 0,
rubygems_max_file_size: 3221225472,
terraform_module_max_file_size: 1073741824,
helm_max_file_size: 5242880,
ci_registered_group_runners: 1000,
ci_registered_project_runners: 1000,
ci_daily_pipeline_schedule_triggers: 0,
ci_max_artifact_size_cluster_image_scanning: 0,
ci_jobs_trace_size_limit: "[FILTERED]",
pages_file_entries: 200000,
dast_profile_schedules: 1,
external_audit_event_destinations: 5,
dotenv_variables: "[FILTERED]",
dotenv_size: 5120,
pipeline_triggers: 25000,
project_ci_secure_files: 100,
repository_size: 0,
security_policy_scan_execution_schedules: 0,
web_hook_calls_mid: 0,
web_hook_calls_low: 0,
project_ci_variables: "[FILTERED]",
group_ci_variables: "[FILTERED]",
ci_max_artifact_size_cyclonedx: 1,
rpm_max_file_size: 5368709120,
pipeline_hierarchy_size: 1000,
ci_max_artifact_size_requirements_v2: 0,
enforcement_limit: 0,
notification_limit: 0,
dashboard_limit_enabled_at: nil,
web_hook_calls: 0,
project_access_token_limit: 0,
google_cloud_logging_configurations: 5,
ml_model_max_file_size: 10737418240,
limits_history: {},
audit_events_amazon_s3_configurations: 5
```

由于 [Rails 控制台中的过滤](operations/rails_console.md#filtered-console-output)，某些限制值在列表中显示为 `[FILTERED]`。
