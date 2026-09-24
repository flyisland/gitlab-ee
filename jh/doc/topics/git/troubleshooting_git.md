---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 Git 问题
description: Troubleshoot and resolve common Git errors and connection issues.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

有时，你在使用 Git 时，事情并不像预期的那样运行。这里有一些关于排查和解决 Git 问题的提示。

<a id="debugging"></a>

## 调试

在极狐GitLab 服务器上调试 Git 问题时，请使用 `/opt/gitlab/embedded/bin/git`，而不是使用系统提供的可能较旧的 `git` 二进制文件。

<a id="use-a-custom-ssh-key-for-a-git-command"></a>

### 为 Git 命令使用自定义 SSH 密钥

```shell
GIT_SSH_COMMAND="ssh -i ~/.ssh/gitlabadmin" git <command>
```

将 `<command>` 替换为你要运行的 Git 命令。

<a id="debug-git-over-ssh"></a>

### 通过 SSH 调试 Git

```shell
GIT_SSH_COMMAND="ssh -vvv" git clone <git@url> 2>&1 \
| tee /tmp/gitlab-clone-test.log
```

将 `<git@url>` 替换为你的仓库的 SSH URL。输出将保存到 `/tmp/gitlab-clone-test.log`。

<a id="debug-git-over-https"></a>

### 通过 HTTPS 调试 Git

```shell
GIT_TRACE_PACKET=1 GIT_TRACE=2 GIT_CURL_VERBOSE=1 git clone <url> 2>&1 \
| tee /tmp/gitlab-clone-test.log
```

将 `<url>` 替换为你的仓库的 HTTPS URL。输出将保存到 `/tmp/gitlab-clone-test.log`。

<a id="debug-git-with-traces"></a>

### 使用 trace 调试 Git

Git 提供了一套完整的[用于调试 Git 命令的 trace](https://git-scm.com/book/en/v2/Git-Internals-Environment-Variables#_debugging)，例如：

- `GIT_TRACE_PERFORMANCE=1`：启用性能数据跟踪，显示每个特定 `git` 调用所花费的时间。
- `GIT_TRACE_SETUP=1`：启用跟踪，显示 `git` 对与其交互的仓库和环境的发现信息。
- `GIT_TRACE_PACKET=1`：启用网络操作的数据包级跟踪。
- `GIT_CURL_VERBOSE=1`：启用 `curl` 的详细输出，这可能[包含凭据](https://curl.se/docs/manpage.html#-v)。

<a id="broken-pipe-errors-on-git-push"></a>

## `git push` 时出现 `Broken pipe` 错误

在尝试推送到远程仓库时，可能会出现 `Broken pipe` 错误。推送时你通常会看到：

```plaintext
写入失败：管道损坏（Broken pipe）
致命错误：远程端意外挂断
```

要解决此问题，以下是一些可能的解决方案。

<a id="increase-the-post-buffer-size-in-git"></a>

### 增加 Git 中的 POST 缓冲区大小

当你尝试通过 HTTPS 使用 Git 推送大型仓库时，你可能会收到如下错误消息：

```shell
fatal: pack has bad object at offset XXXXXXXXX: inflate returned -5
```

要解决此问题：

- 在你的本地 Git 配置中增加
  [http.postBuffer](https://git-scm.com/docs/git-config#Documentation/git-config.txt-httppostBuffer)
  值。默认值为 1 MB。例如，如果 `git clone` 克隆 500 MB 仓库失败，请执行以下操作：

  1. 打开终端或命令提示符。
  1. 增加 `http.postBuffer` 值：

     ```shell
     # 设置 http.postBuffer 大小（以字节为单位）
     git config http.postBuffer 524288000
     ```

如果本地配置不能解决问题，你可能需要修改服务器配置。这应该谨慎进行，并且只有在你具备服务器访问权限时才这么做。

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
           # 设置 http.postBuffer 大小（以字节为单位）
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

如果你看到此错误，可能是由于网络连接速度慢：

```plaintext
RPC 失败；curl 92 HTTP/2 流 0 未正常关闭：INTERNAL_ERROR (错误 2)
```

如果你通过 HTTP 而不是 SSH 使用 Git，请尝试以下修复之一：

- 使用 `git config http.postBuffer 52428800` 增加 Git 配置中的 POST 缓冲区大小。
- 使用 `git config http.version HTTP/1.1` 切换到 `HTTP/1.1` 协议。

如果两种方法都无法修复错误，你可能需要更换互联网服务提供商。

<a id="check-your-ssh-configuration"></a>

### 检查你的 SSH 配置

如果通过 SSH 推送，请先检查你的 SSH 配置，因为 'Broken pipe' 错误有时可能是由 SSH 的底层问题（例如认证）引起的。请确保按照 [SSH 故障排除](../../user/ssh_troubleshooting.md#password-prompt-with-git-clone) 文档中的说明正确配置了 SSH。

如果你是具有服务器访问权限的极狐GitLab 管理员，你还可以通过在客户端或服务器上配置 SSH `keep-alive` 来防止会话超时。

> [!note]
> 同时配置客户端和服务器是不必要的。

在客户端配置 SSH：

- 在 UNIX 上，编辑 `~/.ssh/config`（如果文件不存在则创建）并添加或修改：

  ```plaintext
  Host your-gitlab-instance-url.com
    ServerAliveInterval 60
    ServerAliveCountMax 5
  ```

- 在 Windows 上，如果你使用 PuTTY，前往会话属性，然后转到 **连接**，在 **发送空包以保持会话活动** 下，将 `Seconds between keepalives (0 to turn off)` 设置为 `60`。

在服务器端配置 SSH，编辑 `/etc/ssh/sshd_config` 并添加：

```plaintext
ClientAliveInterval 60
ClientAliveCountMax 5
```

<a id="running-a-git-repack"></a>

### 运行 `git repack`

如果还显示了 'pack-objects' 类型的错误，你可以在再次尝试推送到远程仓库之前运行 `git repack`：

```shell
git repack
git push
```

<a id="upgrade-your-git-client"></a>

### 升级你的 Git 客户端

如果你使用的是旧版 Git（< 2.9），请考虑升级到 >= 2.9。有关更多信息，请参阅[推送到 Git 仓库时出现 broken pipe 问题](https://stackoverflow.com/questions/19120120/broken-pipe-when-pushing-to-git-repository/36971469#36971469)。

<a id="ssh_exchange_identification-error"></a>

## `ssh_exchange_identification` 错误

用户尝试通过 SSH 使用 Git 推送或拉取时，可能会遇到以下错误：

```plaintext
请确保你拥有正确的访问权限
且仓库存在。
...
ssh_exchange_identification：读取：对等方重置连接
致命错误：无法读取远程仓库。
```

或

```plaintext
ssh_exchange_identification：远程主机关闭了连接
致命错误：远程端意外挂断
```

或

```plaintext
kex_exchange_identification：远程主机关闭了连接
x.x.x.x 端口 22 连接关闭
```

该错误通常表示 SSH 守护进程的 `MaxStartups` 值正在限制 SSH 连接。此设置指定了 SSH 守护进程允许的最大并发、未认证连接数。这会影响具有正确认证凭据（SSH 密钥）的用户，因为每个连接在开始时都是‘未认证’的。[默认值](https://man.openbsd.org/sshd_config#MaxStartups) 为 `10`。

可以通过检查主机的 [`sshd`](https://en.wikibooks.org/wiki/OpenSSH/Logging_and_Troubleshooting#Server_Logs) 日志来验证这一点。对于 Debian 家族的系统，请查看 `/var/log/auth.log`；对于 RHEL 衍生系统，请检查 `/var/log/secure` 中是否有以下错误：

```plaintext
sshd[17242]：错误：开始限制 MaxStartups
sshd[17242]：从 [CLIENT_IP]:52114 超过 MaxStartups 在 [CLIENT_IP]:22 上丢弃连接 #1
```

如果未出现此错误，则表明 SSH 守护进程未限制连接，说明底层问题可能与网络相关。

<a id="increase-the-number-of-unauthenticated-concurrent-ssh-connections"></a>

### 增加未认证并发 SSH 连接数

在极狐GitLab 服务器上，通过添加或修改 `/etc/ssh/sshd_config` 中的值来增加 `MaxStartups`：

```plaintext
MaxStartups 100:30:200
```

`100:30:200` 表示最多 100 个 SSH 会话不受限制，之后 30% 的连接将被丢弃，直到达到绝对最大值 200。

修改 `MaxStartups` 的值后，检查配置中是否存在错误。

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

## `git push` / `git pull` 过程中的超时

如果从仓库拉取/推送到仓库耗时超过 50 秒，则会触发超时。超时信息包含执行的操作数量及其各自耗时的日志，如下例所示：

```plaintext
remote：正在对分支 master 进行检查
remote：正在扫描 LFS 对象... (153ms)
remote：正在计算新仓库大小... (在 729ms 后取消)
```

这可用于进一步调查哪个操作性能不佳，并向极狐GitLab 提供更多有关如何改进服务的信息。

<a id="error-operation-timed-out"></a>

### 错误：`Operation timed out`

如果你在使用 Git 时遇到这样的错误，通常表明存在网络问题：

```shell
ssh：连接到主机 jihulab.com 端口 22：操作超时
fatal：无法读取远程仓库
```

为了帮助确定根本原因：

- 通过不同的网络连接（例如，从 Wi-Fi 切换到蜂窝数据），以排除本地网络或防火墙问题。
- 运行以下 bash 命令以收集 `traceroute` 和 `ping` 信息：`mtr -T -P 22 <gitlab_server>.com`。要了解 MTR 以及如何阅读其输出，请参阅 Cloudflare 文章：[我的 Traceroute (MTR)](https://www.cloudflare.com/en-gb/learning/network-layer/what-is-mtr/)。

<a id="error-transfer-closed-with-outstanding-read-data-remaining"></a>

## 错误：`transfer closed with outstanding read data remaining`

有时，通过 HTTP 运行 `git clone` 克隆旧的或大型仓库时，会显示以下错误：

```plaintext
错误：RPC 失败；curl 18 传输关闭，仍有未读数据
致命错误：远程端意外挂断
致命错误：过早 EOF
致命错误：索引包失败
```

这个问题在 Git 本身中很常见，因为它无法处理大文件或大量文件。[Git LFS](https://gitlab.cn/blog/getting-started-with-git-lfs-tutorial/) 正是为了绕过此问题而创建的；然而，即使它也有限制。通常是由于以下原因之一：

- 仓库中的文件数量。
- 历史记录中的修订数量。
- 仓库中存在大文件。

如果在克隆大型仓库时发生此错误，你可以[减少克隆深度](../../user/project/repository/monorepos/_index.md#use-shallow-clones-and-filters-in-cicd-processes) 至 `1`。例如：

这种方法并不能解决根本原因，但可以成功克隆仓库。要将克隆深度减少到 `1`，请运行：

  ```shell
  variables:
    GIT_DEPTH: 1
  ```

<a id="your-password-expired-error-on-git-fetch-with-ssh-for-ldap-user"></a>

## LDAP 用户在使用 SSH 进行 `git fetch` 时出现 `Your password expired` 错误

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果在极狐GitLab 私有化部署 中 `git fetch` 返回此 `HTTP 403 Forbidden` 错误，则极狐GitLab 数据库中该用户的密码过期日期（`users.password_expires_at`）是一个过去的日期：

```plaintext
你的密码已过期。请从网页浏览器访问极狐GitLab 以更新你的密码。
```

使用 SSO 账户且 `password_expires_at` 不为 `null` 的请求会返回此错误：

```plaintext
"403 Forbidden - 你的密码已过期。请从网页浏览器访问极狐GitLab 以更新你的密码。"
```

要解决此问题，你可以通过以下任一方式更新密码过期时间：

- 使用 [极狐GitLab Rails 控制台](../../administration/operations/rails_console.md) 检查并更新用户数据：

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

<a id="error-on-git-fetch-http-basic-access-denied"></a>

## `git fetch` 错误：`HTTP Basic: Access Denied`

如果通过 HTTP(S) 使用 Git 时收到 `HTTP Basic: Access denied` 错误，请参考[双因素认证故障排除指南](../../user/profile/account/two_factor_authentication_troubleshooting.md)。

此错误也可能出现在 [Git for Windows](https://gitforwindows.org/) 2.46.0 及更高版本中。使用令牌进行认证时，用户名可以是任意值，但空值可能会触发认证错误。

要解决此问题，请指定一个用户名字符串。使用以下方法之一，将 `<USERNAME>` 替换为你的极狐GitLab 用户名：

- 克隆仓库时：

  ```shell
  git clone https://<USERNAME>@jihulab.com/path/to/a/project.git
  ```

- 更新现有远程 URL：

  ```shell
  git remote set-url origin https://<USERNAME>@jihulab.com/path/to/a/project.git
  ```

- 配置 Git 为特定主机始终使用一个用户名：

  ```shell
  git config --global url."https://<USERNAME>@jihulab.com/".insteadOf "https://jihulab.com/"
  ```

<a id="401-errors-logged-during-successful-git-clone"></a>

## 成功 `git clone` 期间记录的 `401` 错误

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用 HTTP 克隆仓库时，[`production_json.log`](../../administration/logs/_index.md#production_jsonlog) 文件可能会显示初始状态为 `401`（未授权），随后快速跟随 `200`。

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

由于 [HTTP 基本访问认证](https://en.wikipedia.org/wiki/Basic_access_authentication) 的工作方式，你应该预期每个通过 HTTP 执行的 Git 操作都会出现此初始 `401` 日志条目。

当 Git 客户端启动克隆时，发送到极狐GitLab 的初始请求不提供任何认证详细信息。对于该请求，极狐GitLab 返回 `401 Unauthorized` 结果。几毫秒后，Git 客户端发送包含认证详细信息的后续请求。这第二个请求应该成功，并产生 `200 OK` 日志条目。

如果 `401` 日志条目缺少相应的 `200` 日志条目，则 Git 客户端很可能使用的是：

- 密码错误。
- 已过期或已吊销的令牌。

如果不纠正，你可能会遇到 [`403`（Forbidden）错误](#403-error-when-performing-git-operations-over-http)。

<a id="403-error-when-performing-git-operations-over-http"></a>

## 通过 HTTP 执行 Git 操作时出现 `403` 错误

通过 HTTP 执行 Git 操作时，`403`（Forbidden）错误表示你的 IP 地址已被认证失败封锁：

```plaintext
fatal: 无法访问 'https://jihulab.com/group/project.git/'：请求的 URL 返回错误：403
```

认证失败封锁的限制根据你使用的是[极狐GitLab 私有化部署](../../security/rate_limits.md#failed-authentication-ban-for-git-and-container-registry)还是 [JihuLab.com](../../user/jihulab_com/_index.md#ip-blocks) 而有所不同。

<a id="check-logs-for-failed-authentications"></a>

### 检查认证失败日志

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

可以在 [`production_json.log`](../../administration/logs/_index.md#production_jsonlog) 中看到 `403`：

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

如果你的 IP 地址已被封锁，则在 [`auth_json.log`](../../administration/logs/_index.md#auth_jsonlog) 中存在相应的日志条目：

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