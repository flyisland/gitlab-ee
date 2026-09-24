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

性能栏可直接在你的浏览器中显示实时指标，让你无需查看日志或运行独立的性能分析工具即可获得洞察。

对于开发团队而言，性能栏可以精确地显示他们应该重点努力的方面，从而简化了调试过程。

![性能栏](img/performance_bar_v14_4.png)

<a id="available-information"></a>

## 可用信息

{{< history >}}

- Rugged 调用在极狐GitLab 16.6 中[移除](https://gitlab.com/gitlab-org/gitlab/-/issues/421591)。

{{< /history >}}

从左到右，性能栏会显示：

- **当前主机**：当前正在提供页面的主机。
- **数据库查询**：数据库查询所花费的时间（以毫秒为单位）和查询总数，以 `00ms / 00（00 已缓存）pg` 格式显示。选择后会显示一个包含更多详细信息的对话框。你可以使用它来查看每个查询的以下详细信息：
  - **在事务中**：如果查询是在事务的上下文中执行的，则会显示在查询下方。
  - **角色**：当[数据库负载均衡](../../postgresql/database_load_balancing.md)启用时出现。它显示查询使用了哪个服务器角色。
    “主”表示查询被发送到了读写主服务器。
    “副本”表示查询被发送到了只读副本。
  - **配置名称**：用于区分针对不同
    极狐GitLab 功能配置的不同数据库。显示的名称与
    极狐GitLab 中用于配置数据库连接所使用的名称相同。
- **Gitaly 调用**：花费的时间（以毫秒为单位）和 [Gitaly](../../gitaly/_index.md) 调用的总数。选择后会显示一个包含更多详细信息的对话框。
- **Redis 调用**：花费的时间（以毫秒为单位）和 Redis 调用的总数。选择后会显示一个包含更多详细信息的对话框。
- **Elasticsearch 调用**：花费的时间（以毫秒为单位）和 Elasticsearch 调用的总数。选择后会显示一个包含更多详细信息的对话框。
- **外部 HTTP 调用**：花费的时间（以毫秒为单位）和对外部系统调用的总数。选择后会显示一个包含更多详细信息的对话框。
- **页面的加载时序**：如果你的浏览器支持加载时序，则会显示几个以毫秒为单位、由斜杠分隔的值。
  选择后会显示一个包含更多详细信息的对话框。从左到右的值依次为：
  - **后端**：加载基础页面所需的时间。
  - [**首次内容绘制**](https://developer.chrome.com/docs/lighthouse/performance/first-contentful-paint/)：
    直到用户可以看到某些内容的时间。如果你的浏览器不支持此功能，则显示 `NaN`。
  - [**DomContentLoaded**](https://web.dev/articles/critical-rendering-path/measure-crp) 事件。
  - **页面加载的请求总数**。
- **内存**：在所选的请求期间消耗的内存量以及分配的对象数量。
  选择它会显示一个包含更多详细信息的窗口。
- **追踪**：如果集成了 Jaeger，**追踪** 会链接到一个 Jaeger 追踪页面，
  该页面包含了当前请求的 `correlation_id`。
- **+**：用于将某个请求的详细信息添加到性能栏的链接。可以通过其完整 URL（以当前用户身份认证）或其 `X-Request-Id` 标头的值来添加该请求。
- **下载**：用于下载用于生成性能栏报告的原始 JSON 的链接。
- **内存报告**：生成当前 URL 的内存性能分析报告的链接。
- **模式火焰图**：以所选的 [Stackprof 模式](https://github.com/tmm1/stackprof#sampling)生成当前 URL 的火焰图的链接：
  - **Wall** 模式每隔墙上的时钟时间间隔进行采样，间隔设置为 `10100` 微秒。
  - **CPU** 模式每隔 CPU 活动的时间间隔进行采样，间隔设置为 `10100` 微秒。
  - **Object** 模式每隔一定数量的分配进行采样，间隔设置为 `100` 次分配。
- **请求选择器**：一个显示在性能栏右侧的选择框，使你能够查看在当前页面打开期间发出的任何请求的这些指标。每个唯一 URL 只会捕获前两个请求。
- **统计信息**（可选）：如果设置了 `GITLAB_PERFORMANCE_BAR_STATS_URL` 环境变量，则此 URL 会显示在性能栏中。仅在 JihuLab.com 上使用。

> [!note]
> 并非所有指标在所有环境中都可用。例如，内存视图需要运行 Ruby 时应用[特定补丁](https://gitlab.com/gitlab-org/gitlab-build-images/-/blob/master/patches/ruby/2.7.4/thread-memory-allocations-2.7.patch)。当使用 [GDK](https://gitlab.com/gitlab-org/gitlab-development-kit) 在本地运行极狐GitLab 时，通常不是这种情况，因此无法使用内存视图。

<a id="keyboard-shortcut"></a>

## 键盘快捷键

按 [<kbd>p</kbd> + <kbd>b</kbd> 键盘快捷键](../../../user/shortcuts.md) 以显示性能栏，再次按下则隐藏它。

对于非管理员用户，必须先[为他们启用](#enable-the-performance-bar-for-non-administrators)才能显示性能栏。

<a id="request-warnings"></a>

## 请求警告

超出预定义限制的请求会在指标旁边显示一个警告 {{< icon name="warning" >}} 图标和说明。在此示例中，Gitaly 调用持续时间超出了阈值。

![Gitaly 调用持续时间超出阈值](img/performance_bar_gitaly_threshold_v12_4.png)

<a id="enable-the-performance-bar-for-non-administrators"></a>

## 为非管理员启用性能栏

性能栏默认对非管理员用户禁用。要为某个群组启用它：

1. 以具有管理员访问权限的用户身份登录。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **指标和分析**。
1. 展开 **分析 - 性能栏**。
1. 选择 **允许非管理员访问性能栏**。
1. 在 **允许以下群组成员访问** 字段中，提供允许访问性能栏的群组的完整路径。
1. 选择 **保存更改**。
