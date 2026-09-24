---
stage: Container
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 受保护的容器仓库
description: Protected container repositories in GitLab limit which user roles can push or delete images.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 引入 于极狐GitLab 16.7 [有一个功能标志](../../../administration/feature_flags/_index.md) 名为 `container_registry_protected_containers`。默认禁用。此功能是[试验性](../../../policy/development_stages_support.md)的。
- 在 JihuLab.com 上启用 于极狐GitLab 17.8。
- GA 于极狐GitLab 17.8。功能标志 `container_registry_protected_containers` 已移除。

{{< /history >}}

默认情况下，任何拥有开发者、维护者或所有者角色的用户都可以推送和删除容器仓库中的容器镜像。保护容器仓库可以限制哪些用户可以更改容器仓库中的容器镜像。

当容器仓库受到保护时，默认行为会对容器仓库及其镜像强制执行以下限制：

| 操作                                                                                   | 最低角色         |
|------------------------------------------------------------------------------------------|----------------------|
| 保护一个容器仓库及其容器镜像。                                 | 维护者角色。 |
| 在容器仓库中推送或创建新镜像。                                    | [**推送的最低访问级别**](#create-a-container-repository-protection-rule) 设置中设置的角色。 |
| 推送或更新容器仓库中的现有镜像。                              | [**推送的最低访问级别**](#create-a-container-repository-protection-rule) 设置中设置的角色。 |
| 使用部署令牌推送、创建或更新受保护容器仓库中的现有镜像。 | 不适用。部署令牌可用于未受保护的仓库，但不能用于将镜像推送到受保护的容器仓库，无论其范围如何。 |

您可以使用通配符 (`*`) 通过同一条容器保护规则保护多个容器仓库。
例如，您可以保护在 CI/CD 流水线期间构建的包含临时容器镜像的不同容器仓库。

下表包含匹配多个容器仓库的容器保护规则示例：

| 带通配符的路径模式 | 匹配的示例容器仓库 |
|----------------------------|-----------------------------------------|
| `group/container-*`        | `group/container-prod`, `group/container-prod-sha123456789` |
| `group/*container`         | `group/container`, `group/prod-container`, `group/prod-sha123456789-container` |
| `group/*container*`        | `group/container`, `group/prod-sha123456789-container-v1` |

您可以对同一个容器仓库应用多个保护规则。只要至少一个保护规则匹配，该容器仓库就受到保护。

## 创建容器仓库保护规则

{{< history >}}

- 引入 于极狐GitLab 16.10。

{{< /history >}}

前提条件：

- 您必须拥有维护者或所有者角色。

要创建保护规则：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **软件包和仓库**。
1. 展开 **容器仓库**。
1. 在 **受保护的容器仓库** 下，选择 **添加保护规则**。
1. 填写字段：
   - **仓库路径模式** 是您想要保护的容器仓库路径。模式可以包含通配符 (`*`)。
   - **推送的最低访问级别** 描述了推送到受保护容器仓库路径所需的最低访问级别。
1. 选择 **保护**。

保护规则已创建，容器仓库现在受保护。

## 删除容器仓库保护规则

{{< history >}}

- 引入 于极狐GitLab 17.0。

{{< /history >}}

前提条件：

- 您必须拥有维护者或所有者角色。

要删除保护规则：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **软件包和仓库**。
1. 展开 **容器仓库**。
1. 在 **受保护的容器仓库** 下，在要删除的保护规则旁边，选择 **删除** ({{< icon name="remove" >}})。
1. 在确认对话框中，选择 **删除**。

保护规则已删除，容器仓库不再受保护。