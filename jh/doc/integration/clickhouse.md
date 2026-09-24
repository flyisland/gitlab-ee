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

{{< history >}}

- 极狐GitLab 私有化部署 在极狐GitLab 18.11 中 GA。

{{< /history >}}

[ClickHouse](https://clickhouse.com) 是一个开源列式数据库管理系统，可以高效地对大数据集进行过滤、聚合和查询。

极狐GitLab 使用 ClickHouse 作为辅助数据存储，以支持高级分析功能，例如 极狐GitLab Duo、SDLC 趋势和 CI 分析。极狐GitLab 仅在 ClickHouse 中存储支持这些功能的数据。

您应该使用 [ClickHouse Cloud](https://clickhouse.com/cloud) 将 ClickHouse 连接到极狐GitLab。

或者，您也可以[自带 ClickHouse](https://clickhouse.com/docs/en/install)。有关更多信息，请参阅[适用于极狐GitLab 私有化部署的 ClickHouse 建议](https://clickhouse.com/docs/guides/sizing-and-hardware-recommendations)。

<a id="analytics-available-with-clickhouse"></a>

## 使用 ClickHouse 可用的分析

配置 ClickHouse 后，您可以使用以下分析功能：

| 功能 | 描述 |
|----------------------|---------------------|
| [Runner 集群仪表板](../ci/runners/runner_fleet_dashboard.md#dashboard-metrics)  | 展示 Runner 使用量指标和作业等待时间。支持按项目导出 CSV 文件，其中包含按 Runner 类型和作业状态统计的作业计数和执行的 Runner 分钟数。   |
| [贡献分析](../user/group/contribution_analytics/_index.md)  | 提供群组成员在一段时间内的贡献分析（推送事件、议题、合并请求）。使用 ClickHouse 可降低大型实例出现超时问题的可能性。 |
| [极狐GitLab Duo 与 SDLC 趋势](../user/analytics/duo_and_sdlc_trends.md)  | 衡量 极狐GitLab Duo 对软件开发效能的影响。跟踪开发指标（部署频率、前置时间、变更失败率、恢复时间）以及 AI 特定指标（极狐GitLab Duo 席位采用率、代码建议接受率以及 极狐GitLab Duo Chat 使用量）。 |
| [AI 指标 GraphQL API](../api/graphql/duo_and_sdlc_trends.md) | 通过 `AiMetrics`、`AiUserMetrics` 和 `AiUsageData` 端点提供对 极狐GitLab Duo 与 SDLC 趋势数据的编程访问。支持导出预聚合指标和原始事件数据，以便与 BI 工具和自定义分析集成。 |

<a id="supported-clickhouse-versions"></a>

## 支持的 ClickHouse 版本

支持的 ClickHouse 版本根据您的极狐GitLab 版本而有所不同：

- 极狐GitLab 17.7 及更高版本支持 ClickHouse 23.x。要使用 ClickHouse 24.x 或 25.x，请使用[变通方法](#database-schema-migrations-on-gitlab-1800-and-earlier)。
- 极狐GitLab 18.1 及更高版本支持 ClickHouse 23.x、24.x 和 25.x。
- 极狐GitLab 18.8 及更高版本支持 ClickHouse 23.x、24.x、25.x 以及 Replicated 数据库引擎。
  - 旧集群需要额外的权限（`dictGet`），请参阅[代码片段](#database-dictionary-read-support)。
- 极狐GitLab 19.0 及更高版本支持 ClickHouse 25.x 和 26.x。对 ClickHouse 23.x 和 24.x 的支持已被移除。

ClickHouse Cloud 始终与最新的极狐GitLab 稳定版兼容。

> [!warning]
> 如果您正在使用 ClickHouse 25.12，请注意它引入了对 `ALTER MODIFY COLUMN` 的[后向不兼容更改](https://clickhouse.com/docs/whats-new/changelog#backward-incompatible-change)。这会破坏 18.8 之前的极狐GitLab ClickHouse 集成的迁移过程。需要将极狐GitLab 升级到版本 18.8+。

<a id="set-up-clickhouse"></a>

## 设置 ClickHouse

根据您的运维需求选择部署类型：

- **[ClickHouse Cloud](#set-up-clickhouse-cloud)**（推荐）：全托管服务，自动升级、备份和扩缩容。
- **[极狐GitLab 私有化部署的 ClickHouse (BYOC)](#set-up-clickhouse-for-gitlab-self-managed-byoc)**：完全控制您的基础设施和配置。

设置好 ClickHouse 实例后：

1. [创建极狐GitLab 数据库和用户](#create-database-and-user)。
1. [配置极狐GitLab 连接](#configure-the-gitlab-connection)。
1. [验证连接](#verify-the-connection)。
1. [运行 ClickHouse 迁移](#run-clickhouse-migrations)。
1. [为分析启用 ClickHouse](#enable-clickhouse-for-analytics)。

<a id="set-up-clickhouse-cloud"></a>

### 设置 ClickHouse Cloud

先决条件：

- 拥有一个 ClickHouse Cloud 账号。
- 确保从极狐GitLab 实例到 ClickHouse Cloud 的网络连通性。
- 是极狐GitLab 实例的管理员。

设置 ClickHouse Cloud：

1. 登录 [ClickHouse Cloud](https://clickhouse.cloud)。
1. 选择 **新建服务**。
1. 选择您的服务层级：
   - **开发**：适用于测试和开发环境。
   - **生产**：适用于需要高可用的生产工作负载。
1. 选择云提供商和区域。为获得最佳性能，请选择靠近极狐GitLab 实例的区域。
1. 配置服务名称和设置。
1. 选择 **创建服务**。
1. 配置完成后，从服务仪表板记下您的连接信息：
   - 主机
   - 端口（安全连接通常为 `9440`）
   - 用户名
   - 密码

> [!note]
> ClickHouse Cloud 自动处理版本升级和安全补丁。企业版 (EE) 用户可以计划升级以控制升级时间，避免在工作时间出现意外服务中断。更多信息，请参阅[升级 ClickHouse](#upgrade-clickhouse)。

创建 ClickHouse Cloud 服务后，您需要[创建极狐GitLab 数据库和用户](#create-database-and-user)。

<a id="set-up-clickhouse-for-gitlab-self-managed-byoc"></a>

### 设置极狐GitLab 私有化部署的 ClickHouse (BYOC)

先决条件：

- 已安装并正在运行 ClickHouse 实例。如果尚未安装 ClickHouse，请参阅：
  - [ClickHouse 官方安装指南](https://clickhouse.com/docs/en/install)。
  - [适用于极狐GitLab 私有化部署的 ClickHouse 建议](https://clickhouse.com/docs/guides/sizing-and-hardware-recommendations)。
- 安装了[受支持的 ClickHouse 版本](#supported-clickhouse-versions)。
- 确保从极狐GitLab 实例到 ClickHouse 的网络连通性。
- 同时是 ClickHouse 和极狐GitLab 实例的管理员。

> [!warning]
> 对于极狐GitLab 私有化部署的 ClickHouse，您需要负责规划和执行版本升级、安全补丁和备份。更多信息，请参阅[升级 ClickHouse](#upgrade-clickhouse)。

<a id="configure-high-availability"></a>

#### 配置高可用

对于多节点、高可用（HA）设置，极狐GitLab 支持 ClickHouse 中的 Replicated 表引擎。

先决条件：

- 拥有一个包含多个节点的 ClickHouse 集群，建议至少三个节点。
- 在 `remote_servers` 配置段中定义一个集群。
- 在 ClickHouse 配置中配置以下宏：
  - `cluster`
  - `shard`
  - `replica`

为 HA 配置数据库时，您必须使用 `ON CLUSTER` 子句执行语句。

更多信息，请参阅[ClickHouse Replicated 数据库引擎文档](https://clickhouse.com/docs/en/engines/database-engines/replicated)。

<a id="configure-load-balancer"></a>

#### 配置负载均衡器

极狐GitLab 应用程序通过 HTTP/HTTPS 接口与 ClickHouse 集群通信。对于 HA 部署，请使用 HTTP 代理或负载均衡器将请求分发到 ClickHouse 集群节点。

推荐的负载均衡器选项：

- [chproxy](https://www.chproxy.org/) - 面向 ClickHouse 的 HTTP 代理，内置缓存和路由功能。
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

使用负载均衡器时，请将极狐GitLab 的连接配置指向负载均衡器 URL，而非单个 ClickHouse 节点。

更多信息，请参阅 [chproxy 文档](https://www.chproxy.org/)。

配置好极狐GitLab 私有化部署的 ClickHouse 实例后，请[创建极狐GitLab 数据库和用户](#create-database-and-user)。

<a id="verify-clickhouse-installation"></a>

### 验证 ClickHouse 安装

配置数据库之前，请验证 ClickHouse 已安装并且可以访问：

1. 检查 ClickHouse 是否正在运行：

   ```shell
   clickhouse-client --query "SELECT version()"
   ```

   如果 ClickHouse 正在运行，您会看到版本号（例如 `24.3.1.12`）。
1. 验证能否使用凭据连接：

   ```shell
   clickhouse-client --host your-clickhouse-host --port 9440 --secure --user default --password 'your-password'
   ```

   > [!note]
   > 如果尚未配置 TLS，请先使用端口 `9000` 并且不加 `--secure` 标志进行初始测试。

<a id="create-database-and-user"></a>

### 创建数据库和用户

创建必要的用户和数据库对象：

1. 生成一个安全的密码并保存。
1. 登录到：
   - 对于 ClickHouse Cloud，登录 ClickHouse SQL 控制台。
   - 对于极狐GitLab 私有化部署的 ClickHouse，使用 `clickhouse-client`。
1. 运行以下命令，将 `PASSWORD_HERE` 替换为生成的密码。

{{< tabs >}}

{{< tab title="单节点或 ClickHouse Cloud" >}}

```sql
CREATE DATABASE gitlab_clickhouse_main_production;
CREATE USER gitlab IDENTIFIED WITH sha256_password BY 'PASSWORD_HERE';
CREATE ROLE gitlab_app;
GRANT SELECT, INSERT, ALTER, CREATE, UPDATE, DROP, TRUNCATE, OPTIMIZE, dictGet ON gitlab_clickhouse_main_production.* TO gitlab_app;
GRANT SELECT ON information_schema.* TO gitlab_app;
GRANT gitlab_app TO gitlab;
```

{{< /tab >}}

{{< tab title="HA 极狐GitLab 私有化部署的 ClickHouse" >}}

将 `CLUSTER_NAME_HERE` 替换为您的集群名称：

```sql
CREATE DATABASE gitlab_clickhouse_main_production ON CLUSTER CLUSTER_NAME_HERE ENGINE = Replicated('/clickhouse/databases/{cluster}/gitlab_clickhouse_main_production', '{shard}', '{replica}');
CREATE USER gitlab IDENTIFIED WITH sha256_password BY 'PASSWORD_HERE' ON CLUSTER CLUSTER_NAME_HERE;
CREATE ROLE gitlab_app ON CLUSTER CLUSTER_NAME_HERE;
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
   gitlab_rails['clickhouse_databases']['main']['password'] = 'PASSWORD_HERE' # 替换为实际密码
   ```

   将 URL 替换为：
   - 对于 ClickHouse Cloud：`https://your-service.clickhouse.cloud:9440`
   - 对于极狐GitLab 私有化部署的 ClickHouse 单节点：`https://your-clickhouse-host:8443`
   - 对于极狐GitLab 私有化部署的 ClickHouse HA（带负载均衡器）：`https://your-load-balancer:8080`（或您的负载均衡器 URL）

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm Chart（Kubernetes）" >}}

1. 将 ClickHouse 密码保存为 Kubernetes Secret：

   ```shell
   kubectl create secret generic gitlab-clickhouse-password --from-literal="main_password=PASSWORD_HERE"
   ```

1. 导出 Helm values：

   ```shell
   helm get values gitlab > gitlab_values.yaml
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
   - 对于 ClickHouse Cloud：`https://your-service.clickhouse.cloud:9440`
   - 对于极狐GitLab 私有化部署的 ClickHouse 单节点：`https://your-clickhouse-host:8443`
   - 对于极狐GitLab 私有化部署的 ClickHouse HA（带负载均衡器）：`https://your-load-balancer:8080`（或您负载均衡器的 URL）

1. 保存文件并应用新的 values：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< /tabs >}}

> [!note]
> 对于生产部署，请在 ClickHouse 实例上配置 TLS/SSL 并使用 `https://` URL。对于私有化部署的极狐GitLab 安装，请参阅[网络安全](#network-security)文档。

<a id="verify-the-connection"></a>

### 验证连接

验证连接是否设置成功：

1. 登录到 [Rails 控制台](../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 执行以下命令：

   ```ruby
   ClickHouse::Client.select('SELECT 1', :main)
   ```

   如果成功，该命令将返回 `[{"1"=>1}]`。

如果连接失败，请检查：

- ClickHouse 服务正在运行且可访问。
- 从极狐GitLab 到 ClickHouse 的网络连通性。检查防火墙和安全组是否允许连接。
- 连接 URL 正确（主机、端口、协议）。
- 凭据正确。
- 对于 HA 集群部署：负载均衡器已正确配置并正在分发请求。

<a id="run-clickhouse-migrations"></a>

### 运行 ClickHouse 迁移

{{< tabs >}}

{{< tab title="Linux 软件包" >}}

要创建所需的数据库对象，请执行：

```shell
sudo gitlab-rake gitlab:clickhouse:migrate
```

{{< /tab >}}

{{< tab title="Helm Chart（Kubernetes）" >}}

迁移由 [GitLab-Migrations chart](https://gitlab.cn/docs/charts/charts/gitlab/migrations/) 自动执行。

或者，您也可以在 Toolbox pod 中运行以下命令来执行迁移：

```shell
gitlab-rake gitlab:clickhouse:migrate
```

{{< /tab >}}

{{< /tabs >}}

<a id="enable-clickhouse-for-analytics"></a>

### 为分析启用 ClickHouse

将极狐GitLab 实例连接到 ClickHouse 后，您可以启用使用 ClickHouse 的功能：

先决条件：

- 您必须拥有实例的管理员访问权限。
- ClickHouse 连接已配置并验证。
- 迁移已成功完成。

为分析启用 ClickHouse：

1. 在左侧边栏的底部，选择 **管理员**。
1. 选择 **设置** > **通用**。
1. 展开 **ClickHouse**。
1. 选择 **为分析启用 ClickHouse**。
1. 选择 **保存更改**。

<a id="disable-clickhouse-for-analytics"></a>

### 为分析禁用 ClickHouse

为分析禁用 ClickHouse：

先决条件：

- 您必须拥有实例的管理员访问权限。

要禁用，请执行以下操作：

1. 在左侧边栏的底部，选择 **管理员**。
1. 选择 **设置** > **通用**。
1. 展开 **ClickHouse**。
1. 清除 **为分析启用 ClickHouse** 复选框。
1. 选择 **保存更改**。

> [!note]
> 为分析禁用 ClickHouse 后，极狐GitLab 将停止查询 ClickHouse，但不会删除 ClickHouse 实例中的任何数据。依赖 ClickHouse 的分析功能将回退到备用数据源或变得不可用。

<a id="upgrade-clickhouse"></a>

## 升级 ClickHouse

<a id="clickhouse-cloud"></a>

### ClickHouse Cloud

ClickHouse Cloud 自动处理版本升级和安全补丁，无需手动干预。

有关升级计划及维护窗口的信息，请参阅 [ClickHouse Cloud 升级](https://clickhouse.com/docs/manage/updates)。

> [!note]
> ClickHouse Cloud 会提前通知您即将进行的升级。查看 [ClickHouse Cloud 更新日志](https://clickhouse.com/docs/whats-new/cloud) 以了解最新功能与变更。

<a id="clickhouse-for-gitlab-self-managed-byoc"></a>

### 极狐GitLab 私有化部署的 ClickHouse (BYOC)

对于极狐GitLab 私有化部署的 ClickHouse，您需要负责规划和执行版本升级。

先决条件：

- 拥有 ClickHouse 实例的管理员访问权限。
- 升级前备份数据。请参阅[灾难恢复](#disaster-recovery)。

升级前：

1. 查看 [ClickHouse 发布说明](https://clickhouse.com/docs/category/changelog) 中的破坏性变更。
1. 检查与您极狐GitLab 版本的[兼容性](#supported-clickhouse-versions)。
1. 在非生产环境中测试升级。
1. 为可能的停机时间做好计划，或者对 HA 集群使用滚动升级策略。

升级 ClickHouse：

1. 对于单节点部署，请遵循 [ClickHouse 升级文档](https://clickhouse.com/docs/manage/updates)。
1. 对于 HA 集群部署，执行滚动升级以最小化停机时间：
   - 一次升级一个节点。
   - 等待该节点重新加入集群。
   - 在继续升级下一个节点之前，验证集群健康状态。

> [!warning]
> 始终确保 ClickHouse 版本与您的极狐GitLab 版本保持兼容。不兼容的版本可能导致索引暂停和功能失效。更多信息，请参阅[支持的 ClickHouse 版本](#supported-clickhouse-versions)

有关详细的升级步骤，请参阅 [ClickHouse 更新文档](https://clickhouse.com/docs/manage/updates)。

<a id="operations"></a>

## 运维操作

<a id="check-migration-status"></a>

### 检查迁移状态

先决条件：

- 您必须拥有实例的管理员访问权限。

检查 ClickHouse 迁移状态：

1. 在左侧边栏的底部，选择 **管理员**。
1. 选择 **设置** > **通用**。
1. 展开 **ClickHouse**。
1. 查看 **迁移状态** 部分（如果可用）。

此外，您也可以使用 Rails 控制台检查是否存在挂起的迁移：

```ruby
# 登录到 Rails 控制台
# 运行以下命令检查迁移
ClickHouse::MigrationSupport::Migrator.new(:main).pending_migrations
```

<a id="retry-failed-migrations"></a>

### 重试失败的迁移

如果 ClickHouse 迁移失败：

1. 查看日志获取错误详情。与 ClickHouse 相关的错误会记录在极狐GitLab 应用程序日志中。
1. 解决潜在问题（例如内存不足、网络连接问题）。
1. 重试迁移：

   ```shell
   # 对于使用 Linux 软件包的安装
   sudo gitlab-rake gitlab:clickhouse:migrate

   # 对于自行编译的安装
   bundle exec rake gitlab:clickhouse:migrate RAILS_ENV=production
   ```

> [!note]
> 迁移设计为幂等且可安全重试。如果迁移在执行中途失败，重新运行它会从中断处继续，或者跳过已完成的步骤。

<a id="clickhouse-rake-tasks"></a>

## ClickHouse Rake 任务

极狐GitLab 提供了多个用于管理 ClickHouse 数据库的 Rake 任务。

可用的 Rake 任务如下：

| 任务 | 描述 |
|------|-------------|
| [`sudo gitlab-rake gitlab:clickhouse:migrate`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/tasks/gitlab/click_house/migration.rake) | 运行所有挂起的 ClickHouse 迁移，以创建或更新数据库 schema。 |
| [`sudo gitlab-rake gitlab:clickhouse:drop`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/tasks/gitlab/click_house/migration.rake) | 删除所有 ClickHouse 数据库。请谨慎使用，因为这将删除所有数据。 |
| [`sudo gitlab-rake gitlab:clickhouse:create`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/tasks/gitlab/click_house/migration.rake) | 如果 ClickHouse 数据库不存在，则创建它们。 |
| [`sudo gitlab-rake gitlab:clickhouse:setup`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/tasks/gitlab/click_house/migration.rake) | 创建数据库并运行所有迁移。相当于依次执行 `create` 和 `migrate` 任务。 |
| [`sudo gitlab-rake gitlab:clickhouse:schema:dump`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/tasks/gitlab/click_house/migration.rake) | 将当前数据库 schema 导出到文件，用于备份或版本控制。 |
| [`sudo gitlab-rake gitlab:clickhouse:schema:load`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/tasks/gitlab/click_house/migration.rake) | 从导出的文件加载数据库 schema。 |

> [!note]
> 对于自行编译的安装，请将 `sudo gitlab-rake` 替换为 `bundle exec rake`，并在命令末尾添加 `RAILS_ENV=production`。

<a id="common-task-examples"></a>

### 常见任务示例

<a id="verify-clickhouse-connection-and-schema"></a>

#### 验证 ClickHouse 连接和 schema

验证 ClickHouse 连接是否正常工作：

```shell
# 对于使用 Linux 软件包的安装
sudo gitlab-rake gitlab:clickhouse:info

# 对于自行编译的安装
bundle exec rake gitlab:clickhouse:info RAILS_ENV=production
```

此任务会输出 ClickHouse 连接和配置的调试信息。

<a id="re-run-all-migrations"></a>

#### 重新运行所有迁移

运行所有挂起的迁移：

```shell
# 对于使用 Linux 软件包的安装
sudo gitlab-rake gitlab:clickhouse:migrate

# 对于自行编译的安装
bundle exec rake gitlab:clickhouse:migrate RAILS_ENV=production
```

<a id="reset-the-database"></a>

#### 重置数据库

> [!warning]
> 这将删除 ClickHouse 数据库中的所有数据。仅应在开发环境中或排查问题时使用。

删除并重新创建数据库：

```shell
# 对于使用 Linux 软件包的安装
sudo gitlab-rake gitlab:clickhouse:drop
sudo gitlab-rake gitlab:clickhouse:setup

# 对于自行编译的安装
bundle exec rake gitlab:clickhouse:drop RAILS_ENV=production
bundle exec rake gitlab:clickhouse:setup RAILS_ENV=production
```

<a id="environment-variables"></a>

### 环境变量

您可以使用环境变量控制 Rake 任务的行为：

| 环境变量 | 数据类型 | 描述 |
|---------------------|-----------|-------------|
| `VERBOSE` | 布尔值 | 设置为 `true` 以在迁移期间查看详细输出。示例：`VERBOSE=true sudo gitlab-rake gitlab:clickhouse:migrate` |

<a id="performance-tuning"></a>

## 性能调优

> [!note]
> 有关基于用户数的资源规模和部署建议，请参阅[系统要求](#system-requirements)。

有关 ClickHouse 架构和性能调优的信息，请参阅[ClickHouse 架构文档](https://clickhouse.com/docs/architecture/introduction)。

<a id="disaster-recovery"></a>

## 灾难恢复

<a id="backup-and-restore"></a>

### 备份与恢复

升级极狐GitLab 应用程序之前，您应该执行完整备份。
ClickHouse 数据不包含在极狐GitLab 备份工具中。

备份和恢复策略取决于所选的部署方式。

<a id="clickhouse-cloud"></a>

#### ClickHouse Cloud

ClickHouse Cloud 会自动：

- 管理备份和恢复。
- 创建并保留每日备份。

您无需进行任何额外配置。

更多信息，请参阅[ClickHouse Cloud 备份](https://clickhouse.com/docs/cloud/manage/backups)。

<a id="clickhouse-for-gitlab-self-managed"></a>

#### 极狐GitLab 私有化部署的 ClickHouse

如果您管理自己的 ClickHouse 实例，应定期备份以确保数据安全：

- 首先对表（排除系统表，如 `metrics` 或 `logs`）执行完整的初次备份，将数据备份到[对象存储桶，例如 AWS S3](https://clickhouse.com/docs/en/operations/backup#configuring-backuprestore-to-use-an-s3-endpoint)。
- 在初次完整备份之后，执行[增量备份](https://clickhouse.com/docs/en/operations/backup#take-an-incremental-backup)。

每次完整备份都会复制数据，但这是[恢复数据最简单的方式](https://clickhouse.com/docs/en/operations/backup#restore-from-the-incremental-backup)。

或者，您也可以使用 [`clickhouse-backup`](https://github.com/Altinity/clickhouse-backup)。这是一个第三方工具，提供类似功能，并附带了计划任务和远程存储管理等额外特性。

<a id="monitoring"></a>

## 监控

为确保极狐GitLab 集成的稳定性，您应该监控 ClickHouse 集群的健康和性能。

<a id="clickhouse-cloud"></a>

### ClickHouse Cloud

ClickHouse Cloud 提供了原生的 [Prometheus 集成](https://clickhouse.com/docs/integrations/prometheus)，通过安全的 API 端点暴露指标。

生成 API 凭据后，您可以配置采集器从 ClickHouse Cloud 抓取指标。例如，配置一个 [Prometheus 部署](https://clickhouse.com/docs/integrations/prometheus#configuring-prometheus)。

<a id="clickhouse-for-gitlab-self-managed"></a>

### 极狐GitLab 私有化部署的 ClickHouse

ClickHouse 可以[以 Prometheus 格式暴露指标](https://clickhouse.com/docs/operations/server-configuration-parameters/settings#prometheus)。
要启用此功能：

1. 在 `config.xml` 中配置 `prometheus` 段，以在专用端口（默认为 `9363`）上暴露指标。

   ```xml
   <prometheus>
       <endpoint>/metrics</endpoint>
       <port>9363</port>
       <metrics>true</metrics>
       <events>true</events>
       <asynchronous_metrics>true</asynchronous_metrics>
   </prometheus>
   ```

1. 配置 Prometheus 或类似的兼容服务器，以抓取 `http://<clickhouse-host>:9363/metrics`。

<a id="metrics-to-monitor"></a>

### 需要监控的指标
您应该为以下指标设置告警，以检测可能影响极狐GitLab 功能的问题：

| 指标名称 | 描述 | 告警阈值（建议） |
| :--- | :--- | :--- |
| `ClickHouse_Metrics_Query` | 当前正在执行的查询数。突然激增可能表明存在性能瓶颈。 | 基线偏差（例如 `> 100`） |
| `ClickHouseProfileEvents_FailedSelectQuery` | 失败的 select 查询数 | 基线偏差（例如 `> 50`） |
| `ClickHouseProfileEvents_FailedInsertQuery` | 失败的 insert 查询数 | 基线偏差（例如 `> 10`） |
| `ClickHouse_AsyncMetrics_ReadonlyReplica` | 指示副本是否已进入只读模式（通常由于 ZooKeeper 连接丢失）。 | `> 0`（立即采取措施） |
| `ClickHouse_ProfileEvents_NetworkErrors` | 网络错误（连接重置/超时）。频繁的错误可能导致极狐GitLab 后台任务失败。 | 速率 `> 0` |

<a id="liveness-check"></a>

### 存活检查

如果 ClickHouse 在负载均衡器后面可用，您可以使用 HTTP `/ping` 端点检查存活状态。预期响应为 `Ok`，HTTP 状态码 200。

<a id="security-and-auditing"></a>

## 安全与审计

为确保数据安全并实现审计能力，请采用以下安全实践。

<a id="network-security"></a>

### 网络安全

- TLS 加密：配置 ClickHouse 服务器以[使用 TLS 加密](#network-security)来验证连接。

  在极狐GitLab 中配置连接 URL 时，应使用 `https://` 协议（例如 `https://clickhouse.example.com:8443`）来指定。
- IP 允许列表：将对 ClickHouse 端口（默认 `8443` 或 `9440`）的访问限制为仅极狐GitLab 应用程序节点和其他授权网络。

<a id="audit-logging"></a>

### 审计日志

极狐GitLab 应用程序不会为单个 ClickHouse 查询维护单独的审计日志。为了满足关于数据访问的特定要求（谁在何时查询了什么），您可以在 ClickHouse 端启用日志记录。

<a id="clickhouse-cloud"></a>

#### ClickHouse 云

在 ClickHouse 云中，查询日志记录默认启用。您可以通过查询 `system.query_log` 表来访问这些日志。

<a id="clickhouse-for-gitlab-self-managed"></a>

#### 极狐GitLab 私有化部署 ClickHouse

对于私有化部署实例，请确保在服务器配置中启用了 `query_log` 配置参数：

1. 验证 `query_log` 部分是否存在于您的 `config.xml` 或 `users.xml` 中：

   ```xml
   <query_log>
       <database>system</database>
       <table>query_log</table>
       <partition_by>toYYYYMM(event_date)</partition_by>
       <flush_interval_milliseconds>7500</flush_interval_milliseconds>
       <ttl>event_date + INTERVAL 30 DAY</ttl>  <!-- 仅保留 30 天 -->
   </query_log>
   ```

1. 启用后，所有执行的查询都会记录在 `system.query_log` 表中，从而实现审计跟踪。

<a id="system-requirements"></a>

## 系统要求

推荐的系统要求根据用户数量而变化。

<a id="deployment-decision-matrix-quick-reference"></a>

### 部署决策矩阵快速参考

| 用户数 | 主要推荐 | 等效 AWS ARM 实例 | 等效 GCP ARM 实例 | 等效 Azure ARM 实例 | 部署类型 |
|---|---|---|---|---|---|
| 1000 | ClickHouse Cloud Basic | - | - | - | 托管 |
| 2000 | ClickHouse Cloud Basic | `m8g.xlarge` | `c4a-standard-4` |  `Standard_D4ps_v6` | 托管或单节点 |
| 3000 | ClickHouse Cloud Scale | `m8g.2xlarge` | `c4a-standard-8` | `Standard_D8ps_v6` | 托管或单节点 |
| 5000 | ClickHouse Cloud Scale | `m8g.4xlarge` | `c4a-standard-16` | `Standard_D16ps_v6` | 托管或单节点 |
| 10000 | ClickHouse Cloud Scale | `m8g.4xlarge` | `c4a-standard-16` | `Standard_D16ps_v6` | 托管或单节点/高可用 |
| 25000 | 极狐GitLab 私有化部署 ClickHouse 或 ClickHouse Cloud Scale | `m8g.8xlarge` 或 3×`m8g.4xlarge` | `c4a-standard-32` 或 3×`c4a-standard-16` | `Standard_D32ps_v6` 或 3x`Standard_D16ps_v6` | 托管或单节点/高可用 |
| 50000 | 极狐GitLab 私有化部署 ClickHouse 高可用 (HA) 或 ClickHouse Cloud Scale | 3×`m8g.4xlarge` | 3×`c4a-standard-16` | 3x`Standard_D16ps_v6` | 托管或高可用集群 |

<a id="1k-users"></a>

### 1000 用户

推荐：ClickHouse Cloud Basic，因为它提供良好的成本效益且无运维复杂性。

<a id="2k-users"></a>

### 2000 用户

推荐：ClickHouse Cloud Basic，因为它提供最佳价值且无运维复杂性。

极狐GitLab 私有化部署 ClickHouse 的替代推荐：

- AWS：m8g.xlarge（4 vCPU，16 GB）
- GCP：c4a-standard-4 或 n4-standard-4（4 vCPU，16 GB）
- Azure：Standard_D4ps_v6（4 vCPU，16 GB）
- 存储：20 GB，低至中性能层

<a id="3k-users"></a>

### 3000 用户

推荐：ClickHouse Cloud Scale

极狐GitLab 私有化部署 ClickHouse 的替代推荐：

- AWS：m8g.2xlarge（8 vCPU，32 GB）
- GCP：c4a-standard-8 或 n4-standard-8（8 vCPU，32 GB）
- Azure：Standard_D8ps_v6（8 vCPU，32 GB）
- 存储：100 GB，中性能层

> [!note]
> 在此规模下，高可用部署不具备成本效益。

<a id="5k-users"></a>

### 5000 用户

推荐：ClickHouse Cloud Scale

极狐GitLab 私有化部署 ClickHouse 的替代推荐：

- AWS：m8g.4xlarge（16 vCPU，64 GB）
- GCP：c4a-standard-16 或 n4-standard-16（16 vCPU，64 GB）
- Azure：Standard_D16ps_v6（16 vCPU，64 GB）
- 存储：100 GB，高性能层
- 部署：推荐单节点

<a id="10k-users"></a>

### 10000 用户

推荐：ClickHouse Cloud Scale

极狐GitLab 私有化部署 ClickHouse 的替代推荐：

- AWS：m8g.4xlarge（16 vCPU，64 GB）
- GCP：c4a-standard-16 或 n4-standard-16（16 vCPU，64 GB）
- Azure：Standard_D16ps_v6（16 vCPU，64 GB）
- 存储：200 GB，高性能层
- 高可用选项：对于关键工作负载，3 节点集群变得可行

<a id="25k-users"></a>

### 25000 用户

推荐：ClickHouse Cloud Scale 或极狐GitLab 私有化部署 ClickHouse。两种方案在此规模下均经济可行。

极狐GitLab 私有化部署 ClickHouse 的推荐配置：

- 单节点：

  - AWS：m8g.8xlarge（32 vCPU，128 GB）
  - GCP：c4a-standard-32 或 n4-standard-32（32 vCPU，128 GB）
  - Azure：Standard_D32ps_v6（32 vCPU，128 GB）
- 高可用部署：

  - AWS：3 × m8g.4xlarge（每个 16 vCPU，64 GB）
  - GCP：3 × c4a-standard-16 或 3 × n4-standard-16（每个 16 vCPU，64 GB）
  - Azure：3 x Standard_D16ps_v6（每个 16 vCPU，64 GB）
- 存储：每节点 400 GB，高性能层。

<a id="50k-users"></a>

### 50000 用户

推荐：极狐GitLab 私有化部署 ClickHouse 高可用或 ClickHouse Cloud Scale。在此规模下，私有化部署选项略具成本效益。

极狐GitLab 私有化部署 ClickHouse 的推荐配置：

- 单节点：

  - AWS：m8g.8xlarge（32 vCPU，128 GB）
  - GCP：c4a-standard-32 或 n4-standard-32（32 vCPU，128 GB）
  - Azure：Standard_D32ps_v6（32 vCPU，128 GB）
- 高可用部署（首选）：

  - AWS：3 × m8g.4xlarge（每个 16 vCPU，64 GB）
  - GCP：3 × c4a-standard-16 或 3 × n4-standard-16（每个 16 vCPU，64 GB）
  - Azure：3 x Standard_D16ps_v6（每个 16 vCPU，64 GB）
- 存储：每节点 1000 GB，高性能层。

<a id="ha-considerations-for-clickhouse-for-gitlab-self-managed-deployment"></a>

#### 极狐GitLab 私有化部署 ClickHouse 的高可用考虑

高可用设置仅在 10000 用户或以上时才具有成本效益。

- 最少：三个 ClickHouse 节点用于法定人数。
- [ClickHouse Keeper](https://clickhouse.com/clickhouse/keeper)：三个节点用于协调（可以并置或分离）。
- 负载均衡器：推荐用于分发查询。
- 网络：节点之间的低延迟连接至关重要。

<a id="glossary"></a>

## 术语表

- 集群：一组协同工作以存储和处理数据的节点（服务器）。
- MergeTree：[`MergeTree`](https://clickhouse.com/docs/engines/table-engines/mergetree-family/mergetree) 是 ClickHouse 中一种表引擎，专为高数据摄取速率和大数据量设计。它是 ClickHouse 的核心存储引擎，提供列式存储、自定义分区、稀疏主索引以及支持后台数据合并等功能。
- 数据部分：磁盘上存储表数据一部分的物理文件。数据部分不同于分区，分区是使用分区键创建的表数据的逻辑划分。
- 副本：存储在 ClickHouse 数据库中的数据副本。您可以拥有任意数量的相同数据副本，以实现冗余和可靠性。副本与 ReplicatedMergeTree 表引擎结合使用，使 ClickHouse 能够在不同服务器之间保持多个数据副本同步。
- 分片：数据的一个子集。ClickHouse 始终至少有一个数据分片。如果您没有将数据拆分到多个服务器，则数据存储在一个分片中。如果超出单个服务器的容量，可以通过将数据分片到多个服务器来分担负载。
- TTL（生存时间）：生存时间（TTL）是 ClickHouse 的一项功能，可在一定时间后自动移动、删除或汇总列/行。这使您可以更有效地管理存储，因为您可以删除、移动或归档不再需要频繁访问的数据。

<a id="troubleshooting"></a>

## 故障排除

<a id="database-schema-migrations-on-gitlab-18-0-0-and-earlier"></a>

### 极狐GitLab 18.0.0 及更早版本上的数据库模式迁移

> [!warning]
> 在极狐GitLab 18.0.0 及更早版本上，针对 ClickHouse 24.x 和 25.x 运行数据库模式迁移可能会失败，并显示以下错误消息：
>
> ```plaintext
> 代码：344。DB::Exception：在 ReplacingMergeTree 中完全支持投影，需设置 deduplicate_merge_projection_mode = throw。请使用 deduplicate_merge_projection_mode 的 'drop' 或 'rebuild' 选项。
> ```
>
> 如果不运行所有迁移，ClickHouse 集成将无法工作。

要解决此问题并运行迁移：

1. 登录 [Rails 控制台](../administration/operations/rails_console.md#starting-a-rails-console-session)。
1. 执行以下命令：

   ```ruby
   ClickHouse::Client.execute("INSERT INTO schema_migrations (version) VALUES ('20231114142100'), ('20240115162101')", :main)
   ```

1. 再次迁移数据库：

   ```shell
   sudo gitlab-rake gitlab:clickhouse:migrate
   ```

这次数据库迁移应该会成功完成。

<a id="database-dictionary-read-support"></a>

### 数据库字典读取支持

从极狐GitLab 18.8 开始，极狐GitLab 开始使用 [ClickHouse 字典](https://clickhouse.com/docs/dictionary)进行数据反规范化。18.8 之前的 `GRANT` 语句未授予 `gitlab` 用户查询字典的权限，因此需要手动修改步骤：

1. 登录到：
   - 对于 ClickHouse 云，使用 ClickHouse SQL 控制台。
   - 对于极狐GitLab 私有化部署 ClickHouse，使用 `clickhouse-client`。
1. 运行以下命令，将 `PASSWORD_HERE` 替换为生成的密码。

{{< tabs >}}

{{< tab title="单节点或 ClickHouse 云" >}}

```sql
GRANT dictGet ON gitlab_clickhouse_main_production.* TO gitlab_app;
```

{{< /tab >}}

{{< tab title="极狐GitLab 私有化部署 ClickHouse 高可用" >}}

将 `CLUSTER_NAME_HERE` 替换为您的集群名称：

```sql
GRANT dictGet ON gitlab_clickhouse_main_production.* TO gitlab_app ON CLUSTER CLUSTER_NAME_HERE;
```

{{< /tab >}}

{{< /tabs >}}

如果不授予权限，ClickHouse 迁移（`CreateNamespaceTraversalPathsDict`）将失败，并显示以下错误：

```plaintext
DB::Exception：gitlab：权限不足。
```

授予权限后，可以安全地重试迁移（理想情况下，等待 1-2 小时直到分布式迁移锁清除）。

<a id="clickhouse-ci-job-data-materialized-view-data-inconsistencies"></a>

### ClickHouse CI 作业数据物化视图数据不一致

在极狐GitLab 18.5 及更早版本中，当 Sidekiq 工作进程在网络超时后重试时，可能会向 ClickHouse 表（如 `ci_finished_pipelines` 和 `ci_finished_builds`）插入重复数据。此问题导致物化视图在分析仪表板（包括 Runner 集群仪表板）中显示错误的聚合指标。

此问题已在极狐GitLab 18.9 中修复，并向后移植到 18.6、18.7 和 18.8。要解决此问题，请升级到极狐GitLab 18.6 或更高版本。

如果您已有重复数据，计划在极狐GitLab 18.10 中修复重建受影响的物化视图。如需帮助，请联系极狐GitLab 支持。