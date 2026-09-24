---
stage: None - Facilitated functionality, see <https://handbook.gitlab.com/handbook/product/categories/#facilitated-functionality>
group: Unassigned - Facilitated functionality, see <https://handbook.gitlab.com/handbook/product/categories/#facilitated-functionality>
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: Customize your GitLab instance appearance, including logos, favicons, sign-in pages, Progressive Web App settings, system messages, and color themes.
title: 极狐GitLab 外观
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以更新设置来更改实例的外观和风格。

## 先决条件
<a id="prerequisites"></a>

您必须具有管理员访问权限。

## 访问外观设置
<a id="access-appearance-settings"></a>

要打开 **外观** 设置：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **外观**。

## 自定义首页按钮
<a id="customize-your-homepage-button"></a>

自定义首页按钮的外观。

首页按钮位于左侧边栏的左上角。用任意图片替换默认的极狐GitLab 标志 {{< icon name="tanuki" >}}。

- 文件应小于 1 MB。
- 图片高度应为 24 像素。高于 24 像素的图片会自动调整大小。

要自定义首页图标图片：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **外观**。
1. 在 **导航栏** 下，选择 **选择文件**。
1. 在页面底部，选择 **更新外观设置**。

流水线状态邮件也会显示您的自定义标志。但是，某些电子邮件应用程序不支持 SVG 图片。如果您的自定义图片是 SVG 格式，则流水线邮件会显示默认标志。

## 自定义网站图标
<a id="customize-the-favicon"></a>

自定义网站图标的外观。网站图标是网站在浏览器标签中显示的图标。默认的浏览器和 CI/CD 状态图标是极狐GitLab 标志 {{< icon name="tanuki" >}}。用符合 `32 x 32` 像素、`.png` 或 `.ico` 格式的任意图片替换默认图标。

要更改网站图标：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **外观**。
1. 在 **网站图标** 下，选择 **选择文件**。
1. 在页面底部，选择 **更新外观设置**。

## 自定义站点名称
<a id="customize-the-site-name"></a>

{{< history >}}

- 在极狐GitLab 18.11 中引入。

{{< /history >}}

您可以在浏览器标签的页面标题后添加您的自定义站点名称。例如，如果您的站点名称是 `MyCompany`，在首页上，浏览器标签中显示的页面标题将是 `Home · 极狐GitLab · MyCompany`。

站点名称最大长度为 255 个字符。

要更改站点名称：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **外观**。
1. 在 **站点名称** 下，输入新的站点名称。
1. 在页面底部，选择 **更新外观设置**。

## 添加系统头部和底部消息
<a id="add-system-header-and-footer-messages"></a>

{{< history >}}

- **在电子邮件中启用头部和底部** 复选框在极狐GitLab 15.9 中引入。

{{< /history >}}

在您的极狐GitLab 实例界面上添加一条小型的头部消息、底部消息或两者都添加。这些消息会显示在实例的所有项目页面上，例如登录和注册页面。

- 您可以使用 Markdown 将消息设置为斜体、粗体或添加链接。
- 不支持 Markdown 列表、图片和引用，因为系统消息必须为单行。

要添加系统头部、底部消息或两者：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **外观**。
1. 转到 **系统头部和底部** 部分。
1. 填写字段。
1. 可选。选中 **在电子邮件中启用头部和底部** 复选框。将您的系统消息添加到您的极狐GitLab 实例发送的所有电子邮件中。
1. 在页面底部，选择 **更新外观设置**。

默认情况下，系统头部和底部文本为橙色背景上的白色文字。要自定义消息颜色：

- 转到 **系统头部和底部** 部分，然后选择 **自定义颜色**。

## 自定义登录和注册页面
<a id="customize-your-sign-in-and-register-pages"></a>

<!-- vale gitlab_base.OxfordComma = NO -->
自定义登录和注册页面上的标题、描述和标志。默认情况下，注册页面标志位于页面左侧，在标题和描述之间。
<!-- vale gitlab_base.OxfordComma = YES -->

要自定义登录和注册页面标题或描述：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **外观**。
1. 转到 **登录/注册页面** 部分。
1. 填写字段。您可以使用 Markdown 设置页面 **标题** 和 **描述** 的格式。
1. 在页面底部，选择 **更新外观设置**。

要自定义登录和注册页面上的标志：

- 文件应小于 1 MB。
- 图片高度应为 128 像素。高于 128 像素的图片会自动调整大小。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **外观**。
1. 转到 **登录/注册页面** 部分。
1. 在 **标志** 下，选择 **选择文件**。
1. 在页面底部，选择 **更新外观设置**。

您还可以在登录消息下方添加[自定义帮助消息](settings/help_page.md)或添加[登录文本消息](settings/sign_in_restrictions.md#sign-in-information)。

### 禁用基于 cookie 的语言选择器
<a id="disable-cookie-based-language-selector"></a>

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.10 中引入。

{{< /history >}}

> [!flag]
> 在私有化部署的极狐GitLab 上，默认情况下此功能不可用。要使其可用，管理员可以[启用功能标志](feature_flags/_index.md)，名为 `disable_preferred_language_cookie`。
> 在 JihuLab.com 上，此功能不可用。

您可以通过启用 `disable_preferred_language_cookie` 功能标志，从登录和注册页面的页脚中移除基于 cookie 的语言选择器。

## 自定义渐进式 Web 应用
<a id="customize-the-progressive-web-app"></a>

{{< history >}}

- 在极狐GitLab 15.9 中引入。

{{< /history >}}

自定义渐进式 Web 应用 (PWA) 的图标、显示名称、短名称和描述。有关更多信息，请参阅[渐进式 Web 应用](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps)。

要添加渐进式 Web 应用名称和短名称：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **外观**。
1. 转到 **渐进式 Web 应用 (PWA)** 部分。
1. 填写字段。
   - **名称** 是您的 PWA 的显示名称。
   - **短名称** 显示在移动设备和小屏幕上。
1. 在页面底部，选择 **更新外观设置**。

要添加渐进式 Web 应用描述：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **外观**。
1. 转到 **渐进式 Web 应用 (PWA)** 部分。
1. 填写字段。您可以使用 Markdown 设置 **描述** 的格式。
1. 在页面底部，选择 **更新外观设置**。

要自定义渐进式 Web 应用图标：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **外观**。
1. 转到 **渐进式 Web 应用 (PWA)** 部分。
1. 在 **图标** 下，选择 **选择文件**。
1. 在页面底部，选择 **更新外观设置**。

## 成员准则
<a id="member-guidelines"></a>

您可以在极狐GitLab 中的群组和项目成员页面中添加成员准则。您可以在描述中使用 [Markdown](../user/markdown.md)。

成员准则对有权管理以下内容的用户可见：

- 群组成员。
- 项目成员。

如果您使用以下任一方式管理群组和项目成员资格，则应添加成员准则：

- 预定义群组，而非逐个管理。
- 外部工具。

## 向新建项目页面添加准则
<a id="add-guidelines-to-the-new-project-page"></a>

向 **新建项目页面** 添加准则消息。您可以使用 Markdown 设置消息格式。准则消息显示在 **新建项目** 消息下方，位于 **新建项目页面** 的左侧。

要向 **新建项目页面** 添加准则消息：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **外观**。
1. 转到 **新建项目页面** 部分。
1. 填写字段。您可以使用 Markdown 设置准则格式。

## 添加个人资料图片准则
<a id="add-profile-image-guidelines"></a>

添加个人资料图片准则。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **外观**。
1. 转到 **个人资料图片准则** 部分。
1. 填写字段。您可以使用 Markdown 设置文本格式。

## Libravatar
<a id="libravatar"></a>

极狐GitLab 支持将 [Libravatar](https://www.libravatar.org) 用于头像图片，但您必须在极狐GitLab 实例上手动启用 Libravatar 支持。有关更多信息，请参阅 [Libravatar](libravatar.md) 以使用该服务。

## 更改所有新用户的颜色主题
<a id="change-the-color-theme-for-all-new-users"></a>

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.8 中引入：`gitlab_default_theme` 可以指定一个 1 到 10 的值来设置默认主题。
- 主题：浅靛蓝 (Light Indigo)、浅蓝 (Light Blue)、浅绿 (Light Green) 和浅红 (Light Red) 在极狐GitLab 18.4 中被移除。

{{< /history >}}

要为所有新用户[更改默认导航主题](../user/profile/preferences.md#change-the-navigation-theme)：

1. 在您的 GitLab 配置文件 `/etc/gitlab/gitlab.rb` 中添加 `gitlab_rails['gitlab_default_theme']`：

   ```ruby
   gitlab_rails['gitlab_default_theme'] = 2
   ```

   可用的颜色有：

   | 值 | 颜色   |
   | --- | ------ |
   | 1   | 靛蓝   |
   | 2   | 深色   |
   | 3   | 浅色   |
   | 4   | 蓝色   |
   | 5   | 绿色   |
   | 9   | 红色   |

1. [重新配置并重启极狐GitLab](restart_gitlab.md#reconfigure-a-linux-package-installation)。