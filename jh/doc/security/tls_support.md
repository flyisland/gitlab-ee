---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: TLS 支持
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 优先考虑用户与平台之间的数据传输安全，通过使用传输层安全协议（TLS）来保护信息在互联网上传输时的安全。

随着网络安全威胁不断演变，极狐GitLab 始终致力于维护最高安全标准。极狐GitLab 定期更新 TLS 支持，以确保与极狐GitLab 服务的所有通信都使用最安全、最新的加密方法。

本文档概述了极狐GitLab 当前的 TLS 支持，包括用于保护数据安全的版本和加密套件。

<a id="supported-protocols"></a>

## 支持的协议

极狐GitLab 支持 TLS 1.2 及更高版本进行安全通信。这意味着 TLS 1.2 和 TLS 1.3 完全受支持，并推荐用于极狐GitLab。

由于已知的安全漏洞，较旧的协议如 TLS 1.1、TLS 1.0 以及所有版本的 SSL 均不受支持。通过强制使用 TLS 1.2 及更高版本，极狐GitLab 确保了所有数据传输和与平台交互的高安全性。

<a id="supported-cipher-suites"></a>

## 支持的加密套件

极狐GitLab 支持多种加密套件。以下每个加密套件都被认为是安全的，并具有 `A` 的 [SSL 服务器评级](https://github.com/ssllabs/research/wiki/SSL-Server-Rating-Guide)。

| 协议版本 | 加密套件 |
|------------------|--------------|
| TLSv1.3 | TLS_AKE_WITH_AES_128_GCM_SHA256 |
| TLSv1.3 | TLS_AKE_WITH_AES_256_GCM_SHA384 |
| TLSv1.3 | TLS_AKE_WITH_CHACHA20_POLY1305_SHA256 |
| TLSv1.2 | TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 |
| TLSv1.2 | TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256 |
| TLSv1.2 | TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256-draft |
| TLSv1.2 | TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA |
| TLSv1.2 | TLS_RSA_WITH_AES_128_GCM_SHA256 |
| TLSv1.2 | TLS_RSA_WITH_AES_128_CBC_SHA |
| TLSv1.2 | TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 |
| TLSv1.2 | TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA |
| TLSv1.2 | TLS_RSA_WITH_AES_256_GCM_SHA384 |
| TLSv1.2 | TLS_RSA_WITH_AES_256_CBC_SHA |
| TLSv1.2 | TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256 |
| TLSv1.2 | TLS_RSA_WITH_AES_128_CBC_SHA256 |
| TLSv1.2 | TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384 |
| TLSv1.2 | TLS_RSA_WITH_AES_256_CBC_SHA256 |

<a id="certificate-requirements"></a>

## 证书要求

OpenSSL 3 将[默认安全级别从级别 1 提高到级别 2](https://docs.openssl.org/3.0/man3/SSL_CTX_set_security_level/#default-callback-behaviour)，将安全位数从 80 位提高到 112 位。因此，禁止使用短于 2048 位的 RSA、DSA 和 DH 密钥以及短于 224 位的 ECC 密钥。极狐GitLab 将无法连接到使用位数不足的证书签名的服务，并显示 `证书密钥太弱` 错误消息。

您应使用至少 128 位的安全性。这意味着使用至少 3072 位的 RSA、DSA 和 DH 密钥，以及长于 256 位的 ECC 密钥。

| 密钥类型 | 密钥长度（位） | 状态      |
|----------|-------------------|-------------|
| RSA      | 1024              | 禁止  |
| RSA      | 2048              | 支持   |
| RSA      | 3072              | 推荐 |
| RSA      | 4096              | 推荐 |
| DSA      | 1024              | 禁止  |
| DSA      | 2048              | 支持   |
| DSA      | 3072              | 推荐 |
| ECC      | 192               | 禁止  |
| ECC      | 224               | 支持   |
| ECC      | 256               | 推荐 |
| ECC      | 384               | 推荐 |

<a id="openssl-version-and-tls-requirements"></a>

## OpenSSL 版本和 TLS 要求

极狐GitLab 17.7 及更高版本使用 OpenSSL 版本 3。Linux 软件包附带的所有组件都与 OpenSSL 3 兼容。但是，在升级到极狐GitLab 17.7 之前，请使用 [OpenSSL 3 指南](https://gitlab.cn/docs/omnibus/settings/ssl/openssl_3/) 来识别和评估您的外部集成的兼容性。

<a id="bypassing-the-openssl-3-requirement-for-close_notify"></a>

## 绕过 OpenSSL 3 对 `close_notify` 的要求

{{< history >}}

- 在极狐GitLab 17.10 中引入，并移植到极狐GitLab 17.9.1、17.8.4 和 17.7.6。

{{< /history >}}

[根据 RFC 52460](https://www.rfc-editor.org/rfc/rfc5246#section-7.2.1)，SSL 连接应以 `close_notify` 消息终止。OpenSSL 3 将此作为安全措施强制执行。某些服务（例如第三方 S3 提供商）可能会因此强制执行而报告 `读取时意外 eof` 错误。

可以通过将 `SSL_IGNORE_UNEXPECTED_EOF` [环境变量](../administration/environment_variables.md) 设置为 `true` 来禁用此要求。这仅作为临时解决方法。禁用此功能可能会引入截断攻击的安全漏洞。