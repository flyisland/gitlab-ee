---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 导出议题到 CSV
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- `IID`、`Type`、`Start Date` 和 `Parent IID` 列于极狐GitLab 18.4 添加。

{{< /history >}}

你可以从极狐GitLab 中将议题导出为纯文本 CSV（[逗号分隔值](https://en.wikipedia.org/wiki/Comma-separated_values)）文件。CSV 文件会作为邮件附件发送到你默认的通知邮箱地址。

<!-- vale gitlab_base.Spelling = NO -->

CSV 文件可用于任何绘图或电子表格程序，如 Microsoft Excel、OpenOffice Calc 或 Google Sheets。使用议题的 CSV 列表可以：

<!-- vale gitlab_base.Spelling = YES -->

- 创建议题快照用于离线分析，或与可能不在极狐GitLab 中的其他团队共享。
- 从 CSV 数据创建图表、图形。
- 将数据转换为其他格式以便审计或分享。
- 将议题导入到极狐GitLab 之外的系统。
- 使用随时间创建的多个快照分析长期趋势。
- 使用长期数据收集议题中给出的相关反馈，并根据实际指标改进你的产品。

<a id="select-issues-to-export"></a>

## 选择要导出的议题

你可以从单个项目中导出议题，但不能从群组中导出。

先决条件：

- 你必须具有访客、计划者、报告者、开发者、维护者或所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后通过 **类型** = **议题** 进行过滤。
1. 可选。选择额外的筛选器、运算符和值来导出议题的子集。更多信息，请参见[筛选议题列表](managing_issues.md#filter-the-list-of-issues)。
1. 在右上角，选择 **操作** ({{< icon name="ellipsis_v" >}}) > **导出为 CSV**。
1. 在弹出的对话框中，确认邮箱地址正确，然后选择 **导出议题**。

所有匹配的议题都会被导出，包括那些未在第一页显示的议题。
导出的 CSV 不包含议题中的附件。

<a id="format"></a>

## 格式

CSV 文件遵循以下格式：

- 按标题排序。
- 列以逗号分隔。
- 如有需要，字段会用双引号 (`"`) 括起来。
- 换行符分隔各行。

> [!note]
> 有关可能影响导出文件在极狐GitLab 中显示效果的 CSV 解析要求，请参见 [CSV 解析注意事项](../repository/files/csv.md#csv-parsing-considerations)。

<a id="columns"></a>

## 列

CSV 文件中包含以下列。

| 列 | 描述 |
| ----------------- | ----------- |
| ID | 议题 `id` |
| IID | 议题 `iid` |
| 标题 | 议题 `title` |
| 描述 | 议题 `description` |
| 类型 | 议题 `type` |
| URL | 指向极狐GitLab 上该议题的链接 |
| 状态 | `打开` 或 `已关闭` |
| 机密 | `是` 或 `否` |
| 锁定 | `是` 或 `否` |
| 里程碑 | 议题里程碑的标题 |
| 标签 | 标签，以逗号分隔 |
| 作者 | 议题作者的全名 |
| 作者用户名 | 作者的用户名，省略 `@` 符号 |
| 指派人 | 议题指派人的全名 |
| 指派人用户名 | 指派人的用户名，省略 `@` 符号 |
| 创建时间 (UTC) | 格式为 `YYYY-MM-DD HH:MM:SS` |
| 更新时间 (UTC) | 格式为 `YYYY-MM-DD HH:MM:SS` |
| 关闭时间 (UTC) | 格式为 `YYYY-MM-DD HH:MM:SS` |
| 截止日期 | 格式为 `YYYY-MM-DD` |
| 开始日期 | 格式为 `YYYY-MM-DD` |
| 父级 ID | 父级的 ID |
| 父级 IID | 父级的 IID |
| 父级标题 | 父级的标题 |
| 时间预估 | [时间预估](../time_tracking.md#estimates)，以秒为单位 |
| 已花费时间 | [已花费时间](../time_tracking.md#time-spent)，以秒为单位 |
| 权重 | 议题权重 |

<a id="troubleshooting"></a>

## 疑难排解

在处理导出的议题时，你可能会遇到以下问题。

### 导出文件大小

议题作为邮件附件发送，导出限制为 15 MB，以确保能在各类邮件服务提供商中成功送达。如果达到限制，请在导出前缩小搜索范围。例如，可以考虑分别导出打开和已关闭的议题。