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

{{< history >}}

- 切换 [启用] 于 极狐GitLab 17.11。
- 环境变量覆盖 [引入] 于 极狐GitLab 18.9。

{{< /history >}}

<a id="data-tracking-for-product-usage-at-event-level"></a>

## 基于事件级别的产品使用数据追踪

**重要**：从极狐GitLab 18.0 开始，私有化部署实例收集事件级数据，提供更详细的产品使用洞察。此前，私有化部署实例仅收集聚合指标。

有关产品使用数据收集变更的更多信息，请阅读博客文章
[适用于 极狐GitLab 私有化部署的更细粒度的产品使用洞察](https://gitlab.cn/blog/more-granular-product-usage-insights-for-gitlab-self-managed-and-dedicated/)。

<a id="event-data"></a>

### 事件数据

事件数据追踪极狐GitLab 平台内的交互（或动作）。
这些交互或动作可以是用户发起的，比如启动 CI/CD 流水线、合并合并请求、触发 Webhook 或创建议题。
动作也可能源于后台系统处理，如计划的流水线成功。
事件数据收集的重点在于用户的操作以及这些操作关联的元数据。

用户 ID 经过假名化处理以保护隐私，极狐GitLab 不会采取任何流程来重新识别或将指标与个人用户关联。
事件数据不包括存储在极狐GitLab 中的源代码或其他由客户创建的内容。

更多信息，请参见：

- [指标字典](https://metrics.gitlab.com/?status=active) 获取事件和指标列表
- [客户产品使用信息](https://handbook.gitlab.com/handbook/legal/privacy/customer-product-usage-information/)

<a id="benefits-of-event-data"></a>

### 事件数据的优势

事件级数据通过提供更细粒度的洞察而不识别用户，增强了 Service Ping 的多项优势。

- 主动支持：细粒度数据让我们的客户成功经理（CSM）和支持团队能够访问更详细的信息，使他们能够深入分析并创建根据您的组织独特需求定制的自定义指标，而不是依赖更通用的聚合指标。
- 精准指导：事件级数据提供了对功能使用方式的更深入理解，帮助我们发掘优化和改进的机会。数据深度使我们能够提供更精确、可操作的建议，帮助您最大化极狐GitLab 的价值并增强您的工作流程。
- 匿名化基准报告：细粒度事件数据通过关注详细的使用模式，而非仅高层聚合数据，使得与类似组织的性能比较更加准确和有意义。

<a id="enable-or-disable-event-level-data-collection"></a>

### 启用或禁用事件级数据收集

> [!note]
> 如果启用了 Snowplow 追踪，当启用产品使用追踪时，它将被自动禁用。一次只能激活一种数据收集方法。

要启用或禁用事件级数据收集：

1. 以管理员身份登录。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **指标与分析**。
1. 展开 **事件追踪**。
1. 要启用该设置，选中 **启用事件追踪** 复选框。要禁用该设置，清除复选框。
1. 选择 **保存更改**。

<a id="programmatically-configure-event-level-data-collection"></a>

### 编程式配置事件级数据收集

您可以通过以下两种方式编程式配置事件级数据收集：

- **初始默认值**：仅在首次安装时应用
- **环境变量覆盖**：在运行时应用，并优先于数据库设置

<a id="initial-defaults-installation-only"></a>

#### 初始默认值（仅安装时）

这些设置仅在 极狐GitLab 的初始安装期间生效。安装后更改这些设置无效。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

在 `/etc/gitlab/gitlab.rb` 中将 `gitlab_rails['initial_gitlab_product_usage_data']` 设为 `false`：

```ruby
gitlab_rails['initial_gitlab_product_usage_data'] = false
```

然后重新配置 极狐GitLab：

```shell
sudo gitlab-ctl reconfigure
```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

在您的 values 文件中将 `global.appConfig.initialDefaults.gitlabProductUsageData` 设为 `false`：

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
> 引入于 极狐GitLab 18.9。

`GITLAB_PRODUCT_USAGE_DATA_ENABLED` 环境变量允许您在运行时控制事件级数据收集。设置该环境变量后：

- 优先于数据库设置
- 无法通过管理员界面更改（切换开关被禁用）
- 立即生效，无需数据库迁移

这适用于：

- 需要自动化配置的离线环境
- 需要在升级过程中保持一致设置的部署
- 无法访问 UI 的自动化部署工作流

有效值为 `true` 或 `false`。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

在 `/etc/gitlab/gitlab.rb` 中设置环境变量：

```ruby
gitlab_rails['env']['GITLAB_PRODUCT_USAGE_DATA_ENABLED'] = 'false'
```

然后重新配置 极狐GitLab：

```shell
sudo gitlab-ctl reconfigure
```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

在您的 values 文件中使用 `extraEnv` 设置环境变量：

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

在启动容器时传递环境变量：

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

{{< tab title="自编译 (源码)" >}}

在启动 极狐GitLab 前设置环境变量：

```shell
export GITLAB_PRODUCT_USAGE_DATA_ENABLED=false
```

或将其添加到您的 systemd 服务文件或初始化脚本中。

{{< /tab >}}

{{< /tabs >}}

<a id="check-the-current-setting-source"></a>

#### 检查当前设置来源

当环境变量覆盖生效时，管理员界面会显示一条警告横幅，指出该设置由环境变量控制，无法通过 UI 更改。

您也可以通过 API 检查设置来源：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  "https://gitlab.example.com/api/v4/application/settings" | jq '.gitlab_product_usage_data_enabled, .gitlab_product_usage_data_source'
```

`gitlab_product_usage_data_source` 字段返回以下之一：

- `environment`：该设置由 `GITLAB_PRODUCT_USAGE_DATA_ENABLED` 环境变量控制
- `database`：该设置由数据库控制（可通过管理员界面更改）

<a id="event-delivery-timing"></a>

### 事件发送时机

事件几乎在发生后立即传输到 极狐GitLab。系统以小型批次收集事件，一旦收集到 10 个事件就会发送数据。这种方法在提供近实时交付的同时，保持了高效的网络使用。

<a id="payload-size-and-compression"></a>

### 有效载荷大小与压缩

每个事件在 JSON 格式中约为 10 kB。10 个事件的批次导致未压缩有效载荷大小约 100 kB。传输前，有效载荷会被压缩，以最小化数据传输大小并优化性能。

<a id="event-data-logs"></a>

### 事件数据日志

事件级追踪数据记录在 `product_usage_data.log` 文件中。该日志包含 JSON 格式的已追踪产品使用事件条目，包括有效载荷信息和上下文数据。每行代表一个独立的追踪事件及发送的所有数据。

日志文件位置：

- 在使用 Linux 软件包安装时：`/var/log/gitlab/gitlab-rails/product_usage_data.log`
- 在使用自编译安装时：`/home/git/gitlab/log/product_usage_data.log`

虽然这些日志提供了数据传输的全面可见性，但它们专门设计用于安全团队检查，而非功能使用分析。有关日志系统的更多详细信息，请参阅 [日志系统文档](../logs/_index.md#product-usage-data-log)。