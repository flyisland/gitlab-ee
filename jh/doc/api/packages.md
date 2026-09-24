---
stage: Package
group: Software Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.3 中引入了对项目级 API 使用 [极狐GitLab CI/CD job token](../ci/jobs/ci_job_token.md) 认证的支持。

{{< /history >}}

使用此 API 与 [极狐GitLab 软件包](../administration/packages/_index.md) 交互。

<a id="list-packages"></a>

## 列出软件包

{{< history >}}

- `pipelines` 在极狐GitLab 16.1 中废弃。

{{< /history >}}

<a id="for-a-project"></a>

### 针对项目

列出指定项目的所有软件包。结果中包含所有软件包类型。当
未经认证访问时，仅返回公开项目的软件包。
默认情况下，返回状态为 `default`、`deprecated` 和 `error` 的软件包。使用 `status` 参数查看其他
软件包。

```plaintext
GET /projects/:id/packages
```

| 属性             | 类型           | 是否必需 | 描述 |
|:----------------------|:---------------|:---------|:------------|
| `id`                  | integer or string | 是      | ID 或 [项目 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `order_by`            | string         | 否       | 排序字段。可选值：`created_at`（默认）、`name`、`version` 或 `type`。 |
| `sort`                | string         | 否       | 排序方向，`asc`（默认，升序）或 `desc`（降序）。 |
| `package_type`        | string         | 否       | 按类型筛选返回的软件包。可选值：`composer`、`conan`、`generic`、`golang`、`helm`、`maven`、`npm`、`nuget`、`pypi` 或 `terraform_module`。 |
| `package_name`        | string         | 否       | 按名称模糊搜索项目软件包。 |
| `package_version`     | string         | 否       | 按版本筛选项目软件包。如果与 `include_versionless` 结合使用，则不会返回无版本软件包。[在极狐GitLab 16.6 中引入](https://gitlab.com/gitlab-org/gitlab/-/issues/349065)。 |
| `include_versionless` | boolean        | 否       | 设置为 true 时，响应中包含无版本软件包。 |
| `status`              | string         | 否       | 按状态筛选返回的软件包。可选值：`default`、`hidden`、`processing`、`error`、`pending_destruction` 或 `deprecated`。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/packages"
```

响应示例：

```json
[
  {
    "id": 1,
    "name": "com/mycompany/my-app",
    "version": "1.0-SNAPSHOT",
    "package_type": "maven",
    "created_at": "2019-11-27T03:37:38.711Z",
    "creator_id": 1,
    "pipeline": {
      "id": 123,
      "status": "pending",
      "ref": "new-pipeline",
      "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
      "web_url": "https://example.com/foo/bar/pipelines/47",
      "created_at": "2016-08-11T11:28:34.085Z",
      "updated_at": "2016-08-11T11:32:35.169Z",
      "user": {
        "name": "Administrator",
        "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon"
      }
    },
    "pipelines": [],
    "tags": []
  },
  {
    "id": 2,
    "name": "@foo/bar",
    "version": "1.0.3",
    "package_type": "npm",
    "created_at": "2019-11-27T03:37:38.711Z",
    "tags": []
  }
]
```

默认情况下，`GET` 请求返回 20 条结果，因为该 API 是[分页的](rest/_index.md#pagination)。

尽管可以按状态筛选软件包，但处理状态为 `processing` 的软件包
可能导致数据异常或软件包损坏。

<a id="for-a-group"></a>

### 针对群组

列出指定群组的所有软件包。
未经认证访问时，仅返回公开项目的软件包。
默认情况下，返回状态为 `default`、`deprecated` 和 `error` 的软件包。使用 `status` 参数查看其他
软件包。

```plaintext
GET /groups/:id/packages
```

| 属性             | 类型           | 是否必需 | 描述 |
|:----------------------|:---------------|:---------|:------------|
| `id`                  | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `exclude_subgroups`   | boolean        | 否       | 如果参数为 true，则子群组项目的软件包不列出。默认为 `false`。 |
| `order_by`            | string         | 否       | 排序字段。可选值：`created_at`（默认）、`name`、`version`、`type` 或 `project_path`。 |
| `sort`                | string         | 否       | 排序方向，`asc`（默认，升序）或 `desc`（降序）。 |
| `package_type`        | string         | 否       | 按类型筛选返回的软件包。可选值：`composer`、`conan`、`generic`、`golang`、`helm`、`maven`、`npm`、`nuget`、`pypi` 或 `terraform_module`。 |
| `package_name`        | string         | 否       | 按名称模糊搜索项目软件包。 |
| `package_version`     | string         | 否       | 按版本筛选返回的软件包。如果与 `include_versionless` 结合使用，则不会返回无版本软件包。[在极狐GitLab 16.6 中引入](https://gitlab.com/gitlab-org/gitlab/-/issues/349065)。 |
| `include_versionless` | boolean        | 否       | 设置为 true 时，响应中包含无版本软件包。 |
| `status`              | string         | 否       | 按状态筛选返回的软件包。可选值：`default`、`hidden`、`processing`、`error`、`pending_destruction` 或 `deprecated`。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/packages?exclude_subgroups=false"
```

响应示例：

```json
[
  {
    "id": 1,
    "name": "com/mycompany/my-app",
    "version": "1.0-SNAPSHOT",
    "package_type": "maven",
    "_links": {
      "web_path": "/namespace1/project1/-/packages/1",
      "delete_api_path": "/namespace1/project1/-/packages/1"
    },
    "created_at": "2019-11-27T03:37:38.711Z",
    "creator_id": 1,
    "pipelines": [
      {
        "id": 123,
        "status": "pending",
        "ref": "new-pipeline",
        "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
        "web_url": "https://example.com/foo/bar/pipelines/47",
        "created_at": "2016-08-11T11:28:34.085Z",
        "updated_at": "2016-08-11T11:32:35.169Z",
        "user": {
          "name": "Administrator",
          "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon"
        }
      }
    ]
  },
  {
    "id": 2,
    "name": "@foo/bar",
    "version": "1.0.3",
    "package_type": "npm",
    "_links": {
      "web_path": "/namespace1/project1/-/packages/1",
      "delete_api_path": "/namespace1/project1/-/packages/1"
    },
    "created_at": "2019-11-27T03:37:38.711Z",
    "pipelines": [
      {
        "id": 123,
        "status": "pending",
        "ref": "new-pipeline",
        "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
        "web_url": "https://example.com/foo/bar/pipelines/47",
        "created_at": "2016-08-11T11:28:34.085Z",
        "updated_at": "2016-08-11T11:32:35.169Z",
        "user": {
          "name": "Administrator",
          "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon"
        }
      }
    ]
  }
]
```

默认情况下，`GET` 请求返回 20 条结果，因为该 API 是[分页的](rest/_index.md#pagination)。

`creator_id` 字段包含创建软件包的用户的 ID。当软件包由部署令牌或作业令牌创建时，此字段为 `null`。

`_links` 对象包含以下属性：

- `web_path`：您可以在 极狐GitLab 中访问以查看软件包详情的路径。
- `delete_api_path`：删除软件包的 API 路径。仅当请求用户有权操作时才可用。

尽管可以按状态筛选软件包，但处理状态为 `processing` 的软件包
可能导致数据异常或软件包损坏。

<a id="retrieve-a-project-package"></a>

## 获取项目软件包

{{< history >}}

- `pipelines` 在极狐GitLab 16.1 中废弃。

{{< /history >}}

获取指定的项目软件包。仅返回状态为 `default` 或 `deprecated` 的软件包。

```plaintext
GET /projects/:id/packages/:package_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | ID 或 [项目 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `package_id`      | integer | 是 | 软件包的 ID。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/packages/:package_id"
```

响应示例：

```json
{
  "id": 1,
  "name": "com/mycompany/my-app",
  "version": "1.0-SNAPSHOT",
  "package_type": "maven",
  "_links": {
    "web_path": "/namespace1/project1/-/packages/1",
    "delete_api_path": "/namespace1/project1/-/packages/1"
  },
  "created_at": "2019-11-27T03:37:38.711Z",
  "last_downloaded_at": "2022-09-07T07:51:50.504Z",
  "creator_id": 1,
  "pipelines": [
    {
      "id": 123,
      "status": "pending",
      "ref": "new-pipeline",
      "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
      "web_url": "https://example.com/foo/bar/pipelines/47",
      "created_at": "2016-08-11T11:28:34.085Z",
      "updated_at": "2016-08-11T11:32:35.169Z",
      "user": {
        "name": "Administrator",
        "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon"
      }
    }
  ],
  "versions": [
    {
      "id":2,
      "version":"2.0-SNAPSHOT",
      "created_at":"2020-04-28T04:42:11.573Z",
      "pipelines": [
        {
          "id": 234,
          "status": "pending",
          "ref": "new-pipeline",
          "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
          "web_url": "https://example.com/foo/bar/pipelines/58",
          "created_at": "2016-08-11T11:28:34.085Z",
          "updated_at": "2016-08-11T11:32:35.169Z",
          "user": {
            "name": "Administrator",
            "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon"
          }
        }
      ]
    }
  ]
}
```

`creator_id` 字段包含创建软件包的用户的 ID。当软件包由部署令牌或作业令牌创建时，此字段为 `null`。

`_links` 对象包含以下属性：

- `web_path`：您可以在 极狐GitLab 中访问以查看软件包详情的路径。仅在软件包状态为 `default` 或 `deprecated` 时可用。
- `delete_api_path`：删除软件包的 API 路径。仅当请求用户有权操作时才可用。

<a id="list-package-files"></a>

## 列出软件包文件

列出指定软件包的所有文件。

```plaintext
GET /projects/:id/packages/:package_id/package_files
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | ID 或 [项目 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `package_id`      | integer | 是 | 软件包的 ID。 |
| `order_by`            | string         | 否       | 排序字段。可选值：`id`（默认）、`file_name`、`created_at`。 |
| `sort`                | string         | 否       | 排序方向，`asc`（默认，升序）或 `desc`（降序）。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/packages/:package_id/package_files"
```

响应示例：

```json
[
  {
    "id": 25,
    "package_id": 4,
    "created_at": "2018-11-07T15:25:52.199Z",
    "file_name": "my-app-1.5-20181107.152550-1.jar",
    "size": 2421,
    "file_md5": "58e6a45a629910c6ff99145a688971ac",
    "file_sha1": "ebd193463d3915d7e22219f52740056dfd26cbfe",
    "file_sha256": "a903393463d3915d7e22219f52740056dfd26cbfeff321b",
    "pipelines": [
      {
        "id": 123,
        "status": "pending",
        "ref": "new-pipeline",
        "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
        "web_url": "https://example.com/foo/bar/pipelines/47",
        "created_at": "2016-08-11T11:28:34.085Z",
        "updated_at": "2016-08-11T11:32:35.169Z",
        "user": {
          "name": "Administrator",
          "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon"
        }
      }
    ]
  },
  {
    "id": 26,
    "package_id": 4,
    "created_at": "2018-11-07T15:25:56.776Z",
    "file_name": "my-app-1.5-20181107.152550-1.pom",
    "size": 1122,
    "file_md5": "d90f11d851e17c5513586b4a7e98f1b2",
    "file_sha1": "9608d068fe88aff85781811a42f32d97feb440b5",
    "file_sha256": "2987d068fe88aff85781811a42f32d97feb4f092a399"
  },
  {
    "id": 27,
    "package_id": 4,
    "created_at": "2018-11-07T15:26:00.556Z",
    "file_name": "maven-metadata.xml",
    "size": 767,
    "file_md5": "6dfd0cce1203145a927fef5e3a1c650c",
    "file_sha1": "d25932de56052d320a8ac156f745ece73f6a8cd2",
    "file_sha256": "ac849d002e56052d320a8ac156f745ece73f6a8cd2f3e82"
  }
]
```

默认情况下，`GET` 请求返回 20 条结果，因为该 API 是[分页的](rest/_index.md#pagination)。

<a id="list-package-pipelines"></a>

## 列出软件包流水线

{{< history >}}

- 在极狐GitLab 16.1 中引入。

{{< /history >}}

列出指定软件包的所有流水线。结果按 `id` 降序排列。

结果[基于键集分页](rest/_index.md#keyset-based-pagination)，每页最多返回 20 条记录。

```plaintext
GET /projects/:id/packages/:package_id/pipelines
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | ID 或 [项目 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `package_id`      | integer | 是 | 软件包的 ID。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/packages/:package_id/pipelines"
```

响应示例：

```json
[
  {
    "id": 1,
    "iid": 1,
    "project_id": 9,
    "sha": "2b6127f6bb6f475c4e81afcc2251e3f941e554f9",
    "ref": "mytag",
    "status": "failed",
    "source": "push",
    "created_at": "2023-02-01T12:19:21.895Z",
    "updated_at": "2023-02-01T14:00:05.922Z",
    "web_url": "http://gdk.test:3001/feature-testing/composer-repository/-/pipelines/1",
    "user": {
      "id": 1,
      "username": "root",
      "name": "Administrator",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon",
      "web_url": "http://gdk.test:3001/root"
    }
  },
  {
    "id": 2,
    "iid": 2,
    "project_id": 9,
    "sha": "e564015ac6cb3d8617647802c875b27d392f72a6",
    "ref": "main",
    "status": "canceled",
    "source": "push",
    "created_at": "2023-02-01T12:23:23.694Z",
    "updated_at": "2023-02-01T12:26:28.635Z",
    "web_url": "http://gdk.test:3001/feature-testing/composer-repository/-/pipelines/2",
    "user": {
      "id": 1,
      "username": "root",
      "name": "Administrator",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon",
      "web_url": "http://gdk.test:3001/root"
    }
  }
]
```

<a id="delete-a-project-package"></a>

## 删除项目软件包

删除指定的项目软件包。

```plaintext
DELETE /projects/:id/packages/:package_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | ID 或 [项目 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `package_id`      | integer | 是 | 软件包的 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/packages/:package_id"
```

可能返回以下状态码：

- `204 No Content`：软件包已成功删除。
- `403 Forbidden`：该软件包受保护，无法删除。
- `404 Not Found`：未找到该软件包。

如果启用了[请求转发](../user/packages/package_registry/supported_functionality.md#forwarding-requests)，
删除软件包可能引入[依赖混淆风险](../user/packages/package_registry/supported_functionality.md#deleting-packages)。

如果软件包受[保护规则](../user/packages/package_registry/package_protection_rules.md#protect-a-package)保护，则禁止删除该软件包。

<a id="delete-a-package-file"></a>

## 删除软件包文件

> [!warning]
> 删除软件包文件可能损坏您的软件包，导致其无法使用或无法从软件包管理器中拉取。在删除软件包文件之前，请确保您了解操作后果。

删除指定的软件包文件。

```plaintext
DELETE /projects/:id/packages/:package_id/package_files/:package_file_id
```

| 属性         | 类型           | 是否必需 | 描述 |
| ----------------- | -------------- | -------- | ----------- |
| `id`              | integer or string | 是 | ID 或 [项目 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `package_id`      | integer        | 是 | 软件包的 ID。 |
| `package_file_id` | integer        | 是 | 软件包文件的 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/packages/:package_id/package_files/:package_file_id"
```

可能返回以下状态码：

- `204 No Content`：软件包已成功删除。
- `403 Forbidden`：用户没有权限删除该文件，或该软件包受保护而无法删除。
- `404 Not Found`：未找到该软件包或软件包文件。

如果某个软件包文件所属的软件包受[保护规则](../user/packages/package_registry/package_protection_rules.md#protect-a-package)保护，则禁止删除该软件包文件。