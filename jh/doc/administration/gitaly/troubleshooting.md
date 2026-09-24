---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 Gitaly 故障
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下部分提供了 Gitaly 错误的可能解决方案。

另请参阅 [Gitaly 超时](../settings/gitaly_timeouts.md) 设置，以及我们关于 [解析 `gitaly/current` 文件](../logs/log_parsing.md#parsing-gitalycurrent) 的建议。

<a id="prerequisites"></a>

## 先决条件

你必须具有管理员访问权限。

<a id="check-versions-when-using-standalone-gitaly-servers"></a>

## 检查使用独立 Gitaly 服务器时的版本

使用独立 Gitaly 服务器时，必须确保它们的版本与极狐GitLab 相同，以确保完全兼容：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **概览** > **Gitaly 服务器**。
1. 确认所有 Gitaly 服务器均显示为最新版本。

<a id="find-storage-resource-details"></a>

## 查找存储资源详细信息

你可以在 [Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session) 中运行以下命令来确定 Gitaly 存储上的可用空间和已用空间：

```ruby
Gitlab::GitalyClient::ServerService.new("default").storage_disk_statistics
# 对于 Gitaly 集群 (Praefect)
Gitlab::GitalyClient::ServerService.new("<storage name>").disk_statistics
```

<a id="use-gitaly-debug"></a>

## 使用 `gitaly-debug`

`gitaly-debug` 命令为 Gitaly 和 Git 性能提供了“生产调试”工具。它旨在帮助生产工程师和支持工程师调查 Gitaly 性能问题。

要查看 `gitaly-debug` 的帮助页面以获取支持的子命令列表，请运行：

```shell
gitaly-debug -h
```

<a id="use-gitaly-git-when-git-is-required-for-troubleshooting"></a>

## 在故障排查中需要 Git 时使用 `gitaly git`

使用 `gitaly git` 可以通过与 Gitaly 相同的 Git 执行环境来执行 Git 命令，用于调试或测试目的。`gitaly git` 是确保版本兼容性的首选方法。

`gitaly git` 将所有参数传递给底层的 Git 调用，并支持 Git 所支持的所有输入形式。要使用 `gitaly git`，请运行：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/gitaly git <git-command>
```

例如，要在 Linux 软件包实例的工作目录中通过 Gitaly 运行 `git ls-tree`：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/gitaly git ls-tree --name-status HEAD
```

<a id="commits-pushes-and-clones-return-a-401"></a>

## 提交、推送和克隆返回 401 错误

```plaintext
remote: 极狐GitLab: 401 未授权
```

你需要将你的 `gitlab-secrets.json` 文件与你的极狐GitLab 应用程序节点同步。

<a id="500-and-fetching-folder-content-errors-on-repository-pages"></a>

## 仓库页面出现 500 错误和 `fetching folder content` 错误

`Fetching folder content` 以及在某些情况下 `500` 错误表明极狐GitLab 与 Gitaly 之间存在连接问题。请查阅 [客户端 gRPC 日志](#client-side-grpc-logs) 以获取详细信息。

<a id="client-side-grpc-logs"></a>

## 客户端 gRPC 日志

Gitaly 使用 [gRPC](https://grpc.io/) RPC 框架。Ruby gRPC 客户端有自己的日志文件，当您看到 Gitaly 错误时，该文件可能包含有用的信息。您可以使用 `GRPC_LOG_LEVEL` 环境变量控制 gRPC 客户端的日志级别。默认级别是 `WARN`。

您可以运行 gRPC 跟踪：

```shell
sudo GRPC_TRACE=all GRPC_VERBOSITY=DEBUG gitlab-rake gitlab:gitaly:check
```

如果此命令失败并出现 `failed to connect to all addresses` 错误，请检查 SSL 或 TLS 问题：

```shell
/opt/gitlab/embedded/bin/openssl s_client -connect <gitaly-ipaddress>:<port> -verify_return_error
```

检查 `Verify return code` 字段是否表明 [已知的 Linux 软件包安装配置问题](https://gitlab.cn/docs/omnibus/settings/ssl/)。

如果 `openssl` 成功但 `gitlab-rake gitlab:gitaly:check` 失败，请检查 Gitaly 的 [证书要求](tls_support.md#certificate-requirements)。

<a id="server-side-grpc-logs"></a>

## 服务器端 gRPC 日志

也可以通过 `GODEBUG=http2debug` 环境变量在 Gitaly 本身中启用 gRPC 跟踪。要在 Linux 软件包安装中进行设置：

1. 将以下内容添加到你的 `gitlab.rb` 文件中：

   ```ruby
   gitaly['env'] = {
     "GODEBUG=http2debug" => "2"
   }
   ```

1. [重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation) 极狐GitLab。

<a id="correlating-git-processes-with-rpcs"></a>

## 关联 Git 进程与 RPC

有时你需要找出哪个 Gitaly RPC 创建了特定的 Git 进程。

一种方法是使用 `DEBUG` 日志记录。但是，这需要提前启用，并且生成的日志很详细。

一种轻量级的关联方法是通过检查 Git 进程的环境（使用其 `PID`）并查找 `CORRELATION_ID` 变量：

```shell
PID=<Git 进程 ID>
sudo cat /proc/$PID/environ | tr '\0' '\n' | grep ^CORRELATION_ID=
```

对于 `git cat-file` 进程，此方法不可靠，因为 Gitaly 在内部池化并跨 RPC 重用这些进程。

<a id="repository-changes-fail-with-a-401-unauthorized-error"></a>

## 仓库更改失败并出现 `401 未授权` 错误

如果你在独立的服务器上运行 Gitaly 并注意到以下情况：

- 用户可以使用 SSH 和 HTTPS 成功克隆和获取仓库。
- 用户无法推送到仓库，或者在 Web UI 中尝试进行更改时收到 `401 未授权` 消息。

Gitaly 可能无法通过 Gitaly 客户端进行身份验证，因为它具有 [错误的密钥文件](configure_gitaly.md#configure-gitaly-servers)。

确认以下所有情况都属实：

- 当任何用户向此 Gitaly 服务器上的任何仓库执行 `git push` 时，会失败并出现 `401 未授权` 错误：

  ```shell
  remote: 极狐GitLab: 401 未授权
  To <REMOTE_URL>
  ! [remote rejected] branch-name -> branch-name (pre-receive hook 被拒绝)
  error: 无法推送一些引用到 '<REMOTE_URL>'
  ```

- 当任何用户使用 GitLab UI 从仓库添加或修改文件时，会立即失败并显示红色的 `401 未授权` 横幅。
- 创建新项目并 [使用 README 进行初始化](../../user/project/_index.md#create-a-blank-project) 会成功创建项目，但不会创建 README。
- 当在 Gitaly 客户端上 [跟踪日志](https://gitlab.cn/docs/omnibus/settings/logs/#tail-logs-in-a-console-on-the-server) 并重现错误时，访问 `/api/v4/internal/allowed` 端点时会收到 `401` 错误：

  ```shell
  # api_json.log
  {
    "time": "2019-07-18T00:30:14.967Z",
    "severity": "INFO",
    "duration": 0.57,
    "db": 0,
    "view": 0.57,
    "status": 401,
    "method": "POST",
    "path": "\/api\/v4\/internal\/allowed",
    "params": [
      {
        "key": "action",
        "value": "git-receive-pack"
      },
      {
        "key": "changes",
        "value": "REDACTED"
      },
      {
        "key": "gl_repository",
        "value": "REDACTED"
      },
      {
        "key": "project",
        "value": "\/path\/to\/project.git"
      },
      {
        "key": "protocol",
        "value": "web"
      },
      {
        "key": "env",
        "value": "{\"GIT_ALTERNATE_OBJECT_DIRECTORIES\":[],\"GIT_ALTERNATE_OBJECT_DIRECTORIES_RELATIVE\":[],\"GIT_OBJECT_DIRECTORY\":null,\"GIT_OBJECT_DIRECTORY_RELATIVE\":null}"
      },
      {
        "key": "user_id",
        "value": "2"
      },
      {
        "key": "secret_token",
        "value": "[FILTERED]"
      }
    ],
    "host": "gitlab.example.com",
    "ip": "REDACTED",
    "ua": "Ruby",
    "route": "\/api\/:version\/internal\/allowed",
    "queue_duration": 4.24,
    "gitaly_calls": 0,
    "gitaly_duration": 0,
    "correlation_id": "XPUZqTukaP3"
  }

  # nginx_access.log
  [IP] - - [18/Jul/2019:00:30:14 +0000] "POST /api/v4/internal/allowed HTTP/1.1" 401 30 "" "Ruby"
  ```

要修复此问题，请确认你的 Gitaly 服务器上的 [`gitlab-secrets.json` 文件](configure_gitaly.md#configure-gitaly-servers) 与 Gitaly 客户端上的文件匹配。如果不匹配，请更新 Gitaly 服务器上的密钥文件，使其与 Gitaly 客户端匹配，然后 [重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation) 极狐GitLab。

如果你已确认所有 Gitaly 服务器和客户端上的 `gitlab-secrets.json` 文件都相同，那么应用程序可能从其他文件中获取此密钥。你的 Gitaly 服务器的 `config.toml` 文件指示正在使用的密钥文件。

<a id="repository-pushes-fail-with-401-unauthorized-and-jwtverificationerror"></a>

## 仓库推送失败并出现 `401 未授权` 和 `JWT::VerificationError`

尝试 `git push` 时，你可能会看到：

- `401 未授权` 错误。
- 服务器日志中出现以下内容：

  ```json
  {
    ...
    "exception.class":"JWT::VerificationError",
    "exception.message":"Signature verification raised",
    ...
  }
  ```

当极狐GitLab 服务器已升级到 GitLab 15.5 或更高版本，但 Gitaly 尚未升级时，会出现此错误组合。

GitLab 15.5 及更高版本 [使用 JWT 令牌而不是共享密钥与 GitLab Shell 进行身份验证](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/86148)。
你应在升级极狐GitLab 服务器之前 [升级外部 Gitaly 服务器](../../update/plan_your_upgrade.md#upgrades-for-optional-features)。

<a id="repository-pushes-fail-with-a-deny-updating-a-hidden-ref-error"></a>

## 仓库推送失败并出现 `deny updating a hidden ref` 错误

Gitaly 拥有只读的内部极狐GitLab 引用，不允许用户更新。如果你尝试使用 `git push --mirror` 更新内部引用，Git 将返回拒绝错误 `deny updating a hidden ref`。

以下引用是只读的：

- refs/environments/
- refs/keep-around/
- refs/merge-requests/
- refs/pipelines/

要仅镜像推送分支和标签，并避免尝试镜像推送受保护的引用，请运行：

```shell
git push --force-with-lease origin 'refs/heads/*:refs/heads/*' 'refs/tags/*:refs/tags/*'
```

管理员想要推送的任何其他命名空间也可以通过额外的 [refspecs](https://git-scm.com/docs/git-push#_options) 包含在其中。

<a id="command-line-tools-cannot-connect-to-gitaly"></a>

## 命令行工具无法连接到 Gitaly

如果出现以下情况，gRPC 无法访问你的 Gitaly 服务器：

- 你无法通过命令行工具连接到 Gitaly 服务器。
- 某些操作导致 `14: Connect Failed` 错误消息。

使用 TCP 验证你是否可以访问 Gitaly：

```shell
sudo gitlab-rake gitlab:tcp_check[GITALY_SERVER_IP,GITALY_LISTEN_PORT]
```

如果 TCP 连接：

- 失败，请检查你的网络设置和防火墙规则。
- 成功，则你的网络和防火墙规则是正确的。

如果你在命令行环境（如 Bash）中使用代理服务器，这些可能会干扰你的 gRPC 流量。

如果你使用 Bash 或兼容的命令行环境，请运行以下命令以确定是否配置了代理服务器：

```shell
echo $http_proxy
echo $https_proxy
```

如果这些变量中的任何一个有值，则你的 Gitaly CLI 连接可能通过无法连接到 Gitaly 的代理路由。

要删除代理设置，请运行以下命令（取决于哪些变量有值）：

```shell
unset http_proxy
unset https_proxy
```

<a id="permission-denied-errors-appearing-in-gitaly-or-praefect-logs-when-accessing-repositories"></a>

## 访问仓库时 Gitaly 或 Praefect 日志中出现权限被拒绝错误

你可能会在 Gitaly 和 Praefect 日志中看到以下内容：

```shell
{
  ...
  "error":"rpc error: code = PermissionDenied desc = permission denied: token has expired",
  "grpc.code":"PermissionDenied",
  "grpc.meta.client_name":"gitlab-web",
  "grpc.request.fullMethod":"/gitaly.ServerService/ServerInfo",
  "level":"warning",
  "msg":"finished unary call with code PermissionDenied",
  ...
}
```

日志中的此信息是 gRPC 调用 [错误响应代码](https://grpc.github.io/grpc/core/md_doc_statuscodes.html)。

即使 [Gitaly 身份验证令牌设置正确](praefect/troubleshooting.md#praefect-errors-in-logs)，如果发生此错误，很可能是 Gitaly 服务器正在经历 [时钟漂移](https://en.wikipedia.org/wiki/Clock_drift)。发送到 Gitaly 的身份验证令牌包含时间戳。为了被认为是有效的，Gitaly 要求该时间戳在 Gitaly 服务器时间的 60 秒以内。

确保 Gitaly 客户端和服务器同步，并使用网络时间协议（NTP）时间服务器保持它们同步。

<a id="gitaly-not-listening-on-new-address-after-reconfiguring"></a>

## 重新配置后 Gitaly 未在新地址上监听

当更新 `gitaly['configuration'][:listen_addr]` 或 `gitaly['configuration'][:prometheus_listen_addr]` 值时，在执行 `sudo gitlab-ctl reconfigure` 后，Gitaly 可能会继续在旧地址上监听。

发生这种情况时，运行 `sudo gitlab-ctl restart` 即可解决问题。由于 [此问题](https://jihulab.com/gitlab-cn/gitaly/-/issues/2521) 已解决，因此应该不再需要这样做。

<a id="health-check-warnings"></a>

## 健康检查警告

`/var/log/gitlab/praefect/current` 中的以下警告可以忽略。

```plaintext
"error":"full method name not found: /grpc.health.v1.Health/Check",
"msg":"error when looking up method info"
```

<a id="file-not-found-errors"></a>

## 文件未找到错误

`/var/log/gitlab/gitaly/current` 中的以下错误可以忽略。它们是由极狐GitLab Rails 应用程序检查仓库中不存在的特定文件引起的。

```plaintext
"error":"not found: .gitlab/route-map.yml"
"error":"not found: Dockerfile"
"error":"not found: .gitlab-ci.yml"
```

<a id="git-pushes-are-slow-when-dynatrace-is-enabled"></a>

## 启用 Dynatrace 时 Git 推送速度慢

Dynatrace 可能导致 `sudo -u git -- /opt/gitlab/embedded/bin/gitaly-hooks` 引用事务钩子启动和关闭需要数秒时间。用户推送时，`gitaly-hooks` 会执行两次，从而造成显著延迟。

Dynatrace 似乎通过动态加载 `.so` 文件来对二进制文件进行插桩，这导致了相对短命的 `gitaly-hooks` 进程性能不佳。

如果启用 Dynatrace 时 Git 推送速度太慢，请禁用它。你可能需要从运行 Gitaly 的系统中完全删除 Dynatrace，以防止加载 `.so` 文件。

<a id="gitaly-check-fails-with-401-status-code"></a>

## `gitaly check` 失败并返回 `401` 状态码

如果 Gitaly 无法访问内部极狐GitLab API，`gitaly check` 可能会失败并返回 `401` 状态码。

解决此问题的一种方法是确保在 `gitlab.rb` 中使用 `gitlab_rails['internal_api_url']` 配置的极狐GitLab 内部 API URL 的条目正确。

<a id="changes-diffs-dont-load-for-new-merge-requests-when-using-gitaly-tls"></a>

## 使用 Gitaly TLS 时新合并请求的更改（差异）不加载

启用 [带 TLS 的 Gitaly](tls_support.md) 后，新合并请求的更改（差异）不会生成，并且你会在极狐GitLab 中看到以下消息：

```plaintext
Building your merge request... 此页面将在构建完成后更新。
```

Gitaly 必须能够连接到自身才能完成某些操作。如果 Gitaly 证书不受 Gitaly 服务器信任，则无法生成合并请求差异。

如果 Gitaly 无法连接到自身，你会在 [Gitaly 日志](../logs/_index.md#gitaly-logs) 中看到如下消息：

```json
{
   "level":"warning",
   "msg":"[core] [Channel #16 SubChannel #17] grpc: addrConn.createTransport failed to connect to {Addr: \"ext-gitaly.example.com:9999\", ServerName: \"ext-gitaly.example.com:9999\", }. Err: connection error: desc = \"transport: authentication handshake failed: tls: failed to verify certificate: x509: certificate signed by unknown authority\"",
   "pid":820,
   "system":"system",
   "time":"2023-11-06T05:40:04.169Z"
}
{
   "level":"info",
   "msg":"[core] [Server #3] grpc: Server.Serve failed to create ServerTransport: connection error: desc = \"ServerHandshake(\\\"x.x.x.x:x\\\") failed: wrapped server handshake: remote error: tls: bad certificate\"",
   "pid":820,
   "system":"system",
   "time":"2023-11-06T05:40:04.169Z"
}
```

要解决此问题，请确保已将你的 Gitaly 证书添加到 Gitaly 服务器的 `/etc/gitlab/trusted-certs` 文件夹中，并且：

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以便符号链接证书
1. 手动重启 Gitaly `sudo gitlab-ctl restart gitaly` 以便 Gitaly 进程加载证书。

<a id="gitaly-fails-to-fork-processes-stored-on-noexec-file-systems"></a>

## Gitaly 无法派生存储在 `noexec` 文件系统上的进程

对挂载点（例如 `/var`）应用 `noexec` 选项会导致 Gitaly 抛出与派生进程相关的 `permission denied` 错误。例如：

```shell
fork/exec /var/opt/gitlab/gitaly/run/gitaly-2057/gitaly-git2go: permission denied
```

要解决此问题，请从文件系统挂载中删除 `noexec` 选项。另一种方法是更改 Gitaly 运行时目录：

1. 将 `gitaly['runtime_dir'] = '<PATH_WITH_EXEC_PERM>'` 添加到 `/etc/gitlab/gitlab.rb` 中，并指定一个未设置 `noexec` 的位置。
1. 运行 `sudo gitlab-ctl reconfigure`。

<a id="commit-signing-fails-with-invalid-argument-or-invalid-data"></a>

## 提交签名失败并出现 `invalid argument` 或 `invalid data`

如果提交签名因以下任一错误而失败：

- `invalid argument: 签名密钥已加密`
- `invalid data: tag byte does not have MSB set`

发生此错误是因为 Gitaly 提交签名是无头的，不与特定用户关联。GPG 签名密钥必须在没有密码短语的情况下创建，或者必须在导出之前删除密码短语。

<a id="gitaly-logs-show-errors-in-info-messages"></a>

## Gitaly 日志在 `info` 消息中显示错误

由于 GitLab 16.3 中 [引入](https://jihulab.com/gitlab-cn/gitaly/-/merge_requests/6201) 的一个 bug，额外的条目被写入 [Gitaly 日志](../logs/_index.md#gitaly-logs)。这些日志条目包含 `"level":"info"`，但 `msg` 字符串似乎包含错误。

例如：

```json
{"level":"info","msg":"[core] [Server #3] grpc: Server.Serve failed to create ServerTransport: connection error: desc = \"ServerHandshake(\\\"x.x.x.x:x\\\") failed: wrapped server handshake: EOF\"","pid":6145,"system":"system","time":"2023-12-14T21:20:39.999Z"}
```

此日志条目的原因是底层 gRPC 库有时会输出详细的传输日志。这些日志条目看起来像是错误，但通常可以安全地忽略。

此 bug 已在 GitLab 16.4.5、16.5.5 和 16.6.0 中 [修复](https://jihulab.com/gitlab-cn/gitaly/-/merge_requests/6513/)，这可以防止将此类消息写入 Gitaly 日志。

<a id="profiling-gitaly"></a>

## 分析 Gitaly 性能

Gitaly 在 Prometheus 监听端口上公开了多个 Go 内置性能分析工具。例如，如果 Prometheus 在极狐GitLab 服务器的端口 `9236` 上监听：

- 获取正在运行的 `goroutines` 及其回溯列表：

  ```shell
  curl --output goroutines.txt "http://<gitaly_server>:9236/debug/pprof/goroutine?debug=2"
  ```

- 运行 30 秒的 CPU 分析：

  ```shell
  curl --output cpu.bin "http://<gitaly_server>:9236/debug/pprof/profile"
  ```

- 分析堆内存使用情况：

  ```shell
  curl --output heap.bin "http://<gitaly_server>:9236/debug/pprof/heap"
  ```

- 记录 5 秒的执行跟踪。这会在运行时影响 Gitaly 性能：

  ```shell
  curl --output trace.bin "http://<gitaly_server>:9236/debug/pprof/trace?seconds=5"
  ```

在安装了 `go` 的主机上，可以在浏览器中查看 CPU 分析和堆分析：

```shell
go tool pprof -http=:8001 cpu.bin
go tool pprof -http=:8001 heap.bin
```

可以通过运行以下命令查看执行跟踪：

```shell
go tool trace heap.bin
```

<a id="profile-git-operations"></a>

### 分析 Git 操作

{{< history >}}

- 在 GitLab 16.9 通过 [功能标志](../feature_flags/_index.md) 名为 `log_git_traces` 引入。默认禁用。

{{< /history >}}

> [!flag]
> 在私有化部署实例上，默认情况下此功能不可用。要使其可用，管理员可以 [启用功能标志](../feature_flags/_index.md) 名为 `log_git_traces`。在 JihuLab.com 上，此功能可用，但只能由 JihuLab.com 管理员进行配置。

你可以通过将 Git 操作的附加信息发送到 Gitaly 日志来分析 Gitaly 执行的 Git 操作。借助这些信息，用户可以更深入地了解性能优化、调试和常规遥测数据收集。有关更多信息，请参阅 [Git Trace2 API 参考](https://git-scm.com/docs/api-trace2)。

为防止系统过载，附加信息日志记录受到速率限制。如果超过速率限制，则会跳过跟踪。但是，当速率恢复到健康状态后，跟踪会自动再次处理。速率限制可确保系统保持稳定，并避免因过多的跟踪处理而产生任何不利影响。

<a id="repositories-are-shown-as-empty-after-a-gitlab-restore"></a>

## 极狐GitLab 还原后仓库显示为空

当使用 `fapolicyd` 增强安全性时，极狐GitLab 可能报告从 GitLab 备份文件还原成功，但：

- 仓库显示为空。
- 创建新文件会导致类似以下的错误：

  ```plaintext
  13:commit: commit: starting process [/var/opt/gitlab/gitaly/run/gitaly-5428/gitaly-git2go -log-format json -log-level -correlation-id
  01GP1383JV6JD6MQJBH2E1RT03 -enabled-feature-flags -disabled-feature-flags commit]: fork/exec /var/opt/gitlab/gitaly/run/gitaly-5428/gitaly-git2go: operation not permitted.
  ```

- Gitaly 日志可能包含类似以下的错误：

  ```plaintext
   "error": "exit status 128, stderr: \"fatal: cannot exec '/var/opt/gitlab/gitaly/run/gitaly-5428/hooks-1277154941.d/reference-transaction':

    Operation not permitted\\nfatal: cannot exec '/var/opt/gitlab/gitaly/run/gitaly-5428/hooks-1277154941.d/reference-transaction': Operation
    not permitted\\nfatal: ref updates aborted by hook\\n\"",
   "grpc.code": "Internal",
   "grpc.meta.deadline_type": "none",
   "grpc.meta.method_type": "client_stream",
   "grpc.method": "FetchBundle",
   "grpc.request.fullMethod": "/gitaly.RepositoryService/FetchBundle",
  ...
  ```

你可以使用 [调试模式](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/security_hardening/assembly_blocking-and-allowing-applications-using-fapolicyd_security-hardening#ref_troubleshooting-problems-related-to-fapolicyd_assembly_blocking-and-allowing-applications-using-fapolicyd) 来帮助确定 `fapolicyd` 是否基于当前规则拒绝执行。

如果你发现 `fapolicyd` 正在拒绝执行，请考虑以下操作：

1. 允许在你的 `fapolicyd` 配置中执行 `/var/opt/gitlab/gitaly` 中的所有可执行文件：

   ```plaintext
   allow perm=any all : ftype=application/x-executable dir=/var/opt/gitlab/gitaly/
   ```

1. 重启服务：

   ```shell
   sudo systemctl restart fapolicyd

   sudo gitlab-ctl restart gitaly
   ```

<a id="pre-receive-hook-declined-error-when-pushing-to-rhel-instance-with-fapolicyd-enabled"></a>

## 在启用 `fapolicyd` 的 RHEL 实例上推送时出现 `Pre-receive hook declined` 错误

当推送到启用了 `fapolicyd` 的基于 RHEL 的实例时，你可能会收到 `Pre-receive hook declined` 错误。出现此错误可能是因为 `fapolicyd` 可能阻止 Gitaly 二进制文件的执行。要解决此问题，可以：

- 禁用 `fapolicyd`。
- 创建一个 `fapolicyd` 规则，以允许在 `fapolicyd` 启用的情况下执行 Gitaly 二进制文件。

要创建允许 Gitaly 二进制文件执行的规则：

1. 在 `/etc/fapolicyd/rules.d/89-gitlab.rules` 处创建一个文件。
1. 在文件中输入以下内容：

   ```plaintext
   allow perm=any all : ftype=application/x-executable dir=/var/opt/gitlab/gitaly/
   ```

1. 重启服务：

   ```shell
   systemctl restart fapolicyd
   ```

新规则在守护进程重启后生效。

<a id="update-repositories-after-removing-a-storage-with-a-duplicate-path"></a>

## 删除具有重复路径的存储后更新仓库

{{< history >}}

- Rake 任务 `gitlab:gitaly:update_removed_storage_projects` 在 GitLab 17.1 引入。

{{< /history >}}

在 GitLab 17.0 中，对使用重复路径配置存储的支持 [已被移除](https://jihulab.com/gitlab-cn/gitaly/-/issues/5598)。这可能意味着你必须从 `gitaly` 配置中删除重复的存储配置。

> [!warning]
> 仅当旧存储和新存储在同一 Gitaly 服务器上共享相同的磁盘路径时，才使用此 Rake 任务。在任何其他情况下使用此 Rake 任务会导致仓库变得不可用。在所有其他情况下，请使用 [项目仓库存储移动 API](../../api/project_repository_storage_moves.md) 在存储之间转移项目。

当从 Gitaly 配置中删除与另一存储使用相同路径的存储时，必须将与旧存储关联的项目重新分配给新存储。

例如，你可能具有类似以下的配置：

```ruby
gitaly['configuration'] = {
  storage: [
    {
       name: 'default',
       path: '/var/opt/gitlab/git-data/repositories',
    },
    {
       name: 'duplicate-path',
       path: '/var/opt/gitlab/git-data/repositories',
    },
  ],
}
```

如果你要从配置中删除 `duplicate-path`，你应该运行以下 Rake 任务将其分配的任何项目关联到 `default`：

{{< tabs >}}

{{< tab title="Linux 软件包安装" >}}

```shell
sudo gitlab-rake "gitlab:gitaly:update_removed_storage_projects[duplicate-path, default]"
```

{{< /tab >}}

{{< tab title="自编译安装" >}}
```shell
sudo -u git -H bundle exec rake "gitlab:gitaly:update_removed_storage_projects[duplicate-path, default]" RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

<a id="error-fatal-deflate-error-0-n-when-downloading-repository-as-zip-file"></a>

## 错误：下载仓库为 ZIP 文件时出现 `fatal: deflate error (0)\n`

由于 Git 的一个 Bug（议题 575），该 Bug 已在 Git 2.51 版本中修复，在某些情况下，将仓库下载为 ZIP 压缩包会导致 ZIP 文件不完整。发生这种情况时，Gitaly 日志会显示以下错误：

```plaintext
  "msg": "fatal: deflate error (0)\n",
```

要解决此问题，请升级到使用已修复 Git 版本的极狐GitLab 和 Gitaly 版本。如果无法升级，请使用以下步骤绕过此问题：

{{< tabs >}}

{{< tab title="Linux 软件包安装" >}}

1. 使用 [`git-sizer`](https://github.com/github/git-sizer#getting-started) 检查 blob 的大小。
1. 将 `core.bigFileThreshold` 配置为大于最大 blob 的大小（默认值为 `50m`）：

   ```ruby
     gitaly['configuration'] = {
      # ... your existing configuration ...
      git: {
        config: [
          # ... any existing git config entries ...
          {
            key: 'core.bigFileThreshold',
            value: '500m'
          }
        ]
      }
    }
   ```

1. 运行 `gitlab-ctl reconfigure`。

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 使用 [`git-sizer`](https://github.com/github/git-sizer#getting-started) 检查 blob 的大小。
1. 在你的 `values.yml` 文件中配置 `core.bigFileThreshold`：

   ```yaml
   git:
     config:
       - key: "core.bigFileThreshold"
         value: "500m"
   ```

1. 要更新配置，请运行 `helm upgrade <gitlab_release> gitlab/gitlab -f values.yaml`。

{{< /tab >}}

{{< tab title="自编译安装" >}}

1. 使用 [`git-sizer`](https://github.com/github/git-sizer#getting-started) 检查 blob 的大小。
1. 在 `/home/git/gitaly/config.toml` 中配置 `core.bigFileThreshold`：

   ```toml
   # [[git.config]]
   # key = core.bigFileThreshold
   # value = 500m
   ```

{{< /tab >}}

{{< /tabs >}}