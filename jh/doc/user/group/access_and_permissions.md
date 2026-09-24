---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure and manage group access and permissions.
title: 群组访问和权限
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

配置您的群组以控制群组权限和访问。
更多信息，请参见[共享项目和群组](../project/members/sharing_projects_groups.md)。

<a id="restrict-git-access-protocols"></a>

## 限制 Git 访问协议

{{< history >}}

- 在极狐GitLab 15.1 中引入。
- 在极狐GitLab 16.0 中移除了功能标志。

{{< /history >}}

您可以设置用于访问群组仓库的允许协议，可以是 SSH、HTTPS 或两者。当管理员配置了[实例设置](../../administration/settings/visibility_and_access_controls.md#configure-enabled-git-access-protocols)时，此设置将被禁用。

要更改群组的允许 Git 访问协议：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **权限和群组功能** 部分。
1. 从 **启用的 Git 访问协议** 中选择允许的协议。
1. 选择 **保存更改**。

<a id="restrict-group-access-by-ip-address"></a>

## 按 IP 地址限制群组访问

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

为确保只有您组织的人员可以访问特定资源，您可以按 IP 地址限制对群组的访问。此顶级群组设置适用于：

- 极狐GitLab UI，包括子群组、项目和议题。不适用于极狐GitLab Pages。
- API。
- 在私有化部署的极狐GitLab 上，您还可以为群组配置[全局允许的 IP 地址范围](../../administration/settings/visibility_and_access_controls.md#configure-globally-allowed-ip-address-ranges)。

管理员可以将按 IP 地址限制访问与[全局允许的 IP 地址](../../administration/settings/visibility_and_access_controls.md#configure-globally-allowed-ip-address-ranges)结合使用。

> [!warning]
> IP 限制需要正确配置 `X-Forwarded-For` 头部。为了降低 IP 欺骗的风险，您必须覆盖，而不是追加，客户端发送的任何 `X-Forwarded-For` 头部。
>
> 对于没有上游代理或负载均衡器的部署，配置接收用户直接请求的服务器以保留原始客户端 IP 地址并覆盖任何 `X-Forwarded-For` 头部。例如，在 NGINX 中，修改您的配置文件以包含：
>
> ```plaintext
> proxy_set_header X-Forwarded-For $remote_addr;
> ```
>
> 对于有上游代理或负载均衡器的部署，配置代理或负载均衡器以保留原始客户端 IP 地址并覆盖任何 `X-Forwarded-For` 头部。这种方法确保极狐GitLab 接收到从原始客户端开始的完整 IP 链，并能正确评估 IP 限制。例如，在 NGINX 中，修改您的配置文件以包含：
>
> ```plaintext
> proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
> ```

要按 IP 地址限制群组访问：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **权限和群组功能** 部分。
1. 在 **按 IP 地址限制访问** 文本框中，输入 CIDR 表示法的 IPv4 或 IPv6 地址范围列表：

   ```txt
   192.168.1.0/24
   10.0.0.0/8
   2001:db8::/32
   203.0.113.5/32
   ```

   您必须手动添加每个 IP 地址条目。不支持使用逗号或空格分隔添加多个条目。批量条目支持在[议题 468998](https://jihulab.com/gitlab-cn/gitlab/-/work_items/468998) 中提出。

   此列表：
   - 对 IP 地址范围的数量没有限制。
   - 适用于 SSH 或 HTTP 授权的 IP 地址范围。您不能按授权类型拆分此列表。
1. 选择 **保存更改**。

<a id="security-implications"></a>

### 安全影响

IP 访问限制限制了对群组和项目的访问，但并非完整的防火墙。
虽然此功能通常限制对群组和项目资源的访问，但某些信息可能仍可被受限用户访问。从不允许的 IP 地址访问极狐GitLab 时，请记住以下（非详尽）安全影响列表：

- 管理员和群组所有者始终可以访问群组设置。
- 管理员始终可以访问群组中的项目。这包括克隆代码。
- 群组所有者始终可以访问子群组，但不能访问群组或子群组中的任何项目。
- 用户始终可以访问共享资源。
- 用户始终可以查看群组和项目的名称和层次结构。
- 用户始终可以使用[通过电子邮件回复功能](../../administration/reply_by_email.md)在议题或合并请求上创建和编辑评论。
- 用户有时可以在其仪表板上查看推送、合并、议题或评论事件。
- IP 限制始终适用于公共项目，但缓存的项目文件有时可能可访问。
- IP 限制始终适用于通过 SSH 在 JihuLab.com 上的 Git 操作。
  私有化部署实例应使用启用了 [PROXY 协议](../../administration/operations/gitlab_sshd.md#proxy-protocol-support) 的 `gitlab-sshd`。
- IP 限制始终适用于 CI/CD 作业执行的 Git 克隆操作。
- IP 限制不适用于 Runner 注册或 Runner 请求或更新 CI/CD 作业时。
- IP 限制可能不适用于派生的项目或间接与 IP 限制群组中的议题或产物交互的操作。例如，在合并请求描述中使用议题引用关闭 IP 限制群组中议题的合并请求。
- IP 限制适用于项目和群组访问令牌、服务帐户、部署密钥和部署令牌。

<a id="gitlab-com-access-restrictions"></a>

### JihuLab.com 访问限制

基于 IP 地址的群组访问限制不适用于 [JihuLab.com 的托管 Runner](../../ci/runners/hosted_runners/_index.md)。这些 Runner 作为临时虚拟机运行，具有来自大型云提供商池（AWS、Google Cloud）的[动态 IP 地址](../jihulab_com/_index.md#ip-range)。允许这些广泛的 IP 范围违背了基于 IP 地址的访问限制的目的。

<a id="restrict-group-access-by-domain"></a>

## 按域限制群组访问

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.1.1 中，添加了对将群组成员限制为具有允许电子邮件域子集的群组的支持。

{{< /history >}}

您可以在顶级命名空间定义电子邮件域允许列表，以限制哪些用户可以访问群组及其项目。用户的主要电子邮件域必须与允许列表中的条目匹配才能访问该群组。子群组继承相同的允许列表。

要按域限制群组访问：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **权限和群组功能** 部分。
1. 在 **按电子邮件域限制成员** 文本框中，输入允许的域名。
1. 选择 **保存更改**。

下次您尝试将用户添加到群组时，他们的[主要电子邮件](../profile/_index.md#change-your-primary-email)必须与允许的域之一匹配。

您不能使用最流行的公共电子邮件域进行限制，例如：

- `aol.com`、`gmail.com`、`hotmail.co.uk`、`hotmail.com`、
- `hotmail.fr`、`icloud.com`、`live.com`、`mail.com`、
- `me.com`、`msn.com`、`outlook.com`、
- `proton.me`、`protonmail.com`、`tutanota.com`、
- `yahoo.com`、`yandex.com`、`zohomail.com`

当您共享群组时，源命名空间和目标命名空间都必须允许成员电子邮件地址的域。

> [!note]
> 从 **按电子邮件域限制成员** 列表中删除域不会从群组或其项目中移除具有该域的现有用户。
> 此外，如果您与另一个群组共享群组或项目，目标群组可以向其列表中添加更多不在源群组列表中的电子邮件域。
> 因此，此功能不能确保当前成员始终符合 **按电子邮件域限制成员** 列表。

<a id="prevent-users-from-requesting-access-to-a-group"></a>

## 阻止用户请求访问群组

作为群组所有者，您可以阻止非成员请求访问您的群组。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **权限和群组功能** 部分。
1. 清除 **允许用户请求访问** 复选框。
1. 选择 **保存更改**。

> [!note]
> 禁用 **允许用户请求访问** 设置会阻止新的访问请求。
> 现有的待处理请求不会被移除，仍然可以批准或拒绝。

<a id="prevent-project-forking-outside-group"></a>

## 阻止在群组外派生项目

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

默认情况下，群组中的项目可以被派生。但是，您可以阻止群组中的项目在当前顶级群组之外被派生。

> [!note]
> 尽可能阻止在顶级群组外派生，以减少恶意行为者的潜在途径。
> 但是，如果您预期会有大量外部协作，允许在顶级群组外派生可能不可避免。

先决条件：

- 此设置仅在顶级群组上启用。
- 所有子群组从顶级群组继承此设置，并且不能在子群组级别更改。

要阻止项目在群组外被派生：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **权限和群组功能** 部分。
1. 选中 **阻止在当前群组外派生项目**。
1. 选择 **保存更改**。

现有派生不会被移除。

<a id="prevent-members-from-being-added-to-projects-in-a-group"></a>

## 阻止将成员添加到群组中的项目

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

作为群组所有者，您可以阻止群组中所有项目的任何新项目成员，从而更严格地控制项目成员。

例如，如果您想为[审计事件](../../administration/compliance/audit_event_reports.md)锁定群组，您可以保证在审计期间无法修改项目成员。

如果启用了群组成员锁定，群组所有者仍然可以：

- 邀请群组或将成员添加到群组，以授予他们对 **锁定** 群组中项目的访问权限。
- 更改群组成员的角色。

此设置不会级联。子群组中的项目遵循子群组配置，忽略父群组。

要阻止将成员添加到群组中的项目：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **权限和群组功能** 部分。
1. 在 **成员** 下，选择 **用户无法被添加到此群组中的项目**。
1. 选择 **保存更改**。

锁定群组成员后：

- 所有之前拥有权限的用户都无法再将成员添加到群组。
- 无法通过 API 请求将新用户添加到项目。

<a id="manage-group-memberships-with-ldap"></a>

## 使用 LDAP 管理群组成员

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.2 中，引入了对群组中同步用户的自定义角色的支持。

{{< /history >}}

群组同步允许将 LDAP 群组映射到极狐GitLab 群组。这提供了对每个群组用户管理的更多控制。要配置群组同步，请编辑 `group_base` **DN** (`'OU=Global Groups,OU=GitLab INT,DC=GitLab,DC=org'`)。此 **OU** 包含与极狐GitLab 群组关联的所有群组。

可以使用 CN 或过滤器创建群组链接。要创建这些群组链接，请转到群组的 **设置** > **LDAP 同步** 页面。配置链接后，用户与极狐GitLab 群组同步可能需要一个多小时。配置链接后：

- 在极狐GitLab 16.7 及更早版本中，群组所有者无法向群组添加成员或从群组中移除成员。LDAP 服务器被视为所有使用 LDAP 凭据登录的用户的群组成员身份的唯一真实来源。
- 在极狐GitLab 16.8 及更高版本中，即使为群组启用了 LDAP 同步，群组所有者也可以使用[成员角色 API](../../api/member_roles.md) 或[群组成员 API](../../api/group_members.md#add-a-group-member) 向群组添加服务帐户用户或从群组中移除服务帐户用户。群组所有者无法添加或移除非服务帐户用户。

当用户属于为同一极狐GitLab 群组配置的多个 LDAP 群组时，极狐GitLab 会为其分配两个关联角色中较高的一个。例如：

- 用户是 LDAP 群组 `Owner` 和 `Dev` 的成员。
- 极狐GitLab 群组配置了这两个 LDAP 群组。
- 当群组同步完成时，用户被授予 `Owner` 角色，因为这是两个 LDAP 群组角色中较高的一个。

对于自定义角色，当角色具有不同的基本访问级别时，同样的逻辑适用。例如：

- 如果用户是 LDAP 群组 `Developer` 和 `Developer + admin_vulnerability` 的成员
- 用户被授予 `Developer + admin_vulnerability`，因为这是两个 LDAP 群组角色中较高的一个。

当两个自定义角色共享相同的基本访问级别时，极狐GitLab 无法仅通过排名确定更高的角色。相反，最早创建的群组链接中的自定义角色优先。例如：

- 如果用户是 LDAP 群组 `Developer + admin_vulnerability` 和 `Developer + admin_merge_request` 的成员
- 两个角色共享 `Developer` 基本访问级别。
- 用户被授予最早创建的 LDAP 群组链接的角色。

有关 LDAP 和群组同步管理的更多信息，请参阅[主要 LDAP 文档](../../administration/auth/ldap/ldap_synchronization.md#group-sync)。

> [!note]
> 添加 LDAP 群组同步时，如果 LDAP 用户是群组成员但不在 LDAP 群组中，他们将被从群组中移除。

您可以使用一种变通方法[通过 LDAP 群组管理项目访问](../project/working_with_projects.md#manage-project-access-through-ldap-groups)。

<a id="create-group-links-with-a-cn"></a>

### 使用 CN 创建群组链接

要使用 LDAP 群组 CN 创建群组链接：

<!-- vale gitlab_base.Spelling = NO -->

1. 选择链接的 **LDAP 服务器**。
1. 作为 **同步方法**，选择 `LDAP 群组 cn`。
1. 在 **LDAP 群组 cn** 字段中，开始输入群组的 CN。会有一个下拉列表，其中包含配置的 `group_base` 中匹配的 CN。从此列表中选择您的 CN。
1. 在 **LDAP 访问** 部分，为此群组中同步的用户选择一个[默认角色](../permissions.md)或[自定义成员角色](../custom_roles/_index.md)。
1. 选择 **添加同步**。

极狐GitLab 开始将角色链接到任何匹配的 LDAP 用户。此过程可能需要一个多小时才能完成。

<!-- vale gitlab_base.Spelling = YES -->

<a id="create-group-links-with-a-filter"></a>

### 使用过滤器创建群组链接

要使用 LDAP 用户过滤器创建群组链接：

1. 选择链接的 **LDAP 服务器**。
1. 作为 **同步方法**，选择 `LDAP 用户过滤器`。
1. 在 **LDAP 用户过滤器** 框中输入您的过滤器。遵循[用户过滤器文档](../../administration/auth/ldap/_index.md#set-up-ldap-user-filter)。
1. 在 **LDAP 访问** 部分，为此群组中同步的用户选择一个[默认角色](../permissions.md)或[自定义成员角色](../custom_roles/_index.md)。
1. 选择 **添加同步**。

极狐GitLab 开始将角色链接到任何匹配的 LDAP 用户。此过程可能需要一个多小时才能完成。

<a id="remove-group-links"></a>

### 移除群组链接

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **活动同步**。
1. 识别您要移除的群组链接并选择 **移除**。

> [!note]
> 移除 LDAP 群组同步时，现有的成员身份和角色分配将保留。

<a id="override-user-permissions"></a>

### 覆盖用户权限

LDAP 用户权限可以由管理员手动覆盖。要覆盖用户权限：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **管理** > **成员**。如果 LDAP 同步已授予用户一个角色：
   - 权限多于父群组成员身份，该用户显示为具有群组的[直接成员身份](../project/members/_index.md#display-direct-members)。
   - 权限与父群组成员身份相同或更少，该用户显示为具有群组的[继承成员身份](../project/members/_index.md#membership-types)。
1. 可选。如果您要编辑的用户显示为具有继承成员身份，请在覆盖 LDAP 用户权限之前[过滤子群组以显示直接成员](_index.md#filter-a-group)。
1. 在您要编辑的用户行中，选择铅笔 ({{< icon name="pencil" >}}) 图标。
1. 在对话框中选择 **编辑权限**。

现在，您可以从 **成员** 页面编辑用户的权限。

<a id="set-the-default-role-that-can-use-pipeline-variables"></a>

## 设置可以使用流水线变量的默认角色

{{< history >}}

- 在极狐GitLab 17.10 中引入。

{{< /history >}}

此群组设置控制[允许使用流水线变量运行新流水线的最低角色](../../ci/variables/_index.md#restrict-pipeline-variables)项目设置的默认值。在群组中创建的新项目默认选择此值。

先决条件：

- 您必须在群组中具有维护者或所有者角色。
- 群组必须是顶级群组，而不是子群组。

要设置默认最低角色：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **CI/CD** > **变量**。
1. 在 **使用流水线变量的默认角色** 下选择一个最低角色，或选择 **不允许任何人** 以阻止任何用户使用流水线变量。
1. 选择 **保存更改**。

创建新项目后，具有维护者或所有者角色的项目成员可以根据需要将项目设置更改为其他值。

<a id="troubleshooting"></a>

## 故障排除

<a id="verify-if-access-is-blocked-by-ip-restriction"></a>

### 验证访问是否被 IP 限制阻止

如果用户在尝试访问特定群组时看到 404 错误，他们的访问可能被 IP 限制阻止。

在 `auth.log` Rails 日志中搜索以下一个或多个条目：

- `json.message`: `'Attempting to access IP restricted group'`
- `json.allowed`: `false`

在查看日志条目时，将 `remote.ip` 与群组的[允许的 IP 地址列表](#restrict-group-access-by-ip-address)进行比较。

<a id="cannot-update-permissions-for-a-group-member"></a>

### 无法更新群组成员权限

如果群组所有者无法更新群组成员的权限，请检查列出了哪些成员身份。群组所有者只能更新直接成员身份。

直接添加到子群组的成员如果在父群组中具有相同或更高的角色，仍被视为[继承成员](../project/members/_index.md#membership-types)。

要查看和更新直接成员身份，请[过滤群组以显示直接成员](_index.md#filter-a-group)。

[议题 337539](https://jihulab.com/gitlab-cn/gitlab/-/issues/337539#note_1277786161) 提出了重新设计的成员页面，该页面列出直接和间接成员身份，并能够按类型过滤。

<a id="cannot-clone-or-pull-using-ssh-after-enabling-ip-restrictions"></a>

### 启用 IP 限制后无法使用 SSH 克隆或拉取

如果在添加 IP 地址限制后遇到 Git SSH 操作问题，请检查您的连接是否默认使用 IPv6。

某些操作系统在两者都可用时优先使用 IPv6 而不是 IPv4，这在 Git 终端反馈中可能不明显。

如果您的连接使用 IPv6，您可以通过将 IPv6 地址添加到允许列表来解决此问题。