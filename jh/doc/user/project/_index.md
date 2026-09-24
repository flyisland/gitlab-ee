---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 创建项目
description: New project and project templates.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您有多种创建项目的方式。您可以创建空白项目、从内置或自定义模板创建项目，或者 [通过 `git push` 创建项目](../../topics/git/project.md)。

<a id="create-a-blank-project"></a>

## 创建空白项目

要创建空白项目：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新项目/代码仓**。
1. 选择 **创建空白项目**。
1. 输入项目详细信息：
   1. **项目名称**：输入您的项目名称。
      有关更多信息，请参阅 [命名规则](../reserved_names.md#rules-for-usernames-project-and-group-names-and-slugs)。
   1. **项目路径**：输入项目的路径。极狐GitLab 将路径用作 URL 路径。
   1. **项目部署目标（可选）**：如果您希望将项目部署到特定环境，请选择相应的部署目标。
   1. **可见性级别**：选择适当的可见性级别。
      请参阅用户的 [查看和访问权限](../public_access.md)。
   1. **使用 README 初始化仓库**：选择此选项以初始化 Git 仓库，创建默认分支，并允许克隆此项目的仓库。
   1. **启用静态应用程序安全测试 (SAST)**：选择此选项以分析源代码中的已知安全漏洞。
   1. **启用密钥检测**：选择此选项以分析源代码中的密钥和凭据，防止未经授权的访问。
1. 选择 **创建项目**。

<a id="create-a-project-from-a-built-in-template"></a>

## 从内置模板创建项目

内置模板会用文件填充新项目，帮助您开始使用。
这些模板来源于 [`project-templates`](https://gitlab.com/gitlab-org/project-templates) 和 [`pages`](https://gitlab.com/pages) 群组。
任何人都可以参与贡献内置项目模板。

要从内置模板创建项目：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新项目/代码仓**。
1. 选择 **从模板创建**。
1. 选择 **内置** 选项卡。
1. 从模板列表中：
   - 要预览模板，请选择 **预览**。
   - 要使用模板，请选择 **使用模板**。
1. 输入项目详细信息：
   - **项目名称**：输入您的项目名称。
   - **项目路径**：输入项目的路径。极狐GitLab 将路径用作 URL 路径。
   - **项目描述（可选）**：输入项目的描述。字符限制为 500。
   - **可见性级别**：选择适当的可见性级别。
     请参阅用户的 [查看和访问权限](../public_access.md)。
1. 选择 **创建项目**。

> [!note]
> 如果用户从模板创建项目，或 [导入项目](settings/import_export.md#import-a-project-and-its-data)，他们会被显示为导入项的创建者，并且这些项保留模板或导入时的原始时间戳。这可能导致这些项看起来是在用户的账号存在之前创建的。

导入的对象会标记为 `By <username> on <timestamp>`。
在 极狐GitLab 17.1 之前，此标记会附加 `(imported from GitLab)`。

<a id="create-a-project-from-the-hipaa-audit-protocol-template"></a>

### 从 HIPAA 审计协议模板创建项目

HIPAA 审计协议模板包含美国卫生与公众服务部发布的 HIPAA 审计协议中的审计问询议题。

要从 HIPAA 审计协议模板创建项目：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新项目/代码仓**。
1. 选择 **从模板创建**。
1. 选择 **内置** 选项卡。
1. 找到 **HIPAA 审计协议** 模板：
   - 要预览模板，请选择 **预览**。
   - 要使用模板，请选择 **使用模板**。
1. 输入项目详细信息：
   - **项目名称**：输入您的项目名称。
   - **项目路径**：输入项目的路径。极狐GitLab 将路径用作 URL 路径。
   - **项目描述（可选）**：输入项目的描述。字符限制为 500。
   - **可见性级别**：选择适当的可见性级别。
     请参阅用户的 [查看和访问权限](../public_access.md)。
1. 选择 **创建项目**。

<a id="create-a-project-from-a-custom-template"></a>

## 从自定义模板创建项目

{{< history >}}

- 用于在群组上下文外浏览群组模板的群组选择器已在 极狐GitLab 18.11 中引入，带有 [功能标志](../../administration/feature_flags/_index.md) `constrain_group_project_templates`，默认禁用。

{{< /history >}}

自定义项目模板可用于您的 [实例](../../administration/custom_project_templates.md) 和 [群组](../group/custom_project_templates.md)。

要从自定义模板创建项目：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新项目/代码仓**。
1. 选择 **从模板创建**。
1. 选择 **实例** 或 **群组** 选项卡。
   - 在 **群组** 选项卡上，如果您不在群组上下文中，并且没有预选群组，则会显示群组下拉列表。选择一个群组以加载其模板。
1. 从模板列表中：
   - 要预览模板，请选择 **预览**。
   - 要使用模板，请选择 **使用模板**。
1. 输入项目详细信息：
   - **项目名称**：输入您的项目名称。
   - **项目路径**：输入项目的路径。极狐GitLab 将路径用作 URL 路径。
   - **项目描述（可选）**：输入项目的描述。字符限制为 500。
   - **可见性级别**：选择适当的可见性级别。
     请参阅用户的 [查看和访问权限](../public_access.md)。
1. 选择 **创建项目**。

<a id="create-a-project-that-uses-sha-256-hashing"></a>

## 创建使用 SHA-256 哈希的项目

{{< details >}}

- 状态：实验

{{< /details >}}

{{< history >}}

- 在 极狐GitLab 16.7 中引入，带有 [功能标志](../../administration/feature_flags/_index.md) `support_sha256_repositories`，默认禁用。该功能为 [实验性功能](../../policy/development_stages_support.md#experiment)。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参阅历史记录。
> 此功能可用于测试，但不宜用于生产环境。

您只能在创建项目时选择 SHA-256 哈希。Git 不支持后续迁移到 SHA-256，也不支持迁移回 SHA-1。

要创建使用 SHA-256 哈希的项目：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新项目/代码仓**。
1. 输入项目详细信息：
   - **项目名称**：输入您的项目名称。
   - **项目路径**：输入项目的路径。极狐GitLab 将路径用作 URL 路径。
   - **项目描述（可选）**：输入项目的描述。字符限制为 500。
   - **可见性级别**：选择适当的可见性级别。
     请参阅用户的 [查看和访问权限](../public_access.md)。
1. 在 **项目配置** 区域，展开 **实验性设置**。
1. 选择 **使用 SHA-256 作为仓库哈希算法**。
1. 选择 **创建项目**。

<a id="why-sha-256"></a>

### 为什么使用 SHA-256？

默认情况下，Git 使用 SHA-1 哈希算法为对象（如提交、blob、树和标签）生成 40 个字符的 ID。SHA-1 算法在 Google 能够产生哈希碰撞时被证明是不安全的。由于 Git 存储对象的方式，Git 项目尚未受到此类攻击的影响。

在 SHA-256 仓库中，该算法生成 64 个字符的 ID，而不是 40 个字符。Git 项目在移除实验性标签后确定 SHA-256 功能可以安全使用。

联邦法规（如 NIST 和 CISA 的[指南](https://csrc.nist.gov/projects/hash-functions/nist-policy-on-hash-functions)，由 [FedRamp](https://www.fedramp.gov/) 强制执行）规定在 2030 年停止使用 SHA-1，并鼓励各机构尽可能提前弃用 SHA-1。