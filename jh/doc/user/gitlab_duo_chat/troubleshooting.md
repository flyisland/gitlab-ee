---
stage: AI-powered
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Duo Chat 故障排查
---

使用极狐GitLab Duo Chat 时，你可能会遇到以下问题。

<a id="the-gitlab-duo-chat-button-is-not-displayed"></a>

## **极狐GitLab Duo Chat** 按钮未显示

如果该按钮未在 UI 右上角显示，请确保极狐GitLab Duo Chat [已启用](../gitlab_duo/turn_on_off.md)。

**极狐GitLab Duo Chat** 按钮不会在[已禁用极狐GitLab Duo 功能](../gitlab_duo/turn_on_off.md)的群组和项目上显示。

启用极狐GitLab Duo Chat 后，该按钮可能需要几分钟才能显示。

如果这没有解决问题，你还可以查看以下故障排查文档：

- [极狐GitLab Duo 代码建议](../project/repository/code_suggestions/troubleshooting.md)
- [极狐GitLab Duo 故障排查](../gitlab_duo/troubleshooting.md)
- [极狐GitLab Duo 自托管故障排查](../../administration/gitlab_duo_self_hosted/troubleshooting.md)

<a id="error-m2000"></a>

### `错误 M2000`

你可能会收到一条错误信息，内容为 `抱歉，我无法找到相关文档来回答您的问题。错误代码：M2000`。

当 Chat 无法找到相关文档来回答你的问题时，会出现此错误。如果搜索查询未匹配任何可用文档，或者文档搜索功能出现问题，都可能发生这种情况。

请重试，或参考[极狐GitLab Duo Chat 最佳实践文档](best_practices.md)来完善你的问题。

<a id="error-m3002"></a>

### `错误 M3002`

你可能会收到一条错误信息，内容为 `抱歉，我无法访问您询问的信息。群组或项目所有者已在此群组或项目中关闭了 Duo 功能。错误代码：M3002`。

当你询问的项目或群组已[关闭](../gitlab_duo/turn_on_off.md)极狐GitLab Duo 功能时，会出现此错误。

如果未开启极狐GitLab Duo，则群组或项目中的条目信息（如议题、史诗和合并请求）无法被极狐GitLab Duo Chat 处理。

<a id="error-m3003"></a>

### `错误 M3003`

你可能会收到一条错误信息，内容为 `抱歉，我无法生成回复。请重试。您也可能因为询问的条目不存在、您无权访问，或您的会话已过期而收到此错误。错误代码：M3003`。

出现此错误的原因如下：

- 你向极狐GitLab Duo Chat 询问了无权访问的条目（如议题、史诗和合并请求），或者条目不存在。
- 你的会话已过期。

请重试，询问你有权访问的条目。如果问题仍然存在，可能是由于会话已过期。要继续使用极狐GitLab Duo Chat，请重新登录。更多信息，请参阅[控制极狐GitLab Duo 的可用性](../gitlab_duo/turn_on_off.md)。

<a id="error-m3004"></a>

### `错误 M3004`

你可能会收到一条错误信息，内容为 `抱歉，我无法生成回复。您没有访问极狐GitLab Duo Chat 的权限。错误代码：M3004`。

当你尝试访问极狐GitLab Duo Chat 但不具备所需权限时，会出现此错误。

请确保你[拥有使用极狐GitLab Duo Chat 的权限](../gitlab_duo/turn_on_off.md)。

<a id="error-m3005"></a>

### `错误 M3005`

你可能会收到一条错误信息，内容为 `抱歉，此问题在您的 Duo Pro 订阅中不受支持。您可以考虑升级到 Duo Enterprise。错误代码：M3005`。

当你尝试使用极狐GitLab Duo Chat 中未包含在你的极狐GitLab Duo 订阅层级中的工具时，会出现此错误。

请确保你的[极狐GitLab Duo 订阅层级](https://gitlab.cn/gitlab-duo/#pricing)包含了所选工具。

<a id="error-m3006"></a>

### `错误 M3006`

你可能会收到一条错误信息，内容为 `抱歉，您没有使用 Duo Chat 所需的极狐GitLab Duo 订阅。请联系您的管理员。错误代码：M3006`。

当你的极狐GitLab Duo 订阅不包含极狐GitLab Duo Chat 时，会出现此错误。

请确保你的[极狐GitLab Duo 订阅层级](https://gitlab.cn/gitlab-duo/#pricing)包含了极狐GitLab Duo Chat。

<a id="error-m4000"></a>

### `错误 M4000`

你可能会收到一条错误信息，内容为 `抱歉，我无法生成回复。请重试。错误代码：M4000`。

当处理斜杠命令请求时发生意外问题，会出现此错误。请重新尝试你的请求。如果问题仍然存在，请确保你的命令语法正确。

关于斜杠命令的更多信息，请参阅文档：

- [/tests](examples.md#write-tests-in-the-ide)
- [/refactor](examples.md#refactor-code-in-the-ide)
- [/fix](examples.md#fix-code-in-the-ide)
- [/explain](examples.md#explain-selected-code)

<a id="error-m4001"></a>

### `错误 M4001`

你可能会收到一条错误信息，内容为 `抱歉，我无法生成回复。请重试。错误代码：M4001`。

当查找完成请求所需信息时出现问题时，会出现此错误。请重新尝试你的请求。

<a id="error-m4002"></a>

### `错误 M4002`

你可能会收到一条错误信息，内容为 `抱歉，我无法生成回复。请重试。错误代码：M4002`。

当回答[与 CI/CD 相关的问题](examples.md#ask-about-cicd)时出现问题时，会出现此错误。请重新尝试你的请求。

<a id="error-m4003"></a>

### `错误 M4003`

你可能会收到一条错误信息，内容为 `此命令用于解释漏洞，只能从漏洞详情页面调用。`或 `漏洞解释目前仅支持 SAST 报告的漏洞。错误代码：M4003`。

当使用[`解释漏洞`](examples.md#explain-a-vulnerability)功能出现问题时，会出现此错误。

<a id="error-m4004"></a>

### `错误 M4004`

你可能会收到一条错误信息，内容为 `此资源没有可总结的评论`。

当使用 `总结讨论` 功能出现问题时，会出现此错误。

<a id="error-m4005"></a>

### `错误 M4005`

你可能会收到一条错误信息，内容为 `没有可排查的作业日志。`或 `此命令用于排查作业，只能从失败的作业日志页面调用。`。

当使用[`排查作业`](examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis)功能出现问题时，会出现此错误。

<a id="error-m5000"></a>

### `错误 M5000`

你可能会收到一条错误信息，内容为 `抱歉，我无法生成回复。请重试。错误代码：M5000`。

当处理与条目（如议题、史诗和合并请求）相关内容出现问题时，会出现此错误。请重新尝试你的请求。

<a id="error-a1000"></a>

### `错误 A1000`

你可能会收到一条错误信息，内容为 `抱歉，我未能及时响应。请重试。错误代码：A1000`。

处理过程超时时，会出现此错误。请重新尝试你的请求。

<a id="error-a1001"></a>

### `错误 A1001`

你可能会收到一条错误信息，内容为 `抱歉，我无法生成回复。请重试。错误代码：A1001`。

此错误表示处理你请求的 AI 服务遇到了问题。

可能的原因：

- 极狐GitLab 代码中的客户端错误。
- HTTP 请求未到达 AI 网关。

存在一个议题，以更清晰地指明错误原因。

要解决此问题，请重新尝试你的请求。

如果错误仍然存在，可以使用 `/new` 或 `/reset` 命令开始新的对话。
如果问题仍然存在，请向极狐GitLab 支持团队报告此问题。

<a id="gitlab-duo-self-hosted"></a>

### 极狐GitLab Duo 自托管

如果你在使用极狐GitLab Duo 自托管 Chat 时遇到此错误，说明连接 AI 网关时出现问题。

要解决此问题，请使用[自托管调试脚本](../../administration/gitlab_duo_self_hosted/troubleshooting.md#use-debugging-scripts)检查 AI 网关是否可从极狐GitLab 实例访问且按预期工作。

如果问题仍然存在，请向极狐GitLab 支持团队报告此问题。

<a id="error-a1002"></a>

### `错误 A1002`

你可能会收到一条错误信息，内容为 `抱歉，我未能及时响应。请重试。错误代码：A1002`。

当 AI 网关没有返回事件或极狐GitLab 无法解析事件时，会出现此错误。

请重新尝试你的请求，或检查 [AI Gateway 日志](../../administration/gitlab_duo_self_hosted/logging.md) 以查找任何错误。

<a id="error-a1003"></a>

### `错误 A1003`

你可能会收到一条错误信息，内容为 `抱歉，我未能及时响应。请重试。错误代码：A1003`。

当来自 AI 网关的流式响应失败时，会出现此错误。请重新尝试你的请求。

<a id="gitlab-duo-self-hosted-2"></a>

### 极狐GitLab Duo 自托管

如果你在使用极狐GitLab Duo 自托管 Chat 时遇到此问题，请检查流式传输是否正常：

1. 在 AI 网关容器中，运行以下命令：

   ```shell
   curl --request 'POST' \
   'http://localhost:5052/v2/chat/agent' \
   --header 'accept: application/json' \
   --header 'Content-Type: application/json' \
   --header 'x-gitlab-enabled-feature-flags: expanded_ai_logging' \
   --data '{
     "messages": [
       {
         "role": "user",
         "content": "Hello",
         "context": null,
         "current_file": null,
         "additional_context": []
       }
     ],
     "model_metadata": {
       "provider": "custom_openai",
       "name": "mistral",
       "endpoint": "<change here>",
       "api_key": "<change here>",
       "identifier": "<change here>"
     },
     "unavailable_resources": [],
     "options": {
       "agent_scratchpad": {
         "agent_type": "react",
         "steps": []
       }
     }
   }'
   ```

   如果流式传输正常工作，应该会显示分块响应。如果无法正常工作，响应将为空。

1. 要检查是否是模型部署问题，请检查 [AI 网关日志](../../administration/gitlab_duo_self_hosted/logging.md) 以获取特定的错误信息。

1. 要验证连接，请在 AI 网关容器中设置 `AIGW_CUSTOM_MODELS__DISABLE_STREAMING` 环境变量以禁用流式传输：

   ```shell
   docker run .... -e AIGW_CUSTOM_MODELS__DISABLE_STREAMING=true ...
   ```

<a id="error-a1004"></a>

### `错误 A1004`

你可能会收到一条错误信息，内容为 `抱歉，我未能及时响应。请重试。错误代码：A1004`。

AI 网关进程发生错误时，会出现此错误。请重新尝试你的请求。

<a id="error-a1005"></a>

### `错误 A1005`

你可能会收到一条错误信息，内容为 `抱歉，您输入的提示词过多。请在下次提问前运行 /clear 或 /reset。错误代码：A1005`。

当提示词长度超过 LLM 的最大令牌限制时，会出现此错误。请使用 `/new` 命令开始新对话，然后重新尝试你的请求。

<a id="error-a1006"></a>

### `错误 A1006`

你可能会收到一条错误信息，内容为 `抱歉，Duo Chat 代理在找到您问题的答案之前已达到限制。请尝试其他提示词，或使用 /clear 清除您的对话历史。错误代码：A1006`。

当 ReAct 代理未能为你的查询找到解决方案时，会出现此错误。请尝试其他提示词，或使用 `/new` 或 `/reset` 开始新对话。

<a id="error-a1007"></a>

### `错误 A1007`

你可能会收到一条错误信息，内容为 `处理您的请求时出错。请重试，如果问题仍然存在，请联系支持人员。错误代码：A1007`。

当 GitLab Duo Agent Platform 处理你的请求时遇到意外错误，会出现此错误。

<a id="error-a1008"></a>

### `错误 A1008`

你可能会收到一条错误信息，内容为 `处理您的请求时出错。请重试，如果问题仍然存在，请联系支持人员。错误代码：A1008`。

当你向 GitLab Duo Agent Platform 使用的上游 LLM 提供商提交请求时出错，会出现此错误。

<a id="error-a6000"></a>

### `错误 A6000`

你可能会收到一条错误信息，内容为 `抱歉，我未能及时响应。请尝试更具体的请求，或输入 /clear 开始新聊天。错误代码：A6000`。

这是极狐GitLab Duo Chat 出现问题时的一个后备错误。请尝试更具体的请求，输入 `/new` 开始新聊天，或提供反馈以帮助我们改进。

<a id="error-a9999"></a>

### `错误 A9999`

你可能会收到一条错误信息，内容为 `抱歉，我未能及时响应。请重试。错误代码：A9999`。

当 ReAct 代理发生未知错误时，会出现此错误。请重新尝试你的请求。

如果问题仍然存在，请[向极狐GitLab 支持团队报告此问题](https://gitlab.cn/support/)。

<a id="error-g3001"></a>

### `错误 G3001`

你可能会收到一条错误信息，内容为 `抱歉，回答此问题需要不同的 Duo 订阅。请联系您的管理员。`。

当你的订阅不包含极狐GitLab Duo Chat 时，会出现此错误。请尝试其他请求并联系你的管理员。

<a id="error-g3002"></a>

### `错误 G3002`

你可能会收到一条错误信息，内容为 `抱歉，您尚未选择默认的极狐GitLab Duo 命名空间。请在您的用户偏好中选择一个默认的极狐GitLab Duo 命名空间。`。

当你属于多个极狐GitLab Duo 命名空间，或者在本地处理一个未配置极狐GitLab 远程的项目时，会出现此错误。

要解决此问题，请[设置默认的极狐GitLab Duo 命名空间](../profile/preferences.md#set-a-default-gitlab-duo-namespace)。

<a id="links-in-chat-responses-are-not-selectable"></a>

## Chat 回复中的链接不可选择

极狐GitLab Duo Chat 不会将外部网站和第三方域名的 URL 显示为可选择的回复链接。

Chat 会将此类 URL 转换为仅显示链接文本的代码格式文本，不显示目标 URL。

此限制有助于保护用户免受 AI 回复中可能生成的恶意链接的影响。

Chat 会将以下类型的链接在回复中显示为可选择的：

- 指向 `docs.gitlab.com` 上 GitLab 文档的链接。
- 指向 `gitlab.com` 的链接，包括但不限于 GitLab 项目、议题和合并请求。
- 极狐GitLab 实例中的相对 URL。

<a id="issues-specific-to-gitlab-duo-agentic-chat"></a>

## 极狐GitLab Duo Agentic 模式 Chat 的特定问题

<a id="not-enough-gitlab-credits"></a>

### 极狐GitLab 积分不足

你可能会因为极狐GitLab 积分用完而失去对 Chat 的访问权限。

要解决此问题，你可以执行以下任一操作：

- [购买更多极狐GitLab 积分](../../subscriptions/gitlab_credits.md#buy-gitlab-credits)。
- 切换到非 Agentic 模式 Chat。切换时，会开始一个新的对话。你仍然可以查看之前的 Agentic 模式 Chat 对话，但它是只读的。

<a id="slow-response-times"></a>

### 响应时间慢

在处理和响应请求时，Agentic 模式 Chat 可能比非 Agentic 模式 Chat 更慢。

出现此问题是因为 Agentic 模式 Chat 会进行多次 API 调用来收集信息，因此响应可能需要更长的时间。

<a id="limited-permissions"></a>

### 权限受限

Agentic 模式 Chat 可以访问与你极狐GitLab 用户权限相同的资源。如果你发现 Agentic 模式 Chat 无法访问回答请求所需的资源，请检查你的[用户权限](../permissions.md)。

<a id="search-limitations"></a>

### 搜索限制

Agentic 模式 Chat 使用基于关键词的搜索，而不是语义搜索。Agentic 模式 Chat 可能会遗漏不包含搜索所用确切关键词的相关内容。

<a id="header-mismatch-issue"></a>

## Header 不匹配问题

你可能会收到一条错误信息，内容为 `抱歉，我无法生成回复。请重试`，而没有具体的错误代码。

检查 Sidekiq 日志，查看是否发现以下错误：`Header mismatch 'X-Gitlab-Instance-Id'`。

如果看到此错误，要解决它，请联系极狐GitLab 支持团队，请求他们为许可证发送新的激活码。

更多信息，请参阅议题 103。

<a id="check-the-health-of-the-cloud-connector"></a>

## 检查 Cloud Connector 的健康状况

我们创建了一个脚本来验证与 Cloud Connector 相关的各种组件的状态，例如：

- 访问数据
- 令牌
- 许可证
- 主机连接
- 功能可访问性

你可以在调试模式下运行此脚本以获得更详细的输出并生成报告文件。

1. 通过 SSH 登录到你的单节点实例并下载脚本：

   ```shell
   wget https://gitlab.com/gitlab-org/gitlab/-/snippets/3734617/raw/main/health_check.rb
   ```

1. 使用 Rails Runner 执行脚本。

   确保使用脚本的完整路径。

   ```plaintext
   用法：gitlab-rails runner full_path/to/health_check.rb
          --debug                     启用调试模式
          --output-file <file_path>   将报告写入指定文件
          --username <username>       提供用户名以测试席位分配
          --skip [CHECK]              跳过特定检查（选项：access_data, token, license, host, features, end_to_end）
   ```