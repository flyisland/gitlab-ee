---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Manage audit event streaming destinations for entire GitLab instances using the GraphQL API, including HTTP and Google Cloud Logging configurations.
title: 实例审计事件流 GraphQL API
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 引入自极狐GitLab 16.0，使用功能标志 `ff_external_audit_events`。默认禁用。
- 实例级流目标的自定义 HTTP 头 API 引入自极狐GitLab 16.1，使用功能标志 `ff_external_audit_events`。默认禁用。
- 功能标志 `ff_external_audit_events` 在极狐GitLab 16.2 中默认启用。
- 用户指定目标名称 API 支持引入自极狐GitLab 16.2。
- 实例流目标在极狐GitLab 16.4 中正式发布。功能标志 `ff_external_audit_events` 已移除。

{{< /history >}}

使用 GraphQL API 管理实例的审计事件流目标。

<a id="http-destinations"></a>

## HTTP 目的地

管理整个实例的 HTTP 流目标。

<a id="add-a-new-http-destination"></a>

### 添加新的 HTTP 目的地

向实例添加新的 HTTP 流目标。

前提条件：

- 在实例上具有管理员访问权限。

要启用流并添加目标，请在 GraphQL API 中使用
`instanceExternalAuditEventDestinationCreate` mutation。

```graphql
mutation {
  instanceExternalAuditEventDestinationCreate(input: { destinationUrl: "https://mydomain.io/endpoint/ingest"}) {
    errors
    instanceExternalAuditEventDestination {
      destinationUrl
      id
      name
      verificationToken
    }
  }
}
```

满足以下条件时事件流启用：

- 返回的 `errors` 对象为空。
- API 响应为 `200 OK`。

你也可以使用 GraphQL `instanceExternalAuditEventDestinationCreate` mutation 选择指定自己的目标名称（而不是极狐GitLab 生成的默认名称）。名称长度不得超过 72 个字符且尾随空格不会被修剪。该值应唯一。例如：

```graphql
mutation {
  instanceExternalAuditEventDestinationCreate(input: { destinationUrl: "https://mydomain.io/endpoint/ingest", name: "destination-name-here"}) {
    errors
    instanceExternalAuditEventDestination {
      destinationUrl
      id
      name
      verificationToken
    }
  }
}
```

实例管理员可以使用 GraphQL `auditEventsStreamingInstanceHeadersCreate` mutation 添加 HTTP 标头。你可以通过[列出所有流目标](#list-streaming-destinations)或从上一个 mutation 中获取目标 ID。

```graphql
mutation {
  auditEventsStreamingInstanceHeadersCreate(input:
    {
      destinationId: "gid://gitlab/AuditEvents::InstanceExternalAuditEventDestination/42",
      key: "foo",
      value: "bar",
      active: true
    }) {
    errors
    header {
      id
      key
      value
      active
    }
  }
}
```

如果返回的 `errors` 对象为空，则标头创建成功。

<a id="list-streaming-destinations"></a>

### 列出流目标

列出实例的所有 HTTP 流目标。

前提条件：

- 在实例上具有管理员访问权限。

要查看实例的流目标列表，请使用
`instanceExternalAuditEventDestinations` 查询类型。

```graphql
query {
  instanceExternalAuditEventDestinations {
    nodes {
      id
      name
      destinationUrl
      verificationToken
      headers {
        nodes {
          id
          key
          value
          active
        }
      }
      eventTypeFilters
    }
  }
}
```

如果结果列表为空，则表示实例未启用审计流。

你需要将此查询返回的 ID 值用于更新和删除 mutation。

<a id="update-streaming-destinations"></a>

### 更新流目标

更新实例的 HTTP 流目标。

前提条件：

- 在实例上具有管理员访问权限。

要更新实例的流目标，请使用
`instanceExternalAuditEventDestinationUpdate` mutation 类型。你可以通过[列出所有外部目标](#list-streaming-destinations)获取目标 ID。

```graphql
mutation {
  instanceExternalAuditEventDestinationUpdate(input: {
    id: "gid://gitlab/AuditEvents::InstanceExternalAuditEventDestination/1",
    destinationUrl: "https://www.new-domain.com/webhook",
    name: "destination-name"}) {
    errors
    instanceExternalAuditEventDestination {
      destinationUrl
      id
      name
      verificationToken
    }
  }
}
```

满足以下条件时流目标更新：

- 返回的 `errors` 对象为空。
- API 响应为 `200 OK`。

实例管理员可以使用 `auditEventsStreamingInstanceHeadersUpdate` mutation 类型更新流目标的自定义 HTTP 标头。你可以通过[列出所有自定义 HTTP 标头](#list-streaming-destinations)获取标头 ID。

```graphql
mutation {
  auditEventsStreamingInstanceHeadersUpdate(input: { headerId: "gid://gitlab/AuditEvents::Streaming::InstanceHeader/2", key: "new-key", value: "new-value", active: false }) {
    errors
    header {
      id
      key
      value
      active
    }
  }
}
```

如果返回的 `errors` 对象为空，则标头更新成功。

<a id="delete-streaming-destinations"></a>

### 删除流目标

删除整个实例的流目标。

成功删除最后一个目标后，实例的流将禁用。

前提条件：

- 在实例上具有管理员访问权限。

要删除流目标，请使用
`instanceExternalAuditEventDestinationDestroy` mutation 类型。你可以通过[列出所有流目标](#list-streaming-destinations)获取目标 ID。

```graphql
mutation {
  instanceExternalAuditEventDestinationDestroy(input: { id: "gid://gitlab/AuditEvents::InstanceExternalAuditEventDestination/1" }) {
    errors
  }
}
```

满足以下条件时流目标删除：

- 返回的 `errors` 对象为空。
- API 响应为 `200 OK`。

要删除 HTTP 标头，请使用 GraphQL `auditEventsStreamingInstanceHeadersDestroy` mutation。
要检索标头 ID，请[列出所有自定义 HTTP 标头](#list-streaming-destinations)。

```graphql
mutation {
  auditEventsStreamingInstanceHeadersDestroy(input: { headerId: "gid://gitlab/AuditEvents::Streaming::InstanceHeader/<id>" }) {
    errors
  }
}
```

如果返回的 `errors` 对象为空，则标头删除成功。

<a id="event-type-filters"></a>

### 事件类型过滤器

{{< history >}}

- 事件类型过滤器 API [引入自极狐GitLab 16.2](https://gitlab.com/groups/gitlab-org/-/epics/10868) 在极狐GitLab 16.2。

{{< /history >}}

当为实例启用此功能时，你可以使用 API 允许用户针对每个目标过滤流式审计事件。
如果在没有过滤的情况下启用此功能，则目标将接收所有审计事件。

设置了事件类型过滤器的流目标会显示 **filtered**（{{< icon name="filter" >}}）标签。

#### 使用 API 添加事件类型过滤器

前提条件：

- 你必须具有实例的管理员访问权限。

你可以使用 `auditEventsStreamingDestinationInstanceEventsAdd` mutation 添加事件类型过滤器列表：

```graphql
mutation {
    auditEventsStreamingDestinationInstanceEventsAdd(input: {
        destinationId: "gid://gitlab/AuditEvents::InstanceExternalAuditEventDestination/1",
        eventTypeFilters: ["list of event type filters"]}){
        errors
        eventTypeFilters
    }
}
```

满足以下条件时事件类型过滤器添加成功：

- 返回的 `errors` 对象为空。
- API 响应为 `200 OK`。

#### 使用 API 移除事件类型过滤器

前提条件：

- 你必须具有实例的管理员访问权限。

你可以使用 `auditEventsStreamingDestinationInstanceEventsRemove` mutation 移除事件类型过滤器列表：

```graphql
mutation {
    auditEventsStreamingDestinationInstanceEventsRemove(input: {
    destinationId: "gid://gitlab/AuditEvents::InstanceExternalAuditEventDestination/1",
    eventTypeFilters: ["list of event type filters"]
  }){
    errors
  }
}
```

满足以下条件时事件类型过滤器移除成功：

- 返回的 `errors` 对象为空。
- API 响应为 `200 OK`。
