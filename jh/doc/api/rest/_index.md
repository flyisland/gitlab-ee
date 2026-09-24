---
stage: Developer Experience
group: API Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: "使用极狐GitLab REST API 以编程方式与极狐GitLab 交互。包括请求、速率限制、分页、编码、版本和响应处理。"
title: REST API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用极狐GitLab REST API 自动化您的工作流并构建集成：

- 创建自定义工具，无需人工干预即可大规模管理您的极狐GitLab 资源。
- 通过将极狐GitLab 数据直接集成到您的应用程序中，改进协作。
- 精确管理跨多个项目的 CI/CD 流程。
- 以编程方式控制用户访问，以在您的组织中保持一致的权限。

REST API 使用标准的 HTTP 方法和 JSON 数据格式，
以便与您现有的工具和系统兼容。

<a id="make-a-rest-api-request"></a>

## 发起 REST API 请求

要发起 REST API 请求：

- 使用 REST API 客户端向 API 端点提交请求。
- 极狐GitLab 实例响应该请求。它返回一个状态码，如果适用，还会返回所请求的数据。状态码表示请求的结果，在[故障排除](troubleshooting.md)时非常有用。

REST API 请求必须以根端点和路径开头。

- 根端点是极狐GitLab 主机名。
- 路径必须以 `/api/v4` 开头（`v4` 表示 API 版本）。

在以下示例中，API 请求检索极狐GitLab 主机 `gitlab.example.com` 上的所有项目列表：

```shell
curl --request GET \
  --url "https://gitlab.example.com/api/v4/projects"
```

访问某些端点需要身份验证。有关更多信息，请参阅[身份验证](authentication.md)。

<a id="rate-limits"></a>

## 速率限制

REST API 请求受速率限制设置约束。这些设置降低了极狐GitLab 实例过载的风险。

- 有关详细信息，请参阅[速率限制](../../rate_limits/_index.md)。
- 有关 JihuLab.com 使用的速率限制设置的详细信息，请参阅 [JihuLab.com 特定的速率限制](../../user/jihulab_com/_index.md#jihulabcom-specific-rate-limits)。

<a id="response-format"></a>

## 响应格式

REST API 响应以 JSON 格式返回。某些 API 端点也支持纯文本格式。要确认端点支持哪种内容类型，请参阅 [REST API 资源](../api_resources.md)。

<a id="request-requirements"></a>

## 请求要求

某些 REST API 请求有特定要求，包括使用的数据格式和编码。

<a id="request-payload"></a>

### 请求负载

API 请求可以使用作为[查询字符串](https://en.wikipedia.org/wiki/Query_string)或作为[负载主体](https://datatracker.ietf.org/doc/html/draft-ietf-httpbis-p3-payload-14#section-3.2)发送的参数。GET 请求通常发送查询字符串，而 PUT 或 POST 请求通常发送负载主体：

- 查询字符串：

  ```shell
  curl --request POST \
    --url "https://gitlab.example.com/api/v4/projects?name=<example-name>&description=<example-description>"
  ```

- 请求负载（JSON）：

  ```shell
  curl --request POST \
    --header "Content-Type: application/json" \
    --data '{"name":"<example-name>", "description":"<example-description>"}' "https://gitlab.example.com/api/v4/projects"
  ```

URL 编码的查询字符串有长度限制。过大的请求会导致 `414 Request-URI Too Large` 错误消息。可以通过改用负载主体来解决此问题。

<a id="path-parameters"></a>

### 路径参数

如果端点有路径参数，文档会以冒号前缀显示它们。

例如：

```plaintext
DELETE /projects/:id/share/:group_id
```

`:id` 路径参数需要替换为项目 ID，`:group_id` 需要替换为群组 ID。不应包含冒号 `:`。

对于项目 ID 为 `5`、群组 ID 为 `17` 的项目，生成的 cURL 请求如下：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/share/17"
```

必须遵循需要 URL 编码的路径参数。如果不这样做，它将不匹配 API 端点并返回 404。如果 API 前面有某些内容（例如 Apache），请确保它不解码 URL 编码的路径参数。

<a id="id-vs-iid"></a>

### `id` 与 `iid`

某些 API 资源有两个名称相似的字段。例如，[议题](../issues.md)、[合并请求](../merge_requests.md)和[项目里程碑](../milestones.md)。这些字段是：

- `id`：在所有项目中唯一的 ID。
- `iid`：附加的内部 ID（在 Web UI 中显示），在单个项目范围内唯一。

如果资源同时具有 `iid` 字段和 `id` 字段，通常使用 `iid` 字段而不是 `id` 来获取资源。

例如，假设一个项目（`id: 42`）有一个议题，其 `id: 46` 且 `iid: 5`。在这种情况下：

- 检索该议题的有效 API 请求是 `GET /projects/42/issues/5`。
- 检索该议题的无效 API 请求是 `GET /projects/42/issues/46`。

并非所有具有 `iid` 字段的资源都通过 `iid` 获取。关于应使用哪个字段的指导，请参阅特定资源的文档。

<a id="encoding"></a>

### 编码

发起 REST API 请求时，某些内容必须进行编码，以处理特殊字符和数据结构。

<a id="namespaced-paths"></a>

#### 命名空间路径

如果使用命名空间 API 请求，请确保 `NAMESPACE/PROJECT_PATH` 已进行 URL 编码。

例如，`/` 表示为 `%2F`：

```plaintext
GET /api/v4/projects/diaspora%2Fdiaspora
```

项目的路径不一定与其名称相同。项目的路径可以在项目的 URL 或项目设置中的 **常规** > **高级** > **更改路径** 下找到。

<a id="file-path-branches-and-tags-name"></a>

#### 文件路径、分支和标签名称

如果文件路径、分支或标签包含 `/`，请确保其已进行 URL 编码。

例如，`/` 表示为 `%2F`：

```plaintext
GET /api/v4/projects/1/repository/files/src%2FREADME.md?ref=master
GET /api/v4/projects/1/branches/my%2Fbranch/commits
GET /api/v4/projects/1/repository/tags/my%2Ftag
```

<a id="array-and-hash-types"></a>

#### 数组和哈希类型

您可以使用 `array` 和 `hash` 类型参数请求 API：

<a id="array"></a>

##### `array`

`import_sources` 是一个类型为 `array` 的参数：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  -d "import_sources[]=github" \
  -d "import_sources[]=bitbucket" \
  --url "https://gitlab.example.com/api/v4/some_endpoint"
```

<a id="hash"></a>

##### `hash`

`override_params` 是一个类型为 `hash` 的参数：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form "namespace=email" \
  --form "path=impapi" \
  --form "file=@/path/to/somefile.txt" \
  --form "override_params[visibility]=private" \
  --form "override_params[some_other_param]=some_value" \
  --url "https://gitlab.example.com/api/v4/projects/import"
```

<a id="array-of-hashes"></a>

##### 哈希数组

`variables` 是一个类型为 `array` 的参数，包含哈希键/值对 `[{ 'key': 'UPLOAD_TO_S3', 'value': 'true' }]`：

```shell
curl --globoff --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/169/pipeline?ref=master&variables[0][key]=VAR1&variables[0][value]=hello&variables[1][key]=VAR2&variables[1][value]=world"

curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{ "ref": "master", "variables": [ {"key": "VAR1", "value": "hello"}, {"key": "VAR2", "value": "world"} ] }' \
  --url "https://gitlab.example.com/api/v4/projects/169/pipeline"
```

<a id="encoding--in-iso-8601-dates"></a>

#### 在 ISO 8601 日期中编码 `+`

如果您需要在查询参数中包含 `+`，由于 [W3 建议](https://www.w3.org/Addressing/URL/4_URI_Recommentations.html) 会导致 `+` 被解释为空格，您可能需要改用 `%2B`。例如，在 ISO 8601 日期中，您可能希望以 ISO 8601 格式包含特定时间，例如：

```plaintext
2017-10-17T23:11:13.000+05:30
```

查询参数的正确编码应为：

```plaintext
2017-10-17T23:11:13.000%2B05:30
```

<a id="evaluating-a-response"></a>

## 评估响应

在某些情况下，API 响应可能不符合您的预期。问题可能包括空值和重定向。如果您在响应中收到数字状态码，请参阅[状态码](troubleshooting.md#status-codes)。

<a id="null-vs-false"></a>

### `null` 与 `false`

在 API 响应中，某些布尔字段可以具有 `null` 值。`null` 布尔值没有默认值，既不是 `true` 也不是 `false`。极狐GitLab 将布尔字段中的 `null` 值视为与 `false` 相同。

在布尔参数中，您只应设置 `true` 或 `false` 值（而不是 `null`）。

<a id="redirects"></a>

### 重定向

在[路径更改](../../user/project/repository/_index.md#repository-path-changes)后，REST API 可能会响应一条消息，指出端点已移动。发生这种情况时，请使用 `Location` 请求头中指定的端点。

项目移动到不同路径的示例：

```shell
curl --request GET \
  --verbose \
  --url "https://gitlab.example.com/api/v4/projects/gitlab-org%2Fold-path-project"
```

响应是：

```plaintext
...
< Location: http://gitlab.example.com/api/v4/projects/81
...
This resource has been moved permanently to https://gitlab.example.com/api/v4/projects/81
```

<a id="pagination"></a>

## 分页

极狐GitLab 支持以下分页方法：

- 基于偏移量的分页。默认方法，适用于除 `users` 端点之外的所有端点。
- 基于键集的分页。已添加到选定的端点，但正在[逐步推出](https://gitlab.com/groups/gitlab-org/-/work_items/2039)。

对于大型集合，出于性能原因，您应该使用键集分页（如果可用）而不是偏移量分页。

<a id="offset-based-pagination"></a>

### 基于偏移量的分页

有时，返回的结果跨越许多页。列出资源时，您可以传递以下参数：

| 参数  | 描述                                                   |
|:-----------|:--------------------------------------------------------------|
| `page`     | 页码（默认值：`1`）。                                   |
| `per_page` | 每页列出的条目数（默认值：`20`，最大值：`100`）。 |

以下示例每页列出 50 个[命名空间](../namespaces.md)：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/namespaces?per_page=50"
```

> [!note]
> 偏移量分页存在[最大偏移量允许限制](../../administration/instance_limits.md#max-offset-allowed-by-the-rest-api-for-offset-based-pagination)。您可以在极狐GitLab 私有化部署实例中更改此限制。

<a id="pagination-link-header"></a>

#### 分页 `Link` 请求头

每个响应都会返回 [`Link` 请求头](https://www.w3.org/wiki/LinkHeader)。它们的 `rel` 设置为 `prev`、`next`、`first` 或 `last`，并包含相关的 URL。请务必使用这些链接，而不是生成您自己的 URL。

对于 JihuLab.com 用户，[某些分页请求头可能不会返回](../../user/jihulab_com/_index.md#pagination-response-headers)。

以下 cURL 示例将输出限制为每页三个条目（`per_page=3`），并请求 ID 为 `8` 的议题的[评论](../notes.md)的第二页（`page=2`），该议题属于 ID 为 `9` 的项目：

```shell
curl --request GET \
  --head \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/9/issues/8/notes?per_page=3&page=2"
```

响应是：

```http
HTTP/2 200 OK
cache-control: no-cache
content-length: 1103
content-type: application/json
date: Mon, 18 Jan 2016 09:43:18 GMT
link: <https://gitlab.example.com/api/v4/projects/8/issues/8/notes?page=1&per_page=3>; rel="prev", <https://gitlab.example.com/api/v4/projects/8/issues/8/notes?page=3&per_page=3>; rel="next", <https://gitlab.example.com/api/v4/projects/8/issues/8/notes?page=1&per_page=3>; rel="first", <https://gitlab.example.com/api/v4/projects/8/issues/8/notes?page=3&per_page=3>; rel="last"
status: 200 OK
vary: Origin
x-next-page: 3
x-page: 2
x-per-page: 3
x-prev-page: 1
x-request-id: 732ad4ee-9870-4866-a199-a9db0cde3c86
x-runtime: 0.108688
x-total: 8
x-total-pages: 3
```

<a id="other-pagination-headers"></a>

#### 其他分页请求头

极狐GitLab 还返回以下附加分页请求头：

| 请求头          | 描述 |
|:----------------|:------------|
| `x-next-page`   | 下一页的索引。 |
| `x-page`        | 当前页的索引（从 1 开始）。 |
| `x-per-page`    | 每页的条目数。 |
| `x-prev-page`   | 上一页的索引。 |
| `x-total`       | 条目总数。 |
| `x-total-pages` | 总页数。 |

对于 JihuLab.com 用户，[某些分页请求头可能不会返回](../../user/jihulab_com/_index.md#pagination-response-headers)。

<a id="keyset-based-pagination"></a>

### 基于键集的分页

键集分页允许更高效地检索页面，并且与基于偏移量的分页相比，运行时与集合的大小无关。

此方法由以下参数控制。`order_by` 和 `sort` 都是必填的。

| 参数    | 必填 | 描述 |
|--------------|----------|-------------|
| `pagination` | 是      | `keyset`（启用键集分页）。 |
| `per_page`   | 否       | 每页列出的条目数（默认值：`20`，最大值：`100`）。 |
| `order_by`   | 是      | 排序所依据的列。 |
| `sort`       | 是      | 排序顺序（`asc` 或 `desc`） |

以下示例每页列出 50 个[项目](../projects.md)，按 `id` 升序排序。

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects?pagination=keyset&per_page=50&order_by=id&sort=asc"
```

响应请求头包含指向下一页的链接。例如：

```http
HTTP/1.1 200 OK
...
Link: <https://gitlab.example.com/api/v4/projects?pagination=keyset&per_page=50&order_by=id&sort=asc&id_after=42>; rel="next"
Status: 200 OK
...
```

指向下一页的链接包含一个附加过滤器 `id_after=42`，用于排除已检索到的记录。

再举一个例子，以下请求使用键集分页，每页列出 50 个[群组](../groups.md)，按 `name` 升序排序：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups?pagination=keyset&per_page=50&order_by=name&sort=asc"
```

响应请求头包含指向下一页的链接：

```http
HTTP/1.1 200 OK
...
Link: <https://gitlab.example.com/api/v4/groups?pagination=keyset&per_page=50&order_by=name&sort=asc&cursor=eyJuYW1lIjoiRmxpZ2h0anMiLCJpZCI6IjI2IiwiX2tkIjoibiJ9>; rel="next"
Status: 200 OK
...
```

指向下一页的链接包含一个附加过滤器 `cursor=eyJuYW1lIjoiRmxpZ2h0anMiLCJpZCI6IjI2IiwiX2tkIjoibiJ9`，用于排除已检索到的记录。

`X-NEXT-CURSOR` 请求头包含用于检索下一页记录的游标值，而 `X-PREV-CURSOR` 请求头包含用于检索上一页记录的游标值（如果可用）。

过滤器的类型取决于所使用的 `order_by` 选项，并且您可能有多个附加过滤器。

> [!warning]
> 为与 [W3C `Link` 规范](https://www.w3.org/wiki/LinkHeader) 保持一致，已移除 `Links` 请求头。应改用 `Link` 请求头。

当到达集合末尾且没有其他记录可检索时，`Link` 请求头不存在，结果数组为空。

您应该只使用给定的链接来检索下一页，而不是构建自己的 URL。除了显示的请求头外，不公开其他分页请求头。

<a id="supported-resources"></a>

#### 支持的资源

仅对选定的资源和排序选项支持基于键集的分页：

| 资源                                                                       | 选项                                                                                                                                                                               | 可用性 |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ |
| [群组审计事件](../audit_events.md#list-all-group-audit-events)       | 仅 `order_by=id`、`sort=desc`                                                                                                                                                       | 仅限已认证用户。 |
| [群组](../groups.md#list-groups)                                             | 仅 `order_by=name`、`sort=asc`                                                                                                                                                      | 仅限未认证用户。 |
| [实例审计事件](../audit_events.md#list-all-instance-audit-events) | 仅 `order_by=id`、`sort=desc`                                                                                                                                                       | 仅限已认证用户。 |
| [软件包流水线](../packages.md#list-package-pipelines)                     | 仅 `order_by=id`、`sort=desc`                                                                                                                                                       | 仅限已认证用户。 |
| [项目作业](../jobs.md#list-all-jobs-for-a-project)                         | 仅 `order_by=id`、`sort=desc`                                                                                                                                                       | 仅限已认证用户。 |
| [项目审计事件](../audit_events.md#list-all-project-audit-events)   | 仅 `order_by=id`、`sort=desc`                                                                                                                                                       | 仅限已认证用户。 |
| [项目](../projects.md)                                                     | 仅 `order_by=id`                                                                                                                                                                    | 已认证和未认证用户。 |
| [用户](../users.md)                                                           | `order_by=id`、`order_by=name`、`order_by=username`、`order_by=created_at` 或 `order_by=updated_at`。                                                                                 | 已认证和未认证用户。 |
| [镜像仓库标签](../container_registry.md)                           | 仅 `order_by=name`、`sort=asc` 或 `sort=desc`。                                                                                                                                     | 仅限已认证用户。 |
| [列出代码仓库树](../repositories.md#list-all-repository-trees-in-a-project)                | 不适用                                                                                                                                                                                   | 已认证和未认证用户。在极狐GitLab 17.1 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/154897)。 |
| [项目议题](../issues.md#list-all-project-issues)                             | 仅 `order_by=created_at`、`order_by=updated_at`、`order_by=title`、`order_by=id`、`order_by=weight`、`order_by=due_date`、`order_by=relative_position`、`sort=asc` 或 `sort=desc`。 | 已认证和未认证用户。在极狐GitLab 18.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/199887/)。 |
| [Runner 作业](../runners.md#list-all-jobs-processed-by-a-runner) | 仅 `order_by=id`、`sort=desc` | 仅限已认证用户。 |

<a id="pagination-response-headers"></a>

### 分页响应请求头

出于性能原因，如果查询返回超过 10,000 条记录，极狐GitLab 不会返回以下请求头：

- `x-total`。
- `x-total-pages`。
- `rel="last"` `link`

<a id="versioning-and-deprecations"></a>

## 版本和弃用

REST API 版本符合语义化版本控制规范。主版本号为 `4`。不兼容的更改需要更改此版本号。

- 次版本号不明确，这允许稳定的 API 端点。
- 新功能以相同的版本号添加到 API 中。
- API 主版本更改以及整个 API 版本的移除，与极狐GitLab 主版本发布同步进行。
- 所有弃用和版本之间的更改都会在文档中注明。

以下内容不包含在弃用流程中，可以随时移除，恕不另行通知：

- 在 [REST API 资源](../api_resources.md) 中标记为[实验性或测试版](../../policy/development_stages_support.md)的元素。
- 受功能标志控制且默认禁用的字段。

对于极狐GitLab 私有化部署，从企业版实例[回退](../../update/convert_to_ee/revert.md)到基础版会导致破坏性更改。
