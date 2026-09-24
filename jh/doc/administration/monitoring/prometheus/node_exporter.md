---
stage: Shared responsibility based on functional area
group: Shared responsibility based on functional area
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 节点导出器
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

[node exporter](https://github.com/prometheus/node_exporter) 使您能够测量各种机器资源，例如内存、磁盘和 CPU 利用率。

对于自编译安装，您必须自行安装和配置。

要启用节点导出器：

1. [启用 Prometheus](_index.md#configuring-prometheus)。
1. 编辑 `/etc/gitlab/gitlab.rb`。
1. 添加（或找到并取消注释）以下行，确保它设置为 `true`：

   ```ruby
   node_exporter['enable'] = true
   ```

1. 保存文件，并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

Prometheus 开始从暴露在 `localhost:9100` 的节点导出器收集性能数据。