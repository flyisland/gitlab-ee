---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Kerberos 集成故障排除
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用集成了 Kerberos 的极狐GitLab 时，您可能会遇到以下问题。

<a id="using-google-chrome-with-kerberos-authentication-against-windows-ad"></a>

## 在 Windows AD 上使用 Google Chrome 进行 Kerberos 身份验证

使用 Google Chrome 通过 Kerberos 登录极狐GitLab 时，您必须输入完整的用户名。例如，`username@domain.com`。

如果您没有输入完整的用户名，登录将失败。请检查日志，查看以下事件消息，作为此登录失败的证据：

```plain
"message":"OmniauthKerberosController: failed to process Negotiate/Kerberos authentication: gss_accept_sec_context did not return GSS_S_COMPLETE: An unsupported mechanism was requested\nUnknown error".
```

<a id="test-connectivity-between-the-gitlab-and-kerberos-servers"></a>

## 测试极狐GitLab 与 Kerberos 服务器之间的连接

您可以使用 [`kinit`](https://web.mit.edu/kerberos/krb5-1.12/doc/user/user_commands/kinit.html) 和 [`klist`](https://web.mit.edu/kerberos/krb5-1.12/doc/user/user_commands/klist.html) 等工具来测试极狐GitLab 服务器与 Kerberos 服务器之间的连接。如何安装这些工具取决于您使用的具体操作系统。

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

使用详细模式下的 `kinit` 测试极狐GitLab 能否使用 keytab 文件连接到 Kerberos 服务器：

```shell
KRB5_TRACE=/dev/stdout kinit -kt /etc/http.keytab HTTP/my.gitlab.domain@MY.REALM
```

此命令会显示身份验证过程的详细输出。

<a id="unsupported-gssapi-mechanism"></a>

## 不支持的 GSSAPI 机制

使用 Kerberos SPNEGO 身份验证时，浏览器应向极狐GitLab 发送其支持的机制列表。如果浏览器不支持极狐GitLab 支持的任何机制，身份验证将失败，并在日志中显示类似以下内容的消息：

```plaintext
OmniauthKerberosController: failed to process Negotiate/Kerberos authentication: gss_accept_sec_context did not return GSS_S_COMPLETE: An unsupported mechanism was requested Unknown error
```

此错误消息有多种可能的原因和解决方案。

<a id="kerberos-integration-not-using-a-dedicated-port"></a>

### Kerberos 集成未使用专用端口

除非将 Kerberos 集成配置为[使用专用端口](kerberos.md#http-git-access-with-kerberos-token-passwordless-authentication)，否则极狐GitLab CI/CD 无法与启用了 Kerberos 的极狐GitLab 实例配合使用。

<a id="lack-of-connectivity-between-client-machine-and-kerberos-server"></a>

### 客户端计算机与 Kerberos 服务器之间缺乏连接

这通常发生在浏览器无法直接联系 Kerberos 服务器时。它会回退到一种称为 [`IAKERB`](https://k5wiki.kerberos.org/wiki/Projects/IAKERB)的不受支持的机制，该机制尝试将极狐GitLab 服务器用作与 Kerberos 服务器通信的中介。

如果您遇到此错误，请确保客户端计算机与 Kerberos 服务器之间存在连接——这是先决条件！流量可能被防火墙阻止，或者 DNS 记录可能不正确。

<a id="gitlab-dns-record-is-a-cname-record-error"></a>

### `GitLab DNS record is a CNAME record` 错误

当使用 `CNAME` 记录引用极狐GitLab 时，Kerberos 会因此错误而失败。要解决此问题，请确保极狐GitLab 的 DNS 记录为 `A` 记录。

<a id="mismatched-forward-and-reverse-dns-records-for-gitlab-instance-hostname"></a>

### 极狐GitLab 实例主机名的正向和反向 DNS 记录不匹配

另一种失败情况是极狐GitLab 服务器的正向和反向 DNS 记录不匹配。通常，在这种情况下 Windows 客户端可以正常工作，而 Linux 客户端会失败。它们在检测 Kerberos 领域时使用反向 DNS。如果它们获取到错误的领域，普通的 Kerberos 机制就会失败，因此客户端会回退到尝试协商 `IAKERB`，从而导致之前的身份验证错误消息。

要解决此问题，请确保极狐GitLab 服务器的正向和反向 DNS 匹配。例如，如果您通过 `gitlab.example.com` 访问极狐GitLab，其解析到 IP 地址 `10.0.2.2`，那么 `2.2.0.10.in-addr.arpa` 必须是 `gitlab.example.com`的 `PTR` 记录。

<a id="missing-kerberos-libraries-on-browser-or-client-machine"></a>

### 浏览器或客户端计算机上缺少 Kerberos 库

最后，浏览器或客户端计算机可能完全不支持 Kerberos。请确保已安装 Kerberos 库，并且您能够向其他 Kerberos 服务进行身份验证。

<a id="http-basic-access-denied-when-cloning"></a>

## 克隆时出现 HTTP Basic: Access denied

```shell
remote: HTTP Basic: Access denied
fatal: Authentication failed for '<KRB5 path>'
```

如果您使用 Git v2.11 或更高版本，并且在克隆时看到上述错误，可以将 Git 选项 `http.emptyAuth` 设置为 `true` 来解决此问题：

```shell
git config --global http.emptyAuth true
```

<a id="git-cloning-with-kerberos-over-proxied-https"></a>

## 通过代理 HTTPS 使用 Kerberos 进行 Git 克隆

在以下情况下，您必须注释掉以下内容：

- 在 **使用 KRB5 进行 Git 克隆** 选项中看到 `http://` URL，而预期应为 `https://` URL。
- HTTPS 未在极狐GitLab 实例上终止，而是由您的负载均衡器或本地流量管理器代理。

```shell
# gitlab_rails['kerberos_https'] = false
```

另请参阅：[Git v2.11 发行说明](https://github.com/git/git/blob/master/Documentation/RelNotes/2.11.0.adoc?plain=1#L482-L486)

<a id="helpful-links"></a>

## 实用链接

- <https://help.ubuntu.com/community/Kerberos>
- <https://blog.manula.org/2012/04/setting-up-kerberos-server-with-debian.html>
- <https://www.roguelynn.com/words/explain-like-im-5-kerberos/>
