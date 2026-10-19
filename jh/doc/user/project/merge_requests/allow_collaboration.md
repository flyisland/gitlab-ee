---
stage: AI Coding
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 当您 fork 一个合并请求时，您可以设置上游代码仓库的成员是否可以为您 fork 的副本贡献内容。
title: 跨 forks 协作处理合并请求
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当您从 [fork](../repository/forking_workflow.md)中打开一个合并请求时，您可以允许上游成员与您协作处理您的分支。启用此选项后，拥有合并到目标分支权限的成员将获得对合并请求源分支的写入权限。

随后，上游项目的成员可以在合并前进行小幅修复或对分支执行变基。

此功能适用于跨 forked 项目且[可公开访问](../../public_access.md)的合并请求。

<a id="allow-commits-from-upstream-members"></a>

## 允许上游成员提交

作为合并请求的作者，您可以允许您所贡献项目的上游成员编辑提交：

1. 在创建或编辑合并请求时，滚动到 **贡献**，然后选中 **允许可以合并到目标分支的成员提交** 复选框。
1. 完成合并请求的创建。

创建合并请求后，合并请求小组件会显示消息 **允许可以合并的成员添加提交**。随后，上游成员可以：

- 直接提交到您的分支。
- 重试合并请求的流水线和作业。

<a id="prevent-commits-from-upstream-members"></a>

## 阻止上游成员提交

作为合并请求的作者，您可以阻止您所贡献项目的上游成员编辑提交：

1. 在创建或编辑合并请求时，滚动到 **贡献**，然后清除 **允许可以合并到目标分支的成员提交** 复选框。
1. 完成合并请求的创建。

<a id="push-to-the-fork-as-the-upstream-member"></a>

## 以上游成员身份推送到 fork

如果满足以下条件，您可以直接推送到 forked 代码仓库的分支：

- 合并请求的作者启用了上游成员的贡献权限。
- 您在上游项目中拥有开发者、维护者或所有者角色。

要推送更改或向 fork 的分支添加提交，您可以使用命令行 Git。
有关更多信息，请参阅[以上游成员身份使用 Git 推送到 fork](../../../topics/git/forks.md#push-to-a-fork-as-an-upstream-member)。

<a id="troubleshooting"></a>

## 故障排除

<a id="pipeline-status-unavailable-from-mr-page-of-forked-project"></a>

### 流水线状态在 forked 项目的合并请求页面上不可用

当用户 forks 一个项目时，forked 副本的权限不会从原项目复制。fork 的创建者必须先为 forked 副本授予权限，上游项目中的成员才能查看或合并合并请求中的更改。

要从 forked 项目的合并请求页面查看回到原项目的流水线状态：

1. [创建群组](../../group/_index.md#create-a-group)，其中包含所有上游成员。
1. 在顶部栏中，选择**搜索或跳转到**，然后找到 forked 项目。
1. 转到 forked 项目中的**管理** > **成员**页面，并将新建的群组邀请到 forked 项目中。
