---
stage: Security Risk Management
group: Security Policies
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 教程：设置扫描执行策略
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本教程展示如何创建和应用[扫描执行策略](../../user/application_security/policies/scan_execution_policies.md)。这些策略将应用安全工具强制纳入 CI/CD 流水线。在本教程中，你将创建一个策略，以在两个项目的 CI/CD 流水线中强制运行密钥检测。

在本教程中，你将：

- [创建项目 A](#create-project-a)。
- [创建扫描执行策略](#create-the-scan-execution-policy)。
- [使用项目 A 测试扫描执行策略](#test-the-scan-execution-policy-with-project-a)。
- [创建项目 B](#create-project-b)。
- [将项目 B 链接到安全策略项目](#link-project-b-to-the-security-policy-project)。
- [使用项目 B 测试扫描执行策略](#test-the-scan-execution-policy-with-project-b)。

<a id="before-you-begin"></a>

## 准备工作

- 你需要有在现有群组中创建新项目的权限。

<a id="create-project-a"></a>

## 创建项目 A

在标准工作流中，你可能已有现成项目。本教程从零开始，因此第一步是创建项目。

创建项目 A：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **新项目**。
1. 选择 **创建空白项目**。
1. 填写字段。在 **项目名称** 中输入 `go-example-a`。
1. 选择 **创建项目**。
1. 选择 **添加** ({{< icon name="plus" >}}) > **新建文件**。
1. 在文件名中输入 `helloworld.go`。
1. 将以下示例 Go 代码复制粘贴到文件中。

   ```go
   package main
   import "fmt"
   func main() {
       fmt.Println("Hello world")
   }
   ```

1. 选择 **提交更改**。

下一步是创建扫描执行策略。当创建第一个安全策略时，会同时创建一个策略项目。策略项目存储着所有关联项目所创建的安全策略。将策略与其保护的项目分离，可使你的安全配置更具复用性且更易于维护。

<a id="create-the-scan-execution-policy"></a>

## 创建扫描执行策略

创建扫描执行策略：

1. 在顶部栏中，选择 **搜索或跳转到** 并搜索 `go-example-a` 项目。
1. 进入 **安全防护** > **策略**。
1. 选择 **新建策略**。
1. 在 **扫描执行策略** 部分，选择 **选择策略**。
1. 填写字段。
   - **名称**：强制密钥检测。
   - **策略状态**：启用。
   - **操作**：运行一次密钥检测扫描。
   - **条件**：每次所有分支的流水线运行时触发。
1. 选择 **通过合并请求配置**。

   此时会创建策略项目 `go-example-a - 安全项目`，并生成一个合并请求。
1. 可选。在合并请求的 **变更** 标签页中查看生成的策略 YAML。
1. 前往 **概览** 标签页并选择 **合并**。
1. 在顶部栏中，选择 **搜索或跳转到** 并搜索 `go-example-a` 项目。
1. 进入 **安全防护** > **策略**。

现在你拥有了一个扫描执行策略，该策略会在每个合并请求中针对任意分支运行密钥检测扫描。通过项目 A 创建一个合并请求来测试该策略。

<a id="test-the-scan-execution-policy-with-project-a"></a>

## 使用项目 A 测试扫描执行策略

测试扫描执行策略：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到名为 `go-example-a` 的项目。
1. 进入 **代码** > **仓库**。
1. 选择 `helloworld.go` 文件。
1. 选择 **编辑** > **编辑单个文件**。
1. 在 `fmt.Println("hello world")` 行后立即添加以下行：

   ```plaintext
   var GitLabFeedToken = "feed_token=eFLISqaBym4EjAefkl58"
   ```

1. 在 **目标分支** 字段中输入 `feature-a`。
1. 选择 **提交更改**。
1. 当合并请求页面打开时，选择 **创建合并请求**。

   我们来检查扫描执行策略是否生效。请记住，我们指定了密钥检测应在每次流水线运行时针对任意分支执行。
1. 在刚创建的合并请求中，前往 **流水线** 标签页并选择已创建的流水线。

   这里你可以看到密钥检测作业已运行。我们来检查它是否检测到了测试密钥。
1. 选择密钥检测作业。

   在作业日志底部附近，以下输出确认检测到了示例密钥。

   ```plaintext
   [INFO] [secrets] [2023-09-04T03:46:36Z] ▶ 3:46AM INF 1 个提交已扫描。
   [INFO] [secrets] [2023-09-04T03:46:36Z] ▶ 3:46AM INF 扫描完成，耗时 60 毫秒
   [INFO] [secrets] [2023-09-04T03:46:36Z] ▶ 3:46AM WRN 发现泄露：1
   ```

你已经看到策略对一个项目起作用。接下来创建另一个项目并应用相同的策略。

<a id="create-project-b"></a>

## 创建项目 B

创建项目 B：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **新项目**。
1. 选择 **创建空白项目**。
1. 填写字段。在 **项目名称** 中输入 `go-example-b`。
1. 选择 **创建项目**。
1. 选择 **添加** ({{< icon name="plus" >}}) > **新建文件**。
1. 在文件名中输入 `helloworld.go`。
1. 将以下示例 Go 代码复制粘贴到文件中。

   ```go
   package main
   import "fmt"
   func main() {
       fmt.Println("Hello world")
   }
   ```

1. 选择 **提交更改**。

现在你有了另一个项目，将其链接到同一个策略项目。

<a id="link-project-b-to-the-security-policy-project"></a>

## 将项目 B 链接到安全策略项目

将项目 B 链接到安全策略项目：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到 `go-example-b` 项目。
1. 进入 **安全防护** > **策略**。
1. 选择 **编辑策略项目**。
1. 选择下拉列表，然后搜索本教程开始时创建的安全策略项目。
1. 选择 **保存**。

将项目 B 链接到同一个策略项目后，相同的策略得以应用。扫描执行策略会在每个合并请求中对任意分支运行密钥检测扫描。让我们在项目 B 中创建一个合并请求来测试该策略。

<a id="test-the-scan-execution-policy-with-project-b"></a>

## 使用项目 B 测试扫描执行策略

测试扫描执行策略：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到 `go-example-b` 项目。
1. 进入 **代码** > **仓库**。
1. 选择 `helloworld.go` 文件。
1. 选择 **编辑** > **编辑单个文件**。
1. 在 `fmt.Println("hello world")` 行后立即添加以下行：

   ```plaintext
   var AdobeClient = "4ab4b080d9ce4072a6be2629c399d653"
   ```

1. 在 **目标分支** 字段中输入 `feature-b`。
1. 选择 **提交更改**。
1. 当合并请求页面打开时，选择 **创建合并请求**。

   我们来检查扫描执行策略是否生效。请记住，我们指定了密钥检测应在每次流水线运行时针对任意分支执行。
1. 在刚创建的合并请求中，前往 **流水线** 标签页并选择已创建的流水线。
1. 在刚创建的合并请求中，选择流水线的 ID。

   这里你可以看到密钥检测作业已运行。我们来检查它是否检测到了测试密钥。
1. 选择密钥检测作业。

   在作业日志底部附近，以下输出确认检测到了示例密钥。

   ```plaintext
   [INFO] [secrets] [2023-09-04T04:22:28Z] ▶ 4:22AM INF 1 个提交已扫描。
   [INFO] [secrets] [2023-09-04T04:22:28Z] ▶ 4:22AM INF 扫描完成，耗时 58.2 毫秒
   [INFO] [secrets] [2023-09-04T04:22:28Z] ▶ 4:22AM WRN 发现泄露：1
   ```

恭喜。你已经学会了如何创建扫描执行策略并将其强制执行到项目上。