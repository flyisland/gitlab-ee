---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 的 Go 代理
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验性功能

{{< /details >}}

{{< history >}}

- 在极狐GitLab 13.1 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/27376)，[带有一个功能标志](../../../administration/feature_flags/_index.md)，名为 `go_proxy`。默认禁用。此功能为[实验性功能](../../../policy/development_stages_support.md)。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史记录。
> 此功能可用于测试，但尚未准备好用于生产环境。
> 请参阅[史诗 3043](https://gitlab.com/groups/gitlab-org/-/epics/3043)。

借助极狐GitLab 的 Go 代理，极狐GitLab 中的每个项目都可以通过 [Go 代理协议](https://proxy.golang.org/)进行拉取。

极狐GitLab 的 Go 代理是一个[实验性功能](../../../policy/development_stages_support.md)，由于大型仓库可能存在性能问题，尚未准备好用于生产环境。请参阅[议题 218083](https://gitlab.com/gitlab-org/gitlab/-/issues/218083)。

即使启用了 Go 代理，极狐GitLab 也不会在软件包仓库中显示 Go 模块。请参阅[议题 213770](https://gitlab.com/gitlab-org/gitlab/-/issues/213770)。

有关 Go 代理使用的特定 API 端点的文档，请参阅 [Go 代理 API 文档](../../../api/packages/go_proxy.md)。

<a id="add-gitlab-as-a-go-proxy"></a>

## 将极狐GitLab 添加为 Go 代理

要使用极狐GitLab 作为 Go 代理，你必须使用 Go 1.13 或更高版本。

可用的代理端点是用于按项目获取模块的：`/api/v4/projects/:id/packages/go`

要从极狐GitLab 获取 Go 模块，请将项目特定的端点添加到 `GOPROXY`。

Go 会查询该端点，并回退到默认行为：

```shell
go env -w GOPROXY='https://gitlab.example.com/api/v4/projects/1234/packages/go,https://proxy.golang.org,direct'
```

使用此配置，Go 按以下顺序获取依赖项：

1. Go 尝试从项目特定的 Go 代理获取。
1. Go 尝试从 [`proxy.golang.org`](https://proxy.golang.org) 获取。
1. Go 直接通过版本控制系统操作（如 `git clone`、`svn checkout` 等）获取。

如果未指定 `GOPROXY`，Go 会遵循步骤 2 和 3，这相当于将 `GOPROXY` 设置为 `https://proxy.golang.org,direct`。如果 `GOPROXY` 仅包含项目特定的端点，Go 将仅查询该端点。

有关如何设置 Go 环境变量的详细信息，请参阅 [设置环境变量](#set-environment-variables)。

<a id="fetch-modules-from-private-projects"></a>

## 从私有项目中获取模块

`go` 不支持通过不安全的连接传输凭证。仅当极狐GitLab 配置了 HTTPS 时，以下步骤才有效：

1. 配置 Go，使其在从极狐GitLab 的 Go 代理获取时包含 HTTP 基本认证凭证。
1. 配置 Go，使其跳过从公共校验和数据库下载极狐GitLab 私有项目的校验和。

<a id="enable-request-authentication"></a>

### 启用请求认证

创建一个[个人访问令牌](../../profile/personal_access_tokens.md)，其范围设置为 `api` 或 `read_api`。

打开你的 [`~/.netrc`](https://everything.curl.dev/usingcurl/netrc.html) 文件并添加以下文本。将 `< >` 中的变量替换为你的值。

如果你使用无效的 HTTP 凭证发起 `go get` 请求，你会收到 404 错误。

> [!warning]
> 如果你使用名为 `NETRC` 的环境变量，Go 会将其值用作文件名，并忽略 `~/.netrc`。如果你打算在极狐GitLab CI 中使用 `~/.netrc`，请不要使用 `NETRC` 作为环境变量名。

```plaintext
machine <url> login <username> password <token>
```

- `<url>`：极狐GitLab 的 URL，例如 `gitlab.com`。
- `<username>`：你的用户名。
- `<token>`：你的个人访问令牌。

<a id="disable-checksum-database-queries"></a>

### 禁用校验和数据库查询

当使用 Go 1.13 及更高版本下载依赖项时，获取的源会针对校验和数据库 `sum.golang.org` 进行验证。

如果获取的源的校验和与数据库中的校验和不匹配，Go 不会构建该依赖项。

私有模块构建失败，因为 `sum.golang.org` 无法获取私有模块的源，因此无法提供校验和。

要解决此问题，请将 `GONOSUMDB` 设置为一个逗号分隔的私有项目列表。有关设置 Go 环境变量的详细信息，请参阅 [设置环境变量](#set-environment-variables)。

例如，要禁用 `gitlab.com/my/project` 的校验和查询，请设置 `GONOSUMDB`：

```shell
go env -w GONOSUMDB='gitlab.com/my/project,<previous value>'
```

<a id="working-with-go"></a>

## 使用 Go

如果你不熟悉在 Go 中管理依赖项，或者不熟悉 Go，请查阅以下文档：

- [Go 模块参考](https://go.dev/ref/mod)
- [文档 (`golang.org`)](https://go.dev/doc/)
- [学习 (`go.dev/learn`)](https://go.dev/learn/)

<a id="set-environment-variables"></a>

### 设置环境变量

Go 使用环境变量来控制各种功能。你可以通过所有常规方式管理这些变量。但是，Go 1.14 会从一个特殊的 Go 环境文件（默认为 `~/.go/env`）中读写 Go 环境变量。

- 如果 `GOENV` 设置为一个文件，Go 将改为从该文件读写。
- 如果未设置 `GOENV` 但设置了 `GOPATH`，Go 将读写 `$GOPATH/env`。

Go 环境变量可以用 `go env <var>` 读取，并且在 Go 1.14 及更高版本中，可以用 `go env -w <var>=<value>` 写入。例如，`go env GOPATH` 或 `go env -w GOPATH=/go`。

<a id="release-a-module"></a>

### 发布模块

Go 模块和模块版本由源仓库（如 Git、SVN 和 Mercurial）定义。一个模块就是一个包含 `go.mod` 和 Go 文件的仓库。模块版本由版本控制系统（VCS）标签定义。

要发布模块，请将 `go.mod` 和源文件推送到 VCS 仓库。要发布模块版本，请推送一个 VCS 标签。