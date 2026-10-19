---
stage: Foundations
group: Import and Integrate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 飞书机器人
---

{{< details >}}

- Tier: 专业版, 旗舰版
- Offering: 私有化部署

{{< /details >}}

> - [引入](https://jihulab.com/gitlab-cn/gitlab/-/issues/474)于极狐GitLab 15.4，功能标志为 `feishu_bot_integration`。默认禁用。
> - 功能标志 `feishu_bot_integration` [移除](https://jihulab.com/gitlab-cn/gitlab/-/issues/1761)于极狐GitLab 15.6。
> - 回调的 Verification Token 和 Encrypt Key 校验[引入](https://jihulab.com/gitlab-cn/gitlab/-/work_items/5344)于极狐GitLab 19.5。

您可以使用命令从飞书上控制或查看极狐GitLab 项目中的事件变更，如创建议题、流水线故障或关闭合并请求等。首先您需要分别配置飞书与极狐GitLab，完成集成。

## 配置飞书

* 在飞书中创建机器人
* 在飞书群组中添加机器人

<a id="bot-creation-steps"></a>

在飞书中创建机器人：

1. 访问 [https://open.feishu.cn](https://open.feishu.cn)，进入 **飞书开放平台** 页面。
1. 使用飞书移动端扫描二维码，登录进入您的组织。 
1. 在右上角，选择 **我的后台** > **开发者后台** 进入我的后台页面。
1. 选择 **企业自建应用** 选项卡。
1. 选择 **创建企业自建应用**，在弹出的窗口中填写名称和应用描述，并为应用上传一个图标，选择右下角的 **创建**。
1. 在左侧边栏中选择 **添加应用能力**，选择 **按能力添加** 选项卡。
1. 选择 **机器人** 下方的 **添加**。添加成功后，您也可以选择 **机器人** 下方的 **配置** 进行更多机器人相关配置。
1. （可选）在左侧边栏中，选择 **成员管理**，添加协作人员。
1. 在左侧边栏中，选择 **凭证与基础信息**，记录页面中显示的 **App ID** 和 **App Secret**，以便后续使用。
1. 在左侧边栏中，选择 **事件与回调**（旧版控制台为 **事件订阅**）。
   - 在 **加密策略** 中记录 **Verification Token** 和 **Encrypt Key**，以便后续使用。两者都是必填项。如果 **Encrypt Key** 为空，请在此处设置一个。
   - 订阅方式保持为 **将事件发送至开发者服务器**，配置 **请求地址** 并选择 **保存**。**请求地址** 需要以您的极狐GitLab 站点网址或者 IP 作为前缀，后面补充 `/api/v4/integrations/feishu/robot`，例如 `http://my-jihulab.com/api/v4/integrations/feishu/robot`。
1. 继续在此页面下方选择 **添加事件**，在打开的窗口中搜索并选择 **接收消息**，选择 **确认添加**。
1. 在左侧边栏中，选择 **权限管理**。
1. 选择 **API 权限** 选项卡，在 **权限配置** 列表中选择 **获取用户在群组中@机器人的消息**、**接收群聊中@机器人消息事件**、**获取用户发给机器人的单聊消息**、**读取用户发给机器人的单聊消息** 和 **获取与发送单聊、群组消息** 最右侧的 **开通权限**，获取相应权限。
1. 在左侧边栏中，选择 **版本管理与发布**，在右侧页面中选择 **创建版本**，按照要求填写 **应用版本号** 和 **更新说明** 并在 **移动端的默认能力** 和 **桌面端的默认能力** 中选择 **机器人**，然后选择 **保存**。
1. 在弹出的确认对话框中选择 **申请线上发布**。

NOTE:
在飞书开放平台首页的右上角，单击 **我的后台** 旁边的功能菜单图标，选择 **管理后台** 进入飞书管理后台页面。在左侧边栏中选择 **工作台** > **应用审核**。在右侧页面中选择 **设置审核规则**，您可以查看 **自建应用审核规则** 下的 **开启免审** 开关是否开启。如果开启，您在[在飞书中创建机器人](#bot-creation-steps)申请线上发布后，您所创建的版本会自动通过审核，上线发布；如果未开启，在申请线上发布后，您需要在飞书管理后台页面中选择 **工作台** > **应用审核**，在右侧页面的审核列表中手动审核。

在飞书群组中添加机器人：

1. 打开您需要添加机器人的飞书群组，选择右上角的三个点图标，选择 **设置**。
1. 选择 **群机器人** > **添加机器人**，将您的机器人添加到群组中。


## 配置极狐GitLab

1. 启动极狐GitLab Rails 控制台，在控制台中运行 `Feature.enable(:feishu_bot_integration)`，完成飞书特性开关的启用。详情请参见[功能标志文档](../../../administration/feature_flags.md)（功能标志为 `feishu_bot_integration`，15.6 及之后的版本跳过此步骤）。
1. 以管理员身份登录极狐GitLab，在左侧边栏中选择 **管理中心** > **设置** > **通用**。
1. 在右侧页面中，选择 **飞书集成** 右侧的 **展开**，勾选 **启用飞书集成** 复选框，并填写 **飞书App ID** 和 **飞书App Secret**，选择 **保存更改**。
1. 在左侧边栏中，选择 **管理中心** > **设置** > **集成**。
1. 在右侧页面中，选择 **飞书** > **设置**，勾选 **激活集成** 下面的 **激活** 复选框。此为飞书通知集成，与飞书机器人是两个独立的集成。
1. 在 **触发器** 下面勾选您想在飞书群组中接收通知的事件类型。如推送、议题和评论等。
1. 返回 **管理中心** > **设置** > **集成**，选择 **飞书机器人**。
1. 勾选 **激活** 复选框。
1. 填写 **Verification Token** 和 **Encrypt Key**，即在飞书中记录的值。
1. 选择 **保存更改**。

NOTE:
极狐GitLab 中需要填写的 **飞书App ID** 和 **飞书App Secret** 是[在飞书中创建机器人](#bot-creation-steps)步骤 9 中记录的 **App ID** 和 **App Secret**。

**飞书机器人** 仅在 **设置** > **通用** 中勾选了 **启用飞书集成**，并填写了 App ID 和 App Secret 后，才会显示在集成列表中。如果该处禁用了飞书集成，所有机器人回调都会被拒绝。

勾选 **激活** 后，**Verification Token** 和 **Encrypt Key** 任意一项为空都无法保存。这两个值加密存储，保存后不再显示。之后编辑时将字段留空，会保留当前值。

验证配置：

1. 在飞书开发者后台中，重新保存 **请求地址**。飞书会发送一个验证请求，只有极狐GitLab 中的 Verification Token 和 Encrypt Key 与飞书一致时才能保存成功。
1. 向机器人发送 `help`。

至此，您已经完成了飞书和极狐GitLab 集成所需的所有配置工作。

## 从早期版本升级

19.5 之前，极狐GitLab 仅比对回调中的 App ID，无法证明请求来自飞书。

升级到 19.5 后，在管理员于 **飞书机器人** 集成中配置 Verification Token 和 Encrypt Key 之前，所有飞书机器人回调都会被拒绝：极狐GitLab 返回 HTTP 401，机器人不会在飞书中回复。没有跳过校验的开关。

为缩短中断时间，建议按以下顺序操作：

1. 升级前，在飞书开发者后台记录 Verification Token。如果尚未设置 Encrypt Key，请设置。设置 Encrypt Key 后，飞书会发送加密事件，19.5 之前的版本无法读取，因此请在升级前不久再设置。
1. 升级极狐GitLab。
1. 在 **飞书机器人** 集成中填写这两个值。
1. 按[配置极狐GitLab](#配置极狐gitlab)中的方法验证配置。

中断期间发送的命令不会永久丢失。飞书会在 15 秒、5 分钟、1 小时和 6 小时后重试失败的事件，配置完成后重试的事件会被处理。

## 轮换凭证

在飞书开发者后台重置 Verification Token 或 Encrypt Key 后，飞书会立即使用新值。请立即更新 **飞书机器人** 集成。

在此期间的回调会被拒绝，飞书会按相同的时间间隔重试。如果在重试窗口内完成更新，这些事件会在更新后被处理。

更新后，按[配置极狐GitLab](#配置极狐gitlab)中的方法验证配置。

## 故障排查

### 机器人没有回复

极狐GitLab 会在 `application_json.log` 中记录每个被拒绝的回调，其中 `"message":"Rejected Feishu bot callback"`，并带有 `error_message` 字段说明拒绝原因。日志不会记录密钥。

根据 `error_message` 检查：

- `App ID, Verification Token or Encrypt Key is not configured`：**设置** > **通用** 中的 App ID，或 **飞书机器人** 集成中的两个值缺失，或未勾选 **启用飞书集成**。
- `Callback is not encrypted`：飞书开发者后台没有设置 Encrypt Key。
- `Undecryptable payload`、`Malformed ciphertext` 或 `Malformed payload`：极狐GitLab 中的 Encrypt Key 与飞书不一致。
- `Signature mismatch`：Encrypt Key 不一致，或极狐GitLab 前面的代理修改了请求体。
- `Verification Token mismatch`：Verification Token 不一致。
- `App ID mismatch`：**设置** > **通用** 中的 App ID 不是发送事件的应用。
- `Stale request` 或 `Malformed timestamp`：极狐GitLab 服务器时钟与飞书相差超过 5 分钟，或请求头被代理修改。请确认服务器已启用 NTP 时间同步。
- `Missing event ID`：事件使用了旧的 1.0 事件格式。请订阅 2.0 版本的 **接收消息** 事件。

### 飞书重试的命令没有执行

极狐GitLab 对每个飞书事件最多处理一次。如果命令处理失败，飞书重试该事件时不会再次处理。请在飞书中重新发送命令。


## 飞书命令

您可以在群组中@机器人或者直接与机器人创建一对一的聊天框发送消息。

您需要在命令中通过添加项目路径、项目 ID 或项目别名指定您要进行操作的项目。下表中的命令以 `project-path` 为例，且默认对此项目有操作权限。

在群组中@机器人发送消息和与机器人进行一对一私聊时，会出现返回消息不一致的情况。下表中默认为返回消息一致的描述，如有不一致会另作说明。

| 命令                                                                | 效果                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|-------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `help`                                                            | 显示所有可用命令。                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `(project-path) issue new (title) ⇧ Shift+ ↲ Enter (description)` | 使用标题 `(title)` 和描述 `(description)` 创建一个新议题。 创建成功后，会显示 "I created an issue on xx's behalf: #`(id)` in `(project-path)`"。您可以点击消息中的议题 ID 查看议题的详细信息。<br/><br/>内容书写需遵循 markdown 语法。您也可以在命令中添加指派人和标记等。                                                                                                                                                                                                                                                                                  |
| `(project-path) issue show (id)`                                  | 使用 ID `(id)` 显示指定议题。如果您有所请求显示的议题（非私密）的权限，会显示议题标题、作者、指派人、里程碑和标记。如果您没有所请求显示的议题的权限或请求显示一个不存在的议题，会显示 "I cannot find the issue #`(id)`"。<br/><br/>如果您请求显示一个私密议题：<br/><br/>- 群组中：议题信息如标题、作者、指派人、里程碑和标记不会显示，仅显示议题 ID 链接，拥有对应议题权限的人员可以点击链接查看详细信息，没有权限的人员则无法查看。 <br/><br/>- 私聊中：如果您有该私密议题的权限，则会显示议题信息如标题、作者、指派人、里程碑和标记；如果您没有该私密议题的权限，会显示 "I cannot find the issue #`(id)`" 。<br/><br/>如果您查询一个不存在或您没有权限的项目中的议题，会显示 "You are not allowed to perform bot commands"。                           |
| `(project-path) issue close (id)`                                 | 使用 ID `(id)` 关闭指定议题。关闭议题（非私密）成功后，会显示 "I closed an issue on xx's behalf: #`(id)` in `(project-path)`"，并显示议题信息如标题、作者、指派人、里程碑和标记。<br/><br/>如果您请求关闭一个私密议题：<br/><br/>- 群组中：仅显示关闭成功消息，不显示议题详细信息。<br/><br/>- 私聊中：显示议题详细信息。<br/><br/>如果您请求关闭一个已关闭的议题，会显示 "Issue #`(id)` is already closed."。<br/> <br/>如果您请求关闭一个不存在或您没有权限的议题，会显示 "I cannot find the issue #`(id)`"。                                                                                                                       |
| `(project-path) issue search (your query)`                        | 最多显示五个您权限范围内匹配搜索内容 `(query)` 的议题，按照议题的创建时间从新到旧进行排列。<br/><br/>如果您请求查询议题：<br/><br/>- 群组中：私密议题显示为 "Confidential Issue"，非私密议题显示议题 ID、标题及状态。<br/><br/>- 私聊中：全部议题都显示议题ID、标题及状态。<br/><br/>如果没有找到匹配您查询条件的议题，会显示 "I cannot find any issue related to `(query)`"。<br/><br/>如果您输入的关键字大于或等于 3 个字符，则会进行模糊匹配搜索，即返回所有标题中包含此关键字的议题；如果您输入的关键字小于 3 个字符，则会进行精确匹配搜索，即仅会返回标题与此关键字相同的议题。                                                                                                                |
| `(project-path) issue move (issue_id) to (project_path)`          | 使用 ID `(issue_id)` 移动指定议题到 `(project_path)`。 移动成功后，会显示 "Moved issue #`(old_link)` to #`(new_link)`"。<br/><br/>如果所要移动的议题已关闭，会显示 "I cannot move closed issue"。<br/><br/>如果无法找到目标项目，会显示 "I cannot find target project `(project)`"。                                                                                                                                                                                                                                                             |
| `(project-path) issue comment (id) ⇧ Shift+ ↲ Enter (comment)`    | 向 ID 为 `(id)` 的议题添加评论正文为 `(comment)` 的新评论。评论成功后，会显示 "I commented on an issue on xx's behalf: #`(id)` in `(project-path)`" 和评论内容。<br/><br/>评论内容需遵循 markdown 语法，详情请参见 [Markdown 渲染](https://docs.gitlab.cn/jh/user/markdown.html)。您也可以使用[极狐GitLab 快速操作](https://docs.gitlab.cn/jh/user/project/quick_actions.html)对议题进行高级操作。<br/><br/>如果您请求评论一个不存在的议题，会显示 "I cannot find the issue #`(id)`"。<br/><br/>如果您请求评论一个您没有权限的议题，会显示 "You are not allowed to perform the given bot command"。 |
| `(project-path) deploy (environment) to (target-environment)`     | 从 `(environment)` 环境部署到 `(target-environment)` 环境。您请求部署后，会显示 "Deployment started from `(environment)` to `(target-environment)`. Follow its progress."。您可以点击消息中的链接查看部署进度，详情请参见[环境和部署](https://docs.gitlab.cn/jh/ci/environments/)。                                                                                                                                                                                                                                                                                              |
| `(project-path) run (command) (arguments) `                       | 在默认分支上执行作业 `(command)`。运行成功后，会显示 "ChatOps job #`(id)` started by xx completed successfully" 和具体的作业 ID 及名称。您可以点击消息中的链接查看具体的作业内容。                                                                                                                                                                                                                                                                                                                                                  |


## 在飞书中与 GitLab Duo 对话

> - [引入](https://jihulab.com/gitlab-cn/gitlab/-/work_items/5345)于极狐GitLab 19.5，[功能标志](../../../administration/feature_flags.md)为 `jh_feishu_duo_chat`。默认禁用。此功能为实验功能。

NOTE:
此功能的可用性由功能标志控制。管理员需要为顶级群组启用该功能标志，再按用户启用。

为用户启用功能标志后，用户发给飞书机器人的、不是 ChatOps 命令的消息，会由 GitLab Duo Agent Platform（"GitLab Duo for Feishu" 基础流程）回复。`help` 和上文表格中的现有命令保持不变。

- 一对一聊天：所有不是命令的消息都会发送给 Duo。
- 群聊：只有@机器人的消息会发送给 Duo，其他群消息会被 Duo 忽略。

Duo 的回答显示为对您消息的回复。回复是一张在 Duo 处理期间持续更新的卡片，最终包含回答和指向极狐GitLab 中对应会话的链接。如果无法创建或更新卡片，Duo 会改为发送普通的富文本消息。

### 对话上下文

- Duo 会记住最近的对话（约最近 8 轮，保留 1 天）。
- 每个用户在每个聊天中有各自独立的对话。群组中的话题是单独的对话。
- 发送 `/new` 或 `/reset` 可以重新开始对话。
- 每个用户在每个对话中同一时间只处理一条消息。如果 Duo 仍在处理，会提示您等待。
- 速率限制：每个用户每分钟最多向 Duo 发送 10 条消息。

### Duo 可以做什么

Duo 仅通过极狐GitLab API 工作，不检出代码仓库，也不执行 shell 命令。Duo 可以：

- 读取议题、合并请求和代码等内容。
- 创建和更新议题与工作项，添加评论。
- 更新合并请求。
- 将编码任务交给其他流程。

Duo 不能删除内容、合并或推送代码。

### 审批写入操作

在执行任何写入操作（例如创建议题或评论、更新合并请求、启动其他流程）之前，Duo 会在卡片上显示它要执行的操作，并提供 **同意** 和 **拒绝** 两个按钮：

- 选择 **同意**：允许执行该操作。
- 选择 **拒绝**：取消该操作。

每个请求只接受一次决定。如果该请求已经被回答（通过按钮或回复），或会话已继续进行，再次选择按钮会显示提示，并且卡片上的按钮会被移除。

在群聊中，只有发送原始消息的用户可以选择按钮。其他人选择按钮时，会收到只有该用户可以回答的提示。

您也可以通过回复文字做出决定，例如卡片上没有按钮时：

- 回复 `同意`、`批准`、`确认`、`approve` 或 `ok`：允许执行该操作。
- 回复 `拒绝`、`取消` 或 `reject`：取消该操作。
- 回复其他内容：取消该操作，并将您的回复作为反馈传递给 Duo，例如说明应如何修改。

只有发送原始消息的用户可以做出决定，并且在做出决定时会重新检查该用户当前的权限。写入操作以该用户的身份执行。

### 前提条件

- 已按上文配置飞书机器人，并且用户已将极狐GitLab 账号与飞书绑定（首次使用时机器人会发送绑定链接）。
- 实例中可使用极狐GitLab Duo Agent Platform，并且已为用户的命名空间启用 "GitLab Duo for Feishu" 基础流程。
- 用户已在极狐GitLab **偏好设置** 中设置默认 Duo 命名空间。未设置时，Duo 会回复提示您进行设置。

### 飞书应用权限和事件

除上文已配置的权限外，请确认飞书应用具有以下权限：

| 权限 | 用途 |
|------|------|
| `im:message.p2p_msg:readonly`（或 `im:message.p2p_msg`） | 接收单聊消息。 |
| `im:message.group_at_msg:readonly`（或 `im:message.group_at_msg`） | 接收群聊中@机器人的消息。 |
| `im:message:send_as_bot`（或 `im:message`） | 回复消息。 |
| `cardkit:card:write` | 创建和更新流式回复卡片（Duo 新增）。 |
| `im:resource`（或 `im:resource:upload`） | 上传卡片中的等待动画。未授予时，卡片改为显示文字。 |
| `contact:user.employee_id:readonly` | 读取发送者的用户 ID，账号绑定会使用该 ID。 |

同时，事件订阅中需要包含 **接收消息** v2.0（`im.message.receive_v1`）。

要使用审批按钮，还需要在飞书开发者后台配置卡片回调：

1. 在左侧边栏中，选择 **事件与回调** > **回调配置**。
1. 将订阅方式设置为 **将回调发送至开发者服务器**，**请求地址** 与事件相同（`<极狐GitLab 地址>/api/v4/integrations/feishu/robot`）。
1. 添加回调 **卡片回传交互**（`card.action.trigger`）。
1. 创建并发布新的应用版本。

回调使用与事件相同的 Verification Token 和 Encrypt Key 校验。未配置此回调时，在飞书中选择按钮会出错，文字回复仍然可用。

添加权限后，请按上文步骤创建并发布新的应用版本。

### 启用功能

管理员按以下顺序启用此功能：

1. 为飞书应用添加上述权限，并发布新的应用版本。
1. 在 Rails 控制台中，为将使用该功能的顶级群组启用功能标志，例如 `Feature.enable(:jh_feishu_duo_chat, Group.find_by_full_path('group-path'))`。未启用时，群组设置中不显示 "GitLab Duo for Feishu" 流程，Duo 会话也会被拒绝。
1. 确认已设置 Duo Agent Platform，并为该顶级群组启用 "GitLab Duo for Feishu" 流程。
1. 通知用户设置默认 Duo 命名空间。
1. 在 Rails 控制台中，为特定用户启用功能标志，例如 `Feature.enable(:jh_feishu_duo_chat, User.find_by_username('username'))`。
1. 验证：向机器人发送一条单聊消息，然后在群组中@机器人，再提出一个后续问题，发送 `/reset`，并让 Duo 创建一个议题以检查审批流程。

### 故障排查

- 群组中没有回复：确认消息@了机器人。
- 回复是普通富文本而不是卡片：检查是否已授予 `cardkit:card:write` 权限，并已发布新的应用版本。
- Duo 要求您设置默认 Duo 命名空间：在极狐GitLab **偏好设置** 中设置。
- Duo 提示仍在处理之前的消息：等待上一条回答完成，或发送 `/reset`。
- 点击按钮后飞书提示出错或没有反应：确认已在 **回调配置** 中添加 **卡片回传交互** 回调，请求地址与事件相同，并已发布新的应用版本。
