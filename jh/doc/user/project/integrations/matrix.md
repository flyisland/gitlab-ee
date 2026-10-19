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

您可以配置极狐GitLab，向 Matrix 房间发送通知。

<a id="set-up-the-matrix-integration-in-gitlab"></a>

## 在极狐GitLab 中设置 Matrix 集成

先决条件：

- 实例启用需要管理员访问权限。
- 群组启用需要所有者角色。
- 项目启用需要维护者或所有者角色。

加入 Matrix 房间后，您可以配置极狐GitLab 发送通知：

1. 启用集成：
   - **为您的群组或项目**：
     1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目或群组。
     1. 选择**设置** > **集成**。
   - **为您的实例**：
     1. 在右上角，选择**管理员**。
     1. 选择**设置** > **集成**。
1. 选择 **Matrix**。
1. 在**启用集成**下，选中**活跃**复选框。
1. 可选。在**主机名**中，输入您服务器的主机名。
1. 在**令牌**中，粘贴 Matrix 用户的令牌值。
1. 在**触发器**部分，选中您希望在 Matrix 中接收的极狐GitLab 事件对应的复选框。
1. 在**通知设置**部分：
   - 在**房间标识符**中，粘贴 Matrix 房间标识符。
   - 可选。选中**仅通知失败的流水线**复选框，
     以仅接收失败流水线的通知。
   - 可选。选中**仅在状态变化时通知**复选框，
     以仅在 ref 的流水线状态变化时接收通知。
   - 可选。从**要发送通知的分支**下拉列表中，
     选择您希望接收通知的分支。
1. 可选。选择**测试设置**。
1. 选择**保存更改**。

Matrix 房间现在可以接收所有选中的极狐GitLab 事件。
