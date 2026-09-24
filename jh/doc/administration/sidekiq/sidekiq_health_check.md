---
stage: Tenant Scale
group: Tenant Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Sidekiq 健康检查
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 为 Sidekiq 集群提供了就绪探针和存活探针，用于指示服务健康状况和可达性。这些端点
[可以提供给像 Kubernetes 这样的调度器](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)，
以便在系统就绪前暂停流量，或在必要时重启容器。

可以在[配置 Sidekiq](_index.md) 时设置健康检查服务器。

<a id="readiness"></a>

## 就绪状态

就绪探针检查 Sidekiq 工作进程是否准备好处理任务。

```plaintext
GET /readiness
```

如果服务器绑定到 `localhost:8092`，可以按如下方式探测进程集群的就绪状态：

```shell
curl "http://localhost:8092/readiness"
```

成功时，该端点返回 `200` HTTP 状态码，响应示例如下：

```json
{
   "status": "ok"
}
```

<a id="liveness"></a>

## 存活状态

检查 Sidekiq 集群是否在运行。

```plaintext
GET /liveness
```

如果服务器绑定到 `localhost:8092`，可以按如下方式探测进程集群的存活状态：

```shell
curl "http://localhost:8092/liveness"
```

成功时，该端点返回 `200` HTTP 状态码，响应示例如下：

```json
{
   "status": "ok"
}
```
 
