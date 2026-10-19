---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为极狐GitLab 私有化部署实例上的功能配置 VS Code 扩展市场。
title: 配置 VS Code 扩展市场
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

VS Code 扩展市场提供对扩展的访问，这些扩展可增强 Web IDE 和工作区的功能。管理员可以为整个实例配置对市场的访问。

> [!note]
> 要访问 VS Code 扩展市场，您的浏览器必须能够访问 `*.cdn.web-ide.gitlab-static.net` 资产主机。
> 此安全要求可确保第三方扩展在隔离环境中运行，无法访问您的账号。

<a id="access-vs-code-extension-marketplace-settings"></a>

## 访问 VS Code 扩展市场设置

先决条件：

- 您必须是管理员。

要访问 VS Code 扩展市场设置：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开 **VS Code 扩展市场**。

<a id="enable-the-extension-registry"></a>

## 启用扩展注册表

默认情况下，极狐GitLab 实例配置为使用 [Open VSX](https://open-vsx.org/) 扩展注册表。要使用此默认配置启用扩展市场：

先决条件：

- 您必须是管理员。

要启用扩展市场：

1. 转到 [VS Code 扩展市场设置](#access-vs-code-extension-marketplace-settings)。
1. 打开 **启用扩展市场** 开关。

<a id="modify-the-extension-registry"></a>

## 修改扩展注册表

先决条件：

- 您必须是管理员。

要修改扩展注册表：

1. 转到 [VS Code 扩展市场设置](#access-vs-code-extension-marketplace-settings)。
1. 展开 **扩展仓库设置**。
1. 关闭 **使用 Open VSX 扩展仓库** 开关。
1. 为 VS Code 扩展注册表的 **服务 URL**、**项目 URL** 和 **资源 URL 模板** 输入完整 URL。
1. 选择**保存更改**。

修改扩展注册表后：

- 活动的 Web IDE 或工作区会话在刷新前会继续使用之前的注册表。
- 所有用户都必须先[将其账号与新注册表集成](../../user/profile/preferences.md#integrate-with-the-extension-marketplace)，然后才能使用扩展。
