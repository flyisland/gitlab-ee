---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：在极狐GitLab 中执行模糊测试（已废弃）'
---

<!--- start_remove The following content will be removed on remove_date: '2026-08-15' -->

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 覆盖引导的模糊测试已在极狐GitLab 18.0 中[已废弃]，并计划在 19.0 中移除。这是一个重大变更。

<!-- vale gitlab_base.FutureTense = NO -->

[覆盖引导的模糊测试](../../user/application_security/coverage_fuzzing/_index.md#coverage-guided-fuzz-testing-process) 会向你的应用程序发送非预期的、格式错误的或随机数据，然后监控你的应用程序是否出现不稳定行为和崩溃。

这有助于你发现其他 QA 流程可能遗漏的错误和潜在安全问题。

除了其他安全扫描器和你自己的测试流程外，你还应该使用模糊测试。如果你正在使用极狐GitLab CI/CD，可以将模糊测试作为 CI/CD 工作流的一部分运行。

在本教程中，要使用 JavaScript 设置、配置和执行覆盖引导的模糊测试，你需要：

1. [派生项目模板](#fork-the-project-template)，以创建一个用于运行模糊测试的项目。
1. [创建模糊目标](#create-the-fuzz-targets)。
1. 在你的派生项目中[启用覆盖引导的模糊测试](#enable-coverage-guided-fuzz-testing)。
1. [运行模糊测试](#run-the-fuzz-test)以识别安全漏洞。
1. [修复模糊测试识别出的漏洞](#fix-the-vulnerabilities)。

<a id="fork-the-project-template"></a>

## 派生项目模板

首先，需要先派生 `fuzz-testing` 项目模板，以创建一个用于试用模糊测试的项目：

1. 打开 [`fuzz-testing` 项目模板](https://jihulab.com/gitlab-cn/tutorial-project-templates/fuzz-testing)。
1. [派生项目模板](../../user/project/repository/forking_workflow.md)。
1. 派生项目模板时：
   - 将派生的项目命名为 `fuzz-testing-demo`。
   - 选择一个合适的[命名空间](../../user/namespace/_index.md)。
   - 将[项目可见性](../../user/public_access.md)设置为 **Private**。

你已经成功派生了 `fuzz-testing` 项目模板。在开始模糊测试前，需要先移除项目模板与派生之间的关系：

1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **高级**。
1. 在 **移除派生关系** 部分，选择 **移除派生关系**。
   在提示时输入项目名称。

你的项目已经就绪，现在可以创建模糊测试了。接下来，你将创建模糊目标。

<a id="create-the-fuzz-targets"></a>

## 创建模糊目标

现在你已经有了一个用于模糊测试的项目，你需要创建模糊目标。模糊目标是一个函数或程序，在给定输入的情况下，它会调用被测应用程序。

在本教程中，模糊目标使用随机缓冲区作为参数，调用 `my-tools.js` 文件的某个函数。

要创建两个模糊目标文件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到 `fuzz-testing-demo` 项目。
1. 在项目的根目录下创建一个文件。
1. 将文件命名为 `fuzz-sayhello.js` 并添加以下代码：

   ```javascript
   let tools = require('./my-tools')

   function fuzz(buf) {
     const text = buf.toString()
     tools.sayHello(text)
   }

   module.exports = {
     fuzz
   }
   ```

   你也可以从 `fuzz-testing-demo/fuzzers/fuzz-sayhello.js` 项目文件复制这段代码。
1. 将 **目标分支** 命名为 `add-fuzz-test` 并写一条描述性的提交消息。
   - 暂时不要勾选 **使用这些更改开始新的合并请求** 复选框。
1. 选择 **提交更改**。
1. 返回项目的根目录。
1. 确保你处在 `add-fuzz-test` 分支中。
1. 创建第二个文件，命名为 `fuzz-readme.js` 并添加以下代码：

   ```javascript
   let tools = require('./my-tools')
   function fuzz(buf) {
       const text = buf.toString()
       tools.readmeContent(text)
   }
   module.exports = {
       fuzz
   }
   ```

   你也可以从 `fuzz-testing-demo/fuzzers/fuzz-readme.js` 项目文件复制这段代码。
1. 写一条描述性的提交消息。
1. 确保 **目标分支** 是 `add-fuzz-test`。
1. 选择 **提交更改**。

现在你已经有了两个可以调用被测应用程序的模糊目标。接下来，你将启用模糊测试。

<a id="enable-coverage-guided-fuzz-testing"></a>

## 启用覆盖引导的模糊测试

要启用覆盖引导的模糊测试，需要创建一个运行 `gitlab-cov-fuzz` CLI 的 CI/CD 流水线，以便在两个模糊目标上执行模糊测试。

要创建流水线文件：

1. 确保你处在 `add-fuzz-test` 分支中。
1. 在 `fuzz-testing-demo` 项目的根目录下，创建一个新文件。
1. 将文件命名为 `.gitlab-ci.yml` 并添加以下代码：

   ```yaml
   default:
     image: node:18

   stages:
     - fuzz

   include:
     - template: Coverage-Fuzzing.gitlab-ci.yml

   readme_fuzz_target:
     extends: .fuzz_base
     tags: [saas-linux-large-amd64] # 可选
     variables:
       COVFUZZ_ADDITIONAL_ARGS: '--fuzzTime=60'
     script:
       - npm config set @gitlab-org:registry https://gitlab.com/api/v4/packages/npm/ && npm i -g @gitlab-org/jsfuzz
       - ./gitlab-cov-fuzz run --engine jsfuzz -- fuzz-readme.js

   hello_fuzzing_target:
     extends: .fuzz_base
     tags: [saas-linux-large-amd64] # 可选
     variables:
       COVFUZZ_ADDITIONAL_ARGS: '--fuzzTime=60'
     script:
       - npm config set @gitlab-org:registry https://gitlab.com/api/v4/packages/npm/ && npm i -g @gitlab-org/jsfuzz
       - ./gitlab-cov-fuzz run --engine jsfuzz -- fuzz-sayhello.js
   ```

   此步骤会为你的流水线添加以下内容：
   - 一个使用模板的 `fuzz` 阶段。
   - 两个作业 `readme_fuzz_target` 和 `hello_fuzzing_target`。每个作业都使用 `jsfuzz` 引擎运行，该引擎会将未处理的异常报告为崩溃。

   你也可以从 `fuzz-testing-demo/fuzzers/fuzzers.yml` 项目文件复制这段代码。

1. 写一条描述性的提交消息。
1. 确保 **目标分支** 是 `add-fuzz-test`。
1. 选择 **提交更改**。

你已经成功启用了覆盖引导的模糊测试。接下来，你将使用刚刚创建的流水线来运行模糊测试。

<a id="run-the-fuzz-test"></a>

## 运行模糊测试

要运行模糊测试：

1. 在左侧边栏中，选择 **代码** > **合并请求**。
1. 选择 **新建合并请求**。
1. 在 **源分支** 部分，选择 `add-fuzz-test` 分支。
1. 在 **目标分支** 部分，确保已选择你的命名空间和 `main` 分支。
1. 选择 **比较分支并继续**。
1. [创建合并请求](../../user/project/merge_requests/creating_merge_requests.md)。

创建合并请求会触发一条新流水线，该流水线将运行模糊测试。当流水线运行完毕后，你应该会在合并请求页面看到一个安全漏洞告警。

要查看每个漏洞的详细信息，请选择各个 **未捕获异常** 链接。

你已经成功运行了模糊测试并识别出了待修复的漏洞。

<a id="fix-the-vulnerabilities"></a>

## 修复漏洞

模糊测试识别出了两个安全漏洞。要修复这些漏洞，你需要使用 `my-tools.js` 库。

要创建 `my-tools.js` 文件：

1. 确保你处在项目的 `add-fuzz-test` 分支中。
1. 前往项目的根目录，并打开 `my-tools.js` 文件。
1. 用以下代码替换该文件的内容：

   ```javascript
   const fs = require('fs')

   function sayHello(name) {
     if(name.includes("z")) {
       //throw new Error("😡 error name: " + name)
       console.log("😡 error name: " + name)
     } else {
       return "😀 hello " + name
     }
   }

   function readmeContent(name) {

     let fileName = name => {
       if(name.includes("w")) {
         return "./README.txt"
       } else {
         return "./README.md"
       }
     }

     //const data = fs.readFileSync(fileName(name), 'utf8')
     try {
       const data = fs.readFileSync(fileName(name), 'utf8')
       return data
     } catch (err) {
       console.error(err.message)
       return ""
     }

   }

   module.exports = {
     sayHello, readmeContent
   }
   ```

   你也可以从 `fuzz-testing-demo/javascript/my-tools.js` 项目文件复制代码。
1. 选择 **提交更改**。这将触发另一条流水线来运行新的模糊测试。
1. 当流水线完成后，查看合并请求的 **概览** 页面。你应该会看到安全扫描未检测到新的潜在漏洞。
1. 合入你的更改。

恭喜！你已经成功运行了模糊测试并修复了识别出的安全漏洞！

有关更多信息，请参阅[覆盖引导的模糊测试](../../user/application_security/coverage_fuzzing/_index.md)。

<!--- end_remove -->
