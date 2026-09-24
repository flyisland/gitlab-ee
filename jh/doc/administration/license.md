---
stage: Fulfillment
group: Provision
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 激活极狐GitLab 企业版以解锁专业版和旗舰版功能。了解激活步骤、许可证选项和故障排除技巧。
title: 激活极狐GitLab 企业版
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

When you install a new 极狐GitLab instance without a license, only 基础版 features
are enabled. To enable more features in 极狐GitLab Enterprise Edition (EE), activate
your instance with an activation code.

<a id="activate-gitlab-ee"></a>

## 激活极狐GitLab EE

前提条件：

- [A subscription](https://about.gitlab.com/pricing/).
- 极狐GitLab Enterprise Edition (EE).
- 你的实例已连接到互联网。
- 管理员权限。

要使用激活码激活你的实例：

1. 从以下来源之一复制激活码，它是一个 24 位的字母数字字符串：
   - 你的订阅确认邮件。
   - [Customers Portal](https://customers.jihulab.com/customers/sign_in)，在 **Manage Purchases** 页面。
1. 登录你的实例。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **订阅**。
1. 将激活码粘贴到 **激活码** 中。
1. 阅读并接受服务条款。
1. 选择 **激活**。

订阅现已激活。

<a id="using-one-activation-code-for-multiple-instances"></a>

### 为多个实例使用一个激活码

You can use a single activation code or license key for multiple 极狐GitLab 私有化部署 instances if the users are:

- Identical to your licensed production instance.
- A subset of your licensed production instance.

The activation code is valid for these instances, regardless of how users are configured in groups and projects.

<a id="for-scaled-architectures"></a>

### 对于横向扩展架构

要在横向扩展架构中激活你的实例：

- 仅将许可证文件上传到一个应用程序实例。

许可证存储在数据库中，并将复制到所有实例。

<a id="for-gitlab-geo"></a>

### 对于极狐GitLab Geo

使用极狐GitLab Geo 时激活你的实例：

- 将许可证上传到你的主 Geo 实例。

许可证存储在数据库中，并将复制到所有实例。

<a id="for-offline-environments"></a>

### 对于离线环境

要在离线环境中激活你的实例：

- [使用许可证文件或密钥激活极狐GitLab EE](license_file.md)。

如果你有疑问或需要激活实例的帮助，
[联系极狐GitLab 支持](https://about.gitlab.com/support/#contact-support)。

当 [许可证过期](license_file.md#what-happens-when-your-license-expires) 时，
部分功能将被锁定。

<a id="verify-your-gitlab-edition"></a>

## 验证你的极狐GitLab 版本

要验证版本，登录极狐GitLab 并选择
**帮助** ({{< icon name="question-o" >}}) > **帮助**。极狐GitLab 的版本和修订版会列在
页面顶部。

如果你正在运行极狐GitLab Community Edition (CE)，你可以将安装升级到极狐GitLab
EE。更多信息，请参见 [其他升级路径](../update/convert_to_ee/_index.md)。

如果你有疑问或需要帮助，
[联系极狐GitLab 支持](https://about.gitlab.com/support/#contact-support)。

<a id="troubleshooting"></a>

## 故障排除

在私有化部署的极狐GitLab 实例上激活付费订阅功能时，你可能会遇到以下问题。

<a id="error-an-error-occurred-while-adding-your-subscription"></a>

### 错误：`An error occurred while adding your subscription`

此问题可能在你输入激活码后发生。

要查找有关错误的更多详细信息，你可以使用浏览器的开发者工具：

1. 要打开开发者工具，在页面上右键单击并选择 **检查**。
1. 选择 **Network** 选项卡。
1. 在极狐GitLab 中，重试激活码。
1. 在 **Network** 选项卡中，选择 `graphql` 条目。
1. 选择 **Response** 选项卡，并检查是否有类似以下的错误：

      ```plaintext
      [{"data":{"gitlabSubscriptionActivate":{"errors":["<error> returned=1 errno=0 state=error: <error>"],"license":null,"__typename":"GitlabSubscriptionActivatePayload"}}}]
      ```

要解决此问题：

- 如果 GraphQL 响应中包含 `only get, head, options, and trace methods are allowed in silent mode`，请为你的实例禁用 [静默模式](silent_mode/_index.md#turn-off-silent-mode)。

如果你无法确定问题，请联系 [极狐GitLab 支持](https://about.gitlab.com/support/portal/) 并在问题描述中提供 GraphQL 响应。

<a id="error-cannot-activate-instance-due-to-a-connectivity-issue"></a>

### 错误：`Cannot activate instance due to a connectivity issue`

激活实例时，你可能会遇到阻止连接到极狐GitLab 服务器的连接问题。
这可能是由以下原因引起的：

- **防火墙设置**：
  - 要确认你的极狐GitLab 实例可以建立到 `https://customers.jihulab.com` 端口 443 的加密连接，请使用以下 curl 命令：

    ```shell
    curl --verbose "https://customers.jihulab.com/"
    ```

  - 如果 curl 命令返回错误，请：
    - 检查你的防火墙或代理。
    - [配置代理](https://gitlab.cn/docs/omnibus/settings/environment-variables/)
      在 `gitlab.rb` 中指向你的服务器。

    联系你的网络管理员以更改现有的代理或防火墙。
  - 如果使用了 SSL 检查设备，你必须将该设备的根 CA 证书添加到实例上的 `/etc/gitlab/trusted-certs`，然后运行 `gitlab-ctl reconfigure`。
- **客户门户无法正常运行**：
  - 在 [状态页面](https://status.gitlab.com/) 上检查客户门户是否有任何活跃的服务中断。
- **离线环境**：
  - 检查 [DNS 设置](https://gitlab.cn/docs/omnibus/settings/dns/)。
  - 联系以下任一一方：
    - 你的极狐GitLab 销售代表以申请 [离线许可证](https://about.gitlab.com/pricing/licensing-faq/cloud-licensing/#what-is-an-offline-cloud-license)。
    - [极狐GitLab 支持](https://about.gitlab.com/support/#contact-support) 以请求协助 [排查网络连接问题](https://handbook.gitlab.com/handbook/support/license-and-renewals/workflows/self-managed/troubleshoot_cloud_licensing/#troubleshooting-network-connectivity)。