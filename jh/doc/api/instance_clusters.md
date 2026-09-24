---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 实例集群 API（基于证书）（已弃用）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 该功能在极狐GitLab 14.5 中已弃用。

通过[实例级 Kubernetes 集群](../user/instance/clusters/_index.md)，你可以将 Kubernetes 集群连接到极狐GitLab 实例，并在实例内的所有项目中使用同一个集群。

用户需要管理员权限才能使用这些端点。

<a id="list-instance-clusters"></a>

## 列出实例集群

列出所有实例集群。

```plaintext
GET /admin/clusters
```

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/admin/clusters"
```

示例响应：

```json
[
  {
    "id": 9,
    "name": "cluster-1",
    "created_at": "2020-07-14T18:36:10.440Z",
    "managed": true,
    "enabled": true,
    "domain": null,
    "provider_type": "user",
    "platform_type": "kubernetes",
    "environment_scope": "*",
    "cluster_type": "instance_type",
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/root"
    },
    "platform_kubernetes": {
      "api_url": "https://example.com",
      "namespace": null,
      "authorization_type": "rbac",
      "ca_cert":"-----BEGIN CERTIFICATE-----IxMDM1MV0ZDJkZjM...-----END CERTIFICATE-----"
    },
    "provider_gcp": null,
    "management_project": null
  },
  {
    "id": 10,
    "name": "cluster-2",
    "created_at": "2020-07-14T18:39:05.383Z",
    "domain": null,
    "provider_type": "user",
    "platform_type": "kubernetes",
    "environment_scope": "staging",
    "cluster_type": "instance_type",
    "user": {
      "id": 1,
      "name": "Administrator",
      "username": "root",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
      "web_url": "https://gitlab.example.com/root"
    },
    "platform_kubernetes": {
      "api_url": "https://example.com",
      "namespace": null,
      "authorization_type": "rbac",
      "ca_cert":"-----BEGIN CERTIFICATE-----LzEtMCadtaLGxcsGAZjM...-----END CERTIFICATE-----"
    },
    "provider_gcp": null,
    "management_project": null
  },
  {
    "id": 11,
    "name": "cluster-3",
    ...
  }
]
```

<a id="retrieve-a-single-instance-cluster"></a>

## 获取单个实例集群

获取单个实例集群。

参数：

| 属性          | 类型    | 必需 | 描述               |
| ------------ | ------- | ---- | ----------------- |
| `cluster_id` | integer | 是   | 集群的 ID           |

```plaintext
GET /admin/clusters/:cluster_id
```

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/admin/clusters/9"
```

示例响应：

```json
{
  "id": 9,
  "name": "cluster-1",
  "created_at": "2020-07-14T18:36:10.440Z",
  "managed": true,
  "enabled": true,
  "domain": null,
  "provider_type": "user",
  "platform_type": "kubernetes",
  "environment_scope": "*",
  "cluster_type": "instance_type",
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/root"
  },
  "platform_kubernetes": {
    "api_url": "https://example.com",
    "namespace": null,
    "authorization_type": "rbac",
    "ca_cert":"-----BEGIN CERTIFICATE-----IxMDM1MV0ZDJkZjM...-----END CERTIFICATE-----"
  },
  "provider_gcp": null,
  "management_project": null
}
```

<a id="create-an-instance-cluster"></a>

## 创建实例集群

通过添加现有 Kubernetes 集群来创建实例集群。

```plaintext
POST /admin/clusters/add
```

参数：

| 属性                                                  | 类型    | 必需 | 描述                                                                                     |
| ---------------------------------------------------- | ------- | ---- | --------------------------------------------------------------------------------------- |
| `name`                                               | string  | 是   | 集群的名称                                                                               |
| `domain`                                             | string  | 否   | 集群的[基础域名](../user/project/clusters/gitlab_managed_clusters.md#base-domain)                       |
| `environment_scope`                                  | string  | 否   | 集群关联的环境，默认为 `*`                                                            |
| `management_project_id`                              | integer | 否   | 集群的[管理项目](../user/clusters/management_project.md) ID                             |
| `enabled`                                            | boolean | 否   | 确定集群是否处于活动状态，默认为 `true`                                                |
| `managed`                                            | boolean | 否   | 确定极狐GitLab 是否为此集群管理命名空间和服务账户，默认为 `true`                        |
| `platform_kubernetes_attributes[api_url]`            | string  | 是   | 访问 Kubernetes API 的 URL                                                                 |
| `platform_kubernetes_attributes[token]`              | string  | 是   | 用于 Kubernetes 认证的令牌                                                                 |
| `platform_kubernetes_attributes[ca_cert]`            | string  | 否   | TLS 证书。如果 API 使用自签名 TLS 证书，则此字段为必需                                     |
| `platform_kubernetes_attributes[namespace]`          | string  | 否   | 与项目相关的唯一命名空间                                                                   |
| `platform_kubernetes_attributes[authorization_type]` | string  | 否   | 集群授权类型：`rbac`、`abac` 或 `unknown_authorization`，默认为 `rbac`                     |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --data '{"name":"cluster-3", "environment_scope":"production", "platform_kubernetes_attributes":{"api_url":"https://example.com", "token":"12345", "ca_cert":"-----BEGIN CERTIFICATE-----qpoeiXXZafCM0ZDJkZjM...-----END CERTIFICATE-----"}}' \
  --url "http://gitlab.example.com/api/v4/admin/clusters/add"
```

示例响应：

```json
{
  "id": 11,
  "name": "cluster-3",
  "created_at": "2020-07-14T18:42:50.805Z",
  "managed": true,
  "enabled": true,
  "domain": null,
  "provider_type": "user",
  "platform_type": "kubernetes",
  "environment_scope": "production",
  "cluster_type": "instance_type",
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "http://gitlab.example.com:3000/root"
  },
  "platform_kubernetes": {
    "api_url": "https://example.com",
    "namespace": null,
    "authorization_type": "rbac",
    "ca_cert":"-----BEGIN CERTIFICATE-----qpoeiXXZafCM0ZDJkZjM...-----END CERTIFICATE-----"
  },
  "provider_gcp": null,
  "management_project": null
}
```

<a id="update-an-instance-cluster"></a>

## 更新实例集群

更新现有的实例集群。

```plaintext
PUT /admin/clusters/:cluster_id
```

参数：

| 属性                                       | 类型    | 必需 | 描述                                                                   |
| ------------------------------------------- | ------- | ---- | ---------------------------------------------------------------------- |
| `cluster_id`                                | integer | 是   | 集群的 ID                                                              |
| `name`                                      | string  | 否   | 集群的名称                                                             |
| `domain`                                    | string  | 否   | 集群的[基础域名](../user/project/clusters/gitlab_managed_clusters.md#base-domain) |
| `environment_scope`                         | string  | 否   | 集群关联的环境                                                         |
| `management_project_id`                     | integer | 否   | 集群的[管理项目](../user/clusters/management_project.md) ID             |
| `enabled`                                   | boolean | 否   | 确定集群是否处于活动状态                                               |
| `managed`                                   | boolean | 否   | 确定极狐GitLab 是否为此集群管理命名空间和服务账户                       |
| `platform_kubernetes_attributes[api_url]`   | string  | 否   | 访问 Kubernetes API 的 URL                                             |
| `platform_kubernetes_attributes[token]`     | string  | 否   | 用于 Kubernetes 认证的令牌                                             |
| `platform_kubernetes_attributes[ca_cert]`   | string  | 否   | TLS 证书。如果 API 使用自签名 TLS 证书，则此字段为必需                 |
| `platform_kubernetes_attributes[namespace]` | string  | 否   | 与项目相关的唯一命名空间                                               |

> [!note]
> `name`、`api_url`、`ca_cert` 和 `token` 仅当集群是通过
> [添加现有 Kubernetes 集群](../user/project/clusters/add_existing_cluster.md) 选项或通过
> [创建实例集群](#create-an-instance-cluster) 端点添加时才能更新。

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{"name":"update-cluster-name", "platform_kubernetes_attributes":{"api_url":"https://new-example.com","token":"new-token"}}' \
  --url "http://gitlab.example.com/api/v4/admin/clusters/9"
```

示例响应：

```json
{
  "id": 9,
  "name": "update-cluster-name",
  "created_at": "2020-07-14T18:36:10.440Z",
  "managed": true,
  "enabled": true,
  "domain": null,
  "provider_type": "user",
  "platform_type": "kubernetes",
  "environment_scope": "*",
  "cluster_type": "instance_type",
  "user": {
    "id": 1,
    "name": "Administrator",
    "username": "root",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon",
    "web_url": "https://gitlab.example.com/root"
  },
  "platform_kubernetes": {
    "api_url": "https://new-example.com",
    "namespace": null,
    "authorization_type": "rbac",
    "ca_cert":"-----BEGIN CERTIFICATE-----IxMDM1MV0ZDJkZjM...-----END CERTIFICATE-----"
  },
  "provider_gcp": null,
  "management_project": null,
  "project": null
}
```

<a id="delete-instance-cluster"></a>

## 删除实例集群

删除现有的实例集群。不会删除已连接 Kubernetes 集群中的现有资源。

```plaintext
DELETE /admin/clusters/:cluster_id
```

参数：

| 属性          | 类型    | 必需 | 描述       |
| ------------ | ------- | ---- | --------- |
| `cluster_id` | integer | 是   | 集群的 ID  |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/admin/clusters/11"
```