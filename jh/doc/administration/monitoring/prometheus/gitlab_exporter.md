---
stage: Systems
group: Cloud Connector
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GitLab exporter
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用 [GitLab exporter](https://gitlab.com/gitlab-org/ruby/gems/gitlab-exporter) 监控极狐GitLab 实例的性能指标。
对于 Linux 软件包安装，GitLab exporter 从 Redis 和数据库获取指标，
帮助您了解瓶颈、资源消耗模式以及潜在的优化方向。

对于自行编译的安装，您必须自行安装和配置它。

<a id="enable-gitlab-exporter"></a>

## 启用 GitLab exporter

要在 Linux 软件包实例中启用 GitLab exporter：

1. [启用 Prometheus](_index.md#configuring-prometheus)。
1. 编辑 `/etc/gitlab/gitlab.rb`。
1. 添加或找到并取消注释以下行，确保将其设置为 `true`：

   ```ruby
   gitlab_exporter['enable'] = true
   ```

1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效。

Prometheus 会自动开始从
`localhost:9168` 上公开的 GitLab exporter 收集性能数据。

<a id="use-a-different-rack-server"></a>

## 使用其他 Rack 服务器

默认情况下，GitLab exporter 运行在 [WEBrick](https://github.com/ruby/webrick) 上，这是一个单线程的 Ruby Web 服务器。
您可以选择其他更符合您性能需求的 Rack 服务器。例如，在包含大量 Prometheus 抓取器但只有少数监控节点的多节点设置中，您可能会决定改用多线程服务器，例如 Puma。

要将 Rack 服务器更改为 Puma：

1. 编辑 `/etc/gitlab/gitlab.rb`。
1. 添加或找到并取消注释以下行，并将其设置为 `puma`：

   ```ruby
   gitlab_exporter['server_name'] = 'puma'
   ```

1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation)
   以使更改生效。

支持的 Rack 服务器为 `webrick` 和 `puma`。
