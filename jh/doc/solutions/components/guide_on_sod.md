---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
description: 使用基于角色的访问控制实现极狐GitLab 职责分离解决方案的概述，包括关键组件、工作流程和审计功能。
title: 极狐GitLab 职责分离教程指南
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本文档概述了通过基于角色的访问控制（RBAC）实现的极狐GitLab 职责分离（SoD）解决方案。该解决方案通过防止任何个人完全控制软件开发生命周期中的关键流程，确保符合安全原则。

<a id="getting-started"></a>

## 入门

<a id="access-the-solution-component"></a>

### 访问解决方案组件

1. 从您的客户团队获取邀请码。
1. 使用您的邀请码从 [解决方案组件商店](https://cloud.gitlab-accelerator-marketplace.com) 访问解决方案组件。

<a id="what-is-separation-of-duties"></a>

## 什么是职责分离

职责分离是基本的安全原则，确保没有个人完全控制关键流程。在软件开发中，职责分离通过在不同角色和团队之间分配责任，防止未经授权或意外的代码发布到生产环境。

极狐GitLab 通过基于角色的访问控制（RBAC）实现职责分离的方法提供：

- 开发与部署角色之间的清晰分离
- 受保护环境以控制部署访问
- 受保护分支以防止未经授权的代码修改
- 合并请求审批策略以强制执行代码审查
- 内置审计功能以进行合规性验证

<a id="key-components-of-gitlab-sod-solution"></a>

## 极狐GitLab 职责分离解决方案的关键组件

<a id="role-based-access-control-rbac"></a>

### 基于角色的访问控制（RBAC）

RBAC 构成实施和执行职责分离的框架。它管理平台上的权限和责任，确保最小权限原则得到遵守。通过 RBAC，组织可以：

- 实施具有细粒度基于角色控制的整体用户管理
- 根据最小特权访问原则分配角色
- 通过审计/报告维护对角色和权限的可见性

<a id="feature-branch-workflow"></a>

### 功能分支工作流程

功能分支工作流程通过在开发活动与生产部署之间定义清晰的边界来支持职责分离：

- 开发团队可以在功能分支中修改代码并触发测试流水线
- 安全团队管理质量门禁的审批策略
- 合并请求需要来自非作者的独立审查

<a id="protected-branches-environments"></a>

### 受保护分支和受保护环境

默认分支在执行职责分离中起关键作用：

- 受保护环境将部署限制到指定团队
- 部署团队有权执行部署，但被限制修改源代码
- 受保护分支阻止未经授权的合并和推送

<a id="audit-compliance-capabilities"></a>

### 审计与合规能力

极狐GitLab 提供强大的审计能力以支持合规要求：

- 自动生成的发布证据
- 默认分支活动的事件记录

<a id="prerequisites"></a>

### 前提条件

要完全实施极狐GitLab 职责分离解决方案，组织需要：

- 极狐GitLab 旗舰版许可证
- 正确配置的 CI/CD 流水线
- 在开发与部署角色之间具有清晰分离的用户群组

<a id="additional-resources"></a>

### 额外资源

有关极狐GitLab 职责分离实施的更多信息，请参阅：

- [极狐GitLab 角色与权限文档](../../user/permissions.md)
- [受保护分支文档](../../user/project/repository/branches/protected.md)
- [受保护环境文档](../../ci/environments/protected_environments.md)
- [合并请求审批文档](../../user/project/merge_requests/approvals/_index.md)