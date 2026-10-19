---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 创建项目
description: 新建项目和项目模板。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以通过多种方式创建项目。您可以创建空白项目、基于内置模板或自定义模板创建项目，或者[使用 `git push` 创建项目](../../topics/git/project.md)。

<a id="create-a-blank-project"></a>

## 创建空白项目

创建空白项目：

1. 在右上角，选择**新建**（{{< icon name="plus" >}}）和**新建项目/代码仓库**。
1. 选择**创建空白项目**。
1. 输入项目详细信息：
   1. **项目名称**：输入您的项目名称。
      更多信息，请参见[命名规则](../reserved_names.md#rules-for-usernames-project-and-group-names-and-slugs)。
   1. **项目路径**：输入项目的路径。极狐GitLab 使用该路径作为 URL 路径。
   1. **项目部署目标（可选）**：如果您想将项目部署到特定环境，
      请选择相关的部署目标。
   1. **可见性级别**：选择合适的可见性级别。
      请参见用户的[查看和访问权限](../public_access.md)。
   1. **使用 README 初始化代码仓库**：选择此选项可初始化 Git 代码仓库、
      创建默认分支，并允许克隆此项目的代码仓库。
   1. **启用静态应用程序安全测试（SAST）**：选择此选项可分析
      源代码中已知的安全漏洞。
   1. **启用密钥检测**：选择此选项可分析
      源代码中的密钥和凭据，以防止未经授权的访问。
1. 选择**创建项目**。

<a id="create-a-project-from-a-built-in-template"></a>

## 基于内置模板创建项目

内置模板会使用文件填充新项目，帮助您快速上手。这些模板来自 [`project-templates`](https://gitlab.com/gitlab-org/project-templates) 和 [`pages`](https://gitlab.com/pages) 群组。任何人都可以为内置项目模板贡献内容。

管理员和群组所有者可以在创建项目时[控制内置模板的可用性](../group/manage.md#control-built-in-project-templates)。

基于内置模板创建项目：

1. 在右上角，选择**新建**（{{< icon name="plus" >}}）和**新建项目/代码仓库**。
1. 选择**从模板创建**。
1. 选择**内置**标签页。
1. 从模板列表中：
   - 要预览模板，请选择**预览**。
   - 要使用模板，请选择**使用模板**。
1. 输入项目详细信息：
   - **项目名称**：输入您的项目名称。
   - **项目路径**：输入项目的路径。极狐GitLab 使用该路径作为 URL 路径。
   - **项目描述（可选）**：输入项目的描述。
     字符数限制为 500。
   - **可见性级别**：选择合适的可见性级别。
     请参见用户的[查看和访问权限](../public_access.md)。
1. 选择**创建项目**。

> [!note]
> 如果用户基于模板创建项目，或[导入项目](settings/import_export.md#import-a-project-and-its-data)，
> 则其会显示为导入条目的作者，这些条目会保留模板或导入时的原始时间戳。
> 这可能会使条目看起来像是在用户账号存在之前创建的。

导入的对象会标记为 `By <username> on <timestamp>`。在极狐GitLab 17.1 之前，该标记的后缀为 `(imported from GitLab)`。

<a id="create-a-project-from-the-hipaa-audit-protocol-template"></a>

### 基于 HIPAA 审计协议模板创建项目

HIPAA 审计协议模板包含用于审计问询的议题，这些问询来自美国卫生与公众服务部发布的 HIPAA 审计协议。

基于 HIPAA 审计协议模板创建项目：

1. 在右上角，选择**新建**（{{< icon name="plus" >}}）和**新建项目/代码仓库**。
1. 选择**从模板创建**。
1. 选择**内置**标签页。
1. 找到 **HIPAA 审计协议** 模板：
   - 要预览模板，请选择**预览**。
   - 要使用模板，请选择**使用模板**。
1. 输入项目详细信息：
   - **项目名称**：输入您的项目名称。
   - **项目路径**：输入项目的路径。极狐GitLab 使用该路径作为 URL 路径。
   - **项目描述（可选）**：输入项目的描述。
     字符数限制为 500。
   - **可见性级别**：选择合适的可见性级别。
     请参见用户的[查看和访问权限](../public_access.md)。
1. 选择**创建项目**。

<a id="create-a-project-from-a-custom-template"></a>

## 基于自定义模板创建项目

自定义项目模板可用于您的[实例](../../administration/project_templates.md)和[群组](../group/custom_project_templates.md)。

基于自定义模板创建项目：

1. 在右上角，选择**新建**（{{< icon name="plus" >}}）和**新建项目/代码仓库**。
1. 选择**从模板创建**。
1. 选择**实例**或**群组**标签页。
   - 在**群组**标签页上，如果您不在群组上下文中且未预选任何群组，
     则会显示群组下拉列表。选择一个群组以加载其模板。
1. 从模板列表中：
   - 要预览模板，请选择**预览**。
   - 要使用模板，请选择**使用模板**。
1. 输入项目详细信息：
   - **项目名称**：输入您的项目名称。
   - **项目路径**：输入项目的路径。极狐GitLab 使用该路径作为 URL 路径。
   - **项目描述（可选）**：输入项目的描述。字符数限制为 500。
   - **可见性级别**：选择合适的可见性级别。
     请参见用户的[查看和访问权限](../public_access.md)。
1. 选择**创建项目**。

<a id="create-a-project-that-uses-sha-256-hashing"></a>

## 创建使用 SHA-256 哈希的项目

{{< details >}}

- Status: 实验

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

您只能在创建项目时为项目选择 SHA-256 哈希。Git 不支持之后迁移到 SHA-256，也不支持迁移回 SHA-1。

创建使用 SHA-256 哈希的项目：

1. 在右上角，选择**新建**（{{< icon name="plus" >}}）和**新建项目/代码仓库**。
1. 输入项目详细信息：
   - **项目名称**：输入您的项目名称。
   - **项目路径**：输入项目的路径。极狐GitLab 使用该路径作为 URL 路径。
   - **项目描述（可选）**：输入项目的描述。字符数限制为 500。
   - **可见性级别**：选择合适的可见性级别。
     请参见用户的[查看和访问权限](../public_access.md)。
1. 在**项目配置**区域中，展开**实验性设置**。
1. 选择**使用 SHA-256 作为代码仓库哈希算法**。
1. 选择**创建项目**。

<a id="why-sha-256"></a>

### 为什么使用 SHA-256？

默认情况下，Git 使用 SHA-1 哈希算法为提交、blob、树和标签等对象生成 40 个字符的
ID。当
[Google 能够产生哈希碰撞](https://security.googleblog.com/2017/02/announcing-first-sha1-collision.html)时，SHA-1 算法被证明不安全。由于 Git 存储对象的方式，Git 项目尚未受到此类攻击的影响。

在 SHA-256 代码仓库中，该算法会生成 64 个字符的 ID，而不是 40 个字符的 ID。Git 项目在[移除实验性标签](https://github.com/git/git/blob/master/Documentation/RelNotes/2.42.0.txt#L41-L45)时确定 SHA-256 功能可以安全使用。

联邦法规，例如由 [FedRamp](https://www.fedramp.gov/) 强制执行的 NIST 和 CISA 的[指南](https://csrc.nist.gov/projects/hash-functions/nist-policy-on-hash-functions)，已设定 2030 年为停止使用 SHA-1 的截止日期，并鼓励各机构尽可能提前弃用 SHA-1。
