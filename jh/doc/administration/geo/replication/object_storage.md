---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: Geo 与对象存储
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 对象存储中的文件验证在极狐GitLab 16.4 中被引入，使用功能标志 `geo_object_storage_verification`，默认启用。

{{< /history >}}

Geo 可与对象存储（AWS S3 或其他兼容的对象存储）结合使用。

**次要** 站点可以使用以下方式之一：

- 与 **主站点** 相同的存储桶。
- 复制存储桶。
- 如果主站点使用本地存储，则使用本地存储。

文件的存储方法（本地或对象存储）记录在数据库中，并且数据库从 **主** Geo 站点复制到 **次要** Geo 站点。

访问上传的对象时，我们从数据库中获取其存储方法（本地或对象存储），因此 **次要** Geo 站点必须与 **主** Geo 站点的存储方法匹配。

因此，如果 **主** Geo 站点使用对象存储，**次要** Geo 站点也必须使用它。

要使用：

- 极狐GitLab 管理复制，请遵循 [启用极狐GitLab 复制](#enabling-gitlab-managed-object-storage-replication)。
- 第三方服务管理复制，请遵循 [第三方复制服务](#third-party-replication-services)。

[阅读有关使用对象存储与极狐GitLab 的更多信息](../../object_storage.md)。

<a id="object-storage-verification"></a>

## 对象存储验证

Geo 验证存储在对象存储中的文件，以确保主站点和次要站点之间的数据完整性。

> [!warning]
> 不建议禁用对象存储验证。
> 当您禁用 `geo_object_storage_verification` 功能标志时，极狐GitLab 将异步删除所有现有的验证状态记录。

当 `geo_object_storage_verification` 功能标志被禁用时：

- Geo 验证工作器（`Geo::VerificationBatchWorker`）仍然可能出现在 Sidekiq 日志中，但验证不会发生。
- 在清理验证记录期间，工作器可能会被排入队列以处理剩余记录。

<a id="enabling-gitlab-managed-object-storage-replication"></a>

## 启用极狐GitLab 管理的对象存储复制

{{< history >}}

- 在极狐GitLab 15.1 中引入。

{{< /history >}}

> [!warning]
> 在出现问题时，请避免手动删除单个文件，因为这可能导致 [数据不一致](#inconsistencies-after-the-migration)。

**次要** 站点可以复制 **主站点** 存储的文件，无论它们是存储在本地文件系统中还是存储在对象存储中。

要启用极狐GitLab 复制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 在 **次要** 站点上选择 **编辑**。
1. 在 **同步设置** 部分，找到 **允许此次要站点复制对象存储中的内容** 复选框以启用它。

对于 LFS，请按照文档设置 [LFS 对象存储](../../lfs/_index.md#storing-lfs-objects-in-remote-object-storage)。

对于 CI 作业产物，有类似的文档来配置 [作业产物对象存储](../../cicd/job_artifacts.md#using-object-storage)。

对于用户上传，有类似的文档来配置 [上传对象存储](../../uploads.md#using-object-storage)。

如果要将 **主站点** 的文件迁移到对象存储，可以通过以下几种方式配置 **次要** 站点：

- 使用完全相同的对象存储。
- 使用单独的对象存储，但利用您的对象存储解决方案的内置复制功能。
- 使用单独的对象存储，并启用 **允许此次要站点复制对象存储中的内容** 设置。

如果 **允许此次要站点复制对象存储中的内容** 设置被禁用，并且您已将所有文件从本地存储迁移到对象存储，那么许多 **管理员** > **Geo** > **站点** 进度条会显示 **无内容可同步**。

> [!warning]
> 为避免数据丢失，仅当您为主站点和次要站点使用单独的对象存储时，才应启用 **允许此次要站点复制对象存储中的内容** 设置。

极狐GitLab 不支持同时满足以下条件的情况：

- **主站点** 使用本地存储。
- **次要** 站点使用对象存储。

<a id="inconsistencies-after-the-migration"></a>

### 迁移后的不一致性

从本地存储迁移到对象存储时可能会发生数据不一致，这在 [对象存储故障排除部分](../../object_storage.md#inconsistencies-after-migrating-to-object-storage) 中有进一步描述。

<a id="third-party-replication-services"></a>

## 第三方复制服务

使用 Amazon S3 时，您可以使用 [跨区域复制（CRR）](https://docs.aws.amazon.com/AmazonS3/latest/dev/crr.html)，在 **主站点** 使用的存储桶与 **次要** 站点使用的存储桶之间进行自动复制。

如果您使用 Google Cloud Storage，请考虑使用 [多区域存储](https://cloud.google.com/storage/docs/storage-classes#multi-regional)。或者，您可以使用 [存储转移服务](https://cloud.google.com/storage-transfer/docs/overview)，尽管这仅支持每日同步。

对于手动同步，或按计划通过 `cron` 进行同步，请参阅：

- [`s3cmd sync`](https://s3tools.org/s3cmd-sync)
- [`gsutil rsync`](https://cloud.google.com/storage/docs/gsutil/commands/rsync)