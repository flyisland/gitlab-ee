---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 让新用户确认电子邮件
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 可以配置为要求用户注册时确认其电子邮件地址。启用此设置后，用户必须先确认其电子邮件地址，然后才能登录。

先决条件：

- 管理员访问权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **新用户账户限制**，然后查找 **电子邮件确认设置** 选项。

<a id="confirmation-token-expiry"></a>

## 确认令牌过期

默认情况下，用户可以在确认电子邮件发送后的 24 小时内确认其账户。超过 24 小时，确认令牌将失效。

<a id="automatically-delete-unconfirmed-users"></a>

## 自动删除未确认的用户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

开启电子邮件确认后，管理员可以启用以[自动删除未确认的用户](../administration/moderate_users.md#automatically-delete-unconfirmed-users)的设置。