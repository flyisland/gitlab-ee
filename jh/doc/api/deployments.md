---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 部署 API
---

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 对[极狐GitLab CI/CD 作业令牌](../ci/jobs/ci_job_token.md)认证的支持于 极狐GitLab 16.2 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/414549)。

{{< /history >}}

使用此 API 与 极狐GitLab 环境的[代码部署](../ci/environments/deployments.md)进行交互。

## 列出所有项目部署

<a id="list-all-project-deployments"></a>

列出项目中的所有部署。

```plaintext
GET /projects/:id/deployments
```

| 属性          | 类型           | 是否必需 | 描述                                                                                                                  |
|---------------|----------------|----------|-----------------------------------------------------------------------------------------------------------------------|
| `id`          | integer or string | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。                                              |
| `order_by`    | string         | 否       | 返回按 `id`、`iid`、`created_at`、`updated_at`、`finished_at` 或 `ref` 字段之一排序的部署。默认为 `id`。 |
| `sort`        | string         | 否       | 返回按 `asc` 或 `desc` 排序的部署。默认为 `asc`。                                                                       |
| `updated_after` | datetime       | 否       | 返回在指定日期之后更新的部署。应为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。                                          |
| `updated_before`| datetime       | 否       | 返回在指定日期之前更新的部署。应为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。                                          |
| `finished_after`| datetime       | 否       | 返回在指定日期之后完成的部署。应为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。                                          |
| `finished_before`| datetime       | 否       | 返回在指定日期之前完成的部署。应为 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。                                          |
| `environment`  | string         | 否       | 用于筛选部署的[环境名称](../ci/environments/_index.md)。                                                               |
| `status`       | string         | 否       | 用于筛选部署的状态。可选值：`created`、`running`、`success`、`failed`、`canceled` 或 `blocked`。                       |

```shell
curl --request "GET" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/deployments"
```

> [!note]
> 当使用 `finished_before` 或 `finished_after` 时，您应该将 `order_by` 指定为 `finished_at`，并且 `status` 应为 `success`。

响应示例：

```json
[
  {
    "created_at": "2016-08-11T07:36:40.222Z",
    "updated_at": "2016-08-11T07:38:12.414Z",
    "status": "created",
    "deployable": {
      "commit": {
        "author_email": "admin@example.com",
        "author_name": "Administrator",
        "created_at": "2016-08-11T09:36:01.000+02:00",
        "id": "99d03678b90d914dbb1b109132516d71a4a03ea8",
        "message": "Merge branch 'new-title' into 'main'\r\n\r\nUpdate README\r\n\r\n\r\n\r\nSee merge request !1",
        "short_id": "99d03678",
        "title": "Merge branch 'new-title' into 'main'\r"
      },
      "coverage": null,
      "created_at": "2016-08-11T07:36:27.357Z",
      "finished_at": "2016-08-11T07:36:39.851Z",
      "id": 657,
      "name": "deploy",
      "ref": "main",
      "runner": null,
      "stage": "deploy",
      "started_at": null,
      "status": "success",
      "tag": false,
      "project": {
        "ci_job_token_scope_enabled": false
      },
      "user": {
        "id": 1,
        "name": "Administrator",
        "username": "root",
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
        "web_url": "http://gitlab.dev/root",
        "created_at": "2015-12-21T13:14:24.077Z",
        "bio": null,
        "location": null,
        "public_email": "",
        "linkedin": "",
        "twitter": "",
        "website_url": "",
        "organization": ""
      },
      "pipeline": {
        "created_at": "2016-08-11T02:12:10.222Z",
        "id": 36,
        "ref": "main",
        "sha": "99d03678b90d914dbb1b109132516d71a4a03ea8",
        "status": "success",
        "updated_at": "2016-08-11T02:12:10.222Z",
        "web_url": "http://gitlab.dev/root/project/pipelines/12"
      }
    },
    "environment": {
      "external_url": "https://gitlab.cn",
      "id": 9,
      "name": "production"
    },
    "id": 41,
    "iid": 1,
    "ref": "main",
    "sha": "99d03678b90d914dbb1b109132516d71a4a03ea8",
    "user": {
      "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "id": 1,
      "name": "Administrator",
      "state": "active",
      "username": "root",
      "web_url": "http://localhost:3000/root"
    }
  },
  {
    "created_at": "2016-08-11T11:32:35.444Z",
    "updated_at": "2016-08-11T11:34:01.123Z",
    "status": "created",
    "deployable": {
      "commit": {
        "author_email": "admin@example.com",
        "author_name": "Administrator",
        "created_at": "2016-08-11T13:28:26.000+02:00",
        "id": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
        "message": "Merge branch 'rename-readme' into 'main'\r\n\r\nRename README\r\n\r\n\r\n\r\nSee merge request !2",
        "short_id": "a91957a8",
        "title": "Merge branch 'rename-readme' into 'main'\r"
      },
      "coverage": null,
      "created_at": "2016-08-11T11:32:24.456Z",
      "finished_at": "2016-08-11T11:32:35.145Z",
      "id": 664,
      "name": "deploy",
      "ref": "main",
      "runner": null,
      "stage": "deploy",
      "started_at": null,
      "status": "success",
      "tag": false,
      "project": {
        "ci_job_token_scope_enabled": false
      },
      "user": {
        "id": 1,
        "name": "Administrator",
        "username": "root",
        "state": "active",
        "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
        "web_url": "http://gitlab.dev/root",
        "created_at": "2015-12-21T13:14:24.077Z",
        "bio": null,
        "location": null,
        "public_email": "",
        "linkedin": "",
        "twitter": "",
        "website_url": "",
        "organization": ""
      },
      "pipeline": {
        "created_at": "2016-08-11T07:43:52.143Z",
        "id": 37,
        "ref": "main",
        "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
        "status": "success",
        "updated_at": "2016-08-11T07:43:52.143Z",
        "web_url": "http://gitlab.dev/root/project/pipelines/13"
      }
    },
    "environment": {
      "external_url": "https://gitlab.cn",
      "id": 9,
      "name": "production"
    },
    "id": 42,
    "iid": 2,
    "ref": "main",
    "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
    "user": {
      "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "id": 1,
      "name": "Administrator",
      "state": "active",
      "username": "root",
      "web_url": "http://localhost:3000/root"
    }
  }
]
```

## 获取单个部署

<a id="retrieve-a-deployment"></a>

获取单个部署。

```plaintext
GET /projects/:id/deployments/:deployment_id
```

| 属性 | 类型    | 是否必需 | 描述         |
|-----------|---------|----------|---------------------|
| `id`      | integer or string | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `deployment_id` | integer | 是      | 部署的 ID。 |

```shell
curl --request "GET" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/deployments/1"
```

响应示例：

```json
{
  "id": 42,
  "iid": 2,
  "ref": "main",
  "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
  "created_at": "2016-08-11T11:32:35.444Z",
  "updated_at": "2016-08-11T11:34:01.123Z",
  "status": "success",
  "user": {
    "name": "Administrator",
    "username": "root",
    "id": 1,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://localhost:3000/root"
  },
  "environment": {
    "id": 9,
    "name": "production",
    "external_url": "https://gitlab.cn"
  },
  "deployable": {
    "id": 664,
    "status": "success",
    "stage": "deploy",
    "name": "deploy",
    "ref": "main",
    "tag": false,
    "coverage": null,
    "created_at": "2016-08-11T11:32:24.456Z",
    "started_at": null,
    "finished_at": "2016-08-11T11:32:35.145Z",
    "project": {
      "ci_job_token_scope_enabled": false
    },
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "http://gitlab.dev/root",
      "created_at": "2015-12-21T13:14:24.077Z",
      "bio": null,
      "location": null,
      "linkedin": "",
      "twitter": "",
      "website_url": "",
      "organization": ""
    },
    "commit": {
      "id": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
      "short_id": "a91957a8",
      "title": "Merge branch 'rename-readme' into 'main'\r",
      "author_name": "Administrator",
      "author_email": "admin@example.com",
      "created_at": "2016-08-11T13:28:26.000+02:00",
      "message": "Merge branch 'rename-readme' into 'main'\r\n\r\nRename README\r\n\r\n\r\n\r\nSee merge request !2"
    },
    "pipeline": {
      "created_at": "2016-08-11T07:43:52.143Z",
      "id": 42,
      "ref": "main",
      "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
      "status": "success",
      "updated_at": "2016-08-11T07:43:52.143Z",
      "web_url": "http://gitlab.dev/root/project/pipelines/5"
    },
    "runner": null
  }
}
```

当配置了[多重审批规则](../ci/environments/deployment_approvals.md#add-multiple-approval-rules)时，由 极狐GitLab 专业版或旗舰版用户创建的部署会包含 `approval_summary` 属性：

```json
{
  "approval_summary": {
    "rules": [
      {
        "user_id": null,
        "group_id": 134,
        "access_level": null,
        "access_level_description": "qa-group",
        "required_approvals": 1,
        "deployment_approvals": []
      },
      {
        "user_id": null,
        "group_id": 135,
        "access_level": null,
        "access_level_description": "security-group",
        "required_approvals": 2,
        "deployment_approvals": [
          {
            "user": {
              "id": 100,
              "username": "security-user-1",
              "name": "security user-1",
              "state": "active",
              "avatar_url": "https://www.gravatar.com/avatar/e130fcd3a1681f41a3de69d10841afa9?s=80&d=identicon",
              "web_url": "http://localhost:3000/security-user-1"
            },
            "status": "approved",
            "created_at": "2022-04-11T03:37:03.058Z",
            "comment": null
          }
        ]
      }
    ]
  }
  ...
}
```

## 创建部署

<a id="create-a-deployment"></a>

创建一个部署。

```plaintext
POST /projects/:id/deployments
```

| 属性         | 类型           | 是否必需 | 描述                                                                                                 |
|---------------|----------------|----------|-----------------------------------------------------------------------------------------------------|
| `id`          | integer or string | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。                                   |
| `environment` | string         | 是      | 要为其创建部署的[环境名称](../ci/environments/_index.md)。                                                |
| `sha`         | string         | 是      | 被部署的提交的 SHA。                                                                                  |
| `ref`         | string         | 是      | 被部署的分支或标签的名称。                                                                          |
| `tag`         | boolean        | 是      | 一个布尔值，指示被部署的引用是否为标签（`true` 是，`false` 否）。                                  |
| `status`      | string         | 是      | 创建的部署的状态。可选值：`running`、`success`、`failed` 或 `canceled`。                       |

```shell
curl --request "POST" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "environment=production&sha=a91957a858320c0e17f3a0eca7cfacbff50ea29a&ref=main&tag=false&status=success" \
  --url "https://gitlab.example.com/api/v4/projects/1/deployments"
```

响应示例：

```json
{
  "id": 42,
  "iid": 2,
  "ref": "main",
  "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
  "created_at": "2016-08-11T11:32:35.444Z",
  "status": "success",
  "user": {
    "name": "Administrator",
    "username": "root",
    "id": 1,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://localhost:3000/root"
  },
  "environment": {
    "id": 9,
    "name": "production",
    "external_url": "https://gitlab.cn"
  },
  "deployable": null
}
```

由 极狐GitLab 专业版或旗舰版用户创建的部署包含 `approvals` 和 `pending_approval_count` 属性：

```json
{
  "status": "created",
  "pending_approval_count": 0,
  "approvals": [],
  ...
}
```

## 更新部署

<a id="update-a-deployment"></a>

更新一个部署。

```plaintext
PUT /projects/:id/deployments/:deployment_id
```

| 属性           | 类型           | 是否必需 | 描述                                                                                    |
|------------------|----------------|----------|----------------------------------------------------------------------------------------|
| `id`             | integer or string | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。                       |
| `deployment_id`  | integer        | 是      | 要更新的部署的 ID。                                                                       |
| `status`         | string         | 是      | 部署的新状态。可选值：`running`、`success`、`failed` 或 `canceled`。                  |

```shell
curl --request "PUT" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "status=success" \
  --url "https://gitlab.example.com/api/v4/projects/1/deployments/42"
```

响应示例：

```json
{
  "id": 42,
  "iid": 2,
  "ref": "main",
  "sha": "a91957a858320c0e17f3a0eca7cfacbff50ea29a",
  "created_at": "2016-08-11T11:32:35.444Z",
  "status": "success",
  "user": {
    "name": "Administrator",
    "username": "root",
    "id": 1,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://localhost:3000/root"
  },
  "environment": {
    "id": 9,
    "name": "production",
    "external_url": "https://gitlab.cn"
  },
  "deployable": null
}
```

由 极狐GitLab 专业版或旗舰版用户创建的部署包含 `approvals` 和 `pending_approval_count` 属性：

```json
{
  "status": "created",
  "pending_approval_count": 0,
  "approvals": [
    {
      "user": {
        "id": 49,
        "username": "project_6_bot",
        "name": "****",
        "state": "active",
        "avatar_url": "https://www.gravatar.com/avatar/e83ac685f68ea07553ad3054c738c709?s=80&d=identicon",
        "web_url": "http://localhost:3000/project_6_bot"
      },
      "status": "approved",
      "created_at": "2022-02-24T20:22:30.097Z",
      "comment": "Looks good to me"
    }
  ],
  ...
}
```

## 删除部署

<a id="delete-a-deployment"></a>

删除指定的部署，该部署不能是环境的当前最新部署，也不能处于 `running` 状态。

```plaintext
DELETE /projects/:id/deployments/:deployment_id
```

| 属性 | 类型    | 是否必需 | 描述         |
|-----------|---------|----------|---------------------|
| `id`      | integer or string | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `deployment_id` | integer | 是      | 部署的 ID。 |

```shell
curl --request "DELETE" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/deployments/1"
```

响应示例：

```json
{ "message": "204 Deployment destroyed" }
```

```json
{ "message": "403 Forbidden" }
```

```json
{ "message": "400 Cannot destroy running deployment" }
```

```json
{ "message": "400 Deployment currently deployed to environment" }
```

## 列出与部署关联的所有合并请求

<a id="list-all-merge-requests-associated-with-a-deployment"></a>

> [!note]
> 并非所有部署都可以关联合并请求。更多信息请参考
> [追踪部署到环境的合并请求](../ci/environments/deployments.md#track-newly-included-merge-requests-per-deployment)。

列出随指定部署一起发布的所有合并请求。

```plaintext
GET /projects/:id/deployments/:deployment_id/merge_requests
```

它支持与[合并请求 API](merge_requests.md#list-merge-requests) 相同的参数，并使用相同的格式返回响应：

```shell
curl --request "GET" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/deployments/42/merge_requests"
```

## 批准或拒绝部署

<a id="approve-or-reject-a-deployment"></a>

批准或拒绝一个部署。

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 于 极狐GitLab 14.7 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/343864)，带有名为 `deployment_approvals` 的[功能标志](../administration/feature_flags/_index.md)。默认禁用。
- 于 极狐GitLab 14.8 [移除功能标志](https://gitlab.com/gitlab-org/gitlab/-/issues/347342)。

{{< /history >}}

有关此功能的更多信息，请参见[部署审批](../ci/environments/deployment_approvals.md)。

```plaintext
POST /projects/:id/deployments/:deployment_id/approval
```

| 属性          | 类型           | 是否必需 | 描述                                                                                                 |
|---------------|----------------|----------|-----------------------------------------------------------------------------------------------------|
| `id`            | integer or string | 是      | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。                      |
| `deployment_id` | integer        | 是      | 部署的 ID。                                                                                         |
| `status`        | string         | 是      | 审批的状态（`approved` 或 `rejected`）。                  |
| `comment`       | string         | 否       | 随审批一起提交的评论。                                                                               |
| `represented_as`| string         | 否       | 当用户属于[多重审批规则](../ci/environments/deployment_approvals.md#add-multiple-approval-rules)时，用于审批的用户/群组/角色的名称。 |

```shell
curl --request "POST" \
  --data "status=approved&comment=Looks good to me&represented_as=security" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/deployments/1/approval"
```

响应示例：

```json
{
  "user": {
    "id": 100,
    "username": "security-user-1",
    "name": "security user-1",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/e130fcd3a1681f41a3de69d10841afa9?s=80&d=identicon",
    "web_url": "http://localhost:3000/security-user-1"
  },
  "status": "approved",
  "created_at": "2022-02-24T20:22:30.097Z",
  "comment":"Looks good to me"
}
```