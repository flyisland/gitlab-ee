---
stage: 软件供应链安全
group: 认证
info: 要确定与此页面关联的阶段/群组的技术文档作者，请参阅 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 企业用户
description: 通过域名验证和集中式企业控制来管理组织用户。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

企业用户与标准极狐GitLab 用户类似，但由组织进行管理。
每个企业用户都由特定的顶级群组声明和管理。要声明企业用户，你必须验证群组域名并拥有有效的[订阅许可](../../subscriptions/_index.md)。

如果订阅许可过期或被取消：

- 任何现有企业用户将仍然保留为群组中的企业用户。
- 群组所有者无法管理他们的企业用户。
- 用户帐户的主邮箱必须来自已验证的域名。
- 在续订订阅许可之前，新的企业用户无法与群组关联。

<a id="manage-group-domains"></a>

## 管理群组域名

要将 JihuLab.com 用户声明为企业用户，你必须添加并验证域名的所有权。
群组域名被添加到顶级群组，并应用于群组中的所有子群组和项目。

虽然每个群组可以有多个域名，但一个域名一次只能关联一个群组。如果你将域名转移到另一个付费群组，所有企业用户将自动被新群组声明。

群组域名会链接到你顶级群组中的一个项目。该链接项目需要启用[极狐GitLab Pages](../project/pages/_index.md) 来验证域名，但不需要创建或部署极狐GitLab Pages 站点。在 JihuLab.com 上，极狐GitLab Pages 默认对所有项目启用，因此无需配置。

尽管域名链接到项目，但它对整个群组层级结构（包括所有嵌套子群组和项目）都可用。链接项目中具有[维护者或所有者角色](../permissions.md#project-permissions)的成员可以修改或删除该域名。如果此项目被删除，你关联的域名也会被移除。

有关群组域名的更多信息，请参阅史诗 5299。

<a id="add-group-domains"></a>

### 添加群组域名

先决条件：

- 你必须拥有顶级群组的所有者角色。
- 你必须控制与要验证的邮箱域名匹配的自定义域名 `example.com` 或子域名 `subdomain.example.com`。
- 你必须能够为你的域名创建 DNS `TXT` 记录以证明所有权。
- 你必须在顶级群组中拥有一个使用[极狐GitLab Pages](../project/pages/_index.md) 的专用项目。

为群组添加自定义域名：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **域名验证**。
1. 在右上角，选择 **添加域名**。
1. 配置域名设置：
   - **域名**：输入域名。
   - **项目**：链接到群组中的现有项目。
   - **证书**：选择证书选项：
     - 如果你没有或不想使用 SSL/TLS 证书，请选择 **使用 Let's Encrypt 自动管理证书**。
     - 如果你想提供自己的 SSL/TLS 证书，请选择 **手动输入证书信息**。你也可以稍后添加证书和密钥。

       > [!note]
       > 域名验证不需要有效证书。如果你不使用极狐GitLab Pages，可以忽略自签名证书警告。

1. 选择 **添加域名**。
   极狐GitLab 会保存域名信息。
1. 验证域名所有权：
   1. 在 **TXT** 中，复制验证代码。
   1. 在你的域名提供商 DNS 设置中，将验证代码添加为 `TXT` 记录。
   1. 在极狐GitLab 中，在顶部栏选择 **搜索或跳转到** 并找到你的群组。
   1. 选择 **设置** > **域名验证**。
   1. 在域名旁边，选择 **重试验证** ({{< icon name="retry" >}})。

验证成功后，域名状态将变为 **已验证**，并可用于企业用户管理。

> [!note]
> 通常，DNS 传播会在几分钟内完成，但最长可能需要 24 小时。
> 在此之前，该域名在极狐GitLab 中将保持未验证状态。
>
> 如果七天后域名仍未验证，极狐GitLab 会自动删除该域名。
>
> 验证后，极狐GitLab 会定期重新验证域名。为避免潜在问题，
> 请在你的域名提供商处保留 `TXT` 记录。

<a id="view-group-domains"></a>

### 查看群组域名

查看群组的所有自定义域名：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **域名验证**。

<a id="edit-group-domains"></a>

### 编辑群组域名

编辑群组的自定义域名：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **域名验证**。
1. 在域名旁边，选择 **编辑** ({{< icon name="pencil" >}})。

在这里，你可以：

- 查看自定义域名。
- 查看要添加的 DNS 记录。
- 查看 TXT 验证条目。
- 重试验证。
- 编辑证书设置。

<a id="delete-group-domains"></a>

### 删除群组域名

删除群组域名可能会影响你群组中的企业用户。删除域名后：

- 任何现有企业用户将仍然保留为群组中的企业用户。
- 在验证其他域名之前，新的企业用户无法与群组关联。

删除群组的自定义域名：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **域名验证**。
1. 在域名旁边，选择 **删除域名** ({{< icon name="remove" >}})。
1. 出现提示时，选择 **删除域名**。

<a id="manage-enterprise-users"></a>

## 管理企业用户

除了标准的[群组成员权限](../permissions.md#group-permissions)外，顶级群组的所有者还可以管理其群组中的企业用户。

你也可以[使用 API](../../api/group_enterprise_users.md) 与企业用户交互。

<a id="automatic-claims-of-enterprise-users"></a>

### 自动声明企业用户

先决条件：

- 顶级群组必须[添加并验证群组域名](#add-group-domains)。
- 用户帐户必须满足以下至少一项条件：
  - 用户帐户的主邮箱必须来自已验证的域名。
  - 用户帐户创建于 2021 年 2 月 1 日或之后。
  - 用户帐户具有与组织群组绑定的 SAML 或 SCIM 身份。
  - 用户帐户具有与群组 ID 匹配的 `provisioned_by_group_id` 属性。
  - 用户帐户已经是于 2021 年 2 月 1 日或之后购买或续订的群组订阅许可的成员。

群组验证域名所有权后，来自该域名的邮箱地址的用户将自动被群组声明为企业用户。群组所有者无需直接操作。

任何拥有来自不同域名的邮箱地址的现有群组成员将保留其现有访问权限，但不能由群组所有者管理。要声明这些用户，他们必须更新其主邮箱地址以匹配你的群组域名。

声明过程可能需要最多四天才能触发。你可以通过手动[重新验证群组域名](#edit-group-domains)来立即运行此过程。

群组声明企业用户后：

- 用户会收到一封[欢迎邮件](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/app/views/notify/user_associated_with_enterprise_group_email.html.haml)。
- 群组 ID 会被添加到用户的 `enterprise_group_id` 属性中。

<a id="identifying-enterprise-users"></a>

### 识别企业用户

你可以从[成员列表](../group/_index.md#filter-and-sort-members-in-a-group)中识别企业用户。
所有企业用户在其姓名旁边都有一个 `Enterprise` 徽章。

你可以通过分析 `https://gitlab.com/groups/<group_id>/-/usage_quotas#seats-quota-tab` 上的可计费用户列表来发现任何非企业群组成员。

从此列表中，非企业用户具有以下情况之一：

- 来自未验证域名的邮箱地址。
- 无可见邮箱地址。

<a id="restrict-authentication-methods"></a>

### 限制认证方法

你可以限制企业用户可用的特定认证方法，这有助于减少用户的安全足迹。

- [禁用密码认证](../group/saml_sso/_index.md#disable-password-and-passkey-authentication-for-enterprise-users)。
- [禁用个人访问令牌](../profile/personal_access_tokens.md#disable-personal-access-tokens-for-enterprise-users)。
- [禁用 SSH 密钥](../ssh_advanced.md#disable-ssh-keys-for-enterprise-users)。
- [禁用双因素认证](../../security/two_factor_authentication.md#enterprise-users)。

<a id="restrict-personal-snippets"></a>

### 限制个人代码片段

你可以阻止企业用户在其个人命名空间中创建[个人代码片段](../snippets.md)。更多信息，请参阅
[限制企业用户创建个人代码片段](../group/manage.md#restrict-personal-snippets-for-enterprise-users)。

<a id="restrict-group-and-project-creation"></a>

### 限制群组和项目创建

你可以限制企业用户创建群组和项目，这有助于你定义：

- 企业用户是否可以创建顶级群组。
- 每个企业用户可以创建的最大个人项目数量。

这些限制在 SAML 响应中定义。更多信息，请参阅
[从 SAML 响应配置企业用户设置](../group/saml_sso/_index.md#configure-enterprise-user-settings-from-saml-response)。

<a id="bypass-email-confirmation-for-provisioned-users"></a>

### 跳过已配置用户的邮箱确认

默认情况下，通过 SAML 或 SCIM 配置的用户会收到一封验证邮件以确认其身份。或者，你可以为极狐GitLab 配置自定义域名，极狐GitLab 将自动确认用户帐户。用户仍会收到一封企业用户欢迎邮件。

更多信息，请参阅[通过已验证域名跳过用户邮箱确认](../group/saml_sso/_index.md#bypass-user-email-confirmation-with-verified-domains)。

<a id="view-the-email-addresses-for-an-enterprise-user"></a>

### 查看企业用户的邮箱地址

先决条件：

- 你必须拥有顶级群组的所有者角色。

查看企业用户的邮箱地址：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏中，选择 **管理** > **成员**。
1. 将鼠标悬停在该企业用户的姓名上。

你也可以使用[群组成员 API](../../api/group_members.md) 和[项目成员 API](../../api/project_members.md) 来访问用户信息。对于群组的企业用户，此信息包括用户的邮箱地址。

<a id="change-the-email-addresses-for-an-enterprise-user"></a>

### 更改企业用户的邮箱地址

企业用户可以遵循与其他极狐GitLab 用户相同的流程来[更改其主邮箱地址](../profile/_index.md#change-your-primary-email)。
新的邮箱地址必须来自已验证的域名。如果你的组织没有已验证的域名，你的企业用户将无法更改其主邮箱地址。

群组所有者可以使用[群组企业用户 API](../../api/group_enterprise_users.md#update-an-enterprise-user) 修改其群组中企业用户的邮箱地址。

只有极狐GitLab 支持人员可以将主邮箱地址更改为来自未验证域名的邮箱地址。此操作会[释放企业用户](#release-an-enterprise-user)。

<a id="delete-an-enterprise-user"></a>

### 删除企业用户

先决条件：

- 你必须拥有顶级群组的所有者角色。

你可以使用[群组企业用户 API](../../api/group_enterprise_users.md#delete-an-enterprise-user) 删除企业用户并从极狐GitLab 中永久删除其帐户。此操作不同于释放用户，释放用户仅从用户身上移除企业管理功能。删除用户时，你可以选择：

- 永久删除用户及其[贡献](../profile/account/delete_account.md#associated-records)。
- 保留其贡献并将其转移给一个幽灵用户。

<a id="release-an-enterprise-user"></a>

### 释放企业用户

你可以从企业用户帐户中移除企业管理功能。例如，当用户希望在离开公司后保留其极狐GitLab 帐户时，你可能需要这样做。释放用户时，其帐户角色和权限保持不变，但群组所有者将失去对该用户的管理选项。例如，被释放的用户可以访问群组所有者先前禁用的认证方法。

如果你需要永久删除帐户，请改为[删除用户](#delete-an-enterprise-user)。

要从群组中释放单个企业用户，极狐GitLab 支持人员必须将该用户的主邮箱地址更新为来自未验证域名的邮箱地址。此操作会自动释放该帐户。

要释放所有已声明的企业用户，你可以[删除群组本身](../group/_index.md#schedule-a-group-for-deletion) 而不是群组域名。这对于正在测试企业用户功能的组织非常有用。

允许群组所有者更改主邮箱地址的功能已在议题 412966 中提出。

<a id="dormant-enterprise-user-reactivation"></a>

### 休眠企业用户重新激活

当[自动移除休眠成员](../group/moderate_users.md#automatically-remove-dormant-members)功能处于活动状态时，休眠的企业用户会被停用而非从群组中移除。当这些用户重新登录时，他们的帐户会被重新激活。

但是，当企业群组上启用[受限访问](../group/manage.md#restricted-access)且无可用席位时，用户将被设置为待审批而非重新激活。他们现有的群组和项目成员资格将被保留。

<a id="hide-email-addresses-for-enterprise-users"></a>

### 隐藏企业用户的邮箱地址

{{< history >}}

- [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/197475)于极狐GitLab 18.3。

{{< /history >}}

群组所有者可以为群组中所有企业用户在其个人资料页面中隐藏公开邮箱地址。所有者仍然可以[从成员页面查看邮箱地址](#view-the-email-addresses-for-an-enterprise-user)。

先决条件：

- 你必须拥有顶级群组的所有者角色。
- 群组必须配置了[域名验证](#manage-group-domains)。

隐藏企业用户的邮箱地址：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **权限和群组功能**。
1. 在 **企业用户** 下，勾选 **在公开个人资料中隐藏邮箱地址** 复选框。
1. 选择 **保存更改**。

<a id="enable-the-extension-marketplace-for-enterprise-users"></a>

### 为企业用户启用扩展市场

{{< history >}}

- [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/161819)于极狐GitLab 17.4，作为一个[测试版](../../policy/development_stages_support.md#beta)功能，受名为 `web_ide_oauth` 和 `web_ide_extensions_marketplace` 的[功能标志](../../administration/feature_flags/_index.md)控制。默认禁用。
- `web_ide_oauth` 于极狐GitLab 17.4 [在 JihuLab.com 和私有化部署上启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/163181)。
- `web_ide_extensions_marketplace` 于极狐GitLab 17.4 [在 JihuLab.com 上启用](https://gitlab.com/gitlab-org/gitlab/-/issues/459028)。
- `web_ide_oauth` 于极狐GitLab 17.5 [移除](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/167464)。
- `vscode_extension_marketplace_settings` [功能标志](../../administration/feature_flags/_index.md)于极狐GitLab 17.10 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/508996)。默认禁用。
- `web_ide_extensions_marketplace` [在私有化部署上启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/184662)，并且 `vscode_extension_marketplace_settings` [于 JihuLab.com 和私有化部署上启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/184662)于极狐GitLab 17.11。
- [GA](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/192659)于极狐GitLab 18.1。功能标志 `web_ide_extensions_marketplace` 和 `vscode_extension_marketplace_settings` 已移除。

{{< /history >}}

VS Code 扩展市场提供了可增强 Web IDE 和工作区功能的扩展。顶级群组所有者可以控制其群组中企业用户对市场的访问权限。

先决条件：

- 你必须拥有顶级群组的所有者角色。

为企业用户启用扩展市场：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **权限和群组功能**。
1. 在 **企业用户** 下，勾选 **启用扩展市场** 复选框。
1. 选择 **保存更改**。

## 故障排除

<a id="cannot-disable-two-factor-authentication-for-an-enterprise-user"></a>

### 无法为企业用户禁用双因素认证

如果用户没有 **Enterprise** 徽章，群组所有者将无法禁用或重置其帐户的双因素认证。相反，所有者应告知企业用户考虑可用的[恢复选项](../profile/account/two_factor_authentication_troubleshooting.md#recovery-options-and-2fa-reset)。

## 相关主题

- [极狐GitLab Pages 自定义域名](../project/pages/custom_domains_ssl_tls_certification/_index.md)。