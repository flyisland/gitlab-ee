---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组集群 API（基于证书）（已废弃）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能在极狐GitLab 14.5 中已[废弃](https://gitlab.com/groups/gitlab-org/configure/-/epics/8)。

与[项目级别](../user/project/clusters/_index.md)和
[实例级别](../user/instance/clusters/_index.md)的 Kubernetes 集群类似，
群组级别的 Kubernetes 集群允许你将 Kubernetes 集群连接到
你的群组，从而可以在多个项目中使用同一个集群。

用户需要拥有该群组的维护者或所有者角色才能使用这些端点。

## 列出群组集群

<a id="list-group-clusters"></a>

列出指定群组的所有群组集群。

```plaintext
GET /groups/:id/clusters
```

参数：

| 属性    | 类型           | 是否必填 | 描述                                                                   |
| --------- | -------------- | -------- | ----------------------------------------------------------------------------- |
| `id`      | integer 或 string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/26/clusters"
```

示例响应：

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
    "cluster_type":"group_type",
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

## 获取一个群组集群

<a id="retrieve-a-group-cluster"></a>

获取一个指定的群组集群。

```plaintext
GET /groups/:id/clusters/:cluster_id
```

参数：

| 属性    | 类型           | 是否必填 | 描述                                                                   |
| ------------ | -------------- | -------- | ----------------------------------------------------------------------------- |
| `id`         | integer 或 string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `cluster_id` | integer        | 是      | 集群的 ID                                                        |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/26/clusters/18"
```

示例响应：

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
  "cluster_type":"group_type",
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
  "group":
  {
    "id":26,
    "name":"group-with-clusters-api",
    "web_url":"https://gitlab.example.com/group-with-clusters-api"
  }
}
```

## 创建一个群组集群

<a id="create-a-group-cluster"></a>

通过添加一个已有的 Kubernetes 集群，为指定群组创建一个群组集群。

```plaintext
POST /groups/:id/clusters/user
```

参数：

| 属性                                            | 类型           | 是否必填 | 描述                                                                                         |
| ---------------------------------------------------- | -------------- | -------- | --------------------------------------------------------------------------------------------------- |
| `id`                                                 | integer 或 string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)                       |
| `name`                                               | string         | 是      | 集群的名称                                                                             |
| `domain`                                             | string         | 否       | 集群的[基础域名](../user/group/clusters/_index.md#base-domain)                       |
| `management_project_id`                              | integer        | 否       | 集群的[管理项目](../user/clusters/management_project.md)的 ID          |
| `enabled`                                            | boolean        | 否       | 决定集群是否处于活跃状态，默认为 `true`                                            |
| `managed`                                            | boolean        | 否       | 决定极狐GitLab是否为该集群管理命名空间和服务账户。默认为 `true` |
| `platform_kubernetes_attributes[api_url]`            | string         | 是      | 访问 Kubernetes API 的 URL                                                               |
| `platform_kubernetes_attributes[token]`              | string         | 是      | 用于 Kubernetes 认证的令牌                                                     |
| `platform_kubernetes_attributes[ca_cert]`            | string         | 否       | TLS 证书。如果 API 使用自签名 TLS 证书，则此属性为必填。                          |
| `platform_kubernetes_attributes[authorization_type]` | string         | 否       | 集群授权类型：`rbac`、`abac` 或 `unknown_authorization`。默认为 `rbac`。      |
| `environment_scope`                                  | string         | 否       | 与集群关联的环境。默认为 `*`。仅限专业版和旗舰版。              |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Accept: application/json" \
  --header "Content-Type:application/json" \
  --url "https://gitlab.example.com/api/v4/groups/26/clusters/user" \
  --data '{
    "name":"cluster-5",
    "platform_kubernetes_attributes":{
      "api_url":"https://35.111.51.20",
      "token":"12345",
      "ca_cert":"-----BEGIN CERTIFICATE-----\r\nhFiK1L61owwDQYJKoZIhvcNAQELBQAw\r\nLzEtMCsGA1UEAxMkZDA1YzQ1YjctNzdiMS00NDY0LThjNmEtMTQ0ZDJkZjM4ZDBj\r\nMB4XDTE4MTIyNzIwMDM1MVoXDTIzMTIyNjIxMDM1MVowLzEtMCsGA1UEAxMkZDA1\r\nYzQ1YjctNzdiMS00NDY0LThjNmEtMTQ0ZDJkZjM.......-----END CERTIFICATE-----"
    }
  }'
```

示例响应：

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
  "cluster_type":"group_type",
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
    "authorization_type":"rbac",
    "ca_cert":"-----BEGIN CERTIFICATE-----\r\nhFiK1L61owwDQYJKoZIhvcNAQELBQAw\r\nLzEtMCsGA1UEAxMkZDA1YzQ1YjctNzdiMS00NDY0LThjNmEtMTQ0ZDJkZjM4ZDBj\r\nMB4XDTE4MTIyNzIwMDM1MVoXDTIzMTIyNjIxMDM1MVowLzEtMCsGA1UEAxMkZDA1\r\nYzQ1YjctNzdiMS00NDY0LThjNmEtMTQ0ZDJkZjM.......-----END CERTIFICATE-----"
  },
  "management_project":null,
  "group":
  {
    "id":26,
    "name":"group-with-clusters-api",
    "web_url":"https://gitlab.example.com/root/group-with-clusters-api"
  }
}
```

## 更新一个群组集群

<a id="update-a-group-cluster"></a>

更新一个指定的群组集群。

```plaintext
PUT /groups/:id/clusters/:cluster_id
```

参数：

| 属性                                 | 类型           | 是否必填 | 描述                                                                                |
| ----------------------------------------- | -------------- | -------- | ------------------------------------------------------------------------------------------ |
| `id`                                      | integer 或 string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)              |
| `cluster_id`                              | integer        | 是      | 集群的 ID                                                                      |
| `name`                                    | string         | 否       | 集群的名称                                                                    |
| `domain`                                  | string         | 否       | 集群的[基础域名](../user/group/clusters/_index.md#base-domain)              |
| `management_project_id`                   | integer        | 否       | 集群的[管理项目](../user/clusters/management_project.md)的 ID |
| `enabled`                                 | boolean        | 否       | 决定集群是否处于活跃状态                                                     |
| `managed`                                 | boolean        | 否       | 决定极狐GitLab是否为该集群管理命名空间和服务账户          |
| `platform_kubernetes_attributes[api_url]` | string         | 否       | 访问 Kubernetes API 的 URL                                                       |
| `platform_kubernetes_attributes[token]`   | string         | 否       | 用于 Kubernetes 认证的令牌                                               |
| `platform_kubernetes_attributes[ca_cert]` | string         | 否       | TLS 证书。如果 API 使用自签名 TLS 证书，则此属性为必填。                  |
| `environment_scope`                       | string         | 否       | 与集群关联的环境。仅限专业版和旗舰版。                      |

> [!note]
> `name`、`api_url`、`ca_cert` 和 `token` 仅当集群是通过
> [“添加现有 Kubernetes 集群”](../user/project/clusters/add_existing_cluster.md)选项或
> [“创建一个群组集群”](#create-a-group-cluster)端点添加时，才能被更新。

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type:application/json" \
  --url "https://gitlab.example.com/api/v4/groups/26/clusters/24" \
  --data '{
    "name":"new-cluster-name",
    "domain":"new-domain.com",
    "platform_kubernetes_attributes":{
      "api_url":"https://10.10.101.1:6433"
    }
  }'
```

示例响应：

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
  "cluster_type":"group_type",
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
  "group":
  {
    "id":26,
    "name":"group-with-clusters-api",
    "web_url":"https://gitlab.example.com/group-with-clusters-api"
  }
}
```

## 删除一个群组集群

<a id="delete-a-group-cluster"></a>

删除一个指定的群组集群。不会删除已连接的 Kubernetes 集群中的现有资源。

```plaintext
DELETE /groups/:id/clusters/:cluster_id
```

参数：

| 属性    | 类型           | 是否必填 | 描述                                                                   |
| ------------ | -------------- | -------- | ----------------------------------------------------------------------------- |
| `id`         | integer 或 string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `cluster_id` | integer        | 是      | 集群的 ID                                                        |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/26/clusters/23"
```