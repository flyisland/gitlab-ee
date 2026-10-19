---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Akismet
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 使用 [Akismet](https://akismet.com/) 来防止在公开项目中创建垃圾议题。通过 Web UI 或 API 创建的议题可以提交给 Akismet 进行审查，实例管理员可以[将代码片段标记为垃圾内容](../user/snippets.md#mark-snippet-as-spam)。

检测到的垃圾内容会被拒绝，并在**管理**区域的 **垃圾邮件日志** 部分添加一条记录。

隐私说明：极狐GitLab 会将用户的 IP 和用户代理提交给 Akismet。

> [!note]
> 极狐GitLab 会将所有议题提交给 Akismet。

Akismet 配置可供极狐GitLab 私有化部署的用户使用。Akismet 已在
JihuLab.com 上启用，其配置和管理由 GitLab Inc. 负责。

<a id="configure-akismet"></a>

## 配置 Akismet

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要使用 Akismet：

1. 转到 [Akismet 登录页面](https://akismet.com/account/)。
1. 登录或创建一个新账号。
1. 选择 **显示** 以显示 API 密钥，然后复制该 API 密钥的值。
1. 以管理员身份登录极狐GitLab。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **报告**。
1. 展开**垃圾内容和反机器人保护**。
1. 选中**启用 Akismet** 复选框。
1. 填写第 3 步中的 API 密钥。
1. 保存配置。

<a id="train-the-akismet-filter"></a>

## 训练 Akismet 过滤器

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

为了更好地区分垃圾内容与正常内容，您可以在出现误报或漏报时
训练 Akismet 过滤器。

当某条记录被识别为垃圾内容时，它会被拒绝并添加到垃圾日志中。在这里，您可以查看这些记录是否真的是垃圾内容。如果其中某条并不是
垃圾内容，请选择 **以ham身份提交**，告知 Akismet 它错误地
将某条记录识别为垃圾内容。

如果某条实际上是垃圾内容的记录未被识别为垃圾内容，请使用 **垃圾信息举报** 将此信息
提交给 Akismet。**垃圾信息举报** 按钮仅向
管理员用户显示。

训练 Akismet 有助于它在将来更准确地识别垃圾内容。
