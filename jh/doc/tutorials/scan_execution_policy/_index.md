---
stage: Security Risk Management
group: Security Policies
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：设置扫描执行策略'
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本教程介绍如何创建并应用[扫描执行策略](../../user/application_security/policies/scan_execution_policies.md)。这些策略将应用程序安全工具作为 CI/CD 流水线的一部分强制执行。在本教程中，您将创建一个策略，在两个项目的 CI/CD 流水线中强制执行密钥检测。

在本教程中，您将：

- [创建项目 A](#create-project-a)。
- [创建扫描执行策略](#create-the-scan-execution-policy)。
- [使用项目 A 测试扫描执行策略](#test-the-scan-execution-policy-with-project-a)。
- [创建项目 B](#create-project-b)。
- [将项目 B 链接到安全策略项目](#link-project-b-to-the-security-policy-project)。
- [使用项目 B 测试扫描执行策略](#test-the-scan-execution-policy-with-project-b)。

<a id="before-you-begin"></a>

## 先决条件

- 您需要拥有在现有群组中创建新项目的权限。

<a id="create-project-a"></a>

## 创建项目 A

在标准工作流程中，您可能已经有一个现有项目。在本教程中，您将从零开始，因此第一步是创建一个项目。

创建项目 A：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**新建项目**。
1. 选择**创建空白项目**。
1. 填写各字段。在**项目名称**中，输入 `go-example-a`。
1. 选择**创建项目**。
1. 选择**添加** ({{< icon name="plus" >}}) > **新建文件**。
1. 在文件名中输入 `helloworld.go`。
1. 将以下示例 Go 代码复制并粘贴到文件中。

   ```go
   package main
   import "fmt"
   func main() {
       fmt.Println("Hello world")
   }
   ```

1. 选择**提交更改**。

下一步是创建扫描执行策略。创建第一个安全策略时，会创建一个策略项目。策略项目存储在任何链接到它的项目中创建的安全策略。将策略与其保护的项目分开，可使您的安全配置可复用且更易于维护。

<a id="create-the-scan-execution-policy"></a>

## 创建扫描执行策略

创建扫描执行策略：

1. 在顶部栏中，选择**搜索或跳转到**，然后搜索 `go-example-a` 项目。
1. 转到**安全** > **策略**。
1. 选择**新建策略**。
1. 在**扫描执行策略**部分，选择**选择策略**。
1. 填写各字段。
   - **名称**：强制执行密钥检测。
   - **策略状态**：已启用。
   - **操作**：运行密钥检测扫描。
   - **条件**：每次为所有分支运行流水线时触发。
1. 选择**使用合并请求配置**。

   策略项目 `go-example-a - Security project` 已创建，并且已创建一个合并请求。
1. 可选。在合并请求的**变更**选项卡中查看生成的策略 YAML。
1. 转到**概览**选项卡并选择**合并**。
1. 在顶部栏中，选择**搜索或跳转到**，然后搜索 `go-example-a` 项目。
1. 转到**安全** > **策略**。

您现在拥有一个扫描执行策略，它会在每个合并请求上、针对任何分支运行密钥检测扫描。通过在项目 A 中创建一个合并请求来测试该策略。

<a id="test-the-scan-execution-policy-with-project-a"></a>

## 使用项目 A 测试扫描执行策略

测试扫描执行策略：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到名为 `go-example-a`的项目。
1. 转到**代码** > **代码仓库**。
1. 选择 `helloworld.go` 文件。
1. 选择**编辑** > **编辑单个文件**。
1. 在 `fmt.Println("hello world")` 行之后立即添加以下行：

   ```plaintext
   var GitLabFeedToken = "feed_token=eFLISqaBym4EjAefkl58"
   ```

1. 在**目标分支**字段中，输入 `feature-a`。
1. 选择**提交更改**。
1. 当合并请求页面打开时，选择**创建合并请求**。

   让我们检查扫描执行策略是否生效。请记住，我们指定了密钥检测
   在每次运行流水线时、针对任何分支运行。
1. 在刚创建的合并请求中，转到**流水线**选项卡并选择所创建的流水线。

   在这里您可以看到密钥检测作业已运行。让我们检查它是否检测到了测试密钥。
1. 选择密钥检测作业。

   在作业日志的底部附近，以下输出确认已检测到示例密钥。

   ```plaintext
   [INFO] [secrets] [2023-09-04T03:46:36Z] ▶ 3:46AM INF 1 commits scanned.
   [INFO] [secrets] [2023-09-04T03:46:36Z] ▶ 3:46AM INF scan completed in 60ms
   [INFO] [secrets] [2023-09-04T03:46:36Z] ▶ 3:46AM WRN leaks found: 1
   ```

您已经看到了该策略在一个项目中的效果。创建另一个项目并应用相同的策略。

<a id="create-project-b"></a>

## 创建项目 B

创建项目 B：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**新建项目**。
1. 选择**创建空白项目**。
1. 填写各字段。在**项目名称**中，输入 `go-example-b`。
1. 选择**创建项目**。
1. 选择**添加** ({{< icon name="plus" >}}) > **新建文件**。
1. 在文件名中输入 `helloworld.go`。
1. 将以下示例 Go 代码复制并粘贴到文件中。

   ```go
   package main
   import "fmt"
   func main() {
       fmt.Println("Hello world")
   }
   ```

1. 选择**提交更改**。

现在您有了另一个项目，将其链接到同一个策略项目。

<a id="link-project-b-to-the-security-policy-project"></a>

## 将项目 B 链接到安全策略项目

将项目 B 链接到安全策略项目：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到 `go-example-b` 项目。
1. 转到**安全** > **策略**。
1. 选择**编辑策略项目**。
1. 选择下拉列表，然后搜索本教程开始时创建的安全策略项目。
1. 选择**保存**。

将项目 B 链接到同一个策略项目后，应用了相同的策略。扫描执行策略会在每个合并请求上、针对任何分支运行密钥检测扫描。让我们通过在项目 B 中创建一个合并请求来测试该策略。

<a id="test-the-scan-execution-policy-with-project-b"></a>

## 使用项目 B 测试扫描执行策略

测试扫描执行策略：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到 `go-example-b` 项目。
1. 转到**代码** > **代码仓库**。
1. 选择 `helloworld.go` 文件。
1. 选择**编辑** > **编辑单个文件**。
1. 在 `fmt.Println("hello world")` 行之后立即添加以下行：

   ```plaintext
   var AdobeClient = "4ab4b080d9ce4072a6be2629c399d653"
   ```

1. 在**目标分支**字段中，输入 `feature-b`。
1. 选择**提交更改**。
1. 当合并请求页面打开时，选择**创建合并请求**。

   让我们检查扫描执行策略是否生效。请记住，我们指定了密钥检测
   在每次运行流水线时、针对任何分支运行。
1. 在刚创建的合并请求中，转到**流水线**选项卡并选择所创建的流水线。
1. 在刚创建的合并请求中，选择流水线的 ID。

   在这里您可以看到密钥检测作业已运行。让我们检查它是否检测到了测试密钥。
1. 选择密钥检测作业。

   在作业日志的底部附近，以下输出确认已检测到示例密钥。

   ```plaintext
   [INFO] [secrets] [2023-09-04T04:22:28Z] ▶ 4:22AM INF 1 commits scanned.
   [INFO] [secrets] [2023-09-04T04:22:28Z] ▶ 4:22AM INF scan completed in 58.2ms
   [INFO] [secrets] [2023-09-04T04:22:28Z] ▶ 4:22AM WRN leaks found: 1
   ```

恭喜。您已经学会了如何创建扫描执行策略并在项目上强制执行它。
