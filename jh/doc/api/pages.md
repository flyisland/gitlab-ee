---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Pages API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 来[管理](../administration/pages/_index.md)和[使用](../user/project/pages/_index.md)极狐GitLab Pages。

必须启用极狐GitLab Pages 功能才能使用这些端点。

<a id="unpublish-pages"></a>

## 取消发布 Pages

{{< history >}}

- 在极狐GitLab 17.9 中将所需最低角色从管理员访问更改为维护者角色。

{{< /history >}}

从指定项目中取消发布并删除 Pages。

先决条件：

- 您必须拥有该项目的维护者或所有者角色。

```plaintext
DELETE /projects/:id/pages
```

| 属性 | 类型           | 必需 | 描述                              |
| --------- | -------------- | -------- | ---------------------------------------- |
| `id`      | 整数或字符串 | 是      | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/2/pages"
```

<a id="retrieve-pages-settings-for-a-project"></a>

## 获取项目的 Pages 设置

{{< history >}}

- 在极狐GitLab 16.8 中引入。

{{< /history >}}

获取指定项目的 Pages 设置。

先决条件：

- 您必须拥有该项目的维护者或所有者角色。

```plaintext
GET /projects/:id/pages
```

支持的属性：

| 属性 | 类型           | 必需 | 描述                              |
| --------- | -------------- | -------- | ---------------------------------------- |
| `id`      | 整数或字符串 | 是      | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 和下列响应属性：

| 属性                                 | 类型       | 描述                                                                                                                  |
| ----------------------------------------- | ---------- | -----------------------                                                                                                      |
| `url`                                     | 字符串     | 用于访问此项目 Pages 的 URL。                                                                                            |
| `is_unique_domain_enabled`                | 布尔    | 是否启用了 [唯一域名](../user/project/pages/introduction.md)。                                                        |
| `force_https`                             | 布尔    | 如果项目设置为强制使用 HTTPS，则为 `true`。                                                                                      |
| `deployments[]`                           | 数组      | 当前活动部署的列表。                                                                                          |
| `primary_domain`                          | 字符串     | 将所有 Pages 请求重定向到的主域名。在极狐GitLab 17.8 中引入。 |

| `deployments[]` 属性                 | 类型       | 描述                                                                                                                   |
| ----------------------------------------- | ---------- |-------------------------------------------------------------------------------------------------------------------------------|
| `created_at`                              | 日期       | 创建部署的日期。                                                                                                  |
| `url`                                     | 字符串     | 此部署的 URL。                                                                                                      |
| `path_prefix`                             | 字符串     | 使用 [并行部署](../user/project/pages/_index.md#parallel-deployments) 时此部署的路径前缀。 |
| `root_directory`                          | 字符串     | 根目录。                                                                                                               |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/2/pages"
```

示例响应：

```json
{
  "url": "http://html-root-4160ce5f0e9a6c90ccb02755b7fc80f5a2a09ffbb1976cf80b653.pages.gdk.test:3010",
  "is_unique_domain_enabled": true,
  "force_https": false,
  "deployments": [
    {
      "created_at": "2024-01-05T18:58:14.916Z",
      "url": "http://html-root-4160ce5f0e9a6c90ccb02755b7fc80f5a2a09ffbb1976cf80b653.pages.gdk.test:3010/",
      "path_prefix": "",
      "root_directory": null
    },
    {
      "created_at": "2024-01-05T18:58:46.042Z",
      "url": "http://html-root-4160ce5f0e9a6c90ccb02755b7fc80f5a2a09ffbb1976cf80b653.pages.gdk.test:3010/mr3",
      "path_prefix": "mr3",
      "root_directory": null
    }
  ],
  "primary_domain": null
}
```

<a id="update-pages-settings-for-a-project"></a>

## 更新项目的 Pages 设置

{{< history >}}

- 在极狐GitLab 17.0 中引入。
- 在极狐GitLab 17.9 中将所需最低角色从管理员访问更改为维护者角色。

{{< /history >}}

更新指定项目的 Pages 设置。

先决条件：

- 您必须拥有该项目的维护者或所有者角色。

```plaintext
PATCH /projects/:id/pages
```

支持的属性：

| 属性                       | 类型           | 必需 | 描述                                                                                                         |
| --------------------------------| -------------- | -------- | --------------------------------------------------------------------------------------------------------------------|
| `id`                            | 整数或字符串 | 是      | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                                 |
| `pages_unique_domain_enabled`   | 布尔        | 否       | 是否使用唯一域名                                                                                        |
| `pages_https_only`              | 布尔        | 否       | 是否强制使用 HTTPS                                                                                              |
| `pages_primary_domain`          | 字符串         | 否       | 从现有分配域名中设置主域名，以将所有的 Pages 请求重定向至此。在极狐GitLab 17.8 中引入。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 和下列响应属性：

| 属性                                 | 类型       | 描述                                                                                                                  |
| ----------------------------------------- | ---------- | -----------------------                                                                                                      |
| `url`                                     | 字符串     | 用于访问此项目 Pages 的 URL。                                                                                            |
| `is_unique_domain_enabled`                | 布尔    | 是否启用了 [唯一域名](../user/project/pages/introduction.md)。                                                        |
| `force_https`                             | 布尔    | 如果项目设置为强制使用 HTTPS，则为 `true`。                                                                                      |
| `deployments[]`                           | 数组      | 当前活动部署的列表。                                                                                          |
| `primary_domain`                          | 字符串     | 将所有 Pages 请求重定向到的主域名。在极狐GitLab 17.8 中引入。 |

| `deployments[]` 属性                 | 类型       | 描述                                                                                                                   |
| ----------------------------------------- | ---------- |-------------------------------------------------------------------------------------------------------------------------------|
| `created_at`                              | 日期       | 创建部署的日期。                                                                                                  |
| `url`                                     | 字符串     | 此部署的 URL。                                                                                                      |
| `path_prefix`                             | 字符串     | 使用 [并行部署](../user/project/pages/_index.md#parallel-deployments) 时此部署的路径前缀。 |
| `root_directory`                          | 字符串     | 根目录。                                                                                                               |

示例请求：

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/pages" \
  --form 'pages_unique_domain_enabled=true' \
  --form 'pages_https_only=true' \
  --form 'pages_primary_domain=https://custom.example.com'
```

示例响应：

```json
{
  "url": "http://html-root-4160ce5f0e9a6c90ccb02755b7fc80f5a2a09ffbb1976cf80b653.pages.gdk.test:3010",
  "is_unique_domain_enabled": true,
  "force_https": false,
  "deployments": [
    {
      "created_at": "2024-01-05T18:58:14.916Z",
      "url": "http://html-root-4160ce5f0e9a6c90ccb02755b7fc80f5a2a09ffbb1976cf80b653.pages.gdk.test:3010/",
      "path_prefix": "",
      "root_directory": null
    },
    {
      "created_at": "2024-01-05T18:58:46.042Z",
      "url": "http://html-root-4160ce5f0e9a6c90ccb02755b7fc80f5a2a09ffbb1976cf80b653.pages.gdk.test:3010/mr3",
      "path_prefix": "mr3",
      "root_directory": null
    }
  ],
  "primary_domain": null
}
```