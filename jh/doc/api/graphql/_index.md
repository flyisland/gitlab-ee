---
stage: Developer Experience
group: API Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 以编程方式与极狐GitLab 交互。
title: GraphQL API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[GraphQL](https://graphql.org/) 是一种用于 API 的查询语言。您可以使用它请求所需的确切数据，从而限制所需的请求数量。

GraphQL 数据按类型组织，因此您的客户端可以使用
[客户端 GraphQL 库](https://graphql.org/community/tools-and-libraries/)
来使用 API，并避免手动解析。

GraphQL API 是[无版本的](https://graphql.org/learn/schema-design/#versioning)。

<a id="getting-started"></a>

## 开始使用

如果您是极狐GitLab GraphQL API 的新用户，请参阅[开始使用极狐GitLab GraphQL API](getting_started.md)。

您可以在 [GraphQL API 参考](reference/_index.md)中查看可用的资源。

极狐GitLab GraphQL API 端点位于 `/api/graphql`。

<a id="interactive-graphql-explorer"></a>

### 交互式 GraphQL 浏览器

使用交互式 GraphQL 浏览器探索 GraphQL API，您可以：

- [在 JihuLab.com 上](https://jihulab.com/-/graphql-explorer)。
- 在极狐GitLab 私有化部署上，访问 `https://<your-gitlab-site.com>/-/graphql-explorer`。

更多信息，请参阅 [GraphiQL](getting_started.md#graphiql)。

<a id="view-graphql-examples"></a>

### 查看 GraphQL 示例

您可以使用从 JihuLab.com 上的公开项目拉取数据的示例查询：

- [创建审计报告](audit_report.md)
- [识别议题看板](sample_issue_boards.md)
- [查询用户](users_example.md)
- [使用自定义表情](custom_emoji.md)

[开始使用](getting_started.md)页面介绍了自定义 GraphQL 查询的不同方法。

<a id="authentication"></a>

### 身份验证

部分查询无需身份验证即可访问，但其他查询需要身份验证。变更操作始终需要身份验证。

您可以使用以下任一方式进行身份验证：

- [令牌](#token-authentication)
- [会话 Cookie](#session-cookie-authentication)

如果身份验证信息无效，极狐GitLab 会返回一条错误消息，状态码为 `401`：

```json
{"errors":[{"message":"Invalid token"}]}
```

<a id="token-authentication"></a>

#### 令牌身份验证

使用以下任一令牌向 GraphQL API 进行身份验证：

- [OAuth 2.0 令牌](../oauth2.md)
- [个人访问令牌](../../user/profile/personal_access_tokens.md)
- [项目访问令牌](../../user/project/settings/project_access_tokens.md)
- [群组访问令牌](../../user/group/settings/group_access_tokens.md)

通过[请求头](#header-authentication)或[参数](#parameter-authentication)传入令牌进行身份验证。

令牌需要正确的[范围](#token-scopes)。

<a id="header-authentication"></a>

##### 请求头身份验证

使用 `Authorization: Bearer <token>` 请求头进行令牌身份验证的示例：

```shell
curl --request POST \
  --url "https://jihulab.com/api/graphql" \
  --header "Authorization: Bearer <token>" \
  --header "Content-Type: application/json" \
  --data "{\"query\": \"query {currentUser {name}}\"}"
```

<a id="parameter-authentication"></a>

##### 参数身份验证

在 `access_token` 参数中使用 OAuth 2.0 令牌的示例：

```shell
curl --request POST \
  --url "https://jihulab.com/api/graphql?access_token=<oauth_token>" \
  --header "Content-Type: application/json" \
  --data "{\"query\": \"query {currentUser {name}}\"}"
```

您可以使用 `private_token` 参数传入个人、项目或群组访问令牌：

```shell
curl --request POST \
  --url "https://jihulab.com/api/graphql?private_token=<access_token>" \
  --header "Content-Type: application/json" \
  --data "{\"query\": \"query {currentUser {name}}\"}"
```

<a id="token-scopes"></a>

##### 令牌范围

令牌必须具有正确的范围才能访问 GraphQL API，可以是：

| 范围      | 访问权限 |
|------------|--------|
| `read_api` | 授予对 API 的读取访问权限。足以执行查询。 |
| `api`      | 授予对 API 的读写访问权限。变更操作需要此范围。 |

<a id="session-cookie-authentication"></a>

#### 会话 Cookie 身份验证

登录极狐GitLab 主应用程序会设置一个 `_gitlab_session` 会话 Cookie。

[交互式 GraphQL 浏览器](#interactive-graphql-explorer)和极狐GitLab 自身的 Web 前端使用此身份验证方法。

<a id="authorization"></a>

### 授权

身份验证后，GraphQL API 会检查您对每个所请求资源的权限。API 报告授权失败的方式取决于操作类型。

<a id="query-fields"></a>

#### 查询字段

当您没有访问某个资源的权限时，查询字段会返回 `null`。响应中不包含错误消息。

此行为是有意为之。对于未授权和不存在的资源，API 返回相同的 `null` 响应，这样客户端就无法枚举服务器上存在哪些资源。

例如，如果您查询的字段需要您不具备的角色或附加组件，则 `errors` 数组中不会显示任何条目：

```json
{
  "data": {
    "group": {
      "fieldRequiringPermission": null
    }
  }
}
```

对于使用 Relay 分页模式的[连接字段](getting_started.md#pagination)，您可以区分授权失败和空结果：

- `"field": null` 表示您没有访问此资源的权限。
- `"field": { "nodes": [] }` 表示您有权限，但没有数据与您的查询匹配。

如果您收到意外的 `null`，请确认：

- 您的令牌具有所需的[范围](#token-scopes)。
- 您的角色满足 [GraphQL API 参考](reference/_index.md)中记录的最低访问级别。
- 您的实例已启用所需的订阅层级、功能或附加组件。

<a id="mutations"></a>

#### 变更操作

授权失败时，变更操作会返回错误消息。该错误会出现在顶层 `errors` 数组中，同时数据字段为 `null`：

```json
{
  "data": {
    "mutationName": null
  },
  "errors": [
    {
      "message": "The resource that you are attempting to access does not exist or you don't have permission to perform this action",
      "locations": [{ "line": 2, "column": 3 }],
      "path": ["mutationName"]
    }
  ]
}
```

错误消息可能因资源类型而异。

<a id="object-identifiers"></a>

## 对象标识符

极狐GitLab GraphQL API 混合使用多种标识符。

[全局 ID](#global-ids)、完整路径和内部 ID（IID）在极狐GitLab GraphQL API 中都可用作参数，但通常 schema 的某个特定部分不会同时接受所有这些形式。

尽管极狐GitLab GraphQL API 在历史上对此并不一致，但一般来说您可以预期：

- 如果对象是项目、群组或命名空间，则使用对象的完整路径。
- 如果对象有 IID，则使用完整路径和 IID 的组合。
- 对于其他对象，则使用[全局 ID](#global-ids)。

例如，通过完整路径 `"gitlab-cn/gitlab"` 查找项目：

```graphql
{
  project(fullPath: "gitlab-cn/gitlab") {
    id
    fullPath
  }
}
```

另一个示例，通过项目的完整路径 `"gitlab-cn/gitlab"` 和议题的 IID `"1"` 锁定议题：

```graphql
mutation {
  issueSetLocked(input: { projectPath: "gitlab-cn/gitlab", iid: "1", locked: true }) {
    issue {
      id
      iid
    }
  }
}
```

通过全局 ID 查找 CI runner 的示例：

```graphql
{
  runner(id: "gid://gitlab/Ci::Runner/1") {
    id
  }
}
```

历史上，极狐GitLab GraphQL API 在完整路径和 IID 字段及参数的类型方面并不一致，但一般来说：

- 完整路径字段和参数是 GraphQL `ID` 类型。
- IID 字段和参数是 GraphQL `String` 类型。

<a id="global-ids"></a>

### 全局 ID

在极狐GitLab GraphQL API 中，名为 `id`的字段或参数几乎总是[全局 ID](https://graphql.org/learn/global-object-identification/)，而绝不是数据库主键 ID。极狐GitLab GraphQL API 中的全局 ID 以 `"gid://gitlab/"` 开头。例如，`"gid://gitlab/Issue/123"`。

全局 ID 是一种约定，用于某些客户端库中的缓存和获取。

极狐GitLab 全局 ID 可能会发生变化。如果发生变化，将旧全局 ID 用作参数的做法将被弃用，并按照[弃用和破坏性变更](#breaking-changes)流程提供支持。您不应期望缓存的全局 ID 在极狐GitLab GraphQL 弃用周期之后仍然有效。

<a id="available-top-level-queries"></a>

## 可用的顶层查询

所有查询的顶层入口点定义在 GraphQL 参考的 [`Query` 类型](reference/_index.md#query-type)中。

<a id="multiplex-queries"></a>

### 多路复用查询

极狐GitLab 支持将查询批量合并到单个请求中。更多信息，请参阅
[Multiplex](https://graphql-ruby.org/queries/multiplex.html)。

<a id="breaking-changes"></a>

## 破坏性变更

极狐GitLab GraphQL API 是[无版本的](https://graphql.org/learn/best-practices/#versioning)，对 API 的更改主要是向后兼容的。

但是，极狐GitLab 有时会以不向后兼容的方式更改 GraphQL API。这些更改被视为破坏性变更，可能包括移除或重命名字段、参数或 schema 的其他部分。在创建破坏性变更时，极狐GitLab 遵循[弃用和移除流程](#deprecation-and-removal-process)。

为避免破坏性变更影响您的集成，您应该：

- 熟悉[弃用和移除流程](#deprecation-and-removal-process)。
- 经常[针对未来的破坏性变更 schema 验证您的 API 调用](#verify-against-the-future-breaking-change-schema)。


<a id="breaking-change-exemptions"></a>

### 破坏性变更豁免

在 [GraphQL API 参考](reference/_index.md)中标记为实验的 schema 项不受弃用流程约束。这些项可以随时移除或更改，恕不另行通知。

受功能标志控制且默认禁用的字段不遵循弃用和移除流程。这些字段可以随时移除，恕不另行通知。

> [!warning]
> 极狐GitLab 尽一切努力遵循[弃用和移除流程](#deprecation-and-removal-process)。
> 如果弃用流程会带来重大风险，极狐GitLab 可能会对 GraphQL
> API 立即进行破坏性变更，以修补关键的安全或性能问题。

<a id="verify-against-the-future-breaking-change-schema"></a>

### 针对未来的破坏性变更 schema 进行验证

您可以像所有已弃用项都已被移除一样对 GraphQL API 进行调用。这样，您就可以在[破坏性变更发布](#deprecation-and-removal-process)之前、在项实际从 schema 中移除之前验证 API 调用。

要进行这些调用，请向 GraphQL API 端点添加
`remove_deprecated=true` 查询参数。例如，对于 JihuLab.com 上的 GraphQL，使用
`https://jihulab.com/api/graphql?remove_deprecated=true`。

<a id="deprecation-and-removal-process"></a>

### 弃用和移除流程

标记为要从极狐GitLab GraphQL API 中移除的 schema 部分会先被弃用，但至少仍可使用六个版本。然后在下一个 `XX.0` 主要版本中完全移除。

项在以下位置标记为已弃用：

- [schema](https://spec.graphql.org/October2021/#sec--deprecated)。
- [GraphQL API 参考](reference/_index.md)。
- [弃用功能移除计划](../../update/deprecations.md)，发布文章中会链接到该计划。
- GraphQL API 的内省查询。

弃用消息会为已弃用的 schema 项提供替代方案（如适用）。

为避免遭遇破坏性变更，您应尽快从 GraphQL API 调用中移除已弃用的 schema。您应[针对不含已弃用 schema 项的 schema 验证您的 API 调用](#verify-against-the-future-breaking-change-schema)。

<a id="deprecation-example"></a>

#### 弃用示例

以下字段在不同的次要版本中被弃用，但都在极狐GitLab 17.0 中移除：

| 弃用版本 | 原因 |
|:--------------------|:-------|
| 15.7                | 极狐GitLab 传统上每个主要版本有 12 个次要版本。为确保该字段再可用 6 个版本，它在 17.0 主要版本（而非 16.0）中移除。 |
| 16.6                | 在 17.0 中移除可提供 6 个月的可用期。 |

<a id="list-of-removed-items"></a>

### 已移除项列表

查看以往版本中的[已移除项列表](removed_items.md)。

<a id="limits"></a>

## 限制

以下限制适用于极狐GitLab GraphQL API。

| 限制                                                 | 默认值 |
|:------------------------------------------------------|:--------|
| [最大页面大小](#maximum-page-size)               | 每页 100 条记录（节点）。适用于 API 中的大多数连接。某些连接的最大页面大小可能与默认值不同。 |
| [最大查询复杂度](#maximum-query-complexity) | 未身份验证的请求为 200，已身份验证的请求为 250。 |
| 最大查询大小                                    | 每个查询或变更操作为 10,000 个字符。如果达到此限制，请使用[变量](https://graphql.org/learn/queries/#variables)和[片段](https://graphql.org/learn/queries/#fragments)来减小查询或变更操作的大小。作为最后手段，请移除空白字符。 |
| 速率限制                                           | 对于 JihuLab.com，请参阅 [JihuLab.com 特定的速率限制](../../user/jihulab_com/_index.md#jihulabcom-specific-rate-limits)。 |
| [数据限制](#data-limits)                           | 当指定多个 blob 路径时，blob 请求限制为 20 MB。 |
| 请求超时                                       | 30 秒。 |

<a id="maximum-page-size"></a>

### 最大页面大小

连接的默认最大页面大小为每页 100 条记录（节点）。连接 [`subscriptionUsage.usersUsage.users`](reference/_index.md#gitlabsubscriptionusageusersusageusers)的最大页面大小为 20 条记录（节点）。

如果您请求的记录数超过连接的最大值，API 只会返回最大数量的记录。

<a id="maximum-query-complexity"></a>

### 最大查询复杂度

极狐GitLab GraphQL API 会对查询的复杂度进行评分。一般来说，查询越大，复杂度评分越高。此限制旨在保护 API，避免执行可能对其整体性能产生负面影响的查询。

您可以[查询](getting_started.md#query-complexity)查询的复杂度评分以及请求的限制。

如果查询超过复杂度限制，将返回错误消息响应。

一般来说，查询中的每个字段都会使复杂度评分增加 `1`，但特定字段可能更高或更低。有时，添加某些参数也可能增加查询的复杂度。

<a id="data-limits"></a>

### 数据限制

Blob 请求限制为：

- 任意大小的单个 blob。
- 总大小为 20 MB 或以下的多个 blob。

大于 20 MB 的 blob 必须单独请求。此限制仅适用于您请求包含 blob 数据的字段时。

您可能需要限制请求中的路径数量，以保持在数据限制之内。在排除数据字段的情况下请求 `size` 字段：

```gql
{
  project(fullPath: "gitlab-cn/gitlab") {
    repository {
      blobs(paths: ["big_file.rb", "small_file.rb", "huge_file.rb", ..., etc.], ref: "master") {
        nodes {
          path
          size
        }
      }
    }
  }
}
```

使用响应计算总大小，并确保后续请求不超过 20 MB 的数据限制。

<a id="resolve-mutations-detected-as-spam"></a>

## 解决被检测为垃圾信息的变更操作

GraphQL 变更操作可能被检测为垃圾信息。如果某个变更操作被检测为垃圾信息，并且：

- 未配置 CAPTCHA 服务，则会引发
  [GraphQL 顶层错误](https://spec.graphql.org/June2018/#sec-Errors)。例如：

  ```json
  {
    "errors": [
      {
        "message": "Request denied. Spam detected",
        "locations": [ { "line": 6, "column": 7 } ],
        "path": [ "updateSnippet" ],
        "extensions": {
          "spam": true
        }
      }
    ],
    "data": {
      "updateSnippet": {
        "snippet": null
      }
    }
  }
  ```

- 已配置 CAPTCHA 服务，您会收到一个响应，其中：
  - `needsCaptchaResponse` 设置为 `true`。
  - `spamLogId` 和 `captchaSiteKey` 字段已设置。

  例如：

  ```json
  {
    "errors": [
      {
        "message": "Request denied. Solve CAPTCHA challenge and retry",
        "locations": [ { "line": 6, "column": 7 } ],
        "path": [ "updateSnippet" ],
        "extensions": {
          "needsCaptchaResponse": true,
          "captchaSiteKey": "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI",
          "spamLogId": 67
        }
      }
    ],
    "data": {
      "updateSnippet": {
        "snippet": null,
      }
    }
  }
  ```

- 使用 `captchaSiteKey` 通过相应的 CAPTCHA API 获取 CAPTCHA 响应值。
  仅支持 [Google reCAPTCHA v2](https://developers.google.com/recaptcha/docs/display)。
- 在设置 `X-GitLab-Captcha-Response` 和 `X-GitLab-Spam-Log-Id` 请求头的情况下重新提交请求。

> [!note]
> 极狐GitLab GraphiQL 实现不允许传递请求头，因此请求必须是
> cURL 查询。使用 `--data-binary` 来正确处理 JSON 内嵌查询中
> 转义的双引号。

```shell
export CAPTCHA_RESPONSE="<CAPTCHA response obtained from CAPTCHA service>"
export SPAM_LOG_ID="<spam_log_id obtained from initial REST response>"
curl --request POST \
  --header "Authorization: Bearer $PRIVATE_TOKEN" \
  --header "Content-Type: application/json" \
  --header "X-GitLab-Captcha-Response: $CAPTCHA_RESPONSE" \
  --header "X-GitLab-Spam-Log-Id: $SPAM_LOG_ID" \
  --data-binary '{"query": "mutation {createSnippet(input: {title: \"Title\" visibilityLevel: public blobActions: [ { action: create filePath: \"BlobPath\" content: \"BlobContent\" } ] }) { snippet { id title } errors }}"}' "https://gitlab.example.com/api/graphql"
```
