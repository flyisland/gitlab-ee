---
stage: AI-powered
group: Custom Models
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
description: Enable logging for self-hosted models.
title: 自部署模型的日志
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.1 中引入，受功能标志 `ai_custom_model` 控制。默认禁用。
- 在极狐GitLab 17.6 中启用于私有化部署 GitLab。
- 在极狐GitLab 17.6 及更高版本中要求使用极狐GitLab Duo 附加组件。
- 功能标志 `ai_custom_model` 在极狐GitLab 17.8 中移除。
- 在极狐GitLab 17.9 中 GA。
- 在极狐GitLab 17.9 中通过 UI 添加了打开和关闭日志记录的功能。
- 在极狐GitLab 18.0 中改为包括专业版。

{{< /history >}}

借助详细的日志记录，更有效地监控自部署模型的性能并调试问题。

<a id="turn-on-data-collection-for-gitlab-duo"></a>

## 为极狐GitLab Duo 启用数据收集

前提条件：

- 您必须是管理员。

极狐GitLab Duo 的数据收集因 AI 网关配置而异。

<a id="on-gitlab-self-managed-with-a-self-hosted-ai-gateway"></a>

### 在带有自部署 AI 网关的私有化部署 GitLab 上

当您开启数据收集后，详细的 AI 日志（提示词和响应）会存储在您极狐GitLab 实例和 AI 网关本地的 `llm.log` 中，数据不会共享给极狐GitLab。

要开启数据收集：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **数据收集** 下，选择 **收集使用数据**。
1. 选择 **保存更改**。

<a id="gitlab-self-managed-with-a-gitlab-managed-ai-gateway"></a>

### 私有化部署 GitLab 与 极狐GitLab 管理的 AI 网关

开启 **收集使用数据** 会与极狐GitLab 共享使用数据。在此场景中，为了保护敏感数据，在极狐GitLab 管理的 AI 网关中未启用扩展日志记录。

要开启数据收集：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **数据收集** 下，选择 **收集使用数据**。
1. 选择 **保存更改**。

<a id="logs-in-your-gitlab-installation"></a>

## 您的极狐GitLab 实例中的日志

日志记录设计旨在保护敏感信息的同时保持系统操作的透明度，由以下组件构成：

- 捕获发往极狐GitLab 实例请求的日志。
- 日志记录控制。
- `llm.log` 文件。

<a id="logs-that-capture-requests-to-the-gitlab-instance"></a>

### 捕获发往极狐GitLab 实例请求的日志

`application.json`、`production_json.log` 以及 `production.log` 等文件中的日志会捕获发往极狐GitLab 实例的请求：

- **过滤请求**：我们在这些文件中记录请求，但会确保敏感数据（如输入参数）已被**过滤**。这意味着，虽然请求元数据会被捕获（例如请求类型、端点和响应状态），但实际的输入数据（例如查询参数、变量和内容）不会被记录，以防止暴露敏感信息。
- **示例 1**：在代码建议补全请求的场景中，日志会捕获请求详情，同时过滤掉敏感信息：

  ```json
  {
    "method": "POST",
    "path": "/api/graphql",
    "controller": "GraphqlController",
    "action": "execute",
    "status": 500,
    "params": [
      {"key": "query", "value": "[FILTERED]"},
      {"key": "variables", "value": "[FILTERED]"},
      {"key": "operationName", "value": "chat"}
    ],
    "exception": {
      "class": "NoMethodError",
      "message": "undefined method `id` for {:skip=>true}:Hash"
    },
    "time": "2024-08-28T14:13:50.328Z"
  }
  ```

  如示例所示，错误信息和请求的通用结构被记录，但敏感的输入参数被标记为 `[FILTERED]`。

- **示例 2**：在代码建议补全请求的场景中，日志同样会捕获请求详情并过滤敏感信息：

  ```json
  {
    "method": "POST",
    "path": "/api/v4/code_suggestions/completions",
    "status": 200,
    "params": [
      {"key": "prompt_version", "value": 1},
      {"key": "current_file", "value": {"file_name": "/test.rb", "language_identifier": "ruby", "content_above_cursor": "[FILTERED]", "content_below_cursor": "[FILTERED]"}},
      {"key": "telemetry", "value": []}
    ],
    "time": "2024-10-15T06:51:09.004Z"
  }
  ```

  如示例所示，请求的通用结构被记录，但诸如 `content_above_cursor` 和 `content_below_cursor` 等敏感输入参数被标记为 `[FILTERED]`。

<a id="logging-control"></a>

### 日志记录控制

要控制部分日志，可通过极狐GitLab Duo 设置页面打开或关闭数据收集。关闭数据收集会禁用特定操作的日志记录。

<a id="llmlog-file"></a>

### `llm.log` 文件

在自部署 AI 网关配置中，当数据收集开启时，通过私有化部署极狐GitLab 实例发生的代码生成和极狐GitLab Duo Chat 事件会被捕获到
[`llm.log` 文件](../logs/_index.md#llmlog)中。未开启时，该日志文件不捕获任何内容。

代码补全日志在 AI 网关中捕获。这些日志不会传输到极狐GitLab，仅在您的私有化部署极狐GitLab 基础设施上可见。

- [轮转、管理、导出和可视化 `llm.log` 中的日志](../logs/_index.md)。
- [查看日志文件位置（例如，以便您可以删除日志）](../logs/_index.md#llm-input-and-output-logging)。

<a id="logs-in-your-ai-gateway-container"></a>

## 您的 AI 网关容器中的日志

要指定 AI 网关和极狐GitLab Duo Agent Platform 生成的日志位置，请运行：

```shell
docker run -e AIGW_GITLAB_URL=<your_gitlab_instance> \
 -e AIGW_GITLAB_API_URL=https://<your_gitlab_domain>/api/v4/ \
 -e DUO_WORKFLOW_SELF_SIGNED_JWT__SIGNING_KEY="your-signing-key" \
 -e AIGW_LOGGING__TO_FILE="aigateway.log" \
 -e DUO_WORKFLOW_LOGGING__TO_FILE="duo_agent_platform.log" \
 -v <your_aigateway_file_path>:aigateway.log \
 -v <your_duo_agent_platform_file_path>:duo_agent_platform.log \
 <image>
```

默认情况下，日志级别设置为 `INFO`。要将日志级别更改为 `DEBUG`，请运行：

```shell
docker run -e AIGW_GITLAB_URL=<your_gitlab_instance> \
 -e AIGW_GITLAB_API_URL=https://<your_gitlab_domain>/api/v4/ \
 -e DUO_WORKFLOW_SELF_SIGNED_JWT__SIGNING_KEY="your-signing-key" \
 -e AIGW_LOGGING__TO_FILE="aigateway.log" \
 -e DUO_WORKFLOW_LOGGING__TO_FILE="duo_agent_platform.log" \
 -e AIGW_LOGGING__LEVEL="DEBUG" \
 -e DUO_WORKFLOW_LOGGING__LEVEL="DEBUG" \
 -v <your_aigateway_file_path>:aigateway.log \
 -v <your_duo_agent_platform_file_path>:duo_agent_platform.log \
 <image>
```

此外，要记录来自 `litellm` 的所有调试语句，请添加以下环境变量：

```shell
-e AIGW_LOGGING__ENABLE_LITELLM_LOGGING=true
```

如果您不指定文件名，日志会流式输出到标准输出，也可以通过 Docker 日志管理。更多信息，请参见 [Docker 日志文档](https://docs.docker.com/reference/cli/docker/container/logs/)。

此外，AI 网关执行的输出也可用于调试问题。要访问它们：

- 使用 Docker 时：

  ```shell
  docker logs <container-id>
  ```

- 使用 Kubernetes 时：

  ```shell
  kubectl logs <container-name>
  ```

要将这些日志导入到日志解决方案，请参阅您的日志提供商的文档。

<a id="logs-structure"></a>

## 日志结构

当发出 POST 请求（例如，向 `/chat/completions` 端点）时，服务器会记录请求：

- 载荷
- 请求头
- 元数据

<a id="1-request-payload"></a>

### 1. 请求载荷

JSON 载荷通常包含以下字段：

- `messages`：消息对象数组。
  - 每个消息对象包含：
    - `content`：表示用户输入或查询的字符串。
    - `role`：指示消息发送者的角色（例如 `user`）。
- `model`：指定要使用的模型的字符串（例如 `mistral`）。
- `max_tokens`：指定响应中生成的最大令牌数的整数。
- `n`：指示要生成的补全数量的整数。
- `stop`：表示生成文本停止序列的字符串数组。
- `stream`：指示是否应流式传输响应的布尔值。
- `temperature`：控制输出随机性的浮点数。

<a id="example-request"></a>

#### 请求示例

```json
{
    "messages": [
        {
            "content": "<s>[SUFFIX]None[PREFIX]# # build a hello world ruby method\n def say_goodbye\n    puts \"Goodbye, World!\"\n  end\n\ndef main\n  say_hello\n  say_goodbye\nend\n\nmain",
            "role": "user"
        }
    ],
    "model": "mistral",
    "max_tokens": 128,
    "n": 1,
    "stop": ["[INST]", "[/INST]", "[PREFIX]", "[MIDDLE]", "[SUFFIX]"],
    "stream": false,
    "temperature": 0.0
}
```

<a id="2-request-headers"></a>

### 2. 请求头

请求头提供有关发出请求的客户端的附加上下文。关键请求头可能包括：

- `Authorization`：包含用于 API 访问的 Bearer 令牌。
- `Content-Type`：指示资源的媒体类型（例如 `JSON`）。
- `User-Agent`：发出请求的客户端软件信息。
- `X-Stainless-` 请求头：提供有关客户端环境的附加元数据的各种请求头。

<a id="example-request-headers"></a>

#### 请求头示例

```json
{
    "host": "0.0.0.0:4000",
    "accept-encoding": "gzip, deflate",
    "connection": "keep-alive",
    "accept": "application/json",
    "content-type": "application/json",
    "user-agent": "AsyncOpenAI/Python 1.51.0",
    "authorization": "Bearer <TOKEN>",
    "content-length": "364"
}
```

<a id="3-request-metadata"></a>

### 3. 请求元数据

元数据包含描述请求上下文的各种字段：

- `requester_metadata`：关于请求者的附加元数据。
- `user_api_key`：用于请求的 API 密钥（匿名化）。
- `api_version`：所使用的 API 版本。
- `request_timeout`：请求的超时时长。
- `call_id`：调用的唯一标识符。

<a id="example-metadata"></a>

#### 元数据示例

```json
{
    "user_api_key": "<ANONYMIZED_KEY>",
    "api_version": "1.48.18",
    "request_timeout": 600,
    "call_id": "e1aaa316-221c-498c-96ce-5bc1e7cb63af"
}
```

<a id="example-response"></a>

### 响应示例

服务器以一个结构化的模型响应进行回复。例如：

```python
Response: ModelResponse(
    id='chatcmpl-5d16ad41-c130-4e33-a71e-1c392741bcb9',
    choices=[
        Choices(
            finish_reason='stop',
            index=0,
            message=Message(
                content=' Here is the corrected Ruby code for your function:\n\n```ruby\ndef say_hello\n  puts "Hello, World!"\nend\n\ndef say_goodbye\n    puts "Goodbye, World!"\nend\n\ndef main\n  say_hello\n  say_goodbye\nend\n\nmain\n```\n\nIn your original code, the method names were misspelled as `say_hell` and `say_gobdye`. I corrected them to `say_hello` and `say_goodbye`. Also, there was no need for the prefix',
                role='assistant',
                tool_calls=None,
                function_call=None
            )
        )
    ],
    created=1728983827,
    model='mistral',
    object='chat.completion',
    system_fingerprint=None,
    usage=Usage(
        completion_tokens=128,
        prompt_tokens=69,
        total_tokens=197,
        completion_tokens_details=None,
        prompt_tokens_details=None
    )
)
```

<a id="logs-in-your-inference-service-provider"></a>

## 推理服务提供商的日志

极狐GitLab 不管理由您的推理服务提供商生成的日志。有关如何使用其日志的信息，请参阅您推理服务提供商的文档。

<a id="logging-behavior-in-gitlab-and-ai-gateway-environments"></a>

## 极狐GitLab 和 AI 网关环境中的日志记录行为

极狐GitLab 通过 `llm.log` 来为 AI 相关活动提供日志记录功能，该文件捕获输入、输出和其他相关信息。不过，日志记录行为会根据极狐GitLab 实例和 AI 网关是**私有化部署**还是**云连接**而有所不同。

默认情况下，为了支持 AI 功能数据的[数据保留策略](../../user/gitlab_duo/data_usage.md#data-retention)，日志不包含 LLM 提示词输入和响应输出。

<a id="logging-scenarios"></a>

## 日志记录场景

<a id="gitlab-self-managed-and-self-hosted-ai-gateway"></a>

### 私有化部署 GitLab 和 自部署 AI 网关

在这种配置下，客户同时托管极狐GitLab 和 AI 网关。

- **日志记录行为**：完全日志记录已启用，所有提示词、输入和输出都会记录到实例上的 `llm.log`。
- 当 **收集使用数据** 被启用时，会记录额外的调试信息，包括：
  - 预处理后的提示词。
  - 最终提示词。
  - 附加上下文。
- **隐私**：由于极狐GitLab 和 AI 网关都是私有化部署：
  - 客户可以完全控制数据处理。
  - 敏感信息的日志记录可根据客户决定启用或禁用。

  > [!note]
  > 当 AI 功能使用极狐GitLab 管理的模型时，即便数据收集已开启，也不会在极狐GitLab 管理的 AI 网关中生成详细日志。这可以防止意外泄露敏感信息。

<a id="gitlab-self-managed-and-gitlab-managed-ai-gateway-cloud-connected"></a>

### 私有化部署 GitLab 和 极狐GitLab 管理的 AI 网关（云端连接）

此场景下，客户托管极狐GitLab，但依赖极狐GitLab 管理的 AI 网关进行 AI 处理。

- 日志记录行为：有关极狐GitLab 在使用云连接 AI 网关时如何处理 AI 提示词和响应数据的信息，请参见[极狐GitLab Duo 数据使用](../../user/gitlab_duo/data_usage.md#data-retention)。
- 扩展日志记录：即便 **收集使用数据** 已启用，也不会在极狐GitLab 管理的 AI 网关中生成详细日志，以避免意外泄露敏感信息。
  - 在此设置中，日志记录保持最小化，扩展日志记录功能默认禁用。
- 隐私：此配置旨在确保敏感数据不会在云端环境中被记录。

<a id="logging-in-cloud-connected-ai-gateways"></a>

## 云端连接的 AI 网关中的日志记录

有关极狐GitLab 在使用云连接 AI 网关时如何处理 AI 提示词和响应数据的信息，请参见[极狐GitLab Duo 数据使用](../../user/gitlab_duo/data_usage.md#data-retention)。

<a id="cross-referencing-logs-between-the-ai-gateway-and-gitlab"></a>

## 在 AI 网关和极狐GitLab 之间交叉引用日志

`correlation_id` 属性被分配给每个请求，并贯穿响应请求的不同组件。更多信息，请参见[有关使用关联 ID 查找日志的文档](../logs/tracing_correlation_id.md)。

关联 ID 可以在您的 AI 网关和极狐GitLab 日志中找到。但在您的模型提供商日志中不存在。

<a id="related-topics"></a>

### 相关主题

- [使用 jq 解析极狐GitLab 日志](../logs/log_parsing.md)
- [搜索日志中的关联 ID](../logs/tracing_correlation_id.md#searching-your-logs-for-the-correlation-id)