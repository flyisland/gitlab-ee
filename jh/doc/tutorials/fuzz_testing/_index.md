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
> 覆盖率引导的模糊测试已在极狐GitLab 18.0 中[废弃](https://gitlab.com/gitlab-org/gitlab/-/issues/517841)，
> 并计划在 19.0 中移除。这是一项破坏性变更。

<!-- vale gitlab_base.FutureTense = NO -->

[覆盖率引导的模糊测试](../../user/application_security/coverage_fuzzing/_index.md#coverage-guided-fuzz-testing-process)会向您的应用程序发送意外、畸形或随机的数据，然后监控
您的应用程序是否出现不稳定行为和崩溃。

这有助于您发现其他 QA 流程可能遗漏的缺陷和潜在安全问题。

您应该在其他安全扫描器和您自己的测试流程之外，额外使用模糊测试。如果您使用极狐GitLab CI/CD，可以将模糊测试作为 CI/CD 工作流的一部分来运行。

在本教程中，要使用 JavaScript 设置、配置并执行覆盖率引导的模糊测试，您需要：

1. [Fork 项目模板](#fork-the-project-template)，创建一个用于运行
   模糊测试的项目。
1. [创建模糊测试目标](#create-the-fuzz-targets)。
1. 在您 forked 项目中[启用覆盖率引导的模糊测试](#enable-coverage-guided-fuzz-testing)。
1. [运行模糊测试](#run-the-fuzz-test)，以识别安全漏洞。
1. [修复模糊测试识别出的任何漏洞](#fix-the-vulnerabilities)。

<a id="fork-the-project-template"></a>

## Fork 项目模板

首先，要创建一个用于试用模糊测试的项目，您必须 fork`fuzz-testing` 项目模板：

1. 打开 [`fuzz-testing` 项目模板](https://gitlab.com/gitlab-org/tutorial-project-templates/fuzz-testing)。
1. [Fork 项目模板](../../user/project/repository/forking_workflow.md)。
1. 在 forking 项目模板时：
   - 将 forked 项目命名为 `fuzz-testing-demo`。
   - 选择合适的[命名空间](../../user/namespace/_index.md)。
   - 将[项目可见性](../../user/public_access.md)设置为 **Private**。

您已成功 forked`fuzz-testing` 项目模板。在开始模糊测试之前，请移除项目模板与 fork 之间的关系：

1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**高级**。
1. 在**移除 fork 关系**部分，选择**移除 fork 关系**。
   出现提示时，输入项目名称。

您的项目已准备就绪，现在可以创建模糊测试了。接下来，您将创建模糊测试目标。

<a id="create-the-fuzz-targets"></a>

## 创建模糊测试目标

现在您已有一个用于模糊测试的项目，可以创建模糊测试目标了。模糊测试目标是一个函数或程序，它接收输入，并调用正在测试的应用程序。

在本教程中，模糊测试目标使用随机缓冲区作为参数，调用 `my-tools.js` 文件中的一个函数。

要创建这两个模糊测试目标文件：

1. 在顶部栏中，选择**搜索或跳转到**，找到 `fuzz-testing-demo` 项目。
1. 在项目的根目录中创建一个文件。
1. 将文件命名为 `fuzz-sayhello.js`，并添加以下代码：

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

   您也可以从 `fuzz-testing-demo/fuzzers/fuzz-sayhello.js`
   项目文件中复制此代码。
1. 将**目标分支**命名为 `add-fuzz-test`，并编写一条描述性的提交信息。
   - 暂时不要选中**使用这些更改启动新的合并请求**复选框。
1. 选择**提交更改**。
1. 返回项目的根目录。
1. 确保您位于 `add-fuzz-test` 分支。
1. 创建第二个文件，命名为 `fuzz-readme.js`，并添加以下代码：

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

   您也可以从 `fuzz-testing-demo/fuzzers/fuzz-readme.js`
   项目文件中复制此代码。
1. 编写一条描述性的提交信息。
1. 确保**目标分支**为 `add-fuzz-test`。
1. 选择**提交更改**。

现在您有两个模糊测试目标，可以调用正在测试的应用程序了。接下来，您将启用模糊测试。

<a id="enable-coverage-guided-fuzz-testing"></a>

## 启用覆盖率引导的模糊测试

要启用覆盖率引导的模糊测试，请创建一个 CI/CD 流水线，运行
`gitlab-cov-fuzz` CLI，对这两个模糊测试目标执行模糊测试。

要创建流水线文件：

1. 确保您位于 `add-fuzz-test` 分支。
1. 在 `fuzz-testing-demo` 项目的根目录中，创建一个新文件。
1. 将文件命名为`.gitlab-ci.yml`，并添加以下代码：

   ```yaml
   default:
     image: node:18

   stages:
     - fuzz

   include:
     - template: Coverage-Fuzzing.gitlab-ci.yml

   readme_fuzz_target:
     extends: .fuzz_base
     tags: [saas-linux-large-amd64] # Optional
     variables:
       COVFUZZ_ADDITIONAL_ARGS: '--fuzzTime=60'
     script:
       - npm config set @gitlab-org:registry https://gitlab.com/api/v4/packages/npm/ && npm i -g @gitlab-org/jsfuzz
       - ./gitlab-cov-fuzz run --engine jsfuzz -- fuzz-readme.js

   hello_fuzzing_target:
     extends: .fuzz_base
     tags: [saas-linux-large-amd64] # Optional
     variables:
       COVFUZZ_ADDITIONAL_ARGS: '--fuzzTime=60'
     script:
       - npm config set @gitlab-org:registry https://gitlab.com/api/v4/packages/npm/ && npm i -g @gitlab-org/jsfuzz
       - ./gitlab-cov-fuzz run --engine jsfuzz -- fuzz-sayhello.js
   ```

   此步骤会向您的流水线添加以下内容：
   - 一个使用模板的 `fuzz` 阶段。
   - 两个作业：`readme_fuzz_target` 和 `hello_fuzzing_target`。每个作业都使用
     `jsfuzz` 引擎运行，该引擎会将未处理的异常报告为崩溃。

   您也可以从 `fuzz-testing-demo/fuzzers/fuzzers.yml`
   项目文件中复制此代码。

1. 编写一条描述性的提交信息。
1. 确保**目标分支**为 `add-fuzz-test`。
1. 选择**提交更改**。

您已成功启用覆盖率引导的模糊测试。接下来，您将使用刚刚创建的流水线运行模糊测试。

<a id="run-the-fuzz-test"></a>

## 运行模糊测试

要运行模糊测试：

1. 在左侧边栏中，选择**代码** > **合并请求**。
1. 选择**新建合并请求**。
1. 在**源分支**部分，选择 `add-fuzz-test` 分支。
1. 在**目标分支**部分，确保已选择您的命名空间和 `main` 分支。
1. 选择**比较分支并继续**。
1. [创建合并请求](../../user/project/merge_requests/creating_merge_requests.md)。

创建合并请求会触发一条新的流水线，该流水线会运行模糊测试。当流水线运行完成后，您应该会在合并请求页面上看到一个安全漏洞警报。

要查看每个漏洞的更多信息，请选择各自的 **未捕获异常** 链接。

您已成功运行模糊测试，并识别出需要修复的漏洞。

<a id="fix-the-vulnerabilities"></a>

## 修复漏洞

模糊测试识别出两个安全漏洞。要修复这些漏洞，您需要使用 `my-tools.js` 库。

要创建 `my-tools.js` 文件：

1. 确保您位于项目的 `add-fuzz-test` 分支。
1. 转到项目的根目录，打开 `my-tools.js` 文件。
1. 将此文件的内容替换为以下代码：

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

   您也可以从 `fuzz-testing-demo/javascript/my-tools.js`
   项目文件中复制此代码。
1. 选择**提交更改**。这会触发另一条流水线，运行另一次模糊测试。
1. 当流水线完成后，查看合并请求的**概览**页面。您
   应该会看到安全扫描未检测到新的潜在漏洞。
1. 合并您的更改。

恭喜，您已成功运行模糊测试，并修复了识别出的安全漏洞！

有关更多信息，请参阅[覆盖率引导的模糊测试](../../user/application_security/coverage_fuzzing/_index.md)。

<!--- end_remove -->
