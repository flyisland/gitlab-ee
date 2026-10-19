---
stage: AI-powered
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Find relevant code snippets in your repository based on meaning rather than keyword matching.
title: 语义代码搜索
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.7 中引入，作为测试版。
- 在极狐GitLab 18.8 中添加到极狐GitLab Duo Core。
- 在极狐GitLab 18.9 中添加到极狐GitLab 专业版。

{{< /history >}}

语义代码搜索使用人工智能，根据含义而非关键词匹配，在您的仓库中查找相关代码片段。

语义代码搜索将您的代码库转换为向量嵌入，并将这些嵌入存储在向量数据库中。您的搜索查询也会转换为嵌入，然后与代码嵌入进行比较，以找到语义最相似的结果。这种方法即使关键词不匹配也能找到相关代码。

此功能的改进在史诗 18018 和史诗 20110 中提出。

<a id="prerequisites"></a>

## 前提条件

- 访问 [极狐GitLab AI 网关](../../administration/gitlab_duo/gateway.md)。
- 开启以下功能：
  - 对于 JihuLab.com，为顶级群组开启实验功能。
  - 对于私有化部署实例，开启 极狐GitLab Duo 实验和测试版功能。
- 为您的项目开启 [极狐GitLab Duo](../duo_agent_platform/turn_on_off.md#turn-gitlab-duo-on-or-off)。
- 配置以下向量存储之一：
  - Elasticsearch 8.0 及更高版本。
  - OpenSearch 2.0 及更高版本。
  - 带有 [`pgvector`](https://github.com/pgvector/pgvector) 扩展的 PostgreSQL。
- 管理员访问权限。

<a id="enable-semantic-code-search"></a>

## 启用语义代码搜索

<a id="with-the-ui"></a>

### 通过 UI

如果您的极狐GitLab 实例使用 Elasticsearch 或 OpenSearch 进行高级搜索，您可以通过连接到同一集群来启用语义代码搜索：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **搜索**。
1. 展开 **语义搜索**。
1. 选择 **连接到高级搜索集群**。

<a id="with-the-rails-console"></a>

### 通过 Rails 控制台

要为 Elasticsearch、OpenSearch 或 PostgreSQL 创建自定义向量存储连接，在 Rails 控制台中，使用 `adapter` 和 `options` 创建连接。

> [!note]
> 对于中型到大型仓库，应使用 Elasticsearch 或 OpenSearch。
> 仅对包含少量小型仓库的设置使用带有 `pgvector` 的 PostgreSQL。
> 使用 `pgvector` 时，索引和查询性能可能受限。

<a id="elasticsearch"></a>

#### Elasticsearch

```ruby
connection = Ai::ActiveContext::Connection.create!(
  name: "elasticsearch",
  options: options,
  adapter_class: "ActiveContext::Databases::Elasticsearch::Adapter"
)
connection.activate!
```

连接选项：

| 选项                     | 类型             | 是否必需 | 默认值    | 描述 |
|--------------------------|------------------|----------|------------|-------------|
| `url`                    | 字符串数组       | 是       | 无         | Elasticsearch 集群的 URL 数组（例如 `["http://localhost:9200"]`）。 |
| `client_adapter`         | 字符串           | 否       | `typhoeus` | 使用的 HTTP 适配器。可能值为 `typhoeus` 和 `net_http`。 |
| `client_request_timeout` | 整数             | 否       | `30`       | 请求超时时间（秒）。 |
| `retry_on_failure`       | 整数             | 否       | `0`        | 失败时的重试次数。 |
| `debug`                  | 布尔值           | 否       | `false`    | 启用调试日志。 |

<a id="opensearch"></a>

#### OpenSearch

```ruby
connection = Ai::ActiveContext::Connection.create!(
  name: "opensearch",
  options: options,
  adapter_class: "ActiveContext::Databases::Opensearch::Adapter"
)
connection.activate!
```

连接选项：

| 选项                     | 类型             | 是否必需 | 默认值    | 描述 |
|--------------------------|------------------|----------|------------|-------------|
| `url`                    | 字符串数组       | 是       | 无         | OpenSearch 集群的 URL 数组（例如 `["http://localhost:9200"]`）。 |
| `client_adapter`         | 字符串           | 否       | `typhoeus` | 使用的 HTTP 适配器。可能值为 `typhoeus` 和 `net_http`。 |
| `client_request_timeout` | 整数             | 否       | `30`       | 请求超时时间（秒）。 |
| `retry_on_failure`       | 整数             | 否       | `0`        | 失败时的重试次数。 |
| `debug`                  | 布尔值           | 否       | `false`    | 启用调试日志。 |
| `aws`                    | 布尔值           | 否       | `false`    | 启用 AWS 签名版本 4 签名。 |
| `aws_region`             | 字符串           | 否       | 无         | OpenSearch 域的 AWS 区域。 |
| `aws_access_key`         | 字符串           | 否       | 无         | AWS 访问密钥 ID。 |
| `aws_secret_access_key`  | 字符串           | 否       | 无         | AWS 秘密访问密钥。 |

<a id="postgresql-with-pgvector"></a>

#### 带有 `pgvector` 的 PostgreSQL

{{< history >}}

- 在极狐GitLab 18.8 中引入。

{{< /history >}}

对于 PostgreSQL，使用 [`pgvector`](https://github.com/pgvector/pgvector) 扩展：

1. 在 PostgreSQL 数据库中，创建扩展：

   ```sql
   CREATE EXTENSION vector;
   ```

1. 在 Rails 控制台中，创建连接：

   ```ruby
   connection = Ai::ActiveContext::Connection.create!(
     name: "postgres",
     options: options,
     adapter_class: "ActiveContext::Databases::Postgresql::Adapter"
   )
   connection.activate!
   ```

连接选项：

| 选项           | 类型    | 是否必需 | 默认值 | 描述 |
|------------------|---------|----------|---------|-------------|
| `host`           | 字符串  | 是       | 无      | PostgreSQL 主机。 |
| `port`           | 整数    | 否       | 无      | PostgreSQL 端口。 |
| `database`       | 字符串  | 否       | 无      | 数据库名称。 |
| `user`           | 字符串  | 否       | 无      | PostgreSQL 用户。 |
| `password`       | 字符串  | 否       | 无      | PostgreSQL 密码。 |
| `connect_timeout`| 整数    | 否       | `5`     | 连接超时时间（秒）。 |
| `pool_size`      | 整数    | 否       | `5`     | 连接池大小。 |

<a id="check-semantic-code-search-status"></a>

## 检查语义代码搜索状态

{{< history >}}

- 在极狐GitLab 19.0 中引入。

{{< /history >}}

前提条件：

- 管理员访问权限。

要检查语义代码搜索的状态，包括索引状态、向量存储连接详情、仓库统计信息和嵌入队列大小，运行以下 Rake 任务：

```shell
sudo gitlab-rake gitlab:semantic_search:code:info
```

要持续监控状态，提供以秒为单位的监视间隔：

```shell
sudo gitlab-rake "gitlab:semantic_search:code:info[5]"
```

此任务按指定间隔刷新输出。要停止任务，请按 <kbd>Control</kbd>+<kbd>C</kbd>。

<a id="use-semantic-code-search"></a>

## 使用语义代码搜索

语义代码搜索作为极狐GitLab MCP 服务器工具提供。有关如何使用此工具的更多信息，请参阅 [`semantic_code_search`](model_context_protocol/mcp_server_tools.md#semantic_code_search)。

当您首次在极狐GitLab 项目中使用语义代码搜索时：

- 您的仓库代码被索引并转换为向量嵌入。
- 这些嵌入存储在您配置的向量存储中。
- 当代码合并到默认分支时，更新会增量处理。

初始索引可能需要一段时间，具体取决于仓库大小。