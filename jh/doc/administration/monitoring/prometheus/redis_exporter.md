---
stage: Shared responsibility based on functional area
group: Shared responsibility based on functional area
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Redis 导出器
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

[Redis 导出器](https://github.com/oliver006/redis_exporter) 使您能够测量各种 [Redis](https://redis.io) 指标。有关导出内容的更多信息，请[阅读上游文档](https://github.com/oliver006/redis_exporter/blob/master/README.md#whats-exported)。

对于自编译安装，您必须自行安装和配置它。

要启用 Redis 导出器：

1. [启用 Prometheus](_index.md#configuring-prometheus)。
1. 编辑 `/etc/gitlab/gitlab.rb`。
1. 添加（或找到并取消注释）以下行，确保它设置为 `true`：

   ```ruby
   redis_exporter['enable'] = true
   ```

1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

Prometheus 开始从暴露在 `localhost:9121` 的 Redis 导出器收集性能数据。

## 配置 Redis 导出器标志

您可以使用 `redis_exporter['flags']` 设置来传递[命令行标志](https://github.com/oliver006/redis_exporter/blob/master/README.md#command-line-flags)，并根据您的监控需求自定义 Redis 导出器的行为。

> [!note]
> `redis.addr` 不可用，因为该值由 `gitlab_rails[redis_*]` 值（例如 `gitlab_rails[redis_host]`）配置。

要配置 Redis 导出器标志：

1. 编辑 `/etc/gitlab/gitlab.rb`，并添加一些标志，例如：

   ```ruby
   redis_exporter['flags'] = {
     'redis.password' => 'your-redis-password',
     'namespace' => 'redis',
     'web.listen-address' => ':9121',
     'web.telemetry-path' => '/metrics'
   }
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```