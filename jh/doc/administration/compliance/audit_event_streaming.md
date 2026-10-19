---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 实例审计事件流式传输
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

借助实例审计事件流式传输，管理员可以：

- 为整个实例设置流式传输目标，以结构化 JSON 格式接收该实例的所有审计事件。
- 在第三方系统中管理审计日志。任何能够接收结构化 JSON 数据的服务都可以用作流式传输目标。

每个流式传输目标最多可以包含 20 个随每个流式传输事件一起发送的自定义 HTTP 请求头。

极狐GitLab 可能会将同一个事件多次流式传输到同一目标。请使用负载中的 `id` 键对传入数据进行去重。

审计事件使用 HTTP 支持的 POST 请求方法协议发送。

> [!warning]
> 流式传输目标会接收所有审计事件数据，其中可能包含敏感信息。请确保您信任该流式传输目标。

管理整个实例的流式传输目标。

<a id="http-destinations"></a>

## HTTP 目标

先决条件：

- 为了提高安全性，您应该在目标 URL 上使用 SSL 证书。

管理整个实例的 HTTP 流式传输目标。

<a id="add-a-new-http-destination"></a>

### 添加新的 HTTP 目标

向实例添加新的 HTTP 流式传输目标。

先决条件：

- 拥有实例的管理员访问权限。

要为实例添加流式传输目标：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **审计事件**。
1. 在主区域中，选择**流**选项卡。
1. 选择**添加流式传输目标**，然后选择 **HTTP 端点**以显示用于添加目标的部分。
1. 在**名称**和**目标 URL** 字段中，添加目标名称和 URL。
1. 可选。要添加自定义 HTTP 请求头，请选择**添加请求头**以创建新的名称和值对，并输入它们的值。根据需要重复此步骤，添加任意数量的名称和值对。每个流式传输目标最多可以添加 20 个请求头。
1. 要使请求头生效，请选中**活跃**复选框。该请求头将随审计事件一起发送。
1. 选择**添加请求头**以创建新的名称和值对。根据需要重复此步骤，添加任意数量的名称和值对。每个流式传输目标最多可以添加 20 个请求头。
1. 填写完所有请求头后，选择**添加**以添加新的流式传输目标。

<a id="update-an-http-destination"></a>

### 更新 HTTP 目标

先决条件：

- 拥有实例的管理员访问权限。

要更新实例流式传输目标的名称：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **审计事件**。
1. 在主区域中，选择**流**选项卡。
1. 选择要展开的流。
1. 在**名称**字段中，添加要更新的目标名称。
1. 选择**保存**以更新流式传输目标。

要更新实例流式传输目标的自定义 HTTP 请求头：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **审计事件**。
1. 在主区域中，选择**流**选项卡。
1. 选择要展开的流。
1. 找到**自定义 HTTP 请求头**表格。
1. 找到您要更新的请求头。
1. 要使请求头生效，请选中**活跃**复选框。该请求头将随审计事件一起发送。
1. 选择**添加请求头**以创建新的名称和值对。根据需要输入任意数量的名称和值对。每个流式传输目标最多可以添加 20 个请求头。
1. 选择**保存**以更新流式传输目标。

<a id="verify-event-authenticity"></a>

### 验证事件真实性

每个流式传输目标都有一个唯一的验证令牌（`verificationToken`），可用于验证事件的真实性。此令牌由所有者指定，或在创建事件目标时自动生成，且无法更改。

每个流式传输事件都在 `X-Gitlab-Event-Streaming-Token` HTTP 请求头中包含验证令牌，可以在列出流式传输目标时根据目标的值进行验证。

先决条件：

- 拥有实例的管理员访问权限。

要列出实例的流式传输目标并查看验证令牌：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **审计事件**。
1. 在主区域中，选择**流**选项卡。
1. 在每个条目的右侧查看验证令牌。

<a id="update-event-filters"></a>

### 更新事件过滤器

启用此功能后，您可以允许用户按目标过滤流式传输的审计事件。如果启用此功能时未设置过滤器，则目标会接收所有审计事件。

设置了事件类型过滤器的流式传输目标会带有**已过滤**（{{< icon name="filter" >}}）标记。

要更新流式传输目标的事件过滤器：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **审计事件**。
1. 在主区域中，选择**流**选项卡。
1. 选择要展开的流。
1. 找到**按审计事件类型过滤**下拉列表。
1. 选择下拉列表，然后选择或清除所需的事件类型。
1. 选择**保存**以更新事件过滤器。

<a id="override-default-content-type-header"></a>

### 覆盖默认内容类型请求头

默认情况下，流式传输目标使用 `content-type` 请求头，其值为 `application/x-www-form-urlencoded`。但是，您可能希望将 `content-type` 请求头设置为其他值。例如，`application/json`。

要覆盖实例流式传输目标的 `content-type` 请求头默认值，可以使用以下任一方式：

- [极狐GitLab UI](#update-an-http-destination)。
- [GraphQL API](../../api/graphql/audit_event_streaming_instances.md#update-streaming-destinations)。

<a id="google-cloud-logging-destinations"></a>

## Google Cloud Logging 目标

管理整个实例的 Google Cloud Logging 目标。

<a id="prerequisites"></a>

### 先决条件

在设置 Google Cloud Logging 流式传输审计事件之前，您必须：

1. 在您的 Google Cloud 项目上启用 [Cloud Logging API](https://console.cloud.google.com/marketplace/product/google/logging.googleapis.com)。
1. 为 Google Cloud 创建具有适当凭据和权限的服务账号。此账号用于配置审计日志流式传输身份验证。有关更多信息，请参阅 [Google Cloud 文档中的创建和管理服务账号](https://cloud.google.com/iam/docs/service-accounts-create#creating)。
1. 为该服务账号启用 **Logs Writer** 角色，以在 Google Cloud 上启用日志记录。有关更多信息，请参阅[使用 IAM 进行访问控制](https://cloud.google.com/logging/docs/access-control#logging.logWriter)。
1. 为该服务账号创建 JSON 密钥。有关更多信息，请参阅[创建服务账号密钥](https://cloud.google.com/iam/docs/keys-create-delete#creating)。

<a id="add-a-new-google-cloud-logging-destination"></a>

### 添加新的 Google Cloud Logging 目标

先决条件：

- 拥有实例的管理员访问权限。

要向实例添加 Google Cloud Logging 流式传输目标：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **审计事件**。
1. 在主区域中，选择**流**选项卡。
1. 选择**添加流式传输目标**，然后选择 **Google Cloud Logging** 以显示用于添加目标的部分。
1. 输入一个随机字符串，用作新目标的名称。
1. 输入先前创建的 Google Cloud 服务账号密钥中的 Google 项目 ID 和 Google 客户端电子邮件。
1. 输入先前创建的 Google Cloud 服务账号密钥中的 Google 私钥。它应为 PEM 格式，并以 `-----BEGIN PRIVATE KEY-----` 开头。请勿上传整个 JSON 密钥。
1. 输入一个随机字符串，用作新目标的日志 ID。您以后可以在 Google Cloud 中使用它来过滤日志结果。
1. 选择**添加**以添加新的流式传输目标。

<a id="update-a-google-cloud-logging-destination"></a>

### 更新 Google Cloud Logging 目标

先决条件：

- 拥有实例的管理员访问权限。

要更新实例的 Google Cloud Logging 流式传输目标：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **审计事件**。
1. 在主区域中，选择**流**选项卡。
1. 选择要展开的 Google Cloud Logging 流。
1. 输入一个随机字符串，用作目标的名称。
1. 输入先前创建的 Google Cloud 服务账号密钥中的 Google 项目 ID 和 Google 客户端电子邮件，以更新目标。
1. 输入一个随机字符串，以更新目标的日志 ID。您以后可以在 Google Cloud 中使用它来过滤日志结果。
1. 选择**添加新私钥**并输入 Google 私钥以更新私钥。
1. 选择**保存**以更新流式传输目标。

<a id="aws-s3-destinations"></a>

## AWS S3 目标

管理整个实例的 AWS S3 目标。

<a id="prerequisites-1"></a>

### 先决条件

在设置 AWS S3 流式传输审计事件之前，您必须：

1. 为 AWS 创建具有适当凭据和权限的访问密钥。此账号用于配置审计日志流式传输身份验证。有关更多信息，请参阅[管理访问密钥](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html?icmpid=docs_iam_console#Using_CreateAccessKey)。
1. 创建 AWS S3 存储桶。此存储桶用于存储审计日志流式传输数据。有关更多信息，请参阅[创建存储桶](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html)。

<a id="add-a-new-aws-s3-destination"></a>

### 添加新的 AWS S3 目标

先决条件：

- 拥有实例的管理员访问权限。

要向实例添加 AWS S3 流式传输目标：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **审计事件**。
1. 在主区域中，选择**流**选项卡。
1. 选择**添加流式传输目标**，然后选择 **AWS S3** 以显示用于添加目标的部分。
1. 输入一个随机字符串，用作新目标的名称。
1. 输入先前创建的 AWS 访问密钥和存储桶中的**访问密钥 ID**、**秘密访问密钥**、**存储桶名称**和 **AWS 区域**，以添加到新目标。
1. 选择**添加**以添加新的流式传输目标。

<a id="update-an-aws-s3-destination"></a>

### 更新 AWS S3 目标

先决条件：

- 拥有实例的管理员访问权限。

要更新实例的 AWS S3 流式传输目标：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **审计事件**。
1. 在主区域中，选择**流**选项卡。
1. 选择要展开的 AWS S3 流。
1. 输入一个随机字符串，用作目标的名称。
1. 要更新目标，请输入先前创建的 AWS 访问密钥和存储桶中的**访问密钥 ID**、**秘密访问密钥**、**存储桶名称**和 **AWS 区域**。
1. 选择**添加新秘密访问密钥**并输入 AWS 秘密访问密钥以更新秘密访问密钥。
1. 选择**保存**。

<a id="list-streaming-destinations"></a>

## 列出流式传输目标

先决条件：

- 拥有实例的管理员访问权限。

要列出实例的流式传输目标：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **审计事件**。
1. 在主区域中，选择**流**选项卡。
1. 选择要展开的流。

<a id="activate-or-deactivate-streaming-destinations"></a>

## 激活或停用流式传输目标

您可以暂时停用流向某个目标的审计事件流式传输，而无需删除目标配置。当流式传输目标被停用时：

- 审计事件会立即停止流向该目标。
- 目标配置会被保留。
- 您可以随时重新激活该目标。
- 其他活跃目标会继续接收事件。

<a id="deactivate-a-streaming-destination"></a>

### 停用流式传输目标

先决条件：

- 拥有实例的管理员访问权限。

要停用流式传输目标：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **审计事件**。
1. 在主区域中，选择**流**选项卡。
1. 选择要展开的流。
1. 清除**活跃**复选框。
1. 选择**保存**。

该目标将停止接收审计事件。

<a id="activate-a-streaming-destination"></a>

### 激活流式传输目标

要重新激活之前停用的流式传输目标：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **审计事件**。
1. 在主区域中，选择**流**选项卡。
1. 选择要展开的流。
1. 选中**活跃**复选框。
1. 选择**保存**。

该目标会立即恢复接收审计事件。

<a id="ai-audit-event-streaming"></a>

## AI 审计事件流式传输

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署
- Status: 测试版

{{< /details >}}

> [!warning]
> 启用 AI 审计事件流式传输可能会影响实例性能。只有在评估了实例负载之后，才应启用此设置。

极狐GitLab Duo Agent Platform 会为以下活动记录 AI 审计事件：

- Agent 会话。
- LLM 请求。
- 工具调用。
- 用户输入。

极狐GitLab 始终会将这些事件保存到数据库中。

您还可以使用单独的设置来控制极狐GitLab 是否将 AI 审计事件流式传输到外部目标。此设置默认处于关闭状态。

当 AI 审计事件流式传输：

- 开启时，极狐GitLab 会将 AI 审计事件流式传输到所有活跃的实例流式传输目标。事件类型过滤器、自定义 HTTP 请求头和验证令牌对 AI 审计事件的适用方式与对其他审计事件相同。
- 关闭时，极狐GitLab 仍会将 AI 审计事件保存到数据库，但不会将其发送到任何外部目标。其他审计事件类型会继续根据每个目标的配置进行流式传输。

<a id="turn-on-ai-audit-event-streaming"></a>

### 开启 AI 审计事件流式传输

先决条件：

- 拥有实例的管理员访问权限。

要开启 AI 审计事件流式传输：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**极狐GitLab Duo**。
1. 选择**更改配置**。
1. 选中**启用 AI 审计事件流式传输**复选框。
1. 选择**保存更改**。

<a id="turn-off-ai-audit-event-streaming"></a>

### 关闭 AI 审计事件流式传输

先决条件：

- 拥有实例的管理员访问权限。

要关闭 AI 审计事件流式传输：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**极狐GitLab Duo**。
1. 选择**更改配置**。
1. 清除**启用 AI 审计事件流式传输**复选框。
1. 选择**保存更改**。

AI 审计事件会立即停止流式传输。极狐GitLab 会继续将它们保存到数据库中。

<a id="delete-streaming-destinations"></a>

## 删除流式传输目标

删除整个实例的流式传输目标。当最后一个目标被成功删除后，该实例的流式传输将被禁用。

先决条件：

- 拥有实例的管理员访问权限。

要删除实例上的流式传输目标：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **审计事件**。
1. 在主区域中，选择**流**选项卡。
1. 选择要展开的流。
1. 选择**删除目标**。
1. 要确认，请选择**删除目标**。

<a id="delete-only-custom-http-headers"></a>

### 仅删除自定义 HTTP 请求头

先决条件：

- 拥有实例的管理员访问权限。

要仅删除流式传输目标的自定义 HTTP 请求头：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **审计事件**。
1. 在主区域中，选择**流**选项卡。
1. 在条目右侧，选择**编辑**（{{< icon name="pencil" >}}）。
1. 找到**自定义 HTTP 请求头**表格。
1. 找到您要移除的请求头。
1. 在请求头右侧，选择**删除**（{{< icon name="remove" >}}）。
1. 选择**保存**。
