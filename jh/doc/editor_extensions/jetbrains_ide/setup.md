---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Connect and use GitLab Duo in JetBrains IDEs.
title: 安装和设置 JetBrains IDE 的 极狐GitLab Duo 插件
---

从 [JetBrains 插件市场](https://plugins.jetbrains.com/plugin/22325-gitlab-duo) 下载并安装该插件。

先决条件：

- JetBrains IDE：2023.2.X 及更高版本。
- 极狐GitLab 版本 16.8 或更高。

如果你使用旧版本的 JetBrains IDE，请下载与你的 IDE 兼容的插件版本：

1. 在 极狐GitLab Duo [插件页面](https://plugins.jetbrains.com/plugin/22325-gitlab-duo) 中，选择 **版本**。
1. 选择 **兼容性**，然后选择你的 JetBrains IDE。
1. 选择一个 **频道** 以筛选稳定版本或 alpha 版本。
1. 在兼容性表中，找到你的 IDE 版本并选择 **下载**。

<a id="enable-the-plugin"></a>

## 启用插件

要启用该插件：

1. 在你的 IDE 中，在顶部栏中选择你的 IDE 名称，然后选择 **设置**。
1. 在左侧边栏中，选择 **插件**。
1. 选择 **极狐GitLab Duo** 插件，然后选择 **安装**。
1. 选择 **确定** 或 **保存**。

<a id="connect-to-gitlab"></a>

## 连接到极狐GitLab

安装扩展后，将其连接到你的极狐GitLab 账户。

<a id="authenticate-with-gitlab"></a>

### 通过 极狐GitLab 进行身份验证

先决条件：

- 对于私有化部署认证使用 OAuth：
  - 适用于 JetBrains 的极狐GitLab Duo 插件 3.30.30 及更高版本。
  - 用于 [JetBrains IDE 的 OAuth 应用](../../administration/settings/editor_extensions.md#jetbrains-ides) 的实例级应用程序 ID。
- 对于使用 PAT 进行认证，需要一个具有 `api` 作用域的 [个人访问令牌](../../user/profile/personal_access_tokens.md#create-a-personal-access-token)。
- 对于使用 1Password 进行认证，需完成 [与 1Password CLI 集成](_index.md#integrate-with-1password-cli) 的步骤并准备好密钥引用。

在 IDE 中配置插件后，将其连接到你的极狐GitLab 账户：

1. 在你的 IDE 中，在顶部栏中选择你的 IDE 名称，然后选择 **设置**。
1. 在左侧边栏中，展开 **工具**，然后选择 **极狐GitLab Duo**。
   如果未看到该插件，请重启 IDE。
1. 提供 **极狐GitLab 实例的 URL**。对于 JihuLab.com，使用 `https://jihulab.com`。
1. 选择一种认证方法：**OAuth**、**PAT** 或 **1Password CLI**。
   - 对于 OAuth，按照提示登录并进行身份验证。
   - 对于 PAT，输入你的个人访问令牌。
     令牌值不会显示或暴露给其他人。
   - 对于 1Password，选择 **与 1Password CLI 集成**，选择你的账户，并可选择输入密钥引用。
1. 选择 **验证设置**。
1. 选择 **确定** 或 **保存**。

<a id="configure-gitlab-duo"></a>

## 配置 极狐GitLab Duo

先决条件：

- 对于代理功能，你需要满足 [极狐GitLab Duo Agent Platform](../../user/duo_agent_platform/_index.md#prerequisites) 的先决条件。
- 你已 [启用](../../user/gitlab_duo/turn_on_off.md) 极狐GitLab Duo。
- 对于流，你需要 [启用基础流](../../user/duo_agent_platform/flows/foundational_flows/_index.md#turn-foundational-flows-on-or-off)。
- 对于代理，根据需要使用 [启用内置 Agent](../../user/duo_agent_platform/agents/foundational_agents/_index.md#turn-foundational-agents-on-or-off) 和 [启用自定义代理](../../user/duo_agent_platform/agents/custom.md#enable-an-agent)。
- 你的项目位于一个 [群组命名空间](../../user/namespace/_index.md) 中。
- 你已设置一个 [默认 极狐GitLab Duo 命名空间](../../user/profile/preferences.md#namespace-resolution-in-your-local-environment)，或者已打开一个拥有极狐GitLab Duo 访问权限的项目。

要启用极狐GitLab Duo 功能：

1. 在 JetBrains IDE 中，转到 **设置** > **工具** > **极狐GitLab Duo**。
1. 找到你想要启用的功能，并选中相应的复选框。
1. 如果系统提示，请重启 IDE。

对于极狐GitLab Duo 代码建议，请 [查阅额外的先决条件和设置步骤](../../user/project/repository/code_suggestions/set_up.md#prerequisites)。

若想每个会话只批准一次代理 Chat 工具而不是每次单独批准，请参阅 [工具批准](../../user/gitlab_duo_chat/agentic_chat.md#tool-approvals)。

<a id="install-alpha-versions-of-the-plugin"></a>

## 安装插件的 alpha 版本

极狐GitLab 会将插件的预发布（alpha）构建发布到 JetBrains Marketplace 的
[`Alpha` 发布频道](https://plugins.jetbrains.com/plugin/22325-gitlab-duo/edit/versions/alpha)。

要安装预发布构建，可以：

- 从 JetBrains Marketplace 下载构建文件，然后 [从磁盘安装](https://www.jetbrains.com/help/idea/managing-plugins.html#install_plugin_from_disk)。
- [将 `alpha` 插件仓库添加到](https://www.jetbrains.com/help/idea/managing-plugins.html#add_plugin_repos) 你的 IDE 中。仓库 URL 使用 `https://plugins.jetbrains.com/plugins/alpha/list`。

  > [!note]
  > 添加 `alpha` 插件仓库后，要查看 alpha 版本，你可能需要卸载并重新安装极狐GitLab Duo 插件。