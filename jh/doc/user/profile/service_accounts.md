---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 服务账号
description: Create non-human accounts for automated processes and third-party service integrations.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 基础版中的服务账号：
  - 引入于 GitLab 18.10，通过名为 `service_accounts_available_on_free_or_unlicensed` 的功能标志，默认禁用。
  - 在 GitLab 18.11 中[GA]。功能标志已移除。
- 项目服务账号引入于 GitLab 18.10，通过名为 `allow_projects_to_create_service_accounts` 的功能标志，默认禁用。
- 子群组服务账号引入于 GitLab 18.10，通过名为 `allow_subgroups_to_create_service_accounts` 的功能标志，默认禁用。
- 子群组和项目服务账号在 GitLab 18.11 中[GA]。功能标志 `allow_subgroups_to_create_service_accounts` 和 `allow_projects_to_create_service_accounts` 已移除。

{{< /history >}}

服务账号是代表非人类实体而非个人的用户账号。使用服务账号可执行自动化操作、访问数据或运行计划流程。服务账号通常用于流水线或第三方集成中，在这些场景下，凭证必须保持稳定，不受团队成员变更的影响。

服务账号通过[个人访问令牌](personal_access_tokens.md)进行认证。它们可以与[软件包和容器镜像仓库](../packages/_index.md)交互，执行 [Git 操作](personal_access_tokens.md#clone-repository-using-personal-access-token)，以及访问 API。

服务账号具有以下特征：

- 不占用席位。
- 不是[计费用户](../../subscriptions/manage_seats.md#billable-users)或[内部用户](../../administration/internal_users.md)。
- 始终被标记为[外部用户](../../administration/external_users.md)。
- 无法通过 UI 登录极狐GitLab。
- 无法通过 LDAP 等服务进行管理。
- 由子群组或项目创建时，不能创建顶级群组或其他服务账号。
- 在群组和项目成员列表中显示为服务账号，而非普通用户。
- 除非添加[自定义邮箱地址](../../api/service_accounts.md#create-an-instance-service-account)，否则不会收到通知邮件。
- 可在极狐GitLab的[试用版](https://gitlab.com/-/trial_registrations/new?glm_source=docs.gitlab.com&glm_content=free-user-limit-faq/ee/user/free_user_limit.html)上使用。在 JihuLab.com 上，顶级群组的所有者必须先验证其身份。

你还可以通过[服务账号 API](../../api/service_accounts.md) 管理服务账号。要管理服务账号的 SSH 密钥，请使用[用户 SSH 和 GPG 密钥 API](../../api/user_keys.md)。你无法通过极狐GitLab UI 管理 SSH 密钥。

可创建的服务账号数量取决于您的订阅和部署方式：

- 在极狐GitLab专业版和旗舰版上，你可以为所有部署方式创建无限制数量的服务账号。
- 在极狐GitLab基础版中，限制取决于部署方式：
  - 对于 JihuLab.com，每个顶级群组最多可以创建 100 个服务账号。这包括在子群组或项目中创建的服务账号。
  - 对于私有化部署企业版（EE），实例范围内最多可以创建 100 个服务账号。
  - 对于私有化部署社区版（CE），不能创建服务账号。

<a id="types-of-service-accounts"></a>

## 服务账号类型

服务账号有三种类型，每种类型有不同的范围和先决条件：

{{< tabs >}}

{{< tab title="实例服务账号" >}}

实例服务账号通过管理员区域创建，可以被邀请到实例上的任何群组或项目。

先决条件：

- 拥有实例的管理员访问权限。

{{< /tab >}}

{{< tab title="群组服务账号" >}}

群组服务账号由特定群组创建，可以被邀请到创建它们的群组或其任何子孙群组或项目。它们不能创建顶级群组或服务账号。

先决条件：

- 在 JihuLab.com 上，你必须拥有该群组的所有者角色。
- 对于私有化部署，你必须满足以下任一条件：
  - 是实例的管理员。
  - 在群组中拥有所有者角色，并且被[允许创建服务账号](../../administration/settings/account_and_limit_settings.md#allow-top-level-group-owners-to-create-service-accounts)。

{{< /tab >}}

{{< tab title="项目服务账号" >}}

项目服务账号由特定项目创建，仅在该项目中可用。它们不能创建顶级群组或服务账号。

先决条件：

- 在 JihuLab.com 上，你必须拥有该项目的所有者或维护者角色。
- 对于私有化部署，你必须满足以下任一条件：
  - 是实例的管理员。
  - 在项目中拥有所有者或维护者角色。

{{< /tab >}}

{{< /tabs >}}

<a id="view-and-manage-service-accounts"></a>

## 查看和管理服务账号

{{< history >}}

- 在 GitLab 17.11 中为 JihuLab.com 引入。

{{< /history >}}

服务账号页面显示你的群组、项目或实例中的服务账号信息。每个群组、项目和私有化部署实例都有单独的服务账号页面。在这些页面中，你可以：

- 查看你的群组或实例的所有服务账号。
- 删除服务账号。
- 编辑服务账号的名称或用户名。
- 管理服务账号的个人访问令牌。

{{< tabs >}}

{{< tab title="实例服务账号" >}}

要查看整个实例的服务账号：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **服务账号**。

{{< /tab >}}

{{< tab title="群组服务账号" >}}

要查看群组的服务账号：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **服务账号**。

{{< /tab >}}

{{< tab title="项目服务账号" >}}

要查看项目的服务账号：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **服务账号**。

{{< /tab >}}

{{< /tabs >}}

<a id="create-a-service-account"></a>

### 创建服务账号

{{< history >}}

- 在 GitLab 16.3 中为 JihuLab.com 引入。
- 顶级群组所有者可以在 GitLab 17.5 中为私有化部署创建服务账号，通过名为 `allow_top_level_group_owners_to_create_service_accounts` 的功能标志引入，默认禁用。
- 顶级群组所有者可以在 GitLab 17.6 中[GA]创建服务账号。功能标志 `allow_top_level_group_owners_to_create_service_accounts` 已移除。

{{< /history >}}

在 JihuLab.com 上，只有顶级群组所有者可以创建服务账号。

默认情况下，在私有化部署中，只有管理员可以创建任何类型的服务账号。但你可以[配置实例](../../administration/settings/account_and_limit_settings.md#allow-top-level-group-owners-to-create-service-accounts)以允许顶级群组所有者创建群组服务账号。

可创建的服务账号数量取决于你的订阅和部署方式：

- 在极狐GitLab专业版和旗舰版上，你可以为所有部署方式创建无限制数量的服务账号。
- 在极狐GitLab基础版中，限制取决于部署方式：
  - 对于 JihuLab.com，每个顶级群组最多可以创建 100 个服务账号。这包括在子群组或项目中创建的服务账号。
  - 对于私有化部署企业版（EE），实例范围内最多可以创建 100 个服务账号。
  - 对于私有化部署社区版（CE），不能创建服务账号。

要创建服务账号：

1. 转到[服务账号](#view-and-manage-service-accounts)页面。
1. 选择 **添加服务账号**。
1. 输入服务账号的名称。系统会根据名称自动生成用户名。你可以根据需要修改用户名。
1. 选择 **创建服务账号**。

<a id="edit-a-service-account"></a>

### 编辑服务账号

{{< history >}}

- 在 GitLab 18.9 中，为具有复合身份的服务账号添加了用户名限制。

{{< /history >}}

你可以编辑服务账号的名称或用户名。

> [!note]
> 你无法更新与[复合身份](../duo_agent_platform/composite_identity.md)关联的服务账号的用户名。

要编辑服务账号：

1. 转到[服务账号](#view-and-manage-service-accounts)页面。
1. 找到要编辑的服务账号。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **编辑**。
1. 编辑服务账号的名称或用户名。
1. 选择 **保存更改**。

<a id="add-a-service-account-to-a-group-or-project"></a>

### 将服务账号添加到群组或项目

服务账号在成为群组或项目的成员之前只能进行有限访问。你可以将任意数量的服务账号添加到群组或项目，每个服务账号在不同群组、子群组或项目中可以有不同的角色。

服务账号的访问权限取决于其类型：

- 实例服务账号：可以被邀请到实例上的任何群组或项目。
- 群组服务账号：可以被邀请到创建它们的群组或其任何子孙群组或项目。
- 项目服务账号：只能被邀请到创建它们的项目。

当[群组被共享给另一个群组](../project/members/sharing_projects_groups.md#invite-a-group-to-a-group)时，该群组的所有成员（包括服务账号）都会获得对共享群组的访问权限。

你可以通过以下方式将服务账号分配给群组和项目：

- 极狐GitLab UI：
  - [将用户添加到群组](../group/_index.md#add-users-to-a-group)。
  - [将用户添加到项目](../project/members/_index.md#add-users-to-a-project)。
- API：
  - [群组成员 API](../../api/group_members.md)。
  - [项目成员 API](../../api/project_members.md)。

> [!note]
> 如果启用了[全局 SAML 群组成员锁定](../group/saml_sso/group_sync.md#global-saml-group-memberships-lock)或[全局 LDAP 群组成员锁定](../../administration/auth/ldap/ldap_synchronization.md#global-ldap-group-memberships-lock)设置，你必须使用 API 来控制服务账号的成员关系。

<a id="fork-projects-with-a-service-account"></a>

## 使用服务账号派生项目

服务账号可以通过[项目派生 API](../../api/project_forks.md) 派生项目，但不能派生到其个人命名空间。使用服务账号进行派生时，必须指定目标群组命名空间。

先决条件：

- 服务账号具有开发者角色，并且是目标群组的成员。
- 服务账号的个人访问令牌已开启 `api` 作用域。

使用服务账号派生项目：

1. 确定要在其中创建派生的目标群组。
1. 确保服务账号是该群组的成员并具有适当权限。
1. 使用[派生项目 API](../../api/project_forks.md) 并附带 `namespace_id` 或 `namespace_path`：

   ```shell
    curl --request POST --header "PRIVATE-TOKEN: <service_account_token>" \
      --data "namespace_path=target-group" \
      "https://gitlab.example.com/api/v4/projects/<project_id>/fork"
   ```

<a id="delete-a-service-account"></a>

### 删除服务账号

当你删除服务账号时，该账号所做的任何贡献都将保留，所有权会转移给一个幽灵用户。这些贡献可能包括合并请求、议题、项目和群组等活动。

要删除服务账号：

1. 转到[服务账号](#view-and-manage-service-accounts)页面。
1. 找到要删除的服务账号。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **删除账号**。
1. 输入服务账号的名称。
1. 选择 **删除用户**。

你还可以删除服务账号及其所做的所有贡献。这些贡献可能包括合并请求、议题、群组和项目等活动。

1. 转到[服务账号](#view-and-manage-service-accounts)页面。
1. 找到要删除的服务账号。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **删除账号及贡献**。
1. 输入服务账号的名称。
1. 选择 **删除用户及贡献**。

你还可以通过 API 删除服务账号。

- 对于实例服务账号，使用[用户 API](../../api/users.md#delete-a-user)。
- 对于群组服务账号，使用[服务账号 API](../../api/service_accounts.md#delete-a-group-service-account)。

<a id="view-and-manage-personal-access-tokens-for-a-service-account"></a>

## 查看和管理服务账号的个人访问令牌

个人访问令牌页面显示与你的顶级群组或实例中的服务账号关联的个人访问令牌信息。在这些页面中，你可以：

- 筛选、排序和查看个人访问令牌的详细信息。
- 轮换个人访问令牌。
- 撤销个人访问令牌。

你还可以通过 API 管理服务账号的个人访问令牌。

- 对于实例服务账号，使用[个人访问令牌 API](../../api/personal_access_tokens.md)。
- 对于群组服务账号，使用[服务账号 API](../../api/service_accounts.md)。

要查看服务账号的个人访问令牌页面：

1. 转到[服务账号](#view-and-manage-service-accounts)页面。
1. 找到要查看的服务账号。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **管理访问令牌**。

<a id="create-a-personal-access-token-for-a-service-account"></a>

### 为服务账号创建个人访问令牌

要使用服务账号，你必须创建个人访问令牌以认证请求。

要为服务账号创建个人访问令牌：

1. 转到[服务账号](#view-and-manage-service-accounts)页面。
1. 找到要创建令牌的服务账号。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **管理访问令牌**。
1. 选择 **添加新令牌**。
1. 在 **令牌名称** 中，输入令牌的名称。
1. 可选。在 **令牌描述** 中，输入令牌的描述。
1. 在 **过期日期** 中，输入令牌的过期日期。
   - 令牌会在该日期的世界协调时间凌晨 0 点过期。过期日期为 2024-01-01 的令牌会在 2024-01-01 的 00:00:00 UTC 过期。
   - 如果你不输入过期日期，则过期日期会自动设置为当前日期的 365 天后。
   - 默认情况下，此日期最多可以设置为当前日期的 365 天后。在 GitLab 17.6 或更高版本中，你可以将限制延长至 400 天。
1. 选择[所需的作用域](personal_access_tokens.md#personal-access-token-scopes)。
1. 选择 **创建个人访问令牌**。

<a id="rotate-a-personal-access-token"></a>

### 轮换个人访问令牌

你可以轮换个人访问令牌以使当前令牌失效并生成新值。

> [!warning]
> 这无法撤销。依赖已轮换令牌的服务将停止工作。

要轮换服务账号的个人访问令牌：

1. 转到[服务账号](#view-and-manage-service-accounts)页面。
1. 找到要轮换令牌的服务账号。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **管理访问令牌**。
1. 在活动令牌旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择 **轮换**。
1. 在确认对话框中，选择 **轮换**。

<a id="revoke-a-personal-access-token"></a>

### 撤销个人访问令牌

你可以撤销个人访问令牌以使当前令牌失效。

> [!warning]
> 这无法撤销。依赖已撤销令牌的服务将停止工作。

要撤销服务账号的个人访问令牌：

1. 转到[服务账号](#view-and-manage-service-accounts)页面。
1. 找到要撤销令牌的服务账号。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) > **管理访问令牌**。
1. 在活动令牌旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择 **撤销**。
1. 在确认对话框中，选择 **撤销**。

<a id="rate-limits"></a>

## 速率限制

[速率限制](../../security/rate_limits.md)适用于服务账号：

- 在 JihuLab.com 上，适用 [JihuLab.com 特定的速率限制](../jihulab_com/_index.md#jihulabcom-specific-rate-limits)。
- 在私有化部署中，适用以下速率限制：
  - [可配置的速率限制](../../security/rate_limits.md#configurable-limits)
  - [不可配置的速率限制](../../security/rate_limits.md#non-configurable-limits)

<a id="related-topics"></a>

## 相关主题

- [计费用户](../../subscriptions/manage_seats.md#billable-users)
- [关联记录](account/delete_account.md#associated-records)
- [项目访问令牌 - 机器人用户](../project/settings/project_access_tokens.md#bot-users-for-projects)
- [群组访问令牌 - 机器人用户](../group/settings/group_access_tokens.md#bot-users-for-groups)
- [内部用户](../../administration/internal_users.md)