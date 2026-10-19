---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 主题 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

使用此 API 与项目主题交互。更多信息，请参阅 [项目主题](../user/project/project_topics.md)。

<a id="list-all-topics"></a>

## 列出所有主题

返回 极狐GitLab 实例中按关联项目数量排序的项目主题列表。

```plaintext
GET /topics
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
| ------------------ | ------- | ---------------------- | ----------- |
| `page` | integer | 否 | 要检索的页码。默认为 `1`。 |
| `per_page` | integer | 否 | 每页返回的记录数。默认为 `20`。 |
| `search` | string | 否 | 根据 `name` 搜索主题。 |
| `without_projects` | boolean | 否 | 将结果限制为未分配项目的主题。 |

示例请求：

```shell
curl --request GET \
  --url "https://gitlab.example.com/api/v4/topics?search=git"
```

示例响应：

```json
[
  {
    "id": 1,
    "name": "gitlab",
    "title": "极狐GitLab",
    "description": "极狐GitLab 是一个开源端到端软件开发平台，内置版本控制、议题跟踪、代码审查、CI/CD 等功能。",
    "total_projects_count": 1000,
    "organization_id": 1,
    "avatar_url": "http://www.gravatar.com/avatar/a0d477b3ea21970ce6ffcbb817b0b435?s=80&d=identicon"
  },
  {
    "id": 3,
    "name": "git",
    "title": "Git",
    "description": "Git 是一个免费且开源的分布式版本控制系统，旨在快速高效地处理从小型到大型项目的所有事务。",
    "total_projects_count": 900,
    "organization_id": 1,
    "avatar_url": "http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon"
  },
  {
    "id": 2,
    "name": "git-lfs",
    "title": "Git LFS",
    "description": null,
    "total_projects_count": 300,
    "organization_id": 1,
    "avatar_url": null
  }
]
```

<a id="retrieve-a-topic"></a>

## 获取主题

通过 ID 获取项目主题。

```plaintext
GET /topics/:id
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
| --------- | ------- | ---------------------- | ------------------- |
| `id` | integer | 是 | 项目主题的 ID |

示例请求：

```shell
curl --request GET \
  --url "https://gitlab.example.com/api/v4/topics/1"
```

示例响应：

```json
{
  "id": 1,
  "name": "gitlab",
  "title": "极狐GitLab",
  "description": "极狐GitLab 是一个开源端到端软件开发平台，内置版本控制、议题跟踪、代码审查、CI/CD 等功能。",
  "total_projects_count": 1000,
  "organization_id": 1,
  "avatar_url": "http://www.gravatar.com/avatar/a0d477b3ea21970ce6ffcbb817b0b435?s=80&d=identicon"
}
```

<a id="list-all-projects-assigned-to-a-topic"></a>

## 列出分配给主题的所有项目

使用 [项目 API](projects.md#list-all-projects) 列出分配给特定主题的所有项目。

```plaintext
GET /projects?topic=<topic_name>
```

<a id="create-a-project-topic"></a>

## 创建项目主题

创建新的项目主题。仅管理员可用。

```plaintext
POST /topics
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|-------------------|---------|----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `name` | string | 是 | 简称（名称） |
| `title` | string | 是 | 标题 |
| `avatar` | file | 否 | 头像 |
| `description` | string | 否 | 描述 |
| `organization_id` | integer | 否 | 主题的组织 ID。警告：此属性为实验性，未来可能发生变化。有关组织的更多信息，请参阅 [组织 API](organizations.md) |

示例请求：

```shell
curl --request POST \
    --data "name=topic1&title=Topic 1" \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/topics"
```

示例响应：

```json
{
  "id": 1,
  "name": "topic1",
  "title": "主题 1",
  "description": null,
  "total_projects_count": 0,
  "organization_id": 1,
  "avatar_url": null
}
```

<a id="update-a-project-topic"></a>

## 更新项目主题

更新项目主题。仅管理员可用。

```plaintext
PUT /topics/:id
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|---------------|---------|----------|---------------------|
| `id` | integer | 是 | 项目主题的 ID |
| `avatar` | file | 否 | 头像 |
| `description` | string | 否 | 描述 |
| `name` | string | 否 | 简称（名称） |
| `title` | string | 否 | 标题 |

示例请求：

```shell
curl --request PUT \
    --data "name=topic1" \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/topics/1"
```

示例响应：

```json
{
  "id": 1,
  "name": "topic1",
  "title": "主题 1",
  "description": null,
  "total_projects_count": 0,
  "organization_id": 1,
  "avatar_url": null
}
```

<a id="upload-a-topic-avatar"></a>

### 上传主题头像

要从文件系统上传头像文件，请使用 `--form` 参数。此参数使 cURL 使用标头 `Content-Type: multipart/form-data` 发送数据。`file=` 参数必须指向文件系统上的文件，并在前面加上 `@`。例如：

```shell
curl --request PUT \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/topics/1" \
    --form "avatar=@/tmp/example.png"
```

<a id="remove-a-topic-avatar"></a>

### 移除主题头像

要移除主题头像，请为 `avatar` 属性使用空值。

示例请求：

```shell
curl --request PUT \
    --data "avatar=" \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/topics/1"
```

<a id="delete-a-project-topic"></a>

## 删除项目主题

您必须是管理员才能删除项目主题。删除项目主题时，也会删除项目的主题分配。

```plaintext
DELETE /topics/:id
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|-----------|---------|----------|---------------------|
| `id` | integer | 是 | 项目主题的 ID |

示例请求：

```shell
curl --request DELETE \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/topics/1"
```

<a id="merge-topics"></a>

## 合并主题

您必须是管理员才能将源主题合并到目标主题。合并主题时，将删除源主题，并将所有分配的项目移至目标主题。

```plaintext
POST /topics/merge
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|-------------------|---------|----------|----------------------------|
| `source_topic_id` | integer | 是 | 源项目主题的 ID |
| `target_topic_id` | integer | 是 | 目标项目主题的 ID |

> [!note]
> `source_topic_id` 和 `target_topic_id` 必须属于同一组织。

示例请求：

```shell
curl --request POST \
    --data "source_topic_id=2&target_topic_id=1" \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/topics/merge"
```

示例响应：

```json
{
  "id": 1,
  "name": "topic1",
  "title": "主题 1",
  "description": null,
  "total_projects_count": 0,
  "organization_id": 1,
  "avatar_url": null
}
```