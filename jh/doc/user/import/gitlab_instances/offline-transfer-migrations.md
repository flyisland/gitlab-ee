---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用离线迁移方式迁移群组和项目
description: "通过对象存储迁移极狐GitLab 群组和项目。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

离线迁移通过对象存储在不同实例之间复制极狐GitLab 群组和项目，
源实例与目标实例之间无需直接网络连接。
源实例将数据导出到存储桶，目标实例从它可以读取的存储桶中导入数据。

与[通过直接迁移进行迁移](../../group/import/direct_transfer_migrations.md)（需要目标实例连接到源实例）不同，离线迁移将导出和导入解耦。导出存储桶和导入存储桶不必是同一个存储桶，也不必使用相同的对象存储提供商。如果目标实例无法访问导出存储桶，请将导出文件移动到目标实例可以访问的存储桶。极狐GitLab 不会为您移动这些文件。

离线迁移同时受功能标志和应用程序设置控制。所有这些默认均为关闭状态，对于给定操作，两层都必须开启：

- 导出：`offline_transfer_exports_enabled` 应用程序设置。
- 导入：`offline_transfer_imports_enabled` 应用程序设置。

要执行导出和导入，请使用[离线迁移 REST API](https://api.gitlab.com/rest/#tag/offline-transfers)。在极狐GitLab UI 中支持离线迁移已在[工作项 19870](https://gitlab.com/groups/gitlab-org/-/work_items/19870) 中提出。

<a id="version-requirements"></a>

## 版本要求

要创建离线迁移导出，源实例必须运行极狐GitLab 19.3 或更高版本。要导入导出文件，目标实例必须运行极狐GitLab 19.3 或更高版本。

每次导出都会记录创建它的源实例的版本。如果该版本早于目标实例支持的最低版本，则导入将失败并显示 `Unsupported GitLab version` 错误。

<a id="supported-object-storage-providers"></a>

## 支持的对象存储提供商

离线迁移支持以下对象存储提供商：

| 提供商 | 描述 |
| -------- | ----------- |
| AWS S3 | Amazon S3 对象存储。 |
| 兼容 S3 | MinIO 和其他兼容 S3 的提供商。需要管理员[开启兼容 S3 的对象存储](../../../administration/settings/import_and_export_settings.md#allow-s3-compatible-object-storage-for-offline-transfer)。 |
| Google Cloud Storage（服务账号） | 使用服务账号 JSON 密钥进行身份验证的 Google Cloud Storage。 |
| Google Cloud Storage（HMAC） | 使用 S3 互操作 HMAC 密钥进行身份验证的 Google Cloud Storage。 |
| 使用 Application Default Credentials 的 Google Cloud Storage | 使用 Application Default Credentials (ADC) 进行身份验证的 Google Cloud Storage。仅限于管理员和特定存储桶，在 JihuLab.com 上不可用。有关更多信息，请参阅 [Application Default Credentials](#application-default-credentials)。 |

<a id="required-permissions"></a>

### 所需权限

您提供的对象存储凭据必须具有以下权限。

对于 AWS S3：

- 导出：`s3:PutObject` 和 `s3:ListBucket`
- 导入：`s3:GetObject` 和 `s3:ListBucket`

对于使用服务账号的 Google Cloud Storage：

- 导出：`storage.buckets.get`、`storage.objects.create` 和 `storage.objects.list`
- 导入：`storage.objects.get`

使用 ADC 的 Google Cloud Storage 需要相同的权限，由实例的服务账号持有，而不是由您提供的密钥持有。

Google Cloud Storage HMAC 密钥通过 S3 互操作 API 进行身份验证，因此它们需要上面列出的 AWS S3 权限，而不是 `storage.*` 权限。

其他兼容 S3 的提供商的权限因提供商而异。请为您的提供商配置与上面列出的 AWS S3 权限等效的读写权限。

<a id="application-default-credentials"></a>

### Application Default Credentials

使用 ADC 的 Google Cloud Storage 以运行极狐GitLab 的实例的服务账号身份进行身份验证，而不是以启动迁移的用户身份。由于该服务账号通常比任何单个用户拥有更多权限，极狐GitLab 将 ADC 迁移限制为管理员以及名称以 `gitlab-offline-transfer-` 开头的存储桶。

管理员还必须为实例开启 ADC。有关安全影响和完整限制列表，请参阅[允许离线迁移使用 Application Default Credentials](../../../administration/settings/import_and_export_settings.md#allow-application-default-credentials-for-offline-transfer)。

<a id="migrated-items"></a>

## 迁移的项

离线迁移导入的群组和项目项与通过直接迁移进行迁移时的相同。有关完整列表，请参阅[已迁移的群组项](../../group/import/migrated_items.md#migrated-group-items)和[已迁移的项目项](../../group/import/migrated_items.md#migrated-project-items)。

以下项不通过离线迁移导入：

- 群组和项目成员资格。支持成员资格导入已在[工作项 538356](https://gitlab.com/gitlab-org/gitlab/-/work_items/538356) 中提出。
- Wiki。支持 Wiki 导入已在[工作项 538858](https://gitlab.com/gitlab-org/gitlab/-/work_items/538858) 中提出。
- 代码片段。支持代码片段导入已在[工作项 538347](https://gitlab.com/gitlab-org/gitlab/-/work_items/538347) 中提出。
- 徽章。支持徽章导入已在[工作项 538355](https://gitlab.com/gitlab-org/gitlab/-/work_items/538355) 中提出。

当您导入一个群组时，如果其子群组和项目存在于导出文件中，则它们总是会被导入。

<a id="user-contribution-mapping"></a>

## 用户贡献映射

离线迁移永远不会在目标实例上创建真实用户。相反，导入的贡献会映射到[占位用户](../../import/mapping/post_migration_mapping.md#placeholder-users)。导入完成后，[重新分配占位用户](../../import/mapping/reassignment.md)给目标实例上的用户。

由于离线迁移不导入群组和项目成员资格，您必须自行将成员添加到导入的群组和项目中。

<a id="visibility-rules"></a>

## 可见性规则

离线迁移应用与通过直接迁移进行迁移相同的可见性规则。有关更多信息，请参阅[可见性规则](../../group/import/_index.md#visibility-rules)。

<a id="migrate-a-group-or-project"></a>

## 迁移群组或项目

先决条件：

- 要导出项目，您必须至少具有该项目的维护者角色。
- 要导出群组，您必须具有该群组的所有者角色。
- 要导入到群组，您必须具有目标群组的所有者角色。
- 要将群组作为顶级群组导入，您必须具有创建群组的权限。
- 要为导出或导入使用 Application Default Credentials，您必须具有管理员访问权限。

要迁移群组或项目：

1. 在源实例上，使用 REST API [创建离线迁移导出](https://api.gitlab.com/rest/#tag/offline-transfers/POST/api/v4/offline_exports)到对象存储桶。
1. 导出完成后，极狐GitLab 会向您发送一封包含导出前缀的电子邮件。您需要此前缀才能开始导入。如果您未收到电子邮件，可以在对象存储服务中查看导出前缀。
1. 如果目标实例无法访问导出存储桶，请将导出文件移动到目标实例可以访问的存储桶。
1. 在目标实例上，从存储桶和导出前缀[创建离线迁移导入](https://api.gitlab.com/rest/#tag/offline-transfers/POST/api/v4/offline_imports)。
1. 使用[群组和项目直接迁移 API](../../../api/bulk_imports.md#retrieve-a-group-or-project-migration) 监控导入。

<a id="rate-limits"></a>

## 速率限制

离线迁移导出和导入受速率限制。有关更多信息，请参阅[不可配置的速率限制](../../../rate_limits/non_configurable.md)。
