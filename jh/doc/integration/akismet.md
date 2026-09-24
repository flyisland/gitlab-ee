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

极狐GitLab 使用 [Akismet](https://akismet.com/) 来防止在公共项目中创建垃圾议题。通过 Web UI 或 API 创建的议题可以被提交到 Akismet 进行审查，并且实例管理员可以[将代码片段标记为垃圾](../user/snippets.md#mark-snippet-as-spam)。

检测到的垃圾内容会被拒绝，并在 **管理员** 区域的 **垃圾日志** 部分添加记录。

隐私说明：极狐GitLab 会向 Akismet 提交用户的 IP 和用户代理信息。

> [!NOTE]
> 极狐GitLab 会向 Akismet 提交所有议题。

Akismet 配置可供私有化部署的极狐GitLab 用户使用。在 JihuLab.com 上，Akismet 已经启用，其配置和管理由极狐GitLab Inc. 处理。

<a id="configure-akismet"></a>

## 配置 Akismet

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用 Akismet 的步骤：

1. 前往 [Akismet 登录页面](https://akismet.com/account/)。
1. 登录或创建新账户。
1. 选择 **显示** 来展示 API 密钥，并复制 API 密钥的值。
1. 以管理员身份登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **报告**。
1. 展开 **垃圾内容和反机器人保护**。
1. 选择 **启用 Akismet** 复选框。
1. 填入第 3 步中的 API 密钥。
1. 保存配置。

<a id="train-the-akismet-filter"></a>

## 训练 Akismet 过滤器

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

为了更好地区分垃圾和非垃圾内容，你可以在出现误报或假阴性时训练 Akismet 过滤器。

当一个条目被识别为垃圾，它会被拒绝并添加到垃圾日志中。你可以在此审查这些条目是否真的是垃圾。如果其中某个条目并非垃圾，选择 **提交为非垃圾** 来告诉 Akismet 它错误地将该条目识别为垃圾。

如果某个确实是垃圾的条目未被识别出来，使用 **提交为垃圾** 将此信息提交给 Akismet。**提交为垃圾** 按钮仅向管理员用户显示。

训练 Akismet 有助于其未来更准确地识别垃圾内容。