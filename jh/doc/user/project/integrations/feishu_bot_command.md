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
1. 在左侧边栏中，选择 **事件订阅**，在右侧页面中配置 **请求地址**、**Encrypt Key** 和 **Verification Token** 并选择 **保存**。其中 **请求地址** 需要以您的极狐GitLab 站点网址或者 IP 作为前缀，后面补充 `/api/v4/integrations/feishu/robot`，例如 `http://my-jihulab.com/api/v4/integrations/feishu/robot`。
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
1. 在右侧页面中，选择 **飞书** > **设置**，勾选 **激活集成** 下面的 **激活** 复选框。
1. 在 **触发器** 下面勾选您想在飞书群组中接收通知的事件类型。如推送、议题和评论等。

NOTE:
极狐GitLab 中需要填写的 **飞书App ID** 和 **飞书App Secret** 是[在飞书中创建机器人](#bot-creation-steps)步骤 9 中记录的 **App ID** 和 **App Secret**。

至此，您已经完成了飞书和极狐GitLab 集成所需的所有配置工作。


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

