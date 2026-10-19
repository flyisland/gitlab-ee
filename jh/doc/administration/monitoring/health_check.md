---
stage: Facilitated functionality
group: Facilitated functionality
info: For more information, see <https://handbook.gitlab.com/handbook/product/categories/#facilitated-functionality>
gitlab_dedicated: no
title: 健康检查
description: 执行健康、存活和就绪检查。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 提供存活和就绪探针，用于指示服务健康状况以及能否访问所需服务。这些探针会报告数据库连接、Redis 连接和文件系统访问的状态。这些端点[可以提供给 Kubernetes 等调度器](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)，以便在系统就绪前暂不转发流量，或根据需要重启容器。

健康检查端点通常用于负载均衡器和其他 Kubernetes 调度系统，这些系统需要在转发流量前确定服务可用性。

您不应使用这些端点来确定大型 Kubernetes 部署的有效运行时间。这样做可能会在 pod 因自动扩缩、节点故障或其他正常且通常无中断的运维需求而被移除时，显示假阴性结果。

要确定大型 Kubernetes 部署的运行时间，请查看 UI 的流量。UI 流量经过适当的负载均衡和调度，因此能更好地反映有效运行时间。您也可以监控登录页面 `/users/sign_in` 端点。

<!-- vale gitlab_base.Spelling = NO -->

在 JihuLab.com 上，使用 [Pingdom](https://www.pingdom.com/) 等工具和 Apdex 测量来确定运行时间。

<!-- vale gitlab_base.Spelling = YES -->

<a id="ip-allowlist"></a>

## IP 允许名单

要访问监控资源，请求客户端的 IP 需要包含在允许名单中。有关详情，请参阅[如何将 IP 添加到监控端点的允许名单](ip_allowlist.md)。

<a id="using-the-endpoints-locally"></a>

## 在本地使用端点

在默认允许名单设置下，可以使用以下 URL 从 localhost 访问这些探针：

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

## 健康

检查应用服务器是否正在运行。它不会验证数据库或其他服务是否正在运行。此端点绕过 Rails 控制器，作为额外的中间件 `BasicHealthCheck` 在请求处理生命周期的很早期实现。

```plaintext
GET /-/health
```

示例请求：

```shell
curl "https://gitlab.example.com/-/health"
```

示例响应：

```plaintext
GitLab OK
```

<a id="comprehensive-health-check"></a>

## 综合健康检查

> [!warning]
> 请勿将 `/health_check` 用于负载均衡或自动扩缩。此端点会验证后端服务（数据库、Redis），如果这些服务缓慢或不可用，即使应用运行正常，该端点也会失败。这可能导致负载均衡器不必要地移除健康的应用程序节点。

`/health_check` 端点执行综合健康检查，包括数据库连接、Redis 可用性以及其他后端服务。它由 `health_check` gem 提供，并验证整个应用栈。

在以下情况使用此端点：

- 综合应用监控
- 后端服务健康验证
- 故障排除连接问题
- 监控仪表板和告警

```plaintext
GET /health_check
GET /health_check/database
GET /health_check/cache
GET /health_check/migrations
```

示例请求：

```shell
curl "https://gitlab.example.com/health_check"
```

示例响应（成功）：

```plaintext
success
```

示例响应（失败）：

```plaintext
health_check failed: Unable to connect to database
```

可用的检查：

- `database` - 数据库连接
- `migrations` - 数据库迁移状态
- `cache` - Redis 缓存连接
- `geo`（仅企业版）- Geo 复制状态

<a id="readiness"></a>

## 就绪

就绪探针检查极狐GitLab 实例是否已准备好通过 Rails 控制器接受流量。默认情况下，该检查仅验证实例检查。

如果指定了 `all=1` 参数，该检查还会验证依赖服务（数据库、Redis、Gitaly 等），并给出每项服务的状态。

```plaintext
GET /-/readiness
GET /-/readiness?all=1
```

示例请求：

```shell
curl "https://gitlab.example.com/-/readiness"
```

示例响应：

```json
{
   "master_check":[{
      "status":"failed",
      "message": "unexpected Master check result: false"
   }],
   ...
}
```

失败时，该端点返回 `503` HTTP 状态码。

此检查不受 Rack Attack 限制。

<a id="liveness"></a>

## 存活

> [!warning]
> 在极狐GitLab [12.4](https://about.gitlab.com/whats-new/)中，
> 存活检查的响应体已更改，
> 以与下面的示例保持一致。

检查应用服务器是否正在运行。此探针用于了解 Rails 控制器是否因多线程而出现死锁。

```plaintext
GET /-/liveness
```

示例请求：

```shell
curl "https://gitlab.example.com/-/liveness"
```

示例响应：

成功时，该端点返回 `200` HTTP 状态码，以及如下所示的响应。

```json
{
   "status": "ok"
}
```

失败时，该端点返回 `503` HTTP 状态码。

此检查不受 Rack Attack 限制。

<a id="sidekiq"></a>

## Sidekiq

了解如何配置 [Sidekiq 健康检查](../sidekiq/sidekiq_health_check.md)。
