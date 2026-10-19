---
stage: Analytics
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 设置并配置 Elasticsearch，以便在极狐GitLab 中使用高级搜索。
title: Elasticsearch
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本页介绍如何启用高级搜索。启用后，高级搜索可提供更快的搜索响应时间和[改进的搜索功能](../../user/search/advanced_search.md)。

要启用高级搜索，您必须：

1. [安装 Elasticsearch 或 AWS OpenSearch 集群](#install-an-elasticsearch-or-aws-opensearch-cluster)。
1. [启用高级搜索](#enable-advanced-search)。

> [!note]
> 高级搜索将所有项目存储在相同的 Elasticsearch 索引中。
> 但是，私有项目仅对有权访问的用户显示在搜索结果中。

<a id="elasticsearch-glossary"></a>

## Elasticsearch 术语表

本术语表提供与 Elasticsearch 相关术语的定义。

- **Lucene**：用 Java 编写的全文搜索库。
- **近实时（NRT）**：指从索引文档到该文档可被搜索之间的轻微延迟。
- **集群**：一个或多个节点的集合，它们协同工作以保存所有数据，提供索引和搜索能力。
- **节点**：作为集群一部分工作的单个服务器。
- **索引**：具有某些相似特征的文档集合。
- **文档**：可被索引的基本信息单元。
- **分片**：索引的完全独立且功能完整的细分部分。每个分片实际上是一个 Lucene 索引。
- **副本**：复制索引的故障转移机制。

<a id="install-an-elasticsearch-or-aws-opensearch-cluster"></a>

## 安装 Elasticsearch 或 AWS OpenSearch 集群

Linux 软件包中不包含 Elasticsearch 和 AWS OpenSearch。
您可以自行安装搜索集群，或使用云托管服务，例如：

- [Elasticsearch Service](https://www.elastic.co/elasticsearch/service)（可在 Amazon Web Services、Google Cloud Platform 和 Microsoft Azure 上使用）
- [Amazon OpenSearch Service](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/gsg.html)

您应将搜索集群安装在单独的服务器上。在与极狐GitLab 相同的服务器上运行搜索集群可能会导致性能问题。

对于单节点搜索集群，集群状态始终为黄色，因为主分片已分配。集群无法将副本分片分配到与主分片相同的节点上。

> [!note]
> 在生产环境中使用新的 Elasticsearch 集群之前，请参阅
> [重要的 Elasticsearch 配置](https://www.elastic.co/docs/deploy-manage/deploy/self-managed/important-settings-configuration)。

<a id="version-compatibility"></a>

### 版本兼容性

<a id="elasticsearch"></a>

#### Elasticsearch

> [!warning]
> 对 Elasticsearch 7.x 的支持已在极狐GitLab 18.10 中[弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/583544)，
> 并计划在 20.0 中移除。

高级搜索与以下版本的 Elasticsearch 兼容。

| 极狐GitLab 版本  | Elasticsearch 版本 |
|-----------------|-----------------------|
| 19.1 及更高版本  | 8.x 和 9.x           |
| 15.0 至 19.0    | 7.x 和 8.x           |
| 14.0 至 14.10   | 6.8 至 7.x            |

JihuLab.com 使用 Elasticsearch 9.x。
使用 Elasticsearch 9.x 可获得最佳性能、最新功能和向前兼容性。

高级搜索遵循 [Elasticsearch 生命周期终止政策](https://www.elastic.co/support/eol)。

<a id="opensearch"></a>

#### OpenSearch

高级搜索与以下版本的 OpenSearch 兼容。

| 极狐GitLab 版本   | OpenSearch 版本 |
|------------------|--------------------|
| 18.1 及更高版本   | 1.x 及更高版本      |
| 17.6.3 至 18.0   | 1.x 和 2.x        |
| 15.5.3 至 17.6.2 | 1.x、2.0 至 2.17   |
| 15.0 至 15.5.2   | 1.x                |

高级搜索遵循 [OpenSearch 维护政策](https://opensearch.org/releases/)。

<a id="system-requirements"></a>

### 系统要求

Elasticsearch 和 AWS OpenSearch 比[极狐GitLab 安装要求](../../install/requirements.md)需要更多资源。

内存、CPU 和存储要求取决于您索引到集群中的数据量。使用频繁的 Elasticsearch 集群可能需要更多资源。[`estimate_cluster_size`](#gitlab-advanced-search-rake-tasks) Rake 任务使用代码仓库总大小来估算高级搜索的存储需求。

<a id="access-requirements"></a>

### 访问要求

极狐GitLab 支持 [HTTP 和基于角色的身份验证方法](#advanced-search-configuration)，具体取决于您的需求以及您使用的后端服务。

<a id="role-based-access-control-for-elasticsearch"></a>

#### Elasticsearch 的基于角色的访问控制

Elasticsearch 可以提供基于角色的访问控制，以进一步保护集群。要在 Elasticsearch 集群中访问并执行操作，在**管理**区域中配置的 `Username` 必须具有授予以下权限的角色。`Username` 用于从极狐GitLab 向搜索集群发起请求。

有关更多信息，
请参阅 [Elasticsearch 基于角色的访问控制](https://www.elastic.co/guide/en/elasticsearch/reference/current/authorization.html#roles)
和 [Elasticsearch 安全权限](https://www.elastic.co/docs/reference/elasticsearch/security-privileges)。

```json
{
  "cluster": ["monitor"],
  "indices": [
    {
      "names": ["gitlab-*"],
      "privileges": [
        "create_index",
        "delete_index",
        "view_index_metadata",
        "read",
        "manage",
        "write"
      ]
    }
  ]
}
```

<a id="access-control-for-aws-opensearch-service"></a>

#### AWS OpenSearch Service 的访问控制

先决条件：

- 在创建 OpenSearch 域时，您的 AWS 账户中必须有一个名为 `AWSServiceRoleForAmazonOpenSearchService`的
  [服务关联角色](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/slr.html)。
- AWS OpenSearch 的域访问策略必须允许 `es:ESHttp*` 操作。

`AWSServiceRoleForAmazonOpenSearchService` 由所有 OpenSearch 域使用。
在大多数情况下，当您使用 AWS 管理控制台创建第一个 OpenSearch 域时，会自动创建此角色。要手动创建服务关联角色，请参阅
[AWS 文档](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/slr-aos.html#create-slr)。

AWS OpenSearch Service 有三个主要安全层：

- [网络](#network)
- [域访问策略](#domain-access-policy)
- [精细访问控制](#fine-grained-access-control)

<a id="network"></a>

##### 网络

通过此安全层，您可以在创建域时选择 **公共访问**，以便来自任何客户端的请求都能到达域端点。如果您选择 **VPC 访问**，客户端必须连接到 VPC，请求才能到达端点。

有关更多信息，请参阅
[AWS 文档](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/fgac.html#fgac-access-policies)。

<a id="domain-access-policy"></a>

##### 域访问策略

极狐GitLab 支持以下 AWS OpenSearch 域访问控制方法：

- [**基于资源（域）的访问策略**](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/ac.html#ac-types-resource)：其中 AWS OpenSearch 域配置了 IAM 策略
- [**基于身份的策略**](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/ac.html#ac-types-identity)：其中客户端使用带有策略的 IAM 主体来配置访问

<a id="resource-based-policy-examples"></a>

###### 基于资源的策略示例

以下是一个基于资源（域）的访问策略示例，其中允许 `es:ESHttp*` 操作：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "es:ESHttp*"
      ],
      "Resource": "arn:aws:es:us-west-1:987654321098:domain/test-domain/*"
    }
  ]
}
```

以下是一个基于资源（域）的访问策略示例，其中仅对特定 IAM 主体允许 `es:ESHttp*` 操作：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::123456789012:user/test-user"
        ]
      },
      "Action": [
        "es:ESHttp*"
      ],
      "Resource": "arn:aws:es:us-west-1:987654321098:domain/test-domain/*"
    }
  ]
}
```

> [!note]
> 如果跨账户使用 [AWS `AssumeRole`](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html)，
> 则必须提供 `aws_role_arn`。该 ARN 应为有权访问 OpenSearch 的角色。

<a id="identity-based-policy-examples"></a>

###### 基于身份的策略示例

以下是一个附加到 IAM 主体的基于身份的访问策略示例，其中允许 `es:ESHttp*` 操作：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "es:ESHttp*",
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
```

<a id="fine-grained-access-control"></a>

##### 精细访问控制

当您启用精细访问控制时，必须通过以下方式之一设置[主用户](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/fgac.html#fgac-master-user)：

- [将 IAM ARN 设置为主用户](#set-an-iam-arn-as-a-master-user)。
- [创建主用户](#create-a-master-user)。

<a id="set-an-iam-arn-as-a-master-user"></a>

###### 将 IAM ARN 设置为主用户

如果您使用 IAM 主体作为主用户，则对集群的所有请求
都必须使用 AWS Signature Version 4 签名。
您还可以指定 IAM ARN，即您分配给 EC2 实例的 IAM 角色。有关更多信息，请参阅
[AWS 文档](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/fgac.html#fgac-master-user)。

先决条件：

- 管理员访问权限。

要将 IAM ARN 设置为主用户，您必须在极狐GitLab 实例上
使用带 IAM 凭证的 AWS OpenSearch Service：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**高级搜索**。
1. 在 **AWS OpenSearch IAM 凭证** 部分：
   1. 选中 **使用 IAM 凭证访问 AWS OpenSearch Service** 复选框。
   1. 在 **AWS 区域**中，输入您的 OpenSearch 域所在的 AWS 区域
      （例如 `us-east-1`）。
   1. 在 **AWS 访问密钥** 和 **AWS 秘密访问密钥**中，
      输入用于身份验证的访问密钥。

      > [!note]
      > 直接运行在 EC2 实例上（而非容器中）的极狐GitLab 部署
      > 无需输入访问密钥。
      > 您的极狐GitLab 实例会自动从
      > [AWS 实例元数据服务（IMDS）](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html)获取这些密钥。

1. 选择**保存更改**。

<a id="create-a-master-user"></a>

###### 创建主用户

如果您在内部用户数据库中创建主用户，则可以使用 HTTP 基本身份验证向集群发起请求。有关更多信息，请参阅
[AWS 文档](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/fgac.html#fgac-master-user)。

先决条件：

- 管理员访问权限。

要创建主用户，您必须在极狐GitLab 实例上配置 OpenSearch 域 URL
以及主用户名和密码：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**高级搜索**。
1. 在 **OpenSearch 域 URL**中，输入 OpenSearch 域端点的 URL。
1. 在 **用户名**中，输入主用户名。
1. 在 **密码**中，输入主密码。
1. 选择**保存更改**。

<a id="upgrade-to-a-new-elasticsearch-version"></a>

### 升级到新的 Elasticsearch 版本

先决条件：

- [禁用高级搜索](#disable-search-with-advanced-search)，
  以免搜索因 `HTTP 500` 错误而失败。
- [暂停索引](#pause-indexing)，以便仍能跟踪更改。

当您将 Elasticsearch 升级到新的次要或主要版本时，无需更改极狐GitLab 配置。当 Elasticsearch 集群完全升级并处于活动状态时：

1. 验证集群连接、索引和搜索操作：

   ```shell
   sudo gitlab-rake gitlab:elastic:index_and_search_validation
   ```

1. [恢复索引](#resume-indexing)。
1. 可选。[检查索引状态](#check-indexing-status)。
   为确保搜索结果正确，请确保索引已完成，尤其是
   如果您的 Elasticsearch 实例已离线一段时间。
1. [启用高级搜索](#enable-search-with-advanced-search)。

<a id="elasticsearch-repository-indexer"></a>

## Elasticsearch 代码仓库索引器

为了索引 Git 代码仓库数据，极狐GitLab 使用 [`gitlab-elasticsearch-indexer`](https://gitlab.com/gitlab-org/gitlab-elasticsearch-indexer)。对于自行编译的安装，请参阅[安装索引器](#install-the-indexer)。

<a id="install-the-indexer"></a>

### 安装索引器

您需要先安装一些依赖项，然后构建并安装索引器本身。

<a id="install-dependencies"></a>

#### 安装依赖项

此项目依赖 [International Components for Unicode](https://icu.unicode.org/)（ICU）进行文本编码，
因此请确保在运行 `make` 之前已安装适用于您平台的开发包。

<a id="debian--ubuntu"></a>

##### Debian / Ubuntu

要在 Debian 或 Ubuntu 上安装，请运行：

```shell
sudo apt install libicu-dev
```

<a id="centos--rhel"></a>

##### CentOS / RHEL

要在 CentOS 或 RHEL 上安装，请运行：

```shell
sudo yum install libicu-devel
```

<a id="macos"></a>

##### macOS

> [!note]
> 您必须先[安装 Homebrew](https://brew.sh/)。

要在 macOS 上安装，请运行：

```shell
brew install icu4c
export PKG_CONFIG_PATH="/usr/local/opt/icu4c/lib/pkgconfig:$PKG_CONFIG_PATH"
```

<a id="build-and-install"></a>

#### 构建并安装

要构建并安装索引器，请运行：

```shell
indexer_path=/home/git/gitlab-elasticsearch-indexer

# Run the installation task for gitlab-elasticsearch-indexer:
sudo -u git -H bundle exec rake gitlab:indexer:install[$indexer_path] RAILS_ENV=production
cd $indexer_path && sudo make install
```

`gitlab-elasticsearch-indexer` 会安装到 `/usr/local/bin`。

您可以使用 `PREFIX` 环境变量更改安装路径。如果这样做，请记得向 `sudo` 传递 `-E` 标志。

示例：

```shell
PREFIX=/usr sudo -E make install
```

安装后，请务必[启用 Elasticsearch](#enable-advanced-search)。

> [!note]
> 如果在索引时看到类似 `Permission denied - /home/git/gitlab-elasticsearch-indexer/` 的错误，
> 您可能需要将 `gitlab.yml` 文件中的 `production -> elasticsearch -> indexer_path` 设置
> 设为 `/usr/local/bin/gitlab-elasticsearch-indexer`，即二进制文件的安装位置。

<a id="view-indexing-errors"></a>

### 查看索引错误

来自 [GitLab Elasticsearch Indexer](https://gitlab.com/gitlab-org/gitlab-elasticsearch-indexer)的错误会报告在
[`elasticsearch.log`](../../administration/logs/_index.md#elasticsearchlog) 文件和 [`sidekiq.log`](../../administration/logs/_index.md#sidekiqlog) 文件中，其 `json.exception.class` 为 `Gitlab::Elastic::Indexer::Error`。这些错误可能在索引 Git 代码仓库数据时发生。

<a id="enable-advanced-search"></a>

## 启用高级搜索

先决条件：

- 您必须具有实例的管理员访问权限。
- 配置[每个索引的分片数](#number-of-elasticsearch-shards)。
- 配置[每个索引的副本数](#number-of-elasticsearch-replicas)。
- 可选。为[索引大型实例](#index-large-instances-efficiently)做好准备。

要启用高级搜索：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 为您的 Elasticsearch 集群配置[高级搜索设置](#advanced-search-configuration)。
   暂时不要选中 **使用高级搜索进行搜索** 复选框。
1. [索引实例](#index-the-instance)。
1. 可选。[检查索引状态](#check-indexing-status)。
1. 索引完成后，选中 **使用高级搜索进行搜索** 复选框，然后选择**保存更改**。

> [!note]
> 当 Elasticsearch 已启用但您的 Elasticsearch 集群不可用时，
> 您可能会在更新议题等文档时遇到问题，因为您的
> 实例会将索引更改的作业排队，但找不到有效的
> Elasticsearch 集群。

对于代码仓库数据超过 50 GB 的极狐GitLab 实例，请参阅[高效索引大型实例](#index-large-instances-efficiently)。

<a id="index-the-instance"></a>

### 索引实例

<a id="from-the-user-interface"></a>

#### 从用户界面

先决条件：

- 您必须具有实例的管理员访问权限。

您可以从用户界面执行初始索引或重新创建索引。

要从用户界面启用高级搜索并索引实例：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 选中 **为高级搜索开启索引** 复选框，然后选择**保存更改**。
1. 选择 **为实例建立索引**。

<a id="with-a-rake-task"></a>

#### 使用 Rake 任务

先决条件：

- 您必须具有实例的管理员访问权限。

要索引整个实例，请使用以下 Rake 任务：

```shell
# WARNING: This task deletes all existing indices
# For installations that use the Linux package
sudo gitlab-rake gitlab:elastic:index

# WARNING: This task deletes all existing indices
# For self-compiled installations
bundle exec rake gitlab:elastic:index RAILS_ENV=production
```

要索引特定数据，请使用以下 Rake 任务：

```shell
# For installations that use the Linux package
sudo gitlab-rake gitlab:elastic:index_work_items
sudo gitlab-rake gitlab:elastic:index_group_wikis
sudo gitlab-rake gitlab:elastic:index_namespaces
sudo gitlab-rake gitlab:elastic:index_projects
sudo gitlab-rake gitlab:elastic:index_snippets
sudo gitlab-rake gitlab:elastic:index_users

# For self-compiled installations
bundle exec rake gitlab:elastic:index_work_items RAILS_ENV=production
bundle exec rake gitlab:elastic:index_group_wikis RAILS_ENV=production
bundle exec rake gitlab:elastic:index_namespaces RAILS_ENV=production
bundle exec rake gitlab:elastic:index_projects RAILS_ENV=production
bundle exec rake gitlab:elastic:index_snippets RAILS_ENV=production
bundle exec rake gitlab:elastic:index_users RAILS_ENV=production
```

<a id="check-indexing-status"></a>

### 检查索引状态

先决条件：

- 您必须具有实例的管理员访问权限。

要检查索引状态：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开 **高级搜索索引状态**。

<a id="monitor-the-status-of-background-jobs"></a>

#### 监控后台作业的状态

先决条件：

- 您必须具有实例的管理员访问权限。

要监控索引进度，您还可以检查后台作业的状态：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**监控** > **后台作业**。
1. 在 Sidekiq 仪表板上，选择 **忙碌** 并留意以下索引作业：
   - `Search::Elastic::CommitIndexerWorker` 用于代码和提交。
   - `ElasticWikiIndexerWorker` 用于 Wiki 数据。

<a id="enable-search-with-advanced-search"></a>

### 启用高级搜索

先决条件：

- 您必须具有实例的管理员访问权限。

要在极狐GitLab 中启用高级搜索：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 选中 **使用高级搜索进行搜索** 复选框。
1. 选择**保存更改**。

<a id="enable-code-search-with-advanced-search"></a>

### 启用高级代码搜索

先决条件：

- 您必须具有实例的管理员访问权限。

要在极狐GitLab 中启用高级代码搜索：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 选中 **使用高级搜索进行代码搜索** 复选框。
1. 选择**保存更改**。

<a id="advanced-search-configuration"></a>

### 高级搜索配置

以下 Elasticsearch 设置可用：

| 参数                                                   | 描述 |
|-------------------------------------------------------------|-------------|
| **为高级搜索开启索引**                    | 打开或关闭索引，并在索引尚不存在时创建一个空索引。例如，您可能希望打开索引但关闭搜索，以便让索引有时间完全完成。另外请记住，此选项对现有数据没有任何影响。它仅启用/禁用后台索引器，该索引器跟踪数据更改并确保新数据被索引。 |
| **暂停高级搜索索引**                      | 暂停高级搜索索引。这对于集群迁移/重新索引很有用。所有更改仍会被跟踪，但在恢复之前不会提交到索引。 |
| **使用高级搜索进行搜索**                             | 打开或关闭搜索中的高级搜索功能以及[高级漏洞管理](../../user/application_security/vulnerability_report/_index.md#advanced-vulnerability-management)。 |
| **使用高级搜索进行代码搜索**                        | 打开或关闭高级代码搜索。关闭此设置后，所有代码都会从您的 Elasticsearch 实例中删除。要重新打开此设置，请完全重新索引您的代码。如果启用了精确代码搜索，您应关闭此设置以节省资源。 |
| **将索引工作进程重新加入队列**                                | 打开索引工作进程的自动重新排队。这通过将 Sidekiq 作业排队直到所有文档处理完毕，来提高非代码索引吞吐量。对于较小的实例或 Sidekiq 进程较少的实例，不建议重新排队索引工作进程。 |
| **URL**                                                     | 您的 Elasticsearch 实例的 URL。使用逗号分隔的列表以支持集群（例如 `http://host1, https://host2:9200`）。如果您的 Elasticsearch 实例受密码保护，请使用 `Username` 和 `Password` 字段。或者，使用内联凭证，例如 `http://<username>:<password>@<elastic_host>:9200/`。如果您使用 [OpenSearch](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/vpc.html)，则仅接受通过端口 `80` 和 `443`的连接。 |
| **用户名**                                                | 您的 Elasticsearch 实例的 `username`。 |
| **密码**                                                | 您的 Elasticsearch 实例的密码。 |
| **每个索引的 Elasticsearch 分片数和副本数**   | 出于性能原因，Elasticsearch 索引会拆分为多个分片。通常，您应至少使用五个分片。包含数千万文档的索引应具有更多分片（[请参阅指南](#guidance-on-choosing-optimal-cluster-configuration)）。对此值的更改在您重新创建索引之前不会生效。有关可扩展性和弹性的更多信息，请参阅 [Elasticsearch 文档](https://www.elastic.co/docs/deploy-manage/production-guidance/elasticsearch-in-production-environments)。每个 Elasticsearch 分片可以有多个副本。这些副本是分片的完整副本，可以提供更高的查询性能或抵御硬件故障的能力。增加此值会增加索引所需的总磁盘空间。您可以为每个索引设置分片数和副本数。 |
| **限制要索引的命名空间和项目数据量** | 启用此设置后，您可以指定要索引的命名空间和项目。所有其他命名空间和项目使用数据库搜索。如果您启用此设置但未指定任何命名空间或项目，则仅索引项目记录。有关更多信息，请参阅[限制要索引的命名空间和项目数据量](#limit-the-amount-of-namespace-and-project-data-to-index)。 |
| **使用 IAM 凭证访问 AWS OpenSearch Service**         | 使用 [AWS IAM 授权](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)、[AWS EC2 实例配置文件凭证](https://docs.aws.amazon.com/codedeploy/latest/userguide/getting-started-create-iam-instance-profile.html#getting-started-create-iam-instance-profile-cli)或 [AWS ECS 任务凭证](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html)对您的 OpenSearch 请求进行签名。有关 AWS 托管的 OpenSearch 域访问策略配置的详细信息，请参阅 [Amazon OpenSearch Service 中的身份和访问管理](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/ac.html)。 |
| **AWS 区域**                                              | 您的 OpenSearch Service 所在的 AWS 区域。 |
| **AWS 访问密钥**                                          | AWS 访问密钥。 |
| **AWS 秘密访问密钥**                                   | AWS 秘密访问密钥。 |
| **最大索引文件大小**                               | 请参阅[实例限制中的说明。](../../administration/instance_limits.md#maximum-file-size-indexed)。 |
| **最大字段长度**                                    | 请参阅[实例限制中的说明。](../../administration/instance_limits.md#maximum-field-length)。 |
| **索引超时时间（分钟）**                              | 每个项目的索引超时时间（分钟）。 |
| **非代码索引分片数**                  | 索引工作进程分片数。这通过将更多并行 Sidekiq 作业排队来提高非代码索引吞吐量。对于较小的实例或 Sidekiq 进程较少的实例，不建议增加分片数。默认值为 `2`。 |
| **最大批量请求大小（MiB）**                         | 由极狐GitLab Ruby 和基于 Go 的索引器进程使用。此设置指示在将负载提交到 Elasticsearch Bulk API 之前，给定索引进程中必须收集（并存储在内存中）多少数据。对于基于 Go 的极狐GitLab 索引器，您应将此设置与 **批量请求并发数** 一起使用。**最大批量请求大小（MiB）** 必须同时满足 Elasticsearch 主机以及通过 `gitlab-rake` 命令或 Sidekiq 任务运行基于 Go 的极狐GitLab 索引器的主机的资源约束。 |
| **批量请求并发数**                                | 批量请求并发数指示可以并行运行多少个基于 Go 的极狐GitLab 索引器进程（或线程）来收集数据，以便随后提交到 Elasticsearch Bulk API。这会提高索引性能，但会更快地填满 Elasticsearch 批量请求队列。此设置应与 **最大批量请求大小（MiB）** 设置一起使用，并且需要同时满足 Elasticsearch 主机以及通过 `gitlab-rake` 命令或 Sidekiq 任务运行基于 Go 的极狐GitLab 索引器的主机的资源约束。 |
| **客户端请求超时时间**                                  | Elasticsearch HTTP 客户端请求超时值（秒）。值为 `0` 时使用默认超时 30 秒。超过此限制的搜索请求会返回 `HTTP 408`，而不是在应用服务器终止请求后以 `500` 失败。如果您的 Elasticsearch 查询经常超过 30 秒，请设置更高的值。应用服务器会在 60 秒时终止请求，因此不要设置高于 `60`的值。如需更长的超时时间，您应设置介于 `30` 和 `55` 之间的值。 |
| **代码索引并发数**                               | 允许并发运行的 Elasticsearch 代码索引后台作业的最大数量。这仅适用于代码仓库索引操作。 |
| **失败时重试**                                        | Elasticsearch 搜索请求可能的最大重试次数。在极狐GitLab 17.6 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/486935)。 |
| **索引前缀**                                            | Elasticsearch 索引名称的自定义前缀。默认为 `gitlab`。更改后，所有索引都将使用此前缀而不是 `gitlab`（例如，使用 `custom-production-issues` 而不是 `gitlab-production-issues`）。必须为 1-100 个字符，仅包含小写字母数字字符、连字符和下划线，且不能以连字符或下划线开头或结尾。在极狐GitLab 18.2 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/3421)。 |

> [!warning]
> 增加 **最大批量请求大小（MiB）** 和 **批量请求并发数**的值可能会对
> Sidekiq 性能产生负面影响。如果您在 Sidekiq 日志中看到 `scheduling_latency_s` 持续时间增加，
> 请将它们恢复为默认值。有关更多信息，请参阅
> [议题 322147](https://gitlab.com/gitlab-org/gitlab/-/issues/322147)。

<a id="limit-the-amount-of-namespace-and-project-data-to-index"></a>

### 限制要索引的命名空间和项目数据量

> [!flag]
> 此功能的可用性由功能标志控制。

当您选中 **限制要索引的命名空间和项目数据量** 复选框时，
您可以指定要索引的命名空间和项目。如果命名空间是群组，则其所有子群组及这些子群组中的项目也会被索引。

当您启用此设置时：

- 必须指定命名空间或项目才能进行完整索引。
- 所有项目的项目记录（如项目名称和描述等元数据）始终会被索引。
- 所有项目和命名空间的漏洞记录始终会被索引，
  以支持安全报告中的筛选。
- [关联数据](#advanced-search-index-scopes)仅针对您指定的命名空间和项目进行索引。

> [!warning]
> 如果您在启用此设置后未指定任何命名空间或项目，
> 则仅索引项目记录，且无法搜索任何关联数据。

<a id="indexed-namespaces"></a>

#### 已索引的命名空间

当您索引所有命名空间时，您可以使用高级搜索进行全局代码和提交搜索。当您仅索引部分命名空间时：

- 全局搜索不包含代码或提交搜索范围。
- 代码和提交搜索仅在单个已索引的命名空间中可用。
- 无法跨多个已索引的命名空间进行单个代码或提交搜索。
- 跨项目搜索在已索引的命名空间中可用。

例如，如果您索引两个单独的群组，则必须分别对每个群组运行单独的代码搜索。

要为受限索引启用全局搜索：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**高级搜索**。
1. 选择 **为受限索引启用全局搜索**。
1. 选择**保存更改**。
1. 如果您已经索引了实例，则必须[重新索引实例](#index-the-instance)。
   这会删除现有搜索数据，以使筛选正常工作。

<a id="enable-custom-language-analyzers"></a>

## 启用自定义语言分析器

先决条件：

- 您必须具有实例的管理员访问权限。

您可以使用 Elastic 的 [`smartcn`](https://www.elastic.co/docs/reference/elasticsearch/plugins/analysis-smartcn)
和 [`kuromoji`](https://www.elastic.co/docs/reference/elasticsearch/plugins/analysis-kuromoji) 分析插件，来改进对中文和日文的语言支持。

要启用自定义语言分析器：

1. 安装所需的插件。有关插件安装说明，请参阅 [Elasticsearch 文档](https://www.elastic.co/guide/en/elasticsearch/plugins/7.9/installation.html)。插件必须安装在集群中的每个节点上，并且安装后必须重启每个节点。有关插件列表，请参阅本节后面的表格。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 找到 **自定义分析器：语言支持**。
1. 为 **索引** 启用插件支持。
1. 选择**保存更改**以使更改生效。
1. 触发[零停机重新索引](#zero-downtime-reindexing)或从头重新索引所有内容，以使用更新的映射创建新索引。
1. 上一步完成后，为 **搜索** 启用插件支持。

有关应安装哪些插件的指导，请参阅以下 Elasticsearch 语言插件选项：

| 参数                                             | 描述 |
|-------------------------------------------------------|-------------|
| `Enable Chinese (smartcn) custom analyzer: Indexing`   | 为新建索引启用或禁用使用 [`smartcn`](https://www.elastic.co/docs/reference/elasticsearch/plugins/analysis-smartcn) 自定义分析器的中文语言支持。 |
| `Enable Chinese (smartcn) custom analyzer: Search`   | 启用或禁用将 [`smartcn`](https://www.elastic.co/docs/reference/elasticsearch/plugins/analysis-smartcn) 字段用于高级搜索。仅在安装插件、启用自定义分析器索引并重新创建索引后才启用此项。 |
| `Enable Japanese (kuromoji) custom analyzer: Search`  | 启用或禁用将 [`kuromoji`](https://www.elastic.co/docs/reference/elasticsearch/plugins/analysis-kuromoji) 字段用于高级搜索。仅在安装插件、启用自定义分析器索引并重新创建索引后才启用此项。 |

<a id="disable-advanced-search"></a>

## 禁用高级搜索

先决条件：

- 您必须具有实例的管理员访问权限。

要在极狐GitLab 中禁用高级搜索：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 清除 **为高级搜索开启索引** 和 **使用高级搜索进行搜索** 复选框。
1. 选择**保存更改**。
1. 可选。对于仍处于在线状态的 Elasticsearch 实例，删除现有索引：

   ```shell
   # For installations that use the Linux package
   sudo gitlab-rake gitlab:elastic:delete_index

   # For self-compiled installations
   bundle exec rake gitlab:elastic:delete_index RAILS_ENV=production
   ```

<a id="disable-search-with-advanced-search"></a>

### 禁用高级搜索

先决条件：

- 您必须具有实例的管理员访问权限。

要在极狐GitLab 中禁用高级搜索：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 清除 **使用高级搜索进行搜索** 复选框。
1. 选择**保存更改**。

<a id="disable-code-search-with-advanced-search"></a>

### 禁用高级代码搜索

先决条件：

- 您必须具有实例的管理员访问权限。

要在极狐GitLab 中禁用高级代码搜索：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 清除 **使用高级搜索进行代码搜索** 复选框。
1. 选择**保存更改**。

<a id="pause-indexing"></a>

## 暂停索引

先决条件：

- 您必须具有实例的管理员访问权限。

要暂停索引：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**高级搜索**。
1. 选中 **暂停高级搜索索引** 复选框。
1. 选择**保存更改**。

<a id="resume-indexing"></a>

## 恢复索引

先决条件：

- 您必须具有实例的管理员访问权限。

要恢复索引：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**高级搜索**。
1. 清除 **暂停高级搜索索引** 复选框。
1. 选择**保存更改**。

<a id="zero-downtime-reindexing"></a>

## 零停机重新索引

此重新索引方法背后的思路是使用
[Elasticsearch 重新索引 API](https://www.elastic.co/docs/api/doc/elasticsearch/operation/operation-reindex)
和 Elasticsearch 索引别名功能来执行操作。索引别名连接到极狐GitLab 用于读取和写入的 `primary` 索引。当重新索引过程开始时，对 `primary` 索引的写入会暂时暂停。然后，创建另一个索引并调用 Reindex API 将索引数据迁移到新索引。重新索引作业完成后，索引别名切换到新索引，该索引成为新的 `primary` 索引。最后，写入恢复，正常操作继续。

<a id="using-zero-downtime-reindexing"></a>

### 使用零停机重新索引

您可以使用零停机重新索引来配置那些不创建新索引并复制现有数据就无法更改的索引设置或映射。您不应使用零停机重新索引来修复缺失的数据。如果数据尚未被索引，零停机重新索引不会将数据添加到搜索集群。在开始重新索引之前，您必须完成所有[高级搜索迁移](#advanced-search-migrations)。

<a id="trigger-reindexing"></a>

### 触发重新索引

先决条件：

- 您必须具有实例的管理员访问权限。

要触发重新索引：

1. 以管理员身份登录您的极狐GitLab 实例。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开 **高级搜索零停机重新索引**。
1. 选择 **触发集群重新索引**。

根据 Elasticsearch 集群的大小，重新索引可能是一个漫长的过程。

此过程完成后，原始索引计划在 14 天后删除。您可以在触发重新索引过程的同一页面上按 **取消** 按钮来取消此操作。

重新索引运行期间，您可以在同一部分下跟踪其进度。

<a id="trigger-zero-downtime-reindexing"></a>

#### 触发零停机重新索引

先决条件：

- 您必须具有实例的管理员访问权限。

要触发零停机重新索引：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开 **高级搜索零停机重新索引**。
   以下设置可用：

   - [切片乘数](#slice-multiplier)
   - [最大运行切片数](#maximum-running-slices)

<a id="slice-multiplier"></a>

##### 切片乘数

切片乘数计算[重新索引期间的切片数](https://www.elastic.co/docs/reference/elasticsearch/rest-apis/reindex-indices#docs-reindex-slice)。

极狐GitLab 使用[手动切片](https://www.elastic.co/docs/reference/elasticsearch/rest-apis/reindex-indices#docs-reindex-manual-slice)来高效、安全地控制重新索引，这使用户能够仅重试失败的切片。

该乘数默认为 `2`，并应用于每个索引的分片数。例如，如果此值为 `2` 且您的索引有 20 个分片，则重新索引任务会拆分为 40 个切片。

<a id="maximum-running-slices"></a>

##### 最大运行切片数

最大运行切片数参数默认为 `60`，对应于 Elasticsearch 重新索引期间允许并发运行的最大切片数。

将此值设置得太高可能会对性能产生不利影响，因为您的集群可能会因搜索和写入而严重饱和。将此值设置得太低可能会导致重新索引过程需要很长时间才能完成。

最佳值取决于您的集群大小、您是否愿意在重新索引期间接受一定程度的搜索性能下降，以及重新索引快速完成并恢复索引有多重要。

<a id="mark-the-most-recent-reindexing-job-as-failed-and-resume-indexing"></a>

### 将最近的重新索引作业标记为失败并恢复索引

先决条件：

- 您必须具有实例的管理员访问权限。

要放弃未完成的重新索引作业并恢复索引：

1. 将最近的重新索引作业标记为失败：

   ```shell
   # For installations that use the Linux package
   sudo gitlab-rake gitlab:elastic:mark_reindex_failed

   # For self-compiled installations
   bundle exec rake gitlab:elastic:mark_reindex_failed RAILS_ENV=production
   ```

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**高级搜索**。
1. 清除 **暂停高级搜索索引** 复选框。

<a id="index-integrity"></a>

## 索引完整性

索引完整性可检测并修复缺失的代码仓库数据。当限定到群组或项目的代码搜索返回无结果时，会自动使用此功能。

<a id="advanced-search-migrations"></a>

## 高级搜索迁移

重新索引迁移在后台运行，这意味着您无需手动重新索引实例。

[在 GitLab 18.0 及更高版本中](https://gitlab.com/gitlab-org/gitlab/-/issues/352424)，您可以使用 `elastic_migration_worker_enabled` 应用设置来启用或禁用迁移工作进程。默认情况下，迁移工作进程处于启用状态。

<a id="migration-dictionary-files"></a>

### 迁移字典文件

每个迁移在 `ee/elastic/docs/` 文件夹中都有一个对应的字典文件，其中包含以下信息：

```yaml
name:
version:
description:
group:
milestone:
introduced_by_url:
obsolete:
marked_obsolete_by_url:
marked_obsolete_in_milestone:
```

例如，您可以使用此信息来识别迁移是何时引入或被标记为过时的。

<a id="check-for-pending-migrations"></a>

### 检查待处理的迁移

要检查待处理的高级搜索迁移，请运行以下命令：

```shell
curl "$CLUSTER_URL/gitlab-production-migrations/_search?size=100&q=*" | jq .
```

这应返回类似以下内容：

```json
{
  "took": 14,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 1,
      "relation": "eq"
    },
    "max_score": 1,
    "hits": [
      {
        "_index": "gitlab-production-migrations",
        "_type": "_doc",
        "_id": "20230209195404",
        "_score": 1,
        "_source": {
          "completed": true
        }
      }
    ]
  }
}
```

要调试迁移问题，请检查 [`elasticsearch.log`](../../administration/logs/_index.md#elasticsearchlog) 文件。

<a id="retry-a-halted-migration"></a>

### 重试已停止的迁移

某些迁移设置了重试限制。如果迁移无法在重试限制内完成，它会被停止，并在高级搜索集成设置中显示通知。

建议检查 [`elasticsearch.log` 文件](../../administration/logs/_index.md#elasticsearchlog)，以调试迁移被停止的原因，并在重试迁移之前进行任何更改。

当您认为已修复失败原因时：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**高级搜索**。
1. 在 **高级搜索迁移已停止** 警告框中，选择 **重试迁移**。该迁移计划在后台重试。

如果您无法使迁移成功，您可以考虑[从头重新创建索引的最后手段](../elasticsearch/troubleshooting/indexing.md#last-resort-to-recreate-an-index)。这可能使您跳过该问题，因为新创建的索引会跳过所有迁移，因为索引是使用正确的最新架构重新创建的。

<a id="all-migrations-must-be-finished-before-doing-a-major-upgrade"></a>

### 在进行主要升级之前必须完成所有迁移

在升级到主要极狐GitLab 版本之前，您必须完成该主要版本之前最新次要版本为止存在的所有迁移。您还必须解决并[重试任何已停止的迁移](#retry-a-halted-migration)，然后再进行主要版本升级。有关更多信息，请参阅[升级迁移](../../update/background_migrations.md)。

已移除的迁移会[标记为过时](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/63001)。如果您在所有待处理的高级搜索迁移完成之前升级极狐GitLab，则新版本中已移除的任何待处理迁移都无法执行或重试。在这种情况下，您必须[从头重新创建索引](../elasticsearch/troubleshooting/indexing.md#last-resort-to-recreate-an-index)。

`gitlab:check` Rake 任务包含一个名为 `All migrations must be finished before doing a major upgrade`的检查。当高级搜索索引打开时，如果没有待处理的迁移，该检查会报告 `yes`。当有迁移待处理时，该检查会报告 `no` 以及待处理迁移的数量。当索引关闭时，该检查会被跳过。

该检查：

- 仅报告状态。
- 不会停止、暂停或回滚升级。
- 仅在您运行 `gitlab:check` 或 `gitlab:app:check` Rake 任务时运行。

即使该检查报告 `no`，Rake 任务也会以状态 `0` 退出，因此您无法使用退出代码来限制升级。

待处理迁移计数包括尚未开始、正在进行或已停止的迁移，但不包括[可跳过的迁移](#skippable-migrations)。该检查和 `gitlab:elastic:list_pending_migrations` Rake 任务都不会识别哪些待处理迁移已停止。`gitlab:elastic:info` Rake 任务会报告当前迁移是否已停止，但它仅报告当前迁移。您可以尝试[识别并重试已停止的迁移](#retry-a-halted-migration)。

如果某个迁移一直处于待处理状态，且 `gitlab:elastic:list_pending_migrations` 将其标记为 `[Obsolete]`，则您必须重新创建索引，而不是等待迁移完成。

<a id="skippable-migrations"></a>

### 可跳过的迁移

可跳过的迁移仅在满足条件时执行。例如，如果某个迁移依赖于特定版本的 Elasticsearch，则在该版本达到之前可以跳过它。

如果可跳过的迁移在迁移被标记为过时之前未执行，则要应用更改，您必须[重新创建索引](../elasticsearch/troubleshooting/indexing.md#last-resort-to-recreate-an-index)。

<a id="gitlab-advanced-search-rake-tasks"></a>

## 极狐GitLab 高级搜索 Rake 任务

Rake 任务可用于：

- [构建并安装](#build-and-install)索引器。
- 在[禁用 Elasticsearch](#disable-advanced-search) 时删除索引。
- 将极狐GitLab 数据添加到索引。

以下是一些可用的 Rake 任务：

| 任务                                                                                                                                                       | 描述 |
|:-----------------------------------------------------------------------------------------------------------------------------------------------------------|:------------|
| [`sudo gitlab-rake gitlab:elastic:info`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)                              | 输出高级搜索集成的调试信息。 |
| [`sudo gitlab-rake gitlab:elastic:index`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)                             | 在极狐GitLab 17.0 及更早版本中，打开高级搜索索引并运行 `gitlab:elastic:recreate_index`、`gitlab:elastic:clear_index_status`、`gitlab:elastic:index_group_entities`、`gitlab:elastic:index_projects`、`gitlab:elastic:index_snippets` 和 `gitlab:elastic:index_users`。<br>在极狐GitLab 17.1 及更高版本中，在后台将 Sidekiq 作业排队。首先，该作业打开高级搜索索引并暂停索引，以确保创建所有索引。然后，该作业重新创建所有索引、清除索引状态，并将其他 Sidekiq 作业排队以索引项目和群组数据、代码片段和用户。最后，恢复高级搜索索引以完成。[在极狐GitLab 17.1 中引入](https://gitlab.com/gitlab-org/gitlab/-/issues/421298)，[带有功能标志](../../administration/feature_flags/_index.md) `elastic_index_use_trigger_indexing`。默认启用。在极狐GitLab 17.3 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/issues/434580)。功能标志 `elastic_index_use_trigger_indexing` 已移除。 |
| [`sudo gitlab-rake gitlab:elastic:pause_indexing`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)                    | 暂停高级搜索索引。更改仍会被跟踪。对于集群/索引迁移很有用。 |
| [`sudo gitlab-rake gitlab:elastic:resume_indexing`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)                   | 恢复高级搜索索引。 |
| [`sudo gitlab-rake gitlab:elastic:index_and_search_validation`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)       | 验证所有索引的集群连接、索引和搜索操作。在极狐GitLab 18.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/200664)。 |
| [`sudo gitlab-rake gitlab:elastic:index_projects`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)                    | 遍历所有项目，并将 Sidekiq 作业排队以在后台索引它们。只能在创建索引后使用。 |
| [`sudo gitlab-rake gitlab:elastic:index_group_entities`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)              | 调用 `gitlab:elastic:index_work_items` 和 `gitlab:elastic:index_group_wikis`，并索引群组里程碑。 |
| [`sudo gitlab-rake gitlab:elastic:index_work_items`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)                  | 索引启用了 Elasticsearch 的群组中的所有工作项。 |
| [`sudo gitlab-rake gitlab:elastic:index_namespaces`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)                  | 索引所有根命名空间。 |
| [`sudo gitlab-rake gitlab:elastic:index_group_wikis`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)                 | 索引启用了 Elasticsearch 的群组中的所有 Wiki。 |
| [`sudo gitlab-rake gitlab:elastic:index_snippets`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)                    | 执行 Elasticsearch 导入，以索引代码片段数据。 |
| [`sudo gitlab-rake gitlab:elastic:index_users`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)                       | 将所有用户导入 Elasticsearch。 |
| [`sudo gitlab-rake gitlab:elastic:index_vulnerabilities`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)             | 索引所有漏洞。 |
| [`sudo gitlab-rake gitlab:elastic:index_sbom_occurrence_refs`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)        | 索引所有 SBOM 出现引用。 |
| [`sudo gitlab-rake gitlab:elastic:index_projects_status`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)             | 确定所有项目代码仓库数据（代码、提交和 Wiki）的总体索引状态。状态通过将已索引项目数除以项目总数再乘以 100 计算得出。此任务不包括议题、合并请求或里程碑等非代码仓库数据。 |
| [`sudo gitlab-rake gitlab:elastic:index_groups_status`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)               | 确定所有群组代码仓库数据（群组 Wiki）的总体索引状态。状态通过将已索引群组数除以群组总数再乘以 100 计算得出。此任务不包括史诗、合并请求或里程碑等非代码仓库数据。 |
| [`sudo gitlab-rake gitlab:elastic:clear_index_status`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)                | 删除所有项目的所有 IndexStatus 实例。此命令会导致索引被完全清除，应谨慎使用。 |
| [`sudo gitlab-rake gitlab:elastic:create_empty_index`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)                | 生成空索引（默认索引和单独的议题索引），并仅在 Elasticsearch 端为每个索引分配别名（如果尚不存在）。 |
| [`sudo gitlab-rake gitlab:elastic:delete_index`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)                      | 删除 Elasticsearch 实例上的极狐GitLab 索引和别名（如果存在）。 |
| [`sudo gitlab-rake gitlab:elastic:recreate_index`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)                    | `gitlab:elastic:delete_index` 和 `gitlab:elastic:create_empty_index`的包装任务。不会将任何索引作业排队。 |
| [`sudo gitlab-rake gitlab:elastic:projects_not_indexed`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)              | 显示哪些项目未索引代码仓库数据。此任务不包括议题、合并请求或里程碑等非代码仓库数据。 |
| [`sudo gitlab-rake gitlab:elastic:groups_not_indexed`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)                | 显示哪些群组未索引代码仓库数据。此任务不包括议题、合并请求或里程碑等非代码仓库数据。 |
| [`sudo gitlab-rake gitlab:elastic:reindex_cluster`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)                   | 计划零停机集群重新索引任务。 |
| [`sudo gitlab-rake gitlab:elastic:mark_reindex_failed`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)               | 将最近的重新索引作业标记为失败。 |
| [`sudo gitlab-rake gitlab:elastic:list_pending_migrations`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)           | 列出待处理的迁移。待处理的迁移包括尚未开始、已开始但未完成以及已停止的迁移。 |
| [`sudo gitlab-rake gitlab:elastic:estimate_cluster_size`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)             | 根据代码仓库总大小，获取代码和 Wiki 索引大小以及集群总大小的估算值。 |
| [`sudo gitlab-rake gitlab:elastic:estimate_shard_sizes`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)              | 根据大致的数据库计数，获取每个索引的分片大小估算值。此估算不包括代码仓库数据（代码、提交和 Wiki）。 |
| [`sudo gitlab-rake gitlab:elastic:enable_search_with_elasticsearch`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake)  | 启用 Elasticsearch 高级搜索。 |
| [`sudo gitlab-rake gitlab:elastic:disable_search_with_elasticsearch`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/tasks/gitlab/elastic.rake) | 禁用 Elasticsearch 高级搜索。 |

<a id="environment-variables"></a>

### 环境变量

除 Rake 任务外，还有一些环境变量可用于修改该过程：

| 环境变量 | 数据类型 | 作用                                                                 |
| -------------------- |:---------:| ---------------------------------------------------------------------------- |
| `ID_TO`              | 整数   | 告诉索引器仅索引小于或等于该值的项目。    |
| `ID_FROM`            | 整数   | 告诉索引器仅索引大于或等于该值的项目。 |

<a id="indexing-a-range-of-projects-or-a-specific-project"></a>

### 索引一定范围的项目或特定项目

使用 `ID_FROM` 和 `ID_TO` 环境变量，您可以索引有限数量的项目。这对于分阶段索引很有用。

```shell
root@git:~# sudo gitlab-rake gitlab:elastic:index_projects ID_FROM=1 ID_TO=100
```

由于 `ID_FROM` 和 `ID_TO` 使用 `or equal to` 比较，您可以将两者设置为相同的项目 ID，从而仅索引一个项目：

```shell
root@git:~# sudo gitlab-rake gitlab:elastic:index_projects ID_FROM=5 ID_TO=5
Indexing project repositories...I, [2019-03-04T21:27:03.083410 #3384]  INFO -- : Indexing GitLab User / test (ID=33)...
I, [2019-03-04T21:27:05.215266 #3384]  INFO -- : Indexing GitLab User / test (ID=33) is done!
```

<a id="advanced-search-index-scopes"></a>

## 高级搜索索引范围

执行搜索时，极狐GitLab 索引使用以下范围：

| 范围名称       | 搜索内容       |
|------------------|------------------------|
| `commits`        | 提交数据            |
| `projects`       | 项目数据（默认） |
| `groups`         | 群组数据             |
| `blobs`          | 代码                   |
| `work_items`     | 工作项数据         |
| `merge_requests` | 合并请求数据     |
| `milestones`     | 里程碑数据     |
| `notes`          | 评论数据              |
| `snippets`       | 代码片段数据           |
| `wiki_blobs`     | Wiki 内容          |
| `users`          | 用户                  |

在 JihuLab.com 上，所有项目和命名空间的漏洞记录始终会被索引，以支持搜索之外的功能。在极狐GitLab 私有化部署上索引漏洞记录已在[议题 525484](https://gitlab.com/gitlab-org/gitlab/-/issues/525484)中提出。

<a id="tuning"></a>

## 调优

<a id="guidance-on-choosing-optimal-cluster-configuration"></a>

### 选择最优集群配置的指导

有关选择集群配置的基本指导，另请参阅 [Elastic Cloud 计算器](https://cloud.elastic.co/pricing)。

- 通常，您至少需要使用带一个副本的 2 节点集群配置，这样可以获得弹性。如果您的存储使用量增长迅速，您可能需要提前规划横向扩展（添加更多节点）。
- 不建议在搜索集群中使用 HDD 存储，因为它会影响性能。最好使用 SSD 存储（例如 NVMe 或 SATA SSD 驱动器）。
- 您不应将[仅协调节点](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html#coordinating-only-node)与大型实例一起使用。仅协调节点比[数据节点](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html#data-node)小，这可能会影响性能和[高级搜索迁移](#advanced-search-migrations)。
- 您可以使用 [GitLab Performance Tool](https://gitlab.com/gitlab-org/quality/performance) 对不同搜索集群规模和配置下的搜索性能进行基准测试。
- `Heap size` 应设置为不超过物理 RAM 的 50%。此外，它不应超过基于零的压缩 oops 的阈值。确切阈值因系统而异，但在大多数系统上 26 GB 是安全的，在某些系统上也可以高达 30 GB。有关更多详细信息，请参阅[堆大小设置](https://www.elastic.co/docs/deploy-manage/deploy/self-managed/important-settings-configuration#heap-size-settings)和[设置 JVM 选项](https://www.elastic.co/docs/reference/elasticsearch/jvm-settings)。
- `refresh_interval` 是每个索引的设置。如果您不需要实时数据，您可能希望将其从默认值 `1s` 调整为更大的值。这会改变您看到最新结果的速度。如果这对您很重要，您应将其保持尽可能接近默认值。
- 如果您有大量繁重的索引操作，您可能希望将 [`indices.memory.index_buffer_size`](https://www.elastic.co/docs/reference/elasticsearch/configuration-reference/indexing-buffer-settings) 提高到 30% 或 40%。

<a id="advanced-search-settings"></a>

### 高级搜索设置

<a id="number-of-elasticsearch-shards"></a>

#### Elasticsearch 分片数量

对于单节点集群，将每个索引的 Elasticsearch 分片数量设置为
Elasticsearch 数据节点上的 CPU 核心数。

对于多节点集群，运行 Rake 任务 `gitlab:elastic:estimate_shard_sizes` 以确定每个索引的分片数量。该任务会返回分片和副本大小的建议，以及包含数据库数据的索引的大致文档数量。

将平均分片大小保持在几 GB 到 30 GB 之间。如果平均分片大小增长到超过 30 GB，请增加该索引的分片大小并触发[零停机重新索引](#zero-downtime-reindexing)。为确保集群健康，每个节点的分片数量不得超过所配置堆大小的 20 倍。例如，堆大小为 30 GB 的节点最多只能有 600 个分片。

要更新索引的分片数量，请更改该设置并触发[零停机重新索引](#zero-downtime-reindexing)。

<a id="number-of-elasticsearch-replicas"></a>

#### Elasticsearch 副本数量

对于单节点集群，将每个索引的 Elasticsearch 副本数量设置为 `0`。

对于多节点集群，将每个索引的 Elasticsearch 副本数量设置为 `1`（每个分片有一个副本）。该数量不得为 `0`，因为丢失一个节点会损坏索引。

如果启用了[分片分配感知](https://www.elastic.co/docs/deploy-manage/distributed-architecture/shard-allocation-relocation-recovery/shard-allocation-awareness)，则每个分片的副本总数必须能被感知属性数量（通常是节点或可用区）整除。分片副本在所有感知属性之间的均匀分布可确保最佳的容错能力和负载分布。

```plaintext
(1 + `number_of_replicas`) / `number_of_awareness_attributes` = whole number
```

要更新索引的副本数量，请更改该设置并触发[零停机重新索引](#zero-downtime-reindexing)。

<a id="index-large-instances-efficiently"></a>

### 高效地为大型实例建立索引

先决条件：

- 您必须拥有该实例的管理员访问权限。

> [!warning]
> 为大型实例建立索引会生成大量 Sidekiq 作业。
> 请务必通过[可扩展的部署方案](../../administration/reference_architectures/_index.md)或创建
> [额外的 Sidekiq 进程](../../administration/sidekiq/extra_sidekiq_processes.md)来为此任务做好准备。
>
> Geo 主站点和从站点节点都指向同一个 Elasticsearch 集群。
> 但是，Elasticsearch 索引工作进程仅在主站点的 Sidekiq 节点上运行。
>
> 因此，您必须在主站点的 Sidekiq 节点上配置任何[额外的 Sidekiq 进程](../../administration/sidekiq/extra_sidekiq_processes.md)。

如果[启用高级搜索](#enable-advanced-search)由于要索引大量数据而导致问题：

1. [配置您的 Elasticsearch 主机和端口](#enable-advanced-search)。
1. 创建空索引：

   ```shell
   # For installations that use the Linux package
   sudo gitlab-rake gitlab:elastic:create_empty_index

   # For self-compiled installations
   bundle exec rake gitlab:elastic:create_empty_index RAILS_ENV=production
   ```

1. 如果这是对您的极狐GitLab 实例进行重新索引，请清除索引状态：

   ```shell
   # For installations that use the Linux package
   sudo gitlab-rake gitlab:elastic:clear_index_status

   # For self-compiled installations
   bundle exec rake gitlab:elastic:clear_index_status RAILS_ENV=production
   ```

1. [选中**为高级搜索开启索引**复选框](#enable-advanced-search)。
1. 为大型 Git 代码仓库建立索引可能需要一段时间。为加快该过程，您可以[针对索引速度进行调优](https://www.elastic.co/guide/en/elasticsearch/reference/current/tune-for-indexing-speed.html#tune-for-indexing-speed)：

   - 您可以临时增大 [`refresh_interval`](https://www.elastic.co/docs/api/doc/elasticsearch/operation/operation-indices-refresh)。

   - 您可以将副本数量设置为 0。此设置控制索引的每个主分片拥有的副本数量。因此，将副本数设为 0 实际上会禁用分片在节点之间的复制，这应能提高索引性能。这是在可靠性和查询性能方面的重要权衡。重要的是，在初始索引完成后，记得将副本数设置为一个经过考量的值。

   您可以预期索引时间减少 20%。索引完成后，您可以将 `refresh_interval` 和 `number_of_replicas` 设置回所需的值。

   > [!note]
   > 此步骤是可选的，但可能有助于显著加快大型索引操作。

   ```shell
   curl --request PUT localhost:9200/gitlab-production/_settings --header 'Content-Type: application/json' \
        --data '{
          "index" : {
              "refresh_interval" : "30s",
              "number_of_replicas" : 0
          } }'
   ```

1. 为项目及其关联数据建立索引：

   ```shell
   # For installations that use the Linux package
   sudo gitlab-rake gitlab:elastic:index_projects

   # For self-compiled installations
   bundle exec rake gitlab:elastic:index_projects RAILS_ENV=production
   ```

   这会为每个需要建立索引的项目排入一个 Sidekiq 作业。
   您可以使用 Rake 任务查询索引状态：

   ```shell
   # For installations that use the Linux package
   sudo gitlab-rake gitlab:elastic:index_projects_status

   # For self-compiled installations
   bundle exec rake gitlab:elastic:index_projects_status RAILS_ENV=production

   Indexing is 65.55% complete (6555/10000 projects). Considers only code, commits, and wikis.
   ```

   如果您想将索引限制在某个项目范围内，可以提供
   `ID_FROM` 和 `ID_TO` 参数：

   ```shell
   # For installations that use the Linux package
   sudo gitlab-rake gitlab:elastic:index_projects ID_FROM=1001 ID_TO=2000

   # For self-compiled installations
   bundle exec rake gitlab:elastic:index_projects ID_FROM=1001 ID_TO=2000 RAILS_ENV=production
   ```

   其中 `ID_FROM` 和 `ID_TO` 是项目 ID。这两个参数都是可选的。
   前面的示例会为从 ID `1001` 到（含）ID `2000`的所有项目建立索引。

   > [!note]
   > 有时由 `gitlab:elastic:index_projects` 排入的项目索引作业
   > 可能会被中断。这可能由多种原因导致，但重新运行
   > 索引任务始终是安全的。

   您还可以使用 `gitlab:elastic:clear_index_status` Rake 任务强制
   索引器“忘记”所有进度，从而从头开始重试索引过程。
1. 工作项、群组 Wiki、个人代码片段和用户不与项目关联，必须单独建立索引：

   ```shell
   # For installations that use the Linux package
   sudo gitlab-rake gitlab:elastic:index_work_items
   sudo gitlab-rake gitlab:elastic:index_group_wikis
   sudo gitlab-rake gitlab:elastic:index_snippets
   sudo gitlab-rake gitlab:elastic:index_users

   # For self-compiled installations
   bundle exec rake gitlab:elastic:index_work_items RAILS_ENV=production
   bundle exec rake gitlab:elastic:index_group_wikis RAILS_ENV=production
   bundle exec rake gitlab:elastic:index_snippets RAILS_ENV=production
   bundle exec rake gitlab:elastic:index_users RAILS_ENV=production
   ```

1. 在索引完成后再次启用复制和刷新（仅当您之前增大了 `refresh_interval` 时）：

   ```shell
   curl --request PUT localhost:9200/gitlab-production/_settings --header 'Content-Type: application/json' \
        --data '{
          "index" : {
              "number_of_replicas" : 1,
              "refresh_interval" : "1s"
          } }'
   ```

   在启用刷新后应调用强制合并。

   对于 Elasticsearch 6.x 及更高版本，在进行强制合并之前，请确保索引处于只读模式：

   ```shell
   curl --request PUT localhost:9200/gitlab-production/_settings --header 'Content-Type: application/json' \
        --data '{
          "settings": {
            "index.blocks.write": true
          } }'
   ```

   然后，启动强制合并：

   ```shell
   curl --request POST 'localhost:9200/gitlab-production/_forcemerge?max_num_segments=5'
   ```

   然后，将索引改回读写模式：

   ```shell
   curl --request PUT localhost:9200/gitlab-production/_settings --header 'Content-Type: application/json' \
        --data '{
          "settings": {
            "index.blocks.write": false
          } }'
   ```

1. 索引完成后，[选中**使用高级搜索进行搜索**复选框](#enable-advanced-search)。

<a id="index-large-instances-with-dedicated-sidekiq-nodes-or-processes"></a>

### 使用专用 Sidekiq 节点或进程为大型实例建立索引

> [!warning]
> 对于大多数实例，您不必配置专用的 Sidekiq 节点或进程。
> 以下步骤使用了 Sidekiq 的一项高级设置，
> 称为[路由规则](../../administration/sidekiq/processing_specific_job_classes.md#routing-rules)。
> 请务必充分了解使用路由规则的影响，以避免作业完全丢失。

为大型实例建立索引可能是一个漫长且资源密集的过程，有可能使 Sidekiq 节点和进程不堪重负。这会对极狐GitLab 的性能和可用性产生负面影响。

由于极狐GitLab 允许您启动多个 Sidekiq 进程，您可以创建一个专用于为一组队列（或队列组）建立索引的额外进程。这样，您就可以确保索引队列始终有专用的工作进程，而其余队列有另一个专用工作进程以避免争用。

为此，请使用[路由规则](../../administration/sidekiq/processing_specific_job_classes.md#routing-rules)选项，它允许 Sidekiq 根据[工作进程匹配查询](../../administration/sidekiq/processing_specific_job_classes.md#worker-matching-query)将作业路由到特定队列。

> [!note]
> 路由规则（`sidekiq['routing_rules']`）在所有极狐GitLab 节点（尤其是 GitLab Rails 和 Sidekiq 节点）上必须相同。

您可以选择以下两种方式之一来处理此问题：

- [在单个节点上使用两个队列组](#single-node-two-processes)。
- [使用两个队列组，每个节点一个](#two-nodes-one-process-for-each)。

对于以下步骤，请考虑 `sidekiq['routing_rules']` 的条目：

- `["feature_category=global_search", "global_search"]`，因为所有索引作业都路由到 `global_search` 队列。
- `["*", "default"]`，因为所有其他非索引作业都路由到 `default` 队列。

`sidekiq['queue_groups']` 中至少有一个进程必须包含 `mailers` 队列。否则，邮件作业根本不会被处理。

> [!warning]
> 启动多个进程时，进程数量不能超过您想专用于 Sidekiq 的 CPU
> 核心数。每个 Sidekiq 进程只能使用一个 CPU 核心，具体取决于
> 可用工作负载和并发设置。有关更多详细信息，请参阅如何
> [运行多个 Sidekiq 进程](../../administration/sidekiq/extra_sidekiq_processes.md)。

<a id="single-node-two-processes"></a>

#### 单节点，两个进程

要在一个节点中同时创建索引和非索引 Sidekiq 进程：

1. 在您的 Sidekiq 节点上，将 `/etc/gitlab/gitlab.rb` 文件更改为：

   ```ruby
   sidekiq['enable'] = true

   sidekiq['routing_rules'] = [
      ["feature_category=global_search", "global_search"],
      ["*", "default"],
   ]

   sidekiq['queue_groups'] = [
      "global_search", # process that listens to global_search queue
      "default,mailers" # process that listens to default and mailers queue
   ]

   sidekiq['concurrency'] = 20
   ```

1. 保存文件并[重新配置极狐GitLab](../../administration/restart_gitlab.md)
   以使更改生效。
1. 在所有其他 Rails 和 Sidekiq 节点上，确保 `sidekiq['routing_rules']` 与之前的配置相同。
1. 运行 Rake 任务以[迁移现有作业](../../administration/sidekiq/sidekiq_job_migration.md)：

> [!note]
> 在重新配置极狐GitLab 后立即运行 Rake 任务非常重要。
> 重新配置极狐GitLab 后，在 Rake 任务开始迁移作业之前，现有作业不会被处理。

<a id="two-nodes-one-process-for-each"></a>

#### 两个节点，每个节点一个进程

要在两个节点上处理这些队列组：

1. 要设置索引 Sidekiq 进程，请在您的索引 Sidekiq 节点上，将 `/etc/gitlab/gitlab.rb` 文件更改为：

   ```ruby
   sidekiq['enable'] = true

   sidekiq['routing_rules'] = [
      ["feature_category=global_search", "global_search"],
      ["*", "default"],
   ]

   sidekiq['queue_groups'] = [
     "global_search", # process that listens to global_search queue
   ]

   sidekiq['concurrency'] = 20
   ```

1. 保存文件并[重新配置极狐GitLab](../../administration/restart_gitlab.md)
   以使更改生效。
1. 要设置非索引 Sidekiq 进程，请在您的非索引 Sidekiq 节点上，将 `/etc/gitlab/gitlab.rb` 文件更改为：

   ```ruby
   sidekiq['enable'] = true

   sidekiq['routing_rules'] = [
      ["feature_category=global_search", "global_search"],
      ["*", "default"],
   ]

   sidekiq['queue_groups'] = [
      "default,mailers" # process that listens to default and mailers queue
   ]

   sidekiq['concurrency'] = 20
   ```

1. 在所有其他 Rails 和 Sidekiq 节点上，确保 `sidekiq['routing_rules']` 与之前的配置相同。
1. 保存文件并[重新配置极狐GitLab](../../administration/restart_gitlab.md)
   以使更改生效。
1. 运行 Rake 任务以[迁移现有作业](../../administration/sidekiq/sidekiq_job_migration.md)：

   ```shell
   sudo gitlab-rake gitlab:sidekiq:migrate_jobs:retry gitlab:sidekiq:migrate_jobs:schedule gitlab:sidekiq:migrate_jobs:queued
   ```

> [!note]
> 在重新配置极狐GitLab 后立即运行 Rake 任务非常重要。
> 重新配置极狐GitLab 后，在 Rake 任务开始迁移作业之前，现有作业不会被处理。

<a id="deleted-documents"></a>

### 已删除的文档

每当对已建立索引的极狐GitLab 对象进行更改或删除时，例如当合并请求描述被更改、文件从代码仓库的默认分支中删除，或项目被删除时，索引中的文档就会被删除。但是，由于这些是“软”删除，“已删除文档”的总数以及因此浪费的空间会增加。

Elasticsearch 会智能地合并段以移除这些已删除的文档。但是，根据您的极狐GitLab 安装中的活动数量和类型，索引中可能会出现多达 50% 的浪费空间。

您通常应让 Elasticsearch 使用默认设置自动合并和回收空间。根据 [Lucene 对已删除文档的处理](https://www.elastic.co/blog/lucenes-handling-of-deleted-documents "Lucene's Handling of Deleted Documents")，_"总体而言，除了可能减小最大段大小之外，最好保持 Lucene 默认值不变，不必过于担心何时回收删除内容。"_

但是，一些较大的安装可能希望调整合并策略设置：

- 考虑将 `index.merge.policy.max_merged_segment` 大小从默认的 5 GB 减小到 2 GB 或 3 GB。仅当某个段至少有 50% 的删除内容时才会发生合并。较小的段大小允许更频繁地进行合并。

  ```shell
  curl --request PUT localhost:9200/gitlab-production/_settings ---header 'Content-Type: application/json' \
       --data '{
         "index" : {
           "merge.policy.max_merged_segment": "2gb"
         }
       }'
  ```

- 您还可以调整 `index.merge.policy.reclaim_deletes_weight`，它控制针对删除内容的积极程度。但这可能导致代价高昂的合并决策，因此除非您了解其中的权衡，否则不应更改此项。

  ```shell
  curl --request PUT localhost:9200/gitlab-production/_settings ---header 'Content-Type: application/json' \
       --data '{
         "index" : {
           "merge.policy.reclaim_deletes_weight": "3.0"
         }
       }'
  ```

- 不要执行[强制合并](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-forcemerge.html "Force Merge")来移除已删除的文档。[文档](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-forcemerge.html "Force Merge")中的一条警告指出，这可能导致非常大的段可能永远无法被回收，还可能造成严重的性能或可用性问题。

<a id="reverting-to-basic-search"></a>

## 还原为基础搜索

有时您的 Elasticsearch 索引数据可能会出现问题，因此当没有搜索结果时，极狐GitLab 允许您还原为“基础搜索”，前提是该范围支持基础搜索。此“基础搜索”的行为就像您的实例根本没有启用高级搜索一样，并使用其他数据源（例如 PostgreSQL 数据和 Git 数据）进行搜索。

<a id="disaster-recovery"></a>

## 灾难恢复

Elasticsearch 是极狐GitLab 的辅助数据存储。
存储在 Elasticsearch 中的所有数据都可以再次
从其他数据源（特别是 PostgreSQL 和 Gitaly）派生。
如果 Elasticsearch 数据存储损坏，
您可以从头重新索引所有内容。

如果您的 Elasticsearch 索引太大，从头重新索引所有内容可能会导致过多的停机时间。您无法自动发现差异并重新同步 Elasticsearch 索引，但您可以检查日志以查找任何缺失的更新。要更快地恢复数据，您可以重放：

1. 所有已同步的非代码仓库更新，方法是在
   [`elasticsearch.log`](../../administration/logs/_index.md#elasticsearchlog)
   中搜索 [`track_items`](https://gitlab.com/gitlab-org/gitlab/-/blob/1e60ea99bd8110a97d8fc481e2f41cab14e63d31/ee/app/services/elastic/process_bookkeeping_service.rb#L25)。
   您必须通过
   `::Elastic::ProcessBookkeepingService.track!` 再次发送这些条目。
1. 所有代码仓库更新，方法是在
   [`elasticsearch.log`](../../administration/logs/_index.md#elasticsearchlog)
   中搜索 [`indexing_commit_range`](https://gitlab.com/gitlab-org/gitlab/-/blob/6f9d75dd3898536b9ec2fb206e0bd677ab59bd6d/ee/lib/gitlab/elastic/indexer.rb#L41)。
   您必须将 [`IndexStatus#last_commit/last_wiki_commit`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/app/models/index_status.rb)
   设置为日志中最旧的 `from_sha`，然后使用 [`Search::Elastic::CommitIndexerWorker`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/app/workers/search/elastic/commit_indexer_worker.rb) 和 [`ElasticWikiIndexerWorker`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/app/workers/elastic_wiki_indexer_worker.rb) 触发该项目的另一次索引。
1. 所有项目删除，方法是在
   [`sidekiq.log`](../../administration/logs/_index.md#sidekiqlog)中搜索
   [`ElasticDeleteProjectWorker`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/app/workers/elastic_delete_project_worker.rb)。
   您必须再次触发 `ElasticDeleteProjectWorker`。

您还可以定期创建 [Elasticsearch 快照](https://www.elastic.co/docs/deploy-manage/tools/snapshot-and-restore)，以减少从数据丢失中恢复所需的时间，而无需从头重新索引所有内容。
