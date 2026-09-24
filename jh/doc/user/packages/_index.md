---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包与镜像仓库
description: 软件包管理、容器镜像仓库、产物存储和依赖项管理。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab [软件包仓库](package_registry/_index.md)可作为多种常用包管理器的私有或公共仓库。你可以发布和分享软件包，这些软件包可作为依赖项在下游项目中使用。

<a id="container-registry"></a>

## 容器镜像仓库

极狐GitLab [容器镜像仓库](container_registry/_index.md)是一个安全且私有的容器镜像仓库。它基于开源软件构建，并完全集成在极狐GitLab 中。使用极狐GitLab CI/CD 创建和发布镜像。使用极狐GitLab [API](../../api/container_registry.md) 跨群组和项目管理仓库。

<a id="terraform-module-registry"></a>

## Terraform 模块仓库

极狐GitLab [Terraform 模块仓库](terraform_module_registry/_index.md)是一个安全且私有的 Terraform 模块仓库。你可以使用极狐GitLab CI/CD 创建和发布模块。

<a id="virtual-registry"></a>

## 虚拟仓库

极狐GitLab [虚拟仓库](virtual_registry/_index.md)提供高级缓存、代理和分发功能，以改进对极狐GitLab 中外部仓库的软件包管理。

<a id="dependency-proxy"></a>

## 依赖代理

[依赖代理](dependency_proxy/_index.md)是常用上游镜像和软件包的本地代理。