---
stage: AI Platform
group: AI Core Infra
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在极狐GitLab 私有化部署实例上管理并配置语义代码搜索。
title: 语义代码搜索管理
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise
- Offering: 私有化部署
- Status: 测试版

{{< /details >}}

> [!note]
> 有关用户文档，请参阅[语义代码搜索](../user/gitlab_duo/semantic_code_search.md)。

借助语义代码搜索，AI 原生的极狐GitLab Duo 功能可以在您的代码仓库中查找相关的代码片段。

<a id="prerequisites"></a>

## 先决条件

- 可访问[极狐GitLab AI 网关](gitlab_duo/gateway.md)或[极狐GitLab Duo 自部署版本](gitlab_duo_self_hosted/_index.md)。
- 已[为实例](../user/duo_agent_platform/turn_on_off.md#on-gitlab-self-managed-2)开启测试版和实验性功能。
- [已配置向量存储](#vector-storage)：
  - Elasticsearch 8.0 及更高版本。
  - OpenSearch 2.0 及更高版本。
  - 带有 [`pgvector`](https://github.com/pgvector/pgvector) 扩展的 PostgreSQL。
- 对于极狐GitLab Duo 自部署版本，[已配置嵌入模型](#configure-an-embedding-model)。

<a id="vector-storage"></a>

## 向量存储

对于中大型代码仓库，您应使用 Elasticsearch 或 OpenSearch。
仅在包含少量小型代码仓库的环境中才使用带有 `pgvector` 的 PostgreSQL。使用 `pgvector` 时，索引和查询性能可能会受到限制。

<a id="connect-to-the-advanced-search-cluster"></a>

### 连接到高级搜索集群

如果您的极狐GitLab 实例使用 Elasticsearch 或 OpenSearch 进行[高级搜索](../user/search/advanced_search.md)，
您可以通过连接到同一集群来开启语义代码搜索：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**语义搜索**。
1. 对于**向量存储**，选择**配置**。
1. 在**向量存储**页面的**高级搜索集群**下，选择**连接**。

<a id="configure-a-custom-vector-store"></a>

### 配置自定义向量存储

要配置自定义向量存储连接：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**语义搜索**。
1. 对于**向量存储**，选择**配置**。
1. 从**搜索适配器**下拉列表中，选择
   **Elasticsearch**、**OpenSearch** 或 **PostgreSQL**。
1. 填写适配器的字段。
1. 选择**保存更改**。

<a id="elasticsearch"></a>

#### Elasticsearch

| 设置      | 描述 |
|--------------|-------------|
| **URL**      | Elasticsearch 集群的 URL 列表，以逗号分隔（例如 `http://localhost:9200, http://localhost:9201`）。 |
| **用户名** | 受密码保护的 Elasticsearch 服务器的用户名。 |
| **密码** | 受密码保护的 Elasticsearch 服务器的密码。 |

<a id="opensearch"></a>

#### OpenSearch

| 设置      | 描述 |
|--------------|-------------|
| **URL**      | OpenSearch 集群的 URL 列表，以逗号分隔（例如 `http://localhost:9200, http://localhost:9201`）。 |
| **用户名** | 受密码保护的 OpenSearch 服务器的用户名。 |
| **密码** | 受密码保护的 OpenSearch 服务器的密码。 |

要使用 AWS OpenSearch Service，请选择**使用带 IAM 凭证的 AWS OpenSearch Service**
并填写以下字段：

| 设置                   | 描述 |
|---------------------------|-------------|
| **AWS 区域**            | 您的 OpenSearch 域所在的 AWS 区域。 |
| **AWS 访问密钥**        | AWS 访问密钥 ID。仅当您未使用角色实例凭证时才需要。 |
| **AWS 秘密访问密钥** | AWS 秘密访问密钥。仅当您未使用角色实例凭证时才需要。 |
| **AWS 角色 ARN**          | 跨账户 `AssumeRole` 授权的 AWS IAM 角色 ARN。 |

<a id="postgresql-with-pgvector"></a>

#### 带有 `pgvector` 的 PostgreSQL

先决条件：

- 在您的 PostgreSQL 数据库中启用 [`pgvector`](https://github.com/pgvector/pgvector) 扩展：

  ```sql
  CREATE EXTENSION vector;
  ```

| 设置      | 描述 |
|--------------|-------------|
| **主机**     | PostgreSQL 服务器的主机名。 |
| **端口**     | PostgreSQL 服务器的端口。默认为 `5432`。 |
| **数据库** | PostgreSQL 数据库的名称。 |
| **用户名** | PostgreSQL 用户名。 |
| **密码** | PostgreSQL 密码。 |

<a id="configure-an-embedding-model"></a>

## 配置嵌入模型

要配置嵌入模型：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**语义搜索**。
1. 对于**代码嵌入**，选择**设置模型**。
   如果您已配置嵌入模型，则会改为显示**更改模型**。
1. 在**语义搜索代码嵌入**页面中，
   选择嵌入模型、嵌入维度、
   嵌入请求的批大小以及分块策略。
1. 选择**设置嵌入**。如果您已配置嵌入模型，
   则会改为显示**更新嵌入并启动回填过程**。

> [!warning]
> 当您更改嵌入模型或维度时，会运行回填，
> 根据代码库大小，这可能需要数小时。
> 在此过程中，语义搜索仍可使用。

<a id="embedding-models"></a>

### 嵌入模型

<a id="gitlab-managed-models"></a>

#### 极狐GitLab 管理的模型

先决条件：

- 可同时访问[极狐GitLab AI 网关](gitlab_duo/gateway.md)和[极狐GitLab Duo 自部署版本](gitlab_duo_self_hosted/_index.md)。

极狐GitLab 管理的模型在[极狐GitLab AI 网关](gitlab_duo/gateway.md)上提供。极狐GitLab AI 网关为语义代码搜索提供 `qwen3_7_text_embedding` 嵌入模型。

有关在[极狐GitLab Duo 自部署版本](gitlab_duo_self_hosted/_index.md)环境中使用极狐GitLab 管理的模型的更多信息，请参阅[混合 AI 网关和模型配置](gitlab_duo_self_hosted/_index.md#hybrid-ai-gateway-and-model-configuration)。

> [!warning]
> 当您使用极狐GitLab 管理的模型时，极狐GitLab 会限制用于索引的嵌入请求。
> 要避免这些速率限制，请配置[自部署模型](#self-hosted-models)。
>
> 如果极狐GitLab 弃用您选择的模型，您必须自行切换到其他模型。

<a id="self-hosted-models"></a>

#### 自部署模型

先决条件：

- 可访问[极狐GitLab Duo 自部署版本](gitlab_duo_self_hosted/_index.md)。
- [已开启自部署测试版模型和功能](gitlab_duo_self_hosted/configure_duo_features.md#turn-on-self-hosted-beta-models-and-features)。

自部署模型是[托管在您自己的基础设施上](gitlab_duo_self_hosted/_index.md)的 AI 模型。

要选择自部署模型：

1. 设置[极狐GitLab Duo 自部署版本](gitlab_duo_self_hosted/_index.md)。
1. [添加自部署模型](gitlab_duo_self_hosted/configure_duo_features.md#add-a-self-hosted-model)，并选择[嵌入模型系列](gitlab_duo_self_hosted/configure_duo_features.md#embedding-model)。

<a id="batch-size-for-embedding-requests"></a>

### 嵌入请求的批大小

嵌入请求的批大小表示每个批量嵌入请求的输入数量。请将此值保持在所选嵌入模型的批量 API 限制范围内。如果留空，则使用嵌入模型的默认批大小。如果嵌入模型没有默认批大小，则改用回退值 30。

<a id="update-batch-size"></a>

#### 更新批大小

要在不更改嵌入模型的情况下更新批大小：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **搜索**。
1. 展开**语义搜索**。
1. 对于**代码嵌入**，选择**更改模型**。
1. 在**语义搜索代码嵌入**页面中，
   转到**更新嵌入请求的批大小**部分。
1. 输入新值：
   - 对于没有正在运行回填的活动嵌入模型，
     更新当前模型的批大小。
   - 对于正在运行回填的新嵌入模型，
     更新下一个模型的批大小。
1. 选择**更新批大小**。

<a id="chunking-strategy"></a>

### 分块策略

分块策略是用于将代码文件拆分为更小片段以进行嵌入的算法。请选择以下策略之一：

- 代码字节：
  将代码拆分为固定大小的字节块，不考虑代码结构或语义。
  块大小指每个块的最大字节数。
  在以下情况下使用此策略：
  - 更快的索引速度和更可预测的块大小。
  - 包含多种文件类型和语言的代码仓库。
- 代码 pre-BERT：
  使用针对基于 BERT 的嵌入模型优化的语义边界来拆分代码。
  块大小指每个块的最大令牌数。
  在以下情况下使用此策略：
  - 更好的搜索质量和更符合代码结构的有意义块。
  - 结构良好的代码仓库。

> [!warning]
> 只有在首次配置嵌入模型时，您才能选择分块策略。
> 要在索引开始后更改分块策略，您必须完全重新索引实例。
> 自动重新索引的支持已在[议题 600200](https://gitlab.com/gitlab-org/gitlab/-/work_items/600200) 和[议题 602138](https://gitlab.com/gitlab-org/gitlab/-/work_items/602138)中提出。

<a id="check-semantic-code-search-status"></a>

## 检查语义代码搜索状态

要检查语义代码搜索的状态，包括索引状态、向量存储连接详情、代码仓库统计信息和嵌入队列大小，请运行以下 Rake 任务：

```shell
sudo gitlab-rake gitlab:semantic_search:code:info
```

要持续监控状态，请提供以秒为单位的监视间隔：

```shell
sudo gitlab-rake "gitlab:semantic_search:code:info[5]"
```

此任务会按指定间隔刷新输出。要停止该任务，请按 <kbd>Control</kbd>+<kbd>C</kbd>。

<a id="manage-the-dead-queue"></a>

## 管理死信队列

先决条件：

- 具有 `admin_mode`、`ai_features` 和 `api` 范围的个人访问令牌。

当嵌入生成失败时，条目会经过一系列重试队列，延迟逐渐增加（5 分钟、30 分钟、2 小时和 8 小时）。所有重试均失败的条目会被移入死信队列，等待人工干预。因速率限制错误而失败的条目不会遵循此链条。它们会返回第一个重试队列，并每 5 分钟重试一次，直到速率限制解除。它们永远不会进入死信队列。您可以在[状态 Rake 任务](#check-semantic-code-search-status)输出的 `Embedding Queues` 部分中查看死信队列大小。

<a id="clear-the-dead-queue"></a>

### 清空死信队列

要从死信队列中删除所有条目，请运行以下命令：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_token>" \
  "https://gitlab.example.com/api/v4/admin/active_context/dead_queue"
```

<a id="replay-the-dead-queue"></a>

### 重放死信队列

要将死信队列中的条目移回处理队列以再次尝试，请使用 `queue` 参数指定目标。有效值为 `retry_queue`、`second_retry_queue`、`third_retry_queue`、`fourth_retry_queue`、`code` 和 `code_backfill`。

要让条目再次经过完整重试链，请使用 `retry_queue`：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_token>" \
  --data "queue=retry_queue" \
  "https://gitlab.example.com/api/v4/admin/active_context/dead_queue/replay"
```

要将条目添加到主代码队列，请使用 `code`：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_token>" \
  --data "queue=code" \
  "https://gitlab.example.com/api/v4/admin/active_context/dead_queue/replay"
```
