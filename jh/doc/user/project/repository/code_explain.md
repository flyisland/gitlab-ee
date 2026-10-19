---
stage: AI Coding
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 解释文件中的代码
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo Pro 或 Enterprise、极狐GitLab Duo with Amazon Q
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](../../gitlab_duo/model_selection.md#default-models)
- Amazon Q 的 LLM：Amazon Q Developer
- 适用于[自部署模型的极狐GitLab Duo](../../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

如果您花费大量时间试图理解他人编写的代码，或者难以理解用您不熟悉的语言编写的代码，可以让极狐GitLab Duo 为您解释代码。

先决条件：

- 您必须至少属于一个已启用[实验和测试版功能设置](../../gitlab_duo/turn_on_off.md#turn-on-beta-and-experimental-features)的群组。
- 您必须有权查看该项目。

要解释文件中的代码：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在项目中，选择包含代码的文件。
1. 选择您想要解释的行。
1. 在左侧，选择问号（{{< icon name="question" >}}）。
   您可能需要滚动到所选内容的第一行才能看到它。

   ![文件视图，显示选中的行以及可用于解释代码的问号图标。](img/explain_code_v17_1.png)

极狐GitLab Duo Chat 会解释代码。生成解释可能需要一些时间。

如果您愿意，可以就解释的质量提供反馈。

我们无法保证大语言模型生成的结果是正确的。请谨慎使用解释。

您还可以在以下位置解释代码：

- [合并请求](../merge_requests/changes.md#explain-code-in-a-merge-request)。
- [IDE](../../gitlab_duo_chat/examples.md#explain-selected-code)。
