---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: When you fork a merge request, you can set whether or not members of the upstream repository can contribute to your fork.
title: 跨派生项目的合并请求协作
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当您从您的 [派生](../repository/forking_workflow.md) 中打开一个合并请求时，您可以允许上游成员在您的分支上与您协作。启用此选项后，具备合并到目标分支权限的成员将获得写入合并请求源分支的权限。然后，上游项目的成员可以在合并前进行小的修复或变基分支。

此功能适用于公开可访问的跨派生项目的合并请求。

<a id="allow-commits-from-upstream-members"></a>

## 允许上游成员提交

作为合并请求的作者，您可以允许来自您所贡献项目的上游成员修改提交：

1. 在创建或编辑合并请求时，滚动到 **贡献** 并勾选 **允许可以合并到目标分支的成员提交** 复选框。
1. 完成合并请求的创建。

在您创建合并请求后，合并请求小部件会显示消息 **允许可以合并的成员添加提交**。然后，上游成员可以：

- 直接提交到您的分支。
- 重试合并请求的流水线和作业。

<a id="prevent-commits-from-upstream-members"></a>

## 阻止上游成员提交

作为合并请求的作者，您可以阻止来自您所贡献项目的上游成员修改提交：

1. 在创建或编辑合并请求时，滚动到 **贡献** 并取消勾选 **允许可以合并到目标分支的成员提交** 复选框。
1. 完成合并请求的创建。

<a id="push-to-the-fork-as-the-upstream-member"></a>

## 作为上游成员推送到派生

如果您满足以下条件，可以直接推送到派生仓库的分支：

- 合并请求的作者已启用来自上游成员的贡献。
- 您在上游项目中具有开发者、维护者或所有者角色。

要推送更改或添加提交到派生的分支，您可以使用命令行 Git。更多信息，请参阅 [作为上游成员使用 Git 推送到派生](../../../topics/git/forks.md#push-to-a-fork-as-an-upstream-member)。

<a id="troubleshooting"></a>

## 故障排除

<a id="pipeline-status-unavailable-from-mr-page-of-forked-project"></a>

### 派生项目的合并请求页面中流水线状态不可用

当用户派生一个项目时，派生的副本权限不会从原始项目复制。派生的创建者必须授予派生副本权限，然后上游项目的成员才能查看或合并合并请求中的更改。

要查看从派生项目的合并请求页面回到原始项目的流水线状态：

1. [创建一个包含所有上游成员的群组](../../group/_index.md#create-a-group)。
2. 在顶部栏中，选择 **搜索或跳转到** 并找到派生项目。
3. 在派生项目前往 **管理** > **成员** 页面，并邀请新创建的群组加入派生项目。