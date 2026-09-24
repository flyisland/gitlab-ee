---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 审计员用户
description: Provide read-only access for auditing and compliance monitoring across all resources.
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

审计员用户对实例中的所有群组、项目和其他资源拥有只读访问权限。

审计员用户：

- 对所有群组和项目拥有只读访问权限。
  - 由于一个已知问题，用户必须拥有报告者、开发者、维护者或所有者角色才能执行只读任务。
- 可以根据分配的角色获得额外的[权限](../user/permissions.md)。
- 可以在其个人命名空间中创建群组、项目或代码片段。
- 无法查看管理员区域或执行任何管理操作。
- 无法访问群组或项目设置。
- 启用[调试日志](../ci/variables/variables_troubleshooting.md#enable-debug-logging)时，无法查看作业日志。
- 无法访问用于编辑的区域，包括[流水线编辑器](../ci/pipeline_editor/_index.md)。

审计员用户有时用于以下场景：

- 组织需要在整个极狐GitLab 实例中测试安全策略合规性。
  审计员用户无需被添加到每个项目或获得管理员访问权限即可完成此项工作。
- 特定用户需要查看极狐GitLab 实例中的大量项目。无需手动将用户添加到每个项目中，您可以创建一个自动访问每个项目的审计员用户。

> [!note]
> 审计员用户计为一个可计费用户，并占用一个许可证席位。

## 创建审计员用户

前提条件：

- 管理员访问权限。

要创建新的审计员用户：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **概览** > **用户**。
1. 选择 **新建用户**。
1. 在 **账户** 部分，输入所需的账户信息。
1. 在 **用户类型** 中，选择 **审计员**。
1. 选择 **创建用户**。

您还可以通过以下方式创建审计员用户：

- [SAML 群组](../integration/saml.md#auditor-groups)。
- [用户 API](../api/users.md)。

