---
stage: Security Risk Management
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use the Dependency List Export API to generate and download export files of project or group dependencies.
title: 依赖列表导出 API
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用该 API 导出[依赖项列表](../user/application_security/dependency_list/_index.md)。
每次调用该 API 都需要认证。

<a id="create-a-dependency-list-export"></a>

## 创建依赖列表导出

{{< history >}}

- 引入于极狐GitLab 16.4 [功能标志](../administration/feature_flags/_index.md) 名为 `merge_sbom_api`。默认启用。
- GA 于极狐GitLab 16.7。功能标志 `merge_sbom_api` 已移除。

{{< /history >}}

为流水线中检测到的所有项目依赖项创建 CycloneDX JSON 导出。

如果经过认证的用户没有 [read_dependency](../user/custom_roles/abilities.md#vulnerability-management) 权限，该请求会返回 `403 Forbidden` 状态码。

SBOM 导出只能由导出的创建者访问。

```plaintext
POST /projects/:id/dependency_list_exports
POST /groups/:id/dependency_list_exports
POST /pipelines/:id/dependency_list_exports
```

| 属性 | 类型 | 是否必需 | 描述 |
| ------------------- | ----------------- | ---------- | -----------------------------------------------------------------------------------------------------------------------------|
| `id`                | 整数           | 是        | 经过认证的用户有权访问的项目、群组或流水线的 ID。 |
| `export_type`       | 字符串            | 是        | 导出格式。查看[导出类型](#export-types)以获取可接受值的列表。 |
| `send_email`        | 布尔值           | 否        | 当设置为 `true` 时，在导出完成时向请求导出的用户发送电子邮件通知。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <private_token>" \
  --url "https://gitlab.example.com/api/v4/pipelines/1/dependency_list_exports" \
  --data "export_type=sbom"
```

创建的依赖列表导出将在 `expires_at` 字段中指定的时间自动删除。

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

可以请求不同文件格式的导出。某些格式仅适用于特定对象。

| 导出类型 | 描述 | 适用对象 |
| ----------- | ----------- | ------------- |
| `dependency_list` | 一个以键值对列出依赖项的标准 JSON 对象。 | 项目 |
| `sbom` | [CycloneDX](https://cyclonedx.org/) 1.4 物料清单 | 流水线 |
| `cyclonedx_1_6_json` | [CycloneDX](https://cyclonedx.org/) 1.6 物料清单 | 项目 |
| `json_array` | 一个包含组件对象的扁平 JSON 数组。 | 群组 |
| `csv` | 一个逗号分隔值（CSV）文档。 | 项目、群组 |

<a id="retrieve-a-single-dependency-list-export"></a>

## 获取单个依赖列表导出

获取一个依赖列表导出。

```plaintext
GET /dependency_list_exports/:id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 依赖列表导出的 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <private_token>" \
  --url "https://gitlab.example.com/api/v4/dependency_list_exports/2"
```

当依赖列表导出正在生成时，状态码为 `202 Accepted`，当准备就绪时为 `200 OK`。

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
| `id` | 整数 | 是 | 依赖列表导出的 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <private_token>" \
  --url "https://gitlab.example.com/api/v4/dependency_list_exports/2/download"
```

如果依赖列表导出尚未完成或未找到，响应为 `404 Not Found`。

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
        "vendor": "极狐GitLab",
        "name": "Gemnasium",
        "version": "2.34.0"
      }
    ],
    "authors": [
      {
        "name": "极狐GitLab",
        "email": "support@jihulab.com"
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