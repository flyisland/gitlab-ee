---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: 为您的极狐GitLab 实例配置合并请求审批。
title: 合并请求审批
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

合并请求审批规则可防止用户覆盖某些项目设置。启用后，这些设置会[对实例中的所有项目和群组强制执行](../user/project/merge_requests/approvals/settings.md#cascade-settings-from-the-instance-or-top-level-group)。

可以为整个实例设置以下合并请求审批设置：

- **防止合并请求创建者批准**。禁止项目维护者允许合并请求作者批准自己的合并请求。
- **阻止添加提交的用户批准**。禁止项目维护者允许已向源分支提交任何提交的用户
  批准合并请求。
- **禁止在项目和合并请求中编辑审批规则**。禁止用户修改
  项目设置或单个合并请求中的审批人列表。与仅阻止对单个合并请求进行覆盖的
  等效群组和项目设置不同，此
  实例设置还会锁定项目设置中的审批规则列表。

以下内容也受整个实例的规则影响：

- [项目合并请求审批规则](../user/project/merge_requests/approvals/_index.md)。
- [群组合并请求审批设置](../user/group/manage.md#group-merge-request-approval-settings)。

<a id="enable-merge-request-approval-settings-for-an-instance"></a>

## 为实例启用合并请求审批设置

先决条件：

- 管理员访问权限。

要启用合并请求审批设置：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**推送规则**。
1. 展开**合并请求审批**。
1. 选中任一审批规则的复选框。
1. 选择**保存更改**。
