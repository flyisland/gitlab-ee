---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将项目用作 Go 软件包
description: Go modules and import calls.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 17.3 中更改，对未经授权的 `go get` 请求返回 404 错误。

{{< /history >}}

先决条件：

- 要使用子群组中的私有项目作为 Go 软件包，您必须[对 Go 请求进行身份验证](#authenticate-go-requests-to-private-projects)。未经过身份验证的 Go 请求会导致 `go get` 失败。对于不在子群组中的项目，您无需对 Go 请求进行身份验证。

要将项目用作 Go 软件包，请使用 `go get` 和 `godoc.org` 发现请求。您可以使用以下元标签：

- [`go-import`](https://pkg.go.dev/cmd/go#hdr-Remote_import_paths)
- [`go-source`](https://github.com/golang/gddo/wiki/Source-Code-Links)

> [!note]
> 如果您使用无效的 HTTP 凭据发出 `go get` 请求，您会收到 404 错误。
> 您可以在 `~/.netrc`（MacOS 和 Linux）或 `~/_netrc`（Windows）中找到 HTTP 凭据。
> 在 Go 1.24 及更高版本中，您还可以使用 `GOAUTH` 环境变量提供凭据。
> 有关更多信息，请参阅[使用 `GOAUTH` 进行身份验证](#authenticate-with-goauth)。

<a id="authenticate-go-requests-to-private-projects"></a>

## 对私有项目的 Go 请求进行身份验证

先决条件：

- 您的极狐GitLab 实例必须可通过 HTTPS 访问。
- 您必须拥有一个具有 `read_api` 范围的[个人访问令牌](../profile/personal_access_tokens.md)。

<a id="authenticate-with-goauth"></a>

### 使用 `GOAUTH` 进行身份验证

在 Go 1.24 及更高版本中，使用
[`GOAUTH` 环境变量](https://pkg.go.dev/cmd/go@master#hdr-GOAUTH_environment_variable)
通过自定义命令提供凭据。

> [!note]
> `GOAUTH` 的 `git dir` 值不适用于嵌套深度大于 1 的子群组中的私有项目。请改用自定义命令。

要使用 `GOAUTH` 进行身份验证，请创建一个自定义命令，该命令向 Go 请求添加 HTTP 基本身份验证头。以下示例使用通过 `git credential fill` 返回的 Git over HTTPS 凭据，对 `jihulab.com` 的请求进行身份验证：

```shell
#!/usr/bin/env bash
GITLAB_URL="https://jihulab.com"

creds=$(echo "url=${GITLAB_URL}" | git credential fill 2>&1) || {
  printf >&2 'error: git credential fill failed:\n%s\n' "$creds"
  exit 1
}

username=""
password=""
while IFS='=' read -r key value; do
  case "$key" in
    username) username="$value" ;;
    password) password="$value" ;;
  esac
done <<< "$creds"

if [ -z "$username" ] || [ -z "$password" ]; then
  printf >&2 'error: git credential fill did not return a username or password for %s\n' "$GITLAB_URL"
  exit 1
fi

encoded=$(printf '%s:%s' "$username" "$password" | base64 | tr -d '\n')

# 预期输出格式：https://pkg.go.dev/cmd/go@master#hdr-GOAUTH_environment_variable
printf '%s\n\nAuthorization: Basic %s\n\n' "$GITLAB_URL" "$encoded"
```

要使用此脚本：

1. 将脚本保存到文件，例如 `gitlab_goauth.sh`。
1. 使文件可执行：

   ```shell
   chmod +x gitlab_goauth.sh
   ```

1. 设置 `GOAUTH` 环境变量以使用您的命令：

   ```shell
   export GOAUTH="command <absolute_path_to_your_command>"
   ```

或者，要使用现有的 `.netrc` 文件与 `GOAUTH` 一起使用：

```shell
export GOAUTH="netrc"
```

<a id="authenticate-with-netrc"></a>

### 使用 `.netrc` 进行身份验证

要使用 [`.netrc`](https://everything.curl.dev/usingcurl/netrc.html) 文件对 Go 请求进行身份验证，请使用以下信息创建文件：

```plaintext
machine gitlab.example.com
login <gitlab_user_name>
password <personal_access_token>
```

在 Windows 上，Go 读取 `~/_netrc` 而不是 `~/.netrc`。

`go` 命令不会通过不安全的连接传输凭据。它会对 Go 发出的 HTTPS 请求进行身份验证，但不会对通过 Git 发出的请求进行身份验证。

<a id="authenticate-git-requests"></a>

## 对 Git 请求进行身份验证

如果 Go 无法从代理获取模块，它会使用 Git。Git 使用 `.netrc` 文件对请求进行身份验证，但您可以配置其他身份验证方法。

配置 Git 以执行以下操作之一：

- 在请求 URL 中嵌入凭据：

  ```shell
  git config --global url."https://${user}:${personal_access_token}@gitlab.example.com".insteadOf "https://gitlab.example.com"
  ```

- 使用 SSH 代替 HTTPS：

  ```shell
  git config --global url."git@gitlab.example.com:".insteadOf "https://gitlab.example.com/"
  ```

<a id="disable-go-module-fetching-for-private-projects"></a>

## 禁用私有项目的 Go 模块获取

要获取模块或软件包，Go 使用以下环境变量：

- `GOPRIVATE`
- `GONOPROXY`
- `GONOSUMDB`

要禁用获取：

1. 禁用 `GOPRIVATE`：
   - 要禁用一个项目的查询，请禁用 `GOPRIVATE=gitlab.example.com/my/private/project`。
   - 要禁用 JihuLab.com 上所有项目的查询，请禁用 `GOPRIVATE=gitlab.example.com`。
1. 在 `GONOPROXY` 中禁用代理查询。
1. 在 `GONOSUMDB` 中禁用校验和查询。

- 如果模块名称或其前缀在 `GOPRIVATE` 或 `GONOPROXY` 中，Go 不会查询模块代理。
- 如果模块名称或其前缀在 `GOPRIVATE` 或 `GONOSUMDB` 中，Go 不会查询校验和数据库。

<a id="authenticate-git-requests-to-private-subgroups"></a>

## 对私有子群组的 Git 请求进行身份验证

如果 Go 模块位于私有子群组下，例如 `jihulab.com/namespace/subgroup/go-module`，那么 Git 身份验证不起作用。这是因为 `go get` 会发出未经身份验证的请求来发现仓库路径。在没有身份验证的情况下，极狐GitLab 会响应 `jihulab.com/namespace/subgroup.git`，以防止向未经身份验证的用户暴露项目存在的安全风险。因此，无法下载 Go 模块。

您可以[配置 Go 身份验证](#authenticate-go-requests-to-private-projects)来下载私有子群组中的 Go 模块。

<a id="workaround-use-git-in-the-module-name"></a>

### 变通方法：在模块名称中使用 `.git`

有一种方法可以跳过 `go get` 请求，强制 Go 直接使用 Git 身份验证，但这需要修改模块名称。[根据 Go 文档](https://go.dev/ref/mod#vcs-find)：

> 如果模块路径在路径组件的末尾有一个 VCS 限定符（`.bzr`、`.fossil`、`.git`、`.hg`、`.svn` 之一），go 命令将使用该路径限定符之前的所有内容作为仓库 URL。例如，对于模块 `example.com/foo.git/bar`，go 命令会使用 Git 下载位于 `example.com/foo.git` 的仓库，并期望在 bar 子目录中找到该模块。

1. 转到私有子群组中 Go 模块的 `go.mod` 文件。
1. 在模块名称中添加 `.git`。
   例如，将 `module jihulab.com/namespace/subgroup/go-module` 重命名为 `module jihulab.com/namespace/subgroup/go-module.git`。
1. 提交并推送此更改。
1. 访问依赖此模块的 Go 项目，并调整它们的 `import` 调用。
   例如，`import jihulab.com/namespace/subgroup/go-module.git`。

进行此更改后，Go 模块应该能够正确获取。
例如，`GOPRIVATE=jihulab.com/namespace/* go mod tidy`。

<a id="fetch-go-modules-from-geo-secondary-sites"></a>

## 从 Geo 次要站点获取 Go 模块

使用 [Geo](../../administration/geo/_index.md) 访问次要 Geo 服务器上包含 Go 模块的 Git 仓库。

您可以使用 SSH 或 HTTP 访问 Geo 次要服务器。

<a id="use-ssh-to-access-the-geo-secondary-server"></a>

### 使用 SSH 访问 Geo 次要服务器

要使用 SSH 访问 Geo 次要服务器：

1. 在客户端重新配置 Git，将指向主站点的流量发送到次要站点：

   ```shell
   git config --global url."git@gitlab-secondary.example.com".insteadOf "https://gitlab.example.com"
   git config --global url."git@gitlab-secondary.example.com".insteadOf "http://gitlab.example.com"
   ```

   - 对于 `gitlab.example.com`，使用主站点域名。
   - 对于 `gitlab-secondary.example.com`，使用次要站点域名。

1. 确保客户端已设置为可通过 SSH 访问极狐GitLab 仓库。您可以在主站点上测试此设置，极狐GitLab 会将公钥复制到次要站点。

`go get` 请求会向主 Geo 服务器生成 HTTP 流量。当模块下载开始时，`insteadOf` 配置会将流量发送到次要 Geo 服务器。

<a id="use-http-to-access-the-geo-secondary"></a>

### 使用 HTTP 访问 Geo 次要站点

您必须使用会复制到次要服务器的持久访问令牌。您不能使用 CI/CD 作业令牌通过 HTTP 获取 Go 模块。

要使用 HTTP 访问 Geo 次要服务器：

1. 在客户端添加 Git `insteadOf` 重定向：

   ```shell
   git config --global url."https://gitlab-secondary.example.com".insteadOf "https://gitlab.example.com"
   ```

   - 对于 `gitlab.example.com`，使用主站点域名。
   - 对于 `gitlab-secondary.example.com`，使用次要站点域名。

1. 生成一个[个人访问令牌](../profile/personal_access_tokens.md)，并在客户端的 `~/.netrc` 文件中添加凭据：

   ```shell
   machine gitlab.example.com login USERNAME password TOKEN
   machine gitlab-secondary.example.com login USERNAME password TOKEN
   ```

`go get` 请求会向主 Geo 服务器生成 HTTP 流量。当模块下载开始时，`insteadOf` 配置会将流量发送到次要 Geo 服务器。

