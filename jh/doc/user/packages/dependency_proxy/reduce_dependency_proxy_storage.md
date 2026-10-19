---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 减少容器镜像的依赖代理存储占用
description: 通过清理策略、API 缓存清除和 TTL 设置管理极狐GitLab 依赖代理中的 blob 存储。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

blob 没有自动删除流程。除非您手动删除它们，否则它们会无限期存储。本页介绍了几种从缓存中清除未使用条目的方法。

<a id="check-dependency-proxy-storage-use"></a>

## 检查依赖代理存储使用情况

[**用量配额**](../../storage_usage_quotas.md)页面显示容器镜像依赖代理的存储使用情况。

<a id="use-the-api-to-clear-the-cache"></a>

## 使用 API 清除缓存

要回收不再需要的镜像 blob 所占用的磁盘空间，请使用[依赖代理 API](../../../api/dependency_proxy.md) 清除整个缓存。如果您清除了缓存，下次流水线运行时必须从 Docker Hub 拉取镜像或标签。

<a id="cleanup-policies"></a>

## 清理策略

<a id="enable-cleanup-policies-from-within-gitlab"></a>

### 在极狐GitLab 中启用清理策略

您可以在用户界面中为容器镜像依赖代理启用自动生存时间（TTL）策略。为此，请转到您群组的**设置** > **软件包和镜像仓库** > **依赖代理**，并启用相应设置，以便在 90 天后自动清除缓存中的条目。

<a id="enable-cleanup-policies-with-graphql"></a>

### 使用 GraphQL 启用清理策略

清理策略是一个计划作业，您可以用它来清除不再使用的缓存镜像，从而释放更多存储空间。这些策略使用生存时间（TTL）逻辑：

- 配置天数。
- 所有在该天数内未被拉取的缓存依赖代理文件都会被删除。

使用 [GraphQL API](../../../api/graphql/reference/_index.md#mutationupdatedependencyproxyimagettlgrouppolicy)
启用并配置清理策略：

```graphql
mutation {
  updateDependencyProxyImageTtlGroupPolicy(input:
    {
      groupPath: "<your-full-group-path>",
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

请参阅 [GraphQL 入门](../../../api/graphql/getting_started.md)
指南，了解如何发起 GraphQL 查询。

策略首次启用时，默认 TTL 设置为 90 天。启用后，过期的依赖代理文件每天都会排队等待删除。由于处理时间的原因，删除可能不会立即发生。如果在缓存文件被标记为过期后拉取该镜像，则过期的文件会被忽略，并从外部镜像仓库下载并缓存新文件。
