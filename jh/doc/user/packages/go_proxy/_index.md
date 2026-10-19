---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 的 Go 代理（已废弃）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

> [!warning]
> 此功能已在极狐GitLab 19.1 中[废弃](https://gitlab.com/gitlab-org/gitlab/-/issues/592132)，
> 并计划在 20.0 中移除。请改用 [Go 虚拟仓库](https://gitlab.com/gitlab-org/gitlab/-/issues/592136)（待其可用后）。

借助极狐GitLab 的 Go 代理，极狐GitLab 中的每个项目都可以通过 [Go 代理协议](https://proxy.golang.org/)获取。

极狐GitLab 的 Go 代理是一项[实验](../../../policy/development_stages_support.md)，由于大型代码仓库可能存在性能问题，尚不适合用于生产环境。请参见[议题 218083](https://gitlab.com/gitlab-org/gitlab/-/issues/218083)。

即使启用了 Go 代理，极狐GitLab 也不会在软件包仓库中显示 Go 模块。请参见[议题 213770](https://gitlab.com/gitlab-org/gitlab/-/issues/213770)。

有关 Go 代理所使用的具体 API 端点的文档，请参见
[Go 代理 API 文档](../../../api/packages/go_proxy.md)。

<a id="add-gitlab-as-a-go-proxy"></a>

## 将极狐GitLab 添加为 Go 代理

要将极狐GitLab 用作 Go 代理，您必须使用 Go 1.13 或更高版本。

可用的代理端点用于按项目获取模块：`/api/v4/projects/:id/packages/go`

要从极狐GitLab 获取 Go 模块，请将项目专属端点添加到 `GOPROXY`。

Go 会查询该端点，并回退到默认行为：

```shell
go env -w GOPROXY='https://gitlab.example.com/api/v4/projects/1234/packages/go,https://proxy.golang.org,direct'
```

使用此配置时，Go 按以下顺序获取依赖项：

1. Go 尝试从项目专属的 Go 代理获取。
1. Go 尝试从 [`proxy.golang.org`](https://proxy.golang.org) 获取。
1. Go 直接通过版本控制系统操作获取（例如 `git clone`、
   `svn checkout` 等）。

如果未指定 `GOPROXY`，Go 会执行第 2 步和第 3 步，这相当于将 `GOPROXY` 设置为 `https://proxy.golang.org,direct`。如果 `GOPROXY` 仅包含项目专属端点，则 Go 只查询该端点。

有关如何设置 Go 环境变量的详细信息，请参见[设置环境变量](#set-environment-variables)。

<a id="fetch-modules-from-private-projects"></a>

## 从私有项目获取模块

`go` 不支持通过不安全的连接传输凭据。以下步骤仅在极狐GitLab 配置为 HTTPS 时有效：

1. 配置 Go，使其在从极狐GitLab 的 Go 代理获取时包含 HTTP 基本身份验证凭据。
1. 配置 Go，使其跳过从公共校验和数据库下载私有极狐GitLab 项目的校验和。

<a id="enable-request-authentication"></a>

### 启用请求身份验证

创建一个[个人访问令牌](../../profile/personal_access_tokens.md)，作用域设置为 `api` 或 `read_api`。

打开您的 [`~/.netrc`](https://everything.curl.dev/usingcurl/netrc.html) 文件，并添加以下文本。将 `< >` 中的变量替换为您自己的值。

如果您使用无效的 HTTP 凭据发起 `go get` 请求，会收到 404 错误。

> [!warning]
> 如果您使用名为 `NETRC`的环境变量，Go 会将其值
> 用作文件名，并忽略 `~/.netrc`。如果您打算在
> 极狐GitLab CI/CD 中使用 `~/.netrc`，请不要将 `NETRC` 用作环境变量名。

```plaintext
machine <url> login <username> password <token>
```

- `<url>`：极狐GitLab URL，例如 `gitlab.com`。
- `<username>`：您的用户名。
- `<token>`：您的个人访问令牌。

<a id="disable-checksum-database-queries"></a>

### 禁用校验和数据库查询

使用 Go 1.13 及更高版本下载依赖项时，获取的源代码会根据校验和数据库 `sum.golang.org` 进行验证。

如果获取的源代码的校验和与数据库中的校验和不匹配，Go 不会构建该依赖项。

私有模块会构建失败，因为 `sum.golang.org` 无法获取私有模块的源代码，因此无法提供校验和。

要解决此问题，请将 `GONOSUMDB` 设置为以逗号分隔的私有项目列表。有关设置 Go 环境变量的详细信息，请参见[设置环境变量](#set-environment-variables)。

例如，要禁用 `gitlab.com/my/project`的校验和查询，请设置
`GONOSUMDB`：

```shell
go env -w GONOSUMDB='gitlab.com/my/project,<previous value>'
```

<a id="working-with-go"></a>

## 使用 Go

如果您不熟悉在 Go 中管理依赖项，或者不熟悉 Go 本身，请查阅以下文档：

- [Go 模块参考](https://go.dev/ref/mod)
- [文档（`golang.org`）](https://go.dev/doc/)
- [学习（`go.dev/learn`）](https://go.dev/learn/)

<a id="set-environment-variables"></a>

### 设置环境变量

Go 使用环境变量来控制各种功能。您可以通过所有常见方式管理这些变量。不过，Go 1.14 默认会从特殊的 Go 环境文件 `~/.go/env`中读取和写入 Go 环境变量。

- 如果 `GOENV` 设置为某个文件，则 Go 改为从该文件读取和写入。
- 如果未设置 `GOENV` 但设置了 `GOPATH`，则 Go 读取和写入 `$GOPATH/env`。

Go 环境变量可以使用 `go env <var>` 读取，并且在 Go 1.14 及更高版本中，可以使用 `go env -w <var>=<value>` 写入。例如，`go env GOPATH` 或 `go env -w GOPATH=/go`。

<a id="release-a-module"></a>

### 发布模块

Go 模块和模块版本由源代码仓库（如 Git、
SVN 和 Mercurial）定义。模块是包含 `go.mod` 和 Go
文件的代码仓库。模块版本由版本控制系统（VCS）标签定义。

要发布模块，请将 `go.mod` 和源文件推送到 VCS 代码仓库。要发布模块版本，请推送一个 VCS 标签。
