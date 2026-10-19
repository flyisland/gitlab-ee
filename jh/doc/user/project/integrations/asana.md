---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Asana
description: 配置 Asana 集成，将提交信息作为评论添加到 Asana 任务，并通过极狐GitLab 提交关闭任务。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Asana 集成会将提交信息作为评论添加到 Asana 任务。开启该集成后，系统会检查提交信息中是否包含 Asana 任务 URL（例如 `https://app.asana.com/1/12345/project/67890/task/987654`）或以 `#` 开头的任务 ID（例如 `#987654`）。找到的每个任务 ID 都会添加该提交评论。

您还可以使用包含以下内容的消息关闭任务：`fix #123456`。您可以使用以下任意一个词：

- `fix`
- `fixed`
- `fixes`
- `fixing`
- `close`
- `closes`
- `closed`
- `closing`

另请参阅 [Asana 集成 API 文档](../../../api/project_integrations.md#asana)。

<a id="setup"></a>

## 设置

在 Asana 中创建个人访问令牌。[了解 Asana 中的个人访问令牌](https://developers.asana.com/docs/personal-access-token)。

在极狐GitLab 中完成以下步骤：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Asana**。
1. 在**启用集成**下，选中**活跃**复选框。
1. 粘贴您在 Asana 中生成的令牌。
1. 可选。要将此设置限制为特定分支，请在**限制到分支**
   字段中列出这些分支，以逗号分隔。
1. 可选。选择**测试设置**。
1. 选择**保存更改**。
