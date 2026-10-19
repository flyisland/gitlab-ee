---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: ClickHouse
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[ClickHouse](https://clickhouse.com) 是一个开源的列式数据库管理系统。它可以高效地筛选、聚合和查询大型数据集。

极狐GitLab 使用 ClickHouse 作为辅助数据存储，以支持极狐GitLab Duo、SDLC 趋势和 CI 分析等高级分析功能。极狐GitLab 仅在 ClickHouse 中存储支持这些功能所需的数据。

您应使用 [ClickHouse Cloud](https://clickhouse.com/cloud) 将 ClickHouse 连接到极狐GitLab。

或者，您也可以[自带 ClickHouse](https://clickhouse.com/docs/get-started/setup/install)。更多信息，请参阅 [ClickHouse 针对极狐GitLab 私有化部署的建议](https://clickhouse.com/docs/guides/oss/best-practices/sizing-and-hardware-recommendations)。

<a id="analytics-available-with-clickhouse"></a>

## 可通过 ClickHouse 使用的分析功能

配置 ClickHouse 后，您可以使用以下分析功能：

| 功能 | 描述 |
|----------------------|---------------------|
| [Runner 队列仪表板](../ci/runners/runner_fleet_dashboard.md#dashboard-metrics)  | 显示 Runner 使用指标和作业等待时间。提供 CSV 文件导出，其中包含每个项目按 Runner 类型和作业状态统计的作业数量和已执行的 Runner 分钟数。   |
| [贡献分析](../user/group/contribution_analytics/_index.md)  | 提供群组成员贡献（推送事件、议题、合并请求）随时间的分析。ClickHouse 可降低大型实例出现超时问题的可能性。 |
| [极狐GitLab Duo 和 SDLC 趋势](../user/analytics/duo_and_sdlc_trends.md)  | 衡量极狐GitLab Duo 对软件开发绩效的影响。跟踪开发指标（部署频率、前置时间、变更失败率、恢复时间）以及 AI 专属指标（极狐GitLab Duo 席位采用率、代码建议接受率和极狐GitLab Duo Chat 使用情况）。 |
| [AI 指标的 GraphQL API](../api/graphql/duo_and_sdlc_trends.md) | 通过 `AiMetrics`、`AiUserMetrics` 和 `AiUsageData` 端点以编程方式访问极狐GitLab Duo 和 SDLC 趋势数据。提供预聚合指标和原始事件数据的导出，以便与 BI 工具和自定义分析集成。 |

<a id="supported-clickhouse-versions"></a>

## 支持的 ClickHouse 版本

支持的 ClickHouse 版本因您的极狐GitLab 版本而异：

- 极狐GitLab 17.7 及更高版本支持 ClickHouse 23.x。要使用 ClickHouse 24.x 或 25.x，请使用[变通方法](#database-schema-migrations-on-gitlab-1800-and-earlier)。
- 极狐GitLab 18.1 及更高版本支持 ClickHouse 23.x、24.x 和 25.x。
- 极狐GitLab 18.8 及更高版本支持 ClickHouse 23.x、24.x、25.x 以及 Replicated 数据库引擎。
  - 较旧的集群需要额外权限（`dictGet`），请参阅[代码片段](#database-dictionary-read-support)。
- 极狐GitLab 19.0 及更高版本支持 ClickHouse 25.x 和 26.x（最高包括 26.6）。对 ClickHouse 23.x 和 24.x 的支持已移除。
  - 在极狐GitLab 19.3 和 19.4 中，迁移在某些 ClickHouse 25.x 版本（例如 25.3）上可能失败，
    并出现 `BAD_TTL_EXPRESSION` 错误。
    请升级到极狐GitLab 19.5 或更高版本。
    对于全新安装，您可以改用受支持的 ClickHouse 26.x 版本。
- 不支持 ClickHouse 26.7 及更高版本。有关临时变通方法，请参阅 [ClickHouse 26.7 及更高版本](#clickhouse-267-and-later)。

ClickHouse Cloud 始终与最新的稳定版极狐GitLab 版本兼容。

> [!warning]
> 某些 ClickHouse 版本引入了影响极狐GitLab 集成的向后不兼容变更：
>
> - ClickHouse 25.12 对 `ALTER MODIFY COLUMN` 引入了[向后不兼容变更](https://clickhouse.com/docs/whats-new/changelog#backward-incompatible-change)。这会破坏 18.8 之前版本的极狐GitLab ClickHouse 集成迁移过程。需要将极狐GitLab 升级到 18.8 及更高版本。
> - ClickHouse 26.7 为 `AggregatingMergeTree` 表添加了验证，而极狐GitLab 目前尚不满足该验证，因此迁移会失败并出现 `Code: 36`（`BAD_ARGUMENTS`）错误。有关临时变通方法，请参阅 [ClickHouse 26.7 及更高版本](#clickhouse-267-and-later)。

<a id="set-up-clickhouse"></a>

## 设置 ClickHouse

根据您的运维需求选择部署类型：

- **[ClickHouse Cloud](#set-up-clickhouse-cloud)**（推荐）：全托管服务，具有自动升级、备份和扩缩容能力。
- **[用于极狐GitLab 私有化部署的 ClickHouse（BYOC）](#set-up-clickhouse-for-gitlab-self-managed-byoc)**：完全掌控您的基础设施和配置。

设置 ClickHouse 实例后：

1. [创建极狐GitLab 数据库和用户](#create-database-and-user)。
1. [配置极狐GitLab 连接](#configure-the-gitlab-connection)。
1. [验证连接](#verify-the-connection)。
1. [运行 ClickHouse 迁移](#run-clickhouse-migrations)。
1. [为分析功能启用 ClickHouse](#enable-clickhouse-for-analytics)。

<a id="set-up-clickhouse-cloud"></a>

### 设置 ClickHouse Cloud

先决条件：

- 拥有 ClickHouse Cloud 账号。
- 启用从极狐GitLab 实例到 ClickHouse Cloud 的网络连接。
- 成为极狐GitLab 实例的管理员。

设置 ClickHouse Cloud：

1. 登录 [ClickHouse Cloud](https://clickhouse.cloud)。
1. 选择 **新建服务**。
1. 选择您的服务层级：
   - **Development**：用于测试和开发环境。
   - **Production**：用于具有高可用性的生产工作负载。
1. 选择您的云提供商和区域。为获得最佳性能，请选择靠近极狐GitLab 实例的区域。
1. 配置您的服务名称和设置。
1. 选择 **创建服务**。
1. 预配完成后，从服务仪表板记下您的连接详细信息：
   - 主机
   - 端口（极狐GitLab 使用的 HTTPS 连接为 `8443`，`clickhouse-client` 使用的带 TLS 的原生 TCP 为 `9440`）
   - 用户名
   - 密码

> [!note]
> ClickHouse Cloud 会自动处理版本升级和安全补丁。企业版客户可以安排升级时间，以控制升级发生的时间，并避免在工作时间出现意外的服务中断。更多信息，请参阅[升级 ClickHouse](#upgrade-clickhouse)。

创建 ClickHouse Cloud 服务后，您需要[创建极狐GitLab 数据库和用户](#create-database-and-user)。

<a id="set-up-clickhouse-for-gitlab-self-managed-byoc"></a>

### 为极狐GitLab 私有化部署设置 ClickHouse（BYOC）

先决条件：

- 已安装并运行 ClickHouse 实例。如果尚未安装 ClickHouse，请参阅：
  - [ClickHouse 官方安装指南](https://clickhouse.com/docs/get-started/setup/install)。
  - [ClickHouse 针对极狐GitLab 私有化部署的建议](https://clickhouse.com/docs/guides/oss/best-practices/sizing-and-hardware-recommendations)。
- 使用[受支持的 ClickHouse 版本](#supported-clickhouse-versions)。
- 启用从极狐GitLab 实例到 ClickHouse 的网络连接。
- 成为 ClickHouse 和极狐GitLab 实例的管理员。

> [!warning]
> 对于用于极狐GitLab 私有化部署的 ClickHouse，您需要负责规划和执行版本升级、安全补丁和备份。更多信息，请参阅[升级 ClickHouse](#upgrade-clickhouse)。

<a id="configure-high-availability"></a>

#### 配置高可用性

对于多节点高可用性（HA）设置，极狐GitLab 支持 ClickHouse 中的 Replicated 表引擎。

先决条件：

- 拥有包含多个节点的 ClickHouse 集群。建议至少三个节点。
- 在 `remote_servers` 配置节中定义集群。
- 在 ClickHouse 配置中配置以下宏：
  - `cluster`
  - `shard`
  - `replica`

为 HA 配置数据库时，必须使用 `ON CLUSTER` 子句运行语句。

更多信息，请参阅 [ClickHouse Replicated 数据库引擎文档](https://clickhouse.com/docs/reference/engines/database-engines/replicated)。

<a id="configure-load-balancer"></a>

#### 配置负载均衡器

极狐GitLab 应用程序通过 HTTP/HTTPS 接口与 ClickHouse 集群通信。对于 HA 部署，请使用 HTTP 代理或负载均衡器将请求分发到 ClickHouse 集群节点。

推荐的负载均衡器选项：

- [chproxy](https://www.chproxy.org/) - ClickHouse 专用的 HTTP 代理，内置缓存和路由功能。
- HAProxy - 通用 TCP/HTTP 负载均衡器。
- NGINX - 具有负载均衡能力的 Web 服务器。
- 云提供商负载均衡器（AWS Application Load Balancer、GCP Load Balancer、Azure Load Balancer）。

chproxy 基本配置示例：

```yaml
server:
  http:
    listen_addr: ":8080"

clusters:
  - name: "clickhouse_cluster"
    nodes: [
      "http://ch-node1:8123",
      "http://ch-node2:8123",
      "http://ch-node3:8123"
    ]

users:
  - name: "gitlab"
    password: "your_secure_password"
    to_cluster: "clickhouse_cluster"
    to_user: "gitlab"
```

使用负载均衡器时，请将极狐GitLab 配置为连接到负载均衡器 URL，而不是各个 ClickHouse 节点。

更多信息，请参阅 [chproxy 文档](https://www.chproxy.org/)。

配置好用于极狐GitLab 私有化部署的 ClickHouse 实例后，请[创建极狐GitLab 数据库和用户](#create-database-and-user)。

<a id="verify-clickhouse-installation"></a>

### 验证 ClickHouse 安装

在配置数据库之前，请验证 ClickHouse 已安装且可访问：

1. 检查 ClickHouse 是否正在运行：

   ```shell
   clickhouse-client --query "SELECT version()"
   ```

   如果 ClickHouse 正在运行，您会看到版本号（例如 `24.3.1.12`）。
1. 验证您能否使用凭据连接：

   ```shell
   clickhouse-client --host your-clickhouse-host --port 9440 --secure --user default --password 'your-password'
   ```

   > [!note]
   > 如果您尚未配置 TLS，请在初始测试时使用端口 `9000`，且不带 `--secure` 标志。

<a id="create-database-and-user"></a>

### 创建数据库和用户

创建必要的用户和数据库对象：

1. 生成一个安全密码并保存。
1. 登录到：
   - 对于 ClickHouse Cloud，登录 ClickHouse SQL 控制台。
   - 对于用于极狐GitLab 私有化部署的 ClickHouse，登录 `clickhouse-client`。
1. 运行以下命令，将 `PASSWORD_HERE` 替换为生成的密码。

{{< tabs >}}

{{< tab title="Single-node or ClickHouse Cloud" >}}

<!-- gitlab-clickhouse-grants:start -->
<!-- scripts/click_house/setup_ci_user.rb replays the SQL block between these markers against
     the CI ClickHouse service, so CI runs on the grants documented here. Keep one statement
     per line, keep them idempotent, and keep the database name as
     gitlab_clickhouse_main_production. -->

```sql
CREATE DATABASE IF NOT EXISTS gitlab_clickhouse_main_production;
CREATE USER IF NOT EXISTS gitlab IDENTIFIED WITH sha256_password BY 'PASSWORD_HERE';
CREATE ROLE IF NOT EXISTS gitlab_app;
GRANT SELECT, INSERT, ALTER, CREATE, UPDATE, DROP, TRUNCATE, OPTIMIZE, dictGet ON gitlab_clickhouse_main_production.* TO gitlab_app;
GRANT SELECT ON information_schema.* TO gitlab_app;
GRANT gitlab_app TO gitlab;
```

<!-- gitlab-clickhouse-grants:end -->

{{< /tab >}}

{{< tab title="HA ClickHouse for GitLab Self-Managed" >}}

将 `CLUSTER_NAME_HERE` 替换为您的集群名称：

```sql
CREATE DATABASE IF NOT EXISTS gitlab_clickhouse_main_production ON CLUSTER CLUSTER_NAME_HERE ENGINE = Replicated('/clickhouse/databases/{cluster}/gitlab_clickhouse_main_production', '{shard}', '{replica}');
CREATE USER IF NOT EXISTS gitlab IDENTIFIED WITH sha256_password BY 'PASSWORD_HERE' ON CLUSTER CLUSTER_NAME_HERE;
CREATE ROLE IF NOT EXISTS gitlab_app ON CLUSTER CLUSTER_NAME_HERE;
GRANT SELECT, INSERT, ALTER, CREATE, UPDATE, DROP, TRUNCATE, OPTIMIZE, dictGet ON gitlab_clickhouse_main_production.* TO gitlab_app ON CLUSTER CLUSTER_NAME_HERE;
GRANT SELECT ON information_schema.* TO gitlab_app ON CLUSTER CLUSTER_NAME_HERE;
GRANT gitlab_app TO gitlab ON CLUSTER CLUSTER_NAME_HERE;
```

{{< /tab >}}

{{< /tabs >}}

<a id="configure-the-gitlab-connection"></a>

### 配置极狐GitLab 连接

{{< tabs >}}

{{< tab title="Linux 软件包" >}}

为极狐GitLab 提供 ClickHouse 凭据：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['clickhouse_databases']['main']['database'] = 'gitlab_clickhouse_main_production'
   gitlab_rails['clickhouse_databases']['main']['url'] = 'https://your-clickhouse-host:port'
   gitlab_rails['clickhouse_databases']['main']['username'] = 'gitlab'
   gitlab_rails['clickhouse_databases']['main']['password'] = 'PASSWORD_HERE' # replace with the actual password
   ```

   将 URL 替换为：
   - 对于 ClickHouse Cloud：`https://your-service.clickhouse.cloud:8443`
   - 用于极狐GitLab 私有化部署的 ClickHouse：`https://your-clickhouse-host:8443`
   - 用于极狐GitLab 私有化部署的 ClickHouse HA 配合负载均衡器：`https://your-load-balancer:8080`（或您的负载均衡器 URL）

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

1. 将 ClickHouse 密码保存为 Kubernetes 密钥：

   ```shell
   kubectl create secret generic gitlab-clickhouse-password --namespace <namespace> --from-literal="main_password=PASSWORD_HERE"
   ```

1. 导出 Helm values：

   ```shell
   helm get values gitlab --namespace <namespace> > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     clickhouse:
       enabled: true
       main:
         username: gitlab
         password:
           secret: gitlab-clickhouse-password
           key: main_password
         database: gitlab_clickhouse_main_production
         url: 'https://your-clickhouse-host:port'
   ```

   将 URL 替换为：
   - 对于 ClickHouse Cloud：`https://your-service.clickhouse.cloud:8443`
   - 对于用于极狐GitLab 私有化部署的 ClickHouse 单节点：`https://your-clickhouse-host:8443`
   - 对于用于极狐GitLab 私有化部署的 ClickHouse HA 配合负载均衡器：`https://your-load-balancer:8080`（或您的负载均衡器 URL）

1. 可选。如果您的 ClickHouse 证书由私有证书颁发机构（CA）签名，则必须添加该 CA。
   如果不添加 CA，Helm 会报告升级已完成，但新 Pod 不会启动。
   `gitlab-migrations` 作业和 `dependencies` Init 容器会报告
   `certificate verify failed (unable to get local issuer certificate)`。

   1. 将 CA 证书存储在 Kubernetes 密钥中：

      ```shell
      kubectl create secret generic clickhouse-ca --namespace <namespace> --from-file=clickhouse-ca.crt=<path_to_ca_certificate>
      ```

   1. 将该密钥添加到 `gitlab_values.yaml`：

      ```yaml
      global:
        certificates:
          customCAs:
            - secret: clickhouse-ca
      ```

   更多信息，请参阅[自定义证书颁发机构](https://gitlab.cn/docs/charts/charts/globals/#custom-certificate-authorities)。

1. 保存文件并应用新 values：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab --namespace <namespace> --version <chart_version>
   ```

   将 `<chart_version>` 替换为已部署 chart 的版本。
   例如，如果 `helm list --namespace <namespace>` 的 `CHART` 列显示 `gitlab-10.4.1`，
   则使用 `10.4.1`。
   如果不指定 `--version`，Helm 会使用最新的 chart 版本，这也可能升级极狐GitLab。

{{< /tab >}}

{{< /tabs >}}

> [!note]
> 对于生产部署，请在 ClickHouse 实例上配置 TLS/SSL 并使用 `https://` URL。对于极狐GitLab 私有化部署安装，请参阅[网络安全](#network-security)文档。

<a id="verify-the-connection"></a>

### 验证连接

验证连接是否已成功设置：

1. 登录 [Rails 控制台](../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 执行以下命令：

   ```ruby
   ClickHouse::Client.select('SELECT 1', :main)
   ```

   如果成功，该命令会返回 `[{"1"=>1}]`。

如果连接失败，请验证：

- ClickHouse 服务正在运行且可访问。
- 从极狐GitLab 到 ClickHouse 的网络连接。检查防火墙和安全组是否允许连接。
- 连接 URL 是否正确（主机、端口、协议）。
- 凭据是否正确。
- 对于 HA 集群部署：负载均衡器是否已正确配置并路由请求。

<a id="run-clickhouse-migrations"></a>

### 运行 ClickHouse 迁移

> [!note]
> 此步骤是必需的。如果跳过，分析仪表板将不显示数据，并显示“Failed to fetch data”错误。

{{< tabs >}}

{{< tab title="Linux 软件包" >}}

创建所需的数据库对象，请执行：

```shell
sudo gitlab-rake gitlab:clickhouse:migrate
```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

迁移会通过 [GitLab-Migrations chart](https://gitlab.cn/docs/charts/charts/gitlab/migrations/) 自动执行。

或者，您也可以在 Toolbox Pod 中执行以下命令来运行迁移：

```shell
gitlab-rake gitlab:clickhouse:migrate
```

{{< /tab >}}

{{< /tabs >}}

<a id="enable-clickhouse-for-analytics"></a>

### 为分析功能启用 ClickHouse

极狐GitLab 实例连接到 ClickHouse 后，您可以启用使用 ClickHouse 的功能：

先决条件：

- 您必须具有实例的管理员访问权限。
- ClickHouse 连接已配置并验证。
- 迁移已成功完成。

为分析功能启用 ClickHouse：

1. 在左侧边栏中，选择底部的**管理员**。
1. 选择**设置** > **通用**。
1. 展开 **分析**。
1. 选中 **启用 ClickHouse** 复选框。
1. 选择**保存更改**。

<a id="disable-clickhouse-for-analytics"></a>

### 为分析功能禁用 ClickHouse

为分析功能禁用 ClickHouse：

先决条件：

- 您必须具有实例的管理员访问权限。

禁用：

1. 在左侧边栏中，选择底部的**管理员**。
1. 选择**设置** > **通用**。
1. 展开 **分析**。
1. 清除 **启用 ClickHouse** 复选框。
1. 选择**保存更改**。

> [!note]
> 为分析功能禁用 ClickHouse 会停止极狐GitLab 查询 ClickHouse，但不会从您的 ClickHouse 实例中删除任何数据。依赖 ClickHouse 的分析功能将回退到替代数据源或变得不可用。

<a id="upgrade-clickhouse"></a>

## 升级 ClickHouse

<a id="clickhouse-cloud"></a>

### ClickHouse Cloud

ClickHouse Cloud 会自动处理版本升级和安全补丁。无需手动干预。

有关升级计划和维护窗口的信息，请参阅 [ClickHouse Cloud 升级](https://clickhouse.com/docs/manage/updates)。

> [!note]
> ClickHouse Cloud 会提前通知即将进行的升级。请查看 [ClickHouse Cloud 变更日志](https://clickhouse.com/docs/resources/changelogs/cloud)，及时了解新功能和变更。

<a id="clickhouse-for-gitlab-self-managed-byoc"></a>

### 用于极狐GitLab 私有化部署的 ClickHouse（BYOC）

对于用于极狐GitLab 私有化部署的 ClickHouse，您需要负责规划和执行版本升级。

先决条件：

- 具有 ClickHouse 实例的管理员访问权限。
- 升级前备份数据。请参阅[灾难恢复](#disaster-recovery)。

升级前：

1. 查看 [ClickHouse 发布说明](https://clickhouse.com/docs/category/changelog)，了解破坏性变更。
1. 检查与您的极狐GitLab 版本的[兼容性](#supported-clickhouse-versions)。
1. 在非生产环境中测试升级。
1. 规划潜在停机时间，或对 HA 集群使用滚动升级策略。

升级 ClickHouse：

1. 对于单节点部署，请遵循 [ClickHouse 升级文档](https://clickhouse.com/docs/manage/updates)。
1. 对于 HA 集群部署，执行滚动升级以尽量减少停机时间：
   - 一次升级一个节点。
   - 等待该节点重新加入集群。
   - 在继续下一个节点之前验证集群健康状况。

> [!warning]
> 请始终确保 ClickHouse 版本与您的极狐GitLab 版本保持兼容。不兼容的版本可能导致索引暂停和功能失败。更多信息，请参阅[受支持的 ClickHouse 版本](#supported-clickhouse-versions)

有关详细的升级步骤，请参阅 [ClickHouse 更新文档](https://clickhouse.com/docs/manage/updates)。

<a id="operations"></a>

## 运维

<a id="retry-failed-migrations"></a>

### 重试失败的迁移

如果 ClickHouse 迁移失败：

1. 检查日志以了解错误详情。与 ClickHouse 相关的错误会记录在极狐GitLab 应用程序日志中。
1. 解决根本问题（例如内存不足、连接问题）。
1. 重试迁移：

   ```shell
   # For installations that use the Linux package
   sudo gitlab-rake gitlab:clickhouse:migrate

   # For self-compiled installations
   bundle exec rake gitlab:clickhouse:migrate RAILS_ENV=production
   ```

> [!note]
> 迁移被设计为幂等且可安全重试。如果迁移中途失败，再次运行会从上次中断处继续，或跳过已完成的步骤。

<a id="clickhouse-rake-tasks"></a>

## ClickHouse Rake 任务

极狐GitLab 提供了多个用于管理 ClickHouse 数据库的 Rake 任务。

以下 Rake 任务可用：

| 任务 | 描述 |
|------|-------------|
| [`sudo gitlab-rake gitlab:clickhouse:migrate`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/tasks/gitlab/click_house/migration.rake) | 运行所有待处理的 ClickHouse 迁移，以创建或更新数据库模式。 |
| [`sudo gitlab-rake gitlab:clickhouse:drop`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/tasks/gitlab/click_house/migration.rake) | 删除所有 ClickHouse 数据库。请极其谨慎地使用，因为这会删除所有数据。 |
| [`sudo gitlab-rake gitlab:clickhouse:create`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/tasks/gitlab/click_house/migration.rake) | 如果 ClickHouse 数据库不存在，则创建它们。 |
| [`sudo gitlab-rake gitlab:clickhouse:setup`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/tasks/gitlab/click_house/migration.rake) | 创建数据库并运行所有迁移。等同于运行 `create` 和 `migrate` 任务。 |
| [`sudo gitlab-rake gitlab:clickhouse:schema:dump`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/tasks/gitlab/click_house/migration.rake) | 将当前数据库模式转储到文件，以便备份或版本控制。 |
| [`sudo gitlab-rake gitlab:clickhouse:schema:load`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/tasks/gitlab/click_house/migration.rake) | 从转储文件加载数据库模式。 |

> [!note]
> 对于自行编译的安装，请使用 `bundle exec rake` 而不是 `sudo gitlab-rake`，并在命令末尾添加 `RAILS_ENV=production`。

<a id="common-task-examples"></a>

### 常见任务示例

<a id="re-run-all-migrations"></a>

#### 重新运行所有迁移

运行所有待处理的迁移：

```shell
# For installations that use the Linux package
sudo gitlab-rake gitlab:clickhouse:migrate

# For self-compiled installations
bundle exec rake gitlab:clickhouse:migrate RAILS_ENV=production
```

<a id="reset-the-database"></a>

#### 重置数据库

> [!warning]
> 这会删除 ClickHouse 数据库中的所有数据。仅在开发或故障排除时使用。

删除并重新创建数据库：

```shell
# For installations that use the Linux package
sudo gitlab-rake gitlab:clickhouse:drop
sudo gitlab-rake gitlab:clickhouse:setup

# For self-compiled installations
bundle exec rake gitlab:clickhouse:drop RAILS_ENV=production
bundle exec rake gitlab:clickhouse:setup RAILS_ENV=production
```

<a id="environment-variables"></a>

### 环境变量

您可以使用环境变量来控制 Rake 任务的行为：

| 环境变量 | 数据类型 | 描述 |
|---------------------|-----------|-------------|
| `VERBOSE` | 布尔值 | 设置为 `true` 可在迁移期间查看详细输出。示例：`VERBOSE=true sudo gitlab-rake gitlab:clickhouse:migrate` |

<a id="performance-tuning"></a>

## 性能调优

> [!note]
> 有关基于用户数量的资源规模和部署建议，请参阅[系统要求](#system-requirements)。

有关 ClickHouse 架构和性能调优的信息，请参阅 [ClickHouse 架构文档](https://clickhouse.com/docs/architecture/introduction)。

<a id="disaster-recovery"></a>

## 灾难恢复

<a id="backup-and-restore"></a>

### 备份和恢复

您应在升级极狐GitLab 应用程序之前执行完整备份。
ClickHouse 数据不包含在极狐GitLab 备份工具中。

备份和恢复策略取决于所选的部署方式。

<a id="clickhouse-cloud-1"></a>

#### ClickHouse Cloud

ClickHouse Cloud 会自动：

- 管理备份和恢复。
- 创建并保留每日备份。

您无需进行任何额外配置。

更多信息，请参阅 [ClickHouse Cloud 备份](https://clickhouse.com/docs/cloud/manage/backups)。

<a id="clickhouse-for-gitlab-self-managed"></a>

#### 用于极狐GitLab 私有化部署的 ClickHouse

如果您自行管理 ClickHouse 实例，应定期进行备份以确保数据安全：

- 将表的初始完整备份（不包括 `metrics` 或 `logs` 等系统表）保存到[对象存储桶，例如 AWS S3](https://clickhouse.com/docs/en/operations/backup#configuring-backuprestore-to-use-an-s3-endpoint)。
- 在此初始完整备份之后进行[增量备份](https://clickhouse.com/docs/en/operations/backup#take-an-incremental-backup)。

这会为每次完整备份复制数据，但这是[恢复数据最简单的方法](https://clickhouse.com/docs/en/operations/backup#restore-from-the-incremental-backup)。

或者，使用 [`clickhouse-backup`](https://github.com/Altinity/clickhouse-backup)。这是一个第三方工具，提供类似功能，并具有调度和远程存储管理等附加特性。

<a id="monitoring"></a>

## 监控

为确保极狐GitLab 集成的稳定性，您应监控 ClickHouse 集群的健康状况和性能。

<a id="clickhouse-cloud-2"></a>

### ClickHouse Cloud

ClickHouse Cloud 提供原生 [Prometheus 集成](https://clickhouse.com/docs/integrations/prometheus)，通过安全的 API 端点公开指标。

生成 API 凭据后，您可以配置采集器从 ClickHouse Cloud 抓取指标。例如，[Prometheus 部署](https://clickhouse.com/docs/integrations/prometheus#configuring-prometheus)。

<a id="clickhouse-for-gitlab-self-managed-1"></a>

### 用于极狐GitLab 私有化部署的 ClickHouse

ClickHouse 可以公开 [Prometheus 格式的指标](https://clickhouse.com/docs/operations/server-configuration-parameters/settings#prometheus)。
要启用此功能：

1. 在 `config.xml`中配置 `prometheus` 节，以在专用端口（默认为 `9363`）上公开指标。

   ```xml
   <prometheus>
       <endpoint>/metrics</endpoint>
       <port>9363</port>
       <metrics>true</metrics>
       <events>true</events>
       <asynchronous_metrics>true</asynchronous_metrics>
   </prometheus>
   ```

1. 配置 Prometheus 或类似兼容服务器以抓取 `http://<clickhouse-host>:9363/metrics`。

<a id="metrics-to-monitor"></a>

### 需要监控的指标

您应为以下指标设置告警，以检测可能影响极狐GitLab 功能的问题：

| 指标名称 | 描述 | 告警阈值（建议） |
| :--- | :--- | :--- |
| `ClickHouse_Metrics_Query` | 当前正在执行的查询数量。突然激增可能表明存在性能瓶颈。 | 基线偏差（例如 `> 100`） |
| `ClickHouseProfileEvents_FailedSelectQuery` | 失败的 select 查询数量 | 基线偏差（例如 `> 50`） |
| `ClickHouseProfileEvents_FailedInsertQuery` | 失败的 insert 查询数量 | 基线偏差（例如 `> 10`） |
| `ClickHouse_AsyncMetrics_ReadonlyReplica` | 指示副本是否已进入只读模式（通常是由于 ZooKeeper 连接丢失）。 | `> 0`（立即采取措施） |
| `ClickHouse_ProfileEvents_NetworkErrors` | 网络错误（连接重置/超时）。频繁错误可能导致极狐GitLab 后台作业失败。 | 速率 `> 0` |

<a id="liveness-check"></a>

### 存活检查

如果 ClickHouse 位于负载均衡器后面，您可以使用 HTTP `/ping` 端点检查存活状态。预期响应为 `Ok`，HTTP 状态码为 200。

<a id="security-and-auditing"></a>

## 安全和审计

为确保数据安全并保证可审计性，请使用以下安全实践。

<a id="network-security"></a>

### 网络安全

- TLS 加密：将 ClickHouse 服务器配置为[使用 TLS 加密](#network-security)以验证连接。

  在极狐GitLab 中配置连接 URL 时，您应使用 `https://` 协议（例如 `https://clickhouse.example.com:8443`）来指定。
- IP 允许名单：将 ClickHouse 端口（默认为 `8443` 或 `9440`）的访问限制为仅极狐GitLab 应用程序节点和其他授权网络。

<a id="audit-logging"></a>

### 审计日志

极狐GitLab 应用程序不会为单个 ClickHouse 查询维护单独的审计日志。为了满足有关数据访问的特定要求（谁在何时查询了什么），您可以在 ClickHouse 端启用日志记录。

<a id="clickhouse-cloud-3"></a>

#### ClickHouse Cloud

在 ClickHouse Cloud 中，查询日志记录默认启用。
您可以通过查询 `system.query_log` 表来访问这些日志。

<a id="clickhouse-for-gitlab-self-managed-2"></a>

#### 用于极狐GitLab 私有化部署的 ClickHouse

对于极狐GitLab 私有化部署实例，请确保在服务器配置中启用 `query_log` 配置参数：

1. 验证 `config.xml` 或 `users.xml`中是否存在 `query_log` 节：

   ```xml
   <query_log>
       <database>system</database>
       <table>query_log</table>
       <partition_by>toYYYYMM(event_date)</partition_by>
       <flush_interval_milliseconds>7500</flush_interval_milliseconds>
       <ttl>event_date + INTERVAL 30 DAY</ttl>  <!-- Keep only 30 days -->
   </query_log>
   ```

1. 启用后，所有已执行的查询都会记录在 `system.query_log` 表中，从而支持审计跟踪。

<a id="attributing-queries-to-users"></a>

#### 将查询归属于用户

极狐GitLab 会为发送到 ClickHouse 的每个查询添加 `log_comment` 设置，该设置存储在 `system.query_log`的 `log_comment` 列中。使用该注解将记录的查询归属于发出该查询的请求。该注解是一个 JSON 对象，可以包含：

- `user_id`：触发该请求的用户的数字 ID。
- `root_namespace_id`：根命名空间的数字 ID。
- `organization_id`：该请求所属组织的数字 ID。
- `correlation_id`：请求关联 ID，也用于其他极狐GitLab 日志。
- `application`：`web`、`sidekiq`、`console` 或 `test`。
- `feature_category`：该请求的功能类别。

后台工作进程发出的查询在上下文中没有用户或命名空间，因此其 `log_comment` 通常只包含 `correlation_id`、`application` 和 `feature_category`。

例如，要构建查询及其发出用户的审计跟踪：

```sql
SELECT JSONExtractInt(log_comment, 'user_id') AS user_id,
       JSONExtractString(log_comment, 'correlation_id') AS correlation_id,
       query,
       event_time
FROM system.query_log
WHERE type = 'QueryFinish' AND log_comment != ''
ORDER BY event_time DESC
LIMIT 20
```

<a id="system-requirements"></a>

## 系统要求

推荐的系统要求因用户数量而异。

<a id="deployment-decision-matrix-quick-reference"></a>

### 部署决策矩阵快速参考

| 用户数 | 主要建议 | 可比的 AWS ARM 实例 | 可比的 GCP ARM 实例 | 可比的 Azure ARM 实例 | 部署类型 |
|---|---|---|---|---|---|
| 1K | ClickHouse Cloud Basic | - | - | - | 托管 |
| 2K | ClickHouse Cloud Basic | `m8g.xlarge` | `c4a-standard-4` |  `Standard_D4ps_v6` | 托管或单节点 |
| 3K | ClickHouse Cloud Scale | `m8g.2xlarge` | `c4a-standard-8` | `Standard_D8ps_v6` | 托管或单节点 |
| 5K | ClickHouse Cloud Scale | `m8g.4xlarge` | `c4a-standard-16` | `Standard_D16ps_v6` | 托管或单节点 |
| 10K | ClickHouse Cloud Scale | `m8g.4xlarge` | `c4a-standard-16` | `Standard_D16ps_v6` | 托管或单节点/HA |
| 25K | 用于极狐GitLab 私有化部署的 ClickHouse 或 ClickHouse Cloud Scale | `m8g.8xlarge` 或 3×`m8g.4xlarge` | `c4a-standard-32` 或 3×`c4a-standard-16` | `Standard_D32ps_v6` 或 3x`Standard_D16ps_v6` | 托管或单节点/HA |
| 50K | 用于极狐GitLab 私有化部署的高可用性（HA）ClickHouse 或 ClickHouse Cloud Scale | 3×`m8g.4xlarge` | 3×`c4a-standard-16` | 3x`Standard_D16ps_v6` | 托管或 HA 集群 |

<a id="1k-users"></a>

### 1K 用户

建议：ClickHouse Cloud Basic，因为它具有良好的成本效益且无运维复杂性。

<a id="2k-users"></a>

### 2K 用户

建议：ClickHouse Cloud Basic，因为它提供最佳性价比且无运维复杂性。

用于极狐GitLab 私有化部署的 ClickHouse 部署的替代建议：

- AWS：m8g.xlarge（4 vCPU，16 GB）
- GCP：c4a-standard-4 或 n4-standard-4（4 vCPU，16 GB）
- Azure：Standard_D4ps_v6（4 vCPU，16 GB）
- 存储：20 GB，低-中性能层级

<a id="3k-users"></a>

### 3K 用户

建议：ClickHouse Cloud Scale

用于极狐GitLab 私有化部署的 ClickHouse 部署的替代建议：

- AWS：m8g.2xlarge（8 vCPU，32 GB）
- GCP：c4a-standard-8 或 n4-standard-8（8 vCPU，32 GB）
- Azure：Standard_D8ps_v6（8 vCPU，32 GB）
- 存储：100 GB，中性能层级

> [!note]
> 在此规模下，HA 部署不具备成本效益。

<a id="5k-users"></a>

### 5K 用户

建议：ClickHouse Cloud Scale

用于极狐GitLab 私有化部署的 ClickHouse 部署的替代建议：

- AWS：m8g.4xlarge（16 vCPU，64 GB）
- GCP：c4a-standard-16 或 n4-standard-16（16 vCPU，64 GB）
- Azure：Standard_D16ps_v6（16 vCPU，64 GB）
- 存储：100 GB，高性能层级
- 部署：建议单节点

<a id="10k-users"></a>

### 10K 用户

建议：ClickHouse Cloud Scale

用于极狐GitLab 私有化部署的 ClickHouse 部署的替代建议：

- AWS：m8g.4xlarge（16 vCPU，64 GB）
- GCP：c4a-standard-16 或 n4-standard-16（16 vCPU，64 GB）
- Azure：Standard_D16ps_v6（16 vCPU，64 GB）
- 存储：200 GB，高性能层级
- HA 选项：对于关键工作负载，3 节点集群变得可行

<a id="25k-users"></a>

### 25K 用户

建议：ClickHouse Cloud Scale 或用于极狐GitLab 私有化部署的 ClickHouse。在此规模下，两种方案在经济上均可行。

用于极狐GitLab 私有化部署的 ClickHouse 部署的建议：

- 单节点：

  - AWS：m8g.8xlarge（32 vCPU，128 GB）
  - GCP：c4a-standard-32 或 n4-standard-32（32 vCPU，128 GB）
  - Azure：Standard_D32ps_v6（32 vCPU，128 GB）
- HA 部署：

  - AWS：3 × m8g.4xlarge（每个 16 vCPU，64 GB）
  - GCP：3 × c4a-standard-16 或 3 × n4-standard-16（每个 16 vCPU，64 GB）
  - Azure：3 x Standard_D16ps_v6（每个 16 vCPU，64 GB）
- 存储：每个节点 400 GB，高性能层级。

<a id="50k-users"></a>

### 50K 用户

建议：用于极狐GitLab 私有化部署的 ClickHouse HA 或 ClickHouse Cloud Scale。在此规模下，运行您自己的 ClickHouse 实例略具成本效益。

用于极狐GitLab 私有化部署的 ClickHouse 部署的建议：

- 单节点：

  - AWS：m8g.8xlarge（32 vCPU，128 GB）
  - GCP：c4a-standard-32 或 n4-standard-32（32 vCPU，128 GB）
  - Azure：Standard_D32ps_v6（32 vCPU，128 GB）
- HA 部署（首选）：

  - AWS：3 × m8g.4xlarge（每个 16 vCPU，64 GB）
  - GCP：3 × c4a-standard-16 或 3 × n4-standard-16（每个 16 vCPU，64 GB）
  - Azure：3 x Standard_D16ps_v6（每个 16 vCPU，64 GB）
- 存储：每个节点 1000 GB，高性能层级。

<a id="ha-considerations-for-clickhouse-for-gitlab-self-managed-deployment"></a>

#### 用于极狐GitLab 私有化部署的 ClickHouse 部署的 HA 注意事项

HA 设置仅在 10k 用户或以上时才具有成本效益。

- 最低要求：三个 ClickHouse 节点以形成法定人数。
- [ClickHouse Keeper](https://clickhouse.com/clickhouse/keeper)：三个节点用于协调（可以同址部署或单独部署）。
- LoadBalancer：建议用于分发查询。
- 网络：节点之间的低延迟连接至关重要。

<a id="glossary"></a>

## 术语表

- 集群：协同工作以存储和处理数据的节点（服务器）集合。
- MergeTree：[`MergeTree`](https://clickhouse.com/docs/engines/table-engines/mergetree-family/mergetree) 是 ClickHouse 中为高数据摄入率和大数据量设计的表引擎。
  它是 ClickHouse 的核心存储引擎，提供列式存储、自定义分区、稀疏主索引以及对后台数据合并的支持等特性。
- 分区片段（Parts）：磁盘上存储表部分数据的物理文件。
  分区片段不同于分区，分区是使用分区键创建的表数据的逻辑划分。
- 副本：存储在 ClickHouse 数据库中的数据的副本。
  您可以为同一数据设置任意数量的副本，以实现冗余和可靠性。
  副本与 ReplicatedMergeTree 表引擎配合使用，使 ClickHouse 能够在不同服务器之间保持多份数据副本同步。
- 分片：数据的子集。
  ClickHouse 始终为您的数据保留至少一个分片。
  如果您不将数据拆分到多个服务器，数据将存储在一个分片中。
  如果超出单个服务器的容量，可以通过跨多个服务器分片数据来分担负载。
- TTL（Time To Live）：Time To Live（TTL）是 ClickHouse 的一项功能，可在特定时间段后自动移动、删除或汇总列/行。
  这使您可以更高效地管理存储，因为您可以删除、移动或归档不再需要频繁访问的数据。

<a id="troubleshooting"></a>

## 故障排除

<a id="database-schema-migrations-on-gitlab-1800-and-earlier"></a>

### 极狐GitLab 18.0.0 及更早版本上的数据库模式迁移

> [!warning]
> 在极狐GitLab 18.0.0 及更早版本上，为 ClickHouse 运行数据库模式迁移时，ClickHouse 24.x 和 25.x 可能会失败，并显示以下错误消息：
>
> ```plaintext
> Code: 344. DB::Exception: Projection is fully supported in ReplacingMergeTree with deduplicate_merge_projection_mode = throw. Use 'drop' or 'rebuild' option of deduplicate_merge_projection_mode
> ```
>
> 如果不运行所有迁移，ClickHouse 集成将无法工作。

要变通解决此问题并运行迁移：

1. 登录 [Rails 控制台](../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 执行以下命令：

   ```ruby
   ClickHouse::Client.execute("INSERT INTO schema_migrations (version) VALUES ('20231114142100'), ('20240115162101')", :main)
   ```

1. 再次迁移数据库：

   ```shell
   sudo gitlab-rake gitlab:clickhouse:migrate
   ```

这次数据库迁移应能成功完成。

<a id="database-dictionary-read-support"></a>

### 数据库字典读取支持

从极狐GitLab 18.8 开始，极狐GitLab 开始使用 [ClickHouse 字典](https://clickhouse.com/docs/dictionary)进行数据反规范化。18.8 之前的 `GRANT` 语句未授予 `gitlab` 用户查询字典的权限，因此需要手动修改：

1. 登录到：
   - 对于 ClickHouse Cloud，登录 ClickHouse SQL 控制台。
   - 对于用于极狐GitLab 私有化部署的 ClickHouse，登录 `clickhouse-client`。
1. 运行以下命令，将 `PASSWORD_HERE` 替换为生成的密码。

{{< tabs >}}

{{< tab title="Single-node or ClickHouse Cloud" >}}

```sql
GRANT dictGet ON gitlab_clickhouse_main_production.* TO gitlab_app;
```

{{< /tab >}}

{{< tab title="HA ClickHouse for GitLab Self-Managed" >}}

将 `CLUSTER_NAME_HERE` 替换为您的集群名称：

```sql
GRANT dictGet ON gitlab_clickhouse_main_production.* TO gitlab_app ON CLUSTER CLUSTER_NAME_HERE;
```

{{< /tab >}}

{{< /tabs >}}

如果不授予该权限，ClickHouse 迁移（`CreateNamespaceTraversalPathsDict`）将失败并显示以下错误：

```plaintext
DB::Exception: gitlab: Not enough privileges.
```

授予权限后，可以安全地重试迁移（最好等待 1-2 小时，直到分布式迁移锁清除）。

<a id="clickhouse-ci-job-data-materialized-view-data-inconsistencies"></a>

### ClickHouse CI 作业数据物化视图数据不一致

在极狐GitLab 18.5 及更早版本中，当 Sidekiq 工作进程在网络超时后重试时，可能会将重复数据插入 ClickHouse 表（例如 `ci_finished_pipelines` 和 `ci_finished_builds`）。此问题导致物化视图在分析仪表板（包括 Runner 队列仪表板）中显示不正确的聚合指标。

此问题已在极狐GitLab 18.9 中修复，并向后移植到 18.6、18.7 和 18.8。要解决此问题，请升级到极狐GitLab 18.6 或更高版本。

如果您已有重复数据，重建受影响物化视图的修复计划在极狐GitLab 18.10 中通过[议题 586319](https://gitlab.com/gitlab-org/gitlab/-/issues/586319) 提供。如需帮助，请联系极狐GitLab 支持。

<a id="clickhouse-267-and-later"></a>

### ClickHouse 26.7 及更高版本

ClickHouse 26.7 会拒绝那些列既不属于排序键、也不是聚合状态列（`AggregateFunction` 或 `SimpleAggregateFunction`）的 `AggregatingMergeTree` 表。某些极狐GitLab 表具有这种结构，因此迁移会失败：

```plaintext
Code: 36. DB::Exception: Column(s) purchase_id, add_on_name of the AggregatingMergeTree table are neither part of the sorting key nor aggregate measures (AggregateFunction or SimpleAggregateFunction). ... (BAD_ARGUMENTS)
```

现有安装不受影响。全新安装、新副本以及从零构建的环境会失败。

请使用 ClickHouse 26.6 或更早版本。如果必须运行 26.7 或更高版本，请在 `/etc/clickhouse-server/users.d/compatibility.xml`中将 `compatibility` 设置为 `26.6`：

```xml
<clickhouse>
    <profiles>
        <default>
            <compatibility>26.6</compatibility>
        </default>
    </profiles>
</clickhouse>
```

ClickHouse 会自动重新加载 `users.d`，因此无需重启。该设置仅在配置文件中生效，因此 `ALTER USER ... SETTINGS compatibility` 无效。`users.d` 会还原 26.7 中新增的每项设置的默认值，因此当极狐GitLab 开始支持 26.7 时，请移除此文件。

> [!warning]
> 请勿使用 `allow_dimensions_outside_sorting_key` 服务器 `merge_tree` 设置作为
> `compatibility` 设置的替代方案。26.7 之前的服务器会无法启动，并出现
> `Code: 115`（`UNKNOWN_SETTING`）。
