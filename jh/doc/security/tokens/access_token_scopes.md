---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 访问令牌作用域
description: 个人、群组和项目访问令牌的每个作用域所授予的权限。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

作用域定义了访问令牌在特定组织级别可以执行的操作。每个作用域授予一组特定的权限。

令牌类型决定了令牌的访问范围：

- 个人访问令牌可以访问该用户可用的所有群组和项目。
- 群组访问令牌可以访问其群组中的子群组和项目。
- 项目访问令牌只能访问其所属项目。

要将个人访问令牌限制为特定的资源和权限，请参阅
[细粒度个人访问令牌](../../auth/tokens/fine_grained_access_tokens.md)。

| 作用域 | 令牌可用性 | 描述 |
|-------|------------|-------------|
| `api` | 个人、群组、项目 | 授予对令牌作用域内 API 的完整读写访问权限。包括[容器镜像仓库](../../user/packages/container_registry/_index.md)、[依赖代理](../../user/packages/dependency_proxy/_index.md)和[软件包仓库](../../user/packages/package_registry/_index.md)。 <sup>1</sup> |
| `read_api` | 个人、群组、项目 | 授予对令牌作用域内 API 的读取访问权限。对于个人访问令牌，包括容器镜像仓库和软件包仓库；对于群组和项目访问令牌，仅包括软件包仓库。 |
| `read_repository` | 个人、群组、项目 | 授予对令牌作用域内代码仓库的读取访问权限（拉取）：对于个人访问令牌，为私有项目；对于群组访问令牌，为群组中的所有代码仓库；对于项目访问令牌，为项目中的代码仓库。使用基于 HTTP 的 Git 或[代码仓库文件 API](../../api/repository_files.md)。 |
| `write_repository` | 个人、群组、项目 | 授予对令牌作用域内代码仓库的读写访问权限（拉取和推送）：对于个人访问令牌，为私有项目；对于群组访问令牌，为群组中的所有代码仓库；对于项目访问令牌，为项目中的代码仓库。使用基于 HTTP 的 Git。不支持 API 身份验证。 |
| `read_registry` | 个人、群组、项目 | 在需要授权时，授予对[容器镜像仓库](../../user/packages/container_registry/_index.md)镜像的读取访问权限（拉取）。仅在启用容器镜像仓库时可用。隐私条件因令牌类型而异：对于个人访问令牌，适用于项目为私有时；对于群组访问令牌，适用于群组中任一项目为私有；对于项目访问令牌，适用于项目为私有。 |
| `write_registry` | 个人、群组、项目 | 授予对[容器镜像仓库](../../user/packages/container_registry/_index.md)镜像的写入访问权限（推送）。仅在启用容器镜像仓库时可用。对于群组和项目访问令牌，您还必须包含 `read_registry` 作用域才能推送镜像。 |
| `self_rotate` | 个人、群组、项目 | 授予轮换此令牌的权限。不能轮换其他令牌。要轮换个人访问令牌，请参阅[个人访问令牌 API](../../api/personal_access_tokens.md#rotate-a-personal-access-token)。 |
| `read_virtual_registry` | 个人、群组 | 授予通过[依赖代理](../../user/packages/dependency_proxy/_index.md)读取容器镜像的访问权限（拉取）。仅在启用依赖代理时可用。 <sup>2</sup> |
| `write_virtual_registry` | 个人、群组 | 授予通过[依赖代理](../../user/packages/dependency_proxy/_index.md)读写容器镜像的访问权限（拉取、推送和删除）。仅在启用依赖代理时可用。 <sup>2</sup> |
| `create_runner` | 个人、群组、项目 | 授予在令牌作用域内创建 Runner 的权限。 |
| `manage_runner` | 个人、群组、项目 | 授予在令牌作用域内管理 Runner 的权限。 |
| `ai_features` | 个人、群组、项目 | 授予为极狐GitLab Duo、代码建议 API 和极狐GitLab Duo Chat API 执行 API 操作的权限。设计用于与 JetBrains 的极狐GitLab Duo 插件配合使用。对于所有其他扩展，请参阅各个扩展的文档。不适用于极狐GitLab 私有化部署 16.5、16.6 和 16.7 版本。在极狐GitLab 私有化部署上，此作用域仅在启用极狐GitLab Duo 时可用。 |
| `k8s_proxy` | 个人、群组、项目 | 授予通过 Kubernetes 的 Agent 执行 Kubernetes API 调用的权限。 |
| `admin_mode` | 个人 | 在启用[管理员模式](../../administration/settings/sign_in_restrictions.md#admin-mode)时，授予执行 API 操作的权限。仅适用于极狐GitLab 私有化部署实例上的管理员。 |
| `read_service_ping` | 个人 | 授予以管理员身份通过 API 下载 Service Ping 负载的权限。 |
| `sudo` | 个人 | 授予以管理员身份以系统中任何用户身份执行 API 操作的权限。 |
| `read_user` | 个人 | 授予通过 `/user` API 端点对已认证用户个人资料的只读访问权限，包括用户名、公共电子邮件和全名。还授予对 [`/users`](../../api/users.md) 下只读 API 端点的访问权限。 |

> [!warning]
> 如果您已开启[外部授权](../../administration/settings/external_authorization.md)，
> 个人和项目访问令牌将无法访问容器或软件包仓库。要恢复
> 访问权限，请关闭外部授权。

**脚注**：

1. 对于个人访问令牌，`api` 还授予通过基于 HTTP 的 Git 对仓库和代码仓库的完整读写访问权限。群组和项目访问令牌不包含此基于 HTTP 的 Git 条款。
1. 对于个人访问令牌，虚拟仓库作用域仅在项目为私有且需要授权时适用。群组访问令牌不附带此类条件。
