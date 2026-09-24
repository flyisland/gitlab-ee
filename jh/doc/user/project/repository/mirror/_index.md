---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use repository mirroring to push or pull the contents of a Git repository into another repository.
title: 仓库镜像
---

{{< details >}}

- Tier: 基础版、专业版、旗舰版
- Offering: JihuLab.com、私有化部署

{{< /details >}}

你可以将仓库镜像到外部源或从外部源镜像。你可以选择哪个仓库作为源。分支、标签和提交会自动同步。

存在几种镜像方法：

- [推送](push.md)：将仓库从极狐GitLab 镜像到另一个位置。
- [拉取](pull.md)：从另一个位置镜像仓库。在专业版和旗舰版中可用。
- [双向](bidirectional.md) 镜像也可用，但可能引起冲突。

在以下情况下使用仓库镜像：

- 项目的规范版本已迁移至极狐GitLab。为了继续在旧位置提供项目副本，请将你的极狐GitLab 仓库配置为[推送镜像](push.md)。你在极狐GitLab 仓库中所做的更改将被复制到旧位置。
- 你的极狐GitLab 实例是私有的，但你想将某些项目开源。
- 你已迁移至极狐GitLab，但项目的规范版本在其他地方。将你的极狐GitLab 仓库配置为对其他项目的[拉取镜像](pull.md)。你的极狐GitLab 仓库会拉取该项目的提交、标签和分支的副本，这些副本可在极狐GitLab 中使用。

不支持以下情况：

- SCP 风格的 URL。目前正在实现中。
- 通过[哑 HTTP 协议](https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols#_dumb_http)镜像仓库。

<a id="create-a-repository-mirror"></a>

## 创建仓库镜像

先决条件：

- 你必须具有项目的维护者或所有者角色。
- 如果你的镜像通过 `ssh://` 连接，则必须能在服务器上检测到主机密钥，或者你必须拥有密钥的本地副本。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **镜像仓库**。
1. 选择 **添加新镜像**。
1. 输入一个 **Git 仓库 URL**。该仓库必须可以通过 `http://`、`https://`、`ssh://` 或 `git://` 访问。
1. 选择 **镜像方向**。更多信息，请参见[拉取镜像](pull.md) 和[推送镜像](push.md)。
1. 如果你输入了 `ssh://` URL，请选择以下任一：
   - **检测主机密钥**：极狐GitLab 从服务器获取主机密钥并显示指纹。
   - **手动输入主机密钥**，然后在 **SSH 主机密钥** 中输入主机密钥。

   镜像仓库时，极狐GitLab 会在连接前确认至少有一个存储的主机密钥匹配。这项检查可以防止你的镜像被注入恶意代码，或防止你的密码被窃取。

   - 要创建使用 SSH 认证的仓库镜像，请参见[使用 SSH 认证创建镜像](#example-create-mirror-with-ssh-authentication) 示例。
1. 选择一个 **认证方法**。更多信息，请参见[镜像的认证方法](#authentication-methods-for-mirrors)。
1. 如果你使用 SSH 主机密钥进行认证，请[验证主机密钥](#verify-a-host-key) 以确保其正确。
1. 为了防止强制推送导致分支分歧，请选择 **保留分歧引用**。更多信息，请参见[保留分歧引用](push.md#keep-divergent-refs)。
1. 可选。要限制镜像的分支数量，可选择 **仅镜像受保护分支** 或在 **镜像特定分支** 中输入正则表达式。
1. 选择 **镜像仓库**。

<a id="example-create-mirror-with-ssh-authentication"></a>

### 示例：使用 SSH 认证创建镜像

如果你选择 `SSH 公钥` 作为认证方法，极狐GitLab 会为你的极狐GitLab 仓库生成一个公钥。你必须将此密钥提供给非极狐GitLab 服务器。更多信息，请参见[获取你的 SSH 公钥](#get-your-ssh-public-key)。

要使用 SSH 认证创建仓库镜像：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **镜像仓库**。
1. 选择 **添加新镜像**。
1. 输入一个 **Git 仓库 URL**。提供一个格式为 `ssh://gitlab.com/gitlab-org/gitlab.git` 的 URL。

   > [!note]
   > SSH URL 必须使用 `ssh://host/path/to/repo.git` 格式，而不是 SCP 风格 URL (`git@host:path/to/repo.git`)。将冒号 (`:`) 替换为斜杠 (`/`)，并添加 `ssh://` 前缀。

1. 选择 **镜像方向**。更多信息，请参见[拉取镜像](pull.md) 和[推送镜像](push.md)。
1. 选择 **检测主机密钥** 或 **手动输入主机密钥**。
1. 在 **认证方法** 字段中，选择 **SSH 公钥**。
1. 在 **用户名** 字段中，添加 `git`。
1. 可选。配置 **镜像分支** 设置。
1. 选择 **镜像仓库**。
1. 复制 SSH 公钥并将其提供给非极狐GitLab 服务器。

<a id="mirror-only-protected-branches"></a>

### 仅镜像受保护分支

你可以选择仅镜像镜像项目中的[受保护分支](../branches/protected.md)，无论是从远程仓库还是到远程仓库。对于[拉取镜像](pull.md)，镜像项目中的非受保护分支不会被镜像，并且可能会出现分歧。

要使用此选项，请在创建仓库镜像时选择 **仅镜像受保护分支**。

<a id="mirror-specific-branches"></a>

### 镜像特定分支

{{< details >}}

- Tier: 专业版、旗舰版
- Offering: JihuLab.com、私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.0 中默认启用。
- 在极狐GitLab 16.2 中 GA。功能标志 `mirror_only_branches_match_regex` 已移除。

{{< /history >}}

要仅镜像名称匹配 [RE2 正则表达式](https://github.com/google/re2/wiki/Syntax) 的分支，请在 **镜像特定分支** 字段中输入正则表达式。名称不匹配该正则表达式的分支不会被镜像。

<a id="update-a-mirror"></a>

## 更新镜像

镜像仓库更新时，所有新分支、标签和提交都会显示在项目的活动提要中。极狐GitLab 上的仓库镜像会自动更新。你也可以手动触发更新：

- 在 JihuLab.com 上最多每 5 分钟一次。
- 根据私有化部署实例上管理员设置的[拉取镜像间隔限制](../../../../administration/instance_limits.md#pull-mirroring-interval)进行。

> [!note]
> 极狐GitLab 静默模式会禁用推送和拉取更新。

<a id="force-an-update"></a>

### 强制更新

虽然镜像会按计划自动更新，但你可以强制立即更新，除非：

- 镜像正在更新中。
- 上次更新后拉取镜像的[间隔（以秒为单位）](../../../../administration/instance_limits.md#pull-mirroring-interval)尚未结束。

先决条件：

- 你必须具有项目的维护者或所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **镜像仓库**。
1. 滚动到 **已镜像的仓库**，并确定要更新的镜像。
1. 选择 **立即更新** ({{< icon name="retry" >}})。

<a id="authentication-methods-for-mirrors"></a>

## 镜像的认证方法

创建镜像时，你必须为其配置认证方法。极狐GitLab 支持以下认证方法：

- SSH 认证。
- 用户名和密码。

对于[项目访问令牌](../../settings/project_access_tokens.md) 或[群组访问令牌](../../../group/settings/group_access_tokens.md)，使用非空白值作为用户名，并将令牌作为密码。

<a id="ssh-authentication"></a>

### SSH 认证

SSH 认证是相互的：

- 你必须向服务器证明你有权访问该仓库。
- 服务器也必须向你证明其身份。

对于 SSH 认证，你提供密码或公钥作为凭证。另一个仓库所在的服务器提供其主机密钥作为凭证。你必须手动[验证主机密钥的指纹](#verify-a-host-key)。

如果你通过 SSH（使用 `ssh://` URL）进行镜像，你可以使用以下方式认证：

- 基于密码的认证，如同通过 HTTPS。
- 公钥认证。这种方法通常比密码认证更安全，特别是当另一个仓库支持[部署密钥](../../deploy_keys/_index.md)时。

<a id="get-your-ssh-public-key"></a>

### 获取你的 SSH 公钥

当你镜像仓库并选择 **SSH 公钥** 作为认证方法时，极狐GitLab 会为你生成一个公钥。非极狐GitLab 服务器需要此密钥来建立与你的极狐GitLab 仓库的信任。要复制你的 SSH 公钥：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **镜像仓库**。
1. 滚动到 **已镜像的仓库**。
1. 确定正确的仓库，然后选择 **复制 SSH 公钥** ({{< icon name="copy-to-clipboard" >}})。
1. 将公钥添加到另一个仓库的配置中：
   - 如果另一个仓库托管在极狐GitLab 上，请将公钥添加为[部署密钥](../../deploy_keys/_index.md)。
   - 如果另一个仓库托管在其他地方，请将密钥添加到你的用户的 `authorized_keys` 文件中。将整个 SSH 公钥粘贴到文件中，独占一行，然后保存。

如果你随时需要更改密钥，你可以移除并重新添加镜像以生成新密钥。用新密钥更新另一个仓库以保持镜像运行。

> [!note]
> 生成的密钥存储在极狐GitLab 数据库中，而不是文件系统中。因此，镜像的 SSH 公钥认证不能在预接收钩子中使用。

<a id="verify-a-host-key"></a>

### 验证主机密钥

当使用主机密钥时，务必验证指纹是否与您预期的相符。
JihuLab.com 和其他代码托管站点会发布其指纹供您检查：

- [AWS CodeCommit](https://docs.aws.amazon.com/codecommit/latest/userguide/regions.html#regions-fingerprints)
- [Bitbucket](https://support.atlassian.com/bitbucket-cloud/docs/configure-ssh-and-two-step-verification/)
- [Codeberg](https://docs.codeberg.org/security/ssh-fingerprint/)
- [GitHub](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)
- [JihuLab.com](../../../jihulab_com/_index.md#ssh-host-keys-fingerprints)
- [Launchpad](https://documentation.ubuntu.com/launchpad/user/reference/ssh-fingerprints/)
- [Savannah](https://savannah.gnu.org/maintenance/SshAccess/)
- [SourceForge](https://sourceforge.net/p/forge/documentation/SSH%20Key%20Fingerprints/)

其他提供商的指纹可能不同。如果你：
- 运行私有化部署极狐GitLab。
- 可以访问另一个仓库的服务器。

你可以使用以下命令安全地收集密钥指纹：

```shell
$ cat /etc/ssh/ssh_host*pub | ssh-keygen -E md5 -l -f -
256 MD5:f4:28:9f:23:99:15:21:1b:bf:ed:1f:8e:a0:76:b2:9d root@example.com (ECDSA)
256 MD5:e6:eb:45:8a:3c:59:35:5f:e9:5b:80:12:be:7e:22:73 root@example.com (ED25519)
2048 MD5:3f:72:be:3d:62:03:5c:62:83:e8:6e:14:34:3a:85:1d root@example.com (RSA)
```

旧版本的 SSH 可能需要从命令中删除 `-E md5`。