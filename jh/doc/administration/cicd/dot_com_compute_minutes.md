---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为 JihuLab.com 配置计算分钟的成本系数设置。
title: JihuLab.com 计算分钟管理
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

JihuLab.com 管理员拥有额外的计算分钟控制选项，超越了[私有化部署](compute_minutes.md)所能提供的功能。

## 设置成本系数

前置条件：

- 你必须是 JihuLab.com 的管理员。

要为 Runner 设置成本系数：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **CI/CD** > **Runner**。
1. 找到你要更新的 Runner，选择 **编辑** ({{< icon name="pencil" >}})。
1. 在 **公共项目计算成本系数** 文本框中，输入公共成本系数。
1. 在 **私有项目计算成本系数** 文本框中，输入私有成本系数。
1. 选择 **保存修改**。

## 降低社区贡献的成本系数

当为某个命名空间启用了 `ci_minimal_cost_factor_for_gitlab_namespaces` 功能标志时，目标为该已启用命名空间项目的派生合并请求流水线将使用降低后的成本系数。
这确保了社区贡献不会消耗过多的计算分钟。

前置条件：

- 你必须能够控制功能标志。
- 你必须拥有想要启用降低后成本系数的命名空间 ID。

要启用命名空间使用降低后的成本系数：

1. 为你想要包含的命名空间 ID [启用功能标志](../feature_flags/_index.md#how-to-enable-and-disable-features-behind-flags) `ci_minimal_cost_factor_for_gitlab_namespaces`。

建议仅在 JihuLab.com 上使用此功能。社区贡献者应使用社区派生进行贡献，以免在运行未针对极狐GitLab 项目发起合并请求的流水线时产生分钟消耗。