---
stage: Analytics
group: Knowledge Graph
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: REST API to run queries, retrieve schemas, and check cluster health for Orbit.
title: Orbit API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Status: 实验性

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 18.10，并带有一个名为 `knowledge_graph` 的[功能标志](../administration/feature_flags/_index.md)。此功能是[实验](../policy/development_stages_support.md)性的，受[极狐GitLab 测试协议](https://handbook.gitlab.com/handbook/legal/testing-agreement/)约束。

{{< /history >}}

> [!flag]
> 此功能的可用性由一个功能标志控制。
> 更多信息，请参见历史记录。
> 此功能可用于测试，但不适合用于生产环境。

使用此 API 为 [Orbit](https://jihulab.com/gitlab-cn/orbit/knowledge-graph) 运行查询、检索模式和检查集群健康状况。

<a id="create-a-query"></a>

## 创建查询

对 Orbit gRPC 服务创建并执行查询。

```plaintext
POST /api/v4/orbit/query
```

支持的属性：

| 属性 | 类型 | 必填 | 描述 |
| --- | --- | --- | --- |
| `query` | object | 是 | 查询 DSL 对象。 |
| `query_type` | string | 否 | 查询语言。仅支持 `json`。默认为 `json`。 |
| `response_format` | string | 否 | `raw` 或 `llm` 之一。默认为 `raw`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
| --- | --- | --- |
| `result` | array 或 string | 查询结果。当 `raw` 时为数组，当 `llm` 时为字符串。 |
| `query_type` | string | 查询语言，例如 `json`。 |
| `raw_query_strings` | string array | 执行的底层查询。 |
| `row_count` | integer | 返回的行数。 |

<a id="examples"></a>

### 示例

根据用户名检索用户：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "query": {
      "query_type": "search",
      "node": {"id": "u", "entity": "User", "filters": {"username": "john_smith"}}
    }
  }' \
  --url "https://gitlab.example.com/api/v4/orbit/query"
```

示例响应：

```json
{
  "result": [
    {
      "u_id": 1,
      "u_username": "john_smith",
      "u_name": "John Smith",
      "u_state": "active",
      "u_type": "User"
    }
  ],
  "query_type": "search",
  "row_count": 1
}
```

在项目中查找已合并的合并请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "query": {
      "query_type": "traversal",
      "nodes": [
        {"id": "p", "entity": "Project", "node_ids": [8]},
        {"id": "mr", "entity": "MergeRequest", "filters": {"state": "merged"}}
      ],
      "relationships": [{"type": "IN_PROJECT", "from": "mr", "to": "p"}]
    }
  }' \
  --url "https://gitlab.example.com/api/v4/orbit/query"
```

示例响应：

```json
{
  "result": [
    {
      "p_name": "Diaspora Client",
      "p_full_path": "diaspora/diaspora-client",
      "mr_id": 43,
      "mr_iid": 1,
      "mr_title": "Resolve connection timeout on large payloads",
      "mr_state": "merged"
    },
    {
      "mr_id": 44,
      "mr_iid": 2,
      "mr_title": "Replace deprecated API calls in federation module",
      "mr_state": "merged"
    }
  ],
  "query_type": "traversal",
  "row_count": 2
}
```

按项目统计合并请求数量：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "query": {
      "query_type": "aggregation",
      "nodes": [
        {"id": "p", "entity": "Project"},
        {"id": "mr", "entity": "MergeRequest"}
      ],
      "relationships": [{"type": "IN_PROJECT", "from": "mr", "to": "p"}],
      "aggregations": [{"function": "count", "target": "mr", "group_by": "p", "alias": "mr_count"}]
    }
  }' \
  --url "https://gitlab.example.com/api/v4/orbit/query"
```

示例响应：

```json
{
  "result": [
    {"p_name": "Diaspora Client", "p_full_path": "diaspora/diaspora-client", "mr_count": 8},
    {"p_name": "Puppet", "p_full_path": "brightbox/puppet", "mr_count": 6}
  ],
  "query_type": "aggregation",
  "row_count": 2
}
```

查找用户的外向邻居：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "query": {
      "query_type": "neighbors",
      "node": {"id": "u", "entity": "User", "node_ids": [43]},
      "neighbors": {"node": "u"}
    }
  }' \
  --url "https://gitlab.example.com/api/v4/orbit/query"
```

示例响应：

```json
{
  "result": [
    {
      "_gkg_relationship_type": "MEMBER_OF",
      "_gkg_neighbor_type": "Project",
      "id": 5,
      "name": "Diaspora Client"
    },
    {
      "_gkg_relationship_type": "MEMBER_OF",
      "_gkg_neighbor_type": "Group",
      "id": 29,
      "name": "diaspora"
    },
    {
      "_gkg_relationship_type": "AUTHORED",
      "_gkg_neighbor_type": "MergeRequest",
      "id": 43,
      "title": "Resolve connection timeout on large payloads"
    }
  ],
  "query_type": "neighbors",
  "row_count": 3
}
```

查找两个项目之间的最短路径：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "query": {
      "query_type": "path_finding",
      "nodes": [
        {"id": "p1", "entity": "Project", "node_ids": [8]},
        {"id": "p2", "entity": "Project", "node_ids": [5]}
      ],
      "path": {"type": "shortest", "from": "p1", "to": "p2", "max_depth": 3}
    }
  }' \
  --url "https://gitlab.example.com/api/v4/orbit/query"
```

示例响应：

```json
{
  "result": [
    {
      "depth": 2,
      "path": [
        {"id": 8, "entity_type": "Project", "name": "Diaspora Client", "full_path": "diaspora/diaspora-client"},
        {"id": 43, "entity_type": "User", "name": "John Smith", "username": "john_smith"},
        {"id": 5, "entity_type": "Project", "name": "Puppet", "full_path": "brightbox/puppet"}
      ],
      "edges": ["MEMBER_OF", "MEMBER_OF"]
    }
  ],
  "query_type": "path_finding",
  "row_count": 1
}
```

<a id="retrieve-the-schema"></a>

## 检索模式

检索 Orbit 模式。

```plaintext
GET /api/v4/orbit/schema
```

支持的属性：

| 属性 | 类型 | 必填 | 描述 |
| --- | --- | --- | --- |
| `expand` | string | 否 | 要展开的节点名称，以逗号分隔。 |
| `response_format` | string | 否 | `raw` 或 `llm` 之一。默认为 `raw`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
| --- | --- | --- |
| `schema_version` | string | 模式版本。 |
| `domains` | object array | 域定义。 |
| `nodes` | object array | 节点类型定义。 |
| `edges` | object array | 边类型定义。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/orbit/schema?expand=MergeRequest"
```

示例响应：

```json
{
  "schema_version": "0.1",
  "domains": [
    {"name": "ci", "description": "与 CI/CD 流水线、阶段和作业相关的实体。", "node_names": ["Job", "Pipeline", "Stage"]},
    {"name": "code_review", "node_names": ["MergeRequest", "MergeRequestDiff", "MergeRequestDiffFile"]},
    {"name": "core", "node_names": ["Group", "Note", "Project", "User"]},
    {"name": "plan", "node_names": ["Label", "Milestone", "WorkItem"]},
    {"name": "security", "node_names": ["Finding", "SecurityScan", "Vulnerability"]},
    {"name": "source_code", "node_names": ["Branch", "Definition", "Directory", "File", "ImportedSymbol"]}
  ],
  "nodes": [],
  "edges": []
}
```

<a id="retrieve-cluster-health"></a>

## 检索集群健康状况

检索集群健康状况和组件状态。即使服务不可达，此端点也始终返回 `200 OK`。请检查 `status` 字段确定健康状况。

```plaintext
GET /api/v4/orbit/status
```

支持的属性：

| 属性 | 类型 | 必填 | 描述 |
| --- | --- | --- | --- |
| `response_format` | string | 否 | `raw` 或 `llm` 之一。默认为 `raw`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
| --- | --- | --- |
| `status` | string | 集群健康状况，例如 `healthy` 或 `unknown`。 |
| `timestamp` | string | 健康检查的时间戳。 |
| `version` | string | 服务版本。 |
| `components` | object array | 各个组件的状态。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/orbit/status"
```

示例响应：

```json
{
  "status": "healthy",
  "timestamp": "2026-03-05T15:08:35.885160548+00:00",
  "version": "0.1.0",
  "components": [
    {"name": "gkg-indexer", "status": "healthy", "replicas": {"ready": 1, "desired": 1}, "metrics": {}},
    {"name": "gkg-webserver", "status": "healthy", "replicas": {"ready": 1, "desired": 1}, "metrics": {}},
    {"name": "clickhouse", "status": "healthy", "replicas": {"ready": 0, "desired": 0}, "metrics": {}}
  ]
}
```

<a id="list-all-tools"></a>

## 列出所有工具

列出所有可用的 Orbit 操作。

```plaintext
GET /api/v4/orbit/tools
```

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和一个工具对象数组，包含以下属性：

| 属性 | 类型 | 描述 |
| --- | --- | --- |
| `name` | string | 工具名称。 |
| `description` | string | 工具描述。 |
| `parameters` | object | 工具的参数架构。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/orbit/tools"
```

示例响应：

```json
[
  {
    "name": "query_graph",
    "description": "执行图查询以查找节点、遍历关系……",
    "parameters": {
      "type": "object",
      "required": ["query"],
      "properties": {"query": {"type": "object"}}
    }
  },
  {
    "name": "get_graph_schema",
    "description": "列出极狐GitLab 知识图谱模式……",
    "parameters": {
      "type": "object",
      "properties": {"expand_nodes": {"type": "array"}}
    }
  }
]
```