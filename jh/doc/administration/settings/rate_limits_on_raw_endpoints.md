---
stage: Production Engineering
group: Networking and Incident Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 原始端点的速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 每分钟原始 blob 请求速率限制（未认证）在极狐GitLab 18.10 中引入。

{{< /history >}}

先决条件：

- 管理员访问权限。

两种速率限制设置控制对原始端点的访问：

- **每分钟原始 blob 请求速率限制**：限制每个项目及文件路径的请求。默认为每分钟 `300` 个请求。
- **每分钟原始 blob 请求速率限制（未认证）**：限制每个项目跨所有文件路径的未认证请求。默认为每分钟 `800` 个请求。

要配置这些设置：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **性能优化**。

![每分钟原始 blob 请求速率限制设置为 300 和 800。](img/rate_limits_on_raw_endpoints_v18_10.png)

例如，如果基于路径的限制是 `300`，那么每分钟超过 `300` 个请求到
`https://jihulab.com/gitlab-cn/gitlab-foss/raw/master/app/controllers/application_controller.rb`
会被阻止。原始文件的访问在 1 分钟后被释放。

基于路径的限制：

- 为每个项目及文件路径独立应用。
- 不按 IP 地址或用户应用。
- 默认启用。要禁用，将该选项设为 `0`。

未经身份验证的项目范围限制：

- 为每个项目，跨所有文件路径，仅针对未经身份验证的请求应用。
- 不应用于已认证用户。
- 不按 IP 地址应用。
- 默认启用。要禁用，将该选项设为 `0`。

超出速率限制的请求会记录在 `auth.log` 中。