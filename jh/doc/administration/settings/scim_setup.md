---
stage: Fulfillment
group: Seat Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 为极狐GitLab 私有化部署配置 SCIM
description: 使用自动化的账户生命周期管理来管理用户生命周期。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

你可以使用开放标准跨域身份管理系统 (SCIM) 来自动执行以下操作：

- 创建用户
- 封锁用户
- 重新添加用户（重新激活 SCIM 身份）

[内部极狐GitLab SCIM API](../../development/internal_api/_index.md#instance-scim-api) 实现了 [RFC7644 协议](https://www.rfc-editor.org/rfc/rfc7644) 的部分内容。

如果你是 JihuLab.com 用户，请参阅[为 JihuLab.com 群组配置 SCIM](../../user/group/saml_sso/scim_setup.md)。

<a id="configure-gitlab"></a>

## 配置极狐GitLab

前提条件：

- 已配置 SAML 单点登录。
- 管理员访问权限。

配置极狐GitLab SCIM：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **SCIM 令牌** 部分并选择 **生成 SCIM 令牌**。
1. 为了配置您的身份提供程序，保存：
   - 来自 **您的 SCIM 令牌** 字段的令牌。
   - 来自 **SCIM API 端点 URL** 字段的 URL。

<a id="configure-an-identity-provider"></a>

## 配置身份提供程序

极狐GitLab 支持多种身份提供程序的 SCIM。其他身份提供程序可能仍可与极狐GitLab 配合使用，但未经测试且不受支持。有关不受支持的提供程序的帮助，请直接联系该提供程序。极狐GitLab 支持团队可以帮助审查相关日志条目。

<a id="configure-okta"></a>

### 配置 Okta

在 [单点登录](../../integration/saml.md) 设置过程中为 Okta 创建的 SAML 应用程序必须为 SCIM 进行设置。

前提条件：

- 你必须使用 [Okta Lifecycle Management](https://www.okta.com/products/lifecycle-management/) 产品。此产品层级是在 Okta 上使用 SCIM 所必需的。
- [极狐GitLab 已配置 SCIM](#configure-gitlab)。
- 按照 [Okta 设置说明](../../integration/saml.md#set-up-okta) 中的说明设置的 [Okta](https://developer.okta.com/docs/guides/build-sso-integration/saml2/main/) SAML 应用程序。
- 你的 Okta SAML 设置与 [配置步骤](_index.md) 匹配，尤其是 NameID 配置。

配置 Okta for SCIM：

1. 登录 Okta。
1. 在右上角，选择 **管理员**。从 **管理员** 区域看不到该按钮。
1. 在 **应用程序** 选项卡中，选择 **浏览应用程序目录**。
1. 找到并选择 **GitLab** 应用程序。
1. 在 GitLab 应用程序概览页面上，选择 **添加集成**。
1. 在 **应用程序可见性** 下，选中两个复选框。GitLab 应用程序不支持 SAML 身份验证，因此不应向用户显示该图标。
1. 选择 **完成** 以完成添加应用程序。
1. 在 **预配** 选项卡中，选择 **配置 API 集成**。
1. 选择 **启用 API 集成**。
   - 对于 **基本 URL**，粘贴从极狐GitLab SCIM 配置页面上的 **SCIM API 端点 URL** 复制的 URL。
   - 对于 **API 令牌**，粘贴从极狐GitLab SCIM 配置页面上的 **您的 SCIM 令牌** 复制的 SCIM 令牌。
1. 要验证配置，请选择 **测试 API 凭据**。
1. 选择 **保存**。
1. 保存 API 集成详细信息后，左侧会出现新的设置选项卡。选择 **到应用**。
1. 选择 **编辑**。
1. 选中 **启用** 复选框，同时选中 **创建用户** 和 **停用用户**。
1. 选择 **保存**。
1. 在 **分配** 选项卡中分配用户。分配的用户将在你的极狐GitLab 群组中创建和管理。

<a id="configure-microsoft-entra-id"></a>

### 配置 Microsoft Entra ID

{{< history >}}

- 在极狐GitLab 16.10 中更改了 Microsoft Entra ID 术语。

{{< /history >}}

前提条件：

- [极狐GitLab 已配置 SCIM](#configure-gitlab)。
- [已设置 Microsoft Entra ID 的 SAML 应用程序](../../integration/saml.md#set-up-microsoft-entra-id)。

在 [单点登录](../../integration/saml.md) 设置过程中为 [Azure Active Directory](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/view-applications-portal) 创建的 SAML 应用程序必须为 SCIM 进行设置。有关示例，请参阅[示例配置](../../user/group/saml_sso/example_saml_config.md#scim-mapping)。

> [!note]
> 你必须完全按照以下说明中的详细步骤配置 SCIM 预配。如果配置错误，你将遇到用户预配和登录问题，这些问题需要大量精力才能解决。如果你在任何步骤中遇到任何问题或疑问，请联系极狐GitLab 支持。

要配置 Microsoft Entra ID，你需要配置：

- 为 SCIM 配置 Microsoft Entra ID。
- 设置。
- 映射，包括属性映射。

<a id="configure-microsoft-entra-id-for-scim"></a>

#### 为 SCIM 配置 Microsoft Entra ID

1. 在你的应用程序中，转到 **预配** 选项卡并选择 **开始**。
1. 将 **预配模式** 设置为 **自动**。
1. 使用以下值填写 **管理员凭据**：
   - 在 GitLab 中的 **SCIM API 端点 URL** 用于 **租户 URL** 字段。
   - 在 GitLab 中的 **您的 SCIM 令牌** 用于 **密钥令牌** 字段。
1. 选择 **测试连接**。
   如果测试成功，请保存配置。
   如果测试失败，请参阅[故障排除](../../user/group/saml_sso/troubleshooting.md)以尝试解决此问题。
1. 选择 **保存**。

保存后，**映射** 和 **设置** 部分将出现。

<a id="configure-mappings"></a>

#### 配置映射

在 **映射** 部分下，首先预配群组：

1. 选择 **预配 Microsoft Entra ID 群组**。
1. 在属性映射页面上，关闭 **已启用** 开关。
   极狐GitLab 不支持 SCIM 群组预配。启用群组预配不会破坏 SCIM 用户预配，但会在 Entra ID SCIM 预配日志中产生可能令人困惑和误导的错误。
   > [!note]
   > 即使 **预配 Microsoft Entra ID 群组** 已禁用，映射部分可能仍显示 **已启用: 是**。此行为是一个显示错误，可以安全地忽略。
1. 选择 **保存**。

接下来，预配用户：

1. 选择 **预配 Microsoft Entra ID 用户**。
1. 确保 **已启用** 开关设置为 **是**。
1. 确保所有 **目标对象操作** 均已启用。
1. 在 **属性映射** 下，配置映射以匹配[配置的属性映射](#configure-attribute-mappings)：
   1. 可选。在 **customappsso 属性** 列中，找到 `externalId` 并将其删除。
   1. 编辑第一个属性，使其具有：
      - **源属性** 为 `objectId`。
      - **目标属性** 为 `externalId`。
      - **匹配优先级** 为 `1`。
   1. 更新现有的 **customappsso** 属性以匹配[配置的属性映射](#configure-attribute-mappings)。
   1. 删除任何未出现在[属性映射表](#configure-attribute-mappings)中的额外属性。如果不删除它们不会造成问题，但极狐GitLab 不会使用这些属性。
1. 在映射列表下，选中 **显示高级选项** 复选框。
1. 选择 **编辑 customappsso 的属性列表** 链接。
1. 确保 `id` 是主字段和必填字段，`externalId` 也是必填字段。
1. 选择 **保存**，这将返回属性映射配置页面。
1. 要关闭 **属性映射** 配置页面，选择右上角的 `X`。

<a id="configure-attribute-mappings"></a>

##### 配置属性映射

> [!note]
> 当 Microsoft 从 Azure Active Directory 过渡到 Entra ID 命名方案时，你可能会注意到用户界面中的不一致。如果遇到问题，可以查看本文档的旧版本或联系极狐GitLab 支持。

在配置 Entra ID for SCIM 时，你需要配置属性映射。有关示例，请参阅[示例配置](../../user/group/saml_sso/example_saml_config.md#scim-mapping)。

下表提供了极狐GitLab 所需的属性映射。

| 源属性                                                           | 目标属性               | 匹配优先级 |
|:---------------------------------------------------------------------------|:-------------------------------|:--------------------|
| `objectId`                                                                 | `externalId`                   | 1                   |
| `userPrincipalName` 或 `mail` <sup>1</sup>                                 | `emails[type eq "work"].value` |                     |
| `mailNickname`                                                    | `userName`                     |                     |
| `displayName` 或 `Join(" ", [givenName], [surname])` <sup>2</sup>          | `name.formatted`               |                     |
| `Switch([IsSoftDeleted], , "False", "True", "True", "False")` <sup>3</sup> | `active`                       |                     |

**脚注**:

1. 当 `userPrincipalName` 不是电子邮件地址或不可投递时，使用 `mail` 作为源属性。
1. 如果你的 `displayName` 不匹配 `Firstname Lastname` 格式，请使用 `Join` 表达式。
1. 这是一种表达式映射类型，而不是直接映射。在 **映射类型** 下拉列表中选择 **表达式**。

每个属性映射包含：

- 一个 **customappsso 属性**，对应 **目标属性**。
- 一个 **Microsoft Entra ID 属性**，对应 **源属性**。
- 匹配优先级。

对于每个属性：

1. 编辑现有属性或添加新属性。
1. 从下拉列表中选择所需的源属性和目标属性映射。
1. 选择 **确定**。
1. 选择 **保存**。

如果你的 SAML 配置与[推荐的 SAML 设置](../../integration/saml.md) 不同，请选择映射属性并相应地修改它们。映射到 `externalId` 目标属性的源属性必须与用于 SAML `NameID` 的属性匹配。

如果表中未列出某个映射，请使用 Microsoft Entra ID 默认值。有关所需属性的列表，请参阅[内部实例 SCIM API](../../development/internal_api/_index.md#instance-scim-api) 文档。

<a id="configure-settings"></a>

#### 配置设置

在 **设置** 部分下：

1. 可选。如果需要，选中 **发生故障时发送电子邮件通知** 复选框。
1. 可选。如果需要，选中 **防止意外删除** 复选框。
1. 如有必要，选择 **保存** 以确保所有更改都已保存。

配置完映射和设置后，返回到应用程序概览页面，选择 **开始预配** 以开始自动 SCIM 预配极狐GitLab 中的用户。

> [!warning]
> 同步后，更改映射到 `id` 和 `externalId` 的字段可能会导致错误。这些包括预配错误、重复用户，并可能阻止现有用户访问极狐GitLab 群组。

<a id="remove-access"></a>

## 移除访问权限

在身份提供程序上移除或停用用户会在极狐GitLab 实例上封锁该用户，而 SCIM 身份仍与极狐GitLab 用户保持关联。

要更新用户的 SCIM 身份，请使用[内部极狐GitLab SCIM API](../../development/internal_api/_index.md#update-a-single-scim-provisioned-user-1)。

<a id="reactivate-access"></a>

## 重新激活访问权限

{{< history >}}

- 在极狐GitLab 16.0 中引入，带有一个名为 `skip_saml_identity_destroy_during_scim_deprovision` 的功能标志。默认禁用。
- 在极狐GitLab 16.4 中 GA。功能标志 `skip_saml_identity_destroy_during_scim_deprovision` 已移除。

{{< /history >}}

通过 SCIM 移除或停用用户后，你可以通过将其重新添加到 SCIM 身份提供程序来重新激活该用户。

在身份提供程序根据其配置的计划执行同步后，该用户的 SCIM 身份将被重新激活，并且其对极狐GitLab 实例的访问权限将被恢复。

<a id="group-synchronization-with-scim"></a>

## 使用 SCIM 进行群组同步

{{< history >}}

- 在极狐GitLab 18.0 中引入，带有一个名为 `self_managed_scim_group_sync` 的功能标志。默认禁用。
- 在极狐GitLab 18.2 中默认启用（仅限私有化部署）。
- 在极狐GitLab 18.6 中 GA。功能标志 `self_managed_scim_group_sync` 已移除。

{{< /history >}}

除了用户预配之外，你还可以使用 SCIM 在身份提供程序和极狐GitLab 之间同步群组成员关系。通过此方法，你可以根据用户在身份提供程序中的群组成员关系，自动在极狐GitLab 群组中添加和移除用户。

前提条件：

- 必须首先配置 [SAML 群组链接](../../user/group/saml_sso/group_sync.md#configure-saml-group-links)。
- 身份提供程序中的 SAML 群组名称必须与极狐GitLab 中配置的 SAML 群组名称匹配。

SCIM 群组同步与 SAML 群组链接配合工作来管理群组成员关系。当你的身份提供程序通过 SCIM API 发送群组成员关系变更时，极狐GitLab 会更新所有与该 SCIM 群组关联的 SAML 群组链接的极狐GitLab 群组中的用户成员关系。

SCIM 是单向协议：变更从你的身份提供程序流向极狐GitLab。如果你在极狐GitLab 中更改 SAML 群组链接（例如添加或移除它们），你的身份提供程序无法通过 SCIM 检测到这些更改。

<a id="known-limitation-of-new-group-links"></a>

### 新群组链接的已知限制

当你的身份提供程序首次预配 SCIM 群组（通过 `POST /Groups`）时，极狐GitLab 会将 SCIM 群组 ID 与所有具有匹配群组名称的现有 SAML 群组链接关联起来。但是，如果你在初始预配后添加了具有相同群组名称的新 SAML 群组链接，则这些新群组链接不会自动与 SCIM 群组 ID 关联。这意味着，来自身份提供程序的 SCIM 成员关系更新不会影响新添加的群组链接中的用户。

> [!note]
> 为了确保所有群组链接从一开始就与 SCIM 群组关联，你应该在身份提供程序中设置 SCIM 群组预配之前配置所有 SAML 群组链接。

如果你需要在初始预配后添加群组链接，可以通过删除 SCIM 群组预配（而不是 IdP 群组本身）然后重新创建它，在身份提供程序中重新预配 SCIM 群组。此操作会将所有当前的 SAML 群组链接与 SCIM 群组重新关联。有关更多信息，请参阅你的身份提供程序关于管理 SCIM 群组预配的文档。

如果你在极狐GitLab 中删除了一个 SAML 群组链接，通过该链接成为该群组成员的人仍然留在群组中。但是，SCIM 不再管理他们在该群组中的成员关系，因为群组链接已被移除。如果需要，你可以手动[从群组中移除成员](../../user/group/_index.md#remove-a-member-from-the-group)。

<a id="configure-group-synchronization-in-your-identity-provider"></a>

### 在身份提供程序中配置群组同步

有关在身份提供程序中配置群组同步的详细说明，请参阅提供程序的文档。示例如下：

- [Okta Groups API](https://developer.okta.com/docs/reference/api/groups/)
- [Microsoft Entra ID (Azure AD) SCIM Groups](https://learn.microsoft.com/en-us/entra/identity/app-provisioning/use-scim-to-provision-users-and-groups)
  - 默认情况下，使用 `displayName` 源属性来查找具有用户友好名称的 SAML 群组链接。
  - 但是，如果你的 SAML 群组链接使用对象 ID 作为名称，则必须将源属性更新为 `objectId`。

> [!warning]
> 当多个 SAML 群组链接映射到同一个极狐GitLab 群组时，用户将在所有映射群组链接中获得最高角色。如果用户属于与某个极狐GitLab 群组链接的另一个 SAML 群组，则从 IdP 群组中移除的用户仍留在该极狐GitLab 群组中。

Okta 应用程序目录中的标准极狐GitLab SCIM 应用程序不支持群组同步。或者，你可以为与 Okta 的群组同步创建自定义 SCIM 集成。

<a id="troubleshooting"></a>

## 故障排除

请参阅我们的[SCIM 故障排除指南](../../user/group/saml_sso/troubleshooting_scim.md)。