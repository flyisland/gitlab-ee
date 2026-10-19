---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组徽章 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与群组徽章进行交互。更多信息，请参见[群组徽章](../user/project/badges.md#group-badges)。

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

由于这些端点不在项目的上下文中，用于替换占位符的信息来自该群组中按创建日期排序的第一个项目。如果该群组没有项目，则返回带有占位符的原始 URL。

<a id="list-all-group-badges"></a>

## 列出所有群组徽章

列出指定群组的徽章。

```plaintext
GET /groups/:id/badges
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `name`    | string         | 否  | 要返回的徽章名称（区分大小写）。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/badges?name=Coverage"
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
    "kind": "group"
  }
]
```

<a id="retrieve-a-group-badge"></a>

## 检索群组徽章

检索群组的指定徽章。

```plaintext
GET /groups/:id/badges/:badge_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `badge_id` | integer | 是   | 徽章 ID |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/badges/:badge_id"
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
  "kind": "group"
}
```

<a id="create-a-group-badge"></a>

## 创建群组徽章

为指定群组创建徽章。

```plaintext
POST /groups/:id/badges
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `link_url` | string         | 是 | 徽章链接的 URL |
| `image_url` | string | 是 | 徽章图片的 URL |
| `name` | string | 否 | 徽章名称 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/badges" \
  --data "link_url=https://jihulab.com/gitlab-cn/gitlab-foss/commits/master&image_url=https://shields.io/my/badge1&name=mybadge&position=0"
```

示例响应：

```json
{
  "id": 1,
  "name": "mybadge",
  "link_url": "https://jihulab.com/gitlab-cn/gitlab-foss/commits/master",
  "image_url": "https://shields.io/my/badge1",
  "rendered_link_url": "https://jihulab.com/gitlab-cn/gitlab-foss/commits/master",
  "rendered_image_url": "https://shields.io/my/badge1",
  "kind": "group"
}
```

<a id="update-a-group-badge"></a>

## 更新群组徽章

更新群组的指定徽章。

```plaintext
PUT /groups/:id/badges/:badge_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `badge_id` | integer | 是   | 徽章 ID |
| `link_url` | string         | 否 | 徽章链接的 URL |
| `image_url` | string | 否 | 徽章图片的 URL |
| `name` | string | 否 | 徽章名称 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/badges/:badge_id"
```

示例响应：

```json
{
  "id": 1,
  "name": "mybadge",
  "link_url": "https://jihulab.com/gitlab-cn/gitlab-foss/commits/master",
  "image_url": "https://shields.io/my/badge",
  "rendered_link_url": "https://jihulab.com/gitlab-cn/gitlab-foss/commits/master",
  "rendered_image_url": "https://shields.io/my/badge",
  "kind": "group"
}
```

<a id="delete-a-group-badge"></a>

## 删除群组徽章

从群组中删除指定徽章。

```plaintext
DELETE /groups/:id/badges/:badge_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `badge_id` | integer | 是   | 徽章 ID |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/badges/:badge_id"
```

<a id="retrieve-a-group-badge-preview"></a>

## 检索群组徽章预览

在解析占位符插值后，检索指定群组最终的 `link_url` 和 `image_url` URL 预览。

```plaintext
GET /groups/:id/badges/render
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `link_url` | string         | 是 | 徽章链接的 URL|
| `image_url` | string | 是 | 徽章图片的 URL |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/badges/render?link_url=http%3A%2F%2Fexample.com%2Fci_status.svg%3Fproject%3D%25%7Bproject_path%7D%26ref%3D%25%7Bdefault_branch%7D&image_url=https%3A%2F%2Fshields.io%2Fmy%2Fbadge"
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
