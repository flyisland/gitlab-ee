---
stage: AI-powered
group: AI Framework
info: This page is maintained by Developer Relations, author @dnsmichi, see <https://handbook.gitlab.com/handbook/marketing/developer-relations/developer-advocacy/content/#maintained-documentation>
description: AI-native features and functionality.
title: 极狐GitLab Duo 用例
---

以下用例提供了使用 极狐GitLab Duo 的实践示例、练习和工作流。
学习如何：

- 重构现有源代码。
- 使用 极狐GitLab Duo 根因分析排查失败的作业。
- 解决安全漏洞。

> [!note]
> 如果你使用私有化部署版 极狐GitLab：极狐GitLab Duo 需要 极狐GitLab 17.2 及更高版本以获得最佳用户体验和效果。早期版本可能仍可运行，但体验可能会有所下降。

<a id="use-gitlab-duo-to-solve-development-challenges"></a>

## 使用 极狐GitLab Duo 解决开发挑战

<a id="start-with-a-c-application"></a>

### 从 C# 应用程序开始

在这些示例中，打开你的 C# IDE，确保[已启用 极狐GitLab Duo](turn_on_off.md)，
并探索如何使用 极狐GitLab Duo 的 AI 原生功能提高效率。

<a id="cli-tool-for-querying-the-gitlab-rest-api"></a>

#### 用于查询 GitLab REST API 的 CLI 工具

挑战是创建一个用于查询 GitLab REST API 的 CLI 工具。

- 询问 极狐GitLab Duo Chat 如何启动一个新的 C# 项目，并学习如何使用 dotNET CLI：

  ```markdown
  如何在 VS Code 中开始创建一个空的 C# 控制台应用程序？
  ```

- 使用代码建议通过新的代码注释生成 REST API 客户端：

  ```c#
  // 连接到 REST API 并打印响应
  ```

- 生成的源代码可能需要解释：使用代码任务 `/explain`
  了解 REST API 调用是如何工作的。

从代码建议注释生成源代码后，你需要配置 CI/CD。

- Chat 可以帮助你了解 C# 的 `.gitignore` 文件的最佳实践：

  ```markdown
  展示一个 C# 项目的 .gitignore 和 .gitlab-ci.yml 配置。
  ```

- 如果你的 CI/CD 作业失败，使用根因分析[排查失败的 CI/CD 作业](../gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis)。
  或者，你可以将错误消息复制到
  极狐GitLab Duo Chat 中，并寻求帮助：

  ```markdown
  解释这个 CI/CD 错误：The current .NET SDK does not support targeting
  .NET 8.0
  ```

- 为了稍后创建测试，让 极狐GitLab Duo 使用代码任务 `/refactor` 将
  所选代码重构为一个函数。

- Chat 还可以解释编程语言特定的关键字和函数，或 C#
  编译器错误。

  ```markdown
  你能用实际示例解释 C# 中的 async 和 await 吗？

  解释错误 CS0122：'Program' 由于其保护级别而无法访问
  ```

- 使用 `/tests` 代码任务生成测试。

下一个问题是在 C# 解决方案中将生成的测试放在哪里。
作为初学者，你可能不知道应用程序和测试项目必须位于同一
解决方案级别以避免导入问题。

- 极狐GitLab Duo Chat 可以通过提问和优化提示问题来提供帮助：

  ```markdown
  在 C# 和 VS Code 中，如何从测试项目添加对项目的引用？

  提供我可以添加到 C# .csproj 文件中的 XML 配置，以添加对现有解决方案中另一个项目的引用？
  ```

- 有时，你必须优化提示以获得更好的结果。提示
  `/refactor into the public class` 会创建一个代码提案，该代码稍后可以从测试项目访问。

  ```markdown
  /refactor into the public class
  ```

- 你还可以使用 `/refactor` 代码任务让 Chat 说明如何在
  `.gitlab-ci.yml` 文件中执行测试。

  ```markdown
  /refactor 添加一个作业来运行测试（测试项目）
  ```

资源：

- [包含源代码的项目](https://gitlab.com/gitlab-da/use-cases/ai/gitlab-duo-coffee-chat/gitlab-duo-coffee-chat-2024-01-29)

<a id="improve-a-c-application"></a>

### 改进 C++ 应用程序

<a id="refactor-a-c-application-with-sqlite"></a>

#### 使用 SQLite 重构 C++ 应用程序

在此示例中，存在一个包含单个 main 函数的现有源代码。它重复代码，且无法测试。

要将源代码重构为可重用和可测试的函数：

1. 打开已启用 极狐GitLab Duo 的 VS Code 或 Web IDE。
1. 选择源代码，并使用优化后的提示要求 极狐GitLab Duo Chat 将其重构为函数：

   ```markdown
   /refactor into functions
   ```

   此重构步骤可能不适用于整个选定的源代码。

1. 将重构策略拆分为功能块。
   例如，迭代数据库中的所有插入、更新和删除操作。

1. 要为新创建的函数生成测试，再次选择源代码并
   使用代码任务 `/tests`。包含针对测试框架的具体指令提示：

   ```markdown
   /tests 使用 CTest 测试框架
   ```

1. 如果你的应用程序改用 `Boost.Test` 框架，请优化提示：

   ```markdown
   /tests 使用 Boost.Test 框架
   ```

资源：

- [包含源代码的项目](https://gitlab.com/gitlab-da/use-cases/ai/gitlab-duo-coffee-chat/gitlab-duo-coffee-chat-2024-01-09)

<a id="refactor-c-functions-into-object-oriented-code"></a>

#### 将 C++ 函数重构为面向对象的代码

在此示例中，现有源代码已被包装成函数。
为了将来支持更多数据库类型，必须将代码重构为类和对象继承。

<a id="start-working-on-the-class"></a>

##### 开始处理类

- 询问 极狐GitLab Duo Chat 如何为基数据库类实现面向对象的模式，并在 SQLite 类中继承它：

  ```markdown
  解释一个使用基类的通用数据库实现，以及使用 C++ 的 SQLite 特定类。提供源代码示例和要遵循的步骤。
  ```

- 学习曲线包括询问 极狐GitLab Duo Chat 关于纯虚函数和实现类中的虚函数覆盖。

  ```markdown
  什么是纯虚函数，继承该类的开发者需要做什么？
  ```

- 代码任务可以帮助重构代码。选择 C++ 头文件中的函数，并使用优化后的提示：

  ```markdown
  /refactor 成一个具有公共函数和私有 path/db 属性的类。从基类 DB 继承

  /refactor 成一个具有纯虚函数的基类，名为 DB。移除 SQLite 特定部分。
  ```

- 极狐GitLab Duo Chat 还指导构造函数重载、对象初始化以及使用共享指针优化内存管理。

  ```markdown
  如何在 cpp 文件中向类添加函数实现？

  如何通过类构造函数调用将值传递给类属性？
  ```

<a id="find-better-answers"></a>

##### 找到更好的答案

- 以下问题没有提供足够的上下文。

  ```markdown
  我应该使用 virtual override 而不是只使用 override 吗？
  ```

- 相反，尝试添加更多上下文以获得更好的答案。

  ```markdown
  在继承类中实现纯虚函数时，我应该使用 virtual function override，还是只使用 function override？上下文是 C++。
  ```

- 一个相对复杂的问题涉及如何从新创建的类实例化对象，并调用特定函数。

  ```markdown
  如何在 C++ 中从类实例化对象，使用 SQLite DB 路径调用构造函数并调用函数。优先使用指针。
  ```

- 结果可能有用，但需要针对共享指针和所需的源代码头文件进行优化。

  ```markdown
  如何在 C++ 中从类实例化对象，使用 SQLite DB 路径调用构造函数并调用函数。优先使用共享指针。解释需要哪些头文件包含。
  ```

- 代码建议有助于生成 `std::shared_ptr` 指针运算的正确语法，并帮助提高代码质量。

  ```c++
  // 将 SQLite 路径定义为一个变量，默认值为 database.db

  // 为 SQLite 类创建一个共享指针

  // 使用 OpenConnection 打开数据库连接
  ```

<a id="refactor-your-code"></a>

##### 重构你的代码

- 重构源代码后，可能会出现编译器错误。让 Chat 解释它们。

  ```markdown
  解释错误：`db` 是 `SQLiteDB` 的私有成员
  ```

- 应将一个特定的 SQL 查询字符串重构为多行字符串，以便更高效地编辑。

  ```c++
  std::string sql = "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, email TEXT NOT NULL)";
  ```

- 选择源代码，并使用 `/refactor` 代码任务：

  ```markdown
  /refactor 成一个多行的 stringstream
  ```

- 你还可以将实用函数重构为 C++ 中具有静态函数的类，然后询问 Chat 如何调用它们。

  ```markdown
  /refactor 成一个提供静态函数的类

  如何调用类中的静态函数？
  ```

重构源代码后，为更多数据库类型奠定了基础，整体代码质量得到提高。

资源：

- [包含源代码的项目](https://gitlab.com/gitlab-da/use-cases/ai/gitlab-duo-coffee-chat/gitlab-duo-coffee-chat-2024-01-23)

<a id="explain-test-and-refactor-a-kotlin-application"></a>

### 解释、测试和重构 Kotlin 应用程序

在此示例中，必须分析来自 [Kotlin 代码生成提示](use_cases.md#kotlin-code-generation-prompts)的冒险应用程序，并通过重构和测试进行改进。

当前源代码如下所示：

```kotlin
package org.example

// 创建一个文本冒险
// 寻找金色乐高积木
// 添加视觉辅助
// 使用随机计时器陷阱导致游戏结束
// 创建一个文本冒险
fun createTextAdventure() {
    println("欢迎来到金色乐高积木冒险！")
    println("你发现自己在一个昏暗的房间里。你打算做什么？")

    var gameOver = false
    while (!gameOver) {
        println("1. 寻找金色乐高积木")
        println("2. 检查房间")
        println("3. 退出")

        val choice = readLine()?.toIntOrNull() ?: 0
        when (choice) {
            1 -> searchForBrick()
            2 -> examineRoom()
            3 -> {
                println("再见！")
                gameOver = true
            }
            else -> println("无效选择。请重试。")
        }
    }
}

fun searchForBrick() {
    println("你仔细搜索房间，寻找金色乐高积木的任何迹象。")
    if (Math.random() < 0.2) {
        println("恭喜！你找到了金色乐高积木！")
    } else {
        println("你的搜索一无所获。你必须再试一次。")
    }
}

fun examineRoom() {
    println("你环顾房间，观察细节。")
    println("房间光线昏暗，角落里有阴影。")
    println("北边有一扇门，房间中央有一张桌子。")
}

fun main() {
    createTextAdventure()
}
```

1. 在 IDE 中选择源代码，然后右键单击让 极狐GitLab Duo Chat 解释代码。
1. 优化提示以了解更多关于错误、优化技巧或漏洞的信息：

   ```markdown
   /explain 关注错误和改进

   提供的代码是用 Kotlin 编写的一个简单的文本冒险游戏。它允许用户搜索金色乐高积木或检查房间。虽然代码可以运行，但存在一些潜在的错误和改进领域：

   1. 潜在错误：

   searchForBrick() 函数使用 Math.random() 来确定玩家是否找到了金色乐高积木。但是，此函数没有处理玩家找到积木的情况。即使玩家找到了积木，游戏也会无限期地继续下去。

   2. 改进：

   游戏结束条件：当玩家找到金色乐高积木时，游戏应该有一个适当的游戏结束条件。这可以通过引入一个布尔标志或一个单独的游戏状态来跟踪积木是否已被找到来实现。
   ```

1. 使用 `/tests` 命令要求 Chat 为所选代码生成测试：

   ```markdown
   /tests

   要测试代码，你可以使用 Kotlin 的 JUnit。以下是一些你可以编写的测试：

     import org.junit.jupiter.api.Test
     import java.io.ByteArrayInputStream
     import java.io.ByteArrayOutputStream
     import java.io.PrintStream

     class TextAdventureTest {

         private val standardOut = System.out
         private val standardIn = System.`in`

         @Test
         fun `test searchForBrick success`() {
             val outContent = ByteArrayOutputStream()
             System.setOut(PrintStream(outContent))

             searchForBrick()

             val output = outContent.toString().trim()
             assert(output.contains("恭喜！你找到了金色乐高积木！"))

             System.setOut(standardOut)
         }

      ...
     }
   ```

在确保所有内容都经过测试后，要求 Chat 重构所选代码：

```markdown
/refactor 修复错误，改善用户体验

...

改进：

将菜单打印逻辑提取到一个单独的 printMenu 函数中，以获得更好的代码组织和可读性。
使用 Random.nextDouble() 代替 Math.random()，以更好地兼容 Kotlin 标准库。
在打印菜单后添加了提示，让用户输入他们的选择。
移除了不必要的 gameOver 变量初始化，因为它已经在 createTextAdventure 函数中被赋值。
在 searchForBrick 函数中添加了一条注释，提醒你在需要时添加额外的逻辑或游戏结束条件。
这些更改应能提高代码的可读性、可维护性和用户体验。
```

重构后的源代码可能如下所示：

```kotlin
package org.example

import kotlin.random.Random

// 创建一个文本冒险
// 寻找金色乐高积木
// 添加视觉辅助
// 使用随机计时器陷阱导致游戏结束
// 创建一个文本冒险
fun createTextAdventure() {
    println("欢迎来到金色乐高积木冒险！")
    println("你发现自己在一个昏暗的房间里。你打算做什么？")

    var gameOver = false
    while (!gameOver) {
        printMenu()
        val choice = readLine()?.toIntOrNull()
        when (choice) {
            1 -> searchForBrick()
            2 -> examineRoom()
            3 -> {
                println("再见！")
                gameOver = true
            }
            else -> println("无效选择。请重试。")
        }
    }
}

fun printMenu() {
    println("1. 寻找金色乐高积木")
    println("2. 检查房间")
    println("3. 退出")
    print("输入你的选择：")
}

fun searchForBrick() {
    println("你仔细搜索房间，寻找金色乐高积木的任何迹象。")
    if (Random.nextDouble() < 0.2) {
        println("恭喜！你找到了金色乐高积木！")
        // 在此处添加额外的逻辑或游戏结束条件
    } else {
        println("你的搜索一无所获。你必须再试一次。")
    }
}

fun examineRoom() {
    println("你环顾房间，观察细节。")
    println("房间光线昏暗，角落里有阴影。")
    println("北边有一扇门，房间中央有一张桌子。")
}

fun main() {
    createTextAdventure()
}
```

<a id="get-started-with-powershell"></a>

### 开始使用 PowerShell

> [!note]
> PowerShell 支持是[实验性的](../project/repository/code_suggestions/supported_extensions.md#add-support-for-more-languages)。

1. 使用 极狐GitLab Duo Chat 询问如何开始编写一个打印当前目录文件大小的 PowerShell 脚本。

   ```markdown
   如何开始编写一个打印当前目录文件大小的 PowerShell 脚本？
   ```

   或者，你可以使用代码建议生成源代码。

1. 创建一个新脚本 `get-file-sizes.ps1`，内容如下：

   ```powershell
   # 收集目录中的文件并打印其大小
   ```

1. 等待代码建议完成提示，然后添加以下提示以
   尝试不同的输出格式：

   ```powershell
   # 收集目录中的文件并打印其大小

   $directory = Read-Host -Prompt "输入要获取文件大小的目录路径"
   $files = Get-ChildItem -Path $directory -File
   foreach ($file in $files) {
       $fileSize = [Math]::Round(($file.Length / 1KB), 2)
       Write-Host "$($file.Name) - $fileSize KB"
   }

   # 重复上面的代码，但将结果存储在 CSV 文件中
   ```

1. 使用不同导出格式的提示重复这些步骤，
   或使用代码建议自动完成。例如：

   ```powershell
   # 收集目录中的文件并打印其大小

   $directory = Read-Host -Prompt "输入要获取文件大小的目录路径"
   $files = Get-ChildItem -Path $directory -File
   foreach ($file in $files) {
       $fileSize = [Math]::Round(($file.Length / 1KB), 2)
       Write-Host "$($file.Name) - $fileSize KB"
   }

   # 重复上面的代码，但将结果存储在 CSV 文件中
   $csvFile = "$directory\file-sizes.csv"
   $fileData = foreach ($file in $files) {
       [PSCustomObject]@{
           FileName = $file.Name
           FileSize = [Math]::Round(($file.Length / 1KB), 2)
       }
   }
   $fileData | Export-Csv -Path $csvFile -NoTypeInformation
   Write-Host "文件大小已保存到 $csvFile"

   # 重复上面的代码，但将结果存储在 JSON 文件中
   $jsonFile = "$directory\file-sizes.json"
   $fileData | ConvertTo-Json | Out-File -FilePath $jsonFile
   Write-Host "文件大小已保存到 $jsonFile"

   # 重复上面的代码，但将结果存储在 XML 文件中
   $xmlFile = "$directory\file-sizes.xml"
   $fileData | ConvertTo-Xml -NoTypeInformation | Out-File -FilePath $xmlFile
   Write-Host "文件大小已保存到 $xmlFile"

   # 重复上面的代码，但将结果存储在 HTML 文件中
   $htmlFile = "$directory\file-sizes.html"
   $fileData | ConvertTo-Html -Property FileName, FileSize | Out-File -FilePath $htmlFile
   Write-Host "文件大小已保存到 $htmlFile"

   # 重复上面的代码，但将结果存储在 TXT 文件中
   $txtFile = "$directory\file-sizes.txt"
   $fileData | Out-File -FilePath $txtFile
   Write-Host "文件大小已保存到 $txtFile"
   ```

<a id="explain-and-resolve-vulnerabilities"></a>

## 解释和解决漏洞

<a id="vulnerabilities-in-c-code"></a>

### C 代码中的漏洞

在此示例中，应借助 极狐GitLab Duo 修复 C 语言中检测到的安全漏洞。

[此源代码片段](https://gitlab.com/gitlab-da/use-cases/ai/gitlab-duo-coffee-chat/gitlab-duo-coffee-chat-2024-01-30/-/blob/4685e4e1c658565ae956ad9befdfcc128e60c6cf/src/main-vulnerable-source.c)
引入了一个[缓冲区溢出](https://en.wikipedia.org/wiki/Buffer_overflow)的安全漏洞：

```c
    strcpy(region, "Hello GitLab Duo Vulnerability Resolution challenge");

    printf("Contents of region: %s\n", region);
```

[SAST 安全扫描器](../application_security/sast/_index.md)可以检测并报告问题。使用[漏洞解释](../application_security/analyze/duo.md)来理解问题。
漏洞解决有助于生成 MR。
如果建议的更改不符合要求，或可能导致问题，你可以使用代码建议和 Chat 进行优化。例如：

1. 打开已启用 极狐GitLab Duo 的 VS Code 或 Web IDE，并添加一条带指令的注释：

   ```c
       // 避免潜在的缓冲区溢出

       // 下面可能是 AI 生成的代码
       strncpy(region, "Hello GitLab Duo Vulnerability Resolution challenge", pagesize);
       region[pagesize-1] = '\0';
       printf("Contents of region: %s\n", region);
   ```

1. 删除建议的代码，并使用不同的注释来使用替代方法。

   ```c
       // 使用 snprintf() 避免潜在的缓冲区溢出

       // 下面可能是 AI 生成的代码
       snprintf(region, pagesize, "Hello GitLab Duo Vulnerability Resolution challenge");

       printf("Contents of region: %s\n", region);
   ```

1. 使用 极狐GitLab Duo Chat 提问。`/refactor` 代码任务可以生成不同的建议。
   如果你更喜欢特定的算法或函数，请优化提示：

   ```markdown
   /refactor 使用 snprintf
   ```

资源：

- 包含源代码的项目：[极狐GitLab Duo Coffee Chat 2024-01-30 - 漏洞解决挑战](https://gitlab.com/gitlab-da/use-cases/ai/gitlab-duo-coffee-chat/gitlab-duo-coffee-chat-2024-01-30)

<a id="answer-questions-about-gitlab"></a>

## 回答关于 GitLab 的问题

在此示例中，挑战是使用 极狐GitLab Duo Chat 解决问题。

- 你可以使用 极狐GitLab Duo Chat 解释 CI/CD 错误。

  ```markdown
  解释这个 CI/CD 错误：build.sh: line 14: go command not found
  ```

- 当你没有耐心，只输入一两个词时会发生什么？

  ```markdown
  labels

  issue labels
  ```

  极狐GitLab Duo Chat 会要求提供更多上下文。

- 将你的问题优化成一个完整的句子，描述问题并寻求解决方案。

  ```markdown
  解释 GitLab 中的标签。提供一个高效使用的示例。
  ```

资源：

- [包含源代码的项目](https://gitlab.com/gitlab-da/use-cases/ai/gitlab-duo-coffee-chat/gitlab-duo-coffee-chat-2024-02-01)

<a id="root-cause-analysis-use-cases"></a>

## 根因分析用例

使用根因分析来确定 CI/CD
作业失败的根本原因。以下示例说明了常见错误，并
鼓励你 fork 并练习查找和修复根本原因。

有关更多信息，请参阅博客文章[开发 极狐GitLab Duo：融合 AI 和根因分析来修复 CI/CD 流水线](https://gitlab.cn/blog/developing-gitlab-duo-blending-ai-and-root-cause-analysis-to-fix-ci-cd/)。

<a id="analyze-missing-go-runtime"></a>

### 分析缺失的 Go 运行时

CI/CD 作业可以在容器中执行，这些容器从贡献的 `image`
属性生成。如果容器未提供编程语言运行时，
则引用 `go` 二进制文件的已执行 `script` 部分会失败。例如，
错误消息 `/bin/sh: eval: line 149: go: not found` 必须被理解
并修复。如果在容器的运行时上下文中找不到 `go` 命令，
可能由多种原因导致：

- 作业使用了像 `alpine` 这样的最小容器镜像，并且 Go 语言
  运行时未安装。
- 作业使用了在 CI/CD 配置中指定的错误默认容器镜像，
  或使用了 `default` 关键字。
- 作业使用了 shell 执行器而不是容器镜像。主机操作系统
  已损坏，未安装 Go 语言运行时，或未配置。

项目[挑战：根因分析 - Go GitLab Release Fetcher](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-challenges/root-cause-analysis/challenge-root-cause-analysis-go-gitlab-release-fetcher)
提供了一个练习，用于分析和修复 Go Tanuki 应用程序的 CI/CD 问题。在此练习中，
`build` 和 `docker-build` 作业失败。当你修复
问题后，CI/CD 流水线成功，并且 `build` 作业打印输出。
`solution/` 目录提供了两种可能的解决方案。

<a id="use-gitlab-duo-to-contribute-to-gitlab"></a>

## 使用 极狐GitLab Duo 为 GitLab 做贡献

极狐GitLab Duo 的使用重点是为 GitLab 代码库做贡献，以及客户如何更高效地贡献。

GitLab 代码库很大，需要理解有时复杂的算法或特定于应用程序的实现。

<a id="contribute-to-frontend-profile-settings"></a>

### 为前端做贡献：个人资料设置

在此示例中，挑战是更新 GitLab 个人资料页面并改进社交网络设置。

你可以使用 极狐GitLab Duo Chat 来解释和重构代码，并生成测试。
代码建议有助于完成现有代码，并可以生成 Ruby、Go 或 VueJS 中的新函数和算法。

1. 使用 `/explain` 代码任务来解释选定的代码部分，并学习 HAML 模板如何工作。
1. 你可以优化代码任务提示，转而询问 `/explain HAML 渲染是如何工作的`
您也可以直接在聊天提示框中输入，例如：

```markdown
如何在 HAML 中填充下拉框
```

重构示例包含以下步骤：

1. `/refactor 重构为 HAML 下拉框`
2. 在检查现有 UI 表单代码后，将提示细化为 `/refactor 重构为带有表单下拉框的 HAML 下拉框`

极狐GitLab Duo Chat 帮助进行了错误调试，提示了错误消息：

```markdown
解释这个错误：undefined method `icon` for
```

## 代码生成提示

以下示例为[极狐GitLab Duo 支持的编程语言](../project/repository/code_suggestions/supported_extensions.md)提供了[代码生成](../project/repository/code_suggestions/_index.md#代码生成最佳实践)的提示。
你可以使用多行注释来细化代码生成提示。

这些示例存储在[极狐GitLab Duo Prompts 项目](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts)中，
由 Developer Relations 团队维护。这些示例均经过测试验证有效。你应该根据自身环境审阅并调整它们。

### C 语言代码生成提示

创建一个 Linux 统计工具，用于收集 IO、性能、磁盘使用和 TCP 延迟信息，
并打印输出。完整示例可参阅博客文章[《使用极狐GitLab Duo 进行高效 AI 驱动代码建议的最佳实践》](https://gitlab.cn/blog/top-tips-for-efficient-ai-powered-code-suggestions-with-gitlab-duo/#code-suggestions-flow-with-comments)。

```c
// 创建 Linux 统计工具
// 收集 IO、性能、磁盘使用、TCP 延迟
// 打印摘要

// 导入所需头文件
#include <sys/stat.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <sys/statfs.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/time.h>


int main() {
    struct stat statbuf;

    if (stat("/etc", &statbuf) != 0) {
        perror("stat");
        return 1;
    }

    printf("IO 块大小：%ld\n", statbuf.st_blksize);

    // TODO：添加 CPU 使用率、磁盘使用率、网络延迟测量

```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `c` 目录](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/c?ref_type=heads)找到。

### C++ 代码生成提示

创建一个作为 HTTP 客户端的命令行应用。

```c++
// 创建 HTTP 客户端 CLI 应用
// 创建主函数
// 包含所有头文件
// 读取程序选项：URL、API 端点、基本认证

#include <iostream>
#include <curl/curl.h>
#include <string>

int main(int argc, char** argv) {
  std::string url;
  std::string endpoint;
  std::string username;
  std::string password;

  // 解析命令行选项
  // ...

  CURL* curl = curl_easy_init();
  if(curl) {
    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());

    // 设置基本认证
    curl_easy_setopt(curl, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
    curl_easy_setopt(curl, CURLOPT_USERPWD, (username + ":" + password).c_str());

    CURLcode res = curl_easy_perform(curl);

    if(res != CURLE_OK) {
      std::cerr << "请求失败：" << curl_easy_strerror(res) << std::endl;
    }

    curl_easy_cleanup(curl);
  }

  return 0;
}
```

创建一个用于管理分布式文件节点的应用。

```c++
// 创建管理分布式文件节点的应用
// 提供节点健康状态的概览
// 使用面向对象模式定义基础文件节点
// 添加从基础文件节点继承的特定文件系统

class FileNode {
public:
    std::string name;
    std::string ipAddress;
    int port;
    HealthState healthState;

    FileNode(std::string name, std::string ipAddress, int port)
        : name(name), ipAddress(ipAddress), port(port), healthState(HealthState::Healthy) {}

    void setHealthState(HealthState state) {
        healthState = state;
    }
};

class LocalFileNode : public FileNode {
public:
    std::string mountPoint;

    LocalFileNode(std::string name, std::string mountPoint)
        : FileNode(name, "127.0.0.1", 0), mountPoint(mountPoint) {}
};

class NetworkFileNode : public FileNode {
public:
    std::string user;
    std::string password;

    NetworkFileNode(std::string name, std::string ipAddress, int port, std::string user, std::string password)
        : FileNode(name, ipAddress, port), user(user), password(password) {}
};

int main(){

}
```

创建一个 eBPF 程序，附加到 `XDP` 内核事件以测量网络流量。
仅在 Linux 内核上有效。

```c++
// 创建附加到 XDP 内核事件的 eBPF 程序
// 按 IP 地址统计所有数据包
// 打印摘要
// 包含必要的头文件

#include <bpf/bpf.h>

struct data {
    __uint(type, BPF_MAP_TYPE_PERCPU_ARRAY);
    __type(key, uint32_t);
    __type(value, uint64_t);
};

BPF_TABLE("array", int, long, counts, 1024);

int xdp_prog(struct xdp_md *ctx) {
    void* data_end = (void*)(long)ctx->data_end;
    void* data = (void*)(long)ctx->data;
    struct ethhdr *eth = data;

    if ((void*)eth + sizeof(*eth) <= data_end) {
        struct iphdr *ip = data + sizeof(*eth);
        if ((void*)ip + sizeof(*ip) <= data_end) {
            counts.increment(ip->saddr);
        }
    }

    return XDP_PASS;
}
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `c++` 目录](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/c%2B%2B?ref_type=heads)找到。

### `C#` 代码生成提示

创建一个从不同传感器收集数据的医疗分析器应用，并将数据存储在 `MSSQL` 中。

```c#
// 创建医疗分析器应用
// 从不同传感器收集数据
// 将数据存储到 MSSQL
// 提供访问传感器数据的方法

using System.Data.SqlClient;

namespace MedicalAnalyzer
{
    public class SensorDataStore
    {
        private SqlConnection connection;

        public SensorDataStore()
        {
            // 创建 SQL Server 连接
            connection = new SqlConnection("connection string here");
        }

        public void StoreSensorData(SensorData data)
        {
            // 打开连接
            connection.Open();

            // 将传感器数据插入数据库
            var command = connection.CreateCommand();
            command.CommandText = "INSERT INTO SensorData (Timestamp, DeviceId, Value) " +
                                  "VALUES (@timestamp, @deviceId, @value)";
            command.Parameters.AddWithValue("@timestamp", data.Timestamp);
            command.Parameters.AddWithValue("@deviceId", data.DeviceId);
            command.Parameters.AddWithValue("@value", data.Value);
            command.ExecuteNonQuery();

            // 关闭连接
            connection.Close();
        }

        public SensorData[] GetSensorData(DateTime startTime, DateTime endTime)
        {
            // 查询数据库并返回结果
        }
    }
}
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `c#` 目录](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/c%23?ref_type=heads)找到。

### CSS 代码生成提示

```css
/* 创建彩虹动画的 CSS 类 */

@keyframes rainbow {
    0% {
        background-position: 0% 50%;
    }
    50% {
        background-position: 100% 50%;
    }
    100% {
        background-position: 0% 50%;
    }
}

.rainbow {
    background: linear-gradient(to right, #ff0000, #ff7700, #ffff00, #00ff00, #0000ff, #8b00ff);
    background-size: 600% 600%;
    animation: rainbow 30s ease infinite;
}
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `css` 目录](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/css?ref_type=heads)找到。

### Go 代码生成提示

创建一个 Kubernetes 可观测性应用，读取并打印集群中容器、Pod 和服务的状态。

```go
// 创建 Kubernetes 可观测性客户端
// 创建一个函数，功能如下：
// 从 KUBECONFIG 环境变量读取 Kubernetes 配置文件
// 创建 Kubernetes 上下文，默认命名空间
// 检查容器、Pod、服务状态并打印概览
// 导入必要的包
// 创建 main 包

package main

import (
  "context"
  "fmt"
  "os"

  "k8s.io/client-go/kubernetes"
  "k8s.io/client-go/tools/clientcmd"

  metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func main() {

  clientset := getClientset()
  namespace := "default"

  printPods(clientset, namespace)
  printServices(clientset, namespace)
  printContainers(clientset, namespace)

}

func getClientset() *kubernetes.Clientset {

  kubeconfig := os.Getenv("KUBECONFIG")

  config, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
  if err != nil {
    panic(err)
  }

  clientset, err := kubernetes.NewForConfig(config)
  if err != nil {
    panic(err)
  }

  return clientset
}

func printPods(clientset *kubernetes.Clientset, namespace string) {

  pods, err := clientset.CoreV1().Pods(namespace).List(context.TODO(), metav1.ListOptions{})
  if err != nil {
    panic(err)
  }

  fmt.Printf("在命名空间 %s 中有 %d 个 Pod\n", len(pods.Items), namespace)

}

func printServices(clientset *kubernetes.Clientset, namespace string) {

  services, err := clientset.CoreV1().Services(namespace).List(context.TODO(), metav1.ListOptions{})
  if err != nil {
    panic(err)
  }

  fmt.Printf("在命名空间 %s 中有 %d 个服务\n", len(services.Items), namespace)

}

// 创建打印 Containers 的函数
// 收集并打印数量
func printContainers(clientset *kubernetes.Clientset, namespace string) {

    pods, err := clientset.CoreV1().Pods(namespace).List(context.TODO(), metav1.ListOptions{})
    if err != nil {
        panic(err)
    }

    var totalContainers int
    for _, pod := range pods.Items {
        totalContainers += len(pod.Spec.Containers)
    }

    fmt.Printf("在命名空间 %s 中有 %d 个容器\n", totalContainers, namespace)

}
```

创建一个内存键值存储，类似于 Redis。完整介绍可参阅博客文章[《使用极狐GitLab Duo 进行高效 AI 驱动代码建议的最佳实践》](https://gitlab.cn/blog/top-tips-for-efficient-ai-powered-code-suggestions-with-gitlab-duo/#iterate-faster-with-code-generation)。

```go
// 创建内存键值存储，类似于 Redis
// 提供以下方法：
// 设置/取消键
// 更新值
// 带筛选的列表/打印
// 使用 BoltDB 作为外部库
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `go` 目录](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/go?ref_type=heads)找到。

### Java 代码生成提示

创建一个数据分析应用，使用不同的数据源获取指标。
提供数据查询和聚合的 API。

```java
// 创建数据分析应用
// 解析不同的输入源及其值
// 以列式格式存储指标
// 提供查询和聚合数据的 API
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `java` 目录](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/java?ref_type=heads)找到。

### JavaScript 代码生成提示

使用 ReactJS 为员工创建带日期时间选择器的带薪休假（PTO）应用。

```javascript
// 为用户创建带薪休假应用
// 在 ReactJS 中创建日期时间选择器
// 提供开始和结束选项
// 根据所选国家显示公共假期
// 将请求发送到服务器 API
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `javascript` 目录](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/javascript)找到。

### HTML 代码生成提示

```html
<!-- 创建 AI 知识库。
说明 AI 能如何辅助高效的 DevSecOps 工作流。
添加一个表格，包含一个 Dev、一个 Ops、一个 Sec 示例。
-->

<table>
  <tr>
    <th>Dev</th>
    <th>Ops</th>
    <th>Sec</th>
  </tr>
  <tr>
    <td>自动化测试与持续集成</td>
    <td>基础设施即代码与自动化配置</td>
    <td>静态代码分析与漏洞扫描</td>
  </tr>
</table>
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `html` 目录](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/html)找到。

### Kotlin 代码生成提示

生成一个文本冒险游戏，寻找宝藏。添加视觉辅助元素，并使用随机计时陷阱触发游戏结束。

```kotlin
package org.example

// 创建文本冒险游戏
// 寻找金色乐高积木
// 添加视觉辅助
// 使用随机计时陷阱触发游戏结束
// 创建文本冒险函数
fun createTextAdventure() {
    println("欢迎来到金色乐高积木冒险！")
    println("你发现自己身处一个昏暗的房间。你打算做什么？")

    var gameOver = false
    while (!gameOver) {
        println("1. 搜寻金色乐高积木")
        println("2. 检查房间")
        println("3. 退出")

        val choice = readLine()?.toIntOrNull() ?: 0
        when (choice) {
            1 -> searchForBrick()
            2 -> examineRoom()
            3 -> {
                println("再见！")
                gameOver = true
            }
            else -> println("无效选择，请重试。")
        }
    }
}

fun searchForBrick() {
    println("你仔细搜索房间，寻找金色乐高积木的任何踪迹。")
    if (Math.random() < 0.2) {
        println("恭喜！你找到了金色乐高积木！")
    } else {
        println("你的搜索一无所获。再试试吧。")
    }
}

fun examineRoom() {
    println("你环顾房间，观察细节。")
    println("房间光线昏暗，角落里有阴影。")
    println("北边有一扇门，房间中央有一张桌子。")
}

fun main() {
    createTextAdventure()
}
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `kotlin` 目录](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/kotlin?ref_type=heads)找到。

### PHP 代码生成提示

创建一个获取极狐GitLab 发布版本的 RSS 订阅源抓取器，允许按标题过滤。

```php
// 创建 Web 表单以显示极狐GitLab 发布版本
// 从 https://gitlab.cn/atom.xml 抓取 RSS 订阅源
// 提供按标题过滤的选项

$feedUrl = 'https://gitlab.cn/atom.xml';

$xml = simplexml_load_file($feedUrl);

$titleFilter = $_GET['titleFilter'];

echo '<h1>极狐GitLab 发布版本</h1>';
echo '<ul>';
foreach ($xml->entry as $entry) {
    $title = $entry->title;
    if (empty($titleFilter) || strpos($title, $titleFilter) !== false) {
        echo '<li>' . $title . '</li>';
    }
}
echo '</ul>';

```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `php` 目录](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/php)找到。

### PowerShell 代码生成提示

创建一个脚本，收集目录中的所有文件并打印其大小。
细化提示，将结果存储为 CSV 或 JSON 文件。

```powershell
# 收集目录中的文件并打印其大小

$directory = Read-Host -Prompt "输入要获取文件大小的目录路径"
$files = Get-ChildItem -Path $directory -File
foreach ($file in $files) {
    $fileSize = [Math]::Round(($file.Length / 1KB), 2)
    Write-Host "$($file.Name) - $fileSize KB"
}

# 重复上述代码，但将结果存入 CSV 文件

$csvFile = "$directory\file-sizes.csv"
$fileData = foreach ($file in $files) {
    [PSCustomObject]@{
        FileName = $file.Name
        FileSize = [Math]::Round(($file.Length / 1KB), 2)
    }
}
$fileData | Export-Csv -Path $csvFile -NoTypeInformation
Write-Host "文件大小已保存到 $csvFile"

# 重复上述代码，但将结果存入 JSON 文件

$jsonFile = "$directory\file-sizes.json"
$fileData | ConvertTo-Json | Out-File -FilePath $jsonFile
Write-Host "文件大小已保存到 $jsonFile"
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `powershell` 目录](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/powershell?ref_type=heads)找到。

### Python 代码生成提示

使用 Flask 创建一个 Web 服务器，通过 REST API 管理用户，并将用户存储在 SQLite 中。

```python
# 创建 Flask Web 服务器
# 添加用于按 ID 管理用户的 REST API 端点
# 实现创建、更新、删除功能
# 用户数据需存储在 SQLite 中，若不存在则创建表
# 在 8080 端口运行，支持 TLS
# 在注释中打印 requirements.txt 所需的包
# 默认使用 Python 3.10

# 以下为可能的 AI 生成代码
import flask
from flask import request
import sqlite3

app = flask.Flask(__name__)

# 创建 SQLite 数据库及用户表（如果不存在）
conn = sqlite3.connect('users.db')
conn.execute('''CREATE TABLE IF NOT EXISTS users
         (id INTEGER PRIMARY KEY, name TEXT, email TEXT)''')

@app.route('/users', methods=['POST'])
def create_user():
  # 从请求中获取用户数据
  name = request.form['name']
  email = request.form['email']

  # 将用户插入数据库
  conn.execute('INSERT INTO users (name, email) VALUES (?, ?)', (name, email))

  return '用户创建成功'

@app.route('/users/<int:id>', methods=['PUT'])
def update_user(id):
  # 从请求中获取用户数据
  name = request.form['name']
  email = request.form['email']

  # 更新数据库中的用户
  conn.execute('UPDATE users SET name = ?, email = ? WHERE id = ?', (name, email, id))

  return '用户更新成功'

@app.route('/users/<int:id>', methods=['DELETE'])
def delete_user(id):
  # 从数据库中删除用户
  conn.execute('DELETE FROM users WHERE id = ?', (id,))

  return '用户删除成功'

if __name__ == '__main__':
  # 所需包 - flask, sqlite3
  app.run(host='0.0.0.0', port=8080, ssl_context='adhoc')

```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `python` 目录](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/python?ref_type=heads)找到。

### Ruby 代码生成提示

创建一个日志解析器应用，将日志数据存储在 Elasticsearch 中。

```ruby
# 创建作为日志解析器的 Ruby 应用
# 提供钩子以替换日志行中的敏感字符串
# 格式化日志并将其存入 Elasticsearch

# 以下为可能的 AI 生成代码
require 'logger'
require 'elasticsearch'

class LogParser
  attr_reader :logger

  def initialize
    @logger = Logger.new(STDOUT)
    @elasticsearch = Elasticsearch::Client.new
  end

  def parse_and_store(logs)
    sanitized_logs = sanitize_logs(logs)
    formatted_logs = format_logs(sanitized_logs)
    store_in_elasticsearch(formatted_logs)
  end

  private

  def sanitize_logs(logs)
    logs.map { |line| sanitize_line(line) }
  end

  def sanitize_line(line)
    # 替换敏感数据
    line.gsub(/\d{16}/, '[已编辑]')
  end

  def format_logs(logs)
    logs.map { |line| "#{Time.now}: #{line}" }
  end

  def store_in_elasticsearch(logs)
    logs.each { |log| @elasticsearch.index(index: 'app-logs', document: log) }
  end
end
```

创建一个支持 syslog 格式（含严重级别、应用名称和消息字符串）的日志客户端工具类。

```ruby
# 创建日志工具类
# 将默认日志级别定义为属性
# 添加日志记录方法，输入：级别、应用、消息
# 以 syslog 格式打印带格式日期和时间的数据

# 以下为可能的 AI 生成代码
class Logging
  attr_accessor :log_level

  def log(level, app, message)
    time = Time.now.strftime("%b %d %H:%M:%S")
    puts "#{time} #{app}[#{Process.pid}]: #{level} - #{message}"
  end
end

# 实例化类并测试 log 方法

# 以下为可能的 AI 生成代码
logger = Logging.new
logger.log_level = :debug

logger.log(:info, 'MyApp', '应用已启动 - 信息')
logger.log(:debug, 'MyApp', '应用已启动 - 调试')
logger.log(:error, 'MyApp', '应用已启动 - 错误')
logger.log(:fatal, 'MyApp', '应用已启动 - 致命')
logger.log(:warn, 'MyApp', '应用已启动 - 警告')
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `ruby` 目录](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/ruby)找到。

### Rust 代码生成提示

```rust
// 查询极狐GitLab REST API
// 获取 gitlab-org/gitlab 的所有开放合并请求

use serde_json::Value;

fn main() {

    let client = reqwest::blocking::Client::new();
    let url = "https://jihulab.com/api/v4/projects/278964/merge_requests?state=opened";
    let response = client.get(url).send().unwrap().text().unwrap();
    let json: Value = serde_json::from_str(&response).unwrap();

    // TODO：分页，默认获取结果：20
    // 读取响应头以获取下一页

    println!("{}", json.to_string());

    for mr in json.as_array().unwrap() {
        println!("{} - URL：{}", mr["title"], mr["web_url"]);
    }
}
```

创建一个 RSS 源阅读器应用，示例来自博客文章[《借助 AI 学习高级 Rust 编程》](https://gitlab.cn/blog/learn-advanced-rust-programming-with-a-little-help-from-ai-code-suggestions/)。

```rust
    // 创建一个函数，遍历源数组
    // 并使用 HTTP 从 RSS 源条目中获取数据。
    // 将结果存储在新的哈希映射中。
    // 将哈希映射打印到终端。
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `rust` 目录](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/rust?ref_type=heads)找到。

### Scala 代码生成提示

```scala
// 实现牛顿法
// 创建一个带有 main 函数的对象
// 添加一个实现牛顿法求解方程的函数
// 添加一个测试所实现函数的驱动函数
object NewtonsMethod {
  def solveEquation(f: Double => Double, df: Double => Double, x0: Double, tolerance: Double): Double = {
    var x = x0
    var error = Double.PositiveInfinity
    while (math.abs(error) > tolerance) {
      error = f(x) / df(x)
      x -= error
    }
    x
  }

  def main(args: Array[String]): Unit = {
    val f: Double => Double = x => x * x - 4
    val df: Double => Double = x => 2 * x
    val x0 = 3.0
    val tolerance = 1e-6
    val root = solveEquation(f, df, x0, tolerance)
    println(s"根为：$root")
  }
}
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `scala` 目录](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/scala?ref_type=heads)找到。

### Shell 脚本代码生成提示

创建一个脚本 `mytop.sh`，按 CPU、内存和磁盘 I/O 使用情况显示排名前 10 的进程。
从第一条代码注释开始，让代码建议生成其余部分。

```shell
#!/bin/bash

# 获取 CPU 使用率前 10 的进程
top -b -n 1 | head -n 11 | awk '{print $1, $2, $3, $9}' | column -t

# 获取内存使用率前 10 的进程
top -b -n 1 | head -n 11 | awk '{print $1, $2, $4, $6}' | column -t

# 获取磁盘 I/O 前 10 的进程
top -b -n 1 | head -n 11 | awk '{print $1, $2, $7, $8}' | column -t

# 获取网络 I/O 前 10 的进程
top -b -n 1 | head -n 11 | awk '{print $1, $2, $10, $11}' | column -t

```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `shell` 目录](https://jihulab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/shell?ref_type=heads)找到。

### TypeScript 代码生成提示

创建一个解析 IPv6 和 IPv4 地址格式的工具函数。
```typescript
"use strict";
// 生成一个解析 IPv6 和 IPv4 地址格式的 TypeScript 函数
// 使用正则表达式
function parseAddress(address) {
    const ipv6Regex = /^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$/;
    const ipv4Regex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
    if (ipv6Regex.test(address)) {
        return {
            ipVersion: 6,
            address
        };
    }
    else if (ipv4Regex.test(address)) {
        return {
            ipVersion: 4,
            address
        };
    }
    else {
        throw new Error('Invalid IP address');
    }
}
// 使用随机输入测试该函数
const testInputs = [
    '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
    '192.168.0.1',
    'not-an-ip'
];
for (const input of testInputs) {
    try {
        const result = parseAddress(input);
        console.log(result);
    }
    catch (error) {
        console.error(`无效地址: ${input}`);
    }
}
```

AI 生成的源代码示例可在 [极狐GitLab Duo Prompts 项目中的 `typescript` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows/gitlab-duo-prompts/-/tree/main/code-suggestions/typescript?ref_type=heads) 中找到。