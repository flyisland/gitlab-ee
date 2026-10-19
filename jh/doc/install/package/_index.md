---
stage: GitLab Delivery
group: Build
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Install, configure, and upgrade GitLab by using the Linux package.
title: 使用 Linux 软件包安装极狐GitLab
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Linux 软件包成熟、可扩展，并且被 JihuLab.com 使用。如果你需要更高的灵活性和弹性，我们建议按照[参考架构文档](../../administration/reference_architectures/_index.md)中所述部署极狐GitLab。

Linux 软件包安装更快捷，升级更容易，并且包含增强可靠性的功能，这些功能在其他安装方法中不具备。通过一个集成了运行极狐GitLab 所需的所有不同服务和工具的单一软件包（也称为 Omnibus GitLab）进行安装。请参阅[安装要求](../requirements.md)了解最低硬件要求。

Linux 软件包在我们的[极狐GitLab 软件包仓库](https://packages.gitlab.cn/#browse/browse)中提供。

请确保所需极狐GitLab 版本可供你的宿主操作系统使用。

<a id="supported-platforms"></a>

## 支持的操作系统

极狐GitLab 为下列操作系统提供 Linux 软件包。我们为这些平台构建和分发软件包。下表显示了每个操作系统上可用的极狐GitLab 版本。

我们根据供应商的支持生命周期为操作系统提供 Linux 软件包。当存在长期支持 (LTS) 版本时，我们会面向这些版本，不过并非所有操作系统都遵循 LTS 模式。

软件包构建通常会持续到操作系统达到供应商生命周期终止 (EOL) 为止。我们遵循标准或维护支持时间表，不包括扩展或高级支持期。

我们可能会在供应商 EOL 之前停止软件包构建，原因包括：

- 业务考量：包括但不限于客户采用率低、维护成本不成比例或产品战略方向变更。
- 技术限制：当第三方依赖、安全要求或底层技术变化使得继续构建软件包不切实际或不可能时。
- 供应商行为：当操作系统供应商做出根本性影响我们软件功能的更改，或当所需组件变得不可用时。

我们力求在停止支持任何操作系统版本前至少提前 6 个月发出通知。当技术限制或供应商约束需要更短通知期时，我们将尽快传达变更。

> [!note]
> `amd64` 和 `x86_64` 指代相同的 64 位架构。`arm64` 和 `aarch64` 名称也可以互换，指代相同的架构。

| 操作系统                                                                           | 首个支持的极狐GitLab 版本      | 架构                  | 操作系统生命周期终止 | 建议最后支持的极狐GitLab 版本 | 上游发行说明                                                                                                    |
|------------------------------------------------------------------------------------|--------------------------------|-----------------------|------------------------|--------------------------------|----------------------------------------------------------------------------------------------------------------|
| [AlmaLinux 8](almalinux.md)                         | 极狐GitLab 14.5.0   | `x86_64`, `aarch64` <sup>1</sup> | 2029 年 3 月            | 极狐GitLab 21.10.0 | [AlmaLinux 详情](https://almalinux.org/)                                                                   |
| [AlmaLinux 9](almalinux.md)                         | 极狐GitLab 16.0.0   | `x86_64`, `aarch64` <sup>1</sup> | 2032 年 5 月            | 极狐GitLab 25.0.0  | [AlmaLinux 详情](https://almalinux.org/)                                                                   |
| [AlmaLinux 10](almalinux.md)                        | 极狐GitLab 18.6.0   | `x86_64`, `aarch64` <sup>1</sup> | 2035 年 5 月            | 极狐GitLab 28.0.0  | [AlmaLinux 详情](https://almalinux.org/)                                                                   |
| [Amazon Linux 2](amazonlinux_2.md)                  | 极狐GitLab 14.9.0   | `amd64`, `arm64` <sup>1</sup>    | 2026 年 6 月            | 极狐GitLab 19.1.0  | [Amazon Linux 详情](https://aws.amazon.com/amazon-linux-2/faqs/)                                           |
| [Amazon Linux 2023](amazonlinux_2023.md)            | 极狐GitLab 16.3.0   | `amd64`, `arm64` <sup>1</sup>    | 2029 年 6 月            | 极狐GitLab 22.1.0  | [Amazon Linux 详情](https://docs.aws.amazon.com/linux/al2023/ug/release-cadence.html)                      |
| [Debian 11](debian.md)                              | 极狐GitLab 14.6.0   | `amd64`, `arm64` <sup>1</sup>    | 2026 年 8 月            | 极狐GitLab 19.3.0  | [Debian Linux 详情](https://wiki.debian.org/LTS)                                                           |
| [Debian 12](debian.md)                              | 极狐GitLab 16.1.0   | `amd64`, `arm64` <sup>1</sup>    | 2028 年 6 月            | 极狐GitLab 19.3.0  | [Debian Linux 详情](https://wiki.debian.org/LTS)                                                           |
| [Debian 13](debian.md)                              | 极狐GitLab 18.5.0   | `amd64`, `arm64` <sup>1</sup>    | 2030 年 6 月            | 极狐GitLab 23.1.0  | [Debian Linux 详情](https://wiki.debian.org/LTS)                                                           |
| [openSUSE Leap 15.6](suse.md)              | 极狐GitLab 17.6.0   | `x86_64`, `aarch64` <sup>1</sup> | 2025 年 12 月           | 待定                           | [openSUSE 详情](https://en.opensuse.org/Lifetime)                                                          |
| [SUSE Linux Enterprise Server 12](suse.md) | 极狐GitLab 9.0.0          | `x86_64`              | 2027 年 10 月           | 待定                               | [SUSE Linux Enterprise Server 详情](https://www.suse.com/lifecycle/)                                       |
| [SUSE Linux Enterprise Server 15](suse.md) | 极狐GitLab 14.8.0         | `x86_64`              | 2024 年 12 月           | 待定                               | [SUSE Linux Enterprise Server 详情](https://www.suse.com/lifecycle/)                                       |
| [Oracle Linux 8](almalinux.md)                      | 极狐GitLab 12.8.1   | `x86_64`              | 2029 年 7 月            | 极狐GitLab 22.2.0  | [Oracle Linux 详情](https://www.oracle.com/a/ocom/docs/elsp-lifetime-069338.pdf)                           |
| [Oracle Linux 9](almalinux.md)                      | 极狐GitLab 16.2.0   | `x86_64`              | 2032 年 6 月            | 极狐GitLab 25.1.0  | [Oracle Linux 详情](https://www.oracle.com/a/ocom/docs/elsp-lifetime-069338.pdf)                           |
| [Oracle Linux 10](almalinux.md)                     | 极狐GitLab 18.6.0   | `x86_64`              | 2035 年 6 月            | 极狐GitLab 28.1.0  | [Oracle Linux 详情](https://www.oracle.com/a/ocom/docs/elsp-lifetime-069338.pdf)                           |
| [Red Hat Enterprise Linux 8](almalinux.md)          | 极狐GitLab 12.8.1   | `x86_64`, `arm64` <sup>1</sup>   | 2029 年 5 月            | 极狐GitLab 22.0.0  | [Red Hat Enterprise Linux 详情](https://access.redhat.com/support/policy/updates/errata/#Life_Cycle_Dates) |
| [Red Hat Enterprise Linux 9](almalinux.md)          | 极狐GitLab 16.0.0   | `x86_64`, `arm64` <sup>1</sup>   | 2032 年 5 月            | 极狐GitLab 25.0.0  | [Red Hat Enterprise Linux 详情](https://access.redhat.com/support/policy/updates/errata/#Life_Cycle_Dates) |
| [Red Hat Enterprise Linux 10](almalinux.md)         | 极狐GitLab 18.6.0   | `x86_64`, `arm64` <sup>1</sup>   | 2035 年 5 月            | 极狐GitLab 28.0.0  | [Red Hat Enterprise Linux 详情](https://access.redhat.com/support/policy/updates/errata/#Life_Cycle_Dates) |
| [Ubuntu 20.04](ubuntu.md)                           | 极狐GitLab 13.2.0   | `amd64`, `arm64` <sup>1</sup>    | 2025 年 4 月            | 极狐GitLab 18.8.0  | [Ubuntu 详情](https://wiki.ubuntu.com/Releases)                                                            |
| [Ubuntu 22.04](ubuntu.md)                           | 极狐GitLab 15.5.0   | `amd64`, `arm64` <sup>1</sup>    | 2027 年 4 月            | 极狐GitLab 19.11.0 | [Ubuntu 详情](https://wiki.ubuntu.com/Releases)。FIPS 软件包在极狐GitLab 18.4 中加入。从 Ubuntu 20.04 升级前，请查看[升级说明](#ubuntu-2204-fips)。 |
| [Ubuntu 24.04](ubuntu.md)                           | 极狐GitLab 17.1.0   | `amd64`, `arm64` <sup>1</sup>    | 2029 年 4 月            | 极狐GitLab 21.11.0 | [Ubuntu 详情](https://wiki.ubuntu.com/Releases)                                                            |

**脚注**:

1. 在 ARM 上运行极狐GitLab 存在[已知问题](https://jihulab.com/groups/gitlab-cn/-/epics/4397)。

<a id="unofficial-unsupported-installation-methods"></a>

### 非官方、不受支持的安装方法

以下安装方法由更广泛的极狐GitLab 社区按原样提供，极狐GitLab 不予以支持：

- [Debian 原生软件包](https://wiki.debian.org/gitlab/) (由 Pirate Praveen 提供)
- [Arch Linux 软件包](https://archlinux.org/packages/extra/x86_64/gitlab/) (由 Arch Linux 社区提供)
- [Puppet 模块](https://forge.puppet.com/puppet/gitlab) (由 Vox Pupuli 提供)
- [Ansible story](https://github.com/geerlingguy/ansible-role-gitlab) (由 Jeff Geerling 提供)
- [极狐GitLab 虚拟设备 (KVM)](https://marketplace.opennebula.io/appliance/6b54a412-03a5-11e9-8652-f0def1753696) (由 OpenNebula 提供)
- [Cloudron 上的极狐GitLab](https://cloudron.io/store/com.gitlab.cloudronapp.html) (通过 Cloudron App Library)

<a id="end-of-life-versions"></a>

## 生命周期终止版本

你可以在下表中找到已弃用的操作系统及其最终的极狐GitLab 版本：

| 操作系统版本       | 生命周期终止                                                                         | 最后支持的极狐GitLab 版本 |
|:-----------------|:------------------------------------------------------------------------------------|:------------------------------|
| CentOS 6 和 RHEL 6 | [2020 年 11 月](https://www.centos.org/about/)                                   | 极狐GitLab 13.6 |
| CentOS 7 和 RHEL 7 | [2024 年 6 月](https://www.centos.org/about/)                                       | 极狐GitLab 17.7 |
| CentOS 8         | [2021 年 12 月](https://www.centos.org/about/)                                      | 极狐GitLab 14.6 |
| Oracle Linux 7   | [2024 年 12 月](https://endoflife.date/oracle-linux)                                | 极狐GitLab 17.7 |
| Scientific Linux 7 | [2024 年 6 月](https://scientificlinux.org/downloads/sl-versions/sl7/)               | 极狐GitLab 17.7 |
| Debian 7 Wheezy  | [2018 年 5 月](https://www.debian.org/News/2018/20180601)                            | 极狐GitLab 11.6 |
| Debian 8 Jessie  | [2020 年 6 月](https://www.debian.org/News/2020/20200709)                            | 极狐GitLab 13.3 |
| Debian 9 Stretch | [2022 年 6 月](https://lists.debian.org/debian-lts-announce/2022/07/msg00002.html)   | 极狐GitLab 15.2 |
| Debian 10 Buster | [2024 年 6 月](https://www.debian.org/News/2024/20240615)                            | 极狐GitLab 17.5 |
| OpenSUSE 42.1    | [2017 年 5 月](https://en.opensuse.org/Lifetime#Discontinued_distributions)          | 极狐GitLab 9.3 |
| OpenSUSE 42.2    | [2018 年 1 月](https://en.opensuse.org/Lifetime#Discontinued_distributions)          | 极狐GitLab 10.4 |
| OpenSUSE 42.3    | [2019 年 7 月](https://en.opensuse.org/Lifetime#Discontinued_distributions)          | 极狐GitLab 12.1 |
| OpenSUSE 13.2    | [2017 年 1 月](https://en.opensuse.org/Lifetime#Discontinued_distributions)          | 极狐GitLab 9.1 |
| OpenSUSE 15.0    | [2019 年 12 月](https://en.opensuse.org/Lifetime#Discontinued_distributions)         | 极狐GitLab 12.5 |
| OpenSUSE 15.1    | [2020 年 11 月](https://en.opensuse.org/Lifetime#Discontinued_distributions)         | 极狐GitLab 13.12 |
| OpenSUSE 15.2    | [2021 年 12 月](https://en.opensuse.org/Lifetime#Discontinued_distributions)         | 极狐GitLab 14.7 |
| OpenSUSE 15.3    | [2022 年 12 月](https://en.opensuse.org/Lifetime#Discontinued_distributions)         | 极狐GitLab 15.10 |
| OpenSUSE 15.4    | [2023 年 12 月](https://en.opensuse.org/Lifetime#Discontinued_distributions)         | 极狐GitLab 16.7 |
| OpenSUSE 15.5    | [2024 年 12 月](https://en.opensuse.org/Lifetime#Discontinued_distributions)         | 极狐GitLab 17.8 |
| SLES 15 SP2      | [2024 年 12 月](https://www.suse.com/lifecycle/#suse-linux-enterprise-server-15)     | 极狐GitLab 18.1 |
| Raspbian Wheezy  | [2015 年 5 月](https://downloads.raspberrypi.org/raspbian/images/raspbian-2015-05-07/) | 极狐GitLab 8.17 |
| Raspbian Jessie  | [2017 年 5 月](https://downloads.raspberrypi.org/raspbian/images/raspbian-2017-07-05/) | 极狐GitLab 11.7 |
| Raspbian Stretch | [2020 年 6 月](https://downloads.raspberrypi.org/raspbian/images/raspbian-2019-04-09/) | 极狐GitLab 13.3 |
| Raspberry Pi OS Buster | [2024 年 6 月](https://www.debian.org/News/2024/20240615)                       | 极狐GitLab 17.7 |
| Ubuntu 12.04     | [2017 年 4 月](https://ubuntu.com/info/release-end-of-life)                          | 极狐GitLab 9.1 |
| Ubuntu 14.04     | [2019 年 4 月](https://ubuntu.com/info/release-end-of-life)                          | 极狐GitLab 11.10 |
| Ubuntu 16.04     | [2021 年 4 月](https://ubuntu.com/info/release-end-of-life)                          | 极狐GitLab 13.12 |
| Ubuntu 18.04     | [2023 年 6 月](https://ubuntu.com/info/release-end-of-life)                          | 极狐GitLab 16.11 |

<a id="raspberry-pi-os-32-bit-raspbian"></a>

### Raspberry Pi OS（32 位 - Raspbian）

极狐GitLab 从 17.11 版本起停止了对 Raspberry Pi OS（32 位 - Raspbian）的支持，17.11 是 32 位平台上的最后可用版本。从极狐GitLab 18.0 开始，你应该迁移到 Raspberry Pi OS（64 位）并使用 [Debian arm64 软件包](debian.md)。

有关在 32 位操作系统上备份数据并将其恢复到 64 位操作系统的信息，请参阅[升级 PostgreSQL 的操作系统](../../administration/postgresql/upgrading_os.md)。

<a id="uninstall-the-linux-package"></a>

## 卸载 Linux 软件包

要卸载 Linux 软件包，你可以选择保留数据（代码库、数据库、配置）或全部删除：

1. 可选。在删除软件包之前，移除[由 Linux 软件包创建的所有用户和组](https://gitlab.cn/docs/omnibus/settings/configuration/#disable-user-and-group-account-management)：

   ```shell
   sudo gitlab-ctl stop && sudo gitlab-ctl remove-accounts
   ```

   > [!note]
   > 如果在删除帐户或组时遇到问题，请手动运行 `userdel` 或 `groupdel` 来删除它们。你可能还想从 `/home/` 手动删除遗留的用户主目录。

1. 选择保留数据还是全部删除：

   - 要保留数据（代码库、数据库、配置），停止极狐GitLab 并移除其监督进程：

     ```shell
     sudo systemctl stop gitlab-runsvdir
     sudo systemctl disable gitlab-runsvdir
     sudo rm /usr/lib/systemd/system/gitlab-runsvdir.service
     sudo systemctl daemon-reload
     sudo systemctl reset-failed
     sudo gitlab-ctl uninstall
     ```

   - 要删除所有数据：

     ```shell
     sudo gitlab-ctl cleanse && sudo rm -r /opt/gitlab
     ```

1. 卸载 `gitlab-jh` 软件包：

   {{< tabs >}}

   {{< tab title="apt" >}}

   ```shell
   # Debian/Ubuntu
   sudo apt remove gitlab-jh
   ```

   {{< /tab >}}

   {{< tab title="dnf" >}}

   ```shell
   # AlmaLinux/RHEL/Oracle Linux/Amazon Linux 2023
   sudo dnf remove gitlab-jh
   ```

   {{< /tab >}}

   {{< tab title="zypper" >}}

   ```shell
   # OpenSUSE Leap/SLES
   sudo zypper remove gitlab-jh
   ```

   {{< /tab >}}

   {{< tab title="yum" >}}

   ```shell
   # Amazon Linux 2
   sudo yum remove gitlab-jh
   ```

   {{< /tab >}}

   {{< /tabs >}}

<a id="ubuntu-2204-fips"></a>

### Ubuntu 22.04 FIPS

从极狐GitLab 18.4 及更高版本开始，针对 Ubuntu 22.04 提供了 FIPS 构建。

在升级之前：

1. 验证所有活跃用户的密码哈希迁移：在极狐GitLab 17.11 及更高版本中，用户登录时会自动使用增强盐值重新哈希密码。

   任何尚未完成此哈希迁移的用户将无法登录到 Ubuntu 22 FIPS 安装，需要执行密码重置。

   要查找尚未迁移的用户，请在升级到 Ubuntu 22.04 之前使用[此 Rake 任务](../../administration/raketasks/password.md#check-password-hashes)。

1. 检查极狐GitLab 的 secrets JSON：Rails 现在需要更强的活动 dispatch 盐值来签发 cookie。Linux 软件包在 Ubuntu 22.04 上默认使用长度足够的静态值。但是，你可以在 Linux 软件包配置中通过设置以下键来自定义这些盐值：

   ```ruby
   gitlab_rails['signed_cookie_salt'] = 'custom value'
   gitlab_rails['authenticated_encrypted_cookie_salt'] = 'another custom value'
   ```

   这些值会写入 `gitlab-secrets.json`，并且必须在所有 Rails 节点之间同步。

1. 准备在升级到 FIPS 140-3 时进行 OAuth 令牌迁移：极狐GitLab 18.6.0、18.5.2 和 18.4.4 为 OAuth 令牌引入了 SHA512 哈希，以符合 FIPS 140-3 要求。此前，极狐GitLab 使用无盐的 PBKDF2，这与 Ubuntu 22.04 这类符合 FIPS 140-3 的系统不兼容。

   > [!note]
   > 仅当迁移到符合 FIPS 140-3 的操作系统（如 Ubuntu 22.04）时才需要此迁移。如果你已在较旧的 FIPS 版本上运行（如 Ubuntu 20.04）或继续使用非 FIPS 系统，则无需进行任何更改。

   从非 FIPS 实例或较旧 FIPS 版本迁移到 FIPS 140-3 实例时：

   1. 升级到极狐GitLab 18.4 或更高版本。
   1. 留出足够时间，让活跃的 OAuth 访问令牌在正常使用过程中自动重新哈希。
   1. 轮换 OAuth 应用程序密钥，确保所有新颁发的令牌都使用符合 FIPS 的哈希算法。
   1. 通知用户，如果他们最近未使用其令牌，可能需要在 OAuth 集成应用程序中重新进行身份验证。
