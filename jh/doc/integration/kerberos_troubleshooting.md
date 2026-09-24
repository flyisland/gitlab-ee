---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Kerberos 集成故障排查
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在使用极狐GitLab 与 Kerberos 集成时，你可能会遇到以下问题。

<a id="using-google-chrome-with-kerberos-authentication-against-windows-ad"></a>

## 使用 Google Chrome 进行 Kerberos 认证以访问 Windows AD

当你使用 Google Chrome 登录极狐GitLab 并启用 Kerberos 时，你必须输入完整的用户名。例如，`username@domain.com`。

如果你未输入完整的用户名，登录将失败。检查日志，查看以下事件消息作为登录失败的证据：

```plain
"message":"OmniauthKerberosController: 处理 Negotiate/Kerberos 认证失败: gss_accept_sec_context 未返回 GSS_S_COMPLETE: 请求了不受支持的机制\n未知错误"
```

<a id="test-connectivity-between-the-gitlab-and-kerberos-servers"></a>

## 测试极狐GitLab 与 Kerberos 服务器之间的连通性

你可以使用诸如 [`kinit`](https://web.mit.edu/kerberos/krb5-1.12/doc/user/user_commands/kinit.html) 和 [`klist`](https://web.mit.edu/kerberos/krb5-1.12/doc/user/user_commands/klist.html) 的工具来测试极狐GitLab 服务器与 Kerberos 服务器之间的连通性。这些工具的安装方式取决于你的操作系统。

使用 `klist` 查看 `keytab` 文件中可用的服务主体名称 (SPN) 以及每个 SPN 的加密类型：

```shell
klist -ke /etc/http.keytab
```

在 Ubuntu 服务器上，输出类似于以下内容：

```shell
Keytab name: FILE:/etc/http.keytab
KVNO Principal
---- --------------------------------------------------------------------------
   3 HTTP/my.gitlab.domain@MY.REALM (des-cbc-crc)
   3 HTTP/my.gitlab.domain@MY.REALM (des-cbc-md5)
   3 HTTP/my.gitlab.domain@MY.REALM (arcfour-hmac)
   3 HTTP/my.gitlab.domain@MY.REALM (aes256-cts-hmac-sha1-96)
   3 HTTP/my.gitlab.domain@MY.REALM (aes128-cts-hmac-sha1-96)
```

使用 `kinit` 的详细模式测试极狐GitLab 能否使用 keytab 文件连接到 Kerberos 服务器：

```shell
KRB5_TRACE=/dev/stdout kinit -kt /etc/http.keytab HTTP/my.gitlab.domain@MY.REALM
```

此命令将输出认证过程的详细信息。

<a id="unsupported-gssapi-mechanism"></a>

## 不支持的 GSSAPI 机制

使用 Kerberos SPNEGO 认证时，浏览器需要将其支持的机制列表发送给极狐GitLab。如果浏览器不支持极狐GitLab 支持的任何机制，认证将失败，并在日志中显示如下类似消息：

```plaintext
OmniauthKerberosController: 处理 Negotiate/Kerberos 认证失败: gss_accept_sec_context 未返回 GSS_S_COMPLETE: 请求了不受支持的机制 Unknown error
```

此错误消息有多种可能的原因和解决方案。

<a id="kerberos-integration-not-using-a-dedicated-port"></a>

### Kerberos 集成未使用专用端口

除非 Kerberos 集成被配置为[使用专用端口](kerberos.md#http-git-access-with-kerberos-token-passwordless-authentication)，否则极狐GitLab CI/CD 无法与启用了 Kerberos 的极狐GitLab 实例配合使用。

<a id="lack-of-connectivity-between-client-machine-and-kerberos-server"></a>

### 客户端计算机与 Kerberos 服务器之间缺乏连通性

这通常发生在浏览器无法直接联系 Kerberos 服务器时。它会回退到一种称为 [`IAKERB`](https://k5wiki.kerberos.org/wiki/Projects/IAKERB) 的不受支持的机制，该机制试图使用极狐GitLab 服务器作为与 Kerberos 服务器之间的中介。

如果你遇到此错误，请确保客户端计算机与 Kerberos 服务器之间存在连通性——这是前提条件！流量可能被防火墙阻止，或者 DNS 记录可能不正确。

<a id="gitlab-dns-record-is-a-cname-record-error"></a>

### `GitLab DNS 记录是 CNAME 记录` 错误

当极狐GitLab 引用 `CNAME` 记录时，Kerberos 会因此错误而失败。要解决此问题，请确保极狐GitLab 的 DNS 记录为 `A` 记录。

<a id="mismatched-forward-and-reverse-dns-records-for-gitlab-instance-hostname"></a>

### 极狐GitLab 实例主机名的正向与反向 DNS 记录不匹配

另一种失败情况是极狐GitLab 服务器的正向和反向 DNS 记录不匹配。通常，在这种情况下 Windows 客户端能够正常工作，而 Linux 客户端则失败。它们在检测 Kerberos 领域时使用反向 DNS。如果获取到了错误的领域，则常规的 Kerberos 机制将失败，因此客户端会回退尝试协商 `IAKERB`，从而导致之前的认证错误消息。

要解决此问题，请确保极狐GitLab 服务器的正向和反向 DNS 匹配。例如，如果你通过 `gitlab.example.com` 访问极狐GitLab，该域名解析为 IP 地址 `10.0.2.2`，那么 `2.2.0.10.in-addr.arpa` 必须是一条指向 `gitlab.example.com` 的 `PTR` 记录。

<a id="missing-kerberos-libraries-on-browser-or-client-machine"></a>

### 浏览器或客户端计算机缺少 Kerberos 库

最后，浏览器或客户端计算机可能完全缺乏 Kerberos 支持。请确保已安装 Kerberos 库，并且你能够认证其他 Kerberos 服务。

<a id="http-basic-access-denied-when-cloning"></a>

## HTTP Basic：克隆时访问被拒绝

```shell
remote: HTTP Basic: Access denied
fatal: Authentication failed for '<KRB5 path>'
```

如果你使用的是 Git v2.11 或更高版本，并且在克隆时看到以上错误，可以将 `http.emptyAuth` Git 选项设置为 `true` 来解决：

```shell
git config --global http.emptyAuth true
```

<a id="git-cloning-with-kerberos-over-proxied-https"></a>

## 通过代理 HTTPS 使用 Kerberos 进行 Git 克隆

如果出现以下情况，你必须注释掉以下行：

- 当预期出现 `https://` 地址时，你在 **使用 KRB5 进行 Git 克隆** 选项中看到了 `http://` 地址。
- HTTPS 未在你的极狐GitLab 实例上终止，而是由负载均衡器或本地流量管理器代理。

```shell
# gitlab_rails['kerberos_https'] = false
```

另请参阅：[Git v2.11 发布说明](https://github.com/git/git/blob/master/Documentation/RelNotes/2.11.0.adoc?plain=1#L482-L486)

<a id="helpful-links"></a>

## 有用的链接

- <https://help.ubuntu.com/community/Kerberos>
- <https://blog.manula.org/2012/04/setting-up-kerberos-server-with-debian.html>
- <https://www.roguelynn.com/words/explain-like-im-5-kerberos/>