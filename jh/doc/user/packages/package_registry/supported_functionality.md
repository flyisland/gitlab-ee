---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 支持的软件包管理器及功能
---

极狐GitLab 软件包仓库为每种软件包类型支持不同的功能。这些支持包括发布和拉取软件包、请求转发、管理重复项以及身份验证。

<a id="supported-package-managers"></a>

## 支持的软件包管理器

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 并非所有软件包管理器格式都已准备好用于生产环境。

软件包仓库支持以下软件包管理器类型：

| 软件包类型                                      | 状态 |
|---------------------------------------------------|--------|
| [Composer](../composer_repository/_index.md)      | [测试版](https://gitlab.com/groups/gitlab-org/-/work_items/6817) |
| [Conan 1](../conan_1_repository/_index.md)            | [测试版](https://gitlab.com/groups/gitlab-org/-/work_items/6816) |
| [Conan 2](../conan_2_repository/_index.md)            | [测试版](https://gitlab.com/groups/gitlab-org/-/work_items/8258) |
| [Debian](../debian_repository/_index.md)          | [实验](https://gitlab.com/groups/gitlab-org/-/work_items/6057) |
| [通用软件包](../generic_packages/_index.md) | 正式发布     |
| [Go](../go_proxy/_index.md)                       | [实验](https://gitlab.com/groups/gitlab-org/-/work_items/3043) |
| [Helm](../helm_repository/_index.md)              | 正式发布      |
| [Maven](../maven_repository/_index.md)            | 正式发布      |
| [npm](../npm_registry/_index.md)                  | 正式发布      |
| [NuGet](../nuget_repository/_index.md)            | 正式发布      |
| [PyPI](../pypi_repository/_index.md)              | 正式发布      |
| [Ruby gems](../rubygems_registry/_index.md)       | [实验](https://gitlab.com/groups/gitlab-org/-/work_items/3200) |

[查看每种状态的含义](../../../policy/development_stages_support.md)。

您还可以使用 [API](../../../api/packages.md) 来管理软件包仓库。

<a id="publishing-packages"></a>

## 发布软件包

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

软件包可以发布到您的项目、群组或实例。

| 软件包类型                                           | 项目 | 群组 | 实例 |
|--------------------------------------------------------|---------|-------|----------|
| [Maven（使用 `mvn`）](../maven_repository/_index.md)| 是       | 否     | 否        |
| [Maven（使用 `gradle`）](../maven_repository/_index.md)| 是       | 否     | 否        |
| [Maven（使用 `sbt`）](../maven_repository/_index.md)| 否        | 否     | 否        |
| [npm](../npm_registry/_index.md)                       | 是       | 否     | 否        |
| [NuGet](../nuget_repository/_index.md)                 | 是       | 否     | 否        |
| [PyPI](../pypi_repository/_index.md)                   | 是       | 否     | 否        |
| [通用软件包](../generic_packages/_index.md)      | 是       | 否     | 否        |
| [Terraform](../terraform_module_registry/_index.md)    | 是       | 否     | 否        |
| [Composer](../composer_repository/_index.md)           | 否        | 是    | 否        |
| [Conan 1](../conan_1_repository/_index.md)             | 是       | 否     | 是       |
| [Conan 2](../conan_2_repository/_index.md)             | 是       | 否     | 否        |
| [Helm](../helm_repository/_index.md)                   | 是       | 否     | 否        |
| [Debian](../debian_repository/_index.md)               | 是       | 否     | 否        |
| [Go](../go_proxy/_index.md)                            | 是       | 否     | 否        |
| [Ruby gems](../rubygems_registry/_index.md)            | 是       | 否     | 否        |

<a id="pulling-packages"></a>

## 拉取软件包

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

软件包可以从您的项目、群组或实例中拉取。

| 软件包类型                                           | 项目 | 群组 | 实例 |
|--------------------------------------------------------|---------|-------|----------|
| [Maven（使用 `mvn`）](../maven_repository/_index.md)| 是       | 是     | 是       |
| [Maven（使用 `gradle`）](../maven_repository/_index.md)| 是       | 是     | 是       |
| [Maven（使用 `sbt`）](../maven_repository/_index.md)| 是       | 是     | 是       |
| [npm](../npm_registry/_index.md)                       | 是       | 是     | 是       |
| [NuGet](../nuget_repository/_index.md)                 | 是       | 是     | 否        |
| [PyPI](../pypi_repository/_index.md)                   | 是       | 是     | 否        |
| [通用软件包](../generic_packages/_index.md)      | 是       | 否      | 否        |
| [Terraform](../terraform_module_registry/_index.md)    | 否        | 是     | 否        |
| [Composer](../composer_repository/_index.md)           | 是       | 是     | 否        |
| [Conan 1](../conan_1_repository/_index.md)             | 是       | 否      | 是       |
| [Conan 2](../conan_2_repository/_index.md)             | 是       | 否      | 否        |
| [Helm](../helm_repository/_index.md)                   | 是       | 否      | 否        |
| [Debian](../debian_repository/_index.md)               | 是       | 否      | 否        |
| [Go](../go_proxy/_index.md)                            | 是       | 否      | 是       |
| [Ruby gems](../rubygems_registry/_index.md)            | 是       | 否      | 否        |

<a id="forwarding-requests"></a>

## 转发请求

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

先决条件：

- 在 JihuLab.com 上：您必须是该群组的所有者。
- 在极狐GitLab 私有化部署上：您必须是管理员。

当在您项目的软件包仓库中找不到某个软件包时，请求会转发到该软件包管理器对应的公共仓库。

默认转发行为因软件包类型而异，并可能引入[依赖混淆漏洞](https://medium.com/@alex.birsan/dependency-confusion-4a5d60fec610)。下表显示了哪些软件包管理器支持软件包转发。

为降低相关的安全风险：

- 确认该软件包未被积极使用。
- 实施版本控制工具（如 Git）来跟踪软件包的变更。
- 关闭请求转发：
  - 实例管理员可以在**管理**区域中禁用转发。更多信息，请参见[控制软件包转发](../../../administration/settings/continuous_integration.md#control-package-forwarding)。
  - 群组所有者可以在群组设置中关闭软件包转发。

要为群组关闭请求转发：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **软件包与镜像库**。
1. 在**软件包转发**下，清除以下任一复选框：
   - **转发 npm 软件包请求**
   - **转发 PyPI 软件包请求**
1. 选择**保存更改**。

| 软件包类型                                           | 支持请求转发 | 安全注意事项 |
|--------------------------------------------------------|-----------------------------|------------------------|
| [Maven（使用 `mvn`）](../maven_repository/_index.md)| [是（默认禁用）](../../../administration/settings/continuous_integration.md#control-package-forwarding)| 出于安全考虑，需要明确选择启用。 |
| [Maven（使用 `gradle`）](../maven_repository/_index.md)| [是（默认禁用）](../../../administration/settings/continuous_integration.md#control-package-forwarding)| 出于安全考虑，需要明确选择启用。 |
| [Maven（使用 `sbt`）](../maven_repository/_index.md)| [是（默认禁用）](../../../administration/settings/continuous_integration.md#control-package-forwarding)| 出于安全考虑，需要明确选择启用。 |
| [npm](../npm_registry/_index.md)                       | [是](../../../administration/settings/continuous_integration.md#control-package-forwarding) | 对于私有软件包，请考虑禁用。 |
| [PyPI](../pypi_repository/_index.md)                   | [是](../../../administration/settings/continuous_integration.md#control-package-forwarding) | 对于私有软件包，请考虑禁用。 |
| [NuGet](../nuget_repository/_index.md)                 | 否                           | 无 |
| [通用软件包](../generic_packages/_index.md)      | 否                           | 无 |
| [Terraform](../terraform_module_registry/_index.md)    | 否                           | 无 |
| [Composer](../composer_repository/_index.md)           | 否                           | 无 |
| [Conan 1](../conan_1_repository/_index.md)               | 否                           | 无 |
| [Conan 2](../conan_2_repository/_index.md)               | 否                           | 无 |
| [Helm](../helm_repository/_index.md)                   | 否                           | 无 |
| [Debian](../debian_repository/_index.md)               | 否                           | 无 |
| [Go](../go_proxy/_index.md)                            | 否                           | 无 |
| [Ruby gems](../rubygems_registry/_index.md)            | 否                           | 无 |

<a id="deleting-packages"></a>

## 删除软件包

当软件包请求被转发到公共仓库时，删除软件包可能导致[依赖混淆漏洞](https://medium.com/@alex.birsan/dependency-confusion-4a5d60fec610)。

如果系统尝试拉取已删除的软件包，该请求会转发到公共仓库。如果公共仓库中存在同名同版本的软件包，则会改为拉取该软件包。从该仓库拉取的软件包可能并非您所期望的，并且可能是恶意的。

为降低相关的安全风险，在删除软件包之前：

- 确认该软件包未被积极使用。
- [禁用请求转发](#forwarding-requests)。

要删除软件包，您可以：

- [在 UI 中删除软件包](reduce_package_registry_storage.md#delete-a-package)。
- [使用 API 删除软件包](../../../api/packages.md#delete-a-project-package)。

<a id="importing-packages-from-other-repositories"></a>

## 从其他仓库导入软件包

您可以使用极狐GitLab 流水线，通过[软件包导入工具](https://gitlab.com/gitlab-org/ci-cd/package-stage/pkgs_importer)从其他仓库（如 Maven Central 或 Artifactory）导入软件包。

| 软件包类型                                           | 是否有导入工具？ |
|--------------------------------------------------------|---------------------|
| [Maven（使用 `mvn`）](../maven_repository/_index.md)| 是                  |
| [Maven（使用 `gradle`）](../maven_repository/_index.md)| 是                  |
| [Maven（使用 `sbt`）](../maven_repository/_index.md)| 是                  |
| [npm](../npm_registry/_index.md)                       | 是                  |
| [NuGet](../nuget_repository/_index.md)                 | 是                  |
| [PyPI](../pypi_repository/_index.md)                   | 是                  |
| [通用软件包](../generic_packages/_index.md)      | 否                   |
| [Terraform](../terraform_module_registry/_index.md)    | 否                   |
| [Composer](../composer_repository/_index.md)           | 否                   |
| [Conan 1](../conan_1_repository/_index.md)             | 否                   |
| [Conan 2](../conan_2_repository/_index.md)             | 否                   |
| [Helm](../helm_repository/_index.md)                   | 否                   |
| [Debian](../debian_repository/_index.md)               | 否                   |
| [Go](../go_proxy/_index.md)                            | 否                   |
| [Ruby gems](../rubygems_registry/_index.md)            | 否                   |

<a id="allow-or-prevent-duplicates"></a>

## 允许或阻止重复项

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

默认情况下，极狐GitLab 软件包仓库会根据该特定软件包管理器格式的默认值来允许或阻止重复项。

| 软件包类型                                           | 是否允许重复项？ |
|--------------------------------------------------------|---------------------|
| [Maven（使用 `mvn`）](../maven_repository/_index.md)| 是（可配置）   |
| [Maven（使用 `gradle`）](../maven_repository/_index.md)| 是（可配置）   |
| [Maven（使用 `sbt`）](../maven_repository/_index.md)| 是（可配置）   |
| [npm](../npm_registry/_index.md)                       | 否                   |
| [NuGet](../nuget_repository/_index.md)                 | 是                  |
| [PyPI](../pypi_repository/_index.md)                   | 否                   |
| [通用软件包](../generic_packages/_index.md)      | 是（可配置）   |
| [Terraform](../terraform_module_registry/_index.md)    | 否                   |
| [Composer](../composer_repository/_index.md)           | 否                   |
| [Conan 1](../conan_1_repository/_index.md)             | 否                   |
| [Conan 2](../conan_2_repository/_index.md)             | 否                   |
| [Helm](../helm_repository/_index.md)                   | 是                  |
| [Debian](../debian_repository/_index.md)               | 是                  |
| [Go](../go_proxy/_index.md)                            | 否                   |
| [Ruby gems](../rubygems_registry/_index.md)            | 是                  |

<a id="authenticate-with-the-registry"></a>

## 向仓库进行身份验证

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

身份验证取决于您使用的软件包管理器。要了解特定软件包类型支持哪些身份验证协议，请参见[身份验证协议](#authentication-protocols)。

对于大多数软件包类型，以下身份验证令牌有效：

- [个人访问令牌](../../profile/personal_access_tokens.md)
- [项目部署令牌](../../project/deploy_tokens/_index.md)
- [群组部署令牌](../../project/deploy_tokens/_index.md)
- [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)

下表列出了给定软件包管理器支持哪些身份验证令牌：

| 软件包类型                                           | 支持的令牌                                                       |
|--------------------------------------------------------|------------------------------------------------------------------------|
| [Maven（使用 `mvn`）](../maven_repository/_index.md)| 个人访问令牌、作业令牌、部署令牌（项目或群组）、项目访问令牌 |
| [Maven（使用 `gradle`）](../maven_repository/_index.md)| 个人访问令牌、作业令牌、部署令牌（项目或群组）、项目访问令牌 |
| [Maven（使用 `sbt`）](../maven_repository/_index.md)| 个人访问令牌、作业令牌、部署令牌（项目或群组）、项目访问令牌 |
| [npm](../npm_registry/_index.md)                       | 个人访问令牌、作业令牌、部署令牌（项目或群组）、项目访问令牌 |
| [NuGet](../nuget_repository/_index.md)                 | 个人访问令牌、作业令牌、部署令牌（项目或群组）、项目访问令牌 |
| [PyPI](../pypi_repository/_index.md)                   | 个人访问令牌、作业令牌、部署令牌（项目或群组）、项目访问令牌 |
| [通用软件包](../generic_packages/_index.md)      | 个人访问令牌、作业令牌、部署令牌（项目或群组）、项目访问令牌 |
| [Terraform](../terraform_module_registry/_index.md)    | 个人访问令牌、作业令牌、部署令牌（项目或群组）、项目访问令牌 |
| [Composer](../composer_repository/_index.md)           | 个人访问令牌、作业令牌、部署令牌（项目或群组）、项目访问令牌 |
| [Conan 1](../conan_1_repository/_index.md)                 | 个人访问令牌、作业令牌、项目访问令牌                            |
| [Conan 2](../conan_2_repository/_index.md)                 | 个人访问令牌、作业令牌、项目访问令牌                            |
| [Helm](../helm_repository/_index.md)                   | 个人访问令牌、作业令牌、部署令牌（项目或群组）                 |
| [Debian](../debian_repository/_index.md)               | 个人访问令牌、作业令牌、部署令牌（项目或群组）                 |
| [Go](../go_proxy/_index.md)                            | 个人访问令牌、作业令牌、项目访问令牌                            |
| [Ruby gems](../rubygems_registry/_index.md)            | 个人访问令牌、作业令牌、部署令牌（项目或群组）                 |

> [!note]
> 当您为软件包仓库配置身份验证时：
>
> - 如果**软件包仓库**项目设置已[关闭](_index.md#turn-off-the-package-registry)，则在与软件包仓库交互时会收到 `403 Forbidden` 错误，即使您拥有所有者角色也是如此。
> - 如果已开启[外部授权](../../../administration/settings/external_authorization.md)，则无法使用部署令牌访问软件包仓库。
> - 如果您的组织使用双因素认证（2FA），则必须使用作用域设置为 `api`的个人访问令牌。
> - 如果您使用 CI/CD 流水线发布软件包，则必须使用 CI/CD 作业令牌。

<a id="authentication-protocols"></a>

### 身份验证协议

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

支持以下身份验证协议：

| 软件包类型                                           | 支持的身份验证协议                                    |
|--------------------------------------------------------|-------------------------------------------------------------|
| [Maven（使用 `mvn`）](../maven_repository/_index.md)| 请求头、基本身份验证、OAuth                                  |
| [Maven（使用 `gradle`）](../maven_repository/_index.md)| 请求头、基本身份验证、OAuth                                  |
| [Maven（使用 `sbt`）](../maven_repository/_index.md)| 基本身份验证（仅[拉取](#pulling-packages)）          |
| [npm](../npm_registry/_index.md)                       | OAuth                                                       |
| [NuGet](../nuget_repository/_index.md)                 | 基本身份验证                                                  |
| [PyPI](../pypi_repository/_index.md)                   | 基本身份验证                                                  |
| [通用软件包](../generic_packages/_index.md)      | 基本身份验证                                                  |
| [Terraform](../terraform_module_registry/_index.md)    | 令牌                                                       |
| [Composer](../composer_repository/_index.md)           | OAuth                                                       |
| [Conan 1](../conan_1_repository/_index.md)                 | OAuth、基本身份验证                                           |
| [Conan 2](../conan_2_repository/_index.md)                 | OAuth、基本身份验证                                           |
| [Helm](../helm_repository/_index.md)                   | 基本身份验证                                                  |
| [Debian](../debian_repository/_index.md)               | 基本身份验证                                                  |
| [Go](../go_proxy/_index.md)                            | 基本身份验证                                                  |
| [Ruby gems](../rubygems_registry/_index.md)            | 令牌                                                       |

<a id="supported-hash-types"></a>

## 支持的哈希类型

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

哈希值用于确保您使用的是正确的软件包。您可以在用户界面中或通过 [API](../../../api/packages.md) 查看这些值。

软件包仓库支持以下哈希类型：

| 软件包类型                                           | 支持的哈希                 |
|--------------------------------------------------------|----------------------------------|
| [Maven（使用 `mvn`）](../maven_repository/_index.md)| MD5、SHA1                        |
| [Maven（使用 `gradle`）](../maven_repository/_index.md)| MD5、SHA1                        |
| [Maven（使用 `sbt`）](../maven_repository/_index.md)| MD5、SHA1                        |
| [npm](../npm_registry/_index.md)                       | SHA1                             |
| [NuGet](../nuget_repository/_index.md)                 | 不适用                   |
| [PyPI](../pypi_repository/_index.md)                   | MD5、SHA256                      |
| [通用软件包](../generic_packages/_index.md)      | SHA256                           |
| [Composer](../composer_repository/_index.md)           | 不适用                   |
| [Conan 1](../conan_1_repository/_index.md)             | MD5、SHA1                        |
| [Conan 2](../conan_2_repository/_index.md)             | MD5、SHA1                        |
| [Helm](../helm_repository/_index.md)                   | 不适用                   |
| [Debian](../debian_repository/_index.md)               | MD5、SHA1、SHA256                |
| [Go](../go_proxy/_index.md)                            | MD5、SHA1、SHA256                |
| [Ruby gems](../rubygems_registry/_index.md)            | MD5、SHA1、SHA256（仅 gemspec） |
