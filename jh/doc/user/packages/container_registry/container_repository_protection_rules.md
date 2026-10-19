---
stage: Container
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 受保护的容器仓库
description: 极狐GitLab 中的受保护容器仓库会限制哪些用户角色可以推送或删除镜像。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

默认情况下，任何拥有开发者、维护者或所有者角色的用户都可以向容器仓库推送容器镜像，或从中删除容器镜像。保护容器仓库可以限制哪些用户可以更改您容器仓库中的容器镜像。

当容器仓库受到保护时，默认行为会对该容器仓库及其镜像强制执行以下限制：

| 操作                                                                                   | 最低角色         |
|------------------------------------------------------------------------------------------|----------------------|
| 保护容器仓库及其容器镜像。                                 | 维护者角色。 |
| 在容器仓库中推送或创建新镜像。                                    | 在[**推送的最低访问级别**](#create-a-container-repository-protection-rule)设置中设定的角色。 |
| 在容器仓库中推送或更新现有镜像。                              | 在[**推送的最低访问级别**](#create-a-container-repository-protection-rule)设置中设定的角色。 |
| 使用部署令牌在容器仓库中推送、创建或更新现有镜像。 | 不适用。部署令牌可用于非受保护的仓库，但无论其作用域如何，都不能用于将镜像推送到受保护的容器仓库。 |

您可以使用通配符（`*`）通过同一条容器保护规则保护多个容器仓库。例如，您可以保护不同的容器仓库，其中包含在 CI/CD 流水线中构建的临时容器镜像。

下表包含可匹配多个容器仓库的容器保护规则示例：

| 带通配符的路径模式 | 匹配的容器仓库示例 |
|----------------------------|-----------------------------------------|
| `group/container-*`        | `group/container-prod`, `group/container-prod-sha123456789` |
| `group/*container`         | `group/container`, `group/prod-container`, `group/prod-sha123456789-container` |
| `group/*container*`        | `group/container`, `group/prod-sha123456789-container-v1` |

您可以将多条保护规则应用于同一个容器仓库。只要至少有一条保护规则匹配，该容器仓库就受到保护。

<a id="create-a-container-repository-protection-rule"></a>

## 创建容器仓库保护规则

先决条件：

- 您必须拥有维护者或所有者角色。

要创建保护规则：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **软件包和镜像仓库**。
1. 展开**容器镜像仓库**。
1. 在**受保护的容器仓库**下，选择**添加保护规则**。
1. 填写字段：
   - **仓库路径模式**是您要保护的容器仓库路径。
     该模式可以包含通配符（`*`）。
   - **推送的最低访问级别**描述了推送到受保护的容器仓库路径（创建或更新）所需的最低访问级别。
1. 选择**保护**。

保护规则已创建，该容器仓库现在受到保护。

<a id="delete-a-container-repository-protection-rule"></a>

## 删除容器仓库保护规则

先决条件：

- 您必须拥有维护者或所有者角色。

要删除保护规则：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **软件包和镜像仓库**。
1. 展开**容器镜像仓库**。
1. 在**受保护的容器仓库**下，找到要删除的保护规则，选择**删除**（{{< icon name="remove" >}}）。
1. 在确认对话框中，选择**删除**。

保护规则已删除，该容器仓库不再受到保护。
