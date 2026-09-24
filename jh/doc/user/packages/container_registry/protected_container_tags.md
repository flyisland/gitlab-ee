---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 受保护的容器标签
description: Control who can push or delete container tags with role-based protection rules using regex patterns.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.9 中作为一项[实验](../../../policy/development_stages_support.md)引入，并带有名为 `container_registry_protected_tags` 的[功能标志](../../../administration/feature_flags/_index.md)。默认禁用。
- 于极狐GitLab 17.10 中[在 JihuLab.com 上启用](https://gitlab.com/gitlab-org/gitlab/-/issues/505455)。
- 于极狐GitLab 17.11 中[全面可用（GA）](https://gitlab.com/gitlab-org/gitlab/-/issues/524076)。功能标志 `container_registry_protected_tags` 已移除。

{{< /history >}}

控制谁可以在项目中推送和删除容器标签。

默认情况下，具有开发者、维护者或所有者角色的用户可以在所有项目容器镜像仓库中推送和删除镜像标签。通过标签保护规则，你可以：

- 限制推送和删除标签到特定的用户角色。
- 每个项目最多创建 5 条保护规则。
- 将这些规则应用于项目中的所有容器镜像仓库。

当至少一条保护规则与标签名称匹配时，该标签即受到保护。如果多条规则匹配，则应用最严格的规则。

受保护的标签不能被[清理策略](reduce_container_registry_storage.md#cleanup-policy)删除。

<a id="prerequisites"></a>

## 前提条件

在使用受保护的容器标签之前：

- 你必须使用新版容器镜像仓库：
  - JihuLab.com：默认启用
  - 极狐GitLab 私有化部署：[启用元数据数据库](../../../administration/packages/container_registry_metadata_database.md)

<a id="create-a-protection-rule"></a>

## 创建保护规则

前提条件：

- 你必须具有维护者或所有者角色

要创建保护规则：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **软件包和镜像仓库**。
1. 展开 **容器镜像仓库**。
1. 在 **受保护的容器标签** 下，选择 **添加保护规则**。
1. 填写以下字段：
   - **保护匹配以下规则的容器标签**：输入使用 [RE2 语法](https://github.com/google/re2/wiki/Syntax) 的正则表达式。模式不能超过 100 个字符。请参阅[正则表达式模式示例](#regex-pattern-examples)。
   - **允许推送的最低角色**：选择维护者、所有者或管理员。
   - **允许删除的最低角色**：选择维护者、所有者或管理员。
1. 选择 **添加规则**。

保护规则即创建完成，匹配的标签受到保护。

<a id="regex-pattern-examples"></a>

## 正则表达式模式示例

可用于保护容器标签的示例模式：

| 模式           | 描述 |
|-------------------|-------------|
| `.*`              | 保护所有标签 |
| `^v.*`            | 保护以 “v” 开头的标签（如 `v1.0.0`、`v2.1.0-rc1`） |
| `\d+\.\d+\.\d+`   | 保护语义版本标签（如 `1.0.0`、`2.1.0`） |
| `^latest$`        | 保护 `latest` 标签 |
| `.*-stable$`      | 保护以 “-stable” 结尾的标签（如 `1.0-stable`、`main-stable`） |
| `stable\|release` | 保护包含 “stable” 或 “release” 的标签（如 `1.0-stable`） |

<a id="delete-a-protection-rule"></a>

## 删除保护规则

前提条件：

- 你必须具有维护者或所有者角色

要删除保护规则：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **软件包和镜像仓库**。
1. 展开 **容器镜像仓库**。
1. 在 **受保护的容器标签** 下，在你要删除的保护规则旁边，选择 **删除**（{{< icon name="remove" >}}）。
1. 当提示确认时，选择 **删除**。

保护规则即被删除，匹配的标签不再受保护。

<a id="propagation-delay"></a>

## 传播延迟

规则变更依赖 JWT 令牌在服务之间传播。因此，保护规则和用户访问角色的变更可能仅在当前 JWT 令牌过期后才生效。延迟等于[配置的令牌持续时间](../../../administration/packages/container_registry.md#increase-token-duration)：

- 默认：5 分钟
- JihuLab.com：15 分钟

大多数容器镜像仓库客户端（包括 Docker、极狐GitLab UI 和 API）会为每次操作请求新令牌，但自定义客户端可能会在完整有效期内保留令牌。

<a id="image-manifest-deletions"></a>

## 镜像清单删除

极狐GitLab UI 和 API 不支持直接删除镜像清单。
通过直接的容器镜像仓库 API 调用，清单删除会影响所有关联的标签。

为确保标签保护，仅在以下情况下允许直接清单删除请求：

- 标签保护已禁用
- 用户有权删除任何受保护的标签

<a id="deleting-container-images"></a>

## 删除容器镜像

如果以下所有条件均成立，你将无法[删除容器镜像](delete_container_registry_images.md)：

- 容器镜像具有标签。
- 项目启用了容器镜像仓库标签保护规则。
- 你的访问级别低于任何规则中定义的 `minimum_access_delete_level`。

无论规则模式是否与容器镜像标签匹配，此限制均适用。