---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 非活跃项目删除
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 15.0，使用名为 `inactive_projects_deletion` 的 [功能标志](feature_flags.md)。默认禁用。
- 功能标志 `inactive_projects_deletion` 在极狐GitLab 15.4 中被移除。
- 通过 UI 配置的功能引入于极狐GitLab 15.1。

{{< /history >}}

大型极狐GitLab 实例的管理员可能会发现，随着时间的推移，项目变得不活跃且不再使用。这些项目占用了不必要的磁盘空间。

通过不活跃项目删除功能，您可以识别这些项目，提前警告维护者，然后在项目仍然不活跃时删除它们。当一个不活跃的项目被删除时，该操作会生成一个审核事件，表明该操作由 @GitLab-Admin-Bot 执行。

关于 JihuLab.com 的默认设置，请参见 [JihuLab.com 设置页面](../user/jihulab_com/_index.md#inactive-project-deletion)。

<a id="configure-inactive-project-deletion"></a>

## 配置不活跃项目删除

要配置不活跃项目的删除：

1. 在左侧边栏底部，选择 **管理员**。
1. 选择 **设置 > 代码库**。
1. 展开 **代码库维护**。
1. 在 **不活跃项目删除** 部分，选择 **删除不活跃项目**。
1. 配置设置。
   - 警告邮件会发送给具有不活跃项目的所有者和维护者角色的用户。
   - 邮件发送的持续时间必须小于 **项目删除后** 的持续时间。
1. 选择 **保存更改**。

符合条件的不活跃项目会被安排删除，并发送警告邮件。如果项目仍然不活跃，它们将在指定的持续时间后被删除。即使 [项目已被归档](../user/project/working_with_projects.md#archive-a-project)，这些项目也会被删除。

<a id="configuration-example"></a>

### 配置示例

<a id="example-1"></a>

#### 示例 1

如果您使用以下设置：

- **删除不活跃项目** 已启用。
- **删除超过的项目** 设置为 `50`。
- **项目删除后** 设置为 `12`。
- **发送警告邮件** 设置为 `6`。

如果项目小于 50 MB，该项目不会被视为不活跃。

如果项目大于 50 MB，并且不活跃时间为：

- 超过 6 个月：发送删除警告邮件。此邮件包括项目将被删除的日期。
- 超过 12 个月：该项目被安排删除。

<a id="example-2"></a>

#### 示例 2

如果您使用以下设置：

- **删除不活跃项目** 已启用。
- **删除超过的项目** 设置为 `0`。
- **项目删除后** 设置为 `12`。
- **发送警告邮件** 设置为 `11`。

如果在您配置这些设置时，已经存在不活跃超过 12 个月的项目：

- 删除警告邮件立即发送。此邮件包括项目将被删除的日期。
- 项目在警告邮件发送后 1 个月（12 个月 - 11 个月）被安排删除。

<a id="determine-when-a-project-was-last-active"></a>

## 确定项目上次活跃时间

您可以通过以下方式查看项目的活动并确定项目上次活跃的时间：

- 转到项目的 [活动页面](../user/project/working_with_projects.md#view-project-activity)，查看最新事件的日期。
- 使用 [项目 API](../api/projects.md) 查看项目的 `last_activity_at` 属性。
- 使用 [事件 API](../api/events.md#list-a-projects-visible-events) 列出项目的可见事件。查看最新事件的 `created_at` 属性。
