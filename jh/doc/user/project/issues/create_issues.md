---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 创建议题
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

创建议题时，系统会提示您输入议题的字段。
如果您知道要为议题分配的值，可以使用
[快速操作](../quick_actions.md) 输入这些值。

您可以通过多种方式在极狐GitLab 中创建议题：

- [从项目创建](#from-a-project)
- [从群组创建](#from-a-group)
- [从其他议题或事件创建](#from-another-issue-or-incident)
- [从议题看板创建](#from-an-issue-board)
- [通过发送电子邮件创建](#by-sending-an-email)
- [使用带预填值的 URL 创建](#using-a-url-with-prefilled-values)
- [使用服务台](#using-service-desk)

<a id="from-a-project"></a>

## 从项目创建

先决条件：

- 您必须对该项目拥有访客、计划者、报告者、开发者、维护者或所有者角色。

要创建议题：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 执行以下任一操作：

   - 在左侧边栏中，选择 **计划** > **工作项**，然后在右上角选择 **新建项**。
   - 在右上角，选择加号 ({{< icon name="plus" >}})，然后在 **此项目中** 下，
     选择 **新建工作项**。

1. 从 **类型** 下拉列表中，选择 **议题**（如果尚未选择）。
1. 填写[字段](#fields-in-the-new-issue-form)。
1. 选择 **创建议题**。

新创建的议题将打开。

<a id="from-a-group"></a>

## 从群组创建

议题属于项目，但当您在群组中时，您可以访问和创建属于该群组中项目的议题。

先决条件：

- 您必须对群组中的项目拥有访客、计划者、报告者、开发者、维护者或所有者角色。

要从群组创建议题：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **计划** > **工作项**。
1. 在右上角，选择 **选择项目以创建议题**。
1. 选择您要为其创建议题的项目。该按钮现在会反映所选项目。
1. 选择 **在 `<project name>` 中新建议题**。
1. 填写[字段](#fields-in-the-new-issue-form)。
1. 选择 **创建议题**。

新创建的议题将打开。

您最近选择的项目将成为您下次访问的默认项目。
如果您大多为同一个项目创建议题，这可以为您节省大量时间。

<a id="from-another-issue-or-incident"></a>

## 从其他议题或事件创建

您可以从现有议题创建新议题。然后可以将这两个议题标记为相关。

先决条件：

- 您必须对该项目拥有访客、计划者、报告者、开发者、维护者或所有者角色。

要从其他议题创建议题：

1. 在现有议题中，选择 **议题操作** ({{< icon name="ellipsis_v" >}})。
1. 选择 **新建相关议题**。
1. 填写[字段](#fields-in-the-new-issue-form)。
   新议题表单有一个 **关联到议题 #123** 复选框，其中 `123` 是源议题的 ID。如果您保持选中此复选框，这两个议题将变为
   [已关联](related_issues.md)。
1. 选择 **创建议题**。

新创建的议题将打开。

<a id="from-an-issue-board"></a>

## 从议题看板创建

您可以从[议题看板](../issue_board.md)创建新议题。

先决条件：

- 您必须对该项目拥有访客、计划者、报告者、开发者、维护者或所有者角色。

要从项目议题看板创建议题：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **议题看板**。
1. 在看板列表顶部，选择 **创建新议题** ({{< icon name="plus-square" >}})。
1. 输入议题的标题。
1. 选择 **创建议题**。

要从群组议题看板创建议题：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **计划** > **议题看板**。
1. 在看板列表顶部，选择 **创建新议题** ({{< icon name="plus-square" >}})。
1. 输入议题的标题。
1. 在 **项目** 下，选择该议题应属于的群组中的项目。
1. 选择 **创建议题**。

议题创建后显示在看板列表中。它继承了列表的特征，例如，
如果列表按标记 `Frontend` 限定范围，则新议题也具有此标记。

<a id="by-sending-an-email"></a>

## 通过发送电子邮件创建

您可以在项目的 **议题** 页面上，通过发送电子邮件在该项目中创建议题。

先决条件：

- 您的极狐GitLab 实例必须已配置[接收邮件](../../../administration/incoming_email.md)，
  并支持[电子邮件子地址或捕获所有邮箱](../../../administration/incoming_email.md#requirements)。
- 议题列表中必须至少有一个议题。
- 您必须对该项目拥有访客、计划者、报告者、开发者、维护者或所有者角色。

要通过电子邮件向项目发送议题：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**。
1. 在右上角，选择 **更多操作** ({{< icon name="ellipsis_v" >}})，然后选择 **通过电子邮件向此项目发送工作项**。
1. 要复制电子邮件地址，请选择 **复制** ({{< icon name="copy-to-clipboard" >}})。
1. 从您的电子邮件客户端，向此地址发送电子邮件。
   主题将用作新议题的标题，电子邮件正文将成为描述。
   您可以使用 [Markdown](../../markdown.md) 和 [快速操作](../quick_actions.md)。

将创建一个新议题，作者为您。
您可以将此地址保存为电子邮件客户端中的联系人，以便再次使用。

> [!warning]
> 您看到的电子邮件地址是专门为您生成的私有电子邮件地址。
> **请勿泄露**，因为任何知道此地址的人都可以冒充您创建议题或合并请求。
> 如果您怀疑此私有电子邮件地址已泄露，请立即重置令牌。

要重置电子邮件地址：

1. 在 **议题** 页面上，选择 **通过电子邮件向此项目发送议题**。
1. 选择 **重置此令牌**。

<a id="using-a-url-with-prefilled-values"></a>

## 使用带预填值的 URL

要直接链接到带有预填字段的新议题页面，请在 URL 中使用查询字符串参数。您可以在外部 HTML 页面中嵌入 URL，以创建带有某些预填字段的议题。

要构建带有预填值的议题创建 URL，请组合：

1. 项目或群组的议题页面 URL，后跟 `/new`。
   例如：`https://gitlab.com/gitlab-org/gitlab/-/work_items/new`

1. `?` 开始列出参数。
1. URL 参数，后跟 `=` 和值。
   例如：`issue[title]=My%20test%20issue`。
1. 可选。`&` 连接更多参数。

| 字段                                                                                          | URL 参数          | 备注 |
| ---------------------------------------------------------------------------------------------- | ---------------------- | ----- |
| 标题                                                                                          | `issue[title]`         | 必须进行 [URL 编码](../../../api/rest/_index.md#namespaced-paths)。 |
| 议题类型                                                                                     | `issue[issue_type]`    | 可以是 `incident` 或 `issue`。 |
| 描述模板（议题、事件和合并请求）                                   | `issuable_template`    | 必须进行 [URL 编码](../../../api/rest/_index.md#namespaced-paths)。 |
| 描述模板（任务、OKR、议题和史诗） | `description_template` | 必须进行 [URL 编码](../../../api/rest/_index.md#namespaced-paths)。在极狐GitLab 17.9 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/513095)。 |
| 描述 | `issue[description]` | 必须进行 [URL 编码](../../../api/rest/_index.md#namespaced-paths)。如果与 `issuable_template` 或[默认议题模板](../description_templates.md#set-a-default-template-for-merge-requests-and-issues)结合使用，则 `issue[description]` 值会覆盖模板。 |
| 机密                                                                                   | `issue[confidential]`  | 如果为 `true`，则该议题被标记为机密。 |
| 关联到…                                                                                     | `add_related_issue`    | 一个数字议题 ID。如果存在，议题表单会显示一个 [**关联到** 复选框](#from-another-issue-or-incident)，用于选择性地将新议题链接到指定的现有议题。 |

在[极狐GitLab 17.8 及更高版本](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/177215)中，
当您选择议题模板时，URL 会更改以显示所使用的模板。

调整以下示例以构建带有预填字段的新议题 URL。
要在 GitLab 项目中创建议题：

- 带有预填标题和描述：

  ```plaintext
  https://gitlab.com/gitlab-org/gitlab/-/work_items/new?issue[title]=Whoa%2C%20we%27re%20half-way%20there&issue[description]=Whoa%2C%20livin%27%20in%20a%20URL
  ```

- 带有预填标题和描述模板：

  ```plaintext
  https://gitlab.com/gitlab-org/gitlab/-/work_items/new?issue[title]=Validate%20new%20concept&issuable_template=Feature%20Proposal%20-%20basic
  ```

- 带有预填标题、描述，并标记为机密：

  ```plaintext
  https://gitlab.com/gitlab-org/gitlab/-/work_items/new?issue[title]=Validate%20new%20concept&issue[description]=Research%20idea&issue[confidential]=true
  ```

<a id="using-service-desk"></a>

## 使用服务台

要提供电子邮件支持，请为您的项目启用 [服务台](../service_desk/_index.md)。

现在，当您的客户发送新电子邮件时，可以在适当的项目中创建新议题，并从此处进行跟进。

<a id="fields-in-the-new-issue-form"></a>

## 新议题表单中的字段

创建新议题时，您可以填写以下字段：

- 标题：[有限格式支持](../../markdown.md#work-item-and-merge-request-titles)
- 项目：默认为当前项目
- 类型：议题（默认）或事件
- [描述模板](../description_templates.md)：覆盖描述文本框中的任何内容
- 描述：您可以使用 [Markdown](../../markdown.md) 和 [快速操作](../quick_actions.md)
- 将议题设为[机密](confidential_issues.md)的复选框
- [指派人](managing_issues.md#assignees)
- [权重](../../work_items/weight.md)
- [父项](../../group/epics/_index.md)
- [日期](due_dates.md)
- [里程碑](../milestones/_index.md)
- [标记](../labels.md)
- [迭代](../../group/iterations/_index.md)
- [健康状态](managing_issues.md#health-status)
- [联系人](../../crm/_index.md)
