---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: irker（IRC 网关）
description: "配置 irker 集成，将极狐GitLab 推送通知发送到 IRC 频道。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 提供了一种将更新消息推送到 irker 服务器的方式。配置该集成后，每次向项目推送都会触发该集成，将数据直接发送到 irker 服务器。

另请参阅 [irker 集成 API 文档](../../../api/project_integrations.md)。

更多信息，请参阅 [irker 项目主页](https://gitlab.com/esr/irker)。

<a id="set-up-an-irker-daemon"></a>

## 设置 irker 守护进程

您需要设置一个 irker 守护进程。操作步骤如下：

1. [从其代码仓库](https://gitlab.com/esr/irker)下载 irker 代码：

   ```shell
   git clone https://gitlab.com/esr/irker.git
   ```

1. 运行名为 `irkerd`的 Python 脚本。该脚本就是网关。
   它既作为 IRC 客户端，用于向 IRC 服务器发送消息，
   也作为 TCP 服务器，用于接收来自极狐GitLab 服务的消息。

如果 irker 服务器运行在同一台机器上，则无需其他操作。如果不是，您需要按照下一节的前几个步骤操作。

> [!warning]
> irker 没有内置身份验证，因此如果它托管在防火墙之外，就容易被用来向 IRC 频道发送垃圾信息。为防止滥用，请确保在安全的网络上运行该守护进程。更多详情，请阅读
> [irker 安全分析](http://www.catb.org/~esr/irker/security.html)。

<a id="complete-these-steps-in-gitlab"></a>

## 在极狐GitLab 中完成以下步骤

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **irker（IRC 网关）**。
1. 在**启用集成**下，选中**活跃**复选框。
1. 可选。在**服务器主机**下，输入运行 `irkerd`的服务器主机地址。如果留空，
   则默认为 `localhost`。
1. 可选。在**服务器端口**下，输入 `irkerd`的服务器端口。如果留空，则默认为 `6659`。
1. 可选。在**默认 IRC URI** 下，输入默认 IRC URI，格式为 `irc[s]://domain.name`。
   它会被添加到**接收者**下提供的每个频道或用户之前，前提是这些频道或用户不是完整 URI。
1. 在**接收者**下，输入要接收更新的用户或频道，以空格分隔
   （例如 `#channel1 user1`）。更多详情，请参阅[输入 irker 接收者](#enter-irker-recipients)。
1. 可选。要高亮消息，请选中**为消息着色**复选框。
1. 可选。选择**测试设置**。
1. 选择**保存更改**。

<a id="enter-irker-recipients"></a>

## 输入 irker 接收者

如果您将**默认 IRC URI** 文本框留空，请以完整 URI 的形式输入接收者：`irc[s]://irc.network.net[:port]/#channel`。如果您在其中输入了默认 IRC URI，则只需使用频道名或用户名即可。

要发送消息：

- 发送到频道（例如 `#chan`）时，irker 接受 `chan` 和
  `#chan` 形式的频道名。
- 发送到受密码保护的频道时，请在频道名后附加 `?key=thesecretpassword`，
  并将 `thesecretpassword` 替换为频道密码。例如 `chan?key=hunter2`。
  不要在频道名前加上 `#` 符号。如果加了，irker 会尝试加入一个
  名为 `#chan?key=password`的频道，从而可能通过
  `/whois` IRC 命令泄露频道密码。这是 irker 一个长期存在的缺陷导致的行为。
- 在用户查询中，请在用户名后添加 `,isnick`。例如 `UserSmith,isnick`。
