---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 流水线触发令牌 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API [触发流水线](../ci/triggers/_index.md)。

<a id="list-project-trigger-tokens"></a>

## 列出项目触发令牌

列出一个项目的流水线触发令牌。

```plaintext
GET /projects/:id/triggers
```

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/triggers"
```

```json
[
    {
        "id": 10,
        "description": "my trigger",
        "created_at": "2016-01-07T09:53:58.235Z",
        "last_used": null,
        "token": "6d056f63e50fe6f8c5f8f4aa10edb7",
        "updated_at": "2016-01-07T09:53:58.235Z",
        "owner": null
    }
]
```

如果触发令牌是由已认证用户创建的，则会显示完整的触发令牌。由其他用户创建的触发令牌会缩短为四个字符。

<a id="retrieve-trigger-token-details"></a>

## 获取触发令牌详情

获取一个项目的流水线触发令牌的详细信息。

```plaintext
GET /projects/:id/triggers/:trigger_id
```

| 属性    | 类型           | 是否必需 | 描述 |
|--------------|----------------|----------|-------------|
| `id`         | 整数或字符串 | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `trigger_id` | 整数        | 是      | 触发 ID |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/triggers/5"
```

```json
{
    "id": 10,
    "description": "my trigger",
    "created_at": "2016-01-07T09:53:58.235Z",
    "last_used": null,
    "token": "6d056f63e50fe6f8c5f8f4aa10edb7",
    "updated_at": "2016-01-07T09:53:58.235Z",
    "owner": null
}
```

<a id="create-a-trigger-token"></a>

## 创建触发令牌

为项目创建流水线触发令牌。

```plaintext
POST /projects/:id/triggers
```

| 属性     | 类型           | 是否必需 | 描述 |
|---------------|----------------|----------|-------------|
| `description` | 字符串         | 是      | 触发名称 |
| `id`          | 整数或字符串 | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form description="my description" \
  --url "https://gitlab.example.com/api/v4/projects/1/triggers"
```

```json
{
    "id": 10,
    "description": "my trigger",
    "created_at": "2016-01-07T09:53:58.235Z",
    "last_used": null,
    "token": "6d056f63e50fe6f8c5f8f4aa10edb7",
    "updated_at": "2016-01-07T09:53:58.235Z",
    "owner": null
}
```

<a id="update-a-pipeline-trigger-token"></a>

## 更新流水线触发令牌

更新项目的流水线触发令牌。

```plaintext
PUT /projects/:id/triggers/:trigger_id
```

| 属性     | 类型           | 是否必需 | 描述 |
|---------------|----------------|----------|-------------|
| `id`          | 整数或字符串 | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `trigger_id`  | 整数        | 是      | 触发 ID |
| `description` | 字符串         | 否       | 触发名称 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form description="my description" \
  --url "https://gitlab.example.com/api/v4/projects/1/triggers/10"
```

```json
{
    "id": 10,
    "description": "my trigger",
    "created_at": "2016-01-07T09:53:58.235Z",
    "last_used": null,
    "token": "6d056f63e50fe6f8c5f8f4aa10edb7",
    "updated_at": "2016-01-07T09:53:58.235Z",
    "owner": null
}
```

<a id="delete-a-pipeline-trigger-token"></a>

## 删除流水线触发令牌

删除项目的流水线触发令牌。

```plaintext
DELETE /projects/:id/triggers/:trigger_id
```

| 属性    | 类型           | 是否必需 | 描述 |
|--------------|----------------|----------|-------------|
| `id`         | 整数或字符串 | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths) |
| `trigger_id` | 整数        | 是      | 触发 ID |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/triggers/5"
```

<a id="trigger-a-pipeline-with-a-token"></a>

## 使用令牌触发流水线

{{< history >}}

- `inputs` 属性在 极狐GitLab 17.10 引入，带有名为 `ci_inputs_for_pipelines` 的功能标志。默认禁用。
- `inputs` 属性在 极狐GitLab 17.11 中已在 JihuLab.com 和私有化部署上启用。
- `inputs` 属性在 极狐GitLab 18.1 GA。功能标志 `ci_inputs_for_pipelines` 已移除。

{{< /history >}}

使用[流水线触发令牌](../ci/triggers/_index.md#create-a-pipeline-trigger-token)或 [CI/CD 作业令牌](../ci/jobs/ci_job_token.md)触发流水线以进行身份验证。

使用 CI/CD 作业令牌时，[触发的流水线是多项目流水线](../ci/pipelines/downstream_pipelines.md#trigger-a-multi-project-pipeline-by-using-the-api)。验证请求的作业会与上游流水线关联，这会在流水线图中显示。

如果在作业中使用触发令牌，该作业不会与上游流水线关联。

```plaintext
POST /projects/:id/trigger/pipeline
```

支持的属性：

| 属性   | 类型           | 是否必需 | 描述 |
|-------------|----------------|----------|-------------|
| `id`        | 整数或字符串 | 是      | ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `ref`       | 字符串         | 是      | 要运行流水线的分支或标签。 |
| `token`     | 字符串         | 是      | 触发令牌或 CI/CD 作业令牌。 |
| `variables` | 哈希           | 否       | 包含流水线变量的键值字符串映射。例如：`{ VAR1: "value1", VAR2: "value2" }`。 |
| `inputs`    | 哈希           | 否       | 创建流水线时要使用的输入映射，以键值对形式提供。 |

使用[变量](../ci/variables/_index.md)的请求示例：

```shell
curl --request POST \
  --form "variables[VAR1]=value1" \
  --form "variables[VAR2]=value2" \
  --url "https://gitlab.example.com/api/v4/projects/123/trigger/pipeline?token=2cb1840fb9dfc9fb0b7b1609cd29cb&ref=main"
```

使用[输入](../ci/inputs/_index.md)的请求示例：

```shell
curl --request POST \
  --header "Content-Type: application/json" \
  --data '{"inputs": {"environment": "environment", "scan_security": false, "level": 3}}' \
  --url "https://gitlab.example.com/api/v4/projects/123/trigger/pipeline?token=2cb1840fb9dfc9fb0b7b1609cd29cb&ref=main"
```

响应示例：

```json
{
  "id": 257,
  "iid": 118,
  "project_id": 123,
  "sha": "91e2711a93e5d9e8dddfeb6d003b636b25bf6fc9",
  "ref": "main",
  "status": "created",
  "source": "trigger",
  "created_at": "2022-03-31T01:12:49.068Z",
  "updated_at": "2022-03-31T01:12:49.068Z",
  "web_url": "http://127.0.0.1:3000/test-group/test-project/-/pipelines/257",
  "before_sha": "0000000000000000000000000000000000000000",
  "tag": false,
  "yaml_errors": null,
  "user": {
    "id": 1,
    "username": "root",
    "name": "Administrator",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://127.0.0.1:3000/root"
  },
  "started_at": null,
  "finished_at": null,
  "committed_at": null,
  "duration": null,
  "queued_duration": null,
  "coverage": null,
  "detailed_status": {
    "icon": "status_created",
    "text": "created",
    "label": "created",
    "group": "created",
    "tooltip": "created",
    "has_details": true,
    "details_path": "/test-group/test-project/-/pipelines/257",
    "illustration": null,
    "favicon": "/assets/ci_favicons/favicon_status_created-4b975aa976d24e5a3ea7cd9a5713e6ce2cd9afd08b910415e96675de35f64955.png"
  },
  "archived": false
}
```