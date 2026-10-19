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
- Status: 实验

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

Runner 控制器可为通过[作业路由器](_index.md)路由的 CI/CD 作业启用准入控制。当作业即将执行时，作业路由器会向已连接的 Runner 控制器发送准入请求，控制器可根据自定义策略准入或拒绝该作业。

Runner 控制器针对实例进行配置，并根据其[作用域](#scoping)适用于相应的作业。

使用 Runner 控制器可以：

- 强制执行自定义准入策略，例如镜像允许名单、资源配额或安全要求。
- 控制作业排队和资源分配，以便进行容量管理。
- 确保作业在执行前符合组织策略，以便执行合规要求。
- 根据预算或资源限制来限制作业执行，以便控制成本。

<a id="admission-control-workflow"></a>

## 准入控制工作流

当您将 Runner 控制器与作业路由器一起配置后，准入控制工作流按如下方式运行：

1. Runner 控制器连接到作业路由器。
1. 控制器注册自身并开始处理准入请求。
1. 当作业需要准入时，作业路由器会将作业详情发送给已连接的控制器。
1. 控制器根据自定义策略评估该作业。
1. 控制器发送准入决定（准入或拒绝并附上原因）。
1. 作业路由器继续执行作业，或报告拒绝结果。

<a id="view-rejection-reasons"></a>

## 查看拒绝原因

当 Runner 控制器拒绝某个作业时，该作业会以 `job_router_failure` 失败原因失败。作业详情页面会显示一条消息，其中包含：

- 作业路由器信息
- Runner 控制器信息
- Runner 控制器提供的拒绝原因

![显示 Runner 控制器拒绝原因的作业拒绝消息](img/job_rejection_message_v18_9.png)

<a id="dry-run-mode-logging"></a>

### 试运行模式日志记录

当 Runner 控制器处于 `dry_run` 状态时，拒绝决定不会被执行，而是作为信息性消息记录在作业路由器（KAS）后端日志中。在启用强制执行之前，可使用这些日志验证控制器的行为。

<a id="runner-controller-states"></a>

## Runner 控制器状态

Runner 控制器可以处于以下三种状态之一：

| 状态 | 描述 |
|-------|-------------|
| `disabled` | 默认状态。Runner 控制器不接收准入请求。 |
| `enabled` | Runner 控制器接收准入请求，其决定会影响作业执行。 |
| `dry_run` | Runner 控制器接收准入请求。作业路由器会记录这些决定，但不会强制执行。在启用强制执行之前，可使用此状态进行策略性发布，以验证控制器行为并降低部署风险。 |

<a id="scoping"></a>

## 作用域

Runner 控制器必须设置作用域才能生效。没有任何作用域的 Runner 控制器不会接收准入请求，即使其状态为 `enabled` 或 `dry_run`。

Runner 控制器支持两种互斥的作用域类型：

| 作用域 | 描述 |
|-------|-------------|
| 实例 | Runner 控制器评估极狐GitLab 实例中所有 Runner 的作业。此作用域不能与 Runner 作用域组合使用。 |
| Runner | Runner 控制器仅评估特定 Runner 的作业。您可以将控制器的作用域设置为一个或多个 Runner。该 Runner 必须是实例 Runner。 |

其他作用域类型（群组、项目）已在[议题 586419](https://gitlab.com/gitlab-org/gitlab/-/issues/586419)中提出。

要管理 Runner 控制器作用域，请参见 [Runner 控制器 API](../../../api/runner_controllers.md)。

<a id="manage-runner-controllers"></a>

## 管理 Runner 控制器

Runner 控制器通过 REST API 进行管理。目前还没有用于管理 Runner 控制器的 UI。

- 要创建、列出、更新或删除 Runner 控制器，请参见 [Runner 控制器 API](../../../api/runner_controllers.md)。
- 要创建、列出或删除 Runner 控制器的作用域，请参见 [Runner 控制器作用域 API](../../../api/runner_controllers.md#runner-controller-scopes)。
- 要管理 Runner 控制器的认证令牌，请参见 [Runner 控制器令牌 API](../../../api/runner_controller_tokens.md)。

先决条件：

- 您必须拥有极狐GitLab 实例的管理员访问权限。

<a id="implement-a-runner-controller"></a>

## 实现 Runner 控制器

有关分步指南，请参见[教程：构建 Runner 准入控制器](../../../tutorials/build_runner_admission_controller/_index.md)。

要实现您自己的 Runner 控制器，您需要：

1. 在极狐GitLab 中创建 Runner 控制器。
1. 为 Runner 控制器设置作用域。
1. 获取 Runner 控制器令牌。
1. 使用该令牌连接到作业路由器。
1. 将您的控制器注册到作业路由器。
1. 处理准入请求并发送决定。

有关技术规范和 protobuf 定义，请参见 GitLab Agent for Kubernetes 代码仓库中的
[Runner 控制器文档](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/runner_controller.md)。
