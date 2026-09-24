---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 衡量单体仓库性能的指标
---

要衡量单体仓库的服务器端性能，请使用以下指标。虽然这些是衡量 Gitaly 性能的通用指标，但它们对大型仓库尤其重要。

克隆和获取是最频繁的昂贵操作。当以系统资源消耗的百分比计算时，这些操作通常占 Gitaly 节点上系统资源的 90% 或更多。
你的日志和指标可以提供仓库健康状况的线索。

<a id="cpu-and-memory"></a>

## CPU 和内存

两个主要的远程过程调用（RPC）处理克隆和获取。使用 Gitaly 日志中的这些字段来检查仓库克隆和获取消耗了多少系统资源。
按以下任一字段过滤你的 Gitaly 日志以了解更多信息：

| 日志字段                         | 过滤值                                                                          | 描述 |
|:----------------------------------|:---------------------------------------------------------------------------------------------|:------------|
| `json.grpc.method`                | `PostReceivePack`                                                                            | 处理 HTTP 克隆和获取的远程过程调用。 |
| `json.grpc.method`                | `SSHReceivePack`                                                                             | 处理 SSH 克隆和获取的远程过程调用。 |
| `json.grpc.code`                  | `OK`                                                                                         | 远程过程调用是否成功处理了请求。 |
| `json.grpc.code`                  | `Canceled`                                                                                   | 可以显示客户端是否终止了连接。通常是由于超时。 |
| `json.grpc.code`                  | `ResourceExhausted`                                                                          | 表示机器是否同时产生了过多的 Git 进程。 |
| `json.user_id`                    | 发起克隆或获取的 `user_id`，格式为 `user-<user_id>`，例如 `user-22345` | 查找由单个用户产生的大量克隆或获取操作。 |
| `json.username`                   | 发起克隆或获取的用户名。                                               | 查找由单个用户产生的大量克隆或获取操作。 |
| `json.grpc.request.glRepository`  | 仓库，格式为 `project-<project_id>`，例如 `project-214`                      | 查找单个仓库的克隆和获取总数。 |
| `json.grpc.request.glProjectPath` | 仓库，格式为项目路径，例如 `my-org/coolproject`                       | 查找给定仓库的克隆和获取总数。 |

这些日志条目字段提供有关 CPU 和内存的信息：

| 要检查的日志字段       | 描述 |
|:---------------------------|:------------|
| `json.command.cpu_time_ms` | 由此远程过程调用产生的子进程所使用的 CPU 时间。 |
| `json.command.maxrss`      | 由此远程过程调用产生的子进程的内存消耗。 |

在此示例中，日志消息 `json.command.cpu_time_ms` 为 `420`，`json.command.maxrss` 为 `3342152`：

```json
{
    "command.count":2,
    "command.cpu_time_ms":420,
    "command.inblock":0,
    "command.majflt":0,
    "command.maxrss":3342152,
    "command.minflt":24316,
    "command.oublock":56,
    "command.real_time_ms":626,
    "command.spawn_token_fork_ms":4,
    "command.spawn_token_wait_ms":0,
    "command.system_time_ms":172,
    "command.user_time_ms":248,
    "component":"gitaly.StreamServerInterceptor",
    "correlation_id":"20HCB3DAEPLV08UGNIYT9HJ4JW",
    "environment":"gprd",
    "feature_flags":"",
    "fqdn":"file-99-stor-gprd.c.gitlab-production.internal",
    "grpc.code":"OK",
    "grpc.meta.auth_version":"v2",
    "grpc.meta.client_name":"gitlab-workhorse",
    "grpc.meta.deadline_type":"none",
    "grpc.meta.method_operation":"mutator",
    "grpc.meta.method_scope":"repository",
    "grpc.meta.method_type":"bidi_stream",
    "grpc.method":"PostReceivePack",
    "grpc.request.fullMethod":"/gitaly.SmartHTTPService/PostReceivePack",
    "grpc.request.glProjectPath":"r2414/revenir/development/machinelearning/protein-ddg",
    "grpc.request.glRepository":"project-47506374",
    "grpc.request.payload_bytes":911,
    "grpc.request.repoPath":"@hashed/db/ab/dbabf83f57affedc9a001dc6c6f6b47bb431bd47d7254edd1daf24f0c38793a9.git",
    "grpc.request.repoStorage":"nfs-file99",
    "grpc.response.payload_bytes":54,
    "grpc.service":"gitaly.SmartHTTPService",
    "grpc.start_time":"2023-10-16T20:40:08.836",
    "grpc.time_ms":631.486,
    "hostname":"file-99-stor-gprd",
    "level":"info",
    "msg":"finished streaming call with code OK",
    "pid":1741362,
    "remote_ip":"108.163.136.48",
    "shard":"default",
    "span.kind":"server",
    "stage":"main",
    "system":"grpc",
    "tag":"gitaly",
    "tier":"stor",
    "time":"2023-10-16T20:40:09.467Z",
    "trace.traceid":"AAB3QAeD8G+H9VNmzOi2CztMAcJv1+g4+l1cAgA=",
    "type":"gitaly",
    "user_id":"user-14857500",
    "username":"ctx_ckottke",
  }
```

<a id="read-distribution"></a>

## 读取分布

要检查每个 Gitaly 节点的读取次数，请检查 `gitaly_praefect_read_distribution`。
此 Prometheus 指标是一个[计数器](https://prometheus.io/docs/concepts/metric_types/#counter)，
并有两个向量：

| 指标名称                         | 向量            | 描述 |
|-------------------------------------|-------------------|-------------|
| `gitaly_praefect_read_distribution` | `virtual_storage` | [虚拟存储](../../../../administration/gitaly/praefect/_index.md)名称。 |
| `gitaly_praefect_read_distribution` | `storage`         | Gitaly 存储名称。 |

<a id="pack-objects-cache"></a>

## 打包对象缓存

要检查[打包对象缓存](../../../../administration/gitaly/configure_gitaly.md#pack-objects-cache)，
请检查你的日志和 Prometheus 指标：

| 日志字段名称                        | 描述 |
|:--------------------------------------|:------------|
| `pack_objects_cache.hit`              | 当前打包对象缓存是否命中。（`true` 或 `false`） |
| `pack_objects_cache.key`              | 用于打包对象缓存的缓存键。 |
| `pack_objects_cache.generated_bytes`  | 正在写入的新缓存的大小（以字节为单位）。 |
| `pack_objects_cache.served_bytes`     | 正在提供的缓存的大小（以字节为单位）。 |
| `pack_objects.compression_statistics` | 打包对象生成的统计信息。 |
| `pack_objects.enumerate_objects_ms`   | 枚举客户端发送的对象所花费的总时间（以毫秒为单位）。 |
| `pack_objects.prepare_pack_ms`        | 在将包文件发送回客户端之前准备包文件所花费的总时间（以毫秒为单位）。 |
| `pack_objects.write_pack_file_ms`     | 将包文件发送回客户端所花费的总时间（以毫秒为单位）。高度依赖于客户端的互联网连接。 |
| `pack_objects.written_object_count`   | Gitaly 发送回客户端的对象总数。 |

示例日志消息：

```json
{
"bytes":26186490,
"correlation_id":"01F1MY8JXC3FZN14JBG1H42G9F",
"grpc.meta.deadline_type":"none",
"grpc.method":"PackObjectsHook",
"grpc.request.fullMethod":"/gitaly.HookService/PackObjectsHook",
"grpc.request.glProjectPath":"root/gitlab-workhorse",
"grpc.request.glRepository":"project-2",
"grpc.request.repoPath":"@hashed/d4/73/d4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35.git",
"grpc.request.repoStorage":"default",
"grpc.request.topLevelGroup":"@hashed",
"grpc.service":"gitaly.HookService",
"grpc.start_time":"2021-03-25T14:57:52.747Z",
"level":"info",
"msg":"finished unary call with code OK",
"peer.address":"@",
"pid":20961,
"span.kind":"server",
"system":"grpc",
"time":"2021-03-25T14:57:53.543Z",
"pack_objects.compression_statistics": "Total 145991 (delta 68), reused 6 (delta 2), pack-reused 145911",
"pack_objects.enumerate_objects_ms": 170,
"pack_objects.prepare_pack_ms": 7,
"pack_objects.write_pack_file_ms": 786,
"pack_objects.written_object_count": 145991,
"pack_objects_cache.generated_bytes": 49533030,
"pack_objects_cache.hit": "false",
"pack_objects_cache.key": "123456789",
"pack_objects_cache.served_bytes": 49533030,
"peer.address": "127.0.0.1",
"pid": 8813,
}
```

| Prometheus 指标名称                    | 向量   | 描述 |
|:------------------------------------------|:---------|:------------|
| `gitaly_pack_objects_served_bytes_total`  |          | 正在提供的缓存的大小（以字节为单位）。 |
| `gitaly_pack_objects_cache_lookups_total` | `result` | 缓存查找结果是 `hit`（命中）还是 `miss`（未命中）。 |