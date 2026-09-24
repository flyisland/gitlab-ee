---
stage: AI Platform
group: AI Model Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 部署极狐GitLab Duo 自部署版本的故障排除提示
title: 自部署模型故障排除
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在开始故障排除之前，您应该：

- 能够访问 [`gitlab-rails` 控制台](../operations/rails_console.md)。
- 在 AI 网关 Docker 镜像中打开一个 shell。
- 知道以下端点的位置：
  - AI 网关的托管位置。
  - 模型的托管位置。
- [启用日志记录](logging.md#turn-on-data-collection-for-gitlab-duo)，以确保从极狐GitLab 到 AI 网关的请求和响应被记录到 [`llm.log`](../logs/_index.md#llmlog)。

有关极狐GitLab Duo 故障排除的更多信息，请参阅：

- [故障排除极狐GitLab Duo](../../user/gitlab_duo/troubleshooting.md)。
- [故障排除代码建议](../../user/project/repository/code_suggestions/_index.md#direct-and-indirect-connections)。
- [极狐GitLab Duo Chat 故障排除](../../user/gitlab_duo_chat/troubleshooting.md)。

<a id="use-debugging-scripts"></a>

## 使用调试脚本

我们提供了两个调试脚本，帮助管理员验证其自部署模型配置。

1. 调试极狐GitLab 到 AI 网关的连接。在您的极狐GitLab 实例上，运行
   [Rake 任务](../raketasks/_index.md)：

   ```shell
   gitlab-rake "gitlab:duo:verify_self_hosted_setup[<username>]"
   ```

   可选：包含一个已分配席位的 `<username>`。
   如果您不包含用户名参数，Rake 任务将使用 root 用户。

1. 调试 AI 网关设置。对于您的 AI 网关容器：

   - 通过设置以下内容，在禁用身份验证的情况下重启 AI 网关容器：

     ```shell
     -e AIGW_AUTH__BYPASS_EXTERNAL=true
     ```

     此设置是故障排除命令运行 **系统交换测试** 所必需的。故障排除完成后，您必须移除此设置。

   - 在您的 AI 网关容器中，运行：

     ```shell
     docker exec -it <ai-gateway-container> sh
     poetry run troubleshoot [options]
     ```

     `troubleshoot` 命令支持以下选项：

     | 选项               | 默认值          | 示例                                                       | 描述 |
     |----------------------|------------------|---------------------------------------------------------------|-------------|
     | `--endpoint`         | `localhost:5052` | `--endpoint=localhost:5052`                                   | AI 网关端点 |
     | `--model-family`     | -                | `--model-family=mistral`                                      | 要测试的模型系列。可能的值是 `mistral`、`mixtral`、`gpt` 或 `claude_3` |
     | `--model-endpoint`   | -                | `--model-endpoint=http://localhost:4000/v1`                   | 模型端点。对于托管在 vLLM 上的模型，请添加 `/v1` 后缀。 |
     | `--model-identifier` | -                | `--model-identifier=custom_openai/Mixtral-8x7B-Instruct-v0.1` | 模型标识符。 |
     | `--api-key`          | -                | `--api-key=your-api-key`                                      | 模型 API 密钥。 |

     **示例**：

     对于在 AWS Bedrock 上运行的 `claude_3` 模型：

     ```shell
     poetry run troubleshoot \
       --model-family=claude_3 \
       --model-identifier=bedrock/anthropic.claude-3-5-sonnet-20240620-v1:0
     ```

     对于在 vLLM 上运行的 `mixtral` 模型：

     ```shell
     poetry run troubleshoot \
       --model-family=mixtral \
       --model-identifier=custom_openai/Mixtral-8x7B-Instruct-v0.1 \
       --api-key=your-api-key \
       --model-endpoint=http://<your-model-endpoint>/v1
     ```

故障排除完成后，**不要**使用 `AIGW_AUTH__BYPASS_EXTERNAL=true` 停止并重启 AI 网关容器。

> [!warning]
> 您不得在生产环境中绕过身份验证。

验证命令的输出，并相应地进行修复。

如果两个命令都成功，但极狐GitLab Duo 代码建议仍然无法使用，请在议题跟踪器上提交一个议题。

<a id="gitlab-duo-health-check-is-not-working"></a>

## 极狐GitLab Duo 健康检查不工作

当您 [为极狐GitLab Duo 运行健康检查](../gitlab_duo/configure/_index.md#run-a-health-check-for-gitlab-duo) 时，您可能会遇到类似 `401 response from the AI Gateway` 的错误。

要解决此问题，首先检查极狐GitLab Duo 功能是否正常运行。例如，向极狐GitLab Duo Chat 发送一条消息。

如果这不起作用，该错误可能是因为极狐GitLab Duo 健康检查的已知问题。有关更多信息，请参阅 [议题 517097](https://gitlab.com/gitlab-org/gitlab/-/issues/517097)。

<a id="check-if-gitlab-can-make-a-request-to-the-model"></a>

## 检查极狐GitLab 是否可以向模型发出请求

在 GitLab Rails 控制台中，通过运行以下命令验证极狐GitLab 是否可以连接到您的自部署模型：

```ruby
self_hosted_model = Ai::SelfHostedModel.find_by(name: "<your_model_name>")
user = User.find_by_id(1)
Gitlab::Llm::AiGateway::SelfHostedModels::ConnectionTester.new(user, self_hosted_model).execute
```

如果极狐GitLab 可以访问该模型，命令将返回 `nil`。否则，它将返回一个描述错误的字符串。

如果不是这种情况，这可能意味着以下之一：

- 极狐GitLab 环境变量配置不正确。要解决此问题，[检查极狐GitLab 环境变量是否设置正确](#check-that-the-ai-gateway-environment-variables-are-set-up-correctly)。
- AI 网关不可达。要解决此问题，[检查极狐GitLab 是否可以向 AI 网关发出 HTTP 请求](#check-if-gitlab-can-make-an-http-request-to-the-ai-gateway)。
- 当 LLM 服务器与 AI 网关容器安装在同一实例上时，本地请求可能无法工作。要解决此问题，[允许来自 Docker 容器的本地请求](#llm-server-is-not-available-inside-the-ai-gateway-container)。

<a id="check-if-a-user-can-request-code-suggestions"></a>

## 检查用户是否可以请求代码建议

在 GitLab Rails 控制台中，通过运行以下命令检查用户是否可以请求代码建议：

```ruby
User.find_by_id("<user_id>").can?(:access_code_suggestions)
```

如果返回 `false`，则表示缺少某些配置，用户无法访问代码建议。

此缺失配置可能是由于以下任一原因：

- 许可证无效。要解决此问题，[检查或更新您的许可证](../license_file.md#see-current-license-information)。
- 极狐GitLab Duo 未配置为使用自部署模型。要解决此问题，[检查极狐GitLab 实例是否配置为使用自部署模型](#check-if-gitlab-instance-is-configured-to-use-self-hosted-models)。

<a id="check-if-gitlab-instance-is-configured-to-use-self-hosted-models"></a>

## 检查极狐GitLab 实例是否配置为使用自部署模型

先决条件：

- 管理员访问权限。

要检查极狐GitLab Duo 是否配置正确：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **自部署模型**。
1. 展开 **AI 原生功能**。
1. 在 **功能** 下，检查 **代码建议** 和 **代码生成** 是否设置为 **自部署模型**。

<a id="check-that-the-ai-gateway-url-is-set-up-correctly"></a>

## 检查 AI 网关 URL 是否设置正确

要检查 AI 网关 URL 是否正确，请在 GitLab Rails 控制台上运行以下命令：

```ruby
ApplicationSetting.current.ai_gateway_url == "<your-ai-gateway-instance-url>"
```

如果 AI 网关未设置，[配置您的极狐GitLab 实例以访问 AI 网关](configure_duo_features.md#configure-access-to-the-local-ai-gateway)。

<a id="validate-the-gitlab-duo-agent-platform-service-url"></a>

## 验证极狐GitLab Duo Agent Platform 服务 URL

要检查 Agent Platform 服务的 URL 是否正确，请在 GitLab Rails 控制台上运行以下命令：

```ruby
ApplicationSetting.current.duo_agent_platform_service_url == "<your-duo-agent-platform-instance-url>"
```

Agent Platform 服务的 URL 是 TCP URL，不能有 `http://` 或 `https://` 前缀。

如果 Agent Platform 的 URL 尚未设置，您必须 [配置您的极狐GitLab 实例以访问该 URL](configure_duo_features.md#configure-access-to-the-gitlab-duo-agent-platform)。

<a id="check-if-gitlab-can-make-an-http-request-to-the-ai-gateway"></a>

## 检查极狐GitLab 是否可以向 AI 网关发出 HTTP 请求

在 GitLab Rails 控制台中，通过运行以下命令验证极狐GitLab 是否可以向 AI 网关发出 HTTP 请求：

```ruby
HTTParty.get('<your-aigateway-endpoint>/monitoring/healthz', headers: { 'accept' => 'application/json' }).code
```

如果响应不是 `200`，则意味着以下任一情况：

- 网络配置不正确，无法让极狐GitLab 访问 AI 网关容器。请联系您的网络管理员以验证设置。
- AI 网关无法处理请求。要解决此问题，[检查 AI 网关是否可以向模型发出请求](#check-if-the-ai-gateway-can-make-a-request-to-the-model)。

<a id="check-if-the-ai-gateway-can-make-a-request-to-the-model"></a>

## 检查 AI 网关是否可以向模型发出请求

从 AI 网关容器中，向 AI 网关 API 发出 HTTP 请求以检查自部署模型连接。替换：

- 将 `<your_model_name>` 替换为您正在使用的模型的模型系列。例如 `mistral` 或 `codegemma`。
- 将 `<your_model_identifier>` 替换为您的模型部署的标识符。例如 `custom_openai/mistral:instruct`。
- 将 `<your_model_endpoint>` 替换为模型托管的端点。

```shell
docker exec -it <ai-gateway-container> sh
curl --request POST "http://localhost:5052/v1/prompts/model_configuration%2Fcheck" \
     --header 'accept: application/json' \
     --header 'Content-Type: application/json' \
     --data '{ "stream": false, "inputs": {}, "model_metadata": { "name": "<your_model_name>", "identifier": "<your_model_identifier>", "endpoint": "<your_model_endpoint>", "provider": "openai" } }'
```

如果请求失败，则：

- AI 网关可能未正确配置为使用自部署模型。要解决此问题，[检查 AI 网关环境变量是否设置正确](#check-that-the-ai-gateway-environment-variables-are-set-up-correctly)。
- AI 网关可能无法访问该模型。要解决此问题，[检查模型是否可从 AI 网关访问](#check-if-the-model-is-reachable-from-ai-gateway)。
- 模型端点可能不正确。检查该值，并在必要时进行更正。

<a id="check-if-ai-gateway-can-process-requests"></a>

## 检查 AI 网关是否可以处理请求

```shell
docker exec -it <ai-gateway-container> sh
curl '<your-aigateway-endpoint>/monitoring/healthz'
```

如果响应不是 `200`，则意味着 AI 网关未正确安装。要解决此问题，请遵循 [如何安装 AI 网关的文档](../../install/install_ai_gateway.md)。

<a id="check-that-the-ai-gateway-environment-variables-are-set-up-correctly"></a>

## 检查 AI 网关环境变量是否设置正确

要检查 AI 网关环境变量是否设置正确，请在 AI 网关容器上的控制台中运行以下命令：

```shell
docker exec -it <ai-gateway-container> sh
echo $AIGW_CUSTOM_MODELS__ENABLED # must be true
```

如果环境变量设置不正确，[创建一个容器](../../install/install_ai_gateway.md#ai-gateway-images)。

<a id="check-if-the-model-is-reachable-from-ai-gateway"></a>

## 检查模型是否可从 AI 网关访问

在 AI 网关容器上创建一个 shell，并向模型发出 curl 请求。如果您发现 AI 网关无法发出该请求，这可能是由以下原因造成的：

1. 模型服务器运行不正常。
1. 容器周围的网络设置配置不正确，无法允许请求到达模型托管的位置。

要解决此问题，请联系您的网络管理员。

<a id="check-if-ai-gateway-can-make-requests-to-your-gitlab-instance"></a>

## 检查 AI 网关是否可以向您的极狐GitLab 实例发出请求

`AIGW_GITLAB_URL` 中定义的极狐GitLab 实例必须可从 AI 网关容器访问，以便进行请求身份验证。
如果该实例不可达（例如，由于代理配置错误），请求可能会失败并出现错误，例如：

- ```shell
  jose.exceptions.JWTError: Signature verification failed
  ```

- ```shell
  gitlab_cloud_connector.providers.CompositeProvider.CriticalAuthError: No keys founds in JWKS; are OIDC providers up?
  ```

在这种情况下，请验证 `AIGW_GITLAB_URL` 和 `$AIGW_GITLAB_API_URL` 是否已正确设置到容器并可访问。从容器运行时，以下命令应该成功：

```shell
poetry run troubleshoot
curl "$AIGW_GITLAB_API_URL/projects"
```

如果不成功，请验证您的网络配置。

<a id="the-images-platform-does-not-match-the-host"></a>

## 镜像的平台与主机不匹配

当您 [使用 AI 网关镜像](../../install/install_ai_gateway.md#ai-gateway-images) 时，您可能会遇到错误，提示 `The requested image's platform (linux/amd64) does not match the detected host`。

要解决此错误，请在 `docker run` 命令中添加 `--platform linux/amd64`：

```shell
docker run --platform linux/amd64 -e AIGW_GITLAB_URL=<your-gitlab-endpoint> <image>
```

<a id="llm-server-is-not-available-inside-the-ai-gateway-container"></a>

## LLM 服务器在 AI 网关容器内不可用

如果 LLM 服务器与 AI 网关容器安装在同一实例上，则可能无法通过本地主机访问。

要解决此问题：

1. 在 `docker run` 命令中包含 `--network host`，以启用来自 AI 网关容器的本地请求。
1. 使用 `-e AIGW_FASTAPI__METRICS_PORT=8083` 标志来解决端口冲突。

```shell
docker run --network host -e AIGW_GITLAB_URL=<your-gitlab-endpoint> -e AIGW_FASTAPI__METRICS_PORT=8083 <image>
```

<a id="vllm-404-error"></a>

## vLLM 404 错误

如果您在使用 vLLM 时遇到 **404 错误**，请按照以下步骤解决问题：

1. 创建一个名为 `chat_template.jinja` 的聊天模板文件，内容如下：

   ```jinja
   {%- for message in messages %}
     {%- if message["role"] == "user" %}
       {{- "[INST] " + message["content"] + "[/INST]" }}
     {%- elif message["role"] == "assistant" %}
       {{- message["content"] }}
     {%- elif message["role"] == "system" %}
       {{- bos_token }}{{- message["content"] }}
     {%- endif %}
   {%- endfor %}
   ```

1. 运行 vLLM 命令时，确保指定 `--served-model-name`。例如：

   ```shell
   vllm serve "mistralai/Mistral-7B-Instruct-v0.3" --port <port> --max-model-len 17776 --served-model-name mistral --chat-template chat_template.jinja
   ```

1. 在极狐GitLab UI 中检查 vLLM 服务器 URL，确保该 URL 包含 `/v1` 后缀。正确的格式是：

   ```shell
   http(s)://<your-host>:<your-port>/v1
   ```

<a id="code-suggestions-access-error"></a>

## 代码建议访问错误

如果您在设置后访问代码建议时遇到问题，请尝试以下步骤：

1. 在 Rails 控制台中，检查并验证许可证参数：

   ```shell
   sudo gitlab-rails console
   user = User.find(id) # Replace id with the user provisioned with GitLab Duo Enterprise seat
   Ability.allowed?(user, :access_code_suggestions) # Must return true
   ```

1. 检查所需功能是否已启用且可用：

   ```shell
   ::Ai::FeatureSetting.exists?(feature: [:code_generations, :code_completions], provider: :self_hosted) # Should be true
   ```

<a id="error-a1000"></a>

## 错误 A1000

将极狐GitLab Duo 功能与自部署模型一起使用时，您可能会遇到以下错误：

`I'm sorry, I couldn't respond in time. Please try again. Error code: A1000`

当对您模型的请求可能超过配置的超时时间时，会出现此问题。

常见原因包括：

- 大型上下文窗口或复杂提示
- 模型性能限制
- AI 网关与模型端点之间的网络延迟
- 跨区域推理延迟（适用于 AWS Bedrock 部署）

要解决超时错误：

1. [为 AI 网关配置更高的超时值](configure_duo_features.md#configure-timeout-for-the-ai-gateway)。您可以将超时设置为 60 到 600 秒（10 分钟）之间。
1. 对于极狐GitLab Duo Chat，如果请求仍然超时，请在 AI 网关上 [增加聊天模型请求超时](configure_duo_features.md#configure-the-chat-model-request-timeout)。
1. 调整超时后监控您的日志，以验证错误是否已解决。
1. 如果即使使用更高的超时值，超时错误仍然存在：
   - 检查您模型的性能和资源分配。
   - 验证 AI 网关与模型端点之间的网络连接。
   - 考虑使用性能更高的模型或部署配置。

如果响应在没有错误的情况下被截断，而不是以 `A1000` 失败，请参阅 [响应在没有错误的情况下被截断](#responses-are-truncated-without-an-error)。

<a id="responses-are-truncated-without-an-error"></a>

## 响应在没有错误的情况下被截断

来自大型或推理模型的较长响应可能会在没有错误消息的情况下中途停止。流在模型完成之前结束，部分响应可能看起来是完整的。

当组件之间的代理、负载均衡器或防火墙在模型完成响应之前结束连接时，会出现此问题。当极狐GitLab 检测到中断的流时，如果等待超时，极狐GitLab 会返回 [`Error A1000`](#error-a1000)，如果流本身失败，则返回 [`Error A1003`](../../user/gitlab_duo_chat/troubleshooting.md#error-a1003)。

检查每一跳的超时时间，看看是否出现错误。要解决此问题：

1. 对于 AI 网关，[配置更高的超时值](configure_duo_features.md#configure-timeout-for-the-ai-gateway)，以便极狐GitLab 有足够的时间等待网关。
1. 对于极狐GitLab Duo Chat，[增加聊天模型请求超时](configure_duo_features.md#configure-the-chat-model-request-timeout)，以便 AI 网关有足够的时间等待模型。
1. 检查 AI 网关前面的任何反向代理或负载均衡器。如果您使用 [NGINX 反向代理](../../install/install_ai_gateway.md#set-up-docker-with-nginx-and-ssl)，请提高 `proxy_read_timeout` 以覆盖响应块之间的最长暂停时间，并保持 `proxy_buffering off`。
1. 检查 AI 网关与您的模型服务平台之间的任何代理或负载均衡器是否存在类似的请求或空闲超时。
1. 对于极狐GitLab Duo Agentic Chat，请检查极狐GitLab 前面的反向代理是否存在 WebSocket 空闲或读取超时，这可能会中断较长的流式回答。有关更多信息，请参阅 [Agentic Chat 的响应未显示在 UI 中](#response-from-agentic-chat-does-not-display-in-the-ui)。

<a id="verify-gitlab-setup"></a>

## 验证极狐GitLab 设置

要验证您的极狐GitLab 私有化部署设置，请运行以下命令：

```shell
gitlab-rake gitlab:duo:verify_self_hosted_setup
```

<a id="no-logs-generated-in-the-ai-gateway-server"></a>

## AI 网关服务器中未生成日志

如果 AI 网关服务器中未生成日志，请按照以下步骤进行故障排除：

1. 确保 [已启用 AI 日志](logging.md#turn-on-data-collection-for-gitlab-duo)。
1. 运行以下命令查看 GitLab Rails 日志中的任何错误：

   ```shell
   sudo gitlab-ctl tail
   sudo gitlab-ctl tail sidekiq
   ```

1. 在日志中查找诸如“Error”或“Exception”之类的关键字，以识别任何潜在问题。

<a id="ssl-certificate-errors-and-key-de-serialization-issues-in-the-ai-gateway-container"></a>

## AI 网关容器中的 SSL 证书错误和密钥反序列化问题

当尝试在 AI 网关容器内发起极狐GitLab Duo Chat 时，可能会出现 SSL 证书错误和密钥反序列化问题。

系统在加载 PEM 文件时可能会遇到问题，导致如下错误：

```plaintext
JWKError: Could not deserialize key data. The data may be in an incorrect format, the provided password may be incorrect, or it may be encrypted with an unsupported algorithm.
```

要解决 SSL 证书错误：

- 使用以下环境变量在 Docker 容器中设置适当的证书包路径：
  - `SSL_CERT_FILE=/path/to/ca-bundle.pem`
  - `REQUESTS_CA_BUNDLE=/path/to/ca-bundle.pem`

<a id="error-invocation-of-model-id-meta-isnt-supported"></a>

## 错误：不支持调用模型 ID meta

当模型标识符的格式不正确时，AIGW 日志中会显示以下错误：

```plaintext
Invocation of model ID meta.llama3-3-70b-instruct-v1:0 with on-demand throughput isn\u2019t supported. Retry your request with the ID or ARN of an inference profile that contains this model
```

确保您的 `model identifier` 具有 `bedrock/<region>.<model-id>` 格式，其中：

- `<region>` 是您的 AWS 区域（例如 `us`）
- `<model-id>` 是完整的模型标识符。

例如：`bedrock/us.meta.llama3-3-70b-instruct-v1:0`。更新您的模型配置以使用正确的格式。

<a id="feature-not-accessible-or-feature-button-not-visible"></a>

## 功能不可访问或功能按钮不可见

如果某个功能无法使用或功能按钮（例如，**`/troubleshoot`**）不可见：

1. 检查该功能的 `unit_primitive` 是否列在 [`gitlab-cloud-connector` gem 配置中的自部署模型单元原语列表中](https://gitlab.com/gitlab-org/cloud-connector/gitlab-cloud-connector/-/blob/main/config/services/self_hosted_models.yml)。

   如果该功能不在此文件中，这可能是其无法访问的原因。

1. 可选。如果该功能未列出，您可以通过在极狐GitLab 实例中设置以下内容来验证这是否是问题的原因：

   ```shell
   CLOUD_CONNECTOR_SELF_SIGN_TOKENS=1
   ```

   然后重启极狐GitLab，检查该功能是否变得可访问。

   **重要**：故障排除后，**不要**设置此标志重启极狐GitLab。

   > [!warning]
   > 请勿在生产环境中使用 `CLOUD_CONNECTOR_SELF_SIGN_TOKENS=1`。开发环境应紧密镜像生产环境，不得有隐藏标志或仅限内部使用的变通方法。

1. 要解决此问题：
   - 如果您是 GitLab 团队成员，请通过 [`#g_custom_models` Slack 频道](https://gitlab.enterprise.slack.com/archives/C06DCB3N96F) 联系 Custom Models 团队。
   - 如果您是客户，请通过 [极狐GitLab 支持](https://support.gitlab.com/) 报告该问题。

<a id="error-an-error-occurred-while-fetching-an-authentication-token-for-this-workflow"></a>

## 错误：为此工作流获取身份验证令牌时出错

当您尝试在极狐GitLab 或本地环境中使用 Agentic Chat 时，可能会出现此错误。

您可能还会在 IDE 的 [GitLab Language Server](../../editor_extensions/language_server/_index.md) 日志中看到以下内容：

```shell
2026-01-09T20:17:43:419 [error]: [WorkflowRailsService] Failed to fetch the workflow token
    Error: Fetching direct_access from https://gitlab.example.com/api/v4/ai/duo_workflows/direct_access failed.
{"message":"400 Bad request - 14:failed to connect to all addresses; last error: UNKNOWN: ipv4:172.x.x.x:50052: Ssl handshake failed (TSI_PROTOCOL_FAILURE): SSL_ERROR_SSL: error:100000f7:SSL routines:OPENSSL_internal:WRONG_VERSION_NUMBER: Invalid certificate verification context. debug_error_string:{UNKNOWN:Error received from peer  {grpc_status:14, grpc_message:\"failed to connect to all addresses; last error: UNKNOWN: ipv4:172.x.x.x:50052: Ssl handshake failed (TSI_PROTOCOL_FAILURE): SSL_ERROR_SSL: error:100000f7:SSL routines:OPENSSL_internal:WRONG_VERSION_NUMBER: Invalid certificate verification context\"}}"}
2026-01-09T20:17:43:433 [error]: Max retries exceeded or non-retryable error: An error occurred while fetching an authentication token for this workflow.
2026-01-09T20:17:43:435 [error]: Workflow failed with status code "50": An error occurred while fetching an authentication token for this workflow.
```

这意味着语言服务器无法与 `direct_access` 端点通信以生成 JWT 令牌，原因是证书问题。

如果您不使用 TLS 将自部署模型与 Agent Platform 连接，要解决此问题，请 [关闭](configure_duo_features.md#configure-access-to-the-gitlab-duo-agent-platform) 到极狐GitLab Duo Agent Platform 服务的 TLS 连接。

<a id="response-from-agentic-chat-does-not-display-in-the-ui"></a>

## Agentic Chat 的响应未显示在 UI 中

聊天响应需要浏览器与极狐GitLab 之间保持持久的 WebSocket 连接。如果您的反向代理不支持 WebSocket 升级，则响应会成功生成，但不会显示在极狐GitLab UI 的聊天中。

<a id="symptoms"></a>

### 症状

- `llm.log` 显示 `chunk_received`、`streaming_finished` 和 `final_answer_received`，且没有错误。
- AI 网关日志显示模型响应成功。
- 极狐GitLab Duo Chat UI 似乎正在处理请求，但从未显示响应。

要解决此问题，请确保您的反向代理配置为满足 [入站连接要求](../gitlab_duo/configure/_index.md#allow-inbound-connections-from-clients-to-the-gitlab-instance)。
