---
stage: Foundations
group: Global Search
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Zoekt
---

{{< details >}}

- Tier: 专业版, 旗舰版
- Offering: 私有化部署
- Status: Beta

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 15.9，作为 [beta](../../policy/development_stages_support.md#beta) 功能。使用名为 `index_code_with_zoekt` 和 `search_code_with_zoekt` 的[功能标志](../../administration/feature_flags.md)。默认禁用。
- 在极狐GitLab 16.6 中为 JihuLab.com 启用。
- 在极狐GitLab 17.1 中，[功能标志](../../administration/feature_flags.md) `index_code_with_zoekt` 和 `search_code_with_zoekt` 被移除。


{{< /history >}}

{{< alert type="warning" >}}

此功能处于 [beta](../../policy/development_stages_support.md#beta)，可能会在不通知的情况下进行变更。

{{< /alert >}}

Zoekt 是一个开源搜索引擎，专为搜索代码而设计。

通过这种集成，您可以使用[精确代码搜索](../../user/search/exact_code_search.md)来替代[高级搜索](../../user/search/advanced_search.md)在极狐GitLab中搜索代码。您可以使用精确匹配和正则表达式模式在群组或代码库中搜索代码。

<a id="install-zoekt"></a>

## 安装 Zoekt

前提条件：

- 您必须对实例拥有管理员访问权限。

要在极狐GitLab中[启用精确代码搜索](#enable-exact-code-search)，您必须至少有一个 Zoekt 节点连接到实例。支持以下 Zoekt 安装方法：

- [Zoekt chart](https://gitlab.cn/docs/charts/charts/gitlab/gitlab-zoekt/)（作为独立 chart 或极狐GitLab Helm chart 的子 chart）
- [极狐GitLab Operator](https://gitlab.cn/docs/operator/)（使用 `gitlab-zoekt.install=true`）

以下安装方法可用于测试，不适用于生产环境：

- Docker Compose
- Ansible playbook

<a id="enable-exact-code-search"></a>

## 启用精确代码搜索

前提条件：

- 您必须对实例拥有管理员访问权限。
- 您必须[安装 Zoekt](#install-zoekt)。

要在极狐GitLab中启用[精确代码搜索](../../user/search/exact_code_search.md)：

1. 在左侧边栏底部，选择 **管理员**。
1. 选择 **设置 > 搜索**。
1. 展开 **精确代码搜索配置**。
1. 勾选 **启用索引** 和 **启用搜索** 复选框。
1. 选择 **保存更改**。

<a id="check-indexing-status"></a>

## 检查索引状态

前提条件：

- 您必须对实例拥有管理员访问权限。

索引性能取决于 Zoekt 索引器节点上的 CPU 和内存限制。要检查索引状态：

   {{< tabs >}}

   {{< tab title="极狐GitLab 17.10 及更高版本" >}}

   运行此 Rake 任务：

   ```shell
   gitlab-rake gitlab:zoekt:info
   ```

   要使数据每 10 秒自动刷新一次，请运行此任务：

   ```shell
   gitlab-rake "gitlab:zoekt:info[10]"
   ```

   {{< /tab >}}

   {{< tab title="极狐GitLab 17.9 及更早版本" >}}

   在 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session)中，运行以下命令：

   ```ruby
   Search::Zoekt::Index.group(:state).count
   Search::Zoekt::Repository.group(:state).count
   Search::Zoekt::Task.group(:state).count
   ```

  {{< /tab >}}

   {{< /tabs >}}

<a id="delete-offline-nodes-automatically"></a>

## 自动删除离线节点

前提条件：

- 您必须对实例拥有管理员访问权限。

您可以自动删除离线超过 12 小时的 Zoekt 节点及其相关索引、代码库和任务。

要自动删除离线节点：

1. 在左侧边栏底部，选择 **管理员**。
1. 选择 **设置 > 搜索**。
1. 展开 **精确代码搜索配置**。
1. 勾选 **12 小时后删除离线节点** 复选框。
1. 选择 **保存更改**。

<a id="index-root-namespaces-automatically"></a>

## 自动索引根命名空间

前提条件：

- 您必须对实例拥有管理员访问权限。

您可以自动索引现有和新的根命名空间。要自动索引所有根命名空间：

1. 在左侧边栏底部，选择 **管理员**。
1. 选择 **设置 > 搜索**。
1. 展开 **精确代码搜索配置**。
1. 勾选 **自动索引根命名空间** 复选框。
1. 选择 **保存更改**。

启用此设置后，极狐GitLab 会为以下项目创建索引任务：

- 所有群组和子群组
- 任何新根命名空间

项目被索引后，极狐GitLab 仅在检测到代码库更改时创建增量索引。

禁用此设置时：

- 现有根命名空间保持索引状态。
- 新的根命名空间不再被索引。

<a id="pause-indexing"></a>

## 暂停索引

前提条件：

- 您必须对实例拥有管理员访问权限。

要暂停[精确代码搜索](../../user/search/exact_code_search.md)的索引：

1. 在左侧边栏底部，选择 **管理员**。
1. 选择 **设置 > 搜索**。
1. 展开 **精确代码搜索配置**。
1. 勾选 **暂停索引** 复选框。
1. 选择 **保存更改**。

暂停精确代码搜索的索引时，您代码库中的所有更改都会被排队。要恢复索引，清除 **暂停精确代码搜索的索引** 复选框。

<a id="set-concurrent-indexing-tasks"></a>

## 设置并发索引任务

前提条件：

- 您必须对实例拥有管理员访问权限。

您可以根据 Zoekt 节点的 CPU 容量设置并发索引任务的数量。

更高的倍数意味着更多任务可以同时运行，这将以增加 CPU 使用量为代价提高索引吞吐量。默认值为 `1.0`（每个 CPU 核心一个任务）。

您可以根据节点的性能和工作负载调整此值。要设置并发索引任务的数量：

1. 在左侧边栏底部，选择 **管理员**。
1. 选择 **设置 > 搜索**。
1. 展开 **精确代码搜索配置**。
1. 在 **索引 CPU 到任务倍数** 文本框中输入一个值。

   例如，如果一个 Zoekt 节点有 `4` 个 CPU 核心且倍数为 `1.5`，则该节点的并发任务数为 `6`。

1. 选择 **保存更改**。

<a id="run-zoekt-on-a-separate-server"></a>

## 在单独的服务器上运行 Zoekt

前提条件：

- 您必须对实例拥有管理员访问权限。

要在与极狐GitLab 不同的服务器上运行 Zoekt：

1. [更改 Gitaly 监听接口](../../administration/gitaly/configure_gitaly.md#change-the-gitaly-listening-interface)。
1. [安装 Zoekt](#install-zoekt)。

Zoekt 不支持任何身份验证，因此请确保：

- Zoekt 实例不对公众开放。
- 仅极狐GitLab 服务器可以通过防火墙策略或 IP 规则访问 Zoekt 服务器。

<a id="troubleshooting"></a>

## 故障排除

使用 Zoekt 时，您可能会遇到以下问题。

<a id="namespace-is-not-indexed"></a>

### 命名空间未被索引

当您[启用设置](#index-root-namespaces-automatically)时，新命名空间会自动被索引。如果命名空间未被自动索引，请检查 Sidekiq 日志以查看作业是否正在处理。`Search::Zoekt::SchedulingWorker` 负责索引命名空间。

在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)中，您可以检查：

- Zoekt 未启用的命名空间：

  ```ruby
  Namespace.group_namespaces.root_namespaces_without_zoekt_enabled_namespace
  ```

- Zoekt 索引状态：

  ```ruby
  Search::Zoekt::Index.all.pluck(:state, :namespace_id)
  ```

要手动索引命名空间，请运行以下命令：

```ruby
namespace = Namespace.find_by_full_path('<top-level-group-to-index>')
Search::Zoekt::EnabledNamespace.find_or_create_by(namespace: namespace)
```

<a id="error-silentmodeblockederror"></a>

### 错误：`SilentModeBlockedError`

当您尝试运行精确代码搜索时，可能会遇到 `SilentModeBlockedError`。此问题发生在极狐GitLab 实例上启用了[静默模式](../../administration/silent_mode)时。

要解决此问题，请确保静默模式已禁用。

<a id="error-connections-to-all-backends-failing"></a>

### 错误：`connections to all backends failing`

在 `application_json.log` 中，您可能会收到以下错误：

```plaintext
connections to all backends failing; last error: UNKNOWN: ipv4:1.2.3.4:5678: Trying to connect an http1.x server
```

要解决此问题，请检查您是否正在使用任何代理。如果是，请将极狐GitLab 服务器的 IP 地址设置为 `no_proxy`：

```ruby
gitlab_rails['env'] = {
  "http_proxy" => "http://proxy.domain.com:1234",
  "https_proxy" => "http://proxy.domain.com:1234",
  "no_proxy" => ".domain.com,IP_OF_GITLAB_INSTANCE,127.0.0.1,localhost"
}
```

`proxy.domain.com:1234` 是代理实例的域和端口。`IP_OF_GITLAB_INSTANCE` 指向极狐GitLab 实例的公共 IP 地址。

您可以通过运行 `ip a` 并检查以下之一获取此信息：

- 适当网络接口的 IP 地址
- 您使用的任何负载均衡器的公共 IP 地址

<a id="verify-zoekt-node-connections"></a>

### 验证 Zoekt 节点连接

要验证您的 Zoekt 节点是否配置正确并已连接，请在 [Rails 控制台会话](../../administration/operations/rails_console.md#starting-a-rails-console-session)中：

- 检查配置的 Zoekt 节点总数：

  ```ruby
  Search::Zoekt::Node.count
  ```

- 检查在线节点数量：

  ```ruby
  Search::Zoekt::Node.online.count
  ```

或者，您可以使用 `gitlab:zoekt:info` Rake 任务。

如果在线节点的数量低于配置节点的数量，或者在配置节点为零时，您可能在极狐GitLab 和您的 Zoekt 节点之间存在连接问题。
