---
stage: Developer Experience
group: API Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 运行 GraphQL API 查询和变更
description: "Guide to running GraphQL queries and mutations with examples."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本指南演示了 极狐GitLab GraphQL API 的基本用法。

<a id="running-examples"></a>

## 运行示例

此处记录的示例可通过以下方式运行：

- [GraphiQL](#graphiql)。
- [命令行](#command-line)。
- [Rails 控制台](#rails-console)。

<a id="graphiql"></a>

### GraphiQL

GraphiQL（发音为 “graphical”）允许您交互式地对 API 运行实时 GraphQL 查询。
它通过提供具有语法高亮和自动补全功能的 UI，让探索 schema 变得更加容易。

对于大多数人来说，使用 GraphiQL 是探索 极狐GitLab GraphQL API 的最简单方式。

您可以在以下位置使用 GraphiQL：

- [在 JihuLab.com 上](https://jihulab.com/-/graphql-explorer)。
- 在私有化部署的 `https://<your-gitlab-site.com>/-/graphql-explorer` 上。

请先登录 极狐GitLab，以便使用您的 极狐GitLab 账户对请求进行身份认证。

要开始使用，请参考[示例查询和变更](#queries-and-mutations)。

<a id="command-line"></a>

### 命令行

您可以在本地计算机的命令行中通过 `curl` 请求运行 GraphQL 查询。
请求会以查询作为 payload，通过 `POST` 方法发送至 `/api/graphql`。
您可以生成一个[个人访问令牌](../../user/profile/personal_access_tokens.md)作为 bearer 令牌来授权您的请求。
了解更多关于 [GraphQL 认证](_index.md#authentication)的信息。

示例：

```shell
GRAPHQL_TOKEN=<your-token>
curl --request POST \
  --url "https://jihulab.com/api/graphql" \
  --header "Authorization: Bearer $GRAPHQL_TOKEN" \
  --header "Content-Type: application/json" \
  --data "{\"query\": \"query {currentUser {name}}\"}"
```

要在查询字符串中嵌套字符串，
请将数据用单引号引起来，或使用 ` \\ ` 对字符串进行转义：

```shell
curl --request POST \
  --url "https://jihulab.com/api/graphql" \
  --header "Authorization: Bearer $GRAPHQL_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"query": "query {project(fullPath: \"<group>/<subgroup>/<project>\") {jobs {nodes {id duration}}}}"}'
  # 或者 "{\"query\": \"query {project(fullPath: \\\"<group>/<subgroup>/<project>\\\") {jobs {nodes {id duration}}}}\"}"
```

<a id="rails-console"></a>

### Rails 控制台

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

GraphQL 查询可以在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)中运行。例如，搜索项目：

```ruby
current_user = User.find_by_id(1)
query = <<~EOQ
query securityGetProjects($search: String!) {
  projects(search: $search) {
    nodes {
      path
    }
  }
}
EOQ

variables = { "search": "gitlab" }

result = GitlabSchema.execute(query, variables: variables, context: { current_user: current_user })
result.to_h
```

<a id="queries-and-mutations"></a>

## 查询和变更

您可以使用 极狐GitLab GraphQL API 执行：

- 用于检索数据的查询。
- 用于创建、更新和删除数据的[变更](#mutations)。

> [!note]
> 在 极狐GitLab GraphQL API 中，`id` 指的是一个
> [全局 ID](https://graphql.org/learn/global-object-identification/)，
> 其格式为 `"gid://gitlab/Issue/123"` 的对象标识符。
> 有关更多信息，请参阅[全局 ID](_index.md#global-ids)。

[极狐GitLab GraphQL Schema](reference/_index.md) 概述了客户端可查询的对象和字段及其对应的数据类型。

示例：仅获取当前已认证用户在 `gitlab-org` 群组中能够访问的所有项目（有数量上限）的名称。

```graphql
query {
  group(fullPath: "gitlab-org") {
    id
    name
    projects {
      nodes {
        name
      }
    }
  }
}
```

示例：获取特定项目及第 2 号议题的标题。

```graphql
query {
  project(fullPath: "gitlab-org/graphql-sandbox") {
    name
    issue(iid: "2") {
      title
    }
  }
}
```

<a id="graph-traversal"></a>

### 图遍历

在检索子节点时使用：

- `edges { node { } }` 语法。
- 简写形式 `nodes { }` 语法。

其本质是您正在遍历一幅图，GraphQL 因此而得名。

示例：获取项目名称及其所有议题的标题。

```graphql
query {
  project(fullPath: "gitlab-org/graphql-sandbox") {
    name
    issues {
      nodes {
        title
        description
      }
    }
  }
}
```

更多关于查询的信息：
[GraphQL 文档](https://graphql.org/learn/queries/)

<a id="authorization"></a>

### 授权

如果您已登录 极狐GitLab 并使用 [GraphiQL](#graphiql)，所有查询都将以您（已认证用户）的身份执行。
有关更多信息，请阅读[GraphQL 认证](_index.md#authentication)。

<a id="mutations"></a>

### 变更

变更会对数据进行修改。我们可以更新、删除或创建新的记录。
变更通常使用 InputTypes 和变量，这里不作展示。

变更包含：

- 输入。例如，参数，如您想要添加的 emoji 表情反应，以及要添加到哪个对象上。
- 返回声明。即，当操作成功时您希望获取的结果。
- 错误。务必同时获取可能出现的错误信息，以防万一。

<a id="creation-mutations"></a>

#### 创建型变更

示例：让我们来喝杯茶 - 给一个议题添加一个 `:tea:` 表情反应。

```graphql
mutation {
  awardEmojiAdd(input: { awardableId: "gid://gitlab/Issue/27039960",
      name: "tea"
    }) {
    awardEmoji {
      name
      description
      unicode
      emoji
      unicodeVersion
      user {
        name
      }
    }
    errors
  }
}
```

示例：向议题添加一条评论。此示例使用了 `JihuLab.com` 议题的 ID。
如果您使用的是本地实例，必须获取一个您有写入权限的议题的 ID。

```graphql
mutation {
  createNote(input: { noteableId: "gid://gitlab/Issue/27039960",
      body: "*sips tea*"
    }) {
    note {
      id
      body
      discussion {
        id
      }
    }
    errors
  }
}
```

<a id="update-mutations"></a>

#### 更新型变更

当您看到已创建笔记的结果 `id` 后，请记下它。我们来编辑一下，以便喝得更快。

```graphql
mutation {
  updateNote(input: { id: "gid://gitlab/Note/<note ID>",
      body: "*SIPS TEA*"
    }) {
    note {
      id
      body
    }
    errors
  }
}
```

<a id="deletion-mutations"></a>

#### 删除型变更

让我们删除这条评论，因为我们的茶喝完了。

```graphql
mutation {
  destroyNote(input: { id: "gid://gitlab/Note/<note ID>" }) {
    note {
      id
      body
    }
    errors
  }
}
```

您应该会得到类似以下内容的输出：

```json
{
  "data": {
    "destroyNote": {
      "errors": [],
      "note": null
    }
  }
}
```

所请求的笔记已不存在，因此该字段的返回值为 `null`。

更多关于变更的信息：
[GraphQL 文档](https://graphql.org/learn/queries/#mutations)。

<a id="update-project-settings"></a>

### 更新项目设置

您可以在单个 GraphQL 变更中更新多个项目设置。
此示例是针对 `CI_JOB_TOKEN` 作用域行为[重大变更](../../update/deprecations.md#cicd-job-token---authorized-groups-and-projects-allowlist-enforcement)的一种变通方法。

```graphql
mutation DisableCI_JOB_TOKENscope {
  projectCiCdSettingsUpdate(input:{fullPath: "<namespace>/<project-name>", inboundJobTokenScopeEnabled: false}) {
    ciCdSettings {
      inboundJobTokenScopeEnabled
    }
    errors
  }
}
```

<a id="introspection-queries"></a>

### 内省查询

客户端可以通过发起[内省查询](https://graphql.org/learn/introspection/)来向 GraphQL 端点查询其 schema 的信息。
这些查询旨在用作发现和诊断工具。

- 在开发和测试环境中，内省查询是针对实时 schema 执行的。
- 在生产环境中，内省查询返回一个静态 schema。
  - 内省查询不应被用于在生产环境中获取数据。
    更多信息请参见：
    - [GraphQL 生产环境中的内省](https://graphql.org/learn/introspection/#introspection-in-production)
    - [Apollo 生产环境中的内省](https://www.apollographql.com/blog/why-you-should-disable-graphql-introspection-in-production#what-do-we-need-introspection-for)
  - 所有内省查询，无论请求方法或参数如何，皆返回相同的静态响应。
  - 静态 schema 会自动更新以匹配当前 schema。
  - 内省查询会返回两个静态 schema 文件中的一个：
    - `public/-/graphql/introspection_result.json`：完整的 schema，包括已弃用的字段。
    - `public/-/graphql/introspection_result_no_deprecated.json`：不包含已弃用字段的 schema。

要请求该 schema，请在请求正文中发送以下内容：

```json
{
  "query": "{ __schema { types { name } } }"
}
```

要请求不包含已弃用字段的 schema，请在请求正文中包含 `remove_deprecated: true`：

```json
{
  "query": "{ __schema { types { name } } }",
  "remove_deprecated": true
}
```

<a id="graphiql-introspection-queries"></a>

#### GraphiQL 内省查询

[GraphiQL 查询浏览器](#graphiql) 使用内省查询来：

- 获取关于 极狐GitLab GraphQL schema 的信息。
- 实现自动补全。
- 提供其交互式 `Docs` 选项卡。

更多关于内省的信息：
[GraphQL 文档](https://graphql.org/learn/introspection/)

<a id="query-complexity"></a>

### 查询复杂度

客户端可以通过查询 `queryComplexity` 来获知查询的[复杂度得分及其限制](_index.md#maximum-query-complexity)。

```graphql
query {
  queryComplexity {
    score
    limit
  }

  project(fullPath: "gitlab-org/graphql-sandbox") {
    name
  }
}
```

<a id="sorting"></a>

## 排序

极狐GitLab GraphQL API 中的某些端点允许您指定如何对对象集合进行排序。
您只能根据 schema 所允许的方式进行排序。

示例：议题可以按创建日期排序：

```graphql
query {
  project(fullPath: "gitlab-org/graphql-sandbox") {
   name
    issues(sort: created_asc) {
      nodes {
        title
        createdAt
      }
    }
  }
}
```

<a id="pagination"></a>

## 分页

分页是一种仅请求部分记录（如前十条）的方式。
如果您想要更多记录，可以向服务器发起另一个请求，以获取接下来十条记录，形式类似于 `请给我接下来十条记录`。

默认情况下，极狐GitLab GraphQL API 每页返回 100 条记录。
要更改此行为，请使用 `first` 或 `last` 参数。这两个参数都需要一个值，
因此 `first: 10` 将返回前十条记录，而 `last: 10` 将返回最后十条记录。
每页返回的记录数量存在限制，通常为 `100` 条。

示例：仅获取前两个议题（切片）。`cursor` 字段为您提供了一个位置，
您可以从该位置开始检索相对于该位置的其他记录。

```graphql
query {
  project(fullPath: "gitlab-org/graphql-sandbox") {
    name
    issues(first: 2) {
      edges {
        node {
          title
        }
      }
      pageInfo {
        endCursor
        hasNextPage
      }
    }
  }
}
```

示例：获取接下来的三个议题。（游标值
`eyJpZCI6IjI3MDM4OTMzIiwiY3JlYXRlZF9hdCI6IjIwMTktMTEtMTQgMDU6NTY6NDQgVVRDIn0`
可能会有所不同，但这是上面返回的第二个议题所对应的 `cursor` 值。）

```graphql
query {
  project(fullPath: "gitlab-org/graphql-sandbox") {
    name
    issues(first: 3, after: "eyJpZCI6IjI3MDM4OTMzIiwiY3JlYXRlZF9hdCI6IjIwMTktMTEtMTQgMDU6NTY6NDQgVVRDIn0") {
      edges {
        node {
          title
        }
        cursor
      }
      pageInfo {
        endCursor
        hasNextPage
      }
    }
  }
}
```

更多关于分页和游标的信息：
[GraphQL 文档](https://graphql.org/learn/pagination/)

<a id="file-uploads"></a>

## 文件上传

某些变更接受文件上传作为参数。这些变更使用
[GraphQL multipart request 规范](https://github.com/jaydenseric/graphql-multipart-request-spec)，
该规范允许您在使用 `multipart/form-data` 请求时，同时发送文件和 GraphQL 操作。

支持文件上传的变更具有 `Upload` 类型的参数。
您可以在 [GraphQL API 参考](reference/_index.md)中通过查找具有 `Upload` 标量类型的参数来识别这些变更。

文件上传变更无法通过 [GraphiQL](#graphiql) 运行。您必须使用
像 `curl` 这样的[命令行](#command-line)工具或兼容的 GraphQL 客户端库。

一个 multipart 上传请求包含三个关键部分：

- `operations`：一个 JSON 字符串，包含 GraphQL 查询和变量，其中文件值设为 `null`。
- `map`：一个 JSON 对象，将文件键映射到 operations 中的变量路径。
- 文件字段本身，由 `map` 中使用的键进行引用。

要使用 `designManagementUpload` 变更向议题上传设计：

```shell
GRAPHQL_TOKEN=<your-token>
curl --request POST \
  --url "https://jihulab.com/api/graphql" \
  --header "Authorization: Bearer $GRAPHQL_TOKEN" \
  --form 'operations={"query": "mutation ($files: [Upload!]!, $projectPath: ID!, $iid: ID!) { designManagementUpload(input: { projectPath: $projectPath, iid: $iid, files: $files }) { designs { filename } errors } }", "variables": {"files": [null], "projectPath": "<group>/<project>", "iid": "<issue-iid>"}}' \
  --form 'map={"0": ["variables.files.0"]}' \
  --form '0=@/path/to/your/design.png'
```

要使用 `workItemsCsvImport` 变更从 CSV 文件导入工作项：

```shell
GRAPHQL_TOKEN=<your-token>
curl --request POST \
  --url "https://jihulab.com/api/graphql" \
  --header "Authorization: Bearer $GRAPHQL_TOKEN" \
  --form 'operations={"query": "mutation ($projectPath: ID!, $file: Upload!) { workItemsCsvImport(input: { projectPath: $projectPath, file: $file }) { message errors } }", "variables": {"projectPath": "<group>/<project>", "file": null}}' \
  --form 'map={"0": ["variables.file"]}' \
  --form '0=@/path/to/your/work-items.csv'
```

要在单个请求中上传多个文件，请向 `map` 和表单字段中添加额外的条目：

```shell
GRAPHQL_TOKEN=<your-token>
curl --request POST \
  --url "https://jihulab.com/api/graphql" \
  --header "Authorization: Bearer $GRAPHQL_TOKEN" \
  --form 'operations={"query": "mutation ($files: [Upload!]!, $projectPath: ID!, $iid: ID!) { designManagementUpload(input: { projectPath: $projectPath, iid: $iid, files: $files }) { designs { filename } errors } }", "variables": {"files": [null, null], "projectPath": "<group>/<project>", "iid": "<issue-iid>"}}' \
  --form 'map={"0": ["variables.files.0"], "1": ["variables.files.1"]}' \
  --form '0=@/path/to/first-design.png' \
  --form '1=@/path/to/second-design.png'
```

<a id="changing-the-query-url"></a>

## 更改查询 URL

有时，需要将 GraphQL 请求发送到不同的 URL。一个例子是 `GeoNode` 查询，它只能针对冗灾辅助站点的 URL 运行。

要更改 GraphiQL 浏览器中 GraphQL 请求的 URL，请在 GraphiQL 的 Header 区域（左下角区域，紧挨 Variables 的位置）设置一个自定义 header：

```json
{
  "REQUEST_PATH": "<用于发起 graphQL 请求的 URL>"
}
```