---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 图表代理
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.10 中引入。

{{< /history >}}

使用图表代理以防止浏览器将图表内容发送到如 Kroki 或 PlantUML 等外部服务。极狐GitLab 代表用户获取图表，并通过一次性 URL 提供，该 URL 在使用后过期。

<a id="turn-on-the-diagram-proxy"></a>

开启图表代理

您可以分别针对 [Kroki](kroki.md) 和 [PlantUML](plantuml.md) 集成开启图表代理。您可以为 Kroki、PlantUML 或两者同时开启图表代理。

先决条件：

- 管理员访问权限。

要开启图表代理：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中选择 **设置** > **通用**。
1. 展开 **Kroki** 或 **PlantUML**。
1. 选中 **通过极狐GitLab 代理 Kroki 图表** 或 **通过极狐GitLab 代理 PlantUML 图表** 复选框。
1. 选择 **保存更改**。

