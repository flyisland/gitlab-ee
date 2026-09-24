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

本教程将向你展示如何创建和配置一个采用 `inject_policy` 策略的[流水线执行策略](../../user/application_security/policies/pipeline_execution_policies.md)。你可以使用这些策略来确保关联到该策略的项目始终运行所需的流水线。

在本教程中，你将创建一个流水线执行策略，将其关联到一个测试项目，并验证该流水线是否执行。

要设置流水线执行策略，你需要：

1. [创建测试项目](#create-a-test-project)。
1. [创建 CI/CD 配置文件](#create-a-cicd-configuration-file)。
1. [添加流水线执行策略](#add-a-pipeline-execution-policy)。
1. [测试流水线执行策略](#test-the-pipeline-execution-policy)。

## 准备工作

要完成本教程，你需要具备：

- 在现有群组中创建项目的权限。
- 创建和关联安全策略的权限。

## 创建测试项目

首先，创建一个测试项目来应用你的流水线执行策略：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **新建项目**。
1. 选择 **创建空白项目**。
1. 填写字段。
   - **项目名称**：`my-pipeline-execution-policy`。
   - 选中 **启用静态应用安全测试 (SAST)** 复选框。
1. 选择 **创建项目**。

## 创建 CI/CD 配置文件

接下来，创建你希望流水线执行策略强制执行的 CI/CD 配置文件：

1. 在左侧边栏中，选择 **代码** > **代码仓**。
1. 从 **添加** (+) 下拉列表中，选择 **新建文件**。
1. 在 **文件名** 字段中，输入 `pipeline-config.yml`。
1. 在文件内容中，复制以下内容：

   ```yaml
   ---
   # 此文件定义了将由流水线执行策略强制执行的 CI/CD 作业
   enforced-security-scan:
     stage: .pipeline-policy-pre
     script:
       - echo "正在执行由流水线执行策略所强制要求的安全扫描"
       - echo "此作业无法被开发者跳过"
       - echo "正在检查安全漏洞..."
       - echo "安全扫描成功完成"
     rules:
       - when: always

   enforced-test-job:
     stage: test
     script:
       - echo "正在 test 阶段执行强制测试作业"
       - echo "如果 test 阶段不存在，则创建该阶段"
       - echo "正在执行强制测试要求..."
       - echo "强制测试成功完成"
     rules:
       - when: always

   enforced-compliance-check:
     stage: .pipeline-policy-post
     script:
       - echo "正在执行强制合规性检查"
       - echo "正在验证流水线合规要求"
       - echo "合规性检查已通过"
     rules:
       - when: always
   ```

1. 在 **提交信息** 字段中，输入 `添加流水线执行策略配置`。
1. 选择 **提交更改**。

## 添加流水线执行策略

接下来，为你的测试项目添加一个流水线执行策略：

1. 选择 **安全** > **策略**。
1. 选择 **新建策略**。
1. 在 **流水线执行策略** 中，选择 **选择策略**。
1. 填写字段。
   - **名称**：`强制执行安全和合规性作业`
   - **描述**：`在所有流水线中强制执行所需的安全和合规性作业`
   - **策略状态**：**已启用**

1. 将 **操作** 设置为以下内容：

   ![流水线执行策略操作](img/pipeline_execution_policy_actions_v18_7.png)
1. 选择 **通过合并请求配置**。
1. 在合并请求的 **更改** 选项卡中审查生成的策略 YAML。该策略应类似于：

   ```yaml
   ---
   pipeline_execution_policy:
   - name: 强制执行安全和合规性作业
     description: 在所有流水线中强制执行所需的安全和合规性作业
     enabled: true
     pipeline_config_strategy: inject_policy
     content:
       include:
       - project: [group]/my-pipeline-execution-policy
         file: pipeline-config.yml
     skip_ci:
       - allowed: false
   ```

1. 进入 **概览** 选项卡并选择 **合并**。此步骤会创建一个名为 `My Pipeline Execution Policy - Security Policy Project` 的新项目。安全策略项目用于存储安全策略，以便可以在多个项目间执行相同的策略。
1. 在顶部栏中，选择 **搜索或跳转到** 并找到 `my-pipeline-execution-policy` 项目。
1. 选择 **安全** > **策略**。

   你可以看到在之前步骤中添加的策略列表。

## 测试流水线执行策略

现在，通过创建一个合并请求来测试你的流水线执行策略：

1. 在左侧边栏中，选择 **代码** > **代码仓**。
1. 从 **添加** (+) 下拉列表中，选择 **新建文件**。
1. 在 **文件名** 字段中，输入 `test-file.txt`。
1. 在文件内容中，添加：

   ```plaintext
   这是一个用于触发流水线执行策略的测试文件。
   ```

1. 在 **提交信息** 字段中，输入 `添加测试文件以触发流水线`。
1. 在 **目标分支** 字段中，输入 `test-policy-branch`。
1. 选择 **提交更改**。
1. 当合并请求页面打开时，选择 **创建合并请求**。

   等待流水线完成。这可能需要几分钟。
1. 在合并请求中，选择 **流水线** 选项卡并选择已创建的流水线。

   你应该可以看到强制作业正在运行：
   - `enforced-security-scan` 在 `.pipeline-policy-pre` 阶段（最先运行）
   - `enforced-test-job` 在 `test` 阶段（由策略注入）
   - `enforced-compliance-check` 在 `.pipeline-policy-post` 阶段（最后运行）

1. 选择 `enforced-security-scan` 作业以查看其日志，并确认它按策略定义执行了安全扫描。

流水线执行策略成功强制执行了所需作业，确保它们无论开发者在其项目的 `.gitlab-ci.yml` 文件中包含什么内容，都能运行。

至此，你已了解如何设置和使用流水线执行策略，以在你的组织内的各个项目中强制使用所需的 CI/CD 作业！

## 后续步骤

- 了解有关[流水线执行策略配置策略](../../user/application_security/policies/pipeline_execution_policies.md#pipeline-configuration-strategies)的更多信息。
- 探索[高级流水线执行策略示例](../../user/application_security/policies/pipeline_execution_policies.md#examples)。