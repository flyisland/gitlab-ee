---
stage: Security Governance
group: AI Control Plane
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 配置对极狐GitLab Duo 的访问权限。
title: 配置对极狐GitLab Duo 的访问权限
---

{{< details >}}

- Tier: [基础版](../../../subscriptions/gitlab_credits.md#for-the-free-tier)、专业版、旗舰版
- Offering: JihuLab.com、私有化部署

{{< /details >}}

您可以为群组[开启或关闭极狐GitLab Duo](../../../user/duo_agent_platform/turn_on_off.md#turn-gitlab-duo-on-or-off)，或限制一个或多个群组对极狐GitLab Duo 的访问权限。

<a id="restrict-access-to-gitlab-duo"></a>

## 限制对极狐GitLab Duo 的访问权限

> [!flag]
> 此功能的可用性由功能标志控制。

{{< tabs >}}

{{< tab title="JihuLab.com" >}}

先决条件：

- 顶级群组的所有者角色。

要为顶级群组限制对极狐GitLab Duo 的访问权限：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**基于群组成员资格限制访问**下，选择**添加群组**。
1. 从下拉列表中，选择一个群组。

   当您选择第一个群组时，还会添加一条默认的**所有符合条件的用户**规则。
   您可以使用此规则为所有其他用户配置访问权限。
   当该群组无权访问 GitLab Duo Non-Agentic
   或极狐GitLab Duo Agent Platform，且所有现有群组均被移除时，此规则会自动删除。

1. 选择该群组的直接成员是否可以访问
   GitLab Duo Non-Agentic 和极狐GitLab Duo Agent Platform。
1. 选择**保存更改**。

这些设置适用于以下用户：

- 属于**基于群组成员资格限制访问**下配置的某个群组的直接成员，
  并在顶级群组的某个项目或子群组中执行 AI 操作的用户。
- 将顶级群组设为
  [默认极狐GitLab Duo 命名空间](../../../user/profile/preferences.md#set-a-default-gitlab-duo-namespace)，
  且不是执行 AI 操作所在顶级群组的成员的用户。

配置访问控制时，您只能选择顶级群组的直接子群组。
访问控制规则中不能使用嵌套子群组。

{{< /tab >}}

{{< tab title="极狐GitLab 私有化部署" >}}

先决条件：

- 管理员访问权限。

要为实例限制对极狐GitLab Duo 的访问权限：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在**基于群组成员资格限制访问**下：
   - 要添加现有群组，选择**添加群组**。
   - 要创建新群组，选择**创建群组**。
1. 从下拉列表中，选择一个群组。

   当您选择第一个群组时，还会添加一条默认的**所有符合条件的用户**规则。
   您可以使用此规则为所有其他用户配置访问权限。
   当该群组无权访问 GitLab Duo Non-Agentic
   或极狐GitLab Duo Agent Platform，且所有现有群组均被移除时，此规则会自动删除。

1. 选择该群组的直接成员是否可以访问
   GitLab Duo Non-Agentic 和极狐GitLab Duo Agent Platform。
1. 选择**保存更改**。

这些设置适用于属于**基于群组成员资格限制访问**下配置的
某个群组的直接成员的用户。

配置访问控制时，您可以选择
任意顶级群组或子群组。
访问规则的更改最多需要五分钟才能生效，
因为访问决策会按用户进行缓存。

{{< /tab >}}

{{< /tabs >}}

如果您不想手动管理群组成员资格，可以[使用 LDAP 或 SAML 同步成员资格](#synchronize-group-membership)。

<a id="group-membership"></a>

### 群组成员资格

当用户被分配到多个群组时，该用户可以访问所有已分配群组的功能。
例如，如果用户可以在群组 A 中访问 GitLab Duo Non-Agentic，
在群组 B 中访问极狐GitLab Duo Agent Platform，
则该用户可以访问这两组功能。

如果配置了**所有符合条件的用户**规则，以下用户可以
同时访问 GitLab Duo Non-Agentic 和极狐GitLab Duo Agent Platform：

- 在 JihuLab.com 上：顶级群组的所有成员。
- 在极狐GitLab 私有化部署上：所有用户。

其他控制措施（例如为顶级群组或实例禁用功能）仍然适用。

<a id="synchronize-group-membership"></a>

#### 同步群组成员资格

如果您使用 LDAP 或 SAML 进行身份验证，可以自动同步群组成员资格：

1. 配置您的 LDAP 或 SAML 提供商，使其包含一个代表极狐GitLab Duo Agent Platform 用户的群组。
1. 在极狐GitLab 中，确保该群组已关联到您的 LDAP 或 SAML 提供商。
1. 当用户在提供商群组中被添加或移除时，群组成员资格会自动更新。

有关更多信息，请参阅：

- [LDAP 群组同步](../../auth/ldap/_index.md)
- [极狐GitLab 私有化部署的 SAML](../../../integration/saml.md)
- [JihuLab.com 的 SAML](../../../user/group/saml_sso/_index.md)

<a id="using-access-control"></a>

## 使用访问控制

您可以使用访问控制进行分阶段推出或测试与验证。

<a id="phased-rollouts"></a>

### 分阶段推出

要分阶段推出极狐GitLab Duo：

1. 为试点用户创建一个群组（例如 `engineering/duo-pilot`）。
1. 将一部分用户添加到此群组。
1. 在验证功能并培训用户的过程中，逐步向该群组添加更多用户。
1. 当您准备好全面推出时，将所有用户添加到该群组。

<a id="testing-and-validation"></a>

### 测试与验证

要在受控环境中测试极狐GitLab Duo 能力：

1. 创建一个专用测试群组（例如 `agent-testers`）。
1. 创建一个测试群组或项目。
1. 将测试用户添加到 `agent-testers` 群组。
1. 在更广泛地推出之前，验证功能并培训用户。

<a id="troubleshooting"></a>

## 故障排除

<a id="user-cannot-access-gitlab-duo-features"></a>

### 用户无法访问极狐GitLab Duo 功能

在以下情况下，用户无法访问极狐GitLab Duo 功能：

- 未为该群组配置对 GitLab Duo Non-Agentic 或极狐GitLab Duo Agent Platform
  的访问权限。
- 已为该群组配置对 GitLab Duo Non-Agentic 或极狐GitLab Duo Agent Platform
  的访问权限，但存在以下任一情况：
  - 该用户不是该群组的直接成员。
  - 未配置**所有符合条件的用户**规则。

要解决此问题，请执行以下任一操作：

- 将该用户作为直接成员添加到某个已配置的群组。
- 为**所有符合条件的用户**授予对 GitLab Duo Non-Agentic 或极狐GitLab Duo Agent Platform 的访问权限。
- 移除所有群组成员资格访问规则。

<a id="gitlab-duo-sidebar-does-not-display-for-certain-groups"></a>

### 某些群组不显示极狐GitLab Duo 侧边栏

在极狐GitLab 18.8 及更早版本中，如果您为某个群组授予对极狐GitLab Duo Agent Platform 的访问权限，但未授予对
GitLab Duo Non-Agentic 的访问权限，则极狐GitLab Duo 侧边栏不会向该群组的成员显示。
作为变通方法，请确保该群组同时具有对
GitLab Duo Non-Agentic 和极狐GitLab Duo Agent Platform 的访问权限。

要解决此问题，请升级到极狐GitLab 18.9 或更高版本。
