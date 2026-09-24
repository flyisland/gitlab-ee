---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Pivotal Tracker
description: 配置 Pivotal Tracker 集成，将提交消息作为评论添加到 Pivotal Tracker 故事中，并通过提交关闭故事。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Pivotal Tracker 集成会将提交消息作为评论添加到 Pivotal Tracker 故事中。

启用集成后，系统会检查提交消息中是否包含方括号，方括号内为井号加故事 ID（例如 `[#555]`）。
找到的每个故事 ID 都会添加对应的提交评论。

您还可以使用包含 `fix [#555]` 的消息来关闭故事。
您可以使用以下任一词语：

- `fix`
- `fixed`
- `fixes`
- `complete`
- `completes`
- `completed`
- `finish`
- `finished`
- `finishes`
- `delivers`

有关源提交端点的更多信息，请参阅
[Pivotal Tracker API](https://www.pivotaltracker.com/help/api/rest/v5#Source_Commits)。

有关 Pivotal Tracker 集成的更多信息，请参阅[项目集成 API](../../../api/project_integrations.md#pivotal-tracker)。

<a id="set-up-pivotal-tracker"></a>

## 设置 Pivotal Tracker

在 Pivotal Tracker 中，[创建 API 令牌](https://www.pivotaltracker.com/help/articles/api_token/)。

在极狐GitLab 中完成以下步骤：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Pivotal Tracker**。
1. 在 **启用集成** 下，选中 **启用** 复选框。
1. 粘贴您在 Pivotal Tracker 中生成的令牌。
1. 可选。要将此设置限制为特定分支，请在 **限制到分支** 字段中列出这些分支，并以逗号分隔。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。
