---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为特定极狐GitLab API 端点配置速率限制。
title: API 速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

大多数 API 请求会计入[通用用户和 IP 速率限制](../../administration/settings/user_and_ip_rate_limits.md)。
对于某些 API，您可以改为配置单独的速率限制。
API 速率限制会取代针对该 API 请求的通用限制。
您可以提高或降低单个 API 的限制，而无需更改通用限制。
其他行为不变。

要配置这些限制，请前往**管理区域**，选择**设置** > **网络**。

<a id="available-api-rate-limits"></a>

## 可用的 API 速率限制

| API | 描述 |
|:----|:------------|
| [已弃用的端点](deprecated.md) | 限制那些已有替代方案、但由于不能破坏向后兼容性而无法移除的端点。 |
| [群组 API](groups.md) | 限制列出、检索、创建和归档群组，以及列出和删除群组成员的请求。 |
| [组织 API](organizations.md) | 限制创建组织的请求。 |
| [软件包仓库](package-registry.md) | 限制对 Packages API 的请求，下游项目会调用该 API 来解析依赖项。 |
| [项目 API](projects.md) | 限制列出、检索和创建项目，以及列出和删除项目成员的请求。 |
| [代码仓库文件 API](repository-files.md) | 限制获取、创建、更新和删除代码仓库中文件的请求。 |
| [用户 API](users.md) | 限制读取用户的关注者、状态、SSH 密钥和 GPG 密钥的请求。 |
