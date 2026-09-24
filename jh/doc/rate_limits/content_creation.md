---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 配置议题、史诗和评论创建速率限制。
title: 内容创建速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

速率限制控制用户创建议题、史诗和评论的速度。

<a id="issue-and-epic-creation"></a>

## 议题和史诗创建

[史诗](../user/group/epics/_index.md)创建的速率限制与议题创建的速率限制相同。

前提条件：

- 管理员访问权限。

要限制对议题和史诗创建端点的请求数量：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **议题速率限制**。
1. 在 **每分钟最大请求数** 框中，输入新值。
1. 选择 **保存更改**。

速率限制：

- 按项目和用户独立应用。
- 不按 IP 地址应用。
- 默认禁用。
- 可设置为 `0` 以禁用速率限制。

超过速率限制的请求会记录到 `auth.log` 文件中。

例如，如果您将限制设置为 `300`，则每分钟超过 300 次的请求将被阻止。
一分钟后即可访问该端点。

<a id="note-creation"></a>

## 评论创建

您可以配置对评论创建端点的请求速率限制。

前提条件：

- 管理员访问权限。

要更改评论创建速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **评论速率限制**。
1. 在 **每分钟最大请求数** 框中，输入新值。
1. 可选。在 **从速率限制中排除的用户** 框中，列出允许超过限制的用户。
1. 选择 **保存更改**。

速率限制：

- 按用户独立应用。
- 不按 IP 地址应用。
- 默认为 `300`。

超过速率限制的请求会记录到 `auth.log` 文件中。

例如，如果您将限制设置为 `300`，则每分钟超过 300 次的请求将被阻止。
一分钟后即可访问该端点。
