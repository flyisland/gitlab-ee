---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Rails 控制台速查表
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

这是极狐GitLab 支持团队收集的有关极狐GitLab Rails 控制台的信息，用于故障排除。此处列出以作备忘，因为大部分内容已移至特定功能的故障排除页面和章节，参见史诗 [&8147](https://gitlab.com/groups/gitlab-org/-/epics/8147#tree)。你可能需要相应地更新书签。

> [!warning]
> 如果未正确运行或在适当条件下运行，其中一些脚本可能会造成损害。我们强烈建议在支持工程师的指导下运行它们，或者在测试环境中运行，并准备好对实例进行备份以便恢复，以防万一。

如果你当前遇到极狐GitLab 的问题，强烈建议你先查阅我们关于 [Rails 控制台](../operations/rails_console.md) 的指南，以及你的 [支持选项](https://about.gitlab.com/support/)，然后再尝试此处指向的信息。

> [!warning]
> 随着极狐GitLab 的更改，代码变更不可避免，因此一些脚本可能不像以前那样有效。这些脚本/命令是在发现或需要时添加的，因此未保持更新。如前所述，我们建议在支持工程师的监督下运行这些脚本，他们也可以验证这些脚本是否仍按预期工作，并在需要时针对最新版本的极狐GitLab 更新脚本。

## 镜像

### 查找具有 `bad decrypt` 错误的镜像

此内容已转换为 Rake 任务，请参阅 [验证可以使用当前密钥解密数据库值](../raketasks/check.md#verify-database-values-can-be-decrypted-using-the-current-secrets)。

### 将镜像用户和令牌转移至单一服务账户

此内容已移至 [仓库镜像故障排除](../../user/project/repository/mirror/troubleshooting.md#transfer-mirror-users-and-tokens-to-a-single-service-account)。

## 合并请求

## CI

此内容已移至 [CI/CD 维护](../cicd/maintenance.md)。

## 许可证

此内容已移至 [使用许可证文件或密钥激活极狐GitLab EE](../license_file.md)。

## 镜像仓库

### 按项目划分的镜像仓库磁盘空间用量

要查看容器镜像仓库中按项目划分的存储空间，请参阅 [按项目划分的镜像仓库磁盘空间用量](../packages/container_registry.md#registry-disk-space-usage-by-project)。

### 运行清理策略

要减少容器镜像仓库的存储空间，请参阅 [运行清理策略](../packages/container_registry.md#run-the-cleanup-policy)。

## Sidekiq

此内容已移至 [Sidekiq 故障排除](../sidekiq/sidekiq_troubleshooting.md)。

## Geo

### 重新验证所有上传（或任何已验证的 SSF 数据类型）

已移至 [Geo 复制故障排除](../geo/replication/troubleshooting/synchronization_verification.md#resync-and-reverify-multiple-components)。

### 产物

已移至 [Geo 复制故障排除](../geo/replication/troubleshooting/synchronization_verification.md#manually-retry-replication-or-verification)。

### 仓库验证失败

已移至 [Geo 复制故障排除](../geo/replication/troubleshooting/synchronization_verification.md#manually-retry-replication-or-verification)。

### 重新同步仓库

已移至 [Geo 复制故障排除 - 重新同步仓库类型](../geo/replication/troubleshooting/synchronization_verification.md#manually-retry-replication-or-verification)。

已移至 [Geo 复制故障排除 - 重新同步项目和项目 Wiki 仓库](../geo/replication/troubleshooting/synchronization_verification.md#manually-retry-replication-or-verification)。

### Blob 类型

已移至 [Geo 复制故障排除](../geo/replication/troubleshooting/synchronization_verification.md#manually-retry-replication-or-verification)。

## 生成服务 Ping

此内容已移至极狐GitLab 开发文档中的服务 Ping 故障排除。