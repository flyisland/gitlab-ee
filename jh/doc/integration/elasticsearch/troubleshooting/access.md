---
stage: AI-powered
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 Elasticsearch 访问问题
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在使用 Elasticsearch 访问时，您可能会遇到以下问题。

<a id="set-configurations-in-the-rails-console"></a>

在 Rails 控制台中设置配置

请参阅[启动 Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session)。

<a id="list-attributes"></a>

列出属性

要列出所有可用属性：

1. 打开 Rails 控制台（`sudo gitlab-rails console`）。
1. 运行以下命令：

```ruby
ApplicationSetting.last.attributes
```

输出包含 [Elasticsearch 集成](../../advanced_search/elasticsearch.md) 中所有可用的设置，例如 `elasticsearch_indexing`、`elasticsearch_url`、`elasticsearch_replicas` 和 `elasticsearch_pause_indexing`。

<a id="set-attributes"></a>

设置属性

要设置 Elasticsearch 集成设置，请运行类似以下的命令：

```ruby
ApplicationSetting.last.update(elasticsearch_url: '<your ES URL and port>')

#或者

ApplicationSetting.last.update(elasticsearch_indexing: false)
```

<a id="get-attributes"></a>

获取属性

要检查设置是否已在 [Elasticsearch 集成](../../advanced_search/elasticsearch.md) 或 Rails 控制台中设置，请运行类似以下的命令：

```ruby
Gitlab::CurrentSettings.elasticsearch_url

#或者

Gitlab::CurrentSettings.elasticsearch_indexing
```

<a id="change-the-password"></a>

更改密码

要更改 Elasticsearch 密码，请运行以下命令：

```ruby
es_url = Gitlab::CurrentSettings.current_application_settings

# 确认当前的 Elasticsearch URL
es_url.elasticsearch_url

# 设置 Elasticsearch URL
es_url.elasticsearch_url = "http://<username>:<password>@your.es.host:<port>"

# 保存更改
es_url.save!
```

<a id="view-logs"></a>

查看日志

识别 Elasticsearch 集成问题的最有价值工具之一是日志。与此集成最相关的日志有：

1. [`sidekiq.log`](../../../administration/logs/_index.md#sidekiqlog) - 所有索引都在 Sidekiq 中进行，因此 Elasticsearch 集成的大部分相关日志都可以在此文件中找到。
1. [`elasticsearch.log`](../../../administration/logs/_index.md#elasticsearchlog) - 还有专门针对 Elasticsearch 的额外日志发送到此文件，可能包含有关搜索、索引或迁移的诊断信息。

以下是一些常见陷阱以及如何克服它们。

<a id="verify-that-your-gitlab-instance-is-using-elasticsearch"></a>

验证您的极狐GitLab 实例是否正在使用 Elasticsearch

要验证您的极狐GitLab 实例是否正在使用 Elasticsearch：

- 当您执行搜索时，在搜索结果页面的右上角，确保显示 **高级搜索已启用**。
- 在 **管理员** 区域，在 **设置** > **搜索** 下，检查是否已选择高级搜索设置。

  如有必要，可以从 Rails 控制台获取这些相同的设置：

  ```ruby
  ::Gitlab::CurrentSettings.elasticsearch_search?         # 搜索是否将使用 Elasticsearch
  ::Gitlab::CurrentSettings.elasticsearch_indexing?       # 内容是否将在 Elasticsearch 中索引
  ::Gitlab::CurrentSettings.elasticsearch_limit_indexing? # Elasticsearch 是否仅限于某些项目/命名空间
  ```

- 通过访问 [Rails 控制台](../../../administration/operations/rails_console.md) 并运行以下命令来确认搜索使用了 Elasticsearch：

  ```rails
  u = User.find_by_email('email_of_user_doing_search')
  s = SearchService.new(u, {:search => 'search_term'})
  pp s.search_objects.class
  ```

  最后一个命令的输出是关键。如果显示：

  - `ActiveRecord::Relation`，**则未** 使用 Elasticsearch。
  - `Kaminari::PaginatableArray`，**则正在** 使用 Elasticsearch。
- 如果 Elasticsearch 仅限于特定命名空间，并且您需要知道是否对特定项目或命名空间使用了 Elasticsearch，您可以使用 Rails 控制台：

  ```ruby
  ::Gitlab::CurrentSettings.search_using_elasticsearch?(scope: Namespace.find_by_full_path("/my-namespace"))
  ::Gitlab::CurrentSettings.search_using_elasticsearch?(scope: Project.find_by_full_path("/my-namespace/my-project"))
  ```

<a id="error-user-anonymous-is-not-authorized-to-perform-es-eshttpget"></a>

错误：`User: anonymous is not authorized to perform: es:ESHttpGet`

当对 AWS OpenSearch 或 Elasticsearch 使用域级别访问策略时，AWS 角色未分配给正确的极狐GitLab 节点。极狐GitLab Rails 和 Sidekiq 节点需要权限才能与搜索集群通信。

```plaintext
用户：anonymous 无权执行：es:ESHttpGet，因为没有基于资源的策略允许 es:ESHttpGet 操作
```

要解决此问题，请确保将 AWS 角色分配给正确的极狐GitLab 节点。

<a id="no-valid-region-specified"></a>

未指定有效区域

当使用带有高级搜索的 AWS 授权时，您指定的区域必须有效。

<a id="error-no-permissions-for-indices-data-write-bulk"></a>

错误：`no permissions for [indices:data/write/bulk]`

当对 IAM 角色或使用 AWS OpenSearch Dashboards 创建的角色使用细粒度访问控制时，您可能会遇到以下错误：

```json
{
  "error": {
    "root_cause": [
      {
        "type": "security_exception",
        "reason": "no permissions for [indices:data/write/bulk] and User [name=arn:aws:iam::xxx:role/INSERT_ROLE_NAME_HERE, backend_roles=[arn:aws:iam::xxx:role/INSERT_ROLE_NAME_HERE], requestedTenant=null]"
      }
    ],
    "type": "security_exception",
    "reason": "no permissions for [indices:data/write/bulk] and User [name=arn:aws:iam::xxx:role/INSERT_ROLE_NAME_HERE, backend_roles=[arn:aws:iam::xxx:role/INSERT_ROLE_NAME_HERE], requestedTenant=null]"
  },
  "status": 403
}
```

要解决此问题，您需要在 AWS OpenSearch Dashboards 中 [将角色映射到用户](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/fgac.html#fgac-mapping)。

<a id="create-additional-master-users-in-aws-opensearch-service"></a>

在 AWS OpenSearch Service 中创建额外的主用户

您可以在创建域时设置主用户。
使用此用户，您可以创建额外的主用户。
有关更多信息，请参阅
[AWS 文档](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/fgac.html#fgac-more-masters)。

要创建具有权限的用户和角色并将用户映射到角色，
请参阅 [OpenSearch 文档](https://opensearch.org/docs/latest/security/access-control/users-roles/)。
您必须在角色中包含以下权限：

```json
{
  "cluster_permissions": [
    "cluster_composite_ops",
    "cluster_monitor"
  ],
  "index_permissions": [
    {
      "index_patterns": [
        "gitlab*"
      ],
      "allowed_actions": [
        "data_access",
        "manage_aliases",
        "search",
        "create_index",
        "delete",
        "manage"
      ]
    },
    {
      "index_patterns": [
        "*"
      ],
      "allowed_actions": [
        "indices:admin/aliases/get",
        "indices:monitor/stats"
      ]
    }
  ]
}
```

<a id="accumulation-of-open-tcp-connections"></a>

开放 TCP 连接的累积

在极狐GitLab 17.11 及更高版本中，您可能会注意到从极狐GitLab 进程到外部服务的开放 TCP 连接数量增加。
这些连接会随时间累积且未正确关闭。

此问题与 Faraday 适配器在极狐GitLab 中从 `net_http` 切换到 `typhoeus` 进行连接池化有关。
有关更多信息，请参阅议题 550805。

要解决此问题，请将 [`elasticsearch_client_adapter`](../../../api/settings.md#available-settings) 设置为 `net_http`。