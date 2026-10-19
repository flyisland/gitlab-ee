---
stage: Async
group: Async
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Sidekiq 健康检查
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 提供存活探针和就绪探针，用于指示 Sidekiq 集群的服务健康状况和可达性。这些端点
[可以提供给 Kubernetes 等调度器](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)，
以便在系统就绪前暂缓接收流量，或根据需要重启容器。

健康检查服务器可以在[配置 Sidekiq](_index.md) 时设置。

<a id="readiness"></a>

## 就绪

就绪探针检查 Sidekiq 工作进程是否已准备好处理作业。

```plaintext
GET /readiness
```

如果服务器绑定到 `localhost:8092`，可以按如下方式探测进程集群的就绪状态：

```shell
curl "http://localhost:8092/readiness"
```

成功时，该端点会返回 `200` HTTP 状态码，以及类似如下的响应：

```json
{
   "status": "ok"
}
```

<a id="liveness"></a>

## 存活

检查 Sidekiq 集群是否正在运行。

```plaintext
GET /liveness
```

如果服务器绑定到 `localhost:8092`，可以按如下方式探测进程集群的存活状态：

```shell
curl "http://localhost:8092/liveness"
```

成功时，该端点会返回 `200` HTTP 状态码，以及类似如下的响应：

```json
{
   "status": "ok"
}
```
