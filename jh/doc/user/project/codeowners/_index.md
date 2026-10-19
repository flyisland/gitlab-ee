---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用代码所有者来定义代码库的专家，并根据文件类型或位置设置评审要求。
title: 代码所有者
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用代码所有者功能来定义谁对项目代码库的特定部分具有专业知识。

定义代码仓库中文件和目录的所有者，以便：

- 要求所有者批准变更。将受保护分支与代码所有者结合使用，要求专家在合并请求合并到受保护分支之前批准该合并请求。有关更多信息，请参阅[代码所有者和受保护分支](#code-owners-and-protected-branches)。
- 标识所有者。代码所有者名称会显示在其拥有的文件和目录上：

  ![文件视图，显示在最近变更描述下方列出的代码所有者。](img/codeowners_in_UI_v15_10.png)

<a id="code-owners-and-approval-rules"></a>

## 代码所有者和审批规则

将代码所有者与合并请求[审批规则](../merge_requests/approvals/rules.md)（可选或必需）结合使用，构建灵活的审批工作流：

- 使用代码所有者来确保质量。定义对代码仓库中特定路径具有领域专业知识的用户。
- 使用审批规则来定义不对应代码仓库中特定文件路径的专业领域。审批规则有助于引导合并请求创建者
  找到正确的审核人集合，例如前端开发者或安全团队。

例如：

| 类型 | 名称 | 范围  | 评论    |
|------|------|--------|------------|
| 审批规则            | UX                   | 所有文件     | 用户体验（UX）团队成员评审项目中所有变更的用户体验。 |
| 审批规则            | 安全             | 所有文件     | 安全团队成员评审所有变更是否存在漏洞。 |
| 代码所有者审批规则 | 前端：代码风格 | `*.css` 文件 | 前端工程师评审 CSS 文件变更是否符合项目风格标准。 |
| 代码所有者审批规则 | 后端：代码评审 | `*.rb` 文件  | 后端工程师评审 Ruby 文件的逻辑和代码风格。 |

有关谁有资格作为审批人或代码所有者批准合并请求的信息，请参阅[按成员类型划分的审批人](../merge_requests/approvals/rules.md#approver-by-membership-type)。

<a id="code-owners-and-protected-branches"></a>

## 代码所有者和受保护分支

为确保合并请求变更由 [`CODEOWNERS` 文件](#codeowners-file)中指定的代码所有者评审和批准，合并请求的目标分支必须[受保护](../repository/branches/protected.md)并且必须启用[代码所有者审批](../repository/branches/protected.md#require-code-owner-approval)。

在受保护分支上启用代码所有者审批后，可以使用以下功能：

- [要求代码所有者批准](../repository/branches/protected.md#require-code-owner-approval)。
- [要求代码所有者进行多次批准](advanced.md#require-multiple-approvals-from-code-owners)。
- [代码所有者的可选批准](reference.md#optional-sections)。

<a id="practical-example"></a>

### 实际示例

您的项目在 `config/`目录中包含敏感且重要的信息。您可以：

1. 分配该目录的所有权。为此，请设置一个 `CODEOWNERS` 文件。
1. 为您的默认分支创建受保护分支。例如，`main`。
1. 在受保护分支上启用 **需要代码所有者审批**。
1. 可选。编辑 `CODEOWNERS` 文件，为多次批准添加规则。

使用此配置，更改 `config/`目录中的文件并以 `main` 分支为目标的合并请求在合并前需要指定代码所有者的批准。

<a id="allowed-to-push-and-merge-to-a-protected-branch"></a>

### 允许推送到受保护分支并合并

具有 **允许推送并合并** 权限的用户可以选择为其变更创建合并请求，或直接将变更推送到分支。如果用户跳过合并请求流程，则受保护分支功能以及合并请求内置的代码所有者审批也会被跳过。

此权限通常授予与自动化（[内部用户](../../../administration/internal_users.md)）和发布工具关联的账号。

来自没有 **允许推送** 权限的用户的所有变更都必须通过合并请求进行。

<a id="view-code-owners-of-a-file-or-directory"></a>

## 查看文件或目录的代码所有者

要查看文件或目录的代码所有者：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**代码** > **代码仓库**。
1. 转到您想查看其代码所有者的文件或目录。
1. 可选。选择分支或标签。

极狐GitLab 会在页面顶部显示代码所有者。

<a id="set-up-code-owners"></a>

## 设置代码所有者

先决条件：

- 您必须具有推送到默认分支或创建合并请求的权限。

1. 在您的[首选位置](#codeowners-file)创建 `CODEOWNERS` 文件。
1. 按照 [`CODEOWNERS` 语法](reference.md)在文件中定义一些规则。
   一些建议：
   - 配置 [**所有符合条件的用户**](../merge_requests/approvals/rules.md#code-owners-as-approvers) 审批规则。
   - 在受保护分支上[要求代码所有者批准](../repository/branches/protected.md#require-code-owner-approval)。
1. 提交您的变更，并将它们推送到极狐GitLab。

<a id="codeowners-file"></a>

## `CODEOWNERS` 文件

`CODEOWNERS` 文件定义了谁负责极狐GitLab 项目中的代码。其目的是：

- 为特定文件和目录定义代码所有者。
- 对受保护分支强制执行审批要求。
- 传达项目中的代码所有权。

此文件确定谁应评审和批准变更，并确保合适的专家参与代码变更。

每个代码仓库使用单个 `CODEOWNERS` 文件。极狐GitLab 按以下顺序检查代码仓库中的这些位置。找到的第一个 `CODEOWNERS` 文件会被使用，其他所有文件都会被忽略：

1. 在根目录中：`./CODEOWNERS`。
1. 在 `docs` 目录中：`./docs/CODEOWNERS`。
1. 在`.gitlab` 目录中：`./.gitlab/CODEOWNERS`。

有关更多信息，请参阅 [`CODEOWNERS` 语法](reference.md)和[高级 `CODEOWNERS` 配置](advanced.md)。
