---
stage: Systems
group: Cloud Connector
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab exporter
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用[极狐GitLab exporter](https://jihulab.com/gitlab-cn/ruby/gems/gitlab-exporter)监控你的极狐GitLab 实例的性能指标。
对于 Linux 软件包安装，极狐GitLab exporter 从 Redis 和数据库获取指标，并提供关于瓶颈、资源消耗模式和潜在优化领域的洞察。

对于自编译安装，你必须自行安装和配置它。

<a id="enable-gitlab-exporter"></a>

## 启用极狐GitLab exporter

要在 Linux 软件包实例中启用极狐GitLab exporter：

1. [启用 Prometheus](_index.md#configuring-prometheus)。
1. 编辑 `/etc/gitlab/gitlab.rb`。
1. 添加或查找并取消注释以下行，确保它设置为 `true`：

   ```ruby
   gitlab_exporter['enable'] = true
   ```

1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation)以使更改生效。

Prometheus 会自动开始从 `localhost:9168` 上暴露的极狐GitLab exporter 收集性能数据。

<a id="use-a-different-rack-server"></a>

## 使用不同的 Rack 服务器

默认情况下，极狐GitLab exporter 运行在 [WEBrick](https://github.com/ruby/webrick) 上，这是一个单线程 Ruby web 服务器。
你可以选择更符合你性能需求的 Rack 服务器。
例如，在包含大量 Prometheus 采集器但只有少数监控节点的多节点设置中，你可能会决定运行多线程服务器，如 Puma。

要将 Rack 服务器更改为 Puma：

1. 编辑 `/etc/gitlab/gitlab.rb`。
1. 添加或查找并取消注释以下行，并将其设置为 `puma`：

   ```ruby
   gitlab_exporter['server_name'] = 'puma'
   ```

1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation)以使更改生效。

支持的 Rack 服务器有 `webrick` 和 `puma`。