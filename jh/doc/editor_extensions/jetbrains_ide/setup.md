---
stage: AI Clients
group: Developer Clients
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在 JetBrains IDE 中连接并使用极狐GitLab Duo。
title: 为 JetBrains IDE 安装并设置极狐GitLab Duo 插件
---

从 [JetBrains 插件市场](https://plugins.jetbrains.com/plugin/22325-gitlab-duo)下载该插件并安装。

先决条件：

- JetBrains IDE：2025.1 及更高版本。
- 极狐GitLab 16.8 或更高版本。

如果您使用的是较旧版本的 JetBrains IDE，请下载与您的 IDE 兼容的插件版本：

1. 在极狐GitLab Duo [插件页面](https://plugins.jetbrains.com/plugin/22325-gitlab-duo)上，选择 **版本**。
1. 选择 **兼容性**，然后选择您的 JetBrains IDE。
1. 选择一个 **渠道**，以筛选稳定版本或 alpha 版本。
1. 在兼容性表中，找到您的 IDE 版本并选择 **下载**。

<a id="enable-the-plugin"></a>

## 启用插件

要启用插件：

1. 在您的 IDE 中，在顶部栏中选择您的 IDE 名称，然后选择 **设置**。
1. 在左侧边栏中，选择 **插件**。
1. 选择 **极狐GitLab Duo** 插件，然后选择 **安装**。
1. 选择 **确定** 或 **保存**。

<a id="connect-to-gitlab"></a>

## 连接到极狐GitLab

安装扩展后，将其连接到您的极狐GitLab 账号。

<a id="authenticate-with-gitlab"></a>

### 使用极狐GitLab 进行身份验证

先决条件：

- 使用 OAuth 进行极狐GitLab 私有化部署身份验证：
  - JetBrains 的极狐GitLab Duo 插件 3.30.30 及更高版本。
  - 实例级 [JetBrains IDE 的 OAuth 应用程序](../../administration/settings/editor_extensions.md#jetbrains-ides)的应用程序 ID。
- 使用 PAT 进行身份验证时，需要一个具有 `api` 范围的[个人访问令牌](../../user/profile/personal_access_tokens.md#create-a-personal-access-token)。
- 使用 1Password 进行身份验证时，需要完成[与 1Password 集成的步骤](_index.md#integrate-with-1password-cli)
  以及密钥引用。

在 IDE 中配置插件后，将其连接到您的极狐GitLab 账号：

1. 在您的 IDE 中，在顶部栏中选择您的 IDE 名称，然后选择 **设置**。
1. 在左侧边栏中，展开 **工具**，然后选择 **极狐GitLab Duo**。
   如果您没有看到该插件，请重启您的 IDE。
1. 提供 **极狐GitLab 实例的 URL**。对于 JihuLab.com，请使用 `https://gitlab.com`。
1. 选择一种身份验证方法：**OAuth**、**PAT** 或 **1Password CLI**。
   - 对于 OAuth，请按照提示登录并进行身份验证。
   - 对于 PAT，请输入您的个人访问令牌。
     令牌值不会显示，其他人也无法访问。
   - 对于 1Password，选择 **与 1Password CLI 集成**，选择您的账号，并可选地
     输入密钥引用。
1. 选择 **验证设置**。
1. 选择 **确定** 或 **保存**。

<a id="configure-gitlab-duo"></a>

## 配置极狐GitLab Duo

先决条件：

- 对于 Agent 功能，您需要满足[极狐GitLab Duo Agent Platform](../../user/duo_agent_platform/_index.md#prerequisites)的先决条件。
- 您已[开启](../../user/gitlab_duo/turn_on_off.md)极狐GitLab Duo。
- 对于任务流，您已[开启内置任务流](../../user/duo_agent_platform/flows/foundational_flows/_index.md#turn-foundational-flows-on-or-off)。
- 对于 Agent，您已根据需要[开启内置 Agent](../../user/duo_agent_platform/agents/foundational_agents/_index.md#turn-foundational-agents-on-or-off)
  并[启用自定义 Agent](../../user/duo_agent_platform/agents/custom.md#enable-an-agent)。
- 对于代码建议，您需要满足[其他先决条件](../../user/project/repository/code_suggestions/set_up.md#prerequisites)。
- 您的项目位于[群组命名空间](../../user/namespace/_index.md)中。
- 您已设置[默认极狐GitLab Duo 命名空间](../../user/profile/preferences.md#namespace-resolution-in-your-local-environment)，
  或已打开一个具有极狐GitLab Duo 访问权限的项目。

要开启或关闭极狐GitLab Duo 功能：

1. 在您的 JetBrains IDE 中，转到 **设置** > **工具** > **极狐GitLab Duo**。
1. 找到您要修改的功能，然后选中或清除复选框。
1. 选择 **确定** 或 **保存**。
1. 如果系统提示，请重启您的 IDE。

开启代码建议后，您还可以[添加对更多语言的支持](../../user/project/repository/code_suggestions/supported_extensions.md#add-support-for-more-languages)。

要按会话一次性批准 Agentic Chat 工具，而不是逐个批准，请参阅[工具审批](../../user/gitlab_duo_chat/agentic_chat.md#tool-approvals)。

<a id="add-a-custom-certificate-for-code-suggestions"></a>

### 为代码建议添加自定义证书

极狐GitLab Duo 会尝试在您无需配置的情况下检测[受信任的根证书](https://www.jetbrains.com/help/idea/ssl-certificates.html)。
如有需要，请配置您的 JetBrains IDE，以允许极狐GitLab Duo 插件
在连接到您的极狐GitLab 实例时使用自定义 SSL 证书。

要将自定义 SSL 证书与极狐GitLab Duo 一起使用：

1. 在您的 JetBrains IDE 中，转到 **设置** > **工具** > **极狐GitLab Duo**。
1. 在 **连接** 下，输入 **极狐GitLab 实例的 URL**。
1. 要验证您的连接，请选择 **验证设置**。
1. 选择 **确定** 或 **保存**。

如果您的 IDE 检测到不受信任的 SSL 证书，极狐GitLab Duo 插件会显示一条消息。请查看 SSL 证书详细信息，并确认证书详细信息与您在浏览器中连接到极狐GitLab 时显示的证书一致。

要查看您已接受的证书：

1. 在您的 JetBrains IDE 中，转到 **设置** > **外观与行为** > **系统设置** > **服务器证书**。
1. 选择某个证书以查看它。

<a id="connect-gitlab-duo-directly"></a>

### 直接连接极狐GitLab Duo

默认情况下，由 GitLab Language Server 处理的极狐GitLab Duo 和其他极狐GitLab 功能的流量
使用您的 JetBrains IDE 或系统环境中的代理设置。如果您的代理阻止此流量，您可以配置编辑器扩展，使这些请求绕过代理。

要直接连接极狐GitLab Duo：

1. 在您的 JetBrains IDE 中，转到 **设置** > **工具** > **极狐GitLab Duo**。
1. 在 **高级** > **GitLab Language Server** 下，选择 **直接从语言服务器连接极狐GitLab Duo**。
1. 选择 **确定** 或 **应用**。

此设置仅影响由 GitLab Language Server 处理的流量。
其他编辑器扩展网络请求继续使用编辑器的代理配置。

<a id="install-alpha-versions-of-the-plugin"></a>

## 安装插件的 alpha 版本

极狐GitLab 会将插件的预发布（alpha）版本发布到 JetBrains 插件市场中的
[`Alpha` 发布渠道](https://plugins.jetbrains.com/plugin/22325-gitlab-duo/edit/versions/alpha)。

要安装预发布版本，您可以：

- 从 JetBrains 插件市场下载该版本，并
  [从磁盘安装](https://www.jetbrains.com/help/idea/managing-plugins.html#install_plugin_from_disk)。
- [添加 `alpha` 插件仓库](https://www.jetbrains.com/help/idea/managing-plugins.html#add_plugin_repos)
  到您的 IDE。对于仓库 URL，请使用 `https://plugins.jetbrains.com/plugins/alpha/list`。

  > [!note]
  > 添加 `alpha` 插件仓库后，要看到 alpha 版本，您可能需要卸载并重新安装极狐GitLab Duo 插件。
