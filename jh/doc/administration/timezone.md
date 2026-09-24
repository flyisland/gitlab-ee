---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 更改你的时区
description: 更改实例的时区。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!NOTE]
> 用户可以在其[个人资料中设置时区](../user/profile/_index.md#set-your-time-zone)。
> 新用户没有默认时区，必须
> 明确设置后才能在其个人资料上显示。
> 在 JihuLab.com 上，默认时区为 UTC。

极狐GitLab 中的默认时区是 UTC，但你可以将其更改为你喜欢的时区。

要更新你的极狐GitLab 实例的时区：

1. 指定的时区必须是
   [tz 格式](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)。
   你可以使用 `timedatectl` 命令来查看可用的时区：

   ```shell
   timedatectl list-timezones
   ```

1. 更改时区，例如更改为 `America/New_York`。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

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

{{< tab title="Helm Chart (Kubernetes)" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     time_zone: 'America/New_York'
   ```

1. 保存文件并应用新值：

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

{{< tab title="自编译 (源代码)" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     gitlab:
       time_zone: 'America/New_York'
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于运行 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于运行 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}