---
stage: Security Risk Management
group: Security Policies
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 教程：设置合并请求审批策略
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本教程将向你展示如何创建和配置[合并请求审批策略](../../user/application_security/policies/merge_request_approval_policies.md)。你可以设置这些策略，使其根据扫描结果执行操作。
例如，在本教程中，你将设置一条策略，规定当合并请求中检测到漏洞时，需要获得两个指定用户的审批。

要设置合并请求审批策略，请执行以下步骤：

1. [创建测试项目](#创建测试项目)。
1. [添加合并请求审批策略](#添加合并请求审批策略)。
1. [测试合并请求审批策略](#测试合并请求审批策略)。

<a id="before-you-begin"></a>

## 准备工作

- 本教程使用的命名空间必须包含至少三名用户，包括你自己。如果你没有其他两名用户，则必须首先创建他们。详情请参见[创建用户](../../user/profile/account/create_accounts.md)。
- 你需要拥有在现有群组中创建新项目的权限。

<a id="create-a-test-project"></a>

## 创建测试项目

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建项目/代码仓**。
1. 选择 **创建空白项目**。
1. 填写字段。
   - **项目名称**：`sast-scan-result-policy`。
   - 选中 **启用静态应用安全测试 (SAST)** 复选框。
1. 选择 **创建项目**。
1. 前往新创建的项目，并创建[受保护分支](../../user/project/repository/branches/protected.md)。

<a id="add-a-merge-request-approval-policy"></a>

## 添加合并请求审批策略

接下来，你将向测试项目添加合并请求审批策略：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到 `sast-scan-result-policy` 项目。
1. 选择 **安全** > **策略**。
1. 选择 **新建策略**。
1. 在 **合并请求审批策略** 中，选择 **选择策略**。
1. 填写字段。
   - **名称**：`sast-scan-result-policy`
   - **策略状态**：**已启用**
1. 添加以下规则：

   ```plaintext
   如果 |安全扫描| 来自 |SAST| 发现 |0| 以上 |所有严重级别| |所有漏洞状态| 的漏洞，针对目标为 |所有受保护分支| 的开放合并请求
   ```

1. 将 **操作** 设置为以下内容：

   ```plaintext
   那么 需要从以下审批者中获得 | 2 | 位审批：
   ```

1. 选择两个用户。
1. 选择 **使用合并请求配置**。

   应用程序会创建一个新项目以存储与之关联的策略，并创建一个合并请求来定义该策略。
1. 选择 **合并**。
1. 在顶部栏中，选择 **搜索或跳转到** 并找到 `sast-scan-result-policy` 项目。
1. 选择 **安全** > **策略**。

   你可以看到上一步中添加的策略列表。

<a id="test-the-merge-request-approval-policy"></a>

## 测试合并请求审批策略

干得好！你已经创建了一个合并请求审批策略。要测试它，请引入一些漏洞并查看结果：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到 `sast-scan-result-policy` 项目。
1. 在左侧边栏中，选择 **代码** > **代码仓**。
1. 从 **添加** ({{< icon name="plus" >}}) 下拉列表中，选择 **新建文件**。
1. 在 **文件名** 字段中输入 `main.ts`。
1. 在文件内容中，复制以下内容：

   ```typescript
   // 非字面量 require - tsr-detect-non-literal-require
   var lib: String = 'fs'
   require(lib)

   // 带变量的 eval - tsr-detect-eval-with-expression
   var myeval: String = 'console.log("Hello.");';
   eval(myeval);

   // 不安全的正则表达式 - tsr-detect-unsafe-regexp
   const regex: RegExp = /(x+x+)+y/;

   // 非字面量正则表达式 - tsr-detect-non-literal-regexp
   var myregexpText: String = "/(x+x+)+y/";
   var myregexp: RegExp = new RegExp(myregexpText);
   myregexp.test("(x+x+)+y");

   // 禁用标记转义 - tsr-detect-disable-mustache-escape
   var template: Object = new Object;
   template.escapeMarkup = false;

   // 检测 HTML 注入 - tsr-detect-html-injection
   var element: Element =  document.getElementById("mydiv");
   var content: String = "mycontent"
   Element.innerHTML = content;

   // 时序攻击 - tsr-detect-possible-timing-attacks
   var userInput: String = "Jane";
   var auth: String = "Jane";
   if (userInput == auth) {
     console.log(userInput);
   }
   ```

1. 在 **提交信息** 字段中输入 `添加有漏洞的文件`。
1. 在 **目标分支** 字段中输入 `test-branch`。
1. 选择 **提交更改**。**新建合并请求** 表单将打开。
1. 选择 **创建合并请求**。
1. 在新的合并请求中，选择 `创建合并请求`。

   等待流水线完成。这可能需要几分钟。

合并请求安全挂件确认安全扫描检测到了一个潜在漏洞。根据合并请求审批策略的定义，该合并请求被阻止并等待审批。

现在你已知道如何设置和使用合并请求审批策略来捕获漏洞！