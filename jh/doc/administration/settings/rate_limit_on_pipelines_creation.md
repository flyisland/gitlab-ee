---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 流水线创建速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.0 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/362475)，[带有功能标志](../feature_flags/_index.md)，名称为 `ci_enforce_throttle_pipelines_creation`。默认禁用。在 JihuLab.com 上已启用。
- 在 18.3 中[默认启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/196545)。

{{< /history >}}

你可以设置限制，使用户和进程每分钟请求的流水线数量不能超过设定值。这些限制有助于节省资源并提高稳定性。

极狐GitLab 对流水线创建实施两种类型的速率限制：

- **每个项目、提交和用户**：限制为同一项目、提交 SHA 和用户组合创建的流水线数量。默认禁用。
- **每个用户**：限制单个用户在所有项目中创建的流水线总数。默认禁用。

例如，如果你设置了每个用户 `100` 次的限制，而一个用户在一分钟内跨不同项目向[触发器 API](../../ci/triggers/_index.md) 发送了 `101` 次流水线创建请求，那么第 101 次请求会被阻止。一分钟后，端点访问会再次被允许。

这些限制并非基于 IP 地址实施。

超出限制的请求会记录在 `application_json.log` 文件中。

## 设置流水线请求限制

先决条件：

- 管理员访问权限。

限制流水线请求数量的步骤：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **流水线速率限制**。
1. 在 **每个项目、用户和提交的最大每分钟请求数** 下方，输入一个大于 `0` 的值，以限制同一项目、提交和用户组合的流水线请求。
1. 在 **每个用户的最大每分钟请求数** 下方，输入一个大于 `0` 的值，以限制每个用户创建的流水线总数。设置为 0 表示每分钟请求数不受限制。
1. 选择 **保存更改**。

## 限制如何协同工作

两种速率限制是独立评估的：

- 用户在某个项目中为同一提交 SHA 创建多个流水线时，受 **每个项目、用户和提交** 的限制。
- 用户跨不同项目或提交创建流水线时，受 **每个用户** 的限制。
- 如果超出任一限制，流水线创建请求都会被阻止。