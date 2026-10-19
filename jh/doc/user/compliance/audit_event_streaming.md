---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何在极狐GitLab 中配置和管理审计事件流，将审计日志导出到外部目标以进行合规监控。
title: 顶级群组的审计事件流
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

通过顶级群组的审计事件流，群组所有者可以：

- 为顶级群组设置流式目标，以结构化 JSON 的形式接收有关该群组、子群组和项目的所有审计事件。
- 在第三方系统中管理其审计日志。任何能够接收结构化 JSON 数据的服务都可以用作流式目标。

每个流式目标：

- 每个流式事件最多可包含 20 个自定义 HTTP 请求头。
- 对于 JihuLab.com，必须允许来自 [JihuLab.com IP 地址范围](../jihulab_com/_index.md#ip-range)的流量。

极狐GitLab 可能会将单个事件多次流式传输到同一目标。请使用负载中的 `id` 键对传入数据进行去重。

审计事件使用 HTTP 支持的 POST 请求方法协议发送。

> [!warning]
> 流式目标会接收所有审计事件数据，其中可能包含敏感信息。请确保您信任该流式目标。

<a id="http-destinations"></a>

## HTTP 目标

先决条件：

- 为了提高安全性，您应在目标 URL 上使用 SSL 证书。

管理顶级群组的 HTTP 流式目标。

<a id="add-a-new-http-destination"></a>

### 添加新的 HTTP 目标

为顶级群组添加新的 HTTP 流式目标。

先决条件：

- 顶级群组的所有者角色。

要为顶级群组添加流式目标：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **审计事件**。
1. 在主区域中，选择**流**标签页。
1. 选择**添加流式目标**，然后选择 **HTTP 端点**，以显示用于添加目标的区域。
1. 在**名称**和**目标 URL** 字段中，添加目标名称和 URL。
1. 可选。找到**自定义 HTTP 请求头**表格。
1. 要使该请求头处于活跃状态，请选中**活跃**复选框。该请求头将随审计事件一起发送。
1. 选择**添加请求头**以创建新的名称和值对。根据需要输入任意数量的名称和值对。每个流式目标最多可添加
   20 个请求头。
1. 填写完所有请求头后，选择**添加**以添加新的流式目标。

<a id="update-an-http-destination"></a>

### 更新 HTTP 目标

先决条件：

- 群组的所有者角色。

要更新流式目标的名称：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **审计事件**。
1. 在主区域中，选择**流**标签页。
1. 选择要展开的流。
1. 在**名称**字段中，添加要更新的目标名称。
1. 选择**保存**以更新流式目标。

要更新流式目标的自定义 HTTP 请求头：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **审计事件**。
1. 在主区域中，选择**流**标签页。
1. 选择要展开的流。
1. 找到**自定义 HTTP 请求头**表格。
1. 找到您要更新的请求头。
1. 要使该请求头处于活跃状态，请选中**活跃**复选框。该请求头将随审计事件一起发送。
1. 选择**添加请求头**以创建新的名称和值对。根据需要输入任意数量的名称和值对。每个流式目标最多可添加
   20 个请求头。
1. 选择**保存**以更新流式目标。

<a id="verify-event-authenticity"></a>

### 验证事件真实性

每个流式目标都有一个唯一的验证令牌（`verificationToken`），可用于验证事件的真实性。该令牌由所有者指定，或在创建事件目标时自动生成，且无法更改。

`verificationToken` 参数只能通过 [GraphQL API](../../api/graphql/audit_event_streaming_groups.md#add-a-new-streaming-destination) 设置。

每个流式事件都在 `X-Gitlab-Event-Streaming-Token` HTTP 请求头中包含验证令牌，在列出流式目标时，可将其与目标的值进行比对验证。

先决条件：

- 群组的所有者角色。

要列出流式目标并查看验证令牌：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **审计事件**。
1. 在主区域中，选择**流**标签页。
1. 选择要展开的流。
1. 找到**验证令牌**输入框。

<a id="update-event-filters"></a>

### 更新事件过滤器

为群组启用此功能后，您可以允许用户按目标筛选流式审计事件。如果启用该功能时未设置任何过滤器，则该目标会接收所有审计事件。

设置了事件类型过滤器的流式目标会带有**已过滤** ({{< icon name="filter" >}}) 标记。

要更新流式目标的事件过滤器：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **审计事件**。
1. 在主区域中，选择**流**标签页。
1. 选择要展开的流。
1. 找到**按审计事件类型过滤**下拉列表。
1. 选择该下拉列表，然后选择或清除所需的事件类型。
1. 选择**保存**以更新事件过滤器。

<a id="update-namespace-filters"></a>

### 更新命名空间过滤器

为群组启用此功能后，您可以允许用户按目标筛选流式审计事件。如果启用该功能时未设置任何过滤器，则该目标会接收所有审计事件。

设置了命名空间过滤器的流式目标会带有**已过滤** ({{< icon name="filter" >}}) 标记。

要更新流式目标的命名空间过滤器：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **审计事件**。
1. 在主区域中，选择**流**标签页。
1. 选择要展开的流。
1. 找到**按群组或项目过滤**下拉列表。
1. 选择该下拉列表，然后选择或清除所需的命名空间。
1. 选择**保存**以更新命名空间过滤器。

<a id="override-default-content-type-header"></a>

### 覆盖默认内容类型请求头

默认情况下，流式目标使用 `content-type` 请求头，其值为 `application/x-www-form-urlencoded`。不过，您可能希望将 `content-type` 请求头设置为其他值。例如，`application/json`。

要覆盖顶级群组流式目标的 `content-type` 请求头默认值，请使用以下任一方式：

- [极狐GitLab UI](#update-an-http-destination)。
- [GraphQL API](../../api/graphql/audit_event_streaming_groups.md#update-streaming-destinations)。

<a id="google-cloud-logging-destinations"></a>

## Google Cloud Logging 目标

管理顶级群组的 Google Cloud Logging 目标。

<a id="prerequisites"></a>

### 先决条件

在设置 Google Cloud Logging 流式审计事件之前，您必须：

1. 在您的 Google Cloud 项目上启用 [Cloud Logging API](https://console.cloud.google.com/marketplace/product/google/logging.googleapis.com)。
1. 为 Google Cloud 创建一个具有适当凭据和权限的服务账号。该账号用于配置审计日志流式传输身份验证。
   有关更多信息，请参阅 [Google Cloud 文档中的创建和管理服务账号](https://cloud.google.com/iam/docs/service-accounts-create#creating)。
1. 为该服务账号启用 **Logs Writer** 角色，以便在 Google Cloud 上启用日志记录。有关更多信息，请参阅[使用 IAM 进行访问控制](https://cloud.google.com/logging/docs/access-control#logging.logWriter)。
1. 为该服务账号创建 JSON 密钥。有关更多信息，请参阅[创建服务账号密钥](https://cloud.google.com/iam/docs/keys-create-delete#creating)。

<a id="add-a-new-google-cloud-logging-destination"></a>

### 添加新的 Google Cloud Logging 目标

先决条件：

- 顶级群组的所有者角色。

要为顶级群组添加 Google Cloud Logging 流式目标：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **审计事件**。
1. 在主区域中，选择**流**标签页。
1. 选择**添加流式目标**，然后选择 **Google Cloud Logging**，以显示用于添加目标的区域。
1. 输入一个随机字符串，用作新目标的名称。
1. 输入先前创建的 Google Cloud 服务账号密钥中的 Google 项目 ID、Google 客户端电子邮件和 Google 私钥，以添加到新目标。
1. 输入一个随机字符串，用作新目标的日志 ID。您稍后可以使用它在 Google Cloud 中筛选日志结果。
1. 选择**添加**以添加新的流式目标。

<a id="update-a-google-cloud-logging-destination"></a>

### 更新 Google Cloud Logging 目标

先决条件：

- 顶级群组的所有者角色。

要更新顶级群组的 Google Cloud Logging 流式目标：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **审计事件**。
1. 在主区域中，选择**流**标签页。
1. 选择要展开的 Google Cloud Logging 流。
1. 输入一个随机字符串，用作该目标的名称。
1. 输入先前创建的 Google Cloud 服务账号密钥中的 Google 项目 ID 和 Google 客户端电子邮件，以更新该目标。
1. 输入一个随机字符串，以更新该目标的日志 ID。您稍后可以使用它在 Google Cloud 中筛选日志结果。
1. 选择**添加新私钥**，然后输入 Google 私钥以更新私钥。
1. 选择**保存**以更新流式目标。

<a id="aws-s3-destinations"></a>

## AWS S3 目标

管理顶级群组的 AWS S3 目标。

<a id="prerequisites-1"></a>

### 先决条件

在设置 AWS S3 流式审计事件之前，您必须：

1. 为 AWS 创建一个具有适当凭据和权限的访问密钥。该账号用于配置审计日志流式传输身份验证。
   有关更多信息，请参阅[管理访问密钥](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html?icmpid=docs_iam_console#Using_CreateAccessKey)。
1. 创建一个 AWS S3 存储桶。该存储桶用于存储审计日志流式传输数据。有关更多信息，请参阅[创建存储桶](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html)

<a id="add-a-new-aws-s3-destination"></a>

### 添加新的 AWS S3 目标

先决条件：

- 顶级群组的所有者角色。

要为顶级群组添加 AWS S3 流式目标：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **审计事件**。
1. 在主区域中，选择**流**标签页。
1. 选择**添加流式目标**，然后选择 **AWS S3**，以显示用于添加目标的区域。
1. 输入一个随机字符串，用作新目标的名称。
1. 输入先前创建的 AWS 访问密钥和存储桶中的 **访问密钥 ID**、**秘密访问密钥**、**存储桶名称** 和 **AWS 区域**，
   以添加到新目标。
1. 选择**添加**以添加新的流式目标。

<a id="update-an-aws-s3-destination"></a>

### 更新 AWS S3 目标

先决条件：

- 顶级群组的所有者角色。

要更新顶级群组的 AWS S3 流式目标：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **审计事件**。
1. 在主区域中，选择**流**标签页。
1. 选择要展开的 AWS S3 流。
1. 输入一个随机字符串，用作该目标的名称。
1. 要更新该目标，请输入先前创建的 AWS 访问密钥和存储桶中的 **访问密钥 ID**、**秘密访问密钥**、**存储桶名称** 和 **AWS 区域**。
1. 要更新秘密访问密钥，请选择**添加新的秘密访问密钥**，然后输入 AWS 秘密访问密钥。
1. 选择**保存**。

<a id="list-streaming-destinations"></a>

## 列出流式目标

先决条件：

- 顶级群组的所有者角色。

要列出顶级群组的流式目标：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **审计事件**。
1. 在主区域中，选择**流**标签页。
1. 选择要展开的流。

<a id="activate-or-deactivate-streaming-destinations"></a>

## 激活或停用流式目标

您可以临时停用向某个目标的审计事件流，而无需删除该目标的配置。当流式目标被停用时：

- 审计事件会立即停止流式传输到该目标。
- 该目标的配置会保留。
- 您可以随时重新激活该目标。
- 其他活跃目标会继续接收事件。

<a id="deactivate-a-streaming-destination"></a>

### 停用流式目标

先决条件：

- 顶级群组的所有者角色。

要停用流式目标：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **审计事件**。
1. 在主区域中，选择**流**标签页。
1. 选择要展开的流。
1. 清除**活跃**复选框。
1. 选择**保存**。

该目标将停止接收审计事件。

<a id="activate-a-streaming-destination"></a>

### 激活流式目标

要重新激活先前已停用的流式目标：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **审计事件**。
1. 在主区域中，选择**流**标签页。
1. 选择要展开的流。
1. 选中**活跃**复选框。
1. 选择**保存**。

该目标将立即恢复接收审计事件。

<a id="delete-streaming-destinations"></a>

## 删除流式目标

删除顶级群组的流式目标。当最后一个目标成功删除后，该顶级群组的流式传输将被禁用。

先决条件：

- 顶级群组的所有者角色。

要删除顶级群组的流式目标：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **审计事件**。
1. 在主区域中，选择**流**标签页。
1. 选择要展开的流。
1. 选择**删除目标**。
1. 要确认，请选择**删除目标**。

<a id="delete-only-custom-http-headers"></a>

### 仅删除自定义 HTTP 请求头

先决条件：

- 顶级群组的所有者角色。

要仅删除流式目标的自定义 HTTP 请求头：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**安全** > **审计事件**。
1. 在主区域中，选择**流**标签页。
1. 选择要展开的流。
1. 找到**自定义 HTTP 请求头**表格。
1. 找到您要移除的请求头。
1. 在该请求头的右侧，选择**删除** ({{< icon name="remove" >}})。
1. 选择**保存**。
