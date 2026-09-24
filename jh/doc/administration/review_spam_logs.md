---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Monitor and manage flagged user activity considered to be spam.
title: 查看垃圾信息日志
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 跟踪用户活动并将某些行为标记为潜在垃圾信息。

在 **管理员** 区域，极狐GitLab 管理员可以查看并处理垃圾信息日志。

<a id="manage-spam-logs"></a>

## 管理垃圾信息日志

{{< history >}}

- **信任用户** 在极狐GitLab 16.5 引入。

{{< /history >}}

查看并处理垃圾信息日志，以管理实例中的用户活动。

要查看垃圾信息日志：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **垃圾信息日志**。
1. 可选。要处理某个垃圾信息日志，选择 **更多操作** ({{< icon name="ellipsis_v" >}})，然后选择 **移除用户**、**封禁用户**、**移除日志** 或 **信任用户**。

### 处理垃圾信息日志

你可以通过以下方式处理垃圾信息日志，每种方式有不同的效果：

| 选项 | 描述 |
|---------|-------------|
| **移除用户** | 该用户将被从实例中 [删除](../user/profile/account/delete_account.md)。 |
| **封禁用户** | 该用户将被从实例中封禁。垃圾信息日志仍保留在列表中。 |
| **移除日志** | 该垃圾信息日志将从列表中移除。 |
| **信任用户** | 该用户被信任，可以创建议题、评论、代码片段和合并请求，而不会因垃圾信息被封禁。不会为受信任用户创建垃圾信息日志。 |

## 相关主题

- [审核用户（管理员）](moderate_users.md)
- [查看滥用报告](review_abuse_reports.md)