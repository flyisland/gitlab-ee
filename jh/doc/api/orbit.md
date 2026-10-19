---
stage: Orbit
group: Context Systems
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 用于运行 Orbit 查询、检索 schemas 并检查集群健康状况的 REST API。
title: Orbit API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Status: 测试版

{{< /details >}}

使用此 API 为 [Orbit](https://jihulab.com/gitlab-cn/orbit/knowledge-graph) 运行查询、检索 schemas 并检查集群健康状况。

<a id="endpoint-reference"></a>

## 端点参考

有关 Orbit 端点的完整参考（包括路径、参数和响应），请参阅[交互式 API 参考](https://api.gitlab.com/rest/#tag/orbit)。以下各节介绍生成的参考中未展示的查询 DSL 行为和完整示例。

<a id="query-mode"></a>

## 查询模式

> [!flag]
> GQL 查询模式的可用性由名为 `orbit_gql_queries`的功能标志控制。

默认情况下，查询需要 JSON DSL 对象。启用 `orbit_gql_queries` 后，查询将改为使用只读 GQL 字符串，发现功能也将改为使用 GQL 指引。
GQL 遵循 openCypher 9 语法。
该功能标志针对单个用户。REST 和 MCP 调用方无法通过参数或请求头覆盖该模式。启用该功能标志后，`response_format: gql` 会将查询结果以纯文本表格形式返回。

<a id="skills"></a>

## Skills

Skill 端点需要使用 `read_api` 范围进行身份验证。它们不检查 Orbit 许可证，因此不可用的 skill 会返回 `404 Not Found`，而不是 `403 Forbidden`。在以下情况下，响应为 `404 Not Found`，并带有消息 `Skills are not available`：

- 知识图谱服务是较旧版本，不包含 skill RPC。
- 实例上未配置知识图谱服务。在极狐GitLab 私有化部署上，这由 `gitlab.yml`中的 `orbit.enabled` 控制，或由旧版 `knowledge_graph.enabled` 设置控制。
- 当前用户在某个已开启 Orbit 的顶级群组中不具备至少报告者角色。处于管理员模式的管理员和审计员不受此角色要求限制。

在这些情况下，Orbit CLI 会使用其内嵌的本地 skill。

<a id="list-deployed-skills"></a>

### 列出已部署的 skill

列出随所连接的知识图谱服务一起部署的 Orbit skill。

```plaintext
GET /orbit/skills
```

此请求不接受任何属性。

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
| --------- | ---- | ----------- |
| `server_version` | string | 已部署知识图谱服务的版本。 |
| `skills` | array | 已部署的 skill。 |
| `skills[].compatibility` | string | 来自 skill 清单的环境要求。 |
| `skills[].description` | string | 来自 skill 清单的描述。 |
| `skills[].name` | string | Skill 名称。 |
| `skills[].version` | string | 来自清单的 skill 版本。 |

响应包含一个 `ETag` 响应头（根据排序后的 skill 名称和版本生成），以及一个设置为 `private, max-age=0, must-revalidate`的 `Cache-Control` 响应头。

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/orbit/skills"
```

示例响应：

```json
{
  "skills": [
    {
      "name": "orbit",
      "version": "0.29.0",
      "description": "Use the glab orbit CLI for knowledge graph queries.",
      "compatibility": "Requires Orbit CLI"
    }
  ],
  "server_version": "0.31.0"
}
```

<a id="retrieve-a-deployed-skill"></a>

### 检索已部署的 skill

检索完整的已部署 Orbit skill 树。

```plaintext
GET /orbit/skills/:name
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `name` | string | 是 | Skill 名称。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
| --------- | ---- | ----------- |
| `compatibility` | string | 来自 skill 清单的环境要求。 |
| `files` | array | Skill 树中的文件。 |
| `files[].content` | string | UTF-8 文件内容。 |
| `files[].path` | string | 相对于 skill 根目录的规范化路径。 |
| `files[].sha256` | string | 文件内容的 SHA-256 哈希。 |
| `name` | string | Skill 名称。 |
| `server_version` | string | 已部署知识图谱服务的版本。 |
| `version` | string | Skill 版本。 |

响应包含以下响应头：

| 响应头 | 描述 |
| ------ | ----------- |
| `Cache-Control` | 设置为 `private, max-age=0, must-revalidate`。 |
| `ETag` | 设置为 `"<version>"`。 |

在 `If-None-Match` 请求头中发送当前的 `ETag` 值，以重新验证缓存的 skill 树。如果值匹配，则返回 `304 Not Modified`，且没有响应正文。

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/orbit/skills/orbit"
```

示例响应：

```json
{
  "name": "orbit",
  "version": "0.29.0",
  "compatibility": "Requires Orbit CLI",
  "server_version": "0.31.0",
  "files": [
    {
      "path": "SKILL.md",
      "sha256": "93f2655e8772217e4aa8c8fbe3ad0c1f36b2bdf4a63f9f6e2f6d89a3b01da9f8",
      "content": "# Orbit skill\n"
    }
  ]
}
```

如果 skill 不存在，则返回 `404 Not Found`，并在错误消息中列出已知的 skill 名称。

<a id="check-deployed-skill-metadata"></a>

### 检查已部署 skill 的元数据

检查已部署 skill 的身份和缓存响应头，而不检索其文件。

```plaintext
HEAD /orbit/skills/:name
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `name` | string | 是 | Skill 名称。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes)，以及与 `GET /orbit/skills/:name` 相同的 `ETag` 和 `Cache-Control` 响应头，且没有响应正文。

示例请求：

```shell
curl --head \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/orbit/skills/orbit"
```

<a id="retrieve-a-deployed-skill-file"></a>

### 检索已部署的 skill 文件

以原始 UTF-8 文本形式检索已部署 skill 中的一个文件。使用此路由可直接获取 `SKILL.md`，或跟随相对链接访问同一 skill 树中的文件。

```plaintext
GET /orbit/skills/:name/*path
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `name` | string | 是 | 已部署的 skill 名称。 |
| `path` | string | 是 | 相对于 skill 根目录的文件路径，例如 `references/usage.md`。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及文件内容，而不是 JSON 对象。Markdown 文件（`.md`）的内容类型为 `text/markdown; charset=utf-8`。其他文件的内容类型为 `text/plain; charset=utf-8`；任何 skill 文件都不会以 HTML 形式提供。只有 skill 清单中列出的确切路径才可用。未知路径返回 `404 Not Found`。格式错误的路径可能返回 `400 Bad Request`。API 错误响应为 JSON，而不是原始文件内容；被路径遍历中间件阻止的请求可能返回纯文本错误。

响应包含一个基于文件 SHA-256 的强 `ETag`，以及一个设置为 `private, max-age=0, must-revalidate`的 `Cache-Control` 响应头。在 `If-None-Match`中发送 `ETag`，以便在文件未更改时收到 `304 Not Modified`。`HEAD` 返回相同的响应头，但没有正文。

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/orbit/skills/orbit/SKILL.md"
```

示例响应：

```markdown
# Orbit skill
```

<a id="named-queries"></a>

## 命名查询

对于程序化调用方，优先使用 `POST /api/v4/orbit/query/:name`，而不是 `POST /api/v4/orbit/query`。命名查询的结构位于服务器上，因此不会偏离 DSL 语法或本体。命名请求保留 JSON 信封，并在当前活动模式下运行模板。

<a id="query-templates"></a>

## 查询模板

`GET /api/v4/orbit/query/templates`中列出的命名查询模板包含为已通过身份验证的用户渲染的 `raw_query`：

- 在 JSON 模式下，模板包含 JSON 对象；在 GQL 模式下，模板包含 GQL 字符串。
- 身份值（例如已通过身份验证的用户的 ID）在服务器端根据请求凭据解析。同一请求会为不同用户返回
  不同的 `raw_query` 值。请勿跨用户或跨模式缓存或共享模板。
- 通过名称及其参数调用参数化查询，因为目录中不包含这些查询。

优先直接执行命名查询，而不是使用模板。仅在目标是显示查询文本时使用模板，例如用预设的文本填充查询编辑器或探索界面。

<a id="query-examples"></a>

## 查询示例

以下示例展示每种查询类型的 Orbit 查询 DSL。所有示例都使用 `POST /api/v4/orbit/query`。有关完整的查询语言，请参阅
[Orbit 查询语言](https://docs.gitlab.cn/docs/orbit/remote/queries/query-language/)。

在 GQL 模式下，将 GQL 字符串作为 `query` 值传递给 `POST /api/v4/orbit/query`：

```json
{"query": "MATCH (u:User {id: 1}) RETURN u LIMIT 1"}
```

这些示例使用默认的 `raw` 响应格式。在每个响应中，`result` 对象列出匹配的 `nodes` 以及它们之间的 `edges`。节点 ID 为字符串。聚合查询还会返回 `columns`、`group_columns` 和 `rows`。

按用户名检索用户：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "query": {
      "query_type": "traversal",
      "nodes": [
        {"id": "u", "entity": "User", "filters": {"username": "john_smith"}}
      ]
    }
  }' \
  --url "https://gitlab.example.com/api/v4/orbit/query"
```

示例响应：

```json
{
  "result": {
    "format_version": "5.0.3",
    "query_type": "traversal",
    "nodes": [
      {"type": "User", "id": "1", "username": "john_smith", "name": "John Smith", "state": "active"}
    ],
    "edges": [],
    "pagination": {"has_more": false, "truncated": false}
  },
  "query_type": "traversal",
  "row_count": 1
}
```

查找项目中已合并的合并请求：

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
  "result": {
    "format_version": "5.0.3",
    "query_type": "traversal",
    "nodes": [
      {"type": "Project", "id": "8", "name": "Diaspora Client", "full_path": "diaspora/diaspora-client", "visibility_level": "public"},
      {"type": "MergeRequest", "id": "43", "iid": 1, "title": "Resolve connection timeout on large payloads", "state": "merged", "source_branch": "fix-timeout", "target_branch": "main"},
      {"type": "MergeRequest", "id": "44", "iid": 2, "title": "Replace deprecated API calls in federation module", "state": "merged", "source_branch": "update-federation-api", "target_branch": "main"}
    ],
    "edges": [
      {"from": "MergeRequest", "from_id": "43", "to": "Project", "to_id": "8", "type": "IN_PROJECT"},
      {"from": "MergeRequest", "from_id": "44", "to": "Project", "to_id": "8", "type": "IN_PROJECT"}
    ],
    "pagination": {"has_more": false, "truncated": false}
  },
  "query_type": "traversal",
  "row_count": 2
}
```

统计每个项目的合并请求数量。遍历和聚合查询必须使用 `node_ids` 或过滤器限定至少一个节点：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "query": {
      "query_type": "aggregation",
      "nodes": [
        {"id": "p", "entity": "Project", "node_ids": [5, 8]},
        {"id": "mr", "entity": "MergeRequest"}
      ],
      "relationships": [{"type": "IN_PROJECT", "from": "mr", "to": "p"}],
      "aggregations": [{"count": "mr", "as": "mr_count"}],
      "group_by": ["p"]
    }
  }' \
  --url "https://gitlab.example.com/api/v4/orbit/query"
```

示例响应：

```json
{
  "result": {
    "format_version": "5.0.3",
    "query_type": "aggregation",
    "nodes": [],
    "edges": [],
    "columns": [{"name": "mr_count", "function": "count", "target": "mr"}],
    "group_columns": [{"name": "p", "kind": "node", "node": "p", "entity": "Project"}],
    "rows": [
      {"p": {"type": "Project", "id": "8", "properties": {"name": "Diaspora Client", "full_path": "diaspora/diaspora-client", "visibility_level": "public"}}, "mr_count": 8},
      {"p": {"type": "Project", "id": "5", "properties": {"name": "Puppet", "full_path": "brightbox/puppet", "visibility_level": "public"}}, "mr_count": 6}
    ],
    "pagination": {"has_more": false, "truncated": false}
  },
  "query_type": "aggregation",
  "row_count": 2
}
```

查找用户的出站邻居。`direction` 属性接受 `outgoing`、`incoming` 或 `both`，默认为 `outgoing`：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "query": {
      "query_type": "neighbors",
      "nodes": [{"id": "u", "entity": "User", "node_ids": [1]}],
      "neighbors": {"direction": "outgoing"}
    }
  }' \
  --url "https://gitlab.example.com/api/v4/orbit/query"
```

示例响应：

```json
{
  "result": {
    "format_version": "5.0.3",
    "query_type": "neighbors",
    "nodes": [
      {"type": "User", "id": "1", "username": "john_smith", "name": "John Smith", "state": "active"},
      {"type": "Group", "id": "29", "name": "diaspora", "full_path": "diaspora", "visibility_level": "public"},
      {"type": "MergeRequest", "id": "43", "iid": "1", "title": "Resolve connection timeout on large payloads", "state": "merged", "source_branch": "fix-timeout", "target_branch": "main"},
      {"type": "MergeRequest", "id": "44", "iid": "2", "title": "Replace deprecated API calls in federation module", "state": "merged", "source_branch": "update-federation-api", "target_branch": "main"}
    ],
    "edges": [
      {"from": "User", "from_id": "1", "to": "Group", "to_id": "29", "type": "MEMBER_OF"},
      {"from": "User", "from_id": "1", "to": "MergeRequest", "to_id": "43", "type": "AUTHORED"},
      {"from": "User", "from_id": "1", "to": "MergeRequest", "to_id": "44", "type": "AUTHORED"}
    ],
    "pagination": {"has_more": false, "truncated": false}
  },
  "query_type": "neighbors",
  "row_count": 3
}
```

查找从用户到项目的最短路径。路径查找查询需要 `rel_types`，并且仅沿每种关系类型定义的方向遍历，从 `from` 节点朝向 `to` 节点：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "query": {
      "query_type": "path_finding",
      "nodes": [
        {"id": "u", "entity": "User", "node_ids": [1]},
        {"id": "p", "entity": "Project", "node_ids": [8]}
      ],
      "path": {
        "type": "shortest",
        "from": "u",
        "to": "p",
        "max_depth": 3,
        "rel_types": ["MEMBER_OF", "CONTAINS"]
      }
    }
  }' \
  --url "https://gitlab.example.com/api/v4/orbit/query"
```

示例响应：

```json
{
  "result": {
    "format_version": "5.0.3",
    "query_type": "path_finding",
    "nodes": [
      {"type": "User", "id": "1", "username": "john_smith", "name": "John Smith", "state": "active"},
      {"type": "Group", "id": "29", "name": "diaspora", "full_path": "diaspora", "visibility_level": "public"},
      {"type": "Project", "id": "8", "name": "Diaspora Client", "full_path": "diaspora/diaspora-client", "visibility_level": "public"}
    ],
    "edges": [
      {"from": "User", "from_id": "1", "to": "Group", "to_id": "29", "type": "MEMBER_OF", "path_id": 0, "step": 0},
      {"from": "Group", "from_id": "29", "to": "Project", "to_id": "8", "type": "CONTAINS", "path_id": 0, "step": 1}
    ],
    "pagination": {"has_more": false, "truncated": false}
  },
  "query_type": "path_finding",
  "row_count": 1
}
```

<a id="access-and-cluster-health"></a>

## 访问权限和集群健康状况

无论访问权限或服务健康状况如何，`GET /api/v4/orbit/status` 始终返回 [`200 OK`](rest/troubleshooting.md#status-codes)。当用户没有访问权限时，`system` 为 `null`：

```json
{
  "user": {
    "available": false
  },
  "system": null
}
```
