---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 管理用户
---

如果您被分配了群组的所有者角色，您可以[审批](manage.md#user-cap-for-groups)、封禁或自动移除休眠成员。

> [!note]
> 本主题专门涉及群组中的用户管理。有关私有化部署的信息，请参见[管理文档](../../administration/moderate_users.md)。

<a id="ban-and-unban-users"></a>

## 封禁和解除封禁用户

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.8 中引入，带有一个功能标志，名为 `limit_unique_project_downloads_per_namespace_user`。默认禁用。
- 在极狐GitLab 15.6 中在 JihuLab.com 上启用。
- 在极狐GitLab 18.0 中 GA。功能标志 `limit_unique_project_downloads_per_namespace_user` 已移除。

{{< /history >}}

群组所有者可以通过封禁和解除封禁用户来管理用户访问。当您想要阻止用户访问群组时，应该封禁该用户。

被封禁的用户：

- 无法访问群组或其任何代码库。
- 无法使用[斜杠命令](../project/integrations/gitlab_slack_application.md#slash-commands)。
- 不占用[席位](../free_user_limit.md)。

<a id="ban-a-user"></a>

### 封禁用户

先决条件：

- 在顶级群组中，您必须具有所有者角色。
- 在顶级群组中，如果您要封禁的用户具有所有者角色，您必须[降级该用户](manage.md#change-the-owner-of-a-group)。

要手动封禁用户：

1. 转到顶级群组。
1. 在左侧边栏中，选择 **管理** > **成员**。
1. 在您要封禁的成员旁边，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 从下拉列表中，选择 **封禁成员**。

<a id="unban-a-user"></a>

### 解除封禁用户

要通过 GraphQL API 解除封禁用户，请参见 [`Mutation.namespaceBanDestroy`](../../api/graphql/reference/_index.md#mutationnamespacebandestroy)。

先决条件：

- 在顶级群组中，您必须具有所有者角色。

要解除封禁用户：

1. 转到顶级群组。
1. 在左侧边栏中，选择 **管理** > **成员**。
1. 选择 **已封禁** 选项卡。
1. 对于您要解除封禁的账户，选择 **解除封禁**。

<a id="automatically-remove-dormant-members"></a>

## 自动移除休眠成员

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Status: Beta

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.1 中引入，带有一个功能标志，名为 `group_remove_dormant_members`。默认禁用。
- 在极狐GitLab 17.9 中作为测试版功能发布。

{{< /history >}}

先决条件：

- 您必须具有群组的所有者角色。

您可以自动移除在指定时间段内（默认且最少为 90 天）在群组中没有任何活动的群组成员。
以下操作被视为活动：

- 通过 Git HTTP/SSH 事件与项目交互，例如 `clone` 和 `push`。
- 访问极狐GitLab 中的页面，例如仪表板、项目、议题、合并请求或设置。
- 在群组范围内使用 REST 或 GraphQL API。

> [!note]
> 对于在 2025-01-22 之前添加的成员，活动尚未被记录。这些成员在 2025-04-22 之前不会被移除，即使他们已经休眠超过 90 天。

- 休眠的群组所有者既不会被停用，也不会从群组中移除。
- 休眠的[企业用户](../enterprise_user/_index.md)不会被移除，而是被[停用](../../administration/moderate_users.md#deactivate-and-reactivate-users)。当这些用户重新登录时，他们的账户会被重新激活，访问权限也会恢复。但是，当企业群组上启用了[受限访问](manage.md#restricted-access)且没有可用席位时，用户会被设置为待审批状态，而不是重新激活。有关更多信息，请参见[休眠企业用户重新激活](manage.md#dormant-enterprise-user-reactivation)。

要开启自动休眠成员移除：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **权限和群组功能**。
1. 滚动到 **休眠成员**。
1. 选中 **在一段时间不活跃后移除休眠成员** 复选框。
1. 在 **移除前的不活跃天数** 字段中，输入移除前的天数。最少为 90 天，最多为 1827 天（5 年）。
1. 选择 **保存更改**。

当成员达到不活跃天数并从群组中移除后：

- 他们仍然可以访问 JihuLab.com。
- 他们无法访问该群组。
- 对群组所做的贡献仍然分配给已移除的成员。