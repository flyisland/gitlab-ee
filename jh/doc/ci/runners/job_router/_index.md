---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 作业路由器
description: 通过作业路由器路由 CI/CD 作业，实现高级作业编排。
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署
- Status: 实验性

{{< /details >}}

> [!flag]
> 此功能由功能标志控制。
> 有关更多信息，请参见历史记录。
> 此功能可供测试，但尚未准备用于生产环境。

{{< history >}}

- 在极狐GitLab 18.7 中引入，使用功能标志，名为 `job_router` 和 `job_router_instance_runners`。默认禁用。
- 在极狐GitLab 18.9 中引入，使用功能标志，名为 `job_router_admission_control`。默认禁用。

{{< /history >}}

作业路由器是极狐GitLab Relay (KAS) 的一个组件，为极狐GitLab CI/CD 提供高级作业编排功能。与 Runner 直接轮询极狐GitLab 获取作业的方式不同，Runner 连接到作业路由器，由作业路由器管理作业分配并提供准入控制等功能。

<a id="architecture"></a>

## 架构

```plaintext
极狐GitLab 实例 → 作业路由器 (KAS) → Runner
                        ↓
              Runner 控制器（可选）
```

作业路由器：
- 接收来自 Runner 的作业请求
- 向 Runner 返回要执行的作业
- 可选择性地咨询 Runner 控制器以进行准入决策

<a id="prerequisites"></a>

## 先决条件

要使用作业路由器，您必须具备：

- 设置了以下功能标志为 `true` 的极狐GitLab 实例：
  - `job_router`：用于群组和项目 Runner
  - `job_router_instance_runners`：用于实例 Runner
  - `job_router_admission_control`：用于准入控制（可选）
- 极狐GitLab Runner 18.9 或更高版本，且 `FF_USE_JOB_ROUTER` 环境变量设置为 `true`。

<a id="discover-job-router-information"></a>

## 发现作业路由器信息

Runner 可以通过[作业路由器发现 API](../../../api/runners.md#discover-job-router-information) 发现作业路由器 URL。

<a id="runner-controllers"></a>

## Runner 控制器

Runner 控制器为通过作业路由器路由的作业启用准入控制。
更多信息，请参见 [runner 控制器](runner_controllers.md)。