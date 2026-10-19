---
stage: AI 赋能
group: AI 编码
info: 如需了解与此页面相关的阶段/群组分配的技术文档撰写人员，请参阅 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 自定义 AI 在合并请求审核中使用的指令。
title: 为极狐GitLab Duo 自定义审核指令
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo Enterprise
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 18.2，作为 [测试版](../../../policy/development_stages_support.md#beta)，通过名为 `duo_code_review_custom_instructions` 的 [功能标志](../../../administration/feature_flags/_index.md) 提供。默认禁用。
- 功能标志 `duo_code_review_custom_instructions` 在极狐GitLab 18.3 中 [默认启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/199802)。
- 功能标志 `duo_code_review_custom_instructions` 在极狐GitLab 18.4 中 [被移除](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/202262)。

{{< /history >}}

创建自定义合并请求审核指令，确保极狐GitLab Duo 对你的项目应用统一且明确的代码审查标准。

例如，你可以仅对 Ruby 文件强制执行 Ruby 风格约定，对 Go 文件强制执行 Go 风格约定。

极狐GitLab Duo 会将你的自定义审核指令追加到其标准审核标准之后，而不是替换它们。

极狐GitLab Duo 代码审查支持自定义审核指令。

<a id="configure-custom-review-instructions"></a>

## 配置自定义审核指令

要配置自定义合并请求审核指令：

1. 在你的仓库根目录中，如果尚不存在，请创建一个 `.gitlab/duo` 目录。
1. 在 `.gitlab/duo` 目录中，创建一个名为 `mr-review-instructions.yaml` 的文件。
1. 使用以下格式添加你的自定义指令：

   ```yaml
   instructions:
     - name: <指令组名称>
       fileFilters:
         - <glob_模式_1>
         - <glob_模式_2>
         - !<排除模式>  # 排除与该模式匹配的文件
       instructions: |
         <你的自定义审核指令>
   ```

   `fileFilters` 部分是必填的。使用 glob 模式指定自定义审核规则的目标文件。

   例如：

   ```yaml
   instructions:
     - name: Ruby 风格指南
       fileFilters:
         - "*.rb"           # 根目录中的 Ruby 文件
         - "lib/**/*.rb"    # lib 及其子目录中的 Ruby 文件
         - "!spec/**/*.rb"  # 排除测试文件
       instructions: |
         1. 确保所有方法都有合适的文档
         2. 遵循 Ruby 风格指南约定
         3. 对于哈希键，优先使用符号而非字符串

     - name: TypeScript 源文件
       fileFilters:
         - "**/*.ts"        # 任意目录中的 TypeScript 文件
         - "!**/*.test.ts"  # 排除测试文件
         - "!**/*.spec.ts"  # 排除规格文件
       instructions: |
         1. 确保使用正确的 TypeScript 类型（避免 'any'）
         2. 遵循命名约定
         3. 为复杂函数编写文档

     - name: 除测试外的所有文件
       fileFilters:
         - "!**/*.test.*"   # 排除所有测试文件
         - "!**/*.spec.*"   # 排除所有规格文件
         - "!test/**/*"     # 排除测试目录
         - "!spec/**/*"     # 排除规格目录
       instructions: |
         1. 遵循统一的代码风格
         2. 为复杂逻辑添加有意义的注释
         3. 确保适当的错误处理

     - name: 测试覆盖率
       fileFilters:
         - "spec/**/*_spec.rb" # spec 目录中的 Ruby 测试文件
       instructions: |
         1. 测试正常路径和边界情况
         2. 包含错误场景
         3. 使用共享示例减少重复

     - name: 所有文件
       fileFilters:
         - "**/*"   # 仓库中的所有文件
       instructions: |
         1. 解释每条建议背后的“原因”
   ```

   有关 glob 语法示例，请参阅
   [文件模式参考](#file-pattern-reference)。

1. 可选：添加 [代码所有者](../../project/codeowners/_index.md) 条目以
   保护对 `mr-review-instructions.yaml` 文件的更改。

   ```markdown
   [极狐GitLab Duo]
   .gitlab/duo @default-owner @tech-lead
   ```

1. [创建合并请求](../../project/merge_requests/creating_merge_requests.md)
   以审核并合并更改：

   - 当文件模式匹配时，极狐GitLab Duo 会自动应用你的自定义指令。
   - 多个指令组可以应用于单个文件。
   - 对于由你的自定义指令触发的审核评论，极狐GitLab Duo 使用以下格式：

     ```plaintext
     根据 '[instruction_name]' 中的自定义指令：[反馈评论]
     ```

     `instruction_name` 值对应于你的
     `.gitlab/duo/mr-review-instructions.yaml` 文件中的 `name` 属性。极狐GitLab Duo 标准评论
     不使用此格式。
     <br><br>
     如果极狐GitLab Duo 没有发现任何问题，它会留下一条审核摘要评论。自定义
     指令不适用于此摘要评论。
1. 可选：
   - 查看反馈并根据需要完善你的指令。
   - 测试这些模式以确保它们与预期的文件匹配。

<a id="best-practices"></a>

## 最佳实践

编写自定义审核指令时：

- 要具体且可执行。
- 为指令编号，使之清晰。
- 聚焦最重要的标准。
- 在有用的情况下解释“为什么”。
- 从简单的指令开始，根据需要增加复杂度。

例如：

```yaml
instructions: |
  1. 所有公共函数必须包含带有参数描述的文档字符串
  2. 使用参数化查询防止 SQL 注入
  3. 在处理前验证用户输入（检查类型、长度、格式）
  4. 对所有外部 API 调用包含错误处理
  5. 避免硬编码凭据——使用环境变量
```

有关语言特定示例，请参阅 [用例示例](#use-case-examples)。

<a id="file-pattern-reference"></a>

## 文件模式参考

在 `fileFilters` 中使用 glob 模式来指定目标文件。

例如，对于一个包含 Ruby 文件的项目：

| 模式 | 匹配 |
| --- | --- |
| `**/*.rb`       | 任何目录中的所有 Ruby 文件 |
| `*.rb`          | 仅根目录中的 Ruby 文件 |
| `lib/**/*.rb`   | `lib` 目录及其子目录中的 Ruby 文件 |
| `!**/*.test.rb` | 排除所有 Ruby 测试文件 |
| `!spec/**/*.rb` | 排除 `spec` 目录及其子目录中的所有 Ruby 文件 |
| `!tests/**/*`   | 排除 `tests` 目录及其子目录中的所有文件 |
| `**/*.{js,jsx}` | 所有目录中的 JavaScript 和 JSX 文件 |

下面的示例展示了 `**/*.rb` 与 `*.rb` 的区别：

```plaintext
project/
├── app.rb              ← 被 *.rb 和 **/*.rb 两者匹配
├── lib/
│   └── helper.rb       ← 仅被 **/*.rb 匹配
└── app/
    └── models/
        └── user.rb     ← 仅被 **/*.rb 匹配
```

- `*.rb` 只会匹配 app.rb
- `**/*.rb` 会匹配所有三个文件

对于 `mr-review-instructions.yaml` 文件，`**/*.rb` 确保审核指令
应用于项目结构中任何位置的 Ruby 文件，而不仅仅是根目录。

<a id="use-case-examples"></a>

## 用例示例

<!-- 2025-11-12 用例示例由 DevRel 维护，@dnsmichi
灵感来自 <https://gitlab.com/gitlab-da/use-cases/ai/gitlab-duo-agent-platform/demo-environments/tanuki-iot-platform/-/blob/main/.gitlab/duo/mr-review-instructions.yaml?ref_type=heads> 中的参考
-->

{{< tabs >}}

{{< tab title="Assembly" >}}

```yaml
instructions:
  - name: Assembly 风格指南
    fileFilters:
      - "**/*.asm"
      - "**/*.s"
      - "**/*.S"
    instructions: |
      1. 在顶部注明目标架构（x86-64、ARM、RISC-V、AVR 等）
      2. 使用有意义的标签并为非显而易见的指令添加注释
      3. 说明寄存器使用情况和调用约定
      4. 适当对齐代码段以提高可读性
      5. 包含内存布局和栈使用文档
```

{{< /tab >}}

{{< tab title="C" >}}

```yaml
instructions:
  - name: C 风格指南
    fileFilters:
      - "**/*.c"
      - "**/*.h"
    instructions: |
      1. 不允许使用 goto
      2. 避免使用全局变量
      3. 使用有意义的变量名
      4. 为复杂逻辑添加注释
```

{{< /tab >}}

{{< tab title="C++" >}}

```yaml
instructions:
  - name: C++ 风格指南
    fileFilters:
      - "**/*.cpp"
      - "**/*.{h,hpp}"
    instructions: |
      1. 确保所有方法都有合适的文档
      2. 使用智能指针进行动态内存管理
      3. 避免裸指针
```

{{< /tab >}}

{{< tab title="C#" >}}

```yaml
instructions:
  - name: C# 风格指南
    fileFilters:
      - "**/*.cs"
    instructions: |
      1. 遵循 Microsoft C# 编码规范
      2. 对公共 API 使用 XML 文档注释
      3. 优先使用 async/await 进行异步操作
      4. 适当使用可空引用类型
      5. 遵循 .NET 命名约定（公共成员使用 PascalCase）
```

{{< /tab >}}

{{< tab title="COBOL" >}}

```yaml
instructions:
  - name: COBOL 风格指南
    fileFilters:
      - "**/*.CBL"
      - "**/*.cbl"
      - "**/*.COB"
      - "**/*.cob"
    instructions: |
      1. 为变量和过程使用清晰且有意义的名称
      2. 尽可能优先使用 COBOL-85 语法
      3. 使用正确的部结构（IDENTIFICATION、ENVIRONMENT、DATA、PROCEDURE）
      4. 为所有节和段添加有意义的注释
      5. 对布尔标志和状态码使用 88 级条件名
      6. 避免使用 GO TO 语句，优先使用 PERFORM 实现结构化编程
      7. 使用 declarations 或状态码检查进行正确的错误处理
      8. 使用适当的 PICTURE 子句定义工作存储变量
      9. 使用有意义的段名，描述其操作
      10. 对于大型机集成，记录 JCL 依赖关系和文件布局
```

{{< /tab >}}

{{< tab title="Go" >}}

```yaml
instructions:
  - name: Go 风格指南
    fileFilters:
      - "**/*.go"
    instructions: |
      1. 使用惯用的 Go 实践
      2. 确保所有公共函数和类型都有文档
      3. 尽可能优先使用标准库包而非第三方包
```

{{< /tab >}}

{{< tab title="Java" >}}

```yaml
instructions:
  - name: Java 风格指南
    fileFilters:
      - "**/*.java"
    instructions: |
      1. 不要将 Java 8 代码升级到 Java 11+ 特性，除非有极狐GitLab 议题或任务专门要求升级
      2. 所有公共类必须包含描述用途和用法的 Javadoc
      3. 所有公共方法必须包含带有 @param 和 @return 标签的 Javadoc
      4. 在主类的 Javadoc 中包含代码示例
      5. 所有公共方法必须至少有一个测试用例
```

{{< /tab >}}

{{< tab title="JavaScript/TypeScript" >}}

```yaml
instructions:
  - name: JavaScript/TypeScript 文件
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
      1. 使用 const/let 而不是 var
      2. 优先使用 async/await 而非 Promise 链
      3. 为复杂函数添加 JSDoc 注释
      4. 确保异步代码中有适当的错误处理
      5. 避免在 TypeScript 中使用 'any' 类型
```

{{< /tab >}}

{{< tab title="Kotlin" >}}

```yaml
instructions:
  - name: Kotlin 风格指南
    fileFilters:
      - "**/*.kt"
      - "**/*.kts"
    instructions: |
      1. 遵循 Kotlin 编码规范
      2. 优先使用不可变性（val 优于 var）
      3. 使用协程进行异步操作
      4. 利用 Kotlin 的空安全特性
      5. 使用 KDoc 记录公共 API
```

{{< /tab >}}

{{< tab title="MATLAB" >}}

```yaml
instructions:
  - name: MATLAB 风格指南
    fileFilters:
      - "**/*.m"
    instructions: |
      1. 使用描述性变量和函数名，采用 camelCase 约定
      2. 尽可能向量化操作，而不是使用循环
      3. 使用 H1 行和帮助文本注释记录函数
      4. 在循环前预分配数组以提高性能
      5. 使用 try-catch 块和 error() 函数进行正确的错误处理
```

{{< /tab >}}

{{< tab title="Perl" >}}

```yaml
instructions:
  - name: Perl 风格指南
    fileFilters:
      - "**/*.pl"
      - "**/*.pm"
    instructions: |
      1. 遵循惯用的 Perl 实践
      2. 确保适当的模块文档
      3. 使用 strict 和 warnings 编译指令
```

{{< /tab >}}

{{< tab title="PHP" >}}

```yaml
instructions:
  - name: PHP 风格指南
    fileFilters:
      - "**/*.php"
    instructions: |
      1. 遵循 PSR-12 编码标准
      2. 为函数参数和返回类型使用类型声明
      3. 确保与 PHP 8+ 兼容
      4. 使用适当的错误处理和异常
      5. 使用 PHPDoc 记录类和方法
```

{{< /tab >}}

{{< tab title="Python" >}}

```yaml
instructions:
  - name: Python 源文件
    fileFilters:
      - "**/*.py"
      - "!tests/**/*.py"
      - "!test_*.py"
    instructions: |
      1. 所有函数必须包含带参数和返回类型的文档字符串
      2. 为函数签名使用类型提示
      3. 遵循 PEP 8 风格约定
      4. 确保适当的异常处理
      5. 避免使用裸 'except' 子句

  - name: Python 测试
    fileFilters:
      - "tests/**/*.py"
      - "test_*.py"
    instructions: |
      1. 使用 pytest 夹具进行常规设置
      2. 测试名称应清晰描述所测试的场景
      3. 包含对预期结果和边界情况的断言
      4. 适当模拟外部依赖
```

{{< /tab >}}

{{< tab title="Ruby" >}}

```yaml
instructions:
  - name: Ruby 风格指南
    fileFilters:
      - "*.rb"
      - "lib/**/*.rb"
      - "!spec/**/*.rb"  # 排除测试文件
    instructions: |
      1. 遵循 Ruby 风格指南约定
      2. 对于哈希键，优先使用符号而非字符串
      3. 方法/变量使用 snake_case，常量使用 SCREAMING_SNAKE_CASE，类使用 CamelCase
      4. 适当优先使用 Ruby 3.0+ 特性（模式匹配、无限方法）
      5. 使用适当的错误处理——通过引发异常而非返回 nil 来表示错误
      6. 编写地道的 Ruby——使用块、可枚举对象和 Ruby 惯用法，而非过程式模式
      7. 使用有意义的方法名——对谓词方法使用 ?，对危险方法使用 !
      8. 对于具有多个参数的方法，优先使用关键字参数
      9. 所有公共方法都应有相应的 RSpec/Minitest 测试
      10. 使用 Gemfile 管理依赖并确保版本兼容性
      11. 记录线程安全代码，并对并发操作使用适当的同步
      12. 为守护进程正确处理信号（SIGTERM、SIGINT）
```

{{< /tab >}}

{{< tab title="R" >}}

```yaml
instructions:
  - name: R 风格指南
    fileFilters:
      - "**/*.r"
      - "**/*.R"
    instructions: |
      1. 遵循 tidyverse 风格指南约定
      2. 对变量和函数名使用 snake_case
      3. 使用 roxygen2 注释记录函数
      4. 优先使用向量化操作而非循环
      5. 使用 tryCatch 和 stop() 进行适当的错误处理
```

{{< /tab >}}

{{< tab title="Rust" >}}

```yaml
instructions:
  - name: Rust 风格指南
    fileFilters:
      - "**/*.rs"
    instructions: |
      1. 遵循 Rust 惯用法和约定
      2. 使用 Result 和 Option 类型进行适当的错误处理
      3. 除非绝对必要且有充分文档，否则避免使用 unsafe 代码
      4. 确保所有公共项都有文档注释
```

{{< /tab >}}

{{< tab title="Scala" >}}

```yaml
instructions:
  - name: Scala 风格指南
    fileFilters:
      - "**/*.scala"
    instructions: |
      1. 遵循 Scala 风格指南约定
      2. 优先使用不可变数据结构（val 优于 var）
      3. 有效利用模式匹配进行流程控制
      4. 使用 ScalaDoc 记录公共 API
      5. 使用 Try、Either 或 Option 类型进行适当的错误处理
```

{{< /tab >}}

{{< tab title="Shell" >}}

```yaml
instructions:
  - name: Shell 脚本风格指南
    fileFilters:
      - "**/*.sh"
      - "**/*.bash"
      - "**/*.zsh"
      - "**/*.ksh"
    instructions: |
      1. 始终为变量加上引号以防止单词拆分（"$var" 而非 $var）
      2. 在脚本开头使用 set -euo pipefail 进行适当的错误处理
      3. 在头部注释中记录脚本用途、参数和退出代码
      4. 优先使用 [[ ]] 而非 [ ] 进行条件测试
      5. 使用有意义的函数名，避免复杂的单行命令
```

{{< /tab >}}

{{< tab title="SQL" >}}

```yaml
instructions:
  - name: SQL 风格指南
    fileFilters:
      - "**/*.sql"
    instructions: |
      1. 对 SQL 关键字使用大写（SELECT、FROM、WHERE、JOIN）
      2. 始终显式指定列名，不要使用 SELECT *
      3. 对于 PostgreSQL 使用 SERIAL/RETURNING，对于 MySQL 使用 AUTO_INCREMENT，对于 Oracle 使用 SEQUENCE
      4. 对于 NoSQL（MongoDB），使用正确的索引和聚合管道以避免 N+1 查询
      5. 记录数据库特定功能和预期的性能特征
      6. 对复杂查询和子查询使用适当的缩进
```

{{< /tab >}}

{{< tab title="VHDL" >}}

```yaml
instructions:
  - name: VHDL 风格指南
    fileFilters:
      - "**/*.vhd"
      - "**/*.vhdl"
    instructions: |
      1. 遵循 IEEE VHDL 编码标准
      2. 使用有意义的信号和实体名称，并带有清晰的前缀
      3. 用注释记录所有实体、架构和过程
      4. 使用同步设计实践，正确处理时钟和复位
      5. 避免组合逻辑环路并确保适当的时序约束
```

{{< /tab >}}

{{< tab title="配置文件" >}}

```yaml
instructions:
  - name: 配置文件
    fileFilters:
      - "*.yaml"
      - "*.yml"
      - "*.json"
      - "config/**/*"
      - "!.gitlab/**/*"
    instructions: |
      1. 不要包含敏感数据（密码、API 密钥）
      2. 对环境特定值使用环境变量
      3. 记录所有配置选项
      4. 尽可能验证配置模式
```

{{< /tab >}}

{{< tab title="基础设施即代码" >}}

```yaml
instructions:
  - name: Ansible 风格指南
    fileFilters:
      - "*.yaml"
      - "*.yml"
      - "playbooks/**/*.yaml"
      - "roles/**/*.yaml"
    instructions: |
      1. 使用有意义的 play 和任务名称，描述其操作
      2. 尽可能优先使用模块而非 shell/command 任务
      3. 使用变量和默认值以便跨环境重用
      4. 实现幂等性——任务应可安全地多次运行
      5. 使用 handlers 进行服务重启和通知
      6. 记录 playbook 用途、所需变量和依赖关系

  - name: Dockerfile 风格指南
    fileFilters:
      - "Dockerfile"
      - "*.dockerfile"
      - "Dockerfile.*"
    instructions: |
      1. 使用特定的基础镜像标签，避免使用 'latest'
      2. 通过适时使用 && 组合 RUN 命令来减少层数
      3. 使用多阶段构建减小最终镜像大小
      4. 以非 root 用户身份运行容器以增强安全性
      5. 使用 .dockerignore 排除不必要的文件
      6. 记录暴露的端口、卷和环境变量

  - name: 极狐GitLab CI/CD 风格指南
    fileFilters:
      - ".gitlab-ci.yml"
      - "**/.gitlab-ci.yml"
    instructions: |
      1. 使用 job extends 而非 YAML 锚点以实现可重用性
      2. 始终使用 rules 而非 only/except 进行作业条件控制
      3. 为依赖项定义适当的缓存策略
      4. 使用 stages 逻辑地组织流水线工作流
      5. 包含安全扫描模板（SAST、依赖项扫描、密钥检测）
      6. 在注释中记录作业用途、所需变量和依赖关系

  - name: Helm Chart 风格指南
    fileFilters:
      - "Chart.yaml"
      - "values.yaml"
      - "templates/**/*.yaml"
    instructions: |
      1. 对 Chart 版本使用语义化版本
      2. 在 values.yaml 中提供合理的默认值并添加注释
      3. 使用模板函数进行条件逻辑和循环
      4. 包含带有安装后指示的 NOTES.txt
      5. 在提交前使用 helm lint 验证 Chart
      6. 记录所有可配置值及其用途

  - name: Kubernetes 风格指南
    fileFilters:
      - "*.yaml"
      - "*.yml"
      - "k8s/**/*.yaml"
      - "kubernetes/**/*.yaml"
    instructions: |
      1. 使用明确的 API 版本，避免使用已弃用的 API
      2. 始终为容器定义资源限制和请求
      3. 使用命名空间逻辑地组织资源
      4. 为所有部署定义存活和就绪探针
      5. 使用 ConfigMap 和 Secret 而非硬编码值
      6. 在元数据注释中记录资源用途和依赖关系

  - name: Terraform/OpenTofu 风格指南
    fileFilters:
      - "*.tf"
      - "*.tfvars"
    instructions: |
      1. 对资源使用一致的命名约定（environment_service_resource）
      2. 将代码组织为模块以增强可重用性
      3. 使用带有描述和验证规则的变量
      4. 为重要的资源属性定义输出
      5. 使用带锁的远程状态以便团队协作
      6. 记录模块用途、输入、输出和提供者要求
```

{{< /tab >}}

{{< /tabs >}}

<a id="example-projects"></a>

### 示例项目

有关更多自定义审核指令用例，请参阅以下生产环境示例：

- [极狐GitLab 开发 (`gitlab-cn/gitlab`)](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/.gitlab/duo/mr-review-instructions.yaml)
- [极狐GitLab 手册](https://jihulab.com/gitlab-com/content-sites/handbook/-/blob/main/.gitlab/duo/mr-review-instructions.yaml)
- [极狐GitLab 网站](https://jihulab.com/gitlab-com/marketing/digital-experience/about-gitlab-com/-/blob/main/.gitlab/duo/mr-review-instructions.yaml)
- [开发者倡导：Tanuki IoT 平台](https://jihulab.com/gitlab-da/use-cases/ai/gitlab-duo-agent-platform/demo-environments/tanuki-iot-platform/-/blob/main/.gitlab/duo/mr-review-instructions.yaml)

<a id="related-topics"></a>

## 相关主题

- [合并请求中的极狐GitLab Duo](../../project/merge_requests/duo_in_merge_requests.md)
- [极狐GitLab Duo 代码审查](../code_review.md)