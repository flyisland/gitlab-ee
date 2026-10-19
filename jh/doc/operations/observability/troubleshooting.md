---
stage: none
group: Embody
info: This page is owned by <https://handbook.gitlab.com/handbook/engineering/embody-team/>
description: 监控应用性能并对性能问题进行故障排除。
ignore_in_report: true
title: 可观测性故障排除
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

使用可观测性时，您可能会遇到以下问题。

<a id="gitlab-observability-instance-issues"></a>

## 极狐GitLab 可观测性实例问题

检查容器状态：

```shell
docker ps
```

查看容器日志：

```shell
docker logs [container_name]
```

<a id="menu-doesnt-appear"></a>

## 菜单未显示

1. 检查是否为您的群组或个人命名空间配置了可观测性服务 URL：

   ```ruby
   # For a group:
   namespace = Group.find_by_path('your-group-name')

   # For a personal namespace:
   namespace = User.find_by_username('your-username').namespace

   namespace.observability_group_o11y_setting&.o11y_service_url
   ```

1. 确保路由已正确注册：

   ```ruby
   Rails.application.routes.routes.select { |r| r.path.spec.to_s.include?('observability') }.map(&:path)
   ```

<a id="performance-issues"></a>

## 性能问题

如果您遇到 SSH 连接问题或性能不佳：

- 确认实例类型满足最低要求（2 vCPU，8 GB 内存）。
- 考虑调整为更大的实例类型。
- 检查磁盘空间，如有需要则进行扩容。

<a id="telemetry-doesnt-show-up"></a>

## 遥测数据未显示

如果您的遥测数据未出现在极狐GitLab 可观测性中：

1. 确认安全组中已开放端口 4317 和 4318。
1. 使用以下命令测试连接：

   ```shell
   nc -zv [your-o11y-instance-ip] 4317
   nc -zv [your-o11y-instance-ip] 4318
   ```

1. 检查容器日志中是否有任何错误：

   ```shell
   docker logs otel-collector-standard
   docker logs o11y-otel-collector
   docker logs o11y
   ```

1. 尝试使用 HTTP 端点（4318）而非 gRPC（4317）。
1. 在 OpenTelemetry 设置中添加更多调试信息。
