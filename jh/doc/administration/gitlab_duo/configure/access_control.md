---
stage: AI-powered
group: Agent Foundations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure access to GitLab Duo.
title: 配置访问 极狐GitLab Duo
---

{{< details >}}

- Tier: [基础版](../../../subscriptions/gitlab_credits.md#for-the-free-tier-on-gitlabcom)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.8 引入。

{{< /history >}}

您可以针对群组[开启或关闭 极狐GitLab Duo](../../../user/duo_agent_platform/turn_on_off.md#turn-gitlab-duo-on-or-off)，或为一个或多个群组限制对 极狐GitLab Duo 的访问。

<a id="restrict-access-to-gitlab-duo"></a>

限制访问 极狐GitLab Duo

{{< history >}}

- 默认 **无群组** 规则在极狐GitLab 18.10 引入。
- **成员访问** 部分和 **无群组** 规则在极狐GitLab 18.11 重命名。

{{< /history >}}

{{< tabs >}}

{{< tab title="On JihuLab.com" >}}

先决条件：

- 顶层群组的所有者角色。

要限制顶层群组对 极狐GitLab Duo 的访问：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **基于群组成员身份限制访问** 下，选择 **添加群组**。
1. 从下拉列表中，选择一个群组。

   当您选择第一个群组时，也会添加一个默认的 **所有符合条件的用户** 规则。
   您可以使用此规则为所有其他用户配置访问权限。
   当群组没有 极狐GitLab Duo Non-Agentic 或 极狐GitLab Duo Agent Platform 的访问权限且所有现有群组被移除时，此规则会自动删除。

1. 选择该群组的直接成员是否可以访问
   极狐GitLab Duo Non-Agentic 和 极狐GitLab Duo Agent Platform。
1. 选择 **保存更改**。

这些设置适用于以下用户：

- 属于 **基于群组成员身份限制访问** 中配置的群组之一的直接成员，
  并在顶层群组的项目或子群组中执行 AI 操作的用户。
- 将顶层群组设置为
  [默认 极狐GitLab Duo 命名空间](../../../user/profile/preferences.md#set-a-default-gitlab-duo-namespace)
  且不是执行 AI 操作所在顶层群组成员的所有用户。

配置访问控制时，您只能选择顶层群组的直接子群组。
不能在访问控制规则中使用嵌套子群组。

{{< /tab >}}

{{< tab title="私有化部署" >}}

先决条件：

- 管理员访问权限。

要限制实例对 极狐GitLab Duo 的访问：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **基于群组成员身份限制访问** 下：
   - 要添加现有群组，选择 **添加群组**。
   - 要创建新群组，选择 **创建群组**。
1. 从下拉列表中，选择一个群组。

   当您选择第一个群组时，也会添加一个默认的 **所有符合条件的用户** 规则。
   您可以使用此规则为所有其他用户配置访问权限。
   当群组没有 极狐GitLab Duo Non-Agentic 或 极狐GitLab Duo Agent Platform 的访问权限且所有现有群组被移除时，此规则会自动删除。

1. 选择该群组的直接成员是否可以访问
   极狐GitLab Duo Non-Agentic 和 极狐GitLab Duo Agent Platform。
1. 选择 **保存更改**。

这些设置适用于属于 **基于群组成员身份限制访问** 中配置的群组之一的直接成员的用户。

配置访问控制时，您只能选择顶层群组。
不能在访问控制规则中使用子群组。

{{< /tab >}}

{{< /tabs >}}

如果您不想手动管理群组成员身份，您可以[使用 LDAP 或 SAML 同步成员身份](#synchronize-group-membership)。

<a id="group-membership"></a>

群组成员身份

当用户被分配到多个群组时，该用户将拥有所有分配群组中的功能访问权限。
例如，如果用户在群组 A 中可访问 极狐GitLab Duo Non-Agentic，
在群组 B 中可访问 极狐GitLab Duo Agent Platform，
则该用户可以同时访问这两组功能。

如果配置了 **所有符合条件的用户** 规则，以下用户可以访问
极狐GitLab Duo Non-Agentic 和 极狐GitLab Duo Agent Platform：

- 在 JihuLab.com 上：顶层群组的所有成员。
- 在私有化部署中：所有用户。

其他控制（如为顶层群组或实例禁用功能）仍然适用。

<a id="synchronize-group-membership"></a>

同步群组成员身份

如果您使用 LDAP 或 SAML 进行认证，您可以自动同步群组成员身份：

1. 配置 LDAP 或 SAML 提供程序，以包含代表 极狐GitLab Duo Agent Platform 用户的群组。
1. 在极狐GitLab 中，确保该群组已链接到您的 LDAP 或 SAML 提供程序。
1. 当用户从提供程序群组中添加或移除时，群组成员身份会自动更新。

有关更多信息，请参见：

- [LDAP 群组同步](../../auth/ldap/_index.md)
- [私有化部署的 SAML](../../../integration/saml.md)
- [JihuLab.com 的 SAML](../../../user/group/saml_sso/_index.md)

<a id="using-access-control"></a>

使用访问控制

您可以将访问控制用于分阶段推广或测试和验证。

<a id="phased-rollouts"></a>

分阶段推广

要实施 极狐GitLab Duo 的分阶段推广：

1. 为试点用户创建一个群组（例如，`pilot-users`）。
1. 将一部分用户添加到此群组。
1. 在验证功能并培训用户的过程中，逐步向群组添加更多用户。
1. 当您准备进行全面推广时，将所有用户添加到群组。

<a id="testing-and-validation"></a>

测试和验证

要在受控环境中测试 极狐GitLab Duo 的功能：

1. 创建一个专门的测试群组（例如，`agent-testers`）。
1. 创建一个测试群组或项目。
1. 将测试用户添加到 `agent-testers` 群组。
1. 在更广泛的推广之前，验证功能并培训用户。

<a id="troubleshooting"></a>

故障排查

<a id="user-cannot-access-gitlab-duo-features"></a>

用户无法访问 极狐GitLab Duo 功能

在以下情况下，用户无法访问 极狐GitLab Duo 功能：

- 群组未配置对 极狐GitLab Duo Non-Agentic 或 极狐GitLab Duo Agent Platform 的访问权限。
- 群组已配置对 极狐GitLab Duo Non-Agentic 或 极狐GitLab Duo Agent Platform 的访问权限，但符合以下任一情况：
  - 该用户不是该群组的直接成员。
  - 未配置 **所有符合条件的用户** 规则。

要解决此问题，请执行以下操作之一：

- 将用户作为直接成员添加到一个已配置的群组中。
- 赋予 **所有符合条件的用户** 对 极狐GitLab Duo Non-Agentic 或 极狐GitLab Duo Agent Platform 的访问权限。
- 移除所有群组成员身份访问规则。

<a id="gitlab-duo-sidebar-does-not-display-for-certain-groups"></a>

极狐GitLab Duo 侧边栏在某些群组中不显示

在极狐GitLab 18.8 及更早版本中，如果您为群组授予了 极狐GitLab Duo Agent Platform 的访问权限，
但未授予 极狐GitLab Duo Non-Agentic 的访问权限，则 极狐GitLab Duo 侧边栏不会对该群组的成员显示。
作为变通方法，请确保该群组同时拥有 极狐GitLab Duo Non-Agentic 和 极狐GitLab Duo Agent Platform 的访问权限。

要解决此问题，请升级到极狐GitLab 18.9 或更高版本。