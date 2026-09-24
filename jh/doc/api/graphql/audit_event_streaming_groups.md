---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Manage audit event streaming destinations for top-level groups using the GraphQL API, including HTTP and Google Cloud Logging configurations.
title: 顶级群组的审计事件流 GraphQL API
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 自定义 HTTP 头 API 在极狐GitLab 15.1 中引入，带有一个名为 `streaming_audit_event_headers` 的功能标志。默认禁用。
- 自定义 HTTP 头 API 在极狐GitLab 15.2 中于 JihuLab.com 和私有化部署上启用。
- 自定义 HTTP 头 API 在极狐GitLab 15.3 中 GA。功能标志 `streaming_audit_event_headers` 被移除。
- 用户指定的验证令牌 API 支持在极狐GitLab 15.4 中引入。
- 功能标志 `ff_external_audit_events` 在极狐GitLab 16.2 中默认启用。
- 用户指定的目标名称 API 支持在极狐GitLab 16.2 中引入。
- API 功能标志 `ff_external_audit_events` 在极狐GitLab 16.4 中被移除。

{{< /history >}}

使用 GraphQL API 管理顶级群组的审计事件流目的地。

<a id="http-destinations"></a>

## HTTP 目的地

管理顶级群组的 HTTP 流目的地。

<a id="add-a-new-streaming-destination"></a>

### 添加新的流目的地

向顶级群组添加新的流目的地。

> [!warning]
> 流目的地会接收**所有**审计事件数据，其中可能包含敏感信息。请确保您信任该流目的地。

先决条件：

- 顶级群组的所有者角色。

要启用流并向顶级群组添加目的地，请使用 `externalAuditEventDestinationCreate` 变更。

```graphql
mutation {
  externalAuditEventDestinationCreate(input: { destinationUrl: "https://mydomain.io/endpoint/ingest", groupPath: "my-group" } ) {
    errors
    externalAuditEventDestination {
      id
      name
      destinationUrl
      verificationToken
      group {
        name
      }
    }
  }
}
```

您可以选择使用 GraphQL `externalAuditEventDestinationCreate` 变更指定自己的验证令牌（而不是默认的极狐GitLab 生成的令牌）。验证令牌长度必须在 16 到 24 个字符之间，并且不会修剪尾随空格。您应设置一个加密随机的唯一值。例如：

```graphql
mutation {
  externalAuditEventDestinationCreate(input: { destinationUrl: "https://mydomain.io/endpoint/ingest", groupPath: "my-group", verificationToken: "unique-random-verification-token-here" } ) {
    errors
    externalAuditEventDestination {
      id
      name
      destinationUrl
      verificationToken
      group {
        name
      }
    }
  }
}
```

您可以选择使用 GraphQL `externalAuditEventDestinationCreate` 变更指定自己的目标名称（而不是默认的极狐GitLab 生成的名称）。名称长度不得超过 72 个字符，并且不会修剪尾随空格。此值应在群组范围内唯一。例如：

```graphql
mutation {
  externalAuditEventDestinationCreate(input: { destinationUrl: "https://mydomain.io/endpoint/ingest", name: "destination-name-here", groupPath: "my-group" }) {
    errors
    externalAuditEventDestination {
      id
      name
      destinationUrl
      verificationToken
      group {
        name
      }
    }
  }
}
```

如果满足以下条件，则启用事件流：

- 返回的 `errors` 对象为空。
- API 响应 `200 OK`。

您可以使用 GraphQL `auditEventsStreamingHeadersCreate` 变更添加 HTTP 头。您可以通过[列出所有流目的地](#list-streaming-destinations)或从上面的变更中获取目的地 ID。

```graphql
mutation {
  auditEventsStreamingHeadersCreate(input: {
    destinationId: "gid://gitlab/AuditEvents::ExternalAuditEventDestination/1",
     key: "foo",
     value: "bar",
     active: false
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

如果返回的 `errors` 对象为空，则创建该头。

<a id="list-streaming-destinations"></a>

### 列出流目的地

列出顶级群组的流目的地。

先决条件：

- 顶级群组的所有者角色。

您可以使用 `externalAuditEventDestinations` 查询类型查看顶级群组的流目的地列表。

```graphql
query {
  group(fullPath: "my-group") {
    id
    externalAuditEventDestinations {
      nodes {
        destinationUrl
        verificationToken
        id
        name
        headers {
          nodes {
            key
            value
            id
            active
          }
        }
        eventTypeFilters
        namespaceFilter {
          id
          namespace {
            id
            name
            fullName
          }
        }
      }
    }
  }
}
```

如果结果列表为空，则该群组未启用审计流。

<a id="update-streaming-destinations"></a>

### 更新流目的地

更新顶级群组的流目的地。

先决条件：

- 顶级群组的所有者角色。

要更新群组的流目的地，请使用 `externalAuditEventDestinationUpdate` 变更类型。您可以通过[列出所有流目的地](#list-streaming-destinations)获取目的地 ID。

```graphql
mutation {
  externalAuditEventDestinationUpdate(input: {
    id:"gid://gitlab/AuditEvents::ExternalAuditEventDestination/1",
    destinationUrl: "https://www.new-domain.com/webhook",
    name: "destination-name"} ) {
    errors
    externalAuditEventDestination {
      id
      name
      destinationUrl
      verificationToken
      group {
        name
      }
    }
  }
}
```

如果满足以下条件，则更新流目的地：

- 返回的 `errors` 对象为空。
- API 响应 `200 OK`。

具有群组所有者角色的用户可以使用 `auditEventsStreamingHeadersUpdate` 变更类型更新流目的地的自定义 HTTP 头。您可以通过[列出所有自定义 HTTP 头](#list-streaming-destinations)获取自定义 HTTP 头 ID。

```graphql
mutation {
  auditEventsStreamingHeadersUpdate(input: { headerId: "gid://gitlab/AuditEvents::Streaming::Header/2", key: "new-key", value: "new-value", active: false }) {
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

群组所有者可以使用 GraphQL `auditEventsStreamingHeadersDestroy` 变更移除 HTTP 头。您可以通过[列出所有自定义 HTTP 头](#list-streaming-destinations)获取头 ID。

```graphql
mutation {
  auditEventsStreamingHeadersDestroy(input: { headerId: "gid://gitlab/AuditEvents::Streaming::Header/1" }) {
    errors
  }
}
```

如果返回的 `errors` 对象为空，则删除该头。

<a id="delete-streaming-destinations"></a>

### 删除流目的地

删除顶级群组的流目的地。

当最后一个目的地成功删除后，该群组的流将被禁用。

先决条件：

- 顶级群组的所有者角色。

具有群组所有者角色的用户可以使用 `externalAuditEventDestinationDestroy` 变更类型删除流目的地。您可以通过[列出所有流目的地](#list-streaming-destinations)获取目的地 ID。

```graphql
mutation {
  externalAuditEventDestinationDestroy(input: { id: destination }) {
    errors
  }
}
```

如果满足以下条件，则删除流目的地：

- 返回的 `errors` 对象为空。
- API 响应 `200 OK`。

群组所有者可以使用 GraphQL `auditEventsStreamingHeadersDestroy` 变更移除 HTTP 头。您可以通过[列出所有自定义 HTTP 头](#list-streaming-destinations)获取头 ID。

```graphql
mutation {
  auditEventsStreamingHeadersDestroy(input: { headerId: "gid://gitlab/AuditEvents::Streaming::Header/1" }) {
    errors
  }
}
```

如果返回的 `errors` 对象为空，则删除该头。

<a id="event-type-filters"></a>

### 事件类型过滤器

{{< history >}}

- 事件类型过滤器 API 在极狐GitLab 15.7 中引入。

{{< /history >}}

当为群组启用此功能时，您可以使用 API 允许用户按目的地过滤流式审计事件。如果启用了该功能但没有设置过滤器，则目的地会接收所有审计事件。

设置了事件类型过滤器的流目的地会带有 **filtered** ({{< icon name="filter" >}}) 标签。

<a id="use-the-api-to-add-an-event-type-filter"></a>

#### 使用 API 添加事件类型过滤器

先决条件：

- 您必须具有群组的所有者角色。

您可以使用 `auditEventsStreamingDestinationEventsAdd` 查询类型添加事件类型过滤器列表：

```graphql
mutation {
    auditEventsStreamingDestinationEventsAdd(input: {
        destinationId: "gid://gitlab/AuditEvents::ExternalAuditEventDestination/1",
        eventTypeFilters: ["list of event type filters"]}){
        errors
        eventTypeFilters
    }
}
```

如果满足以下条件，则添加事件类型过滤器：

- 返回的 `errors` 对象为空。
- API 响应 `200 OK`。

<a id="use-the-api-to-remove-an-event-type-filter"></a>

#### 使用 API 移除事件类型过滤器

先决条件：

- 您必须具有群组的所有者角色。

您可以使用 `auditEventsStreamingDestinationEventsRemove` 变更类型移除事件类型过滤器列表：

```graphql
mutation {
    auditEventsStreamingDestinationEventsRemove(input: {
    destinationId: "gid://gitlab/AuditEvents::ExternalAuditEventDestination/1",
    eventTypeFilters: ["list of event type filters"]
  }){
    errors
  }
}
```

如果满足以下条件，则移除事件类型过滤器：

- 返回的 `errors` 对象为空。
- API 响应 `200 OK`。

<a id="namespace-filters"></a>

### 命名空间过滤器

{{< history >}}

- 命名空间过滤器 API 在极狐GitLab 16.7 中引入。

{{< /history >}}

当您对群组应用命名空间过滤器时，用户可以按目的地过滤流式审计事件，仅针对该群组的特定子群组或项目。否则，目的地会接收所有审计事件。

设置了命名空间过滤器的流目的地会带有 **filtered** ({{< icon name="filter" >}}) 标签。

<a id="use-the-api-to-add-a-namespace-filter"></a>

#### 使用 API 添加命名空间过滤器

先决条件：

- 您必须具有群组的所有者角色。

您可以使用 `auditEventsStreamingHttpNamespaceFiltersAdd` 变更类型为子群组和项目添加命名空间过滤器。

如果满足以下条件，则添加命名空间过滤器：

- API 返回空的 `errors` 对象。
- API 响应 `200 OK`。

<a id="mutation-for-subgroup"></a>

##### 针对子群组的变更

```graphql
mutation auditEventsStreamingHttpNamespaceFiltersAdd {
  auditEventsStreamingHttpNamespaceFiltersAdd(input: {
    destinationId: "gid://gitlab/AuditEvents::ExternalAuditEventDestination/1",
    groupPath: "path/to/subgroup"
  }) {
    errors
    namespaceFilter {
      id
      namespace {
        id
        name
        fullName
      }
    }
  }
}
```

<a id="mutation-for-project"></a>

##### 针对项目的变更

```graphql
mutation auditEventsStreamingHttpNamespaceFiltersAdd {
  auditEventsStreamingHttpNamespaceFiltersAdd(input: {
    destinationId: "gid://gitlab/AuditEvents::ExternalAuditEventDestination/1",
    projectPath: "path/to/project"
  }) {
    errors
    namespaceFilter {
      id
      namespace {
        id
        name
        fullName
      }
    }
  }
}
```

<a id="use-the-api-to-remove-a-namespace-filter"></a>

#### 使用 API 移除命名空间过滤器

先决条件：

- 您必须具有群组的所有者角色。

您可以使用 `auditEventsStreamingHttpNamespaceFiltersDelete` 变更类型移除命名空间过滤器：

```graphql
mutation auditEventsStreamingHttpNamespaceFiltersDelete {
  auditEventsStreamingHttpNamespaceFiltersDelete(input: {
    namespaceFilterId: "gid://gitlab/AuditEvents::Streaming::HTTP::NamespaceFilter/5"
  }) {
    errors
  }
}
```

如果满足以下条件，则移除命名空间过滤器：

- 返回的 `errors` 对象为空。
- API 响应 `200 OK`。

