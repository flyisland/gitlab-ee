---
title: Geo SSH 代理默认启用
tier: [ Premium, Ultimate ]
offering: [ self_managed ]
stage: GitLab Dedicated
documentation_link: '../../../administration/geo/replication/troubleshooting/ssh_proxying'
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/454707"
categories: [ Geo Replication ]
---

Geo SSH 代理默认启用

以下功能标志在极狐GitLab 19.4 中默认启用：

- `geo_proxy_fetch_ssh_to_primary`
- `geo_proxy_push_ssh_to_primary`

当操作被代理到主站点时，Geo SSH 代理为向 Geo 从站点发起的 SSH 拉取和推送提供了更可靠的路径。它还修复了长期存在的代理操作失败缺陷，例如
[带推送选项的推送](https://gitlab.com/gitlab-org/gitlab/-/issues/417186)和
[从大型代码仓库拉取](https://gitlab.com/gitlab-org/gitlab/-/issues/454707)。

**Cloud Native GitLab 部署需要采取的操作**

使用**内置 NGINX Ingress**的 Cloud Native GitLab 部署必须执行以下任一操作：

- 在此次推出之前升级为使用 [Gateway API 与 Envoy Gateway](https://gitlab.cn/docs/charts/installation/migration/envoy_gateway_migration/)，**或**
- 在推出后禁用这两个功能标志。

否则，通过 Geo 从站点进行的 SSH 拉取和推送可能会挂起或超时。

有关 SSH 代理的更多信息，请参阅 [Geo 故障排除文档](../../../administration/geo/replication/troubleshooting/ssh_proxying.md)。
