---
stage: AI Clients
group: Developer Clients
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在 Eclipse 中连接并使用极狐GitLab Duo。
title: 安装并设置 GitLab for Eclipse 插件
---

{{< details >}}

- Tier: [基础版](../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

> [!disclaimer]

<a id="install-the-gitlab-for-eclipse-plugin"></a>

## 安装 GitLab for Eclipse 插件

先决条件：

- Eclipse 4.33 及更高版本。
- 极狐GitLab 16.8 及更高版本。

要安装 GitLab for Eclipse：

1. 打开您的 Eclipse IDE 和您常用的 Web 浏览器。
1. 在 Web 浏览器中，前往 Eclipse Marketplace 中的
   [GitLab for Eclipse 插件](https://marketplace.eclipse.org/content/gitlab-eclipse)页面。
1. 在该插件页面上，选择 **安装**，然后将鼠标拖到您的 Eclipse IDE 上。
1. 在 **Eclipse Marketplace** 窗口中，选择 **GitLab For Eclipse** 类别。
1. 选择 **确认 >**，然后选择 **完成**。
1. 如果出现 **信任颁发机构** 窗口，请选择 **`https://gitlab.com`** 更新站点，然后选择 **信任所选项**。
1. 选择 **立即重启**。

如果 Eclipse Marketplace 不可用，请按照
[Eclipse 安装说明](https://help.eclipse.org/latest/index.jsp?topic=%2Forg.eclipse.platform.doc.user%2Ftasks%2Ftasks-124.htm)
添加新的软件站点。对于 **使用**，请使用
`https://gitlab.com/gitlab-org/editor-extensions/gitlab-eclipse-plugin/-/releases/permalink/latest/downloads/`。

<a id="authenticate-with-gitlab"></a>

## 使用极狐GitLab 进行身份验证

安装插件后，请进行身份验证并将其连接到您的极狐GitLab 账号。

先决条件：

- 一个具有 `api` 作用域的[个人访问令牌](../../user/profile/personal_access_tokens.md#create-a-personal-access-token)。

要使用极狐GitLab 进行身份验证：

1. 在您的 IDE 中，打开首选项：
   - 对于 macOS，选择 **Eclipse** > **设置**。
   - 对于 Windows 或 Linux，选择 **窗口** > **首选项**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 在 **连接** 下，输入您的极狐GitLab 实例的 URL。对于 JihuLab.com，
   请使用 `https://gitlab.com`。
1. 在 **身份验证** 下，输入您的个人访问令牌。
   您的令牌会被隐藏，并使用 Eclipse 安全存储进行保存。
1. 选择 **验证设置**。
1. 选择 **应用并关闭**。

<a id="configure-code-suggestions"></a>

## 配置代码建议

先决条件：

- 您满足代码建议的[先决条件](../../user/project/repository/code_suggestions/set_up.md#prerequisites)。
- 您打开的是 Eclipse 项目，而不是单个文件。

代码建议默认开启。要验证：

1. 在 Eclipse 中，打开您的极狐GitLab 项目。
1. 在 Eclipse 底部工具栏中，选择极狐GitLab 图标。
1. 检查 **代码建议**的状态。

要为某个项目关闭代码建议：

1. 在 Eclipse 底部工具栏中，选择极狐GitLab 图标。
1. 选择 **禁用代码建议**。

要为特定语言关闭代码建议：

1. 在 Eclipse 底部工具栏中，选择极狐GitLab 图标。
1. 选择 **显示设置**。
1. 在 **启用代码建议的语言** 下，清除您要关闭的语言对应的复选框。

您还可以[添加对更多语言的支持](../../user/project/repository/code_suggestions/supported_extensions.md#add-support-for-more-languages)。
