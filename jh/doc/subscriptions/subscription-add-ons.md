---
stage: Fulfillment
group: Seat Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 探索极狐GitLab Duo 订阅附加组件并分配席位。
title: 极狐GitLab Duo 附加组件
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.0 中，更改为包含极狐GitLab Duo Core 附加组件。
- 极狐GitLab UI 中的极狐GitLab Duo Non-Agentic Chat 功能在极狐GitLab 18.3 中添加到基础版。
- 在极狐GitLab 18.4 中，添加了在私有化部署实例上禁用席位分配邮件的功能。

{{< /history >}}

极狐GitLab Duo 附加组件通过 AI 原生功能扩展你的专业版或旗舰版订阅。
使用极狐GitLab Duo 加速开发工作流、减少重复编码任务，
并深入洞察整个项目。

提供三种附加组件：极狐GitLab Duo Core、Pro 和 Enterprise。

每个附加组件都提供对
[一系列极狐GitLab Duo 功能](../user/gitlab_duo/feature_summary.md) 的访问。

<a id="gitlab-duo-core"></a>

## 极狐GitLab Duo Core

如果你满足以下条件，极狐GitLab Duo Core 将自动包含在内：

- 极狐GitLab 18.0 或更高版本。
- 专业版或旗舰版订阅。

如果你是从极狐GitLab 17.11 或更早版本升级的现有客户，
你必须 [为极狐GitLab Duo Core 开启功能](../user/gitlab_duo/turn_on_off.md#turn-gitlab-duo-core-on-or-off)。

如果你是极狐GitLab 18.0 或更高版本的新客户，极狐GitLab Duo Core 的功能将自动开启，无需额外操作。

要查看哪些角色可以访问极狐GitLab Duo Core，请参阅 [极狐GitLab Duo 群组权限](../user/permissions.md#group-gitlab-duo)。

<a id="gitlab-duo-self-hosted"></a>

### 极狐GitLab Duo Self-Hosted

如果你拥有离线许可证，极狐GitLab Duo Core 在
极狐GitLab Duo Self-Hosted 上不可用，因为极狐GitLab Duo Core 需要连接到极狐GitLab AI 网关。

如果你拥有在线许可证，你可以将极狐GitLab Duo Core 与
极狐GitLab Duo Self-Hosted 结合使用。要使用极狐GitLab Duo Core，你必须为实例选择极狐GitLab 管理的模型
用于极狐GitLab Duo Non-Agentic Chat 和代码建议。

<a id="gitlab-duo-core-limits"></a>

### 极狐GitLab Duo Core 限制

使用限制以及 [极狐GitLab 服务条款](https://gitlab.cn/terms/)
适用于专业版和旗舰版客户使用包含的代码建议和极狐GitLab Duo Chat 功能。

极狐GitLab 将在这些限制生效前 30 天发出通知。
届时，组织管理员将拥有监控和管理消耗的工具，并能够
购买额外容量。

限制不适用于极狐GitLab Duo Pro 或 Enterprise。

<a id="gitlab-duo-pro-and-enterprise"></a>

## 极狐GitLab Duo Pro 和 Enterprise

极狐GitLab Duo Pro 和 Enterprise 需要你购买席位并将其分配给团队成员。
基于席位的模型让你可以根据特定团队需求控制功能访问和成本管理。

<a id="gitlab-duo-agent-platform-self-hosted"></a>

## 极狐GitLab Duo Agent Platform Self-Hosted

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.8 中引入。

{{< /history >}}

拥有离线许可证的客户必须购买极狐GitLab Duo Agent Platform Self-Hosted 附加组件，
才能在 Agent Platform 中使用自部署模型。

拥有此附加组件的客户按席位计费，而不是 [按用量](gitlab_credits.md) 计费。

拥有在线许可证的客户可以在没有附加组件的情况下在 Agent Platform 中使用自部署模型，
并按用量计费。

要购买极狐GitLab Duo Agent Platform Self-Hosted，请联系
[极狐GitLab 销售团队](https://gitlab.cn/solutions/gitlab-duo-pro/sales/)。

<a id="purchase-gitlab-duo"></a>

## 购买极狐GitLab Duo

要购买极狐GitLab Duo Enterprise，请联系
[极狐GitLab 销售团队](https://gitlab.cn/solutions/gitlab-duo-pro/sales/)。

要购买极狐GitLab Duo Pro 的席位，请使用 Customers Portal 或
联系 [极狐GitLab 销售团队](https://gitlab.cn/solutions/gitlab-duo-pro/sales/)。

要使用门户网站：

1. 登录 [极狐GitLab Customers Portal](https://customers.jihulab.com/)。
1. 在订阅卡片上，选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择 **购买极狐GitLab Duo Pro**。
1. 输入极狐GitLab Duo 的席位数。
1. 查看 **购买摘要** 部分。
1. 从 **支付方式** 下拉列表中，选择你的支付方式。
1. 选择 **购买席位**。

<a id="purchase-additional-gitlab-duo-seats"></a>

## 购买额外的极狐GitLab Duo 席位

你可以为你的群组命名空间或极狐GitLab 私有化部署实例购买额外的极狐GitLab Duo Pro 或极狐GitLab Duo Enterprise 席位。购买完成后，席位将添加到订阅中的极狐GitLab Duo 总席位数中。

先决条件：

- 你必须购买了极狐GitLab Duo Pro 或极狐GitLab Duo Enterprise 附加组件。

<a id="for-gitlabcom"></a>

### 对于 JihuLab.com

先决条件：

- 你必须具有所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 在 **席位利用率** 旁边，选择 **分配席位**。
1. 选择 **购买席位**。
1. 在 Customers Portal 中，在 **添加额外席位** 字段中，输入席位数。该数量
   不能高于与你的群组命名空间关联的订阅中的席位数。
1. 在 **账单信息** 部分，从下拉列表中选择支付方式。
1. 选中 **隐私政策** 和 **服务条款** 复选框。
1. 选择 **购买席位**。
1. 选择 **极狐GitLab SaaS** 选项卡并刷新页面。

<a id="for-gitlab-self-managed"></a>

### 对于极狐GitLab 私有化部署

先决条件：

- 你必须是管理员。

1. 登录 [极狐GitLab Customers Portal](https://customers.jihulab.com/)。
1. 在你的订阅卡片的 **极狐GitLab Duo Pro** 部分，选择 **添加席位**。
1. 输入席位数。该数量不能高于订阅中的席位数。
1. 查看 **购买摘要** 部分。
1. 从 **支付方式** 下拉列表中，选择你的支付方式。
1. 选择 **购买席位**。

<a id="assign-gitlab-duo-seats"></a>

## 分配极狐GitLab Duo 席位

先决条件：

- 你必须购买极狐GitLab Duo Pro 或 Enterprise 附加组件，或者拥有活跃的极狐GitLab Duo 试用。
- 对于极狐GitLab 私有化部署：
  - 极狐GitLab Duo Pro 附加组件在极狐GitLab 16.8 及更高版本中可用。
  - 极狐GitLab Duo Enterprise 附加组件仅在极狐GitLab 17.3 及更高版本中可用。

购买极狐GitLab Duo Pro 或 Enterprise 后，你可以将席位分配给用户以授予对附加组件的访问权限。

<a id="for-gitlabcom-1"></a>

### 对于 JihuLab.com

先决条件：

- 你必须具有所有者角色。

要在任何项目或群组中使用极狐GitLab Duo 功能，你必须至少在一个顶级群组中将用户分配一个席位。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 在 **席位利用率** 旁边，选择 **分配席位**。
1. 在用户右侧，打开切换开关以分配极狐GitLab Duo 席位。

用户将收到一封确认电子邮件。

<a id="for-gitlab-self-managed-1"></a>

### 对于极狐GitLab 私有化部署

先决条件：

- 你必须是管理员。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
   - 如果 **极狐GitLab Duo** 菜单项不可用，请在购买后同步你的订阅：
     1. 在左侧边栏中，选择 **订阅**。
     1. 在 **订阅详情** 中，在 **上次同步** 右侧，选择
        同步订阅 ({{< icon name="retry" >}})。
1. 在 **席位利用率** 旁边，选择 **分配席位**。
1. 在用户右侧，打开切换开关以分配极狐GitLab Duo 席位。

用户将收到一封确认电子邮件。

- 要禁用此电子邮件，请将 `sm_duo_seat_assignment_email` 功能标志设置为 `false`。
  此标志默认启用。

分配席位后，
[确保为你的极狐GitLab 私有化部署实例设置极狐GitLab Duo](../administration/gitlab_duo/configure/gitlab_self_managed.md)。

<a id="assign-and-remove-gitlab-duo-seats-in-bulk"></a>

## 批量分配和移除极狐GitLab Duo 席位

你可以批量分配或移除多个用户的席位。

<a id="saml-group-sync"></a>

### SAML 群组同步

JihuLab.com 群组可以使用 SAML 群组同步来 [管理极狐GitLab Duo 席位分配](../user/group/saml_sso/group_sync.md#manage-gitlab-duo-seat-assignment)。

<a id="for-gitlabcom-2"></a>

### 对于 JihuLab.com

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 在右下角，你可以调整页面显示为 **50** 或 **100** 个项目，以增加可供选择的用户数量。
1. 选择要分配或移除席位的用户：
   - 要选择多个用户，请在每个用户左侧选中复选框。
   - 要全选，请选中表格顶部的复选框。
1. 分配或移除席位：
   - 要分配席位，选择 **分配席位**，然后选择 **分配席位** 确认。
   - 要移除用户的席位，选择 **移除席位**，然后选择 **移除席位** 确认。

<a id="for-gitlab-self-managed-2"></a>

### 对于极狐GitLab 私有化部署

先决条件：

- 你必须是管理员。
- 你必须拥有极狐GitLab 17.5 或更高版本。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 在右下角，你可以调整页面显示为 **50** 或 **100** 个项目，以增加可供选择的用户数量。
1. 选择要分配或移除席位的用户：
   - 要选择多个用户，请在每个用户左侧选中复选框。
   - 要全选，请选中表格顶部的复选框。
1. 分配或移除席位：
   - 要分配席位，选择 **分配席位**，然后选择 **分配席位** 确认。
   - 要移除用户的席位，选择 **移除席位**，然后选择 **移除席位** 确认。

极狐GitLab 私有化部署实例的管理员也可以使用 [Rake 任务](../administration/raketasks/user_management.md#bulk-assign-users-to-gitlab-duo) 来批量分配或移除席位。

<a id="managing-gitlab-duo-seats-with-ldap-configuration"></a>

#### 通过 LDAP 配置管理极狐GitLab Duo 席位

你可以根据 LDAP 群组成员资格自动为启用了 LDAP 的用户分配和移除极狐GitLab Duo 席位。

要启用此功能，你必须在 LDAP 设置中 [配置 `duo_add_on_groups` 属性](../administration/auth/ldap/ldap_synchronization.md#gitlab-duo-add-on-for-groups)。

配置 `duo_add_on_groups` 后，它会成为启用了 LDAP 的用户中极狐GitLab Duo 席位管理的单一真实来源。
有关更多信息，请参阅 [席位分配工作流](../administration/duo_add_on_seat_management_with_ldap.md#seat-management-workflow)。

此自动化流程可确保根据你组织的 LDAP 群组结构高效分配极狐GitLab Duo 席位。
有关更多信息，请参阅 [通过 LDAP 管理极狐GitLab Duo 附加组件席位](../administration/duo_add_on_seat_management_with_ldap.md)。

<a id="view-assigned-gitlab-duo-users"></a>

## 查看已分配的极狐GitLab Duo 用户

{{< history >}}

- 最后极狐GitLab Duo 活动字段在极狐GitLab 18.0 中引入。

{{< /history >}}

先决条件：

- 你必须购买极狐GitLab Duo Pro 或 Enterprise 附加组件，或者拥有活跃的极狐GitLab Duo 试用。

购买极狐GitLab Duo Pro 或 Enterprise 后，你可以将席位分配给用户以
授予对附加组件的访问权限。然后你可以查看已分配的极狐GitLab Duo 用户的详细信息。

极狐GitLab Duo 席位利用率页面为每个用户显示以下信息：

- 用户的全名和用户名
- 席位分配状态
- 公共电子邮件地址：显示在其公开个人资料上的用户电子邮件。
- 上次极狐GitLab 活动：用户上次在极狐GitLab 中执行任何操作的日期。
- 上次极狐GitLab Duo 活动：用户上次使用极狐GitLab Duo 功能的日期。在任何极狐GitLab Duo 活动时刷新。

这些字段使用来自 [GraphQL API](../api/graphql/reference/_index.md#addonuser) 中 `AddOnUser` 类型的数据。

<a id="for-gitlabcom-3"></a>

### 对于 JihuLab.com

先决条件：

- 你必须具有所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 在 **席位利用率** 旁边，选择 **分配席位**。
1. 在过滤栏中，选择 **已分配席位** 和 **是**。
1. 用户列表会被过滤，只显示已分配极狐GitLab Duo 席位的用户。

<a id="for-gitlab-self-managed-3"></a>

### 对于极狐GitLab 私有化部署

先决条件：

- 你必须是管理员。
- 你必须拥有极狐GitLab 17.5 或更高版本。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
   - 如果 **极狐GitLab Duo** 菜单项不可用，请在购买后同步你的订阅：
     1. 在左侧边栏中，选择 **订阅**。
     1. 在 **订阅详情** 中，在 **上次同步** 右侧，选择
        同步订阅 ({{< icon name="retry" >}})。
1. 在 **席位利用率** 旁边，选择 **分配席位**。
1. 要按已分配极狐GitLab Duo 席位的用户进行过滤，请在 **过滤用户** 栏中选择 **已分配席位**，然后选择 **是**。
1. 用户列表会被过滤，只显示已分配极狐GitLab Duo 席位的用户。

<a id="automatic-seat-removal"></a>

## 自动席位移除

极狐GitLab Duo 附加组件席位会被自动移除，以确保只有符合条件的用户拥有访问权限。这
发生在以下情况：

- 席位超额
- 被阻止、被禁止和已停用的用户

<a id="at-subscription-expiration"></a>

### 订阅到期时

如果你包含极狐GitLab Duo 附加组件的订阅到期，席位分配将保留 28 天。如果在此 28 天窗口内续订了订阅，或者购买了包含极狐GitLab Duo 的新订阅，用户将被自动重新分配。
否则，席位分配将被移除，用户必须重新分配。

<a id="for-seat-overages"></a>

### 席位超额时

如果你购买的极狐GitLab Duo 附加组件席位数减少，席位分配将自动移除，以匹配订阅中可用的席位数量。

例如：

- 你拥有一个 50 席位的极狐GitLab Duo Pro 订阅，所有席位均已分配。
- 你以 30 个席位续订了订阅。超出订阅的 20 个用户将被自动从极狐GitLab Duo Pro 席位分配中移除。
- 如果在续订之前只有 20 个用户被分配了极狐GitLab Duo Pro 席位，则不会移除任何席位。

席位移除的选择依据以下标准，按此顺序：

1. 尚未使用代码建议的用户，按最近分配的时间排序。
1. 已使用代码建议的用户，按最近使用代码建议的时间排序（最早使用的最先移除）。

<a id="for-blocked-banned-and-deactivated-users"></a>

### 被阻止、被禁止和已停用的用户

每天一次或两次，CronJob 会审查极狐GitLab Duo 席位分配。如果被分配了极狐GitLab Duo 席位的用户被
阻止、禁止或停用，他们对极狐GitLab Duo 功能的访问权限将被自动移除。

席位移除后，该席位变为可用状态，可以重新分配给新用户。

<a id="troubleshooting"></a>

## 故障排除

<a id="unable-to-use-the-ui-to-assign-seats-to-your-users"></a>

### 无法使用 UI 为用户分配席位

在 **用量配额** 页面上，如果你遇到以下两种情况，将无法使用 UI 为用户分配席位：

- **席位** 选项卡无法加载。
- 显示以下错误消息：

  ```plaintext
  加载付费成员列表时发生错误。
  ```

作为一种解决方法，你可以使用 [此代码片段](https://jihulab.com/gitlab-cn/gitlab/-/snippets/3763094) 中的 GraphQL 查询来为用户分配席位。