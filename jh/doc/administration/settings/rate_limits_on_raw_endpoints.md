---
stage: Production Engineering
group: Networking and Incident Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 原始端点速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

先决条件：

- 管理员访问权限。

有两个速率限制设置控制对原始端点的访问：

- **每分钟原始 blob 请求速率限制**：限制针对每个项目和文件路径的请求。默认值为每分钟 `300` 个请求。
- **每分钟原始 blob 请求速率限制（未认证）**：限制针对每个项目、跨所有文件路径的未认证请求。默认值为每分钟 `800` 个请求。

要配置这些设置：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **网络**。
1. 展开**性能优化**。

![每分钟原始 blob 请求速率限制设置为 300 和 800。](img/rate_limits_on_raw_endpoints_v18_10.png)

例如，如果基于路径的限制为 `300`，则每分钟对
`https://gitlab.com/gitlab-org/gitlab-foss/raw/master/app/controllers/application_controller.rb`
超过 `300`的请求会被阻止。1 分钟后恢复对该原始文件的访问。

基于路径的限制：

- 针对每个项目和文件路径独立应用。
- 不按 IP 地址或用户应用。
- 默认启用。要禁用，请将该选项设置为 `0`。

未认证的项目范围限制：

- 针对每个项目、跨所有文件路径应用，仅适用于未认证请求。
- 不适用于已认证用户。
- 不按 IP 地址应用。
- 默认启用。要禁用，请将该选项设置为 `0`。

超过速率限制的请求会记录到 `auth.log`中。
