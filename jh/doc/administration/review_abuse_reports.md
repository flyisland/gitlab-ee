---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: View and resolve abuse reports submitted by users.
gitlab_dedicated: yes
title: 审查滥用报告
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

查看并解决来自极狐GitLab用户的滥用报告。

极狐GitLab 管理员可以在 **管理员** 区域查看并[解决](#resolving-abuse-reports)滥用报告。

<a id="receive-notification-of-abuse-reports-by-email"></a>

## 通过电子邮件接收滥用报告通知

要通过电子邮件接收新滥用报告的通知：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **报告**。
1. 展开 **滥用报告** 部分。
1. 提供电子邮件地址，然后选择 **保存更改**。

通知电子邮件地址也可以[通过 API ](../api/settings.md#available-settings)设置和获取。

<a id="reporting-abuse"></a>

## 报告滥用

要了解有关报告滥用的更多信息，请参阅
[滥用报告用户文档](../user/report_abuse.md)。

<a id="resolving-abuse-reports"></a>

## 解决滥用报告

{{< history >}}

- **信任用户** 引入于极狐GitLab 16.4。

{{< /history >}}

要访问滥用报告：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **滥用报告**。

有四种方法可以解决滥用报告，每种方法对应一个按钮：

- **删除用户和报告**。这会：
  - [从实例中删除被举报的用户](../user/profile/account/delete_account.md)。
  - 从列表中删除滥用报告。
- [**阻止用户**](#blocking-users)。
- **删除报告**。这会：
  - 从列表中删除滥用报告。
  - 移除针对被举报用户的访问限制。
- **信任用户**。这会：
  - 允许用户创建议题、评论、代码片段和合并请求，而不会因垃圾信息被阻止。
  - 防止针对该用户创建滥用报告。

以下是 **滥用报告** 页面的一个示例：

![显示针对某个用户提交的示例滥用报告的仪表板。](img/abuse_reports_page_v18_6.png)

<a id="blocking-users"></a>

### 阻止用户

被阻止的用户无法登录或访问任何代码仓库，但其所有数据都会保留。

阻止用户会：

- 将其保留在滥用报告列表中。
- 将 **阻止用户** 按钮更改为禁用的 **已阻止** 按钮。

用户会收到以下消息通知：

```plaintext
您的账户已被阻止。如果您认为这是错误的，请联系工作人员。
```

阻止后，您仍然可以：

- 如有必要，删除用户和报告。
- 删除报告。

<a id="related-topics"></a>

## 相关主题

- [审核用户（管理）](moderate_users.md)
- [查看垃圾信息日志](review_spam_logs.md)