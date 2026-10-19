---
stage: Growth
group: Engagement
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: 自定义极狐GitLab 实例的外观，包括徽标、网站图标、登录页面、渐进式 Web 应用设置、系统消息和颜色主题。
title: 极狐GitLab 外观
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以更新设置，以更改实例的外观和风格。

<a id="prerequisites"></a>

## 先决条件

您必须拥有管理员访问权限。

<a id="access-appearance-settings"></a>

## 访问外观设置

要打开**外观**设置：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **外观**。

<a id="customize-your-homepage-button"></a>

## 自定义主页按钮

自定义主页按钮的外观。

主页按钮位于左侧边栏的左上角。将默认的极狐GitLab 徽标 {{< icon name="tanuki" >}} 替换为任意图像。

- 文件应小于 1 MB。
- 图像高度应为 24 像素。高度超过 24 像素的图像会自动调整大小。

要自定义主页图标图像：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **外观**。
1. 在**导航栏**下，选择**选择文件**。
1. 在页面底部，选择**更新外观设置**。

流水线状态邮件也会显示您的自定义徽标。但是，某些电子邮件应用程序不支持 SVG 图像。如果您的自定义图像为 SVG 格式，流水线邮件将显示默认徽标。

<a id="customize-the-favicon"></a>

## 自定义网站图标

自定义网站图标的外观。网站图标是网站在浏览器标签页中显示的图标。极狐GitLab 徽标 {{< icon name="tanuki" >}} 是默认的浏览器和 CI/CD 状态网站图标。将默认图标替换为任意 `32 x 32` 像素、格式为 `.png` 或 `.ico`的图像。

要更改网站图标：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **外观**。
1. 在**网站图标**下，选择**选择文件**。
1. 在页面底部，选择**更新外观设置**。

<a id="customize-the-site-name"></a>

## 自定义站点名称

您可以将自定义站点名称附加到浏览器标签页中的页面标题后面。例如，如果您的站点名称为 `MyCompany`，则在主页上，浏览器标签页中的页面标题会显示为 `Home · GitLab · MyCompany`。

站点名称的最大长度为 255 个字符。

要更改站点名称：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **外观**。
1. 在**站点名称**下，输入新的站点名称。
1. 在页面底部，选择**更新外观设置**。

<a id="add-system-header-and-footer-messages"></a>

## 添加系统页眉和页脚消息

向极狐GitLab 实例的界面添加一条简短的页眉消息、一条简短的页脚消息，或同时添加两者。这些消息会显示在实例的所有项目和页面上，例如登录和注册页面。

- 您可以使用 Markdown 为消息添加斜体、粗体或链接。
- 不支持 Markdown 列表、图像和引用，因为系统消息必须是单行。

要添加系统页眉、页脚消息或同时添加两者：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **外观**。
1. 转到**系统页眉和页脚**部分。
1. 填写各字段。
1. 可选。选中**在电子邮件中启用页眉和页脚**复选框。将您的系统消息添加到极狐GitLab 实例发送的所有电子邮件中。
1. 在页面底部，选择**更新外观设置**。

默认情况下，系统页眉和页脚文本为橙色背景上的白色文本。要自定义消息颜色：

- 转到**系统页眉和页脚**部分，然后选择**自定义颜色**。

<a id="customize-your-sign-in-and-register-pages"></a>

## 自定义登录和注册页面

<!-- vale gitlab_base.OxfordComma = NO -->
自定义登录和注册页面上的标题、描述和徽标。默认情况下，注册页面徽标位于页面左侧，介于标题和描述之间。
<!-- vale gitlab_base.OxfordComma = YES -->

要自定义登录和注册页面的标题或描述：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **外观**。
1. 转到**登录/注册页面**部分。
1. 填写各字段。您可以使用 Markdown 设置页面**标题**和**描述**的格式。
1. 在页面底部，选择**更新外观设置**。

要自定义登录和注册页面上的徽标：

- 文件应小于 1 MB。
- 图像高度应为 128 像素。高度超过 128 像素的图像会自动调整大小。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **外观**。
1. 转到**登录/注册页面**部分。
1. 在**徽标**下，选择**选择文件**。
1. 在页面底部，选择**更新外观设置**。

您还可以在登录消息下方添加[自定义帮助消息](settings/help_page.md)，或添加[登录文本消息](settings/sign_in_restrictions.md#sign-in-information)。

<a id="disable-cookie-based-language-selector"></a>

### 禁用基于 Cookie 的语言选择器

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

> [!flag]
> 在极狐GitLab 私有化部署上，此功能默认不可用。要使其可用，管理员可以[启用功能标志](feature_flags/_index.md) `disable_preferred_language_cookie`。
> 在 JihuLab.com 上，此功能不可用。

您可以通过启用 `disable_preferred_language_cookie` 功能标志，从登录和注册页面的页脚中移除基于 Cookie 的语言选择器。

<a id="customize-the-progressive-web-app"></a>

## 自定义渐进式 Web 应用

自定义渐进式 Web 应用（PWA）的图标、显示名称、短名称和描述。有关更多信息，请参阅[渐进式 Web 应用](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps)。

要添加渐进式 Web 应用名称和短名称：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **外观**。
1. 转到**渐进式 Web 应用（PWA）**部分。
1. 填写各字段。
   - **名称**是您的 PWA 的显示名称。
   - **短名称**会显示在移动设备和小屏幕上。
1. 在页面底部，选择**更新外观设置**。

要添加渐进式 Web 应用描述：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **外观**。
1. 转到**渐进式 Web 应用（PWA）**部分。
1. 填写各字段。您可以使用 Markdown 设置**描述**的格式。
1. 在页面底部，选择**更新外观设置**。

要自定义渐进式 Web 应用图标：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **外观**。
1. 转到**渐进式 Web 应用（PWA）**部分。
1. 在**图标**下，选择**选择文件**。
1. 在页面底部，选择**更新外观设置**。

<a id="member-guidelines"></a>

## 成员准则

您可以在极狐GitLab 的群组和项目成员页面中添加成员准则。您可以在描述中使用 [Markdown](../user/markdown.md)。

拥有管理以下任一对象[权限](../user/permissions.md)的用户可以看到成员准则：

- 群组的成员。
- 项目的成员。

如果您使用以下任一方式管理群组和项目成员资格，则应添加成员准则：

- 预定义群组，而非逐个管理。
- 外部工具。

<a id="add-guidelines-to-the-new-project-page"></a>

## 向新项目页面添加准则

向**新项目页面**添加准则消息。您可以使用 Markdown 设置消息格式。准则消息会显示在**新项目**消息下方，以及**新项目页面**的左侧。

要向**新项目页面**添加准则消息：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **外观**。
1. 转到**新项目页面**部分。
1. 填写各字段。您可以使用 Markdown 设置准则格式。

<a id="add-profile-image-guidelines"></a>

## 添加个人资料图像准则

添加个人资料图像的准则。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **外观**。
1. 转到**个人资料图像准则**部分。
1. 填写各字段。您可以使用 Markdown 设置文本格式。

<a id="libravatar"></a>

## Libravatar

极狐GitLab 支持使用 [Libravatar](https://www.libravatar.org) 作为头像图像，但您必须在极狐GitLab 实例上手动启用 Libravatar 支持。有关更多信息，请参阅 [Libravatar](libravatar.md) 以使用该服务。

<a id="change-the-color-theme-for-all-new-users"></a>

## 更改所有新用户的颜色主题

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

要为所有新用户[更改默认导航主题](../user/profile/preferences.md#change-the-navigation-theme)：

1. 将 `gitlab_rails['gitlab_default_theme']` 添加到位于 `/etc/gitlab/gitlab.rb`的极狐GitLab 配置文件中：

   ```ruby
   gitlab_rails['gitlab_default_theme'] = 2
   ```

   以下颜色可用：
   <!-- The themes are defined in `lib/gitlab/themes.rb` -->

   | 值 | 颜色  |
   | ----- | -----  |
   | 1     | 靛蓝   |
   | 2     | 深色   |
   | 3     | 浅色   |
   | 4     | 蓝色   |
   | 5     | 绿色   |
   | 9     | 红色   |

1. [重新配置并重启极狐GitLab](restart_gitlab.md#reconfigure-a-linux-package-installation)。
