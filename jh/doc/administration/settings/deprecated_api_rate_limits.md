---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Define limits for deprecated APIs on GitLab.
gitlab_dedicated: yes
title: 已弃用的 API 速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

已弃用的 API 端点已被替代功能替换，但删除它们会破坏向后兼容性。为了鼓励用户切换到替代功能，可以对已弃用的端点设置严格的速率限制。

<a id="deprecated-api-endpoints"></a>

## 已弃用的 API 端点

此速率限制并不包括所有已弃用的 API 端点，仅针对那些可能影响性能的端点：

- [`GET /groups/:id`](../../api/groups.md#retrieve-a-group) 未使用 `with_projects=0` 查询参数。

<a id="define-deprecated-api-rate-limits"></a>

## 定义已弃用的 API 速率限制

已弃用的 API 端点的速率限制默认是禁用的。启用后，它们会取代已弃用端点请求的通用用户和 IP 速率限制。你可以保留已经设置好的任何通用用户和 IP 速率限制，并提高或降低已弃用的 API 端点的速率限制。此覆盖不提供其他新功能。

先决条件：

- 你必须拥有实例的管理员访问权限。

要覆盖已弃用 API 端点的请求的通用用户和 IP 速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **网络**。
1. 展开 **已弃用的 API 速率限制**。
1. 选择你想要启用的速率限制类型的复选框：
   - **未认证 API 请求速率限制**
   - **已认证 API 请求速率限制**
1. 如果选择了 **未认证**：
   1. 选择 **每个 IP 每个周期的最大未认证 API 请求数**。
   1. 选择 **未认证 API 速率限制周期（秒）**。
1. 如果选择了 **已认证**：
   1. 选择 **每个用户每个周期的最大已认证 API 请求数**。
   1. 选择 **已认证 API 速率限制周期（秒）**。

---

注意删除 Related topics 部分后，直接结束。末尾多一行空行。完成。