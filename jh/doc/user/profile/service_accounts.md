---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 服务账号
description: 为自动化流程和第三方服务集成创建非人类账号。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

服务账号是代表非人类实体而非具体个人的用户账号。使用服务账号执行自动化操作、访问数据或运行计划任务。服务账号通常用于流水线或第三方集成，在这些场景中，无论您的团队成员如何变动，凭据都必须保持稳定。

服务账号使用[个人访问令牌](personal_access_tokens.md)进行身份验证。
它们可以与[软件包和容器镜像仓库](../packages/_index.md)交互、
执行 [Git 操作](personal_access_tokens.md#clone-repository-using-personal-access-token)，
并访问 API。

服务账号具有以下特征：

- 它们不占用席位。
- 它们不是[计费用户](../../subscriptions/manage_seats.md#billable-users)或[内部用户](../../administration/internal_users.md)。
- 它们始终被标记为[外部用户](../../administration/external_users.md)。
- 它们无法通过 UI 登录极狐GitLab。
- 它们无法通过 LDAP 等服务进行管理。
- 当由子群组或项目预配时，它们无法创建顶级群组或其他服务账号。
- 它们会在群组和项目成员列表中显示为服务账号，而不是普通用户。
- 除非您添加[自定义电子邮件地址](../../api/service_accounts.md#create-an-instance-service-account)，否则它们不会收到通知邮件。
- 它们可用于极狐GitLab 的[试用版本](https://jihulab.com/-/trial_registrations/new?glm_source=docs.gitlab.com&glm_content=free-user-limit-faq/ee/user/free_user_limit.html)。
  在 JihuLab.com 上，顶级群组的所有者必须先验证其身份。

您还可以通过[服务账号 API](../../api/service_accounts.md) 管理服务账号。
要管理服务账号的 SSH 密钥，请使用[用户 SSH 和 GPG 密钥 API](../../api/user_keys.md)。您
无法通过极狐GitLab UI 管理 SSH 密钥。

您可以创建的服务账号数量取决于您的订阅和交付方式：

- 在极狐GitLab 专业版和旗舰版上，您可以为所有交付方式创建无限数量的服务账号。
- 在极狐GitLab 基础版上，限制因交付方式而异：
  - 对于 JihuLab.com，您可以为每个顶级群组创建最多 100 个服务账号。
    这包括在子群组或项目中创建的服务账号。
  - 对于极狐GitLab 私有化部署，您可以为整个实例创建最多 100 个服务账号。
    这包括在实例、群组或项目级别创建的服务账号。

<a id="types-of-service-accounts"></a>

## 服务账号的类型

服务账号有三种类型，每种类型具有不同的范围和先决条件：

{{< tabs >}}

{{< tab title="实例服务账号" >}}

实例服务账号通过管理区域创建，可以邀请加入实例上的任何群组或
项目。

先决条件：

- 对实例具有管理员访问权限。

{{< /tab >}}

{{< tab title="群组服务账号" >}}

群组服务账号由特定群组创建，可以邀请加入创建它们的群组，或加入任何后代子群组或项目。它们无法创建顶级群组或
服务账号。

先决条件：

- 在 JihuLab.com 上，您必须拥有该群组的所有者角色。
- 在极狐GitLab 私有化部署上，您必须满足以下任一条件：
  - 是实例的管理员。
  - 在群组中拥有所有者角色，并且[被允许创建服务账号](../../administration/settings/account_and_limit_settings.md#allow-top-level-group-owners-to-create-service-accounts)。

{{< /tab >}}

{{< tab title="项目服务账号" >}}

项目服务账号由特定项目创建，仅对该项目可用。
它们无法创建顶级群组或服务账号。

先决条件：

- 在 JihuLab.com 上，您必须拥有该项目的维护者或所有者角色。
- 在极狐GitLab 私有化部署上，您必须满足以下任一条件：
  - 是实例的管理员。
  - 在项目中拥有维护者或所有者角色。

{{< /tab >}}

{{< /tabs >}}

<a id="view-and-manage-service-accounts"></a>

## 查看和管理服务账号

服务账号页面显示您的群组、项目或实例中服务账号的信息。每个群组、项目和极狐GitLab 私有化部署实例都有单独的服务账号页面。在这些页面上，您可以：

- 查看您的群组或实例的所有服务账号。
- 删除服务账号。
- 编辑服务账号的名称或用户名。
- 管理服务账号的个人访问令牌。

{{< tabs >}}

{{< tab title="实例服务账号" >}}

要查看整个实例的服务账号：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **服务账号**。

{{< /tab >}}

{{< tab title="群组服务账号" >}}

要查看群组的服务账号：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **服务账号**。

{{< /tab >}}

{{< tab title="项目服务账号" >}}

要查看项目的服务账号：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **服务账号**。

{{< /tab >}}

{{< /tabs >}}

<a id="create-a-service-account"></a>

### 创建服务账号

在 JihuLab.com 上，只有顶级群组所有者可以创建服务账号。

默认情况下，在极狐GitLab 私有化部署上，只有管理员可以创建任一类型的服务账号。
但是，您可以[配置实例](../../administration/settings/account_and_limit_settings.md#allow-top-level-group-owners-to-create-service-accounts)
以允许顶级群组所有者创建群组服务账号。

您可以创建的服务账号数量取决于您的订阅和交付方式：

- 在极狐GitLab 专业版和旗舰版上，您可以为所有交付方式创建无限数量的服务账号。
- 在极狐GitLab 基础版上，限制因交付方式而异：
  - 对于 JihuLab.com，您可以为每个顶级群组创建最多 100 个服务账号。
    这包括在子群组或项目中创建的服务账号。
  - 对于极狐GitLab 私有化部署，您可以为整个实例创建最多 100 个服务账号。
    这包括在实例、群组或项目级别创建的服务账号。

要创建服务账号：

1. 转到[服务账号](#view-and-manage-service-accounts)页面。
1. 选择**添加服务账号**。
1. 输入服务账号的名称。系统会根据该名称自动生成用户名。如有需要，您可以修改用户名。
1. 选择**创建服务账号**。

<a id="edit-a-service-account"></a>

### 编辑服务账号

您可以编辑服务账号的名称或用户名。

> [!note]
> 您无法更新与[复合身份](../duo_agent_platform/composite_identity.md)关联的服务账号的用户名。

要编辑服务账号：

1. 转到[服务账号](#view-and-manage-service-accounts)页面。
1. 找到某个服务账号。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **编辑**。
1. 编辑服务账号的名称或用户名。
1. 选择**保存更改**。

<a id="add-a-service-account-to-a-group-or-project"></a>

### 将服务账号添加到群组或项目

在您将服务账号添加为群组或项目的成员之前，它们的访问权限有限。您可以将任意数量的服务账号添加到群组或项目，并且每个服务账号可以在每个群组、子群组或项目中拥有不同的角色。

服务账号的访问权限取决于服务账号的类型：

- 实例服务账号：可以邀请加入实例上的任何群组或项目。
- 群组服务账号：可以邀请加入创建它们的群组，或加入任何
  后代子群组或项目。
- 项目服务账号：只能邀请加入创建它们的项目。

当您[将一个群组与另一个群组共享](../project/members/sharing_projects_groups.md#invite-a-group-to-a-group)时，
被共享群组的所有成员（包括服务账号）都会获得对共享目标群组的访问权限。

如果您为服务账号分配某个群组的所有者角色，该服务账号的个人访问令牌也会拥有该群组的所有者角色。

您可以使用以下方式将服务账号分配到群组和项目：

- 极狐GitLab UI：
  - [将用户添加到群组](../group/_index.md#add-users-to-a-group)。
  - [将用户添加到项目](../project/members/_index.md#add-users-to-a-project)。
- API：
  - [群组成员 API](../../api/group_members.md)。
  - [项目成员 API](../../api/project_members.md)。

> [!note]
> 如果启用了[全局 SAML 群组成员关系锁定](../group/saml_sso/group_sync.md#global-saml-group-memberships-lock)
> 或[全局 LDAP 群组成员关系锁定](../../administration/auth/ldap/ldap_synchronization.md#global-ldap-group-memberships-lock)
> 设置，则必须使用 API 来控制服务账号的成员关系。

<a id="fork-projects-with-a-service-account"></a>

## 使用服务账号 Fork 项目

服务账号可以通过 [Project forks API](../../api/project_forks.md) fork 项目，但不能 fork 到自己的个人命名空间。使用服务账号创建 fork 时，必须指定目标群组命名空间。

先决条件：

- 服务账号具有开发者角色，并且是目标群组的成员。
- 服务账号的个人访问令牌已开启 `api` 范围。

要使用服务账号 fork 项目：

1. 确定创建 fork 的目标群组。
1. 确保服务账号是该群组的成员并具有适当的权限。
1. 使用 [fork 项目 API](../../api/project_forks.md)，并指定 `namespace_id` 或 `namespace_path`：

   ```shell
    curl --request POST --header "PRIVATE-TOKEN: <service_account_token>" \
      --data "namespace_path=target-group" \
      "https://gitlab.example.com/api/v4/projects/<project_id>/fork"
   ```

<a id="delete-a-service-account"></a>

### 删除服务账号

当您删除服务账号时，该账号所做的任何贡献都会保留，所有权会转移给幽灵用户。这些贡献可以包括合并请求、议题、项目和群组等活动。

要删除服务账号：

1. 转到[服务账号](#view-and-manage-service-accounts)页面。
1. 找到某个服务账号。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **删除账号**。
1. 输入服务账号的名称。
1. 选择**删除用户**。

您也可以删除服务账号以及该账号所做的任何贡献。这些贡献可以包括合并请求、议题、群组和项目等活动。

1. 转到[服务账号](#view-and-manage-service-accounts)页面。
1. 找到某个服务账号。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **删除账号和贡献**。
1. 输入服务账号的名称。
1. 选择**删除用户和贡献**。

您还可以通过 API 删除服务账号。

- 对于实例服务账号，请使用[用户 API](../../api/users.md#delete-a-user)。
- 对于群组服务账号，请使用[服务账号 API](../../api/service_accounts.md#delete-a-group-service-account)。

<a id="view-and-manage-personal-access-tokens-for-a-service-account"></a>

## 查看和管理服务账号的个人访问令牌

个人访问令牌页面显示您的顶级群组或实例中与服务账号关联的个人访问令牌的信息。在这些页面上，您可以：

- 筛选、排序和查看个人访问令牌的详细信息。
- 轮换个人访问令牌。
- 撤销个人访问令牌。

您还可以通过 API 管理服务账号的个人访问令牌。

- 对于实例服务账号，请使用[个人访问令牌 API](../../api/personal_access_tokens.md)。
- 对于群组服务账号，请使用[服务账号 API](../../api/service_accounts.md)。

要查看服务账号的个人访问令牌页面：

1. 转到[服务账号](#view-and-manage-service-accounts)页面。
1. 找到某个服务账号。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **管理访问令牌**。

<a id="create-a-personal-access-token-for-a-service-account"></a>

### 为服务账号创建个人访问令牌

要使用服务账号，您必须创建个人访问令牌来验证请求。

要为服务账号创建个人访问令牌：

1. 转到[服务账号](#view-and-manage-service-accounts)页面。
1. 找到某个服务账号。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **管理访问令牌**。
1. 选择**添加新令牌**。
1. 在**令牌名称**中，输入令牌的名称。
1. 可选。在**令牌描述**中，输入令牌的描述。
1. 在**到期日期**中，输入令牌的到期日期。
   - 令牌将在该日期午夜 UTC 到期。到期日期为 2024-01-01 的令牌将在 2024-01-01 00:00:00 UTC 到期。
   - 如果您未输入到期日期，到期日期会自动设置为当前日期之后 365 天。
   - 默认情况下，该日期最多可比当前日期晚 365 天。在极狐GitLab 17.6 或更高版本中，您可以[将此限制延长至 400 天](https://gitlab.com/gitlab-org/gitlab/-/issues/461901)。
1. 选择[所需范围](../../security/tokens/access_token_scopes.md)。
1. 选择**创建个人访问令牌**。

<a id="rotate-a-personal-access-token"></a>

### 轮换个人访问令牌

您可以轮换个人访问令牌，使当前令牌失效并生成新值。

> [!warning]
> 此操作无法撤销。依赖被轮换令牌的服务将停止工作。

要轮换服务账号的个人访问令牌：

1. 转到[服务账号](#view-and-manage-service-accounts)页面。
1. 找到某个服务账号。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **管理访问令牌**。
1. 在有效令牌旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择**轮换**。
1. 在确认对话框中，选择**轮换**。

<a id="revoke-a-personal-access-token"></a>

### 撤销个人访问令牌

您可以撤销个人访问令牌，使当前令牌失效。

> [!warning]
> 此操作无法撤销。依赖被撤销令牌的服务将停止工作。

要撤销服务账号的个人访问令牌：

1. 转到[服务账号](#view-and-manage-service-accounts)页面。
1. 找到某个服务账号。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **管理访问令牌**。
1. 在有效令牌旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择**撤销**。
1. 在确认对话框中，选择**撤销**。

<a id="rate-limits"></a>

## 速率限制

[速率限制](../../rate_limits/_index.md)适用于服务账号：

- 在 JihuLab.com 上，适用 [JihuLab.com 特定的速率限制](../jihulab_com/_index.md#jihulabcom-specific-rate-limits)。
- 在极狐GitLab 私有化部署上，适用以下速率限制：
  - [可配置的速率限制](../../rate_limits/_index.md#configuration-options)
  - [不可配置的速率限制](../../rate_limits/non_configurable.md)
