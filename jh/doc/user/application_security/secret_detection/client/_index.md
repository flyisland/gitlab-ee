---
stage: Application Security Testing
group: Secret Detection
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 客户端密钥检测
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 GitLab 15.11 中引入。
- 在 GitLab 16.1 中引入了对具有自定义前缀的个人访问令牌的检测功能。仅限私有化部署。
- 在 GitLab 18.11 中引入了对实例范围令牌前缀的检测功能。仅限私有化部署。

{{< /history >}}

当你创建一个议题、向合并请求添加描述或编写评论时，你可能会意外地泄露一个密钥。例如，你可能会粘贴包含认证令牌的 API 请求或环境变量的详细信息。如果密钥泄露，攻击者可以利用它来冒充合法用户。

客户端密钥检测有助于最大限度地降低意外泄露密钥的风险。当你编辑议题或合并请求中的描述或评论时，极狐GitLab 会自动扫描内容中的密钥。

<a id="secret-detection-workflow"></a>

## 密钥检测工作流

客户端密钥检测完全在你的浏览器中使用模式匹配进行操作。这种方法确保：

- 密钥在提交到极狐GitLab 之前被检测到。
- 在检测过程中不会传输任何敏感信息。
- 该功能无需额外配置即可无缝工作。

<a id="getting-started"></a>

## 入门

默认情况下，所有极狐GitLab 层级都启用了客户端密钥检测。无需设置或配置。

要测试此功能：

1. 导航到任意议题或合并请求。
1. 添加包含测试密钥模式的评论，例如 `glpat-xxxxxxxxxxxxxxxxxxxx`。
1. 在提交之前观察出现的警告消息。

测试时始终使用占位符值，以避免暴露真实密钥。

<a id="coverage"></a>

## 覆盖范围

客户端密钥检测分析以下内容：

- 议题描述和评论
- 合并请求描述和评论

有关检测到的密钥具体类型的详细信息，请参阅 [已检测密钥](../detected_secrets.md) 文档。

<a id="understanding-the-results"></a>

## 理解结果

当客户端密钥检测识别出潜在密钥时，极狐GitLab 会显示一个警告，高亮显示检测到的密钥。
你可以：

- **编辑** 评论或描述的内容以移除密钥。
- **添加** 内容而不进行任何更改。在添加可能包含密钥的内容之前，请谨慎操作。

检测完全在你的浏览器中进行。除非你选择 **添加**，否则不会传输任何信息。

<a id="optimization"></a>

## 优化

为了最大限度地提高客户端密钥检测的有效性：

- 仔细查看警告。在继续之前务必检查标记的内容。
- 使用占位符。用如 `[REDACTED]` 或 `<API_KEY>` 的占位符文本替换实际密钥。