---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目别名 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 管理[项目别名](../user/project/working_with_projects.md#project-aliases)。
为项目创建别名后，用户可使用别名克隆仓库，这在迁移仓库时很有帮助。

所有方法都需要管理员授权。

## 列出所有项目别名

<a id="list-all-project-aliases"></a>

获取所有项目别名的列表：

```plaintext
GET /project_aliases
```

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性          | 类型    | 描述             |
|--------------|---------|-----------------|
| `id`         | integer | 项目别名 ID。      |
| `project_id` | integer | 关联项目 ID。      |
| `name`       | string  | 别名名称。         |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/project_aliases"
```

响应示例：

```json
[
  {
    "id": 1,
    "project_id": 1,
    "name": "gitlab-foss"
  },
  {
    "id": 2,
    "project_id": 2,
    "name": "gitlab"
  }
]
```

## 获取项目别名

<a id="retrieve-a-project-alias"></a>

获取项目别名的详细信息：

```plaintext
GET /project_aliases/:name
```

支持的属性：

| 属性    | 类型   | 是否必需 | 描述             |
|--------|--------|----------|-----------------|
| `name` | string | 是       | 别名名称。         |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性          | 类型    | 描述             |
|--------------|---------|-----------------|
| `id`         | integer | 项目别名 ID。      |
| `project_id` | integer | 关联项目 ID。      |
| `name`       | string  | 别名名称。         |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/project_aliases/gitlab"
```

响应示例：

```json
{
  "id": 1,
  "project_id": 1,
  "name": "gitlab"
}
```

## 创建项目别名

<a id="create-a-project-alias"></a>

为项目添加新别名：

```plaintext
POST /project_aliases
```

支持的属性：

| 属性          | 类型              | 是否必需 | 描述                           |
|--------------|-------------------|----------|-------------------------------|
| `project_id` | integer 或 string | 是       | 项目 ID 或路径。                 |
| `name`       | string            | 是       | 别名名称。必须唯一。              |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性          | 类型    | 描述             |
|--------------|---------|-----------------|
| `id`         | integer | 项目别名 ID。      |
| `project_id` | integer | 关联项目 ID。      |
| `name`       | string  | 别名名称。         |

请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/project_aliases" \
  --form "project_id=1" \
  --form "name=gitlab"
```

你也可以使用项目路径：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/project_aliases" \
  --form "project_id=gitlab-org/gitlab" \
  --form "name=gitlab"
```

响应示例：

```json
{
  "id": 1,
  "project_id": 1,
  "name": "gitlab"
}
```

## 删除项目别名

<a id="delete-a-project-alias"></a>

移除一个项目别名：

```plaintext
DELETE /project_aliases/:name
```

支持的属性：

| 属性    | 类型   | 是否必需 | 描述             |
|--------|--------|----------|-----------------|
| `name` | string | 是       | 别名名称。         |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

请求示例：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/project_aliases/gitlab"
```