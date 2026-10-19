---
stage: Analytics
group: Analytics Instrumentation
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 事件数据
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="data-tracking-for-product-usage-at-event-level"></a>

## 事件级产品使用数据跟踪

**重要提示**：从极狐GitLab 18.0 开始，极狐GitLab 私有化部署实例会收集事件级数据，从而提供更详细的产品使用情况洞察。此前，仅从极狐GitLab 私有化部署实例收集聚合指标。

有关产品使用数据收集变更的更多信息，请阅读博客文章[针对极狐GitLab 私有化部署的更精细产品使用洞察](https://about.gitlab.com/blog/more-granular-product-usage-insights-for-gitlab-self-managed-and-dedicated/)。

<a id="event-data"></a>

### 事件数据

事件数据跟踪极狐GitLab 平台内的交互（或操作）。这些交互或操作可能是用户发起的，例如启动 CI/CD 流水线、合并合并请求、触发 webhook 或创建议题。操作也可能来自后台系统处理，例如定时流水线成功执行。事件数据收集的重点是用户的操作以及与这些操作相关的元数据。

用户 ID 会经过假名化处理以保护隐私，极狐GitLab 不会进行任何重新识别或将指标与单个用户关联的处理。事件数据不包含源代码或存储在极狐GitLab 中的其他客户创建内容。

更多信息，另请参阅：

- [指标字典](https://metrics.gitlab.com/?status=active)，了解事件和指标列表
- [客户产品使用信息](https://handbook.gitlab.com/handbook/legal/privacy/customer-product-usage-information/)

<a id="benefits-of-event-data"></a>

### 事件数据的优势

事件级数据通过在不识别用户的情况下提供更精细的洞察，增强了 Service Ping 的多项优势。

- 主动支持：精细数据使我们的客户成功经理（CSM）和支持团队能够访问更详细的信息，从而可以深入分析并创建针对您组织独特需求的自定义指标，而不必依赖更笼统的聚合指标。
- 有针对性的指导：事件级数据可更深入地了解功能的使用方式，帮助我们发掘优化和改进的机会。数据的深度使我们能够提供更精确、可操作的建议，帮助您最大化极狐GitLab 的价值并改进您的工作流。
- 匿名基准报告：精细的事件数据通过关注详细的使用模式（而不仅仅是高层次的聚合数据），可与类似组织进行更准确、更相关的性能比较。

<a id="enable-or-disable-event-level-data-collection"></a>

### 启用或禁用事件级数据收集

> [!note]
> 如果启用了 Snowplow 跟踪，当您启用产品使用跟踪时，它会自动禁用。同一时间只能有一种数据收集方法处于活动状态。

要启用或禁用事件级数据收集：

1. 以具有管理员访问权限的用户身份登录。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **指标与分析**。
1. 展开**事件跟踪**。
1. 要启用该设置，选中**启用事件跟踪**复选框。要禁用该设置，清除该复选框。
1. 选择**保存更改**。

<a id="programmatically-configure-event-level-data-collection"></a>

### 以编程方式配置事件级数据收集

您可以使用以下任一方式以编程方式配置事件级数据收集：

- **初始默认值**：仅在首次安装时应用
- **环境变量覆盖**：在运行时应用，并优先于数据库设置

<a id="initial-defaults-installation-only"></a>

#### 初始默认值（仅安装时）

这些设置仅在极狐GitLab 初始安装期间应用。安装后更改这些设置不会产生任何效果。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

在 `/etc/gitlab/gitlab.rb`中将 `gitlab_rails['initial_gitlab_product_usage_data']` 设置为 `false`：

```ruby
gitlab_rails['initial_gitlab_product_usage_data'] = false
```

然后重新配置极狐GitLab：

```shell
sudo gitlab-ctl reconfigure
```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

在您的 values 文件中将 `global.appConfig.initialDefaults.gitlabProductUsageData` 设置为 `false`：

```yaml
global:
  appConfig:
    initialDefaults:
      gitlabProductUsageData: false
```

或通过命令行：

```shell
helm install gitlab gitlab/gitlab \
  --set global.appConfig.initialDefaults.gitlabProductUsageData=false
```

{{< /tab >}}

{{< /tabs >}}

<a id="environment-variable-override-runtime"></a>

#### 环境变量覆盖（运行时）

> [!note]
> 在极狐GitLab 18.9 中引入。

`GITLAB_PRODUCT_USAGE_DATA_ENABLED` 环境变量允许您在运行时控制事件级数据收集。设置后，此环境变量：

- 优先于数据库设置
- 无法通过管理 UI 更改（开关处于禁用状态）
- 立即生效，无需数据库迁移

这适用于：

- 需要自动化配置的气隙环境
- 需要在升级之间保持一致设置的部署
- 无法实际访问 UI 的自动化部署工作流

有效值为 `true` 或 `false`。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

在 `/etc/gitlab/gitlab.rb`中设置该环境变量：

```ruby
gitlab_rails['env']['GITLAB_PRODUCT_USAGE_DATA_ENABLED'] = 'false'
```

然后重新配置极狐GitLab：

```shell
sudo gitlab-ctl reconfigure
```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

在您的 values 文件中使用 `extraEnv` 设置该环境变量：

```yaml
gitlab:
  sidekiq:
    extraEnv:
      GITLAB_PRODUCT_USAGE_DATA_ENABLED: 'false'
  webservice:
    extraEnv:
      GITLAB_PRODUCT_USAGE_DATA_ENABLED: 'false'
```

或通过命令行：

```shell
helm upgrade gitlab gitlab/gitlab \
  --set gitlab.sidekiq.extraEnv.GITLAB_PRODUCT_USAGE_DATA_ENABLED='false' \
  --set gitlab.webservice.extraEnv.GITLAB_PRODUCT_USAGE_DATA_ENABLED='false'
```

{{< /tab >}}

{{< tab title="Docker" >}}

在启动容器时传入该环境变量：

```shell
docker run --env GITLAB_PRODUCT_USAGE_DATA_ENABLED=false registry.gitlab.cn/omnibus/gitlab-jh:latest
```

或在 Docker Compose 文件中：

```yaml
services:
  gitlab:
    image: registry.gitlab.cn/omnibus/gitlab-jh:latest
    environment:
      GITLAB_PRODUCT_USAGE_DATA_ENABLED: 'false'
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

在启动极狐GitLab 之前设置该环境变量：

```shell
export GITLAB_PRODUCT_USAGE_DATA_ENABLED=false
```

或将其添加到您的 systemd 服务文件或 init 脚本中。

{{< /tab >}}

{{< /tabs >}}

<a id="check-the-current-setting-source"></a>

#### 检查当前设置来源

当环境变量覆盖处于活动状态时，管理 UI 会显示一条警告横幅，指出该设置由环境变量控制，无法通过 UI 更改。

您也可以通过 API 检查设置来源：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  "https://gitlab.example.com/api/v4/application/settings" | jq '.gitlab_product_usage_data_enabled, .gitlab_product_usage_data_source'
```

`gitlab_product_usage_data_source` 字段返回以下值之一：

- `environment`：该设置由 `GITLAB_PRODUCT_USAGE_DATA_ENABLED` 环境变量控制
- `database`：该设置由数据库控制（可通过管理 UI 更改）

<a id="event-delivery-timing"></a>

### 事件传输时机

事件发生后几乎会立即传输到极狐GitLab。系统以小批量方式收集事件，收集到 10 个事件后即发送数据。这种方式可提供近乎实时的传输，同时保持高效的网络使用。

<a id="payload-size-and-compression"></a>

### 载荷大小和压缩

每个事件的 JSON 格式大小约为 10 kB。每批 10 个事件的未压缩载荷大小约为 100 kB。传输前会对载荷进行压缩，以尽量减少数据传输大小并优化性能。

<a id="event-data-logs"></a>

### 事件数据日志

事件级跟踪数据记录在 `product_usage_data.log` 文件中。此日志包含所跟踪产品使用事件的 JSON 格式条目，包括载荷信息和上下文数据。每一行代表一个单独的跟踪事件以及发送的所有数据。

该日志文件位于：

- Linux 软件包安装：`/var/log/gitlab/gitlab-rails/product_usage_data.log`
- 自行编译安装：`/home/git/gitlab/log/product_usage_data.log`

这些日志可让您全面了解数据传输情况，但它们专为安全团队检查而设计，而非用于功能使用情况分析。有关日志系统的更多详细信息，请参阅[日志系统文档](../logs/_index.md#product-usage-data-log)。
