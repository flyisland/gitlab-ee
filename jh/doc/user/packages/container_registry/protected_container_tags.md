---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 受保护的容器标签
description: 使用基于角色的保护规则和正则表达式模式，控制谁可以推送或删除容器标签。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

控制谁可以在您的项目中推送和删除容器标签。

默认情况下，拥有开发者、维护者或所有者角色的用户可以推送和删除所有项目容器仓库中的镜像标签。借助标签保护规则，您可以：

- 将推送和删除标签的操作限制为特定用户角色。
- 每个项目最多创建 5 条保护规则。
- 在项目的所有容器仓库中应用这些规则。

当至少有一条保护规则与标签名称匹配时，该标签即受保护。如果有多条规则匹配，则应用限制最严格的规则。

受保护的标签无法通过[清理策略](reduce_container_registry_storage.md#cleanup-policy)删除。

<a id="prerequisites"></a>

## 先决条件

在使用受保护的容器标签之前：

- 您必须使用新版容器镜像仓库：
  - JihuLab.com：默认启用
  - 极狐GitLab 私有化部署：[启用元数据数据库](../../../administration/packages/container_registry_metadata_database.md)

<a id="create-a-protection-rule"></a>

## 创建保护规则

先决条件：

- 您必须拥有维护者或所有者角色

创建保护规则：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**设置** > **软件包和镜像仓库**。
1. 展开**容器镜像仓库**。
1. 在**受保护的容器标签**下，选择**添加保护规则**。
1. 填写以下字段：
   - **保护匹配以下内容的容器标签**：使用 [RE2 语法](https://github.com/google/re2/wiki/Syntax)输入正则表达式模式。模式不得超过 100 个字符。请参阅[正则表达式模式示例](#regex-pattern-examples)。
   - **允许推送的最低角色**：选择维护者、所有者或管理员。
   - **允许删除的最低角色**：选择维护者、所有者或管理员。
1. 选择**添加规则**。

保护规则即创建完成，匹配的标签将受到保护。

<a id="regex-pattern-examples"></a>

## 正则表达式模式示例

可用于保护容器标签的示例模式：

| 模式           | 描述 |
|-------------------|-------------|
| `.*`              | 保护所有标签 |
| `^v.*`            | 保护以“v”开头的标签（如 `v1.0.0`、`v2.1.0-rc1`） |
| `\d+\.\d+\.\d+`   | 保护语义化版本标签（如 `1.0.0`、`2.1.0`） |
| `^latest$`        | 保护 `latest` 标签 |
| `.*-stable$`      | 保护以“-stable”结尾的标签（如 `1.0-stable`、`main-stable`） |
| `stable\|release` | 保护包含“stable”或“release”的标签（如 `1.0-stable`） |

<a id="delete-a-protection-rule"></a>

## 删除保护规则

先决条件：

- 您必须拥有维护者或所有者角色

删除保护规则：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**设置** > **软件包和镜像仓库**。
1. 展开**容器镜像仓库**。
1. 在**受保护的容器标签**下，找到要删除的保护规则，选择其旁边的**删除**（{{< icon name="remove" >}}）。
1. 系统提示确认时，选择**删除**。

保护规则即被删除，匹配的标签不再受保护。

<a id="propagation-delay"></a>

## 传播延迟

规则变更依赖 JWT 令牌在服务之间传播。因此，保护规则和用户访问角色的变更可能仅在当前 JWT 令牌过期后才会生效。延迟时间等于[配置的令牌有效期](../../../administration/packages/container_registry.md#increase-token-duration)：

- 默认：5 分钟
- JihuLab.com：15 分钟

大多数容器镜像仓库客户端（包括 Docker、极狐GitLab UI 和 API）会为每次操作请求新令牌，但自定义客户端可能会在令牌的整个有效期内一直保留该令牌。

<a id="image-manifest-deletions"></a>

## 镜像清单删除

极狐GitLab UI 和 API 不支持直接删除镜像清单。通过直接调用容器镜像仓库 API 删除清单时，会影响所有关联的标签。

为确保标签保护生效，仅在以下情况下才允许直接删除清单的请求：

- 标签保护已禁用
- 用户有权删除任何受保护的标签

<a id="deleting-container-images"></a>

## 删除容器镜像

如果以下条件全部成立，您将无法[删除容器镜像](delete_container_registry_images.md)：

- 该容器镜像带有标签。
- 项目具有容器镜像仓库标签保护规则。
- 您的访问级别低于任一规则中定义的 `minimum_access_delete_level`。

无论规则模式是否与容器镜像标签匹配，此限制均适用。
