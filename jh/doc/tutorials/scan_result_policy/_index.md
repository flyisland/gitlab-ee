---
stage: Security Risk Management
group: Security Policies
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：设置合并请求审批策略'
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本教程向您展示如何创建和配置[合并请求审批策略](../../user/application_security/policies/merge_request_approval_policies.md)。这些策略可以根据扫描结果采取措施。例如，在本教程中，您将设置一个策略，当在合并请求中检测到漏洞时，需要两个指定用户批准。

要设置合并请求审批策略：

1. [创建测试项目](#create-a-test-project)。
1. [添加合并请求审批策略](#add-a-merge-request-approval-policy)。
1. [测试合并请求审批策略](#test-the-merge-request-approval-policy)。

<a id="before-you-begin"></a>

## 开始之前

- 您用于本教程的命名空间必须至少包含三个用户，其中包括您自己。如果您没有另外两个
  用户，必须先创建它们。有关详情，请参阅[创建用户](../../user/profile/account/create_accounts.md)。
- 您需要拥有在现有群组中创建新项目的权限。

<a id="create-a-test-project"></a>

## 创建测试项目

1. 在右上角，选择**创建新的** ({{< icon name="plus" >}}) 和**新建项目/仓库**。
1. 选择**创建空白项目**。
1. 填写字段。
   - **项目名称**：`sast-scan-result-policy`。
   - 选中**启用静态应用程序安全测试 (SAST)** 复选框。
1. 选择**创建项目**。
1. 要保护默认分支：
   1. 在顶部栏中，选择**搜索或跳转到**并输入 `sast-scan-result-policy`。
   1. 在左侧边栏中，选择**设置** > **代码仓库**。
   1. 展开**分支规则**。
   1. 选择**添加分支规则** > **分支名称或样式**。
   1. 从下拉列表中，搜索并选择 `main`（或您的默认分支），然后选择**创建分支规则**。
   1. 在**允许合并**部分，选择**编辑**，将其设置为**维护者**，然后选择**保存更改**。
   1. 在**允许推送和合并**部分，选择**编辑**，将其设置为**没有任何人**，然后选择**保存更改**。

<a id="add-a-merge-request-approval-policy"></a>

## 添加合并请求审批策略

接下来，您将向测试项目添加合并请求审批策略：

1. 在顶部栏中，选择**搜索或跳转到**并找到 `sast-scan-result-policy` 项目。
1. 选择**安全** > **策略**。
1. 选择**新建策略**。
1. 在**合并请求审批策略**中，选择**选择策略**。
1. 填写字段。
   - **名称**：`sast-scan-result-policy`
   - **策略状态**：**已启用**
1. 选择**添加新规则**并配置规则：
   - 对于扫描类型，选择**安全扫描**和 **SAST**。
   - 对于目标，选择**所有受保护分支**和**无例外**。
   - 对于漏洞数量，选择**多于**并输入 `0`。
1. 在**全局设置**下，配置严重性和状态：
   - **严重性为**：**所有严重性级别**
   - **状态**：**新建** + **所有漏洞状态**

1. 将**操作**设置为以下内容：

   ```plaintext
   THEN Require approval from | 2 | of the following approvers:
   ```

1. 选择两个用户。
1. 选择**使用合并请求配置**。

   应用程序会创建一个新项目来存储与其关联的策略，并创建一个合并请求来定义该策略。
1. 选择**合并**。
1. 在顶部栏中，选择**搜索或跳转到**并找到 `sast-scan-result-policy` 项目。
1. 选择**安全** > **策略**。

   您可以看到前面步骤中添加的策略列表。

<a id="test-the-merge-request-approval-policy"></a>

## 测试合并请求审批策略

做得好，您已经创建了一个合并请求审批策略。要测试它，请创建一些漏洞并检查结果：

1. 在顶部栏中，选择**搜索或跳转到**并找到 `sast-scan-result-policy` 项目。
1. 在左侧边栏中，选择**代码** > **代码仓库**。
1. 从**添加** ({{< icon name="plus" >}}) 下拉列表中，选择**新建文件**。
1. 在**文件名**字段中输入 `main.ts`。
1. 在文件内容中，复制以下内容：

   ```typescript
   // Non-literal require - tsr-detect-non-literal-require
   var lib: String = 'fs'
   require(lib)

   // Eval with variable - tsr-detect-eval-with-expression
   var myeval: String = 'console.log("Hello.");';
   eval(myeval);

   // Unsafe Regexp - tsr-detect-unsafe-regexp
   const regex: RegExp = /(x+x+)+y/;

   // Non-literal Regexp - tsr-detect-non-literal-regexp
   var myregexpText: String = "/(x+x+)+y/";
   var myregexp: RegExp = new RegExp(myregexpText);
   myregexp.test("(x+x+)+y");

   // Markup escaping disabled - tsr-detect-disable-mustache-escape
   var template: Object = new Object;
   template.escapeMarkup = false;

   // Detects HTML injections - tsr-detect-html-injection
   var element: Element =  document.getElementById("mydiv");
   var content: String = "mycontent"
   Element.innerHTML = content;

   // Timing attack - tsr-detect-possible-timing-attacks
   var userInput: String = "Jane";
   var auth: String = "Jane";
   if (userInput == auth) {
     console.log(userInput);
   }
   ```

1. 在**提交信息**字段中，输入 `Add vulnerable file`。
1. 在**目标分支**字段中，输入 `test-branch`。
1. 选择**提交更改**。**新建合并请求**表单打开。
1. 选择**创建合并请求**。
1. 在新的合并请求中，选择 `Create merge request`。

   等待流水线完成。这可能需要几分钟。

合并请求的**报告**选项卡确认安全扫描检测到一个潜在漏洞。按照合并请求审批策略中的定义，该合并请求被阻止并等待批准。

现在您已经知道如何设置和使用合并请求审批策略来捕获漏洞了！
