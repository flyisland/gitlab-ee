---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Phorge
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 16.11。

{{< /history >}}

您可以将 [Phorge](https://we.phorge.it/) 用作极狐GitLab 中的[外部议题跟踪器](../../../integration/external-issue-tracker.md)。

<a id="configure-the-integration"></a>

## 配置集成

要在极狐GitLab 项目中配置 Phorge：

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏，选择 **设置** > **集成**。
1. 选择 **Phorge**。
1. 在 **启用集成** 下，勾选 **活跃** 复选框。
1. 在 **项目 URL** 中，输入 Phorge 项目的 URL。
1. 在 **议题 URL** 中，输入 Phorge 项目议题的 URL。
   URL 必须包含 `:id`。极狐GitLab 会将此令牌替换为 Maniphest 任务 ID（例如，`T123`）。
1. 在 **新建议题 URL** 中，输入新建 Phorge 项目议题的 URL。
   要预填与此项目相关的标签，您可以使用 `?tags=`。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

在该极狐GitLab 项目中，您可以看到指向 Phorge 项目的链接。现在您可以在极狐GitLab 中使用 `T<ID>` 引用 Phorge 议题和任务，其中 `<ID>` 是 Maniphest 任务 ID（例如 `T123`）。