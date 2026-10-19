---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Gitaly 故障排除
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下各节提供了 Gitaly 错误的可能解决方案。

另请参阅 [Gitaly 超时](../settings/gitaly_timeouts.md)设置，以及我们关于[解析 `gitaly/current` 文件](../logs/log_parsing.md#parsing-gitalycurrent)的建议。

<a id="prerequisites"></a>

## 先决条件

您必须具有管理员访问权限。

<a id="check-versions-when-using-standalone-gitaly-servers"></a>

## 使用独立 Gitaly 服务器时检查版本

使用独立 Gitaly 服务器时，您必须确保它们与极狐GitLab 版本相同，以确保完全兼容：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**概览** > **Gitaly 服务器**。
1. 确认所有 Gitaly 服务器都指示它们是最新的。

<a id="find-storage-resource-details"></a>

## 查找存储资源详情

您可以在 [Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)中运行以下命令，以确定 Gitaly 存储上的可用空间和已用空间：

```ruby
Gitlab::GitalyClient::ServerService.new("default").storage_disk_statistics
# For Gitaly Cluster (Praefect)
Gitlab::GitalyClient::ServerService.new("<storage name>").disk_statistics
```

<a id="use-gitaly-debug"></a>

## 使用 `gitaly-debug`

`gitaly-debug` 命令为 Gitaly 和 Git 性能提供了“生产调试”工具。它旨在帮助生产工程师和支持工程师调查 Gitaly 性能问题。

要查看 `gitaly-debug`的帮助页面以获取受支持的子命令列表，请运行：

```shell
gitaly-debug -h
```

<a id="use-gitaly-git-when-git-is-required-for-troubleshooting"></a>

## 当故障排除需要 Git 时使用 `gitaly git`

使用 `gitaly git` 通过与 Gitaly 相同的 Git 执行环境来执行 Git 命令，以进行调试或测试。`gitaly git` 是确保版本兼容性的首选方法。

`gitaly git` 将所有参数传递给底层 Git 调用，并支持 Git 支持的所有形式的输入。要使用 `gitaly git`，请运行：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/gitaly git <git-command>
```

例如，要在 Linux 软件包实例上通过 Gitaly 在代码仓库的工作目录中运行 `git ls-tree`：

```shell
sudo -u git -- /opt/gitlab/embedded/bin/gitaly git ls-tree --name-status HEAD
```

<a id="commits-pushes-and-clones-return-a-401"></a>

## 提交、推送和克隆返回 401

```plaintext
remote: GitLab: 401 Unauthorized
```

您需要将 `gitlab-secrets.json` 文件与您的极狐GitLab 应用节点同步。

<a id="500-and-fetching-folder-content-errors-on-repository-pages"></a>

## 代码仓库页面上的 500 和 `fetching folder content` 错误

`Fetching folder content` 错误，以及在某些情况下的 `500` 错误，表明
极狐GitLab 与 Gitaly 之间存在连接问题。请查阅[客户端 gRPC 日志](#client-side-grpc-logs)以了解详情。

<a id="client-side-grpc-logs"></a>

## 客户端 gRPC 日志

Gitaly 使用 [gRPC](https://grpc.io/) RPC 框架。Ruby gRPC
客户端有自己的日志文件，当您遇到 Gitaly 错误时，该文件可能包含有用的信息。您可以使用 `GRPC_LOG_LEVEL` 环境变量控制 gRPC 客户端的日志级别。默认级别为 `WARN`。

您可以使用以下命令运行 gRPC 跟踪：

```shell
sudo GRPC_TRACE=all GRPC_VERBOSITY=DEBUG gitlab-rake gitlab:gitaly:check
```

如果此命令失败并出现 `failed to connect to all addresses` 错误，请检查是否存在 SSL 或 TLS 问题：

```shell
/opt/gitlab/embedded/bin/openssl s_client -connect <gitaly-ipaddress>:<port> -verify_return_error
```

检查 `Verify return code` 字段是否指示[已知的 Linux 软件包安装配置问题](https://gitlab.cn/docs/omnibus/settings/ssl/)。

如果 `openssl` 成功但 `gitlab-rake gitlab:gitaly:check` 失败，请检查 Gitaly 的[证书要求](tls_support.md#certificate-requirements)。

<a id="server-side-grpc-logs"></a>

## 服务器端 gRPC 日志

也可以使用 `GODEBUG=http2debug` 环境变量在 Gitaly 本身中启用 gRPC 跟踪。要在 Linux 软件包安装中设置此项：

1. 将以下内容添加到您的 `gitlab.rb` 文件中：

   ```ruby
   gitaly['env'] = {
     "GODEBUG=http2debug" => "2"
   }
   ```

1. [重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation)极狐GitLab。

<a id="correlating-git-processes-with-rpcs"></a>

## 将 Git 进程与 RPC 关联

有时您需要找出是哪个 Gitaly RPC 创建了特定的 Git 进程。

一种方法是使用 `DEBUG` 日志记录。但是，这需要提前启用，并且产生的日志非常冗长。

一种轻量级的关联方法是检查 Git 进程的环境（使用其 `PID`）并查看 `CORRELATION_ID` 变量：

```shell
PID=<Git process ID>
sudo cat /proc/$PID/environ | tr '\0' '\n' | grep ^CORRELATION_ID=
```

此方法对于 `git cat-file` 进程不可靠，因为 Gitaly 会在内部跨 RPC 池化并重用这些进程。

<a id="repository-changes-fail-with-a-401-unauthorized-error"></a>

## 代码仓库更改失败并出现 `401 Unauthorized` 错误

如果您在自己的服务器上运行 Gitaly 并注意到以下情况：

- 用户可以通过 SSH 和 HTTPS 成功克隆和拉取代码仓库。
- 用户无法推送到代码仓库，或者在 Web UI 中尝试对其进行更改时收到 `401 Unauthorized` 消息。

Gitaly 可能无法通过 Gitaly 客户端进行身份验证，因为它使用了[错误的密钥文件](configure_gitaly.md#configure-gitaly-servers)。

确认以下各项均为真：

- 当任何用户对此 Gitaly 服务器上的任何代码仓库执行 `git push` 时，
  它都会失败并出现 `401 Unauthorized` 错误：

  ```shell
  remote: GitLab: 401 Unauthorized
  To <REMOTE_URL>
  ! [remote rejected] branch-name -> branch-name (pre-receive hook declined)
  error: failed to push some refs to '<REMOTE_URL>'
  ```

- 当任何用户使用极狐GitLab UI 从代码仓库添加或修改文件时，
  它会立即失败并显示红色的 `401 Unauthorized` 横幅。
- 创建新项目并[使用 README 初始化它](../../user/project/_index.md#create-a-blank-project)
  会成功创建项目，但不会创建 README。
- 当在 Gitaly 客户端上[跟踪日志](https://gitlab.cn/docs/omnibus/settings/logs/#tail-logs-in-a-console-on-the-server)并重现该错误时，在访问 `/api/v4/internal/allowed` 端点时
  您会收到 `401` 错误：

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

要解决此问题，请确认 Gitaly 服务器上的 [`gitlab-secrets.json` 文件](configure_gitaly.md#configure-gitaly-servers)与 Gitaly 客户端上的文件匹配。如果不匹配，请更新 Gitaly 服务器上的密钥文件以匹配 Gitaly 客户端，然后[重新配置](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

如果您已确认所有 Gitaly 服务器和客户端上的 `gitlab-secrets.json` 文件都相同，则应用可能正在从其他文件获取此密钥。您的 Gitaly 服务器的 `config.toml file` 指示了正在使用的密钥文件。

<a id="repository-pushes-fail-with-401-unauthorized-and-jwtverificationerror"></a>

## 代码仓库推送失败并出现 `401 Unauthorized` 和 `JWT::VerificationError`

在尝试 `git push` 时，您可能会看到：

- `401 Unauthorized` 错误。
- 服务器日志中出现以下内容：

  ```json
  {
    ...
    "exception.class":"JWT::VerificationError",
    "exception.message":"Signature verification raised",
    ...
  }
  ```

当极狐GitLab 服务器已升级但 Gitaly 尚未升级时，会出现这种错误组合。

极狐GitLab [使用 JWT 令牌而非共享密钥与 GitLab Shell 进行身份验证](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/86148)。
您应该先[升级外部 Gitaly 服务器](../../update/plan_your_upgrade.md#upgrades-for-optional-features)，然后再升级极狐GitLab 服务器。

<a id="repository-pushes-fail-with-a-deny-updating-a-hidden-ref-error"></a>

## 代码仓库推送失败并出现 `deny updating a hidden ref` 错误

Gitaly 具有只读的内部极狐GitLab 引用，不允许用户更新。如果您尝试使用 `git push --mirror` 更新内部引用，Git 会返回拒绝错误 `deny updating a hidden ref`。

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

如果出现以下情况，gRPC 无法访问您的 Gitaly 服务器：

- 您无法使用命令行工具连接到 Gitaly 服务器。
- 某些操作导致 `14: Connect Failed` 错误消息。

验证您可以使用 TCP 访问 Gitaly：

```shell
sudo gitlab-rake gitlab:tcp_check[GITALY_SERVER_IP,GITALY_LISTEN_PORT]
```

如果 TCP 连接：

- 失败，请检查您的网络设置和防火墙规则。
- 成功，则您的网络和防火墙规则是正确的。

如果您在命令行环境（如 Bash）中使用代理服务器，这些可能会干扰您的 gRPC 流量。

如果您使用 Bash 或兼容的命令行环境，请运行以下命令以确定您是否配置了代理服务器：

```shell
echo $http_proxy
echo $https_proxy
```

如果这些变量中的任何一个有值，您的 Gitaly CLI 连接可能会被路由到无法连接到 Gitaly 的代理。

要移除代理设置，请运行以下命令（取决于哪些变量有值）：

```shell
unset http_proxy
unset https_proxy
```

<a id="permission-denied-errors-appearing-in-gitaly-or-praefect-logs-when-accessing-repositories"></a>

## 访问代码仓库时 Gitaly 或 Praefect 日志中出现权限被拒绝错误

您可能会在 Gitaly 和 Praefect 日志中看到以下内容：

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

日志中的此信息是 gRPC 调用[错误响应代码](https://grpc.github.io/grpc/core/md_doc_statuscodes.html)。

如果出现此错误，即使 [Gitaly 身份验证令牌已正确设置](praefect/troubleshooting.md#praefect-errors-in-logs)，Gitaly 服务器也很可能正在经历[时钟漂移](https://en.wikipedia.org/wiki/Clock_drift)。发送到 Gitaly 的身份验证令牌包含时间戳。要被视为有效，Gitaly 要求该时间戳在 Gitaly 服务器时间的 60 秒内。

确保 Gitaly 客户端和服务器已同步，并使用网络时间协议 (NTP) 时间服务器使它们保持同步。

<a id="gitaly-not-listening-on-new-address-after-reconfiguring"></a>

## 重新配置后 Gitaly 未监听新地址

在更新 `gitaly['configuration'][:listen_addr]` 或 `gitaly['configuration'][:prometheus_listen_addr]` 值后，Gitaly 在 `sudo gitlab-ctl reconfigure` 之后可能继续监听旧地址。

发生这种情况时，请运行 `sudo gitlab-ctl restart` 来解决问题。由于[此议题](https://gitlab.com/gitlab-org/gitaly/-/issues/2521)已解决，这应该不再必要。

<a id="health-check-warnings"></a>

## 健康检查警告

`/var/log/gitlab/praefect/current`中的以下警告可以忽略。

```plaintext
"error":"full method name not found: /grpc.health.v1.Health/Check",
"msg":"error when looking up method info"
```

<a id="file-not-found-errors"></a>

## 文件未找到错误

`/var/log/gitlab/gitaly/current`中的以下错误可以忽略。它们是由 GitLab Rails 应用检查代码仓库中不存在的特定文件引起的。

```plaintext
"error":"not found: .gitlab/route-map.yml"
"error":"not found: Dockerfile"
"error":"not found: .gitlab-ci.yml"
```

<a id="git-pushes-are-slow-when-dynatrace-is-enabled"></a>

## 启用 Dynatrace 时 Git 推送缓慢

Dynatrace 可能导致 `sudo -u git -- /opt/gitlab/embedded/bin/gitaly-hooks` 引用事务钩子需要几秒钟才能启动和关闭。当用户推送时，`gitaly-hooks` 会被执行两次，这会导致显著的延迟。

Dynatrace 似乎通过动态加载 `.so` 文件来对二进制文件进行插桩，这导致了相对短命的 `gitaly-hooks` 进程性能不佳。

如果启用 Dynatrace 时 Git 推送太慢，请禁用 Dynatrace。您可能需要从 Gitaly 运行所在的系统中完全移除 Dynatrace，以防止加载 `.so` 文件。

<a id="gitaly-check-fails-with-401-status-code"></a>

## `gitaly check` 失败并出现 `401` 状态码

如果 Gitaly 无法访问内部极狐GitLab API，`gitaly check` 可能会失败并出现 `401` 状态码。

解决此问题的一种方法是确保在 `gitlab.rb`中使用 `gitlab_rails['internal_api_url']` 配置的极狐GitLab 内部 API URL 条目正确。

<a id="changes-diffs-dont-load-for-new-merge-requests-when-using-gitaly-tls"></a>

## 使用 Gitaly TLS 时新合并请求的更改（差异）无法加载

在启用[使用 TLS 的 Gitaly](tls_support.md)后，新合并请求的更改（差异）不会生成，并且您会在极狐GitLab 中看到以下消息：

```plaintext
Building your merge request... This page will update when the build is complete
```

Gitaly 必须能够连接到自身才能完成某些操作。如果 Gitaly 服务器不信任 Gitaly 证书，则无法生成合并请求差异。

如果 Gitaly 无法连接到自身，您会在 [Gitaly 日志](../logs/_index.md#gitaly-logs)中看到类似以下消息的消息：

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

要解决此问题，请确保您已将 Gitaly 证书添加到 Gitaly 服务器上的 `/etc/gitlab/trusted-certs` 文件夹，并且：

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以便证书被符号链接
1. 手动重启 Gitaly `sudo gitlab-ctl restart gitaly`，以便 Gitaly 进程加载证书。

<a id="gitaly-fails-to-fork-processes-stored-on-noexec-file-systems"></a>

## Gitaly 无法 fork 存储在 `noexec` 文件系统上的进程

将 `noexec` 选项应用于挂载点（例如 `/var`）会导致 Gitaly 抛出与 fork 进程相关的 `permission denied` 错误。例如：

```shell
fork/exec /var/opt/gitlab/gitaly/run/gitaly-2057/gitaly-git2go: permission denied
```

要解决此问题，请从文件系统挂载中移除 `noexec` 选项。另一种方法是更改 Gitaly 运行时目录：

1. 将 `gitaly['runtime_dir'] = '<PATH_WITH_EXEC_PERM>'` 添加到 `/etc/gitlab/gitlab.rb`，并指定一个未设置 `noexec`的位置。
1. 运行 `sudo gitlab-ctl reconfigure`。

<a id="commit-signing-fails-with-invalid-argument-or-invalid-data"></a>

## 提交签名失败并出现 `invalid argument` 或 `invalid data`

如果提交签名失败并出现以下任一错误：

- `invalid argument: signing key is encrypted`
- `invalid data: tag byte does not have MSB set`

出现此错误是因为 Gitaly 提交签名是无头的，并且不与特定用户关联。GPG 签名密钥必须在创建时不使用密码短语，或者在导出前移除密码短语。

<a id="profiling-gitaly"></a>

## 对 Gitaly 进行性能分析

Gitaly 在 Prometheus 监听端口上公开了若干 Go 内置性能分析工具。例如，如果 Prometheus 正在监听
极狐GitLab 服务器的端口 `9236`：

- 获取正在运行的 `goroutines` 及其回溯的列表：

  ```shell
  curl --output goroutines.txt "http://<gitaly_server>:9236/debug/pprof/goroutine?debug=2"
  ```

- 运行 30 秒的 CPU 性能分析：

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

在安装了 `go`的主机上，可以在浏览器中查看 CPU 性能分析和堆性能分析：

```shell
go tool pprof -http=:8001 cpu.bin
go tool pprof -http=:8001 heap.bin
```

可以通过运行以下命令查看执行跟踪：

```shell
go tool trace heap.bin
```

<a id="profile-git-operations"></a>

### 对 Git 操作进行性能分析

> [!flag]
> 在极狐GitLab 私有化部署上，默认情况下此功能不可用。要使其可用，管理员可以[启用功能标志](../feature_flags/_index.md)
> `log_git_traces`。在 JihuLab.com 上，此功能可用，但只能由 JihuLab.com 管理员配置。

您可以通过将有关 Git 操作的附加信息发送到 Gitaly 日志来对 Gitaly 执行的 Git 操作进行性能分析。借助此信息，用户可以更深入地了解性能优化、调试和一般遥测收集。有关更多信息，请参阅 [Git Trace2 API 参考](https://git-scm.com/docs/api-trace2)。

为防止系统过载，附加信息日志记录受到速率限制。如果超过速率限制，跟踪将被跳过。但是，在速率恢复到健康状态后，跟踪会自动再次处理。速率限制可确保系统保持稳定，并避免因过多的跟踪处理而产生任何不利影响。

<a id="repositories-are-shown-as-empty-after-a-gitlab-restore"></a>

## 极狐GitLab 恢复后代码仓库显示为空

当使用 `fapolicyd` 来增强安全性时，极狐GitLab 可能会报告从极狐GitLab 备份文件恢复成功，但是：

- 代码仓库显示为空。
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

您可以使用[调试模式](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/security_hardening/assembly_blocking-and-allowing-applications-using-fapolicyd_security-hardening#ref_troubleshooting-problems-related-to-fapolicyd_assembly_blocking-and-allowing-applications-using-fapolicyd)来帮助确定 `fapolicyd` 是否基于当前规则拒绝执行。

如果您发现 `fapolicyd` 正在拒绝执行，请考虑以下事项：

1. 在您的 `fapolicyd` 配置中允许 `/var/opt/gitlab/gitaly`中的所有可执行文件：

   ```plaintext
   allow perm=any all : ftype=application/x-executable dir=/var/opt/gitlab/gitaly/
   ```

1. 重启服务：

   ```shell
   sudo systemctl restart fapolicyd

   sudo gitlab-ctl restart gitaly
   ```

<a id="pre-receive-hook-declined-error-when-pushing-to-rhel-instance-with-fapolicyd-enabled"></a>

## 在启用 `fapolicyd`的 RHEL 实例上推送时出现 `Pre-receive hook declined` 错误

在启用 `fapolicyd`的基于 RHEL 的实例上推送时，您可能会收到 `Pre-receive hook declined` 错误。出现此错误可能是因为 `fapolicyd` 会阻止 Gitaly 二进制文件的执行。要解决此问题，请执行以下任一操作：

- 禁用 `fapolicyd`。
- 创建一条 `fapolicyd` 规则，以在启用 `fapolicyd`的情况下允许执行 Gitaly 二进制文件。

要创建允许执行 Gitaly 二进制文件的规则：

1. 在 `/etc/fapolicyd/rules.d/89-gitlab.rules` 处创建一个文件。
1. 将以下内容输入到该文件中：

   ```plaintext
   allow perm=any all : ftype=application/x-executable dir=/var/opt/gitlab/gitaly/
   ```

1. 重启服务：

   ```shell
   systemctl restart fapolicyd
   ```

新规则在守护进程重启后生效。

<a id="update-repositories-after-removing-a-storage-with-a-duplicate-path"></a>

## 移除具有重复路径的存储后更新代码仓库

在极狐GitLab 17.0 中，对配置具有重复路径的存储的支持[已被移除](https://gitlab.com/gitlab-org/gitaly/-/issues/5598)。这可能意味着您必须从 `gitaly` 配置中移除重复的存储配置。

> [!warning]
> 仅当旧存储和新存储在同一 Gitaly 服务器上共享相同的磁盘路径时，才使用此 Rake 任务。在任何其他情况下使用此 Rake 任务
> 都会导致代码仓库不可用。在所有其他情况下，请使用[项目代码仓库存储移动 API](../../api/project_repository_storage_moves.md)
> 在存储之间转移项目。

当从 Gitaly 配置中移除与另一个存储使用相同路径的存储时，必须将与该旧存储关联的项目重新分配给新存储。

例如，您可能有类似以下的配置：

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

如果您要从配置中移除 `duplicate-path`，您可以运行以下 Rake 任务，将分配给它的任何项目改为关联到 `default`：

{{< tabs >}}

{{< tab title="Linux package installations" >}}

```shell
sudo gitlab-rake "gitlab:gitaly:update_removed_storage_projects[duplicate-path, default]"
```

{{< /tab >}}

{{< tab title="Self-compiled installations" >}}

```shell
sudo -u git -H bundle exec rake "gitlab:gitaly:update_removed_storage_projects[duplicate-path, default]" RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

<a id="error-fatal-deflate-error-0n-when-downloading-repository-as-zip-file"></a>

## 错误：将代码仓库下载为 ZIP 文件时出现 `fatal: deflate error (0)\n`

由于一个已在 Git 2.51 版本中修复的 Git 缺陷（[议题 575](https://gitlab.com/gitlab-org/git/-/issues/575)），在某些情况下将代码仓库下载为 ZIP 归档会导致 ZIP 文件不完整。发生这种情况时，Gitaly 日志会显示以下错误：

```plaintext
  "msg": "fatal: deflate error (0)\n",
```

要解决此问题，请升级到使用已修复版本 Git 的极狐GitLab 和 Gitaly 版本。如果您无法升级，请使用以下步骤来变通解决此问题：

{{< tabs >}}

{{< tab title="Linux package installations" >}}

1. 使用 [`git-sizer`](https://github.com/github/git-sizer#getting-started) 检查您的 blob 大小。
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

{{< tab title="Helm chart（Kubernetes）" >}}

1. 使用 [`git-sizer`](https://github.com/github/git-sizer#getting-started) 检查您的 blob 大小。
1. 在您的 `values.yml` 文件中配置 `core.bigFileThreshold`：

   ```yaml
   git:
     config:
       - key: "core.bigFileThreshold"
         value: "500m"
   ```

1. 要更新配置，请运行 `helm upgrade <gitlab_release> gitlab/gitlab -f values.yaml`。

{{< /tab >}}

{{< tab title="Self-compiled installations" >}}

1. 使用 [`git-sizer`](https://github.com/github/git-sizer#getting-started) 检查您的 blob 大小。
1. 在 `/home/git/gitaly/config.toml`中配置 `core.bigFileThreshold`：

   ```toml
   # [[git.config]]
   # key = core.bigFileThreshold
   # value = 500m
   ```

{{< /tab >}}

{{< /tabs >}}
