---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Projects API 速率限制
description: 为 Projects API 端点设置速率限制。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 升级到极狐GitLab 18.0 或更高版本时，此 API 的可配置速率限制设置为 `0`。管理员可以根据需要调整速率限制。有关受影响的速率限制的信息，请参阅[为 Projects、Groups 和 Users API 宣布的速率限制](https://about.gitlab.com/blog/rate-limitations-announced-for-projects-groups-and-users-apis/#rate-limitation-details)。

<a id="configure-projects-api-rate-limits"></a>

## 配置 Projects API 速率限制

为每个 IP 地址和用户对以下 Projects API 端点的请求配置速率限制：

| 限制                                                                                                       | 默认值 | 间隔 |
|-------------------------------------------------------------------------------------------------------------|---------|----------|
| [`GET /projects`](../../api/projects.md#list-all-projects)（未认证请求）                       | 400     | 10 分钟 |
| [`GET /projects`](../../api/projects.md#list-all-projects)（已认证请求）                         | 2000    | 10 分钟 |
| [`GET /projects/:id`](../../api/projects.md#retrieve-a-project)                                             | 400     | 1 分钟 |
| [`GET /users/:user_id/projects`](../../api/projects.md#list-all-personal-projects-for-a-user)               | 300     | 1 分钟 |
| [`GET /users/:user_id/contributed_projects`](../../api/projects.md#list-all-projects-contributions-for-a-user) | 100     | 1 分钟 |
| [`GET /users/:user_id/starred_projects`](../../api/project_starring.md#list-projects-starred-by-a-user)     | 100     | 1 分钟 |
| [`POST /projects`](../../api/projects.md#create-a-project)                                                  | 200     | 1 天 |

前提条件：

- 管理员访问权限。

要更改速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **Projects API 速率限制**。
1. 更改速率限制的值，或将速率限制设置为 `0` 以禁用它。
1. 选择 **保存更改**。

速率限制：

- 适用于每个已认证用户。如果请求未认证，则速率限制适用于 IP 地址。

超过速率限制的请求会记录到 `auth.log` 文件中。

例如，如果您为 `GET /projects/:id` 设置 400 的限制，则对该 API 端点的请求超过每分钟 400 个后将被阻止。一分钟后可恢复对该端点的访问。

有关项目 API 端点的更多信息，请参阅 [projects API](../../api/projects.md#list-all-projects)。

<a id="configure-rate-limits-on-deleting-project-members"></a>

## 配置删除项目成员的速率限制

为每个项目和用户对[删除成员端点](../../api/project_members.md#remove-a-direct-member-of-a-project)的请求配置速率限制。

前提条件：

- 管理员访问权限。

要更改速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **Members API 速率限制**。
1. 在 **每个群组 / 项目每分钟的最大请求数** 文本框中，输入一个值。
1. 选择 **保存更改**。

速率限制：

- 默认为每分钟 60 个请求
- 适用于每个项目和用户。
- 可以设置为 `0` 以禁用速率限制。

超过速率限制的请求会记录到 `auth.log` 文件中。

例如，如果您设置 60 的限制，则对该 API 端点的请求超过每分钟 60 个后将被阻止。一分钟后可恢复对该端点的访问。

<a id="configure-rate-limits-on-listing-project-members"></a>

## 配置列出项目成员的速率限制

为[列出项目成员端点](../../api/project_members.md#list-all-members-of-a-project)的请求配置速率限制。

`GET /projects/:id/members/all` 和 `GET /groups/:id/members/all` API 端点共享相同的速率限制配置。如果您在 projects 端点上设置速率限制，则该速率限制也适用于 groups 端点。

前提条件：

- 管理员访问权限。

要更改速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **Projects API 速率限制**。
1. 在 **每个用户或 IP 地址每分钟对 `GET /projects/:id/members/all` API 的最大请求数** 文本框中，输入一个值。
1. 选择 **保存更改**。

速率限制：

- 默认为每分钟 200 个请求。
- 适用于每个已认证用户。如果请求未认证，则速率限制适用于 IP 地址。
- 可以设置为 `0` 以禁用速率限制。

超过速率限制的请求会记录到 `auth.log` 文件中。

例如，如果您设置 200 的限制，则对该 API 端点的请求超过每分钟 200 个后将被阻止。一分钟后可恢复对该端点的访问。
