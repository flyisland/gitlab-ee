---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: Configure Git abuse rate limiting to automatically restrict and ban users who exceed defined repository download limits on a GitLab instance
title: Git 滥用速率限制（管理）
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.2 [引入]() [带有功能标志](../feature_flags/_index.md) 名称 `git_abuse_rate_limit_feature_flag`。默认禁用。
- 在极狐GitLab 15.11 [正式发布]()。功能标志 `git_abuse_rate_limit_feature_flag` 移除。

{{< /history >}}

这是管理文档。有关群组的 Git 滥用速率限制信息，请参阅[群组文档](../../user/group/reporting/git_abuse_rate_limit.md)。

Git 滥用速率限制是一个功能，可以自动[封禁用户](../moderate_users.md#ban-and-unban-users)，这些用户在给定时间范围内下载、克隆或派生（fork）的仓库数量超过实例中任何项目的指定数量。被封禁的用户无法登录实例，也无法通过 HTTP 或 SSH 访问任何非公开群组。该速率限制也适用于使用[个人](../../user/profile/personal_access_tokens.md)或[群组访问令牌](../../user/group/settings/group_access_tokens.md)进行身份验证的用户。

Git 滥用速率限制不适用于实例管理员、[部署令牌](../../user/project/deploy_tokens/_index.md)或[部署密钥](../../user/project/deploy_keys/_index.md)。

极狐GitLab 如何确定用户的速率限制仍在开发中。
极狐GitLab 团队成员可以在此机密史诗中查看更多信息：
`https://gitlab.com/groups/gitlab-org/modelops/anti-abuse/-/epics/14`

<a id="configure-git-abuse-rate-limiting"></a>

## 配置 Git 滥用速率限制

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **报告**。
1. 展开 **Git 滥用速率限制**。
1. 更新 Git 滥用速率限制设置：
   1. 在 **仓库数量** 字段中输入一个数字，大于或等于 `0` 且小于或等于 `10000`。此数字指定用户在指定时间段内可下载的最大唯一仓库数量，超过后将被封禁。设置为 `0` 时，Git 滥用速率限制将被禁用。
   1. 在 **报告时间段（秒）** 字段中输入一个数字，大于或等于 `0` 且小于或等于 `864000`（10天）。此数字指定用户在可下载最大数量仓库的时间（以秒为单位），超过后被封禁。设置为 `0` 时，Git 滥用速率限制将被禁用。
   1. 可选。通过将最多 `100` 个用户添加到 **排除的用户** 字段来排除他们。排除的用户不会被自动封禁。
   1. 将最多 `100` 个用户添加到 **发送通知给** 字段。你必须至少选择一位用户。默认情况下选择所有应用程序管理员。
   1. 可选。打开 **当用户超过指定限制时自动从该命名空间封禁用户** 开关以启用自动封禁。
1. 选择 **保存更改**。

<a id="automatic-ban-notifications"></a>

## 自动封禁通知

如果自动封禁被禁用，当用户超出限制时不会自动封禁。但是，通知仍会发送到 **发送通知给** 下列出的用户。你可以使用此设置来确定速率限制设置的正确值，然后再启用自动封禁。

如果启用了自动封禁，当用户即将被封禁时会发送电子邮件通知，并且用户会自动被禁止访问极狐GitLab 实例。

<a id="unban-a-user"></a>

## 解封用户

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **概览** > **用户**。
1. 选择 **已封禁** 标签页，然后搜索要解封的账户。
1. 从 **用户管理** 下拉列表中选择 **解封用户**。
1. 在确认对话框中，选择 **解封用户**。