---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Git LFS 故障排除
---

使用 Git LFS 时，您可能会遇到以下问题。

- 不支持 Git LFS 原始 v1 API。
- Git LFS 请求使用 HTTPS 凭据，这意味着您应使用 Git
  [凭据存储](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage)。
- [群组 Wiki](../../../user/project/wiki/group.md) 不支持 Git LFS。

<a id="error-repository-or-object-not-found"></a>

## 错误：找不到代码仓库或对象

此错误可能由多种原因引起，包括：

- 您没有访问某个 LFS 对象的权限。请确认您有权限推送到该项目，或从该项目拉取。
- 该项目无权访问该 LFS 对象。您想要推送（或拉取）的 LFS 对象已不再可供该项目使用。大多数情况下，该对象已从服务器上移除。
- 本地 Git 代码仓库使用的是已弃用的 Git LFS API 版本。请更新本地 Git LFS 副本，然后重试。

<a id="invalid-status-for-url--501"></a>

## `<url>` 的状态无效：501

Git LFS 会将失败记录到日志文件中。要查看此日志文件：

1. 在终端窗口中，转到项目的目录。
1. 运行以下命令以查看最近的日志文件：

   ```shell
   git lfs logs last
   ```

以下问题可能导致 `501` 错误：

- 项目的设置中未启用 Git LFS。请检查项目设置并启用 Git LFS。
- 极狐GitLab 服务器上未启用 Git LFS 支持。请向极狐GitLab 管理员咨询服务器上未启用 Git LFS 的原因。有关如何启用 Git LFS 支持的说明，请参阅
  [LFS 管理文档](../../../administration/lfs/_index.md)。
- 极狐GitLab 服务器不支持该 Git LFS 客户端版本。您应：
  1. 使用 `git lfs version` 检查您的 Git LFS 版本。
  1. 使用 `git lfs -l` 检查项目的 Git 配置中是否有已弃用 API 的痕迹。如果您的配置设置了 `batch = false`，
     请删除该行，然后更新您的 Git LFS 客户端。极狐GitLab 仅支持
     1.0.1 及更高版本。

<a id="credentials-are-always-required-when-pushing-an-object"></a>

## 推送对象时始终需要凭据

Git LFS 在每次推送每个对象时都会通过 HTTP 基本认证对用户进行身份验证，因此需要用户的 HTTPS 凭据。默认情况下，Git 支持记住您使用的每个代码仓库的凭据。有关更多信息，请参阅 [Git 官方文档](https://git-scm.com/docs/gitcredentials)。

例如，您可以告诉 Git 在您预期推送对象的一段时间内记住您的密码。此示例会记住您的凭据一小时（3600 秒），一小时后您必须重新进行身份验证：

```shell
git config --global credential.helper 'cache --timeout=3600'
```

要存储并加密凭据，请参阅：

- MacOS：使用 `osxkeychain`。
- Windows：使用 `wincred` 或 Microsoft
  [Git Credential Manager for Windows](https://github.com/Microsoft/Git-Credential-Manager-for-Windows/releases)。

要详细了解如何存储用户凭据，请参阅 [Git 凭据存储文档](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage)。

<a id="lfs-objects-are-missing-on-push"></a>

## 推送时缺少 LFS 对象

极狐GitLab 会在推送时检查文件以检测 LFS 指针。如果检测到 LFS 指针，极狐GitLab 会尝试验证这些文件是否已存在于 LFS 中。如果您为 Git LFS 使用单独的服务器，并遇到此问题：

1. 确认您已在本地安装 Git LFS。
1. 考虑使用 `git lfs push --all` 手动推送。

如果您将 Git LFS 文件存储在极狐GitLab 之外，可以在项目上
[禁用 Git LFS](_index.md#enable-or-disable-git-lfs-for-a-project)。

<a id="hosting-lfs-objects-externally"></a>

## 在外部托管 LFS 对象

您可以通过设置自定义 LFS URL 在外部托管 LFS 对象：

```shell
git config -f .lfsconfig lfs.url https://example.com/<project>.git/info/lfs
```

如果您将 LFS 数据存储在设备（如 Nexus Repository）上，可能需要这样做。如果您使用外部 LFS 存储，极狐GitLab 无法验证 LFS 对象。如果您启用了极狐GitLab LFS 支持，推送就会失败。

要停止推送失败，您可以在[项目设置](_index.md#enable-or-disable-git-lfs-for-a-project)中禁用 Git LFS 支持。但是，此方法可能并不理想，因为它还会禁用极狐GitLab LFS 功能，例如：

- 验证 LFS 对象。
- LFS 的极狐GitLab UI 集成。

<a id="io-timeout-when-pushing-lfs-objects"></a>

## 推送 LFS 对象时出现 I/O 超时

如果您的网络状况不稳定，Git LFS 客户端在尝试上传文件时可能会超时。您可能会看到如下错误：

```shell
LFS: Put "http://example.com/root/project.git/gitlab-lfs/objects/<OBJECT-ID>/15":
read tcp your-instance-ip:54544->your-instance-ip:443: i/o timeout
error: failed to push some refs to 'ssh://example.com:2222/root/project.git'
```

要解决此问题，请将客户端活动超时设置为更高的值。例如，要将超时设置为 60 秒：

```shell
git config lfs.activitytimeout 60
```

<a id="encountered-n-files-that-should-have-been-pointers-but-werent"></a>

## 遇到 `n` 个本应是指针但不是指针的文件

此错误表示代码仓库应使用 Git LFS 跟踪某个文件，但实际并未跟踪。

要解决此问题，请迁移受影响的文件，并将它们推送到代码仓库：

1. 将该文件迁移到 LFS：

   ```shell
   git lfs migrate import --yes --no-rewrite "<your-file>"
   ```

1. 推送回您的代码仓库：

   ```shell
   git push
   ```

1. 可选。清理您的 `.git` 文件夹：

   ```shell
   git reflog expire --expire-unreachable=now --all
   git gc --prune=now
   ```

<a id="lfs-objects-not-checked-out-automatically"></a>

## LFS 对象未自动检出

您可能会遇到 Git LFS 对象未自动检出的问题。出现这种情况时，文件存在，但包含的是指针引用而非实际内容。如果您打开这些文件，可能看不到预期的文件内容，而是看到如下所示的 LFS 指针：

```plaintext
version https://git-lfs.github.com/spec/v1
oid sha256:d276d250bc645e27a1b0ab82f7baeb01f7148df7e4816c4b333de12d580caa29
size 2323563
```

当文件名与 `.gitattributes` 文件中的规则不匹配时，会出现此问题。LFS 文件只有在与 `.gitattributes`中的规则匹配时才会自动检出。

在 `git-lfs` v3.6.0 中，此行为发生了变化，[LFS 文件的匹配方式得到了优化](https://github.com/git-lfs/git-lfs/pull/5699)。

极狐GitLab Runner v17.7.0 将默认辅助镜像升级为使用 `git-lfs` v3.6.0。

为了在不同大小写敏感度各异的操作系统之间保持一致的行为，请调整您的 `.gitattributes` 文件以匹配不同的大小写模式。

例如，如果您有名为 `image.jpg` 和 `wombat.JPG`的 LFS 文件，请在 `.gitattributes` 文件中使用不区分大小写的正则表达式：

```plaintext
*.[jJ][pP][gG] filter=lfs diff=lfs merge=lfs -text
*.[jJ][pP][eE][gG] filter=lfs diff=lfs merge=lfs -text
```

如果您只在区分大小写的文件系统（例如大多数 Linux 发行版）上工作，可以使用更简单的模式。例如：

```plaintext
*.jpg filter=lfs diff=lfs merge=lfs -text
*.jpeg filter=lfs diff=lfs merge=lfs -text
```

<a id="warning-possible-lfs-configuration-issue"></a>

## 警告：可能存在 LFS 配置问题

您可能会在极狐GitLab UI 中看到如下警告：

```plaintext
Possible LFS configuration issue. This project contains LFS objects but there is no .gitattributes file.
You can ignore this message if you recently added a .gitattributes file.
```

当启用了 Git LFS 且包含 LFS 对象，但在项目根目录中未检测到 `.gitattributes` 文件时，会出现此警告。Git 支持将 `.gitattributes` 文件放在子目录中，但极狐GitLab 只检查根目录中的此文件。

变通方法是在根目录中创建一个空的 `.gitattributes` 文件：

{{< tabs >}}

{{< tab title="使用 Git" >}}

1. 克隆您的代码仓库：

   ```shell
   git clone <repository>
   cd repository
   ```

1. 创建一个空的 `.gitattributes` 文件：

   ```shell
   touch .gitattributes
   git add .gitattributes
   git commit -m "Add empty .gitattributes file to root directory"
   git push
   ```

{{< /tab >}}

{{< tab title="在 UI 中" >}}

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 选择加号图标（**+**）和**新建文件**。
1. 在**文件名**字段中，输入 `.gitattributes`。
1. 选择**提交更改**。
1. 在**提交信息**字段中，输入提交信息。
1. 选择**提交更改**。

{{< /tab >}}

{{< /tabs >}}
