---
stage: 极狐GitLab 交付
group: Build
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Linux 软件包中的软件包和镜像
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Below you can find some basic information on why 极狐GitLab provides packages and
a Docker image that come with bundled dependencies.

These methods are great for physical and virtual machine installations, and simple Docker installations.

<a id="goals"></a>

## Goals

We have a few core goals with these packages:

1. Extremely easy to install, upgrade, maintain.
1. Support for a wide variety of operating systems
1. Wide support of cloud service providers

<a id="linux-package-architecture"></a>

## Linux 软件包架构

极狐GitLab in its core is a Ruby on Rails project. However, 极狐GitLab as a whole
application is more complex and has multiple components. If these components are
not present or are incorrectly configured, 极狐GitLab does not work or it works
unpredictably.

The 极狐GitLab Architecture Overview in the 极狐GitLab development documentation shows some of these components and how they
interact. Each of these components needs to be configured and kept up to date.

Most of the components also have external dependencies. For example, the Rails
application depends on a number of [Ruby gems](https://gitlab.com/gitlab-org/gitlab-foss/blob/master/Gemfile.lock). Some of these dependencies also
have their own external dependencies which need to be present on the Operating
System in order for them to function correctly.

Furthermore, 极狐GitLab has a monthly release cycle requiring frequent maintenance
to stay up to date.

All the things listed previously present a challenge for the user maintaining the 极狐GitLab
installation.

<a id="external-software-dependencies"></a>

## 外部软件依赖

For applications such as 极狐GitLab, external dependencies usually bring the following
challenges:

- Keeping versions in sync between direct and indirect dependencies
- Availability of a version on a specific Operating System
- Version changes can introduce or remove previously used configuration
- Security implications when library is marked as vulnerable but does not have
  a new version released yet

Keep in mind that if a dependency exists on your Operating System, it does not
necessarily exist on other supported OSs.

<a id="benefits"></a>

## 优势

A few benefits of a package with bundled dependencies:

1. Minimal effort required to install 极狐GitLab.
1. Minimum configuration required to get 极狐GitLab up and running.
1. Minimum effort required to upgrade between 极狐GitLab versions.
1. Multiple platforms supported.
1. Maintenance on older platforms is greatly simplified.
1. Less effort to support potential issues.

<a id="drawbacks"></a>

## 缺点

Some drawbacks of a package with bundled dependencies:

1. Duplication with possibly existing software.
1. Less flexibility in configuration.

<a id="why-would-you-install-a-package-from-the-linux-package-when-you-can-use-a-system-package"></a>

## 为什么可以使用系统软件包时还要从 Linux 软件包安装？

The answer can be simplified to: less maintenance required. Instead of handling
multiple packages that can break existing functionality if the versions are
not compatible, only handle one.

Multiple packages require correct configuration in multiple locations.
Keeping configuration in sync can be error prone.

If you have the skill set to maintain all current dependencies and enough time
to handle any future dependencies that might get introduced, the previous
reasons might not be good enough for you to not use a package from the Linux package.

There are two things to keep in mind before going down this route:

1. Getting support for any problems
   you encounter might be more difficult due to the number of possibilities that exist
   when using a library version that is not tested by majority of users.
1. Packages from the Linux package also allow shutting off of any services that you do not need,
   if you need to run a component independently. For example, you can use a
   [non-bundled PostgreSQL database](https://gitlab.cn/docs/omnibus/settings/database/#using-a-non-packaged-postgresql-database-management-server)
   with a Linux package installation.

Keep in mind that a non-standard solution like the Linux package
might be a better fit when the application has a number of moving parts.

<a id="docker-image-with-multiple-services"></a>

## 包含多种服务的 Docker 镜像

[极狐GitLab Docker 镜像](../../install/docker/_index.md) 是基于 Linux 软件包的。

Considering that container spawned from this image contains multiple processes,
these types of containers are also referred to as 'fat containers'.

There are reasons for and against an image like this, but they are similar to
what was noted previously:

1. Very simple to get started.
1. Upgrading to the latest version is extremely simple.
1. Running separate services in multiple containers and keeping them running
   can be more complex and might not be required for a given install.

This method is useful for organizations just getting started with containers and schedulers, and may not be ready for a more complex installation. This method is a great introduction, and works well for smaller organizations.