---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用代码仓库镜像推送或拉取 Git 代码仓库的内容到另一个代码仓库。
title: 代码仓库镜像
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以在代码仓库与外部源之间进行镜像。您可以选择哪个代码仓库作为源。分支、标签和提交会自动同步。

存在多种镜像方式：

- [推送](push.md)：将代码仓库从极狐GitLab 镜像到另一个位置。
- [拉取](pull.md)：从另一个位置镜像代码仓库。适用于专业版和旗舰版。
- [双向](bidirectional.md)镜像也可用，但可能导致冲突。

在以下情况下镜像代码仓库：

- 您项目的规范版本已迁移到极狐GitLab。为了在项目之前的位置继续提供副本，请将您的极狐GitLab 代码仓库配置为[推送镜像](push.md)。您对极狐GitLab 代码仓库所做的更改会复制到旧位置。
- 您的极狐GitLab 实例是私有的，但您想开源一些项目。
- 您已迁移到极狐GitLab，但您项目的规范版本在其他地方。请将您的极狐GitLab 代码仓库配置为另一个项目的[拉取镜像](pull.md)。您的极狐GitLab 代码仓库会拉取该项目的提交、标签和分支的副本。它们可在极狐GitLab 上使用。

不支持以下内容：

- SCP 风格的 URL。实现 SCP 风格 URL 的工作仍在进行中。
  有关更多信息并跟踪其进展，请参阅
  [议题 18993](https://gitlab.com/gitlab-org/gitlab/-/issues/18993)。
- 通过[哑 HTTP 协议](https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols#_dumb_http)镜像代码仓库。
- 在使用不同对象格式的代码仓库之间进行镜像。
  例如，在 SHA-1 和 [SHA-256](../../_index.md#create-a-project-that-uses-sha-256-hashing) 代码仓库之间。

<a id="create-a-repository-mirror"></a>

## 创建代码仓库镜像

先决条件：

- 您必须具有该项目的维护者或所有者角色。
- 如果您的镜像通过 `ssh://` 连接，则主机密钥必须可在服务器上检测到，
  或者您必须拥有该密钥的本地副本。

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**镜像代码仓库**。
1. 选择**添加新的**。
1. 输入 **Git 代码仓库 URL**。该代码仓库必须可通过 `http://`、`https://`、`ssh://` 或 `git://` 访问。
1. 选择**镜像方向**。有关更多信息，请参阅[拉取镜像](pull.md)和[推送镜像](push.md)。
1. 如果您输入了 `ssh://` URL，请选择以下之一：
   - **检测主机密钥**：极狐GitLab 从服务器获取主机密钥并显示指纹。
   - **手动输入主机密钥**，并将主机密钥输入到 **SSH 主机密钥**中。

   镜像代码仓库时，极狐GitLab 会在连接前确认至少有一个存储的主机密钥匹配。此检查可保护您的镜像免受恶意代码注入，
   或防止您的密码被盗。

   - 要使用 SSH 认证创建代码仓库镜像，
     请参阅[使用 SSH 认证创建镜像](#example-create-mirror-with-ssh-authentication)
     示例。

1. 选择**认证方法**。有关更多信息，请参阅
   [镜像的认证方法](#authentication-methods-for-mirrors)。
1. 如果您使用 SSH 主机密钥进行认证，请[验证主机密钥](#verify-a-host-key)
   以确保其正确。
1. 为防止对已分叉的引用强制推送，请选择**保留分叉的引用**。有关更多信息，请参阅[保留分叉的引用](push.md#keep-divergent-refs)。
1. 可选。要限制镜像的分支数量，请选择
   **仅镜像受保护分支**或在**镜像特定分支**中输入正则表达式。
1. 选择**镜像代码仓库**。

<a id="example-create-mirror-with-ssh-authentication"></a>

### 示例：使用 SSH 认证创建镜像

如果您选择 `SSH public key` 作为认证方法，极狐GitLab 会为您的极狐GitLab 代码仓库生成一个公钥。您必须将此密钥提供给非极狐GitLab 服务器。
有关更多信息，请参阅[获取您的 SSH 公钥](#get-your-ssh-public-key)。

要使用 SSH 认证镜像代码仓库：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**镜像代码仓库**。
1. 选择**添加新的**。
1. 输入 **Git 代码仓库 URL**。提供格式为 `ssh://gitlab.com/gitlab-org/gitlab.git`的 URL。

   > [!note]
   > SSH URL 必须使用 `ssh://host/path/to/repo.git` 格式，而不是
   > SCP 风格的 URL（`git@host:path/to/repo.git`）。将冒号（`:`）
   > 替换为斜杠（`/`）并添加 `ssh://` 前缀。

1. 选择**镜像方向**。有关更多信息，请参阅[拉取镜像](pull.md)和[推送镜像](push.md)。
1. 选择**检测主机密钥**或**手动输入主机密钥**。
1. 在**认证方法**字段中，选择 **SSH 公钥**。
1. 在**用户名**字段中，添加 `git`。
1. 可选。配置**镜像分支**设置。
1. 选择**镜像代码仓库**。
1. 复制 SSH 公钥并将其提供给您的非极狐GitLab 服务器。

<a id="mirror-only-protected-branches"></a>

### 仅镜像受保护分支

您可以选择仅镜像镜像项目中的
[受保护分支](../branches/protected.md)，
无论是从您的远程代码仓库还是到您的远程代码仓库。对于[拉取镜像](pull.md)，镜像项目中的非受保护分支不会被镜像，并且可能分叉。

要使用此选项，请在创建代码仓库镜像时选择**仅镜像受保护分支**。

<a id="mirror-specific-branches"></a>

### 镜像特定分支

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要仅镜像名称匹配 [RE2 正则表达式](https://github.com/google/re2/wiki/Syntax)的分支，
请在**镜像特定分支**字段中输入正则表达式。名称不匹配该正则表达式的分支不会被镜像。

<a id="update-a-mirror"></a>

## 更新镜像

当镜像代码仓库更新时，所有新分支、标签和提交都会显示在项目的活动源中。极狐GitLab 上的代码仓库镜像会自动更新。您也可以手动触发更新：

- 在 JihuLab.com 上最多每五分钟一次。
- 根据管理员在极狐GitLab 私有化部署实例上设置的[拉取镜像间隔限制](../../../../administration/instance_limits.md#pull-mirroring-interval)。

> [!note]
> [极狐GitLab 静默模式](../../../../administration/silent_mode/_index.md)会同时禁用推送和拉取更新。

<a id="force-an-update"></a>

### 强制更新

虽然镜像会按计划自动更新，但您可以强制立即更新，除非：

- 镜像已在更新中。
- 拉取镜像限制的[间隔（以秒为单位）](../../../../administration/instance_limits.md#pull-mirroring-interval)
  在其上次更新后尚未经过。

先决条件：

- 您必须具有该项目的维护者或所有者角色。

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**镜像代码仓库**。
1. 滚动到**已镜像的代码仓库**并确定要更新的镜像。
1. 选择**立即更新**（{{< icon name="retry" >}}）。

<a id="authentication-methods-for-mirrors"></a>

## 镜像的认证方法

创建镜像时，您必须为其配置认证方法。极狐GitLab 支持以下认证方法：

- [SSH 认证](#ssh-authentication)。
- 用户名和密码。

对于[项目访问令牌](../../settings/project_access_tokens.md)或
[群组访问令牌](../../../group/settings/group_access_tokens.md)，
请使用非空值作为用户名，并将令牌作为密码。

<a id="ssh-authentication"></a>

### SSH 认证

SSH 认证是相互的：

- 您必须向服务器证明您有权访问该代码仓库。
- 服务器也必须向您证明它确实是它所声称的身份。

对于 SSH 认证，您以密码或公钥的形式提供您的凭据。另一个代码仓库所在的服务器以主机密钥的形式提供其凭据。您必须手动[验证此主机密钥的指纹](#verify-a-host-key)。

如果您通过 SSH 进行镜像（使用 `ssh://` URL），您可以使用以下方式进行认证：

- 基于密码的认证，就像通过 HTTPS 一样。
- 公钥认证。此方法通常比密码认证更安全，
  尤其是当另一个代码仓库支持[部署密钥](../../deploy_keys/_index.md)时。

<a id="get-your-ssh-public-key"></a>

### 获取您的 SSH 公钥

当您镜像代码仓库并选择 **SSH 公钥**作为您的认证方法时，极狐GitLab 会为您生成一个公钥。非极狐GitLab 服务器需要此密钥来与您的极狐GitLab 代码仓库建立信任。要复制您的 SSH 公钥：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**镜像代码仓库**。
1. 滚动到**已镜像的代码仓库**。
1. 确定正确的代码仓库，并选择**复制 SSH 公钥**（{{< icon name="copy-to-clipboard" >}}）。
1. 将SSH 公钥添加到另一个代码仓库的配置中：
   - 如果另一个代码仓库托管在极狐GitLab 上，请将SSH 公钥
     添加为[部署密钥](../../deploy_keys/_index.md)。
   - 如果另一个代码仓库托管在其他地方，请将该密钥添加到
     您用户的 `authorized_keys` 文件中。将整个SSH 公钥粘贴到
     文件中，单独占一行并保存。

如果您必须在任何时候更改密钥，您可以移除并重新添加镜像以生成新密钥。使用新密钥更新另一个代码仓库以保持镜像运行。

> [!note]
> 生成的密钥存储在极狐GitLab 数据库中，而不是文件系统中。因此，
> 镜像的 SSH 公钥认证不能用于 pre-receive 钩子。

<a id="verify-a-host-key"></a>

### 验证主机密钥

使用主机密钥时，请始终验证指纹与您的预期匹配。JihuLab.com 和其他代码托管站点会发布其指纹供您检查：

- [AWS CodeCommit](https://docs.aws.amazon.com/codecommit/latest/userguide/regions.html#regions-fingerprints)
- [Bitbucket](https://support.atlassian.com/bitbucket-cloud/docs/configure-ssh-and-two-step-verification/)
- [Codeberg](https://docs.codeberg.org/security/ssh-fingerprint/)
- [GitHub](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)
- [JihuLab.com](../../../jihulab_com/_index.md#ssh-host-keys-fingerprints)
- [Launchpad](https://documentation.ubuntu.com/launchpad/user/reference/ssh-fingerprints/)
- [Savannah](https://savannah.gnu.org/maintenance/SshAccess/)
- [SourceForge](https://sourceforge.net/p/forge/documentation/SSH%20Key%20Fingerprints/)

其他提供商各有不同。如果您满足以下条件，可以使用以下命令安全地收集密钥指纹：

- 运行极狐GitLab 私有化部署。
- 有权访问另一个代码仓库的服务器。

```shell
$ cat /etc/ssh/ssh_host*pub | ssh-keygen -E md5 -l -f -
256 MD5:f4:28:9f:23:99:15:21:1b:bf:ed:1f:8e:a0:76:b2:9d root@example.com (ECDSA)
256 MD5:e6:eb:45:8a:3c:59:35:5f:e9:5b:80:12:be:7e:22:73 root@example.com (ED25519)
2048 MD5:3f:72:be:3d:62:03:5c:62:83:e8:6e:14:34:3a:85:1d root@example.com (RSA)
```

较旧版本的 SSH 可能要求您从命令中移除 `-E md5`。
