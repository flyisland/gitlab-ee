---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 镜像仓库导出器
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

镜像仓库导出器允许您测量各种镜像仓库指标。
要启用它：

1. [启用 Prometheus](_index.md#configuring-prometheus)。
1. 编辑 `/etc/gitlab/gitlab.rb` 并启用容器镜像仓库的[调试模式](https://docs.docker.com/registry/#debug)：

   ```ruby
   registry['debug_addr'] = "localhost:5001"  # localhost:5001/metrics
   ```

1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation)以使更改生效。

Prometheus 会自动开始从 `localhost:5001/metrics` 下暴露的镜像仓库导出器收集性能数据。

[← 返回 Prometheus 主页](_index.md)