---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: 配置 Git 滥用速率限制，以自动限制并封禁在极狐GitLab 实例上超出所定义代码仓库下载限制的用户
title: Git 滥用速率限制（管理）
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

这是管理文档。有关群组的 Git 滥用速率限制的信息，请参阅[群组文档](../../user/group/reporting/git_abuse_rate_limit.md)。

Git 滥用速率限制是一项功能，可自动[封禁用户](../moderate_users.md#ban-and-unban-users)，这些用户在给定时间范围内下载、克隆或 fork 实例中任一项目的代码仓库数量超过指定值。被封禁的用户无法登录实例，也无法通过 HTTP 或 SSH 访问任何非公开群组。该速率限制同样适用于使用[个人访问令牌](../../user/profile/personal_access_tokens.md)或[群组访问令牌](../../user/group/settings/group_access_tokens.md)进行身份验证的用户。

Git 滥用速率限制不适用于实例管理员、[部署令牌](../../user/project/deploy_tokens/_index.md)或[部署密钥](../../user/project/deploy_keys/_index.md)。

<a id="configure-git-abuse-rate-limiting"></a>

## 配置 Git 滥用速率限制

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **报告**。
1. 展开 **Git 滥用速率限制**。
1. 更新 Git 滥用速率限制设置：
   1. 在**代码仓库数量**字段中输入一个大于或等于 `0` 且小于或等于 `10000`的数字。该数字指定用户在指定时间段内可下载的唯一代码仓库的最大数量，超过该数量后将被封禁。设置为 `0` 时，Git 滥用速率限制将被禁用。
   1. 在**报告时间段（秒）**字段中输入一个大于或等于 `0` 且小于或等于 `864000`（10 天）的数字。该数字指定用户可下载最大数量代码仓库的时间（以秒为单位），超过该时间后将被封禁。设置为 `0` 时，Git 滥用速率限制将被禁用。
   1. 可选。最多可排除 `100` 个用户，方法是将他们添加到**排除的用户**字段。被排除的用户不会被自动封禁。
   1. 最多可将 `100` 个用户添加到**发送通知给**字段。您必须至少选择一个用户。默认情况下会选择所有应用管理员。
   1. 可选。开启**当用户超出指定限制时自动从该命名空间封禁用户**开关以启用自动封禁。
1. 选择**保存更改**。

<a id="automatic-ban-notifications"></a>

## 自动封禁通知

如果自动封禁已禁用，用户超出限制时不会被自动封禁。但是，仍会向**发送通知给**下列出的用户发送通知。您可以使用此设置来确定速率限制设置的正确值，然后再启用自动封禁。

如果自动封禁已启用，当用户即将被封禁时会发送电子邮件通知，并且该用户会被自动从极狐GitLab 实例中封禁。

<a id="unban-a-user"></a>

## 解除封禁用户

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **用户**。
1. 选择**已封禁**标签页，并搜索您要解除封禁的账号。
1. 从**用户管理**下拉列表中选择**解除封禁用户**。
1. 在确认对话框中，选择**解除封禁用户**。
