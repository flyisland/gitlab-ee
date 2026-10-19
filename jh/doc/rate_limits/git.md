---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
description: 为 Git HTTP、Git LFS 和 Git SSH 操作配置速率限制。
title: Git 操作速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

常见的 Git 操作（如克隆、拉取和推送）可能在短时间内产生大量请求。对 Git HTTP、Git LFS 和 Git SSH 操作设置速率限制，可以保护极狐GitLab 实例的安全性和持久性。这些限制各自与[通用用户和 IP 速率限制](../administration/settings/user_and_ip_rate_limits.md)的配合方式各不相同。每个章节会分别说明。

<a id="git-http"></a>

## Git HTTP

如果您在代码仓库中使用 Git HTTP，常见的 Git 操作可能会产生大量 Git HTTP 请求。极狐GitLab 可以对已认证和未认证的 Git HTTP 请求强制执行速率限制，以提高 Web 应用程序的安全性和持久性。

> [!note]
> [通用用户和 IP 速率限制](../administration/settings/user_and_ip_rate_limits.md)不适用于 Git HTTP 请求。

<a id="git-http-on-gitlabcom"></a>

### JihuLab.com 上的 Git HTTP

在 JihuLab.com 上，Git HTTP 请求受 [Git HTTPS 请求速率限制](../user/jihulab_com/_index.md#jihulabcom-specific-rate-limits)约束。

<a id="configure-unauthenticated-git-http-rate-limits"></a>

### 配置未认证的 Git HTTP 速率限制

极狐GitLab 默认禁用对未认证 Git HTTP 请求的速率限制。

前提条件：

- 您必须具有管理员访问权限。

要对不包含认证参数的 Git HTTP 请求应用速率限制，请启用并配置这些限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **Git HTTP 速率限制**。
1. 选择 **启用未认证的 Git HTTP 请求速率限制**。
1. 为 **每个用户每个周期内未认证的 Git HTTP 请求数上限** 输入一个值。
1. 为 **未认证的 Git HTTP 速率限制周期（秒）** 输入一个值。
1. 选择 **保存更改**。

<a id="configure-authenticated-git-http-rate-limits"></a>

### 配置已认证的 Git HTTP 速率限制

极狐GitLab 默认禁用对已认证 Git HTTP 请求的速率限制。

前提条件：

- 您必须具有管理员访问权限。

要对包含认证参数的 Git HTTP 请求应用速率限制，请启用并配置这些限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **Git HTTP 速率限制**。
1. 选择 **启用已认证的 Git HTTP 请求速率限制**。
1. 为 **每个用户每个周期内已认证的 Git HTTP 请求数上限** 输入一个值。
1. 为 **已认证的 Git HTTP 速率限制周期（秒）** 输入一个值。
1. 选择 **保存更改**。

如有需要，您可以[允许特定用户绕过已认证的请求速率限制](../administration/settings/user_and_ip_rate_limits.md#allow-specific-users-to-bypass-authenticated-request-rate-limiting)。

<a id="git-lfs"></a>

## Git LFS

[Git 大文件存储（LFS）](../topics/git/lfs/_index.md)是用于处理大文件的 Git 扩展。使用 Git LFS 的代码仓库可能会产生大量 LFS 请求。您可以强制执行[通用用户和 IP 速率限制](../administration/settings/user_and_ip_rate_limits.md)，也可以覆盖通用设置，对 Git LFS 请求强制执行额外限制。此覆盖可以提高 Web 应用程序的安全性和持久性。

<a id="git-lfs-on-gitlabcom"></a>

### JihuLab.com 上的 Git LFS

在 JihuLab.com 上，Git LFS 请求受[已认证的 Web 请求速率限制](../user/jihulab_com/_index.md#jihulabcom-specific-rate-limits)约束。这些限制设置为每个用户每分钟 1000 个请求。

每个上传或下载的 Git LFS 对象都会生成一个计入此限制的 HTTP 请求。

> [!note]
> 包含多个大文件的项目可能会遇到 HTTP 速率限制错误。在 CI/CD 流水线等自动化环境中从单个 IP 地址执行克隆或拉取操作时，可能会发生此错误。

<a id="configure-git-lfs-rate-limits"></a>

### 配置 Git LFS 速率限制

Git LFS 速率限制在极狐GitLab 私有化部署实例上默认禁用。管理员可以为 Git LFS 流量专门配置专用的速率限制。启用后，这些专用的 LFS 速率限制将覆盖默认的[用户和 IP 速率限制](../administration/settings/user_and_ip_rate_limits.md)。

前提条件：

- 您必须是该实例的管理员。

要配置 Git LFS 速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **Git LFS 速率限制**。
1. 选择 **启用已认证的 Git LFS 请求速率限制**。
1. 为 **每个用户每个周期内已认证的 Git LFS 请求数上限** 输入一个值。
1. 为 **已认证的 Git LFS 速率限制周期（秒）** 输入一个值。
1. 选择 **保存更改**。

<a id="git-ssh-operations"></a>

## Git SSH 操作

极狐GitLab 按用户账号和项目对使用 SSH 的 Git 操作应用速率限制。当用户超过速率限制时，极狐GitLab 会拒绝该用户对该项目的进一步连接请求。

该速率限制应用于 Git 命令（[plumbing](https://git-scm.com/book/en/v2/Git-Internals-Plumbing-and-Porcelain)）级别。默认情况下，每个命令的速率限制为每分钟 600 次。例如：

- `git push` 的速率限制为每分钟 600 次。
- `git pull` 有自己的速率限制，为每分钟 600 次。

`git-upload-pack`、`git pull` 和 `git clone` 命令共享一个速率限制，因为它们共享命令。

> [!note]
> [通用用户和 IP 速率限制](../administration/settings/user_and_ip_rate_limits.md)不适用于 Git SSH 操作。SSH 流量通过内部 API 到达极狐GitLab，因此仅计入此限制。

<a id="git-ssh-operations-on-gitlabcom"></a>

### JihuLab.com 上的 Git SSH 操作

在 JihuLab.com 上，Git SSH 操作使用默认速率限制，即每分钟 600 次操作。您无法更改此限制。

<a id="configure-the-gitlab-shell-operation-limit"></a>

### 配置 GitLab Shell 操作限制

`Git operations using SSH` 默认启用。默认为每个用户每分钟 600 次。

前提条件：

- 管理员访问权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **Git SSH 操作速率限制**。
1. 为 **每分钟 Git 操作数上限** 输入一个值。
   - 要禁用速率限制，请将其设置为 `0`。
1. 选择 **保存更改**。
