---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
description: Use merge request reviews to discuss and improve code before it is merged into your project.
title: 管理合并请求
---

极狐GitLab 提供用于管理项目和群组合并请求的工具。

<a id="delete-a-merge-request"></a>

删除合并请求

在大多数情况下，你应该关闭合并请求，而不是将其删除。
合并请求删除后无法撤销。

先决条件：

- 你必须具有项目的所有者角色。

要删除合并请求：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的项目。
1. 在左侧边栏中，选择 **代码** > **合并请求**，然后找到要删除的合并请求。
1. 选择 **编辑**。
1. 滚动到页面底部，然后选择 **删除合并请求**。

> [!注意]
> 删除合并请求不会完全清除所有数据。部分信息会保留以维护项目历史记录并支持恢复流程。更多信息，请参见[处理敏感信息](../../../topics/git/undo.md#handle-sensitive-information)。

<a id="bulk-edit-merge-requests-in-a-project"></a>

批量编辑项目中的合并请求

批量编辑合并请求时，以下属性可编辑：

- 状态 (开启/关闭)
- 指派人
- 里程碑
- 标签
- 订阅

先决条件：

- 你必须具有开发者、维护者或所有者角色。

操作步骤：

1. 在项目中，转到 **代码** > **合并请求**。
1. 选择 **批量编辑**。屏幕右侧会出现一个带有可编辑字段的侧边栏。
1. 选中要编辑的每个合并请求旁边的复选框。
1. 从侧边栏中选择相应的字段及其值。
1. 选择 **更新选中项**。

<a id="bulk-edit-merge-requests-in-a-group"></a>

批量编辑群组中的合并请求

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当你批量编辑群组的合并请求时，以下属性可编辑：

- 里程碑
- 标签

先决条件：

- 你必须具有项目的开发者、维护者或所有者角色。

要同时更新多个群组合并请求：

1. 在群组中，转到 **代码** > **合并请求**。
1. 选择 **批量编辑**。屏幕右侧会出现一个带有可编辑字段的侧边栏。
1. 选中要编辑的每个合并请求旁边的复选框。
1. 从侧边栏中选择相应的字段及其值。
1. 选择 **更新选中项**。

