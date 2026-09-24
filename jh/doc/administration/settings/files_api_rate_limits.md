---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: Configure rate limits for the repository files API.
title: 仓库文件 API 的速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

[仓库文件 API](../../api/repository_files.md) 使您能够获取、创建、更新和删除仓库中的文件。为了提高 Web 应用程序的安全性和耐久性，您可以对此 API 强制[速率限制](../../security/rate_limits.md)。您为文件 API 创建的任何速率限制都会覆盖[通用用户和 IP 速率限制](user_and_ip_rate_limits.md)。

<a id="define-files-api-rate-limits"></a>

## 定义文件 API 速率限制

文件 API 的速率限制默认禁用。启用后，它们会取代针对[仓库文件 API](../../api/repository_files.md) 请求的通用用户和 IP 速率限制。您可以保留现有的通用用户和 IP 速率限制，并增加或减少文件 API 的速率限制。此覆盖不提供其他新功能。

先决条件：

- 您必须具有实例的管理员访问权限。

要覆盖对仓库文件 API 请求的通用用户和 IP 速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **网络**。
1. 展开 **文件 API 速率限制**。
1. 选中要为哪些类型的速率限制启用的复选框：
   - **未认证 API 请求速率限制**
   - **经认证的 API 请求速率限制**
1. 如果您选择了 **未认证**：
   1. 选择 **每个 IP 每个周期最大未认证 API 请求数**。
   1. 选择 **未认证 API 速率限制周期（秒）**。
1. 如果您选择了 **经认证**：
   1. 选择 **每个用户每个周期最大经认证 API 请求数**。
   1. 选择 **经认证 API 速率限制周期（秒）**。