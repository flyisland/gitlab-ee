---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 数据管理 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Status: 实验

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.3 中引入，带有名为 `geo_primary_verification_view` 的功能标志，默认禁用。此功能为实验。
- 该功能标志在极狐GitLab 18.8 中默认启用。

{{< /history >}}

使用数据管理 API 管理实例的数据。

先决条件：

- 您必须是管理员。

<a id="retrieve-model-information"></a>

## 检索模型信息

检索实例中数据模型的信息。此操作为实验，可能会在没有通知的情况下更改或删除。

```plaintext
GET /admin/data_management/:model_name
```

`:model_name` 参数必须为以下之一：

- `ci_job_artifacts`
- `ci_pipeline_artifacts`
- `ci_secure_files`
- `container_repositories`
- `dependency_proxy_blobs`
- `dependency_proxy_manifests`
- `design_management_repositories`
- `group_wiki_repositories`
- `lfs_objects`
- `merge_request_diffs`
- `packages_nuget_symbols`
- `packages_package_files`
- `pages_deployments`
- `projects`
- `projects_wiki_repositories`
- `snippet_repositories`
- `supply_chain_attestations`
- `terraform_state_versions`
- `uploads`

支持的属性：

| 属性        | 类型   | 必填 | 描述                                                                                                                 |
|------------------|--------|----------|-----------------------------------------------------------------------------------------------------------------------------|
| `model_name`     | string | 是      | 所请求模型的复数形式名称。必须属于上述 `:model_name` 列表。                                    |
| `checksum_state` | string | 否       | 按校验和状态搜索。允许的值：pending、started、succeeded、failed、disabled。                                   |
| `identifiers`    | array  | 否       | 使用所请求模型的唯一标识符数组过滤结果，这些标识符可以是整数或 base64 编码的字符串。 |

此端点支持基于模型主键的[键集分页](../rest/_index.md#keyset-based-pagination)，可升序或降序排序。要使用键集分页，请在请求中添加参数 `pagination=keyset`。默认情况下，键集分页每页加载 20 条记录，按升序排序。您可以通过查询参数 `sort` 修改排序顺序，值为 `asc` 或 `desc`。要选择每页的记录数，请使用参数 `per_page`。

如果成功，返回 [`200`](../rest/troubleshooting.md#status-codes) 以及模型信息。包括以下响应属性：

| 属性              | 类型              | 描述                                                                    |
|------------------------|-------------------|--------------------------------------------------------------------------------|
| `checksum_information` | JSON              | Geo 特定的校验和信息（如果可用）。                               |
| `created_at`           | timestamp         | 创建时间戳（如果可用）。                                              |
| `file_size`            | integer           | 对象大小（如果可用）。                                              |
| `model_class`          | string            | 模型的类名。                                                       |
| `record_identifier`    | string 或 integer | 记录的唯一标识符。可以是整数或 base64 编码的字符串。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://primary.example.com/api/v4/admin/data_management/projects?pagination=keyset"
```

响应示例：

```json
[
  {
    "record_identifier": 1,
    "model_class": "Project",
    "created_at": "2025-02-05T11:27:10.173Z",
    "file_size": null,
    "checksum_information": {
      "checksum": "<object checksum>",
      "last_checksum": "2025-07-24T14:22:18.643Z",
      "checksum_state": "succeeded",
      "checksum_retry_count": 0,
      "checksum_retry_at": null,
      "checksum_failure": null
    }
  },
  {
    "record_identifier": 2,
    "model_class": "Project",
    "created_at": "2025-02-05T11:27:14.402Z",
    "file_size": null,
    "checksum_information": {
      "checksum": "<object checksum>",
      "last_checksum": "2025-07-24T14:22:18.214Z",
      "checksum_state": "succeeded",
      "checksum_retry_count": 0,
      "checksum_retry_at": null,
      "checksum_failure": null
    }
  }
]
```

<a id="recalculate-checksums-for-model-records"></a>

## 为模型记录重新计算校验和

为指定模型的选定记录重新计算校验和，可通过 `checksum_state` 和 `identifiers` 参数进行过滤（如果提供）。此请求会将一个后台作业加入队列以执行重新计算。

```plaintext
PUT /admin/data_management/:model_name/checksum
```

| 属性          | 类型    | 必填 | 描述                                                                                                                 |
|--------------------|---------|----------|-----------------------------------------------------------------------------------------------------------------------------|
| `model_name`       | string  | 是      | 所请求模型的复数形式名称。必须属于上述 `:model_name` 列表。                                    |
| `checksum_state`   | string  | 否       | 按校验和状态过滤。允许的值：pending、started、succeeded、failed、disabled。                                   |
| `identifiers`      | array   | 否       | 使用所请求模型的唯一标识符数组过滤记录，这些标识符可以是整数或 base64 编码的字符串。 |

如果成功，返回 [`200`](../rest/troubleshooting.md#status-codes) 以及包含以下信息的 JSON 响应：

| 属性 | 类型   | 描述                                       |
|-----------|--------|---------------------------------------------------|
| `message` | string | 关于成功或错误的信息消息。 |
| `status`  | string | 可以是 "success" 或 "error"。                      |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://primary.example.com/api/v4/admin/data_management/projects/checksum"
```

响应示例：

```json
{
  "status": "success",
  "message": "批量更新作业已成功加入队列。"
}
```

<a id="retrieve-information-about-a-model-record"></a>

## 检索模型记录的信息

检索指定模型记录的信息。

```plaintext
GET /admin/data_management/:model_name/:id
```

| 属性           | 类型              | 必填 | 描述                                                                                 |
|---------------------|-------------------|----------|---------------------------------------------------------------------------------------------|
| `model_name`        | string            | 是      | 所请求模型的复数形式名称。必须属于上述 `:model_name` 列表。    |
| `record_identifier` | string 或 integer | 是      | 所请求模型的唯一标识符。可以是整数或 base64 编码的字符串。 |

如果成功，返回 [`200`](../rest/troubleshooting.md#status-codes) 以及特定模型记录的信息。包括以下响应属性：

| 属性              | 类型              | 描述                                                                    |
|------------------------|-------------------|--------------------------------------------------------------------------------|
| `checksum_information` | JSON              | Geo 特定的校验和信息（如果可用）。                               |
| `created_at`           | timestamp         | 创建时间戳（如果可用）。                                              |
| `file_size`            | integer           | 对象大小（如果可用）。                                              |
| `model_class`          | string            | 模型的类名。                                                       |
| `record_identifier`    | string 或 integer | 记录的唯一标识符。可以是整数或 base64 编码的字符串。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://primary.example.com/api/v4/admin/data_management/projects/1"
```

响应示例：

```json
{
  "record_identifier": 1,
  "model_class": "Project",
  "created_at": "2025-02-05T11:27:10.173Z",
  "file_size": null,
  "checksum_information": {
    "checksum": "<object checksum>",
    "last_checksum": "2025-07-24T14:22:18.643Z",
    "checksum_state": "succeeded",
    "checksum_retry_count": 0,
    "checksum_retry_at": null,
    "checksum_failure": null
  }
}
```

<a id="recalculate-the-checksum-of-a-model-record"></a>

## 重新计算模型记录的校验和

重新计算指定模型记录的校验和。校验和值是使用 md5 或 sha256 算法对查询模型进行哈希计算的结果。

```plaintext
PUT /admin/data_management/:model_name/:record_identifier/checksum
```

| 属性           | 类型              | 必填 | 描述                                                                                                               |
|---------------------|-------------------|----------|---------------------------------------------------------------------------------------------------------------------------|
| `model_name`        | string            | 是      | 所请求模型的复数形式名称。必须属于上述 `:model_name` 列表。                                  |
| `record_identifier` | string 或 integer | 是      | 记录的唯一标识符。可以是整数或 base64 编码的字符串（取自 GET 查询的响应）。 |

如果成功，返回 [`200`](../rest/troubleshooting.md#status-codes) 以及特定模型记录的信息。

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://primary.example.com/api/v4/admin/data_management/projects/1/checksum"
```

响应示例：

```json
{
  "record_identifier": 1,
  "model_class": "Project",
  "created_at": "2025-02-05T11:27:10.173Z",
  "file_size": null,
  "checksum_information": {
    "checksum": "<sha256 或 md5 字符串>",
    "last_checksum": "2025-07-24T14:22:18.643Z",
    "checksum_state": "succeeded",
    "checksum_retry_count": 0,
    "checksum_retry_at": null,
    "checksum_failure": null
  }
}
```