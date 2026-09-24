---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 成员 API 速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 16.9。

{{< /history >}}

<a id="rate-limit-on-members-api"></a>

## 成员 API 的速率限制

您可以为每个用户配置每个群组（或项目）对[删除成员 API](../../api/members.md#remove-a-member-from-a-group-or-project)的速率限制。

要更改速率限制：

1. 在左侧边栏底部，选择 **管理员**。
1. 选择 **设置 > 网络**。
1. 展开 **成员 API 速率限制**。
1. 在 **每分钟每群组 / 项目的最大请求数** 文本框中，输入新值。
1. 选择 **保存更改**。

速率限制：

- 适用于每个群组或项目的每个用户。
- 可以设置为 0 以禁用速率限制。

速率限制的默认值为 `60`。

超过速率限制的请求会记录到 `auth.log` 文件中。

例如，如果您设置的限制为 60，发送到[删除成员 API](../../api/members.md#remove-a-member-from-a-group-or-project)的请求超过每分钟 300 的速率将被阻止。访问该端点将在一分钟后被允许。
