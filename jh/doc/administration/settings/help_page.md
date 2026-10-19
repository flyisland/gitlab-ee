---
stage: Facilitated functionality
group: Facilitated functionality
info: For more information, see <https://handbook.gitlab.com/handbook/product/categories/#facilitated-functionality>
title: 自定义帮助页面消息
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在大型组织中，了解应该联系谁或到哪里寻求帮助非常有用。您可以在极狐GitLab `/help` 页面上自定义并显示这些信息。

<a id="prerequisites"></a>

## 先决条件

您必须具有管理员访问权限。

<a id="add-a-help-message-to-the-help-page"></a>

## 向帮助页面添加帮助消息

您可以添加一条帮助消息，该消息会显示在极狐GitLab `/help` 页面的顶部（例如
<https://gitlab.com/help>）：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **偏好设置**。
1. 展开**帮助页面**。
1. 在**在帮助页面上显示的附加文本**中，输入您要在 `/help` 上显示的信息。
1. 选择**保存更改**。

现在您可以在 `/help` 上看到该消息。

> [!note]
> 默认情况下，`/help` 对未认证用户可见。但是，如果
> [**公开**可见性级别](visibility_and_access_controls.md#restrict-visibility-levels)
> 受到限制，则 `/help` 仅对已认证用户可见。

<a id="add-a-help-message-to-the-sign-in-page"></a>

## 向登录页面添加帮助消息

要向登录页面添加帮助消息，请[自定义您的登录和注册页面](../appearance.md#customize-your-sign-in-and-register-pages)。

<a id="hide-marketing-related-entries-from-the-help-page"></a>

## 从帮助页面隐藏营销相关条目

极狐GitLab 营销相关条目偶尔会显示在帮助页面上。要隐藏这些条目：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **偏好设置**。
1. 展开**帮助页面**。
1. 选中**从帮助页面隐藏营销相关条目**复选框。
1. 选择**保存更改**。

<a id="set-a-custom-support-page-url"></a>

## 设置自定义支持页面 URL

您可以指定一个自定义 URL，当用户执行以下操作时会被定向到该 URL：

- 选择**帮助** > **支持**。
- 在帮助页面上选择**查看我们的网站以获取帮助**。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **偏好设置**。
1. 展开**帮助页面**。
1. 在**支持页面 URL** 文本框中，输入该 URL。
1. 选择**保存更改**。

<a id="redirect-help-pages"></a>

## 重定向 `/help` 页面

您可以将所有 `/help` 链接重定向到满足[必要要求](#destination-requirements)的目标。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **偏好设置**。
1. 展开**帮助页面**。
1. 在**文档页面 URL** 文本框中，输入该 URL。
1. 选择**保存更改**。

如果**文档页面 URL** 文本框为空，极狐GitLab 实例会显示来自 [`doc` 目录](https://gitlab.com/gitlab-org/gitlab/-/tree/master/doc)的基础版文档。

<a id="destination-requirements"></a>

### 目标要求

重定向 `/help` 时，极狐GitLab：

- 将指定的 URL 用作重定向的基础 URL。
- 通过以下方式构造完整 URL：
  - 添加版本号（`${VERSION}`）。
  - 添加文档路径。
  - 移除所有 `.md` 文件扩展名。

例如，如果 URL 设置为 `https://docs.gitlab.com`，则对 `/help/administration/settings/help_page.md`的请求会重定向到：
`https://docs.gitlab.com/${VERSION}/administration/settings/help_page`。
