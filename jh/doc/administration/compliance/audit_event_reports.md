---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 审计事件管理
description: View, export, and manage audit events for the 极狐GitLab instance, including CSV encoding and user impersonation.
---

除了[审计事件](../../user/compliance/audit_events.md)之外，作为管理员，您还可以访问其他功能。

<a id="instance-audit-events"></a>

## 实例审计事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以查看整个 极狐GitLab 实例中用户操作的审计事件。
要查看实例审计事件：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **监控** > **审计事件**。
1. 按以下条件过滤：
   - 执行操作的项目成员（用户）
   - 群组
   - 项目
   - 日期范围

实例审计事件也可以通过[实例审计事件 API](../../api/audit_events.md#instance-audit-events) 访问。

<a id="exporting-audit-events"></a>

## 导出审计事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 16.2 中，为实例审计事件引入了 Entity 类型 `Gitlab::Audit::InstanceScope`。

{{< /history >}}

您可以以 CSV（逗号分隔值）文件格式导出实例审计事件的当前视图（包括筛选条件）。要将实例审计事件导出为 CSV：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **监控** > **审计事件**。
1. 选择可用的搜索过滤器。
1. 选择 **导出为 CSV**。

随即出现下载确认对话框，供您下载 CSV 文件。导出的 CSV 最多包含 100,000 个事件，达到此限制时，其余记录将被截断。

<a id="audit-event-csv-encoding"></a>

### 审计事件 CSV 编码

导出的 CSV 文件编码如下：

- `,` 用作列分隔符
- `"` 用于在必要时引用字段。
- `\n` 用于分隔行。

第一行包含标题，下表列出了这些标题及其值的描述：

| 列                | 描述                                                                        |
| --------------------- | ---------------------------------------------------------------------------------- |
| **ID**                | 审计事件 `id`。                                                                  |
| **Author ID**         | 作者的 ID。                                                                  |
| **Author Name**       | 作者的全名。                                                           |
| **Entity ID**         | 作用域的 ID。                                                                   |
| **Entity Type**       | 作用域的类型（`Project`、`Group`、`User` 或 `Gitlab::Audit::InstanceScope`）。 |
| **Entity Path**       | 作用域的路径。                                                                 |
| **Target ID**         | 目标的 ID。                                                                  |
| **Target Type**       | 目标的类型。                                                                |
| **Target Details**    | 目标的详细信息。                                                             |
| **Action**            | 操作的描述。                                                         |
| **IP Address**        | 执行操作的作者的 IP 地址。                                        |
| **Created At (UTC)**  | 格式为 `YYYY-MM-DD HH:MM:SS`。                                                |

所有项按 `created_at` 升序排列。

<a id="user-impersonation"></a>

## 用户模拟

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

当用户被[模拟](../admin_area.md#user-impersonation)时，其操作会记录为审计事件，并附带以下额外详细信息：

- 审计事件包括有关模拟管理员的信息。
- 为管理员模拟会话的开始和结束记录额外的审计事件。

![一个带有模拟用户的审计事件。](img/impersonated_audit_events_v15_7.png)

<a id="time-zones"></a>

## 时区

有关时区和审计事件的信息，请参见[时区](../../user/compliance/audit_events.md#time-zones)。

<a id="contribute-to-audit-events"></a>

## 贡献审计事件

有关贡献审计事件的信息，请参见[贡献审计事件](../../user/compliance/audit_events.md#contribute-to-audit-events)。