---

stage: Verify  
group: Runner Core  
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>  
title: 项目发布 API  
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版  
- Offering: JihuLab.com，私有化部署  

{{< /details >}}

使用此 API 与项目的 [发布](../../user/project/releases/_index.md) 进行交互。

> [!note]  
> 要与群组的发布进行交互，请参见 [群组发布 API](../group_releases.md)。  
>  
> 要将链接作为发布资产进行交互，请参见 [发布链接 API](links.md)。  

<a id="authentication"></a>

## 认证

对于认证，发布 API 接受以下任一方式：

- 使用 `PRIVATE-TOKEN` 头的 [个人访问令牌](../../user/profile/personal_access_tokens.md)。  
- 使用 `JOB-TOKEN` 头的 [极狐GitLab CI/CD 作业令牌](../../ci/jobs/ci_job_token.md) `$CI_JOB_TOKEN`。  

<a id="list-releases"></a>

## 列出发布

返回按 `released_at` 排序的分页发布列表。

```plaintext
GET /projects/:id/releases
```

| 属性         | 类型           | 是否必需 | 描述                                                                         |  
| ------------- | -------------- | -------- | ----------------------------------------------------------------------------------- |  
| `id`          | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](../rest/_index.md#namespaced-paths)。 |  
| `order_by`    | string         | 否       | 排序依据的字段。可以是 `released_at`（默认）或 `created_at`。 |  
| `sort`        | string         | 否       | 排序方向。`desc`（默认）表示降序，`asc` 表示升序。 |  
| `include_html_description` | boolean        | 否       | 如果为 `true`，响应中包含发布描述 HTML 渲染后的 Markdown。   |  

如果成功，返回 [`200 OK`](../rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性                             | 类型   | 描述                                      |  
|:--------------------------------------|:-------|:-------------------------------------------------|  
| `[]._links`                           | object | 发布的链接。                            |  
| `[]._links.closed_issues_url`         | string | 发布已关闭议题的 HTTP URL。         |  
| `[]._links.closed_merge_requests_url` | string | 发布已关闭合并请求的 HTTP URL。 |  
| `[]._links.edit_url`                  | string | 发布编辑页的 HTTP URL。             |  
| `[]._links.merged_merge_requests_url` | string | 发布已合并合并请求的 HTTP URL。 |  
| `[]._links.opened_issues_url`         | string | 发布开放议题的 HTTP URL。           |  
| `[]._links.opened_merge_requests_url` | string | 发布开放合并请求的 HTTP URL。   |  
| `[]._links.self`                      | string | 发布的 HTTP URL。                         |  

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/24/releases"
```

示例响应：

```json
[
   {
      "tag_name":"v0.2",
      "description":"## CHANGELOG\r\n\r\n- Escape label and milestone titles to prevent XSS in GLFM autocomplete. !2740\r\n- Prevent private snippets from being embeddable.\r\n- Add subresources removal to member destroy service.",
      "name":"Awesome app v0.2 beta",
      "created_at":"2019-01-03T01:56:19.539Z",
      "released_at":"2019-01-03T01:56:19.539Z",
      "author":{
         "id":1,
         "name":"Administrator",
         "username":"root",
         "state":"active",
         "avatar_url":"https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon",
         "web_url":"https://gitlab.example.com/root"
      },
      "commit":{
         "id":"079e90101242458910cccd35eab0e211dfc359c0",
         "short_id":"079e9010",
         "title":"Update README.md",
         "created_at":"2019-01-03T01:55:38.000Z",
         "parent_ids":[
            "f8d3d94cbd347e924aa7b715845e439d00e80ca4"
         ],
         "message":"Update README.md",
         "author_name":"Administrator",
         "author_email":"admin@example.com",
         "authored_date":"2019-01-03T01:55:38.000Z",
         "committer_name":"Administrator",
         "committer_email":"admin@example.com",
         "committed_date":"2019-01-03T01:55:38.000Z"
      },
      "milestones": [
         {
            "id":51,
            "iid":1,
            "project_id":24,
            "title":"v1.0-rc",
            "description":"Voluptate fugiat possimus quis quod aliquam expedita.",
            "state":"closed",
            "created_at":"2019-07-12T19:45:44.256Z",
            "updated_at":"2019-07-12T19:45:44.256Z",
            "due_date":"2019-08-16",
            "start_date":"2019-07-30",
            "web_url":"https://gitlab.example.com/root/awesome-app/-/milestones/1",
            "issue_stats": {
               "total": 98,
               "closed": 76
            }
         },
         {
            "id":52,
            "iid":2,
            "project_id":24,
            "title":"v1.0",
            "description":"Voluptate fugiat possimus quis quod aliquam expedita.",
            "state":"closed",
            "created_at":"2019-07-16T14:00:12.256Z",
            "updated_at":"2019-07-16T14:00:12.256Z",
            "due_date":"2019-08-16",
            "start_date":"2019-07-30",
            "web_url":"https://gitlab.example.com/root/awesome-app/-/milestones/2",
            "issue_stats": {
               "total": 24,
               "closed": 21
            }
         }
      ],
      "commit_path":"/root/awesome-app/commit/588440f66559714280628a4f9799f0c4eb880a4a",
      "tag_path":"/root/awesome-app/-/tags/v0.11.1",
      "assets":{
         "count":6,
         "sources":[
            {
               "format":"zip",
               "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.2/awesome-app-v0.2.zip"
            },
            {
               "format":"tar.gz",
               "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.2/awesome-app-v0.2.tar.gz"
            },
            {
               "format":"tar.bz2",
               "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.2/awesome-app-v0.2.tar.bz2"
            },
            {
               "format":"tar",
               "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.2/awesome-app-v0.2.tar"
            }
         ],
         "links":[
            {
               "id":2,
               "name":"awesome-v0.2.msi",
               "url":"http://192.168.10.15:3000/msi",
               "link_type":"other"
            },
            {
               "id":1,
               "name":"awesome-v0.2.dmg",
               "url":"http://192.168.10.15:3000",
               "link_type":"other"
            }
         ],
         "evidence_file_path":"https://gitlab.example.com/root/awesome-app/-/releases/v0.2/evidence.json"
      },
      "evidences":[
        {
          "sha": "760d6cdfb0879c3ffedec13af470e0f71cf52c6cde4d",
          "filepath": "https://gitlab.example.com/root/awesome-app/-/releases/v0.2/evidence.json",
          "collected_at": "2019-01-03T01:56:19.539Z"
        }
     ]
   },
   {
      "tag_name":"v0.1",
      "description":"## CHANGELOG\r\n\r\n-Remove limit of 100 when searching repository code. !8671\r\n- Show error message when attempting to reopen an MR and there is an open MR for the same branch. !16447 (Akos Gyimesi)\r\n- Fix a bug where internal email pattern wasn't respected. !22516",
      "name":"Awesome app v0.1 alpha",
      "created_at":"2019-01-03T01:55:18.203Z",
      "released_at":"2019-01-03T01:55:18.203Z",
      "author":{
         "id":1,
         "name":"Administrator",
         "username":"root",
         "state":"active",
         "avatar_url":"https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon",
         "web_url":"https://gitlab.example.com/root"
      },
      "commit":{
         "id":"f8d3d94cbd347e924aa7b715845e439d00e80ca4",
         "short_id":"f8d3d94c",
         "title":"Initial commit",
         "created_at":"2019-01-03T01:53:28.000Z",
         "parent_ids":[

         ],
         "message":"Initial commit",
         "author_name":"Administrator",
         "author_email":"admin@example.com",
         "authored_date":"2019-01-03T01:53:28.000Z",
         "committer_name":"Administrator",
         "committer_email":"admin@example.com",
         "committed_date":"2019-01-03T01:53:28.000Z"
      },
      "assets":{
         "count":4,
         "sources":[
            {
               "format":"zip",
               "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.1/awesome-app-v0.1.zip"
            },
            {
               "format":"tar.gz",
               "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.1/awesome-app-v0.1.tar.gz"
            },
            {
               "format":"tar.bz2",
               "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.1/awesome-app-v0.1.tar.bz2"
            },
            {
               "format":"tar",
               "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.1/awesome-app-v0.1.tar"
            }
         ],
         "links":[

         ],
         "evidence_file_path":"https://gitlab.example.com/root/awesome-app/-/releases/v0.1/evidence.json"
      },
      "evidences":[
        {
          "sha": "c3ffedec13af470e760d6cdfb08790f71cf52c6cde4d",
          "filepath": "https://gitlab.example.com/root/awesome-app/-/releases/v0.1/evidence.json",
          "collected_at": "2019-01-03T01:55:18.203Z"
        }
      ],
      "_links": {
         "closed_issues_url": "https://gitlab.example.com/root/awesome-app/-/issues?release_tag=v0.1&scope=all&state=closed",
         "closed_merge_requests_url": "https://gitlab.example.com/root/awesome-app/-/merge_requests?release_tag=v0.1&scope=all&state=closed",
         "edit_url": "https://gitlab.example.com/root/awesome-app/-/releases/v0.1/edit",
         "merged_merge_requests_url": "https://gitlab.example.com/root/awesome-app/-/merge_requests?release_tag=v0.1&scope=all&state=merged",
         "opened_issues_url": "https://gitlab.example.com/root/awesome-app/-/issues?release_tag=v0.1&scope=all&state=opened",
         "opened_merge_requests_url": "https://gitlab.example.com/root/awesome-app/-/merge_requests?release_tag=v0.1&scope=all&state=opened",
         "self": "https://gitlab.example.com/root/awesome-app/-/releases/v0.1"
      }
   }
]
```

<a id="get-a-release-by-a-tag-name"></a>

## 通过标签名称获取发布

获取给定标签的发布。

```plaintext
GET /projects/:id/releases/:tag_name
```

| 属性                  | 类型           | 是否必需 | 描述                                                                         |  
|----------------------------| -------------- | -------- | ----------------------------------------------------------------------------------- |  
| `id`                       | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](../rest/_index.md#namespaced-paths)。  |  
| `tag_name`                 | string         | 是      | 发布关联的 Git 标签。                                         |  
| `include_html_description` | boolean        | 否       | 如果为 `true`，响应中包含发布描述 HTML 渲染后的 Markdown。   |  

如果成功，返回 [`200 OK`](../rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性                             | 类型   | 描述                                      |  
|:--------------------------------------|:-------|:-------------------------------------------------|  
| `[]._links`                           | object | 发布的链接。                            |  
| `[]._links.closed_issues_url`         | string | 发布已关闭议题的 HTTP URL。         |  
| `[]._links.closed_merge_requests_url` | string | 发布已关闭合并请求的 HTTP URL。 |  
| `[]._links.edit_url`                  | string | 发布编辑页的 HTTP URL。             |  
| `[]._links.merged_merge_requests_url` | string | 发布已合并合并请求的 HTTP URL。 |  
| `[]._links.opened_issues_url`         | string | 发布开放议题的 HTTP URL。           |  
| `[]._links.opened_merge_requests_url` | string | 发布开放合并请求的 HTTP URL。   |  
| `[]._links.self`                      | string | 发布的 HTTP URL。                         |  

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/24/releases/v0.1"
```

示例响应：

```json
{
   "tag_name":"v0.1",
   "description":"## CHANGELOG\r\n\r\n- Remove limit of 100 when searching repository code. !8671\r\n- Show error message when attempting to reopen an MR and there is an open MR for the same branch. !16447 (Akos Gyimesi)\r\n- Fix a bug where internal email pattern wasn't respected. !22516",
   "name":"Awesome app v0.1 alpha",
   "created_at":"2019-01-03T01:55:18.203Z",
   "released_at":"2019-01-03T01:55:18.203Z",
   "author":{
      "id":1,
      "name":"Administrator",
      "username":"root",
      "state":"active",
      "avatar_url":"https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon",
      "web_url":"https://gitlab.example.com/root"
   },
   "commit":{
      "id":"f8d3d94cbd347e924aa7b715845e439d00e80ca4",
      "short_id":"f8d3d94c",
      "title":"Initial commit",
      "created_at":"2019-01-03T01:53:28.000Z",
      "parent_ids":[

      ],
      "message":"Initial commit",
      "author_name":"Administrator",
      "author_email":"admin@example.com",
      "authored_date":"2019-01-03T01:53:28.000Z",
      "committer_name":"Administrator",
      "committer_email":"admin@example.com",
      "committed_date":"2019-01-03T01:53:28.000Z"
   },
   "milestones": [
       {
         "id":51,
         "iid":1,
         "project_id":24,
         "title":"v1.0-rc",
         "description":"Voluptate fugiat possimus quis quod aliquam expedita.",
         "state":"closed",
         "created_at":"2019-07-12T19:45:44.256Z",
         "updated_at":"2019-07-12T19:45:44.256Z",
         "due_date":"2019-08-16",
         "start_date":"2019-07-30",
         "web_url":"https://gitlab.example.com/root/awesome-app/-/milestones/1",
         "issue_stats": {
            "total": 98,
            "closed": 76
         }
       },
       {
         "id":52,
         "iid":2,
         "project_id":24,
         "title":"v1.0",
         "description":"Voluptate fugiat possimus quis quod aliquam expedita.",
         "state":"closed",
         "created_at":"2019-07-16T14:00:12.256Z",
         "updated_at":"2019-07-16T14:00:12.256Z",
         "due_date":"2019-08-16",
         "start_date":"2019-07-30",
         "web_url":"https://gitlab.example.com/root/awesome-app/-/milestones/2",
         "issue_stats": {
            "total": 24,
            "closed": 21
         }
       }
   ],
   "commit_path":"/root/awesome-app/commit/588440f66559714280628a4f9799f0c4eb880a4a",
   "tag_path":"/root/awesome-app/-/tags/v0.11.1",
   "assets":{
      "count":5,
      "sources":[
         {
            "format":"zip",
            "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.1/awesome-app-v0.1.zip"
         },
         {
            "format":"tar.gz",
            "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.1/awesome-app-v0.1.tar.gz"
         },
         {
            "format":"tar.bz2",
            "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.1/awesome-app-v0.1.tar.bz2"
         },
         {
            "format":"tar",
            "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.1/awesome-app-v0.1.tar"
         }
      ],
      "links":[
         {
            "id":3,
            "name":"hoge",
            "url":"https://gitlab.example.com/root/awesome-app/-/tags/v0.11.1/binaries/linux-amd64",
            "link_type":"other"
         }
      ]
   },
   "evidences":[
     {
       "sha": "760d6cdfb0879c3ffedec13af470e0f71cf52c6cde4d",
       "filepath": "https://gitlab.example.com/root/awesome-app/-/releases/v0.1/evidence.json",
       "collected_at": "2019-07-16T14:00:12.256Z"
     },
   "_links": {
      "closed_issues_url": "https://gitlab.example.com/root/awesome-app/-/issues?release_tag=v0.1&scope=all&state=closed",
      "closed_merge_requests_url": "https://gitlab.example.com/root/awesome-app/-/merge_requests?release_tag=v0.1&scope=all&state=closed",
      "edit_url": "https://gitlab.example.com/root/awesome-app/-/releases/v0.1/edit",
      "merged_merge_requests_url": "https://gitlab.example.com/root/awesome-app/-/merge_requests?release_tag=v0.1&scope=all&state=merged",
      "opened_issues_url": "https://gitlab.example.com/root/awesome-app/-/issues?release_tag=v0.1&scope=all&state=opened",
      "opened_merge_requests_url": "https://gitlab.example.com/root/awesome-app/-/merge_requests?release_tag=v0.1&scope=all&state=opened",
      "self": "https://gitlab.example.com/root/awesome-app/-/releases/v0.1"
    }
  ]
}
```

<a id="download-a-release-asset"></a>

## 下载发布资产

{{< history >}}

- 在极狐GitLab 15.4 引入。

{{< /history >}}

通过以下格式发出请求下载发布资产文件：

```plaintext
GET /projects/:id/releases/:tag_name/downloads/:direct_asset_path
```

| 属性                  | 类型           | 是否必需 | 描述                                                                         |  
|----------------------------| -------------- | -------- | ----------------------------------------------------------------------------------- |  
| `id`                       | integer 或 string | 是      | 项目的 ID 或 [URL 编码路径](../rest/_index.md#namespaced-paths)。  |  
| `tag_name`                 | string         | 是      | 发布关联的 Git 标签。                                         |  
| `direct_asset_path`        | string         | 是      | 发布资产文件的路径，如 [创建](links.md#create-a-release-link) 或 [更新](links.md#update-a-release-link) 其链接时所指定。 |  

示例请求：

```shell
curl --location --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/24/releases/v0.1/downloads/bin/asset.exe"
```

<a id="get-the-latest-release"></a>

### 获取最新发布

{{< history >}}

- 在极狐GitLab 15.4 引入。

{{< /history >}}

最新发布信息可通过永久 API URL 访问。

URL 格式为：

```plaintext
GET /projects/:id/releases/permalink/latest
```

要调用任何其他需要发布标签的 GET API，请将后缀追加到 `permalink/latest` API 路径。

例如，要获取最新的 [发布证据](#collect-release-evidence)，您可以使用：

```plaintext
GET /projects/:id/releases/permalink/latest/evidence
```

另一个例子是 [下载资产](#download-a-release-asset) 的最新发布，您可以使用：

```plaintext
GET /projects/:id/releases/permalink/latest/downloads/bin/asset.exe
```

<a id="sorting-preferences"></a>

#### 排序偏好

默认情况下，极狐GitLab 使用 `released_at` 时间获取发布。使用查询参数 `?order_by=released_at` 是可选的。

<a id="create-a-release"></a>

## 创建发布

创建发布。创建发布需要项目的开发者级别访问权限。

```plaintext
POST /projects/:id/releases
```

| 属性          | 类型            | 是否必需                    | 描述                                                                                                                      |  
| -------------------| --------------- | --------                    | -------------------------------------------------------------------------------------------------------------------------------- |  
| `id`               | integer 或 string  | 是                         | 项目的 ID 或 [URL 编码路径](../rest/_index.md#namespaced-paths)。                                              |  
| `name`             | string          | 否                          | 发布名称。                                                                                                                |  
| `tag_name`         | string          | 是                         | 创建发布所使用的标签。                                                                                  |  
| `tag_message`      | string          | 否                          | 如果创建新的注释标签，要使用的消息。                                                                                  |  
| `description`      | string          | 否                          | 发布的描述。您可以使用 [Markdown](../../user/markdown.md)。                                                  |  
| `ref`              | string          | 是，如果 `tag_name` 不存在 | 如果 `tag_name` 中指定的标签不存在，则从 `ref` 创建发布并使用 `tag_name` 进行标记。它可以是提交 SHA、另一个标签名称或分支名称。 |  
| `milestones`       | array of string | 否                          | 发布关联的每个里程碑的标题。[极狐GitLab 专业版](https://gitlab.cn/pricing/) 客户可以指定群组里程碑。                                                                      |  
| `assets:links`     | array of hash   | 否                          | 资产链接的数组。                                                                                                        |  
| `assets:links:name`| string          | 由 `assets:links` 必需 | 链接的名称。链接名称在发布内必须唯一。                                                              |  
| `assets:links:url` | string          | 由 `assets:links` 必需 | 链接的 URL。链接 URL 在发布内必须唯一。                                                                |  
| `assets:links:direct_asset_path` | string     | 否 | [直接资产链接](../../user/project/releases/release_fields.md#permanent-links-to-release-assets) 的可选路径。 |  
| `assets:links:link_type` | string     | 否 | 链接的类型：`other`、`runbook`、`image`、`package`。默认为 `other`。 |  
| `released_at`      | datetime        | 否                          | 发布的日期和时间。默认为当前时间。期望为 ISO 8601 格式（`2019-03-15T08:00:00Z`）。仅在创建 [即将发布](../../user/project/releases/_index.md#upcoming-releases) 或 [历史发布](../../user/project/releases/_index.md#historical-releases) 时提供此字段。  |  

示例请求：

```shell
curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: <your_access_token>" \
     --data '{ "name": "New release", "tag_name": "v0.3", "description": "Super nice release", "milestones": ["v1.0", "v1.0-rc"], "assets": { "links": [{ "name": "hoge", "url": "https://google.com", "direct_asset_path": "/binaries/linux-amd64", "link_type":"other" }] } }' \
     --request POST "https://gitlab.example.com/api/v4/projects/24/releases"
```

示例响应：
```json
{
   "tag_name":"v0.3",
   "description":"超级棒的发布",
   "name":"新版本",
   "created_at":"2019-01-03T02:22:45.118Z",
   "released_at":"2019-01-03T02:22:45.118Z",
   "author":{
      "id":1,
      "name":"管理员",
      "username":"root",
      "state":"活跃",
      "avatar_url":"https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon",
      "web_url":"https://gitlab.example.com/root"
   },
   "commit":{
      "id":"079e90101242458910cccd35eab0e211dfc359c0",
      "short_id":"079e9010",
      "title":"更新 README.md",
      "created_at":"2019-01-03T01:55:38.000Z",
      "parent_ids":[
         "f8d3d94cbd347e924aa7b715845e439d00e80ca4"
      ],
      "message":"更新 README.md",
      "author_name":"管理员",
      "author_email":"admin@example.com",
      "authored_date":"2019-01-03T01:55:38.000Z",
      "committer_name":"管理员",
      "committer_email":"admin@example.com",
      "committed_date":"2019-01-03T01:55:38.000Z"
   },
   "milestones": [
       {
         "id":51,
         "iid":1,
         "project_id":24,
         "title":"v1.0-rc",
         "description":"Voluptate fugiat possimus quis quod aliquam expedita.",
         "state":"已关闭",
         "created_at":"2019-07-12T19:45:44.256Z",
         "updated_at":"2019-07-12T19:45:44.256Z",
         "due_date":"2019-08-16",
         "start_date":"2019-07-30",
         "web_url":"https://gitlab.example.com/root/awesome-app/-/milestones/1",
         "issue_stats": {
            "total": 99,
            "closed": 76
         }
       },
       {
         "id":52,
         "iid":2,
         "project_id":24,
         "title":"v1.0",
         "description":"Voluptate fugiat possimus quis quod aliquam expedita.",
         "state":"已关闭",
         "created_at":"2019-07-16T14:00:12.256Z",
         "updated_at":"2019-07-16T14:00:12.256Z",
         "due_date":"2019-08-16",
         "start_date":"2019-07-30",
         "web_url":"https://gitlab.example.com/root/awesome-app/-/milestones/2",
         "issue_stats": {
            "total": 24,
            "closed": 21
         }
       }
   ],
   "commit_path":"/root/awesome-app/commit/588440f66559714280628a4f9799f0c4eb880a4a",
   "tag_path":"/root/awesome-app/-/tags/v0.11.1",
   "evidence_sha":"760d6cdfb0879c3ffedec13af470e0f71cf52c6cde4d",
   "assets":{
      "count":5,
      "sources":[
         {
            "format":"zip",
            "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.3/awesome-app-v0.3.zip"
         },
         {
            "format":"tar.gz",
            "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.3/awesome-app-v0.3.tar.gz"
         },
         {
            "format":"tar.bz2",
            "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.3/awesome-app-v0.3.tar.bz2"
         },
         {
            "format":"tar",
            "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.3/awesome-app-v0.3.tar"
         }
      ],
      "links":[
         {
            "id":3,
            "name":"hoge",
            "url":"https://gitlab.example.com/root/awesome-app/-/tags/v0.11.1/binaries/linux-amd64",
            "link_type":"other"
         }
      ],
      "evidence_file_path":"https://gitlab.example.com/root/awesome-app/-/releases/v0.3/evidence.json"
   }
}
```

<a id="group-milestones"></a>

### 群组里程碑

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

与项目关联的群组里程碑可以在[创建发布](#create-a-release)和[更新发布](#update-a-release) API 调用的 `milestones` 数组中指定。只能指定与项目群组关联的里程碑，添加上级群组的里程碑会引发错误。

<a id="collect-release-evidence"></a>

## 收集发布证据

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

为现有发布创建证据。

```plaintext
POST /projects/:id/releases/:tag_name/evidence
```

| 属性          | 类型              | 是否必需 | 描述                                                                                             |
| ------------- | ----------------- | -------- | ------------------------------------------------------------------------------------------------ |
| `id`          | 整数或字符串        | 是       | 项目的 ID 或 [URL 编码路径](../rest/_index.md#namespaced-paths)。                             |
| `tag_name`    | 字符串             | 是       | 与该发布关联的 Git 标签。                                                                         |

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/24/releases/v0.1/evidence"
```

示例响应：

```json
200
```

<a id="update-a-release"></a>

## 更新发布

{{< history >}}

- 在极狐GitLab 14.5 中[变更](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/72448)为允许使用 `JOB-TOKEN`。

{{< /history >}}

更新一个发布。更新发布需要对项目具有开发者级别的访问权限。

```plaintext
PUT /projects/:id/releases/:tag_name
```

| 属性          | 类型              | 是否必需 | 描述                                                                                                                              |
| ------------- | ----------------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `id`          | 整数或字符串        | 是       | 项目的 ID 或 [URL 编码路径](../rest/_index.md#namespaced-paths)。                                                               |
| `tag_name`    | 字符串             | 是       | 与该发布关联的 Git 标签。                                                                                                          |
| `name`        | 字符串             | 否       | 发布名称。                                                                                                                        |
| `description` | 字符串             | 否       | 发布的描述。你可以使用 [Markdown](../../user/markdown.md)。                                                                            |
| `milestones`  | 字符串数组          | 否       | 要与发布关联的每个里程碑的标题。极狐GitLab 专业版客户可以指定群组里程碑。要从发布中移除所有里程碑，请指定 `[]`。                                  |
| `released_at` | 日期时间            | 否       | 发布准备就绪的日期。应为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。                                                                  |

示例请求：

```shell
curl --header 'Content-Type: application/json' --request PUT --data '{"name": "新名称", "milestones": ["v1.2"]}' \
     --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/24/releases/v0.1"
```

示例响应：

```json
{
   "tag_name":"v0.1",
   "description":"## CHANGELOG\r\n\r\n- 移除搜索仓库代码时的 100 条限制。!8671\r\n- 当尝试重新打开一个 MR 但同一分支已有打开的 MR 时显示错误信息。!16447 (Akos Gyimesi)\r\n- 修复内部电子邮件模式未被遵循的错误。!22516",
   "name":"新名称",
   "created_at":"2019-01-03T01:55:18.203Z",
   "released_at":"2019-01-03T01:55:18.203Z",
   "author":{
      "id":1,
      "name":"管理员",
      "username":"root",
      "state":"活跃",
      "avatar_url":"https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon",
      "web_url":"https://gitlab.example.com/root"
   },
   "commit":{
      "id":"f8d3d94cbd347e924aa7b715845e439d00e80ca4",
      "short_id":"f8d3d94c",
      "title":"初始提交",
      "created_at":"2019-01-03T01:53:28.000Z",
      "parent_ids":[

      ],
      "message":"初始提交",
      "author_name":"管理员",
      "author_email":"admin@example.com",
      "authored_date":"2019-01-03T01:53:28.000Z",
      "committer_name":"管理员",
      "committer_email":"admin@example.com",
      "committed_date":"2019-01-03T01:53:28.000Z"
   },
   "milestones": [
      {
         "id":53,
         "iid":3,
         "project_id":24,
         "title":"v1.2",
         "description":"Voluptate fugiat possimus quis quod aliquam expedita.",
         "state":"活跃",
         "created_at":"2019-09-01T13:00:00.256Z",
         "updated_at":"2019-09-01T13:00:00.256Z",
         "due_date":"2019-09-20",
         "start_date":"2019-09-05",
         "web_url":"https://gitlab.example.com/root/awesome-app/-/milestones/3",
         "issue_stats": {
            "opened": 11,
            "closed": 78
         }
      }
   ],
   "commit_path":"/root/awesome-app/commit/588440f66559714280628a4f9799f0c4eb880a4a",
   "tag_path":"/root/awesome-app/-/tags/v0.11.1",
   "evidence_sha":"760d6cdfb0879c3ffedec13af470e0f71cf52c6cde4d",
   "assets":{
      "count":4,
      "sources":[
         {
            "format":"zip",
            "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.1/awesome-app-v0.1.zip"
         },
         {
            "format":"tar.gz",
            "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.1/awesome-app-v0.1.tar.gz"
         },
         {
            "format":"tar.bz2",
            "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.1/awesome-app-v0.1.tar.bz2"
         },
         {
            "format":"tar",
            "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.1/awesome-app-v0.1.tar"
         }
      ],
      "links":[

      ],
      "evidence_file_path":"https://gitlab.example.com/root/awesome-app/-/releases/v0.1/evidence.json"
   }
}
```

<a id="delete-a-release"></a>

## 删除发布

删除一个发布。删除发布不会删除关联的标签。删除发布需要对项目具有维护者级别的访问权限。

```plaintext
DELETE /projects/:id/releases/:tag_name
```

| 属性          | 类型              | 是否必需 | 描述                                                                                             |
| ------------- | ----------------- | -------- | ------------------------------------------------------------------------------------------------ |
| `id`          | 整数或字符串        | 是       | 项目的 ID 或 [URL 编码路径](../rest/_index.md#namespaced-paths)。                              |
| `tag_name`    | 字符串             | 是       | 与该发布关联的 Git 标签。                                                                         |

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/projects/24/releases/v0.1"
```

示例响应：

```json
{
   "tag_name":"v0.1",
   "description":"## CHANGELOG\r\n\r\n- 移除搜索仓库代码时的 100 条限制。!8671\r\n- 当尝试重新打开一个 MR 但同一分支已有打开的 MR 时显示错误信息。!16447 (Akos Gyimesi)\r\n- 修复内部电子邮件模式未被遵循的错误。!22516",
   "name":"新名称",
   "created_at":"2019-01-03T01:55:18.203Z",
   "released_at":"2019-01-03T01:55:18.203Z",
   "author":{
      "id":1,
      "name":"管理员",
      "username":"root",
      "state":"活跃",
      "avatar_url":"https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon",
      "web_url":"https://gitlab.example.com/root"
   },
   "commit":{
      "id":"f8d3d94cbd347e924aa7b715845e439d00e80ca4",
      "short_id":"f8d3d94c",
      "title":"初始提交",
      "created_at":"2019-01-03T01:53:28.000Z",
      "parent_ids":[

      ],
      "message":"初始提交",
      "author_name":"管理员",
      "author_email":"admin@example.com",
      "authored_date":"2019-01-03T01:53:28.000Z",
      "committer_name":"管理员",
      "committer_email":"admin@example.com",
      "committed_date":"2019-01-03T01:53:28.000Z"
   },
   "commit_path":"/root/awesome-app/commit/588440f66559714280628a4f9799f0c4eb880a4a",
   "tag_path":"/root/awesome-app/-/tags/v0.11.1",
   "evidence_sha":"760d6cdfb0879c3ffedec13af470e0f71cf52c6cde4d",
   "assets":{
      "count":4,
      "sources":[
         {
            "format":"zip",
            "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.1/awesome-app-v0.1.zip"
         },
         {
            "format":"tar.gz",
            "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.1/awesome-app-v0.1.tar.gz"
         },
         {
            "format":"tar.bz2",
            "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.1/awesome-app-v0.1.tar.bz2"
         },
         {
            "format":"tar",
            "url":"https://gitlab.example.com/root/awesome-app/-/archive/v0.1/awesome-app-v0.1.tar"
         }
      ],
      "links":[

      ],
      "evidence_file_path":"https://gitlab.example.com/root/awesome-app/-/releases/v0.1/evidence.json"
   }
}
```

<a id="upcoming-releases"></a>

## 即将发布的版本

`released_at` 属性设置为未来日期的发布，[在 UI 中](../../user/project/releases/_index.md#upcoming-releases) 会被标记为 **即将发布**。

此外，如果[从 API 请求发布列表](#list-releases)，对于每个 `release_at` 属性设置为未来日期的发布，响应中会额外返回一个 `upcoming_release` 属性（设置为 true）。

<a id="historical-releases"></a>

## 历史发布

{{< history >}}

- 在极狐GitLab 15.2 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/199429)。

{{< /history >}}

`released_at` 属性设置为过去日期的发布，[在 UI 中](../../user/project/releases/_index.md#historical-releases) 会被标记为 **历史发布**。

此外，如果[从 API 请求发布列表](#list-releases)，对于每个 `release_at` 属性设置为过去日期的发布，响应中会额外返回一个 `historical_release` 属性（设置为 true）。