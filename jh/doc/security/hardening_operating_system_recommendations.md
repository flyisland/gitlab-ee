---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 加固 - 操作系统建议
---

一般性加固指南在[主加固文档](hardening.md)中进行了概述。

您可以配置基础操作系统以提高整体安全性。在诸如极狐GitLab 私有化部署这样的受控环境中，需要进行额外的步骤，实际上对于某些部署来说通常是必须的。FedRAMP 就是这样的部署示例。

<a id="ssh-configuration"></a>

## SSH 配置

<a id="ssh-client-configuration"></a>

### SSH 客户端配置

对于客户端访问（无论是访问极狐GitLab 实例还是基础操作系统），这里有一些 SSH 密钥生成建议。第一个是典型的 SSH 密钥：

```shell
ssh-keygen -a 64 -t ed25519 -f ~/.ssh/id_ed25519 -C "ED25519 Key"
```

对于符合 FIPS 的 SSH 密钥，请使用以下命令：

```shell
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -C "RSA FIPS-compliant Key"
```

<a id="ssh-server-configuration"></a>

### SSH 服务器配置

在操作系统级别，如果您允许 SSH 访问（通常通过 OpenSSH），以下是 `sshd_config` 文件的配置选项示例（确切位置可能因操作系统而异，但通常是 `/etc/ssh/sshd_config`）：

```shell
#
# sshd 配置文件示例。支持公钥认证，并关闭了几个潜在的安全风险区域
#
PubkeyAuthentication yes
PasswordAuthentication yes
UsePAM yes
UseDNS no
AllowTcpForwarding no
X11Forwarding no
PrintMotd no
PermitTunnel no
PermitRootLogin no

# 允许客户端传递语言环境变量
AcceptEnv LANG LC_*

# 默认 120 秒更改为 60 秒
LoginGraceTime 60

# 覆盖默认的无子系统设置
Subsystem       sftp    /usr/lib/openssh/sftp-server

# 协议调整，这些在 FIPS 或 FedRAMP 部署中是必需/推荐的，并且仅使用经过验证的强大算法选择
Protocol 2
Ciphers aes128-ctr,aes192-ctr,aes256-ctr
HostKeyAlgorithms ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521
KexAlgorithms ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521
Macs hmac-sha2-256,hmac-sha2-512
```

<a id="firewall-rules"></a>

## 防火墙规则

对于防火墙规则，基本使用只需要开放 TCP 端口 `80` 和 `443`。默认情况下，`5050` 端口对容器镜像仓库的远程访问开放，但在加固环境中，这很可能存在于不同的主机上，在某些环境中甚至根本不开放。因此，建议仅开放端口 `80` 和 `443`，并且端口 `80` 只能用于重定向到 `443`。

对于像 FedRAMP 这样真正加固或隔离的环境，您应调整防火墙规则，限制所有端口，仅允许访问它的网络。例如，如果 IP 地址是 `192.168.1.2`，并且所有授权客户端也都在 `192.168.1.0/24` 上，则仅将端口 `80` 和 `443` 的访问限制为 `192.168.1.0/24`（作为安全限制），即使在其他地方使用另一个防火墙限制了访问也是如此。

理想情况下，如果您正在安装极狐GitLab 私有化部署实例，您应该在安装开始前实施防火墙规则，仅允许管理员和安装人员访问，并在实例安装并正确加固后再添加用户的 IP 地址范围。

使用 `iptables` 或 `ufw` 在每台主机上实施并强制端口 `80` 和 `443` 的访问是可以接受的，或者通过 GCP Google Compute 或 AWS 安全组使用基于云的防火墙规则来实施此操作。所有其他端口应被阻止，或至少限制到特定范围。有关端口的更多信息，请参阅[软件包默认值](../administration/package_information/defaults.md)。

<a id="allow-outbound-connections-from-the-gitlab-instance"></a>

## 允许从极狐GitLab 实例的出站连接

检查您的出站和入站设置：

- 您的防火墙和 HTTP/S 代理服务器必须允许通过 `https://` 协议访问端口 `443` 上的 `cloud.jihulab.com` 和 `customers.jihulab.com`。这些主机受 Cloudflare 保护。更新您的防火墙设置，以允许访问 Cloudflare 发布的 [IP 范围列表](https://www.cloudflare.com/ips/) 中的所有 IP 地址。
- 要使用 HTTP/S 代理，必须为 `gitLab_workhorse` 和 `gitLab_rails` 设置必要的 [Web 代理环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables.html)。
- 在多节点极狐GitLab 安装中，需要在所有 **Rails** 和 **Sidekiq** 节点上配置 HTTP/S 代理。
- 要在极狐GitLab 私有化部署上配置极狐GitLab Duo，请 [允许从极狐GitLab 实例到极狐GitLab Duo 的出站连接](../administration/gitlab_duo/configure/_index.md#allow-outbound-connections-from-the-gitlab-instance-to-gitlab-duo)。

<a id="firewall-additions"></a>

### 防火墙附加规则

可能启用了各种需要外部访问的服务（例如 Sidekiq），并需要开放网络访问。将这些类型的服务限制到特定的 IP 地址或特定的 C 类网络。作为一种分层附加预防措施，尽可能将这些额外服务限制到极狐GitLab 中的特定节点或子网络。

<a id="kernel-adjustments"></a>

## 内核调整

可以通过编辑 `/etc/sysctl.conf` 或 `/etc/sysctl.d/` 中的文件来进行内核调整。内核调整不会完全消除攻击威胁，但增加了额外的安全层。以下说明解释了这些调整的一些优势。

```shell
## 内核 sysctl.conf 优化 ##
##
## 以下有助于减轻越界、空指针解引用、堆和
## 缓冲区溢出错误、use-after-free 等被利用的风险。它不能 100%
## 解决问题，但严重阻碍了漏洞利用。
##
# 默认值为 65536。更高的值可提供更强的保护，防止空指针解引用漏洞利用。
# 仅在应用程序兼容性需要时使用 4096，因为它会减小受保护的低内存地址范围。
vm.mmap_min_addr=4096
# 默认值为 0，在内存中随机化虚拟地址空间，使漏洞利用更困难
kernel.randomize_va_space=2
# 限制内核指针访问（例如，cat /proc/kallsyms）以防止漏洞利用辅助
kernel.kptr_restrict=2
# 限制 dmesg 中的详细内核错误
kernel.dmesg_restrict=1
# 限制 eBPF
kernel.unprivileged_bpf_disabled=1
net.core.bpf_jit_harden=2
# 防止常见的 use-after-free 漏洞利用
vm.unprivileged_userfaultfd=0
# 通过阻止非特权用户创建命名空间来缓解 CVE-2024-1086
kernel.unprivileged_userns_clone=0

## 网络优化 ##
##
## 防止 IP 堆栈层的常见攻击
##
# 防止 SYNFLOOD 拒绝服务攻击
net.ipv4.tcp_syncookies=1
# 防止时间等待暗杀攻击
net.ipv4.tcp_rfc1337=1
# IP 欺骗/源路由保护
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1
net.ipv6.conf.all.accept_ra=0
net.ipv6.conf.default.accept_ra=0
net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.default.accept_source_route=0
net.ipv6.conf.all.accept_source_route=0
net.ipv6.conf.default.accept_source_route=0
# IP 重定向保护
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.default.secure_redirects=0
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.default.accept_redirects=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.send_redirects=0
```

