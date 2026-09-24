---
stage: None - Facilitated functionality, see <https://handbook.gitlab.com/handbook/product/categories/#facilitated-functionality>
group: Unassigned - Facilitated functionality, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: 健康检查
description: 进行健康、存活和就绪检查。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 提供存活性探针和就绪性探针来指示服务健康状况以及所需服务的可达性。这些探针报告数据库连接、Redis 连接和文件系统访问的状态。这些端点[可以提供给 Kubernetes 等调度器](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)，以便在系统准备好之前暂停流量，或根据需要重启容器。

健康检查端点通常用于负载均衡器和其他需要在重定向流量之前确定服务可用性的 Kubernetes 调度系统。

你不应使用这些端点来确定大型 Kubernetes 部署的有效正常运行时间。这样做可能会在 Pod 因自动伸缩、节点故障或其他正常且无中断的操作需求而被移除时显示出错误的故障。

要确定大型 Kubernetes 部署的正常运行时间，请观察流向用户界面的流量。这些流量经过了恰当的均衡和调度，因此是有效正常运行时间的更佳指标。你也可以监控登录页面 `/users/sign_in` 端点。

<!-- vale gitlab_base.Spelling = NO -->

在 JihuLab.com 上，会使用 [Pingdom](https://www.pingdom.com/) 和 Apdex 测量等工具来确定正常运行时间。

<!-- vale gitlab_base.Spelling = YES -->

<a id="ip-allowlist"></a>

## IP 白名单

要访问监控资源，请求客户端的 IP 需要包含在白名单中。详情请参阅[如何将 IP 添加到监控端点的白名单](ip_allowlist.md)。

<a id="using-the-endpoints-locally"></a>

## 本地使用端点

使用默认白名单设置时，可以通过以下 URL 从 localhost 访问这些探针：

```plaintext
GET http://localhost/-/health
```

```plaintext
GET http://localhost/health_check
```

```plaintext
GET http://localhost/-/readiness
```

```plaintext
GET http://localhost/-/liveness
```

<a id="health"></a>

## 健康检查

检查应用服务器是否正在运行。
它不验证数据库或其他服务是否在运行。此端点绕过 Rails 控制器，并在请求处理生命周期的非常早期作为附加中间件 `BasicHealthCheck` 实现。

```plaintext
GET /-/health
```

请求示例：

```shell
curl "https://gitlab.example.com/-/health"
```

响应示例：

```plaintext
GitLab OK
```

<a id="comprehensive-health-check"></a>

## 综合健康检查

> [!warning]
> **不要将 `/health_check` 用于负载均衡或自动伸缩。** 此端点会验证后端服务（数据库、Redis），如果这些服务响应缓慢或不可用，即使应用本身运行正常，该端点也会失败。这可能会导致负载均衡器无端移除正常的应用节点。

`/health_check` 端点执行全面的健康检查，包括数据库连接、Redis 可用性以及其他后端服务。它由 `health_check` gem 提供，用于验证整个应用栈。

此端点用于：

- 全面的应用监控
- 后端服务健康验证
- 排查连接问题
- 监控仪表板和告警

```plaintext
GET /health_check
GET /health_check/database
GET /health_check/cache
GET /health_check/migrations
```

请求示例：

```shell
curl "https://gitlab.example.com/health_check"
```

响应示例（成功）：

```plaintext
success
```

响应示例（失败）：

```plaintext
health_check failed: Unable to connect to database
```

可用的检查项：

- `database` - 数据库连接
- `migrations` - 数据库迁移状态
- `cache` - Redis 缓存连接
- `geo`（仅限 EE）- Geo 复制状态

<a id="readiness"></a>

## 就绪性检查

就绪性探针检查极狐GitLab 实例是否已准备好通过 Rails 控制器接收流量。默认情况下，该检查仅验证实例检查项。

如果指定了 `all=1` 参数，该检查还将验证依赖服务（数据库、Redis、Gitaly 等），并给出每个服务的状态。

```plaintext
GET /-/readiness
GET /-/readiness?all=1
```

请求示例：

```shell
curl "https://gitlab.example.com/-/readiness"
```

响应示例：

```json
{
   "master_check":[{
      "status":"failed",
      "message": "unexpected Master check result: false"
   }],
   ...
}
```

失败时，端点返回 `503` HTTP 状态码。

此检查不受 Rack Attack 限制。

<a id="liveness"></a>

## 存活性检查

> [!warning]
> 在极狐GitLab [12.4](https://gitlab.cn/upcoming-releases/) 中，Liveness 检查的响应体已更改，以匹配下面的示例。

检查应用服务器是否正在运行。此探针用于了解 Rails 控制器是否因多线程而出现死锁。

```plaintext
GET /-/liveness
```

请求示例：

```shell
curl "https://gitlab.example.com/-/liveness"
```

响应示例：

成功时，端点返回 `200` HTTP 状态码，并返回如下所示的响应。

```json
{
   "status": "ok"
}
```

失败时，端点返回 `503` HTTP 状态码。

此检查不受 Rack Attack 限制。

<a id="sidekiq"></a>

## Sidekiq

了解如何配置 [Sidekiq 健康检查](../sidekiq/sidekiq_health_check.md)。