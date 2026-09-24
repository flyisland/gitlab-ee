---
stage: none
group: Tutorials
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用 Web 编辑器编辑文件'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[项目](../../user/project/organize_work_with_projects.md) 文件可以由拥有[适当访问权限](../../user/project/members/_index.md)的团队成员编辑。

了解如何使用简单的 Web 编辑器直接在极狐GitLab UI 中编辑单个文件。

<a id="select-the-file-you-wish-to-edit"></a>

## 选择要编辑的文件

首先，转到项目主页以获取项目中的文件列表。

![项目主页上的文件列表。它显示了一个名为 "Company Handbook" 的项目，其中包含名为 "break-room.md" 等的文件。](img/project_file_listing_v18_9.png)

选择任意文件以查看其详细信息。

![详细显示了 "break-room.md" 文件。其内容展示了便利设施，如卡片、视频游戏和台球桌。](img/file_in_detail_v18_9.png)

<a id="edit-the-file"></a>

## 编辑文件

选择 **编辑** 下拉列表，然后选择 **编辑单个文件**。

![编辑按钮展开显示下拉列表选项，"在 Web IDE 中打开" 和 "编辑单个文件"。](img/edit_dropdown_v18_9.png)

在编辑器中，根据需要编辑文件。

![文件重新出现在可编辑的文本字段中，允许查看者更改其内容。](img/edit_file_v18_9.png)

<a id="commit-your-changes-and-create-a-merge-request"></a>

## 提交你的更改并创建合并请求

可以直接将更改提交（保存）到文件。但是，对于大多数团队来说，不建议这样做，因为先让团队成员审查你的更改是一个好习惯。在此步骤中，你将创建一个分支和合并请求，其中包含新的更改。

完成编辑后：

1. 选择 **提交更改**。
1. 在 **提交消息** 文本框中填写更改的描述。
1. 在 **分支** 下，选择 **提交到新分支**。
1. 在 **提交到新分支** 下，输入新分支的名称，或保留自动生成的名称。
1. 确保选中 **为此更改创建合并请求**。

![提交更改表单，包含示例值。提交消息为 "删除关于乒乓球桌的提及"，选中了 "提交到新分支"，分支名称为 "ping-pong-table-removal"。](img/commit_changes_v18_9.png)

最后，选择 **提交更改** 将更改提交到新分支。新的合并请求表单出现。要创建请求，请执行以下操作：

1. 将 **标题** 设置为更改的适当摘要。
1. 在 **描述** 字段中提供有关更改的更多详细信息。
1. 将 **指派人** 设置为你自己。
1. 如果你知道谁应该审查你的更改，请设置 **审核人**。
1. 可选。设置合并请求的[里程碑](../../user/project/milestones/_index.md)。
1. 可选。为合并请求设置标签以更好地分类。
1. 选择 **创建合并请求** 以创建合并请求。

![新合并请求的表单，显示标题设置为 "删除关于乒乓球桌的提及"，描述为 "此合并请求从休息室页面删除了乒乓球桌，因为我们不再拥有它。"](img/merge_request_v18_9.png)

你的编辑现在位于合并请求中，并准备好由其他贡献者审查。

<a id="next-steps"></a>

## 后续步骤

接下来你可以：

- 审查其他人的合并请求
- [在现有项目中创建议题](../create_issue_in_existing_project/_index.md)