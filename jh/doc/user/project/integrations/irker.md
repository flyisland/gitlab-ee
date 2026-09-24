---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: irker（IRC 网关）
description: "Configure the irker integration to send GitLab push notifications to IRC channels."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 提供了一种将更新消息推送到 irker 服务器的方法。配置集成后，每次推送到项目都会触发集成，直接将数据发送到 irker 服务器。

另请参阅 [irker 集成 API 文档](../../../api/project_integrations.md)。

更多信息，请参阅 [irker 项目主页](https://gitlab.com/esr/irker)。

<a id="set-up-an-irker-daemon"></a>

## 设置 irker 守护进程

你需要设置一个 irker 守护进程。操作步骤如下：

1. 从 [其仓库](https://gitlab.com/esr/irker) 下载 irker 代码：

   ```shell
   git clone https://gitlab.com/esr/irker.git
   ```

1. 运行名为 `irkerd` 的 Python 脚本。这是网关脚本。它既作为 IRC 客户端，用于向 IRC 服务器发送消息，也作为 TCP 服务器，用于接收来自极狐GitLab 服务的消息。

如果 irker 服务器在同一台机器上运行，则设置完成。否则，你需要执行下一节的前几个步骤。

> [!warning]
> irker **没有**内置身份验证，如果托管在防火墙之外，则容易受到向 IRC 频道发送垃圾消息的攻击。为防止滥用，请确保在安全的网络中运行守护进程。更多详情，请阅读 [irker 安全分析](http://www.catb.org/~esr/irker/security.html)。

<a id="complete-these-steps-in-gitlab"></a>

## 在极狐GitLab 中完成以下步骤

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **irker（IRC 网关）**。
1. 确保 **启用** 开关已开启。
1. 可选。在 **服务器主机** 下，输入运行 `irkerd` 的服务器主机地址。如果为空，则默认为 `localhost`。
1. 可选。在 **服务器端口** 下，输入 `irkerd` 的服务器端口。如果为空，则默认为 `6659`。
1. 可选。在 **默认 IRC URI** 下，输入默认 IRC URI，格式为 `irc[s]://domain.name`。它会添加到 **收件人** 下提供的每个频道或用户前面，这些频道或用户不是完整的 URI。
1. 在 **收件人** 下，输入要接收更新的用户或频道，用空格分隔（例如 `#channel1 user1`）。更多详情，请参阅 [输入 irker 收件人](#enter-irker-recipients)。
1. 可选。要高亮显示消息，请选中 **彩色消息** 复选框。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

<a id="enter-irker-recipients"></a>

## 输入 irker 收件人

如果你将 **默认 IRC URI** 字段留空，请输入完整的 URI 作为收件人：`irc[s]://irc.network.net[:port]/#channel`。如果你在那里输入了默认 IRC URI，则只需使用频道或用户名。

发送消息：

- 发送到频道（例如 `#chan`），irker 接受 `chan` 和 `#chan` 形式的频道名称。
- 发送到受密码保护的频道，请在频道名称后附加 `?key=thesecretpassword`，并将 `thesecretpassword` 替换为频道密码。例如 `chan?key=hunter2`。**不要**在频道名称前加上 `#` 符号。如果这样做，irker 会尝试加入名为 `#chan?key=password` 的频道，从而可能通过 `/whois` IRC 命令泄露频道密码。这是由于 irker 长期存在的一个错误。
- 在用户查询中，在用户名后添加 `,isnick`。例如 `UserSmith,isnick`。