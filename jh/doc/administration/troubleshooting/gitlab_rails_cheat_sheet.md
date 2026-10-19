---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GitLab Rails 控制台速查表
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

这是极狐GitLab 支持团队收集的关于 GitLab Rails 控制台的信息，供故障排除时使用。此处列出仅供存档，因为大部分内容已移至特定功能的故障排除页面和章节，请参见史诗 [&8147](https://gitlab.com/groups/gitlab-org/-/work_items/8147)。您可能需要相应地更新您的书签。

> [!warning]
> 如果未正确运行，或在不当的条件下运行，其中一些脚本可能会造成破坏。
> 强烈建议您在支持工程师的指导下运行它们，或在测试环境中运行它们，
> 并准备好可恢复的实例备份，以防万一。

如果您当前在使用极狐GitLab 时遇到问题，强烈建议您先查看我们关于 [Rails 控制台](../operations/rails_console.md)的指南，以及您的[支持选项](https://gitlab.cn/support)，然后再尝试此处指向的信息。

> [!warning]
> 随着极狐GitLab 的变化，代码的变更不可避免，
> 因此一些脚本可能不再像以前那样工作。这些脚本/命令是在发现/需要时添加的，
> 因此并未保持最新。如前所述，我们建议在支持工程师的监督下运行这些脚本，
> 他们还可以验证这些脚本是否继续按预期工作，并在需要时
> 为最新版本的极狐GitLab 更新脚本。

<a id="mirrors"></a>

## 镜像

<a id="find-mirrors-with-bad-decrypt-errors"></a>

### 查找出现 `bad decrypt` 错误的镜像

此内容已转换为 Rake 任务，请参见[验证数据库值可以使用当前密钥解密](../raketasks/check.md#verify-database-values-can-be-decrypted-using-the-current-secrets)。

<a id="transfer-mirror-users-and-tokens-to-a-single-service-account"></a>

### 将镜像用户和令牌转移至单个服务账号

此内容已移至[仓库镜像故障排除](../../user/project/repository/mirror/troubleshooting.md#transfer-mirror-users-and-tokens-to-a-single-service-account)。

<a id="ci"></a>

## CI

此内容已移至 [CI/CD 维护](../cicd/maintenance.md)。

<a id="license"></a>

## 许可证

此内容已移至[使用许可证文件或密钥激活极狐GitLab 企业版](../license_file.md)。

<a id="registry"></a>

## 镜像仓库

<a id="registry-disk-space-usage-by-project"></a>

### 按项目统计的镜像仓库磁盘空间使用情况

要查看容器镜像仓库中按项目统计的存储空间，请参见[按项目统计的镜像仓库磁盘空间使用情况](../packages/container_registry.md#registry-disk-space-usage-by-project)。

<a id="run-the-cleanup-policy"></a>

### 运行清理策略

要减少容器镜像仓库中的存储空间，请参见[运行清理策略](../packages/container_registry.md#run-the-cleanup-policy)。

<a id="sidekiq"></a>

## Sidekiq

此内容已移至[Sidekiq 故障排除](../sidekiq/sidekiq_troubleshooting.md)。

<a id="geo"></a>

## Geo

<a id="reverify-all-uploads-or-any-ssf-data-type-which-is-verified"></a>

### 重新验证所有上传（或任何经过验证的 SSF 数据类型）

已移至[重新同步并重新验证 Geo 数据](../geo/replication/resync_reverify.md#resync-and-reverify-multiple-components)。

<a id="artifacts"></a>

### 产物

已移至[重新同步并重新验证 Geo 数据](../geo/replication/resync_reverify.md)。

<a id="repository-verification-failures"></a>

### 代码仓库验证失败

已移至[重新同步并重新验证 Geo 数据](../geo/replication/resync_reverify.md)。

<a id="resync-repositories"></a>

### 重新同步代码仓库

已移至[重新同步并重新验证 Geo 数据](../geo/replication/resync_reverify.md)。

已移至[重新同步并重新验证 Geo 数据](../geo/replication/resync_reverify.md)。

<a id="blob-types"></a>

### Blob 类型

已移至[重新同步并重新验证 Geo 数据](../geo/replication/resync_reverify.md)。

<a id="generate-service-ping"></a>

## 生成 Service Ping

此内容已移至 GitLab 开发文档中的 Service Ping 故障排除。
