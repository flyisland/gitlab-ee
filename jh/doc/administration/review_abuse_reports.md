---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 查看并解决用户提交的滥用报告。
gitlab_dedicated: yes
title: 审查滥用报告
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

查看并解决极狐GitLab 用户提交的滥用报告。

极狐GitLab 管理员可以在**管理**区域中查看并[解决](#resolving-abuse-reports)滥用报告。

<a id="receive-notification-of-abuse-reports-by-email"></a>

## 通过电子邮件接收滥用报告通知

要通过电子邮件接收新滥用报告的通知：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **报告**。
1. 展开**滥用报告**部分。
1. 提供一个电子邮件地址，然后选择**保存更改**。

通知电子邮件地址也可以[使用 API](../api/settings.md#available-settings) 设置和获取。

<a id="reporting-abuse"></a>

## 报告滥用

要详细了解如何报告滥用，请参阅[滥用报告用户文档](../user/report_abuse.md)。

<a id="resolving-abuse-reports"></a>

## 解决滥用报告

要访问滥用报告：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**滥用报告**。

有四种解决滥用报告的方法，每种方法对应一个按钮：

- 移除用户和报告。此操作会：
  - 从实例中[删除被报告的用户](../user/profile/account/delete_account.md)。
  - 从列表中移除该滥用报告。
- [阻止用户](#blocking-users)。
- 移除报告。此操作会：
  - 从列表中移除该滥用报告。
  - 移除被报告用户的访问限制。
- 信任用户。此操作会：
  - 允许该用户创建议题、评论、代码片段和合并请求，而不会因垃圾信息被阻止。
  - 防止针对该用户创建滥用报告。

以下是**滥用报告**页面的示例：

![显示针对某用户提交的示例滥用报告的仪表板。](img/abuse_reports_page_v18_6.png)

<a id="blocking-users"></a>

### 阻止用户

被阻止的用户无法登录或访问任何代码仓库，但其所有数据仍会保留。

阻止用户：

- 会将其保留在滥用报告列表中。
- 会将**阻止用户**按钮变为禁用的**已阻止**按钮。

该用户会收到以下消息：

```plaintext
Your account has been blocked. If you believe this is in error, contact a staff member.
```

阻止后，您仍然可以：

- 必要时移除该用户和报告。
- 移除该报告。
