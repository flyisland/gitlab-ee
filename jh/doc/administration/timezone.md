---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 更改时区
description: 更改实例的时区。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 用户可以在[个人资料中设置时区](../user/profile/_index.md#set-your-time-zone)。
> 新用户没有默认时区，必须
> 显式设置后才会显示在个人资料中。
> 在 JihuLab.com 上，默认时区为 UTC。

极狐GitLab 中的默认时区为 UTC，但您可以将其更改为您喜欢的时区。

要更新极狐GitLab 实例的时区：

1. 指定的时区必须采用
   [tz 格式](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)。
   您可以使用 `timedatectl` 命令查看可用的时区：

   ```shell
   timedatectl list-timezones
   ```

1. 更改时区，例如更改为 `America/New_York`。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['time_zone'] = 'America/New_York'
   ```

1. 保存文件，然后重新配置并重启极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   sudo gitlab-ctl restart
   ```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

1. 导出 Helm values：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     time_zone: 'America/New_York'
   ```

1. 保存文件并应用新的 values：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['time_zone'] = 'America/New_York'
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     gitlab:
       time_zone: 'America/New_York'
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # For systems running systemd
   sudo systemctl restart gitlab.target

   # For systems running SysV init
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}
