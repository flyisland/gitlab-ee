---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 角色与权限
description: 了解极狐GitLab 中每个用户角色可用的权限和能力。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

角色定义了用户在群组或项目中的权限。

拥有[管理员访问权限](../administration/_index.md)的用户拥有所有权限，可以执行任何操作。

<a id="roles"></a>

## 角色

当您将用户添加到群组或项目时，需要为其分配一个角色。
该角色决定了他们的权限。可以分配[默认角色](#default-roles)
或[自定义角色](custom_roles/_index.md)。

一个用户可以在每个群组和项目中拥有不同的角色。用户始终保留其
最高角色对应的权限。例如，如果用户拥有：

- 父群组的维护者角色
- 该群组中某个项目的开发者角色

该用户会在项目中继承其维护者角色的权限。

要查看已分配的角色，请前往
[群组](group/_index.md#view-group-members)或
[项目](project/members/_index.md#view-project-members)的 **成员** 页面。

<a id="default-roles"></a>

### 默认角色

角色按权限从少到多排序。
访客、报告者、开发者、维护者和所有者角色是累积的，因此每个角色
都包含其之前角色的大部分权限。计划者和安全管理员角色
专门用于规划和安全工作，因此它们不包含其他角色的所有权限。要
确认某个角色是否具有特定权限，请查看相关表格。

以下默认角色可用：

| 角色 | 描述 |
| ---------------- | ----------- |
| 最小访问权限 | 查看有限的群组信息，但无法访问项目。更多信息，请参见[具有最小访问权限的用户](#users-with-minimal-access)。 |
| 访客 | 查看和评论议题及史诗。无法推送代码或访问代码仓库。此角色仅适用于[私有和内部项目](public_access.md)。 |
| 计划者 | 创建和管理议题、史诗、里程碑及迭代。专注于项目规划与跟踪，并能够查看和协作处理代码变更。 |
| 报告者 | 查看代码、创建议题并生成报告。无法推送代码或管理受保护分支。 |
| 安全管理员 | 查看和管理安全漏洞、合规配置及审计事件。专注于安全运营，无代码推送权限。 |
| 开发者 | 将代码推送到非受保护分支、创建合并请求并运行 CI/CD 流水线。无法管理项目设置。 |
| 维护者 | 管理分支、合并请求、CI/CD 设置和项目成员。无法删除项目。 |
| 所有者 | 对项目或群组拥有完全控制权，包括删除和可见性设置。 |

默认情况下，所有用户都可以创建顶级群组并更改其用户名。
拥有[管理员访问权限](../administration/user_settings.md)的用户可以更改此行为。

<!--
Sort these permissions according the following rules in order:
1. By minimum role.
2. By the object being accessed (for example, issue, security dashboard, or pipeline)
3. By the action: view, create, change, edit, manage, run, delete, all others
4. Alphabetically.

List only one action (for example, view, create, or delete) per line.
It's okay to list multiple related objects per line (for example, "View pipelines and pipeline details").
-->

<a id="group-permissions"></a>

## 群组权限

任何用户都可以将自己从群组中移除，除非他们是该群组唯一的所有者。

下表列出了每个角色可用的群组权限。

> [!note]
> 最小访问权限角色未包含在内，因为它没有任何权限。

<a id="groups"></a>

### 群组

[群组功能](group/_index.md)的群组权限：

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ------------------------------------------------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 浏览群组 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| [搜索](search/_index.md)群组中的项目 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| [搜索](search/_index.md)群组中的子群组 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看群组[审计事件](compliance/audit_events.md) <sup>1</sup> | | | | ✓ | ✓ | ✓ | ✓ |
| 在群组中创建项目 <sup>2</sup> | | | | | ✓ | ✓ | ✓ |
| 创建子群组 <sup>3</sup> | | | | | | ✓ | ✓ |
| 更改[项目集成](project/integrations/_index.md)的自定义设置 | | | | | | | ✓ |
| 编辑[史诗](group/epics/_index.md)评论（由任何用户发布） | | | | | | ✓ | ✓ |
| 将项目复刻到群组中 | | | | | | ✓ | ✓ |
| 查看[计费](../subscriptions/manage_subscription.md#view-subscription) <sup>4</sup> | | | | | | | ✓ |
| 查看群组[用量配额](storage_usage_quotas.md)页面 <sup>4</sup> | | | | | | | ✓ |
| [迁移群组](group/import/_index.md) | | | | | | | ✓ |
| 归档群组 | | | | | | | ✓ |
| 删除群组 | | | | | | | ✓ |
| 转移群组 | | | | | | | ✓ |
| 管理[订阅、存储和计算分钟数](../subscriptions/manage_seats.md#gitlabcom-billing-and-usage) | | | | | | | ✓ |
| 管理[群组访问令牌](group/settings/group_access_tokens.md) | | | | | | | ✓ |
| 更改群组可见性级别 | | | | | | | ✓ |
| 编辑群组设置 | | | | | | | ✓ |
| 配置项目模板 | | | | | | | ✓ |
| 配置 [SAML SSO](group/saml_sso/_index.md) <sup>4</sup> | | | | | | | ✓ |
| 禁用通知邮件 | | | | | | | ✓ |
| 导入[项目](project/settings/import_export.md) | | | | | | ✓ | ✓ |

**脚注**：

1. 开发者和维护者只能查看基于其个人操作的事件。更多信息，请参见[先决条件](compliance/audit_events.md#prerequisites)。
1. 开发者、维护者和所有者：仅当项目创建角色已[为实例](../administration/settings/visibility_and_access_controls.md#define-which-roles-can-create-projects)或[为群组](group/_index.md#specify-who-can-add-projects-to-a-group)设置时。<br>开发者：仅当[默认分支保护](group/manage.md#change-the-default-branch-protection-of-a-group)设置为“部分保护”或“未保护”时，开发者才能将提交推送到新项目的默认分支。
1. 维护者：仅当具有维护者角色的用户[可以创建子群组](group/subgroups/_index.md#change-who-can-create-subgroups)时。
1. 不适用于子群组。

<a id="group-analytics"></a>

### 群组分析

[分析](analytics/_index.md)功能的群组权限，包括价值流、产品分析和洞察：

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ------------------------------------------------------------------ | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看 [极狐GitLab Duo 和 SDLC 趋势](analytics/duo_and_sdlc_trends.md) | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[洞察](project/insights/_index.md) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[洞察](project/insights/_index.md)图表 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[议题分析](group/issues_analytics/_index.md) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看贡献分析 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看价值流分析 | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[生产力分析](analytics/productivity_analytics.md) | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[群组 DevOps 采用情况](group/devops_adoption/_index.md) | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看指标仪表板注解 | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| 管理指标仪表板注解 | | | | | ✓ | ✓ | ✓ |

<a id="group-application-security"></a>

### 群组应用安全

[应用安全](application_security/secure_your_application.md)功能的群组权限，包括依赖管理、安全分析器、安全策略和漏洞管理。

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| -------------------------------------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看[依赖列表](application_security/dependency_list/_index.md) | | | | ✓ | ✓ | ✓ | ✓ |
| 查看[漏洞报告](application_security/vulnerability_report/_index.md) | | | | ✓ | ✓ | ✓ | ✓ |
| 查看[安全仪表板](application_security/security_dashboard/_index.md) | | | | ✓ | ✓ | ✓ | ✓ |
| 创建[安全策略项目](application_security/policies/_index.md) | | | | ✓ | | | ✓ |
| 分配[安全策略项目](application_security/policies/_index.md) | | | | ✓ | | | ✓ |

<a id="group-secrets-manager"></a>

### 群组密钥管理器

[极狐GitLab 密钥管理器](../ci/secrets/secrets_manager/_index.md)的群组权限：

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
|-------------------------------------------------|:-----:|:-------:|:--------:|:----------------:|:---------:|:----------:|:-----:|
| 启用极狐GitLab 密钥管理器 <sup>1</sup> | | | | | | | ✓ |
| 管理密钥权限 | | | | | | | ✓ |
| 读取密钥元数据 | | | | | | | ✓ |
| 创建、更新和删除密钥 <sup>2</sup> | | | | | | | ✓ |
| 读取密钥值 <sup>3</sup> | | | | | | | |

**脚注**：

1. 在 JihuLab.com 上，只有顶级群组所有者才能为子群组和项目启用密钥管理器。在私有化部署实例上，必须由管理员为实例启用。
1. 所有者可以将此操作授予其他角色、特定用户、群组或自定义角色。请参见[管理密钥权限](../ci/secrets/secrets_manager/_index.md#manage-secrets-permissions)。
1. 任何角色都无法读取密钥的值。CI/CD 作业通过作业身份验证读取值。其他工作负载通过[密钥管理器 API](../ci/secrets/secrets_manager/non_cicd_access.md)读取值，并且仅当它们已被授予该密钥的读取值权限时。

<a id="group-cicd"></a>

### 群组 CI/CD

[CI/CD](../ci/_index.md)功能的群组权限，包括 Runner、变量和受保护环境：

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看实例 Runner | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看群组 Runner | | | | | | ✓ | ✓ |
| 管理群组级 Kubernetes 集群 | | | | | | ✓ | ✓ |
| 管理群组 Runner | | | | | | | ✓ |
| 管理群组级 CI/CD 变量 | | | | | | | ✓ |
| 管理群组受保护环境 | | | | | | | ✓ |

<a id="group-compliance"></a>

### 群组合规

[合规](compliance/_index.md)功能的群组权限，包括合规中心、审计事件、合规框架和许可证。

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| -------------------------------------------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看[审计事件](compliance/audit_events.md) <sup>1</sup> | | | | ✓ | ✓ | ✓ | ✓ |
| 在[依赖列表](application_security/dependency_list/_index.md)中查看许可证 | | | | ✓ | ✓ | ✓ | ✓ |
| 查看[合规中心](compliance/compliance_center/_index.md) | | | | ✓ | | | ✓ |
| 管理[合规框架](compliance/compliance_frameworks/_index.md) | | | | ✓ | | | ✓ |
| 将[合规框架](compliance/compliance_frameworks/_index.md)分配给项目 | | | | ✓ | | | ✓ |
| 管理[审计流](compliance/audit_event_streaming.md) | | | | ✓ | | | ✓ |

**脚注**：

1. 用户只能查看基于其个人操作的事件。更多详情，请参见[先决条件](compliance/audit_events.md#prerequisites)。

<a id="group-gitlab-duo"></a>

### 群组极狐GitLab Duo

[极狐GitLab Duo](gitlab_duo/_index.md)的群组权限：

| 操作 | 非成员 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ---------------------------------------------------------------------------------------------------------- | :--------: | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 使用极狐GitLab Duo 功能 <sup>1</sup> | | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 配置[极狐GitLab Duo 功能可用性](gitlab_duo/turn_on_off.md#for-a-group-or-subgroup) | | | | | | | ✓ | ✓ |
| 配置[极狐GitLab Duo 自部署版本](../administration/gitlab_duo_self_hosted/configure_duo_features.md) | | | | | | | | ✓ |
| 启用[测试版和实验性功能](gitlab_duo/turn_on_off.md#turn-on-beta-and-experimental-features) | | | | | | | | ✓ |
| 购买[极狐GitLab Duo 席位](../subscriptions/subscription-add-ons.md#purchase-additional-gitlab-duo-seats) | | | | | | | | ✓ |

**脚注**：

1. 如果用户拥有极狐GitLab Duo Pro 或 Enterprise，则[必须为用户分配席位才能访问该极狐GitLab Duo 附加组件](../subscriptions/subscription-add-ons.md#assign-gitlab-duo-seats)。如果用户拥有极狐GitLab Duo Core，则没有其他要求。

<a id="group-packages-and-registries"></a>

### 群组软件包和镜像仓库

[软件包和容器镜像仓库](packages/_index.md)的群组权限：

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ----------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 拉取容器镜像仓库镜像 <sup>1</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 使用依赖代理拉取容器镜像 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 删除容器镜像仓库镜像 | | | | | ✓ | ✓ | ✓ |
| 配置虚拟仓库 | | | | | | ✓ | ✓ |
| 从虚拟仓库拉取产物 | ✓ | | ✓ | ✓ | ✓ | ✓ | ✓ |

**脚注**：

1. 访客只能查看基于其个人操作的事件。

[软件包仓库](packages/_index.md)的群组权限：

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ---------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 拉取软件包 | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| 发布软件包 | | | | | ✓ | ✓ | ✓ |
| 删除软件包 | | | | | | ✓ | ✓ |
| 管理软件包设置 | | | | | | | ✓ |
| 管理依赖代理清理策略 | | | | | | | ✓ |
| 启用依赖代理 | | | | | | | ✓ |
| 禁用依赖代理 | | | | | | | ✓ |
| 清除群组依赖代理 | | | | | | | ✓ |
| 启用软件包请求转发 | | | | | | | ✓ |
| 禁用软件包请求转发 | | | | | | | ✓ |

<a id="group-planning"></a>

### 群组规划

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ----------------------------------------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看史诗 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| [搜索](search/_index.md)史诗 <sup>1</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 将议题添加到[史诗](group/epics/_index.md) <sup>2</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 添加[子史诗](work_items/child_items.md#work-with-multi-level-hierarchies) <sup>3</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 添加父史诗 <sup>4</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 添加内部评论 | | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 创建史诗 | | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 更新史诗详情 | | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 管理[史诗看板](group/epics/epic_boards.md) | | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 删除史诗 <sup>5</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

**脚注**：

1. 您必须拥有[查看史诗](group/epics/manage_epics.md#who-can-view-an-epic)的权限。
1. 您必须拥有[查看史诗](group/epics/manage_epics.md#who-can-view-an-epic)和编辑议题的权限。
1. 您必须拥有[查看](group/epics/manage_epics.md#who-can-view-an-epic)父史诗和子史诗的权限。
1. 您必须拥有[查看](group/epics/manage_epics.md#who-can-view-an-epic)父史诗的权限。
1. 没有计划者或所有者角色的用户只能删除他们自己创建的史诗。

[Wiki](project/wiki/group.md)的群组权限：

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| --------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看群组 Wiki <sup>1</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| [搜索](search/_index.md)群组 Wiki <sup>2</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 创建群组 Wiki 页面 | | ✓ | | | ✓ | ✓ | ✓ |
| 编辑群组 Wiki 页面 | | ✓ | | | ✓ | ✓ | ✓ |
| 删除群组 Wiki 页面 | | ✓ | | | ✓ | ✓ | ✓ |

**脚注**：

1. 访客：此外，如果您的群组是公开或内部的，所有能看到该群组的用户也可以看到群组 Wiki 页面。
1. 访客：此外，如果您的群组是公开或内部的，所有能看到该群组的用户也可以搜索群组 Wiki 页面。

<a id="group-repositories"></a>

### 群组代码仓库

[代码仓库](project/repository/_index.md)功能的群组权限，包括合并请求、推送规则和部署令牌。

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
|----------------------------------------------------------------------------------------|:-----:|:-------:|:--------:|:----------------:|:---------:|:----------:|:-----:|
| 管理[部署令牌](project/deploy_tokens/_index.md) | | | | | | | ✓ |
| 管理[合并请求设置](group/manage.md#group-merge-request-approval-settings) | | | | | | | ✓ |
| 管理[推送规则](project/repository/push_rules.md#group-push-rules) | | | | | | | ✓ |

<a id="group-user-management"></a>

### 群组用户管理

用户管理的群组权限：

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看成员的 2FA 状态 | | | | | | | ✓ |
| 按 2FA 状态筛选成员 | | | | | | | ✓ |
| 管理群组成员 | | | | | | | ✓ |
| 管理群组级自定义角色 | | | | | | | ✓ |
| 将群组共享（邀请）给群组 | | | | | | | ✓ |

<a id="group-workspaces"></a>

### 群组工作区

工作区的群组权限：

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| --------------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看映射到群组的工作区集群 Agent | | | | | | ✓ | ✓ |
| 将工作区集群 Agent 映射到群组或从群组取消映射 | | | | | | | ✓ |

<a id="project-permissions"></a>

## 项目权限

用户的角色决定了他们在项目上拥有哪些权限。所有者角色提供所有权限，但仅适用于：

- 群组和项目所有者。
- 管理员。

个人[命名空间](namespace/_index.md)所有者：

- 在命名空间中的项目上显示为拥有维护者角色，但拥有与所有者角色用户相同的权限。
- 对于命名空间中的新项目，显示为拥有所有者角色。

当您配置[受保护分支设置](project/repository/branches/protection_rules.md)时，
选择一个角色会授予该角色及所有更高级别角色的用户访问权限。例如，如果您在受保护分支设置中选择
**维护者**，则拥有维护者和所有者角色的用户
都可以执行该操作。

有关如何管理项目成员的更多信息，请参见
[项目成员](project/members/_index.md)。

下表列出了每个角色可用的项目权限。

> [!note]
> 最小访问权限角色未包含在内，因为它没有任何权限。

<a id="projects"></a>

### 项目

[项目功能](project/organize_work_with_projects.md)的项目权限：

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| -------------------------------------------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 下载项目 <sup>1</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 发表评论 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 重新定位图片上的评论（由任何用户发布） <sup>2</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[洞察](project/insights/_index.md) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[需求](project/requirements/_index.md) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[时间跟踪](project/time_tracking.md)报告 <sup>1</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[代码片段](snippets.md) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| [搜索](search/_index.md)[代码片段](snippets.md)和评论 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[项目流量统计](../api/project_statistics.md) | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| 创建[代码片段](snippets.md) | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[发布](project/releases/_index.md) <sup>3</sup> | | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 管理[发布](project/releases/_index.md) <sup>4</sup> | | | | | | ✓ | ✓ |
| 配置 [Webhook](project/integrations/webhooks.md) | | | | | | ✓ | ✓ |
| 管理[项目访问令牌](project/settings/project_access_tokens.md) <sup>5</sup> | | | | | | ✓ | ✓ |
| [导出项目](project/settings/import_export.md) | | | | | | ✓ | ✓ |
| 重命名项目 | | | | | | ✓ | ✓ |
| 编辑项目徽章 | | | | | | ✓ | ✓ |
| 编辑项目设置 | | | | | | ✓ | ✓ |
| 更改[项目功能可见性](public_access.md)级别 <sup>6</sup> | | | | | | ✓ | ✓ |
| 更改[项目集成](project/integrations/_index.md)的自定义设置 | | | | | | ✓ | ✓ |
| 编辑其他用户发布的评论 | | | | | | ✓ | ✓ |
| 添加[部署密钥](project/deploy_keys/_index.md) | | | | | | ✓ | ✓ |
| 管理[项目运维](../operations/_index.md) | | | | | | ✓ | ✓ |
| 查看[用量配额](storage_usage_quotas.md)页面 | | | | | | ✓ | ✓ |
| 全局删除[代码片段](snippets.md) | | | | | | ✓ | ✓ |
| 全局编辑[代码片段](snippets.md) | | | | | | ✓ | ✓ |
| 归档项目 | | | | | | | ✓ |
| 更改项目可见性级别 | | | | | | | ✓ |
| 删除项目 | | | | | | | ✓ |
| 禁用通知邮件 | | | | | | | ✓ |
| 转移项目 | | | | | | | ✓ |

**脚注**：

<!-- Disable ordered list rule <https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md#md029---ordered-list-item-prefix> -->
<!-- markdownlint-disable MD029 -->

1. 在极狐GitLab 私有化部署上，拥有访客角色的用户只能在公开和内部项目（而非私有项目）上执行此操作。[外部用户](../administration/external_users.md)必须被授予明确访问权限（至少为 **报告者** 角色），即使项目是内部的。由于内部可见性不可用，JihuLab.com 上拥有访客角色的用户只能在公开项目上执行此操作。
2. 仅适用于[设计管理](project/issues/design_management.md)设计上的评论。
3. 访客用户可以访问极狐GitLab [**发布**](project/releases/_index.md)以下载资产，但不允许下载源代码，也不允许查看[提交和发布证据等代码仓库信息](project/releases/_index.md#view-a-release-and-download-assets)。
4. 如果[标签受保护](project/protected_tags.md)，这取决于授予开发者和维护者的访问权限。
5. 对于极狐GitLab 私有化部署，项目访问令牌在所有版本中均可用。对于 JihuLab.com，项目访问令牌在专业版和旗舰版中受支持（不包括[试用许可证](https://about.gitlab.com/free-trial/)）。
6. 如果[项目可见性](public_access.md)设置为私有，维护者或所有者无法更改项目功能可见性级别。

   <!-- markdownlint-enable MD029 -->

[GitLab Pages](project/pages/_index.md)的项目权限：

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| -------------------------------------------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看受[访问控制](project/pages/pages_access_control.md)保护的 GitLab Pages | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 管理 GitLab Pages | | | | | | ✓ | ✓ |
| 管理 GitLab Pages 域名和证书 | | | | | | ✓ | ✓ |
| 移除 GitLab Pages | | | | | | ✓ | ✓ |

<a id="project-analytics"></a>

### 项目分析

[分析](analytics/_index.md)功能的项目权限，包括价值流、使用趋势、产品分析和洞察。

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ------------------------------------------------------------------------------------------ | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看[议题分析](group/issues_analytics/_index.md) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[价值流分析](group/value_stream_analytics/_index.md) | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看 [CI/CD 分析](analytics/ci_cd_analytics.md) | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[代码评审分析](analytics/code_review_analytics.md) | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看 [DORA 指标](analytics/ci_cd_analytics.md) | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[合并请求分析](analytics/merge_request_analytics.md) | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[代码仓库分析](analytics/repository_analytics.md) | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[价值流仪表板](analytics/value_streams_dashboard.md) | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看 [极狐GitLab Duo 和 SDLC 趋势](analytics/duo_and_sdlc_trends.md) | | | ✓ | ✓ | ✓ | ✓ | ✓ |

<a id="project-application-security"></a>

### 项目应用安全

[应用安全](application_security/secure_your_application.md)功能的项目权限，包括依赖管理、安全分析器、安全策略和漏洞管理。

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ----------------------------------------------------------------------------------------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看[依赖列表](application_security/dependency_list/_index.md) | | | | ✓ | ✓ | ✓ | ✓ |
| 在[依赖列表](application_security/dependency_list/_index.md)中查看许可证 | | | | ✓ | ✓ | ✓ | ✓ |
| 查看[安全仪表板](application_security/security_dashboard/_index.md) | | | | ✓ | ✓ | ✓ | ✓ |
| 查看[漏洞报告](application_security/vulnerability_report/_index.md) | | | | ✓ | ✓ | ✓ | ✓ |
| [手动创建漏洞](application_security/vulnerability_report/_index.md#manually-add-a-vulnerability) | | | | ✓ | | ✓ | ✓ |
| 从漏洞发现创建[议题](application_security/vulnerabilities/_index.md#create-a-gitlab-issue-for-a-vulnerability) | | | | ✓ | ✓ | ✓ | ✓ |
| 创建[按需 DAST 扫描](application_security/dast/on-demand_scan.md) | | | | ✓ | ✓ | ✓ | ✓ |
| 运行[按需 DAST 扫描](application_security/dast/on-demand_scan.md) | | | | ✓ | ✓ | ✓ | ✓ |
| 创建[独立安全策略](application_security/policies/_index.md) | | | | | ✓ | ✓ | ✓ |
| 更改[独立安全策略](application_security/policies/_index.md) | | | | | ✓ | ✓ | ✓ |
| 删除[独立安全策略](application_security/policies/_index.md) | | | | | ✓ | ✓ | ✓ |
| 创建 [CVE ID 请求](application_security/cve_id_request.md) | | | | | | ✓ | ✓ |
| 更改漏洞状态 <sup>1</sup> | | | | ✓ | | ✓ | ✓ |
| 创建[安全策略项目](application_security/policies/_index.md) | | | | | | | ✓ |
| 分配[安全策略项目](application_security/policies/_index.md) | | | | | | | ✓ |
| 配置 [SAST 漏洞解决](application_security/vulnerabilities/agentic_vulnerability_resolution.md) <sup>2</sup> | | | | ✓ | | ✓ | ✓ |
| 配置 [SAST 误报检测](application_security/vulnerabilities/false_positive_detection.md) <sup>2</sup> | | | | ✓ | | ✓ | ✓ |
| 配置[密钥检测误报检测](application_security/vulnerabilities/secret_false_positive_detection.md) <sup>2</sup> | | | | ✓ | | ✓ | ✓ |
| 管理其他[安全配置](application_security/detect/security_configuration.md) <sup>3</sup> | | | | ✓ | | ✓ | ✓ |

**脚注**：

1. `admin_vulnerability`权限已在极狐GitLab 17.0 中从开发者角色[移除](https://gitlab.com/gitlab-org/gitlab/-/issues/412693)。
1. 安全管理员可以在 **设置 > 通用 > 极狐GitLab Duo** 中配置这些设置。
1. 安全管理员只能通过 UI（**安全 > 安全配置**）管理其他安全配置。

<a id="project-secrets-manager"></a>

### 项目密钥管理器

[极狐GitLab 密钥管理器](../ci/secrets/secrets_manager/_index.md)的项目权限：

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
|-------------------------------------------------|:-----:|:-------:|:--------:|:----------------:|:---------:|:----------:|:-----:|
| 查看密钥管理器用户权限 | | | | | | ✓ | ✓ |
| 管理密钥权限 | | | | | | | ✓ |
| 读取密钥元数据 | | | | | | | ✓ |
| 创建、更新和删除密钥 <sup>1</sup> | | | | | | | ✓ |
| 读取密钥值 <sup>2</sup> | | | | | | | |

**脚注**：

1. 所有者可以将此操作授予其他角色、特定用户、群组或自定义角色。请参见[管理密钥权限](../ci/secrets/secrets_manager/_index.md#manage-secrets-permissions)。
1. 任何角色都无法读取密钥的值。CI/CD 作业通过作业身份验证读取值。其他工作负载通过[密钥管理器 API](../ci/secrets/secrets_manager/non_cicd_access.md)读取值，并且仅当它们已被授予该密钥的读取值权限时。

<a id="project-cicd"></a>

### 项目 CI/CD

某些角色的[极狐GitLab CI/CD](../ci/_index.md)权限可以通过以下设置修改：

- [基于项目的流水线可见性](../ci/pipelines/settings.md#change-which-users-can-view-your-pipelines)：
  当设置为公开时，会向项目访客成员授予某些 CI/CD 功能的访问权限。
- [流水线可见性](../ci/pipelines/settings.md#change-pipeline-visibility-for-non-project-members-in-public-projects)：
  当设置为 **所有有访问权限的人** 时，会向非项目成员授予某些 CI/CD“查看”功能的访问权限。

项目所有者可以执行任何列出的操作，并且可以删除流水线：

| 操作 | 非成员 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 |
| ----------------------------------------------------------------------------------------------------------- | :--------: | :---: | :-----: | :------: | :--------------: | :-------: | :--------: |
| 查看实例 Runner | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看现有产物 <sup>1</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看作业列表 <sup>2</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看产物 <sup>3</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 下载产物 <sup>3</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[环境](../ci/environments/_index.md) <sup>1</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看作业日志和作业详情页面 <sup>2</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看流水线和流水线详情页面 <sup>2</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 在合并请求中查看流水线选项卡 <sup>1</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[流水线中的漏洞](application_security/detect/security_scanning_results.md) <sup>4</sup> | | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 为受保护环境运行部署作业 <sup>5</sup> | | | | ✓ | | ✓ | ✓ |
| 查看 [Kubernetes Agent](clusters/agent/_index.md) | | | | | | ✓ | ✓ |
| 查看项目[安全文件](../api/secure_files.md) | | | | | | ✓ | ✓ |
| 下载项目[安全文件](../api/secure_files.md) | | | | | | ✓ | ✓ |
| 查看带有[调试日志](../ci/variables/variables_troubleshooting.md#enable-debug-logging)的作业 | | | | | | ✓ | ✓ |
| 创建[环境](../ci/environments/_index.md) | | | | | | ✓ | ✓ |
| 删除[环境](../ci/environments/_index.md) | | | | | | ✓ | ✓ |
| 停止[环境](../ci/environments/_index.md) | | | | | | ✓ | ✓ |
| 运行、重新运行或重试 CI/CD 流水线或作业 <sup>14</sup> | | | | | ✓ | ✓ | ✓ |
| 为受保护分支运行、重新运行或重试 CI/CD 流水线或作业 <sup>6</sup> | | | | | | ✓ | ✓ |
| 删除作业日志或作业产物 <sup>7</sup> | | | | | | ✓ | ✓ |
| 启用[评审应用](../ci/review_apps/_index.md) | | | | | | ✓ | ✓ |
| 取消作业 <sup>8</sup> | | | | | | ✓ | ✓ |
| 读取 [Terraform](infrastructure/_index.md) 状态 | | | | | | ✓ | ✓ |
| 运行[交互式 Web 终端](../ci/interactive_web_terminal/_index.md) <sup>15</sup> | | | | | | ✓ | ✓ |
| 使用流水线编辑器 | | | | | | ✓ | ✓ |
| 查看项目 Runner <sup>9</sup> | | | | | ✓ | | ✓ |
| 管理项目 Runner <sup>9</sup> | | | | | | | ✓ |
| 删除项目 Runner <sup>10</sup> | | | | | | | ✓ |
| 管理 [Kubernetes Agent](clusters/agent/_index.md) | | | | | | | ✓ |
| 管理 CI/CD 设置 | | | | | | | ✓ |
| 管理作业触发器 | | | | | | | ✓ |
| 管理项目 CI/CD 变量 | | | | | | | ✓ |
| 管理项目受保护环境 | | | | | | | ✓ |
| 管理项目[安全文件](../api/secure_files.md) | | | | | | | ✓ |
| 管理 [Terraform](infrastructure/_index.md) 状态 | | | | | | | ✓ |
| 将项目 Runner 添加到项目 <sup>11</sup> | | | | | | | ✓ |
| 手动清除 Runner 缓存 | | | | | | | ✓ |
| 在项目中启用实例 Runner | | | | | | | ✓ |
| 创建流水线计划 <sup>12</sup> | | | | | | ✓ | ✓ |
| 编辑自己的流水线计划 <sup>12</sup> | | | | | | ✓ | ✓ |
| 删除自己的流水线计划 | | | | | | ✓ | ✓ |
| 手动运行流水线计划 <sup>13</sup> | | | | | | ✓ | ✓ |
| 接管流水线计划的所有权 | | | | | | | ✓ |
| 删除他人的流水线计划 | | | | | | | ✓ |

**脚注**：

<!-- Disable ordered list rule <https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md#md029---ordered-list-item-prefix> -->
<!-- markdownlint-disable MD029 -->

1. 非成员和访客：仅当项目是公开的。
2. 非成员：仅当项目是公开的且启用了 **基于项目的流水线可见性**。<br>访客：仅当启用了 **基于项目的流水线可见性**。
3. 非成员：仅当项目是公开的、启用了 **基于项目的流水线可见性**，且作业上未设置 [`artifacts:public: false`](../ci/yaml/_index.md#artifactspublic)。<br>访客：仅当启用了 **基于项目的流水线可见性** 且作业上未设置`artifacts:public: false`。<br>报告者：仅当作业上未设置`artifacts:public: false`。<br>`artifacts:public`设置仅影响极狐GitLab UI 和 API 访问。CI/CD 作业令牌仍可通过 Runner API 访问产物。
4. 访客：仅当启用了 **基于项目的流水线可见性**。
5. 报告者：仅当用户是[有权访问受保护环境的群组的一部分](../ci/environments/protected_environments.md#deployment-only-access-to-protected-environments)。<br>开发者和维护者：仅当用户[被允许部署到受保护环境](../ci/environments/protected_environments.md#protecting-environments)。
6. 开发者和维护者：仅当用户[被允许合并或推送到受保护分支](../ci/pipelines/_index.md#pipeline-security-on-protected-branches)。
7. 开发者：仅当作业由该用户触发且针对非受保护分支运行。
8. 取消权限可以在流水线设置中[受限](../ci/pipelines/settings.md#restrict-roles-that-can-cancel-pipelines-or-jobs)。
9. 维护者：必须对与 Runner 关联的项目拥有维护者角色。
10. 维护者：必须对[所有者项目](../ci/runners/runners_scope.md#project-runner-ownership)（第一个与 Runner 关联的项目）拥有维护者角色。
11. 维护者：必须对要添加的项目以及已与 Runner 关联的项目拥有维护者角色。
12. 开发者：仅针对用户拥有合并权限的分支。
    对于受保护分支，必须拥有目标分支的合并权限。
    对于受保护标签，必须允许用户创建受保护标签。
    这些权限要求适用于创建或编辑计划时，并且会随着分支保护规则可能随时间变化而动态检查。
13. 手动运行时，流水线以触发用户的权限执行，而不是计划所有者的权限。
14. 安全管理员只能运行 DAST 按需扫描流水线。
15. 开发者和维护者：仅当作业由该用户触发。

<!-- markdownlint-enable MD029 -->

此表显示了由特定角色触发的作业所授予的权限。

项目所有者可以执行任何列出的操作，但任何用户都不能同时推送源代码和 LFS。
访客用户和拥有报告者角色的成员无法执行任何这些操作。

| 操作 | 开发者 | 维护者 |
| --------------------------------------------------------- | :-------: | :--------: |
| 从当前项目克隆源代码和 LFS | ✓ | ✓ |
| 从公开项目克隆源代码和 LFS | ✓ | ✓ |
| 从内部项目克隆源代码和 LFS <sup>1</sup> | ✓ | ✓ |
| 从私有项目克隆源代码和 LFS <sup>2</sup> | ✓ | ✓ |
| 从当前项目拉取容器镜像 | ✓ | ✓ |
| 从公开项目拉取容器镜像 | ✓ | ✓ |
| 从内部项目拉取容器镜像 <sup>1</sup> | ✓ | ✓ |
| 从私有项目拉取容器镜像 <sup>2</sup> | ✓ | ✓ |
| 将容器镜像推送到当前项目 <sup>3</sup> | ✓ | ✓ |

**脚注**：

1. 开发者和维护者：仅当触发用户不是外部用户。
1. 仅当触发用户是项目成员。另请参见[使用带有`if-not-present`拉取策略的私有 Docker 镜像](https://gitlab.cn/docs/runner/security/#usage-of-private-docker-images-with-if-not-present-pull-policy)。
1. 您无法将容器镜像推送到其他项目。

<a id="project-compliance"></a>

### 项目合规

[合规](compliance/_index.md)功能的项目权限，包括合规中心、审计事件、合规框架和许可证。

| 操作 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| --------------------------------------------------------------------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看[合并请求中允许和拒绝的许可证](compliance/license_scanning_of_cyclonedx_files/_index.md) <sup>1</sup> | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 查看[审计事件](compliance/audit_events.md) <sup>2</sup> | | | | ✓ | ✓ | ✓ | ✓ |
| 在[依赖列表](application_security/dependency_list/_index.md)中查看许可证 | | | | ✓ | ✓ | ✓ | ✓ |
| 查看[合规中心](compliance/compliance_center/_index.md) | | | | ✓ | | | ✓ |
| 管理[审计流](compliance/audit_event_streaming.md) | | | | | | | ✓ |

**脚注**：

1. 在极狐GitLab 私有化部署上，拥有访客角色的用户只能在公开和内部项目（而非私有项目）上执行此操作。[外部用户](../administration/external_users.md)必须拥有报告者、开发者、维护者或所有者角色，即使项目是内部的。由于内部可见性不可用，JihuLab.com 上拥有访客角色的用户只能在公开项目上执行此操作。
1. 用户只能查看基于其个人操作的事件。更多详情，请参见[先决条件](compliance/audit_events.md#prerequisites)。

<a id="project-gitlab-duo"></a>

### 项目极狐GitLab Duo

[极狐GitLab Duo](gitlab_duo/_index.md)的项目权限：

| 操作 | 非成员 | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ------------------------------------------------------------------------------------ | :--------: | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 使用极狐GitLab Duo 功能 <sup>1</sup> | | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 配置[极狐GitLab Duo 功能可用性](gitlab_duo/turn_on_off.md#for-a-project) | | | | | | | ✓ | ✓ |

**脚注**：

1. 代码建议要求[为用户分配席位以访问极狐GitLab Duo 附加组件](../subscriptions/subscription-add-ons.md#assign-gitlab-duo-seats)。

<a id="project-merge-requests"></a>

### 项目合并请求

[合并请求](project/merge_requests/_index.md)的项目权限：

| 操作                                                                                    | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ----------------------------------------------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| [查看](project/merge_requests/_index.md#view-merge-requests) 合并请求 <sup>1</sup> |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| [搜索](search/_index.md) 合并请求和评论 <sup>1</sup><sup>2</sup>           |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| [批准](project/merge_requests/approvals/_index.md) 合并请求 <sup>3</sup>         |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 添加内部评论                                                                         |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 评论和添加建议                                                               |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 创建[代码片段](snippets.md)                                                            |       |         |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 创建[合并请求](project/merge_requests/creating_merge_requests.md) <sup>4</sup>    |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 更新合并请求详情 <sup>5</sup>                                                 |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 管理[合并请求设置](project/merge_requests/approvals/settings.md)             |       |         |          |                  |           |     ✓      |   ✓   |
| 管理[合并请求批准规则](project/merge_requests/approvals/rules.md)          |       |         |          |                  |           |     ✓      |   ✓   |
| 删除合并请求                                                                      |       |         |          |                  |           |            |   ✓   |

**脚注**：

1. 在极狐GitLab 私有化部署上，具有访客角色的用户只能在公开和内部项目（而非私有项目）中执行此操作。即使项目是内部的，[外部用户](../administration/external_users.md)也必须获得显式访问权限（至少是**报告者**角色）。由于内部可见性不可用，JihuLab.com 上具有访客角色的用户只能在公开项目中执行此操作。
1. 具有计划者角色的用户无法对合并请求及合并请求上的评论使用高级搜索。有关更多信息，请参阅[史诗 &17674](https://gitlab.com/groups/gitlab-org/-/work_items/17674)。
1. 仅当[为项目启用](project/merge_requests/approvals/rules.md#enable-approval-permissions-for-additional-users)时，计划者和报告者角色的批准才可用。
1. 在接受外部成员贡献的项目中，用户可以创建、编辑和关闭自己的合并请求。对于**私有**项目，这不包括访客角色，因为这些用户[无法克隆私有项目](public_access.md#private-projects-and-groups)。对于**内部**项目，包括对项目具有只读访问权限的用户，因为[他们可以克隆内部项目](public_access.md#internal-projects-and-groups)。
1. 在接受外部成员贡献的项目中，用户可以创建、编辑和关闭自己的合并请求。他们无法编辑某些字段，例如指派人、审核人、标记和里程碑。

<a id="project-model-registry-and-experiments"></a>

### 项目模型仓库和实验

[模型仓库](project/ml/model_registry/_index.md)和[模型实验](project/ml/experiment_tracking/_index.md)的项目权限。

| 操作                                                                          | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ------------------------------------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看[模型和版本](project/ml/model_registry/_index.md) <sup>1</sup>    |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 查看[模型实验](project/ml/experiment_tracking/_index.md) <sup>2</sup> |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 创建模型、版本和产物 <sup>3</sup>                             |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 编辑模型、版本和产物                                            |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 删除模型、版本和产物                                          |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 创建实验和候选版本                                               |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 编辑实验和候选版本                                                 |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 删除实验和候选版本                                               |       |         |          |                  |     ✓     |     ✓      |   ✓   |

**脚注**：

1. 非成员只能在具有**所有有访问权限的人**可见性级别的公开项目中查看模型和版本。非成员无法查看内部项目，即使他们已登录。
1. 非成员只能在具有**所有有访问权限的人**可见性级别的公开项目中查看模型实验。非成员无法查看内部项目，即使他们已登录。
1. 您还可以使用软件包仓库 API 上传和下载产物，该 API 使用一组不同的权限。

<a id="project-monitoring"></a>

### 项目监控

监控的项目权限，包括[错误跟踪](../operations/error_tracking.md)和[事件管理](../operations/incident_management/_index.md)：

| 操作                                                                                                              | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ------------------------------------------------------------------------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看[事件](../operations/incident_management/incidents.md)                                                  |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 分配[事件管理](../operations/incident_management/_index.md)警报                                  |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 参与[事件管理](../operations/incident_management/_index.md)的值班轮换              |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 查看[警报](../operations/incident_management/alerts.md)                                                          |       |         |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 查看[错误跟踪](../operations/error_tracking.md)列表                                                         |       |         |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 查看[升级策略](../operations/incident_management/escalation_policies.md)                                |       |         |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 查看[值班安排](../operations/incident_management/oncall_schedules.md)                                     |       |         |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 创建[事件](../operations/incident_management/incidents.md)                                                   |       |         |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 更改[警报状态](../operations/incident_management/alerts.md#change-an-alerts-status)                          |       |         |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 更改[事件严重性](../operations/incident_management/manage_incidents.md#change-severity)                   |       |         |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 更改[事件升级状态](../operations/incident_management/manage_incidents.md#change-status)            |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 更改[事件升级策略](../operations/incident_management/manage_incidents.md#change-escalation-policy) |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 管理[错误跟踪](../operations/error_tracking.md)                                                            |       |         |          |                  |           |     ✓      |   ✓   |
| 管理[升级策略](../operations/incident_management/escalation_policies.md)                              |       |         |          |                  |           |     ✓      |   ✓   |
| 管理[值班安排](../operations/incident_management/oncall_schedules.md)                                   |       |         |          |                  |           |     ✓      |   ✓   |

<a id="project-packages-and-registries"></a>

### 项目软件包和仓库

[容器镜像仓库](packages/_index.md)的项目权限：

| 操作                                                                                           | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ------------------------------------------------------------------------------------------------ | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 拉取容器镜像仓库镜像 <sup>1</sup>                                                      |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 推送容器镜像仓库镜像                                                                   |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 删除容器镜像仓库镜像                                                                 |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 管理清理策略                                                                          |       |         |          |                  |           |     ✓      |   ✓   |
| 创建[标签保护](packages/container_registry/protected_container_tags.md)规则           |       |         |          |                  |           |     ✓      |   ✓   |
| 创建[不可变标签保护](packages/container_registry/immutable_container_tags.md)规则 |       |         |          |                  |           |            |   ✓   |

**脚注**：

1. 查看容器镜像仓库和拉取镜像由[容器镜像仓库可见性权限](packages/container_registry/_index.md#container-registry-visibility-permissions)控制。访客角色在私有项目中不具有查看或拉取权限。

[软件包仓库](packages/_index.md)的项目权限：

| 操作                                  | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| --------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 拉取软件包 <sup>1</sup>              |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 发布软件包                        |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 删除软件包                         |       |         |          |                  |           |     ✓      |   ✓   |
| 删除与软件包关联的文件  |       |         |          |                  |           |     ✓      |   ✓   |

**脚注**：

1. 在极狐GitLab 私有化部署上，具有访客角色的用户只能在公开和内部项目（而非私有项目）中执行此操作。即使项目是内部的，[外部用户](../administration/external_users.md)也必须获得显式访问权限（至少是**报告者**角色）。由于内部可见性不可用，JihuLab.com 上具有访客角色的用户只能在公开项目中执行此操作。

<a id="project-planning"></a>

### 项目规划

[议题](project/issues/_index.md)的项目权限：

| 操作                                                                            | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| --------------------------------------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看议题                                                                       |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| [搜索](search/_index.md)议题和评论                                    |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 创建议题                                                                     |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 查看[机密议题](project/issues/confidential_issues.md)                 |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| [搜索](search/_index.md)机密议题和评论 <sup>6</sup>          |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 编辑议题，包括元数据、项锁定和解决讨论线程 <sup>1</sup> |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 添加内部评论                                                                |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 关闭和重新打开议题 <sup>2</sup>                                              |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 管理[设计管理](project/issues/design_management.md)文件             |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 管理[议题看板](project/issue_board.md)                                     |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 管理[里程碑](project/milestones/_index.md)                                 |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| [搜索](search/_index.md)里程碑 <sup>6</sup>                                |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 归档或重新打开[需求](project/requirements/_index.md) <sup>3</sup>     |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 创建或编辑[需求](project/requirements/_index.md) <sup>4</sup>        |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 导入或导出[需求](project/requirements/_index.md)                   |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 归档[测试用例](../ci/test_cases/_index.md)                                  |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 创建[测试用例](../ci/test_cases/_index.md)                                   |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 移动[测试用例](../ci/test_cases/_index.md)                                     |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 重新打开[测试用例](../ci/test_cases/_index.md)                                   |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 从 CSV 文件[导入](project/issues/csv_import.md)议题                     |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 将议题[导出](project/issues/csv_export.md)到 CSV 文件                       |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 删除议题 <sup>5</sup>                                                        |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 管理[功能标志](../operations/feature_flags.md)                            |       |         |          |                  |     ✓     |     ✓      |   ✓   |

**脚注**：

1. 元数据包括标记、指派人、里程碑、史诗、权重、机密性、时间跟踪等。访客用户只能在创建议题时设置元数据。他们无法更改现有议题上的元数据。访客用户可以修改他们创建或被指派到的议题的标题和描述。
1. 访客用户可以关闭和重新打开他们创建或被指派到的议题。
1. 访客用户可以归档和重新打开他们创建或被指派到的议题。
1. 访客用户可以修改他们创建或被指派到的议题的标题和描述。
1. 没有计划者或所有者角色的用户只能删除他们创建的议题。
1. 具有计划者角色的用户无法对里程碑或机密议题上的评论使用高级搜索。有关更多信息，请参阅[史诗 17674](https://gitlab.com/groups/gitlab-org/-/work_items/17674)。

[任务](tasks.md)的项目权限：

| 操作                                                                           | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| -------------------------------------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看任务                                                                       |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| [搜索](search/_index.md)任务                                                 |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 创建任务                                                                     |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 编辑任务，包括元数据、项锁定和解决讨论线程 <sup>1</sup> |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 添加关联项                                                                |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 转换为其他项类型                                                     |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 从议题中移除                                                                |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 添加内部评论                                                                |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 删除任务 <sup>2</sup>                                                        |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |

**脚注**：

1. 访客用户可以修改他们创建或被指派到的任务的标题和描述。
1. 没有计划者或所有者角色的用户只能删除他们创建的任务。

[OKR](okrs.md)的项目权限：

| 操作                                                             | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ------------------------------------------------------------------ | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看 OKR                                                          |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| [搜索](search/_index.md) OKR                                    |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 创建 OKR                                                        |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 编辑 OKR，包括元数据、项锁定和解决讨论线程 |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 添加子 OKR                                                    |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 添加关联项                                                  |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 转换为其他项类型                                       |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 编辑 OKR                                                          |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 更改 OKR 中的机密性                                      |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 添加内部评论                                                  |       |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |

[Wiki](project/wiki/_index.md)的项目权限：

| 操作                           | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| -------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看 Wiki                        |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| [搜索](search/_index.md) Wiki |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 创建 Wiki 页面                |       |    ✓    |          |                  |     ✓     |     ✓      |   ✓   |
| 编辑 Wiki 页面                  |       |    ✓    |          |                  |     ✓     |     ✓      |   ✓   |
| 删除 Wiki 页面                |       |    ✓    |          |                  |     ✓     |     ✓      |   ✓   |

<a id="project-repositories"></a>

### 项目代码仓库

[代码仓库](project/repository/_index.md)功能（包括源代码、分支、推送规则等）的项目权限：

| 操作                                                                | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| --------------------------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看项目代码 <sup>1</sup>                                        |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| [搜索](search/_index.md)项目代码 <sup>1</sup> <sup>2</sup>                  |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| [搜索](search/_index.md)提交和评论 <sup>1</sup> <sup>2</sup>          |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 拉取项目代码 <sup>3</sup>                                        |   ✓   |    ✓    |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 查看提交状态                                                    |       |         |    ✓     |        ✓         |     ✓     |     ✓      |   ✓   |
| 创建提交状态 <sup>4</sup>                                     |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 更新提交状态 <sup>4</sup>                                     |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 创建 [Git 标签](project/repository/tags/_index.md)                  |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 删除 [Git 标签](project/repository/tags/_index.md)                  |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 创建新[分支](project/repository/branches/_index.md)          |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 推送到非受保护分支                                        |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 强制推送到非受保护分支                                  |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 删除非受保护分支                                         |       |         |          |                  |     ✓     |     ✓      |   ✓   |
| 管理[受保护分支](project/repository/branches/protected.md) |       |         |          |                  |           |     ✓      |   ✓   |
| 推送到受保护分支 <sup>4</sup>                               |       |         |          |                  |           |     ✓      |   ✓   |
| 删除受保护分支                                             |       |         |          |                  |           |     ✓      |   ✓   |
| 管理[受保护标签](project/protected_tags.md)                    |       |         |          |                  |           |     ✓      |   ✓   |
| 管理[推送规则](project/repository/push_rules.md)                 |       |         |          |                  |           |     ✓      |   ✓   |
| 移除复刻关系                                              |       |         |          |                  |           |            |   ✓   |
| 强制推送到受保护分支 <sup>5</sup>                         |       |         |          |                  |           |            |       |

**脚注**：

<!-- Disable ordered list rule <https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md#md029---ordered-list-item-prefix> -->
<!-- markdownlint-disable MD029 -->

1. 在极狐GitLab 私有化部署上，具有访客角色的用户只能在公开和内部项目（而非私有项目）中执行此操作。即使项目是内部的，[外部用户](../administration/external_users.md)也必须获得显式访问权限（至少是**计划者**角色）。由于内部可见性不可用，JihuLab.com 上具有访客角色的用户只能在公开项目中执行此操作。具有访客角色和旗舰版许可证的用户可以查看私有代码仓库内容，前提是管理员（在极狐GitLab 私有化部署上）或群组所有者（在 JihuLab.com 上）授予这些用户权限。管理员或群组所有者可以通过 API 或 UI 创建[自定义角色](custom_roles/_index.md)并将该角色分配给用户。在极狐GitLab 18.7 及更高版本中，具有计划者角色的用户可以查看私有代码仓库内容。
1. 具有计划者角色的用户无法在私有项目中对代码、提交和提交评论使用精确代码搜索或高级搜索。有关更多信息，请参阅[史诗 &17674](https://gitlab.com/groups/gitlab-org/-/work_items/17674)。
1. 如果[分支受保护](project/repository/branches/protected.md)，这取决于授予开发者和维护者的访问权限。
1. 在极狐GitLab 私有化部署上，具有访客角色的用户只能在公开和内部项目（而非私有项目）中执行此操作。即使项目是内部的，[外部用户](../administration/external_users.md)也必须获得显式访问权限（至少是**报告者**角色）。由于内部可见性不可用，JihuLab.com 上具有访客角色的用户只能在公开项目中执行此操作。具有访客角色和旗舰版许可证的用户可以查看私有代码仓库内容，前提是管理员（在极狐GitLab 私有化部署上）或群组所有者（在 JihuLab.com 上）授予这些用户权限。管理员或群组所有者可以通过 API 或 UI 创建[自定义角色](custom_roles/_index.md)并将该角色分配给用户。
1. 访客、报告者、开发者、维护者或所有者均不允许。请参阅[受保护分支](project/repository/branches/protected.md#allow-force-push)。

<!-- markdownlint-enable MD029 -->

<a id="project-user-management"></a>

### 项目用户管理

[用户管理](project/members/_index.md)的项目权限。

| 操作                                                           | 访客 | 计划者 | 报告者 | 安全管理员 | 开发者 | 维护者 | 所有者 |
| ---------------------------------------------------------------- | :---: | :-----: | :------: | :--------------: | :-------: | :--------: | :---: |
| 查看成员的 2FA 状态                                       |       |         |          |                  |           |     ✓      |   ✓   |
| 管理[项目成员](project/members/_index.md) <sup>1</sup> |       |         |          |                  |           |     ✓      |   ✓   |
| 与群组共享（邀请）项目 <sup>2</sup>                 |       |         |          |                  |           |            |   ✓   |

**脚注**：

1. 维护者无法创建、降级或移除所有者，也无法将用户提升为所有者角色。他们也无法批准所有者角色的访问请求。
1. 当启用[共享群组锁定](project/members/sharing_projects_groups.md#prevent-a-project-from-being-shared-with-groups)时，项目无法与其他群组共享。这不影响群组与群组之间的共享。

<a id="subgroup-permissions"></a>

## 子群组权限

当您向子群组添加成员时，他们会继承父群组的成员身份和权限级别。此模型允许您访问嵌套群组，前提是您是其某个父群组的成员。

有关更多信息，请参阅[子群组成员身份](group/subgroups/_index.md#subgroup-membership)。

<a id="users-with-minimal-access"></a>

## 具有最小访问权限的用户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

具有最小访问权限角色的用户不会：

- 自动获得对该顶级群组中项目和子群组的访问权限。所有者必须显式地将这些用户添加到特定的子群组和项目中。
- 计入许可席位，前提是该用户在实例或 JihuLab.com 命名空间中的任何其他位置没有其他角色。

最小访问权限角色不授予群组和项目权限表中的任何权限。仅具有此角色的用户无法查看 Wiki、议题或代码仓库等项目功能。要授予这些用户对项目或子群组的访问权限，所有者必须使用访客角色或更高级别的角色添加他们。

如果具有最小访问权限角色的用户在某个项目或子群组中被授予[可计费角色](../subscriptions/manage_seats.md#billable-users)，则他们将根据其最高角色消耗许可席位。

您可以将最小访问权限角色与[JihuLab.com 群组的 SAML SSO](group/saml_sso/_index.md) 结合使用，以控制对群组层级中群组和项目的访问。您可以将通过 SSO 自动添加到顶级群组的成员的默认角色设置为最小访问权限。

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **SAML SSO**。
1. 从**默认成员角色**下拉列表中，选择**最小访问权限**。
1. 选择**保存更改**。

<a id="minimal-access-users-receive-404-errors"></a>

### 最小访问权限用户收到 404 错误

由于一个[未解决的问题](https://gitlab.com/gitlab-org/gitlab/-/issues/267996)，使用标准 Web 身份验证登录的具有最小访问权限角色的用户在访问父群组时会收到 `404` 错误。

使用群组 SSO 登录的具有最小访问权限角色的用户会被重定向到其群组仪表板，而不是父群组页面。有关该仪表板上显示的群组的已知问题，请参阅[议题 506280](https://gitlab.com/gitlab-org/gitlab/-/issues/506280) 和[议题 507968](https://gitlab.com/gitlab-org/gitlab/-/issues/507968)。

要变通解决 `404` 错误，请为这些用户授予父群组中任何项目或子群组的访客、计划者、报告者、安全管理员、开发者、维护者或所有者角色。访客用户在专业版中消耗许可席位，但在旗舰版中不消耗。
