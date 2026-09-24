---
title: 配置极狐GitLab 使用自部署模型
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.1 中，随[功能标志](../feature_flags/_index.md) `ai_custom_model` 引入（默认禁用）。
- 于极狐GitLab 17.6 中，在极狐GitLab 私有化部署上启用。
- 在极狐GitLab 17.6 及更高版本中，需要极狐GitLab Duo 附加组件。
- 功能标志 `ai_custom_model` 在极狐GitLab 17.8 中移除。
- 于极狐GitLab 17.9 中，添加了使用 UI 设置 AI 网关 URL 的功能。
- 在极狐GitLab 17.9 中 GA。
- 在极狐GitLab 18.0 中，改为也包含专业版。

{{< /history >}}

先决条件：

- [将极狐GitLab 升级到 17.9 或更高版本](../../update/_index.md)。
- 你必须是管理员。

要配置你的极狐GitLab 实例以访问你基础设施中的自部署模型：

1. 配置你的极狐GitLab 实例以访问 AI 网关。
2. 在极狐GitLab 18.4 及更高版本中，配置你的极狐GitLab 实例以访问极狐GitLab Duo Agent Platform 服务。
3. 将自部署模型添加到你的极狐GitLab 实例。
4. 为功能选择自部署模型。

<a id="configure-access-to-the-local-ai-gateway"></a>

## 配置本地 AI 网关的访问

要配置你的极狐GitLab 实例与本地 AI 网关之间的访问：

1. 在右上角，选择 **管理员**。
2. 在左侧边栏中，选择 **极狐GitLab Duo**。
3. 选择 **更改配置**。
4. 在 **本地 AI 网关 URL** 下，输入你的 AI 网关 URL。
5. 选择 **保存更改**。

> [!note]
> 如果你的 AI 网关 URL 指向本地网络或私有 IP 地址（例如 `172.31.x.x` 或类似 `ip-172-xx-xx-xx.region.compute.internal` 的内部主机名），极狐GitLab 可能会出于安全原因阻止该请求。要允许向该地址发送请求，请[将地址添加到 IP 允许列表](../../security/webhooks.md#allow-outbound-requests-to-certain-ip-addresses-and-domains)。

<a id="configure-timeout-for-the-ai-gateway"></a>

### 配置 AI 网关超时

{{< history >}}

- 在极狐GitLab 18.7 中引入。

{{< /history >}}

为了节省资源并防止长时间运行的查询，可以配置极狐GitLab 向 AI 网关发送请求时等待模型响应的超时时间。对于具有大型上下文窗口或复杂查询的自部署模型，请使用更长的超时时间。

你可以配置 60 到 600 秒（10 分钟）的超时时间。如果不设置超时，极狐GitLab 将使用默认超时 60 秒。

要配置 AI 网关超时：

1. 在右上角，选择 **管理员**。
2. 在左侧边栏中，选择 **极狐GitLab Duo**。
3. 选择 **更改配置**。
4. 在 **AI 网关请求超时** 下，输入以秒为单位的超时值（介于 60 和 600 之间）。
5. 选择 **保存更改**。

<a id="determine-the-timeout-value"></a>

### 确定超时值

超时值取决于你的特定部署和用例。

要确定超时值：

- 从 60 秒的默认超时开始，监控是否出现超时错误。
- 监控日志中是否有 `A1000` 超时错误。如果这些错误频繁出现，请考虑增加超时时间。
- 考虑你的用例。较大的提示、复杂的代码生成任务或处理大型设计文档可能需要更长的超时时间。
- 考虑你的基础设施。模型性能取决于可用的 GPU 资源、AI 网关与模型端点之间的网络延迟以及模型的处理能力。
- 逐步增加。如果遇到超时，请逐步增加值（例如，每次增加 30-60 秒），并监控结果。

有关超时错误故障排除的更多信息，请参阅[错误 A1000](troubleshooting.md#error-a1000)。

<a id="configure-access-to-the-gitlab-duo-agent-platform"></a>

## 配置对极狐GitLab Duo Agent Platform 的访问

{{< history >}}

- 于极狐GitLab 18.4 [实验性引入](../../policy/development_stages_support.md#experiment)，带有[功能标志](../feature_flags/_index.md) `self_hosted_agent_platform`（默认禁用）。
- 在极狐GitLab 18.5 中从实验性改为 Beta。
- 在极狐GitLab 18.7 中启用。
- 在极狐GitLab 18.8 中 GA。
- 功能标志 `self_hosted_agent_platform` 在极狐GitLab 18.9 中移除。
- 在极狐GitLab 18.7 和 18.8 中，对于拥有在线许可证的客户，此功能为 Beta 版。要使用此功能，你必须[开启](#turn-on-self-hosted-beta-models-and-features)自部署 Beta 模型和功能。

{{< /history >}}

先决条件：

- 如果你的实例拥有离线许可证，你必须拥有 [极狐GitLab Duo Agent Platform 自部署](../../subscriptions/subscription-add-ons.md) 附加组件。

要从你的极狐GitLab 实例访问 Agent Platform 服务：

1. 在右上角，选择 **管理员**。
2. 在左侧边栏中，选择 **极狐GitLab Duo**。
3. 选择 **更改配置**。
4. 在 **极狐GitLab Duo Agent Platform 服务的本地 URL** 下，输入本地 Agent Platform 服务的 URL。
   - 该 URL 通常与 **本地 AI 网关 URL** 相同，但使用 gRPC 端口 :50052。
   - 不要包含 URL 前缀，如 `http://` 或 `https://`。
   - 如果你已[按照推荐](../../install/install_ai_gateway.md#set-up-docker-with-nginx-and-ssl)使用 NGINX 反向代理设置了 SSL，或使用[启用了 Ingress 的 Helm Chart](../../install/install_ai_gateway.md#install-by-using-helm-chart)，请不要指定端口。NGINX Ingress 会处理端口转发。
5. 可选。如果你的本地极狐GitLab Duo Agent Platform 端点使用 TLS，在 **安全** 下，选中 **为极狐GitLab Duo Agent Platform 服务使用安全连接 (TLS)** 复选框。
6. 选择 **保存更改**。

<a id="add-a-self-hosted-model"></a>

## 添加自部署模型

你必须将自部署模型添加到极狐GitLab 实例，才能与极狐GitLab Duo 功能一起使用。

要添加自部署模型：

1. 在右上角，选择 **管理员**。
2. 在左侧边栏中，选择 **极狐GitLab Duo**。
3. 选择 **为极狐GitLab Duo 配置模型**。
   - 如果 **为极狐GitLab Duo 配置模型** 不可用，请在购买后同步你的订阅：
     1. 在左侧边栏中，选择 **订阅**。
     2. 在 **订阅详情** 中，在 **上次同步** 右侧，选择同步订阅（{{< icon name="retry" >}}）。
4. 选择 **添加自部署模型**。
5. 完成字段：
   - **部署名称**：输入一个名称来唯一标识模型部署，例如 `Mixtral-8x7B-it-v0.1 on GCP`。
   - **模型系列**：选择该部署所属的模型系列。你可以选择受支持的模型或兼容的模型。
   - **端点**：输入模型托管的 URL。
   - **API 密钥**：可选。如果访问模型需要 API 密钥，请在此添加。
   - **模型标识符**：根据你的部署方法输入模型标识符。模型标识符应匹配以下格式：

     | 部署方法 | 格式 | 示例 |
     |-------------|---------|---------|
     | [vLLM](supported_llm_serving_platforms.md#find-the-model-name)        | `custom_openai/<通过 vLLM 提供服务的模型名称>` | `custom_openai/Mixtral-8x7B-Instruct-v0.1` |

6. 选择 **添加自部署模型**。

<a id="turn-on-self-hosted-beta-models-and-features"></a>

## 开启自部署 Beta 模型和功能

> [!note]
> 开启自部署 Beta 模型和功能即表示你接受 [极狐GitLab 测试协议](https://handbook.gitlab.com/handbook/legal/testing-agreement/)。

要启用自部署 Beta 模型和功能：

1. 在右上角，选择 **管理员**。
2. 在左侧边栏中，选择 **极狐GitLab Duo**。
3. 选择 **更改配置**。
4. 在 **自部署 Beta 模型和功能** 下，选中 **在极狐GitLab Duo 自部署中使用 Beta 模型和功能** 复选框。
5. 选择 **保存更改**。

<a id="configure-gitlab-duo-features-to-use-self-hosted-models"></a>

## 配置极狐GitLab Duo 功能以使用自部署模型

<a id="view-configured-features"></a>

### 查看已配置的功能

1. 在右上角，选择 **管理员**。
2. 在左侧边栏中，选择 **极狐GitLab Duo**。
3. 选择 **为极狐GitLab Duo 配置模型**。
   - 如果 **为极狐GitLab Duo 配置模型** 不可用，请在购买后同步你的订阅：
     1. 在左侧边栏中，选择 **订阅**。
     2. 在 **订阅详情** 中，在 **上次同步** 右侧，选择同步订阅（{{< icon name="retry" >}}）。
4. 选择 **AI 原生功能** 选项卡。

<a id="select-a-self-hosted-model-for-a-feature"></a>

### 为功能选择自部署模型

要选择自部署模型：

1. 在右上角，选择 **管理员**。
2. 在左侧边栏中，选择 **极狐GitLab Duo**。
3. 选择 **为极狐GitLab Duo 配置模型**。
4. 选择 **AI 原生功能** 选项卡。
5. 对于要为其选择自部署模型的功能，从下拉列表中选择模型。

> [!note]
> 如果你没有为极狐GitLab Duo Chat 子功能指定模型，它将自动使用为 **通用聊天** 配置的模型。
> 这样可以确保所有 Chat 功能正常工作，而无需为每个子功能单独选择模型。

<a id="select-a-gitlab-managed-model-for-a-feature"></a>

### 为功能选择极狐GitLab 管理的模型

{{< history >}}

- 于极狐GitLab 18.3 [Beta 引入](../../policy/development_stages_support.md#beta)，带有[功能标志](../feature_flags/_index.md) `ai_self_hosted_vendored_features`（默认禁用）。
- 在极狐GitLab 18.7 中默认启用。
- 在极狐GitLab 18.9 中 GA。功能标志 `ai_self_hosted_vendored_features` 已移除。

{{< /history >}}

即使你使用自部署 AI 网关和自部署模型，你也可以为某一功能选择极狐GitLab 管理的模型。

1. 在右上角，选择 **管理员**。
2. 在左侧边栏中，选择 **极狐GitLab Duo**。
3. 选择 **为极狐GitLab Duo 配置模型**。
4. 选择 **AI 原生功能** 选项卡。
5. 对于你要配置的功能和子功能，从下拉列表中选择 **极狐GitLab 管理的模型**。

<a id="turn-off-gitlab-duo-features"></a>

### 关闭极狐GitLab Duo 功能

即使你没有为功能选择模型，极狐GitLab Duo 功能仍保持开启。

要关闭极狐GitLab Duo 功能：

1. 在右上角，选择 **管理员**。
2. 在左侧边栏中，选择 **极狐GitLab Duo**。
3. 选择 **为极狐GitLab Duo 配置模型**。
4. 选择 **AI 原生功能** 选项卡。
5. 对于你要关闭的功能，从下拉列表中选择 **已禁用**。

<a id="self-host-the-gitlab-documentation"></a>

### 自部署极狐GitLab 文档

如果你的设置阻止你访问位于 `docs.gitlab.com` 的极狐GitLab 文档，你可以自部署该文档。
有关更多信息，请参阅[托管极狐GitLab 产品文档](../docs_self_host.md)。