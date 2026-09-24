---
stage: AI-powered
group: AI Coding
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 解释文件中的代码
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐 GitLab Duo 专业版或旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认大模型](../../gitlab_duo/model_selection.md#default-models)
- 可访问 [自部署模型的 极狐 GitLab Duo](../../../administration/gitlab_duo_self_hosted/_index.md) 了解详情

{{< /collapsible >}}

{{< history >}}

- GA 于 极狐 GitLab 16.8 中发布。
- 在 极狐 GitLab 17.6 及更高版本中，更改为需要 极狐 GitLab Duo 附加组件。
- 更新默认大模型为 国内 SOTA 大模型，于 极狐 GitLab 18.6 中。

{{< /history >}}

如果您花费大量时间试图理解他人创建的代码，或者难以理解用不熟悉的语言编写的代码，您可以请求 极狐 GitLab Duo 为您解释代码。

前提条件：

- 您必须属于至少一个已启用 [实验和测试功能设置](../../gitlab_duo/turn_on_off.md#turn-on-beta-and-experimental-features) 的群组。
- 您必须有权查看项目。

要解释文件中的代码：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在项目中，选择包含代码的文件。
1. 选择您想要解释的行。
1. 在左侧，选择问号 ({{< icon name="question" >}})。
   您可能需要滚动到所选内容的第一行才能查看它。

   ![文件视图显示所选行和问号图标，您可以使用该图标解释代码。](img/explain_code_v17_1.png)

极狐 GitLab Duo Chat 会解释代码。生成解释可能需要片刻时间。

如果您愿意，可以提供关于解释质量的反馈。

我们无法保证大语言模型生成的结果是正确的。使用时请谨慎。

您还可以在以下位置解释代码：

- 一个 [合并请求](../merge_requests/changes.md#explain-code-in-a-merge-request)。
