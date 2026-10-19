---
stage: AI Clients
group: Duo Chat
info: This page is maintained by Developer Relations, author @dnsmichi, see <https://handbook.gitlab.com/handbook/marketing/developer-relations/developer-advocacy/content/#maintained-documentation>
description: AI 原生特性和功能。
title: 极狐GitLab Duo 用例
---

以下用例提供了使用极狐GitLab Duo 的实用示例、练习和工作流。了解如何：

- 重构现有源代码。
- 使用极狐GitLab Duo 根因分析排查失败的作业。
- 解决安全漏洞。

> [!note]
> 如果您使用极狐GitLab 私有化部署：为获得最佳用户体验和结果，极狐GitLab Duo 需要极狐GitLab 17.2 及更高版本。更早的版本可能仍可继续使用，但体验可能会有所下降。

<a id="use-gitlab-duo-to-solve-development-challenges"></a>

## 使用极狐GitLab Duo 解决开发难题

<a id="start-with-a-c-application"></a>

### 从 C# 应用程序开始

在这些示例中，打开您的 C# IDE，确保[已启用极狐GitLab Duo](turn_on_off.md)，
并探索如何使用极狐GitLab Duo AI 原生特性来提高效率。

<a id="cli-tool-for-querying-the-gitlab-rest-api"></a>

#### 用于查询极狐GitLab REST API 的 CLI 工具


挑战在于创建一个用于查询极狐GitLab REST API 的 CLI 工具。

- 询问极狐GitLab Duo Chat 如何启动一个新的 C# 项目，并了解如何使用 dotNET CLI：

  ```markdown
  How can I get started creating an empty C# console application in VS Code?
  ```

- 使用代码建议，通过新的代码注释生成 REST API 客户端：

  ```c#
  // Connect to a REST API and print the response
  ```

- 生成的源代码可能需要解释。使用代码任务 `/explain`
  来深入了解 REST API 调用是如何工作的。

在通过代码建议注释生成源代码后，您需要配置 CI/CD。

- Chat 可以帮助提供 C# 的 `.gitignore` 文件最佳实践：

  ```markdown
  Show a .gitignore and .gitlab-ci.yml configuration for a C# project.
  ```

- 如果您的 CI/CD 作业失败，请使用根因分析来[排查失败的 CI/CD 作业](../gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis)。
  或者，您可以将错误消息复制到
  极狐GitLab Duo Chat 中，并寻求帮助：

  ```markdown
  Explain the CI/CD error: The current .NET SDK does not support targeting
  .NET 8.0
  ```

- 若要在稍后创建测试，请让极狐GitLab Duo 使用代码任务 `/refactor` 将
  所选代码重构为函数。

- Chat 还可以解释特定于编程语言的关键字和函数，或 C#
  编译器错误。

  ```markdown
  Can you explain async and await in C# with practical examples?

  explain error CS0122: 'Program' is inaccessible due to its protection level
  ```

- 使用 `/tests` 代码任务生成测试。

接下来的问题是，在 C# 解决方案中应将生成的测试放在哪里。作为初学者，您可能不知道应用程序和测试项目必须位于同一解决方案级别，以避免导入问题。

- 极狐GitLab Duo Chat 可以通过提问和优化提示问题来提供帮助：

  ```markdown
  In C# and VS Code, how can I add a reference to a project from a test project?

  Provide the XML configuration which I can add to a C# .csproj file to add a
  reference to another project in the existing solution?
  ```

- 有时，您必须优化提示才能获得更好的结果。提示
  `/refactor into the public class` 会为稍后可从测试项目访问的代码创建建议。

  ```markdown
  /refactor into the public class
  ```

- 您还可以使用 `/refactor` 代码任务来询问 Chat 如何在
  `.gitlab-ci.yml` 文件中执行测试。

  ```markdown
  /refactor add a job to run tests (the test project)
  ```

资源：

- [包含源代码的项目](https://gitlab.com/gitlab-da/use-cases/ai/gitlab-duo-coffee-chat-2024/gitlab-duo-coffee-chat-2024-01-29)

<a id="improve-a-c-application"></a>

### 改进 C++ 应用程序

<a id="refactor-a-c-application-with-sqlite"></a>

#### 使用 SQLite 重构 C++ 应用程序

在此示例中，现有源代码只有一个 main 函数。它重复代码，且无法测试。


要将源代码重构为可复用且可测试的函数：

1. 打开已启用极狐GitLab Duo 的 VS Code 或 Web IDE。
1. 选择源代码，并使用优化后的提示让极狐GitLab Duo Chat 将其重构为函数：

   ```markdown
   /refactor into functions
   ```

   此重构步骤可能不适用于整个所选源代码。

1. 将重构策略拆分为功能块。
   例如，遍历数据库中的所有插入、更新和删除操作。

1. 要为新建的函数生成测试，请再次选择源代码，并使用代码任务 `/tests`。包含针对测试框架的具体提示说明：

   ```markdown
   /tests using the CTest test framework
   ```

1. 如果您的应用程序改用 `Boost.Test` 框架，请优化提示：

   ```markdown
   /tests using the Boost.Test framework
   ```

资源：

- [包含源代码的项目](https://gitlab.com/gitlab-da/use-cases/ai/gitlab-duo-coffee-chat-2024/gitlab-duo-coffee-chat-2024-01-09)

<a id="refactor-c-functions-into-object-oriented-code"></a>

#### 将 C++ 函数重构为面向对象的代码

在此示例中，现有源代码已被包装为函数。为了将来支持更多数据库类型，必须将代码重构为类和对象继承。


<a id="start-working-on-the-class"></a>

##### 开始处理类

- 询问极狐GitLab Duo Chat 如何为基础数据库类实现面向对象模式，并在 SQLite 类中继承它：

  ```markdown
  Explain a generic database implementation using a base class, and SQLite specific class using C++. Provide source examples and steps to follow.
  ```

- 学习过程包括向极狐GitLab Duo Chat 询问实现类中的纯虚函数和虚函数覆盖。

  ```markdown
  What is a pure virtual function, and what is required for the developer inheriting from that class?
  ```

- 代码任务可以帮助重构代码。选择 C++ 头文件中的函数，并使用优化后的提示：

  ```markdown
  /refactor into class with public functions, and private path/db attributes. Inherit from the base class DB

  /refactor into a base class with pure virtual functions called DB. Remove the SQLite specific parts.
  ```

- 极狐GitLab Duo Chat 还会指导构造函数重载、对象初始化，以及使用共享指针优化内存管理。

  ```markdown
  How to add a function implementation to a class in a cpp file?

  How to pass values to class attributes through the class constructor call?
  ```

<a id="find-better-answers"></a>

##### 找到更好的答案

- 以下问题没有提供足够的上下文。

  ```markdown
  Should I use virtual override instead of just override?
  ```

- 相反，请尝试添加更多上下文以获得更好的答案。

  ```markdown
  When implementing a pure virtual function in an inherited class, should I use virtual function override, or just function override? Context is C++.
  ```

- 一个相对复杂的问题涉及如何从新建的类实例化对象，并调用特定函数。

  ```markdown
  How to instantiate an object from a class in C++, call the constructor with the SQLite DB path and call the functions. Prefer pointers.
  ```

- 结果可能有用，但需要针对共享指针和所需的源代码头文件进行优化。

  ```markdown
  How to instantiate an object from a class in C++, call the constructor with the SQLite DB path and call the functions. Prefer shared pointers. Explain which header includes are necessary.
  ```

- 代码建议有助于为 `std::shared_ptr` 指针运算生成正确的语法，并帮助提高代码质量。

  ```c++
  // Define the SQLite path in a variable, default value database.db

  // Create a shared pointer for the SQLite class

  // Open a database connection using OpenConnection
  ```

<a id="refactor-your-code"></a>

##### 重构您的代码

- 重构源代码后，可能会出现编译器错误。请让 Chat 解释这些错误。

  ```markdown
  Explain the error: `db` is a private member of `SQLiteDB`
  ```

- 应将特定的 SQL 查询字符串重构为多行字符串，以便更高效地编辑。

  ```c++
  std::string sql = "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, email TEXT NOT NULL)";
  ```

- 选择源代码，并使用 `/refactor` 代码任务：

  ```markdown
  /refactor into a stringstream with multiple lines
  ```

- 您还可以将实用函数重构为 C++ 中带有静态函数的类，然后询问 Chat 如何调用它们。

  ```markdown
  /refactor into a class providing static functions

  How to call the static functions in the class?
  ```

重构源代码后，就为支持更多数据库类型奠定了基础，整体代码质量也得到了提高。

资源：

- [包含源代码的项目](https://gitlab.com/gitlab-da/use-cases/ai/gitlab-duo-coffee-chat-2024/gitlab-duo-coffee-chat-2024-01-23)

<a id="explain-test-and-refactor-a-kotlin-application"></a>

### 解释、测试和重构 Kotlin 应用程序

在此示例中，必须分析来自 [Kotlin 代码生成提示](#kotlin-code-generation-prompts)
的冒险应用程序，并通过重构和测试加以改进。

当前源代码如下所示：

```kotlin
package org.example

// Create a text adventure
// Search for the golden LEGO brick
// Add visual helpers
// Use random timer traps for game over
// Create a text adventure
fun createTextAdventure() {
    println("Welcome to the golden LEGO brick adventure!")
    println("You find yourself in a dimly lit room. What do you do?")

    var gameOver = false
    while (!gameOver) {
        println("1. Search for the golden LEGO brick")
        println("2. Examine the room")
        println("3. Quit")

        val choice = readLine()?.toIntOrNull() ?: 0
        when (choice) {
            1 -> searchForBrick()
            2 -> examineRoom()
            3 -> {
                println("Goodbye!")
                gameOver = true
            }
            else -> println("Invalid choice. Please try again.")
        }
    }
}

fun searchForBrick() {
    println("You search the room carefully, looking for any sign of the golden LEGO brick.")
    if (Math.random() < 0.2) {
        println("Congratulations! You found the golden LEGO brick!")
    } else {
        println("Your search turns up nothing. You'll have to try again.")
    }
}

fun examineRoom() {
    println("You look around the room, taking in the details.")
    println("The room is dimly lit, with shadows in the corners.")
    println("There is a door to the north and a table in the center of the room.")
}

fun main() {
    createTextAdventure()
}
```

1. 在 IDE 中选择源代码，然后右键单击，让极狐GitLab Duo Chat 解释代码。
1. 优化提示，以了解更多关于缺陷、优化建议或漏洞的信息：

   ```markdown
   /explain focus on bugs and improvements

   The provided code is a simple text adventure game written in Kotlin. It allows the user to search for a golden LEGO brick or
   examine the room. While the code is functional, there are a few potential bugs and areas for improvement:

   1. Potential Bugs:

   The searchForBrick() function uses Math.random() to determine if the player finds the golden LEGO brick. However, this function
   does not handle the case where the player finds the brick. The game will continue indefinitely, even after the player has found
   the brick.

   2. Improvements:

   Game Over Condition: The game should have a proper game over condition when the player finds the golden LEGO brick. This could
   be achieved by introducing a boolean flag or a separate game state to track whether the brick has been found.
   ```

1. 使用 `/tests` 命令让 Chat 为所选代码生成测试：

   ```markdown
   /tests

   To test the code, you can use JUnit for Kotlin. Here are some tests you can write:

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
             assert(output.contains("Congratulations! You found the golden LEGO brick!"))

             System.setOut(standardOut)
         }

      ...
     }
   ```

在确保所有内容都已测试后，请让 Chat 重构所选代码：

```markdown
/refactor fix bugs, improve UX

...

Improvements:

Extracted the menu printing logic into a separate printMenu function for better code organization and readability.
Used Random.nextDouble() instead of Math.random() for better compatibility with Kotlin's standard library.
Added a prompt for the user to enter their choice after printing the menu.
Removed the unnecessary gameOver variable initialization, as it's already assigned a value in the createTextAdventure function.
Added a comment in the searchForBrick function to remind you to add additional logic or game over condition if needed.
These changes should improve the code's readability, maintainability, and user experience.
```

重构后的源代码可能如下所示：

```kotlin
package org.example

import kotlin.random.Random

// Create a text adventure
// Search for the golden LEGO brick
// Add visual helpers
// Use random timer traps for game over
// Create a text adventure
fun createTextAdventure() {
    println("Welcome to the golden LEGO brick adventure!")
    println("You find yourself in a dimly lit room. What do you do?")

    var gameOver = false
    while (!gameOver) {
        printMenu()
        val choice = readLine()?.toIntOrNull()
        when (choice) {
            1 -> searchForBrick()
            2 -> examineRoom()
            3 -> {
                println("Goodbye!")
                gameOver = true
            }
            else -> println("Invalid choice. Please try again.")
        }
    }
}

fun printMenu() {
    println("1. Search for the golden LEGO brick")
    println("2. Examine the room")
    println("3. Quit")
    print("Enter your choice: ")
}

fun searchForBrick() {
    println("You search the room carefully, looking for any sign of the golden LEGO brick.")
    if (Random.nextDouble() < 0.2) {
        println("Congratulations! You found the golden LEGO brick!")
        // Add additional logic or game over condition here
    } else {
        println("Your search turns up nothing. You'll have to try again.")
    }
}

fun examineRoom() {
    println("You look around the room, taking in the details.")
    println("The room is dimly lit, with shadows in the corners.")
    println("There is a door to the north and a table in the center of the room.")
}

fun main() {
    createTextAdventure()
}
```

<a id="get-started-with-powershell"></a>

### PowerShell 入门

> [!note]
> PowerShell 支持处于[实验阶段](../project/repository/code_suggestions/supported_extensions.md#add-support-for-more-languages)。

1. 使用极狐GitLab Duo Chat 询问如何开始编写一个打印当前目录文件大小的 PowerShell 脚本。

   ```markdown
   How to get started with a PowerShell script that prints the file size of the current directory?
   ```

   或者，您可以使用代码建议生成源代码。

1. 创建一个新脚本 `get-file-sizes.ps1`，内容如下：

   ```powershell
   # Collect the files in a directory and print their size
   ```

1. 等待代码建议完成提示，然后添加以下提示，
   以尝试不同的输出格式：

   ```powershell
   # Collect the files in a directory and print their size

   $directory = Read-Host -Prompt "Enter the directory path to get file sizes"
   $files = Get-ChildItem -Path $directory -File
   foreach ($file in $files) {
       $fileSize = [Math]::Round(($file.Length / 1KB), 2)
       Write-Host "$($file.Name) - $fileSize KB"
   }

   # Repeat the code above but store the results in a CSV file
   ```

1. 使用针对不同导出格式的提示重复这些步骤，
   或使用代码建议自动补全。例如：

   ```powershell
   # Collect the files in a directory and print their size

   $directory = Read-Host -Prompt "Enter the directory path to get file sizes"
   $files = Get-ChildItem -Path $directory -File
   foreach ($file in $files) {
       $fileSize = [Math]::Round(($file.Length / 1KB), 2)
       Write-Host "$($file.Name) - $fileSize KB"
   }

   # Repeat the code above but store the results in a CSV file
   $csvFile = "$directory\file-sizes.csv"
   $fileData = foreach ($file in $files) {
       [PSCustomObject]@{
           FileName = $file.Name
           FileSize = [Math]::Round(($file.Length / 1KB), 2)
       }
   }
   $fileData | Export-Csv -Path $csvFile -NoTypeInformation
   Write-Host "File sizes saved to $csvFile"

   # Repeat the code above but store the results in a JSON file
   $jsonFile = "$directory\file-sizes.json"
   $fileData | ConvertTo-Json | Out-File -FilePath $jsonFile
   Write-Host "File sizes saved to $jsonFile"

   # Repeat the code above but store the results in a XML file
   $xmlFile = "$directory\file-sizes.xml"
   $fileData | ConvertTo-Xml -NoTypeInformation | Out-File -FilePath $xmlFile
   Write-Host "File sizes saved to $xmlFile"

   # Repeat the code above but store the results in a HTML file
   $htmlFile = "$directory\file-sizes.html"
   $fileData | ConvertTo-Html -Property FileName, FileSize | Out-File -FilePath $htmlFile
   Write-Host "File sizes saved to $htmlFile"

   # Repeat the code above but store the results in a TXT file
   $txtFile = "$directory\file-sizes.txt"
   $fileData | Out-File -FilePath $txtFile
   Write-Host "File sizes saved to $txtFile"
   ```

<a id="explain-and-resolve-vulnerabilities"></a>

## 解释和解决漏洞

<a id="vulnerabilities-in-c-code"></a>

### C 代码中的漏洞

在此示例中，应借助极狐GitLab Duo 修复检测到的 C 语言安全漏洞。


[此源代码片段](https://gitlab.com/gitlab-da/use-cases/ai/gitlab-duo-coffee-chat-2024/gitlab-duo-coffee-chat-2024-01-30/-/blob/4685e4e1c658565ae956ad9befdfcc128e60c6cf/src/main-vulnerable-source.c)
引入了一个[缓冲区溢出](https://en.wikipedia.org/wiki/Buffer_overflow)安全漏洞：

```c
    strcpy(region, "Hello GitLab Duo Vulnerability Resolution challenge");

    printf("Contents of region: %s\n", region);
```

[SAST 安全扫描器](../application_security/sast/_index.md)可以检测并报告该问题。使用[漏洞解释](../application_security/analyze/duo.md)来理解该问题。
漏洞解决有助于生成一个合并请求。如果建议的更改不符合要求，或可能导致问题，您可以使用代码建议和 Chat 进行优化。例如：

1. 打开已启用极狐GitLab Duo 的 VS Code 或 Web IDE，并添加带有说明的注释：

   ```c
       // Avoid potential buffer overflows

       // Possible AI-generated code below
       strncpy(region, "Hello GitLab Duo Vulnerability Resolution challenge", pagesize);
       region[pagesize-1] = '\0';
       printf("Contents of region: %s\n", region);
   ```

1. 删除建议的代码，并使用不同的注释来采用替代方法。

   ```c
       // Avoid potential buffer overflows using snprintf()

       // Possible AI-generated code below
       snprintf(region, pagesize, "Hello GitLab Duo Vulnerability Resolution challenge");

       printf("Contents of region: %s\n", region);
   ```

1. 使用极狐GitLab Duo Chat 提问。`/refactor` 代码任务可以生成不同的建议。
   如果您偏好特定的算法或函数，请优化提示：

   ```markdown
   /refactor using snprintf
   ```

资源：

- 包含源代码的项目：[极狐GitLab Duo Coffee Chat 2024-01-30 - 漏洞解决挑战](https://gitlab.com/gitlab-da/use-cases/ai/gitlab-duo-coffee-chat-2024/gitlab-duo-coffee-chat-2024-01-30)

<a id="answer-questions-about-gitlab"></a>

## 回答关于极狐GitLab 的问题

在此示例中，挑战在于使用极狐GitLab Duo Chat 解决问题。


- 您可以使用极狐GitLab Duo Chat 解释 CI/CD 错误。

  ```markdown
  Explain this CI/CD error: build.sh: line 14: go command not found
  ```

- 当您没有耐心，只输入一两个词时会发生什么？

  ```markdown
  labels

  issue labels
  ```

  极狐GitLab Duo Chat 会要求提供更多上下文。

- 将您的问题优化为完整的句子，描述问题并寻求解决方案。

  ```markdown
  Explain labels in GitLab. Provide an example for efficient usage.
  ```

资源：

- [包含源代码的项目](https://gitlab.com/gitlab-da/use-cases/ai/gitlab-duo-coffee-chat-2024/gitlab-duo-coffee-chat-2024-02-01)

<a id="root-cause-analysis-use-cases"></a>

## 根因分析用例

使用根因分析来确定 CI/CD 作业失败的根本原因。以下示例说明了常见错误，并鼓励您 fork 并练习查找和修复根本原因。

有关更多信息，请参阅博客文章[开发极狐GitLab Duo：融合 AI 和根因分析以修复 CI/CD 流水线](https://about.gitlab.com/blog/developing-gitlab-duo-blending-ai-and-root-cause-analysis-to-fix-ci-cd/)。

<a id="analyze-missing-go-runtime"></a>

### 分析缺少 Go 运行时

CI/CD 作业可以在容器中执行，这些容器由贡献的 `image` 属性生成。如果容器未提供编程语言运行时，则引用 `go` 二进制文件的已执行 `script` 部分会失败。例如，必须理解并修复错误消息 `/bin/sh: eval: line 149: go: not found`。如果在容器的运行时上下文中找不到 `go` 命令，可能是由于多种原因：

- 该作业使用了像 `alpine` 这样的最小容器镜像，且未安装 Go 语言
  运行时。
- 该作业使用了 CI/CD 配置中指定的错误默认容器镜像，
  或使用了 `default` 关键字。
- 该作业使用了 shell executor 而不是容器镜像。主机操作
  系统已损坏、未安装 Go 语言运行时，或未正确配置。

项目[挑战：根因分析 - Go GitLab Release Fetcher](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-challenges/root-cause-analysis/challenge-root-cause-analysis-go-gitlab-release-fetcher)
提供了一个练习，用于分析和修复 Go Tanuki 应用程序的 CI/CD 问题。在此练习中，
`build` 和 `docker-build` 作业失败。当您修复
问题后，CI/CD 流水线会成功，并且 `build` 作业会打印输出。
`solution/` 目录提供了两种可能的解决方案。

<a id="use-gitlab-duo-to-contribute-to-gitlab"></a>

## 使用极狐GitLab Duo 为 GitLab 做贡献

极狐GitLab Duo 的使用重点在于为 GitLab 代码库做贡献，以及客户如何更高效地做贡献。

GitLab 代码库非常庞大，需要您理解有时很复杂的算法或特定于应用程序的实现。

<a id="contribute-to-frontend-profile-settings"></a>

### 为前端做贡献：个人资料设置

在此示例中，挑战在于更新极狐GitLab 个人资料页面并改进社交网络设置。


您可以使用极狐GitLab Duo Chat 解释和重构代码，并生成测试。代码建议有助于补全现有代码，并可以在 Ruby、Go 或 VueJS 中生成新函数和算法。

1. 使用 `/explain` 代码任务解释所选代码段，并了解 HAML 模板如何工作。
1. 您可以优化代码任务提示，改为询问 `/explain how HAML rendering works`

或者，您可以直接在聊天提示中编写，例如：

```markdown
how to populate a select in haml
```

重构示例涉及以下内容：

1. `/refactor into a HAML dropdown`
1. 检查现有 UI 表单代码后，将提示优化为 `/refactor into a HAML dropdown with a form select`

极狐GitLab Duo Chat 帮助进行错误调试，并在错误消息前添加前缀：

```markdown
Explain this error: undefined method `icon` for
```

<a id="code-generation-prompts"></a>

## 代码生成提示

以下示例为极狐GitLab Duo 中的[受支持语言](../project/repository/code_suggestions/supported_extensions.md)提供了[代码生成](../project/repository/code_suggestions/_index.md#best-practices-for-code-generation)
提示。您可以使用多行注释来优化代码生成提示。

这些示例存储在[极狐GitLab Duo Prompts 项目](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts)中，
由 Developer Relations 团队维护。这些示例经过测试可正常工作。您应审查它们并根据您的环境进行调整。

<a id="c-code-generation-prompts"></a>

### C 代码生成提示

创建一个 Linux 统计工具，用于收集 I/O、性能、磁盘使用情况和 TCP 延迟，
并打印其输出。有关完整示例，请参阅博客文章[使用极狐GitLab Duo 实现高效 AI 驱动代码建议的顶级技巧](https://about.gitlab.com/blog/top-tips-for-efficient-ai-powered-code-suggestions-with-gitlab-duo/#code-suggestions-flow-with-comments)。

```c
// Create a Linux statistic tool
// Collect IO, performance, disk usage, TCP latency
// Print summaries

// Import required headers
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

    printf("IO Block Size: %ld\n", statbuf.st_blksize);

    // TODO: add CPU usage, disk usage, network latency measurements

```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `c` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/c)中找到。

<a id="c-code-generation-prompts-1"></a>

### C++ 代码生成提示

创建一个充当 HTTP 客户端的 CLI 应用程序。

```c++
// Create a CLI app as HTTP client
// Create a main function
// Include all headers
// Read program options: URL, API endpoint, basic auth

#include <iostream>
#include <curl/curl.h>
#include <string>

int main(int argc, char** argv) {
  std::string url;
  std::string endpoint;
  std::string username;
  std::string password;

  // Parse command line options
  // ...

  CURL* curl = curl_easy_init();
  if(curl) {
    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());

    // Set up basic auth
    curl_easy_setopt(curl, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
    curl_easy_setopt(curl, CURLOPT_USERPWD, (username + ":" + password).c_str());

    CURLcode res = curl_easy_perform(curl);

    if(res != CURLE_OK) {
      std::cerr << "Request failed: " << curl_easy_strerror(res) << std::endl;
    }

    curl_easy_cleanup(curl);
  }

  return 0;
}
```

创建一个用于管理分布式文件节点的应用程序。

```c++
// Create an application to manage distributed file nodes
// Provide an overview the health state of nodes
// Use OOP patterns to define the base file node
// Add specific filesystems inherited from the base file

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

创建一个 eBPF 程序，它附加到 `XDP` 内核事件以测量网络流量。仅适用于 Linux 内核。

```c++
// Create an eBPF program which attaches to XDP kernel events
// Count all packets by IP address
// Print a summary
// Include necessary headers

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

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `c++` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/c++)中找到。

<a id="c-code-generation-prompts-2"></a>

### `C#` 代码生成提示

创建一个来自不同传感器的医疗分析器应用程序，并将数据存储在 `MSSQL`中。

```c#
// Create a medical analyzer app
// Collect data from different sensors
// Store data in MSSQL
// Provide methods to access the sensor data

using System.Data.SqlClient;

namespace MedicalAnalyzer
{
    public class SensorDataStore
    {
        private SqlConnection connection;

        public SensorDataStore()
        {
            // Create SQL Server connection
            connection = new SqlConnection("connection string here");
        }

        public void StoreSensorData(SensorData data)
        {
            // Open connection
            connection.Open();

            // Insert sensor data into database
            var command = connection.CreateCommand();
            command.CommandText = "INSERT INTO SensorData (Timestamp, DeviceId, Value) " +
                                  "VALUES (@timestamp, @deviceId, @value)";
            command.Parameters.AddWithValue("@timestamp", data.Timestamp);
            command.Parameters.AddWithValue("@deviceId", data.DeviceId);
            command.Parameters.AddWithValue("@value", data.Value);
            command.ExecuteNonQuery();

            // Close connection
            connection.Close();
        }

        public SensorData[] GetSensorData(DateTime startTime, DateTime endTime)
        {
            // Query database and return results
        }
    }
}
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `c#` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/c%23)中找到。

<a id="css-code-generation-prompts"></a>

### CSS 代码生成提示

```css
/* Create CSS classes for animating a rainbow */

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

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `css` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/css)中找到。

<a id="go-code-generation-prompts"></a>

### Go 代码生成提示

创建一个用于 Kubernetes 的可观测性应用程序，它读取并打印集群中容器、Pod 和服务的状态。

```go
// Create a client for Kubernetes observability
// Create a function that
// Reads the kubernetes configuration file from the KUBECONFIG env var
// Create kubernetes context, namespace default
// Inspect container, pod, service status and print an overview
// Import necessary packages
// Create main package

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

  fmt.Printf("There are %d pods in the %s namespace\n", len(pods.Items), namespace)

}

func printServices(clientset *kubernetes.Clientset, namespace string) {

  services, err := clientset.CoreV1().Services(namespace).List(context.TODO(), metav1.ListOptions{})
  if err != nil {
    panic(err)
  }

  fmt.Printf("There are %d services in the %s namespace\n", len(services.Items), namespace)

}

// Create a function to print Containers
// Collect and print the count

func printContainers(clientset *kubernetes.Clientset, namespace string) {

    pods, err := clientset.CoreV1().Pods(namespace).List(context.TODO(), metav1.ListOptions{})
    if err != nil {
        panic(err)
    }

    var totalContainers int
    for _, pod := range pods.Items {
        totalContainers += len(pod.Spec.Containers)
    }

    fmt.Printf("There are %d containers in the %s namespace\n", totalContainers, namespace)

}
```


创建一个类似于 Redis 的内存键值存储。有关完整演练，请参阅
博客文章[使用极狐GitLab Duo 实现高效 AI 驱动代码建议的顶级技巧](https://about.gitlab.com/blog/top-tips-for-efficient-ai-powered-code-suggestions-with-gitlab-duo/#iterate-faster-with-code-generation)
博客文章。

```go
// Create an in-memory key value store, similar to Redis
// Provide methods to
// set/unset keys
// update values
// list/print with filters
// Use BoltDB as external library
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `go` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/go)中找到。

<a id="java-code-generation-prompts"></a>

### Java 代码生成提示

创建一个数据分析应用程序，为指标提供不同的数据源。为数据查询和聚合提供 API。

```java
// Create a data analytics app
// Parse different input sources and their values
// Store the metrics in a columnar format
// Provide an API to query and aggregate data
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `java` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/java)中找到。

<a id="javascript-code-generation-prompts"></a>

### JavaScript 代码生成提示

使用 ReactJS 为员工创建一个带日期时间选择器的带薪休假应用程序。

```javascript
// Create a Paid Time Off app for users
// Create a date-time picker in ReactJS
// Provide start and end options
// Show public holidays based on the selected country
// Send the request to a server API
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `javascript` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/javascript)中找到。

<a id="html-code-generation-prompts"></a>

### HTML 代码生成提示

```html
<!-- Create an AI knowledge base.
Describe where AI can help with efficient DevSecOps workflows.
Add a table with one Dev, one Ops, one Sec example.
-->

<table>
  <tr>
    <th>Dev</th>
    <th>Ops</th>
    <th>Sec</th>
  </tr>
  <tr>
    <td>Automated testing and continuous integration</td>
    <td>Infrastructure as code and automated provisioning</td>
    <td>Static code analysis and vulnerability scanning</td>
  </tr>
</table>
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `html` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/html)中找到。

<a id="kotlin-code-generation-prompts"></a>

### Kotlin 代码生成提示

生成一个文字冒险游戏并寻找宝藏。添加视觉辅助，并使用随机计时器陷阱来结束游戏。

```kotlin
package org.example

// Create a text adventure
// Search for the golden LEGO brick
// Add visual helpers
// Use random timer traps for game over
// Create a text adventure
fun createTextAdventure() {
    println("Welcome to the golden LEGO brick adventure!")
    println("You find yourself in a dimly lit room. What do you do?")

    var gameOver = false
    while (!gameOver) {
        println("1. Search for the golden LEGO brick")
        println("2. Examine the room")
        println("3. Quit")

        val choice = readLine()?.toIntOrNull() ?: 0
        when (choice) {
            1 -> searchForBrick()
            2 -> examineRoom()
            3 -> {
                println("Goodbye!")
                gameOver = true
            }
            else -> println("Invalid choice. Please try again.")
        }
    }
}

fun searchForBrick() {
    println("You search the room carefully, looking for any sign of the golden LEGO brick.")
    if (Math.random() < 0.2) {
        println("Congratulations! You found the golden LEGO brick!")
    } else {
        println("Your search turns up nothing. You'll have to try again.")
    }
}

fun examineRoom() {
    println("You look around the room, taking in the details.")
    println("The room is dimly lit, with shadows in the corners.")
    println("There is a door to the north and a table in the center of the room.")
}

fun main() {
    createTextAdventure()
}
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `kotlin` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/kotlin)中找到。

<a id="php-code-generation-prompts"></a>

### PHP 代码生成提示

创建一个用于极狐GitLab 发布的 RSS 源获取器，允许按标题筛选。

```php
// Create a web form to show GitLab releases
// Fetch the RSS feed from https://about.gitlab.com/atom.xml
// Provide filter options for the title

$feedUrl = 'https://about.gitlab.com/atom.xml';

$xml = simplexml_load_file($feedUrl);

$titleFilter = $_GET['titleFilter'];

echo '<h1>GitLab Releases</h1>';
echo '<ul>';
foreach ($xml->entry as $entry) {
    $title = $entry->title;
    if (empty($titleFilter) || strpos($title, $titleFilter) !== false) {
        echo '<li>' . $title . '</li>';
    }
}
echo '</ul>';

```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `php` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/php)中找到。

<a id="powershell-code-generation-prompts"></a>

### PowerShell 代码生成提示

创建一个脚本，收集目录中的所有文件并打印其大小。优化提示，将结果存储到 CSV 或 JSON 文件中。

```powershell
# Collect the files in a directory and print their size

$directory = Read-Host -Prompt "Enter the directory path to get file sizes"
$files = Get-ChildItem -Path $directory -File
foreach ($file in $files) {
    $fileSize = [Math]::Round(($file.Length / 1KB), 2)
    Write-Host "$($file.Name) - $fileSize KB"
}

# Repeat the code above but store the results in a CSV file

$csvFile = "$directory\file-sizes.csv"
$fileData = foreach ($file in $files) {
    [PSCustomObject]@{
        FileName = $file.Name
        FileSize = [Math]::Round(($file.Length / 1KB), 2)
    }
}
$fileData | Export-Csv -Path $csvFile -NoTypeInformation
Write-Host "File sizes saved to $csvFile"

# Repeat the code above but store the results in a JSON file

$jsonFile = "$directory\file-sizes.json"
$fileData | ConvertTo-Json | Out-File -FilePath $jsonFile
Write-Host "File sizes saved to $jsonFile"
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `powershell` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/powershell)中找到。

<a id="python-code-generation-prompts"></a>

### Python 代码生成提示

使用 Flask 创建一个 Web 服务器，通过 REST API 管理用户，并将它们存储在 SQLite 中。

```python
# Create a Flask webserver
# Add REST API entrypoints to manage users by ID
# Implement create, update, delete functions
# User data needs to be stored in SQlite, create table if not exists
# Run the server on port 8080, support TLS
# Print required packages for requirements.txt in a comment.
# Use Python 3.10 as default

# Potential AI-generated code below
import flask
from flask import request
import sqlite3

app = flask.Flask(__name__)

# Create SQLite database and users table if not exists
conn = sqlite3.connect('users.db')
conn.execute('''CREATE TABLE IF NOT EXISTS users
         (id INTEGER PRIMARY KEY, name TEXT, email TEXT)''')

@app.route('/users', methods=['POST'])
def create_user():
  # Get user data from request
  name = request.form['name']
  email = request.form['email']

  # Insert user into database
  conn.execute('INSERT INTO users (name, email) VALUES (?, ?)', (name, email))

  return 'User created successfully'

@app.route('/users/<int:id>', methods=['PUT'])
def update_user(id):
  # Get user data from request
  name = request.form['name']
  email = request.form['email']

  # Update user in database
  conn.execute('UPDATE users SET name = ?, email = ? WHERE id = ?', (name, email, id))

  return 'User updated successfully'

@app.route('/users/<int:id>', methods=['DELETE'])
def delete_user(id):
  # Delete user from database
  conn.execute('DELETE FROM users WHERE id = ?', (id,))

  return 'User deleted successfully'

if __name__ == '__main__':
  # Required packages - flask, sqlite3
  app.run(host='0.0.0.0', port=8080, ssl_context='adhoc')

```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `python` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/python)中找到。

<a id="ruby-code-generation-prompts"></a>

### Ruby 代码生成提示

创建一个日志解析器应用程序，将日志数据存储在 Elasticsearch 中。

```ruby
# Create a Ruby app as log parser
# Provide hooks to replace sensitive strings in log lines
# Format the logs and store them in Elasticsearch

# Potential AI-generated code below
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
    # replace sensitive data
    line.gsub(/\d{16}/, '[REDACTED]')
  end

  def format_logs(logs)
    logs.map { |line| "#{Time.now}: #{line}" }
  end

  def store_in_elasticsearch(logs)
    logs.each { |log| @elasticsearch.index(index: 'app-logs', document: log) }
  end
end
```

创建一个日志客户端实用工具类，支持带有严重级别、应用程序名称和消息字符串的 syslog 格式。

```ruby
# Create Logging utility class
# Define default log level as attribute
# Add method for logging, inputs: level, app, message
# Print the data with formatted date and time in syslog format

# Potential AI-generated code below
class Logging
  attr_accessor :log_level

  def log(level, app, message)
    time = Time.now.strftime("%b %d %H:%M:%S")
    puts "#{time} #{app}[#{Process.pid}]: #{level} - #{message}"
  end
end

# Instantiate class and test the log method

# Potential AI-generated code below
logger = Logging.new
logger.log_level = :debug

logger.log(:info, 'MyApp', 'Application started - info')
logger.log(:debug, 'MyApp', 'Application started - debug')
logger.log(:error, 'MyApp', 'Application started - error')
logger.log(:fatal, 'MyApp', 'Application started - fatal')
logger.log(:warn, 'MyApp', 'Application started - warn')
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `ruby` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/ruby)中找到。

<a id="rust-code-generation-prompts"></a>

### Rust 代码生成提示

```rust
// Query the GitLab REST API
// Get all open merge requests for gitlab-org/gitlab

use serde_json::Value;

fn main() {

    let client = reqwest::blocking::Client::new();
    let url = "https://gitlab.com/api/v4/projects/278964/merge_requests?state=opened";
    let response = client.get(url).send().unwrap().text().unwrap();
    let json: Value = serde_json::from_str(&response).unwrap();

    // TODO: Pagination, default fetch results: 20
    // Read the response headers to access the next page

    println!("{}", json.to_string());

    for mr in json.as_array().unwrap() {
        println!("{} - URL: {}", mr["title"], mr["web_url"]);
    }
}
```

创建一个 RSS 源阅读器应用程序，示例来自博客文章[借助 AI 的一点帮助学习高级 Rust 编程](https://about.gitlab.com/blog/learn-advanced-rust-programming-with-a-little-help-from-ai-code-suggestions/)。

```rust
    // Create a function that iterates over the source array
    // and fetches the data using HTTP from the RSS feed items.
    // Store the results in a new hash map.
    // Print the hash map to the terminal.
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `rust` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/rust)中找到。

<a id="scala-code-generation-prompts"></a>

### Scala 代码生成提示

```scala
// Implement Newtons Method
// Create an object with a main function
// Add a function that implements Newtons method for solving equations
// Add a driver function which tests the implemented function
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
    println(s"The root is: $root")
  }
}
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `scala` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/scala)中找到。

<a id="shell-scripts-code-generation-prompts"></a>

### Shell 脚本代码生成提示

创建一个脚本 `mytop.sh`，显示按 CPU、内存和磁盘 I/O 使用率排名的前 10 个进程。从第一个代码注释开始，让代码建议生成其余所有内容。

```shell
#!/bin/bash

# Get the top 10 processes by CPU usage
top -b -n 1 | head -n 11 | awk '{print $1, $2, $3, $9}' | column -t

# Get the top 10 processes by memory usage
top -b -n 1 | head -n 11 | awk '{print $1, $2, $4, $6}' | column -t

# Get the top 10 processes by disk I/O
top -b -n 1 | head -n 11 | awk '{print $1, $2, $7, $8}' | column -t

# Get the top 10 processes by network I/O
top -b -n 1 | head -n 11 | awk '{print $1, $2, $10, $11}' | column -t

```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `shell` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/shell)中找到。

<a id="typescript-code-generation-prompts"></a>

### TypeScript 代码生成提示

创建一个解析 IPv6 和 IPv4 地址格式的实用函数。

```typescript
"use strict";
// Generate a TypeScript function which parses IPv6 and IPv4 address formats
// Use regular expressions
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
// Test the function with random inputs
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
        console.error(`Invalid address: ${input}`);
    }
}
```

AI 生成的源代码示例可在[极狐GitLab Duo Prompts 项目中的 `typescript` 目录](https://gitlab.com/gitlab-da/use-cases/ai/ai-workflows-2024/gitlab-duo-prompts/-/tree/main/code-suggestions/typescript)中找到。
