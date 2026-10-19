---
stage: Analytics
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 Elasticsearch 访问
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用 Elasticsearch 访问时，您可能会遇到以下问题。

<a id="set-configurations-in-the-rails-console"></a>

## 在 Rails 控制台中设置配置

请参见[启动 Rails 控制台会话](../../../administration/operations/rails_console.md#starting-a-rails-console-session)。

<a id="list-attributes"></a>

### 列出属性

要列出所有可用属性：

1. 打开 Rails 控制台（`sudo gitlab-rails console`）。
1. 运行以下命令：

```ruby
ApplicationSetting.last.attributes
```

输出包含 [Elasticsearch 集成](../../advanced_search/elasticsearch.md)中所有可用的设置，例如 `elasticsearch_indexing`、`elasticsearch_url`、`elasticsearch_replicas` 和 `elasticsearch_pause_indexing`。

<a id="set-attributes"></a>

### 设置属性

要设置 Elasticsearch 集成设置，请运行类似以下的命令：

```ruby
ApplicationSetting.last.update(elasticsearch_url: '<your ES URL and port>')

#or

ApplicationSetting.last.update(elasticsearch_indexing: false)
```

<a id="get-attributes"></a>

### 获取属性

要检查设置是在 [Elasticsearch 集成](../../advanced_search/elasticsearch.md)中设置的，还是在 Rails 控制台中设置的，请运行类似以下的命令：

```ruby
Gitlab::CurrentSettings.elasticsearch_url

#or

Gitlab::CurrentSettings.elasticsearch_indexing
```

<a id="change-the-password"></a>

### 更改密码

要更改 Elasticsearch 密码，请运行以下命令：

```ruby
es_url = Gitlab::CurrentSettings.current_application_settings

# Confirm the current Elasticsearch URL
es_url.elasticsearch_url

# Set the Elasticsearch URL
es_url.elasticsearch_url = "http://<username>:<password>@your.es.host:<port>"

# Save the change
es_url.save!
```

<a id="view-logs"></a>

## 查看日志

识别 Elasticsearch 集成问题最有价值的工具之一就是日志。与该集成最相关的日志有：

1. [`sidekiq.log`](../../../administration/logs/_index.md#sidekiqlog) - 所有索引操作都在 Sidekiq 中进行，因此与该 Elasticsearch 集成相关的大量日志都可以在此文件中找到。
1. [`elasticsearch.log`](../../../administration/logs/_index.md#elasticsearchlog) - 还有一些特定于 Elasticsearch 的日志会发送到此文件，其中可能包含有关搜索、索引或迁移的诊断信息。

以下是一些常见问题及其解决方法。

<a id="verify-that-your-gitlab-instance-is-using-elasticsearch"></a>

## 验证您的极狐GitLab 实例是否正在使用 Elasticsearch

要验证您的极狐GitLab 实例是否正在使用 Elasticsearch：

- 当您执行搜索时，在搜索结果页面的右上角，确保显示 **高级搜索已启用**。
- 在**管理**区域中，在 **设置** > **搜索** 下，检查是否已选择高级搜索设置。

  如有必要，也可以从 Rails 控制台获取这些相同的设置：

  ```ruby
  ::Gitlab::CurrentSettings.elasticsearch_search?         # Whether or not searches will use Elasticsearch
  ::Gitlab::CurrentSettings.elasticsearch_indexing?       # Whether or not content will be indexed in Elasticsearch
  ::Gitlab::CurrentSettings.elasticsearch_limit_indexing? # Whether or not Elasticsearch is limited only to certain projects/namespaces
  ```

- 通过访问 [Rails 控制台](../../../administration/operations/rails_console.md)并运行以下命令，确认搜索使用的是 Elasticsearch：

  ```rails
  u = User.find_by_email('email_of_user_doing_search')
  s = SearchService.new(u, {:search => 'search_term'})
  pp s.search_objects.class
  ```

  最后一条命令的输出是关键。如果它显示：

  - `ActiveRecord::Relation`，则表示未使用 Elasticsearch。
  - `Kaminari::PaginatableArray`，则表示正在使用 Elasticsearch。
- 如果 Elasticsearch 仅限于特定命名空间，而您需要知道某个特定项目或命名空间是否正在使用 Elasticsearch，可以使用 Rails 控制台：

  ```ruby
  ::Gitlab::CurrentSettings.search_using_elasticsearch?(scope: Namespace.find_by_full_path("/my-namespace"))
  ::Gitlab::CurrentSettings.search_using_elasticsearch?(scope: Project.find_by_full_path("/my-namespace/my-project"))
  ```

<a id="error-user-anonymous-is-not-authorized-to-perform-eseshttpget"></a>

## 错误：`User: anonymous is not authorized to perform: es:ESHttpGet`

将域级别访问策略与 AWS OpenSearch 或 Elasticsearch 一起使用时，AWS 角色未分配给正确的极狐GitLab 节点。GitLab Rails 和 Sidekiq 节点需要具有与搜索集群通信的权限。

```plaintext
User: anonymous is not authorized to perform: es:ESHttpGet because no resource-based policy allows the es:ESHttpGet
action
```

要解决此问题，请确保将 AWS 角色分配给正确的极狐GitLab 节点。

<a id="no-valid-region-specified"></a>

## 未指定有效区域

将 AWS 授权与高级搜索一起使用时，您指定的区域必须有效。

<a id="error-no-permissions-for-indicesdatawritebulk"></a>

## 错误：`no permissions for [indices:data/write/bulk]`

将精细访问控制与 IAM 角色或使用 AWS OpenSearch Dashboards 创建的角色一起使用时，您可能会遇到以下错误：

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

要解决此问题，您需要在 AWS OpenSearch Dashboards 中[将角色映射到用户](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/fgac.html#fgac-mapping)。

<a id="create-additional-master-users-in-aws-opensearch-service"></a>

## 在 AWS OpenSearch Service 中创建其他主用户

您可以在创建域时设置一个主用户。使用该用户，您可以创建其他主用户。有关更多信息，请参见 [AWS 文档](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/fgac.html#fgac-more-masters)。

要创建具有权限的用户和角色，并将用户映射到角色，请参见 [OpenSearch 文档](https://docs.opensearch.org/latest/security/access-control/users-roles/)。您必须在角色中包含以下权限：

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

## 打开的 TCP 连接不断累积

在极狐GitLab 17.11 及更高版本中，您可能会注意到从极狐GitLab 进程到外部服务的打开 TCP 连接有所增加。这些连接会随时间累积，并且没有被正确关闭。

此问题与 Faraday 适配器在极狐GitLab 中为连接池从 `net_http` 切换为 `typhoeus` 有关。有关更多信息，请参见[议题 550805](https://gitlab.com/gitlab-org/gitlab/-/issues/550805)。

要解决此问题，请将 [`elasticsearch_client_adapter`](../../../api/settings.md#available-settings) 设置为 `net_http`。

<a id="gitlabelasticinfo-reports-elasticsearch-even-when-the-search-cluster-is-opensearch"></a>

## 即使搜索集群是 OpenSearch，`gitlab:elastic:info` 仍报告 Elasticsearch

当[在 Amazon OpenSearch Service 中启用兼容模式](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/rename.html#rename-upgrade)时，OpenSearch 集群会向任何客户端报告其版本为 7.10.2，并将其发行版报告为 Elasticsearch。运行 `gitlab:elastic:info` 会将 `Server distribution` 显示为 Elasticsearch 及其版本。要检查是否启用了兼容模式，请直接查询集群的设置：

```json
curl --user "<username>:<password>" \
  "<opensearch_url>/_cluster/settings?include_defaults=true&pretty" \
  | grep -A2 override_main_response_version
```

如果 `compatibility.override_main_response_version` 为 `true`，则该集群运行的是 OpenSearch，并为了与面向 Elasticsearch 的客户端兼容而掩盖了自身身份。要让 `gitlab:elastic:info` 准确报告，请将其设置为 `false` 以禁用兼容模式。
