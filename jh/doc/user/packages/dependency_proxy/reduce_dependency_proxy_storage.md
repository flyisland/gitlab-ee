---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 减少容器镜像的依赖代理存储空间
description: 通过清理策略、API 缓存清除和 TTL 设置在极狐GitLab 依赖代理中管理 blob 存储。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Blob 没有自动移除流程。除非手动删除，否则它们会被无限期存储。本页面介绍了几种从缓存中清除未使用项的方案。

## 检查依赖代理存储使用情况

[**使用配额**](../../storage_usage_quotas.md) 页面显示了容器镜像依赖代理的存储使用情况。

## 使用 API 清除缓存

要回收不再需要的镜像 blob 所占用的磁盘空间，请使用
[依赖代理 API](../../../api/dependency_proxy.md)
清除整个缓存。如果清除了缓存，下次流水线运行时必须从 Docker Hub 拉取镜像或标签。

## 清理策略

{{< history >}}

- 在极狐GitLab 15.0 中，所需角色从开发者[变更](为维护者。
- 在极狐GitLab 17.0 中，所需角色从维护者[变更](为所有者。

{{< /history >}}

### 从极狐GitLab 内部启用清理策略

你可以通过用户界面为容器镜像的依赖代理启用自动生存时间（TTL）策略。为此，请前往你的群组 **设置** > **软件包和镜像仓库** > **依赖代理**，并启用 90 天后自动清除缓存项的设置。

### 使用 GraphQL 启用清理策略

清理策略是一个计划任务，用于清除不再使用的缓存镜像，从而释放额外的存储空间。该策略使用生存时间（TTL）逻辑：

- 配置天数。
- 所有在指定天数内未被拉取过的缓存依赖代理文件都将被删除。

使用 [GraphQL API](../../../api/graphql/reference/_index.md#mutationupdatedependencyproxyimagettlgrouppolicy)
启用并配置清理策略：

```graphql
mutation {
  updateDependencyProxyImageTtlGroupPolicy(input:
    {
      groupPath: "<你的完整群组路径>",
      enabled: true,
      ttl: 90
    }
  ) {
    dependencyProxyImageTtlPolicy {
      enabled
      ttl
    }
    errors
  }
}
```

请参阅 [GraphQL 入门指南](../../../api/graphql/getting_started.md)
了解如何进行 GraphQL 查询。

当策略首次启用时，默认的 TTL 设置为 90 天。启用后，过期的依赖代理文件每天都会被加入删除队列。由于处理时间的原因，删除可能不会立即发生。如果在缓存文件被标记为过期后又拉取了该镜像，这些过期文件将被忽略，系统会从外部镜像仓库下载新文件并进行缓存。