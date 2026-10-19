---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 审计事件管理
description: 查看、导出和管理极狐GitLab 实例的审计事件，包括 CSV 编码和用户模拟。
---

除了[审计事件](../../user/compliance/audit_events.md)之外，作为管理员，您还可以使用其他功能。

<a id="instance-audit-events"></a>

## 实例审计事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以查看整个极狐GitLab 实例中用户操作产生的审计事件。要查看实例审计事件：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **审计事件**。
1. 按以下条件筛选：
   - 执行操作所针对的用户
   - 执行操作所针对的群组
   - 执行操作所针对的项目
   - 日期范围

实例审计事件也可以通过[实例审计事件 API](../../api/audit_events.md#instance-audit-events) 访问。

<a id="exporting-audit-events"></a>

## 导出审计事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以将实例审计事件的当前视图（包括筛选条件）导出为 CSV（逗号分隔值）文件。要将实例审计事件导出为 CSV：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **审计事件**。
1. 选择可用的搜索筛选条件。
1. 选择**导出为 CSV**。

随后会出现下载确认对话框，供您下载 CSV 文件。导出的 CSV 最多包含 100000 个事件。达到此上限时，其余记录会被截断。

<a id="audit-event-csv-encoding"></a>

### 审计事件 CSV 编码

导出的 CSV 文件编码方式如下：

- 使用 `,` 作为列分隔符
- 必要时使用 `"` 引用字段。
- 使用 `\n` 分隔行。

第一行包含表头，下表列出了这些表头及其值的说明：

| 列                    | 描述                                                                        |
| --------------------- | ---------------------------------------------------------------------------------- |
| **ID**                | 审计事件 `id`。                                                                  |
| **Author ID**         | 作者的 ID。                                                                  |
| **Author Name**       | 作者的全名。                                                           |
| **Entity ID**         | 范围的 ID。                                                                   |
| **Entity Type**       | 范围的类型（`Project`、`Group`、`User` 或 `Gitlab::Audit::InstanceScope`）。 |
| **Entity Path**       | 范围的路径。                                                                 |
| **Target ID**         | 目标的 ID。                                                                  |
| **Target Type**       | 目标的类型。                                                                |
| **Target Details**    | 目标的详细信息。                                                             |
| **Action**            | 操作的描述。                                                         |
| **IP Address**        | 执行该操作的作者的 IP 地址。                                 |
| **Created At (UTC)**  | 格式为 `YYYY-MM-DD HH:MM:SS`。                                                |

所有条目均按 `created_at` 升序排序。

<a id="user-impersonation"></a>

## 用户模拟

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

当用户被[模拟](../admin_area.md#user-impersonation)时，其操作会作为审计事件记录，并包含以下附加详细信息：

- 审计事件包含有关执行模拟的管理员的信息。
- 管理员模拟会话的开始和结束会记录额外的审计事件。

![带有被模拟用户的审计事件。](img/impersonated_audit_events_v15_7.png)

<a id="time-zones"></a>

## 时区

有关时区和审计事件的信息，请参阅[时区](../../user/compliance/audit_events.md#time-zones)。

<a id="contribute-to-audit-events"></a>

## 为审计事件贡献

有关为审计事件贡献的信息，请参阅[为审计事件贡献](../../user/compliance/audit_events.md#contribute-to-audit-events)。
