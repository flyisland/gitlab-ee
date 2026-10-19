---
stage: Developer Experience
group: Performance Enablement
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 性能栏
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

性能栏直接在您的浏览器中显示实时指标，让您无需查看日志或运行单独的剖析工具即可获得洞察。

对于开发团队，性能栏会准确显示他们应重点关注的位置，从而简化调试工作。

![性能栏](img/performance_bar_v14_4.png)

<a id="available-information"></a>

## 可用信息

从左到右，性能栏显示：

- **当前主机**：为页面提供服务的当前主机。
- **数据库查询**：数据库查询所花费的时间（以毫秒为单位）以及查询总数，
  显示格式为 `00ms / 00 (00 cached) pg`。选择后可显示
  包含更多详细信息的对话框。您可以使用它查看每个查询的以下
  详细信息：
  - **在事务中**：如果查询是在事务上下文中执行的，则会显示在查询下方
  - **角色**：当启用[数据库负载均衡](../../postgresql/database_load_balancing.md)
    时显示。它显示该查询使用了哪个服务器角色。
    “Primary”表示该查询被发送到读/写主服务器。
    “Replica”表示它被发送到只读副本。
  - **配置名称**：用于区分针对不同
    极狐GitLab 功能配置的不同数据库。显示的名称与在极狐GitLab 中配置数据库
    连接时使用的名称相同。
- **Gitaly 调用**：所花费的时间（以毫秒为单位）以及
  [Gitaly](../../gitaly/_index.md) 调用总数。选择后可显示包含更多
  详细信息的对话框。
- **Redis 调用**：所花费的时间（以毫秒为单位）以及
  Redis 调用总数。选择后可显示包含更多详细信息的对话框。
- **Elasticsearch 调用**：所花费的时间（以毫秒为单位）以及
  Elasticsearch 调用总数。选择后可显示包含更多详细信息的对话框。
- **外部 HTTP 调用**：所花费的时间（以毫秒为单位）以及
  对其他系统的外部调用总数。选择后可显示包含更多详细信息的
  对话框。
- **页面加载耗时**：如果您的浏览器支持加载耗时，则会显示若干
  以毫秒为单位的值，用斜杠分隔。
  选择后可显示包含更多详细信息的对话框。这些值从左到右依次为：
  - **后端**：基础页面加载所需的时间。
  - [**首次内容绘制**](https://developer.chrome.com/docs/lighthouse/performance/first-contentful-paint/)：
    直到用户看到内容所需的时间。如果您的浏览器不支持此功能，
    则显示 `NaN`。
  - [**DomContentLoaded**](https://web.dev/articles/critical-rendering-path/measure-crp) 事件。
  - 页面加载的**请求总数**。
- **内存**：所选请求期间消耗的内存量以及分配的对象数。
  选择后可显示包含更多详细信息的窗口。
- **追踪**：如果集成了 Jaeger，**追踪** 会链接到包含当前请求
  `correlation_id`的 Jaeger 追踪页面。
- **+**：用于将请求的详细信息添加到性能栏的链接。可以通过请求的完整 URL
  （以当前用户身份进行身份验证）或通过其 `X-Request-Id` 请求头的值来添加该请求。
- **下载**：用于下载生成性能栏报告所用原始 JSON 的链接。
- **内存报告**：生成当前 URL 的
  内存剖析
  报告的链接。
- **模式火焰图**：使用所选的 [Stackprof 模式](https://github.com/tmm1/stackprof#sampling)
  生成当前 URL 火焰图的链接：
  - **Wall** 模式按墙上时钟的每个时间间隔进行采样。间隔设置为 `10100` 微秒。
  - **CPU** 模式按 CPU 活动的每个间隔进行采样。间隔设置为 `10100` 微秒。
  - **Object** 模式按每个间隔进行采样。间隔设置为 `100` 次分配。
- **请求选择器**：显示在性能栏右侧的选择框，使您能够查看当前页面打开期间
  发出的任何请求的这些指标。每个唯一 URL 仅捕获前两个请求。
- **统计信息**（可选）：如果设置了 `GITLAB_PERFORMANCE_BAR_STATS_URL` 环境变量，
  则该 URL 会显示在栏中。仅在 JihuLab.com 上使用。

> [!note]
> 并非所有指标在所有环境中都可用。例如，内存视图
> 需要运行应用了[特定补丁](https://gitlab.com/gitlab-org/gitlab-build-images/-/blob/master/patches/ruby/2.7/thread-memory-allocations.patch)
> 的 Ruby。使用 [GDK](https://gitlab.com/gitlab-org/gitlab-development-kit) 在本地运行极狐GitLab 时，
> 通常并非如此，因此无法使用内存视图。

<a id="keyboard-shortcut"></a>

## 键盘快捷键

按 [<kbd>p</kbd> + <kbd>b</kbd> 键盘快捷键](../../../user/shortcuts.md)可显示性能栏，再次按下可将其隐藏。

要让非管理员显示性能栏，必须[为他们启用该功能](#enable-the-performance-bar-for-non-administrators)。

<a id="request-warnings"></a>

## 请求警告

超过预定义限制的请求会在指标旁边显示警告 {{< icon name="warning" >}} 图标和说明。在此示例中，Gitaly 调用时长超过了阈值。

![Gitaly 调用时长超过阈值](img/performance_bar_gitaly_threshold_v12_4.png)

<a id="warning-format"></a>

### 警告格式

每条警告消息遵循以下格式：

```plaintext
<metric> <type>: <actual> over <threshold>
```

例如，`es calls: 83 over 5` 表示 83 次 Elasticsearch 调用，
超过了 5 次的阈值。

有三种阈值类型可以触发警告：

- `calls`：请求期间对该服务发起的调用总数。
- `duration`：对该服务的所有调用所花费的总时间（以毫秒为单位）。
- `individual call`：对该服务的单次调用所花费的时间（以毫秒为单位）。
  单次调用警告会显示在该指标的详情对话框中，而不是栏本身。

<a id="metrics-and-default-thresholds"></a>

### 指标和默认阈值

以下指标在请求超过其阈值时会发出警告。生产环境与所有其他环境的阈值不同。表中标记为 `(development)`的值适用于所有非生产环境，例如开发环境和测试环境。此处显示的值反映了 `lib/peek/views/` 下源文件中定义的默认值。

| 指标 | 警告标签前缀 | 调用次数阈值 | 总时长阈值 | 单次调用阈值 |
|--------|---------------------|-----------------|--------------------------|---------------------------|
| Database (SQL) | `active-record` | 100 | 3,000 ms（开发环境）/ 15,000 ms（生产环境） | 1,000 ms（开发环境）/ 5,000 ms（生产环境） |
| Gitaly | `gitaly` | 30 | 1,000 ms | 500 ms |
| Elasticsearch | `es` | 5 | 1,000 ms | 1,000 ms |
| External HTTP | `external-http` | 10 | 1,000 ms | 100 ms |
| ClickHouse | `ch` | 5 | 1,000 ms | 1,000 ms |
| Zoekt | `zkt` | 3（开发环境）/ 5（生产环境） | 500 ms（开发环境）/ 1,000 ms（生产环境） | 500 ms（开发环境）/ 1,000 ms（生产环境） |

性能栏会跟踪并显示 Redis 调用，但未为其定义阈值，因此不会对 Redis 发出任何警告。

Bullet 指标是上述格式的例外。Bullet 会检测 N+1 查询，并且默认仅在开发环境中运行。当它处于活动状态时，会发出固定的 `Unoptimized queries detected` 警告，而不是基于阈值的 `<metric> <type>: <actual> over <threshold>` 消息。

数据库指标的生产环境阈值高于开发环境默认值，因为生产环境中的查询在更大的数据量下通常耗时更长。除 Zoekt 外，所有其他指标在各环境中使用相同的阈值。这些值是在源文件中定义的可配置默认值。如果阈值发生变化，源文件是权威参考。

<a id="when-a-warning-is-actionable"></a>

### 警告何时需要处理

警告表示某个请求使用的资源比典型页面预期的更多。使用以下指导来判断是否需要调查：

- 调用次数偏高（例如 `gitaly calls: 45 over 30`）通常表示存在 N+1 模式，
  即同一类型的调用在循环中重复。选择该指标以打开详情
  对话框，并查找参数相似的重复调用。
- 总时长偏高（例如 `active-record duration: 4500 over 3000`）意味着该服务
  整体较慢。检查是少量高开销调用导致的，还是
  许多小调用累积所致。
- 单次调用时长偏高会显示在详情对话框中该特定调用的旁边。
  单次缓慢调用通常指向缺少索引、负载过大或查询未优化。

某些警告在特定上下文中属于预期内的噪声：

- 跨多个项目或群组聚合数据的页面（例如仪表板或群组
  概览页面）比单一资源页面发起更多调用。
- 数据集较小的开发环境可能触发生产环境不会触发的时长警告，而生产环境的数据量
  可能触发开发环境不会触发的警告。

<a id="enable-the-performance-bar-for-non-administrators"></a>

## 为非管理员启用性能栏

默认情况下，非管理员无法使用性能栏。要为给定群组启用它：

1. 以具有管理员访问权限的用户身份登录。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **指标和剖析**。
1. 展开**剖析 - 性能栏**。
1. 选择**允许非管理员访问性能栏**。
1. 在**允许以下群组的成员访问**字段中，提供允许访问性能栏的
   群组的完整路径。
1. 选择**保存更改**。
