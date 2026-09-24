---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure merge request approvals for your GitLab instance.
title: 合并请求审批
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

合并请求审批规则可防止用户覆盖某些项目设置。启用后，这些设置会在实例中的所有项目和群组中[强制执行](https://gitlab.cn/docs/ee/user/project/merge_requests/approvals/settings.md#cascade-settings-from-the-instance-or-top-level-group)。

整个实例可以设置以下合并请求审批设置：

- **禁止合并请求创建者审批**。可防止项目维护者允许合并请求作者审批自己的合并请求。
- **禁止提交者审批**。如果用户提交了任何源代码分支的提交，可防止项目维护者允许这些用户审批合并请求。
- **禁止编辑项目和合并请求的审批规则**。可防止用户修改项目设置或单独合并请求中的审批人列表。与等效的群组和项目设置不同，后者仅防止在单独合并请求上覆盖，此实例设置还会锁定项目设置中的审批规则列表。

以下内容也会受到实例全局规则的影响：

- [项目合并请求审批规则](https://gitlab.cn/docs/ee/user/project/merge_requests/approvals/_index.md)。
- [群组合并请求审批设置](https://gitlab.cn/docs/ee/user/group/manage.md#group-merge-request-approval-settings)。

<a id="enable-merge-request-approval-settings-for-an-instance"></a>

为实例启用合并请求审批设置

先决条件：

- 管理员访问权限。

要启用合并请求审批设置：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **推送规则**。
1. 展开 **合并请求审批**。
1. 勾选任何审批规则的复选框。
1. 选择 **保存更改**。