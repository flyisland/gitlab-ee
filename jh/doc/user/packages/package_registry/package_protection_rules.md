---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 受保护的软件包
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 GitLab 16.5 中引入，通过功能标志 `packages_protected_packages`。默认禁用。此功能为实验性质。
- 保护规则设置 **Push protected up to access level** 在 GitLab 17.1 中重命名为 **Minimum access level for push**。
- 在 GitLab 17.6 中 GA。功能标志 `packages_protected_packages` 已移除。
- Conan 受保护的软件包在 GitLab 17.6 中引入，通过功能标志 `packages_protected_packages_conan`。默认禁用。此功能为实验性质。
- Maven 受保护的软件包在 GitLab 17.9 中引入，通过功能标志 `packages_protected_packages_maven`。默认禁用。此功能为实验性质。
- 在 GitLab 17.10 中引入，通过功能标志 `packages_protected_packages_delete`。默认禁用。此功能为实验性质。
- Maven 受保护的软件包在 GitLab 17.11 中 GA。功能标志 `packages_protected_packages_maven` 已移除。
- Conan 受保护的软件包在 GitLab 17.11 中 GA。功能标志 `packages_protected_packages_conan` 已移除。
- NuGet 受保护的软件包在 GitLab 18.0 中引入，通过功能标志 `packages_protected_packages_nuget`。默认禁用。此功能为实验性质。
- 受保护的 Helm Chart 在 GitLab 18.1 中引入，通过功能标志 `packages_protected_packages_helm`。默认禁用。此功能为实验性质。
- Generic 受保护的软件包在 GitLab 18.1 中引入，通过功能标志 `packages_protected_packages_generic`。默认禁用。此功能为实验性质。
- Generic 受保护的软件包在 GitLab 18.2 中 GA。功能标志 `packages_protected_packages_generic` 已移除。
- NuGet 受保护的软件包在 GitLab 18.2 中 GA。功能标志 `packages_protected_packages_nuget` 已移除。
- Helm 受保护的软件包在 GitLab 18.3 中 GA。功能标志 `packages_protected_packages_helm` 已移除。

{{< /history >}}

默认情况下，任何具有开发者、维护者或所有者角色的用户都可以创建、编辑和删除软件包。添加软件包保护规则可以限制哪些用户能够对您的软件包进行更改。

极狐GitLab 支持对 npm、PyPI、Maven 和 Conan 软件包进行保护，但史诗 5574 提议增加更多功能和软件包格式。

当软件包受到保护时，默认行为会对该软件包强制执行以下限制：

| 操作                                 | 最低角色或令牌                                                                     |
|:---------------------------------------|:----------------------------------------------------------------------------------|
| 保护软件包                      | 维护者或所有者角色。                                                     |
| 推送新软件包                     | 至少具有 [**推送的最低访问级别**](#protect-a-package) 中设置的角色。 |
| 使用部署令牌推送新软件包 | 任何有效的部署令牌，仅当推送的软件包未被保护规则匹配时。受保护的软件包无法使用部署令牌推送。 |
| 删除软件包                       | 至少具有 [**删除的最低访问级别**](#protect-a-package) 中设置的角色。 |

<a id="protect-a-package"></a>

## 保护软件包

{{< history >}}

- 在 GitLab 16.9 中引入。

{{< /history >}}

前置条件：

- 您必须具有维护者或所有者角色。

要保护软件包：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **软件包和镜像仓库**。
1. 展开 **软件包仓库**。
1. 在 **受保护的软件包** 下，选择 **添加保护规则**。
1. 填写字段：
   - **名称模式** 是您要保护的软件包名称模式。该模式可以包含通配符 (`*`)。
   - **软件包类型** 是要保护的软件包类型。
   - **推送的最低访问级别** 是推送与名称模式匹配的软件包所需的最低角色。
   - **删除的最低访问级别** 是删除与名称模式匹配的软件包所需的最低角色。
1. 选择 **保护**。

软件包保护规则已创建，并显示在设置中。

<a id="protecting-multiple-packages"></a>

### 保护多个软件包

您可以使用通配符通过同一条软件包保护规则来保护多个软件包。
例如，您可以保护在 CI/CD 流水线期间构建的所有临时软件包。

下表包含匹配多个软件包的软件包保护规则示例：

| 带通配符的软件包名称模式 | 匹配的软件包                                                           |
|------------------------------------|-----------------------------------------------------------------------------|
| `@group/package-*`                 | `@group/package-prod`、`@group/package-prod-sha123456789`                   |
| `@group/*package`                  | `@group/package`、`@group/prod-package`、`@group/prod-sha123456789-package` |
| `@group/*package*`                 | `@group/package`、`@group/prod-sha123456789-package-v1`                     |

可以对同一个软件包应用多条保护规则。
如果至少有一条保护规则适用于该软件包，则该软件包即受到保护。

<a id="delete-a-package-protection-rule-and-unprotect-a-package"></a>

## 删除软件包保护规则并取消保护软件包

{{< history >}}

- 在 GitLab 16.10 中引入。

{{< /history >}}

前置条件：

- 您必须具有维护者或所有者角色。

要取消保护软件包：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **软件包和镜像仓库**。
1. 展开 **软件包仓库**。
1. 在 **受保护的软件包** 下，在您要删除的保护规则旁边，选择 **删除** ({{< icon name="remove" >}})。
1. 在确认对话框中，选择 **删除**。

软件包保护规则已删除，并且不再显示在设置中。