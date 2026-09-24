---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Set and configure Git protocol v2 for GitLab Self-Managed.
title: 配置 Git 协议 v2
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Git 协议 v2 在多个方面改进了 v1 有线协议，并且在极狐GitLab 中默认对 HTTP 请求启用。要启用 SSH，需要管理员进行额外配置。

有关新功能和改进的更多详细信息，请参见 [Google 开源博客](https://opensource.googleblog.com/2018/05/introducing-git-protocol-version-2.html)。

<a id="prerequisites"></a>

## 先决条件

在客户端，必须安装 `git` `v2.18.0` 或更高版本。

在服务器端，如果要配置 SSH，需要设置 `sshd` 服务器以接受 `GIT_PROTOCOL` 环境变量。

在使用 [极狐GitLab Helm Charts](https://gitlab.cn/docs/charts) 和 [一体化 Docker 镜像](../install/docker/_index.md) 的安装中，SSH 服务已配置为接受 `GIT_PROTOCOL` 环境变量。用户无需进行其他操作。

对于来自 Linux 软件包或自行编译的安装，请手动更新服务器的 SSH 配置，在 `/etc/ssh/sshd_config` 文件中添加以下行：

```plaintext
AcceptEnv GIT_PROTOCOL
```

配置完 SSH 守护进程后，重新启动它以使其生效：

```shell
# CentOS 6 / RHEL 6
sudo service sshd restart

# 所有其他支持的发行版
sudo systemctl restart ssh
```

<a id="instructions"></a>

## 说明

要使用新协议，客户端需要将配置 `-c protocol.version=2` 传递给 Git 命令，或者全局设置：

```shell
git config --global protocol.version 2
```

<a id="http-connections"></a>

### HTTP 连接

验证客户端是否使用 Git v2：

```shell
GIT_TRACE_CURL=1 git -c protocol.version=2 ls-remote https://your-gitlab-instance.com/group/repo.git 2>&1 | grep Git-Protocol
```

你应该会看到发送了 `Git-Protocol` 标头：

```plaintext
16:29:44.577888 http.c:657              => Send header: Git-Protocol: version=2
```

验证服务器是否使用 Git v2：

```shell
GIT_TRACE_PACKET=1 git -c protocol.version=2 ls-remote https://your-gitlab-instance.com/group/repo.git 2>&1 | head
```

使用 Git 协议 v2 的响应示例：

```shell
$ GIT_TRACE_PACKET=1 git -c protocol.version=2 ls-remote https://your-gitlab-instance.com/group/repo.git 2>&1 | head
10:42:50.574485 pkt-line.c:80           packet:          git< # service=git-upload-pack
10:42:50.574653 pkt-line.c:80           packet:          git< 0000
10:42:50.574673 pkt-line.c:80           packet:          git< version 2
10:42:50.574679 pkt-line.c:80           packet:          git< agent=git/2.18.1
10:42:50.574684 pkt-line.c:80           packet:          git< ls-refs
10:42:50.574688 pkt-line.c:80           packet:          git< fetch=shallow
10:42:50.574693 pkt-line.c:80           packet:          git< server-option
10:42:50.574697 pkt-line.c:80           packet:          git< 0000
10:42:50.574817 pkt-line.c:80           packet:          git< version 2
10:42:50.575308 pkt-line.c:80           packet:          git< agent=git/2.18.1
```

<a id="ssh-connections"></a>

### SSH 连接

验证客户端是否使用 Git v2：

```shell
GIT_SSH_COMMAND="ssh -v" git -c protocol.version=2 ls-remote ssh://git@your-gitlab-instance.com/group/repo.git 2>&1 | grep GIT_PROTOCOL
```

你应该会看到发送了 `GIT_PROTOCOL` 环境变量：

```plaintext
debug1: Sending env GIT_PROTOCOL = version=2
```

对于服务器端，你可以使用 [HTTP 中的相同示例](#http-connections)，将 URL 更改为使用 SSH。

<a id="observe-git-protocol-version-of-connections"></a>

### 观察连接的 Git 协议版本

有关观察生产环境中使用的 Git 协议版本的信息，请参见 [相关文档](gitaly/monitoring.md#queries)。

