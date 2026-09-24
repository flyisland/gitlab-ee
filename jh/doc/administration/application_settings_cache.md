---
stage: None
group: Unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 应用缓存间隔
description: 管理极狐GitLab 应用缓存。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

默认情况下，极狐GitLab 会将应用设置缓存 60 秒。有时你可能需要延长该间隔，以便在应用设置更改与用户注意到这些更改之间有更多的延迟。

我们建议将此值设置为大于 `0` 秒。将其设置为 `0` 将导致每次请求都加载 `application_settings` 表，这会增加 Redis 和 PostgreSQL 的额外负载。

<a id="change-the-expiration-interval-for-application-cache"></a>

## 更改应用缓存过期间隔

要更改过期值：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['application_settings_cache_seconds'] = 60
   ```

1. 保存文件，然后重新配置并重启极狐GitLab 以使更改生效：

   ```shell
   gitlab-ctl reconfigure
   gitlab-ctl restart
   ```

{{< /tab >}}

{{< tab title="自编译 (源代码)" >}}

1. 编辑 `config/gitlab.yml`：

   ```yaml
   gitlab:
     application_settings_cache_seconds: 60
   ```

1. 保存文件，然后[重启](restart_gitlab.md#self-compiled-installations)极狐GitLab 以使更改生效。

{{< /tab >}}

{{< /tabs >}}