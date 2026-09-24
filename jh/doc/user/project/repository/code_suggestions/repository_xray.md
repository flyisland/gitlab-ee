---
stage: AI-powered
group: AI Coding
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Repository X-Ray gives 极狐GitLab Code Suggestions more insight into your project's codebase and dependencies.
title: 仓库 X 光与代码建议
---

{{< history >}}

- 在极狐GitLab 16.7 引入。

{{< /history >}}

仓库 X 光自动增强：

- [极狐GitLab Duo 代码建议](_index.md)的代码生成请求，通过提供关于项目依赖的额外上下文，以提高代码推荐的准确性和相关性。
- 对[重构代码](../../../gitlab_duo_chat/examples.md#refactor-code-in-the-ide)、[修复代码](../../../gitlab_duo_chat/examples.md#fix-code-in-the-ide)和[编写测试](../../../gitlab_duo_chat/examples.md#write-tests-in-the-ide)的请求。

为此，仓库 X 光通过以下方式让代码助手更深入地了解项目的代码库和依赖：

- 搜索依赖管理器的配置文件（例如 `Gemfile.lock`、`package.json`、`go.mod`）。
- 从这些文件内容中提取依赖库列表。
- 将提取的列表作为额外上下文提供给极狐GitLab Duo 代码建议，用于代码生成、重构代码、修复代码和编写测试的请求。

通过了解正在使用的库和其他依赖项，仓库 X 光帮助代码助手调整建议，以匹配项目中使用的编码模式、风格和技术。这使代码建议能够更无缝地集成，并遵循相应技术栈的最佳实践。

> [!NOTE]
> 仓库 X 光仅增强代码生成请求，而不增强代码补全请求。

<a id="how-repository-x-ray-works"></a>

## 仓库 X 光的工作方式

{{< history >}}

- 最大库数量在极狐GitLab 17.6 中引入。

{{< /history >}}

当你向项目的默认分支推送一个新提交时，仓库 X 光会触发一个后台作业。此作业会扫描并解析仓库中适用的配置文件。

通常，每个项目中一次只运行一个扫描作业。如果在已有扫描进行时触发第二次扫描，第二次扫描将等待第一次扫描完成后才执行。这可能会导致在数据库中最新的配置文件数据被解析和更新之前出现短暂延迟。

当发出代码生成请求时，从解析的数据中最多包含 300 个库作为提示中的额外上下文。

<a id="enable-repository-x-ray"></a>

## 启用仓库 X 光

{{< history >}}

- 在极狐GitLab 17.4 中通过名为 `ai_enable_internal_repository_xray_service` 的功能标志引入，默认禁用。
- 在极狐GitLab 17.6 中 GA，功能标志 `ai_enable_internal_repository_xray_service` 已移除。

{{< /history >}}

如果你的项目可以访问[极狐GitLab Duo 代码建议](_index.md)，仓库 X 光服务会自动启用。

<a id="supported-languages-and-dependency-managers"></a>

## 支持的语言和依赖管理器

仓库 X 光最多从仓库根目录搜索两层目录。例如，它支持 `Gemfile.lock`、`api/Gemfile.lock` 或 `api/client/Gemfile.lock`，但不支持 `api/v1/client/Gemfile.lock`。对于每种语言，仅处理第一个匹配的依赖管理器。如果存在锁定文件，则锁定文件优先于非锁定文件。

| 语言       | 依赖管理器 | 配置文件                                | 极狐GitLab 版本 |
| ---------- |------------| --------------------------------------- | --------------- |
| C/C++      | Conan      | `conanfile.py`                          | 17.5 或更高版本 |
| C/C++      | Conan      | `conanfile.txt`                         | 17.5 或更高版本 |
| C/C++      | vcpkg      | `vcpkg.json`                            | 17.5 或更高版本 |
| C#         | NuGet      | `*.csproj`                              | 17.5 或更高版本 |
| Go         | Go Modules | `go.mod`                                | 17.4 或更高版本 |
| Java       | Gradle     | `build.gradle`                          | 17.4 或更高版本 |
| Java       | Maven      | `pom.xml`                               | 17.4 或更高版本 |
| JavaScript | NPM        | `package-lock.json`、`package.json`     | 17.5 或更高版本 |
| Kotlin     | Gradle     | `build.gradle.kts`                      | 17.5 或更高版本 |
| PHP        | Composer   | `composer.lock`、`composer.json`        | 17.5 或更高版本 |
| Python     | Conda      | `environment.yml`                       | 17.5 或更高版本 |
| Python     | Pip        | `*requirements*.txt` <sup>1</sup>       | 17.5 或更高版本 |
| Python     | Poetry     | `poetry.lock`、`pyproject.toml`         | 17.5 或更高版本 |
| Ruby       | RubyGems   | `Gemfile.lock`                          | 17.4 或更高版本 |

脚注：

1. 对于 Python Pip，处理所有与 `*requirements*.txt` glob 模式匹配的配置文件。