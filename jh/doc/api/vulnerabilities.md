---
stage: Security Risk Management
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 漏洞 API
description: 使用 REST API 管理极狐GitLab 漏洞（已弃用）。支持获取、确认、解决、关闭和撤销操作。请改用 GraphQL。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- `last_edited_at` 在极狐GitLab 16.7 中弃用。
- `start_date` 在极狐GitLab 16.7 中弃用。
- `updated_by_id` 在极狐GitLab 16.7 中弃用。
- `last_edited_by_id` 在极狐GitLab 16.7 中弃用。
- `due_date` 在极狐GitLab 16.7 中弃用。

{{< /history >}}

> [!note]
> 之前的漏洞 API 已重命名为漏洞发现 API，其文档已移至[不同位置](vulnerability_findings.md)。
> 本文档描述了新的漏洞 API，该 API 提供对 [漏洞](https://jihulab.com/groups/gitlab-org/-/epics/634) 的访问。

每次对漏洞的 API 调用都必须[认证](rest/authentication.md)。

如果经过认证的用户没有[查看漏洞报告](../user/permissions.md#project-application-security)的权限，
此请求将返回 `403 Forbidden` 状态码。

> [!warning]
> 此 API 正在弃用过程中且不稳定。
> 响应负载可能在不同极狐GitLab 版本中发生变化或中断。请使用
> [GraphQL API](graphql/reference/_index.md#queryvulnerabilities) 代替。更多信息，请参见 [GraphQL 示例](#replace-vulnerability-rest-api-with-graphql)。

<a id="retrieve-a-vulnerability"></a>

## 获取漏洞

获取指定的漏洞。

```plaintext
GET /vulnerabilities/:id
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer 或 string | 是 | 要获取的漏洞 ID |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/vulnerabilities/1"
```

示例响应：

```json
{
  "id": 1,
  "title": "Predictable pseudorandom number generator",
  "description": null,
  "state": "opened",
  "severity": "medium",
  "confidence": "medium",
  "report_type": "sast",
  "project": {
    "id": 32,
    "name": "security-reports",
    "full_path": "/gitlab-examples/security/security-reports",
    "full_name": "gitlab-examples / security / security-reports"
  },
  "author_id": 1,
  "closed_by_id": null,
  "created_at": "2019-10-13T15:08:40.219Z",
  "updated_at": "2019-10-13T15:09:40.382Z",
  "closed_at": null
}
```

<a id="confirm-a-vulnerability"></a>

## 确认漏洞

确认指定的漏洞。如果漏洞已被确认，则返回状态码 `304`。

如果经过认证的用户没有[更改漏洞状态](../user/permissions.md#project-application-security)的权限，
此请求将返回 `403` 状态码。

```plaintext
POST /vulnerabilities/:id/confirm
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer 或 string | 是 | 要确认的漏洞 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/vulnerabilities/5/confirm"
```

示例响应：

```json
{
  "id": 2,
  "title": "Predictable pseudorandom number generator",
  "description": null,
  "state": "confirmed",
  "severity": "medium",
  "confidence": "medium",
  "report_type": "sast",
  "project": {
    "id": 32,
    "name": "security-reports",
    "full_path": "/gitlab-examples/security/security-reports",
    "full_name": "gitlab-examples / security / security-reports"
  },
  "author_id": 1,
  "closed_by_id": null,
  "created_at": "2019-10-13T15:08:40.219Z",
  "updated_at": "2019-10-13T15:09:40.382Z",
  "closed_at": null
}
```

<a id="resolve-a-vulnerability"></a>

## 解决漏洞

解决指定的漏洞。如果漏洞已被解决，则返回状态码 `304`。

如果经过认证的用户没有[更改漏洞状态](../user/permissions.md#project-application-security)的权限，
此请求将返回 `403` 状态码。

```plaintext
POST /vulnerabilities/:id/resolve
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer 或 string | 是 | 要解决的漏洞 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/vulnerabilities/5/resolve"
```

示例响应：

```json
{
  "id": 2,
  "title": "Predictable pseudorandom number generator",
  "description": null,
  "state": "resolved",
  "severity": "medium",
  "confidence": "medium",
  "report_type": "sast",
  "project": {
    "id": 32,
    "name": "security-reports",
    "full_path": "/gitlab-examples/security/security-reports",
    "full_name": "gitlab-examples / security / security-reports"
  },
  "author_id": 1,
  "closed_by_id": null,
  "created_at": "2019-10-13T15:08:40.219Z",
  "updated_at": "2019-10-13T15:09:40.382Z",
  "closed_at": null
}
```

<a id="dismiss-a-vulnerability"></a>

## 关闭漏洞

关闭指定的漏洞。如果漏洞已被关闭，则返回状态码 `304`。

如果经过认证的用户没有[更改漏洞状态](../user/permissions.md#project-application-security)的权限，
此请求将返回 `403` 状态码。

```plaintext
POST /vulnerabilities/:id/dismiss
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer 或 string | 是 | 要关闭的漏洞 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/vulnerabilities/5/dismiss"
```

示例响应：

```json
{
  "id": 2,
  "title": "Predictable pseudorandom number generator",
  "description": null,
  "state": "closed",
  "severity": "medium",
  "confidence": "medium",
  "report_type": "sast",
  "project": {
    "id": 32,
    "name": "security-reports",
    "full_path": "/gitlab-examples/security/security-reports",
    "full_name": "gitlab-examples / security / security-reports"
  },
  "author_id": 1,
  "closed_by_id": null,
  "created_at": "2019-10-13T15:08:40.219Z",
  "updated_at": "2019-10-13T15:09:40.382Z",
  "closed_at": null
}
```

<a id="revert-a-vulnerability-to-the-detected-state"></a>

## 将漏洞恢复为已检测状态

将指定漏洞恢复为已检测状态。如果漏洞已处于已检测状态，则返回状态码 `304`。

如果经过认证的用户没有[更改漏洞状态](../user/permissions.md#project-application-security)的权限，
此请求将返回 `403` 状态码。

```plaintext
POST /vulnerabilities/:id/revert
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer 或 string | 是 | 要恢复为已检测状态的漏洞 ID |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/vulnerabilities/5/revert"
```

示例响应：

```json
{
  "id": 2,
  "title": "Predictable pseudorandom number generator",
  "description": null,
  "state": "detected",
  "severity": "medium",
  "confidence": "medium",
  "report_type": "sast",
  "project": {
    "id": 32,
    "name": "security-reports",
    "full_path": "/gitlab-examples/security/security-reports",
    "full_name": "gitlab-examples / security / security-reports"
  },
  "author_id": 1,
  "closed_by_id": null,
  "created_at": "2019-10-13T15:08:40.219Z",
  "updated_at": "2019-10-13T15:09:40.382Z",
  "closed_at": null
}
```

<a id="replace-vulnerability-rest-api-with-graphql"></a>

## 使用 GraphQL 替代漏洞 REST API

为了准备漏洞 REST API 端点的[即将弃用](https://gitlab.com/groups/gitlab-org/-/epics/5118)，请使用以下示例通过 GraphQL API 执行等效操作。

<a id="graphql---single-vulnerability"></a>

### GraphQL - 单个漏洞

使用 [`Query.vulnerability`](graphql/reference/_index.md#queryvulnerability)。

```graphql
{
  vulnerability(id: "gid://gitlab/Vulnerability/20345379") {
    title
    description
    state
    severity
    reportType
    project {
      id
      name
      fullPath
    }
    detectedAt
    confirmedAt
    resolvedAt
    resolvedBy {
      id
      username
    }
  }
}
```

示例响应：

```json
{
  "data": {
    "vulnerability": {
      "title": "Improper Input Validation in railties",
      "description": "A remote code execution vulnerability in development mode Rails beta3 can allow an attacker to guess the automatically generated development mode secret token. This secret token can be used in combination with other Rails internals to escalate to a remote code execution exploit.",
      "state": "RESOLVED",
      "severity": "CRITICAL",
      "reportType": "DEPENDENCY_SCANNING",
      "project": {
        "id": "gid://gitlab/Project/6102100",
        "name": "security-reports",
        "fullPath": "gitlab-examples/security/security-reports"
      },
      "detectedAt": "2021-10-14T03:13:41Z",
      "confirmedAt": "2021-12-14T01:45:56Z",
      "resolvedAt": "2021-12-14T01:45:59Z",
      "resolvedBy": {
        "id": "gid://gitlab/User/480804",
        "username": "thiagocsf"
      }
    }
  }
}
```

<a id="graphql---confirm-vulnerability"></a>

### GraphQL - 确认漏洞

使用 [`Mutation.vulnerabilityConfirm`](graphql/reference/_index.md#mutationvulnerabilityconfirm)。

```graphql
mutation {
  vulnerabilityConfirm(input: { id: "gid://gitlab/Vulnerability/23577695"}) {
    vulnerability {
      state
    }
    errors
  }
}
```

示例响应：

```json
{
  "data": {
    "vulnerabilityConfirm": {
      "vulnerability": {
        "state": "CONFIRMED"
      },
      "errors": []
    }
  }
}
```

<a id="graphql---resolve-vulnerability"></a>

### GraphQL - 解决漏洞

使用 [`Mutation.vulnerabilityResolve`](graphql/reference/_index.md#mutationvulnerabilityresolve)。

```graphql
mutation {
  vulnerabilityResolve(input: { id: "gid://gitlab/Vulnerability/23577695"}) {
    vulnerability {
      state
    }
    errors
  }
}
```

示例响应：

```json
{
  "data": {
    "vulnerabilityConfirm": {
      "vulnerability": {
        "state": "RESOLVED"
      },
      "errors": []
    }
  }
}
```

<a id="graphql---dismiss-vulnerability"></a>

### GraphQL - 关闭漏洞

使用 [`Mutation.vulnerabilityDismiss`](graphql/reference/_index.md#mutationvulnerabilitydismiss)。

```graphql
mutation {
  vulnerabilityDismiss(input: { id: "gid://gitlab/Vulnerability/23577695"}) {
    vulnerability {
      state
    }
    errors
  }
}
```

示例响应：

```json
{
  "data": {
    "vulnerabilityConfirm": {
      "vulnerability": {
        "state": "DISMISSED"
      },
      "errors": []
    }
  }
}
```

<a id="graphql---revert-vulnerability-to-the-detected-state"></a>

### GraphQL - 将漏洞恢复为已检测状态

使用 [`Mutation.vulnerabilityRevertToDetected`](graphql/reference/_index.md#mutationvulnerabilityreverttodetected)。

```graphql
mutation {
  vulnerabilityRevertToDetected(input: { id: "gid://gitlab/Vulnerability/20345379"}) {
    vulnerability {
      state
    }
    errors
  }
}
```

示例响应：

```json
{
  "data": {
    "vulnerabilityConfirm": {
      "vulnerability": {
        "state": "DETECTED"
      },
      "errors": []
    }
  }
}
```