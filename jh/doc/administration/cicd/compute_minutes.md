---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Calculations, quotas, purchase information.
title: 计算分钟管理
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- [重命名] 从 "CI/CD 分钟" 为 "计算配额" 或 "计算分钟" 在极狐GitLab 16.1。

{{< /history >}}

管理员可以限制项目每月在[实例 runner](../../ci/runners/runners_scope.md) 上运行作业的时间。此限制通过[计算分钟配额](../../ci/pipelines/compute_minutes.md) 进行追踪。群组和项目 runner 不受计算配额的限制。

对于私有化部署实例：

- 计算配额默认禁用。
- 如果某个命名空间用尽了其月度配额，管理员可以[分配更多计算分钟](#set-the-compute-quota-for-a-group)。
- 对于所有项目，[成本因子](../../ci/pipelines/compute_minutes.md#compute-usage-calculation) 为 `1`。

在 JihuLab.com 上：

- 要了解适用的配额和成本因子，请参阅[计算分钟](../../ci/pipelines/compute_minutes.md)。
- 要作为极狐GitLab 团队成员管理计算分钟，请参阅[JihuLab.com 的计算分钟管理](dot_com_compute_minutes.md)。

[触发作业](../../ci/yaml/_index.md#trigger) 不会在 runner 上执行，因此即使使用 [`strategy:depend`](../../ci/yaml/_index.md#triggerstrategy) 等待[下游流水线](../../ci/pipelines/downstream_pipelines.md) 的状态，它们也不会消耗计算分钟。触发的下游流水线与其他流水线一样消耗计算分钟。

<a id="set-the-compute-quota-for-all-namespaces"></a>

## 为所有命名空间设置计算配额

默认情况下，极狐GitLab 实例没有计算配额。配额的默认值为 `0`，表示无限制。

前提条件：

- 您必须是极狐GitLab 管理员。

要更改适用于所有命名空间的默认配额：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **持续集成与部署**。
1. 在 **计算配额** 框中，输入限制值。
1. 选择 **保存更改**。

如果已为特定命名空间定义了配额，此值不会更改该配额。

<a id="set-the-compute-quota-for-a-group"></a>

## 设置群组的计算配额

您可以覆盖全局值并为群组设置计算配额。

前提条件：

- 您必须是极狐GitLab 管理员。
- 该群组必须是顶级群组，而不是子群组。

要为群组或命名空间设置计算配额：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **概览** > **群组**。
1. 对于要更新的群组，选择 **编辑**。
1. 在 **计算配额** 框中，输入最大计算分钟数。
1. 选择 **保存更改**。

您也可以使用 [更新群组 API](../../api/groups.md#update-group-attributes) 或 [更新用户 API](../../api/users.md#modify-a-user) 代替。

<a id="reset-compute-usage"></a>

## 重置计算用量

管理员可以重置当前月命名空间的计算用量。

<a id="reset-usage-for-a-personal-namespace"></a>

### 重置个人命名空间的用量

1. 在[**管理员**区域找到用户](../admin_area.md#administering-users)。
1. 选择 **编辑**。
1. 在 **限制** 中，选择 **重置计算用量**。

<a id="reset-usage-for-a-group-namespace"></a>

### 重置群组命名空间的用量

1. 在[**管理员**区域找到群组](../admin_area.md#administering-groups)。
1. 选择 **编辑**。
1. 在 **权限和群组功能** 中，选择 **重置计算用量**。