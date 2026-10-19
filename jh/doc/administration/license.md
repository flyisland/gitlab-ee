---
stage: Fulfillment
group: Provision
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 激活极狐GitLab 企业版
description: "使用激活码激活极狐GitLab 企业版，解锁付费功能。了解如何为新实例、横向扩展实例或离线实例激活订阅。"
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

安装新的极狐GitLab 实例时，如果没有许可证，则仅启用基础版功能。要启用极狐GitLab 企业版中的更多功能，请使用激活码激活您的实例。

<a id="activate-gitlab-ee"></a>

## 激活极狐GitLab 企业版

先决条件：

- [订阅](https://gitlab.cn/pricing)。
- 极狐GitLab 企业版。
- 您的实例已连接到互联网。
- 管理员访问权限。

要使用激活码激活您的实例：

1. 从以下任一位置复制激活码（一个 24 个字符的字母数字字符串）：
   - 您的订阅确认电子邮件。
   - [客户门户](https://customers.jihulab.com/customers/sign_in)的**管理购买**页面。
1. 登录您的实例。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**订阅**。
1. 将激活码粘贴到**激活码**中。
1. 阅读并接受服务条款。
1. 选择**激活**。

订阅已激活。

<a id="using-one-activation-code-for-multiple-instances"></a>

### 对多个实例使用同一个激活码

如果用户满足以下条件，您可以将单个激活码或许可证密钥用于多个极狐GitLab 私有化部署实例：

- 与您已获许可的生产实例完全相同。
- 是您已获许可的生产实例的子集。

无论用户如何在群组和项目中配置，该激活码对这些实例均有效。

<a id="for-scaled-architectures"></a>

### 对于横向扩展架构

要在横向扩展架构中激活您的实例：

- 仅将许可证文件上传到一个应用实例。

许可证存储在数据库中，并会复制到所有实例。

<a id="for-gitlab-geo"></a>

### 对于极狐GitLab Geo

在使用极狐GitLab Geo 时激活您的实例：

- 将许可证上传到您的主 Geo 实例。

许可证存储在数据库中，并会复制到所有实例。

<a id="for-offline-environments"></a>

### 对于离线环境

要为离线环境激活您的实例：

- [使用许可证文件或密钥激活极狐GitLab 企业版](license_file.md)。

如果您有疑问或需要协助激活您的实例，请[联系极狐GitLab 支持](https://gitlab.cn/support)。

当[许可证过期](license_file.md#what-happens-when-your-license-expires)时，部分功能会被锁定。

<a id="verify-your-gitlab-edition"></a>

## 验证您的极狐GitLab 版本类型

要验证版本类型，请登录极狐GitLab 并选择**帮助** ({{< icon name="question-o" >}}) > **帮助**。极狐GitLab 的版本类型和版本号列在页面顶部。



如果您有疑问或需要协助，请[联系极狐GitLab 支持](https://gitlab.cn/support)。

<a id="troubleshooting"></a>

## 故障排除

在极狐GitLab 私有化部署实例上激活付费订阅功能时，您可能会遇到以下问题。

<a id="error-an-error-occurred-while-adding-your-subscription"></a>

### 错误：`An error occurred while adding your subscription`

此问题可能在您输入激活码后出现。

要查找有关该错误的更多详细信息，您可以使用浏览器的开发者工具：

1. 要打开开发者工具，请右键点击页面并选择**检查**。
1. 选择**网络**标签页。
1. 在极狐GitLab 中，重试激活码。
1. 在**网络**标签页中，选择 `graphql` 条目。
1. 选择**响应**标签页，并检查是否有类似以下的错误：

      ```plaintext
      [{"data":{"gitlabSubscriptionActivate":{"errors":["<error> returned=1 errno=0 state=error: <error>"],"license":null,"__typename":"GitlabSubscriptionActivatePayload"}}}]
      ```

要解决此问题：

- 如果 GraphQL 响应包含 `only get, head, options, and trace methods are allowed in silent mode`，请为您的实例禁用[静默模式](silent_mode/_index.md#turn-off-silent-mode)。

如果您无法确定问题所在，请联系[极狐GitLab 支持](https://gitlab.cn/support)，并在问题描述中提供 GraphQL 响应。

<a id="error-cannot-activate-instance-due-to-a-connectivity-issue"></a>

### 错误：`Cannot activate instance due to a connectivity issue`

激活您的实例时，您可能会遇到连接问题，导致无法连接到极狐GitLab 服务器。这可能由以下原因引起：

- **防火墙设置**：
  - 要确认您的极狐GitLab 实例能够通过端口 443 与 `https://customers.jihulab.com` 建立加密连接，请使用以下 curl 命令：

    ```shell
    curl --verbose "https://customers.jihulab.com/"
    ```

  - 如果 curl 命令返回错误，请执行以下任一操作：
    - 检查您的防火墙或代理。域名 `https://customers.jihulab.com` 由
      Cloudflare 提供前端服务。请确保您的防火墙或代理允许流量访问 Cloudflare
      [IPv4](https://www.cloudflare.com/ips-v4/) 和
      [IPv6](https://www.cloudflare.com/ips-v6/) 范围，以便激活正常工作。
    - 在 `gitlab.rb`中[配置代理](https://gitlab.cn/docs/omnibus/settings/environment-variables/)
      以指向您的服务器。

    请联系您的网络管理员，对现有代理或防火墙进行更改。
  - 如果使用了 SSL 检查设备，您必须将该设备的根 CA 证书添加到实例上的 `/etc/gitlab/trusted-certs`，然后运行 `gitlab-ctl reconfigure`。
- **客户门户无法运行**：
  - 在 [状态页面](https://status.gitlab.com/) 上检查客户门户是否有任何正在发生的服务中断。
- **离线环境**：
  - 检查 [DNS 设置](https://gitlab.cn/docs/omnibus/settings/dns/)。
  - 联系以下任一对象：
    - 您的极狐GitLab 销售代表，以申请[离线许可证](https://about.gitlab.com/pricing/licensing-faq/cloud-licensing/#what-is-an-offline-cloud-license)。
    - [极狐GitLab 支持](https://gitlab.cn/support)，以请求协助进行[网络连接故障排除](https://handbook.gitlab.com/handbook/support/license-and-renewals/workflows/self-managed/troubleshoot_cloud_licensing/#troubleshooting-network-connectivity)。
