---
stage: none
group: Embody
info: This page is owned by <https://handbook.gitlab.com/handbook/engineering/embody-team/>
description: Monitor application performance and troubleshoot performance issues.
ignore_in_report: true
title: 发送遥测数据到极狐GitLab 可观测性
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Experiment

{{< /details >}}

配置可观测性后，您可以开始向极狐GitLab 发送数据。

要开始使用，请查看 [CI/CD 流水线数据](ci_cd.md)、[发送测试数据](#send-test-data)或[使用模板](#gitlab-observability-templates)。

<a id="view-observability-data"></a>

## 查看可观测性数据

配置极狐GitLab 可观测性后：

1. 在顶部栏中，选择 **搜索或跳转到**，找到您的群组。
1. 在左侧边栏中，选择 **可观测性** > **服务**。
1. 选择要查看详细信息的服务。

![JihuLab.com 可观测性仪表板](img/gitLab_o11y_gitlab_com_dashboard_v18_1.png "JihuLab.com 可观测性仪表板")

<a id="instrument-your-application"></a>

## 检测您的应用程序

要向您的应用程序添加 OpenTelemetry 监测：

1. 添加适用于您语言的 OpenTelemetry SDK。
1. 配置 OTLP 导出器以指向您的极狐GitLab 可观测性实例。
1. 配置推荐的资源属性。
1. 添加跨度和属性来跟踪操作和元数据。

请参阅 [OpenTelemetry 文档](https://opentelemetry.io/docs/instrumentation/)，了解特定语言的指南。

<a id="recommended-resource-attributes"></a>

### 推荐的资源属性

在 OpenTelemetry SDK 中配置这些资源属性，将遥测数据链接回您的极狐GitLab 项目和代码。这可以启用诸如将追踪与提交关联，以及从异常自动创建议题等功能。

| 资源属性 | 极狐GitLab CI/CD 变量 | 描述 |
| --- | --- | --- |
| `gitlab.project.id` | `CI_PROJECT_ID` | 将遥测数据链接到极狐GitLab 项目。极狐GitLab Duo 集成所必需的。 |
| `gitlab.project.name` | `CI_PROJECT_NAME` | 用于在仪表板中显示的可读项目名称。 |
| `service.version` | `CI_COMMIT_SHA` | 运行代码的提交 SHA。可让您将追踪和错误关联到所部署的确切版本。 |
| `deployment.environment.name` | `CI_ENVIRONMENT_NAME` | 代码运行所在的环境（例如，`production` 或 `staging`）。 |

`service.version` 和 `deployment.environment.name` 是 [OpenTelemetry 语义约定](https://opentelemetry.io/docs/specs/semconv/resource/)。`gitlab.*` 属性使用了供应商命名空间，用于极狐GitLab 特定的上下文。

这四个变量都在[极狐GitLab CI/CD 中进行了预定义](../../ci/variables/predefined_variables.md)，当您的应用程序在流水线中运行时，无需额外配置。对于本地开发，请手动设置这些环境变量，或接受空的默认值。

以下 Ruby 示例展示了如何配置这些属性：

```ruby
OpenTelemetry::SDK.configure do |c|
  c.resource = OpenTelemetry::SDK::Resources::Resource.create(
    'gitlab.project.id'           => ENV.fetch('CI_PROJECT_ID', ''),
    'gitlab.project.name'         => ENV.fetch('CI_PROJECT_NAME', ''),
    'service.version'             => ENV.fetch('CI_COMMIT_SHA', ''),
    'deployment.environment.name' => ENV.fetch('CI_ENVIRONMENT_NAME', '')
  )

  c.use_all
end
```

对于其他语言，请使用您语言的 OpenTelemetry SDK 设置相同的资源属性。属性名称和环境变量在各个语言中都是相同的。

<a id="send-test-data"></a>

## 发送测试数据

您可以使用 OpenTelemetry SDK 发送示例遥测数据来测试极狐GitLab 可观测性安装。此示例使用 Ruby，但 OpenTelemetry 提供了[多种语言的 SDK](https://opentelemetry.io/docs/instrumentation/)。

<a id="prerequisites"></a>

### 前提条件

- 本地机器上安装了 Ruby。
- 所需 gem：

  ```shell
  gem install opentelemetry-sdk opentelemetry-exporter-otlp
  ```

<a id="create-a-basic-test-script"></a>

### 创建基本的测试脚本

创建名为 `test_o11y.rb` 的文件，内容如下：

```ruby
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'

OpenTelemetry::SDK.configure do |c|
  # 定义服务信息
  resource = OpenTelemetry::SDK::Resources::Resource.create({
    'service.name' => 'test-service',
    'service.version' => '1.0.0',
    'deployment.environment.name' => 'production',
    'gitlab.project.id' => ENV.fetch('CI_PROJECT_ID', ''),
    'gitlab.project.name' => ENV.fetch('CI_PROJECT_NAME', '')
  })
  c.resource = resource

  # 配置 OTLP 导出器以发送到极狐GitLab 可观测性
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new(
        endpoint: 'http://[your-o11y-instance-ip]:4318/v1/traces'
      )
    )
  )
end

# 获取追踪器并创建跨度
tracer = OpenTelemetry.tracer_provider.tracer('basic-demo')

# 创建父跨度
tracer.in_span('parent-operation') do |parent|
  parent.set_attribute('custom.attribute', 'test-value')
  puts "已创建父跨度：#{parent.context.hex_span_id}"

  # 创建子跨度
  tracer.in_span('child-operation') do |child|
    child.set_attribute('custom.child', 'child-value')
    puts "已创建子跨度：#{child.context.hex_span_id}"
    sleep(1)
  end
end

puts "等待导出..."
sleep(5)
puts "完成！"
```

将 `[your-o11y-instance-ip]` 替换为您的极狐GitLab 可观测性实例的 IP 地址或主机名。

<a id="run-the-test"></a>

### 运行测试

1. 运行脚本：

   ```shell
   ruby test_o11y.rb
   ```

1. 转到 **可观测性** > **服务**。选择 `test-service` 服务即可查看追踪和跨度。

<a id="gitlab-observability-templates"></a>

## 极狐GitLab 可观测性模板

极狐GitLab 提供了预构建的仪表板模板，帮助您快速开始使用可观测性。这些模板位于 [极狐GitLab 可观测性模板](https://jihulab.com/gitlab-org/embody-team/experimental-observability/o11y-templates/)。

<a id="available-templates"></a>

### 可用模板

**标准 OpenTelemetry 仪表板**：如果您使用标准 OpenTelemetry 库检测了您的应用程序，您可以使用这些即插即用的仪表板模板：

- 应用程序性能监控仪表板
- 服务依赖可视化
- 错误率和延迟追踪

**极狐GitLab 特定仪表板**：当您向极狐GitLab 可观测性实例发送极狐GitLab OpenTelemetry 数据时，使用这些仪表板即可获得开箱即用的洞察：

- 极狐GitLab 应用程序性能指标
- 极狐GitLab 服务健康监控
- 极狐GitLab 特定的追踪分析

**CI/CD 可观测性**：该仓库包含一个示例极狐GitLab CI/CD 流水线，其中包含 OpenTelemetry 监测，可与极狐GitLab 可观测性 CI/CD 仪表板模板 JSON 文件配合使用。这有助于您监控 CI/CD 流水线性能并识别瓶颈。

<a id="using-the-templates"></a>

### 使用模板

1. 从仓库克隆或下载模板。
1. 在示例应用程序仪表板中更新服务名称，使其与您的服务名称匹配。
1. 将 JSON 文件导入到极狐GitLab 可观测性实例。
1. 按照[检测您的应用程序](#instrument-your-application)部分所述，配置您的应用程序以使用标准 OpenTelemetry 库发送遥测数据。
1. 现在，这些仪表板便可在极狐GitLab 可观测性中使用您应用程序的遥测数据。

