---
stage: AI 驱动
group: 编辑器扩展
info: 要确定分配给与此页面关联的 Stage/Group 的技术文档工程师，请参阅 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在 Eclipse 中连接和使用极狐GitLab Duo。
title: 安装和设置 Eclipse 的极狐GitLab 插件
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: GitLab Duo Core, Pro, or Enterprise
- Offering: JihuLab.com，私有化部署
- Status: Beta

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.11 中，该功能从实验性功能变为测试阶段。

{{< /history >}}

> [!disclaimer]

## 安装 Eclipse 的极狐GitLab 插件

前提条件：

- Eclipse 4.33 及更高版本。
- 极狐GitLab 版本 16.8 或更高版本。

安装 Eclipse 的极狐GitLab 插件的步骤：

1. 打开你的 Eclipse IDE 和常用的网络浏览器。
1. 在网络浏览器中，访问 Eclipse Marketplace 上的 [Eclipse 的极狐GitLab 插件](https://marketplace.eclipse.org/content/gitlab-eclipse)页面。
1. 在插件页面上，选择 **Install**，并将其拖动到你的 Eclipse IDE 中。
1. 在 **Eclipse Marketplace** 窗口中，选择 **Eclipse 的极狐GitLab 插件** 类别。
1. 选择 **Confirm >**，然后选择 **Finish**。
1. 如果出现 **Trust Authorities** 窗口，请选择 **`https://gitlab.com`** 更新站点，然后选择 **Trust Selected**。
1. 选择 **Restart Now**。

如果 Eclipse Marketplace 不可用，请按照[Eclipse 安装说明](https://help.eclipse.org/latest/index.jsp?topic=%2Forg.eclipse.platform.doc.user%2Ftasks%2Ftasks-124.htm)添加新的软件站点。对于 **Work with**，请使用 `https://gitlab.com/gitlab-org/editor-extensions/gitlab-eclipse-plugin/-/releases/permalink/latest/downloads/`。

## 与极狐GitLab 进行认证

安装插件后，进行身份验证并将其连接到你的极狐GitLab 账户。

前提条件：

- 一个具有 `api` 作用域的[个人访问令牌](../../user/profile/personal_access_tokens.md#create-a-personal-access-token)。

与极狐GitLab 进行认证的步骤：

1. 在你的 IDE 中，打开首选项：
   - 对于 macOS，选择 **Eclipse** > **Settings**。
   - 对于 Windows 或 Linux，选择 **Window** > **Preferences**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 在 **Connection** 下，输入你的极狐GitLab 实例的 URL。对于 JihuLab.com，请使用 `https://gitlab.com`。
1. 在 **Authentication** 下，输入你的个人访问令牌。
   你的令牌会被隐藏并使用 Eclipse 安全存储进行存储。
1. 选择 **Verify Setup**。
1. 选择 **Apply and Close**。