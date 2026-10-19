---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 性能、健康状态和正常运行时间监控。
title: 监控极狐GitLab
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

探索用于监控极狐GitLab 实例的各项功能：

- [性能监控](performance/_index.md)：极狐GitLab 性能监控
  可用于测量实例的各种统计数据。
- [Prometheus](prometheus/_index.md)：Prometheus 是一款强大的时间序列监控
  服务，为监控极狐GitLab 及其他软件
  产品提供了灵活的平台。
- [GitHub 导入](github_imports.md)：通过多种 Prometheus 指标监控 GitHub
  导入器的健康状态和进度。
- [监控正常运行时间](health_check.md)：使用健康检查端点检查
  服务器状态。
  - [IP 允许名单](ip_allowlist.md)：配置极狐GitLab，以支持在被探测时
    提供健康检查信息的监控端点。
- [`nginx_status`](https://gitlab.cn/docs/omnibus/settings/nginx/#enablingdisabling-nginx_status)：
  监控您的 NGINX 服务器状态。
