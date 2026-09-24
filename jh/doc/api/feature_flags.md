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

{{< history >}}

- 于极狐GitLab 专业版 12.5 引入。
- 于 13.5 移至极狐GitLab 基础版。

{{< /history >}}

使用此 API 与极狐GitLab [功能标志](../operations/feature_flags.md) 进行交互。

先决条件：

- 您必须具有开发者、维护者或所有者角色。

<a id="list-feature-flags-for-a-project"></a>

## 列出一个项目的功能标志

获取请求项目的所有功能标志。

```plaintext
GET /projects/:id/feature_flags
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination) 参数来控制结果的分页。

| 属性                  | 类型              | 是否必需 | 描述                                                                                                              |
| --------------------- | ---------------- | -------- | ----------------------------------------------------------------------------------------------------------------- |
| `id`                  | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                  |
| `scope`               | string           | 否       | 功能标志的条件，可选值为：`enabled`、`disabled`。                                                                |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
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

## 检索一个功能标志

检索指定功能标志。

```plaintext
GET /projects/:id/feature_flags/:feature_flag_name
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination) 参数来控制结果的分页。

| 属性                  | 类型              | 是否必需 | 描述                                                                                   |
| --------------------- | ---------------- | -------- | -------------------------------------------------------------------------------------- |
| `id`                  | integer 或 string | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                       |
| `feature_flag_name`   | string           | 是       | 功能标志的名称。                                                                       |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
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

## 创建一个功能标志

为指定项目创建一个功能标志。

```plaintext
POST /projects/:id/feature_flags
```

| 属性                                  | 类型                          | 是否必需 | 描述                                                                                                                                                                                                                                                        |
| ------------------------------------- | ----------------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`                                  | integer 或 string             | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                                                                                                                                                             |
| `name`                                | string                        | 是       | 功能标志的名称。                                                                                                                                                                                                                                            |
| `version`                             | string                        | 是       | **已弃用** 功能标志的版本。必须为 `new_version_flag`。省略以创建旧版功能标志。                                                                                                                                                                             |
| `description`                         | string                        | 否       | 功能标志的描述。                                                                                                                                                                                                                                            |
| `active`                              | boolean                       | 否       | 标志的启用状态。默认为 true。                                                                                                                                                                                                                               |
| `strategies`                          | strategy JSON 对象数组          | 否       | 功能标志的[策略](../operations/feature_flags.md#feature-flag-strategies)。                                                                                                                                                                                |
| `strategies:name`                     | JSON                          | 否       | 策略名称。可选值为 `default`、`gradualRolloutUserId`、`userWithId` 或 `gitlabUserList`。在 极狐GitLab 13.5 及之后版本中，也可以是 [`flexibleRollout`](https://docs.getunleash.io/user_guide/activation_strategy/#gradual-rollout)。                          |
| `strategies:parameters`               | JSON                          | 否       | 策略参数。                                                                                                                                                                                                                                                  |
| `strategies:scopes`                   | JSON                          | 否       | 策略的作用域。                                                                                                                                                                                                                                              |
| `strategies:scopes:environment_scope` | string                        | 否       | 作用域的环境作用域。                                                                                                                                                                                                                                        |
| `strategies:user_list_id`             | integer 或 string             | 否       | 功能标志用户列表的 ID。当策略为 `gitlabUserList` 时有效。                                                                                                                                                                                                 |

```shell
curl "https://gitlab.example.com/api/v4/projects/1/feature_flags" \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-type: application/json" \
     --data @- << EOF
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

## 更新一个功能标志

更新指定功能标志。

```plaintext
PUT /projects/:id/feature_flags/:feature_flag_name
```

| 属性                                  | 类型                          | 是否必需 | 描述                                                                                                                                |
| ------------------------------------- | ----------------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `id`                                  | integer 或 string             | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                                     |
| `feature_flag_name`                   | string                        | 是       | 功能标志的当前名称。                                                                                                                |
| `description`                         | string                        | 否       | 功能标志的描述。                                                                                                                    |
| `active`                              | boolean                       | 否       | 标志的启用状态。                                                                                                                    |
| `name`                                | string                        | 否       | 功能标志的新名称。                                                                                                                  |
| `strategies`                          | strategy JSON 对象数组          | 否       | 功能标志的[策略](../operations/feature_flags.md#feature-flag-strategies)。                                                         |
| `strategies:id`                       | JSON                          | 否       | 功能标志策略的 ID。                                                                                                                 |
| `strategies:name`                     | JSON                          | 否       | 策略名称。                                                                                                                          |
| `strategies:_destroy`                 | boolean                       | 否       | 当为 true 时删除该策略。                                                                                                            |
| `strategies:parameters`               | JSON                          | 否       | 策略参数。                                                                                                                          |
| `strategies:scopes`                   | JSON                          | 否       | 策略的作用域。                                                                                                                      |
| `strategies:scopes:id`                | JSON                          | 否       | 环境作用域的 ID。                                                                                                                   |
| `strategies:scopes:environment_scope` | string                        | 否       | 作用域的环境作用域。                                                                                                                |
| `strategies:scopes:_destroy`          | boolean                       | 否       | 当为 true 时删除该作用域。                                                                                                          |
| `strategies:user_list_id`             | integer 或 string             | 否       | 功能标志用户列表的 ID。当策略为 `gitlabUserList` 时有效。                                                                           |

```shell
curl "https://gitlab.example.com/api/v4/projects/1/feature_flags/awesome_feature" \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-type: application/json" \
     --data @- << EOF
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

## 删除一个功能标志

删除指定功能标志。

```plaintext
DELETE /projects/:id/feature_flags/:feature_flag_name
```

| 属性                  | 类型              | 是否必需 | 描述                                                                                   |
| --------------------- | ---------------- | -------- | -------------------------------------------------------------------------------------- |
| `id`                  | integer 或 string | 是       | 项目的 ID 或 [URL-编码路径](rest/_index.md#namespaced-paths)。                        |
| `feature_flag_name`   | string           | 是       | 功能标志的名称。                                                                       |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/feature_flags/awesome_feature"
```