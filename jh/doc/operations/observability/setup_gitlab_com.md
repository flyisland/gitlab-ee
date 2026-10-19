---
stage: none
group: Embody
info: This page is owned by <https://handbook.gitlab.com/handbook/engineering/embody-team/>
description: 监控应用性能并排查性能问题。
ignore_in_report: true
title: 在 JihuLab.com 上设置可观测性
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Status: 实验

{{< /details >}}

要在 JihuLab.com 上设置极狐GitLab 可观测性，请为您的群组或个人命名空间中的项目启用极狐GitLab 可观测性。

{{< tabs >}}

{{< tab title="群组" >}}

先决条件：

- 您必须具有该群组的开发者、维护者或所有者角色。

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**观测** > **设置**。
1. 选择**启用可观测性**。
1. 启用后，系统会生成您的 OpenTelemetry (OTEL) 端点 URL 并显示在页面上。

复制该 OTEL 端点 URL，以便在为应用插桩时使用。

{{< /tab >}}

{{< tab title="个人项目" >}}

先决条件：

- 您必须具有该项目的所有者角色。
- 该项目必须位于您的个人命名空间中，且不属于任何群组。

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**观测** > **设置**。
1. 选择**启用可观测性**。
1. 启用后，系统会生成您的 OpenTelemetry (OTEL) 端点 URL 并显示在页面上。

复制该 OTEL 端点 URL，以便在为应用插桩时使用。

启用可观测性会应用于您个人命名空间中的所有项目。

如果您具有该项目的维护者或开发者角色，则无法自行启用可观测性。
请让项目所有者启用它。

{{< /tab >}}

{{< /tabs >}}

<a id="next-steps"></a>

## 后续步骤

- [将您的遥测数据发送到极狐GitLab 可观测性](send.md)。
- [显示 CI/CD 流水线遥测数据](ci_cd.md)。
- [获取故障排除信息](troubleshooting.md)。
