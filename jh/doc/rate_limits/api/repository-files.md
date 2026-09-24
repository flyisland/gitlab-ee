---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: 为代码仓库文件 API 配置速率限制。
title: 代码仓库文件 API 速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

[代码仓库文件 API](../../api/repository_files.md) 允许您获取、创建、更新和删除代码仓库中的文件。为了提高 Web 应用程序的安全性和持久性，您可以对此 API 实施[速率限制](../_index.md)。您为文件 API 创建的任何速率限制都会覆盖[常规用户和 IP 速率限制](../../administration/settings/user_and_ip_rate_limits.md)。

<a id="define-files-api-rate-limits"></a>

## 定义文件 API 速率限制

文件 API 的速率限制默认处于禁用状态。启用后，对于[代码仓库文件 API](../../api/repository_files.md) 的请求，这些限制将取代常规用户和 IP 速率限制。您可以保留已有的任何常规用户和 IP 速率限制，并增加或减少文件 API 的速率限制。此覆盖不提供任何其他新功能。

前提条件：

- 您必须具有该实例的管理员访问权限。

要覆盖对代码仓库文件 API 请求的常规用户和 IP 速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **文件 API 速率限制**。
1. 选中您要启用的速率限制类型对应的复选框：
   - **未认证 API 请求速率限制**
   - **已认证 API 请求速率限制**
1. 如果您选择了 **未认证**：
   1. 选择 **每个 IP 每周期最大未认证 API 请求数**。
   1. 选择 **未认证 API 速率限制周期（秒）**。
1. 如果您选择了 **已认证**：
   1. 选择 **每个用户每周期最大已认证 API 请求数**。
   1. 选择 **已认证 API 速率限制周期（秒）**。
