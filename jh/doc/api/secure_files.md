---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目级安全文件 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- [GA] 在 极狐GitLab 15.7 中。功能标志 `ci_secure_files` 已移除。

{{< /history >}}

使用此 API 管理项目的 [安全文件](../ci/secure_files/_index.md)。

<a id="list-all-secure-files-for-a-project"></a>

## 列出项目的所有安全文件

列出指定项目的所有安全文件。

```plaintext
GET /projects/:project_id/secure_files
```

支持的属性：

| 属性    | 类型           | 是否必需 | 描述 |
|--------------|----------------|----------|-------------|
| `project_id` | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/secure_files"
```

示例响应：

```json
[
    {
        "id": 1,
        "name": "myfile.jks",
        "checksum": "16630b189ab34b2e3504f4758e1054d2e478deda510b2b08cc0ef38d12e80aac",
        "checksum_algorithm": "sha256",
        "created_at": "2022-02-22T22:22:22.222Z",
        "expires_at": null,
        "metadata": null
    },
    {
        "id": 2,
        "name": "myfile.cer",
        "checksum": "16630b189ab34b2e3504f4758e1054d2e478deda510b2b08cc0ef38d12e80aa2",
        "checksum_algorithm": "sha256",
        "created_at": "2022-02-22T22:22:22.222Z",
        "expires_at": "2023-09-21T14:55:59.000Z",
        "metadata": {
            "id":"75949910542696343243264405377658443914",
            "issuer": {
                "C":"US",
                "O":"Apple Inc.",
                "CN":"Apple Worldwide Developer Relations Certification Authority",
                "OU":"G3"
            },
            "subject": {
                "C":"US",
                "O":"Organization Name",
                "CN":"Apple Distribution: Organization Name (ABC123XYZ)",
                "OU":"ABC123XYZ",
                "UID":"ABC123XYZ"
            },
            "expires_at":"2023-09-21T14:55:59.000Z"
        }
    }
]
```

<a id="retrieve-details-of-a-secure-file"></a>

## 检索安全文件的详细信息

检索项目中指定安全文件的详细信息。

```plaintext
GET /projects/:project_id/secure_files/:id
```

支持的属性：

| 属性    | 类型           | 是否必需 | 描述 |
|--------------|----------------|----------|-------------|
| `id`         | 整数        | 是      | 安全文件的 ID。 |
| `project_id` | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/secure_files/1"
```

示例响应：

```json
{
    "id": 1,
    "name": "myfile.jks",
    "checksum": "16630b189ab34b2e3504f4758e1054d2e478deda510b2b08cc0ef38d12e80aac",
    "checksum_algorithm": "sha256",
    "created_at": "2022-02-22T22:22:22.222Z",
    "expires_at": null,
    "metadata": null
}
```

<a id="create-a-secure-file"></a>

## 创建安全文件

在指定项目中创建安全文件。

```plaintext
POST /projects/:project_id/secure_files
```

支持的属性：

| 属性       | 类型           | 是否必需 | 描述 |
|-----------------|----------------|----------|-------------|
| `file`          | 文件           | 是      | 正在上传的文件（限制 5 MB）。 |
| `name`          | 字符串         | 是      | 正在上传的文件的名称。文件名在项目中必须是唯一的。 |
| `project_id`    | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/secure_files" \
  --form "name=myfile.jks" \
  --form "file=@/path/to/file/myfile.jks"
```

示例响应：

```json
{
    "id": 1,
    "name": "myfile.jks",
    "checksum": "16630b189ab34b2e3504f4758e1054d2e478deda510b2b08cc0ef38d12e80aac",
    "checksum_algorithm": "sha256",
    "created_at": "2022-02-22T22:22:22.222Z",
    "expires_at": null,
    "metadata": null
}
```

<a id="download-a-secure-file"></a>

## 下载安全文件

下载项目中指定安全文件的内容。

```plaintext
GET /projects/:project_id/secure_files/:id/download
```

支持的属性：

| 属性    | 类型           | 是否必需 | 描述 |
|--------------|----------------|----------|-------------|
| `id`         | 整数        | 是      | 安全文件的 ID。 |
| `project_id` | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/secure_files/1/download" \
  --output myfile.jks
```

<a id="delete-a-secure-file"></a>

## 删除安全文件

从项目中删除指定的安全文件。

```plaintext
DELETE /projects/:project_id/secure_files/:id
```

支持的属性：

| 属性    | 类型           | 是否必需 | 描述 |
|--------------|----------------|----------|-------------|
| `id`         | 整数        | 是      | 安全文件的 ID。 |
| `project_id` | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/secure_files/1"
```