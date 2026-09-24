---
stage: AI-powered
group: AI Coding
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for 极狐GitLab Duo Code Suggestions.
title: 代码建议 API
---

使用此 API 访问 极狐GitLab Duo 代码建议。

<a id="generate-code-completions"></a>

## 生成代码补全

{{< details >}}

- 状态：实验性

{{< /details >}}

{{< history >}}

- 于极狐GitLab 16.2 [作为功能标志引入](../administration/feature_flags/_index.md)，名称为 `code_suggestions_completion_api`。默认禁用。此功能为实验性。
- 调用此端点前需要生成 JWT 的要求在极狐GitLab 16.3 中已移除。
- 于极狐GitLab 16.8 中 GA。功能标志 `code_suggestions_completion_api` 已移除。
- `context` 和 `user_instruction` 属性在极狐GitLab 17.1 中[作为功能标志引入](../administration/feature_flags/_index.md)，名称为 `code_suggestions_context`。默认禁用。
- `context` 和 `user_instruction` 属性在极狐GitLab 18.6 中 GA。功能标志 `code_suggestions_context` 已移除。

{{< /history >}}

```plaintext
POST /code_suggestions/completions
```

> [!note]
> 此端点对每个用户限制为每分钟 60 个请求。

使用 AI 抽象层生成代码补全。

发往此端点的请求会被代理到
[AI 网关](https://jihulab.com/gitlab-cn/modelops/applied-ml/code-suggestions/ai-assist/-/blob/main/docs/api.md)。

参数：

| 属性 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `current_file` | hash | 是 | 为其生成建议的文件的属性。查看[文件属性](#文件属性)了解该属性接受的字符串列表。 |
| `intent` | string | 否 | 补全请求的意图。可以是 `completion`（补全）或 `generation`（生成）。 |
| `stream` | boolean | 否 | 是否在就绪时以小数据块流式传输响应（如适用）。默认值：`false`。 |
| `project_path` | string | 否 | 项目的路径。 |
| `generation_type` | string | 否 | 生成请求的事件类型。可以是 `comment`、`empty_function` 或 `small_file`。 |
| `context` | array | 否 | 用于代码建议的附加上下文。查看[上下文属性](#上下文属性)了解该属性接受的参数列表。 |
| `user_instruction` | string | 否 | 用户对代码建议的指令。 |

<a id="file-attributes"></a>

### 文件属性

`current_file` 属性接受以下字符串：

- `file_name` - 文件名称。必填。
- `content_above_cursor` - 当前光标位置以上的文件内容。必填。
- `content_below_cursor` - 当前光标位置以下的文件内容。可选。

<a id="context-attributes"></a>

### 上下文属性

`context` 属性接受具有以下属性的元素列表：

- `type` - 上下文元素的类型。可以是 `file`（文件）或 `snippet`（代码片段）。
- `name` - 上下文元素的名称。文件或代码片段的名称。
- `content` - 上下文元素的内容。文件体或函数。

示例请求：

```shell
curl --request POST \
  --header "Authorization: Bearer <YOUR_ACCESS_TOKEN>" \
  --data '{
      "current_file": {
        "file_name": "car.py",
        "content_above_cursor": "class Car:\n    def __init__(self):\n        self.is_running = False\n        self.speed = 0\n    def increase_speed(self, increment):",
        "content_below_cursor": ""
      },
      "intent": "completion"
    }' \
  --url "https://gitlab.example.com/api/v4/code_suggestions/completions"
```

示例响应：

```json
{
  "id": "id",
  "model": {
    "engine": "国内 SOTA 模型",
    "name": "国内 SOTA 模型"
  },
  "object": "text_completion",
  "created": 1688557841,
  "choices": [
    {
      "text": "\n        if self.is_running:\n            self.speed += increment\n            print(\"The car's speed is now",
      "index": 0,
      "finish_reason": "length"
    }
  ]
}
```

<a id="validate-that-code-suggestions-is-enabled"></a>

## 验证代码建议是否已启用

{{< history >}}

- 于极狐GitLab 16.7 引入。

{{< /history >}}

使用此端点验证以下任一情况是否满足：

- 项目已启用 `code_suggestions`。
- 项目的群组在其命名空间设置中已启用 `code_suggestions`。

```plaintext
POST code_suggestions/enabled
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|------|------|----------|------|
| `project_path` | string | 是 | 要验证的项目的路径。 |

如果成功，返回：

- [`200`](rest/troubleshooting.md#status-codes) 表示功能已启用。
- [`403`](rest/troubleshooting.md#status-codes) 表示功能已禁用。

此外，如果路径为空或项目不存在，则返回 [`404`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request POST \
  --url "https://gitlab.example.com/api/v4/code_suggestions/enabled" \
  --header "PRIVATE-TOKEN: <YOUR_ACCESS_TOKEN>" \
  --header "Content-Type: application/json" \
  --data '{
      "project_path": "group/project_name"
    }'
```

<a id="fetch-direct-connection-details-for-the-ai-gateway"></a>

## 获取 AI 网关的直接连接详情

{{< history >}}

- 于极狐GitLab 17.0 [作为功能标志引入](../administration/feature_flags/_index.md)，名称为 `code_suggestions_direct_completions`。默认禁用。
- 于极狐GitLab 17.2 中 GA。功能标志 `code_suggestions_direct_completions` 已移除。

{{< /history >}}

```plaintext
POST /code_suggestions/direct_access
```

> [!note]
> 此端点对每个用户限制为每 5 分钟 10 个请求。

返回用户特定的连接详情，IDE/客户端可使用这些详情直接向 AI 网关发送 `completion` 请求，包含必须代理到 AI 网关的标头以及所需的身份验证令牌。

示例请求：

```shell
curl --request POST \
  --header "Authorization: Bearer <YOUR_ACCESS_TOKEN>" \
  --url "https://gitlab.example.com/api/v4/code_suggestions/direct_access"
```

示例响应：

```json
{
  "base_url": "http://0.0.0.0:5052",
  "token": "a valid token",
  "expires_at": 1713343569,
  "headers": {
    "X-Gitlab-Instance-Id": "292c3c7c-c5d5-48ec-b4bf-f00b724ce560",
    "X-Gitlab-Realm": "saas",
    "X-Gitlab-Global-User-Id": "Df0Jhs9xlbetQR8YoZCKDZJflhxO0ZBI8uoRzmpnd1w=",
    "X-Gitlab-Host-Name": "gitlab.example.com"
  }
}
```

<a id="fetch-connection-details"></a>

## 获取连接详情

{{< history >}}

- 于极狐GitLab 18.3 引入。

{{< /history >}}

```plaintext
POST /code_suggestions/connection_details
```

> [!note]
> 此端点对每个用户限制为每分钟 10 个请求。

返回特定于用户的连接详情，IDE/客户端可用于遥测，包括有关用户连接的极狐GitLab 实例的元数据。

示例请求：

```shell
curl --request POST \
  --header "Authorization: Bearer <YOUR_ACCESS_TOKEN>" \
  --url "https://gitlab.example.com/api/v4/code_suggestions/connection_details"
```

示例响应：

```json
{
  "instance_id": "292c3c7c-c5d5-48ec-b4bf-f00b724ce560",
  "instance_version": "18.2",
  "realm": "saas",
  "global_user_id": "Df0Jhs9xlbetQR8YoZCKDZJflhxO0ZBI8uoRzmpnd1w=",
  "host_name": "gitlab.example.com",
  "feature_enablement_type": "duo_pro",
  "saas_duo_pro_namespace_ids": "1000000"
}
```