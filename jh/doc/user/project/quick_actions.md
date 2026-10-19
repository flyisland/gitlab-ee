---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 快速操作
description: 命令、快捷方式和内联操作。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

快速操作提供了在极狐GitLab 中执行常见操作的基于文本的快捷方式。
快速操作：

- 无需使用用户界面即可执行常见操作。
- 支持处理议题、合并请求、史诗和提交。
- 在您保存描述或评论时自动运行。
- 响应特定的上下文和条件。
- 在单独的行中输入时，可处理多个命令。

例如，您可以使用快速操作来：

- 指派用户。
- 添加标记。
- 设置截止日期。
- 更改状态。
- 设置其他属性。

每个命令都以斜杠 (`/`) 开头，并且必须单独占一行。
许多快速操作接受参数，您可以使用引号 (`"`) 或特定格式输入这些参数。

<a id="parameters"></a>

## 参数

许多快速操作需要参数。例如，`/assign` 快速操作
需要用户名。极狐GitLab 使用 [自动补全字符](autocomplete_characters.md)
与快速操作结合，通过提供可用值列表来帮助用户输入参数。

如果您手动输入参数，则必须用双引号
(`"`) 括起来，除非它仅包含以下字符：

- ASCII 字母
- 数字 (0-9)
- 下划线 (`_`)、连字符 (`-`)、问号 (`?`)、点 (`.`)、与号 (`&`) 或 at (`@`)

参数区分大小写。自动补全会自动处理这一点以及引号的插入。

<a id="quick-actions"></a>

## 快速操作

以下快速操作适用于描述、讨论和
讨论串。某些快速操作可能并非对所有订阅层级都可用。

<a id="add_child"></a>

### `add_child`

将一个或多个项添加为子项。

**可用性**：

- 史诗（添加议题、任务、目标或关键结果）
- 议题（添加任务、目标或关键结果）
- 目标（添加目标或关键结果）

**参数**：

- `<item>`：要添加为子项的项。该值应采用 `#item`、`group/project#item` 或该项的 URL 格式。
  可以同时将多个工作项添加为子项。

**示例**：

- 添加单个子项：

  ```plaintext
  /add_child #123
  ```

- 添加多个子项：

  ```plaintext
  /add_child #123 #456 group/project#789
  ```

- 使用 URL 添加子项：

  ```plaintext
  /add_child https://gitlab.com/group/project/-/work_items/123
  ```

<a id="add_contacts"></a>

### `add_contacts`

添加一个或多个活跃的 CRM 联系人。

**可用性**：

- 议题

**参数**：

- `[contact:email1@example.com]`：一个或多个联系人电子邮件，格式为 `contact:email@example.com`。

**示例**：

- 添加单个联系人：

  ```plaintext
  /add_contacts [contact:alex@example.com]
  ```

- 添加多个联系人：

  ```plaintext
  /add_contacts [contact:alex@example.com] [contact:sam@example.com]
  ```

**其他详细信息**：

- 有关更多信息，请参阅 [CRM 联系人](../crm/_index.md)。

<a id="add_email"></a>

### `add_email`

添加最多六个电子邮件参与者。

**可用性**：

- 事件
- 议题

**参数**：

- `email1 email2`：一个或多个电子邮件地址，以空格分隔。

**示例**：

- 添加单个电子邮件参与者：

  ```plaintext
  /add_email alex@example.com
  ```

- 添加多个电子邮件参与者：

  ```plaintext
  /add_email alex@example.com sam@example.com
  ```

**其他详细信息**：

- 在 [议题模板](description_templates.md) 中不受支持。
- 有关更多信息，请参阅 [电子邮件参与者](service_desk/external_participants.md)。

<a id="approve"></a>

### `approve`

批准合并请求。

**可用性**：

- 合并请求

**示例**：

- 批准合并请求：

  ```plaintext
  /approve
  ```

**其他详细信息**：

- 要取消批准合并请求，请使用 [`/unapprove`](#unapprove)。

<a id="assign"></a>

### `assign`

将一个或多个用户指派给工作项。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**参数**：

- `@user1 @user2`：要指派的一个或多个用户名。用户名必须以 `@` 为前缀。
- `me`：将您自己指派给工作项。

**示例**：

- 指派单个用户：

  ```plaintext
  /assign @alex
  ```

- 指派多个用户：

  ```plaintext
  /assign @alex @sam
  ```

- 指派您自己：

  ```plaintext
  /assign me
  ```

**其他详细信息**：

- 您可以在单个命令中通过空格分隔用户名来指派多个用户。
- 要移除指派人，请使用 [`/unassign`](#unassign)。
- 要替换指派人，请使用 [`/reassign`](#reassign)。

<a id="assign_reviewer"></a>

### `assign_reviewer`

将一个或多个用户指派为审核人，或向现有审核人请求新的评审。

**[`/request_review`](#request_review) 的别名。**

**可用性**：

- 合并请求

**参数**：

- `@user1 @user2`：要指派为审核人的一个或多个用户名。用户名必须以 `@` 为前缀。
- `me`：将您自己指派为审核人。

**示例**：

- 指派单个审核人：

  ```plaintext
  /assign_reviewer @alex
  ```

- 指派多个审核人：

  ```plaintext
  /assign_reviewer @alex @sam
  ```

- 将您自己指派为审核人：

  ```plaintext
  /assign_reviewer me
  ```

**其他详细信息**：

- 如果用户还不是审核人，则将其指派为审核人。
- 如果用户已经是审核人，则向他们请求新的评审（重置其评审状态并发送通知）。
- 您可以在单个命令中通过空格分隔用户名来指派多个用户。
- `/reviewer` 也是此命令的别名。
- 要替换审核人，请使用 [`/reassign_reviewer`](#reassign_reviewer)。
- 要移除审核人，请使用 [`/unassign_reviewer`](#unassign_reviewer)。
- 有关更多信息，请参阅 [`/request_review`](#request_review)。

<a id="award"></a>

### `award`

切换表情符号反应。

**可用性**：

- 任务
- 目标
- 关键结果

**参数**：

- `:emoji:`：要切换的表情符号。必须采用 `:emoji_name:` 格式。

**示例**：

- 切换点赞反应：

  ```plaintext
  /award :thumbsup:
  ```

- 切换爱心反应：

  ```plaintext
  /award :heart:
  ```

**其他详细信息**：

- `/award` 是 `/react` 的别名。
- 有关更多信息，请参阅 [表情符号反应](../emoji_reactions.md)。

<a id="blocked_by"></a>

### `blocked_by`

将该项标记为被其他项阻塞。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求

**参数**：

- `<item1> <item2>`：阻塞此项的一个或多个项。该值应采用 `#item`、`group/project#item` 或完整 URL 的格式。对于合并请求，请使用 `!merge_request`、`group/project!merge_request` 或合并请求 URL。

**示例**：

- 标记为被单个项阻塞：

  ```plaintext
  /blocked_by #123
  ```

- 标记为被多个项阻塞：

  ```plaintext
  /blocked_by #123 group/project#456
  ```

- 使用 URL 标记为被项阻塞：

  ```plaintext
  /blocked_by https://gitlab.com/group/project/-/work_items/123
  ```

- 将合并请求标记为被另一个合并请求阻塞：

  ```plaintext
  /blocked_by !456
  ```

**其他详细信息**：

- 要移除阻塞关系，请使用 [`/unlink`](#unlink)。
- 要将这些项标记为相关（互不阻塞），请使用 [`/relate`](#relate)。

<a id="blocks"></a>

### `blocks`

将该项标记为阻塞其他项。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求

**参数**：

- `<item1> <item2>`：此项阻塞的一个或多个项。该值应采用 `#item`、`group/project#item` 或完整 URL 的格式。对于合并请求，请使用 `!merge_request`、`group/project!merge_request` 或合并请求 URL。

**示例**：

- 标记为阻塞单个项：

  ```plaintext
  /blocks #123
  ```

- 标记为阻塞多个项：

  ```plaintext
  /blocks #123 group/project#456
  ```

- 使用 URL 标记为阻塞项：

  ```plaintext
  /blocks https://gitlab.com/group/project/-/work_items/123
  ```

- 将合并请求标记为阻塞另一个合并请求：

  ```plaintext
  /blocks !456
  ```

**其他详细信息**：

- 要移除阻塞关系，请使用 [`/unlink`](#unlink)。
- 要将这些项标记为相关（互不阻塞），请使用 [`/relate`](#relate)。

<a id="board_move"></a>

### `board_move`

将议题移动到看板上的列。

**可用性**：

- 议题

**参数**：

- `~column`：要将议题移动到的看板列的标记名称。必须以 `~` 为前缀。

**示例**：

- 移动到列：

  ```plaintext
  /board_move ~"In Progress"
  ```

**其他详细信息**：

- 项目必须只有一个议题看板。

<a id="checkin_reminder"></a>

### `checkin_reminder`

为目标安排签到提醒。

> [!flag]
> 此功能的可用性由功能标志控制。

**可用性**：

- 目标

**参数**：

- `<cadence>`：提醒频率。选项有：
  - `weekly`
  - `twice-monthly`
  - `monthly`
  - `never`（默认）

**示例**：

- 设置每周提醒：

  ```plaintext
  /checkin_reminder weekly
  ```

- 禁用提醒：

  ```plaintext
  /checkin_reminder never
  ```

**其他详细信息**：

- 有关更多信息，请参阅 [安排 OKR 签到提醒](../okrs.md#schedule-okr-check-in-reminders)。

<a id="clear_health_status"></a>

### `clear_health_status`

清除健康状态。

**可用性**：

- 史诗
- 议题
- 任务
- 目标
- 关键结果

**示例**：

- 清除健康状态：

  ```plaintext
  /clear_health_status
  ```

**其他详细信息**：

- 有关更多信息，请参阅 [健康状态](issues/managing_issues.md#health-status)。

<a id="clear_weight"></a>

### `clear_weight`

清除权重。

**可用性**：

- 议题
- 任务

**示例**：

- 清除权重：

  ```plaintext
  /clear_weight
  ```

<a id="clone"></a>

### `clone`

将工作项克隆到给定的群组或项目。

**可用性**：

- 史诗
- 事件
- 议题

**参数**：

- `<path/to/group_or_project>`：目标群组或项目的路径。如果未提供，则克隆到当前项目。
- `--with_notes`：可选标志，用于在克隆中包含评论和系统评论。
- `[type:<work item type>]`（可选）：在目标命名空间中使用的
  工作项类型。省略时，保留源工作项类型。
  多词类型名称（例如，`Key Result`）不需要引号，因为
  `]` 会终止该值。

**示例**：

- 克隆到另一个项目：

  ```plaintext
  /clone group/project
  ```

- 克隆到当前项目：

  ```plaintext
  /clone
  ```

- 带评论克隆：

  ```plaintext
  /clone group/project --with_notes
  ```

- 克隆到另一个项目并转换为特定工作项类型：

  ```plaintext
  /clone group/project [type:Issue]
  ```

- 使用多词类型名称克隆：

  ```plaintext
  /clone group/project [type:Key Result]
  ```

**其他详细信息**：

- 只要目标包含等效对象（如标记、里程碑或史诗），就会尽可能多地复制数据。
- 除非提供 `--with_notes` 作为参数，否则不复制评论或系统评论。
- 未提供类型时，保留源工作项类型。如果该类型在目标命名空间中不可用，则克隆失败。
- 提供类型时，工作项将转换为该类型。如果该类型在目标命名空间中不可用，则克隆失败。
- `[type:...]` 值将与目标命名空间中可用的工作项类型名称进行不区分大小写的匹配。
- 如果解析出的类型在目标命名空间中被禁用（已归档、管理员禁用或在目标上下文中不可见），则克隆失败。
- 克隆到同一命名空间时，会验证 `[type:...]` 参数，但不执行转换。克隆保留源工作项类型。
- 内置类型之间的基本类型转换（例如，`Issue`、`Task`、
  `Incident`）在所有层级上均可用。
- 自定义工作项类型和按命名空间的类型可见性是 JihuLab.com 上的专业版和
  旗舰版功能。如果根据您的订阅，目标命名空间中某个类型不可用，则克隆失败，错误消息会列出您可以使用的类型。

<a id="close"></a>

### `close`

关闭工作项。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**示例**：

- 关闭工作项：

  ```plaintext
  /close
  ```

**其他详细信息**：

- 要重新打开工作项，请使用 [`/reopen`](#reopen)。

<a id="confidential"></a>

### `confidential`

将工作项标记为机密。

**可用性**：

- 史诗
- 事件
- 议题
- 任务
- 目标
- 关键结果

**示例**：

- 标记为机密：

  ```plaintext
  /confidential
  ```

**其他详细信息**：

- 有关更多信息，请参阅 [谁可以查看机密议题](issues/confidential_issues.md#who-can-see-confidential-issues)、
  [OKR](../okrs.md#who-can-see-confidential-okrs) 或
  [任务](../tasks.md#who-can-see-confidential-tasks)。
- 要使某个项不再机密，请在右上角选择 **更多操作** ({{< icon name="ellipsis_v" >}})，然后选择 **关闭机密性**。

<a id="convert_to_ticket"></a>

### `convert_to_ticket`

将议题转换为服务台工单。

**可用性**：

- 事件
- 议题

**参数**：

- `<email address>`：要与工单关联的电子邮件地址。

**示例**：

- 转换为工单：

  ```plaintext
  /convert_to_ticket user@example.com
  ```

**其他详细信息**：

- 仅当项目已 [设置服务台](service_desk/configure.md) 时，此快速操作才可用。
  在极狐GitLab 私有化部署上，实例还必须
  配置 [传入电子邮件](../../administration/incoming_email.md)，并支持电子邮件子地址或捕获所有邮箱。
- 有关更多信息，请参阅 [将常规议题转换为服务台工单](service_desk/using_service_desk.md#convert-a-regular-issue-to-a-service-desk-ticket)。

<a id="copy_metadata"></a>

### `copy_metadata`

从另一个项复制标记和里程碑。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**参数**：

- `<#item>`：要从中复制元数据的项。对于合并请求，请使用格式 `!MR_IID`。对于其他项，请使用 `#item` 或 URL。

**示例**：

- 从议题复制元数据：

  ```plaintext
  /copy_metadata #123
  ```

- 从合并请求复制元数据：

  ```plaintext
  /copy_metadata !456
  ```

- 使用 URL 从工作项复制元数据：

  ```plaintext
  /copy_metadata https://gitlab.com/group/project/-/work_items/123
  ```

**其他详细信息**：

- 您要从中复制元数据的项必须位于同一命名空间中。

<a id="create_merge_request"></a>

### `create_merge_request`

从当前议题创建新的合并请求。

**可用性**：

- 事件
- 议题
- 任务

**参数**：

- `<branch name>`：要为合并请求创建的分支名称。

**示例**：

- 创建合并请求：

  ```plaintext
  /create_merge_request fix-bug-123
  ```

<a id="done"></a>

### `done`

将待办事项标记为已完成。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**示例**：

- 将待办事项标记为已完成：

  ```plaintext
  /done
  ```

<a id="draft"></a>

### `draft`

设置合并请求的草稿状态。

**可用性**：

- 合并请求

**示例**：

- 标记为草稿：

  ```plaintext
  /draft
  ```

**其他详细信息**：

- 有关更多信息，请参阅 [草稿状态](merge_requests/drafts.md)。

<a id="due"></a>

### `due`

设置截止日期。

**可用性**：

- 史诗
- 事件
- 议题
- 任务
- 关键结果

**参数**：

- `<date>`：截止日期。有效日期的示例包括 `in 2 days`、`this Friday` 和 `December 31st`。

**示例**：

- 将截止日期设置为特定日期：

  ```plaintext
  /due December 31st
  ```

- 将截止日期设置为相对于今天：

  ```plaintext
  /due in 2 days
  ```

- 将截止日期设置为下周五：

  ```plaintext
  /due this Friday
  ```

**其他详细信息**：

- 有关更多日期格式示例，请参阅 [Chronic 示例](https://gitlab.com/gitlab-org/ruby/gems/gitlab-chronic#examples)。
- 要移除截止日期，请使用 [`/remove_due_date`](#remove_due_date)。

<a id="duplicate"></a>

### `duplicate`

关闭此项，并将其标记为与另一项相关且重复。

**可用性**：

- 史诗
- 事件
- 议题

**参数**：

- `<item>`：此项重复的项。该值应采用 `#item`、`group/project#item` 或 URL 的格式。

**示例**：

- 标记为重复：

  ```plaintext
  /duplicate #123
  ```

- 使用 URL 标记为重复：

  ```plaintext
  /duplicate https://gitlab.com/group/project/-/work_items/123
  ```

<a id="epic"></a>

### `epic`

作为子项添加到史诗。

**可用性**：

- 史诗
- 议题

**参数**：

- `<epic>`：要将此项添加到的史诗。该值应采用 `&epic`、`#epic`、`group&epic`、`group#epic` 或史诗 URL 的格式。

**示例**：

- 通过引用添加到史诗：

  ```plaintext
  /epic &123
  ```

- 通过群组和引用添加到史诗：

  ```plaintext
  /epic group&456
  ```

- 使用 URL 添加到史诗：

  ```plaintext
  /epic https://gitlab.com/groups/group/-/epics/123
  ```

**其他详细信息**：

- `/set_parent` 行为相同，但可用于更多工作项类型。

<a id="estimate"></a>

### `estimate`

设置时间估算。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求

**参数**：

- `<time>`：时间估算。例如，`1mo 2w 3d 4h 5m`。

**示例**：

- 设置时间估算：

  ```plaintext
  /estimate 1mo 2w 3d 4h 5m
  ```

- 以小时为单位设置时间估算：

  ```plaintext
  /estimate 8h
  ```

**其他详细信息**：

- `/estimate_time` 是 `/estimate` 的别名。
- 要移除估算，请使用 [`/remove_estimate`](#remove_estimate)。
- 有关更多信息，请参阅 [时间跟踪](time_tracking.md)。

<a id="health_status"></a>

### `health_status`

设置健康状态。

**可用性**：

- 史诗
- 议题
- 任务
- 目标
- 关键结果

**参数**：

- `<value>`：健康状态值。有效选项为 `on_track`、`needs_attention` 和 `at_risk`。

**示例**：

- 将健康状态设置为正常：

  ```plaintext
  /health_status on_track
  ```

- 将健康状态设置为需要关注：

  ```plaintext
  /health_status needs_attention
  ```

- 将健康状态设置为有风险：

  ```plaintext
  /health_status at_risk
  ```

**其他详细信息**：

- 有关更多信息，请参阅 [健康状态](issues/managing_issues.md#health-status)。

<a id="internal_note"></a>

### `internal_note`

将评论设为内部评论。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 工单
- 目标
- 关键结果

**示例**：

- 将评论设为内部评论：

  ```plaintext
  This is an internal comment.
  /internal_note
  ```

**其他详细信息**：

- 您必须具有计划者、报告者、开发者、维护者或所有者角色。
- 您不能在描述中、作为非内部讨论的回复中或编辑现有评论时使用 `/internal_note`。
- 您不能将内部评论转换为常规评论。
- 有关更多信息，请参阅 [内部评论](../discussions/_index.md#add-an-internal-note)。

<a id="iteration"></a>

### `iteration`

设置迭代。

**可用性**：

- 事件
- 议题

**参数**：

- `*iteration:<iteration ID> or <iteration name>`：按 ID 或名称设置为特定迭代。
- `[cadence:<iteration cadence ID> or <iteration cadence name>] <--current or --next>`：设置为特定节奏的当前或下一个迭代。
- `--current` 或 `--next`：当群组只有一个迭代节奏时，设置为当前或下一个迭代。

**示例**：

- 按名称设置为特定迭代：

  ```plaintext
  /iteration *iteration:"Late in July"
  ```

- 设置为节奏的当前迭代：

  ```plaintext
  /iteration [cadence:"Team cadence"] --current
  ```

- 当群组只有一个节奏时，设置为下一个迭代：

  ```plaintext
  /iteration --next
  ```

**其他详细信息**：

- 要移除迭代，请使用 [`/remove_iteration`](#remove_iteration)。

<a id="label"></a>

### `label`

添加一个或多个标记。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**参数**：

- `~label1 ~label2`：一个或多个标记名称。
  标记名称也可以不带波浪号 (`~`) 开头，但不支持混合语法。

**示例**：

- 添加单个标记：

  ```plaintext
  /label ~bug
  ```

- 添加多个标记：

  ```plaintext
  /label ~bug ~"high priority"
  ```

- 不带波浪号添加标记：

  ```plaintext
  /label bug "high priority"
  ```

**其他详细信息**：

- 名称中包含空格的标记必须用双引号括起来。
- `/labels` 是 `/label` 的别名。
- 要移除标记，请使用 [`/unlabel`](#unlabel)。
- 要替换标记，请使用 [`/relabel`](#relabel)。

<a id="link"></a>

### `link`

在事件的链接资源中添加链接和描述。

**可用性**：

- 事件

**示例**：

- 添加链接资源：

  ```plaintext
  /link
  ```

**其他详细信息**：

- 有关更多信息，请参阅 [链接资源](../../operations/incident_management/linked_resources.md)。

<a id="lock"></a>

### `lock`

锁定讨论。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求

**示例**：

- 锁定讨论：

  ```plaintext
  /lock
  ```

**其他详细信息**：

- 要解锁讨论，请使用 [`/unlock`](#unlock)。

<a id="merge"></a>

### `merge`

合并更改。

**可用性**：

- 合并请求

**示例**：

- 合并合并请求：

  ```plaintext
  /merge
  ```

**其他详细信息**：

- 根据项目设置，这可能是 [当流水线成功时](merge_requests/auto_merge.md)，或添加到 [合并列车](../../ci/pipelines/merge_trains.md)。

<a id="milestone"></a>

### `milestone`

设置里程碑。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求

**参数**：

- `%milestone`：里程碑名称。必须以 `%` 为前缀。

**示例**：

- 设置里程碑：

  ```plaintext
  /milestone %"Sprint 1"
  ```

**其他详细信息**：

- 要移除里程碑，请使用 [`/remove_milestone`](#remove_milestone)。

<a id="move"></a>

### `move`

将工作项移动到另一个群组或项目。

**可用性**：

- 史诗
- 事件
- 议题

**参数**：

- `<path/to/group_or_project>`：目标群组或项目的路径。
- `[type:<work item type>]`（可选）：在目标命名空间中使用的
  工作项类型。省略时，保留源工作项类型。
  多词类型名称（例如，`Key Result`）不需要引号，因为
  `]` 会终止该值。

**示例**：

- 移动到另一个项目：

  ```plaintext
  /move group/project
  ```

- 移动到另一个项目并转换为特定工作项类型：

  ```plaintext
  /move group/project [type:Issue]
  ```

- 使用多词类型名称移动：

  ```plaintext
  /move group/project [type:Key Result]
  ```

**其他详细信息**：

- 将工作项移动到具有不同访问规则的位置时请务必小心。
  在移动工作项之前，请确保它不包含敏感数据。
- 未提供类型时，保留源工作项类型。如果该类型在目标命名空间中不可用，则移动失败。
- 提供类型时，工作项将转换为该类型。如果该类型在目标命名空间中不可用，则移动失败。
- `[type:...]` 值将与目标命名空间中可用的工作项类型名称进行不区分大小写的匹配。
- 如果解析出的类型在目标命名空间中被禁用（已归档、管理员禁用或在目标上下文中不可见），则移动失败。
- 移动到同一命名空间时，会验证 `[type:...]` 参数，但不执行转换。工作项保留其现有类型。
- 内置类型之间的基本类型转换（例如，`Issue`、`Task`、
  `Incident`）在所有层级上均可用。
- 自定义工作项类型和按命名空间的类型可见性是 JihuLab.com 上的专业版和
  旗舰版功能。如果根据您的订阅，目标命名空间中某个类型不可用，则移动失败，错误消息会列出您可以使用的类型。

<a id="page"></a>

### `page`

为事件启动升级。

**可用性**：

- 事件

**参数**：

- `<policy name>`：升级策略名称。

**示例**：

- 启动升级：

  ```plaintext
  /page "On-call policy"
  ```

<a id="promote_to"></a>

### `promote_to`

将工作项提升为指定类型。

**可用性**：

- 议题
- 任务
- 关键结果

**参数**：

- `<type>`：要提升到的类型。可用选项：
  - `Epic`（适用于议题）
  - `Incident`（适用于议题）
  - `issue`（适用于任务）
  - `objective`（适用于关键结果）

**示例**：

- 将议题提升为史诗：

  ```plaintext
  /promote_to Epic
  ```

- 将任务提升为议题：

  ```plaintext
  /promote_to issue
  ```

- 将关键结果提升为目标：

  ```plaintext
  /promote_to objective
  ```

**其他详细信息**：

- 对于议题，`/promote_to_incident` 是 `/promote_to Incident` 的快捷方式。
- 要更改工作项的类型，也可以使用 [`/type`](#type)。

<a id="promote_to_incident"></a>

### `promote_to_incident`

将议题提升为事件。

**可用性**：

- 议题

**示例**：

- 提升为事件：

  ```plaintext
  /promote_to_incident
  ```

**其他详细信息**：

- 您也可以在创建新议题时使用此快速操作。

<a id="publish"></a>

### `publish`

将议题发布到关联的状态页面。

**可用性**：

- 议题

**示例**：

- 发布到状态页面：

  ```plaintext
  /publish
  ```

**其他详细信息**：

- 有关更多信息，请参阅 [状态页面](../../operations/incident_management/status_page.md)。

<a id="react"></a>

### `react`

切换表情符号反应。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求

**参数**：

- `:emoji:`：要切换的表情符号。必须采用 `:emoji_name:` 格式。

**示例**：

- 切换点赞反应：

  ```plaintext
  /react :thumbsup:
  ```

- 切换爱心反应：

  ```plaintext
  /react :heart:
  ```

**其他详细信息**：

- `/award` 是 `/react` 的别名。

<a id="ready"></a>

### `ready`

设置合并请求的就绪状态。

**可用性**：

- 合并请求

**示例**：

- 标记为就绪：

  ```plaintext
  /ready
  ```

**其他详细信息**：

- 有关更多信息，请参阅 [将合并请求标记为就绪](merge_requests/drafts.md#mark-merge-requests-as-ready)。

<a id="reassign"></a>

### `reassign`

用指定的指派人替换当前的指派人。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**参数**：

- `@user1 @user2`：要指派的一个或多个用户名。用户名必须以 `@` 为前缀。

**示例**：

- 重新指派给单个用户：

  ```plaintext
  /reassign @alex
  ```

- 重新指派给多个用户：

  ```plaintext
  /reassign @alex @sam
  ```

**其他详细信息**：

- 要在不替换先前的指派人的情况下添加指派人，请使用 [`/assign`](#assign)。
- 要移除指派人，请使用 [`/unassign`](#unassign)。
- 要替换指派人，请使用 [`/reassign`](#reassign)。

<a id="reassign_reviewer"></a>

### `reassign_reviewer`

用指定的审核人替换当前的审核人。

**可用性**：

- 合并请求

**参数**：

- `@user1 @user2`：要指派为审核人的一个或多个用户名。用户名必须以 `@` 为前缀。

**示例**：

- 重新指派给单个审核人：

  ```plaintext
  /reassign_reviewer @alex
  ```

- 重新指派给多个审核人：

  ```plaintext
  /reassign_reviewer @alex @sam
  ```

**其他详细信息**：

- 要在不替换先前审核人的情况下指派审核人，请使用 [`/assign_reviewer`](#assign_reviewer)。
- 要移除审核人，请使用 [`/unassign_reviewer`](#unassign_reviewer)。

<a id="rebase"></a>

### `rebase`

在目标分支的最新提交上变基源分支。如果存在冲突，则不执行任何操作。

**可用性**：

- 合并请求

**示例**：

- 变基合并请求：

  ```plaintext
  /rebase
  ```

**其他详细信息**：

- 如需帮助，请参阅 [Git 故障排查](../../topics/git/troubleshooting_git.md)。

<a id="relabel"></a>

### `relabel`

用指定的标记替换当前的标记。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**参数**：

- `~label1 ~label2`：一个或多个标记名称。标记名称也可以不带波浪号 (`~`) 开头，但不支持混合语法。

**示例**：

- 替换为单个标记：

  ```plaintext
  /relabel ~bug
  ```

- 替换为多个标记：

  ```plaintext
  /relabel ~bug ~"high priority"
  ```

**其他详细信息**：

- 名称中包含空格的标记必须用双引号括起来。
- 要在不替换先前标记的情况下添加标记，请使用 [`/label`](#label)。
- 要移除标记，请使用 [`/unlabel`](#unlabel)。

<a id="relate"></a>

### `relate`

将这些项标记为相关。

**可用性**：

- 史诗
- 事件
- 议题

**参数**：

- `<item1> <item2>`：要关联的一个或多个项。该值应采用 `#item`、`group/project#item` 或完整 URL 的格式。

**示例**：

- 关联到单个项：

  ```plaintext
  /relate #123
  ```

- 关联到多个项：

  ```plaintext
  /relate #123 group/project#456
  ```

**其他详细信息**：

- 要移除关系，请使用 [`/unlink`](#unlink)。
- 要将这些项标记为一个阻塞另一个，请使用 [`/blocked_by`](#blocked_by) 或 [`/blocks`](#blocks)。

<a id="remove_child"></a>

### `remove_child`

将某个项移除为子项。

**可用性**：

- 史诗
- 议题
- 目标

**参数**：

- `<item>`：要移除为子项的项。该值应采用 `#item`、`group/project#item` 或该项的 URL 格式。

**示例**：

- 移除子项：

  ```plaintext
  /remove_child #123
  ```

- 使用 URL 移除子项：

  ```plaintext
  /remove_child https://gitlab.com/group/project/-/work_items/123
  ```

<a id="remove_contacts"></a>

### `remove_contacts`

移除一个或多个 CRM 联系人。

**可用性**：

- 议题

**参数**：

- `[contact:email1@example.com]`：一个或多个联系人电子邮件，格式为 `contact:email@example.com`。

**示例**：

- 移除单个联系人：

  ```plaintext
  /remove_contacts [contact:alex@example.com]
  ```

- 移除多个联系人：

  ```plaintext
  /remove_contacts [contact:alex@example.com] [contact:sam@example.com]
  ```

**其他详细信息**：

- 有关更多信息，请参阅 [CRM 联系人](../crm/_index.md)。

<a id="remove_due_date"></a>

### `remove_due_date`

移除截止日期。

**可用性**：

- 史诗
- 事件
- 议题
- 任务
- 关键结果

**示例**：

- 移除截止日期：

  ```plaintext
  /remove_due_date
  ```

**其他详细信息**：

- 要添加或替换截止日期，请使用 [`/due`](#due)。

<a id="remove_email"></a>

### `remove_email`

移除最多六个电子邮件参与者。

**可用性**：

- 事件
- 议题

**参数**：

- `email1 email2`：一个或多个电子邮件地址，以空格分隔。

**示例**：

- 移除单个电子邮件参与者：

  ```plaintext
  /remove_email alex@example.com
  ```

- 移除多个电子邮件参与者：

  ```plaintext
  /remove_email alex@example.com sam@example.com
  ```

**其他详细信息**：

- 在议题模板、合并请求或史诗中不受支持。
- 有关更多信息，请参阅 [电子邮件参与者](service_desk/external_participants.md)。

<a id="remove_estimate"></a>

### `remove_estimate`

移除时间估算。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求

**示例**：

- 移除时间估算：

  ```plaintext
  /remove_estimate
  ```

**其他详细信息**：

- `/remove_time_estimate` 是 `/remove_estimate` 的别名。
- 要添加或替换估算，请使用 [`/estimate`](#estimate)。

<a id="remove_iteration"></a>

### `remove_iteration`

移除迭代。

**可用性**：

- 事件
- 议题

**示例**：

- 移除迭代：

  ```plaintext
  /remove_iteration
  ```

**其他详细信息**：

- 要设置迭代，请使用 [`/iteration`](#iteration)。

<a id="remove_milestone"></a>

### `remove_milestone`

移除里程碑。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求

**示例**：

- 移除里程碑：

  ```plaintext
  /remove_milestone
  ```

**其他详细信息**：

- 要设置里程碑，请使用 [`/milestone`](#milestone)。

<a id="remove_parent"></a>

### `remove_parent`

移除该项的父项。

**可用性**：

- 史诗
- 议题
- 任务
- 关键结果

**示例**：

- 移除父项：

  ```plaintext
  /remove_parent
  ```

**其他详细信息**：

- 要设置父项，请使用 [`/set_parent`](#set_parent)。

<a id="remove_time_spent"></a>

### `remove_time_spent`

移除已花费时间。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求

**示例**：

- 移除已花费时间：

  ```plaintext
  /remove_time_spent
  ```

**其他详细信息**：

- 要添加已花费时间，请使用 [`/spend`](#spend)。

<a id="remove_zoom"></a>

### `remove_zoom`

从议题中移除 Zoom 会议。

**可用性**：

- 议题

**示例**：

- 移除 Zoom 会议：

  ```plaintext
  /remove_zoom
  ```

**其他详细信息**：

- 要添加 Zoom 会议，请使用 [`/zoom`](#zoom)。

<a id="reopen"></a>

### `reopen`

重新打开工作项。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**示例**：

- 重新打开工作项：

  ```plaintext
  /reopen
  ```

**其他详细信息**：

- 要关闭工作项，请使用 [`/close`](#close)。

<a id="request_review"></a>

### `request_review`

指派审核人或向一个或多个用户请求新的评审。

**可用性**：

- 合并请求

**参数**：

- `@user1 @user2`：要向其请求评审的一个或多个用户名。用户名必须以 `@` 为前缀。
- `me`：向您自己请求评审。

**示例**：

- 向单个用户请求评审：

  ```plaintext
  /request_review @alex
  ```

- 向多个用户请求评审：

  ```plaintext
  /request_review @alex @sam
  ```

- 向您自己请求评审：

  ```plaintext
  /request_review me
  ```

**其他详细信息**：

- 也可以使用 [`/assign_reviewer`](#assign_reviewer) 或 `/reviewer` 调用。
- 如果用户还不是审核人，则将其指派为审核人。
- 如果用户已经是审核人，则向他们请求新的评审（重置其评审状态并发送通知）。
- 有关更多信息，请参阅 [请求评审](merge_requests/reviews/_index.md#request-a-review)。

<a id="run_pipeline"></a>

### `run_pipeline`

为合并请求运行新的流水线。

**可用性**：

- 合并请求

**示例**：

- 运行新的流水线：

  ```plaintext
    /run_pipeline
  ```

**其他详细信息**：

- 流水线是异步触发的，并在命令执行后不久出现。
- 您必须具有为合并请求创建流水线的权限。
- 您可以将其与其他快速操作结合使用。例如，要运行流水线并设置自动合并：

  ```plaintext
    /run_pipeline
    /merge
  ```

<a id="set_parent"></a>

### `set_parent`

设置父项。

**可用性**：

- 史诗
- 议题
- 任务
- 关键结果

**参数**：

- `<item>`：父项。该值应采用 `#IID`、引用或项的 URL 格式。

**示例**：

- 通过引用设置父项：

  ```plaintext
  /set_parent #123
  ```

- 使用 URL 设置父项：

  ```plaintext
  /set_parent https://gitlab.com/group/project/-/work_items/123
  ```

**其他详细信息**：

- 对于议题，`/epic` 是 `/set_parent` 的别名。
- 要移除父项，请使用 [`/remove_parent`](#remove_parent)。

<a id="severity"></a>

### `severity`

设置事件的严重性。

**可用性**：

- 事件

**参数**：

- `<severity>`：严重性级别。可用选项：
  - `S1`
  - `S2`
  - `S3`
  - `S4`
  - `critical`
  - `high`
  - `medium`
  - `low`
  - `unknown`

**示例**：

- 将严重性设置为严重：

  ```plaintext
  /severity critical
  ```

- 使用 S 表示法设置严重性：

  ```plaintext
  /severity S1
  ```

<a id="shrug"></a>

### `shrug`

将 `¯\_(ツ)_/¯` 添加到评论中。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**示例**：

- 添加耸肩表情：

  ```plaintext
  /shrug
  ```

<a id="spend"></a>

### `spend`

添加或减去已花费时间。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求

**参数**：

- `<time>`：要添加或减去的时间。例如，`1mo 2w 3d 4h 5m`。使用负值来减去时间。
- `[<date>]`：可选。花费时间的日期。

**示例**：

- 添加已花费时间：

  ```plaintext
  /spend 1mo 2w 3d 4h 5m
  ```

- 减去已花费时间：

  ```plaintext
  /spend -1h 30m
  ```

- 在特定日期添加已花费时间：

  ```plaintext
  /spend 1mo 2w 3d 4h 5m 2018-08-26
  ```

**其他详细信息**：

- `/spend_time` 是 `/spend` 的别名。
- 要移除已花费时间，请使用 [`/remove_time_spent`](#remove_time_spent)。
- 有关更多信息，请参阅 [时间跟踪](time_tracking.md)。

<a id="status"></a>

### `status`

设置状态。

**可用性**：

- 议题
- 任务

**参数**：

- `<value>`：状态值。可用选项包括为命名空间设置的状态选项。

**示例**：

- 设置状态：

  ```plaintext
  /status "In Progress"
  ```

**其他详细信息**：

- 有关更多信息，请参阅 [状态](../work_items/status.md)。

<a id="submit_review"></a>

### `submit_review`

提交待处理的 [评审](merge_requests/reviews/_index.md#submit-a-review)。

**可用性**：

- 合并请求

**示例**：

- 提交评审：

  ```plaintext
  /submit_review
  ```

  ```plaintext
  /submit_review reviewed
  ```

- 提交评审并批准：

  ```plaintext
  /submit_review approve
  ```

- 提交评审并 [请求更改](merge_requests/reviews/_index.md#prevent-merge-when-you-request-changes)：

  ```plaintext
  /submit_review requested_changes
  ```

<a id="subscribe"></a>

### `subscribe`

订阅工作项的通知。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**示例**：

- 订阅通知：

  ```plaintext
  /subscribe
  ```

**其他详细信息**：

- 要取消订阅通知，请使用 [`/unsubscribe`](#unsubscribe)。

<a id="tableflip"></a>

### `tableflip`

将 `(╯°□°)╯︵ ┻━┻` 添加到评论中。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**示例**：

- 添加翻桌表情：

  ```plaintext
  /tableflip
  ```

<a id="target_branch"></a>

### `target_branch`

设置合并请求的目标分支。

**可用性**：

- 合并请求

**参数**：

- `<local branch name>`：目标分支的名称。

**示例**：

- 设置目标分支：

  ```plaintext
  /target_branch main
  ```

<a id="timeline"></a>

### `timeline`

向事件添加时间线事件。

**可用性**：

- 事件

**参数**：

- `<timeline comment> | <date(YYYY-MM-DD)> <time(HH:MM)>`：时间线评论、日期和时间，以 `|` 分隔。

**示例**：

- 添加时间线事件：

  ```plaintext
  /timeline DB load spiked | 2022-09-07 09:30
  ```

<a id="title"></a>

### `title`

更改标题。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**参数**：

- `<new title>`：工作项的新标题。

**示例**：

- 更改标题：

  ```plaintext
  /title New title for this item
  ```

<a id="todo"></a>

### `todo`

为您自己添加待办事项。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**示例**：

- 添加待办事项：

  ```plaintext
  /todo
  ```

<a id="type"></a>

### `type`

将工作项转换为指定类型。

**可用性**：

- 议题
- 关键结果
- 目标
- 任务

**参数**：

- `<type>`：要转换成的类型。可用选项：
  - `issue`
  - `task`
  - `objective`
  - `key result`

**示例**：

- 转换为议题：

  ```plaintext
  /type issue
  ```

- 转换为任务：

  ```plaintext
  /type task
  ```

**其他详细信息**：

- 要将议题转换为史诗或事件，请使用 [`/promote_to`](#promote_to)。
- `/type Epic` 也可以将议题转换为史诗，与 `/promote_to Epic` 相同。

<a id="unapprove"></a>

### `unapprove`

取消批准合并请求。

**可用性**：

- 合并请求

**示例**：

- 取消批准合并请求：

  ```plaintext
  /unapprove
  ```

**其他详细信息**：

- 要批准合并请求，请使用 [`/approve`](#approve)。

<a id="unassign"></a>

### `unassign`

移除指派人。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**参数**：

- `@user1 @user2`：可选。要取消指派的一个或多个用户名。
  如果未提供，则移除所有指派人。

**示例**：

- 移除特定指派人：

  ```plaintext
  /unassign @alex @sam
  ```

- 移除所有指派人：

  ```plaintext
  /unassign
  ```

**其他详细信息**：

- 要添加指派人，请使用 [`/assign`](#assign)。
- 要替换指派人，请使用 [`/reassign`](#reassign)。

<a id="unassign_reviewer"></a>

### `unassign_reviewer`

移除审核人。

**可用性**：

- 合并请求

**参数**：

- `@user1 @user2`：可选。要移除为审核人的一个或多个用户名。如果未提供，则移除所有审核人。
- `me`：将您自己移除为审核人。

**示例**：

- 移除特定审核人：

  ```plaintext
  /unassign_reviewer @alex @sam
  ```

- 将您自己移除为审核人：

  ```plaintext
  /unassign_reviewer me
  ```

- 移除所有审核人：

  ```plaintext
  /unassign_reviewer
  ```

**其他详细信息**：

- `/remove_reviewer` 是 `/unassign_reviewer` 的别名。
- 要指派审核人，请使用 [`/assign_reviewer`](#assign_reviewer)。
- 要替换审核人，请使用 [`/reassign_reviewer`](#reassign_reviewer)。

<a id="unlabel"></a>

### `unlabel`

移除标记。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**参数**：

- `~label1 ~label2`：可选。要移除的一个或多个标记名称。如果未提供，则移除所有标记。

**示例**：

- 移除特定标记：

  ```plaintext
  /unlabel ~bug ~"high priority"
  ```

- 移除所有标记：

  ```plaintext
  /unlabel
  ```

**其他详细信息**：

- 名称中包含空格的标记必须用双引号括起来。
- `/remove_label` 是 `/unlabel` 的别名。
- 要添加标记，请使用 [`/label`](#label)。
- 要替换标记，请使用 [`/relabel`](#relabel)。

<a id="unlink"></a>

### `unlink`

移除与另一个项的链接。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**参数**：

- `<item>`：要取消链接的项。该值应采用 `#item`、`group/project#item` 或完整 URL 的格式。对于合并请求，请使用 `!merge_request`、`group/project!merge_request` 或合并请求 URL。

**示例**：

- 取消链接项：

  ```plaintext
  /unlink #123
  ```

- 使用 URL 取消链接项：

  ```plaintext
  /unlink https://gitlab.com/group/project/-/work_items/123
  ```

- 移除合并请求之间的阻塞关系：

  ```plaintext
  /unlink !456
  ```

**其他详细信息**：

- 要在项之间设置关系，请使用 [`/relate`](#relate)、[`/blocks`](#blocks) 或 [`/blocked_by`](#blocked_by)。

<a id="unlock"></a>

### `unlock`

解锁讨论。

**可用性**：

- 史诗
- 议题
- 合并请求

**示例**：

- 解锁讨论：

  ```plaintext
  /unlock
  ```

**其他详细信息**：

- 要锁定讨论，请使用 [`/lock`](#lock)。

<a id="unsubscribe"></a>

### `unsubscribe`

取消订阅工作项的通知。

**可用性**：

- 史诗
- 事件
- 议题
- 合并请求
- 任务
- 目标
- 关键结果

**示例**：

- 取消订阅通知：

  ```plaintext
  /unsubscribe
  ```

**其他详细信息**：

- 要订阅通知，请使用 [`/subscribe`](#subscribe)。

<a id="weight"></a>

### `weight`

设置权重。

**可用性**：

- 议题
- 任务

**参数**：

- `<value>`：权重值。有效值为整数，如 `0`、`1` 或 `2`。

**示例**：

- 设置权重：

  ```plaintext
  /weight 3
  ```

<a id="zoom"></a>

### `zoom`

向议题或事件添加 Zoom 会议。

**可用性**：

- 事件
- 议题

**参数**：

- `<Zoom URL>`：Zoom 会议的 URL。

**示例**：

- 添加 Zoom 会议：

  ```plaintext
  /zoom https://zoom.us/j/123456789
  ```

**其他详细信息**：

- 极狐GitLab 专业版的用户可以在 [向事件添加 Zoom 链接](../../operations/incident_management/linked_resources.md#link-zoom-meetings-from-an-incident) 时添加简短描述。
- 要移除 Zoom 会议，请使用 [`/remove_zoom`](#remove_zoom)。

<a id="commit-comments"></a>

## 提交评论

您可以在评论单个提交时使用快速操作。这些快速操作仅在
提交评论讨论串中有效，在提交消息或其他极狐GitLab 上下文中无效。

要在提交评论中使用快速操作：

1. 通过从提交列表、合并请求
   或其他提交链接中选择提交，转到提交页面。
1. 在提交页面底部的评论表单中，输入您的快速操作。
1. 选择 **评论**。

以下快速操作适用于提交评论：

<a id="tag"></a>

### `tag`

创建指向被评论提交的 Git 标签。

**参数**：

- `v1.2.3`：标签名称。
- `<message>`：可选。标签的消息。

**示例**：

- 创建带消息的标签：

  ```plaintext
  Ready for release after security fix.
  /tag v2.1.1 Security patch release
  ```

  此评论创建一个名为 `v2.1.1` 的 Git 标签，指向该提交，并带有
  消息“Security patch release”。

<a id="troubleshooting"></a>

## 故障排查

<a id="quick-action-isnt-executed"></a>

### 快速操作未执行

如果您运行了快速操作，但没有任何反应，请检查在您输入时该快速操作是否出现在自动补全
框中。
如果没有出现，则可能的原因是：

- 根据您的订阅层级或您在群组或项目中的用户角色，与快速操作相关的功能对您不可用。
- 快速操作的必要条件未满足。
  例如，您在没有标记的议题上运行 `/unlabel`。
