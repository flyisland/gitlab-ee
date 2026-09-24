---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 支持的软件包管理器
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

{{< alert type="warning" >}}

并不是所有的软件包管理器格式都能用于生产。

{{< /alert >}}

<a id="the-package-registry-supports-the-following-package-manager-types"></a>

软件包仓库支持以下软件包管理器类型：

| 软件包类型                                       | 状态 |
|---------------------------------------------------|--------|
| [Composer](../composer_repository/_index.md)      | Beta |
| [Conan](../conan_repository/_index.md)            | 实验 |
| [Debian](../debian_repository/_index.md)          | 实验 |
| [Generic packages](../generic_packages/_index.md) | GA     |
| [Go](../go_proxy/_index.md)                       | 实验 |
| [Helm](../helm_repository/_index.md)              | Beta |
| [Maven](../maven_repository/_index.md)            | GA      |
| [npm](../npm_registry/_index.md)                  | GA      |
| [NuGet](../nuget_repository/_index.md)            | GA      |
| [PyPI](../pypi_repository/_index.md)              | GA      |
| [Ruby gems](../rubygems_registry/_index.md)       | 实验 |

[查看每种状态的含义](../../../policy/development_stages_support.md)。

您还可以使用 [API](../../../api/packages.md) 来管理软件包仓库。
