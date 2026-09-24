---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安全与合规设置
description: 配置安全与合规管理设置，包括要同步哪些软件包仓库。
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

## 依赖项扫描

<a id="dependency-scanning"></a>

### SBOM 扫描 API 限制

<a id="sbom-scan-api-limits"></a>

[使用 SBOM 功能的依赖项扫描](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md) 使用内部 API，并具有[预定义的限制](../instance_limits.md#dependency-scanning-using-sbom-limits)。

先决条件：

- 管理员权限。

要为这些限制配置不同的值：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **安全与合规**。
1. 展开 **依赖项扫描**。
1. 更改任何速率限制的值，或将速率限制设置为 `0` 以禁用它。
1. 选择 **保存更改**。

## 软件包元数据数据库同步

<a id="package-metadata-database-synchronization"></a>

### 选择要同步的软件包仓库元数据

<a id="choose-package-registry-metadata-to-sync"></a>

要选择要与极狐GitLab 软件包元数据数据库 (PMDB) 同步的软件包，以用于[许可证合规](../../user/compliance/license_scanning_of_cyclonedx_files/_index.md)和[持续漏洞扫描](../../user/application_security/continuous_vulnerability_scanning/_index.md)：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **安全与合规**。
1. 展开 **许可证合规**。
1. 在 **要同步的软件包仓库元数据** 中，选中或清除要同步的软件包仓库的复选框。
1. 选择 **保存更改**。

为了使此数据同步正常工作，您必须允许从极狐GitLab 实例到域 `storage.googleapis.com` 的出站网络流量。另请参阅[启用软件包元数据数据库](../../topics/offline/quick_start_guide.md#enabling-the-package-metadata-database)中描述的离线设置说明。

### 安全注意事项

<a id="security-considerations"></a>

PMDB 是一项服务，它将许可证和公告数据发布到可公开访问（只读）的 Google Cloud Storage 存储桶中。任何人都可以读取这些存储桶，但只有经过授权的极狐GitLab 维护者才能通过 IAM 控制进行写入访问。极狐GitLab 持续从安全的 PostgreSQL 数据库摄取数据，并通过使用 OIDC 身份验证的私有服务将其导出。极狐GitLab 实例从公共存储桶同步数据，执行模式验证，然后将经过验证的数据更新插入到极狐GitLab 数据库中。