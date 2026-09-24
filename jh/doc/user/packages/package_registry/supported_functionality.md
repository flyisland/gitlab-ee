---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 支持的软件包管理器及功能
---

极狐GitLab 软件包仓库为每种软件包类型提供了不同的功能支持，包括发布和拉取软件包、请求转发、管理重复包以及认证。

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
| [Composer](../composer_repository/_index.md)      | [测试版](https://jihulab.com/gitlab-cn/groups/gitlab-org/-/epics/6817) |
| [Conan 1](../conan_1_repository/_index.md)            | [测试版](https://jihulab.com/gitlab-cn/groups/gitlab-org/-/epics/6816) |
| [Conan 2](../conan_2_repository/_index.md)            | [测试版](https://jihulab.com/gitlab-cn/groups/gitlab-org/-/epics/8258) |
| [Debian](../debian_repository/_index.md)          | [实验性](https://jihulab.com/gitlab-cn/groups/gitlab-org/-/epics/6057) |
| [通用软件包](../generic_packages/_index.md) | GA     |
| [Go](../go_proxy/_index.md)                       | [实验性](https://jihulab.com/gitlab-cn/groups/gitlab-org/-/epics/3043) |
| [Helm](../helm_repository/_index.md)              | GA      |
| [Maven](../maven_repository/_index.md)            | GA      |
| [npm](../npm_registry/_index.md)                  | GA      |
| [NuGet](../nuget_repository/_index.md)            | GA      |
| [PyPI](../pypi_repository/_index.md)              | GA      |
| [Ruby gems](../rubygems_registry/_index.md)       | [实验性](https://jihulab.com/gitlab-cn/groups/gitlab-org/-/epics/3200) |

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
| [Maven (使用 `mvn`)](../maven_repository/_index.md)    | 是       | 否     | 否        |
| [Maven (使用 `gradle`)](../maven_repository/_index.md) | 是       | 否     | 否        |
| [Maven (使用 `sbt`)](../maven_repository/_index.md)    | 否        | 否     | 否        |
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

可以从您的项目、群组或实例拉取软件包。

| 软件包类型                                           | 项目 | 群组 | 实例 |
|--------------------------------------------------------|---------|-------|----------|
| [Maven (使用 `mvn`)](../maven_repository/_index.md)    | 是       | 是     | 是       |
| [Maven (使用 `gradle`)](../maven_repository/_index.md) | 是       | 是     | 是       |
| [Maven (使用 `sbt`)](../maven_repository/_index.md)    | 是       | 是     | 是       |
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

- 在 JihuLab.com 上：您必须是群组的所有者。
- 在私有化部署实例上：您必须是管理员。

当在项目软件包仓库中找不到软件包时，请求会被转发到软件包管理器对应的公共仓库。

默认转发行为因软件包类型而异，并可能引入[依赖混淆漏洞](https://medium.com/@alex.birsan/dependency-confusion-4a5d60fec610)。下表显示了哪些软件包管理器支持软件包转发。

为降低相关安全风险：

- 确认软件包未被积极使用。
- 实施版本控制工具（如 Git）来跟踪软件包更改。
- 关闭请求转发：
  - 实例管理员可以在 **管理员** 区域禁用转发。更多信息，请参见[控制软件包转发](../../../administration/settings/continuous_integration.md#control-package-forwarding)。
  - 群组所有者可以在群组设置中关闭软件包转发。

要为群组关闭请求转发：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **软件包与镜像仓库**。
1. 在 **软件包转发** 下，清除以下任一复选框：
   - **转发 npm 软件包请求**
   - **转发 PyPI 软件包请求**
1. 选择 **保存更改**。

| 软件包类型                                           | 支持请求转发 | 安全注意事项 |
|--------------------------------------------------------|-----------------------------|------------------------|
| [Maven (使用 `mvn`)](../maven_repository/_index.md)    | [是（默认禁用）](../../../administration/settings/continuous_integration.md#control-package-forwarding) | 需要显式选择加入以确保安全。 |
| [Maven (使用 `gradle`)](../maven_repository/_index.md) | [是（默认禁用）](../../../administration/settings/continuous_integration.md#control-package-forwarding) | 需要显式选择加入以确保安全。 |
| [Maven (使用 `sbt`)](../maven_repository/_index.md)    | [是（默认禁用）](../../../administration/settings/continuous_integration.md#control-package-forwarding) | 需要显式选择加入以确保安全。 |
| [npm](../npm_registry/_index.md)                       | [是](../../../administration/settings/continuous_integration.md#control-package-forwarding) | 考虑为私有软件包禁用。 |
| [PyPI](../pypi_repository/_index.md)                   | [是](../../../administration/settings/continuous_integration.md#control-package-forwarding) | 考虑为私有软件包禁用。 |
| [NuGet](../nuget_repository/_index.md)                 | 否                           | 否 |
| [通用软件包](../generic_packages/_index.md)      | 否                           | 否 |
| [Terraform](../terraform_module_registry/_index.md)    | 否                           | 否 |
| [Composer](../composer_repository/_index.md)           | 否                           | 否 |
| [Conan 1](../conan_1_repository/_index.md)               | 否                           | 否 |
| [Conan 2](../conan_2_repository/_index.md)               | 否                           | 否 |
| [Helm](../helm_repository/_index.md)                   | 否                           | 否 |
| [Debian](../debian_repository/_index.md)               | 否                           | 否 |
| [Go](../go_proxy/_index.md)                            | 否                           | 否 |
| [Ruby gems](../rubygems_registry/_index.md)            | 否                           | 否 |

<a id="deleting-packages"></a>

## 删除软件包

当软件包请求被转发到公共仓库时，删除软件包可能导致[依赖混淆漏洞](https://medium.com/@alex.birsan/dependency-confusion-4a5d60fec610)。

如果系统尝试拉取已删除的软件包，请求会转发到公共仓库。如果公共仓库中存在同名同版本的软件包，则会拉取该软件包。从仓库拉取的软件包可能并非您所期望的，甚至可能是恶意的。

为降低相关安全风险，在删除软件包之前：

- 确认软件包未被积极使用。
- [禁用请求转发](#forwarding-requests)。

要删除软件包，您可以：

- [在 UI 中删除软件包](reduce_package_registry_storage.md#delete-a-package)。
- [使用 API 删除软件包](../../../api/packages.md#delete-a-project-package)。

<a id="importing-packages-from-other-repositories"></a>

## 从其他仓库导入软件包

您可以使用极狐GitLab 流水线从其他仓库（如 Maven Central 或 Artifactory）导入软件包，使用[软件包导入工具](https://jihulab.com/gitlab-cn/ci-cd/package-stage/pkgs_importer)。

| 软件包类型                                           | 导入器可用？ |
|--------------------------------------------------------|---------------------|
| [Maven (使用 `mvn`)](../maven_repository/_index.md)    | 是                  |
| [Maven (使用 `gradle`)](../maven_repository/_index.md) | 是                  |
| [Maven (使用 `sbt`)](../maven_repository/_index.md)    | 是                  |
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

## 允许或阻止重复

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

默认情况下，极狐GitLab 软件包仓库会根据特定软件包管理器格式的默认设置来允许或阻止重复。

| 软件包类型                                           | 允许重复？ |
|--------------------------------------------------------|---------------------|
| [Maven (使用 `mvn`)](../maven_repository/_index.md)    | 是（可配置）   |
| [Maven (使用 `gradle`)](../maven_repository/_index.md) | 是（可配置）   |
| [Maven (使用 `sbt`)](../maven_repository/_index.md)    | 是（可配置）   |
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

## 向仓库认证

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

认证方式取决于您使用的软件包管理器。要了解特定软件包类型支持的认证协议，请参见[认证协议](#authentication-protocols)。

对于大多数软件包类型，以下认证令牌是有效的：

- [个人访问令牌](../../profile/personal_access_tokens.md)
- [项目部署令牌](../../project/deploy_tokens/_index.md)
- [群组部署令牌](../../project/deploy_tokens/_index.md)
- [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)

下表列出了给定软件包管理器支持的认证令牌：

| 软件包类型                                           | 支持的令牌                                                       |
|--------------------------------------------------------|------------------------------------------------------------------------|
| [Maven (使用 `mvn`)](../maven_repository/_index.md)    | 个人访问令牌、作业令牌、部署令牌（项目或群组）、项目访问令牌 |
| [Maven (使用 `gradle`)](../maven_repository/_index.md) | 个人访问令牌、作业令牌、部署令牌（项目或群组）、项目访问令牌 |
| [Maven (使用 `sbt`)](../maven_repository/_index.md)    | 个人访问令牌、作业令牌、部署令牌（项目或群组）、项目访问令牌 |
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
> 配置软件包仓库认证时：
>
> - 如果项目的 **软件包仓库** 设置被[关闭](_index.md#turn-off-the-package-registry)，即使您具有所有者角色，与软件包仓库交互时也会收到 `403 Forbidden` 错误。
> - 如果[外部授权](../../../administration/settings/external_authorization.md)开启，则无法使用部署令牌访问软件包仓库。
> - 如果您的组织使用双因素认证 (2FA)，则必须使用范围设置为 `api` 的个人访问令牌。
> - 如果您通过 CI/CD 流水线发布软件包，则必须使用 CI/CD 作业令牌。

<a id="authentication-protocols"></a>

### 认证协议

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.0 中为 Maven 软件包引入了基本认证。

{{< /history >}}

支持以下认证协议：

| 软件包类型                                           | 支持的认证协议                                    |
|--------------------------------------------------------|-------------------------------------------------------------|
| [Maven (使用 `mvn`)](../maven_repository/_index.md)    | 标头、基本认证、OAuth                                  |
| [Maven (使用 `gradle`)](../maven_repository/_index.md) | 标头、基本认证、OAuth                                  |
| [Maven (使用 `sbt`)](../maven_repository/_index.md)    | 基本认证（仅[拉取](#pulling-packages)）          |
| [npm](../npm_registry/_index.md)                       | OAuth                                                       |
| [NuGet](../nuget_repository/_index.md)                 | 基本认证                                                  |
| [PyPI](../pypi_repository/_index.md)                   | 基本认证                                                  |
| [通用软件包](../generic_packages/_index.md)      | 基本认证                                                  |
| [Terraform](../terraform_module_registry/_index.md)    | 令牌                                                       |
| [Composer](../composer_repository/_index.md)           | OAuth                                                       |
| [Conan 1](../conan_1_repository/_index.md)                 | OAuth、基本认证                                           |
| [Conan 2](../conan_2_repository/_index.md)                 | OAuth、基本认证                                           |
| [Helm](../helm_repository/_index.md)                   | 基本认证                                                  |
| [Debian](../debian_repository/_index.md)               | 基本认证                                                  |
| [Go](../go_proxy/_index.md)                            | 基本认证                                                  |
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
| [Maven (使用 `mvn`)](../maven_repository/_index.md)    | MD5、SHA1                        |
| [Maven (使用 `gradle`)](../maven_repository/_index.md) | MD5、SHA1                        |
| [Maven (使用 `sbt`)](../maven_repository/_index.md)    | MD5、SHA1                        |
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
