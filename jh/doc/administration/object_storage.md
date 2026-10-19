---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: 对象存储
description: 为数据配置对象存储服务。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 支持使用对象存储服务来保存多种类型的数据。相比 NFS，更推荐使用对象存储；在较大规模的部署中，对象存储通常性能更高、更可靠，也更具可扩展性。

要配置对象存储，您有两种选择：

- 推荐做法。[为所有对象类型配置单一存储连接](#configure-a-single-storage-connection-for-all-object-types-consolidated-form)：
  所有受支持的对象类型共享同一组凭据。这称为整合形式。
- [为每种对象类型配置各自的存储连接](#configure-each-object-type-to-define-its-own-storage-connection-storage-specific-form)：
  每个对象都定义自己的对象存储连接和配置。这称为特定于存储的形式。

  如果您已经在使用特定于存储的形式，请参阅如何
  [过渡到整合形式](#transition-to-consolidated-form)。

如果您将数据存储在本地，请参阅如何[迁移到对象存储](#migrate-to-object-storage)。

<a id="object-storage-provider-support"></a>

## 对象存储提供商支持

极狐GitLab 使用 [Fog 库](https://fog.github.io/about/supported_services.html)实现对象存储，并支持以下三种连接类型。不支持其他 Fog 提供商。

| 连接类型      | `provider` 值 | 配合使用 |
|:---------------------|:-----------------|:---------|
| S3 兼容        | `AWS`            | Amazon S3 及任何 S3 兼容服务 |
| Google Cloud Storage | `Google`         | Google Cloud Storage |
| Azure Blob Storage   | `AzureRM`        | Azure Blob Storage |

如果您的对象存储服务与其中一种连接类型兼容，请使用下方对应的连接设置进行配置。选择哪个提供商由您决定。

<a id="providers-with-active-test-coverage"></a>

### 具有活跃测试覆盖的提供商

极狐GitLab 会主动测试以下提供商：

- [Amazon S3](https://aws.amazon.com/s3/) - `AWS` 连接类型。不支持 [Object Lock](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html)。
  更多信息，请参阅[议题 335775](https://gitlab.com/gitlab-org/gitlab/-/issues/335775)。
- [Google Cloud Storage](https://cloud.google.com/storage) - `Google` 连接类型。
- [Azure Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction) - `AzureRM`
  连接类型。

<a id="community-documented-providers"></a>

### 社区记录的提供商

以下提供商由社区记录。极狐GitLab 不会测试这些提供商。提供配置示例仅供参考。如果您使用其中某个提供商并遇到问题，极狐GitLab 支持可能无法提供帮助。

- [Digital Ocean Spaces](https://www.digitalocean.com/products/spaces)。S3 兼容，请参阅
  [特定于提供商的配置示例](#provider-specific-configuration-examples)。
- [Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/s3compatibleapi.htm)。
  S3 兼容，请参阅[特定于提供商的配置示例](#provider-specific-configuration-examples)。
- [OpenStack Swift](https://docs.openstack.org/swift/latest/s3_compat.html)（S3 兼容模式）。
- [Storj Gateway](https://www.storj.io/)。S3 兼容，请参阅
  [特定于提供商的配置示例](#provider-specific-configuration-examples)。
- [Ceph RGW](https://docs.ceph.com/en/reef/cephadm/services/rgw/)。S3 兼容，请参阅
  [特定于提供商的配置示例](#provider-specific-configuration-examples)
- [Hitachi Vantara HCP](https://docs.hitachivantara.com/r/en-us/content-platform/9.7.x/mk-95hcph001/hcp-management-api-reference/introduction-to-the-hcp-management-api/support-for-the-amazon-s3-api)。
  S3 兼容，请参阅[特定于提供商的配置示例](#provider-specific-configuration-examples)。
- 提供 S3 兼容 API 的本地硬件和设备。

<a id="configure-a-single-storage-connection-for-all-object-types-consolidated-form"></a>

## 为所有对象类型配置单一存储连接（整合形式）

大多数类型的对象，例如 CI 产物、LFS 文件和上传附件，都可以通过为对象存储指定单一凭据并配合多个存储桶，保存到对象存储中。

> [!note]
> 对于 GitLab Helm Charts，请参阅如何[配置整合形式](https://gitlab.cn/docs/charts/charts/globals/#consolidated-object-storage)。

使用整合形式配置对象存储有许多优势：

- 它可以简化您的极狐GitLab 配置，因为连接详情在各对象类型之间共享。
- 它支持使用[加密的 S3 存储桶](#encrypted-s3-buckets)。
- 它会[使用正确的 `Content-MD5` 请求头将文件上传到 S3](https://gitlab.com/gitlab-org/gitlab-workhorse/-/issues/222)。

使用整合形式时，会自动启用直接上传。因此，只能使用以下提供商：

- [S3 兼容提供商](#s3-compatible-providers)
- [Google Cloud Storage](#google-cloud-storage-gcs)
- [Azure Blob storage](#azure-blob-storage)

整合形式配置不能用于备份或
Mattermost。备份可以单独使用
[服务器端加密](backup_restore/backup_gitlab.md#s3-encrypted-buckets)进行配置。请参阅[完整列表表格](#configure-each-object-type-to-define-its-own-storage-connection-storage-specific-form)了解受支持的对象存储类型。

启用整合形式会为所有对象类型启用对象存储。如果未指定所有存储桶，您可能会看到类似以下的错误：

```plaintext
Object storage for <object type> must have a bucket specified
```

如果您想对特定对象类型使用本地存储，可以[为特定功能禁用对象存储](#disable-object-storage-for-specific-features)。

<a id="configure-the-common-parameters"></a>

### 配置通用参数

在整合形式中，`object_store` 部分定义了一组通用参数。

| 设置                    | 描述                       |
|----------------------------|------------------------------------|
| `enabled`                  | 启用或禁用对象存储。 |
| `proxy_download`           | 设置为 `true` 以[启用代理所有已提供的文件](#proxy-download)。设置为 `false` 时，客户端直接从远程存储下载，减少极狐GitLab 服务器上的出站流量。 |
| `allowed_download_modes`   | API 客户端在受支持的端点上通过 `download_mode` 参数允许请求的传输模式。默认仅允许 `proxy_download` 设置的模式。设置为 `[proxy, direct]` 可[让客户端请求直接下载](#allow-client-override-for-proxy-download)。 |
| `connection`               | 下文描述的各种[连接选项](#configure-the-connection-settings)。 |
| `storage_options`          | 保存新对象时使用的选项，例如[服务器端加密](#server-side-encryption-headers)。 |
| `objects`                  | [特定于对象的配置](#configure-the-parameters-of-each-object)。 |

有关示例，请参阅如何[使用整合形式和 Amazon S3](#full-example-using-the-consolidated-form-and-amazon-s3)。

<a id="configure-the-parameters-of-each-object"></a>

### 配置每个对象的参数

每种对象类型至少必须定义其存储所用的存储桶名称。

下表列出了可以使用的有效 `objects`：

| 类型               | 描述 |
|--------------------|-------------|
| `artifacts`        | [CI/CD 作业产物](cicd/job_artifacts.md) |
| `external_diffs`   | [合并请求差异](merge_request_diffs.md) |
| `uploads`          | [用户上传](uploads.md) |
| `lfs`              | [Git Large File Storage 对象](lfs/_index.md) |
| `packages`         | [项目软件包（例如 PyPI、Maven 或 NuGet）](packages/_index.md)|
| `dependency_proxy` | [依赖代理](packages/dependency_proxy.md) |
| `terraform_state`  | [Terraform 状态文件](terraform_state.md) |
| `pages`            | [Pages](pages/_index.md) |
| `ci_secure_files`  | [安全文件](cicd/secure_files.md) |
| `ci_catalog_bundles` | [CI/CD 组件包](../ci/components/_index.md) |

在每种对象类型中，可以定义四个参数：

| 设置                  | 是否必需？   | 描述                                                         |
|--------------------------|-------------|----------------------------------------------------------------------|
| `bucket`                 | {{< yes >}} | 该对象类型的存储桶名称。如果 `enabled` 设置为 `false`，则不需要。 |
| `enabled`                | {{< no >}}  | 覆盖[通用参数](#configure-the-common-parameters)。 |
| `proxy_download`         | {{< no >}}  | 覆盖[通用参数](#configure-the-common-parameters)。 |
| `allowed_download_modes` | {{< no >}}  | 覆盖[通用参数](#configure-the-common-parameters)。 |

有关示例，请参阅如何[使用整合形式和 Amazon S3](#full-example-using-the-consolidated-form-and-amazon-s3)。

<a id="disable-object-storage-for-specific-features"></a>

#### 为特定功能禁用对象存储

如前所述，可以通过将 `enabled` 标志设置为 `false` 来为特定类型禁用对象存储。例如，要为 CI 产物禁用对象存储：

```ruby
gitlab_rails['object_store']['objects']['artifacts']['enabled'] = false
```

如果完全禁用该功能，则不需要存储桶。例如，如果使用此设置禁用 CI 产物，则不需要存储桶：

```ruby
gitlab_rails['artifacts_enabled'] = false
```

<a id="configure-each-object-type-to-define-its-own-storage-connection-storage-specific-form"></a>

## 为每种对象类型配置各自的存储连接（特定于存储的形式）

使用特定于存储的形式时，每个对象都定义自己的对象存储连接和配置。您应[使用整合形式](#transition-to-consolidated-form)，但整合形式不支持的存储类型除外。使用 GitLab Helm charts 时，请参阅这些 chart 如何处理[对象存储的整合形式](https://gitlab.cn/docs/charts/charts/globals/#consolidated-object-storage)。

不支持在非整合形式下使用[加密的 S3 存储桶](#encrypted-s3-buckets)。如果使用，您可能会遇到 [ETag 不匹配错误](#etag-mismatch)。

> [!note]
> 对于特定于存储的形式，
> [直接上传可能会成为默认方式](https://gitlab.com/gitlab-org/gitlab/-/issues/27331)，
> 因为它不需要共享文件夹。

对于整合形式不支持的存储类型，请参阅以下指南：

| 对象存储类型 | 整合形式是否支持？ |
|---------------------|------------------------------------------|
| [备份](backup_restore/backup_gitlab.md#upload-backups-to-a-remote-cloud-storage) | {{< no >}} |
| [容器镜像仓库](packages/container_registry.md#use-object-storage)（可选功能） | {{< no >}} |
| [Mattermost](https://docs.mattermost.com/configure/file-storage-configuration-settings.html)| {{< no >}} |
| [自动扩缩 runner 缓存](https://gitlab.cn/docs/runner/configuration/autoscale/#distributed-runners-caching)（可选，用于提升性能） | {{< no >}} |
| [安全文件](cicd/secure_files.md#using-object-storage) | {{< yes >}} |
| [作业产物](cicd/job_artifacts.md#using-object-storage)，包括归档的作业日志 | {{< yes >}} |
| [LFS 对象](lfs/_index.md#storing-lfs-objects-in-remote-object-storage) | {{< yes >}} |
| [上传](uploads.md#using-object-storage) | {{< yes >}} |
| [合并请求差异](merge_request_diffs.md#using-object-storage) | {{< yes >}} |
| [软件包](packages/_index.md#migrate-packages-between-object-storage-and-local-storage)（可选功能） | {{< yes >}} |
| [依赖代理](packages/dependency_proxy.md#using-object-storage)（可选功能） | {{< yes >}} |
| [Terraform 状态文件](terraform_state.md#using-object-storage) | {{< yes >}} |
| [Pages 内容](pages/_index.md#object-storage-settings) | {{< yes >}} |

<a id="configure-the-connection-settings"></a>

## 配置连接设置

整合形式和特定于存储的形式都必须配置连接。以下各节描述可在 `connection` 设置中使用的参数。

<a id="s3-compatible-providers"></a>

### S3 兼容提供商

这些设置适用于 Amazon S3 以及任何使用 `AWS` 连接类型的 S3 兼容服务。如果不直接使用 AWS，请将 `endpoint` 设置为您的提供商的 URL。

S3 兼容服务在实现 AWS S3 API 的紧密程度上各不相同。极狐GitLab 使用特定的 S3 行为，包括预签名 URL、分段上传，以及可选的块签名流式传输，并非每个 S3 兼容实现都以相同方式支持这些行为。如果某个提供商在其他工具中可用但在极狐GitLab 中不可用，最可能需要调整的设置是：

- `aws_signature_version`。
- `enable_signature_v4_streaming`。

连接设置与 [fog-aws](https://github.com/fog/fog-aws) 提供的设置一致：

| 设置                                     | 描述                        | 默认值 |
|---------------------------------------------|------------------------------------|---------|
| `provider`                                  | 对于兼容主机，始终为 `AWS`。 | `AWS` |
| `aws_access_key_id`                         | AWS 凭据，或兼容凭据。    | |
| `aws_secret_access_key`                     | AWS 凭据，或兼容凭据。    | |
| `aws_signature_version`                     | 要使用的 AWS 签名版本。`2` 或 `4` 是有效选项。某些 S3 兼容提供商可能需要 `2`。 | `4` |
| `enable_signature_v4_streaming`             | 设置为 `true` 以启用使用 [AWS v4 签名](https://docs.aws.amazon.com/AmazonS3/latest/developerguide/sigv4-streaming.html)的 HTTP 分块传输。某些 S3 兼容提供商要求将其设置为 `false`。极狐GitLab 17.4 将默认值从 `true` 改为 `false`。 | `false` |
| `region`                                    | AWS 区域。                        | |
| `host`                                      | 已弃用：请改用 `endpoint`。不使用 AWS 时使用的 S3 兼容主机。例如 `localhost` 或 `storage.example.com`。默认使用 HTTPS 和端口 443。 | `s3.amazonaws.com` |
| `endpoint`                                  | 配置 S3 兼容服务时可以使用，输入类似 `http://127.0.0.1:9000`的 URL。它优先于 `host`。整合形式始终使用 `endpoint`。 | （可选） |
| `path_style`                                | 设置为 `true` 以使用 `host/bucket_name/object` 风格的路径，而不是 `bucket_name.host/object`。对于需要路径风格寻址的 S3 兼容服务，设置为 `true`。对于 AWS S3，保持为 `false`。 | `false` |
| `use_iam_profile`                           | 设置为 `true` 以使用 IAM 配置文件而不是访问密钥。 | `false` |
| `aws_credentials_refresh_threshold_seconds` | 在 IAM 中使用临时凭据时，以秒为单位设置[自动刷新阈值](https://github.com/fog/fog-aws#controlling-credential-refresh-time-with-iam-authentication)。必须为整数。 | `15`[^refresh-threshold] |
| `disable_imds_v2`                           | 通过禁用对检索 `X-aws-ec2-metadata-token`的 IMDS v2 端点的访问，强制使用 IMDS v1。 | `false` |

[^refresh-threshold]: 当 `use_iam_profile` 为 `true` 时，GitLab Pages 部署默认使用 `900`。
    默认情况下，GitLab Pages 最多可以提供 11 分钟的缓存预签名 URL
    （`gitlab_cache_expiry` 加上 `zip_cache_expiration`），并且该 URL 仅在
    签署它的临时凭据有效期内有效。使用 EC2 实例配置文件时，此默认值
    会缩短该窗口但不会关闭它，因为实例元数据服务会返回
    相同的凭据，直到 AWS 轮换它们。在整合连接中设置的值同样
    适用于 GitLab Pages，并会替换此默认值。

<a id="s3-compatibility-and-known-failure-modes"></a>

#### S3 兼容性和已知故障模式

声称兼容 S3 并不能保证提供商可以正确地与极狐GitLab 配合使用。如果您在使用 S3 兼容提供商时遇到错误，请在提交支持请求之前尝试以下调整：

- **签名流式传输**：某些提供商拒绝 AWS Signature
  Version 4 流式传输使用的分块传输编码。设置 `enable_signature_v4_streaming: false`。
- **签名版本**：某些提供商不完全支持 Signature Version 4。设置
  `aws_signature_version: 2`。
- **路径风格 URL**：某些提供商要求路径风格的存储桶寻址。设置 `path_style: true`。
- **ETag 验证**：某些提供商返回的 ETag 与上传对象的 MD5 不匹配，
  而极狐GitLab 会对此进行验证。请参阅 [ETag 不匹配](#etag-mismatch)。

极狐GitLab 支持可以帮助排查配置问题，但无法保证解决不在[已测试集合](#providers-with-active-test-coverage)中的提供商所特有的问题。

<a id="use-amazon-instance-profiles"></a>

#### 使用 Amazon 实例配置文件

您无需在对象存储配置中提供 AWS 访问密钥和秘密访问密钥，而是可以配置极狐GitLab 使用 Amazon Identity Access and Management (IAM) 角色来设置
[Amazon 实例配置文件](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html)。使用此方式时，极狐GitLab 每次访问 S3 存储桶时都会获取临时凭据，因此配置中不需要硬编码的值。

先决条件：

- 极狐GitLab 必须能够连接到
  [实例元数据端点](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html)。
- 如果极狐GitLab [配置为使用互联网代理](https://gitlab.cn/docs/omnibus/settings/environment-variables/)，则必须将端点 IP
  地址添加到 `no_proxy` 列表中。
- 对于 IMDS v2 访问，请确保[跳数限制](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html)足够。如果极狐GitLab
  在容器中运行，您可能需要将该限制从 1 提高到 2。

要设置实例配置文件：

1. 创建具有必要权限的 IAM 角色。
   以下示例是一个名为 `test-bucket`的 S3 存储桶的角色：

   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": [
                   "s3:PutObject",
                   "s3:GetObject",
                   "s3:DeleteObject"
               ],
               "Resource": "arn:aws:s3:::test-bucket/*"
           },
           {
               "Effect": "Allow",
               "Action": [
                   "s3:ListBucket"
               ],
               "Resource": "arn:aws:s3:::test-bucket"
           }
       ]
   }
   ```

   > [!note]
   > 如果外部进程会为您的 S3 存储桶中的对象添加标签（例如 AWS GuardDuty Malware
   > Protection），请将 `s3:GetObjectTagging` 添加到源存储桶的对象级 `Action` 列表，
   > 并将 `s3:PutObjectTagging` 添加到目标存储桶。如果没有这些权限，极狐GitLab
   > 在复制带标签的对象时，`CopyObject` 操作会失败并返回 `AccessDenied`。

1. [将此角色附加](https://repost.aws/knowledge-center/attach-replace-ec2-instance-profile)
   到承载您的极狐GitLab 实例的 EC2 实例。
1. 将 `use_iam_profile` 极狐GitLab 配置选项设置为 `true`。

<a id="encrypted-s3-buckets"></a>

#### 加密的 S3 存储桶

无论是使用实例配置文件还是整合形式进行配置，GitLab Workhorse 都能正确地将文件上传到
[默认启用了 SSE-S3 或 SSE-KMS 加密](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html)的 S3
存储桶。AWS KMS 密钥和 SSE-C 加密
[不受支持，因为这需要在每个请求中发送加密密钥](https://gitlab.com/gitlab-org/gitlab/-/issues/226006)。

<a id="server-side-encryption-headers"></a>

#### 服务器端加密请求头

在 S3 存储桶上设置默认加密是启用加密的最简单方式，但您可能希望[设置存储桶策略以确保只上传加密对象](https://repost.aws/knowledge-center/s3-bucket-store-kms-encrypted-objects)。为此，您必须配置极狐GitLab 在 `storage_options` 配置部分中发送正确的加密请求头：

| 设置                             | 描述                              |
|-------------------------------------|------------------------------------------|
| `server_side_encryption`            | 加密模式（`AES256` 或 `aws:kms`）。 |
| `server_side_encryption_kms_key_id` | Amazon Resource Name。仅当 `server_side_encryption`中使用 `aws:kms` 时才需要。请参阅[关于使用 KMS 加密的 Amazon 文档](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingKMSEncryption.html)。 |

与默认加密的情况一样，这些选项仅在启用 Workhorse S3 客户端时有效。必须满足以下两个条件之一：

- 连接设置中的 `use_iam_profile` 为 `true`。
- 正在使用整合形式。

如果在未启用 Workhorse S3 客户端的情况下使用服务器端加密请求头，会出现 [ETag 不匹配错误](#etag-mismatch)。

<a id="google-cloud-storage-gcs"></a>

### Google Cloud Storage (GCS)

以下是 GCS 的有效连接参数：

| 设置                      | 描述       | 示例 |
|------------------------------|-------------------|---------|
| `provider`                   | 提供商名称。    | `Google` |
| `google_project`             | GCP 项目名称。 | `gcp-project-12345` |
| `google_json_key_location`   | JSON 密钥路径。    | `/path/to/gcp-project-12345-abcde.json` |
| `google_json_key_string`     | JSON 密钥字符串。  | `{ "type": "service_account", "project_id": "example-project-382839", ... }` |
| `google_application_default` | 设置为 `true` 以使用 [Google Cloud 应用默认凭据](https://cloud.google.com/docs/authentication#adc)来定位服务账号凭据。 | |
| `universe_domain`            | 用于 Google Cloud 请求的 universe 域。使用此项可连接到 [Google Cloud Dedicated](https://cloud.google.com/sovereign-cloud) 或其他非默认 universe 域。 | `googleapis.com` |

极狐GitLab 会依次读取 `google_json_key_location`、`google_json_key_string`，最后是 `google_application_default`的值。它使用其中第一个有值的设置。

服务账号必须具有访问该存储桶的权限。更多信息，
请参阅 [Cloud Storage 认证文档](https://docs.cloud.google.com/storage/docs/authentication)。

<a id="google-cloud-application-default-credentials"></a>

#### Google Cloud 应用默认凭据

[Google Cloud 应用默认凭据 (ADC)](https://docs.cloud.google.com/docs/authentication/application-default-credentials) 通常
与极狐GitLab 一起使用，以使用默认服务账号或 [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)。
将 `google_application_default` 设置为 `true`，并省略 `google_json_key_location` 和 `google_json_key_string`。

如果使用 ADC，请确保：

- 您使用的服务账号具有
  [`iam.serviceAccounts.signBlob` 权限](https://docs.cloud.google.com/iam/docs/reference/credentials/rest/v1/projects.serviceAccounts/signBlob)。
  通常通过向该服务账号授予 `Service Account Token Creator` 角色来实现。
- 如果您使用 Google Compute 虚拟机，请确保它们具有[访问 Google Cloud API 的正确访问范围](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances#changeserviceaccountandscopes)。如果虚拟机没有正确的范围，错误日志可能会显示：

  ```shell
  Google::Apis::ClientError (insufficientPermissions: Request had insufficient authentication scopes.)
  ```

> [!note]
> 要将存储桶加密与[客户管理的加密密钥](https://docs.cloud.google.com/storage/docs/encryption/using-customer-managed-keys)一起使用，请使用[整合形式](#configure-a-single-storage-connection-for-all-object-types-consolidated-form)。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行，替换
   为您想要的值：

   ```ruby
   gitlab_rails['object_store']['connection'] = {
    'provider' => 'Google',
    'google_project' => '<GOOGLE PROJECT>',
    'google_json_key_location' => '<FILENAME>'
   }
   ```

   要使用 ADC，请改用 `google_application_default`：

   ```ruby
   gitlab_rails['object_store']['connection'] = {
    'provider' => 'Google',
    'google_project' => '<GOOGLE PROJECT>',
    'google_application_default' => true
   }
   ```

   要使用非默认 universe 域（例如 [Google Cloud Dedicated](https://cloud.google.com/sovereign-cloud)）：

   ```ruby
   gitlab_rails['object_store']['connection'] = {
    'provider' => 'Google',
    'google_project' => '<GOOGLE PROJECT>',
    'google_application_default' => true,
    'universe_domain' => '<UNIVERSE DOMAIN>'
   }
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

1. 将以下内容放入名为 `object_storage.yaml`的文件中，用作
   [Kubernetes 密钥](https://gitlab.cn/docs/charts/charts/globals/#connection)：

   ```yaml
   provider: Google
   google_project: <GOOGLE PROJECT>
   google_json_key_location: '<FILENAME>'
   ```

   要使用 ADC，请改用 `google_application_default`：

   ```yaml
   provider: Google
   google_project: <GOOGLE PROJECT>
   google_application_default: true
   ```

   要使用非默认 universe 域（例如 [Google Cloud Dedicated](https://cloud.google.com/sovereign-cloud)）：

   ```yaml
   provider: Google
   google_project: <GOOGLE PROJECT>
   google_application_default: true
   universe_domain: <UNIVERSE DOMAIN>
   ```

1. 创建 Kubernetes 密钥：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-object-storage --from-file=connection=object_storage.yaml
   ```

1. 导出 Helm values：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
        artifacts:
          bucket: gitlab-artifacts
        ciSecureFiles:
          bucket: gitlab-ci-secure-files
          enabled: true
        dependencyProxy:
          bucket: gitlab-dependency-proxy
          enabled: true
        externalDiffs:
          bucket: gitlab-mr-diffs
          enabled: true
        lfs:
          bucket: gitlab-lfs
        object_store:
          connection:
            secret: gitlab-object-storage
          enabled: true
          proxy_download: false
        packages:
          bucket: gitlab-packages
        terraformState:
          bucket: gitlab-terraform-state
          enabled: true
        uploads:
          bucket: gitlab-uploads
   ```

1. 保存文件并应用新的 values：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           # Consolidated object storage configuration
           gitlab_rails['object_store']['enabled'] = true
           gitlab_rails['object_store']['proxy_download'] = false
           gitlab_rails['object_store']['connection'] = {
             'provider' => 'Google',
             'google_project' => '<GOOGLE PROJECT>',
             'google_json_key_location' => '<FILENAME>'
           }
           gitlab_rails['object_store']['objects']['artifacts']['bucket'] = 'gitlab-artifacts'
           gitlab_rails['object_store']['objects']['external_diffs']['bucket'] = 'gitlab-mr-diffs'
           gitlab_rails['object_store']['objects']['lfs']['bucket'] = 'gitlab-lfs'
           gitlab_rails['object_store']['objects']['uploads']['bucket'] = 'gitlab-uploads'
           gitlab_rails['object_store']['objects']['packages']['bucket'] = 'gitlab-packages'
           gitlab_rails['object_store']['objects']['dependency_proxy']['bucket'] = 'gitlab-dependency-proxy'
           gitlab_rails['object_store']['objects']['terraform_state']['bucket'] = 'gitlab-terraform-state'
           gitlab_rails['object_store']['objects']['ci_secure_files']['bucket'] = 'gitlab-ci-secure-files'
           gitlab_rails['object_store']['objects']['pages']['bucket'] = 'gitlab-pages'
   ```

   要使用 ADC，请改用 `google_application_default`：

   ```ruby
   gitlab_rails['object_store']['connection'] = {
     'provider' => 'Google',
     'google_project' => '<GOOGLE PROJECT>',
     'google_application_default' => true
   }
   ```

   要使用非默认 universe 域（例如 [Google Cloud Dedicated](https://cloud.google.com/sovereign-cloud)）：

   ```ruby
   gitlab_rails['object_store']['connection'] = {
     'provider' => 'Google',
     'google_project' => '<GOOGLE PROJECT>',
     'google_application_default' => true,
     'universe_domain' => '<UNIVERSE DOMAIN>'
   }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="azure-blob-storage"></a>

### Azure Blob storage

尽管 Azure 使用 `container` 一词来表示一组 blob，但极狐GitLab 统一使用 `bucket` 这一术语。请务必在 `bucket` 设置中配置 Azure 容器名称。

Azure Blob storage 只能与[整合形式](#configure-a-single-storage-connection-for-all-object-types-consolidated-form)一起使用，
因为使用同一组凭据访问多个容器。不支持[特定于存储的形式](#configure-each-object-type-to-define-its-own-storage-connection-storage-specific-form)。更多详情，请参阅[如何过渡到整合形式](#transition-to-consolidated-form)。

以下是 Azure 的有效连接参数。更多信息，请参阅
[Azure Blob Storage 文档](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction)。

| 设置                      | 描述    | 示例   |
|------------------------------|----------------|-----------|
| `provider`                   | 提供商名称。 | `AzureRM` |
| `azure_storage_account_name` | 用于访问存储的 Azure Blob Storage 账号名称。 | `azuretest` |
| `azure_storage_access_key`   | 用于访问容器的存储账号访问密钥。这通常是一个以 base64 编码的 512 位加密密钥，属于敏感信息。对于 [Azure 工作负载和托管标识](#azure-workload-and-managed-identities)，此项为可选。 | `czV2OHkvQj9FKEgrTWJRZVRoV21ZcTN0Nnc5eiRDJkYpSkBOY1JmVWpYbjJy\nNHU3eCFBJUQqRy1LYVBkU2dWaw==\n` |
| `azure_storage_domain`       | 用于联系 Azure Blob Storage API 的域名（可选）。默认为 `blob.core.windows.net`。如果您使用 Azure 中国或其他自定义 Azure 域，请设置此项。 | `blob.core.windows.net` |

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行，替换
   为您想要的值：

   ```ruby
   gitlab_rails['object_store']['connection'] = {
     'provider' => 'AzureRM',
     'azure_storage_account_name' => '<AZURE STORAGE ACCOUNT NAME>',
     'azure_storage_access_key' => '<AZURE STORAGE ACCESS KEY>',
     'azure_storage_domain' => '<AZURE STORAGE DOMAIN>'
   }
   gitlab_rails['object_store']['objects']['artifacts']['bucket'] = 'gitlab-artifacts'
   gitlab_rails['object_store']['objects']['external_diffs']['bucket'] = 'gitlab-mr-diffs'
   gitlab_rails['object_store']['objects']['lfs']['bucket'] = 'gitlab-lfs'
   gitlab_rails['object_store']['objects']['uploads']['bucket'] = 'gitlab-uploads'
   gitlab_rails['object_store']['objects']['packages']['bucket'] = 'gitlab-packages'
   gitlab_rails['object_store']['objects']['dependency_proxy']['bucket'] = 'gitlab-dependency-proxy'
   gitlab_rails['object_store']['objects']['terraform_state']['bucket'] = 'gitlab-terraform-state'
   gitlab_rails['object_store']['objects']['ci_secure_files']['bucket'] = 'gitlab-ci-secure-files'
   gitlab_rails['object_store']['objects']['pages']['bucket'] = 'gitlab-pages'
   ```

   如果您使用[工作负载标识](#azure-workload-and-managed-identities)，请省略 `azure_storage_access_key`：

   ```ruby
   gitlab_rails['object_store']['connection'] = {
     'provider' => 'AzureRM',
     'azure_storage_account_name' => '<AZURE STORAGE ACCOUNT NAME>',
     'azure_storage_domain' => '<AZURE STORAGE DOMAIN>'
   }
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

1. 将以下内容放入名为 `object_storage.yaml`的文件中，用作
   [Kubernetes 密钥](https://gitlab.cn/docs/charts/charts/globals/#connection)：

   ```yaml
   provider: AzureRM
   azure_storage_account_name: <YOUR_AZURE_STORAGE_ACCOUNT_NAME>
   azure_storage_access_key: <YOUR_AZURE_STORAGE_ACCOUNT_KEY>
   azure_storage_domain: blob.core.windows.net
   ```

   如果您使用[工作负载或托管标识](#azure-workload-and-managed-identities)，请省略 `azure_storage_access_key`：

   ```yaml
   provider: AzureRM
   azure_storage_account_name: <YOUR_AZURE_STORAGE_ACCOUNT_NAME>
   azure_storage_domain: blob.core.windows.net
   ```

1. 创建 Kubernetes 密钥：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-object-storage --from-file=connection=object_storage.yaml
   ```

1. 导出 Helm values：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
        artifacts:
          bucket: gitlab-artifacts
        ciSecureFiles:
          bucket: gitlab-ci-secure-files
          enabled: true
        dependencyProxy:
          bucket: gitlab-dependency-proxy
          enabled: true
        externalDiffs:
          bucket: gitlab-mr-diffs
          enabled: true
        lfs:
          bucket: gitlab-lfs
        object_store:
          connection:
            secret: gitlab-object-storage
          enabled: true
          proxy_download: false
        packages:
          bucket: gitlab-packages
        terraformState:
          bucket: gitlab-terraform-state
          enabled: true
        uploads:
          bucket: gitlab-uploads
   ```

1. 保存文件并应用新的 values：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           # Consolidated object storage configuration
           gitlab_rails['object_store']['enabled'] = true
           gitlab_rails['object_store']['proxy_download'] = false
           gitlab_rails['object_store']['connection'] = {
             'provider' => 'AzureRM',
             'azure_storage_account_name' => '<AZURE STORAGE ACCOUNT NAME>',
             'azure_storage_access_key' => '<AZURE STORAGE ACCESS KEY>',
             'azure_storage_domain' => '<AZURE STORAGE DOMAIN>'
           }
           gitlab_rails['object_store']['objects']['artifacts']['bucket'] = 'gitlab-artifacts'
           gitlab_rails['object_store']['objects']['external_diffs']['bucket'] = 'gitlab-mr-diffs'
           gitlab_rails['object_store']['objects']['lfs']['bucket'] = 'gitlab-lfs'
           gitlab_rails['object_store']['objects']['uploads']['bucket'] = 'gitlab-uploads'
           gitlab_rails['object_store']['objects']['packages']['bucket'] = 'gitlab-packages'
           gitlab_rails['object_store']['objects']['dependency_proxy']['bucket'] = 'gitlab-dependency-proxy'
           gitlab_rails['object_store']['objects']['terraform_state']['bucket'] = 'gitlab-terraform-state'
           gitlab_rails['object_store']['objects']['ci_secure_files']['bucket'] = 'gitlab-ci-secure-files'
           gitlab_rails['object_store']['objects']['pages']['bucket'] = 'gitlab-pages'
   ```

   如果您使用[托管标识](#azure-workload-and-managed-identities)，请省略 `azure_storage_access_key`。

   ```ruby
   gitlab_rails['object_store']['connection'] = {
     'provider' => 'AzureRM',
     'azure_storage_account_name' => '<AZURE STORAGE ACCOUNT NAME>',
     'azure_storage_domain' => '<AZURE STORAGE DOMAIN>'
   }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

对于自行编译的安装，Workhorse 也需要配置 Azure
凭据。Linux 软件包安装不需要这样做，因为 Workhorse
设置会从之前的设置中填充。

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并添加或修改以下行：

   ```yaml
   production: &base
     object_store:
       enabled: true
       proxy_download: false
       connection:
         provider: AzureRM
         azure_storage_account_name: '<AZURE STORAGE ACCOUNT NAME>'
         azure_storage_access_key: '<AZURE STORAGE ACCESS KEY>'
       objects:
         artifacts:
           bucket: gitlab-artifacts
         external_diffs:
           bucket: gitlab-mr-diffs
         lfs:
           bucket: gitlab-lfs
         uploads:
           bucket: gitlab-uploads
         packages:
           bucket: gitlab-packages
         dependency_proxy:
           bucket: gitlab-dependency-proxy
         terraform_state:
           bucket: gitlab-terraform-state
         ci_secure_files:
           bucket: gitlab-ci-secure-files
         pages:
           bucket: gitlab-pages
   ```

1. 编辑 `/home/git/gitlab-workhorse/config.toml` 并添加或修改以下行：

     ```toml
     [object_storage]
       provider = "AzureRM"

     [object_storage.azurerm]
       azure_storage_account_name = "<AZURE STORAGE ACCOUNT NAME>"
       azure_storage_access_key = "<AZURE STORAGE ACCESS KEY>"
     ```

   如果您使用自定义 Azure 存储域，则不必在 Workhorse 配置中设置
   `azure_storage_domain`。此信息会在 GitLab Rails 与
   Workhorse 之间的 API 调用中交换。

1. 保存文件并重启极狐GitLab：

   ```shell
   # For systems running systemd
   sudo systemctl restart gitlab.target

   # For systems running SysV init
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="azure-workload-and-managed-identities"></a>

#### Azure 工作负载和托管标识

要使用 [Azure 工作负载标识](https://azure.github.io/azure-workload-identity/docs/)或[托管标识](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/)，请从配置中省略 `azure_storage_access_key`。当 `azure_storage_access_key` 为空时，极狐GitLab 会尝试：

1. 使用[工作负载标识](https://learn.microsoft.com/en-us/entra/workload-id/workload-identities-overview)获取临时凭据。环境中应存在 `AZURE_TENANT_ID`、`AZURE_CLIENT_ID` 和 `AZURE_FEDERATED_TOKEN_FILE`。
1. 如果工作负载标识不可用，则从 [Azure 实例元数据服务](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-to-use-vm-token)请求凭据。
1. 获取[用户委派密钥](https://learn.microsoft.com/en-us/rest/api/storageservices/get-user-delegation-key)。
1. 使用该密钥生成 SAS 令牌，以访问存储账号 blob。

请确保该标识已分配 `Storage Blob Data Contributor` 角色。

<a id="provider-specific-configuration-examples"></a>

### 特定于提供商的配置示例

以下示例展示了需要非默认设置的特定 S3 兼容提供商的配置。对于此处未列出的任何 S3 兼容提供商，请使用[基础 S3 兼容配置](#s3-compatible-providers)，并为您提供商的设置合适的 `endpoint`。

<a id="oracle-cloud-infrastructure"></a>

#### Oracle Cloud Infrastructure

Oracle Cloud Infrastructure S3 需要以下设置：

| 设置                         | 值 |
|:--------------------------------|:------|
| `enable_signature_v4_streaming` | `false` |
| `path_style`                    | `true` |

如果 `enable_signature_v4_streaming` 设置为 `true`，您可能会在 `production.log`中看到以下错误：

```plaintext
STREAMING-AWS4-HMAC-SHA256-PAYLOAD is not supported
```

<a id="storj-gateway-sj"></a>

#### Storj Gateway (SJ)

> [!note]
> Storj Gateway [不支持](https://github.com/storj/gateway-st/blob/4b74c3b92c63b5de7409378b0d1ebd029db9337d/docs/s3-compatibility.md)多线程复制（请参阅表中的 `UploadPartCopy`）。
> 虽然[已有实现计划](https://github.com/storj/roadmap/issues/40)，但在完成之前，您必须[禁用多线程复制](#multi-threaded-copying)。

[Storj Network](https://www.storj.io/) 提供 S3 兼容的 API 网关。请使用以下配置示例：

```ruby
gitlab_rails['object_store']['connection'] = {
  'provider' => 'AWS',
  'endpoint' => 'https://gateway.storjshare.io',
  'path_style' => true,
  'region' => 'eu1',
  'aws_access_key_id' => 'ACCESS_KEY',
  'aws_secret_access_key' => 'SECRET_KEY',
  'aws_signature_version' => 2,
  'enable_signature_v4_streaming' => false
}
```

签名版本必须为 `2`。使用 v4 会导致 HTTP 411 Length Required 错误。
更多信息，请参阅[议题 #4419](https://gitlab.com/gitlab-org/gitlab/-/issues/4419)。

<a id="hitachi-vantara-hcp"></a>

#### Hitachi Vantara HCP

> [!note]
> 连接到 HCP 时可能会返回错误，提示 `SignatureDoesNotMatch - The request signature we calculated does not match the signature you provided. Check your HCP Secret Access key and signing method.` 在这些情况下，请将 `endpoint` 设置为租户的 URL 而不是命名空间的 URL，并确保存储桶路径配置为 `<namespace_name>/<bucket_name>`。

[HCP](https://docs.hitachivantara.com/r/en-us/content-platform/9.7.x/mk-95hcph001/hcp-management-api-reference/introduction-to-the-hcp-management-api/support-for-the-amazon-s3-api) 提供 S3 兼容的 API。请使用以下配置示例：

```ruby
gitlab_rails['object_store']['connection'] = {
  'provider' => 'AWS',
  'endpoint' => 'https://<tenant_endpoint>',
  'path_style' => true,
  'region' => 'eu1',
  'aws_access_key_id' => 'ACCESS_KEY',
  'aws_secret_access_key' => 'SECRET_KEY',
  'aws_signature_version' => 4,
  'enable_signature_v4_streaming' => false
}

# Example of <namespace_name/bucket_name> formatting
gitlab_rails['object_store']['objects']['artifacts']['bucket'] = '<namespace_name>/<bucket_name>'
```

<a id="ceph-rgw"></a>

#### Ceph RGW

[Ceph RGW](https://docs.ceph.com/en/reef/cephadm/services/rgw/) 是 Ceph 的 S3 兼容 API。
请使用以下配置示例：

```ruby
gitlab_rails['object_store']['connection'] = {
  'provider' => 'AWS',
  'endpoint' => 'https://rgw-ceph.example.com',
  'region' => 'us-west-1',
  'aws_access_key_id' => 'ACCESS_KEY',
  'aws_secret_access_key' => 'SECRET_KEY',
  'path_style': true
}
```

要使用 Ceph RGW 启用[服务器端加密](#server-side-encryption-headers)，您必须使用 HTTPS 连接。Ceph 会拒绝通过非安全连接发出的加密请求。

<a id="full-example-using-the-consolidated-form-and-amazon-s3"></a>

## 使用整合形式和 Amazon S3 的完整示例

以下示例使用 AWS S3 为所有受支持的服务启用对象存储：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行，替换
   为您想要的值：

   ```ruby
   # Consolidated object storage configuration
   gitlab_rails['object_store']['enabled'] = true
   gitlab_rails['object_store']['proxy_download'] = false
   gitlab_rails['object_store']['connection'] = {
     'provider' => 'AWS',
     'region' => 'eu-central-1',
     'aws_access_key_id' => '<AWS_ACCESS_KEY_ID>',
     'aws_secret_access_key' => '<AWS_SECRET_ACCESS_KEY>'
   }
   # OPTIONAL: The following lines are only needed if server side encryption is required
   gitlab_rails['object_store']['storage_options'] = {
     'server_side_encryption' => '<AES256 or aws:kms>',
     'server_side_encryption_kms_key_id' => '<arn:aws:kms:xxx>'
   }
   gitlab_rails['object_store']['objects']['artifacts']['bucket'] = 'gitlab-artifacts'
   gitlab_rails['object_store']['objects']['external_diffs']['bucket'] = 'gitlab-mr-diffs'
   gitlab_rails['object_store']['objects']['lfs']['bucket'] = 'gitlab-lfs'
   gitlab_rails['object_store']['objects']['uploads']['bucket'] = 'gitlab-uploads'
   gitlab_rails['object_store']['objects']['packages']['bucket'] = 'gitlab-packages'
   gitlab_rails['object_store']['objects']['dependency_proxy']['bucket'] = 'gitlab-dependency-proxy'
   gitlab_rails['object_store']['objects']['terraform_state']['bucket'] = 'gitlab-terraform-state'
   gitlab_rails['object_store']['objects']['ci_secure_files']['bucket'] = 'gitlab-ci-secure-files'
   gitlab_rails['object_store']['objects']['pages']['bucket'] = 'gitlab-pages'
   ```

   如果您使用 [AWS IAM 配置文件](#use-amazon-instance-profiles)，请省略
   AWS 访问密钥和秘密访问密钥/值对。例如：

   ```ruby
   gitlab_rails['object_store']['connection'] = {
     'provider' => 'AWS',
     'region' => 'eu-central-1',
     'use_iam_profile' => true
   }
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

1. 将以下内容放入名为 `object_storage.yaml`的文件中，用作
   [Kubernetes 密钥](https://gitlab.cn/docs/charts/charts/globals/#connection)：

   ```yaml
   provider: AWS
   region: us-east-1
   aws_access_key_id: <AWS_ACCESS_KEY_ID>
   aws_secret_access_key: <AWS_SECRET_ACCESS_KEY>
   ```

   如果您使用 [AWS IAM 配置文件](#use-amazon-instance-profiles)，请省略
   AWS 访问密钥和秘密访问密钥/值对。例如：

   ```yaml
   provider: AWS
   region: us-east-1
   use_iam_profile: true
   ```

1. 创建 Kubernetes 密钥：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-object-storage --from-file=connection=object_storage.yaml
   ```

1. 导出 Helm values：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
        artifacts:
          bucket: gitlab-artifacts
        ciSecureFiles:
          bucket: gitlab-ci-secure-files
          enabled: true
        dependencyProxy:
          bucket: gitlab-dependency-proxy
          enabled: true
        externalDiffs:
          bucket: gitlab-mr-diffs
          enabled: true
        lfs:
          bucket: gitlab-lfs
        object_store:
          connection:
            secret: gitlab-object-storage
          enabled: true
          proxy_download: false
        packages:
          bucket: gitlab-packages
        terraformState:
          bucket: gitlab-terraform-state
          enabled: true
        uploads:
          bucket: gitlab-uploads
   ```

1. 保存文件并应用新的 values：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           # Consolidated object storage configuration
           gitlab_rails['object_store']['enabled'] = true
           gitlab_rails['object_store']['proxy_download'] = false
           gitlab_rails['object_store']['connection'] = {
             'provider' => 'AWS',
             'region' => 'eu-central-1',
             'aws_access_key_id' => '<AWS_ACCESS_KEY_ID>',
             'aws_secret_access_key' => '<AWS_SECRET_ACCESS_KEY>'
           }
           # OPTIONAL: The following lines are only needed if server side encryption is required
           gitlab_rails['object_store']['storage_options'] = {
             'server_side_encryption' => '<AES256 or aws:kms>',
             'server_side_encryption_kms_key_id' => '<arn:aws:kms:xxx>'
           }
           gitlab_rails['object_store']['objects']['artifacts']['bucket'] = 'gitlab-artifacts'
           gitlab_rails['object_store']['objects']['external_diffs']['bucket'] = 'gitlab-mr-diffs'
           gitlab_rails['object_store']['objects']['lfs']['bucket'] = 'gitlab-lfs'
           gitlab_rails['object_store']['objects']['uploads']['bucket'] = 'gitlab-uploads'
           gitlab_rails['object_store']['objects']['packages']['bucket'] = 'gitlab-packages'
           gitlab_rails['object_store']['objects']['dependency_proxy']['bucket'] = 'gitlab-dependency-proxy'
           gitlab_rails['object_store']['objects']['terraform_state']['bucket'] = 'gitlab-terraform-state'
           gitlab_rails['object_store']['objects']['ci_secure_files']['bucket'] = 'gitlab-ci-secure-files'
           gitlab_rails['object_store']['objects']['pages']['bucket'] = 'gitlab-pages'
   ```

   如果您使用 [AWS IAM 配置文件](#use-amazon-instance-profiles)，请省略
   AWS 访问密钥和秘密访问密钥/值对。例如：

   ```ruby
   gitlab_rails['object_store']['connection'] = {
     'provider' => 'AWS',
     'region' => 'eu-central-1',
     'use_iam_profile' => true
   }
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并添加或修改以下行：

   ```yaml
   production: &base
     object_store:
       enabled: true
       proxy_download: false
       connection:
         provider: AWS
         aws_access_key_id: <AWS_ACCESS_KEY_ID>
         aws_secret_access_key: <AWS_SECRET_ACCESS_KEY>
         region: eu-central-1
       storage_options:
         server_side_encryption: <AES256 or aws:kms>
         server_side_encryption_key_kms_id: <arn:aws:kms:xxx>
       objects:
         artifacts:
           bucket: gitlab-artifacts
         external_diffs:
           bucket: gitlab-mr-diffs
         lfs:
           bucket: gitlab-lfs
         uploads:
           bucket: gitlab-uploads
         packages:
           bucket: gitlab-packages
         dependency_proxy:
           bucket: gitlab-dependency-proxy
         terraform_state:
           bucket: gitlab-terraform-state
         ci_secure_files:
           bucket: gitlab-ci-secure-files
         pages:
           bucket: gitlab-pages
   ```

   如果您使用 [AWS IAM 配置文件](#use-amazon-instance-profiles)，请省略
   AWS 访问密钥和秘密访问密钥/值对。例如：

   ```yaml
   connection:
     provider: AWS
     region: eu-central-1
     use_iam_profile: true
   ```

1. 编辑 `/home/git/gitlab-workhorse/config.toml` 并添加或修改以下行：

   ```toml
   [object_storage]
     provider = "AWS"

   [object_storage.s3]
     aws_access_key_id = "<AWS_ACCESS_KEY_ID>"
     aws_secret_access_key = "<AWS_SECRET_ACCESS_KEY>"
   ```

   如果您使用 [AWS IAM 配置文件](#use-amazon-instance-profiles)，请省略
   AWS 访问密钥和秘密访问密钥/值对。例如：

   ```yaml
   [object_storage.s3]
     use_iam_profile = true
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # For systems running systemd
   sudo systemctl restart gitlab.target

   # For systems running SysV init
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="migrate-to-object-storage"></a>

## 迁移到对象存储

要将现有本地数据迁移到对象存储，请参阅以下指南：

- [作业产物](cicd/job_artifacts.md#migrating-to-object-storage)，包括归档的作业日志
- [LFS 对象](lfs/_index.md#migrating-to-object-storage)
- [上传](raketasks/uploads/migrate.md#migrate-to-object-storage)
- [合并请求差异](merge_request_diffs.md#using-object-storage)
- [软件包](packages/_index.md#migrate-packages-between-object-storage-and-local-storage)（可选功能）
- [依赖代理](packages/dependency_proxy.md#migrate-local-dependency-proxy-blobs-and-manifests-to-object-storage)
- [Terraform 状态文件](terraform_state.md#migrate-to-object-storage)
- [Pages 内容](pages/_index.md#migrate-pages-deployments-to-object-storage)
- [项目级安全文件](cicd/secure_files.md#migrate-to-object-storage)

<a id="transition-to-consolidated-form"></a>

## 过渡到整合形式

在特定于存储的配置中：

- 所有类型对象（例如 CI/CD 产物、LFS
  文件和上传附件）的对象存储配置都是独立配置的。
- 密码和端点 URL 等对象存储连接参数会为每种类型重复。

例如，Linux 软件包安装可能有以下配置：

```ruby
# Original object storage configuration
gitlab_rails['artifacts_object_store_enabled'] = true
gitlab_rails['artifacts_object_store_direct_upload'] = true
gitlab_rails['artifacts_object_store_proxy_download'] = false
gitlab_rails['artifacts_object_store_remote_directory'] = 'artifacts'
gitlab_rails['artifacts_object_store_connection'] = { 'provider' => 'AWS', 'aws_access_key_id' => 'access_key', 'aws_secret_access_key' => 'secret' }
gitlab_rails['uploads_object_store_enabled'] = true
gitlab_rails['uploads_object_store_direct_upload'] = true
gitlab_rails['uploads_object_store_proxy_download'] = false
gitlab_rails['uploads_object_store_remote_directory'] = 'uploads'
gitlab_rails['uploads_object_store_connection'] = { 'provider' => 'AWS', 'aws_access_key_id' => 'access_key', 'aws_secret_access_key' => 'secret' }
```

尽管这提供了灵活性，使极狐GitLab 可以将对象存储在不同的云提供商中，但它也带来了额外的复杂性和不必要的冗余。由于 GitLab Rails 和 Workhorse 组件都需要访问对象存储，整合形式避免了凭据的过度重复。

仅当省略原始形式中的所有行时，才会使用整合形式。要迁移到整合形式，请移除原始配置（例如 `artifacts_object_store_enabled` 或
`uploads_object_store_connection`）

<a id="migrate-objects-to-a-different-object-storage-provider"></a>

## 将对象迁移到其他对象存储提供商

您可能需要将对象存储中的极狐GitLab 数据迁移到其他对象存储提供商。以下步骤展示如何使用 [Rclone](https://rclone.org/) 完成此操作。

这些步骤假设您要移动 `uploads` 存储桶，但相同流程也适用于其他存储桶。

先决条件：

- 选择运行 Rclone 的计算机。根据您要迁移的数据量，Rclone 可能需要运行很长时间，因此应避免使用可能进入省电模式的笔记本电脑或台式机。您可以使用极狐GitLab 服务器来运行 Rclone。

1. [安装](https://rclone.org/downloads/) Rclone。
1. 通过运行以下命令配置 Rclone：

   ```shell
   rclone config
   ```

   配置过程是交互式的。至少添加两个“remote”：一个用于您数据当前所在的
   对象存储提供商（`old`），另一个用于您要迁移到的提供商（`new`）。

1. 验证您可以读取旧数据。以下示例引用 `uploads` 存储桶，但您的存储桶可能有不同的名称：

   ```shell
   rclone ls old:uploads | head
   ```

   这应会打印当前存储在 `uploads` 存储桶中的对象的部分列表。如果您遇到错误，或者
   列表为空，请返回并使用 `rclone config` 更新您的 Rclone 配置。

1. 执行初始复制。此步骤不需要将极狐GitLab 服务器下线。

   ```shell
   rclone sync -P old:uploads new:uploads
   ```

1. 第一次同步完成后，使用新对象存储提供商的 Web UI 或命令行界面
   验证新存储桶中是否有对象。如果没有，或者您在运行
   `rclone sync` 时遇到错误，请检查您的 Rclone 配置并重试。

在您至少成功完成一次从旧位置到新位置的 Rclone 复制后，安排维护并将极狐GitLab 服务器下线。在维护窗口期间，您必须做两件事：

1. 执行最后一次 `rclone sync` 运行，此时您的用户无法添加新对象，因此不会在旧存储桶中留下任何对象。
1. 更新极狐GitLab 服务器的对象存储配置，使 `uploads` 使用新提供商。

<a id="alternatives-to-file-system-storage"></a>

## 文件系统存储的替代方案

如果您正在努力[横向扩展](reference_architectures/_index.md)您的极狐GitLab 部署，或增加容错和冗余，您可能希望消除对块文件系统或网络文件系统的依赖。请参阅以下附加指南：

1. 确保 [`git` 用户主目录](https://gitlab.cn/docs/omnibus/settings/configuration/#move-the-home-directory-for-a-user)位于本地磁盘上。
1. 配置 [SSH 密钥的数据库查找](operations/fast_ssh_key_lookup.md)
   以消除对共享 `authorized_keys` 文件的需求。
1. [防止作业日志使用本地磁盘](cicd/job_logs.md#prevent-local-disk-usage)。
1. [禁用 Pages 本地存储](pages/_index.md#disable-pages-local-storage)。

<a id="troubleshooting"></a>

## 故障排除

<a id="objects-are-not-included-in-gitlab-backups"></a>

### 对象未包含在极狐GitLab 备份中

如[备份文档](backup_restore/backup_gitlab.md#object-storage)所述，对象未包含在极狐GitLab 备份中。您可以改为使用对象存储提供商启用备份。

<a id="use-separate-buckets"></a>

### 使用单独的存储桶

为每种数据类型使用单独的存储桶是极狐GitLab 推荐的做法。这可确保极狐GitLab 存储的各种数据类型之间不会发生冲突。[议题 292958](https://gitlab.com/gitlab-org/gitlab/-/issues/292958) 提议支持使用单个存储桶。

使用 Linux 软件包和自行编译安装时，可以将单个真实存储桶拆分为多个虚拟存储桶。如果您的对象存储存储桶名为 `my-gitlab-objects`，您可以将上传配置为存入 `my-gitlab-objects/uploads`，将产物存入 `my-gitlab-objects/artifacts`，等等。应用程序会将这些视为单独的存储桶。使用存储桶前缀[可能无法与 Helm 备份正确配合](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/3376)。

基于 Helm 的安装需要单独的存储桶来[处理备份恢复](https://gitlab.cn/docs/charts/advanced/external-object-storage/#lfs-artifacts-uploads-packages-external-diffs-terraform-state-dependency-proxy-secure-files)。

<a id="s3-api-compatibility-issues"></a>

### S3 API 兼容性问题

如果您在使用 S3 兼容提供商时遇到错误，请参阅 [S3 兼容性和已知故障模式](#s3-compatibility-and-known-failure-modes)了解常见原因和配置调整。`production.log`中出现 `411 Length Required` 错误通常是由签名流式传输引起的。设置 `enable_signature_v4_streaming: false` 即可解决。

<a id="artifacts-always-downloaded-with-filename-download"></a>

### 产物始终以文件名 `download` 下载

下载的产物文件名通过
[GetObject 请求](https://docs.aws.amazon.com/AmazonS3/latest/API/API_GetObject.html)中的 `response-content-disposition` 标头设置。
如果 S3 提供商不支持此标头，下载的文件将始终保存为 `download`。

<a id="proxy-download"></a>

### 代理下载

客户端可以通过接收预签名、有时间限制的 URL 来下载对象存储中的文件，或者由极狐GitLab 将数据从对象存储代理到客户端。直接从对象存储下载文件有助于减少极狐GitLab 需要处理的出口流量。

当文件存储在本地块存储或 NFS 上时，极狐GitLab 必须充当代理。这不是对象存储的默认行为。

`proxy_download` 设置控制此行为：默认值为 `false`。请在每个用例的文档中确认这一点。

如果您希望极狐GitLab 代理这些文件，请将 `proxy_download` 设置为 `true`。如果将 `proxy_download` 设置为 `true`，极狐GitLab 服务器的性能可能会受到很大影响。极狐GitLab 的服务器部署将 `proxy_download` 设置为 `false`。

<a id="allow-client-override-for-proxy-download"></a>

#### 允许客户端覆盖代理下载

默认情况下，所有下载都使用由 `proxy_download` 设置的传输模式，API 客户端无法覆盖它。要允许 API 客户端在支持的端点上选择不同的传输模式，请将 `allowed_download_modes` 设置为一个同时包含 `proxy` 和 `direct`的列表。例如：

```yaml
object_store:
  proxy_download: true
  allowed_download_modes: [proxy, direct]
```

当 `direct` 位于 `allowed_download_modes`中时，客户端可以在支持的端点上传递 `download_mode=direct` 作为查询参数，以接收指向对象存储的 HTTP 302 重定向，而不是让请求通过极狐GitLab 代理。如果端点不支持直接下载，或者客户端未发送该参数，极狐GitLab 将使用由 `proxy_download` 设置的模式。

`allowed_download_modes` 必须是一个仅包含 `proxy`、`direct` 或两者都有的数组。如果该值为纯字符串（例如 `allowed_download_modes: proxy` 而不是 `allowed_download_modes: [proxy]`）或包含任何其他值，极狐GitLab 将无法启动。

当 `proxy_download` 为 `false` 时，极狐GitLab 会返回[带有预签名、有时间限制的对象存储 URL 的 HTTP 302 重定向](https://gitlab.com/gitlab-org/gitlab/-/issues/32117#note_218532298)。这可能会导致以下一些问题：

- 如果极狐GitLab 使用非安全 HTTP 访问对象存储，客户端可能会生成
  `https->http` 降级错误并拒绝处理该重定向。解决此问题的方法是
  让极狐GitLab 使用 HTTPS。例如，LFS 会生成以下错误：

  ```plaintext
  LFS: lfsapi/client: refusing insecure redirect, https->http
  ```

- 客户端需要信任签发对象存储
  证书的证书颁发机构，否则可能会返回常见的 TLS 错误，例如：

  ```plaintext
  x509: certificate signed by unknown authority
  ```

- 客户端需要能够通过网络访问对象存储。
  网络防火墙可能会阻止访问。
  如果未建立此访问权限，
  可能会产生以下错误：

  ```plaintext
  Received status code 403 from server: Forbidden
  ```

- 对象存储存储桶需要允许来自极狐GitLab 实例 URL 的跨域资源共享
  (CORS) 访问。尝试在代码仓库页面中加载
  PDF 时可能会显示以下错误：

  ```plaintext
  An error occurred while loading the file. Please try again later.
  ```

  有关更多详细信息，请参阅 [LFS 文档](lfs/_index.md#error-viewing-a-pdf-file)。

> [!warning]
> 预签名 URL 有时间限制，但不与特定用户绑定。任何获得
> 预签名 URL 的用户都可以在 URL 有效期内
> 无需认证即可访问该对象。直接下载还可能会产生对象存储
> 提供商与客户端之间的带宽费用。

<a id="etag-mismatch"></a>

### ETag 不匹配

使用极狐GitLab 默认设置时，某些 S3 兼容对象存储后端（例如
[Alibaba](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/1564)）
可能会生成 `ETag mismatch` 错误。

<a id="amazon-s3-encryption"></a>

#### Amazon S3 加密

如果您在使用 Amazon Web Services S3 时看到此 ETag 不匹配错误，
很可能是由于[存储桶上的加密设置](https://docs.aws.amazon.com/AmazonS3/latest/developerguide/RESTCommonResponseHeaders.html)。要解决此问题，您有两种选择：

- [使用整合形式](#configure-a-single-storage-connection-for-all-object-types-consolidated-form)。
- [使用 Amazon 实例配置文件](#use-amazon-instance-profiles)。

对于 S3 兼容服务，建议使用整合形式。某些服务可能还需要额外的服务器端配置（例如启用兼容模式）才能解决 ETag 不匹配错误。

如果未启用整合形式或实例配置文件，
GitLab Workhorse 会使用预签名 URL 将文件上传到 S3，而这些 URL
没有为其计算 `Content-MD5` HTTP 标头。为确保数据不被损坏，Workhorse 会检查所发送数据的 MD5 哈希是否等于 S3 服务器返回的 ETag 标头。当启用加密时，情况并非如此，这会导致 Workhorse 在上传期间报告 `ETag mismatch` 错误。

当整合形式：

- 与 S3 兼容对象存储或实例配置文件一起使用时，Workhorse
  会使用其内部 S3 客户端，该客户端具有 S3 凭证，因此可以计算
  `Content-MD5` 标头。这样就不再需要比较 S3 服务器
  返回的 ETag 标头。
- 未与 S3 兼容对象存储一起使用时，Workhorse 会回退为使用
  预签名 URL。

<a id="google-cloud-storage-encryption"></a>

#### Google Cloud Storage 加密

在启用[使用客户管理的加密密钥 (CMEK) 进行数据加密](https://docs.cloud.google.com/storage/docs/encryption/using-customer-managed-keys)时，Google Cloud Storage (GCS) 中也会出现 ETag 不匹配错误。

要使用 CMEK，请使用[整合形式](#configure-a-single-storage-connection-for-all-object-types-consolidated-form)。

<a id="multi-threaded-copying"></a>

### 多线程复制

极狐GitLab 使用 [S3 Upload Part Copy API](https://docs.aws.amazon.com/AmazonS3/latest/API/API_UploadPartCopy.html)
来加速存储桶内的文件复制。某些 S3 兼容提供商不支持此功能，它们会[在上传期间返回 404 错误](https://gitlab.com/gitlab-org/gitlab/-/issues/300604)。

要禁用多线程复制，请让具有 [Rails 控制台访问权限](feature_flags/_index.md#how-to-enable-and-disable-features-behind-flags)的极狐GitLab 管理员运行以下命令：

```ruby
Feature.disable(:s3_multithreaded_uploads)
```

<a id="manual-testing-through-rails-console"></a>

### 通过 Rails 控制台进行手动测试

当您怀疑存在配置错误时，可以使用此方法验证对象存储连接。以下示例测试连接、写入测试对象，然后将其读回。

1. 启动 [Rails 控制台](operations/rails_console.md)。
1. 使用您在 `/etc/gitlab/gitlab.rb`中设置的相同参数，按照以下示例格式
   设置对象存储连接：

   使用现有上传配置的示例连接：

   ```ruby
   settings = Gitlab.config.uploads.object_store.connection.deep_symbolize_keys
   connection = Fog::Storage.new(settings)
   ```

   使用访问密钥的示例连接：

   ```ruby
   connection = Fog::Storage.new(
     {
       provider: 'AWS',
       region: 'eu-central-1',
       aws_access_key_id: '<AWS_ACCESS_KEY_ID>',
       aws_secret_access_key: '<AWS_SECRET_ACCESS_KEY>'
     }
   )
   ```

   使用 AWS IAM 配置文件的示例连接：

   ```ruby
   connection = Fog::Storage.new(
     {
       provider: 'AWS',
       use_iam_profile: true,
       region: 'us-east-1'
     }
   )
   ```

1. 指定要测试的存储桶名称，写入并最终读取一个测试文件。

   ```ruby
   dir = connection.directories.new(key: '<bucket-name-here>')
   f = dir.files.create(key: 'test.txt', body: 'test')
   pp f
   pp dir.files.head('test.txt')
   ```

<a id="enable-additional-debugging"></a>

#### 启用额外调试

您还可以启用额外调试以查看 HTTP 请求。您应在 [Rails 控制台](operations/rails_console.md)中执行此操作，以避免在日志文件中泄露凭证。以下展示了如何为不同提供商启用请求调试：

{{< tabs >}}

{{< tab title="Amazon S3" >}}

设置 `EXCON_DEBUG` 环境变量：

```ruby
ENV['EXCON_DEBUG'] = "1"
```

您还可以通过将 `AWS_DEBUG` 环境变量设置为 `1`，在 GitLab Workhorse 日志中启用 S3 HTTP 请求和响应标头日志记录。对于
Linux 软件包 (Omnibus)：

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_workhorse['env'] = {
     'AWS_DEBUG' => '1'
   }
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

   S3 兼容存储的请求和响应标头记录在
   `/var/log/gitlab/gitlab-workhorse/current`中。

{{< /tab >}}

{{< tab title="Google Cloud Storage" >}}

将记录器配置为记录到 `STDOUT`：

```ruby
Google::Apis.logger = Logger::new(STDOUT)
```

{{< /tab >}}

{{< tab title="Azure Blob Storage" >}}

设置 `DEBUG` 环境变量：

```ruby
ENV['DEBUG'] = "1"
```

{{< /tab >}}

{{< /tabs >}}

<a id="reset-the-geo-tracking-database-to-ensure-full-objects-consistency"></a>

### 重置 Geo 跟踪数据库以确保对象完全一致

假设存在以下 Geo 场景：

- 环境由 Geo 主站点和从站点组成。
- 您在主站点上[迁移到了对象存储](#migrate-to-object-storage)。
  - 从站点使用单独的对象存储存储桶。
  - **允许此从站点在对象存储上复制内容**已激活。

此类迁移可能导致对象在跟踪数据库中被标记为已同步，但实际上从对象存储中缺失。在这种情况下，请[重置 Geo 从站点复制](geo/replication/troubleshooting/synchronization_verification.md#resetting-geo-secondary-site-replication)以确保对象状态在迁移后保持一致。

<a id="inconsistencies-after-migrating-to-object-storage"></a>

### 迁移到对象存储后出现不一致

从本地存储迁移到对象存储时可能会出现数据不一致。尤其是在与 [Geo](geo/replication/object_storage.md) 结合使用时，如果文件在迁移前被手动删除。

例如，实例管理员在本地文件系统上手动删除了若干产物。此类更改未正确传播到数据库，从而导致不一致。迁移到对象存储后，这些不一致仍然存在，并可能造成问题。Geo 从站点可能会继续尝试复制这些文件，因为它们仍在数据库中被引用，但已不再存在。

<a id="identify-inconsistencies-when-using-geo"></a>

#### 使用 Geo 时识别不一致

假设存在以下 Geo 场景：

- 环境由一个 Geo 主节点和一个从节点组成
- 两个系统都已迁移到对象存储
  - 从站点使用与主站点相同的对象存储
  - 选项 `Allow this secondary site to replicate content on Object Storage` 已停用
- 在对象存储迁移之前手动删除了多个上传
  - 在此示例中，为上传到某个议题的两张图片

在这种情况下，从站点不再需要复制任何数据，因为它使用与主站点相同的对象存储。由于不一致，管理员可能会观察到从站点仍在尝试复制数据：

在主站点上：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 查看**主站点**并检查验证信息。所有上传均已验证：
   ![Geo 站点仪表板显示主站点验证成功。](img/geo_primary_uploads_verification_v17_11.png)
1. 查看**从站点**并检查验证信息。请注意，仍有两个上传正在同步，尽管从站点应使用相同的对象存储。这意味着它不应需要同步任何上传：
   ![Geo 站点仪表板显示从站点的不一致。](img/geo_secondary_uploads_inconsistencies_v17_11.png)

<a id="clean-up-inconsistencies"></a>

#### 清理不一致

> [!warning]
> 在执行任何删除命令之前，请确保手头有最近且可用的备份。

基于前面的场景，多个上传导致了不一致，下面以此为例。

请按以下步骤正确删除潜在的残留项：

1. 将识别出的不一致映射到各自的模型名称。以下步骤中需要用到模型名称。

   | 对象存储类型      | 模型名称                                              |
   |--------------------------|---------------------------------------------------------|
   | 备份                  | 不适用                                          |
   | 容器镜像仓库       | 不适用                                          |
   | Mattermost               | 不适用                                          |
   | 自动扩缩 runner 缓存 | 不适用                                          |
   | 安全文件             | `Ci::SecureFile`                                        |
   | 作业产物            | `Ci::JobArtifact` 和 `Ci::PipelineArtifact`            |
   | LFS 对象              | `LfsObject`                                             |
   | 上传                  | `Upload`                                                |
   | 合并请求差异      | `MergeRequestDiff`                                      |
   | 软件包                 | `Packages::PackageFile`                                 |
   | 依赖代理         | `DependencyProxy::Blob` 和 `DependencyProxy::Manifest` |
   | Terraform 状态文件    | `Terraform::StateVersion`                               |
   | Pages 内容            | `PagesDeployment`                                       |

1. 启动 [Rails 控制台](operations/rails_console.md)。
1. 根据上一步的模型名称，查询所有仍存储在本地（而非对象存储中）的“文件”。在此情况下，由于受影响的是上传，因此使用模型名称 `Upload`。请注意 `openbao.png` 仍存储在本地：

   ```ruby
   Upload.with_files_stored_locally
   ```

   ```ruby
   #<Upload:0x00007d35b69def68
     id: 108,
     size: 13346,
     path: "c95c1c9bf91a34f7d97346fd3fa6a7be/openbao.png",
     checksum: "db29d233de49b25d2085dcd8610bac787070e721baa8dcedba528a292b6e816b",
     model_id: 2,
     model_type: "Project",
     uploader: "FileUploader",
     created_at: Wed, 02 Apr 2025 05:56:47.941319000 UTC +00:00,
     store: 1,
     mount_point: nil,
     secret: "[FILTERED]",
     version: 2,
     uploaded_by_user_id: 1,
     organization_id: nil,
     namespace_id: nil,
     project_id: 2,
     verification_checksum: nil>]
   ```

1. 使用所识别资源的 `id` 正确删除它们。首先，使用 `find` 验证它是正确的资源，然后运行 `destroy`：

   ```ruby
   Upload.find(108)
   Upload.find(108).destroy
   ```

1. 可选地，通过再次运行 `find` 来验证资源已正确删除，此时应不再能找到它：

   ```ruby
   Upload.find(108)
   ```

   ```ruby
   ActiveRecord::RecordNotFound: Couldn't find Upload with 'id'=108
   ```

对所有受影响的对象存储类型重复这些步骤。

<a id="job-logs-are-missing-in-a-multi-node-gitlab-instance"></a>

### 多节点极狐GitLab 实例中缺少作业日志

在具有多个 Rails 节点（运行 Web 服务或 Sidekiq 的服务器）的极狐GitLab 实例上，需要有一种机制，使作业日志在从 Runner 发送后可供所有节点使用。作业日志可以存储在本地磁盘或对象存储中。

如果未使用 NFS，并且未启用[增量日志记录功能](cicd/job_logs.md#incremental-logging)，则作业日志可能会丢失：

1. 从 runner 接收日志的节点将日志写入本地磁盘。
1. 当极狐GitLab 尝试归档日志时，作业通常运行在无法访问该日志的其他服务器上。
1. 上传到对象存储失败。

以下错误也可能会记录到 `/var/log/gitlab/gitlab-rails/exceptions_json.log`：

```yaml
{
  "severity": "ERROR",
  "exception.class": "Ci::AppendBuildTraceService::TraceRangeError",
  "extra.build_id": 425187,
  "extra.body_end": 12955,
  "extra.stream_size": 720,
  "extra.stream_class": {},
  "extra.stream_range": "0-12954"
}
```

如果在多节点环境中将 CI 产物写入对象存储，则必须[启用增量日志记录功能](cicd/job_logs.md#configure-incremental-logging)。
