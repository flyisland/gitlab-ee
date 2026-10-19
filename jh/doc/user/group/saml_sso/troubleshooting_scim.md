---
stage: Fulfillment
group: Seat Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 SCIM 故障
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本部分包含您可能遇到的问题的可能解决方案。

<a id="user-cannot-be-added-after-they-are-removed"></a>

## 用户被移除后无法再次添加

当您移除用户时，他们将从群组中被移除，但他们的帐户不会被删除（请参阅 [移除访问权限](scim_setup.md#remove-access)）。

当用户被重新添加到 SCIM 应用时，极狐GitLab 不会创建新用户，因为该用户已存在。

自 2023 年 8 月 11 日起，`skip_saml_identity_destroy_during_scim_deprovision` 功能标志已启用。

对于自该日期起通过 SCIM 取消配置的用户，其 SAML 身份不会被移除。当该用户被重新添加到 SCIM 应用时：

- 其 SCIM 身份 `active` 属性将被设置为 `true`。
- 他们可以使用 SSO 登录。

对于在该日期之前通过 SCIM 取消配置的用户，其 SAML 身份将被销毁。要解决此问题，用户必须 [将 SAML 链接到其现有的 JihuLab.com 帐户](_index.md#link-saml-to-your-existing-gitlabcom-account)。

<a id="gitlab-self-managed"></a>

### 私有化部署

对于私有化部署的极狐GitLab，该实例的管理员可以改为 [自行添加用户身份](../../../administration/admin_area.md#user-identities)。如果管理员需要重新添加多个身份，这可能会节省时间。

<a id="user-cannot-sign-in"></a>

## 用户无法登录

以下是用户无法登录问题的可能解决方案：

- 确保用户已被添加到 SCIM 应用。
- 如果您收到 `User is not linked to a SAML account` 错误，则该用户可能已存在于极狐GitLab 中。让用户按照 [链接 SCIM 和 SAML 身份](scim_setup.md#link-scim-and-saml-identities) 说明进行操作。或者，私有化部署管理员可以 [添加用户身份](../../../administration/admin_area.md#user-identities)。
- 极狐GitLab 存储的 **身份** (`extern_uid`) 值会在 `id` 或 `externalId` 更改时由 SCIM 更新。除非登录方法的极狐GitLab 标识符 (`extern_uid`) 与提供商发送的 ID 匹配，例如 SAML 发送的 `NameId`，否则用户无法登录。此值也由 SCIM 用于匹配 `id` 上的用户，并在 `id` 或 `externalId` 值更改时由 SCIM 更新。
- 在 JihuLab.com 上，SCIM `id` 和 SCIM `externalId` 必须配置为与 SAML `NameId` 相同的值。您可以使用 [调试工具](troubleshooting.md#saml-debugging-tools) 来跟踪 SAML 响应，并根据 [SAML 故障排查](troubleshooting.md) 信息检查任何错误。

<a id="unsure-if-users-saml-nameid-matches-the-scim-externalid"></a>

## 不确定用户的 SAML `NameId` 是否与 SCIM `externalId` 匹配

要检查用户的 SAML `NameId` 是否与其 SCIM `externalId` 匹配：

- 管理员可以使用 **管理员** 区域 [列出用户的 SCIM 身份](../../../administration/admin_area.md#user-identities)。
- 群组所有者可以在群组 SAML SSO 设置页面中查看用户列表以及为每个用户存储的标识符。
- 您可以使用 [SCIM API](../../../api/scim.md) 手动检索极狐GitLab 为用户存储的 `extern_uid`，并将其与来自 [SAML API](../../../api/saml.md) 的每个用户的值进行比较。
- 让用户使用 [SAML Tracer](troubleshooting.md#saml-debugging-tools) 并将 `extern_uid` 与作为 SAML `NameId` 返回的值进行比较。

<a id="mismatched-scim-extern_uid-and-saml-nameid"></a>

## SCIM `extern_uid` 和 SAML `NameId` 不匹配

无论值是否已更改，或者您需要映射到不同的字段，以下内容必须映射到相同的字段：

- `extern_Id`
- `NameId`

如果 SCIM `extern_uid` 与 SAML `NameId` 不匹配，您必须更新 SCIM `extern_uid` 以使用户能够登录。

修改 SCIM 身份提供商使用的字段（通常是 `extern_Id`）时要谨慎。您的身份提供商应配置为执行此更新。在某些情况下，身份提供商无法执行更新，例如当用户查找失败时。

极狐GitLab 使用这些 ID 来查找用户。如果身份提供商不知道这些字段的当前值，则该提供商可能会创建重复用户，或无法完成预期的操作。

要更改标识符值以使其匹配，您可以执行以下操作之一：

- 让用户根据 [SAML 认证失败：用户已存在](troubleshooting.md#message-saml-authentication-failed-user-has-already-been-taken) 部分自行取消链接并重新链接。
- 在开启同步的情况下，通过从 SCIM 应用中移除所有用户来同时取消所有用户的链接。

  > [!warning]
  > 这将使所有用户在顶级群组和子群组中的角色重置为 [已配置的默认成员角色](_index.md#configure-gitlab)。

- 使用 [SAML API](../../../api/saml.md) 或 [SCIM API](../../../api/scim.md) 手动更正为用户存储的 `extern_uid`，以与 SAML `NameId` 或 SCIM `externalId` 匹配。

您不得：

- 将这些值更新为不正确的值，因为这会导致用户无法登录。
- 将值分配给错误的用户，因为这会导致用户登录到错误的帐户。

此外，用户的主电子邮件必须与您的 SCIM 身份提供商中的电子邮件匹配。

<a id="change-scim-app"></a>

## 更改 SCIM 应用

当 SCIM 应用发生更改时：

- 用户可以按照 [更改 SAML 应用](_index.md#change-the-identity-provider) 部分中的说明进行操作。
- 身份提供商的管理员可以：
  1. 从 SCIM 应用中移除用户，这将：
     - 在 JihuLab.com 上，从群组中移除所有被移除的用户。
     - 在私有化部署的极狐GitLab 中，屏蔽用户。
  1. 为新的 SCIM 应用开启同步以 [链接现有用户](scim_setup.md#link-scim-and-saml-identities)。

<a id="scim-app-returns-user-has-already-been-taken-status-409-error"></a>

## SCIM 应用返回 `"User has already been taken","status":409` 错误

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

更改 SAML 或 SCIM 配置或提供商可能会导致以下问题：

- SAML 和 SCIM 身份不匹配。要解决此问题：
  1. [验证用户的 SAML `NameId` 是否与 SCIM `extern_uid` 匹配](#unsure-if-users-saml-nameid-matches-the-scim-externalid)。
  1. [更新或修复不匹配的 SCIM `extern_uid` 和 SAML `NameId`](#mismatched-scim-extern_uid-and-saml-nameid)。
- 极狐GitLab 与身份提供商 SCIM 应用之间的 SCIM 身份不匹配。要解决此问题：
  1. 使用 [SCIM API](../../../api/scim.md)，它会显示存储在极狐GitLab 中的用户 `extern_uid`，并将其与 SCIM 应用中的用户 `externalId` 进行比较。
  1. 使用相同的 SCIM API 更新 JihuLab.com 上用户的 SCIM `extern_uid`。

<a id="the-members-email-address-is-not-allowed-for-this-group"></a>

## 此群组不允许该成员的电子邮件地址

SCIM 同步可能失败，HTTP 状态为 `412` 并显示以下错误消息：

```plaintext
此群组不允许该成员的电子邮件地址。请与您的管理员核实。
```

当以下两种情况同时存在时，会发生此错误：

- 已为群组配置 [按域限制群组访问](../access_and_permissions.md)。
- 正在配置的用户帐户的电子邮件域不被允许。

要解决此问题，您可以执行以下任一操作：

- 将用户帐户的电子邮件域添加到允许的域列表中。
- 通过移除所有域来禁用 [按域限制群组访问](../access_and_permissions.md) 功能。

<a id="search-rails-logs-for-scim-requests"></a>

## 在 Rails 日志中搜索 SCIM 请求

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

JihuLab.com 管理员可以使用 Kibana 中的 `pubsub-rails-inf-gprd-*` 索引在 `api_json.log` 中搜索 SCIM 请求。根据内部 [群组 SCIM API](../../../development/internal_api/_index.md#group-scim-api) 使用以下过滤器：

- `json.path`: `/scim/v2/groups/<group-path>`
- `json.params.value`: `<externalId>`

在相关的日志条目中，`json.params.value` 显示了极狐GitLab 接收到的 SCIM 参数的值。使用这些值来验证在身份提供商的 SCIM 应用中配置的 SCIM 参数是否按预期传达给了极狐GitLab。

例如，将这些值作为确定帐户为何以特定详细信息集配置的最终来源。这些信息可以帮助查明帐户通过 SCIM 配置的详细信息与 SCIM 应用配置不匹配的情况。

<a id="members-email-address-is-not-linked-error-in-scim-log"></a>

## SCIM 日志中出现成员电子邮件地址未链接错误

当您尝试在 JihuLab.com 上配置 SCIM 用户时，极狐GitLab 会检查是否已存在使用该电子邮件地址的用户。在以下情况下，您可能会看到此错误：

- 用户存在，但未链接 SAML 身份。
- 用户存在，拥有 SAML 身份，**并且** 拥有设置为 `active: false` 的 SCIM 身份。
- 用户存在，但不是关联顶级群组的成员，并且已启用 SAML SSO 强制。

```plaintext
该成员的电子邮件地址未链接到 SAML 帐户或具有不活跃的 SCIM 身份。
```

此错误消息返回的状态为 `412`。

这可能会阻止受影响的最终用户正确访问其帐户。

第一个解决方法是：

1. 让最终用户 [将 SAML 链接到其现有的 JihuLab.com 帐户](_index.md#link-saml-to-your-existing-gitlabcom-account)。
1. 用户完成此操作后，从您的身份提供商发起 SCIM 同步。如果 SCIM 同步完成且未出现相同错误，则极狐GitLab 已成功将 SCIM 身份链接到现有用户帐户，用户现在应该能够使用 SAML SSO 登录。

如果错误仍然存在，则该用户很可能已存在，同时拥有 SAML 和 SCIM 身份，并且 SCIM 身份设置为 `active: false`。要解决此问题：

1. 可选。如果您在首次配置 SCIM 时未保存 SCIM 令牌，请 [生成新令牌](scim_setup.md#configure-gitlab)。如果您生成新的 SCIM 令牌，您 **必须** 更新身份提供商的 SCIM 配置中的令牌，否则 SCIM 将停止工作。
1. 找到您的 SCIM 令牌。
1. 使用 API [获取单个 SCIM 配置用户](../../../development/internal_api/_index.md#get-a-single-scim-provisioned-user)。
1. 检查返回的信息以确保：

   - 用户的标识符 (`id`) 和电子邮件与您的身份提供商发送的内容匹配。
   - `active` 设置为 `false`。

   如果此信息有任何不匹配，请 [联系极狐GitLab 支持](https://support.gitlab.com/)。
1. 使用 API [将 SCIM 配置用户的 `active` 值更新为 `true`](../../../development/internal_api/_index.md#update-a-single-scim-provisioned-user)。
1. 如果更新返回状态码 `204`，让用户尝试使用 SAML SSO 登录。

<a id="azure-active-directory"></a>

## Azure Active Directory

以下故障排查信息专门针对通过 Azure Active Directory 配置的 SCIM。

<a id="verify-my-scim-configuration-is-correct"></a>

### 验证我的 SCIM 配置是否正确

确保：

- `externalId` 的匹配优先级为 1。
- SCIM 中 `externalId` 的值与 SAML 中 `NameId` 的值匹配。

检查以下 SCIM 参数的值是否合理：

- `userName`
- `displayName`
- `emails[type eq "work"].value`

<a id="invalid-credentials-error-when-testing-connection"></a>

### 测试连接时出现 `invalid credentials` 错误

测试连接时，您可能会遇到一个错误：

```plaintext
您似乎输入了无效的凭据。请确认您正在为管理帐户使用正确的信息
```

如果 `Tenant URL` 和 `secret token` 是正确的，请检查您的群组路径是否包含可能被视为无效 JSON 原语的字符（例如 `.`）。移除或对这些字符进行 URL 编码通常可以解决此错误。

<a id="field-cant-be-blank-sync-error"></a>

### `(Field) can't be blank` 同步错误

检查配置的审计事件时，您有时会看到 `Namespace can't be blank, Name can't be blank, and User can't be blank.` 错误。

此错误可能发生，因为并非所有被映射的用户都具备所有必需的字段（例如名字和姓氏）。

作为解决方法，尝试替代映射：

1. 按照 [Azure 映射说明](scim_setup.md#configure-attribute-mappings) 进行操作。
1. 删除 `name.formatted` 目标属性条目。
1. 更改 `displayName` 源属性，使其具有 `name.formatted` 目标属性。

<a id="failed-to-match-an-entry-in-the-source-and-target-systems-group-group-name-error"></a>

### `Failed to match an entry in the source and target systems Group 'Group-Name'` 错误

Azure 中的群组同步可能会失败，并显示 `Failed to match an entry in the source and target systems Group 'Group-Name'` 错误。错误响应可能包含极狐GitLab URL `https://gitlab.com/users/sign_in` 的 HTML 结果。

此错误无害，发生此错误是因为群组同步已开启，但极狐GitLab SCIM 集成不支持也不需要它。要移除此错误，请按照 Azure 配置指南中的说明禁用 [将 Azure Active Directory 组同步到 AppName](scim_setup.md#configure-microsoft-entra-id) 的选项。

<a id="okta"></a>

## Okta

以下故障排查信息专门针对通过 Okta 配置的 SCIM。

<a id="error-authenticating-null-message-when-testing-api-scim-credentials"></a>

### 测试 API SCIM 凭据时出现 `Error authenticating: null` 消息

在您的 Okta SCIM 应用中测试 API 凭据时，您可能会遇到一个错误：

```plaintext
Error authenticating: null
```

Okta 需要能够连接到您的极狐GitLab 实例以配置或取消配置用户。

在您的 Okta SCIM 应用中，检查 SCIM **Base URL** 是否正确并指向有效的极狐GitLab SCIM API 端点 URL。查阅以下文档以查找此 URL 的信息：

- [JihuLab.com 群组](scim_setup.md#configure-gitlab)。
- [私有化部署的极狐GitLab](../../../administration/settings/scim_setup.md#configure-gitlab)。

对于私有化部署的极狐GitLab，请确保您的实例可公开访问，以便 Okta 能够连接到它。如有需要，您可以在防火墙上 [允许访问 Okta IP 地址](https://help.okta.com/en-us/Content/Topics/Security/ip-address-allow-listing.htm)。