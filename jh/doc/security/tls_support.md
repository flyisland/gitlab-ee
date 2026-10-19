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

极狐GitLab 通过采用传输层安全协议（TLS）来保护信息在互联网上传输时的安全，从而优先保障用户与平台之间数据传输的安全性。

随着网络安全威胁不断演变，极狐GitLab 始终致力于维持最高安全标准。极狐GitLab 定期更新 TLS 支持，以确保与极狐GitLab 服务的所有通信都使用当前可用的最安全、最新的加密方法。

本文档介绍极狐GitLab 当前支持的 TLS，包括用于保障数据安全的协议版本和密码套件。

<a id="supported-protocols"></a>

## 支持的协议

极狐GitLab 支持 TLS 1.2 及更高版本用于安全通信。这意味着完全支持 TLS 1.2 和 TLS 1.3，并推荐与极狐GitLab 一起使用。

由于存在已知的安全漏洞，不支持 TLS 1.1、TLS 1.0 等较旧的协议以及所有版本的 SSL。通过强制使用 TLS 1.2 及更高版本，极狐GitLab 确保所有数据传输以及与平台的交互都具有高安全性。

<a id="supported-cipher-suites"></a>

## 支持的密码套件

极狐GitLab 支持多种密码套件。以下每个密码套件都被认为是安全的，并且具有 [SSL 服务器评级](https://github.com/ssllabs/research/wiki/SSL-Server-Rating-Guide) `A`。

| 协议版本 | 密码套件 |
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

OpenSSL 3 将[默认安全级别从级别 1 提高到级别 2](https://docs.openssl.org/3.0/man3/SSL_CTX_set_security_level/#default-callback-behaviour)，将安全位数从 80 位提高到 112 位。因此，禁止使用短于 2048 位的 RSA、DSA 和 DH 密钥，以及短于 224 位的 ECC 密钥。极狐GitLab 将无法连接到使用位数不足的证书签名的服务，并会显示 `certificate key too weak` 错误消息。

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

极狐GitLab 17.7 及更高版本使用 OpenSSL 3。Linux 软件包随附的所有组件都与 OpenSSL 3 兼容。但是，在升级到极狐GitLab 17.7 之前，请使用 [OpenSSL 3 指南](https://gitlab.cn/docs/omnibus/settings/ssl/openssl_3/)来识别和评估您的外部集成的兼容性。

<a id="bypassing-the-openssl-3-requirement-for-close_notify"></a>

## 绕过 `close_notify`的 OpenSSL 3 要求

[根据 RFC 5246](https://www.rfc-editor.org/rfc/rfc5246#section-7.2.1)，
SSL 连接应使用 `close_notify` 消息终止。OpenSSL
3 将此作为一项安全措施强制执行。由于这一强制执行，某些服务（例如第三方 S3 提供商）可能会报告 `unexpected eof while reading` 错误。

可以通过将 `SSL_IGNORE_UNEXPECTED_EOF` [环境变量](../administration/environment_variables.md)设置为 `true` 来禁用此要求。这仅作为临时变通方法。禁用此功能可能会引入截断攻击的安全漏洞。
