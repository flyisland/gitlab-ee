---
stage: Fulfillment
group: Seat Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 为极狐GitLab 私有化部署配置 SCIM
description: 通过自动化账号预配管理用户生命周期。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以使用开放标准跨域身份管理系统（SCIM）自动执行以下操作：

- 创建用户。
- 封锁用户。
- 重新添加用户（重新激活 SCIM 身份）。

[极狐GitLab 内部 SCIM API](../../development/internal_api/_index.md#instance-scim-api) 实现了 [RFC7644 协议](https://www.rfc-editor.org/rfc/rfc7644)的一部分。

如果您是 JihuLab.com 用户，请参阅[为 JihuLab.com 群组配置 SCIM](../../user/group/saml_sso/scim_setup.md)。

<a id="configure-gitlab"></a>

## 配置极狐GitLab

先决条件：

- 已配置 [SAML 单点登录](../../integration/saml.md)。
- 具有管理员访问权限。

要配置极狐GitLab SCIM：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开 **SCIM 令牌**部分，然后选择**生成 SCIM 令牌**。
1. 为配置您的身份提供商，请保存：
   - **您的 SCIM 令牌**字段中的令牌。
   - **SCIM API 端点 URL**字段中的 URL。

<a id="configure-an-identity-provider"></a>

## 配置身份提供商

极狐GitLab 支持与多个身份提供商配合使用 SCIM。其他身份提供商可能仍可与极狐GitLab 配合使用，但尚未经过测试，因此不受支持。如需不受支持提供商的帮助，请直接联系该提供商。极狐GitLab 支持可帮助审查相关日志条目。

<a id="configure-okta"></a>

### 配置 Okta

在 Okta 的[单点登录](../../integration/saml.md)设置期间创建的 SAML 应用程序必须针对 SCIM 进行设置。

先决条件：

- 您必须使用 [Okta Lifecycle Management](https://www.okta.com/products/lifecycle-management/) 产品。在 Okta 上使用 SCIM
  需要此产品层级。
- [极狐GitLab 已配置](#configure-gitlab) SCIM。
- 按照 [Okta 设置说明](../../integration/saml.md#set-up-okta)所述设置的 [Okta](https://developer.okta.com/docs/guides/build-sso-integration/saml2/main/) SAML 应用程序。
- 您的 Okta SAML 设置与[配置步骤](_index.md)一致，尤其是 NameID 配置。

要为 SCIM 配置 Okta：

1. 登录 Okta。
1. 在右上角，选择**管理员**。该按钮在**管理**区域中不可见。
1. 在**应用程序**标签页中，选择**浏览应用程序目录**。
1. 找到并选择 **GitLab** 应用程序。
1. 在 GitLab 应用程序概览页面上，选择**添加集成**。
1. 在**应用程序可见性**下，选中两个复选框。GitLab 应用程序不支持 SAML
   身份验证，因此不应向用户显示该图标。
1. 选择**完成**以完成添加应用程序。
1. 在**预配**标签页中，选择**配置 API 集成**。
1. 选择**启用 API 集成**。
   - 对于**基本 URL**，粘贴您从极狐GitLab SCIM 配置页面上的**SCIM API 端点 URL**复制的 URL。
   - 对于**API 令牌**，粘贴您从极狐GitLab SCIM
     配置页面上的**您的 SCIM 令牌**复制的 SCIM 令牌。
1. 要验证配置，请选择**测试 API 凭据**。
1. 选择**保存**。
1. 保存 API 集成详细信息后，左侧会出现新的设置标签页。选择**到应用**。
1. 选择**编辑**。
1. 为**创建用户**和**停用用户**选中**启用**复选框。
1. 选择**保存**。
1. 在**分配**标签页中分配用户。已分配的用户将在您的极狐GitLab 群组中创建和管理。

<a id="configure-microsoft-entra-id"></a>

### 配置 Microsoft Entra ID

先决条件：

- [极狐GitLab 已配置](#configure-gitlab) SCIM。
- [已设置 Microsoft Entra ID 的 SAML 应用程序](../../integration/saml.md#set-up-microsoft-entra-id)。

在[单点登录](../../integration/saml.md)设置期间为
[Azure Active Directory](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/view-applications-portal)
创建的 SAML 应用程序必须针对 SCIM 进行设置。有关示例，请参阅[示例配置](../../user/group/saml_sso/example_saml_config.md#scim-mapping)。

> [!note]
> 您必须完全按照以下说明中的详细内容配置 SCIM 预配。如果配置错误，您将遇到用户预配
> 和登录方面的问题，解决这些问题需要付出大量精力。如果您在任何步骤中遇到问题或有疑问，请联系极狐GitLab 支持。

要配置 Microsoft Entra ID，您需要配置：

- 用于 SCIM 的 Microsoft Entra ID。
- 设置。
- 映射，包括属性映射。

<a id="configure-microsoft-entra-id-for-scim"></a>

#### 为 SCIM 配置 Microsoft Entra ID

1. 在您的应用中，转到**预配**标签页，然后选择**开始**。
1. 将**预配模式**设置为**自动**。
1. 使用以下值完成**管理员凭据**：
   - 极狐GitLab 中的**SCIM API 端点 URL**，用于**租户 URL**字段。
   - 极狐GitLab 中的**您的 SCIM 令牌**，用于**密钥令牌**字段。
1. 选择**测试连接**。

   如果测试成功，请保存您的配置。

   如果测试不成功，请参阅
   [故障排除](../../user/group/saml_sso/troubleshooting.md)以尝试解决此问题。
1. 选择**保存**。

保存后，将显示**映射**和**设置**部分。

<a id="configure-mappings"></a>

#### 配置映射

群组同步是可选的。如果要配置它，请在**映射**部分下，先预配群组：

1. 选择**预配 Microsoft Entra ID 群组**。
1. 在属性映射页面上，打开**已启用**开关。
1. 在**目标对象操作**下，选中**创建**、**更新**和**删除**复选框。
1. 在**属性映射**下，编辑第一个属性，使其具有：
   - **源属性**为 `displayName`。
   - **目标属性**为 `displayName`。
   - **匹配优先级**为 `1`。

1. 选择**保存**。

接下来，预配用户：

1. 选择**预配 Microsoft Entra ID 用户**。
1. 确保**已启用**开关设置为**是**。
1. 确保所有**目标对象操作**均已启用。
1. 在**属性映射**下，配置映射以匹配
   [已配置的属性映射](#configure-attribute-mappings)：
   1. 可选。在**customappsso 属性**列中，找到 `externalId` 并将其删除。
   1. 编辑第一个属性，使其具有：
      - **源属性**为 `objectId`。
      - **目标属性**为 `externalId`。
      - **匹配优先级**为 `1`。
      - **应用此映射**设置为 `Always`
   1. 更新现有的 **customappsso** 属性，以匹配
      [已配置的属性映射](#configure-attribute-mappings)。
   1. 删除[属性映射表](#configure-attribute-mappings)中不存在的任何其他属性。如果不删除它们，它们不会导致问题，
      但极狐GitLab 不会使用这些属性。
1. 在映射列表下，选中**显示高级选项**复选框。
1. 选择**编辑 customappsso 的属性列表**链接。
1. 确保 `id` 是主要且必填字段，并且 `externalId` 也是必填字段。
1. 选择**保存**，这将返回属性映射配置页面。
1. 要关闭**属性映射**配置页面，请选择右上角的 `X`。

<a id="configure-attribute-mappings"></a>

##### 配置属性映射

> [!note]
> 在 Microsoft 从 Azure Active Directory 命名方案过渡到 Entra ID 命名方案期间，您可能会注意到
> 用户界面中存在不一致之处。如果遇到问题，您可以查看本文档的旧版本，或联系极狐GitLab 支持。

在为 SCIM 配置 Entra ID 时，您需要配置
属性映射。有关示例，请参阅[示例配置](../../user/group/saml_sso/example_saml_config.md#scim-mapping)。

下表提供了极狐GitLab 所需的属性映射。

| 源属性                                                           | 目标属性               | 匹配优先级 |
|:---------------------------------------------------------------------------|:-------------------------------|:--------------------|
| `objectId`                                                                 | `externalId`                   | 1                   |
| `userPrincipalName` 或 `mail`[^mail-source-attribute]                                 | `emails[type eq "work"].value` |                     |
| `mailNickname`                                                    | `userName`                     |                     |
| `displayName` 或 `Join(" ", [givenName], [surname])`[^join-expression]          | `name.formatted`               |                     |
| `Switch([IsSoftDeleted], , "False", "True", "True", "False")`[^expression-mapping] | `active`                       |                     |

[^mail-source-attribute]: 当 `userPrincipalName` 不是电子邮件地址或不可投递时，使用 `mail` 作为源属性。
[^join-expression]: 如果您的 `displayName` 与 `Firstname Lastname`的格式不匹配，请使用 `Join` 表达式。
[^expression-mapping]: 这是表达式映射类型，不是直接映射。在**映射类型**下拉列表中选择**表达式**。

每个属性映射都有：

- 一个**customappsso 属性**，对应于**目标属性**。
- 一个**Microsoft Entra ID 属性**，对应于**源属性**。
- 一个匹配优先级。

对于每个属性：

1. 编辑现有属性或添加新属性。
1. 从下拉列表中选择所需的源属性和目标属性映射。
1. 选择**确定**。
1. 选择**保存**。

如果您的 SAML 配置与[推荐的 SAML 设置](../../integration/saml.md)不同，请选择映射属性并相应修改它们。您映射到 `externalId` 目标属性的源属性必须与用于 SAML `NameID`的属性匹配。

如果表中未列出某个映射，请使用 Microsoft Entra ID 默认值。有关所需属性的列表，请参阅[内部实例 SCIM API](../../development/internal_api/_index.md#instance-scim-api) 文档。

<a id="configure-settings"></a>

#### 配置设置

在**设置**部分下：

1. 可选。如果需要，选中**发生故障时发送电子邮件通知**复选框。
1. 可选。如果需要，选中**防止意外删除**复选框。
1. 如有必要，选择**保存**以确保所有更改均已保存。

配置完映射和设置后，返回应用概览页面，然后选择**开始预配**，以开始自动对极狐GitLab 中的用户进行 SCIM 预配。

> [!warning]
> 同步后，更改映射到 `id` 和 `externalId`的字段可能会导致错误。这些错误包括
> 预配错误和重复用户，并且可能会阻止现有用户访问极狐GitLab 群组。

<a id="remove-access"></a>

## 移除访问权限

在身份提供商上移除或停用用户会通过将身份标记为 `active: false` 来在极狐GitLab 上封锁该用户，而 SCIM 身份仍与极狐GitLab 用户账号保持关联。

通过 SCIM 取消预配用户不会移除关联的 SAML 身份。

要更新用户 SCIM 身份，请使用
[极狐GitLab 内部 SCIM API](../../development/internal_api/_index.md#update-a-single-scim-provisioned-user-1)。

<a id="reactivate-access"></a>

## 重新激活访问权限

通过 SCIM 移除或停用用户后，您可以通过将该用户添加到 SCIM 身份提供商来重新激活该用户。

在身份提供商根据其配置的计划执行同步后，该用户的 SCIM 身份将被重新激活，其对极狐GitLab 实例的访问权限也将恢复。由于关联的 SAML 身份在取消预配期间会保留，用户可以立即使用 SSO 登录。

<a id="group-synchronization-with-scim"></a>

## 使用 SCIM 进行群组同步

除了用户预配之外，您还可以使用 SCIM 在您的身份提供商和极狐GitLab 之间同步群组成员关系。通过此方法，您可以根据用户在身份提供商中的群组成员关系，自动在极狐GitLab 群组中添加和移除用户。

先决条件：

- 必须先配置 [SAML 群组链接](../../user/group/saml_sso/group_sync.md#configure-saml-group-links)。
- 您身份提供商中的 SAML 群组名称必须与极狐GitLab 中配置的 SAML 群组名称匹配。

SCIM 群组同步与 SAML 群组链接配合使用来管理群组成员关系。当您的身份提供商通过 SCIM API 发送群组成员关系变更时，极狐GitLab 会更新所有与该 SCIM 群组关联了 SAML 群组链接的极狐GitLab 群组中的用户成员关系。

SCIM 是单向协议：变更从您的身份提供商流向极狐GitLab。如果您在极狐GitLab 中更改 SAML 群组链接（例如添加或移除它们），您的身份提供商无法通过 SCIM 检测到这些更改。

<a id="saml-group-link-and-scim-group-association"></a>

### SAML 群组链接与 SCIM 群组关联

当您的身份提供商首次预配 SCIM 群组时（通过 `POST /Groups`），极狐GitLab 会将 SCIM 群组 ID 与所有具有匹配群组名称的现有 SAML 群组链接关联起来。当您创建具有相同群组名称的新 SAML 群组链接时，极狐GitLab 会自动将现有 SCIM 群组 ID 继承到新的 SAML 群组链接上。

<a id="deleting-saml-group-links"></a>

#### 删除 SAML 群组链接

如果您在极狐GitLab 中删除某个 SAML 群组链接，通过该链接加入该群组的成员仍会保留在该群组中。但是，由于该群组链接已被移除，SCIM 不再管理他们在该群组中的成员关系。如有需要，您可以手动[从群组中移除成员](../../user/group/_index.md#remove-a-member-from-the-group)。

如果您删除与某个 SCIM 群组关联的所有 SAML 群组链接：

- 极狐GitLab 会清除该群组的 SCIM 成员关系缓存。
- 您的身份提供商会在下一个同步周期收到 `404 Group not found` 响应。

要恢复 SCIM 群组同步，请创建一个新的 SAML 群组链接，并在您的身份提供商中为该群组触发一次 SCIM 同步。

<a id="configure-group-synchronization-in-your-identity-provider"></a>

### 在您的身份提供商中配置群组同步

有关在您的身份提供商中配置群组同步的详细说明，请参阅该提供商的文档。示例如下：

- [Okta Groups API](https://developer.okta.com/docs/reference/api/groups/)
- [Microsoft Entra ID (Azure AD) SCIM Groups](https://learn.microsoft.com/en-us/entra/identity/app-provisioning/use-scim-to-provision-users-and-groups)
  - 默认情况下，使用 `displayName` 源属性来查找具有用户友好名称的 SAML 群组链接。
  - 但是，如果您的 SAML 群组链接使用对象 ID 作为名称，则必须将源属性更新为 `objectId`。

> [!warning]
> 当多个 SAML 群组链接映射到同一个极狐GitLab 群组时，用户会被分配所有映射群组链接中的最高角色。如果用户属于另一个链接到某极狐GitLab 群组的 SAML 群组，则即使用户已从某个 IdP 群组中移除，仍会保留在该极狐GitLab 群组中。

Okta 应用程序目录中的标准极狐GitLab SCIM 应用程序不支持群组同步。或者，您可以为 Okta 创建自定义 SCIM 集成以实现群组同步。有关更多信息，请参阅[议题 582729](https://gitlab.com/gitlab-org/gitlab/-/issues/582729)。

<a id="troubleshooting"></a>

## 故障排除

请参阅我们的 [SCIM 故障排除指南](../../user/group/saml_sso/troubleshooting_scim.md)。
