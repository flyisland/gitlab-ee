---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
description: Guide for using GitLab Duo Workflow to automatically apply Java coding style guidelines to projects, with configuration, execution, and sample use cases.
title: Duo Workflow 应用编码风格的用例
---

{{< details >}}

- Tier: 旗舰版，包含极狐GitLab Duo Workflow
- Offering: JihuLab.com
- Status: 实验性

{{< /details >}}

<a id="getting-started"></a>

## 入门

<a id="download-the-solution-component"></a>

### 下载解决方案组件

1. 从你的客户团队获取邀请码。
1. 使用邀请码从[解决方案组件商店](https://cloud.gitlab-accelerator-marketplace.com)下载解决方案组件。

<a id="duo-workflow-use-case-improve-java-application-with-style-guide"></a>

## Duo Workflow 用例：使用风格指南改进 Java 应用程序

本文档描述了带有提示和上下文库的极狐GitLab Duo Workflow 解决方案。该解决方案旨在基于定义的风格改进应用程序编码。

此解决方案将极狐GitLab 议题作为提示，将风格指南作为上下文，旨在使用极狐GitLab Duo Workflow 自动将 Java 风格指南应用于代码库。提示和上下文库使 Duo Workflow 能够：

1. 访问存储在极狐GitLab 仓库中的集中式风格指南内容
1. 理解特定领域的编码标准
1. 在保持功能的同时对 Java 代码应用一致的格式

有关极狐GitLab Duo Workflow 的详细信息，请查阅[此文档](../../../user/duo_agent_platform/_index.md)。

<a id="key-benefits"></a>

### 主要优势

- **强制统一风格**，覆盖所有 Java 代码库
- **自动应用风格**，无需人工操作
- **保持代码功能**，同时提高可读性
- **减少代码审查时间**，避免在此类问题上耗费精力
- **作为学习工具**，帮助开发者理解风格指南

<a id="sample-result"></a>

### 示例结果

配置正确时，该提示将把你的代码转换为符合企业标准，类似于以下 diff 所示的转换：

![Duo Workflow 视图，显示指令、任务分析和解决步骤](img/duoworkflow-style_output_v17_10.png)

![经 Duo Workflow 风格指南转换后，具有一致格式的更新代码片段](img/duoworkflow_style_code_transform_v17_10.png)

<a id="configure-the-solution-prompt-and-context-library"></a>

## 配置解决方案提示和上下文库

<a id="basic-setup"></a>

### 基本设置

要运行智能工作流来审查并为你的应用程序应用风格，你需要设置此用例的提示和上下文库。

1. **设置提示和上下文库**：克隆 `Enterprise Code Quality Standards` 项目
1. **创建极狐GitLab 议题** `Review and Apply Style`，其内容来自库文件 `.gitlab/workflows/java-style-workflow.md` 中的提示内容
1. **在该议题** `Review and Apply Style` 中，根据[配置指南](#configuration-guide)中的详细信息，配置工作流变量
1. **在极狐GitLab 中**，使用项目 `Enterprise Code Quality Standards`，输入一个简单的 [workflow prompt](#example-duo-workflow-prompt) 启动 Duo Workflow
1. **使用 Duo Workflow**：审查提议的计划和自动化任务，如有需要，可向工作流提供进一步输入
1. **审查并提交**已应用风格更改的代码到你的仓库

<a id="example-duo-workflow-prompt"></a>

### Duo Workflow 提示示例

```yaml
按照议题 <issue_reference_id> 中的指令操作文件 <path/file_name.java>。确保访问议题中提到的任何议题或极狐GitLab 项目，以获取所有必要的信息。
```

这一简单的提示之所以强大，是因为它指示 Duo Workflow：

1. 读取特定议题 ID 中的详细需求
1. 访问被引用的风格指南仓库
1. 将指南应用于指定文件
1. 遵循议题中的所有指令

<a id="configuration-guide"></a>

## 配置指南

该提示定义在解决方案包中的 `.gitlab/workflows/java-style-workflow.md` 文件中。该文件作为你的模板，用于创建极狐GitLab 议题，指示工作流代理制定计划，自动对应用程序进行风格指南审查并应用更改。

在 `.gitlab/workflows/java-style-workflow.md` 的第一部分中，定义了需要为提示配置的变量。

<a id="variable-definition"></a>

### 变量定义

变量直接定义在 `.gitlab/workflows/java-style-workflow.md` 文件中。该文件作为你的模板，用于创建极狐GitLab 议题，指示 AI 助手。你需要在创建包含其内容的新议题之前，修改此文件中的变量。

<a id="1-style-guide-repository-as-the-context"></a>

#### 1. 作为上下文的风格指南仓库

提示必须配置为指向你组织的风格指南仓库。在 `java-style-prompt.md` 文件中，替换以下变量：

- `{{GITLAB_INSTANCE}}`：你的极狐GitLab 实例 URL（例如 `https://gitlab.example.com`）
- `{{STYLE_GUIDE_PROJECT_ID}}`：包含 Java 风格指南的极狐GitLab 项目 ID
- `{{STYLE_GUIDE_PROJECT_NAME}}`：风格指南项目的显示名称
- `{{STYLE_GUIDE_BRANCH}}`：包含最新风格指南的分支（默认：main）
- `{{STYLE_GUIDE_PATH}}`：仓库中风格指南文档的路径

示例：

```yaml
GITLAB_INSTANCE=https://gitlab.example.com
STYLE_GUIDE_PROJECT_ID=gl-demo-ultimate-zhenderson/sandbox/enterprise-java-standards
STYLE_GUIDE_PROJECT_NAME=Enterprise Java Standards
STYLE_GUIDE_BRANCH=main
STYLE_GUIDE_PATH=coding-style/java/guidelines/java-coding-standards.md
```

<a id="2-target-repository-to-apply-style-improvement"></a>

#### 2. 应用风格改进的目标仓库

在同一 `java-style-prompt.md` 文件中，配置要应用风格指南的文件：

- `{{TARGET_PROJECT_ID}}`：你的 Java 项目的极狐GitLab ID
- `{{TARGET_FILES}}`：要针对的特定文件或模式（例如 `src/main/java/**/*.java`）

示例：

```yaml
TARGET_PROJECT_ID=royal-reserve-bank
TARGET_FILES=asset-management-api/src/main/java/com/royal/reserve/bank/asset/management/api/service/AssetManagementService.java
```

<a id="important-notes-about-ai-generated-code"></a>

### 关于 AI 生成的代码的重要说明

**⚠️ 重要免责声明**：

极狐GitLab for VS Code 使用非确定性的 Agentic AI，这意味着：

- 即使使用相同的输入，每次运行的结果也可能不同
- AI 助手对风格指南的理解和应用每次可能略有差异
- 本文档中提供的示例仅为说明，你的实际结果可能有所不同

**使用 AI 生成的代码更改的最佳实践**：

1. **始终审查生成的代码**：切勿在未经充分人工审查的情况下合并 AI 生成的更改
1. **遵循适当的合并请求流程**：使用标准代码审查程序
1. **运行所有测试**：确保所有单元和集成测试在合并前通过
1. **验证风格合规性**：确认更改符合你的风格指南预期
1. **增量式应用**：考虑最初对较小的文件集应用风格更改

请记住，此工具旨在辅助开发者，而不是取代代码审查过程中的人类判断。

<a id="step-by-step-implementation"></a>

## 逐步实现

<a id="create-a-style-guide-issue"></a>

### 创建风格指南议题

- 在你的项目中创建一个新议题（例如 Issue #3）
- 包含关于要应用的风格指南的详细信息
- 如果适用，引用外部风格指南仓库
- 指定如下要求：

  ```yaml
  任务：代码风格更新
  描述：将企业标准 Java 风格指南应用于代码库。
  参考风格指南：Enterprise Java Style Guidelines (https://gitlab.com/gl-demo-ultimate-zhenderson/sandbox/enterprise-java-standards/-/blob/main/coding-style/java/guidelines/java-coding-standards.md)
  约束条件：
  - 遵守企业标准 Java 风格指南
  - 保持功能不变
  - 实施自动化风格检查
  ```

<a id="configure-the-prompt"></a>

### 配置提示

- 从 `java-style-prompt.md` 复制模板
- 填写所有配置变量
- 添加任何项目特定的例外或要求

<a id="review-and-implement"></a>

### 审查与实施

- 审查建议的更改
- 在你的代码库中实施更改
- 运行测试以确保功能得以保留
- 通过极狐GitLab 界面监控任务进展

<a id="sample-workflow-execution"></a>

## 示例工作流执行

当正确配置后，Duo Workflow 将执行一个详细的计划来应用风格指南。以下是工作流执行情况的示例：

<a id="sample-workflow-plan"></a>

### 示例工作流计划

AI 助手首先创建一个包含特定工具的执行计划：

1. 使用 `run_read_only_git_command` 从 Enterprise Java Standards 项目（`https://gitlab.com/gl-demo-ultimate-zhenderson/sandbox/enterprise-java-standards.git`）中获取 `coding-style/java/guidelines/java-coding-standards.md` 文件，以访问 Java 风格指南内容，支持工具：`run_read_only_git_command`
1. 使用 `read_file` 工具读取并分析 `AssetManagementService.java` 的当前内容，以了解其结构并识别需要风格更新的区域，支持工具：`read_file`
1. 使用 `find_files` 在项目中搜索类似文件，以确保在相关的服务类之间保持一致的风格应用，支持工具：`find_files`
1. 使用 `edit_file` 工具编辑 `AssetManagementService.java` 以应用风格指南，重点关注：
   - 包和导入组织
   - 类和方法文档
   - 代码缩进和间距
   - 注解位置
   - 方法参数格式，支持工具：`edit_file`
1. 使用 `grep_files` 检查整个代码库中的注解模式，确保所有 Lombok 注解（@Service, @RequiredArgsConstructor, @Slf4j）按照风格指南正确格式化，支持工具：`grep_files`

<a id="sample-analysis-output"></a>

### 示例分析输出

助理随后分析文件和要求：

我已经分析了议题 #3 和 `AssetManagementService.java` 文件。以下是我的发现：

1. 议题 #3 是关于将企业标准 Java 风格指南应用于 Royal Banking 代码库。
1. `AssetManagementService.java` 文件位于 `asset-management-api` 模块中。
1. 风格指南存储在一个单独的极狐GitLab 项目中，路径为 `gl-demo-ultimate-zhenderson/sandbox/enterprise-java-standards`。
1. 当前的 `AssetManagementService.java` 文件包含：
   1. 包和导入语句
   1. 带有 Spring 注解的服务类
   1. 一个用于检查资产可用性的公共方法
   1. Lombok 注解
   1. Javadoc 注释

该议题要求：

1. 按照企业标准 Java 风格指南进行格式化
1. 实施自动化风格检查
1. 保持现有功能
1. 确保所有测试在风格更新后通过

要开始实施，你需要：

1. 从 Enterprise Java Standards 项目访问 Java 风格指南
1. 将风格指南应用于 AssetManagementService.java
1. 验证更改不会影响功能
1. 确保所有测试在更新后通过

<a id="sample-implementation-result"></a>

### 示例实施结果

执行后，助手提供转换后的代码，并解释所做的更改，包括：

1. 已应用的风格指南摘要
1. 具有适当格式的转换后代码
1. 关键风格更改的解释
1. 自动化风格执行建议

典型更改包括：

- 标准化的导入顺序
- 运算符周围的一致间距
- 正确的 Javadoc 格式
- 标准化的方法参数对齐
- 一致的花括号放置

所有这些，都确保代码保持原有功能。

<a id="sample-tutorial-use-case-royal-reserve-bank-java-project"></a>

## 示例教程用例：Royal Reserve Bank Java 项目

此仓库包含一个银行教程示例，用于演示风格指南应用在真实场景中的运作方式。Royal Reserve Bank 项目遵循微服务架构，包含多个 Java 服务：

- Account API
- Asset Management API
- Transaction API
- Notification API
- API Gateway
- Config Server
- Discovery Server

示例将企业风格指南应用于 `AssetManagementService.java` 类，演示了以下方面的正确格式：

1. 导入组织
1. Javadoc 标准
1. 方法参数对齐
1. 变量命名约定
1. 异常处理模式

<a id="customizing-for-your-organization"></a>

## 为您的组织进行定制

要使此提示适合你组织的需求，请执行以下操作：

1. **替换风格指南**
   - 指向你组织的风格指南仓库
   - 引用你特定的风格指南文档

1. **选择目标文件**
   - 选择要应用风格指南的特定文件或模式
   - 优先处理高可见性的代码文件用于初始实施

1. **额外验证**
   - 添加自定义验证要求
   - 指明对标准风格规则的任何例外情况

1. **与 CI/CD 集成**
   - 配置提示，使其作为 CI/CD 流水线的一部分运行
   - 设置自动化风格检查，确保持续合规

<a id="troubleshooting"></a>

## 故障排查

常见问题及其解决方案：

- **访问被拒绝**：确保 AI Agent 有适当的权限访问两个仓库
- **找不到风格指南**：验证风格指南的路径和分支是否正确
- **功能变化**：应用风格更改后运行所有测试以验证功能

<a id="contributing"></a>

## 贡献

欢迎通过以下方式增强此提示：

- 添加更多风格规则解释
- 为不同的 Java 项目类型创建示例
- 改进验证工作流
- 添加与其他静态分析工具的集成