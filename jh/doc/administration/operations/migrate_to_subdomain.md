---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从相对 URL 迁移到子域名
description: Reconfigure a GitLab instance to use a subdomain instead of a relative URL.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以将极狐GitLab从相对 URL 配置迁移到子域名部署。

迁移期间的停机时间取决于您的部署架构和负载均衡器配置：

- 极狐GitLab 升级停机时间：对于单节点安装，重新配置极狐GitLab需要停机。对于具有负载均衡的多节点安装，你可以按照[零停机升级](../../update/zero_downtime.md)流程，通过按顺序更新节点来最小化停机时间。
- URL 切换期间的用户停机时间：影响取决于你的负载均衡器和 DNS 配置。在应用极狐GitLab配置更改之前，你可以配置负载均衡器或 DNS 将旧 URL 和新 URL 都路由到同一后端，从而在过渡期间最小化对用户的干扰。

> [!warning]
> 极狐GitLab必须配置为其将使用的实际 URL。你不能将极狐GitLab配置为一个 URL，然后使用负载均衡器向用户呈现不同的 URL，因为极狐GitLab在内部为 API 响应、电子邮件和 UI 元素生成绝对 URL。

<a id="migrate-to-a-subdomain"></a>

## 迁移到子域名

要从相对 URL 迁移到子域名：

1. 根据您的安装类型，更新极狐GitLab配置以禁用相对 URL 配置。

   {{< tabs >}}

   {{< tab title="Linux 安装包（Omnibus）" >}}

      编辑 `/etc/gitlab/gitlab.rb` 并更新 `external_url` 以使用新的子域名：

      ```ruby
      external_url "https://gitlab.example.com"
      ```

   {{< /tab >}}

   {{< tab title="Helm chart（Kubernetes）" >}}

      更新 [`global.hosts`](https://gitlab.cn/docs/charts/charts/globals/#configure-host-settings) 配置以使用新的子域名。

   {{< /tab >}}

   {{< tab title="自行编译（源代码）" >}}

      按照[在极狐GitLab中禁用相对 URL](../../install/relative_url.md#disable-relative-url-in-gitlab)操作。

   {{< /tab >}}

   {{< /tabs >}}

1. 要应用新的子域名配置，请按照适用于你的安装类型的[升级极狐GitLab实例](../../update/_index.md)流程进行操作。
1. 更改 URL 会更改所有远程 URL，因此你必须手动编辑任何指向你的极狐GitLab实例的本地仓库中的远程 URL。使用相对 URL 克隆的任何本地仓库的远程 URL 都指向旧路径，用户必须手动更新这些 URL。
1. 如果你必须在过渡期间保留现有链接，请[配置负载均衡器重定向](#configure-load-balancer-redirects)，将旧的相对 URL 重定向到新的子域名。

<a id="configure-load-balancer-redirects"></a>

## 配置负载均衡器重定向

在将极狐GitLab从相对 URL 迁移到子域名后，配置负载均衡器将旧相对 URL 重定向到新的子域名：

1. 确保你的负载均衡器拥有旧域名和新域名的 SSL 证书。
1. 配置 DNS 将两个域名解析到你的负载均衡器。
1. 向你的负载均衡器配置中添加重定向规则，这些规则应：
   - 检测指向旧域名、且路径以相对 URL 前缀开头的请求（例如，`/gitlab/`）。
   - 将请求重定向到新的子域名，并返回 301（永久重定向）状态码。
   - 通过从路径开头移除相对 URL 前缀来保留路径和查询参数。
1. 如果你拥有具有单独 URL 配置的极狐GitLab组件（如容器镜像仓库或 Pages），请为这些路径添加类似的重定向规则。