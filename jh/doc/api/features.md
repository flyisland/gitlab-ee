---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 功能标志 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

该 API 用于管理 极狐GitLab 开发中使用的基于 Flipper 的功能标志。

所有方法都需要管理员授权。

请注意，该 API 仅支持布尔值和按时间百分比的门控值。

<a id="list-all-feature-flags"></a>

列出所有功能标志

列出所有持久化的功能标志及其门控值。

```plaintext
GET /features
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/features"
```

示例响应：

```json
[
  {
    "name": "experimental_feature",
    "state": "off",
    "gates": [
      {
        "key": "boolean",
        "value": false
      }
    ],
    "definition": null
  },
  {
    "name": "my_user_feature",
    "state": "on",
    "gates": [
      {
        "key": "percentage_of_actors",
        "value": 34
      }
    ],
    "definition": {
      "name": "my_user_feature",
      "introduced_by_url": "https://gitlab.com/gitlab-org/gitlab/-/merge_requests/40880",
      "rollout_issue_url": "https://gitlab.com/gitlab-org/gitlab/-/issues/244905",
      "group": "group::ci",
      "type": "development",
      "default_enabled": false
    }
  },
  {
    "name": "new_library",
    "state": "on",
    "gates": [
      {
        "key": "boolean",
        "value": true
      }
    ],
    "definition": null
  }
]
```

<a id="list-all-feature-flag-definitions"></a>

列出所有功能标志定义

列出所有功能标志定义。

```plaintext
GET /features/definitions
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/features/definitions"
```

示例响应：

```json
[
  {
    "name": "geo_pages_deployment_replication",
    "introduced_by_url": "https://gitlab.com/gitlab-org/gitlab/-/merge_requests/68662",
    "rollout_issue_url": "https://gitlab.com/gitlab-org/gitlab/-/issues/337676",
    "milestone": "14.3",
    "log_state_changes": null,
    "type": "development",
    "group": "group::geo",
    "default_enabled": true
  }
]
```

<a id="create-or-update-a-feature-flag"></a>

创建或更新功能标志

创建或更新功能标志的门控值。如果指定名称的功能标志尚不存在，则会创建它。值可以是布尔值，也可以是一个表示时间百分比的整数。

> [!warning]
> 在启用仍在开发中的功能之前，您应该了解[安全和稳定性风险](../administration/feature_flags/_index.md#risks-when-enabling-features-still-in-development)。

```plaintext
POST /features/:name
```

| 属性       | 类型           | 是否必需 | 描述                                                                                                                                                                                      |
|-----------------|----------------|----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `name`          | string         | 是      | 要创建或更新的功能名称                                                                                                                                                          |
| `value`         | integer 或 string | 是      | `true` 或 `false` 来启用/禁用，或一个表示时间百分比的整数                                                                                                                        |
| `key`           | string         | 否       | `percentage_of_actors` 或 `percentage_of_time`（默认）                                                                                                                                         |
| `feature_group` | string         | 否       | 功能群组名称                                                                                                                                                                             |
| `user`          | string         | 否       | 极狐GitLab 用户名，或以逗号分隔的多个用户名                                                                                                                                          |
| `group`         | string         | 否       | 极狐GitLab 群组路径，例如 `gitlab-org`，或以逗号分隔的多个群组路径                                                                                                         |
| `namespace`     | string         | 否       | 极狐GitLab 群组或用户命名空间路径，例如 `john-doe`，或以逗号分隔的多个命名空间路径。在 极狐GitLab 15.0 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/353117)。 |
| `project`       | string         | 否       | 项目路径，例如 `gitlab-org/gitlab-foss`，或以逗号分隔的多个项目路径                                                                                                 |
| `repository`    | string         | 否       | 仓库路径，例如 `gitlab-org/gitlab-test.git`、`gitlab-org/gitlab-test.wiki.git`、`snippets/21.git` 等。使用逗号分隔多个仓库路径              |
| `runner`        | string         | 否       | Runner ID，或以逗号分隔的 Runner ID 列表                                                                                                                                               |
| `force`         | boolean        | 否       | 跳过功能标志验证检查，例如 YAML 定义                                                                                                                                   |

您可以在一次 API 调用中为 `feature_group`、`user`、`group`、`namespace`、`project`、`repository` 和 `runner` 启用或禁用功能。

```shell
curl --request POST \
  --data "value=30" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/features/new_library"
```

示例响应：

```json
{
  "name": "new_library",
  "state": "conditional",
  "gates": [
    {
      "key": "boolean",
      "value": false
    },
    {
      "key": "percentage_of_time",
      "value": 30
    }
  ],
  "definition": {
    "name": "my_user_feature",
    "introduced_by_url": "https://gitlab.com/gitlab-org/gitlab/-/merge_requests/40880",
    "rollout_issue_url": "https://gitlab.com/gitlab-org/gitlab/-/issues/244905",
    "group": "group::ci",
    "type": "development",
    "default_enabled": false
  }
}
```

<a id="set-percentage-of-actors-rollout"></a>

设置参与者百分比发布

按参与者百分比发布。

```plaintext
POST https://gitlab.example.com/api/v4/features/my_user_feature?private_token=<your_access_token>
Content-Type: application/x-www-form-urlencoded
value=42&key=percentage_of_actors&
```

示例响应：

```json
{
  "name": "my_user_feature",
  "state": "conditional",
  "gates": [
    {
      "key": "boolean",
      "value": false
    },
    {
      "key": "percentage_of_actors",
      "value": 42
    }
  ],
  "definition": {
    "name": "my_user_feature",
    "introduced_by_url": "https://gitlab.com/gitlab-org/gitlab/-/merge_requests/40880",
    "rollout_issue_url": "https://gitlab.com/gitlab-org/gitlab/-/issues/244905",
    "group": "group::ci",
    "type": "development",
    "default_enabled": false
  }
}
```

将 `my_user_feature` 发布到 `42%` 的参与者。

<a id="delete-a-feature"></a>

删除功能

删除功能标志门控。无论功能标志是否存在，都会返回相同的响应。

```plaintext
DELETE /features/:name
```