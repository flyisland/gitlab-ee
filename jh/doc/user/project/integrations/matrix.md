---
stage: Growth
group: Engagement
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Matrix
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 17.3。

{{< /history >}}

您可以配置极狐GitLab向 Matrix 房间发送通知。

<a id="set-up-the-matrix-integration-in-gitlab"></a>

## 设置极狐GitLab中的Matrix集成

先决条件：

- 实例启用的管理员访问权限。
- 群组启用的所有者角色。
- 项目启用的维护者或所有者角色。

加入 Matrix 房间后，您可以配置极狐GitLab发送通知：

1. 要启用集成：
   - **对于您的群组或项目**：
     1. 在顶部栏，选择**搜索或跳转到**并找到您的项目或群组。
     1. 选择**设置** > **集成**。
   - **对于您的实例**：
     1. 在右上角，选择**管理员**。
     1. 选择**设置** > **集成**。
1. 选择**Matrix**。
1. 在**启用集成**下，勾选**活跃**复选框。
1. 可选。在**主机名**中，输入服务器的主机名。
1. 在**令牌**中，粘贴来自 Matrix 用户的令牌值。
1. 在**触发器**部分，勾选您希望在 Matrix 中接收的极狐GitLab事件的复选框。
1. 在**通知设置**部分：
   - 在**房间标识符**中，粘贴 Matrix 房间标识符。
   - 可选。勾选**仅通知损坏的流水线**复选框，仅接收失败流水线的通知。
   - 可选。勾选**仅在状态更改时通知**复选框，仅在引用的流水线状态更改时接收通知。
   - 可选。从**要发送通知的分支**下拉列表中，选择您要接收通知的分支。
1. 可选。选择**测试设置**。
1. 选择**保存更改**。

Matrix 房间现在可以接收所有选定的极狐GitLab事件。