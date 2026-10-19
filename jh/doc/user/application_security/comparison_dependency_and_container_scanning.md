---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 依赖扫描与容器扫描对比
description: 依赖扫描与容器扫描对比。
---

极狐GitLab 同时提供[依赖扫描](dependency_scanning/_index.md)和
[容器扫描](container_scanning/_index.md)以确保覆盖所有这些
依赖类型。为了尽可能覆盖您的风险区域，您应该使用所有可用的
安全扫描工具：

- 依赖扫描分析您的项目，并告诉您哪些软件依赖项，
  包括上游依赖项，已被包含在您的项目中，以及这些依赖项包含哪些已知
  风险。
- 容器扫描分析您的容器，并告诉您操作系统 (OS) 软件包中的已知风险。

下表总结了每种扫描工具可以检测的依赖类型：

| 功能                                                                                      | 依赖扫描 | 容器扫描 |
|----------------------------------------------------------------------------------------------|---------------------|--------------------|
| 识别引入依赖的清单文件、锁定文件或静态文件              | {{< yes >}}         | {{< no >}}         |
| 开发依赖项                                                                     | {{< yes >}}         | {{< no >}}         |
| 已提交到您仓库的锁定文件中的依赖项                                     | {{< yes >}}         | {{< yes >}} <sup>1</sup> |
| 由 Go 构建的二进制文件                                                                         | {{< no >}}          | {{< yes >}} <sup>2</sup> |
| 由操作系统安装的动态链接的特定语言依赖项          | {{< no >}}          | {{< yes >}}        |
| 操作系统依赖项                                                                | {{< no >}}          | {{< yes >}}        |
| 安装在操作系统上的特定语言依赖项（非由您的项目构建） | {{< no >}}          | {{< yes >}}        |

1. 锁定文件必须存在于镜像中才能被检测到。
1. [报告特定语言的发现](container_scanning/_index.md#report-language-specific-findings) 必须启用，且二进制文件必须存在于镜像中才能被检测到。