---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Geo 站点
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

设置[数据库复制并配置好 Geo 节点](../setup/_index.md)后，您可以像使用主站点一样使用离您最近的极狐GitLab 站点。

<a id="git-operations"></a>

## Git 操作

您可以直接推送到 **辅助** 站点（包括 HTTP、SSH 和 Git LFS），请求会被代理到 **主** 站点。

推送至 **辅助** 站点时看到的输出示例：

```shell
$ git push
远程：
远程：此请求将转发到 Geo 辅助节点：
远程：Geo 主节点：
远程：
远程：  ssh://git@primary.geo/user/repo.git
远程：
所有内容均为最新
```

> [!note]
> 如果您使用 HTTPS 而不是 [SSH](../../../user/ssh.md) 推送到辅助站点，
> 您无法在 URL 中存储凭据，如 `user:password@URL`。相反，您可以为类 Unix 操作系统使用
> [`.netrc` 文件](https://www.gnu.org/software/inetutils/manual/html_node/The-_002enetrc-file.html)，或为 Windows 使用 `_netrc`。在这种情况下，凭据
> 以纯文本形式存储。如果您正在寻找一种更安全的凭据存储方式，
> 可以使用 [Git 凭证存储](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage)。

<a id="web-user-interface"></a>

## Web 用户界面

**辅助** 站点的 Web 用户界面是读/写的。作为用户，在 **主** 站点上允许的所有操作都可以在 **辅助** 站点上无限制地执行。

**辅助** 站点上的 Web 界面访问请求会自动透明地代理到 **主** 站点。

<a id="fetch-go-modules-from-geo-secondary-sites"></a>

## 从 Geo 辅助站点拉取 Go 模块

Go 模块可以从辅助站点拉取，但有一些限制：

- 需要 Git 配置（使用 `insteadOf`）才能从 Geo 辅助站点获取数据。
- 对于私有项目，需要在 `~/.netrc` 中指定身份验证详细信息。

更多信息，请参见
[将项目用作 Go 软件包](../../../user/project/use_project_as_go_package.md#fetch-go-modules-from-geo-secondary-sites)。