---
stage: none
group: Embody
info: This page is owned by <https://handbook.gitlab.com/handbook/engineering/embody-team/>
description: Monitor application performance and troubleshoot performance issues.
ignore_in_report: true
title: 在 JihuLab.com 上设置可观测性
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Status: Experiment

{{< /details >}}

要在 JihuLab.com 上设置极狐GitLab 可观测性，请为您的群组启用极狐GitLab 可观测性。

前提条件：

- 您必须具有该群组的开发者、维护者或所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并查找您的群组。
1. 在左侧边栏中，选择 **可观测性** > **设置**。
1. 选择 **启用可观测性**。
1. 启用后，您的 OpenTelemetry (OTEL) 端点 URL 将生成并显示在页面上。

复制 OTEL 端点 URL，以便在检测您的应用程序时使用。

## 后续步骤

- [将您的遥测数据发送到极狐GitLab 可观测性](send.md)。
- [显示 CI/CD 流水线遥测](ci_cd.md)。
- [获取故障排除信息](troubleshooting.md)。