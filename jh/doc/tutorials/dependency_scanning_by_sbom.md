```markdown
---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn how to configure dependency scanning using SBOM, detect vulnerabilities in your project dependencies, and understand which vulnerabilities are reachable in your code.
title: '教程：使用 SBOM 设置依赖扫描'
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com

{{< /details >}}

依赖扫描可以在软件依赖被提交到主分支之前自动检测其中的安全漏洞。在您开发并测试应用时，您可以尽早识别并解决有漏洞的依赖，从而降低风险。依赖分析器生成应用依赖的软件物料清单（SBOM），然后将其与安全通告进行比较，以识别漏洞。静态可达性分析通过识别应用导入了哪些有漏洞的依赖，增强了漏洞风险评估数据。

本教程将向您展示如何执行以下操作：

- 创建一个示例 JavaScript 应用。
- 使用新的 SBOM 分析器设置依赖扫描，包括静态可达性分析。
- 对应用依赖中的漏洞进行分类。
- 通过更新依赖来修复漏洞。

> [!note]
> 本教程使用具有已知漏洞的过时依赖来演示检测过程。

<a id="before-you-begin"></a>

## 准备工作

在开始本教程之前，请确保您具备以下条件：

- JihuLab.com 账号以及创建新项目的权限
- Git
- Node.js（版本 14 或更高版本）

<a id="create-example-application-files"></a>

## 创建示例应用文件

本教程的第一个任务是设置示例项目，包括示例漏洞应用，并配置 CI/CD。

1. 在 JihuLab.com 上，使用默认值创建一个空白项目。
1. 将项目克隆到您的本地机器：

   ```plaintext
   git clone https://jihulab.com/<your-username>/<project-name>.git
   cd <project-name>
   ```

1. 在您的本地机器上，在项目中创建以下文件：

   - `.gitlab-ci.yml`
   - `package.json`
   - `app.js`

   文件名：`.gitlab-ci.yml`

   ```yaml
   stages:

   - build
   - test

   include:
   - template: Jobs/Dependency-Scanning.v2.gitlab-ci.yml
       inputs:
         enable_static_reachability: true
   ```

   文件名：`package.json`

   ```json
   {
      "name": "tutorial-ds-sbom-scanning-with-sra",
      "version": "1.0.0",
      "main": "index.js",
      "dependencies": {
         "axios": "0.21.1",
         "fastify": "2.14.1"
      }
   }
   ```

   文件名：`app.js`

   ```javascript
   const axios = require('axios');

   async function runDemo() {
     console.log("Starting Reachability Demo...");
     try {
       // This specific call creates the reachability link
       const response = await axios.get('<https://jihulab.com>');
       console.log("Request successful, status:", response.status);
     } catch (err) {
       console.log("Demo request finished.");
     }
   }

   runDemo();
   ```

1. 创建锁定文件。

   ```plaintext
   npm install
   ```

1. 将这些文件提交并推送到您的项目：

   ```plaintext
   git add .gitlab-ci.yml app.js package.json package-lock.json
   git commit -m "Set up files for tutorial"
   git push
   ```

1. 在 JihuLab.com 上，转到 **构建** > **流水线** 并确认最新的流水线已成功完成。

   在流水线中，依赖扫描会运行并执行以下操作：

   - 从您的依赖生成 SBOM。您可以[下载 SBOM](#optional-download-sbom)。
   - 根据已知漏洞公告扫描 SBOM 中列出的依赖。
   - 通过静态可达性分析丰富结果，以识别代码中导入了哪些依赖。

<a id="triage-and-analyze-vulnerabilities"></a>

## 分类和分析漏洞

依赖扫描应已检测到应用依赖中的漏洞。下一个任务是对这些漏洞进行分类和分析。

> [!note]
> 为了简化本教程，所有更改都提交到 `main` 分支。在实际环境中，您会在开发分支中运行依赖扫描，以便在分支合并之前检测漏洞。

在本教程中，我们将仅对其中一个漏洞进行分类和分析。我们选择此漏洞是因为它是可达的，并且有明确的修复路径。

1. 在 JihuLab.com 上，转到 **安全** > **漏洞报告**。

   您应该会在报告中看到多个列出的漏洞。截至撰写时，已检测到 12 个漏洞。

   > 出于本教程的目的，我们将仅关注一个漏洞。在实际环境中，您将分析所有[可用的风险评估数据](../user/application_security/vulnerabilities/risk_assessment_data.md)，并应用您组织的风险管理框架。

1. 选择搜索过滤器，然后从下拉列表中选择 **可达性**，再选择 **是**。

   现在漏洞报告仅列出可达的漏洞。各严重级别的漏洞数量会更新以匹配新过滤器。

   > 在此示例中，您在 `package.json` 中声明了以下直接依赖：
   >
   > - `axios` - 版本 0.21.1
   > - `fastify` - 版本 2.14.1
   >
   > 依赖扫描在 `fastify` 和 `axios` 及其传递依赖中均检测到了漏洞。但是，只有 `fastify` 被示例应用导入，因此 `axios` 中的漏洞不可达。当您应用可达性过滤器时，`axios` 中的漏洞将从漏洞报告中排除。

1. 选择 CVE-2026-25223 的描述——“Fastify 的 Content-Type 标头中的 tab 字符允许绕过请求体验证”。

   1. 查看此漏洞的详细信息。

      该漏洞为高严重性，且 **可达性** 为 **是**，表示该依赖已被应用导入。这使得它比其它不可达的高严重性漏洞更具风险。

   1. 向下滚动到 **解决方案** 部分。

      对于此漏洞，解决方案是升级该依赖的版本。

为了简化本教程，我们将应用所述解决方案。在实际环境中，您将遵循公司的漏洞分析流程，在应用前验证此解决方案。

<a id="remediate-the-vulnerability"></a>

## 修复漏洞

现在我们有了解决方案，接下来我们将升级 `fastify` 依赖。

1. 在您的本地机器上，将 `package.json` 文件中的版本更新为漏洞详情页中列出的 `fastify` 版本——5.7.2。

   ```json
   {
      "name": "tutorial-ds-sbom-scanning-with-sra",
      "version": "1.0.0",
      "main": "index.js",
      "dependencies": {
         "axios": "0.21.1",
         "fastify": "5.7.2"
      }
   }
   ```

1. 更新锁定文件。

   ```plaintext
   npm install
   ```

   这会使用新的依赖版本更新 `package-lock.json` 文件。

1. 创建一个新分支并提交这些更改：

   ```plaintext
   git checkout -b update-dependencies
   git add package.json package-lock.json
   git commit -m "Update version of fastify"
   git push -u origin update-dependencies
   ```

1. 在 JihuLab.com 上，转到 **代码** > **合并请求**，然后选择 **创建合并请求**。

1. 在 **新建合并请求** 页面上，滚动到底部并选择 **创建合并请求**。

   合并请求流水线完成后，等待安全结果小部件出现。处理安全报告通常需要一两分钟。

1. 在安全结果小部件中，选择 **显示详情**（{{< icon name="chevron-lg-down" >}}）。

   安全结果小部件表示合并请求中的更改修复了 7 个漏洞，包括您分类和分析的漏洞。

1. 选择 **合并**。

   等待合并请求被合并。

1. 转到 **安全** > **漏洞报告**。

   漏洞 CVE-2026-25223 不再列出，因为漏洞报告默认仅列出 **仍检测到** 的漏洞。要查看漏洞详情，您可以更改状态过滤器。

在本教程中，您已学习了如何执行以下操作：

- 使用 SBOM 和静态可达性分析设置依赖扫描
- 检测和分类依赖中的漏洞
- 通过更新依赖修复漏洞
- 验证漏洞已修复

<a id="optional-download-sbom"></a>

## 可选：下载 SBOM

要下载依赖扫描分析器生成的 SBOM：

1. 转到 **构建** > **流水线**。
1. 选择最近的流水线。
1. 选择 **依赖扫描** 作业。
1. 在 **作业产物** 部分，选择 **下载**。

作业产物将下载为文件 `artifacts.zip`。解压缩以获取 SBOM 文件 `gl-sbom-npm-npm.cdx.json`。
```