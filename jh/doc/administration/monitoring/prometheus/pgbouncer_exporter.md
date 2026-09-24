---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: PgBouncer 导出器
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

[PgBouncer 导出器](https://github.com/prometheus-community/pgbouncer_exporter)使您能够测量各种 [PgBouncer](https://www.pgbouncer.org/) 指标。

对于自行编译的安装，您必须自行安装和配置它。

要启用 PgBouncer 导出器：

1. [启用 Prometheus](_index.md#configuring-prometheus)。
1. 编辑 `/etc/gitlab/gitlab.rb`。
1. 添加（或找到并取消注释）以下行，确保将其设置为 `true`：

   ```ruby
   pgbouncer_exporter['enable'] = true
   ```

1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

Prometheus 开始从 `localhost:9188` 上公开的 PgBouncer 导出器收集性能数据。

如果启用了 [`pgbouncer_role`](https://gitlab.cn/docs/omnibus/roles/#postgresql-roles) 角色，则 PgBouncer 导出器默认启用。