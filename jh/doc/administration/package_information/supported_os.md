---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 支持的操作系统
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 官方支持长期支持 (LTS) 版本的操作系统。一些操作系统，如 Ubuntu，有明确的 LTS 和非 LTS 版本区别。然而，也有其他操作系统，例如 openSUSE，不遵循 LTS 概念。

为避免混淆，极狐GitLab 支持的所有操作系统都列在 [安装页面](https://gitlab.cn/install/)。

{{< alert type="note" >}}

`amd64` 和 `x86_64` 指代相同的 64 位架构。名称 `arm64` 和 `aarch64` 也可以互换，指代相同的架构。

{{< /alert >}}

<a id="almalinux"></a>

## AlmaLinux

AlmaLinux 支持以下版本。

| 操作系统 | 第一个支持的极狐GitLab 版本 |  CPU 架构        | 安装文档                                                          | 操作系统的 EOL | 详情 |
|:-----------------|:-------------------------------|:--------------------|:------------------------------------------------------------------------------------|:---------------------|:--------|
| AlmaLinux 8      | GitLab JH 14.5.0   | `x86_64`, `aarch64` | [AlmaLinux 安装文档](https://gitlab.cn/install/#almalinux) | 2029                 | [AlmaLinux 详情](https://almalinux.org/) |
| AlmaLinux 9      | GitLab JH 16.0.0   | `x86_64`, `aarch64` | [AlmaLinux 安装文档](https://gitlab.cn/install/#almalinux) | 2032                 | [AlmaLinux 详情](https://almalinux.org/) |

<a id="amazon-linux"></a>

## Amazon Linux

Amazon Linux 支持以下版本。

| 操作系统 | 第一个支持的极狐GitLab 版本 | CPU 架构 | 安装文档   | 操作系统的 EOL | 详情 |
|:------------------|:-------------------------------|:-----------------|:---------------------------------------------------------------------------------------------------|:---------------------|:--------|
| Amazon Linux 2023 | GitLab JH 17.6.1   | `amd64`, `arm64` | [Amazon Linux 2023 安装文档](https://gitlab.cn/install/#amazonlinux-2023) | 2028                 | [Amazon Linux 详情](https://docs.aws.amazon.com/linux/al2023/ug/release-cadence.html) |

<a id="centos-and-scientific-linux"></a>

## CentOS and Scientific Linux

CentOS 和 Scientific Linux 支持以下版本。

| 操作系统 | 第一个支持的极狐GitLab 版本 | CPU 架构 | 安装文档   | 操作系统的 EOL | 详情 |
|:-----------------|:-------------------------------|:-------------|:------------------------------------------------------------------------------------|:---------------------|:--------|
| CentOS 7         | GitLab CE / GitLab EE 7.10.0   | `x86_64`     | [CentOS 安装文档](https://gitlab.cn/install/#centos-7)     | June 2024            | [CentOS Linux 详情](https://www.centos.org/about/) |
| Scientific Linux | GitLab CE / GitLab EE 8.14.0   | `x86_64`     | [Use CentOS 安装文档](https://gitlab.cn/install/#centos-7) | June 2024            | [Scientific Linux 详情](https://scientificlinux.org/downloads/sl-versions/sl7/) |

<a id="debina"></a>

## Debian

Debian 支持以下版本。

| 操作系统 | 第一个支持的极狐GitLab 版本 | CPU 架构 | 安装文档   | 操作系统的 EOL | 详情 |
|:-----------------|:-------------------------------|:-----------------|:------------------------------------------------------------------------------|:---------------------|:--------|
| Debian 11        | GitLab JH 14.6.0   | `amd64`, `arm64` | [Debian 安装文档](https://gitlab.cn/install/#debian) | 2026                 | [Debian Linux 详情](https://wiki.debian.org/LTS) |
| Debian 12        | GitLab JH 16.1.0   | `amd64`, `arm64` | [Debian 安装文档](https://gitlab.cn/install/#debian) | TBD                  | [Debian Linux 详情](https://wiki.debian.org/LTS) |

<a id="ubuntu"></a>

## Ubuntu

Ubuntu支持以下版本。

| 操作系统 | 第一个支持的极狐GitLab 版本 | CPU 架构 | 安装文档   | 操作系统的 EOL | 详情 |
|:-----------------|:-------------------------------|:-----------------|:------------------------------------------------------------------------------|:---------------------|:--------|
| Ubuntu 20.04     | GitLab CE / GitLab EE 13.2.0   | `amd64`, `arm64` | [Ubuntu 安装文档](https://gitlab.cn/install/#ubuntu) | April 2025           | [Ubuntu details](https://wiki.ubuntu.com/Releases) |
| Ubuntu 22.04     | GitLab JH 15.5.0   | `amd64`, `arm64` | [Ubuntu 安装文档](https://gitlab.cn/install/#ubuntu) | April 2027           | [Ubuntu 详情](https://wiki.ubuntu.com/Releases) |
| Ubuntu 24.04     | GitLab JH 17.1.0   | `amd64`, `arm64` | [Ubuntu 安装文档](https://gitlab.cn/install/#ubuntu) | April 2029           | [Ubuntu 详情](https://wiki.ubuntu.com/Releases) |

## 支持的国产操作系统

极狐GitLab（GitLab JH）是专门为国内用户和企业提供服务的一体化 DevOps 平台，目前已经针对国内的操作系统 **OpenCloudOS、Alibaba Cloud Linux、Kylin、OpenEuler** 提供了支持。详细安装教程可以查看[极狐GitLab 官网安装指南](https://gitlab.cn/install/)。

## 升级操作系统后升级极狐GitLab 包源

升级操作系统后，您还需要在您的包管理器配置中升级极狐GitLab 软件包源 URL。

如果您的软件包管理器报告没有进一步的更新可用，但您知道更新存在，请重复[Linux 包安装指南](https://gitlab.cn/install/#content)中的说明来添加极狐GitLab 包源。将来的极狐GitLab 升级将根据您的升级操作系统进行获取。

## 同时升级极狐GitLab 和操作系统

如要同时升级操作系统和极狐GitLab：

1. 升级操作系统。
1. 检查是否需要[升级极狐GitLab 包源](#update-gitlab-package-sources-after-upgrading-the-os)。
1. [升级GitLab](../../update/index.md).

## 升级操作系统后，Postgres 索引可能损坏

作为操作系统升级的一部分，如果您的 `glibc` 版本发生变化，您必须按照[升级操作系统中的 PostgreSQL](../postgresql/upgrading_os.md) 来避免索引损坏。

## 针对 ARM64 的软件包

极狐GitLab 为一些支持的操作系统提供 arm64/aarch64 软件包。您可以在上面的表格中查看您的操作系统架构是否受支持。

<a id="os-versions-that-are-no-longer-supported"></a>

## 不再支持的操作系统版本

极狐GitLab 为操作系统提供对应的 Linux 软件包直到它们（指操作系统）达到 EOL 日期。在 EOF 日期后，极狐GitLab 就会停止发布官方软件包。弃用的操作系统版本和它们对应的最后一个极狐GitLab 版本如下：

| 操作系统版本       | End of life                                                                         | 支持的最后一个极狐GitLab 版本 |
|:-----------------|:------------------------------------------------------------------------------------|:------------------------------|
| CentOS 6         | 2020年11月                                      | GitLab JH 13.6 |
| CentOS 7         | 2024年6月                                          | GitLab JH 17.7 |
| CentOS 8         | 2021年12月                                      | GitLab JH 14.6 |
| Debian 7 Wheezy  | 2018年5月                               | GitLab JH 11.6 |
| Debian 8 Jessie  | 2020年6月                              | GitLab JH 13.3 |
| Debian 9 Stretch | 2022年6月     | GitLab JH 15.2 |
| Debian 10 Buster | 2024年6月                              | GitLab JH 17.5 |
| OpenSUSE 42.1    | 2017年5月             | GitLab JH 9.3 |
| OpenSUSE 42.2    | 2018年1月         | GitLab JH 10.4 |
| OpenSUSE 42.3    | 2019年7月            | GitLab JH 12.1 |
| OpenSUSE 13.2    | 2017年1月         | GitLab JH 9.1 |
| OpenSUSE 15.0    | 2019年12月        | GitLab JH 12.5 |
| OpenSUSE 15.1    | 2020年11月        | GitLab JH 13.12 |
| OpenSUSE 15.2    | 2021年12月        | GitLab JH 14.7 |
| OpenSUSE 15.3    | 2022年12月        | GitLab JH 15.10 |
| OpenSUSE 15.4    | 2023年12月        | GitLab JH 16.7 |
| Raspbian Wheezy  | 2015年5月  | GitLab JH 8.17 |
| Raspbian Jessie  | 2017年5月  | GitLab JH 11.7 |
| Raspbian Stretch | 2020年6月 | GitLab JH 13.3 |
| Ubuntu 12.04     | 2017年4月                           | GitLab JH 9.1 |
| Ubuntu 14.04     | 2019年4月                           | GitLab JH 11.10 |
| Ubuntu 16.04     | 2021年4月                           | GitLab JH 13.12 |
| Ubuntu 18.04     | 2023年6月                            | GitLab JH 16.11 |

NOTE:
此弃用策略会有例外，那就是当我们无法为操作系统的下一个版本提供软件包时。最常见的原因是我们的软件包存储库提供商 PackageCloud 不支持新版本，因此我们无法将软件包进行上传。

## 极狐GitLab 专业技术支持

如果您在升级过程中遇到任何问题，欢迎您在[极狐GitLab 官方论坛寻求答案](https://forum.gitlab.cn/)，您可可以查阅文章开头的 [GitLab 专业升级服务](https://gitlab.cn/resources/articles/7e9d346f0af645bcae17691a50491d33)详情来获取专业帮助。

当然，也欢迎您通过扫描下方二维码来直接咨询专业技术人员：

![upgrade-service](./img/upgrade-service.png)