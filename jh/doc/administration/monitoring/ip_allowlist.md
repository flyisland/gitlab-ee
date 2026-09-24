---
stage: Systems
group: Cloud Connector
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: IP 允许列表
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 提供了一些[监控端点](health_check.md)，在被探测时会提供健康检查信息。

要通过 IP 允许列表控制对这些端点的访问，你可以添加单个主机或使用 IP 范围：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 打开 `/etc/gitlab/gitlab.rb` 并添加或取消注释以下内容：

   ```ruby
   gitlab_rails['monitoring_whitelist'] = ['127.0.0.0/8', '192.168.0.1']
   ```

1. 保存文件并[重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation)极狐GitLab 以使更改生效。

{{< /tab >}}

{{< tab title="Helm Chart (Kubernetes)" >}}

你可以在 `gitlab.webservice.monitoring.ipWhitelist` 键下设置所需的 IP。例如：

```yaml
gitlab:
   webservice:
      monitoring:
         # Monitoring IP allowlist
         ipWhitelist:
         # Defaults
         - 0.0.0.0/0
         - ::/0
```

{{< /tab >}}

{{< tab title="自编译 (源代码)" >}}

1. 编辑 `config/gitlab.yml`：

   ```yaml
   monitoring:
     # 默认情况下，仅允许本地 IP 访问监控资源
     ip_whitelist:
       - 127.0.0.0/8
       - 192.168.0.1
   ```

1. 保存文件并[重启](../restart_gitlab.md#self-compiled-installations)极狐GitLab 以使更改生效。

{{< /tab >}}

{{< /tabs >}}