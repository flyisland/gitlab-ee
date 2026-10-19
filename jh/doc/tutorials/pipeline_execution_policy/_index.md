---
stage: Security Risk Management
group: Security Policies
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: "教程：设置流水线执行策略"
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本教程介绍如何使用 `inject_policy` 策略创建并配置[流水线执行策略](../../user/application_security/policies/pipeline_execution_policies.md)。您可以使用这些策略，确保必需的流水线始终在已关联该策略的项目中运行。

在本教程中，您可以创建流水线执行策略，将其关联到测试项目，并验证流水线是否执行。

要设置流水线执行策略，您需要：

1. [创建测试项目](#create-a-test-project)。
1. [创建 CI/CD 配置文件](#create-a-cicd-configuration-file)。
1. [添加流水线执行策略](#add-a-pipeline-execution-policy)。
1. [测试流水线执行策略](#test-the-pipeline-execution-policy)。

<a id="before-you-begin"></a>

## 开始之前

要完成本教程，您需要：

- 在现有群组中创建项目的权限。
- 创建和关联安全策略的权限。

<a id="create-a-test-project"></a>

## 创建测试项目

首先，创建一个测试项目，以便将流水线执行策略应用到该项目：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**新建项目**。
1. 选择**创建空白项目**。
1. 填写字段。
   - **项目名称**：`my-pipeline-execution-policy`。
   - 选中**启用静态应用程序安全测试（SAST）**复选框。
1. 选择**创建项目**。

<a id="create-a-cicd-configuration-file"></a>

## 创建 CI/CD 配置文件

接下来，创建您希望流水线执行策略强制执行的 CI/CD 配置文件：

1. 在左侧边栏中，选择**代码** > **代码仓库**。
1. 从**添加**（+）下拉列表中，选择**新建文件**。
1. 在**文件名**字段中，输入 `pipeline-config.yml`。
1. 在文件内容中，复制以下内容：

   ```yaml
   ---
   # This file defines the CI/CD jobs that will be
   # enforced by the pipeline execution policy
   enforced-security-scan:
     stage: .pipeline-policy-pre
     script:
       - echo "Running enforced security scan from pipeline execution policy"
       - echo "This job cannot be skipped by developers"
       - echo "Checking for security vulnerabilities..."
       - echo "Security scan completed successfully"
     rules:
       - when: always

   enforced-test-job:
     stage: test
     script:
       - echo "Running enforced test job in test stage"
       - echo "Creating test stage if it doesn't exist"
       - echo "Performing mandatory testing requirements..."
       - echo "Enforced tests completed successfully"
     rules:
       - when: always

   enforced-compliance-check:
     stage: .pipeline-policy-post
     script:
       - echo "Running enforced compliance check"
       - echo "Verifying pipeline compliance requirements"
       - echo "Compliance check passed"
     rules:
       - when: always
   ```

1. 在**提交信息**字段中，输入 `Add pipeline execution policy configuration`。
1. 选择**提交更改**。

<a id="add-a-pipeline-execution-policy"></a>

## 添加流水线执行策略

接下来，将流水线执行策略添加到您的测试项目：

1. 选择**安全** > **策略**。
1. 选择**新建策略**。
1. 在**流水线执行策略**中，选择**选择策略**。
1. 填写字段。
   - **名称**：`Enforce Security and Compliance Jobs`
   - **描述**：`Enforces required security and compliance jobs across all pipelines`
   - **策略状态**：**已启用**

1. 将**操作**设置为以下内容：

   ![流水线执行策略操作](img/pipeline_execution_policy_actions_v18_7.png)
1. 选择**使用合并请求配置**。
1. 在合并请求的**变更**选项卡中查看生成的策略 YAML。该策略应类似于：

   ```yaml
   ---
   pipeline_execution_policy:
   - name: Enforce Security and Compliance Jobs
     description: Enforces required security and compliance jobs across all pipelines
     enabled: true
     pipeline_config_strategy: inject_policy
     content:
       include:
       - project: [group]/my-pipeline-execution-policy
         file: pipeline-config.yml
     skip_ci:
       - allowed: false
   ```

1. 转到**概览**选项卡并选择**合并**。此步骤会创建一个名为 `My Pipeline Execution Policy - Security Policy Project`的新项目。安全策略项目用于存储安全策略，以便同一策略可以在多个项目中强制执行。
1. 在顶部栏中，选择**搜索或跳转到**，然后找到 `my-pipeline-execution-policy` 项目。
1. 选择**安全** > **策略**。

   您可以看到前面步骤中添加的策略列表。

<a id="test-the-pipeline-execution-policy"></a>

## 测试流水线执行策略

现在，通过创建合并请求来测试您的流水线执行策略：

1. 在左侧边栏中，选择**代码** > **代码仓库**。
1. 从**添加**（+）下拉列表中，选择**新建文件**。
1. 在**文件名**字段中，输入 `test-file.txt`。
1. 在文件内容中，添加：

   ```plaintext
   This is a test file to trigger the pipeline execution policy.
   ```

1. 在**提交信息**字段中，输入 `Add test file to trigger pipeline`。
1. 在**目标分支**字段中，输入 `test-policy-branch`。
1. 选择**提交更改**。
1. 当合并请求页面打开时，选择**创建合并请求**。

   等待流水线完成。这可能需要几分钟。
1. 在合并请求中，选择**流水线**选项卡，然后选择所创建的流水线。

   您应该会看到强制执行的作业正在运行：
   - `enforced-security-scan` 位于 `.pipeline-policy-pre` 阶段（最先运行）
   - `enforced-test-job` 位于 `test` 阶段（由策略注入）
   - `enforced-compliance-check` 位于 `.pipeline-policy-post` 阶段（最后运行）

1. 选择 `enforced-security-scan` 作业以查看其日志，并确认它按策略中的定义执行了安全扫描。

流水线执行策略成功强制执行了必需的作业，确保无论开发人员在其项目的 `.gitlab-ci.yml` 文件中包含什么内容，这些作业都会运行。

现在您已经了解如何设置和使用流水线执行策略，以在您组织内的各个项目中强制使用必需的 CI/CD 作业！

<a id="next-steps"></a>

## 后续步骤

- 详细了解[流水线执行策略配置策略](../../user/application_security/policies/pipeline_execution_policies.md#pipeline-configuration-strategies)。
- 探索[高级流水线执行策略示例](../../user/application_security/policies/pipeline_execution_policies.md#examples)。
