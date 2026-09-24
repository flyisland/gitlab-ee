---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 告警管理告警 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与 [告警](../operations/incident_management/alerts.md) 的指标图像进行交互。

更多端点可通过 [GraphQL API](graphql/reference/_index.md#alertmanagementalert) 获取。

<a id="upload-metric-image"></a>

## 上传指标图像

为指定告警上传指标图像。

```plaintext
POST /projects/:id/alert_management_alerts/:alert_iid/metric_images
```

| 属性 | 类型 | 是否必需 | 描述 |
|-------------|----------------|----------|-------------|
| `id` | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `alert_iid` | integer | 是 | 项目告警的内部 ID。 |

请求示例：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
  --form 'file=@/path/to/file.png' \
  --form 'url=http://example.com' \
  --form 'url_text=Example website' \
  --url "https://gitlab.example.com/api/v4/projects/5/alert_management_alerts/93/metric_images"
```

响应示例：

```json
{
  "id":17,
  "created_at":"2020-11-12T20:07:58.156Z",
  "filename":"sample_2054",
  "file_path":"/uploads/-/system/alert_metric_image/file/17/sample_2054.png",
  "url":"https://example.com/metric",
  "url_text":"An example metric"
}
```

<a id="list-all-metric-images"></a>

## 列出所有指标图像

列出指定告警的所有指标图像。

```plaintext
GET /projects/:id/alert_management_alerts/:alert_iid/metric_images
```

| 属性 | 类型 | 是否必需 | 描述 |
|-------------|----------------|----------|-------------|
| `id` | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `alert_iid` | integer | 是 | 项目告警的内部 ID。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/alert_management_alerts/93/metric_images"
```

响应示例：

```json
[
  {
    "id":17,
    "created_at":"2020-11-12T20:07:58.156Z",
    "filename":"sample_2054",
    "file_path":"/uploads/-/system/alert_metric_image/file/17/sample_2054.png",
    "url":"https://example.com/metric",
    "url_text":"An example metric"
  },
  {
    "id":18,
    "created_at":"2020-11-12T20:14:26.441Z",
    "filename":"sample_2054",
    "file_path":"/uploads/-/system/alert_metric_image/file/18/sample_2054.png",
    "url":"https://example.com/metric",
    "url_text":"An example metric"
  }
]
```

<a id="update-a-metric-image"></a>

## 更新指标图像

更新告警的指定指标图像。

```plaintext
PUT /projects/:id/alert_management_alerts/:alert_iid/metric_images/:image_id
```

| 属性 | 类型 | 是否必需 | 描述 |
|-------------|----------------|----------|-------------|
| `id` | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `alert_iid` | integer | 是 | 项目告警的内部 ID。 |
| `image_id` | integer | 是 | 图像的 ID。 |
| `url` | string | 否 | 查看更多指标信息的 URL。 |
| `url_text` | string | 否 | 图像或 URL 的描述。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --request PUT  --form 'url=http://example.com' \
  --form 'url_text=Example website' \
  --url "https://gitlab.example.com/api/v4/projects/5/alert_management_alerts/93/metric_images/1"
```

响应示例：

```json
{
  "id":23,
  "created_at":"2020-11-13T00:06:18.084Z",
  "filename":"file.png",
  "file_path":"/uploads/-/system/alert_metric_image/file/23/file.png",
  "url":"https://example.com/metric",
  "url_text":"An example metric"
}
```

<a id="delete-a-metric-image"></a>

## 删除指标图像

删除告警的指定指标图像。

```plaintext
DELETE /projects/:id/alert_management_alerts/:alert_iid/metric_images/:image_id
```

| 属性 | 类型 | 是否必需 | 描述 |
|-------------|----------------|----------|-------------|
| `id` | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `alert_iid` | integer | 是 | 项目告警的内部 ID。 |
| `image_id` | integer | 是 | 图像的 ID。 |

请求示例：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url  "https://gitlab.example.com/api/v4/projects/5/alert_management_alerts/93/metric_images/1"
```

可能返回以下状态码：

- `204 No Content`：如果图像删除成功。
- `422 Unprocessable`：如果图像无法删除。