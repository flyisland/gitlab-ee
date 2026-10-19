---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use the 极狐GitLab for VS Code extension to perform and review security scans.
title: 在极狐GitLab for VS Code 中保护你的应用安全
---

使用极狐GitLab for VS Code 扩展来检查您的应用程序是否存在安全漏洞。直接在您的 IDE 中审查安全发现并运行文件的静态应用安全测试 (SAST)。

## 查看安全发现

<a id="view-security-findings"></a>

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

先决条件：

- 极狐GitLab for VS Code 3.74.0 或更高版本。
- 一个包含[安全风险管理](https://gitlab.cn/features/?stage=secure)功能的项目，例如静态应用安全测试 (SAST)、动态应用安全测试 (DAST)、容器扫描或依赖项扫描。
- 已配置[安全风险管理](../../user/application_security/secure_your_application.md)功能。

要查看安全发现：

1. 在 VS Code 中，在左侧边栏中，选择 **极狐GitLab** ({{< icon name="tanuki" >}})。
1. 在当前分支部分，展开 **安全扫描**。
1. 选择 **新发现** 或 **已修复发现**。
1. 选择一个严重级别。
1. 选择一个发现以在 VS Code 标签页中打开它。

## 静态应用安全测试 (SAST)

<a id="static-application-security-testing-sast"></a>

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Status: Experiment

{{< /details >}}

{{< history >}}

- 在 VS Code 扩展 5.31 中引入。

{{< /history >}}

VS Code 中的静态应用安全测试 (SAST) 会检测活动文件中的漏洞。通过早期检测，您可以在将更改合并到默认分支之前修复漏洞。

当您触发 SAST 扫描时，活动文件的内容将传递给极狐GitLab，并依据 SAST 漏洞规则进行检查。极狐GitLab 会在 **极狐GitLab** ({{< icon name="tanuki" >}}) 扩展面板中显示扫描结果。

### 启用 SAST 扫描

<a id="enable-sast-scanning"></a>

要启用实时 SAST 扫描：

1. 选择 **扩展** > **极狐GitLab**。
1. 选择 **管理** ({{< icon name="settings" >}})，然后选择 **设置** > **代码安全**。
1. 选中 **启用实时 SAST 扫描** 复选框。
1. 可选。要在保存文件时启用活动文件的 SAST 扫描，请选中 **启用文件保存时扫描** 复选框。

### 执行 SAST 扫描

<a id="perform-sast-scanning"></a>

先决条件：

- 极狐GitLab for VS Code 5.31.0 或更高版本。
- 扩展[已与极狐GitLab 认证](setup.md#authenticate-with-gitlab)。
- 已启用实时 SAST 扫描。

要在 VS Code 中对文件执行 SAST 扫描：

1. 打开文件。
1. 通过以下任一方式触发 SAST 扫描：
   - 保存文件（如果您已启用在文件保存时扫描）。
   - 在左侧边栏中，选择 **极狐GitLab** ({{< icon name="tanuki" >}}) > **极狐GitLab 远程扫描 (SAST)**。然后，选择该部分顶部的 **扫描当前文件** 按钮。
   - 使用命令面板：
     1. 打开命令面板：
        - 对于 macOS，按 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
        - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
     1. 搜索 **极狐GitLab: Run Remote Scan (SAST)** 并按 <kbd>Enter</kbd>。
1. 查看 SAST 扫描结果。
   1. 在 VS Code 中，在左侧边栏中，选择 **极狐GitLab** ({{< icon name="tanuki" >}})。
   1. 展开极狐GitLab 远程扫描 (SAST) 部分。SAST 扫描结果按严重程度降序列出。
   1. 选择一个发现以查看详细信息。