---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在极狐GitLab 上为已弃用的 API 定义限制。
gitlab_dedicated: yes
title: 已弃用 API 速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

已弃用的 API 端点已被替代功能取代，但由于不能破坏向后兼容性，因此无法移除。为了鼓励用户改用替代功能，请对已弃用的端点设置严格的速率限制。

<a id="deprecated-api-endpoints"></a>

## 已弃用的 API 端点

此速率限制并非涵盖所有已弃用的 API 端点，仅涵盖可能影响性能的端点：

- [`GET /groups/:id`](../../api/groups.md#retrieve-a-group) 未使用 `with_projects=0` 查询参数。

<a id="define-deprecated-api-rate-limits"></a>

## 定义已弃用 API 速率限制

已弃用 API 端点的速率限制默认处于禁用状态。启用后，它们将取代针对已弃用端点请求的通用用户和 IP 速率限制。您可以保留已有的任何通用用户和 IP 速率限制，并增加或减少已弃用 API 端点的速率限制。此覆盖不提供任何其他新功能。

前提条件：

- 您必须具有该实例的管理员访问权限。

要覆盖针对已弃用 API 端点请求的通用用户和 IP 速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **已弃用 API 速率限制**。
1. 选中您要启用的速率限制类型对应的复选框：
   - **未认证 API 请求速率限制**
   - **已认证 API 请求速率限制**
1. 如果您选择了 **未认证**：
   1. 选择 **每个 IP 每周期最大未认证 API 请求数**。
   1. 选择 **未认证 API 速率限制周期（秒）**。
1. 如果您选择了 **已认证**：
   1. 选择 **每个用户每周期最大已认证 API 请求数**。
   1. 选择 **已认证 API 速率限制周期（秒）**。
