---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 Geo 客户端和 HTTP 响应代码错误
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="fixing-client-errors"></a>

## 修复客户端错误

<a id="authorization-errors-from-lfs-https-client-requests"></a>

### LFS HTTP(S) 客户端请求的授权错误

如果您运行的 [Git LFS](https://git-lfs.com/) 版本低于 2.4.2，可能会遇到问题。如[此身份验证问题](https://github.com/git-lfs/git-lfs/issues/3025)所述，由从站点重定向到主站点的请求无法正确发送
Authorization 请求头。这可能导致无限 `Authorization <-> Redirect`
循环，或出现 Authorization 错误消息。

<a id="repair-oauth-authorization-between-geo-sites"></a>

### 修复 Geo 站点之间的 OAuth 授权

升级 Geo 站点时，您可能无法登录仅使用 OAuth 进行身份验证的从站点。在这种情况下，请在主站点上启动 [Rails 控制台](../../../operations/rails_console.md)会话，并执行以下步骤：

1. 要找到受影响的节点，请先列出您拥有的所有 Geo 节点：

   ```ruby
   GeoNode.all
   ```

1. 通过指定 ID 修复受影响的 Geo 节点：

   ```ruby
   GeoNode.find(<id>).repair
   ```

<a id="http-response-code-errors"></a>

## HTTP 响应代码错误

<a id="secondary-site-returns-502-errors-with-geo-proxying"></a>

### 从站点在使用 Geo 代理时返回 502 错误

当启用[从站点的 Geo 代理](../../secondary_proxy/_index.md)后，从站点的用户界面返回 502 错误，可能是从主站点代理过来的响应头过大。

检查 NGINX 日志中是否有类似以下示例的错误：

```plaintext
2022/01/26 00:02:13 [error] 26641#0: *829148 upstream sent too big header while reading response header from upstream, client: 10.0.2.2, server: geo.staging.gitlab.com, request: "POST /users/sign_in HTTP/2.0", upstream: "http://unix:/var/opt/gitlab/gitlab-workhorse/sockets/socket:/users/sign_in", host: "geo.staging.gitlab.com", referrer: "https://geo.staging.gitlab.com/users/sign_in"
```

要解决此问题：

1. 在从站点所有 Web 节点的 `/etc/gitlab.rb`中设置 `nginx['proxy_custom_buffer_size'] = '8k'`。
1. 使用 `sudo gitlab-ctl reconfigure` 重新配置从站点。

如果仍然出现此错误，您可以重复之前的步骤并更改 `8k` 大小来进一步增大缓冲区，例如将其加倍为 `16k`。

<a id="geo-admin-area-shows-unknown-for-health-status-and-request-failed-with-status-code-401"></a>

### Geo 管理区域显示健康状态为 `Unknown` 以及“Request failed with status code 401”

如果使用负载均衡器，请确保将负载均衡器的 URL 设置为负载均衡器后面节点的 `/etc/gitlab/gitlab.rb`中的 `external_url`。

在主站点上，转到**管理员** > **Geo** > **设置**，找到 **允许的 Geo IP** 字段。确保其中列出了从站点的 IP 地址。

<a id="primary-site-returns-500-error-when-accessing-admingeoreplicationprojects"></a>

### 主站点在访问 `/admin/geo/replication/projects` 时返回 500 错误

在 Geo 主站点上导航到**管理员** > **Geo** > **复制**（或 `/admin/geo/replication/projects`）时，会显示 500 错误，而同一链接在从站点上可以正常工作。主站点的 `production.log`中有类似以下内容的条目：

```plaintext
Geo::TrackingBase::SecondaryNotConfigured: Geo secondary database is not configured
  from ee/app/models/geo/tracking_base.rb:26:in `connection'
  [..]
  from ee/app/views/admin/geo/projects/_all.html.haml:1
```

在 Geo 主站点上，可以忽略此错误。

出现此问题的原因是极狐GitLab 尝试显示来自 [Geo 跟踪数据库](../../_index.md#geo-tracking-database)的注册表，而该数据库在主站点上不存在（主站点上只存在原始项目；不存在复制的项目，因此不存在跟踪数据库）。

<a id="secondary-site-returns-400-error-request-header-or-cookie-too-large"></a>

### 从站点返回 400 错误 `Request header or cookie too large`

当主站点的内部 URL 不正确时，可能会发生此错误。

例如，当您使用统一 URL 且主站点的内部 URL 也等于外部 URL 时。这会导致从站点将请求代理到主站点的内部 URL 时出现循环。

要解决此问题，请将主站点的内部 URL 设置为满足以下条件的 URL：

- 主站点独有。
- 可从所有从站点访问。

1. 访问主站点。
1. [设置内部 URL](../../../geo_sites.md#set-up-the-internal-urls)。

<a id="geo-admin-area-returns-404-error-for-a-secondary-site"></a>

### Geo 管理区域对从站点返回 404 错误

有时 `sudo gitlab-rake gitlab:geo:check` 表明从站点的 Rails 节点运行正常，但在主站点的 Web 界面上的 Geo **管理**区域中却返回从站点的 404 Not Found 错误消息。

要解决此问题：

- 尝试使用 `sudo gitlab-ctl restart` 重启从站点上的每个 Rails、Sidekiq 和 Gitaly 节点。
- 检查 Sidekiq 节点上的 `/var/log/gitlab/gitlab-rails/geo.log`，查看从站点是否
  使用 IPv6 将其状态发送到主站点。如果是，请在主站点的
  `/etc/hosts` 文件中添加一条使用 IPv4 的条目。或者，您应
  [在主站点上启用 IPv6](https://gitlab.cn/docs/omnibus/settings/nginx/#setting-the-nginx-listen-address-or-addresses)。

<a id="websocket-requests-fail-on-geo-secondary-sites"></a>

## WebSocket 请求在 Geo 从站点上失败

使用依赖 WebSocket 的功能（例如极狐GitLab Duo Chat、议题实时更新或其他实时功能）时，连接可能会在 Geo 从站点上失败并返回 404 错误。

出现此问题的原因是 WebSocket 请求会经由从站点代理到主站点。在主站点上，必须将 ActionCable 配置为允许来自所有 Geo 站点的 WebSocket 请求。默认情况下，ActionCable 仅允许来自本地站点的请求。

要解决此问题，请根据您的安装类型配置 `action_cable_allowed_origins`：

- [Linux 软件包的 Geo 文档](../configuration.md#add-primary-and-secondary-urls-as-allowed-actioncable-origins)
- [Helm chart 的 Geo 文档](https://gitlab.cn/docs/charts/advanced/geo/#configure-primary-database)
