---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 Git
description: 排查并解决常见的 Git 错误和连接问题。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 Git 时，有时事情并不会按照应有的方式或您期望的方式运行。以下是一些排查和解决 Git 问题的技巧。

<a id="debugging"></a>

## 调试

在极狐GitLab 服务器上调试 Git 问题时，请使用 `/opt/gitlab/embedded/bin/git` 而不是系统自带的 `git` 二进制文件，后者可能版本较旧。

<a id="use-a-custom-ssh-key-for-a-git-command"></a>

### 为 Git 命令使用自定义 SSH 密钥

```shell
GIT_SSH_COMMAND="ssh -i ~/.ssh/gitlabadmin" git <command>
```

将 `<command>` 替换为您要运行的 Git 命令。

<a id="debug-git-over-ssh"></a>

### 通过 SSH 调试 Git

```shell
GIT_SSH_COMMAND="ssh -vvv" git clone <git@url> 2>&1 \
| tee /tmp/gitlab-clone-test.log
```

将 `<git@url>` 替换为代码仓库的 SSH URL。输出会保存到 `/tmp/gitlab-clone-test.log`。

<a id="debug-git-over-https"></a>

### 通过 HTTPS 调试 Git

```shell
GIT_TRACE_PACKET=1 GIT_TRACE=2 GIT_CURL_VERBOSE=1 git clone <url> 2>&1 \
| tee /tmp/gitlab-clone-test.log
```

将 `<url>` 替换为代码仓库的 HTTPS URL。输出会保存到 `/tmp/gitlab-clone-test.log`。

<a id="debug-git-with-traces"></a>

### 使用 trace 调试 Git

Git 包含一整套[用于调试 Git 命令的 trace](https://git-scm.com/book/en/v2/Git-Internals-Environment-Variables#_debugging)，例如：

- `GIT_TRACE_PERFORMANCE=1`：启用性能数据跟踪，显示每次 `git` 调用所花费的时间。
- `GIT_TRACE_SETUP=1`：启用跟踪，显示 `git` 发现的关于代码仓库及其交互环境的信息。
- `GIT_TRACE_PACKET=1`：为网络操作启用数据包级跟踪。
- `GIT_CURL_VERBOSE=1`：启用 `curl`的详细输出，其中[可能包含凭据](https://curl.se/docs/manpage.html#-v)。

<a id="broken-pipe-errors-on-git-push"></a>

## `Broken pipe` 错误（`git push` 时）

尝试推送到远程代码仓库时，可能会出现 `Broken pipe` 错误。推送时通常会看到：

```plaintext
Write failed: Broken pipe
fatal: The remote end hung up unexpectedly
```

要解决此问题，以下是一些可能的解决方案。

<a id="increase-the-post-buffer-size-in-git"></a>

### 增加 Git 中的 POST 缓冲区大小

当您尝试通过 HTTPS 用 Git 推送大型代码仓库时，可能会收到如下错误消息：

```shell
fatal: pack has bad object at offset XXXXXXXXX: inflate returned -5
```

要解决此问题：

- 在本地 Git 配置中增加
  [http.postBuffer](https://git-scm.com/docs/git-config#Documentation/git-config.txt-httppostBuffer)
  的值。默认值为 1 MB。例如，如果 `git clone`
  在克隆 500 MB 的代码仓库时失败，请执行以下操作：

  1. 打开终端或命令提示符。
  1. 增加 `http.postBuffer`的值：

     ```shell
     # Set the http.postBuffer size in bytes
     git config http.postBuffer 524288000
     ```

如果本地配置无法解决问题，您可能需要修改服务器配置。此操作应谨慎进行，并且只有在您有服务器访问权限时才能执行。

- 在服务器端增加 `http.postBuffer`：

  1. 打开终端或命令提示符。
  1. 修改极狐GitLab 实例的
     [`gitlab.rb`](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/blob/13.5.1+ee.0/files/gitlab-config-template/gitlab.rb.template#L1435-1455) 文件：

     ```ruby
     gitaly['configuration'] = {
       # ...
       git: {
         # ...
         config: [
           # Set the http.postBuffer size, in bytes
           {key: "http.postBuffer", value: "524288000"},
         ],
       },
     }
     ```

  1. 应用配置更改：

     ```shell
     sudo gitlab-ctl reconfigure
     ```

<a id="error-stream-0-was-not-closed-cleanly"></a>

### 错误：`stream 0 was not closed cleanly`

如果您看到此错误，可能是由网络连接速度较慢引起的：

```plaintext
RPC failed; curl 92 HTTP/2 stream 0 was not closed cleanly: INTERNAL_ERROR (err 2)
```

如果您使用 HTTP 而不是 SSH 进行 Git 操作，请尝试以下修复方法之一：

- 使用 `git config http.postBuffer 52428800` 增加 Git 配置中的 POST 缓冲区大小。
- 使用 `HTTP/1.1` 协议，执行 `git config http.version HTTP/1.1`。

如果这两种方法都无法修复错误，您可能需要更换互联网服务提供商。

<a id="check-your-ssh-configuration"></a>

### 检查您的 SSH 配置

如果通过 SSH 推送，请首先检查您的 SSH 配置，因为 `Broken pipe` 错误有时可能是由 SSH 的底层问题（例如身份验证）引起的。请按照
[SSH 故障排除](../../user/ssh_troubleshooting.md#password-prompt-with-git-clone)文档中的说明，确保 SSH 已正确配置。

如果您是有服务器访问权限的极狐GitLab 管理员，还可以通过在客户端或服务器上配置 SSH `keep-alive` 来防止会话超时。

> [!note]
> 无需同时配置客户端和服务器。

要在客户端配置 SSH：

- 在 UNIX 上，编辑 `~/.ssh/config`（如果文件不存在则创建），
  并添加或编辑：

  ```plaintext
  Host your-gitlab-instance-url.com
    ServerAliveInterval 60
    ServerAliveCountMax 5
  ```

- 在 Windows 上，如果您使用 PuTTY，请进入会话属性，然后
  转到 **连接**，在 **发送空包以保持会话活动** 下，
  将 `Seconds between keepalives (0 to turn off)` 设置为 `60`。

要在服务器端配置 SSH，请编辑 `/etc/ssh/sshd_config` 并添加：

```plaintext
ClientAliveInterval 60
ClientAliveCountMax 5
```

<a id="running-a-git-repack"></a>

### 运行 `git repack`

如果还显示了 `pack-objects` 类型的错误，您可以尝试在再次尝试推送到远程代码仓库之前运行 `git repack`：

```shell
git repack
git push
```

<a id="upgrade-your-git-client"></a>

### 升级您的 Git 客户端

如果您运行的是较旧版本的 Git（< 2.9），请考虑升级
到 >= 2.9。有关更多信息，请参阅[推送到 Git 代码仓库时出现 broken pipe](https://stackoverflow.com/questions/19120120/broken-pipe-when-pushing-to-git-repository/36971469#36971469)。

<a id="ssh_exchange_identification-error"></a>

## `ssh_exchange_identification` 错误

用户在使用 Git over SSH 尝试推送或拉取时，可能会遇到以下错误：

```plaintext
Please make sure you have the correct access rights
and the repository exists.
...
ssh_exchange_identification: read: Connection reset by peer
fatal: Could not read from remote repository.
```

或

```plaintext
ssh_exchange_identification: Connection closed by remote host
fatal: The remote end hung up unexpectedly
```

或

```plaintext
kex_exchange_identification: Connection closed by remote host
Connection closed by x.x.x.x port 22
```

此错误通常表示 SSH 守护进程的 `MaxStartups` 值正在限制 SSH 连接。此设置指定了到 SSH 守护进程的并发未认证连接的最大数量。这会影响具有正确身份验证
凭据（SSH 密钥）的用户，因为每个连接在开始时都是“未认证”的。[默认值](https://man.openbsd.org/sshd_config#MaxStartups)为 `10`。

可以通过检查主机的 [`sshd`](https://en.wikibooks.org/wiki/OpenSSH/Logging_and_Troubleshooting#Server_Logs)
日志来验证这一点。对于 Debian 系列系统，请参阅 `/var/log/auth.log`，对于 RHEL 衍生系统，请检查 `/var/log/secure`中是否有以下错误：

```plaintext
sshd[17242]: error: beginning MaxStartups throttling
sshd[17242]: drop connection #1 from [CLIENT_IP]:52114 on [CLIENT_IP]:22 past MaxStartups
```

如果没有此错误，则表明 SSH 守护进程没有限制连接，说明底层问题可能与网络有关。

<a id="increase-the-number-of-unauthenticated-concurrent-ssh-connections"></a>

### 增加未认证并发 SSH 连接的数量

通过在 `/etc/ssh/sshd_config`中添加或修改值，在极狐GitLab 服务器上增加 `MaxStartups`：

```plaintext
MaxStartups 100:30:200
```

`100:30:200` 表示最多允许 100 个 SSH 会话不受限制，
之后丢弃 30% 的连接，直到达到绝对最大值 200。

修改 `MaxStartups`的值后，请检查配置中是否有任何错误。

```shell
sudo sshd -t -f /etc/ssh/sshd_config
```

如果配置检查运行无误，则可以安全地重启 SSH 守护进程以使更改生效。

```shell
# Debian/Ubuntu
sudo systemctl restart ssh

# CentOS/RHEL
sudo service sshd restart
```

<a id="timeout-during-git-push--git-pull"></a>

## `git push` / `git pull` 期间超时

如果从代码仓库拉取/推送到代码仓库耗时超过 50 秒，就会触发超时。其中包含所执行操作数量及其各自耗时的日志，如下例所示：

```plaintext
remote: Running checks for branch: master
remote: Scanning for LFS objects... (153ms)
remote: Calculating new repository size... (canceled after 729ms)
```

这可用于进一步调查哪个操作表现不佳，并为极狐GitLab 提供更多关于如何改进服务的信息。

<a id="error-operation-timed-out"></a>

### 错误：`Operation timed out`

如果您在使用 Git 时遇到此类错误，通常表明存在网络问题：

```shell
ssh: connect to host gitlab.com port 22: Operation timed out
fatal: Could not read from remote repository
```

为帮助识别底层问题：

- 通过不同的网络连接（例如，从 Wi-Fi 切换到蜂窝数据）以排除
  本地网络或防火墙问题。
- 运行此 bash 命令以收集 `traceroute` 和 `ping` 信息：`mtr -T -P 22 <gitlab_server>.com`。
  要了解 MTR 以及如何阅读其输出，请参阅 Cloudflare 关于
  [My Traceroute (MTR)](https://www.cloudflare.com/en-gb/learning/network-layer/what-is-mtr/)的文章。

<a id="error-transfer-closed-with-outstanding-read-data-remaining"></a>

## 错误：`transfer closed with outstanding read data remaining`

有时，在通过 HTTP 克隆旧代码仓库或大型代码仓库时，运行 `git clone` 会显示以下错误：

```plaintext
error: RPC failed; curl 18 transfer closed with outstanding read data remaining
fatal: The remote end hung up unexpectedly
fatal: early EOF
fatal: index-pack failed
```

此问题在 Git 本身中很常见，因为它无法处理大文件或大量文件。
[Git LFS](https://about.gitlab.com/blog/getting-started-with-git-lfs-tutorial/) 就是为了解决这个问题而创建的；然而，它也有局限性。通常是由以下原因之一造成的：

- 代码仓库中的文件数量。
- 历史记录中的修订数量。
- 代码仓库中存在大文件。

如果在克隆大型代码仓库时出现此错误，您可以
[将克隆深度降低](../../user/project/repository/monorepos/_index.md#use-shallow-clones-and-filters-in-cicd-processes)到 `1`。例如：

这种方法不能解决根本原因，但您可以成功克隆代码仓库。要将克隆深度降低到 `1`，请运行：

  ```shell
  variables:
    GIT_DEPTH: 1
  ```

<a id="your-password-expired-error-on-git-fetch-with-ssh-for-ldap-user"></a>

## LDAP 用户通过 SSH 进行 Git fetch 时出现 `Your password expired` 错误

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果 `git fetch` 在极狐GitLab 私有化部署上返回此 `HTTP 403 Forbidden` 错误，则说明该用户在极狐GitLab 数据库中的密码过期日期（`users.password_expires_at`）是过去的日期：

```plaintext
Your password expired. Please access GitLab from a web browser to update your password.
```

使用 SSO 账号发出的请求，且 `password_expires_at` 不为 `null` 时，会返回此错误：

```plaintext
"403 Forbidden - Your password expired. Please access GitLab from a web browser to update your password."
```

要解决此问题，您可以通过以下任一方式更新密码过期时间：

- 使用 [GitLab Rails 控制台](../../administration/operations/rails_console.md)
  检查并更新用户数据：

  ```ruby
  user = User.find_by_username('<USERNAME>')
  user.password_expired?
  user.password_expires_at
  user.update!(password_expires_at: nil)
  ```

- 使用 `gitlab-psql`：

  ```sql
  # gitlab-psql
  UPDATE users SET password_expires_at = null WHERE username='<USERNAME>';
  ```

该缺陷已在 [议题 332455](https://gitlab.com/gitlab-org/gitlab/-/issues/332455)中报告。

<a id="error-on-git-fetch-http-basic-access-denied"></a>

## Git fetch 时出现错误：`HTTP Basic: Access Denied`

如果您在使用 Git over HTTP(S) 时收到 `HTTP Basic: Access denied` 错误，
请参阅[双重身份验证故障排除指南](../../user/profile/account/two_factor_authentication_troubleshooting.md)。

此错误也可能出现在 [Git for Windows](https://gitforwindows.org/)
2.46.0 及更高版本中。使用令牌进行身份验证时，用户名可以是任意值，但空值可能会触发身份验证错误。

要解决此问题，请指定一个用户名字符串。使用以下方法之一，将
`<USERNAME>` 替换为您的极狐GitLab 用户名：

- 克隆代码仓库时：

  ```shell
  git clone https://<USERNAME>@gitlab.com/path/to/a/project.git
  ```

- 更新现有的远程 URL：

  ```shell
  git remote set-url origin https://<USERNAME>@gitlab.com/path/to/a/project.git
  ```

- 配置 Git 使其始终为特定主机使用用户名：

  ```shell
  git config --global url."https://<USERNAME>@gitlab.com/".insteadOf "https://gitlab.com/"
  ```

<a id="401-errors-logged-during-successful-git-clone"></a>

## 成功执行 `git clone` 期间记录的 `401` 错误

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用 HTTP 克隆代码仓库时，
[`production_json.log`](../../administration/logs/_index.md#production_jsonlog) 文件
可能会显示初始状态为 `401`（未授权），随后很快出现 `200`。

```json
{
   "method":"GET",
   "path":"/group/project.git/info/refs",
   "format":"*/*",
   "controller":"Repositories::GitHttpController",
   "action":"info_refs",
   "status":401,
   "time":"2023-04-18T22:55:15.371Z",
   "remote_ip":"x.x.x.x",
   "ua":"git/2.39.2",
   "correlation_id":"01GYB98MBM28T981DJDGAD98WZ",
   "duration_s":0.03585
}
{
   "method":"GET",
   "path":"/group/project.git/info/refs",
   "format":"*/*",
   "controller":"Repositories::GitHttpController",
   "action":"info_refs",
   "status":200,
   "time":"2023-04-18T22:55:15.714Z",
   "remote_ip":"x.x.x.x",
   "user_id":1,
   "username":"root",
   "ua":"git/2.39.2",
   "correlation_id":"01GYB98MJ0CA3G9K8WDH7HWMQX",
   "duration_s":0.17111
}
```

由于 [HTTP 基本访问身份验证](https://en.wikipedia.org/wiki/Basic_access_authentication)的工作方式，
对于通过 HTTP 执行的每次 Git 操作，您都应该预料到会出现这个初始 `401` 日志条目。

当 Git 客户端发起克隆时，发送到极狐GitLab 的初始请求不提供任何身份验证详细信息。极狐GitLab 会为该请求返回 `401 Unauthorized` 结果。几毫秒后，Git 客户端会发送一个包含身份验证详细信息的后续请求。这第二个请求应该会成功，并产生 `200 OK` 日志条目。

如果 `401` 日志条目缺少相应的 `200` 日志条目，则 Git 客户端可能使用了以下任一内容：

- 错误的密码。
- 已过期或被撤销的令牌。

如果不加以纠正，您可能会遇到
[`403`（Forbidden）错误](#403-error-when-performing-git-operations-over-http)。

<a id="403-error-when-performing-git-operations-over-http"></a>

## 通过 HTTP 执行 Git 操作时出现 `403` 错误

通过 HTTP 执行 Git 操作时，`403`（Forbidden）错误表示
您的 IP 地址已被失败身份验证封禁阻止：

```plaintext
fatal: unable to access 'https://gitlab.com/group/project.git/': The requested URL returned error: 403
```

失败身份验证封禁的限制因您使用的是
[极狐GitLab 私有化部署](../../rate_limits/abuse_bans.md#failed-authentication-ban-for-git-and-container-registry)
还是 [JihuLab.com](../../user/jihulab_com/_index.md#ip-blocks) 而异。

<a id="check-logs-for-failed-authentications"></a>

### 检查日志中的失败身份验证

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

可以在 [`production_json.log`](../../administration/logs/_index.md#production_jsonlog)中看到 `403`：

```json
{
   "method":"GET",
   "path":"/group/project.git/info/refs",
   "format":"*/*",
   "controller":"Repositories::GitHttpController",
   "action":"info_refs",
   "status":403,
   "time":"2023-04-19T22:14:25.894Z",
   "remote_ip":"x.x.x.x",
   "user_id":1,
   "username":"root",
   "ua":"git/2.39.2",
   "correlation_id":"01GYDSAKAN2SPZPAMJNRWW5H8S",
   "duration_s":0.00875
}
```

如果您的 IP 地址已被阻止，则
[`auth_json.log`](../../administration/logs/_index.md#auth_jsonlog)中会存在相应的日志条目：

```json
{
    "severity":"ERROR",
    "time":"2023-04-19T22:14:25.893Z",
    "correlation_id":"01GYDSAKAN2SPZPAMJNRWW5H8S",
    "message":"Rack_Attack",
    "env":"blocklist",
    "remote_ip":"x.x.x.x",
    "request_method":"GET",
    "path":"/group/project.git/info/refs?service=git-upload-pack"}
```
