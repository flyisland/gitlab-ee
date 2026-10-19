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

当您创建议题、为合并请求添加描述或撰写评论时，可能会不小心发布密钥。例如，您可能粘贴了包含认证令牌的 API 请求详情或环境变量。如果密钥泄露，攻击者可以利用它来冒充合法用户。

客户端密钥检测有助于降低密钥意外暴露的风险。当您在议题或合并请求中编辑描述或评论时，极狐GitLab 会自动扫描内容中的密钥。

<a id="secret-detection-workflow"></a>

## 密钥检测工作流

客户端密钥检测完全在您的浏览器中使用模式匹配运行。这种方式可确保：

- 密钥在提交到极狐GitLab 之前即被检测到。
- 检测过程中不会传输任何敏感信息。
- 该功能无需额外配置即可无缝运行。

<a id="getting-started"></a>

## 开始使用

客户端密钥检测默认对所有极狐GitLab 订阅层级启用。无需任何设置或配置。

要测试此功能：

1. 导航到任意议题或合并请求
1. 添加一条包含测试密钥模式的评论，例如 `glpat-xxxxxxxxxxxxxxxxxxxx`
1. 观察提交前出现的警告消息

测试时请始终使用占位值，以免暴露真实密钥。

<a id="coverage"></a>

## 覆盖范围

客户端密钥检测会分析以下内容：

- 议题描述和评论
- 合并请求描述和评论

有关所检测的具体密钥类型的详细信息，请参阅[检测到的密钥](../detected_secrets.md)文档。

<a id="understanding-the-results"></a>

## 了解检测结果

当客户端密钥检测识别到潜在密钥时，极狐GitLab 会显示一条警告，并高亮显示检测到的密钥。您可以：

- **编辑**评论或描述的内容，以移除该密钥。
- **添加**内容而不做任何更改。在添加包含潜在密钥的内容之前，请务必谨慎。

检测完全在您的浏览器中进行。除非您选择**添加**，否则不会传输任何信息。

<a id="optimization"></a>

## 优化

要最大限度地发挥客户端密钥检测的效果：

- 仔细查看警告。在继续操作之前，请务必调查被标记的内容。
- 使用占位符。将实际密钥替换为占位文本，例如 `[REDACTED]` 或 `<API_KEY>`。
