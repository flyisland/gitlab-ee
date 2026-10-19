---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: Geo 与对象存储
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Geo 可以与对象存储（AWS S3 或其他兼容的对象存储）结合使用。

从站点可以使用以下方式之一：

- 与主站点使用同一个存储桶。
- 使用一个已复制的存储桶。
- 如果主站点使用本地存储，则使用本地存储。

文件的存储方式（本地存储或对象存储）记录在数据库中，而数据库会从 Geo 主站点复制到 Geo 从站点。

访问上传的对象时，我们会从数据库中获取其存储方式（本地存储或对象存储），因此 Geo 从站点必须与 Geo 主站点的存储方式一致。

因此，如果 Geo 主站点使用对象存储，Geo 从站点也必须使用对象存储。

若要：

- 由极狐GitLab 管理复制，请遵循[启用极狐GitLab 复制](#enabling-gitlab-managed-object-storage-replication)。
- 由第三方服务管理复制，请遵循[第三方复制服务](#third-party-replication-services)。

[详细了解如何将对象存储与极狐GitLab 配合使用](../../object_storage.md)。

<a id="object-storage-verification"></a>

## 对象存储验证

Geo 会验证存储在对象存储中的文件，以确保主站点和从站点之间的数据完整性。

`geo_object_storage_verification`
[功能标志](../../feature_flags/_index.md)控制对象存储验证，且默认启用。作为一种运维控制手段，如果验证对象存储中的文件会导致实例上出现过多的数据库负载或内存占用，您可以禁用该功能标志。

> [!warning]
> 不建议禁用对象存储验证。
> 当您禁用 `geo_object_storage_verification` 功能标志时，极狐GitLab 会异步删除所有现有的验证状态记录。

当 `geo_object_storage_verification` 功能标志被禁用时：

- Geo 验证工作进程（`Geo::VerificationBatchWorker`）仍可能出现在 Sidekiq 日志中，但不会执行验证。
- 在清理验证记录期间，可能会将工作进程加入队列以处理剩余记录。

<a id="enabling-gitlab-managed-object-storage-replication"></a>

## 启用极狐GitLab 管理的对象存储复制

> [!warning]
> 如果出现问题，请避免手动删除单个文件，因为这可能导致[数据不一致](#inconsistencies-after-the-migration)。

从站点可以复制主站点存储的文件，无论这些文件存储在本地文件系统还是对象存储中。

要启用极狐GitLab 复制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 在从站点上选择**编辑**。
1. 在**同步设置**部分，找到**允许此从站点复制对象存储中的内容**
   复选框并将其启用。

对于 LFS，请遵循文档[设置 LFS 对象存储](../../lfs/_index.md#storing-lfs-objects-in-remote-object-storage)。

对于 CI 作业产物，有类似的文档可用于配置[作业产物对象存储](../../cicd/job_artifacts.md#using-object-storage)。

对于用户上传内容，有类似的文档可用于配置[上传对象存储](../../uploads.md#using-object-storage)。

如果您想将主站点的文件迁移到对象存储，可以通过以下几种方式配置从站点：

- 使用完全相同的对象存储。
- 使用单独的对象存储，但利用对象存储解决方案内置的复制功能。
- 使用单独的对象存储，并启用**允许此从站点复制对象存储中的内容**设置。

如果**允许此从站点复制对象存储中的内容**设置被禁用，并且您已将所有文件从本地存储迁移到对象存储，那么许多**管理员** > **Geo** > **站点**进度条会显示**无需同步**。

> [!warning]
> 为避免数据丢失，只有在主站点和从站点使用单独的对象存储时，才应启用 **允许此从站点复制
> 对象存储中的内容** 设置。

极狐GitLab 不支持以下两种情况同时存在：

- 主站点使用本地存储。
- 从站点使用对象存储。

<a id="inconsistencies-after-the-migration"></a>

### 迁移后的不一致

从本地存储迁移到对象存储时可能会出现数据不一致，这在[对象存储故障排除部分](../../object_storage.md#inconsistencies-after-migrating-to-object-storage)中有进一步说明。

<a id="third-party-replication-services"></a>

## 第三方复制服务

使用 Amazon S3 时，您可以使用[跨区域复制（CRR）](https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication.html)在主站点使用的存储桶与从站点使用的存储桶之间进行自动复制。

如果您使用的是 Google Cloud Storage，请考虑使用
[多区域存储](https://cloud.google.com/storage/docs/storage-classes#multi-regional)。
或者您可以使用 [Storage Transfer Service](https://docs.cloud.google.com/storage-transfer/docs/overview)，
不过它仅支持每日同步。

如需手动同步，或通过 `cron` 定时同步，请参阅：

- [`s3cmd sync`](https://s3tools.org/s3cmd-sync)
- [`gsutil rsync`](https://docs.cloud.google.com/storage/docs/gsutil)
