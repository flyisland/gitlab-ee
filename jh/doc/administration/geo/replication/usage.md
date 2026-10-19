---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Geo 站点
---

<!-- Please update `EE::GitLab::GeoGitAccess::GEO_SERVER_DOCS_URL` if this file is moved -->

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在完成[数据库复制并配置 Geo 节点](../setup/_index.md)后，您可以像使用主站点一样使用距离您最近的极狐GitLab 站点。

<a id="git-operations"></a>

## Git 操作

您可以直接推送到从站点（HTTP 和 SSH 均支持，包括 Git LFS），该请求会被代理到主站点。

推送到从站点时看到的输出示例：

```shell
$ git push
remote:
remote: This request to a Geo secondary node will be forwarded to the
remote: Geo primary node:
remote:
remote:   ssh://git@primary.geo/user/repo.git
remote:
Everything up-to-date
```

> [!note]
> 如果您使用 HTTPS 而不是 [SSH](../../../user/ssh.md) 推送到从站点，
> 则无法像 `user:password@URL` 那样将凭据存储在 URL 中。您可以改用
> [`.netrc` 文件](https://www.gnu.org/software/inetutils/manual/html_node/The-_002enetrc-file.html)
> （适用于类 Unix 操作系统）或 Windows 上的 `_netrc`。在这种情况下，凭据
> 以纯文本形式存储。如果您想寻找更安全的凭据存储方式，
> 可以使用 [Git 凭据存储](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage)。

<a id="web-user-interface"></a>

## Web 用户界面

从站点上的 Web 用户界面为读写模式。作为用户，在主站点上允许的所有操作都可以在从站点上执行，不受限制。

从站点上的 Web 界面访问请求会自动且透明地代理到主站点。

<a id="fetch-go-modules-from-geo-secondary-sites"></a>

## 从 Geo 从站点获取 Go 模块

可以从从站点拉取 Go 模块，但存在一些限制：

- 需要配置 Git（使用 `insteadOf`）才能从 Geo 从站点获取数据。
- 对于私有项目，需要在 `~/.netrc`中指定身份验证详细信息。

有关更多信息，请参见[将项目用作 Go 软件包](../../../user/project/use_project_as_go_package.md#fetch-go-modules-from-geo-secondary-sites)。
