---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目徽章 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理项目[徽章](../user/project/badges.md)。

徽章支持占位符，这些占位符会在链接和图片 URL 中实时替换。可用的占位符如下：

- `%{project_path}`：替换为项目路径。
- `%{project_title}`：替换为项目标题。
- `%{project_name}`：替换为项目名称。
- `%{project_id}`：替换为项目 ID。
- `%{project_namespace}`：替换为项目的命名空间完整路径。
- `%{group_name}`：替换为项目的顶级群组名称。
- `%{gitlab_server}`：替换为项目的服务器名称。
- `%{gitlab_pages_domain}`：替换为托管 GitLab Pages 的域名。
- `%{default_branch}`：替换为项目的默认分支。
- `%{commit_sha}`：替换为项目的最后一次提交 SHA。
- `%{latest_tag}`：替换为项目的最后一个标签。

<a id="list-all-badges-of-a-project"></a>

## 列出项目的所有徽章

列出项目的所有徽章，包括群组徽章。

```plaintext
GET /projects/:id/badges
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `name`    | string         | 否  | 要返回的徽章名称（区分大小写）。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/badges?name=Coverage"
```

示例响应：

```json
[
  {
    "name": "Coverage",
    "id": 1,
    "link_url": "http://example.com/ci_status.svg?project=%{project_path}&ref=%{default_branch}",
    "image_url": "https://shields.io/my/badge",
    "rendered_link_url": "http://example.com/ci_status.svg?project=example-org/example-project&ref=main",
    "rendered_image_url": "https://shields.io/my/badge",
    "kind": "project"
  },
  {
    "name": "Pipeline",
    "id": 2,
    "link_url": "http://example.com/ci_status.svg?project=%{project_path}&ref=%{default_branch}",
    "image_url": "https://shields.io/my/badge",
    "rendered_link_url": "http://example.com/ci_status.svg?project=example-org/example-project&ref=main",
    "rendered_image_url": "https://shields.io/my/badge",
    "kind": "group"
  }
]
```

<a id="retrieve-a-badge-of-a-project"></a>

## 检索项目的徽章

检索项目的徽章。

```plaintext
GET /projects/:id/badges/:badge_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `badge_id` | integer | 是   | 徽章 ID |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/badges/:badge_id"
```

示例响应：

```json
{
  "name": "Coverage",
  "id": 1,
  "link_url": "http://example.com/ci_status.svg?project=%{project_path}&ref=%{default_branch}",
  "image_url": "https://shields.io/my/badge",
  "rendered_link_url": "http://example.com/ci_status.svg?project=example-org/example-project&ref=main",
  "rendered_image_url": "https://shields.io/my/badge",
  "kind": "project"
}
```

<a id="create-a-badge-for-a-project"></a>

## 为项目创建徽章

为项目创建徽章。

```plaintext
POST /projects/:id/badges
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `link_url` | string         | 是 | 徽章链接的 URL |
| `image_url` | string | 是 | 徽章图片的 URL |
| `name` | string | 否 | 徽章名称 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --form "link_url=https://jihulab.com/gitlab-cn/gitlab-foss/commits/main" \
  --form "image_url=https://shields.io/my/badge1" \
  --form "name=mybadge" \
  --url "https://gitlab.example.com/api/v4/projects/:id/badges"
```

示例响应：

```json
{
  "id": 1,
  "name": "mybadge",
  "link_url": "https://jihulab.com/gitlab-cn/gitlab-foss/commits/main",
  "image_url": "https://shields.io/my/badge1",
  "rendered_link_url": "https://jihulab.com/gitlab-cn/gitlab-foss/commits/main",
  "rendered_image_url": "https://shields.io/my/badge1",
  "kind": "project"
}
```

<a id="update-a-badge-of-a-project"></a>

## 更新项目的徽章

更新项目的徽章。

```plaintext
PUT /projects/:id/badges/:badge_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `badge_id` | integer | 是   | 徽章 ID |
| `link_url` | string         | 否 | 徽章链接的 URL |
| `image_url` | string | 否 | 徽章图片的 URL |
| `name` | string | 否 | 徽章名称 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/badges/:badge_id"
```

示例响应：

```json
{
  "id": 1,
  "name": "mybadge",
  "link_url": "https://jihulab.com/gitlab-cn/gitlab-foss/commits/main",
  "image_url": "https://shields.io/my/badge",
  "rendered_link_url": "https://jihulab.com/gitlab-cn/gitlab-foss/commits/main",
  "rendered_image_url": "https://shields.io/my/badge",
  "kind": "project"
}
```

<a id="delete-a-badge-from-a-project"></a>

## 从项目中删除徽章

从项目中删除徽章。要删除群组徽章，请改用[群组徽章 API](group_badges.md)。

```plaintext
DELETE /projects/:id/badges/:badge_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `badge_id` | integer | 是   | 徽章 ID |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/badges/:badge_id"
```

<a id="preview-a-badge-from-a-project"></a>

## 预览项目的徽章

返回解析占位符插值后 `link_url` 和 `image_url`的最终 URL。

```plaintext
GET /projects/:id/badges/render
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `link_url` | string         | 是 | 徽章链接的 URL|
| `image_url` | string | 是 | 徽章图片的 URL |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/badges/render?link_url=http%3A%2F%2Fexample.com%2Fci_status.svg%3Fproject%3D%25%7Bproject_path%7D%26ref%3D%25%7Bdefault_branch%7D&image_url=https%3A%2F%2Fshields.io%2Fmy%2Fbadge"
```

示例响应：

```json
{
  "link_url": "http://example.com/ci_status.svg?project=%{project_path}&ref=%{default_branch}",
  "image_url": "https://shields.io/my/badge",
  "rendered_link_url": "http://example.com/ci_status.svg?project=example-org/example-project&ref=main",
  "rendered_image_url": "https://shields.io/my/badge"
}
```
