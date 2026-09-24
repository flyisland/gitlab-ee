---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将 NFS 与极狐GitLab 结合使用
description: 将 NFS 与极狐GitLab 结合使用。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

NFS 可以作为对象存储的替代方案，但出于性能原因，通常不建议这样做。

对于 LFS、上传文件和产物等数据对象，在可能的情况下，建议使用[对象存储服务](object_storage.md)而非 NFS，因为其性能更佳。
在消除 NFS 的使用时，除了迁移到对象存储之外，还需要[执行其他步骤](object_storage.md#alternatives-to-file-system-storage)。

NFS 不能用于代码仓库存储。

有关可用于测试文件系统性能的步骤，请参阅
[文件系统性能基准测试](operations/filesystem_benchmarking.md)。

<a id="fast-lookup-of-authorized-ssh-keys"></a>

## 授权 SSH 密钥的快速查找

[快速 SSH 密钥查找](operations/fast_ssh_key_lookup.md)功能可以提高
极狐GitLab 实例的性能，即使它们使用块存储。

[快速 SSH 密钥查找](operations/fast_ssh_key_lookup.md)是
`authorized_keys`（位于 `/var/opt/gitlab/.ssh`）的替代方案，它使用极狐GitLab 数据库。

NFS 会增加延迟，因此如果将 `/var/opt/gitlab` 迁移到 NFS，建议使用快速查找。

我们正在研究将
[快速查找作为默认设置](https://gitlab.com/groups/gitlab-org/-/work_items/3104)。

<a id="nfs-server"></a>

## NFS 服务器

安装 `nfs-kernel-server` 软件包允许您与运行极狐GitLab 应用程序的客户端共享目录：

```shell
sudo apt-get update
sudo apt-get install nfs-kernel-server
```

<a id="required-features"></a>

### 必需功能

**文件锁定**：极狐GitLab **需要**建议性文件锁定，该功能仅在 NFS 版本 4 中原生支持。只要使用 Linux 内核 2.6.5+，NFSv3 也支持锁定。我们建议使用版本 4，并且不专门测试 NFSv3。

<a id="recommended-options"></a>

### 推荐选项

在定义 NFS 导出时，我们建议您同时添加以下选项：

- `no_root_squash` - NFS 通常会将 `root` 用户更改为 `nobody`。当 NFS 共享被许多不同的用户访问时，这是一个很好的安全措施。但是，在这种情况下，只有极狐GitLab 使用 NFS 共享，因此是安全的。极狐GitLab 建议使用 `no_root_squash` 设置，因为我们需要自动管理文件权限。如果没有此设置，当 Linux 软件包尝试更改权限时，您可能会收到错误。极狐GitLab 和其他捆绑组件不以 `root` 身份运行，而是以非特权用户身份运行。建议使用 `no_root_squash` 是为了允许 Linux 软件包根据需要设置文件的所有权和权限。在某些无法使用 `no_root_squash` 选项的情况下，`root` 标志可以达到相同的结果。
- `sync` - 强制同步行为。默认是异步的，在某些情况下，如果在数据同步之前发生故障，可能会导致数据丢失。

由于在 LDAP 环境下运行 Linux 软件包的复杂性，以及在没有 LDAP 的情况下维护 ID 映射的复杂性，在大多数情况下，您应该启用数字 UID 和 GID（在某些情况下默认关闭），以简化系统之间的权限管理：

- [NetApp 说明](https://docs.netapp.com/a/ontap/7-mode/8.2.4/File-Access-And-Protocols-Management-Guide-For-7-Mode.pdf)
- 对于非 NetApp 设备，通过执行与[启用 NFSv4 idmapper](https://wiki.archlinux.org/title/NFS#Enabling_NFSv4_idmapping)相反的操作来禁用 NFSv4 `idmapping`

<a id="disable-nfs-server-delegation"></a>

### 禁用 NFS 服务器委派

我们建议所有 NFS 用户禁用 NFS 服务器委派功能。这是为了避免一个 [Linux 内核错误](https://bugzilla.redhat.com/show_bug.cgi?id=1552203)，该错误会导致 NFS 客户端因
[大量 `TEST_STATEID` NFS 消息导致的过多网络流量](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/52017)而急剧变慢。

要禁用 NFS 服务器委派，请执行以下操作：

1. 在 NFS 服务器上，运行：

   ```shell
   echo 0 > /proc/sys/fs/leases-enable
   sysctl -w fs.leases-enable=0
   ```

1. 重启 NFS 服务器进程。例如，在 CentOS 上运行 `service nfs restart`。

> [!note]
> 该内核错误可能已在
> [包含此提交的更新内核中](https://github.com/torvalds/linux/commit/95da1b3a5aded124dd1bda1e3cdb876184813140)修复。
> Red Hat Enterprise 7 于 2019 年 8 月 6 日[发布了内核更新](https://access.redhat.com/errata/RHSA-2019:2029)，可能也已解决此问题。
> 如果您确定使用的是已修复的 Linux 内核版本，则可能无需禁用 NFS 服务器委派。话虽如此，极狐GitLab 仍鼓励实例管理员保持禁用 NFS 服务器委派。

<a id="nfs-client"></a>

## NFS 客户端

`nfs-common` 提供 NFS 功能，而无需安装我们不需要在应用程序节点上运行的服务器组件。

```shell
apt-get update
apt-get install nfs-common
```

<a id="mount-options"></a>

### 挂载选项

以下是一个示例片段，可添加到 `/etc/fstab`：

```plaintext
10.1.0.1:/var/opt/gitlab/.ssh /var/opt/gitlab/.ssh nfs4 defaults,vers=4.1,hard,rsize=1048576,wsize=1048576,noatime,nofail,_netdev,lookupcache=positive 0 2
10.1.0.1:/var/opt/gitlab/gitlab-rails/uploads /var/opt/gitlab/gitlab-rails/uploads nfs4 defaults,vers=4.1,hard,rsize=1048576,wsize=1048576,noatime,nofail,_netdev,lookupcache=positive 0 2
10.1.0.1:/var/opt/gitlab/gitlab-rails/shared /var/opt/gitlab/gitlab-rails/shared nfs4 defaults,vers=4.1,hard,rsize=1048576,wsize=1048576,noatime,nofail,_netdev,lookupcache=positive 0 2
10.1.0.1:/var/opt/gitlab/gitlab-ci/builds /var/opt/gitlab/gitlab-ci/builds nfs4 defaults,vers=4.1,hard,rsize=1048576,wsize=1048576,noatime,nofail,_netdev,lookupcache=positive 0 2
```

您可以通过运行 `nfsstat -m` 和 `cat /etc/fstab` 来查看每个已挂载 NFS 文件系统的信息和设置的选项。

请注意，有几个选项您应该考虑使用：

| 设置                | 描述 |
|------------------------|-------------|
| `vers=4.1`             | 应使用 NFS v4.1 而不是 v4.0，因为 Linux 存在 [NFS v4.0 客户端错误](https://gitlab.com/gitlab-org/gitaly/-/issues/1339)，该错误可能因陈旧数据而导致严重问题。 |
| `nofail`               | 不要停止启动过程等待此挂载变为可用。 |
| `lookupcache=positive` | 告知 NFS 客户端遵循 `positive` 缓存结果，但使任何 `negative` 缓存结果失效。负缓存结果会导致 Git 出现问题。具体来说，`git push` 可能无法在所有 NFS 客户端上统一注册。负缓存会导致客户端“记住”这些文件之前不存在。 |
| `hard`                 | 而不是 `soft`。[更多详情](#soft-mount-option)。 |
| `cto`                  | `cto` 是默认选项，您应该使用它。不要使用 `nocto`。[更多详情](#nocto-mount-option)。 |
| `_netdev`              | 等待网络在线后再挂载文件系统。另请参阅 [`high_availability['mountpoint']`](https://gitlab.cn/docs/omnibus/settings/configuration/#start-linux-package-installation-services-only-after-a-given-file-system-is-mounted) 选项。 |

<a id="soft-mount-option"></a>

#### `soft` 挂载选项

建议您在挂载选项中使用 `hard`，除非您有特定原因使用 `soft`。

当 JihuLab.com 使用 NFS 时，我们使用了 `soft`，因为有时我们的 NFS 服务器会重启，而 `soft` 提高了可用性，但每个人的基础设施都不同。例如，如果您的 NFS 由具有冗余控制器的本地存储阵列提供，则您不必担心 NFS 服务器的可用性。

NFS 手册页说明：

> “soft” 超时在某些情况下可能导致静默数据损坏

请阅读 [Linux 手册页](https://linux.die.net/man/5/nfs) 以了解差异，如果您确实使用 `soft`，请确保您已采取措施降低风险。

如果您遇到可能由 NFS 服务器上的磁盘写入未发生而导致的行为，例如提交丢失，请使用 `hard` 选项，因为（来自手册页）：

> 仅在客户端响应能力比数据完整性更重要时才使用 soft 选项

其他供应商也提出了类似建议，包括[读写目录的推荐挂载选项](https://help.sap.com/docs/SUPPORT_CONTENT/basis/3354611703.html)和 NetApp 的[知识库](https://kb.netapp.com/on-prem/ontap/da/NAS/NAS-KBs/What_are_the_differences_between_hard_mount_and_soft_mount)。
他们强调，如果 NFS 客户端驱动程序缓存数据，`soft` 意味着无法确定极狐GitLab 的写入是否真正落盘。

使用 `hard` 选项设置的挂载点可能性能不佳，如果 NFS 服务器宕机，`hard` 会导致进程在与挂载点交互时挂起。使用 `SIGKILL`（`kill -9`）来处理挂起的进程。`intr` 选项
[在 2.6 内核中已停止工作](https://access.redhat.com/solutions/157873)。

<a id="nocto-mount-option"></a>

#### `nocto` 挂载选项

不要使用 `nocto`。相反，请使用默认的 `cto`。

使用 `nocto` 时，dentry 缓存始终被使用，从创建之时起最长可达 `acdirmax` 秒（属性缓存时间）。

这会导致多个客户端出现陈旧的 dentry 缓存问题，每个客户端可能看到目录的不同（缓存）版本。

来自 [Linux 手册页](https://linux.die.net/man/5/nfs) 的重要部分：

> 如果指定了 `nocto` 选项，客户端将使用非标准启发式方法来确定服务器上的文件何时发生更改。
>
> 使用 `nocto` 选项可能会提高只读挂载的性能，但仅应在服务器上的数据仅偶尔更改时使用。

我们在一个关于[推送后找不到引用](https://gitlab.com/gitlab-org/gitlab/-/issues/326066)的议题中注意到了这种行为，
新添加的松散引用在具有本地 dentry 缓存的不同客户端上可能被视为缺失，如
[此议题中所述](https://gitlab.com/gitlab-org/gitlab/-/issues/326066#note_539436931)。

<a id="a-single-nfs-mount"></a>

### 单个 NFS 挂载

建议将所有极狐GitLab 数据目录嵌套在一个挂载中，这样可以在不手动移动现有数据的情况下自动恢复备份。

```plaintext
mountpoint
└── gitlab-data
    ├── builds
    ├── shared
    └── uploads
```

为此，请使用嵌套在挂载点中的每个目录的路径配置 Linux 软件包，如下所示：

挂载 `/gitlab-nfs`，然后使用以下 Linux 软件包配置将每个数据位置移动到子目录：

```ruby
gitlab_rails['uploads_directory'] = '/gitlab-nfs/gitlab-data/uploads'
gitlab_rails['shared_path'] = '/gitlab-nfs/gitlab-data/shared'
gitlab_ci['builds_directory'] = '/gitlab-nfs/gitlab-data/builds'
```

运行 `sudo gitlab-ctl reconfigure` 以开始使用中心位置。请注意，如果您有现有数据，则需要手动将其复制或 rsync 到这些新位置，然后重启极狐GitLab。

<a id="bind-mounts"></a>

### 绑定挂载

无需更改 Linux 软件包中的配置，即可使用绑定挂载将数据存储在 NFS 挂载上。

绑定挂载提供了一种方法，可以只指定一个 NFS 挂载，然后将默认的极狐GitLab 数据位置绑定到该 NFS 挂载。首先，像通常一样在 `/etc/fstab` 中定义您的单个 NFS 挂载点。假设您的 NFS 挂载点是 `/gitlab-nfs`。然后，在 `/etc/fstab` 中添加以下绑定挂载：

```shell
/gitlab-nfs/gitlab-data/.ssh /var/opt/gitlab/.ssh none bind 0 0
/gitlab-nfs/gitlab-data/uploads /var/opt/gitlab/gitlab-rails/uploads none bind 0 0
/gitlab-nfs/gitlab-data/shared /var/opt/gitlab/gitlab-rails/shared none bind 0 0
/gitlab-nfs/gitlab-data/builds /var/opt/gitlab/gitlab-ci/builds none bind 0 0
```

使用绑定挂载要求您在尝试恢复之前手动确保数据目录为空。阅读更多关于
[恢复先决条件](backup_restore/_index.md)的信息。

<a id="multiple-nfs-mounts"></a>

### 多个 NFS 挂载

使用默认的 Linux 软件包配置时，您需要在所有极狐GitLab 集群节点之间共享 3 个数据位置。不应共享其他位置。以下是需要共享的 3 个位置：

| 位置 | 描述 | 默认配置 |
| -------- | ----------- | --------------------- |
| `/var/opt/gitlab/gitlab-rails/uploads` | 用户上传的附件 | `gitlab_rails['uploads_directory'] = '/var/opt/gitlab/gitlab-rails/uploads'` |
| `/var/opt/gitlab/gitlab-rails/shared` | 构建产物、GitLab Pages、LFS 对象和临时文件等对象。如果您使用 LFS，这可能也占您数据的很大一部分 | `gitlab_rails['shared_path'] = '/var/opt/gitlab/gitlab-rails/shared'` |
| `/var/opt/gitlab/gitlab-ci/builds` | 极狐GitLab CI/CD 构建日志 | `gitlab_ci['builds_directory'] = '/var/opt/gitlab/gitlab-ci/builds'` |

其他极狐GitLab 目录不应在节点之间共享。它们包含特定于节点的文件和不需要共享的极狐GitLab 代码。要将日志发送到中心位置，请考虑使用远程 syslog。Linux 软件包提供 [UDP 日志传输](https://gitlab.cn/docs/omnibus/settings/logs/#udp-log-forwarding)的配置。

拥有多个 NFS 挂载要求您在尝试恢复之前手动确保数据目录为空。阅读更多关于
[恢复先决条件](backup_restore/_index.md)的信息。

<a id="testing-nfs"></a>

## 测试 NFS

当您设置好 NFS 服务器和客户端后，可以通过测试以下命令来验证 NFS 是否配置正确：

```shell
sudo mkdir /gitlab-nfs/test-dir
sudo chown git /gitlab-nfs/test-dir
sudo chgrp root /gitlab-nfs/test-dir
sudo chmod 0700 /gitlab-nfs/test-dir
sudo chgrp gitlab-www /gitlab-nfs/test-dir
sudo chmod 0751 /gitlab-nfs/test-dir
sudo chgrp git /gitlab-nfs/test-dir
sudo chmod 2770 /gitlab-nfs/test-dir
sudo chmod 2755 /gitlab-nfs/test-dir
sudo -u git mkdir /gitlab-nfs/test-dir/test2
sudo -u git chmod 2755 /gitlab-nfs/test-dir/test2
sudo ls -lah /gitlab-nfs/test-dir/test2
sudo -u git rm -r /gitlab-nfs/test-dir
```

任何 `Operation not permitted` 错误都意味着您应该检查 NFS 服务器的导出选项。

<a id="nfs-in-a-firewalled-environment"></a>

## 防火墙环境中的 NFS

如果您的 NFS 服务器和 NFS 客户端之间的流量受到防火墙的端口过滤，那么您需要重新配置该防火墙以允许 NFS 通信。

[Linux 文档项目 (TDLP) 的这份指南](https://tldp.org/HOWTO/NFS-HOWTO/security.html#FIREWALLS)
涵盖了在防火墙环境中使用 NFS 的基础知识。此外，我们鼓励您搜索并查阅您的操作系统或发行版以及防火墙软件的特定文档。

Ubuntu 示例：

通过运行命令检查主机上的防火墙是否允许来自客户端的 NFS 流量：`sudo ufw status`。如果被阻止，您可以使用以下命令允许来自特定客户端的流量。

```shell
sudo ufw allow from <client_ip_address> to any port nfs
```

<a id="known-issues"></a>

## 已知问题

<a id="avoid-using-cloud-based-file-systems"></a>

### 避免使用基于云的文件系统

极狐GitLab 强烈建议不要使用基于云的文件系统，例如：

- AWS Elastic File System (EFS)。
- Google Cloud Filestore。
- Azure Files。

我们的支持团队无法协助解决与基于云的文件系统访问相关的性能问题。

客户和用户报告说，这些文件系统对于极狐GitLab 所需的文件系统访问性能不佳。以串行方式写入许多小文件的工作负载（如 `git`）不太适合基于云的文件系统。

如果您确实选择使用这些，请避免将极狐GitLab 日志文件（例如 `/var/log/gitlab` 中的文件）存储在其中，因为这也会影响性能。我们建议将日志文件存储在本地卷上。


<a id="avoid-using-cephfs-and-glusterfs"></a>

### 避免使用 CephFS 和 GlusterFS

极狐GitLab 强烈建议不要使用 CephFS 和 GlusterFS。
这些分布式文件系统不太适合极狐GitLab 的输入/输出访问模式，因为 Git 使用许多小文件，并且访问时间和文件锁定时间的传播使得 Git 活动变得非常缓慢。

<a id="avoid-using-postgresql-with-nfs"></a>

### 避免将 PostgreSQL 与 NFS 一起使用

极狐GitLab 强烈建议不要跨 NFS 运行您的 PostgreSQL 数据库。极狐GitLab 支持团队无法协助解决与此配置相关的性能问题。

此外，[PostgreSQL 文档](https://www.postgresql.org/docs/16/creating-cluster.html#CREATING-CLUSTER-NFS)中特别警告了此配置：

>PostgreSQL 对 NFS 文件系统没有特殊处理，这意味着它假定 NFS 的行为与本地连接的驱动器完全一样。如果客户端或服务器的 NFS 实现不提供标准的文件系统语义，这可能会导致可靠性问题。具体来说，对 NFS 服务器的延迟（异步）写入可能导致数据损坏问题。

有关受支持的数据库架构，请参阅我们关于
[为复制和故障转移配置数据库](postgresql/replication_and_failover.md)的文档。

<a id="troubleshooting"></a>

## 故障排除

<a id="finding-the-requests-that-are-being-made-to-nfs"></a>

### 查找正在对 NFS 发出的请求

如果遇到与 NFS 相关的问题，使用 `perf` 跟踪正在发出的文件系统请求可能会有所帮助：

```shell
sudo perf trace -e 'nfs4:*' -p $(pgrep -fd ',' puma)
```
