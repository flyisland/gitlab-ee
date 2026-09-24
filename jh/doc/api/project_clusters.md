---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目集群 API（基于证书）（已弃用）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能在极狐GitLab 14.5 中已被[弃用](https://gitlab.com/groups/gitlab-org/configure/-/epics/8)。

用户需要维护者或所有者角色才能使用这些端点。

<a id="list-all-clusters-in-a-project"></a>

## 列出项目中的所有集群

列出指定项目中的所有集群。

```plaintext
GET /projects/:id/clusters
```

参数说明：

| 属性   | 类型         | 是否必需 | 描述                                                         |
| ------ | ------------ | -------- | ------------------------------------------------------------ |
| `id`   | 整数或字符串 | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

请求示例：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/26/clusters"
```

响应示例：

```json
[
  {
    "id":18,
    "name":"cluster-1",
    "domain":"example.com",
    "created_at":"2019-01-02T20:18:12.563Z",
    "managed": true,
    "enabled": true,
    "provider_type":"user",
    "platform_type":"kubernetes",
    "environment_scope":"*",
    "cluster_type":"project_type",
    "user":
    {
      "id":1,
      "name":"Administrator",
      "username":"root",
      "state":"active",
      "avatar_url":"https://www.gravatar.com/avatar/4249f4df72b..",
      "web_url":"https://gitlab.example.com/root"
    },
    "platform_kubernetes":
    {
      "api_url":"https://104.197.68.152",
      "namespace":"cluster-1-namespace",
      "authorization_type":"rbac",
      "ca_cert":"-----BEGIN CERTIFICATE-----\r\nhFiK1L61owwDQYJKoZIhvcNAQELBQAw\r\nLzEtMCsGA1UEAxMkZDA1YzQ1YjctNzdiMS00NDY0LThjNmEtMTQ0ZDJkZjM4ZDBj\r\nMB4XDTE4MTIyNzIwMDM1MVoXDTIzMTIyNjIxMDM1MVowLzEtMCsGA1UEAxMkZDA1\r\nYzQ1YjctNzdiMS00NDY0LThjNmEtMTQ0ZDJkZjM.......-----END CERTIFICATE-----"
    },
    "management_project":
    {
      "id":2,
      "description":null,
      "name":"project2",
      "name_with_namespace":"John Doe8 / project2",
      "path":"project2",
      "path_with_namespace":"namespace2/project2",
      "created_at":"2019-10-11T02:55:54.138Z"
    }
  },
  {
    "id":19,
    "name":"cluster-2",
    ...
  }
]
```

<a id="retrieve-a-cluster-from-a-project"></a>

## 从项目中获取集群

获取项目中的指定集群。

```plaintext
GET /projects/:id/clusters/:cluster_id
```

参数说明：

| 属性         | 类型         | 是否必需 | 描述                                                         |
| ------------ | ------------ | -------- | ------------------------------------------------------------ |
| `id`         | 整数或字符串 | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `cluster_id` | 整数         | 是       | 集群的 ID                                                    |

请求示例：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/26/clusters/18"
```

响应示例：

```json
{
  "id":18,
  "name":"cluster-1",
  "domain":"example.com",
  "created_at":"2019-01-02T20:18:12.563Z",
  "managed": true,
  "enabled": true,
  "provider_type":"user",
  "platform_type":"kubernetes",
  "environment_scope":"*",
  "cluster_type":"project_type",
  "user":
  {
    "id":1,
    "name":"Administrator",
    "username":"root",
    "state":"active",
    "avatar_url":"https://www.gravatar.com/avatar/4249f4df72b..",
    "web_url":"https://gitlab.example.com/root"
  },
  "platform_kubernetes":
  {
    "api_url":"https://104.197.68.152",
    "namespace":"cluster-1-namespace",
    "authorization_type":"rbac",
    "ca_cert":"-----BEGIN CERTIFICATE-----\r\nhFiK1L61owwDQYJKoZIhvcNAQELBQAw\r\nLzEtMCsGA1UEAxMkZDA1YzQ1YjctNzdiMS00NDY0LThjNmEtMTQ0ZDJkZjM4ZDBj\r\nMB4XDTE4MTIyNzIwMDM1MVoXDTIzMTIyNjIxMDM1MVowLzEtMCsGA1UEAxMkZDA1\r\nYzQ1YjctNzdiMS00NDY0LThjNmEtMTQ0ZDJkZjM.......-----END CERTIFICATE-----"
  },
  "management_project":
  {
    "id":2,
    "description":null,
    "name":"project2",
    "name_with_namespace":"John Doe8 / project2",
    "path":"project2",
    "path_with_namespace":"namespace2/project2",
    "created_at":"2019-10-11T02:55:54.138Z"
  },
  "project":
  {
    "id":26,
    "description":"",
    "name":"project-with-clusters-api",
    "name_with_namespace":"Administrator / project-with-clusters-api",
    "path":"project-with-clusters-api",
    "path_with_namespace":"root/project-with-clusters-api",
    "created_at":"2019-01-02T20:13:32.600Z",
    "default_branch":null,
    "tag_list":[], // 已弃用，请使用 `topics` 代替
    "topics":[],
    "ssh_url_to_repo":"ssh://gitlab.example.com/root/project-with-clusters-api.git",
    "http_url_to_repo":"https://gitlab.example.com/root/project-with-clusters-api.git",
    "web_url":"https://gitlab.example.com/root/project-with-clusters-api",
    "readme_url":null,
    "avatar_url":null,
    "star_count":0,
    "forks_count":0,
    "last_activity_at":"2019-01-02T20:13:32.600Z",
    "namespace":
    {
      "id":1,
      "name":"root",
      "path":"root",
      "kind":"user",
      "full_path":"root",
      "parent_id":null
    }
  }
}
```

<a id="add-a-cluster-to-a-project"></a>

## 向项目添加集群

将一个现有集群添加到指定项目。

```plaintext
POST /projects/:id/clusters/user
```

参数说明：

| 属性                                                  | 类型         | 是否必需 | 描述                                                                                    |
| ----------------------------------------------------- | ------------ | -------- | --------------------------------------------------------------------------------------- |
| `id`                                                  | 整数或字符串 | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                            |
| `name`                                                | 字符串       | 是       | 集群的名称                                                                              |
| `domain`                                              | 字符串       | 否       | 集群的[基础域](../user/project/clusters/gitlab_managed_clusters.md#base-domain)           |
| `management_project_id`                               | 整数         | 否       | 集群的[管理项目](../user/clusters/management_project.md) ID                              |
| `enabled`                                             | 布尔值       | 否       | 决定集群是否启用，默认为 `true`                                                           |
| `managed`                                             | 布尔值       | 否       | 决定极狐GitLab是否管理此集群的命名空间和服务账户，默认为 `true`                              |
| `platform_kubernetes_attributes[api_url]`             | 字符串       | 是       | 访问 Kubernetes API 的 URL                                                                |
| `platform_kubernetes_attributes[token]`               | 字符串       | 是       | 用于在 Kubernetes 中进行身份验证的令牌                                                     |
| `platform_kubernetes_attributes[ca_cert]`             | 字符串       | 否       | TLS 证书。如果 API 使用自签名 TLS 证书，则为必需项。                                        |
| `platform_kubernetes_attributes[namespace]`           | 字符串       | 否       | 与项目相关的唯一命名空间                                                                  |
| `platform_kubernetes_attributes[authorization_type]`  | 字符串       | 否       | 集群授权类型：`rbac`、`abac` 或 `unknown_authorization`。默认为 `rbac`。                    |
| `environment_scope`                                   | 字符串       | 否       | 与集群关联的环境。默认为 `*`。仅限专业版和旗舰版。                                          |

请求示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Accept: application/json" \
  --header "Content-Type:application/json" \
  --data '{"name":"cluster-5", "platform_kubernetes_attributes":{"api_url":"https://35.111.51.20","token":"12345","namespace":"cluster-5-namespace","ca_cert":"-----BEGIN CERTIFICATE-----\r\nhFiK1L61owwDQYJKoZIhvcNAQELBQAw\r\nLzEtMCsGA1UEAxMkZDA1YzQ1YjctNzdiMS00NDY0LThjNmEtMTQ0ZDJkZjM4ZDBj\r\nMB4XDTE4MTIyNzIwMDM1MVoXDTIzMTIyNjIxMDM1MVowLzEtMCsGA1UEAxMkZDA1\r\nYzQ1YjctNzdiMS00NDY0LThjNmEtMTQ0ZDJkZjM.......-----END CERTIFICATE-----"}}' \
  --url "https://gitlab.example.com/api/v4/projects/26/clusters/user"
```

响应示例：

```json
{
  "id":24,
  "name":"cluster-5",
  "created_at":"2019-01-03T21:53:40.610Z",
  "managed": true,
  "enabled": true,
  "provider_type":"user",
  "platform_type":"kubernetes",
  "environment_scope":"*",
  "cluster_type":"project_type",
  "user":
  {
    "id":1,
    "name":"Administrator",
    "username":"root",
    "state":"active",
    "avatar_url":"https://www.gravatar.com/avatar/4249f4df72b..",
    "web_url":"https://gitlab.example.com/root"
  },
  "platform_kubernetes":
  {
    "api_url":"https://35.111.51.20",
    "namespace":"cluster-5-namespace",
    "authorization_type":"rbac",
    "ca_cert":"-----BEGIN CERTIFICATE-----\r\nhFiK1L61owwDQYJKoZIhvcNAQELBQAw\r\nLzEtMCsGA1UEAxMkZDA1YzQ1YjctNzdiMS00NDY0LThjNmEtMTQ0ZDJkZjM4ZDBj\r\nMB4XDTE4MTIyNzIwMDM1MVoXDTIzMTIyNjIxMDM1MVowLzEtMCsGA1UEAxMkZDA1\r\nYzQ1YjctNzdiMS00NDY0LThjNmEtMTQ0ZDJkZjM.......-----END CERTIFICATE-----"
  },
  "management_project":null,
  "project":
  {
    "id":26,
    "description":"",
    "name":"project-with-clusters-api",
    "name_with_namespace":"Administrator / project-with-clusters-api",
    "path":"project-with-clusters-api",
    "path_with_namespace":"root/project-with-clusters-api",
    "created_at":"2019-01-02T20:13:32.600Z",
    "default_branch":null,
    "tag_list":[], // 已弃用，请使用 `topics` 代替
    "topics":[],
    "ssh_url_to_repo":"ssh:://gitlab.example.com/root/project-with-clusters-api.git",
    "http_url_to_repo":"https://gitlab.example.com/root/project-with-clusters-api.git",
    "web_url":"https://gitlab.example.com/root/project-with-clusters-api",
    "readme_url":null,
    "avatar_url":null,
    "star_count":0,
    "forks_count":0,
    "last_activity_at":"2019-01-02T20:13:32.600Z",
    "namespace":
    {
      "id":1,
      "name":"root",
      "path":"root",
      "kind":"user",
      "full_path":"root",
      "parent_id":null
    }
  }
}
```

<a id="update-a-cluster-in-a-project"></a>

## 更新项目中的集群

更新指定项目中的集群。

```plaintext
PUT /projects/:id/clusters/:cluster_id
```

参数说明：

| 属性                                        | 类型         | 是否必需 | 描述                                                                                       |
| ------------------------------------------- | ------------ | -------- | ------------------------------------------------------------------------------------------ |
| `id`                                        | 整数或字符串 | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                               |
| `cluster_id`                                | 整数         | 是       | 集群的 ID                                                                                 |
| `name`                                      | 字符串       | 否       | 集群的名称                                                                                 |
| `domain`                                    | 字符串       | 否       | 集群的[基础域](../user/project/clusters/gitlab_managed_clusters.md#base-domain)              |
| `management_project_id`                     | 整数         | 否       | 集群的[管理项目](../user/clusters/management_project.md) ID                                 |
| `enabled`                                   | 布尔值       | 否       | 决定集群是否启用                                                                           |
| `managed`                                   | 布尔值       | 否       | 决定极狐GitLab是否管理此集群的命名空间和服务账户                                               |
| `platform_kubernetes_attributes[api_url]`   | 字符串       | 否       | 访问 Kubernetes API 的 URL                                                                 |
| `platform_kubernetes_attributes[token]`     | 字符串       | 否       | 用于在 Kubernetes 中进行身份验证的令牌                                                       |
| `platform_kubernetes_attributes[ca_cert]`   | 字符串       | 否       | TLS 证书。如果 API 使用自签名 TLS 证书，则为必需项。                                          |
| `platform_kubernetes_attributes[namespace]` | 字符串       | 否       | 与项目相关的唯一命名空间                                                                   |
| `environment_scope`                         | 字符串       | 否       | 与集群关联的环境                                                                           |

> [!note]
> 仅当集群是通过[“添加现有 Kubernetes 集群”](../user/project/clusters/add_existing_cluster.md)选项或通过[“向项目添加现有集群”](#add-a-cluster-to-a-project)端点添加时，才能更新 `name`、`api_url`、`ca_cert` 和 `token`。

请求示例：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type:application/json" \
  --data '{"name":"new-cluster-name","domain":"new-domain.com","api_url":"https://new-api-url.com"}' \
  --url "https://gitlab.example.com/api/v4/projects/26/clusters/24"
```

响应示例：

```json
{
  "id":24,
  "name":"new-cluster-name",
  "domain":"new-domain.com",
  "created_at":"2019-01-03T21:53:40.610Z",
  "managed": true,
  "enabled": true,
  "provider_type":"user",
  "platform_type":"kubernetes",
  "environment_scope":"*",
  "cluster_type":"project_type",
  "user":
  {
    "id":1,
    "name":"Administrator",
    "username":"root",
    "state":"active",
    "avatar_url":"https://www.gravatar.com/avatar/4249f4df72b..",
    "web_url":"https://gitlab.example.com/root"
  },
  "platform_kubernetes":
  {
    "api_url":"https://new-api-url.com",
    "namespace":"cluster-5-namespace",
    "authorization_type":"rbac",
    "ca_cert":null
  },
  "management_project":
  {
    "id":2,
    "description":null,
    "name":"project2",
    "name_with_namespace":"John Doe8 / project2",
    "path":"project2",
    "path_with_namespace":"namespace2/project2",
    "created_at":"2019-10-11T02:55:54.138Z"
  },
  "project":
  {
    "id":26,
    "description":"",
    "name":"project-with-clusters-api",
    "name_with_namespace":"Administrator / project-with-clusters-api",
    "path":"project-with-clusters-api",
    "path_with_namespace":"root/project-with-clusters-api",
    "created_at":"2019-01-02T20:13:32.600Z",
    "default_branch":null,
    "tag_list":[], // 已弃用，请使用 `topics` 代替
    "topics":[],
    "ssh_url_to_repo":"ssh:://gitlab.example.com/root/project-with-clusters-api.git",
    "http_url_to_repo":"https://gitlab.example.com/root/project-with-clusters-api.git",
    "web_url":"https://gitlab.example.com/root/project-with-clusters-api",
    "readme_url":null,
    "avatar_url":null,
    "star_count":0,
    "forks_count":0,
    "last_activity_at":"2019-01-02T20:13:32.600Z",
    "namespace":
    {
      "id":1,
      "name":"root",
      "path":"root",
      "kind":"user",
      "full_path":"root",
      "parent_id":null
    }
  }
}
```

<a id="delete-cluster-from-a-project"></a>

## 从项目中删除集群

从项目中删除指定集群。此操作不会删除已连接 Kubernetes 集群中的现有资源。

```plaintext
DELETE /projects/:id/clusters/:cluster_id
```

参数说明：

| 属性         | 类型         | 是否必需 | 描述                                                         |
| ------------ | ------------ | -------- | ------------------------------------------------------------ |
| `id`         | 整数或字符串 | 是       | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `cluster_id` | 整数         | 是       | 集群的 ID                                                    |

请求示例：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/26/clusters/23"
```