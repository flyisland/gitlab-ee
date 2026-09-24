---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Runner 控制器
description: 使用 Runner 控制器控制作业准入。
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史记录。
> 此功能可用于测试，但尚未准备好用于生产环境。

{{< history >}}

- 在 极狐GitLab 18.9 中引入，[带有功能标志](../../../administration/feature_flags/_index.md) 命名为 `job_router_admission_control`。默认禁用。此功能为[实验](../../../policy/development_stages_support.md)性质，并受 [极狐GitLab 测试协议](https://handbook.gitlab.com/handbook/legal/testing-agreement/) 约束。
- 在 极狐GitLab 18.10 中引入了 Runner 范围。

{{< /history >}}

Runner 控制器为通过[作业路由器](_index.md)路由的 CI/CD 作业启用准入控制。当作业即将执行时，作业路由器向连接的 Runner 控制器发送准入请求，这些控制器可以根据自定义策略接受或拒绝该作业。

Runner 控制器位于实例级别，并根据其[范围](#scoping)适用于作业。

使用 Runner 控制器可以：

- 强制执行自定义准入策略，例如镜像允许列表、资源配额或安全要求。
- 控制作业排队和资源分配，以进行容量管理。
- 确保作业在执行前符合组织策略，以实现合规性执行。
- 根据预算或资源限制限制作业执行，以控制成本。

<a id="admission-control-workflow"></a>

## 准入控制工作流

当您将 Runner 控制器与作业路由器一起配置时，准入控制工作流按以下方式运行：

1. Runner 控制器连接到作业路由器。
1. 控制器注册自身并开始处理准入请求。
1. 当作业需要准入时，作业路由器将作业详细信息发送给连接的控制器。
1. 控制器根据自定义策略评估作业。
1. 控制器发送准入决定（接受或拒绝并说明原因）。
1. 作业路由器继续执行作业或报告拒绝。

<a id="view-rejection-reasons"></a>

## 查看拒绝原因

当 Runner 控制器拒绝作业时，作业会因 `job_router_failure` 失败原因而失败。作业详情页面显示一条消息，包括：

- 作业路由器信息
- Runner 控制器信息
- Runner 控制器提供的拒绝原因

![显示 Runner 控制器拒绝原因的作业拒绝消息](img/job_rejection_message_v18_9.png)

<a id="dry-run-mode-logging"></a>

### 试运行模式日志记录

当 Runner 控制器处于 `dry_run` 状态时，拒绝决定不会被强制执行，但会作为信息性消息记录在作业路由器（KAS）后端日志中。在启用强制执行之前，使用这些日志验证控制器的行为。

<a id="runner-controller-states"></a>

## Runner 控制器状态

Runner 控制器可以处于三种状态之一：

| 状态 | 描述 |
|-------|-------------|
| `disabled` | Runner 控制器不接收准入请求。这是默认状态。 |
| `enabled` | Runner 控制器接收准入请求，其决定会影响作业执行。 |
| `dry_run` | Runner 控制器接收准入请求。作业路由器记录决定，但决定不会被强制执行。使用此状态进行战略部署，以验证控制器行为并在启用强制执行之前降低部署风险。 |

<a id="scoping"></a>

## 范围

Runner 控制器必须设置范围才能激活。没有任何范围的 Runner 控制器不会接收准入请求，即使其状态为 `enabled` 或 `dry_run`。

Runner 控制器支持两种互斥的范围类型：

| 范围 | 描述 |
|-------|-------------|
| 实例 | Runner 控制器评估 极狐GitLab 实例中所有 Runner 的作业。此范围不能与 Runner 范围组合。 |
| Runner | Runner 控制器仅评估特定 Runner 的作业。您可以将控制器范围限定为一个或多个 Runner。Runner 必须是实例 Runner。 |

要管理 Runner 控制器范围，请参见 [Runner 控制器 API](../../../api/runner_controllers.md)。

<a id="manage-runner-controllers"></a>

## 管理 Runner 控制器

Runner 控制器通过 REST API 进行管理。目前还没有用于管理 Runner 控制器的 UI。

- 要创建、列出、更新或删除 Runner 控制器，请参见 [Runner 控制器 API](../../../api/runner_controllers.md)。
- 要创建、列出或删除 Runner 控制器的范围，请参见 [Runner 控制器范围 API](../../../api/runner_controllers.md#runner-controller-scopes)。
- 要管理 Runner 控制器的认证令牌，请参见 [Runner 控制器令牌 API](../../../api/runner_controller_tokens.md)。

前提条件：

- 您必须具有对 极狐GitLab 实例的管理员访问权限。

<a id="implement-a-runner-controller"></a>

## 实现 Runner 控制器

有关分步指南，请参见[教程：构建 Runner 准入控制器](../../../tutorials/build_runner_admission_controller/_index.md)。

要实现您自己的 Runner 控制器，您需要：

1. 在 极狐GitLab 中创建 Runner 控制器。
1. 设置 Runner 控制器的范围。
1. 获取 Runner 控制器令牌。
1. 使用令牌连接到作业路由器。
1. 向作业路由器注册您的控制器。
1. 处理准入请求并发送决定。

有关技术规范和 protobuf 定义，请参见 Kubernetes 仓库的 极狐GitLab Agent 中的 [Runner 控制器文档](https://jihulab.com/gitlab-cn/cluster-integration/gitlab-agent/-/blob/master/doc/runner_controller.md)。

<a id="related-topics"></a>

## 相关主题

- [作业路由器](_index.md)
- [Runner 控制器 API](../../../api/runner_controllers.md)
- [Runner 控制器范围 API](../../../api/runner_controllers.md#runner-controller-scopes)
- [Runner 控制器令牌 API](../../../api/runner_controller_tokens.md)
- [教程：构建 Runner 准入控制器](../../../tutorials/build_runner_admission_controller/_index.md)
- [Runner 控制器示例](https://jihulab.com/gitlab-cn/cluster-integration/runner-controller-example)（参考实现）

