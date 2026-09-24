---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目导入和导出 API
description: "使用 REST API 导入和导出项目。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 来[迁移项目](../user/project/settings/import_export.md)。
如果您首先使用[群组导入和导出 API](group_import_export.md) 迁移父级群组结构，则可以保留群组级别的关联关系，例如项目议题与群组史诗之间的连接。

使用此 API 后，您可能希望使用[项目级 CI/CD 变量 API](project_level_variables.md) 来保留项目的 CI/CD 变量。

您仍然必须通过一系列 Docker 拉取和推送来迁移您的[容器镜像仓库](../user/packages/container_registry/_index.md)。重新运行任何 CI/CD 流水线以检索任何构建产物。

先决条件：

- 对于项目导出，请参阅[导出项目及其数据](../user/project/settings/import_export.md#export-a-project-and-its-data)。
- 对于项目导入，请参阅[导入项目及其数据](../user/project/settings/import_export.md#import-a-project-and-its-data)。

<a id="export-a-project"></a>

## 导出项目

导出指定的项目。

使用 `upload` 哈希参数将导出的项目上传到 Web 服务器或任何兼容 S3 的平台。对于导出，极狐GitLab：

- 仅支持将二进制数据文件上传到最终服务器。
- 在上传请求中发送 `Content-Type: application/gzip` 请求头。请确保您的预签名 URL 在签名中包含此
  请求头。
- 完成项目导出过程可能需要一些时间。请确保上传 URL 的过期时间不要太短，并在整个导出过程中保持可用。
- 管理员可以修改最大导出文件大小。默认情况下，最大值是无限的（`0`）。要更改此设置，
  请使用以下任一方式编辑 `max_export_size`：
  - [极狐GitLab UI](../administration/settings/import_and_export_settings.md)。
  - [应用程序设置 API](settings.md#update-application-settings)
- 在 JihuLab.com 上，最大导入文件大小有固定限制。有关更多信息，请参阅
  [账户和限制设置](../user/jihulab_com/_index.md#account-and-limit-settings)。

如果存在 `upload` 参数，则 `upload[url]` 参数是必需的。

对于上传到 Amazon S3，请参阅[生成用于上传对象的预签名 URL](https://docs.aws.amazon.com/AmazonS3/latest/userguide/PresignedUrlUploadObject.html)
文档脚本以生成 `upload[url]`。
由于一个[已知问题](https://gitlab.com/gitlab-org/gitlab/-/issues/430277)，您只能将最大文件大小为 5 GB 的文件上传到 Amazon S3。

```plaintext
POST /projects/:id/export
```

| 属性             | 类型              | 必填 | 描述 |
|-----------------------|-------------------|----------|-------------|
| `id`                  | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `upload[url]`         | 字符串            | 是      | 上传项目的 URL。 |
| `description`         | 字符串            | 否       | 覆盖项目描述。 |
| `upload`              | 哈希              | 否       | 包含将导出的项目上传到 Web 服务器所需信息的哈希。 |
| `upload[http_method]` | 字符串            | 否       | 上传导出项目所使用的 HTTP 方法。仅允许 `PUT` 和 `POST` 方法。默认为 `PUT`。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/export" \
  --data "upload[http_method]=PUT" \
  --data-urlencode "upload[url]=https://example-bucket.s3.eu-west-3.amazonaws.com/backup?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=<your_access_token>%2F20180312%2Feu-west-3%2Fs3%2Faws4_request&X-Amz-Date=20180312T110328Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=8413facb20ff33a49a147a0b4abcff4c8487cc33ee1f7e450c46e8f695569dbd"
```

```json
{
  "message": "202 Accepted"
}
```

<a id="retrieve-the-status-of-a-project-export"></a>

## 检索项目导出的状态

检索指定项目最近一次导出的状态。

```plaintext
GET /projects/:id/export
```

| 属性 | 类型              | 必填 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/export"
```

状态可以是以下之一：

- `none`：没有排队、开始、完成或正在重新生成的导出。
- `queued`：已收到导出请求，正在队列中等待处理。
- `started`：导出过程已开始并进行中。它包括：
  - 导出过程。
  - 对生成的文件执行的操作，例如发送电子邮件通知
    用户下载文件，或将导出的文件上传到 Web 服务器。
- `finished`：导出过程已完成且用户已收到通知后。
- `regeneration_in_progress`：有导出文件可供下载，并且正在处理生成新导出的请求。

`_links` 仅在导出完成时出现。

`created_at` 是项目创建时间戳，而不是导出开始时间。

```json
{
  "id": 1,
  "description": "Itaque perspiciatis minima aspernatur corporis consequatur.",
  "name": "Gitlab Test",
  "name_with_namespace": "Gitlab Org / Gitlab Test",
  "path": "gitlab-test",
  "path_with_namespace": "gitlab-org/gitlab-test",
  "created_at": "2017-08-29T04:36:44.383Z",
  "export_status": "finished",
  "_links": {
    "api_url": "https://gitlab.example.com/api/v4/projects/1/export/download",
    "web_url": "https://gitlab.example.com/gitlab-org/gitlab-test/download_export"
  }
}
```

<a id="download-a-project-export"></a>

## 下载项目导出

下载指定项目最近一次的导出。

```plaintext
GET /projects/:id/export/download
```

| 属性 | 类型              | 必填 | 描述                              |
| --------- | ----------------- | -------- | ---------------------------------------- |
| `id`      | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --remote-header-name \
  --remote-name \
  --url "https://gitlab.example.com/api/v4/projects/5/export/download"
```

```shell
ls *export.tar.gz
2017-12-05_22-11-148_namespace_project_export.tar.gz
```

<a id="import-a-project-from-a-local-archive"></a>

## 从本地归档导入项目

从本地归档导入项目。

```plaintext
POST /projects/import
```

| 属性         | 类型              | 必填 | 描述 |
|-------------------|-------------------|----------|-------------|
| `file`            | 字符串            | 是      | 要上传的文件。 |
| `path`            | 字符串            | 是      | 新项目的名称和路径。 |
| `name`            | 字符串            | 否       | 要导入的项目的名称。如果未提供，则默认为项目的路径。 |
| `namespace`       | 整数或字符串 | 否       | （已弃用）要将项目导入到的命名空间的 ID 或路径。默认为当前用户的命名空间。<br/><br/> 需要在目标群组中具有维护者或所有者角色。请改用 `namespace_id` 或 `namespace_path`。 |
| `namespace_id`    | 整数           | 否       | 要将项目导入到的命名空间的 ID。默认为当前用户的命名空间。<br/><br/> 需要在目标群组中具有维护者或所有者角色。 |
| `namespace_path`  | 字符串            | 否       | 要将项目导入到的命名空间的路径。默认为当前用户的命名空间。<br/><br/> 需要在目标群组中具有维护者或所有者角色。 |
| `override_params` | 哈希              | 否       | 支持[项目 API](projects.md) 中定义的所有字段。 |
| `overwrite`       | 布尔值           | 否       | 如果存在相同路径的项目，则导入会覆盖它。默认为 `false`。 |

传递的覆盖参数优先于导出文件内定义的所有值。

要从您的文件系统上传文件，请使用 `--form` 参数。这会使 cURL 使用请求头 `Content-Type: multipart/form-data` 发布数据。
`file=` 参数必须指向您文件系统上的一个文件，并且前面
加上 `@`。例如：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form "path=api-project" \
  --form "file=@/path/to/file" \
  --url "https://gitlab.example.com/api/v4/projects/import"
```

cURL 不支持从远程服务器发布文件。此示例使用 Python 的 `open` 方法导入项目：

```python
import requests

url =  'https://gitlab.example.com/api/v4/projects/import'
files = { "file": open("project_export.tar.gz", "rb") }
data = {
    "path": "example-project",
    "namespace_path": "example-group"
}
headers = {
    'Private-Token': "<your_access_token>"
}

requests.post(url, headers=headers, data=data, files=files)
```

```json
{
  "id": 1,
  "description": null,
  "name": "api-project",
  "name_with_namespace": "Administrator / api-project",
  "path": "api-project",
  "path_with_namespace": "root/api-project",
  "created_at": "2018-02-13T09:05:58.023Z",
  "import_status": "scheduled",
  "correlation_id": "mezklWso3Za",
  "failed_relations": []
}
```

> [!note]
> 最大导入文件大小可由管理员设置。默认为 `0`（无限制）。
> 作为管理员，您可以修改最大导入文件大小。为此，请在[应用程序设置 API](settings.md#update-application-settings) 中使用 `max_import_size` 选项，或在 [**管理员**区域](../administration/settings/account_and_limit_settings.md) 中进行修改。

<a id="import-a-project-from-a-remote-archive"></a>

## 从远程归档导入项目

{{< details >}}

- Status: 测试版

{{< /details >}}

从远程归档导入项目。

```plaintext
POST /projects/remote-import
```

| 属性         | 类型              | 必填 | 描述                              |
| ----------------- | ----------------- | -------- | ---------------------------------------- |
| `path`            | 字符串            | 是      | 新项目的名称和路径。 |
| `url`             | 字符串            | 是      | 要导入的文件的 URL。 |
| `name`            | 字符串            | 否       | 要导入的项目的名称。如果未提供，则默认为项目的路径。 |
| `namespace`       | 整数或字符串 | 否       | （已弃用）要将项目导入到的命名空间的 ID 或路径。默认为当前用户的命名空间。<br/><br/> 需要在目标群组中具有维护者或所有者角色。请改用 `namespace_id` 或 `namespace_path`。 |
| `namespace_id`    | 整数           | 否       | 要将项目导入到的命名空间的 ID。默认为当前用户的命名空间。<br/><br/> 需要在目标群组中具有维护者或所有者角色。 |
| `namespace_path`  | 字符串            | 否       | 要将项目导入到的命名空间的路径。默认为当前用户的命名空间。<br/><br/> 需要在目标群组中具有维护者或所有者角色。 |
| `overwrite`       | 布尔值           | 否       | 导入时是否覆盖具有相同路径的项目。默认为 `false`。 |
| `override_params` | 哈希              | 否       | 支持[项目 API](projects.md) 中定义的所有字段。 |

传递的覆盖参数优先于导出文件中定义的所有值。

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/remote-import" \
  --data '{"url":"https://remoteobject/file?token=123123","path":"remote-project"}'
```

```json
{
  "id": 1,
  "description": null,
  "name": "remote-project",
  "name_with_namespace": "Administrator / remote-project",
  "path": "remote-project",
  "path_with_namespace": "root/remote-project",
  "created_at": "2018-02-13T09:05:58.023Z",
  "import_status": "scheduled",
  "correlation_id": "mezklWso3Za",
  "failed_relations": [],
  "import_error": null
}
```

`Content-Length` 请求头必须返回一个有效的数字。最大文件大小为 10 GB。
`Content-Type` 请求头必须是 `application/gzip`。

<a id="import-a-project-from-an-aws-s3-bucket"></a>

## 从 AWS S3 存储桶导入项目

从存储在指定 AWS S3 存储桶中的归档导入项目。

```plaintext
POST /projects/remote-import-s3
```

| 属性           | 类型              | 必填 | 描述 |
| ------------------- | ----------------- | -------- | ----------- |
| `access_key_id`     | 字符串            | 是      | [AWS S3 访问密钥 ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)。 |
| `bucket_name`       | 字符串            | 是      | 存储文件的 [AWS S3 存储桶名称](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html)。 |
| `file_key`          | 字符串            | 是      | 用于标识文件的 [AWS S3 文件键](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingObjects.html)。 |
| `path`              | 字符串            | 是      | 新项目的完整路径。 |
| `region`            | 字符串            | 是      | 存储文件的 [AWS S3 区域名称](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html#Regions)。 |
| `secret_access_key` | 字符串            | 是      | [AWS S3 秘密访问密钥](https://docs.aws.amazon.com/IAM/latest/UserGuide/security-creds.html#access-keys-and-secret-access-keys)。 |
| `name`              | 字符串            | 否       | 要导入的项目的名称。如果未提供，则默认为项目的路径。 |
| `namespace`         | 整数或字符串 | 否       | （已弃用）要将项目导入到的命名空间的 ID 或路径。默认为当前用户的命名空间。<br/><br/> 需要在目标群组中具有维护者或所有者角色。请改用 `namespace_id` 或 `namespace_path`。 |
| `namespace_id`      | 整数           | 否       | 要将项目导入到的命名空间的 ID。默认为当前用户的命名空间。<br/><br/> 需要在目标群组中具有维护者或所有者角色。 |
| `namespace_path`    | 字符串            | 否       | 要将项目导入到的命名空间的路径。默认为当前用户的命名空间。<br/><br/> 需要在目标群组中具有维护者或所有者角色。 |

传递的覆盖参数优先于导出文件中定义的所有值。

```shell
curl --request POST \
  --url "https://gitlab.example.com/api/v4/projects/remote-import-s3" \
  --header "PRIVATE-TOKEN: <your gitlab access key>" \
  --header 'Content-Type: application/json' \
  --data '{
  "name": "Sample Project",
  "path": "sample-project",
  "region": "<Your S3 region name>",
  "bucket_name": "<Your S3 bucket name>",
  "file_key": "<Your S3 file key>",
  "access_key_id": "<Your AWS access key id>",
  "secret_access_key": "<Your AWS secret access key>"
}'
```

此示例使用连接到 Amazon S3 的模块从 Amazon S3 存储桶导入：

```python
import requests
from io import BytesIO

s3_file = requests.get(presigned_url)

url =  'https://gitlab.example.com/api/v4/projects/import'
files = {'file': ('file.tar.gz', BytesIO(s3_file.content))}
data = {
    "path": "example-project",
    "namespace_path": "example-group"
}
headers = {
    'Private-Token': "<your_access_token>"
}

requests.post(url, headers=headers, data=data, files=files)
```

```json
{
  "id": 1,
  "description": null,
  "name": "Sample project",
  "name_with_namespace": "Administrator / sample-project",
  "path": "sample-project",
  "path_with_namespace": "root/sample-project",
  "created_at": "2018-02-13T09:05:58.023Z",
  "import_status": "scheduled",
  "correlation_id": "mezklWso3Za",
  "failed_relations": [],
  "import_error": null
}
```

<a id="retrieve-the-status-of-a-project-import"></a>

## 检索项目导入的状态

检索指定项目最近一次导入的状态。

```plaintext
GET /projects/:id/import
```

| 属性 | 类型           | 必填 | 描述                              |
| --------- | -------------- | -------- | ---------------------------------------- |
| `id`      | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/import"
```

状态可以是以下之一：

- `none`
- `scheduled`
- `failed`
- `started`
- `finished`

如果状态为 `failed`，则会在 `import_error` 下包含导入错误消息。如果状态为 `failed`、`started` 或 `finished`，则 `failed_relations` 数组可能会填充因以下任一原因而导入失败的关联关系：

- 不可恢复的错误。
- 重试次数已用尽。一个典型的例子：查询超时。

> [!note]
> `failed_relations` 中元素的 `id` 字段引用的是失败记录，而不是关联关系本身。
> 此外，`failed_relations` 数组最多包含 100 个项目。

```json
{
  "id": 1,
  "description": "Itaque perspiciatis minima aspernatur corporis consequatur.",
  "name": "Gitlab Test",
  "name_with_namespace": "Gitlab Org / Gitlab Test",
  "path": "gitlab-test",
  "path_with_namespace": "gitlab-org/gitlab-test",
  "created_at": "2017-08-29T04:36:44.383Z",
  "import_status": "started",
  "import_type": "github",
  "correlation_id": "mezklWso3Za",
  "failed_relations": [
    {
      "id": 42,
      "created_at": "2020-04-02T14:48:59.526Z",
      "exception_class": "RuntimeError",
      "exception_message": "A failure occurred",
      "source": "custom error context",
      "relation_name": "merge_requests",
      "line_number": 0
    }
  ]
}
```

从 GitHub 导入时，`stats` 字段会列出已从 GitHub 获取了多少对象以及已导入了多少对象：

```json
{
  "id": 1,
  "description": "Itaque perspiciatis minima aspernatur corporis consequatur.",
  "name": "Gitlab Test",
  "name_with_namespace": "Gitlab Org / Gitlab Test",
  "path": "gitlab-test",
  "path_with_namespace": "gitlab-org/gitlab-test",
  "created_at": "2017-08-29T04:36:44.383Z",
  "import_status": "started",
  "import_type": "github",
  "correlation_id": "mezklWso3Za",
  "failed_relations": [
    {
      "id": 42,
      "created_at": "2020-04-02T14:48:59.526Z",
      "exception_class": "RuntimeError",
      "exception_message": "A failure occurred",
      "source": "custom error context",
      "relation_name": "merge_requests",
      "line_number": 0
    }
  ],
  "stats": {
    "fetched": {
      "diff_note": 19,
      "issue": 3,
      "label": 1,
      "note": 3,
      "pull_request": 2,
      "pull_request_merged_by": 1,
      "pull_request_review": 16
    },
    "imported": {
      "diff_note": 19,
      "issue": 3,
      "label": 1,
      "note": 3,
      "pull_request": 2,
      "pull_request_merged_by": 1,
      "pull_request_review": 16
    }
  }
}
```

<a id="import-project-resources"></a>

## 导入项目资源

导入项目归档中包含的[项目资源](../user/project/settings/import_export.md#project-items-that-are-exported)。要导入的项目类型由 `relation` 属性控制。
跳过之前已导入的项目。

所需的项目导出文件遵循[从本地归档导入项目](#import-a-project-from-a-local-archive) 中描述的相同结构和大小要求。

- 解压后的文件必须符合极狐GitLab 项目导出的结构。
- 归档文件不得超过管理员配置的最大导入文件大小。

```plaintext
POST /projects/import-relation
```

| 属性  | 类型   | 必填 | 描述                                                                                                    |
|------------|--------|----------|----------------------------------------------------------------------------------------------------------------|
| `file`     | 字符串 | 是      | 要上传的文件。                                                                                       |
| `path`     | 字符串 | 是      | 新项目的名称和路径。                                                                                 |
| `relation` | 字符串 | 是      | 要导入的关联关系的名称。必须是 `issues`、`milestones`、`ci_pipelines` 或 `merge_requests` 之一。 |

要从您的文件系统上传文件，请使用 `--form` 选项，这会使 cURL 使用请求头 `Content-Type: multipart/form-data` 发布数据。
`file=` 参数必须指向您文件系统上的一个文件，并且前面
加上 `@`。例如：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form "path=api-project" \
  --form "file=@/path/to/file" \
  --form "relation=issues" \
  --url "https://gitlab.example.com/api/v4/projects/import-relation"
```

```json
{
  "id": 9,
  "project_path": "namespace1/project1",
  "relation": "issues",
  "status": "finished"
}
```

<a id="retrieve-the-status-of-a-project-resource-import"></a>

## 检索项目资源导入的状态

检索指定项目最近一次关联关系导入的状态。由于一次只能调度一个关联关系导入，您可以使用此端点来检查之前的导入是否成功完成。

```plaintext
GET /projects/:id/relation-imports
```

| 属性 | 类型               | 必填 | 描述                                                                          |
| --------- |--------------------| -------- |--------------------------------------------------------------------------------------|
| `id`      | 整数或字符串  | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/18/relation-imports"
```

```json
[
  {
    "id": 1,
    "project_path": "namespace1/project1",
    "relation": "issues",
    "status": "created",
    "created_at": "2024-03-25T11:03:48.074Z",
    "updated_at": "2024-03-25T11:03:48.074Z"
  }
]
```

状态可以是以下之一：

- `created`：导入已调度，但尚未开始。
- `started`：导入正在处理中。
- `finished`：导入已完成。
- `failed`：导入未能完成。
