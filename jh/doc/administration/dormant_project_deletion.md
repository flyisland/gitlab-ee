---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 休眠项目删除
description: 配置休眠项目的删除。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

随着时间的推移，大型极狐GitLab 实例中的项目可能会进入休眠状态，并占用不必要的磁盘空间。

您可以配置极狐GitLab，使其在项目超过特定无活动期限后自动删除休眠项目。当项目在此定义期限内无任何活动时：

- 维护者会收到警告通知，告知计划中的删除操作。
- 如果项目仍无活动，极狐GitLab 会在期限到期时将其删除。
- 删除发生时，极狐GitLab 会生成一条审计事件，显示删除操作由 @GitLab-Admin-Bot 执行。

有关 JihuLab.com 上的默认设置，请参阅 [JihuLab.com 设置](../user/jihulab_com/_index.md#inactive-project-deletion)。

<a id="configure-dormant-project-deletion"></a>

## 配置休眠项目删除

先决条件：

- 管理员访问权限。

要配置休眠项目的删除：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **代码仓库**。
1. 展开 **代码仓库维护**。
1. 在 **休眠项目删除** 部分，选择 **删除休眠项目**。
1. 配置设置。
   - 警告邮件会发送给对休眠项目拥有所有者或维护者角色的用户。
   - 邮件发送期限必须短于 **项目删除期限**。
1. 选择 **保存更改**。

符合标准的休眠项目会被安排删除，并发送警告邮件。如果项目仍处于休眠状态，则会在指定期限后删除。即使
[项目已归档](../user/project/working_with_projects.md#archive-a-project)，这些项目也会被删除。

<a id="configuration-example"></a>

### 配置示例

<a id="example-1"></a>

#### 示例 1

如果您使用以下设置：

- 启用 **删除休眠项目**。
- 将 **删除超过以下大小的休眠项目** 设置为 `50`。
- 将 **项目删除期限** 设置为 `12`。
- 将 **发送警告邮件** 设置为 `6`。

如果项目小于 50 MB，则该项目不被视为休眠项目。

如果项目大于 50 MB 且休眠时间：

- 超过 6 个月：会发送删除警告邮件。此邮件包含项目计划删除的日期。
- 超过 12 个月：项目会被安排删除。

<a id="example-2"></a>

#### 示例 2

如果您使用以下设置：

- 启用 **删除休眠项目**。
- 将 **删除超过以下大小的休眠项目** 设置为 `0`。
- 将 **项目删除期限** 设置为 `12`。
- 将 **发送警告邮件** 设置为 `11`。

由于大小限制已设置为 0 MB，实例中的所有项目均涵盖在内。如果项目休眠时间：

- 超过 11 个月：会发送删除警告邮件。此邮件包含项目计划删除的日期。
- 超过 12 个月：项目会被安排删除。

如果配置这些设置时，已存在休眠超过 12 个月的项目：

- 会立即发送删除警告邮件。此邮件包含项目计划删除的日期。
- 项目会在警告邮件发送后 1 个月（12 个月 - 11 个月）被安排删除。

<a id="determine-when-a-project-was-last-active"></a>

## 确定项目上次活动时间

您可以通过以下方式查看项目的活动并确定项目上次活动时间：

- 转到项目的[活动页面](../user/project/working_with_projects.md#view-project-activity)，查看
  最新事件的日期。
- 使用 [Projects API](../api/projects.md) 查看项目的以下属性：
  - `last_activity_at` 每小时更新一次，主要跟踪事件。它还跟踪项目和路径重命名以及描述编辑。
  - `updated_at` 在项目保存时更新。
- 使用 [Events API](../api/events.md#list-all-visible-events-for-a-project) 列出项目的可见事件。
  查看最新事件的 `created_at` 属性。
