---
stage: None - Facilitated functionality, see <https://handbook.gitlab.com/handbook/product/categories/#facilitated-functionality>
group: Unassigned - Facilitated functionality, see <https://handbook.gitlab.com/handbook/product/categories/#facilitated-functionality>
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义帮助页面消息
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在大型组织中，提供联系人或求助位置的信息非常有用。您可以在 极狐GitLab 的 `/help` 页面上自定义并显示这些信息。

<a id="prerequisites"></a>

## 先决条件

您必须具有管理员访问权限。

<a id="add-a-help-message-to-the-help-page"></a>

## 向帮助页面添加帮助消息

您可以添加一条帮助消息，该消息显示在 极狐GitLab `/help` 页面的顶部（例如 <https://jihulab.com/help>）：

1. 在右上角，选择**管理员**。
1. 在左侧边栏，选择**设置** > **偏好设置**。
1. 展开**帮助页面**。
1. 在**在帮助页面上显示的额外文本**中，输入要显示在 `/help` 上的信息。
1. 选择**保存更改**。

您现在可以在 `/help` 上看到该消息。

> [!note]
> 默认情况下，`/help` 对未认证用户可见。但是，如果 [**公开** 可见性级别](visibility_and_access_controls.md#restrict-visibility-levels) 被限制，`/help` 只对已认证用户可见。

<a id="add-a-help-message-to-the-sign-in-page"></a>

## 向登录页面添加帮助消息

{{< history >}}

- 在登录页面上显示的附加文本已于 极狐GitLab 17.0 弃用。

{{< /history >}}

要向登录页面添加帮助消息，[自定义您的登录和注册页面](../appearance.md#customize-your-sign-in-and-register-pages)。

<a id="hide-marketing-related-entries-from-the-help-page"></a>

## 从帮助页面隐藏营销相关条目

极狐GitLab 营销相关的条目偶尔会显示在帮助页面上。要隐藏这些条目：

1. 在右上角，选择**管理员**。
1. 在左侧边栏，选择**设置** > **偏好设置**。
1. 展开**帮助页面**。
1. 选中 **从帮助页面隐藏营销相关条目** 复选框。
1. 选择**保存更改**。

<a id="set-a-custom-support-page-url"></a>

## 设置自定义支持页面 URL

您可以指定一个自定义 URL，当用户执行以下操作时，将会重定向到该 URL：

- 选择**帮助** > **支持**。
- 在帮助页面上选择**访问我们的网站获取帮助**。

1. 在右上角，选择**管理员**。
1. 在左侧边栏，选择**设置** > **偏好设置**。
1. 展开**帮助页面**。
1. 在**支持页面 URL** 文本框中输入 URL。
1. 选择**保存更改**。

<a id="redirect-help-pages"></a>

## 重定向 `/help` 页面

您可以将所有 `/help` 链接重定向到满足 [必要要求](#destination-requirements) 的目标。

1. 在右上角，选择**管理员**。
1. 在左侧边栏，选择**设置** > **偏好设置**。
1. 展开**帮助页面**。
1. 在**文档页面 URL** 文本框中输入 URL。
1. 选择**保存更改**。

如果**文档页面 URL** 文本框为空，极狐GitLab 实例将显示来自 极狐GitLab 的 [`doc` 目录](https://jihulab.com/gitlab-cn/gitlab/-/tree/master/doc) 的基础版文档。

<a id="destination-requirements"></a>

### 目的地要求

重定向 `/help` 时，极狐GitLab：

- 使用指定的 URL 作为重定向的基础 URL。
- 通过以下方式构建完整 URL：
  - 添加版本号 (`${VERSION}`)。
  - 添加文档路径。
  - 删除所有 `.md` 文件扩展名。

例如，如果将 URL 设置为 `https://gitlab.cn/docs`，那么对 `/help/administration/settings/help_page.md` 的请求将重定向到：
`https://gitlab.cn/docs/${VERSION}/administration/settings/help_page`。