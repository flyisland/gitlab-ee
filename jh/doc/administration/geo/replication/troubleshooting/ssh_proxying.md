---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Geo SSH 响应代码错误故障排除
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="ssh-pull-and-push-hang-indefinitely-on-cloud-native-deployments-using-nginx-ingress"></a>

## 使用 NGINX Ingress 的 Cloud Native 部署中 SSH 拉取和推送无限期挂起

> [!note]
> 此问题仅影响使用内置 NGINX Ingress 的 Cloud Native GitLab 部署。
> 使用 Envoy 作为 Ingress 控制器的部署不受此问题影响。

当启用以下功能标志时，从使用 Helm Chart 部署的从站点进行 SSH 推送和拉取可能会无限期挂起：

- `geo_proxy_fetch_ssh_to_primary`
- `geo_proxy_push_ssh_to_primary`

这些功能标志会改变针对 Geo 从站点发起的 Git 操作的 SSH 代理路径。在极狐GitLab 19.4.0 及更高版本中，它们已默认启用。

该问题由 webservice Ingress 上的 NGINX 请求缓冲引起。GitLab Shell 发送流式请求正文，而 Git 客户端等待引用通告；NGINX 等待请求正文，Git 客户端等待响应，因此请求无法到达 Workhorse。

要解决此问题，请选择与您的部署相匹配的选项：

- 对于极狐GitLab 18.11 及更早版本：禁用这两个功能标志：
  - `geo_proxy_fetch_ssh_to_primary`
  - `geo_proxy_push_ssh_to_primary`
- 对于极狐GitLab 19.0 及更高版本：
  - 升级为使用 [Envoy Gateway](https://gitlab.cn/docs/charts/installation/migration/envoy_gateway_migration/) 作为 Ingress 控制器。

在使用内置 NGINX Ingress 时，请勿同时启用这两个功能标志。否则，用户可能无法通过 Geo 从站点完成 SSH 拉取或推送。

有关技术细节，请参见 [Geo 代理的 Git 拉取错误：fatal: the remote end hung up unexpectedly](https://gitlab.com/gitlab-org/gitlab/-/work_items/454707)。

<a id="error-netreadtimeout-when-pushing-through-ssh-on-a-geo-secondary"></a>

## 错误：在 Geo 从站点上通过 SSH 推送时出现 `Net::ReadTimeout`

当您通过 SSH 在 Geo 从站点上推送大型代码仓库时，可能会遇到超时。这是因为 Rails 会将推送代理到主站点，并且默认超时时间为 60 秒，[正如该 Geo 议题中所述](https://gitlab.com/gitlab-org/gitlab/-/issues/7405)。此问题仅在 `geo_proxy_push_ssh_to_primary` 功能标志被禁用时发生。

当前的变通方法有：

- 改为通过 HTTP 推送，此时 Workhorse 会将请求代理到主站点（如果未启用 Geo 代理，则重定向到主站点）。
- 直接推送到主站点。

日志示例（`gitlab-shell.log`）：

```plaintext
Failed to contact primary https://primary.domain.com/namespace/push_test.git\\nError: Net::ReadTimeout\",\"result\":null}" code=500 method=POST pid=5483 url="http://127.0.0.1:3000/api/v4/geo/proxy_git_push_ssh/push"
```
