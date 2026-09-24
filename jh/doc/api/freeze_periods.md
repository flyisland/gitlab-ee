---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 冻结期 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与部署 [冻结期](../user/project/releases/_index.md#prevent-unintentional-releases-by-setting-a-deploy-freeze) 进行交互。

<a id="list-freeze-periods"></a>

列出冻结期

按 `created_at` 升序排列的冻结期分页列表。

先决条件：

- 你必须具有项目的报告者、开发者、维护者或所有者角色。

```plaintext
GET /projects/:id/freeze_periods
```

| 属性     | 类型           | 是否必需 | 描述                                                                         |
| ------------- | -------------- | -------- | ----------------------------------------------------------------------------------- |
| `id`          | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/19/freeze_periods"
```

示例响应：

```json
[
   {
      "id":1,
      "freeze_start":"0 23 * * 5",
      "freeze_end":"0 8 * * 1",
      "cron_timezone":"UTC",
      "created_at":"2020-05-15T17:03:35.702Z",
      "updated_at":"2020-05-15T17:06:41.566Z"
   }
]
```

<a id="retrieve-a-freeze-period"></a>

获取单个冻结期

获取指定 `freeze_period_id` 的冻结期。

先决条件：

- 你必须具有项目的报告者、开发者、维护者或所有者角色。

```plaintext
GET /projects/:id/freeze_periods/:freeze_period_id
```

| 属性     | 类型           | 是否必需 | 描述                                                                         |
| ------------- | -------------- | -------- | ----------------------------------------------------------------------------------- |
| `id`          | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `freeze_period_id`    | integer         | 是      | 冻结期的 ID。                                     |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/19/freeze_periods/1"
```

示例响应：

```json
{
   "id":1,
   "freeze_start":"0 23 * * 5",
   "freeze_end":"0 8 * * 1",
   "cron_timezone":"UTC",
   "created_at":"2020-05-15T17:03:35.702Z",
   "updated_at":"2020-05-15T17:06:41.566Z"
}
```

<a id="create-a-freeze-period"></a>

创建冻结期

为指定项目创建冻结期。

先决条件：

- 你必须具有项目的维护者或所有者角色。

```plaintext
POST /projects/:id/freeze_periods
```

| 属性          | 类型            | 是否必需                    | 描述                                                                                                                      |
| -------------------| --------------- | --------                    | -------------------------------------------------------------------------------------------------------------------------------- |
| `id`               | integer or string  | 是                         | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                              |
| `freeze_start`     | string          | 是                         | 冻结期开始时间，采用 [cron](https://crontab.guru/) 格式。                                                              |
| `freeze_end`       | string          | 是                         | 冻结期结束时间，采用 [cron](https://crontab.guru/) 格式。                                                                |
| `cron_timezone`    | string          | 否                          | cron 字段的时区，如果未提供则默认为 UTC。                                                               |

示例请求：

```shell
curl --request POST \
  --header 'Content-Type: application/json' \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data '{ "freeze_start": "0 23 * * 5", "freeze_end": "0 7 * * 1", "cron_timezone": "UTC" }' \
  --url "https://gitlab.example.com/api/v4/projects/19/freeze_periods"
```

示例响应：

```json
{
   "id":1,
   "freeze_start":"0 23 * * 5",
   "freeze_end":"0 7 * * 1",
   "cron_timezone":"UTC",
   "created_at":"2020-05-15T17:03:35.702Z",
   "updated_at":"2020-05-15T17:03:35.702Z"
}
```

<a id="update-a-freeze-period"></a>

更新冻结期

更新指定 `freeze_period_id` 的冻结期。

先决条件：

- 你必须具有项目的维护者或所有者角色。

```plaintext
PUT /projects/:id/freeze_periods/:freeze_period_id
```

| 属性     | 类型            | 是否必需 | 描述                                                                                                 |
| ------------- | --------------- | -------- | ----------------------------------------------------------------------------------------------------------- |
| `id`          | integer or string  | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                         |
| `freeze_period_id`    | integer          | 是      | 冻结期的 ID。                                                              |
| `freeze_start`     | string          | 否                         | 冻结期开始时间，采用 [cron](https://crontab.guru/) 格式。                                                              |
| `freeze_end`       | string          | 否                         | 冻结期结束时间，采用 [cron](https://crontab.guru/) 格式。                                                                |
| `cron_timezone`    | string          | 否                          | cron 字段的时区。                                                               |

示例请求：

```shell
curl --request PUT \
  --header 'Content-Type: application/json' \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data '{ "freeze_end": "0 8 * * 1" }' \
  --url "https://gitlab.example.com/api/v4/projects/19/freeze_periods/1"
```

示例响应：

```json
{
   "id":1,
   "freeze_start":"0 23 * * 5",
   "freeze_end":"0 8 * * 1",
   "cron_timezone":"UTC",
   "created_at":"2020-05-15T17:03:35.702Z",
   "updated_at":"2020-05-15T17:06:41.566Z"
}
```

<a id="delete-a-freeze-period"></a>

删除冻结期

删除指定 `freeze_period_id` 的冻结期。

先决条件：

- 你必须具有项目的维护者或所有者角色。

```plaintext
DELETE /projects/:id/freeze_periods/:freeze_period_id
```

| 属性     | 类型           | 是否必需 | 描述                                                                         |
| ------------- | -------------- | -------- | ----------------------------------------------------------------------------------- |
| `id`          | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `freeze_period_id`    | integer         | 是      | 冻结期的 ID。                                     |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/19/freeze_periods/1"
```