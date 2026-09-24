---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 实例审计事件流
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在 GitLab 16.1 中 [引入](../feature_flags/_index.md)，使用功能标志 `ff_external_audit_events`，默认禁用。
- 在 GitLab 16.2 中，功能标志 `ff_external_audit_events` 默认启用。
- 在 GitLab 16.4 中，实例流目标 [正式发布]，并移除了功能标志 `ff_external_audit_events`。
- 在 GitLab 15.2 中 [引入](../feature_flags/_index.md) 了自定义 HTTP 标头 UI，通过功能标志 `custom_headers_streaming_audit_events_ui` 控制，默认禁用。
- 在 GitLab 15.3 中，自定义 HTTP 标头 UI [正式发布]，并移除了功能标志 `custom_headers_streaming_audit_events_ui`。
- 在 GitLab 15.3 中 [改善了用户体验]。
- HTTP 目标 **名称** 字段在 GitLab 16.3 中 [添加]。
- **激活** 复选框功能在 GitLab 16.5 中 [添加]。

{{< /history >}}

针对实例的审计事件流，管理员可以：

- 为整个实例设置一个流目标，以便以结构化 JSON 格式接收有关该实例的所有审计事件。
- 在第三方系统中管理审计日志。任何可以接收结构化 JSON 数据的服务都可以用作流
  目标。

每个流目标可以包含最多 20 个自定义 HTTP 标头随每个流事件一起发送。

极狐GitLab 可能会将单个事件多次流式传输到同一目标。请使用负载中的 `id` 键对传入数据进行去重。

审计事件使用 HTTP 支持的 POST 请求方法协议发送。

> [!warning]
> 流目标接收 **所有** 审计事件数据，其中可能包含敏感信息。请确保你信任该流目标。

管理整个实例的流目标。

<a id="http-destinations"></a>

## HTTP 目标

先决条件：

- 为了更好的安全性，你应该在目标 URL 上使用 SSL 证书。

管理整个实例的 HTTP 流目标。

<a id="add-a-new-http-destination"></a>

### 添加新的 HTTP 目标

向实例添加新的 HTTP 流目标。

先决条件：

- 实例的管理员访问权限。

为实例添加流目标：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **监控** > **审计事件**。
1. 在主区域，选择 **流** 选项卡。
1. 选择 **添加流目标** 并选择 **HTTP 端点** 以显示添加目标部分。
1. 在 **名称** 和 **目标 URL** 字段中，添加目标名称和 URL。
1. 可选。要添加自定义 HTTP 标头，选择 **添加标头** 以创建新的名称和值配对，并输入其值。根据需要重复此步骤添加多个名称和值配对。每个流目标最多可添加 20 个标头。
1. 要使标头生效，请选中 **激活** 复选框。标头将与审计事件一起发送。
1. 选择 **添加标头** 以创建新的名称和值配对。根据需要重复此步骤添加多个名称和值配对。每个流目标最多可添加
   20 个标头。
1. 填写完所有标头后，选择 **添加** 以添加新的流目标。

<a id="update-an-http-destination"></a>

### 更新 HTTP 目标

先决条件：

- 实例的管理员访问权限。

要更新实例流目标的名称：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **监控** > **审计事件**。
1. 在主区域，选择 **流** 选项卡。
1. 选择要展开的流。
1. 在 **名称** 字段中，输入要更新的目标名称。
1. 选择 **保存** 以更新流目标。

要更新实例流目标的自定义 HTTP 标头：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **监控** > **审计事件**。
1. 在主区域，选择 **流** 选项卡。
1. 选择要展开的流。
1. 找到 **自定义 HTTP 标头** 表格。
1. 找到你要更新的标头。
1. 要使标头生效，请选中 **激活** 复选框。标头将与审计事件一起发送。
1. 选择 **添加标头** 以创建新的名称和值配对。根据需要输入多个名称和值配对。每个流目标最多可添加
   20 个标头。
1. 选择 **保存** 以更新流目标。

<a id="verify-event-authenticity"></a>

### 验证事件真实性

{{< history >}}

- 在 GitLab 16.1 中 [引入](../feature_flags/_index.md)，使用功能标志 `ff_external_audit_events`，默认禁用。
- 在 GitLab 16.2 中，功能标志 `ff_external_audit_events` 默认启用。
- 在 GitLab 16.4 中，实例流目标 [正式发布]，并移除了功能标志 `ff_external_audit_events`。

{{< /history >}}

每个流目标都有一个唯一的验证令牌 (`verificationToken`)，可用于验证事件的真实性。此
令牌由所有者指定或当事件目标创建时自动生成，并且无法更改。

每个流事件在 `X-Gitlab-Event-Streaming-Token` HTTP 标头中包含验证令牌，可在列出流目标时与
目标值进行验证。

先决条件：

- 实例的管理员访问权限。

要列出实例的流目标并查看验证令牌：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **监控** > **审计事件**。
1. 在主区域，选择 **流** 选项卡。
1. 查看每个项目右侧的验证令牌。

<a id="update-event-filters"></a>

### 更新事件过滤器

{{< history >}}

- 在 GitLab 16.3 中 [引入]了在 UI 中按特定审计事件类型列表进行事件类型过滤的功能。

{{< /history >}}

启用此功能后，你可以允许用户按目标过滤流式审计事件。
如果该功能启用时未设置过滤器，则目标将接收所有审计事件。

设置了事件类型过滤器的流目标会带有 **已过滤** （{{< icon name="filter" >}}）标签。

要更新流目标的事件过滤器：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **监控** > **审计事件**。
1. 在主区域，选择 **流** 选项卡。
1. 选择要展开的流。
1. 找到 **按审计事件类型过滤** 下拉列表。
1. 选择下拉列表，选择或清除所需的事件类型。
1. 选择 **保存** 以更新事件过滤器。

<a id="override-default-content-type-header"></a>

### 覆盖默认内容类型标头

默认情况下，流目标使用 `content-type` 标头值为 `application/x-www-form-urlencoded`。但是，你可能希望将 `content-type` 标头设置为其他值。例如，`application/json`。

要覆盖实例流目标的 `content-type` 标头默认值，请使用以下任一方式：

- [极狐GitLab UI](#update-an-http-destination)。
- [GraphQL API](../../api/graphql/audit_event_streaming_instances.md#update-streaming-destinations)。

<a id="list-streaming-destinations"></a>

## 列出流目标

先决条件：

- 实例的管理员访问权限。

要列出实例的流目标：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **监控** > **审计事件**。
1. 在主区域，选择 **流** 选项卡。
1. 选择要展开的流。

<a id="activate-or-deactivate-streaming-destinations"></a>

## 激活或停用流目标

{{< history >}}

- [引入]于 GitLab 18.2。

{{< /history >}}

你可以临时停用到某个目标的审计事件流而无需删除目标配置。当流目标被停用时：

- 审计事件会立即停止流向该目标。
- 目标配置将被保留。
- 你可以随时重新激活该目标。
- 其他活跃目标会继续接收事件。

<a id="deactivate-a-streaming-destination"></a>

### 停用流目标

先决条件：

- 实例的管理员访问权限。

要停用流目标：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **监控** > **审计事件**。
1. 在主区域，选择 **流** 选项卡。
1. 选择要展开的流。
1. 取消选中 **激活** 复选框。
1. 选择 **保存**。

该目标将停止接收审计事件。

<a id="activate-a-streaming-destination"></a>

### 激活流目标

要重新激活之前停用的流目标：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **监控** > **审计事件**。
1. 在主区域，选择 **流** 选项卡。
1. 选择要展开的流。
1. 选中 **激活** 复选框。
1. 选择 **保存**。

该目标将立即恢复接收审计事件。

<a id="delete-streaming-destinations"></a>

## 删除流目标

删除整个实例的流目标。当最后一个目标成功删除后，实例的流传输将被禁用。

先决条件：

- 实例的管理员访问权限。

要删除实例上的流目标：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **监控** > **审计事件**。
1. 在主区域，选择 **流** 选项卡。
1. 选择要展开的流。
1. 选择 **删除目标**。
1. 确认选择 **删除目标**。

<a id="delete-only-custom-http-headers"></a>

### 仅删除自定义 HTTP 标头

先决条件：

- 实例的管理员访问权限。

要仅删除流目标的自定义 HTTP 标头：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **监控** > **审计事件**。
1. 在主区域，选择 **流** 选项卡。
1. 在项目右侧，选择 **编辑**（{{< icon name="pencil" >}}）。
1. 找到 **自定义 HTTP 标头** 表格。
1. 找到你要删除的标头。
1. 在标头右侧，选择 **删除**（{{< icon name="remove" >}}）。
1. 选择 **保存**。