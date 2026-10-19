---
stage: AI Coding
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 自定义 AI 在合并请求评审中使用的指令。
title: 为 Agent Platform 自定义审查指令
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

创建自定义审查指令，为极狐GitLab Duo 在评审合并请求时提供可参考的标准。

例如，您可以引导极狐GitLab Duo 对 Ruby 文件关注 Ruby 风格约定，对 Go 文件关注 Go 风格约定。

> [!note]
> 自定义审查指令是对 AI 审核人的指导，而非强制执行的策略。
> 极狐GitLab Duo 将其作为上下文来塑造评审，但无法保证每条指令
> 在每种情况下都被应用。请勿依赖自定义指令进行安全控制、
> 合规义务或其他需要一致强制执行的要求。

极狐GitLab Duo 会将您的自定义审查指令附加到其标准评审标准之上，
而不是替换它们。

代码评审任务流支持为项目、群组或实例配置自定义审查指令。

<a id="configure-custom-review-instructions-for-a-project"></a>

## 为项目配置自定义审查指令

要配置自定义合并请求审查指令：

1. 在代码仓库根目录中，如果尚不存在 `.gitlab/duo` 目录，请创建该目录。
1. 在 `.gitlab/duo` 目录中，创建一个名为 `mr-review-instructions.yaml` 的文件。
1. 使用以下格式添加您的自定义指令：

   ```yaml
   instructions:
     - name: <instruction_group_name>
       fileFilters:
         - <glob_pattern_1>
         - <glob_pattern_2>
         - !<exclude_pattern>  # Exclude files matching this pattern
       instructions: |
         <your_custom_review_instructions>
   ```

   `fileFilters` 部分是可选的。在此部分中使用 glob 模式将指令
   定向到特定文件。如果省略 `fileFilters` 或将其留空，极狐GitLab Duo 会将
   指令应用于合并请求中的每个文件。

   例如：

   ```yaml
   instructions:
     - name: Ruby Style Guide
       fileFilters:
         - "*.rb"           # Ruby files in the root directory
         - "lib/**/*.rb"    # Ruby files in lib and its subdirectories
         - "!spec/**/*.rb"  # Exclude test files
       instructions: |
         1. Ensure all methods have proper documentation
         2. Follow Ruby style guide conventions
         3. Prefer symbols over strings for hash keys

     - name: TypeScript Source Files
       fileFilters:
         - "**/*.ts"        # Typescript files in any directory
         - "!**/*.test.ts"  # Exclude test files
         - "!**/*.spec.ts"  # Exclude spec files
       instructions: |
         1. Ensure proper TypeScript types (avoid 'any')
         2. Follow naming conventions
         3. Document complex functions

     - name: All Files Except Tests
       fileFilters:
         - "!**/*.test.*"   # Exclude all test files
         - "!**/*.spec.*"   # Exclude all spec files
         - "!test/**/*"     # Exclude test directories
         - "!spec/**/*"     # Exclude spec directories
       instructions: |
         1. Follow consistent code style
         2. Add meaningful comments for complex logic
         3. Ensure proper error handling

     - name: Test Coverage
       fileFilters:
         - "spec/**/*_spec.rb" # Ruby test files in spec directory
       instructions: |
         1. Test both happy paths and edge cases
         2. Include error scenarios
         3. Use shared examples to reduce duplication

     - name: Database Migrations
       fileFilters:
         - "db/migrate/**/*.rb"
         - "db/post_migrate/**/*.rb"
       instructions: |
         1. Follow the migration safety guidelines in
            https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/development/database/avoiding_downtime_in_migrations.md
         2. Apply the team checklist in docs/migrations-checklist.md

     - name: All Files
       fileFilters:
         - "**/*"   # All files in the repository
       instructions: |
         1. Explain the "why" behind each suggestion
   ```

   有关在指令中引用文件的详细信息，请参见
   [在指令中引用文件](#reference-files-in-instructions)。

   有关 glob 语法示例，请参见
   [文件模式参考](#file-pattern-reference)。

1. 可选：添加 [Code Owners](../../project/codeowners/_index.md) 条目，
   以保护对 `mr-review-instructions.yaml` 文件的更改。

   ```markdown
   [GitLab Duo]
   .gitlab/duo @default-owner @tech-lead
   ```

1. [创建合并请求](../../project/merge_requests/creating_merge_requests.md)
   以审查并合并更改：

   - 当文件模式匹配时，极狐GitLab Duo 会自动应用您的自定义指令。
   - 多个指令组可以应用于单个文件。当一个文件
     匹配多个组的 `fileFilters` 时，代码评审任务流会应用
     每个匹配组中的指令。
   - 对于由您的自定义指令触发的评审评论，极狐GitLab Duo 使用以下格式：

     ```plaintext
     According to custom instructions in '[instruction_name]': [feedback comments]
     ```

     `instruction_name` 值对应于您的
     `.gitlab/duo/mr-review-instructions.yaml` 文件中的 `name` 属性。标准的极狐GitLab Duo 评论
     不使用此格式。
     <br><br>
     如果极狐GitLab Duo 未发现任何问题，它会留下一条评审摘要评论。自定义
     指令不适用于此摘要评论。
1. 可选：
   - 审查反馈并根据需要完善您的指令。
   - 测试模式以确保它们匹配预期的文件。

<a id="configure-custom-review-instructions-for-a-group"></a>

## 为群组配置自定义审查指令

您可以通过指定一个项目作为模板，为群组定义自定义审查指令。
模板项目必须包含一个 `.gitlab/duo/mr-review-instructions.yaml` 文件，其中包含适用于该群组及其子群组中所有项目的审查指令。

当极狐GitLab Duo 执行代码评审时，它会将来自顶级群组的指令与
单个项目中定义的指令相结合。

> [!note]
> 如果您已经配置了一个项目来为您的群组存储[自动评审排除规则](../flows/foundational_flows/code_review/_index.md#exclude-merge-requests-for-a-project)，请将您的 `mr-review-instructions.yaml`
> 存储在同一个项目中。
> 您只能指定一个项目来为群组自定义代码评审，因此极狐GitLab 会自动
> 检查该项目中的审查指令。您无需再次执行以下步骤。

先决条件：

- 顶级群组的所有者角色。
- 群组中有一个项目包含您想用作模板的自定义审查指令。

  > [!warning]
  > 请勿在 `mr-review-instructions.yaml` 中存储敏感或机密信息。
  > 任何可以查看群组中合并请求的用户都可以访问群组审查指令，
  > 即使他们无权访问包含该文件的项目。

要为群组配置自定义审查指令：

{{< tabs >}}

{{< tab title="GitLab.com" >}}

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的顶级群组。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **极狐GitLab Duo 功能** > **自定义代码评审** 下，选择包含
   带有您群组审查指令的 `.gitlab/duo/mr-review-instructions.yaml` 文件的项目。
1. 选择 **保存更改**。

{{< /tab >}}

{{< tab title="GitLab Self-Managed and GitLab Dedicated" >}}

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的顶级群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **极狐GitLab Duo 功能**。
1. 在 **自定义代码评审** 下，选择包含
   带有您群组审查指令的 `.gitlab/duo/mr-review-instructions.yaml` 文件的项目。
1. 选择 **保存更改**。

{{< /tab >}}

{{< /tabs >}}

<a id="configure-custom-review-instructions-for-an-instance"></a>

## 为实例配置自定义审查指令

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

在极狐GitLab 私有化部署上，您可以通过指定一个项目作为模板来定义实例级自定义审查指令。
模板项目必须包含一个 `.gitlab/duo/mr-review-instructions.yaml` 文件，其中包含适用于实例上每个项目的审查指令。

当极狐GitLab Duo 执行代码评审时，它会将实例指令与群组和项目指令相结合。

先决条件：

- 实例的管理员访问权限。
- 实例上有一个项目包含您想用作模板的自定义审查指令。

  > [!warning]
  > 请勿在 `mr-review-instructions.yaml` 中存储敏感或机密信息。
  > 任何可以查看实例上合并请求的用户都可以访问实例审查指令，
  > 即使他们无权访问包含该文件的项目。

要为实例配置自定义审查指令：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **为此实例中的所有群组自定义代码评审** 下，选择包含
   带有您审查指令的 `.gitlab/duo/mr-review-instructions.yaml` 文件的项目。
1. 选择 **保存更改**。

<a id="reference-files-in-instructions"></a>

## 在指令中引用文件

您可以在自定义指令中引用其他文件，而不是重复内容。
代码评审任务流会在预扫描步骤中读取被引用的文件，
并提取相关指导。

自定义指令支持两种文件引用模式：

- 与合并请求位于同一项目中的文件：使用代码仓库相对路径，
  例如 `docs/security-checklist.md`。
- 同一极狐GitLab 实例上其他项目中的文件：使用完整的
  极狐GitLab blob URL，例如
  `https://gitlab.example.com/group/project/-/blob/main/docs/style-guide.md`。
  该 URL 必须指向与合并请求相同的极狐GitLab 实例，并且
  必须使用 `/-/blob/<ref>/<path>` 格式。

例如：

```yaml
instructions:
  - name: Database Migrations
    fileFilters:
      - "db/migrate/**/*.rb"
    instructions: |
      1. Follow the migration guidelines in
         https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/development/database/avoiding_downtime_in_migrations.md
      2. Reference the team checklist in docs/db-checklist.md
```

<a id="limitations-of-file-references"></a>

### 文件引用的限制

文件引用解析有以下约束：

- 仅限同一极狐GitLab 实例。指向不同极狐GitLab
  实例、从极狐GitLab 私有化部署实例指向公共 GitLab，或指向任何
  非 GitLab 站点（如 Confluence 或公共文档站点）的 URL 不会被获取。
- 仅限 blob URL，格式为 `/-/blob/<ref>/<path>`。Wiki 页面、议题、
  raw URL 和代码片段不会被获取。
- 裸路径仅限同一项目。诸如 `docs/security.md` 的裸路径
  会相对于与合并请求相同的项目进行解析。请使用完整的极狐GitLab
  blob URL 来引用不同项目中的文件。
- 尽力而为，不作保证。代码评审任务流会根据指令文本决定要获取哪些引用。
  解析失败的引用（例如不存在的路径或解析器拒绝的 URL）会被静默跳过。
- 代码评审任务流使用摘要，而非原始文件。它会在预扫描步骤中总结
  获取的内容，并在评审期间使用该摘要。对同一合并请求的两次评审可能产生不同的摘要。

如果您希望代码评审任务流使用确切的文件内容而非摘要，
请将其直接包含在 `instructions:` 字段中，而不是引用文件。
内联指令会按原样使用。

<a id="best-practices"></a>

## 最佳实践

编写自定义审查指令时：

- 要具体且可操作。代码评审任务流会针对差异检查每条规则。
  例如，像“验证公共方法是否有 YARD 文档”这样的具体规则会产生有用的评论，
  但像“好好记录您的代码”这样的抽象指导则不会。
- 为清晰起见，为您的指令编号。
- 专注于最重要的标准。每条规则的文本都会成为
  评审提示的一部分，因此低价值规则的长列表只会增加提示量
  而不会增加有效信息。
- 在有帮助时解释“为什么”。
- 从简单的指令开始，根据需要增加复杂性。
- 专注于代码评审任务流默认不会应用的项目特定标准。
  自定义指令是在标准评审标准之上添加的，而不是替换它们。
  像“添加错误处理”或“使用有意义的名称”这样的通用建议通常已被涵盖。
  请将自定义指令用于只有您的项目才知道的内容：内部 API、架构约定、
  领域特定模式。
- 将指令编写为指导，而非强制要求。指令是塑造评审行为的提示，
  而非极狐GitLab Duo 必须遵循的策略。避免使用“始终标记”或“绝不允许”等措辞。
  这种表述可能会误导协作者，使其认为该行为是有保证的。
- 让文件模式反映规则的实际范围。代码评审任务流
  会结合每个 `fileFilters` 引用来读取每条指令，并仅将规则
  应用于匹配这些模式的文件。例如，一条针对“Rails
  控制器”的规则如果作用域为 `**/*.rb`，将应用于 gem、脚本和
  测试，而不仅仅是控制器。请改用 `app/controllers/**/*.rb`。
- 仅在确切措辞无关紧要时才使用外部文件引用，
  否则请将详细信息作为规则直接包含在
  `instructions:` 字段中。代码评审任务流会为引用的文件生成并使用
  摘要，但会使用 `instructions` 中定义的确切措辞。

例如：

```yaml
instructions: |
  1. All public functions must include docstrings with parameter descriptions
  2. Use parameterized queries to prevent SQL injection
  3. Validate user input before processing (check type, length, format)
  4. Include error handling for all external API calls
  5. Avoid hardcoded credentials - use environment variables
```

有关特定语言的示例，请参见[用例示例](#use-case-examples)。

<a id="file-pattern-reference"></a>

## 文件模式参考

在 `fileFilters` 中使用 glob 模式来定向特定文件。

例如，对于一个包含 Ruby 文件的项目：

| 模式 | 匹配 |
| --- | --- |
| `**/*.rb`       | 任何目录中的所有 Ruby 文件 |
| `*.rb`          | 仅根目录中的 Ruby 文件 |
| `lib/**/*.rb`   | `lib` 目录及其子目录中的 Ruby 文件 |
| `!**/*.test.rb` | 排除所有 Ruby 测试文件 |
| `!spec/**/*.rb` | 排除 `spec` 目录及其子目录中的所有 Ruby 文件 |
| `!tests/**/*`   | 排除 `tests` 目录及其子目录中的所有文件 |
| `**/*.{js,jsx}` | 所有目录中的 JavaScript 和 JSX 文件（极狐GitLab 19.1 及更高版本） |

以下示例展示了 `**/*.rb` 和 `*.rb` 之间的区别：

```plaintext
project/
├── app.rb              ← matched by both *.rb and **/*.rb
├── lib/
│   └── helper.rb       ← matched only by **/*.rb
└── app/
    └── models/
        └── user.rb     ← matched only by **/*.rb
```

- `*.rb` 只会匹配 app.rb
- `**/*.rb` 会匹配所有三个文件

对于 `mr-review-instructions.yaml` 文件，`**/*.rb` 可确保审查指令
应用于项目结构中任意位置的 Ruby 文件，而不仅仅是根目录。

<a id="use-case-examples"></a>

## 用例示例

<!-- 2025-11-12 Use case examples are maintained by DevRel, @dnsmichi
Inspired by the reference in <https://gitlab.com/gitlab-da/use-cases/ai/gitlab-duo-agent-platform/demo-environments/tanuki-iot-platform/-/blob/main/.gitlab/duo/mr-review-instructions.yaml?ref_type=heads>
-->

{{< tabs >}}

{{< tab title="Assembly" >}}

```yaml
instructions:
  - name: Assembly Style Guide
    fileFilters:
      - "**/*.asm"
      - "**/*.s"
      - "**/*.S"
    instructions: |
      1. Document the target architecture (x86-64, ARM, RISC-V, AVR, etc.) at the top
      2. Use meaningful labels and comment all non-obvious instructions
      3. Document register usage and calling conventions
      4. Align code sections properly for readability
      5. Include memory layout and stack usage documentation
```

{{< /tab >}}

{{< tab title="C" >}}

```yaml
instructions:
  - name: C Style Guide
    fileFilters:
      - "**/*.c"
      - "**/*.h"
    instructions: |
      1. goto is not allowed
      2. Avoid using global variables
      3. Use meaningful variable names
      4. Add comments for complex logic
```

{{< /tab >}}

{{< tab title="C++" >}}

```yaml
instructions:
  - name: C++ Style Guide
    fileFilters:
      - "**/*.cpp"
      - "**/*.{h,hpp}"
    instructions: |
      1. Ensure all methods have proper documentation
      2. Use smart pointers for dynamic memory management
      3. Avoid raw pointers
```

{{< /tab >}}

{{< tab title="C#" >}}

```yaml
instructions:
  - name: C# Style Guide
    fileFilters:
      - "**/*.cs"
    instructions: |
      1. Follow Microsoft C# coding conventions
      2. Use XML documentation comments for public APIs
      3. Prefer async/await for asynchronous operations
      4. Use nullable reference types appropriately
      5. Follow .NET naming conventions (PascalCase for public members)
```

{{< /tab >}}

{{< tab title="COBOL" >}}

```yaml
instructions:
  - name: COBOL Style Guide
    fileFilters:
      - "**/*.CBL"
      - "**/*.cbl"
      - "**/*.COB"
      - "**/*.cob"
    instructions: |
      1. Use clear and meaningful names for variables and procedures
      2. Prefer COBOL-85 syntax where possible
      3. Use proper division structure (IDENTIFICATION, ENVIRONMENT, DATA, PROCEDURE)
      4. Document all paragraphs and sections with meaningful comments
      5. Use 88-level condition names for boolean flags and status codes
      6. Avoid GO TO statements, prefer PERFORM for structured programming
      7. Use proper error handling with declaratives or status code checking
      8. Define working storage variables with appropriate PICTURE clauses
      9. Use meaningful paragraph names that describe the operation
      10. For mainframe integration, document JCL dependencies and file layouts
```

{{< /tab >}}

{{< tab title="Go" >}}

```yaml
instructions:
  - name: Go Style Guide
    fileFilters:
      - "**/*.go"
    instructions: |
      1. Use idiomatic Go practices
      2. Ensure all public functions and types have documentation
      3. Prefer standard library packages over third-party ones when possible
```

{{< /tab >}}

{{< tab title="Java" >}}

```yaml
instructions:
  - name: Java Style Guide
    fileFilters:
      - "**/*.java"
    instructions: |
      1. Do not modernize Java 8 code to Java 11+ features, unless there is a GitLab issue or task specifically requesting modernization
      2. All public classes must have Javadoc describing purpose and usage
      3. All public methods must have Javadoc with @param and @return tags
      4. Include code examples in main class Javadoc
      5. All public methods must have at least one test case
```

{{< /tab >}}

{{< tab title="JavaScript/TypeScript" >}}

```yaml
instructions:
  - name: JavaScript/TypeScript Files
    fileFilters:
      - "src/**/*.js"
      - "src/**/*.jsx"
      - "src/**/*.ts"
      - "src/**/*.tsx"
      - "!**/*.test.js"
      - "!**/*.test.ts"
      - "!**/*.spec.js"
      - "!**/*.spec.ts"
    instructions: |
      1. Use const/let instead of var
      2. Prefer async/await over promise chains
      3. Add JSDoc comments for complex functions
      4. Ensure proper error handling in async code
      5. Avoid any 'any' types in TypeScript
```

{{< /tab >}}

{{< tab title="Kotlin" >}}

```yaml
instructions:
  - name: Kotlin Style Guide
    fileFilters:
      - "**/*.kt"
      - "**/*.kts"
    instructions: |
      1. Follow Kotlin coding conventions
      2. Prefer immutability (val over var)
      3. Use coroutines for asynchronous operations
      4. Leverage Kotlin's null safety features
      5. Document public APIs with KDoc
```

{{< /tab >}}

{{< tab title="MATLAB" >}}

```yaml
instructions:
  - name: MATLAB Style Guide
    fileFilters:
      - "**/*.m"
    instructions: |
      1. Use descriptive variable and function names with camelCase convention
      2. Vectorize operations instead of using loops where possible
      3. Document functions with H1 line and help text comments
      4. Preallocate arrays before loops to improve performance
      5. Use proper error handling with try-catch blocks and error() function
```

{{< /tab >}}

{{< tab title="Perl" >}}

```yaml
instructions:
  - name: Perl Style Guide
    fileFilters:
      - "**/*.pl"
      - "**/*.pm"
    instructions: |
      1. Follow idiomatic Perl practices
      2. Ensure proper module documentation
      3. Use strict and warnings pragmas
```

{{< /tab >}}

{{< tab title="PHP" >}}

```yaml
instructions:
  - name: PHP Style Guide
    fileFilters:
      - "**/*.php"
    instructions: |
      1. Follow PSR-12 coding standard
      2. Use type declarations for function parameters and return types
      3. Ensure compatibility with PHP 8+
      4. Use proper error handling and exceptions
      5. Document classes and methods with PHPDoc
```

{{< /tab >}}

{{< tab title="Python" >}}

```yaml
instructions:
  - name: Python Source Files
    fileFilters:
      - "**/*.py"
      - "!tests/**/*.py"
      - "!test_*.py"
    instructions: |
      1. All functions must have docstrings with parameters and return types
      2. Use type hints for function signatures
      3. Follow PEP 8 style conventions
      4. Ensure proper exception handling
      5. Avoid using bare 'except' clauses

  - name: Python Tests
    fileFilters:
      - "tests/**/*.py"
      - "test_*.py"
    instructions: |
      1. Use pytest fixtures for common setup
      2. Test names should clearly describe the scenario being tested
      3. Include assertions for both expected outcomes and edge cases
      4. Mock external dependencies appropriately
```

{{< /tab >}}

{{< tab title="Ruby" >}}

```yaml
instructions:
  - name: Ruby Style Guide
    fileFilters:
      - "*.rb"
      - "lib/**/*.rb"
      - "!spec/**/*.rb"  # Exclude test files
    instructions: |
      1. Follow Ruby style guide conventions
      2. Prefer symbols over strings for hash keys
      3. Use snake_case for methods/variables, SCREAMING_SNAKE_CASE for constants, CamelCase for classes
      4. Prefer Ruby 3.0+ features (pattern matching, endless methods) where appropriate
      5. Use proper error handling - raise exceptions over returning nil for errors
      6. Write idiomatic Ruby - use blocks, enumerables, and Ruby idioms over procedural patterns
      7. Use meaningful method names - use ? for predicates, ! for dangerous methods
      8. Prefer keyword arguments for methods with multiple parameters
      9. All public methods should have corresponding RSpec/Minitest tests
      10. Manage dependencies with Gemfile and ensure version compatibility
      11. Document thread-safe code and use proper synchronization for concurrent operations
      12. Handle signals (SIGTERM, SIGINT) properly for daemon processes
```

{{< /tab >}}

{{< tab title="R" >}}

```yaml
instructions:
  - name: R Style Guide
    fileFilters:
      - "**/*.r"
      - "**/*.R"
    instructions: |
      1. Follow tidyverse style guide conventions
      2. Use snake_case for variable and function names
      3. Document functions with roxygen2 comments
      4. Prefer vectorized operations over loops
      5. Use proper error handling with tryCatch and stop()
```

{{< /tab >}}

{{< tab title="Rust" >}}

```yaml
instructions:
  - name: Rust Style Guide
    fileFilters:
      - "**/*.rs"
    instructions: |
      1. Follow Rust idioms and conventions
      2. Use proper error handling with Result and Option types
      3. Avoid unsafe code unless absolutely necessary and well-documented
      4. Ensure all public items have documentation comments
```

{{< /tab >}}

{{< tab title="Scala" >}}

```yaml
instructions:
  - name: Scala Style Guide
    fileFilters:
      - "**/*.scala"
    instructions: |
      1. Follow Scala style guide conventions
      2. Prefer immutable data structures (val over var)
      3. Use pattern matching effectively for control flow
      4. Document public APIs with ScalaDoc
      5. Use proper error handling with Try, Either, or Option types
```

{{< /tab >}}

{{< tab title="Shell" >}}

```yaml
instructions:
  - name: Shell Script Style Guide
    fileFilters:
      - "**/*.sh"
      - "**/*.bash"
      - "**/*.zsh"
      - "**/*.ksh"
    instructions: |
      1. Always quote variables to prevent word splitting ("$var" not $var)
      2. Use proper error handling with set -euo pipefail at script start
      3. Document script purpose, parameters, and exit codes in header comments
      4. Prefer [[ ]] over [ ] for conditional tests
      5. Use meaningful function names and avoid complex one-liners
```

{{< /tab >}}

{{< tab title="SQL" >}}

```yaml
instructions:
  - name: SQL Style Guide
    fileFilters:
      - "**/*.sql"
    instructions: |
      1. Use uppercase for SQL keywords (SELECT, FROM, WHERE, JOIN)
      2. Always specify column names explicitly instead of using SELECT *
      3. For PostgreSQL use SERIAL/RETURNING, for MySQL use AUTO_INCREMENT, for Oracle use SEQUENCE
      4. For NoSQL (MongoDB) use proper indexing and aggregation pipelines to avoid N+1 queries
      5. Document database-specific features and expected performance characteristics
      6. Use proper indentation for complex queries and subqueries
```

{{< /tab >}}

{{< tab title="VHDL" >}}

```yaml
instructions:
  - name: VHDL Style Guide
    fileFilters:
      - "**/*.vhd"
      - "**/*.vhdl"
    instructions: |
      1. Follow IEEE VHDL coding standards
      2. Use meaningful signal and entity names with clear prefixes
      3. Document all entities, architectures, and processes with comments
      4. Use synchronous design practices with proper clock and reset handling
      5. Avoid combinational loops and ensure proper timing constraints
```

{{< /tab >}}

{{< tab title="Configuration files" >}}

```yaml
instructions:
  - name: Configuration Files
    fileFilters:
      - "*.yaml"
      - "*.yml"
      - "*.json"
      - "config/**/*"
      - "!.gitlab/**/*"
    instructions: |
      1. Do not include sensitive data (passwords, API keys)
      2. Use environment variables for environment-specific values
      3. Document all configuration options
      4. Validate configuration schema if possible
```

{{< /tab >}}

{{< tab title="Infrastructure-as-Code" >}}

```yaml
instructions:
  - name: Ansible Style Guide
    fileFilters:
      - "*.yaml"
      - "*.yml"
      - "playbooks/**/*.yaml"
      - "roles/**/*.yaml"
    instructions: |
      1. Use meaningful play and task names that describe the action
      2. Prefer modules over shell/command tasks when possible
      3. Use variables and defaults for reusability across environments
      4. Implement idempotency - tasks should be safe to run multiple times
      5. Use handlers for service restarts and notifications
      6. Document playbook purpose, required variables, and dependencies

  - name: Dockerfile Style Guide
    fileFilters:
      - "Dockerfile"
      - "*.dockerfile"
      - "Dockerfile.*"
    instructions: |
      1. Use specific base image tags, avoid 'latest'
      2. Minimize layers by combining RUN commands with && where logical
      3. Use multi-stage builds to reduce final image size
      4. Run containers as non-root user for security
      5. Use .dockerignore to exclude unnecessary files
      6. Document exposed ports, volumes, and environment variables

  - name: GitLab CI/CD Style Guide
    fileFilters:
      - ".gitlab-ci.yml"
      - "**/.gitlab-ci.yml"
    instructions: |
      1. Use job extends instead of YAML anchors for reusability
      2. Always use rules instead of only/except for job conditions
      3. Define appropriate caching strategies for dependencies
      4. Use stages to organize pipeline workflow logically
      5. Include security scanning templates (SAST, dependency scanning, secret detection)
      6. Document job purpose, required variables, and dependencies in comments

  - name: Helm Chart Style Guide
    fileFilters:
      - "Chart.yaml"
      - "values.yaml"
      - "templates/**/*.yaml"
    instructions: |
      1. Use semantic versioning for chart versions
      2. Provide sensible defaults in values.yaml with comments
      3. Use template functions for conditional logic and loops
      4. Include NOTES.txt with post-installation instructions
      5. Validate charts with helm lint before committing
      6. Document all configurable values and their purpose

  - name: Kubernetes Style Guide
    fileFilters:
      - "*.yaml"
      - "*.yml"
      - "k8s/**/*.yaml"
      - "kubernetes/**/*.yaml"
    instructions: |
      1. Use explicit API versions and avoid deprecated APIs
      2. Always define resource limits and requests for containers
      3. Use namespaces to organize resources logically
      4. Define liveness and readiness probes for all deployments
      5. Use ConfigMaps and Secrets instead of hardcoded values
      6. Document resource purpose and dependencies in metadata annotations

  - name: Terraform/OpenTofu Style Guide
    fileFilters:
      - "*.tf"
      - "*.tfvars"
    instructions: |
      1. Use consistent naming conventions for resources (environment_service_resource)
      2. Organize code into modules for reusability
      3. Use variables with descriptions and validation rules
      4. Define outputs for important resource attributes
      5. Use remote state with locking for team collaboration
      6. Document module purpose, inputs, outputs, and provider requirements
```

{{< /tab >}}

{{< /tabs >}}

<a id="example-projects"></a>

### 示例项目

有关更多自定义审查指令用例，请参见以下生产示例：

- [`gitlab-org/gitlab` 中的 GitLab 开发](https://gitlab.com/gitlab-org/gitlab/-/blob/master/.gitlab/duo/mr-review-instructions.yaml)
- [GitLab 手册](https://gitlab.com/gitlab-com/content-sites/handbook/-/blob/main/.gitlab/duo/mr-review-instructions.yaml)
- [GitLab 网站](https://gitlab.com/gitlab-com/marketing/digital-experience/about-gitlab-com/-/blob/main/.gitlab/duo/mr-review-instructions.yaml)
- [Developer Advocacy: Tanuki IoT Platform](https://gitlab.com/gitlab-da/use-cases/ai/gitlab-duo-agent-platform/demo-environments/tanuki-iot-platform/-/blob/main/.gitlab/duo/mr-review-instructions.yaml)

<a id="troubleshooting"></a>

## 故障排查

在使用 `mr-review-instructions.yaml` 时，您可能会遇到以下问题。

<a id="code-review-flow-skips-instructions-or-returns-a-generic-review"></a>

### 代码评审任务流跳过指令或返回通用评审

如果代码评审任务流跳过您的自定义指令或返回通用评审，
则文件可能存在结构问题。请使用自定义指令 linter 来
识别任何问题。

<a id="run-the-custom-instructions-linter"></a>

#### 运行自定义指令 linter

自定义指令 linter 可帮助您验证 `mr-review-instructions.yaml` 文件。

linter 会检查：

- 无效的 YAML 语法。
- 缺失或意外的顶级键。
- 缺失或空白的必填字段（`name`、`instructions`）。
- 指令条目中的未知键，例如使用 `rules` 而非 `instructions`。
- `fileFilters` 值不是列表，或包含非字符串或空白条目。
- 缺失或空的 `fileFilters`，这会导致指令应用于每个文件（信息）。
- 指令条目之间存在重复的 `name` 值。

> [!note]
> linter 仅读取文件，不会修改它。
> 它不依赖极狐GitLab 或 Rails，可在任何安装了 Ruby 的环境中运行。

先决条件：

- Ruby 3.0 或更高版本。

要在极狐GitLab 服务器上以 Rake 任务形式运行 linter，请将 `<path>` 替换为
您的 `mr-review-instructions.yaml` 文件的路径。例如：

```shell
sudo gitlab-rake "gitlab:duo:lint_review_instructions[<path>]"
```

要在任何安装了 Ruby 的机器上以独立脚本形式运行 linter：

1. 下载 [`review_instructions_linter.rb`](https://gitlab.com/gitlab-org/gitlab/-/raw/master/ee/lib/gitlab/duo/administration/review_instructions_linter.rb)。
1. 运行 linter。将 `<path>` 替换为您的 `mr-review-instructions.yaml` 文件的路径。

   ```shell
   ruby -r ./review_instructions_linter.rb -e '
     linter = Gitlab::Duo::Administration::ReviewInstructionsLinter.new(ARGV[0]).run
     linter.issues.each { |issue| puts issue }
     exit(linter.valid? ? 0 : 1)
   ' <path>
   ```

如果省略路径，linter 默认使用工作目录中的 `.gitlab/duo/mr-review-instructions.yaml`。
如果未发现错误，linter 以状态 `0` 退出，否则以
`1` 退出。警告和信息消息不会导致非零退出。

例如，以下无效文件使用了 `rules` 而非 `instructions`，并且省略了
`fileFilters`：

```yaml
instructions:
  - name: "General"
    rules: "Do something"
```

linter 会报告：

```plaintext
[ERROR E009] Field 'instructions' must be a non-empty string at instructions[0]
[WARNING W003] Unknown keys: "rules"; expected name, instructions, fileFilters at instructions[0]
[INFO I001] Missing 'fileFilters'; the instruction applies to every file at instructions[0]
```

修复报告的错误并重新运行 linter，直到它不再报告错误。

<a id="linter-message-codes"></a>

#### Linter 消息代码

每条消息都包含一个稳定的代码，您可以在寻求帮助时引用。
以 `E` 开头的代码是错误，以 `W` 开头的代码是警告，
以 `I` 开头的代码是关于有效但值得了解的行为的信息性说明。

| 代码 | 描述 |
| ---- | ----------- |
| `E001` | 文件在给定路径不存在。 |
| `E003` | 文件包含无效的 YAML 语法。 |
| `E004` | 顶级 YAML 值不是映射。 |
| `E005` | 缺少顶级 `instructions` 键。 |
| `E006` | `instructions` 值不是列表。 |
| `E007` | `instructions` 下的条目不是映射。 |
| `E008` | 条目的 `name` 字段缺失、空白或不是字符串。 |
| `E009` | 条目的 `instructions` 字段缺失、空白或不是字符串。 |
| `E011` | 条目的 `fileFilters` 值不是列表。 |
| `E013` | 条目的 `fileFilters` 包含非字符串值，例如数字。 |
| `E014` | 条目的 `fileFilters` 包含空白字符串。 |
| `W001` | 文件包含未知的顶级键。 |
| `W002` | `instructions` 列表为空，因此没有指令适用。 |
| `W003` | 条目包含 `name`、`instructions` 和 `fileFilters` 以外的键。 |
| `W004` | 两个或多个条目共享相同的 `name`。 |
| `W007` | 文件为空，因此没有指令适用。 |
| `I001` | 条目缺少 `fileFilters` 字段，因此该指令适用于每个文件。 |
| `I002` | 条目的 `fileFilters` 列表为空，因此该指令适用于每个文件。 |
