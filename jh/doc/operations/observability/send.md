---
stage: none
group: Embody
info: This page is owned by <https://handbook.gitlab.com/handbook/engineering/embody-team/>
description: 监控应用性能并排查性能问题。
ignore_in_report: true
title: 向极狐GitLab 可观测性发送遥测数据
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

配置可观测性后，您就可以开始向极狐GitLab 发送数据了。

要开始使用，请查看 [CI/CD 流水线数据](ci_cd.md)、[发送测试数据](#send-test-data)，或[使用模板](#gitlab-observability-templates)。

<a id="view-observability-data"></a>

## 查看可观测性数据

配置极狐GitLab 可观测性后：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的群组或项目。
1. 在左侧边栏中，选择**观测** > **服务**。
1. 选择您要查看详细信息的服务。

![JihuLab.com 可观测性仪表板](img/gitLab_o11y_gitlab_com_dashboard_v18_1.png "JihuLab.com 可观测性仪表板")

<a id="instrument-your-application"></a>

## 为您的应用添加插桩

要为您的应用添加 OpenTelemetry 插桩：

1. 添加适用于您所用语言的 OpenTelemetry SDK。
1. 配置 OTLP 导出器，使其指向您的极狐GitLab 可观测性实例。
1. 配置推荐的资源属性。
1. 添加 span 和属性，以跟踪操作和元数据。

有关特定语言的指南，请参阅 [OpenTelemetry 文档](https://opentelemetry.io/docs/instrumentation/)。

<a id="recommended-resource-attributes"></a>

### 推荐的资源属性

使用以下资源属性配置您的 OpenTelemetry SDK，以便将
遥测数据关联回您的极狐GitLab 项目和代码。这样可以启用诸如将跟踪与提交关联，以及根据异常自动创建议题等功能。

| 资源属性 | 极狐GitLab CI/CD 变量 | 描述 |
| --- | --- | --- |
| `gitlab.project.id` | `CI_PROJECT_ID` | 将遥测数据关联到极狐GitLab 项目。极狐GitLab Duo 集成所必需。 |
| `gitlab.project.name` | `CI_PROJECT_NAME` | 便于阅读的项目名称，用于在仪表板中显示。 |
| `service.version` | `CI_COMMIT_SHA` | 正在运行的代码的提交 SHA。让您可以将跟踪和错误关联到所部署的确切版本。 |
| `deployment.environment.name` | `CI_ENVIRONMENT_NAME` | 代码运行所在的环境（例如 `production` 或 `staging`）。 |

`service.version` 和 `deployment.environment.name` 属于
[OpenTelemetry 语义约定](https://opentelemetry.io/docs/specs/semconv/resource/)。
`gitlab.*` 属性使用厂商命名空间来表示极狐GitLab 特有的上下文。

这四个变量都[已在极狐GitLab CI/CD 中预定义](../../ci/variables/predefined_variables.md)，当您的应用在流水线中运行时，无需额外配置。对于本地开发，请手动设置这些环境变量，或接受空默认值。

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

对于其他语言，请使用您所用语言的 OpenTelemetry SDK 设置相同的资源属性。属性名称和环境变量在所有语言中都是相同的。

<a id="send-test-data"></a>

## 发送测试数据

您可以使用 OpenTelemetry SDK 发送示例遥测数据，以测试您的极狐GitLab 可观测性安装。此示例使用 Ruby，但 OpenTelemetry 有[适用于多种语言的 SDK](https://opentelemetry.io/docs/instrumentation/)。

<a id="prerequisites"></a>

### 先决条件

- 本地机器上已安装 Ruby。
- 所需的 gem：

  ```shell
  gem install opentelemetry-sdk opentelemetry-exporter-otlp
  ```

<a id="create-a-basic-test-script"></a>

### 创建基本测试脚本

创建一个名为 `test_o11y.rb`的文件，内容如下：

```ruby
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'

OpenTelemetry::SDK.configure do |c|
  # Define service information
  resource = OpenTelemetry::SDK::Resources::Resource.create({
    'service.name' => 'test-service',
    'service.version' => '1.0.0',
    'deployment.environment.name' => 'production',
    'gitlab.project.id' => ENV.fetch('CI_PROJECT_ID', ''),
    'gitlab.project.name' => ENV.fetch('CI_PROJECT_NAME', '')
  })
  c.resource = resource

  # Configure OTLP exporter to send to GitLab Observability
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new(
        endpoint: 'http://[your-o11y-instance-ip]:4318/v1/traces'
      )
    )
  )
end

# Get tracer and create spans
tracer = OpenTelemetry.tracer_provider.tracer('basic-demo')

# Create parent span
tracer.in_span('parent-operation') do |parent|
  parent.set_attribute('custom.attribute', 'test-value')
  puts "Created parent span: #{parent.context.hex_span_id}"

  # Create child span
  tracer.in_span('child-operation') do |child|
    child.set_attribute('custom.child', 'child-value')
    puts "Created child span: #{child.context.hex_span_id}"
    sleep(1)
  end
end

puts "Waiting for export..."
sleep(5)
puts "Done!"
```

将 `[your-o11y-instance-ip]` 替换为您的极狐GitLab 可观测性实例的 IP 地址或主机名。

<a id="run-the-test"></a>

### 运行测试

1. 运行脚本：

   ```shell
   ruby test_o11y.rb
   ```

1. 转到**观测** > **服务**。选择 `test-service` 服务以查看跟踪和 span。

<a id="gitlab-observability-templates"></a>

## GitLab 可观测性模板

GitLab 提供预构建的仪表板模板，帮助您快速上手可观测性。这些模板可在 [GitLab 可观测性模板](https://gitlab.com/gitlab-org/embody-team/experimental-observability/o11y-templates/)处获取。

<a id="available-templates"></a>

### 可用模板

**标准 OpenTelemetry 仪表板**：如果您使用标准 OpenTelemetry 库为应用添加插桩，可以使用这些即插即用的仪表板模板：

- 应用性能监控仪表板
- 服务依赖关系可视化
- 错误率和延迟跟踪

**极狐GitLab 专用仪表板**：当您将极狐GitLab OpenTelemetry 数据发送到您的极狐GitLab 可观测性实例时，可使用这些仪表板获得开箱即用的洞察：

- 极狐GitLab 应用性能指标
- 极狐GitLab 服务健康监控
- 极狐GitLab 专用跟踪分析

**CI/CD 可观测性**：该代码仓库包含一个带有 OpenTelemetry 插桩的极狐GitLab CI/CD 流水线示例，可与极狐GitLab 可观测性 CI/CD 仪表板模板 JSON 文件配合使用。这有助于您监控 CI/CD 流水线性能并识别瓶颈。

<a id="using-the-templates"></a>

### 使用模板

1. 从代码仓库克隆或下载模板。
1. 更新示例应用仪表板中的服务名称，使其与您的服务名称一致。
1. 将 JSON 文件导入您的极狐GitLab 可观测性实例。
1. 按照[为您的应用添加插桩](#instrument-your-application)部分所述，配置您的应用使用标准 OpenTelemetry 库发送遥测数据。
1. 现在，这些仪表板已可在极狐GitLab 可观测性中与您应用的遥测数据一起使用。
