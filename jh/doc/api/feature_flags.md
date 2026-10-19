---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 功能标志 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与极狐GitLab [功能标志](../operations/feature_flags.md)交互。

先决条件：

- 您必须具有开发者、维护者或所有者角色。

<a id="list-feature-flags-for-a-project"></a>

## 列出项目的功能标志

获取所请求项目的所有功能标志。

```plaintext
GET /projects/:id/feature_flags
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination)参数来控制结果的分页。

| 属性           | 类型             | 是否必需   | 描述                                                                                                                 |
| ------------------- | ---------------- | ---------- | --------------------------------------------------------------------------------------------------------------------------- |
| `id`                | integer or string   | 是        | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                            |
| `scope`             | string           | 否         | 功能标志的条件，取值为：`enabled`、`disabled` 之一。                                                              |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/feature_flags"
```

示例响应：

```json
[
   {
      "name":"merge_train",
      "description":"This feature is about merge train",
      "active": true,
      "version": "new_version_flag",
      "created_at":"2019-11-04T08:13:51.423Z",
      "updated_at":"2019-11-04T08:13:51.423Z",
      "scopes":[],
      "strategies": [
        {
          "id": 1,
          "name": "userWithId",
          "parameters": {
            "userIds": "user1"
          },
          "scopes": [
            {
              "id": 1,
              "environment_scope": "production"
            }
          ],
          "user_list": null
        }
      ]
   },
   {
      "name":"new_live_trace",
      "description":"This is a new live trace feature",
      "active": true,
      "version": "new_version_flag",
      "created_at":"2019-11-04T08:13:10.507Z",
      "updated_at":"2019-11-04T08:13:10.507Z",
      "scopes":[],
      "strategies": [
        {
          "id": 2,
          "name": "default",
          "parameters": {},
          "scopes": [
            {
              "id": 2,
              "environment_scope": "staging"
            }
          ],
          "user_list": null
        }
      ]
   },
   {
      "name":"user_list",
      "description":"This feature is about user list",
      "active": true,
      "version": "new_version_flag",
      "created_at":"2019-11-04T08:13:10.507Z",
      "updated_at":"2019-11-04T08:13:10.507Z",
      "scopes":[],
      "strategies": [
        {
          "id": 2,
          "name": "gitlabUserList",
          "parameters": {},
          "scopes": [
            {
              "id": 2,
              "environment_scope": "staging"
            }
          ],
          "user_list": {
            "id": 1,
            "iid": 1,
            "name": "My user list",
            "user_xids": "user1,user2,user3"
          }
        }
      ]
   }
]
```

<a id="retrieve-a-feature-flag"></a>

## 检索功能标志

检索指定的功能标志。

```plaintext
GET /projects/:id/feature_flags/:feature_flag_name
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination)参数来控制结果的分页。

| 属性           | 类型             | 是否必需   | 描述                                                                            |
| ------------------- | ---------------- | ---------- | ---------------------------------------------------------------------------------------|
| `id`                | integer or string   | 是        | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。       |
| `feature_flag_name` | string           | 是        | 功能标志的名称。                                                          |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/feature_flags/awesome_feature"
```

示例响应：

```json
{
  "name": "awesome_feature",
  "description": null,
  "active": true,
  "version": "new_version_flag",
  "created_at": "2020-05-13T19:56:33.119Z",
  "updated_at": "2020-05-13T19:56:33.119Z",
  "scopes": [],
  "strategies": [
    {
      "id": 36,
      "name": "default",
      "parameters": {},
      "scopes": [
        {
          "id": 37,
          "environment_scope": "production"
        }
      ],
      "user_list": null
    }
  ]
}
```

<a id="create-a-feature-flag"></a>

## 创建功能标志

为指定项目创建功能标志。

```plaintext
POST /projects/:id/feature_flags
```

| 属性           | 类型             | 是否必需   | 描述                                                                                                                                                                                                                                                                              |
| ------------------- | ---------------- | ---------- |------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `id`                | integer or string   | 是        | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                                                                                                                                                                     |
| `name`              | string           | 是        | 功能标志的名称。                                                                                                                                                                                                                                                            |
| `version`           | string           | 是        | **已弃用**功能标志的版本。必须为 `new_version_flag`。省略此项将创建旧版功能标志。                                                                                                                                                                        |
| `description`       | string           | 否         | 功能标志的描述。                                                                                                                                                                                                                                                     |
| `active`            | boolean          | 否         | 功能标志的激活状态。默认为 true。                                                                                                                                                                                                                                          |
| `strategies`        | array of strategy JSON objects | 否         | 功能标志[策略](../operations/feature_flags.md#feature-flag-strategies)。                                                                                                                                                                                     |
| `strategies:name`   | JSON             | 否         | 策略名称。可以是 `default`、`gradualRolloutUserId`、`userWithId`、`gitlabUserList` 或 [`flexibleRollout`](https://docs.getunleash.io/reference/activation-strategies#gradual-rollout)。 |
| `strategies:parameters` | JSON         | 否         | 策略参数。                                                                                                                                                                                                                                                                 |
| `strategies:scopes` | JSON             | 否         | 策略的作用域。                                                                                                                                                                                                                                                             |
| `strategies:scopes:environment_scope` | string | 否 | 作用域的环境作用域。                                                                                                                                                                                                                                                      |
| `strategies:user_list_id` | integer or string | 否     | 功能标志用户列表的 ID。当策略为 `gitlabUserList` 时使用。                                                                                                                                                                                                                   |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-type: application/json" \
  --data @- \
  --url "https://gitlab.example.com/api/v4/projects/1/feature_flags" << EOF
{
  "name": "awesome_feature",
  "version": "new_version_flag",
  "strategies": [{ "name": "default", "parameters": {}, "scopes": [{ "environment_scope": "production" }] }]
}
EOF
```

示例响应：

```json
{
  "name": "awesome_feature",
  "description": null,
  "active": true,
  "version": "new_version_flag",
  "created_at": "2020-05-13T19:56:33.119Z",
  "updated_at": "2020-05-13T19:56:33.119Z",
  "scopes": [],
  "strategies": [
    {
      "id": 36,
      "name": "default",
      "parameters": {},
      "scopes": [
        {
          "id": 37,
          "environment_scope": "production"
        }
      ]
    }
  ]
}
```

<a id="update-a-feature-flag"></a>

## 更新功能标志

更新指定的功能标志。

```plaintext
PUT /projects/:id/feature_flags/:feature_flag_name
```

| 属性           | 类型             | 是否必需   | 描述                                                                            |
| ------------------- | ---------------- | ---------- | ---------------------------------------------------------------------------------------|
| `id`                | integer or string   | 是        | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。   |
| `feature_flag_name` | string           | 是        | 功能标志的当前名称。                                                  |
| `description`       | string           | 否         | 功能标志的描述。                                                   |
| `active`            | boolean          | 否         | 标志的激活状态。                                                          |
| `name`              | string           | 否         | 功能标志的新名称。                                                      |
| `strategies`        | array of strategy JSON objects | 否         | 功能标志[策略](../operations/feature_flags.md#feature-flag-strategies)。 |
| `strategies:id`     | JSON             | 否         | 功能标志策略 ID。                                                          |
| `strategies:name`   | JSON             | 否         | 策略名称。                                                                     |
| `strategies:_destroy` | boolean         | 否         | 为 true 时删除该策略。                                                        |
| `strategies:parameters` | JSON         | 否         | 策略参数。                                                               |
| `strategies:scopes` | JSON             | 否         | 策略的作用域。                                                           |
| `strategies:scopes:id` | JSON          | 否         | 环境作用域 ID。                                                              |
| `strategies:scopes:environment_scope` | string | 否 | 作用域的环境作用域。                                                    |
| `strategies:scopes:_destroy` | boolean | 否 | 为 true 时删除该作用域。                                                                    |
| `strategies:user_list_id` | integer or string | 否     | 功能标志用户列表的 ID。当策略为 `gitlabUserList` 时使用。                 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-type: application/json" \
  --data @- \
  --url "https://gitlab.example.com/api/v4/projects/1/feature_flags/awesome_feature" << EOF
{
  "strategies": [{ "name": "gradualRolloutUserId", "parameters": { "groupId": "default", "percentage": "25" }, "scopes": [{ "environment_scope": "staging" }] }]
}
EOF
```

示例响应：

```json
{
  "name": "awesome_feature",
  "description": null,
  "active": true,
  "version": "new_version_flag",
  "created_at": "2020-05-13T20:10:32.891Z",
  "updated_at": "2020-05-13T20:10:32.891Z",
  "scopes": [],
  "strategies": [
    {
      "id": 38,
      "name": "gradualRolloutUserId",
      "parameters": {
        "groupId": "default",
        "percentage": "25"
      },
      "scopes": [
        {
          "id": 40,
          "environment_scope": "staging"
        }
      ]
    },
    {
      "id": 37,
      "name": "default",
      "parameters": {},
      "scopes": [
        {
          "id": 39,
          "environment_scope": "production"
        }
      ]
    }
  ]
}
```

<a id="delete-a-feature-flag"></a>

## 删除功能标志

删除指定的功能标志。

```plaintext
DELETE /projects/:id/feature_flags/:feature_flag_name
```

| 属性           | 类型             | 是否必需   | 描述                                                                            |
| ------------------- | ---------------- | ---------- | ---------------------------------------------------------------------------------------|
| `id`                | integer or string   | 是        | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。       |
| `feature_flag_name` | string           | 是        | 功能标志的名称。                                                          |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/feature_flags/awesome_feature"
```

<a id="retrieve-feature-flag-settings"></a>

## 检索功能标志设置

> [!flag]
> `feature_flag_management_permissions` 功能标志控制 `minimum_role`的强制执行，但不控制对此端点的访问。

检索指定项目的功能标志设置。

```plaintext
GET /projects/:id/feature_flags_settings
```

| 属性 | 类型              | 是否必需 | 描述                                                                   |
| --------- | ----------------- | -------- | ----------------------------------------------------------------------------- |
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/feature_flags_settings"
```

示例响应：

```json
{
   "minimum_role": "developer"
}
```

<a id="update-feature-flag-settings"></a>

## 更新功能标志设置

> [!flag]
> `feature_flag_management_permissions` 功能标志控制 `minimum_role`的强制执行，但不控制对此端点的访问。

更新指定项目的功能标志设置。

先决条件：

- 您必须至少具有该项目的维护者角色。
- 要将 `minimum_role` 从 `owner` 或 `no_one_allowed` 改为其他值，您必须具有该项目的所有者角色。

```plaintext
PUT /projects/:id/feature_flags_settings
```

| 属性      | 类型              | 是否必需 | 描述                                                                                                                          |
| -------------- | ----------------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------|
| `id`           | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                        |
| `minimum_role` | string            | 是      | 管理功能标志所需的最低角色。取值为 `no_one_allowed`、`developer`、`maintainer` 或 `owner` 之一。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/feature_flags_settings?minimum_role=maintainer"
```

示例响应：

```json
{
   "minimum_role": "maintainer"
}
```

有关每个值的含义，请参见[限制谁可以管理功能标志](../operations/feature_flags.md#restrict-who-can-manage-feature-flags)。
