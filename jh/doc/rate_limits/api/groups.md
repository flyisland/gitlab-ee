---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组 API 速率限制
description: 为群组 API 端点设置速率限制。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 升级到极狐GitLab 18.0 或更高版本时，此 API 的可配置速率限制设置为 `0`。管理员可以根据需要调整速率限制。有关受影响的速率限制的信息，请参阅[为 Projects、Groups 和 Users API 宣布的速率限制](https://about.gitlab.com/blog/rate-limitations-announced-for-projects-groups-and-users-apis/#rate-limitation-details)。

<a id="configure-groups-api-rate-limits"></a>

## 配置群组 API 速率限制

为以下群组 API 端点的请求配置每个 IP 地址和用户的速率限制：

| 限制                                                           | 默认值 | 时间间隔 |
|-----------------------------------------------------------------|---------|----------|
| [`GET /groups`](../../api/groups.md#list-groups)                | 200     | 1 分钟 |
| [`GET /groups/:id`](../../api/groups.md#retrieve-a-group)     | 400     | 1 分钟 |
| [`GET /groups/:id/groups/shared`](../../api/groups.md#list-shared-groups) | 0     | 1 分钟 |
| [`GET /groups/:id/invited_groups`](../../api/groups.md#list-shared-groups) | 60     | 1 分钟 |
| [`GET /groups/:id/projects`](../../api/groups.md#list-projects) | 600     | 1 分钟 |
| [`POST /groups/:id/archive`](../../api/groups.md#archive-a-group) | 60    | 1 分钟 |
| [`POST /groups`](../../api/groups.md#create-a-group)            | 200     | 1 天 |

前提条件：

- 管理员访问权限。

要更改速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **群组 API 速率限制**。
1. 更改任何速率限制的值，或将速率限制设置为 `0` 以禁用它。
1. 选择 **保存更改**。

速率限制：

- 适用于每个已认证用户。如果请求未认证，则速率限制适用于 IP 地址。
- 可以设置为 0 以禁用速率限制。

超过速率限制的请求会记录到 `auth.log` 文件中。

例如，如果您为 `GET /groups/:id` 设置 400 的限制，则超过每分钟 400 次速率的 API 端点请求将被阻止。一分钟后可恢复对该端点的访问。

<a id="rate-limit-on-listing-group-and-project-members"></a>

## 列出群组和项目成员时的速率限制

[列出所有群组成员 API 端点](../../api/group_members.md#list-all-group-members-including-inherited-and-invited-members)上设置了速率限制。

`GET /projects/:id/members/all` 和 `GET /groups/:id/members/all` API 端点共享相同的速率限制配置。如果您在项目端点上设置了速率限制，则该速率限制也适用于群组端点。

前提条件：

- 管理员访问权限。

要为两个端点修改此速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **项目 API 速率限制**。
1. 在 **每个用户或 IP 地址每分钟对 `GET /projects/:id/members/all` API 的最大请求数** 文本框中，输入一个值。
1. 选择 **保存更改**。

速率限制：

- 默认为每分钟 200 个请求。
- 适用于每个已认证用户。如果请求未认证，则速率限制适用于 IP 地址。
- 通过项目 API 速率限制设置进行配置。有关更多信息，请参阅[配置列出项目成员时的速率限制](projects.md#configure-rate-limits-on-listing-project-members)。
- 可以设置为 `0` 以禁用两个端点的速率限制。

超过速率限制的请求会记录到 `auth.log` 文件中。

例如，超过每分钟 200 个请求速率的 API 端点请求将被阻止。一分钟后可恢复对该端点的访问。

<a id="configure-rate-limits-on-group-archiving-and-unarchiving"></a>

## 配置群组归档和取消归档的速率限制

{{< details >}}

- Status: 实验

{{< /details >}}

为以下群组归档端点的请求配置速率限制：

```plaintext
POST /groups/:id/archive
POST /groups/:id/unarchive
```

前提条件：

- 管理员访问权限。

要更改速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **群组 API 速率限制**。
1. 在 **每个用户或 IP 地址每分钟对 `POST /groups/:id/archive` 和 `POST /groups/:id/unarchive` API 的最大请求数** 文本框中，输入一个值。
1. 选择 **保存更改**。

速率限制：

- 默认为每分钟 60 个请求
- 适用于每个已认证用户。如果请求未认证，则速率限制适用于 IP 地址。
- 可以设置为 `0` 以禁用两个端点的速率限制

超过速率限制的请求会记录到 `auth.log` 文件中。

例如，如果您设置 60 的限制，则超过每分钟 60 个请求速率的 API 端点请求将被阻止。一分钟后可恢复对该端点的访问。

有关群组归档端点的更多信息，请参阅[归档群组](../../api/groups.md#archive-a-group)。

<a id="configure-rate-limits-on-deleting-group-members"></a>

## 配置删除群组成员的速率限制

为[删除成员端点](../../api/group_members.md#remove-a-group-member)的请求配置每个群组和用户的速率限制。

前提条件：

- 管理员访问权限。

要更改速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **成员 API 速率限制**。
1. 在 **每个群组 / 项目每分钟的最大请求数** 文本框中，输入一个值。
1. 选择 **保存更改**。

速率限制：

- 默认为每分钟 60 个请求。
- 适用于每个群组和用户。
- 可以设置为 `0` 以禁用速率限制。

超过速率限制的请求会记录到 `auth.log` 文件中。

例如，如果您设置 60 的限制，则超过每分钟 60 个请求速率的 API 端点请求将被阻止。一分钟后可恢复对该端点的访问。
