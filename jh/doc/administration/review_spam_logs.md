---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 监控和管理被标记为垃圾信息的用户活动。
gitlab_dedicated: yes
title: 查看垃圾信息日志
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 会跟踪用户活动，并将某些行为标记为潜在垃圾信息。

在**管理**区域中，极狐GitLab 管理员可以查看并解决垃圾信息日志。

<a id="manage-spam-logs"></a>

## 管理垃圾信息日志

查看并解决垃圾信息日志，以管理实例中的用户活动。

查看垃圾信息日志：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**垃圾信息日志**。
1. 可选。要解决垃圾信息日志，请选择**更多操作**（{{< icon name="ellipsis_v" >}}），然后选择**移除用户**、**阻止用户**、**移除日志**或**信任用户**。

<a id="resolving-spam-logs"></a>

### 解决垃圾信息日志

您可以通过以下任一方式解决垃圾信息日志：

| 选项 | 描述 |
|---------|-------------|
| **移除用户** | 该用户会从实例中[删除](../user/profile/account/delete_account.md)。 |
| **阻止用户** | 该用户会被阻止访问实例。垃圾信息日志仍保留在列表中。 |
| **移除日志** | 垃圾信息日志会从列表中移除。 |
| **信任用户** | 该用户会被信任，可以创建议题、评论、代码片段和合并请求，而不会因垃圾信息被阻止。系统不会为受信任的用户创建垃圾信息日志。 |
