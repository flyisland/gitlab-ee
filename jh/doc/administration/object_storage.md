---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: 对象存储
description: 配置用于存储数据的对象存储服务。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 支持使用对象存储服务存储多种类型的数据。推荐优先于 NFS，并且在大多数大型部署中，对象存储通常更高效、更可靠且更具可扩展性。

要配置对象存储，您有两种选择：

- 推荐。[为所有对象类型配置一个统一的存储连接](#为所有对象类型配置一个统一的存储连接合并表单)：所有支持的对象类型共享同一个凭据。这称为合并表单。
- [为每种对象类型分别定义其自己的存储连接](#为每种对象类型分别定义其自己的存储连接存储特定表单)：每种对象类型定义自己的对象存储连接和配置。这称为存储特定表单。

  如果您已经在使用存储特定表单，请参阅如何[过渡到合并表单](#过渡到合并表单)。

如果您的数据存储在本地，请参阅如何[迁移至对象存储](#迁移至对象存储)。

<a id="object-storage-provider-support"></a>

## 对象存储提供商支持

极狐GitLab 使用 [Fog 库](https://fog.github.io/about/supported_services.html)进行对象存储，并支持以下三种连接类型。不支持其他 Fog 提供商。

| 连接类型 | `provider` 值     | 使用场景                   |
|:---------------------|:-----------------|:---------------------------|
| S3 兼容              | `AWS`            | Amazon S3 及任何与 S3 兼容的服务 |
| Google Cloud Storage | `Google`         | Google Cloud Storage       |
| Azure Blob Storage   | `AzureRM`        | Azure Blob Storage         |

如果您的对象存储服务与其中一种连接类型兼容，请使用下方相应的连接设置进行配置。提供商的选择由您决定。

<a id="providers-with-active-test-coverage"></a>

### 有活跃测试覆盖的提供商

极狐GitLab 积极测试以下提供商：

- [Amazon S3](https://aws.amazon.com/s3/)——`AWS` 连接类型。不支持 [Object Lock](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html)。更多信息，请参阅 [议题 335775](https://jihulab.com/gitlab-cn/gitlab/-/issues/335775)。
- [Google Cloud Storage](https://cloud.google.com/storage)——`Google` 连接类型。
- [Azure Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction)——`AzureRM` 连接类型。

<a id="community-documented-providers"></a>

### 社区记录的提供商

以下提供商由社区用户记录。极狐GitLab 未对它们进行测试。提供的配置示例仅为方便起见。如果您使用这些提供商并遇到问题，极狐GitLab 支持可能无法提供帮助。

- [Digital Ocean Spaces](https://www.digitalocean.com/products/spaces)。与 S3 兼容，请参阅[提供商特定的配置示例](#提供商特定的配置示例)。
- [Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/s3compatibleapi.htm)。与 S3 兼容，请参阅[提供商特定的配置示例](#提供商特定的配置示例)。
- [OpenStack Swift](https://docs.openstack.org/swift/latest/s3_compat.html)（S3 兼容模式）。
- [Storj Gateway](https://www.storj.io/)。与 S3 兼容，请参阅[提供商特定的配置示例](#提供商特定的配置示例)。
- [Ceph RGW](https://docs.ceph.com/en/reef/cephadm/services/rgw/)。与 S3 兼容，请参阅[提供商特定的配置示例](#提供商特定的配置示例)
- [Hitachi Vantara HCP](https://docs.hitachivantara.com/r/en-us/content-platform/9.7.x/mk-95hcph001/hcp-management-api-reference/introduction-to-the-hcp-management-api/support-for-the-amazon-s3-api)。与 S3 兼容，请参阅[提供商特定的配置示例](#提供商特定的配置示例)。
- 暴露兼容 S3 API 的本地硬件和设备。

<a id="为所有对象类型配置一个统一的存储连接合并表单"></a>

## 为所有对象类型配置一个统一的存储连接（合并表单）

大多数对象类型，如 CI 产物、LFS 文件和上传附件，都可以通过为对象存储指定一个统一的凭据并配置多个存储桶来存储。

> [!note]
> 对于极狐GitLab Helm Charts，请参阅如何[配置合并表单](https://gitlab.cn/docs/charts/charts/globals/#consolidated-object-storage)。

使用合并表单配置对象存储有许多优点：

- 它可以简化您的极狐GitLab 配置，因为连接详情在所有对象类型间共享。
- 它支持使用 [加密 S3 存储桶](#加密-s3-存储桶)。
- 它[上传文件到 S3 时附带正确的 `Content-MD5` 标头](https://gitlab.com/gitlab-org/gitlab-workhorse/-/issues/222)。

使用合并表单时，直接上传会自动启用。因此，只能使用以下提供商：

- [兼容 S3 的提供商](#兼容-s3-的提供商)
- [Google Cloud Storage (GCS)](#google-cloud-storage-gcs)
- [Azure Blob Storage](#azure-blob-storage)

合并表单配置不能用于备份或 Mattermost。备份可以单独配置[服务器端加密](backup_restore/backup_gitlab.md#s3-encrypted-buckets)。请参阅[完整支持列表的表格](#为每种对象类型分别定义其自己的存储连接存储特定表单)以了解支持的对象存储类型。

启用合并表单会为所有对象类型启用对象存储。如果并非所有存储桶都已指定，您可能会看到类似以下的错误：

```plaintext
对象存储类型为 <object type> 的必须指定存储桶
```

如果您想对特定对象类型使用本地存储，可以[为特定功能禁用对象存储](#为特定功能禁用对象存储)。

<a id="configure-the-common-parameters"></a>

### 配置通用参数

在合并表单中，`object_store` 部分定义了一组通用参数。

| 设置               | 描述                                                         |
|-------------------|--------------------------------------------------------------|
| `enabled`         | 启用或禁用对象存储。                                           |
| `proxy_download`  | 设为 `true` 以[启用所有已提供文件的代理服务](#代理下载)。可减少出站流量，因为这允许客户端直接从远程存储下载，而不是代理所有数据。 |
| `connection`      | 下述的[各种连接选项](#configure-the-connection-settings)。 |
| `storage_options` | 保存新对象时使用的选项，例如[服务器端加密](#server-side-encryption-headers)。 |
| `objects`         | [对象类型的特定配置](#configure-the-parameters-of-each-object)。 |

有关示例，请参阅[使用合并表单和 Amazon S3 的完整示例](#使用合并表单和-amazon-s3-的完整示例)。

<a id="configure-the-parameters-of-each-object"></a>

### 配置每种对象类型的参数

每种对象类型必须至少定义其存储的存储桶名称。

下表列出了可以使用的有效 `objects`：

| 类型               | 描述                                     |
|--------------------|--------------------------------------------|
| `artifacts`        | [CI/CD 作业产物](cicd/job_artifacts.md)     |
| `external_diffs`   | [合并请求差异](merge_request_diffs.md)      |
| `uploads`          | [用户上传](uploads.md)                     |
| `lfs`              | [Git 大文件存储对象](lfs/_index.md)         |
| `packages`         | [项目软件包（例如 PyPI、Maven 或 NuGet）](packages/_index.md) |
| `dependency_proxy` | [依赖代理](packages/dependency_proxy.md)   |
| `terraform_state`  | [Terraform 状态文件](terraform_state.md)    |
| `pages`            | [Pages](pages/_index.md)                   |
| `ci_secure_files`  | [安全文件](cicd/secure_files.md)           |

每种对象类型下，可以定义三个参数：

| 设置              | 是否必需？                              | 描述                                       |
|------------------|---------------------------------------|----------------------------------------------|
| `bucket`         | {{< icon name="check-circle" >}} 是\* | 对象类型的存储桶名称。如果 `enabled` 设为 `false` 则不需要。 |
| `enabled`        | {{< icon name="dotted-circle" >}} 否  | 覆盖[通用参数](#configure-the-common-parameters)。     |
| `proxy_download` | {{< icon name="dotted-circle" >}} 否  | 覆盖[通用参数](#configure-the-common-parameters)。     |

有关示例，请参阅[使用合并表单和 Amazon S3 的完整示例](#使用合并表单和-amazon-s3-的完整示例)。

<a id="disable-object-storage-for-specific-features"></a>

#### 为特定功能禁用对象存储

如前所述，可以通过将 `enabled` 标志设置为 `false` 来为特定类型禁用对象存储。例如，为 CI 产物禁用对象存储：

```ruby
gitlab_rails['object_store']['objects']['artifacts']['enabled'] = false
```

如果该功能被完全禁用，则不需要存储桶。例如，若使用以下设置禁用 CI 产物，则无需存储桶：

```ruby
gitlab_rails['artifacts_enabled'] = false
```

<a id="为每种对象类型分别定义其自己的存储连接存储特定表单"></a>

## 为每种对象类型分别定义其自己的存储连接（存储特定表单）

使用存储特定表单时，每种对象类型都定义自己的对象存储连接和配置。您应该[改用合并表单](#过渡到合并表单)，除非某些存储类型不受合并表单支持。当使用极狐GitLab Helm Charts 时，请参考 Charts 如何处理[对象存储的合并表单](https://gitlab.cn/docs/charts/charts/globals/#consolidated-object-storage)。

不支持在非合并表单中使用[加密 S3 存储桶](#加密-s3-存储桶)。如果使用，可能会遇到 [ETag 不匹配错误](#etag-不匹配)。

> [!note]
> 对于存储特定表单，
> [直接上传可能成为默认方式](https://gitlab.com/gitlab-org/gitlab/-/issues/27331)
> 因为它不需要共享文件夹。

对于合并表单不支持存储类型的，请参考以下指南：

| 对象存储类型                                                    | 是否受合并表单支持？                          |
|---------------------------------------------------------------|-------------------------------------------|
| [备份](backup_restore/backup_gitlab.md#upload-backups-to-a-remote-cloud-storage) | {{< icon name="dotted-circle" >}} 否       |
| [容器镜像仓库](packages/container_registry.md#use-object-storage)（可选功能）   | {{< icon name="dotted-circle" >}} 否       |
| [Mattermost](https://docs.mattermost.com/configure/file-storage-configuration-settings.html) | {{< icon name="dotted-circle" >}} 否       |
| [自动缩放 Runner 缓存](https://docs.gitlab.com/runner/configuration/autoscale/#distributed-runners-caching)（可选，用于提升性能） | {{< icon name="dotted-circle" >}} 否       |
| [安全文件](cicd/secure_files.md#using-object-storage)                     | {{< icon name="check-circle" >}} 是       |
| [作业产物](cicd/job_artifacts.md#using-object-storage)（包括归档的作业日志）  | {{< icon name="check-circle" >}} 是       |
| [LFS 对象](lfs/_index.md#storing-lfs-objects-in-remote-object-storage)      | {{< icon name="check-circle" >}} 是       |
| [上传](uploads.md#using-object-storage)                                   | {{< icon name="check-circle" >}} 是       |
| [合并请求差异](merge_request_diffs.md#using-object-storage)                   | {{< icon name="check-circle" >}} 是       |
| [软件包](packages/_index.md#migrate-packages-between-object-storage-and-local-storage)（可选功能） | {{< icon name="check-circle" >}} 是       |
| [依赖代理](packages/dependency_proxy.md#using-object-storage)（可选功能）      | {{< icon name="check-circle" >}} 是       |
| [Terraform 状态文件](terraform_state.md#using-object-storage)               | {{< icon name="check-circle" >}} 是       |
| [Pages 内容](pages/_index.md#object-storage-settings)                       | {{< icon name="check-circle" >}} 是       |

<a id="configure-the-connection-settings"></a>

## 配置连接设置

合并表单和存储特定表单都必须配置连接。以下部分描述了可以在 `connection` 设置中使用的参数。

<a id="s3-compatible-providers"></a>

### 兼容 S3 的提供商

以下设置适用于使用 `AWS` 连接类型的 Amazon S3 和任何兼容 S3 的服务。当不直接使用 AWS 时，将 `endpoint` 设置为您提供商的 URL。

兼容 S3 的服务在实现 AWS S3 API 方面存在差异。极狐GitLab 会使用特定的 S3 行为，包括预签名 URL、多部分上传以及可选的分块签名流式传输，并非所有兼容 S3 的实现都能相同地支持这些行为。如果某个提供商在其他工具中可以工作但在极狐GitLab 中不行，最可能需要调整的设置是：

- `aws_signature_version`。
- `enable_signature_v4_streaming`。

连接设置与 [fog-aws](https://github.com/fog/fog-aws) 提供的匹配：

| 设置                                        | 描述                                                                                                     | 默认值             |
|---------------------------------------------|----------------------------------------------------------------------------------------------------------------|------------------|
| `provider`                                  | 对于兼容的主机始终为 `AWS`。                                                                              | `AWS`            |
| `aws_access_key_id`                         | AWS 凭据，或兼容的。                                                                                      |                  |
| `aws_secret_access_key`                     | AWS 凭据，或兼容的。                                                                                      |                  |
| `aws_signature_version`                     | 要使用的 AWS 签名版本。`2` 或 `4` 均为有效选项。某些兼容 S3 的提供商可能需要 `2`。                          | `4`              |
| `enable_signature_v4_streaming`             | 设置为 `true` 以启用使用 [AWS V4 签名](https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-streaming.html)的 HTTP 分块传输。某些兼容 S3 的提供商需要将其设为 `false`。极狐GitLab 17.4 将默认值从 `true` 改为 `false`。 | `false` |
| `region`                                    | AWS 区域。                                                                                                |                  |
| `host`                                      | 已弃用：请改用 `endpoint`。当不使用 AWS 时，用于兼容 S3 的主机。例如，`localhost` 或 `storage.example.com`。默认使用 HTTPS 和 443 端口。 | `s3.amazonaws.com` |
| `endpoint`                                  | 当配置兼容 S3 的服务时，可以输入 URL，例如 `http://127.0.0.1:9000`。此设置优先于 `host`。对于合并表单，请始终使用 `endpoint`。 | (可选)           |
| `path_style`                               | 设置为 `true` 以使用 `host/bucket_name/object` 样式的路径，而非 `bucket_name.host/object`。对于需要路径样式寻址的兼容 S3 的服务，请设置为 `true`。对于 AWS S3，请保留为 `false`。 | `false`          |
| `use_iam_profile`                          | 设置为 `true` 以使用 IAM 实例配置文件而非访问密钥。                                                           | `false`          |
| `aws_credentials_refresh_threshold_seconds` | 当在 IAM 中使用临时凭据时，设置[自动刷新阈值](https://github.com/fog/fog-aws#controlling-credential-refresh-time-with-iam-authentication)（以秒为单位）。 | `15`             |
| `disable_imds_v2`                           | 强制使用 IMDS v1，通过禁用检索 `X-aws-ec2-metadata-token` 的 IMDS v2 端点。                                 | `false`          |

<a id="s3-compatibility-and-known-failure-modes"></a>

#### S3 兼容性及已知故障模式

声称兼容 S3 并不意味着该提供商能与极狐GitLab 正常工作。如果您在使用兼容 S3 的提供商时遇到错误，在提出支持请求前，请尝试以下调整：

- **签名流式传输**：某些提供商拒绝 AWS 签名 V4 流式传输使用的分块传输编码。请设置 `enable_signature_v4_streaming: false`。
- **签名版本**：某些提供商不完全支持签名版本 4。请设置 `aws_signature_version: 2`。
- **路径样式 URL**：某些提供商要求路径样式的存储桶寻址。请设置 `path_style: true`。
- **ETag 验证**：某些提供商返回的 ETag 与上传对象的 MD5 不匹配，而极狐GitLab 会验证此匹配。请参阅 [ETag 不匹配](#etag-不匹配)。

极狐GitLab 支持可以帮助排查配置问题，但无法保证解决[已测试集合](#有活跃测试覆盖的提供商)之外提供商的特定问题。

<a id="use-amazon-instance-profiles"></a>

#### 使用 Amazon 实例配置文件

无需在对象存储配置中提供 AWS 访问密钥和秘密密钥，您可以将极狐GitLab 配置为使用 Amazon 身份和访问管理 (IAM) 角色来设置 [Amazon 实例配置文件](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html)。使用此方法时，极狐GitLab 在每次访问 S3 存储桶时获取临时凭据，因此配置中无需硬编码的值。

前提条件：

- 极狐GitLab 必须能够连接到[实例元数据端点](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html)。
- 如果极狐GitLab [配置为使用互联网代理](https://docs.gitlab.com/omnibus/settings/environment-variables/)，则必须将端点 IP 地址添加到 `no_proxy` 列表中。
- 对于 IMDS v2 访问，请确保[跳数限制](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html)足够。如果极狐GitLab 运行在容器中，您可能需要将限制从 1 提高到 2。

设置实例配置文件：

1. 创建具有必要权限的 IAM 角色。以下示例是为名为 `test-bucket` 的 S3 存储桶创建的角色示例：

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

1. [将此角色关联](https://repost.aws/knowledge-center/attach-replace-ec2-instance-profile)到托管您极狐GitLab 实例的 EC2 实例。
1. 将极狐GitLab 的 `use_iam_profile` 配置选项设置为 `true`。

<a id="encrypted-s3-buckets"></a>

#### 加密 S3 存储桶

当通过实例配置文件或合并表单配置时，极狐GitLab Workhorse 会将文件正确上传到启用了[默认 SSE-S3 或 SSE-KMS 加密](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html)的 S3 存储桶。不支持 AWS KMS 密钥和 SSE-C 加密，[因为这需要在每个请求中发送加密密钥](https://gitlab.com/gitlab-org/gitlab/-/issues/226006)。

<a id="server-side-encryption-headers"></a>

#### 服务器端加密标头

在 S3 存储桶上设置默认加密是启用加密的最简单方式，但您可能想[设置存储桶策略以确保只上传加密的对象](https://repost.aws/knowledge-center/s3-bucket-store-kms-encrypted-objects)。为此，您必须在 `storage_options` 配置部分配置极狐GitLab 以发送适当的加密标头：

| 设置                               | 描述                                       |
|-----------------------------------|--------------------------------------------------|
| `server_side_encryption`          | 加密模式（`AES256` 或 `aws:kms`）。           |
| `server_side_encryption_kms_key_id` | Amazon 资源名称。仅当在 `server_side_encryption` 中使用 `aws:kms` 时才需要。请参阅[关于使用 KMS 加密的 Amazon 文档](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingKMSEncryption.html)。 |

与默认加密一样，这些选项仅在启用 Workhorse S3 客户端时有效。必须满足以下两个条件之一：

- 连接设置中 `use_iam_profile` 为 `true`。
- 正在使用合并表单。

如果在未启用 Workhorse S3 客户端的情况下使用服务器端加密标头，将会出现 [ETag 不匹配错误](#etag-不匹配)。

<a id="google-cloud-storage-gcs"></a>

### Google Cloud Storage (GCS)

{{< history >}}

- `universe_domain` 设置在 极狐GitLab 18.9 中引入。

{{< /history >}}

以下是 GCS 的有效连接参数：

| 设置                        | 描述                                                                                                     | 示例                                           |
|-----------------------------|-----------------------------------------------------------------------------------------------------------------|-------------------------------------------------|
| `provider`                  | 提供商名称。                                                                                                    | `Google`                                        |
| `google_project`            | GCP 项目名称。                                                                                                | `gcp-project-12345`                             |
| `google_json_key_location`  | JSON 密钥路径。                                                                                               | `/path/to/gcp-project-12345-abcde.json`         |
| `google_json_key_string`    | JSON 密钥字符串。                                                                                            | `{ "type": "service_account", "project_id": "example-project-382839", ... }` |
| `google_application_default` | 设置为 `true` 以使用 [Google Cloud 应用程序默认凭据](https://cloud.google.com/docs/authentication#adc)来定位服务账号凭据。 |                                                 |
| `universe_domain`           | 用于 Google Cloud 请求的 Universe 域。使用此选项连接至 [Google Cloud Dedicated](https://cloud.google.com/sovereign-cloud) 或其他非默认 Universe 域。 | `googleapis.com`                                |

极狐GitLab 会按顺序读取 `google_json_key_location`、`google_json_key_string`，最后是 `google_application_default` 的值。
它会使用其中第一个有值的设置。

服务账号必须拥有存储桶的访问权限。更多信息，请参阅 [Cloud Storage 身份验证文档](https://cloud.google.com/storage/docs/authentication)。

<a id="google-cloud-application-default-credentials"></a>

#### Google Cloud 应用程序默认凭据

[Google Cloud 应用程序默认凭据 (ADC)](https://cloud.google.com/docs/authentication/application-default-credentials) 通常用于极狐GitLab，以使用默认服务账号或[工作负载身份联合](https://cloud.google.com/iam/docs/workload-identity-federation)。将 `google_application_default` 设置为 `true`，并省略 `google_json_key_location` 和 `google_json_key_string`。

如果使用 ADC，请确保：

- 您使用的服务账号拥有 [`iam.serviceAccounts.signBlob` 权限](https://cloud.google.com/iam/docs/reference/credentials/rest/v1/projects.serviceAccounts/signBlob)。通常通过向服务账号授予 `Service Account Token Creator` 角色来实现。
- 如果使用 Google Compute 虚拟机，确保它们具有[正确的访问范围以访问 Google Cloud API](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances#changeserviceaccountandscopes)。如果虚拟机没有正确的范围，错误日志可能会显示：

  ```shell
  Google::Apis::ClientError (insufficientPermissions: Request had insufficient authentication scopes.)
  ```

> [!note]
> 要使用[客户管理的加密密钥](https://cloud.google.com/storage/docs/encryption/using-customer-managed-keys)的存储桶加密，请使用[合并表单](#为所有对象类型配置一个统一的存储连接合并表单)。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行，替换为您的值：

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

   要使用非默认 Universe 域（例如 [Google Cloud Dedicated](https://cloud.google.com/sovereign-cloud)）：

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

{{< tab title="Helm chart (Kubernetes)" >}}

1. 将以下内容放入名为 `object_storage.yaml` 的文件中，用作 [Kubernetes Secret](https://docs.gitlab.com/charts/charts/globals/#connection)：

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

   要使用非默认 Universe 域（例如 [Google Cloud Dedicated](https://cloud.google.com/sovereign-cloud)）：

   ```yaml
   provider: Google
   google_project: <GOOGLE PROJECT>
   google_application_default: true
   universe_domain: <UNIVERSE DOMAIN>
   ```

1. 创建 Kubernetes Secret：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-object-storage --from-file=connection=object_storage.yaml
   ```
### Azure Blob 存储

<a id="azure-blob-storage"></a>

尽管 Azure 使用 `container` 一词来表示 Blob 的集合，极狐GitLab 统一使用术语 `bucket`。请确保在 `bucket` 设置中配置 Azure 容器名称。

Azure Blob 存储只能与[统一形式](#configure-a-single-storage-connection-for-all-object-types-consolidated-form)一起使用，因为需要使用同一组凭据访问多个容器。不支持[特定存储形式](#configure-each-object-type-to-define-its-own-storage-connection-storage-specific-form)。有关更多详细信息，请参阅[如何过渡到统一形式](#transition-to-consolidated-form)。

以下是 Azure 的有效连接参数。有关更多信息，请参阅 [Azure Blob 存储文档](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction)。

| 设置                          | 描述             | 示例       |
|------------------------------|------------------|-----------|
| `provider`                   | 提供者名称。      | `AzureRM` |
| `azure_storage_account_name` | 用于访问存储的 Azure Blob 存储账户名称。 | `azuretest` |
| `azure_storage_access_key`   | 用于访问容器的存储账户访问密钥。这通常是一个以 base64 编码的 512 位加密密钥。对于 [Azure 工作负载和托管标识](#azure-workload-and-managed-identities)，这是可选的。 | `czV2OHkvQj9FKEgrTWJRZVRoV21ZcTN0Nnc5eiRDJkYpSkBOY1JmVWpYbjJy\nNHU3eCFBJUQqRy1LYVBkU2dWaw==\n` |
| `azure_storage_domain`       | 用于联系 Azure Blob 存储 API 的域名（可选）。默认为 `blob.core.windows.net`。如果您使用的是 Azure 中国或某些其他自定义 Azure 域，请设置此项。 | `blob.core.windows.net` |

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行，替换为您想要的值：

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

   如果您使用的是[工作负载标识](#azure-workload-and-managed-identities)，请省略 `azure_storage_access_key`：

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

{{< tab title="Helm Chart (Kubernetes)" >}}

1. 将以下内容放入名为 `object_storage.yaml` 的文件中，用作 [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#connection)：

   ```yaml
   provider: AzureRM
   azure_storage_account_name: <YOUR_AZURE_STORAGE_ACCOUNT_NAME>
   azure_storage_access_key: <YOUR_AZURE_STORAGE_ACCOUNT_KEY>
   azure_storage_domain: blob.core.windows.net
   ```

   如果您使用的是[工作负载或托管标识](#azure-workload-and-managed-identities)，请省略 `azure_storage_access_key`：

   ```yaml
   provider: AzureRM
   azure_storage_account_name: <YOUR_AZURE_STORAGE_ACCOUNT_NAME>
   azure_storage_domain: blob.core.windows.net
   ```

1. 创建 Kubernetes Secret：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-object-storage --from-file=connection=object_storage.yaml
   ```

1. 导出 Helm 值：

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

1. 保存文件并应用新值：

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
           # 统一对象存储配置
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

    如果您使用的是[托管标识](#azure-workload-and-managed-identities)，请省略 `azure_storage_access_key`。

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

对于自行编译的安装，Workhorse 也需要配置 Azure 凭据。这在 Linux 软件包安装中是不需要的，因为 Workhorse 设置会从之前的设置中填充。

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

   如果您使用的是自定义 Azure 存储域，则 **无需** 在 Workhorse 配置中设置 `azure_storage_domain`。此信息会在极狐GitLab Rails 与 Workhorse 之间的 API 调用中交换。

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

#### Azure 工作负载和托管标识

<a id="azure-workload-and-managed-identities"></a>

{{< history >}}

- 在极狐GitLab 17.9 中引入。

{{< /history >}}

要使用 [Azure 工作负载标识](https://azure.github.io/azure-workload-identity/docs/) 或[托管标识](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/)，请从配置中省略 `azure_storage_access_key`。当 `azure_storage_access_key` 为空时，极狐GitLab 会尝试：

1. 使用[工作负载标识](https://learn.microsoft.com/en-us/entra/workload-id/workload-identities-overview)获取临时凭据。环境变量中应包含 `AZURE_TENANT_ID`、`AZURE_CLIENT_ID` 和 `AZURE_FEDERATED_TOKEN_FILE`。
1. 如果工作负载标识不可用，则从 [Azure 实例元数据服务](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-to-use-vm-token)请求凭据。
1. 获取[用户委托密钥](https://learn.microsoft.com/en-us/rest/api/storageservices/get-user-delegation-key)。
1. 使用该密钥生成 SAS 令牌以访问存储账户 Blob。

确保该标识已分配 `Storage Blob Data Contributor` 角色。

### 特定提供商的配置示例

<a id="provider-specific-configuration-examples"></a>

以下示例展示了需要非默认设置的特定 S3 兼容提供商的配置。对于此处未列出的任何 S3 兼容提供商，请使用[基础 S3 兼容配置](#s3-compatible-providers)，并为您提供商设置适当的 `endpoint`。

#### Oracle 云基础设施

<a id="oracle-cloud-infrastructure"></a>

Oracle 云基础设施 S3 需要以下设置：

| 设置                             | 值     |
|:--------------------------------|:------|
| `enable_signature_v4_streaming` | `false` |
| `path_style`                    | `true` |

如果 `enable_signature_v4_streaming` 设置为 `true`，您可能会在 `production.log` 中看到以下错误：

```plaintext
不支持 STREAMING-AWS4-HMAC-SHA256-PAYLOAD
```

#### Storj 网关 (SJ)

<a id="storj-gateway-sj"></a>

> [!note]
> Storj 网关[不支持](https://github.com/storj/gateway-st/blob/4b74c3b92c63b5de7409378b0d1ebd029db9337d/docs/s3-compatibility.md)多线程复制（参见表中的 `UploadPartCopy`）。
> 虽然[已计划](https://github.com/storj/roadmap/issues/40)实现，但在完成之前，您必须[禁用多线程复制](#multi-threaded-copying)。

[Storj 网络](https://www.storj.io/)提供了一个 S3 兼容的 API 网关。使用以下配置示例：

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
有关更多信息，请参阅[议题 #4419](https://jihulab.com/gitlab-cn/gitlab/-/issues/4419)。

#### Hitachi Vantara HCP

<a id="hitachi-vantara-hcp"></a>

> [!note]
> 连接到 HCP 可能会返回错误，提示 `SignatureDoesNotMatch - The request signature we calculated does not match the signature you provided. Check your HCP Secret Access key and signing method.`。在这些情况下，请将 `endpoint` 设置为租户的 URL 而不是命名空间，并确保存储桶路径配置为 `<namespace_name>/<bucket_name>`。

[HCP](https://docs.hitachivantara.com/r/en-us/content-platform/9.7.x/mk-95hcph001/hcp-management-api-reference/introduction-to-the-hcp-management-api/support-for-the-amazon-s3-api) 提供了一个 S3 兼容的 API。使用以下配置示例：

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

# <namespace_name/bucket_name> 格式示例
gitlab_rails['object_store']['objects']['artifacts']['bucket'] = '<namespace_name>/<bucket_name>'
```

#### Ceph RGW

<a id="ceph-rgw"></a>

[Ceph RGW](https://docs.ceph.com/en/reef/cephadm/services/rgw/) 是 Ceph 的 S3 兼容 API。
使用以下配置示例：

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

要启用 Ceph RGW 的[服务端加密](#server-side-encryption-headers)，您必须使用 HTTPS 连接。Ceph 会拒绝通过非安全连接的加密请求。

## 使用统一形式和 Amazon S3 的完整示例

<a id="full-example-using-the-consolidated-form-and-amazon-s3"></a>

以下示例使用 AWS S3 为所有支持的服务启用对象存储：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行，替换为您想要的值：

   ```ruby
   # 统一对象存储配置
   gitlab_rails['object_store']['enabled'] = true
   gitlab_rails['object_store']['proxy_download'] = false
   gitlab_rails['object_store']['connection'] = {
     'provider' => 'AWS',
     'region' => 'eu-central-1',
     'aws_access_key_id' => '<AWS_ACCESS_KEY_ID>',
     'aws_secret_access_key' => '<AWS_SECRET_ACCESS_KEY>'
   }
   # 可选：以下行仅在需要服务端加密时才需要
   gitlab_rails['object_store']['storage_options'] = {
     'server_side_encryption' => '<AES256 或 aws:kms>',
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

   如果您使用的是 [AWS IAM 实例配置文件](#use-amazon-instance-profiles)，请省略 AWS 访问密钥和秘密访问密钥/值对。例如：

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

{{< tab title="Helm Chart (Kubernetes)" >}}

1. 将以下内容放入名为 `object_storage.yaml` 的文件中，用作 [Kubernetes Secret](https://gitlab.cn/docs/charts/charts/globals/#connection)：

   ```yaml
   provider: AWS
   region: us-east-1
   aws_access_key_id: <AWS_ACCESS_KEY_ID>
   aws_secret_access_key: <AWS_SECRET_ACCESS_KEY>
   ```

   如果您使用的是 [AWS IAM 实例配置文件](#use-amazon-instance-profiles)，请省略 AWS 访问密钥和秘密访问密钥/值对。例如：

   ```yaml
   provider: AWS
   region: us-east-1
   use_iam_profile: true
   ```

1. 创建 Kubernetes Secret：

   ```shell
   kubectl create secret generic -n <namespace> gitlab-object-storage --from-file=connection=object_storage.yaml
   ```

1. 导出 Helm 值：

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

1. 保存文件并应用新值：

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
           # 统一对象存储配置
           gitlab_rails['object_store']['enabled'] = true
           gitlab_rails['object_store']['proxy_download'] = false
           gitlab_rails['object_store']['connection'] = {
             'provider' => 'AWS',
             'region' => 'eu-central-1',
             'aws_access_key_id' => '<AWS_ACCESS_KEY_ID>',
             'aws_secret_access_key' => '<AWS_SECRET_ACCESS_KEY>'
           }
           # 可选：以下行仅在需要服务端加密时才需要
           gitlab_rails['object_store']['storage_options'] = {
             'server_side_encryption' => '<AES256 或 aws:kms>',
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

   如果您使用的是 [AWS IAM 实例配置文件](#use-amazon-instance-profiles)，请省略 AWS 访问密钥和秘密访问密钥/值对。例如：

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
         server_side_encryption: <AES256 或 aws:kms>
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

   如果您使用的是 [AWS IAM 实例配置文件](#use-amazon-instance-profiles)，请省略 AWS 访问密钥和秘密访问密钥/值对。例如：

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
   ```
    ```yaml
    [object_storage.s3]
      aws_access_key_id = "<AWS_ACCESS_KEY_ID>"
      aws_secret_access_key = "<AWS_SECRET_ACCESS_KEY>"
    ```

   如果你正在使用 [AWS IAM 配置文件](#use-amazon-instance-profiles)，请省略 AWS 访问密钥和密钥/值对。例如：

   ```yaml
   [object_storage.s3]
     use_iam_profile = true
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于运行 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于运行 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="migrate-to-object-storage"></a>

## 迁移到对象存储

要将现有本地数据迁移到对象存储，请参阅以下指南：

- [产物](cicd/job_artifacts.md#migrating-to-object-storage) 包括归档的作业日志
- [LFS 对象](lfs/_index.md#migrating-to-object-storage)
- [上传](raketasks/uploads/migrate.md#migrate-to-object-storage)
- [合并请求差异](merge_request_diffs.md#using-object-storage)
- [软件包](packages/_index.md#migrate-packages-between-object-storage-and-local-storage)（可选功能）
- [依赖代理](packages/dependency_proxy.md#migrate-local-dependency-proxy-blobs-and-manifests-to-object-storage)
- [Terraform 状态文件](terraform_state.md#migrate-to-object-storage)
- [Pages 内容](pages/_index.md#migrate-pages-deployments-to-object-storage)
- [项目级别安全文件](cicd/secure_files.md#migrate-to-object-storage)

<a id="transition-to-consolidated-form"></a>

## 过渡到统一配置形式

在存储特定配置中：

- 所有类型对象（如 CI/CD 产物、LFS 文件和上传附件）的对象存储配置是独立进行的。
- 对象存储连接参数（如密码和端点 URL）对于每种类型都会重复出现。

例如，Linux 软件包安装可能具有以下配置：

```ruby
# 原始对象存储配置
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

尽管这种方式提供了灵活性，使极狐GitLab 能够将对象存储在不同的云提供商上，但它也增加了不必要的复杂性和冗余。因为极狐GitLab Rails 和 Workhorse 组件都需要访问对象存储，统一配置形式避免了凭证的过度重复。

统一配置形式仅在所有原始形式的配置行均被省略时才会使用。要迁移到统一配置形式，请删除原始配置（例如 `artifacts_object_store_enabled` 或 `uploads_object_store_connection`）。

<a id="migrate-objects-to-a-different-object-storage-provider"></a>

## 将对象迁移到不同的对象存储提供商

你可能需要将极狐GitLab 在对象存储中的数据迁移到不同的对象存储提供商。以下步骤展示了如何使用 [Rclone](https://rclone.org/) 完成此操作。

这些步骤假设你正在迁移 `uploads` 存储桶，但相同的流程也适用于其他存储桶。

先决条件：

- 选择运行 Rclone 的计算机。根据你要迁移的数据量，Rclone 可能需要运行很长时间，因此应避免使用可能进入省电模式的笔记本电脑或台式机。你可以使用极狐GitLab 服务器来运行 Rclone。

1. [安装](https://rclone.org/downloads/) Rclone。
1. 通过运行以下命令配置 Rclone：

   ```shell
   rclone config
   ```

   配置过程是交互式的。至少添加两个“远程存储”：一个是你当前数据所在的对象存储提供商（`old`），另一个是你要迁移到的提供商（`new`）。

1. 确认你可以读取旧数据。以下示例引用 `uploads` 存储桶，但你的存储桶可能具有不同的名称：

   ```shell
   rclone ls old:uploads | head
   ```

   这应该会打印出当前存储在 `uploads` 存储桶中的部分对象列表。如果你收到错误，或者列表为空，请返回并使用 `rclone config` 更新你的 Rclone 配置。

1. 执行初始复制。在此步骤中你无需将极狐GitLab 服务器下线。

   ```shell
   rclone sync -P old:uploads new:uploads
   ```

1. 首次同步完成后，使用新对象存储提供商的 Web UI 或命令行界面验证新存储桶中是否有对象。如果没有，或者运行 `rclone sync` 时遇到错误，请检查你的 Rclone 配置并重试。

在你至少成功完成一次从旧位置到新位置的 Rclone 复制后，安排维护并将极狐GitLab 服务器下线。在维护窗口期间，你必须完成两件事：

1. 执行一次最终的 `rclone sync` 运行，确保用户无法添加新对象，这样就不会在旧存储桶中留下任何数据。
1. 更新极狐GitLab 服务器的对象存储配置，以使用新的 `uploads` 提供商。

<a id="alternatives-to-file-system-storage"></a>

## 文件系统存储的替代方案

如果你正在 [扩展](reference_architectures/_index.md) 极狐GitLab 实施，或增加容错和冗余，你可能希望消除对块存储或网络文件系统的依赖。请参阅以下附加指南：

1. 确保 [`git` 用户主目录](https://gitlab.cn/docs/omnibus/settings/configuration/#move-the-home-directory-for-a-user) 位于本地磁盘上。
1. 配置 [SSH 密钥的数据库查找](operations/fast_ssh_key_lookup.md)，以消除对共享 `authorized_keys` 文件的需求。
1. [防止作业日志使用本地磁盘](cicd/job_logs.md#prevent-local-disk-usage)。
1. [禁用 Pages 本地存储](pages/_index.md#disable-pages-local-storage)。

<a id="troubleshooting"></a>

## 故障排除

<a id="objects-are-not-included-in-gitlab-backups"></a>

### 对象未包含在极狐GitLab 备份中

正如 [备份文档](backup_restore/backup_gitlab.md#object-storage) 中所指出的，对象不会包含在极狐GitLab 备份中。你可以启用对象存储提供商提供的备份来代替。

<a id="use-separate-buckets"></a>

### 使用独立的存储桶

为每种数据类型使用独立的存储桶是极狐GitLab 的推荐方法。这样可以确保极狐GitLab 存储的各种类型数据之间不会发生冲突。借助 Linux 软件包和自编译安装，可以将一个真实存储桶拆分为多个虚拟存储桶。如果你的对象存储桶名为 `my-gitlab-objects`，你可以将上传配置到 `my-gitlab-objects/uploads`，产物配置到 `my-gitlab-objects/artifacts` 等。应用程序会将其视为独立的存储桶。

基于 Helm 的安装需要独立的存储桶来 [处理备份恢复](https://gitlab.cn/docs/charts/advanced/external-object-storage/#lfs-artifacts-uploads-packages-external-diffs-terraform-state-dependency-proxy-secure-files)。

<a id="s3-api-compatibility-issues"></a>

### S3 API 兼容性问题

如果你在使用与 S3 兼容的提供商时遇到错误，请参阅 [S3 兼容性及已知故障模式](#s3-compatibility-and-known-failure-modes) 了解常见原因和配置调整。`production.log` 中出现 `411 Length Required` 错误通常是由签名流式传输引起的。将 `enable_signature_v4_streaming: false` 设置为 false 以解决此问题。

<a id="artifacts-always-downloaded-with-filename-download"></a>

### 产物始终以 `download` 文件名下载

下载的产物文件名是通过 [GetObject 请求](https://docs.aws.amazon.com/AmazonS3/latest/API/API_GetObject.html) 中的 `response-content-disposition` 标头设置的。如果 S3 提供商不支持此标头，则下载的文件始终保存为 `download`。

<a id="proxy-download"></a>

### 代理下载

客户端可以通过接收预签名、有时限的 URL，或由极狐GitLab 代理将数据从对象存储传输给客户端来下载对象存储中的文件。直接从对象存储下载文件有助于减少极狐GitLab 需要处理的出口流量。

当文件存储在本地块存储或 NFS 上时，极狐GitLab 必须充当代理。这不是对象存储的默认行为。

`proxy_download` 设置控制此行为：默认值为 `false`。请在每个用例的文档中验证这一点。

如果你希望极狐GitLab 代理文件，请将 `proxy_download` 设置为 `true`。如果 `proxy_download` 设置为 `true`，极狐GitLab 服务器的性能可能会受到很大影响。极狐GitLab 的服务器部署将 `proxy_download` 设置为 `false`。

当 `proxy_download` 为 `false` 时，极狐GitLab 会返回一个 HTTP 302 重定向，包含一个预签名、有时限的对象存储 URL。这可能导致以下一些问题：

- 如果极狐GitLab 使用非安全 HTTP 访问对象存储，客户端可能会产生 `https->http` 降级错误并拒绝处理重定向。解决方法是让极狐GitLab 使用 HTTPS。例如，LFS 会生成此错误：

  ```plaintext
  LFS: lfsapi/client: refusing insecure redirect, https->http
  ```

- 客户端需要信任颁发对象存储证书的证书颁发机构，否则可能会返回常见的 TLS 错误，例如：

  ```plaintext
  x509: certificate signed by unknown authority
  ```

- 客户端需要能够网络访问对象存储。网络防火墙可能会阻止访问。如果未建立此访问，可能出现的错误包括：

  ```plaintext
  Received status code 403 from server: Forbidden
  ```

- 对象存储桶需要允许来自极狐GitLab 实例 URL 的跨源资源共享（CORS）访问。尝试在仓库页面加载 PDF 时可能会显示以下错误：

  ```plaintext
  An error occurred while loading the file. Please try again later.
  ```

  有关更多详细信息，请参阅 [LFS 文档](lfs/_index.md#error-viewing-a-pdf-file)。

> [!warning]
> 预签名 URL 具有时限性，但不会与特定用户绑定。任何获得预签名 URL 的用户都可以在 URL 有效期内无需认证即可访问对象。直接下载还可能会在你的对象存储提供商与客户端之间产生带宽费用。

<a id="etag-mismatch"></a>

### ETag 不匹配

使用默认的极狐GitLab 设置时，某些与 S3 兼容的对象存储后端（例如阿里云）可能会生成 `ETag mismatch` 错误。

<a id="amazon-s3-encryption"></a>

#### Amazon S3 加密

如果你在 Amazon Web Services S3 上遇到此 ETag 不匹配错误，很可能是由于 [存储桶上的加密设置](https://docs.aws.amazon.com/AmazonS3/latest/API/RESTCommonResponseHeaders.html) 所致。要解决此问题，你有两个选择：

- [使用统一配置形式](#configure-a-single-storage-connection-for-all-object-types-consolidated-form)。
- [使用 Amazon 实例配置文件](#use-amazon-instance-profiles)。

对于与 S3 兼容的服务，建议使用统一配置形式。某些服务还可能需要额外的服务器端配置，例如启用兼容模式，以解决 ETag 不匹配错误。

如果不使用统一配置形式或实例配置文件，极狐GitLab Workhorse 会使用未计算 `Content-MD5` HTTP 标头的预签名 URL 将文件上传到 S3。为了确保数据未被损坏，Workhorse 会检查发送数据的 MD5 哈希值是否等于 S3 服务器返回的 ETag 标头。启用加密后，情况并非如此，这会导致 Workhorse 在上传过程中报告 `ETag mismatch` 错误。

当统一配置形式：

- 与 S3 兼容的对象存储或实例配置文件一起使用时，Workhorse 会使用其内部 S3 客户端，该客户端具有 S3 凭证，从而可以计算 `Content-MD5` 标头。这消除了比较 S3 服务器返回的 ETag 标头的需要。
- 不与 S3 兼容的对象存储一起使用时，Workhorse 会回退到使用预签名 URL。

<a id="google-cloud-storage-encryption"></a>

#### Google Cloud Storage 加密

{{< history >}}

- 引入于极狐GitLab 16.11。

{{< /history >}}

在启用 [客户管理的加密密钥（CMEK）](https://cloud.google.com/storage/docs/encryption/using-customer-managed-keys) 时，Google Cloud Storage（GCS）中也会发生 ETag 不匹配错误。

要使用 CMEK，请使用 [统一配置形式](#configure-a-single-storage-connection-for-all-object-types-consolidated-form)。

<a id="multi-threaded-copying"></a>

### 多线程复制

极狐GitLab 使用 [S3 Upload Part Copy API](https://docs.aws.amazon.com/AmazonS3/latest/API/API_UploadPartCopy.html) 来加速存储桶内文件的复制。此功能不受某些 S3 兼容提供商的支持，并且它们在上传期间会返回 404 错误。

要禁用多线程复制，请让具有 [Rails 控制台访问权限](feature_flags/_index.md#how-to-enable-and-disable-features-behind-flags) 的极狐GitLab 管理员运行以下命令：

```ruby
Feature.disable(:s3_multithreaded_uploads)
```

<a id="manual-testing-through-rails-console"></a>

### 通过 Rails 控制台进行手动测试

当你怀疑配置错误时，可以使用此方法验证对象存储连接。以下示例测试连接，写入一个测试对象，并将其读回。

1. 启动 [Rails 控制台](operations/rails_console.md)。
1. 使用你在 `/etc/gitlab/gitlab.rb` 中设置的相同参数，以下列示例格式设置对象存储连接：

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

1. 指定要测试的存储桶名称，写入并最后读取一个测试文件。

   ```ruby
   dir = connection.directories.new(key: '<bucket-name-here>')
   f = dir.files.create(key: 'test.txt', body: 'test')
   pp f
   pp dir.files.head('test.txt')
   ```

<a id="enable-additional-debugging"></a>

#### 启用额外的调试

{{< history >}}

- `AWS_DEBUG` 环境变量支持引入于极狐GitLab 18.3。

{{< /history >}}

你还可以启用额外的调试来查看 HTTP 请求。你应在 [Rails 控制台](operations/rails_console.md) 中执行此操作，以避免凭证泄露到日志文件中。以下展示了如何为不同的提供商启用请求调试：

{{< tabs >}}

{{< tab title="Amazon S3" >}}

设置 `EXCON_DEBUG` 环境变量：

```ruby
ENV['EXCON_DEBUG'] = "1"
```

你还可以通过将 `AWS_DEBUG` 环境变量设置为 `1`，在极狐GitLab Workhorse 日志中启用 S3 HTTP 请求和响应标头日志记录。对于 Linux 软件包（Omnibus）：

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

   与 S3 兼容的存储请求和响应标头将记录在 `/var/log/gitlab/gitlab-workhorse/current` 中。

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

### 重置 Geo 跟踪数据库以确保完整的对象一致性

假设以下 Geo 场景：

- 环境由一个 Geo 主节点和一个辅助节点组成。
- 你在主节点上 [迁移到了对象存储](#migrate-to-object-storage)。
  - 辅助节点使用独立的对象存储桶。
  - 已激活“允许此辅助站点复制对象存储上的内容”选项。

此类迁移可能导致在跟踪数据库中将对象标记为已同步，但对象存储中却实际缺失这些对象。在这种情况下，[重置你的 Geo 辅助站点复制](geo/replication/troubleshooting/synchronization_verification.md#resetting-geo-secondary-site-replication)，以确保迁移后对象状态保持一致。

<a id="inconsistencies-after-migrating-to-object-storage"></a>

### 迁移到对象存储后出现不一致

从本地存储迁移到对象存储时，可能会出现数据不一致。特别是在与 [Geo](geo/replication/object_storage.md) 结合使用时，如果文件在迁移前已被手动删除，就会出现这种情况。

例如，实例管理员在本地文件系统上手动删除了几个产物。此类更改无法正确传播到数据库，从而导致不一致。迁移到对象存储后，这些不一致仍然存在，并可能造成摩擦。Geo 辅助节点可能会继续尝试复制这些文件，因为这些文件仍在数据库中被引用，但已不复存在。

<a id="identify-inconsistencies-when-using-geo"></a>

#### 在使用 Geo 时识别不一致

假设以下 Geo 场景：

- 环境由一个 Geo 主节点和一个辅助节点组成
- 两个系统均已迁移到对象存储
  - 辅助节点使用与主节点相同的对象存储
  - 选项“允许此辅助站点复制对象存储上的内容”已停用
- 在对象存储迁移之前，手动删除了多个上传文件
  - 在本示例中，有两张上传到议题的图片

在这种情况下，辅助节点不再需要复制任何数据，因为它使用与主节点相同的对象存储。由于存在不一致，管理员可以观察到辅助节点仍在尝试复制数据：

在主站点上：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 查看 **主站点** 并检查验证信息。所有上传均已验证：
   ![Geo 站点仪表板显示主站点验证成功。](img/geo_primary_uploads_verification_v17_11.png)
1. 查看 **辅助站点** 并检查验证信息。请注意，有两个上传仍在同步，尽管辅助站点应该使用相同的对象存储。也就是说，它本不应该同步任何上传：
   ![Geo 站点仪表板显示辅助站点存在不一致。](img/geo_secondary_uploads_inconsistencies_v17_11.png)

<a id="clean-up-inconsistencies"></a>

#### 清理不一致

> [!warning]
> 在执行任何删除命令之前，请确保你手头有最新且可用的备份。

基于之前的情况，多个 **上传** 导致了不一致，以下将以它们为例进行说明。

按照以下步骤正确删除潜在的残留数据：

1. 将已识别的不一致项映射到其对应的模型名称。在后续步骤中需要使用模型名称。

   | 对象存储类型                | 模型名称                                                |
   |--------------------------|---------------------------------------------------------|
   | 备份                      | 不适用                                                   |
   | 容器镜像仓库                 | 不适用                                                   |
   | Mattermost               | 不适用                                                   |
   | 自动伸缩 Runner 缓存             | 不适用                                                   |
   | 安全文件                   | `Ci::SecureFile`                                        |
   | 作业产物                   | `Ci::JobArtifact` 和 `Ci::PipelineArtifact`            |
   | LFS 对象                  | `LfsObject`                                             |
   | 上传                     | `Upload`                                                |
   | 合并请求差异               | `MergeRequestDiff`                                      |
   | 软件包                     | `Packages::PackageFile`                                 |
   | 依赖代理                   | `DependencyProxy::Blob` 和 `DependencyProxy::Manifest` |
   | Terraform 状态文件          | `Terraform::StateVersion`                               |
   | Pages 内容                | `PagesDeployment`                                       |

1. 启动一个 [Rails 控制台](operations/rails_console.md)。
1. 根据上一步中的模型名称查询所有仍存储在本地（而非对象存储中）的“文件”。在本例中，由于上传受到影响，因此使用模型名称 `Upload`。观察 `openbao.png` 如何仍存储在本地：

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

1. 使用已识别资源的 `id` 来正确删除它们。首先，通过使用 `find` 验证其是否为正确的资源，然后运行 `destroy`：

   ```ruby
   Upload.find(108)
   Upload.find(108).destroy
   ```

1. 可选地，通过再次运行 `find` 来验证资源是否已正确删除，此时不应再找到它：

   ```ruby
   Upload.find(108)
   ```

   ```ruby
   ActiveRecord::RecordNotFound: Couldn't find Upload with 'id'=108
   ```

对所有受影响的对象存储类型重复以上步骤。

<a id="job-logs-are-missing-in-a-multi-node-gitlab-instance"></a>

### 多节点极狐GitLab 实例中缺少作业日志

在具有多个 Rails 节点（运行 Web 服务或 Sidekiq 的服务器）的极狐GitLab 实例上，需要有一种机制，使作业日志在从 Runner 发送后可供所有节点使用。作业日志可以存储在本地磁盘或对象存储中。

如果未使用 NFS，并且 [增量日志记录功能](cicd/job_logs.md#incremental-logging) 尚未启用，则作业日志可能会丢失：

1. 从 Runner 接收日志的节点将日志写入本地磁盘。
1. 当极狐GitLab 尝试归档日志时，通常作业运行在其他服务器上，该服务器无法访问该日志。
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

如果 CI 产物在多节点环境中写入对象存储，你必须 [启用增量日志记录功能](cicd/job_logs.md#configure-incremental-logging)。