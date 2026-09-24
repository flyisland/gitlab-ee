---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 CSV 导入议题
description: "通过上传 CSV 文件将议题导入到项目中。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以通过上传包含以下列的 CSV（逗号分隔值）文件，将议题导入到项目中：

| 名称          | 是否必需                             | 描述 |
| ------------- | ------------------------------------ | ----------- |
| `title`       | {{< yes >}} | 议题标题。 |
| `description` | {{< yes >}} | 议题描述。 |
| `due_date`    | {{< no >}} | 议题截止日期，格式为 `YYYY-MM-DD`。 |
| `milestone`   | {{< no >}} | 议题里程碑的标题。 |
| `type`        | {{< no >}} | 议题类型。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/200893)于极狐GitLab 18.4。 |

其他列中的数据不会被导入。

您可以使用 `description` 字段嵌入[快速操作](../quick_actions.md)，为议题添加其他数据。
例如，标记、指派人和里程碑。

或者，您可以[移动议题](managing_issues.md#move-an-issue)。移动议题会保留更多数据。

上传 CSV 文件的用户将被设置为所导入议题的作者。

您必须拥有项目的计划者、报告者、安全管理员、开发者、维护者或所有者角色，才能导入议题。

<a id="prepare-for-the-import"></a>

## 导入准备

- 考虑先导入一个仅包含少量议题的测试文件。如果不使用极狐GitLab API，则无法撤销大规模导入。
- 确保您的 CSV 文件符合[文件格式](#csv-file-format)要求。
- 如果您的 CSV 包含里程碑表头，请确保文件中所有唯一的里程碑标题已存在于该项目或其父群组中。

<a id="import-the-file"></a>

## 导入文件

要导入议题：

1. 转到您项目的**议题**页面。
1. 根据项目是否已有议题，打开导入功能：
   - 项目已有议题：在右上角，**批量编辑**旁边，选择 **操作** ({{< icon name="ellipsis_v" >}}) > **导入 CSV**。
   - 项目没有议题：在页面中间，选择 **导入 CSV**。
1. 选择要导入的文件，然后选择 **导入议题**。

文件将在后台处理，如果检测到任何错误或导入完成后，系统会向您发送通知邮件。

<a id="csv-file-format"></a>

## CSV 文件格式

要导入议题，极狐GitLab 要求 CSV 文件具有特定格式。

> [!note]
> 有关可能影响导入文件在极狐GitLab 中显示方式的 CSV 解析要求，请参阅 [CSV 解析注意事项](../repository/files/csv.md#csv-parsing-considerations)。

| 元素                | 格式 |
| ---------------------- | ------ |
| 表头行             | CSV 文件必须包含以下表头：`title` 和 `description`。表头的大小写无关紧要。 |
| 列                | 位于 `title`、`description`、`due_date`、`milestone` 和 `type` 之外的列数据不会被导入。 |
| 分隔符             | 列分隔符从表头行检测。支持的分隔符字符包括逗号 (`,`)、分号 (`;`) 和制表符 (`\t`)。行分隔符可以是 `CRLF` 或 `LF`。 |
| 双引号字符 | 双引号 (`"`) 字符用于引用字段，从而允许在字段中使用列分隔符（请参阅下方示例 CSV 数据中的第三行）。要在带引号的字段中插入双引号 (`"`)，请连续使用两个双引号字符 (`""`)。 |
| 数据行              | 在表头行之后，后续行必须使用相同的列顺序。议题标题为必填项，但描述为可选项。 |

如果字段中包含特殊字符（例如，`,` 或 `\n`）或多行内容（例如，
使用[快速操作](../quick_actions.md)时），请使用双引号 (`"`) 将这些字符括起来。

此外，使用[快速操作](../quick_actions.md)时：

- 每个操作必须单独占一行。
- 对于 `/label` 和 `/milestone` 等快速操作，标记或里程碑必须已存在于项目中。
- 您指派议题的用户必须是该项目的成员。

示例 CSV 数据：

```plaintext
title,description,due_date,milestone
My Issue Title,My Issue Description,2022-06-28
Another Title,"A description, with a comma",
"One More Title","One More Description",
An Issue with Quick Actions,"Hey can we change the frontend?

/assign @sjones
/label ~frontend ~documentation",
An issue with milestone,"My milestone is created",,v1.0
```

<a id="file-size"></a>

### 文件大小

限制取决于您的极狐GitLab 实例的托管方式：

- 极狐GitLab 私有化部署：由极狐GitLab 实例的 `Max Attachment Size` 配置值设置。
- JihuLab.com：限制为 10 MB。
