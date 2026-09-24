---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use Code Owners to define experts for your codebase, and set review requirements based on file type or location.
title: 代码所有者
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用代码所有者功能来定义谁对项目代码库的特定部分拥有专业知识。

在仓库中定义文件和目录的所有者，以便：

- 要求所有者批准更改。将受保护分支与代码所有者结合，要求专家在合并到受保护分支之前批准合并请求。更多信息，请参见[代码所有者与受保护分支](#code-owners-and-protected-branches)。
- 识别所有者。代码所有者名称显示在他们拥有的文件和目录上：

  ![文件视图，显示在最近更改描述下方列出的代码所有者](img/codeowners_in_UI_v15_10.png)

<a id="code-owners-and-approval-rules"></a>

## 代码所有者与审批规则

将代码所有者与合并请求 [审批规则](../merge_requests/approvals/rules.md)（可选或必需）相结合，构建灵活的审批工作流程：

- 使用代码所有者确保质量。定义对仓库中特定路径拥有领域专业知识的用户。
- 使用审批规则定义与仓库中特定文件路径不对应的专业领域。审批规则帮助引导合并请求创建者找到正确的审阅者集合，例如前端开发人员或安全团队。

例如：

| 类型 | 名称 | 范围 | 注释 |
|------|------|--------|------------|
| 审批规则            | 用户体验                   | 所有文件     | 一名用户体验团队成员审查项目中所有更改的用户体验。 |
| 审批规则            | 安全             | 所有文件     | 一名安全团队成员审查所有更改是否存在漏洞。 |
| 代码所有者审批规则 | 前端：代码风格 | `*.css` 文件 | 一名前端工程师审查 CSS 文件的更改，以确保符合项目风格标准。 |
| 代码所有者审批规则 | 后端：代码审查 | `*.rb` 文件  | 一名后端工程师审查 Ruby 文件的逻辑和代码风格。 |

有关谁有资格作为审批人或代码所有者批准合并请求的信息，请参阅[按成员身份类型的审批人](../merge_requests/approvals/rules.md#approver-by-membership-type)。

<a id="code-owners-and-protected-branches"></a>

## 代码所有者与受保护分支

为确保合并请求更改由 [`CODEOWNERS` 文件](#codeowners-file) 中指定的代码所有者审核和批准，合并请求的目标分支必须处于 [受保护](../repository/branches/protected.md) 状态，并且需启用 [代码所有者审批](../repository/branches/protected.md#require-code-owner-approval)。

当您在受保护分支上启用代码所有者审批时，以下功能可用：

- [需要代码所有者审批](../repository/branches/protected.md#require-code-owner-approval)。
- [需要代码所有者的多个审批](advanced.md#require-multiple-approvals-from-code-owners)。
- [代码所有者的可选审批](reference.md#optional-sections)。

<a id="practical-example"></a>

### 实践示例

您的项目在 `config/` 目录中包含敏感且重要的信息。您可以：

1. 分配目录的所有权。为此，设置一个 `CODEOWNERS` 文件。
1. 为默认分支创建一个受保护分支。例如 `main`。
1. 在受保护分支上启用 **需要代码所有者审批**。
1. 可选。编辑 `CODEOWNERS` 文件以添加多个审批的规则。

通过这种配置，更改 `config/` 目录中文件且目标分支为 `main` 的合并请求在合并之前需要指定的代码所有者批准。

<a id="allowed-to-push-and-merge-to-a-protected-branch"></a>

### 允许推送到受保护分支并进行合并

**允许推送并合并** 的用户可以选择为其更改创建合并请求，或者直接将更改推送到分支。如果用户跳过合并请求流程，则内置于合并请求中的受保护分支功能和代码所有者审批也将被跳过。

此权限通常授予与自动化（[内部用户](../../../administration/internal_users.md)）和发布工具关联的帐户。

没有 **允许推送** 权限的用户所做的所有更改都必须通过合并请求进行。

<a id="view-code-owners-of-a-file-or-directory"></a>

## 查看文件或目录的代码所有者

要查看文件或目录的代码所有者：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **代码** > **仓库**。
1. 转到您想查看代码所有者的文件或目录。
1. 可选。选择一个分支或标签。

极狐GitLab 在页面顶部显示代码所有者。

<a id="set-up-code-owners"></a>

## 设置代码所有者

前提条件：

- 您必须拥有推送到默认分支或创建合并请求的权限。

1. 在您的 [首选位置](#codeowners-file) 创建 `CODEOWNERS` 文件。
1. 按照 [`CODEOWNERS` 语法](reference.md) 在文件中定义一些规则。
   一些建议：
   - 配置 [**所有符合条件的用户**](../merge_requests/approvals/rules.md#code-owners-as-approvers) 审批规则。
   - 在受保护分支上 [要求代码所有者审批](../repository/branches/protected.md#require-code-owner-approval)。
1. 提交您的更改，并将它们推送到极狐GitLab。

<a id="codeowners-file"></a>

## `CODEOWNERS` 文件

`CODEOWNERS` 文件定义谁负责极狐GitLab 项目中的代码。其目的是：

- 定义特定文件和目录的代码所有者。
- 为受保护分支强制执行审批要求。
- 在项目中传达代码所有权。

此文件确定谁应审核和批准更改，并确保合适的专家参与代码更改。

每个仓库使用一个 `CODEOWNERS` 文件。极狐GitLab 按以下顺序检查仓库中的这些位置。找到的第一个 `CODEOWNERS` 文件将被使用，所有其他文件将被忽略：

1. 在根目录中：`./CODEOWNERS`。
1. 在 `docs` 目录中：`./docs/CODEOWNERS`。
1. 在 `.gitlab` 目录中：`./.gitlab/CODEOWNERS`。

更多信息，请参阅 [`CODEOWNERS` 语法](reference.md) 和 [高级 `CODEOWNERS` 配置](advanced.md)。