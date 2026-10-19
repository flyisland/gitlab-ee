---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 从站点 Runner
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

通过[从站点的 Geo 代理](_index.md)，可以将 `gitlab-runner` 注册到从站点。这可以减轻主实例的负载。

> [!note]
> 在流水线第一阶段启动的作业，其 Git 克隆请求几乎总是被转发到主站点。这是因为这些克隆通常发生在 Git 数据被从站点复制和验证之前。后续阶段也不保证由从站点提供服务，例如，如果 Git 变更很大、带宽很小或流水线阶段很短。在大多数情况下，流水线的后续阶段会从从站点提供 Git 数据。[议题 446176](https://gitlab.com/gitlab-org/gitlab/-/issues/446176) 提出了一项增强建议，以提高第一阶段克隆请求由从站点提供服务的可能性。

<a id="use-secondary-runners-with-a-location-aware-public-url-unified-url"></a>

## 将从站点 Runner 与位置感知公共 URL（统一 URL）结合使用

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

使用[位置感知 DNS](_index.md#configure-location-aware-dns)，在启用功能标志的情况下，无需额外配置即可工作。在您安装 Runner 并将其注册到与从站点相同的位置后，它会自动与最近的站点通信，并且仅当从站点数据过期时才代理到主站点。

<a id="use-secondary-runners-with-separate-urls"></a>

## 将从站点 Runner 与单独的 URL 结合使用

使用单独的从站点 URL 时，Runner 应：

1. 使用从站点的外部 URL 注册。
1. 配置 [`clone_url`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#how-clone_url-works) 为从实例的 `external_url`。

<a id="handling-a-planned-failover-with-secondary-runners"></a>

## 使用从站点 Runner 处理计划内故障转移

执行[计划内故障转移](../disaster_recovery/planned_failover.md)时，从站点 Runner 会尝试继续与其本地实例通信。这会导致 Runner 容量下降，可能需要考虑这一点。

<a id="with-location-aware-public-url"></a>

### 使用位置感知公共 URL

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

使用[位置感知 DNS](_index.md#configure-location-aware-dns)时，所有 Runner 都会自动连接到最近的 Geo 站点。

故障转移到新主站点时：

- 当旧主站点仍在 DNS 记录中时，任何先前连接到旧主站点的 Runner 仍会尝试从旧主站点获取作业。如果旧主站点不可达，Runner 会[检测到这一点](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#how-unhealthy_requests_limit-and-unhealthy_interval-works)，并在实例恢复后停止请求一段较长时间。
- 如果您有[多个从节点](../disaster_recovery/_index.md#promoting-secondary-geo-replica-in-multi-secondary-configurations)，在初始故障转移后，剩余的从站点将处于不健康状态，直到它们被[复制](../disaster_recovery/_index.md#step-2-initiate-the-replication-process)到新主站点。连接到这些从站点的 Runner 将无法签入，其健康检查也会触发。
- 如果您从 Geo DNS 条目中移除任何不健康的节点，Runner 会选择下一个最近的实例。根据您的架构，这可能不是您想要的，因为您可能会在站点处于降级状态时使其过载。

要缓解这些问题中的任何一个，您可以[暂停](#pausing-runners)或关闭部分 Runner，直到站点恢复到 100% 运行状态。

如果您不关心这些问题，则无需执行任何操作。

<a id="with-separate-urls"></a>

### 使用单独的 URL

- 如果您要将旧主站点恢复服务，可以暂停旧主站点的 Runner，直到它重新上线。这可以防止健康检查触发。
- 如果旧主站点不再恢复，或者您希望避免 Runner 容量暂时减少，则应重新配置主站点 Runner 以连接到新主站点。
- 如果使用了多个从站点，则在它们被复制到新主站点期间，应[暂停](#pausing-runners)、关闭或重新配置 Runner 以连接到新主站点。

<a id="pausing-runners"></a>

### 暂停 Runner

您必须具有管理员访问权限才能使用以下任何方法：

- 通过 **管理员** 区域：
  1. 在右上角，选择 **管理员**。
  1. 选择 **设置** > **Runner**。
  1. 确定您要暂停的 Runner。
  1. 在每个要暂停的 Runner 旁边，选择 `pause` 按钮。
  1. 故障转移完成后，取消暂停您在上一步中暂停的 Runner。
- 使用 [Runner API](../../../api/runners.md)：
  1. 获取或创建具有管理员访问权限的[个人访问令牌](../../../user/profile/personal_access_tokens.md)。
  1. 获取 Runner 列表。您可以使用 [API](../../../api/runners.md#list-all-runners) 筛选列表。
  1. 确定您要暂停的 Runner，并记下它们的 `id`。
  1. [按照 API 文档](../../../api/runners.md#pause-a-runner)暂停每个 Runner。
  1. 故障转移完成后，使用 API 通过设置 `paused=false` 来取消暂停 Runner 列表。
