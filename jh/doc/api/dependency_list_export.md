---
stage: Security Risk Management
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用依赖列表导出 API 生成并下载项目或群组依赖的导出文件。
title: 依赖列表导出 API
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 导出[依赖列表](../user/application_security/dependency_list/_index.md)。每次调用此 API 都需要进行身份验证。

<a id="create-a-dependency-list-export"></a>

## 创建依赖列表导出

为流水线中检测到的所有项目依赖创建 CycloneDX JSON 导出。

如果已通过身份验证的用户没有 [read_dependency](../user/custom_roles/abilities.md#vulnerability-management) 权限，此请求将返回 `403 Forbidden` 状态码。

SBOM 导出只能由导出的作者访问。

```plaintext
POST /projects/:id/dependency_list_exports
POST /groups/:id/dependency_list_exports
POST /pipelines/:id/dependency_list_exports
```

| 属性           | 类型              | 是否必需   | 描述                                                                                                                  |
| ------------------- | ----------------- | ---------- | -----------------------------------------------------------------------------------------------------------------------------|
| `id`                | integer           | 是        | 已通过身份验证的用户有权访问的项目、群组或流水线的 ID。 |
| `export_type`       | string            | 是        | 导出的格式。有关可接受值的列表，请参阅[导出类型](#export-types)。 |
| `send_email`        | boolean           | 否         | 设置为 `true` 时，导出完成后会向请求导出的用户发送电子邮件通知。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <private_token>" \
  --url "https://gitlab.example.com/api/v4/pipelines/1/dependency_list_exports" \
  --data "export_type=sbom"
```

创建的依赖列表导出将在 `expires_at` 字段指定的时间自动删除。

示例响应：

```json
{
  "id": 2,
  "status": "running",
  "has_finished": false,
  "export_type": "sbom",
  "send_email": false,
  "expires_at": "2025-04-06T09:35:38.746Z",
  "self": "http://gitlab.example.com/api/v4/dependency_list_exports/2",
  "download": "http://gitlab.example.com/api/v4/dependency_list_exports/2/download"
}
```

<a id="export-types"></a>

### 导出类型

可以请求以不同的文件格式导出。某些格式仅适用于特定对象。

| 导出类型 | 描述 | 适用于 |
| ----------- | ----------- | ------------- |
| `dependency_list` | 一个标准 JSON 对象，以键值对形式列出依赖。 | 项目 |
| `sbom` | 一个 [CycloneDX](https://cyclonedx.org/) 1.4 物料清单 | 流水线 |
| `cyclonedx_1_6_json` | 一个 [CycloneDX](https://cyclonedx.org/) 1.6 物料清单 | 项目 |
| `json_array` | 一个包含组件对象的扁平 JSON 数组。 | 群组 |
| `csv` | 一个逗号分隔值（CSV）文档。 | 项目、群组 |

<a id="retrieve-a-single-dependency-list-export"></a>

## 检索单个依赖列表导出

检索一个依赖列表导出。

```plaintext
GET /dependency_list_exports/:id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | 依赖列表导出的 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <private_token>" \
  --url "https://gitlab.example.com/api/v4/dependency_list_exports/2"
```

当依赖列表导出正在生成时，状态码为 `202 Accepted`；准备就绪时，状态码为 `200 OK`。

示例响应：

```json
{
  "id": 4,
  "has_finished": true,
  "self": "http://gitlab.example.com/api/v4/dependency_list_exports/4",
  "download": "http://gitlab.example.com/api/v4/dependency_list_exports/4/download"
}
```

<a id="download-dependency-list-export"></a>

## 下载依赖列表导出

下载单个依赖列表导出。

```plaintext
GET /dependency_list_exports/:id/download
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | 依赖列表导出的 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <private_token>" \
  --url "https://gitlab.example.com/api/v4/dependency_list_exports/2/download"
```

如果依赖列表导出尚未完成或未找到，响应为 `404 Not Found`。

在 CycloneDX 导出中，带有 SPDX 许可证表达式（例如 `MIT AND Zlib`）的组件会在 `licenses[].license.name`中包含完整表达式，并且该条目没有 `id` 字段。

示例响应：

```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "serialNumber": "urn:uuid:aec33827-20ae-40d0-ae83-18ee846364d2",
  "version": 1,
  "metadata": {
    "tools": [
      {
        "vendor": "Gitlab",
        "name": "Gemnasium",
        "version": "2.34.0"
      }
    ],
    "authors": [
      {
        "name": "Gitlab",
        "email": "support@gitlab.com"
      }
    ],
    "properties": [
      {
        "name": "gitlab:dependency_scanning:input_file",
        "value": "package-lock.json"
      }
    ]
  },
  "components": [
    {
      "name": "com.fasterxml.jackson.core/jackson-core",
      "purl": "pkg:maven/com.fasterxml.jackson.core/jackson-core@2.9.2",
      "version": "2.9.2",
      "type": "library",
      "licenses": [
        {
          "license": {
            "id": "MIT",
            "url": "https://spdx.org/licenses/MIT.html"
          }
        },
        {
          "license": {
            "id": "BSD-3-Clause",
            "url": "https://spdx.org/licenses/BSD-3-Clause.html"
          }
        }
      ]
    }
  ]
}

```
