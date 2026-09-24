```json
{
  "reasonable": true,
  "explanation": "删除“两位”使表达更简洁，将“吸引到”改为“吸引了”更符合现代汉语表达习惯，句子更通顺。"
}
```

---

以下是按要求翻译并删减后的文档：

```markdown
---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 配置极狐GitLab编辑器扩展，适用于Visual Studio Code、JetBrains IDE、Visual Studio、Eclipse和Neovim。
title: 配置编辑器扩展
---

{{< details >}}
- 层级：免费版、专业版、旗舰版
- 提供：极狐GitLab.com、极狐GitLab Self-Managed、极狐GitLab Dedicated
{{< /details >}}

为您的极狐GitLab实例配置编辑器扩展设置。

## 要求最低语言服务器版本

{{< history >}}
- [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/541744)于极狐GitLab 18.1，[带有一个标志](../feature_flags/_index.md)名为 `enforce_language_server_version`。默认禁用。
{{< /history >}}

> [!flag]
> 在极狐GitLab Self-Managed上，默认此功能不可用。要使其可用，管理员可以[启用功能标志](../feature_flags/_index.md)名为 `enforce_language_server_version`。
> 在极狐GitLab.com上，此功能可用，但只能由极狐GitLab.com管理员配置。
> 在极狐GitLab Dedicated上，此功能可用。

默认情况下，当启用个人访问令牌时，任何极狐GitLab Language Server版本都可以连接到您的极狐GitLab实例。要阻止来自较旧版本客户端的请求，请配置最低语言服务器版本。低于允许的最低Language Server版本的客户端会收到API错误。

先决条件：

- 您必须是管理员。

  ```ruby
  # For a specific user
  Feature.enable(:enforce_language_server_version, User.find(1))

  # For this GitLab instance
  Feature.enable(:enforce_language_server_version)
  ```

要强制执行最低极狐GitLab Language Server版本：

1. 在右上角，选择**管理**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**编辑器扩展**。
1. 勾选**启用Language Server限制**。
1. 在**最低极狐GitLab Language Server客户端版本**下，输入有效的极狐GitLab Language Server版本。

要允许任何极狐GitLab Language Server客户端：

1. 在右上角，选择**管理**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**编辑器扩展**。
1. 取消勾选**启用Language Server限制**。
1. 在**最低极狐GitLab Language Server客户端版本**下，输入有效的极狐GitLab Language Server版本。

> [!note]
> 不建议允许所有请求。如果您的极狐GitLab版本领先于扩展版本，可能会导致不兼容。您应该更新扩展以获取最新的功能改进、错误修复和安全修复。
```