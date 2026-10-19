---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 企业用户
description: 通过域名验证和集中式企业管控来管理组织用户。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

企业用户与标准极狐GitLab 用户类似，但由组织进行管理。每个企业用户都由特定的顶级群组认领和管理。要认领企业用户，您必须验证群组域名，并拥有有效的[订阅](../../subscriptions/_index.md)。

如果订阅过期或被取消：

- 任何现有的企业用户仍为该群组中的企业用户。
- 群组所有者无法管理其企业用户。
- 用户账号的主邮箱必须来自已验证的域名。
- 在订阅续订之前，新的企业用户无法与该群组关联。

<a id="manage-group-domains"></a>

## 管理群组域名

要将 JihuLab.com 用户认领为企业用户，您必须添加域名并验证其所有权。群组域名添加到顶级群组，并应用于该群组中的所有子群组和项目。

虽然每个群组可以有多个域名，但每个域名一次只能与一个群组关联。如果您将域名移动到另一个付费群组，所有企业用户都会自动被新群组认领。

群组域名链接到您顶级群组中的一个项目。链接的项目需要启用 [GitLab Pages](../project/pages/_index.md) 才能验证域名，但不需要
创建或部署 GitLab Pages 网站。在 JihuLab.com 上，GitLab Pages 默认对所有项目
启用，因此无需进行任何配置。

尽管域名链接到某个项目，但它可供整个群组层级使用，包括所有嵌套的子群组和项目。链接项目中拥有[维护者或所有者角色](../permissions.md#project-permissions)的成员可以修改或移除该域名。如果此项目被删除，您关联的域名也会被移除。

有关群组域名的更多信息，请参阅[史诗 5299](https://gitlab.com/groups/gitlab-org/-/epics/5299)。

<a id="add-group-domains"></a>

### 添加群组域名

先决条件：

- 您必须拥有顶级群组的所有者角色。
- 您必须控制一个自定义域名 `example.com` 或子域名 `subdomain.example.com`，且与您要验证的邮箱域名匹配。
- 您必须能够为您的域名创建 DNS `TXT` 记录以证明所有权。
- 您必须在顶级群组中拥有一个使用
  [GitLab Pages](../project/pages/_index.md)的专用项目。

要为群组添加自定义域名：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **域名验证**。
1. 在右上角，选择**添加域名**。
1. 配置域名设置：
   - **域名**：输入域名。
   - **项目**：链接到群组中的现有项目。
   - **证书**：选择证书选项：
     - 如果您没有或不想使用 SSL/TLS 证书，请选择
       **使用 Let's Encrypt 自动管理证书**。
     - 如果您想提供自己的 SSL/TLS 证书，请选择
       **手动输入证书信息**。

       > [!note]
       > 域名验证不需要有效证书。如果您不使用 GitLab Pages，
       > 可以忽略自签名证书警告。

1. 选择**添加域名**。
   极狐GitLab 会保存域名信息。
1. 验证域名所有权：
   1. 在 **TXT**中，复制验证码。
   1. 在您的域名提供商 DNS 设置中，将验证码添加为 `TXT` 记录。
   1. 在极狐GitLab 中，在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
   1. 选择**设置** > **域名验证**。
   1. 在域名旁边，选择**重试验证**（{{< icon name="retry" >}}）。

验证成功后，域名状态会变为**已验证**，并可用于企业用户管理。

> [!note]
> 通常，DNS 传播会在几分钟内完成，但最多可能需要 24 小时。
> 在传播完成之前，该域名在极狐GitLab 中会保持未验证状态。
>
> 如果域名在七天后仍未验证，极狐GitLab 会自动移除该域名。
>
> 验证后，极狐GitLab 会定期重新验证该域名。为避免潜在问题，
> 请在您的域名提供商处保留 `TXT` 记录。

<a id="view-group-domains"></a>

### 查看群组域名

要查看群组的所有自定义域名：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **域名验证**。

<a id="edit-group-domains"></a>

### 编辑群组域名

要编辑群组的自定义域名：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **域名验证**。
1. 在域名旁边，选择**编辑**（{{< icon name="pencil" >}}）。

在此处，您可以：

- 查看自定义域名。
- 查看要添加的 DNS 记录。
- 查看 TXT 验证条目。
- 重试验证。
- 编辑证书设置。

<a id="delete-group-domains"></a>

### 删除群组域名

删除群组域名可能会影响您群组中的企业用户。删除域名后：

- 任何现有的企业用户仍为该群组中的企业用户。
- 在验证另一个域名之前，新的企业用户无法与该群组关联。

要删除群组的自定义域名：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **域名验证**。
1. 在域名旁边，选择**移除域名**（{{< icon name="remove" >}}）。
1. 出现提示时，选择**删除域名**。

<a id="manage-enterprise-users"></a>

## 管理企业用户

除了标准的[群组成员权限](../permissions.md#group-permissions)外，顶级群组的所有者还可以管理其群组中的企业用户。

您还可以[使用 API](../../api/group_enterprise_users.md) 与企业用户进行交互。

<a id="automatic-claims-of-enterprise-users"></a>

### 自动认领企业用户

先决条件：

- 顶级群组必须[添加并验证群组域名](#add-group-domains)。
- 用户的主邮箱必须与已验证的域名匹配。
- 用户账号必须至少满足以下条件之一：
  - 用户账号是在 2021 年 2 月 1 日或之后创建的。
  - 用户账号具有与该组织群组绑定的 SAML 或 SCIM 身份。
  - 用户账号具有与群组 ID 匹配的 `provisioned_by_group_id` 属性。
  - 用户账号已经是该群组在 2021 年 2 月 1 日或之后购买或续订的订阅的成员。

群组验证域名所有权后，使用该域名邮箱地址的用户会被该群组自动认领为企业用户。群组所有者无需直接执行任何操作。

任何使用其他域名邮箱地址的现有群组成员会保留其现有访问权限，但无法由群组所有者管理。要认领这些用户，他们必须将其主邮箱地址更新为与您的群组域名匹配。

认领过程最多可能需要四天才会触发。您可以通过手动[重新验证群组域名](#edit-group-domains)立即运行此过程。

群组认领企业用户后：

- 该用户会收到一封[欢迎邮件](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/app/views/notify/user_associated_with_enterprise_group_email.html.haml)。
- 群组 ID 会添加到该用户的 `enterprise_group_id` 属性中。

<a id="identifying-enterprise-users"></a>

### 识别企业用户

您可以从[成员列表](../group/_index.md#filter-and-sort-members-in-a-group)中识别企业用户。所有企业用户的姓名旁边都有一个 `Enterprise` 徽章。

您可以通过分析以下位置的计费用户列表来发现任何非企业群组成员：
`https://gitlab.com/groups/<group_id>/-/usage_quotas#seats-quota-tab`。

在此列表中，非企业用户具有以下情况之一：

- 来自未验证域名的邮箱地址。
- 没有可见的邮箱地址。

<a id="restrict-authentication-methods"></a>

### 限制身份验证方法

您可以限制企业用户可用的特定身份验证方法，这有助于减少用户的安全暴露面。

- [禁用密码身份验证](../group/saml_sso/_index.md#disable-password-and-passkey-authentication-for-enterprise-users)。
- [禁用个人访问令牌](../profile/personal_access_tokens.md#disable-personal-access-tokens-for-enterprise-users)。
- [禁用 SSH 密钥](../ssh_advanced.md#disable-ssh-keys-for-enterprise-users)。
- [禁用双因素认证](../../security/two_factor_authentication.md#enterprise-users)。

<a id="restrict-personal-snippets"></a>

### 限制个人代码片段

您可以阻止企业用户在其个人命名空间中创建[个人代码片段](../snippets.md)。有关更多信息，请参阅[为企业用户限制个人代码片段](../group/manage.md#restrict-personal-snippets-for-enterprise-users)。

<a id="restrict-group-and-project-creation"></a>

### 限制群组和项目创建

您可以限制企业用户创建群组和项目，这有助于您定义：

- 企业用户是否可以创建顶级群组。
- 每个企业用户可以创建的个人项目数量上限。

这些限制在 SAML 响应中定义。有关更多信息，请参阅[从 SAML 响应配置企业用户设置](../group/saml_sso/_index.md#configure-enterprise-user-settings-from-saml-response)。

<a id="bypass-email-confirmation-for-provisioned-users"></a>

### 为预配用户绕过邮箱确认

默认情况下，通过 SAML 或 SCIM 预配的用户会收到一封验证邮件以验证其身份。您可以改为使用自定义域名配置极狐GitLab，极狐GitLab 会自动确认用户账号。用户仍会收到企业用户欢迎邮件。

有关更多信息，请参阅[使用已验证域名绕过用户邮箱确认](../group/saml_sso/_index.md#bypass-user-email-confirmation-with-verified-domains)。

<a id="view-the-email-addresses-for-an-enterprise-user"></a>

### 查看企业用户的邮箱地址

先决条件：

- 您必须拥有顶级群组的所有者角色。

要查看企业用户的邮箱地址：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目或群组。
1. 在左侧边栏中，选择**管理** > **成员**。
1. 将鼠标悬停在企业用户的姓名上。

您还可以使用[群组成员 API](../../api/group_members.md) 和[项目成员 API](../../api/project_members.md) 来访问用户信息。对于群组的企业用户，此信息包括用户的邮箱地址。

<a id="change-the-email-addresses-for-an-enterprise-user"></a>

### 更改企业用户的邮箱地址

企业用户可以按照与其他极狐GitLab 用户相同的流程[更改其主邮箱地址](../profile/_index.md#change-your-primary-email)。新邮箱地址必须来自已验证的域名。如果您的组织没有已验证的域名，您的企业用户将无法更改其主邮箱地址。

群组所有者可以使用[群组企业用户 API](../../api/group_enterprise_users.md#update-an-enterprise-user) 修改其群组中企业用户的邮箱地址。

只有极狐GitLab 支持人员才能将主邮箱地址更改为来自未验证域名的邮箱地址。此操作会[释放该企业用户](#release-an-enterprise-user)。

<a id="delete-an-enterprise-user"></a>

### 删除企业用户

先决条件：

- 您必须拥有顶级群组的所有者角色。

您可以使用[群组企业用户 API](../../api/group_enterprise_users.md#delete-an-enterprise-user) 删除企业用户，并将该账号从极狐GitLab 中永久移除。此操作不同于释放用户，后者仅从用户身上移除企业管理功能。删除用户时，您可以选择：

- 永久删除该用户及其
  [贡献](../profile/account/delete_account.md#associated-records)。
- 保留其贡献并将其转移给幽灵用户。

<a id="release-an-enterprise-user"></a>

### 释放企业用户

您可以从企业用户账号中移除企业管理功能。例如，当用户希望在离开公司后保留其极狐GitLab 账号时，您可能需要这样做。释放用户时，其账号角色和权限保持不变，但群组所有者会失去对该用户的管理选项。例如，被释放的用户可以使用群组所有者之前禁用的身份验证方法。

如果您需要永久移除该账号，请改为[删除该用户](#delete-an-enterprise-user)。

要从您的群组中释放单个企业用户，极狐GitLab 支持人员必须将该用户的主邮箱地址更新为来自未验证域名的邮箱。此操作会自动释放该账号。

要释放所有已认领的企业用户，您可以[删除该群组](../group/_index.md#schedule-a-group-for-deletion)本身，而不是删除群组域名。这对于测试企业用户功能的组织很有用。

允许群组所有者更改主邮箱的建议见[议题 412966](https://gitlab.com/gitlab-org/gitlab/-/issues/412966)。

<a id="dormant-enterprise-user-reactivation"></a>

### 休眠企业用户重新激活

当[自动移除休眠成员](../group/moderate_users.md#automatically-remove-dormant-members)处于活动状态时，休眠的企业用户会被停用，而不是从群组中移除。当这些用户重新登录时，其账号会被重新激活。

但是，当企业群组上启用了[受限访问](../../subscriptions/manage_seats.md#restricted-access)且没有可用席位时，该用户会被设置为待审批，而不是被重新激活。其现有的群组和项目成员资格会保留。

<a id="hide-email-addresses-for-enterprise-users"></a>

### 隐藏企业用户的邮箱地址

群组所有者可以为其群组中所有企业用户隐藏个人资料页面上的公开邮箱地址。所有者仍可[从成员页面查看邮箱地址](#view-the-email-addresses-for-an-enterprise-user)。

先决条件：

- 您必须拥有顶级群组的所有者角色。
- 该群组必须已配置[域名验证](#manage-group-domains)。

要隐藏企业用户的邮箱地址：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**权限和群组功能**。
1. 在**企业用户**下，选中**在公开个人资料中隐藏邮箱地址**复选框。
1. 选择**保存更改**。

<a id="prevent-enterprise-users-from-deleting-their-own-account"></a>

### 阻止企业用户删除自己的账号

群组所有者可以阻止其群组中的企业用户删除自己的账号。禁用此设置后，企业用户无法从其用户设置中删除账号。账号删除部分会显示一条消息，说明不允许删除账号。群组所有者仍可[删除企业用户](#delete-an-enterprise-user)。

先决条件：

- 顶级群组的所有者角色。
- 该群组必须已配置[域名验证](#manage-group-domains)。

要阻止企业用户删除自己的账号：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**权限和群组功能**。
1. 在**企业用户**下，清除**允许企业用户删除自己的账号**复选框。
1. 选择**保存更改**。

<a id="enable-the-extension-marketplace-for-enterprise-users"></a>

### 为企业用户启用扩展市场

VS Code 扩展市场提供对扩展的访问，这些扩展可增强 Web IDE 和工作区的功能。顶级群组所有者可以控制其群组中企业用户对市场的访问。

先决条件：

- 您必须拥有顶级群组的所有者角色。

要为企业用户启用扩展市场：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**权限和群组功能**。
1. 在**企业用户**下，选中**启用扩展市场**复选框。
1. 选择**保存更改**。

<a id="troubleshooting"></a>

## 故障排除

<a id="cannot-disable-two-factor-authentication-for-an-enterprise-user"></a>

### 无法为企业用户禁用双因素认证

如果用户没有 **Enterprise** 徽章，群组所有者无法为其账号禁用或重置 2FA。此时，所有者应告知该企业用户考虑可用的[恢复选项](../profile/account/two_factor_authentication_troubleshooting.md#recovery-options-and-2fa-reset)。
