---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为 JihuLab.com 上的计算配额配置成本系数。
title: JihuLab.com 的计算配额管理
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

JihuLab.com 管理员对计算配额拥有额外的控制能力，这些控制超出了[极狐GitLab 私有化部署](compute_minutes.md)中提供的范围。

<a id="set-cost-factors"></a>

## 设置成本系数

先决条件：

- 您必须是 JihuLab.com 的管理员。

要为 Runner 设置成本系数：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runner**。
1. 对于要更新的 Runner，选择**编辑**（{{< icon name="pencil" >}}）。
1. 在**公共项目计算成本系数**文本框中，输入公共成本系数。
1. 在**私有项目计算成本系数**文本框中，输入私有成本系数。
1. 选择**保存更改**。

<a id="reduce-cost-factors-for-community-contributions"></a>

## 降低社区贡献的成本系数

当为某个命名空间启用 `ci_minimal_cost_factor_for_gitlab_namespaces` 功能标志后，来自 forks 且目标为已启用命名空间中项目的合并请求流水线将使用降低后的成本系数。这可确保社区贡献不会消耗过多的计算配额。

先决条件：

- 您必须能够控制功能标志。
- 您必须拥有要为其启用降低成本系数的命名空间 ID。

要使某个命名空间能够使用降低后的成本系数：

1. 为您要包含的命名空间 ID [启用功能标志](../feature_flags/_index.md#how-to-enable-and-disable-features-behind-flags) `ci_minimal_cost_factor_for_gitlab_namespaces`。

此功能建议仅在 JihuLab.com 上使用。社区贡献者应使用社区 forks 进行贡献，以避免在运行不属于针对极狐GitLab 项目的合并请求的流水线时累积配额。
