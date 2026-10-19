---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从相对 URL 迁移到子域
description: 重新配置极狐GitLab 实例，改用子域而非相对 URL。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以将极狐GitLab 从相对 URL 配置迁移到子域部署。

迁移期间的停机时间取决于您的部署架构和负载均衡器配置：

- 极狐GitLab 升级停机时间：对于单节点安装，重新配置极狐GitLab 需要停机。对于带负载均衡的多节点安装，您可以按照[零停机升级](../../update/zero_downtime.md)流程，通过依次更新节点来最大程度减少停机时间。
- URL 切换期间面向用户的停机时间：影响取决于您的负载均衡器和 DNS 配置。在应用极狐GitLab 配置变更之前，您可以配置负载均衡器或 DNS，将新旧 URL 都路由到同一后端，从而最大程度减少过渡期间对用户的干扰。

> [!warning]
> 极狐GitLab 必须配置为使用其实际使用的 URL。您不能为极狐GitLab 配置一个 URL，却通过负载均衡器向用户呈现另一个 URL，
> 因为极狐GitLab 会为 API 响应、电子邮件和 UI 元素在内部生成绝对 URL。

<a id="migrate-to-a-subdomain"></a>

## 迁移到子域

要从相对 URL 迁移到子域：

1. 根据您的安装类型，更新极狐GitLab 配置以禁用相对 URL 配置。

   {{< tabs >}}

   {{< tab title="Linux 软件包（Omnibus）" >}}

   编辑 `/etc/gitlab/gitlab.rb`，并将 `external_url` 更新为使用新的子域：

   ```ruby
   external_url "https://gitlab.example.com"
   ```

   {{< /tab >}}

   {{< tab title="Helm chart（Kubernetes）" >}}

   更新 [`global.hosts`](https://gitlab.cn/docs/charts/charts/globals/#configure-host-settings) 配置以使用新的子域。

   {{< /tab >}}

   {{< tab title="自行编译（源代码）" >}}

   按照[在极狐GitLab 中禁用相对 URL](../../install/relative_url.md#disable-relative-url-in-gitlab) 操作。

   {{< /tab >}}

   {{< /tabs >}}

1. 要应用新的子域配置，请按照适用于您安装类型的[升级极狐GitLab 实例](../../update/_index.md)流程操作。
1. 更改 URL 会更改所有远程 URL，因此您必须在任何指向极狐GitLab 实例的本地代码仓库中手动编辑这些 URL。在使用相对 URL 时克隆的任何本地代码仓库，其远程 URL 都指向旧路径，用户必须手动更新这些 URL。
1. 如果您必须在过渡期间保留现有链接，请[配置负载均衡器重定向](#configure-load-balancer-redirects)，将旧的相对 URL 重定向到新的子域。

<a id="configure-load-balancer-redirects"></a>

## 配置负载均衡器重定向

将极狐GitLab 从相对 URL 迁移到子域后，配置负载均衡器将旧的相对 URL 重定向到新的子域：

1. 确保您的负载均衡器同时具有旧域名和新域名的 SSL 证书。
1. 配置 DNS，将两个域名都解析到您的负载均衡器。
1. 在负载均衡器配置中添加重定向规则，以便：
   - 检测对旧域名的请求，其路径以相对 URL 前缀开头（例如 `/gitlab/`）。
   - 以 301（永久重定向）状态将请求重定向到新的子域。
   - 从路径开头移除相对 URL 前缀，以保留路径和查询参数。
1. 如果您有使用单独 URL 配置的极狐GitLab 组件（例如容器镜像仓库或 Pages），请为这些路径添加类似的重定向规则。
