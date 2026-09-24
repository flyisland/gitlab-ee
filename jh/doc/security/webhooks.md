---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 过滤出站请求
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

为了保护数据丢失和泄露的风险，极狐GitLab 管理员现在可以使用出站请求过滤控制来限制极狐GitLab 实例发出的某些出站请求。

<a id="secure-webhooks-and-integrations"></a>

## 保护 webhooks 和集成

具有维护者或所有者角色的用户可以设置 webhooks，当项目或群组中发生特定更改时触发。触发后，会向 URL 发送一个 `POST` HTTP 请求。Webhook 通常配置为将数据发送到特定的外部 Web 服务，该服务以适当的方式处理数据。

但是，Webhook 可以配置为内部 Web 服务的 URL，而不是外部 Web 服务。当 Webhook 被触发时，运行在极狐GitLab 服务器或其本地网络中的非极狐GitLab Web 服务可能会被利用。

Webhook 请求由极狐GitLab 服务器本身发出，并使用每个钩子的单个可选密钥令牌进行授权，而不是：
- 用户令牌。
- 仓库特定令牌。

因此，这些请求可能具有比预期更广泛的访问权限，包括访问托管 Webhook 的服务器上运行的所有内容，包括：
- 极狐GitLab 服务器。
- API 本身。
- 对于某些 Webhook，可以网络访问该 Webhook 服务器本地网络中的其他服务器，即使这些服务在其他方面受到保护且无法从外部访问。

Webhook 可用于使用不需要身份验证的 Web 服务触发破坏性命令。这些 Webhook 可以使极狐GitLab 服务器向删除资源的端点发出 `POST` HTTP 请求。

<a id="allow-requests-to-the-local-network-from-webhooks-and-integrations"></a>

### 允许来自 webhooks 和集成的本地网络请求

先决条件：

- 您必须具有实例的管理员访问权限。

为了防止利用不安全的内部 Web 服务，不允许向以下本地网络地址发出所有 Webhook 和集成请求：
- 当前极狐GitLab 实例服务器地址。
- 私有网络地址，包括 `127.0.0.1`、`::1`、`0.0.0.0`、`10.0.0.0/8`、`172.16.0.0/12`、`192.168.0.0/16` 和 IPv6 站点本地 (`ffc0::/10`) 地址。

要允许访问这些地址：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **出站请求**。
1. 选中 **允许来自 webhooks 和集成的本地网络请求** 复选框。

<a id="prevent-requests-to-the-local-network-from-system-hooks"></a>

### 阻止来自系统钩子的本地网络请求

先决条件：

- 您必须具有实例的管理员访问权限。

系统钩子默认可以发出本地网络请求。要阻止系统钩子向本地网络发出请求：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **出站请求**。
1. 清除 **允许来自系统钩子的本地网络请求** 复选框。

<a id="enforce-dns-rebinding-attack-protection"></a>

### 强制执行 DNS 重新绑定攻击保护

先决条件：

- 您必须具有实例的管理员访问权限。

[DNS 重新绑定](https://en.wikipedia.org/wiki/DNS_rebinding) 是一种技术，使恶意域名解析到内部网络资源，以绕过本地网络访问限制。极狐GitLab 默认启用对此攻击的保护。要禁用此保护：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **出站请求**。
1. 清除 **强制执行 DNS 重新绑定攻击保护** 复选框。

<a id="filter-requests"></a>

## 过滤请求

{{< history >}}

- 在极狐GitLab 15.10 中引入。

{{< /history >}}

先决条件：

- 您必须具有极狐GitLab 实例的管理员访问权限。

要通过阻止许多请求来过滤请求：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **出站请求**。
1. 选中 **阻止所有请求，除了在允许列表中定义的 IP 地址、IP 范围和域名** 复选框。

选中此复选框后，对以下内容的请求仍不会被阻止：
- 核心服务，如 Git、极狐GitLab Shell、Gitaly、PostgreSQL 和 Redis。
- 对象存储。
- [允许列表](#allow-outbound-requests-to-certain-ip-addresses-and-domains) 中的 IP 地址和域名。

启用此设置后，极狐GitLab 可能会对包含在其他对象中的 URL（例如发布链接）执行 DNS 解析。如果 DNS 解析失败，请求将失败。要解决此问题，请将主机名添加到 [允许列表](#allow-outbound-requests-to-certain-ip-addresses-and-domains)，即使极狐GitLab 永远不需要与该主机建立出站连接。

此设置仅由主极狐GitLab 应用程序遵守，因此其他服务（如 Gitaly）仍可以发出违反规则的请求。此外，[极狐GitLab 的某些区域](https://jihulab.com/groups/gitlab-cn/-/epics/8029) 不遵守出站过滤规则。

<a id="allow-outbound-requests-to-certain-ip-addresses-and-domains"></a>

## 允许向特定 IP 地址和域名的出站请求

先决条件：

- 您必须具有实例的管理员访问权限。

要允许向特定 IP 地址和域名的出站请求：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **出站请求**。
1. 在 **钩子和集成可以访问的本地 IP 地址和域名** 中，输入您的 IP 地址和域名。

条目可以：
- 用分号、逗号或空格（包括换行符）分隔。
- 采用不同格式，如主机名、IP 地址、IP 地址范围。支持 IPv6。包含 Unicode 字符的主机名应使用 [国际化域名](https://www.icann.org/en/icann-acronyms-and-terms/internationalized-domain-names-in-applications-en) (IDNA) 编码。
- 包含端口。例如，`127.0.0.1:8080` 仅允许连接到 `127.0.0.1` 上的端口 8080。如果未指定端口，则允许该 IP 地址或域名上的所有端口。IP 地址范围允许该范围内所有 IP 地址上的所有端口。
- 条目数量不超过 1000 个，每个条目不超过 255 个字符。
- 不包含通配符（例如，`*.example.com`）。

例如：

```plaintext
example.com;gitlab.example.com
127.0.0.1,1:0:0:0:0:0:0:1
127.0.0.0/8 1:0:0:0:0:0:0:0/124
[1:0:0:0:0:0:0:1]:8080
127.0.0.1:8080
example.com:8080
```

<a id="troubleshooting"></a>

## 故障排除

过滤出站请求时，您可能会遇到以下问题。

<a id="configured-urls-are-blocked"></a>

### 配置的 URL 被阻止

只有在没有配置的 URL 会被阻止的情况下，才能选中 **阻止所有请求，除了在允许列表中定义的 IP 地址、IP 范围和域名** 复选框。否则，您可能会收到一条错误消息，指出该 URL 被阻止。

如果您无法启用此设置，请执行以下操作之一：
- 禁用 URL 设置。
- 配置另一个 URL，或将 URL 设置留空。
- 将配置的 URL 添加到 [允许列表](#allow-requests-to-the-local-network-from-webhooks-and-integrations)。

<a id="public-runner-releases-url-is-blocked"></a>

### 公共 Runner 发布 URL 被阻止

大多数极狐GitLab 实例的 `public_runner_releases_url` 设置为 `https://jihulab.com/api/v4/projects/gitlab-cn%2Fgitlab-runner/releases`，这可能会阻止您 [过滤请求](#filter-requests)。

要解决此问题，请 [配置极狐GitLab 不再从 JihuLab.com 获取 Runner 发布版本数据](../administration/settings/continuous_integration.md#control-runner-version-management)。

<a id="gitlab-subscription-management-is-blocked"></a>

### 极狐GitLab 订阅管理被阻止

当您 [过滤请求](#filter-requests) 时，[极狐GitLab 订阅管理](../subscriptions/manage_subscription.md) 被阻止。

要解决此问题，请将 `customers.jihulab.com:443` 添加到 [允许列表](#allow-outbound-requests-to-certain-ip-addresses-and-domains)。

<a id="gitlab-documentation-is-blocked"></a>

### 极狐GitLab 文档被阻止

当您 [过滤请求](#filter-requests) 时，您可能会收到一个错误，指出 `帮助页面文档基础 URL 被阻止：不允许向不在允许列表中的主机和 IP 地址发出请求`。
要解决此错误：

1. 还原更改，以便不再显示错误消息 `帮助页面文档基础 URL 被阻止`。
1. 将 `gitlab.cn` 或 [重定向帮助文档页面 URL](../administration/settings/help_page.md#redirect-help-pages) 添加到 [允许列表](#allow-outbound-requests-to-certain-ip-addresses-and-domains)。
1. 选择 **保存更改**。

<a id="gitlab-duo-functionality-is-blocked"></a>

### 极狐GitLab Duo 功能被阻止

当您 [过滤请求](#filter-requests) 时，尝试使用 [极狐GitLab Duo 功能](../user/gitlab_duo/_index.md) 时可能会看到 `401` 错误。

当不允许向极狐GitLab 云服务器发出出站请求时，可能会发生此错误。要解决此错误：

1. 将 `https://cloud.jihulab.com:443` 添加到 [允许列表](#allow-outbound-requests-to-certain-ip-addresses-and-domains)。
1. 选择 **保存更改**。
1. 在极狐GitLab 可以访问 [云服务器](../user/gitlab_duo/_index.md) 后，[手动同步您的许可证](../subscriptions/manage_subscription.md#manually-synchronize-subscription-data)。