---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 18 升级说明
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本页面包含极狐GitLab 18 次要版本和补丁版本的升级信息。
请确保您查看以下说明：

- 您的安装类型。
- 当前版本与目标版本之间的所有版本。

有关 Helm chart 安装的更多信息，请参见
[Helm chart 9.0 升级说明](https://gitlab.cn/docs/charts/releases/9_0/)。

<a id="required-upgrade-stops"></a>

## 必需的升级停靠点

为了给实例管理员提供可预测的升级计划，
必需的升级停靠点位于以下版本：

- `18.2`
- `18.5`
- `18.8`
- `18.11`

<a id="upgrade-notes-reference"></a>

## 升级说明参考

以下是每个极狐GitLab 次要版本升级说明的参考列表。
每个列表项都指向包含更多信息的具体章节。

带有安装方式标记的条目，例如 `(Geo)` 或 `(Linux package)`，
仅适用于该安装方式。所有其他条目适用于所有安装方式。

<a id="upgrade-to-1811"></a>

### 升级到 18.11

升级到极狐GitLab 18.11 之前，请查看以下内容：

- [18.11.0 - 18.11.2] - [文件存储上 Geo blob 同步失败并出现 `log_error` NoMethodError](#geo-blob-sync-failures-with-log_error-nomethoderror-on-file-storage) (Geo)
- [18.11.0 - 18.11.4] - [Geo 容器仓库同步静默跳过 OCI 镜像索引标签](#geo-container-repository-sync-silently-skips-oci-image-index-tags) (Geo)
- [18.11.0 - 18.11.1] - [CI 作业令牌回归问题：从内部和公开项目拉取容器镜像](#ci-job-token-regression-pulling-container-images-from-internal-and-public-projects)
- [18.11.0] - [升级到 18.11 会触发 PostgreSQL 17.7 版本升级](#postgresql-version-177-upgrade-on-gitlab-1811) (Linux package, Docker, Geo)
- [18.11.0] - [Mattermost 和 Spamcheck 已从 SLES 12.5 软件包中移除](#mattermost-and-spamcheck-removed-from-sles-125-packages) (Linux package)
- [18.11.0] - [编译后的单作业配置受 1 MiB 大小限制](#compiled-per-job-config-is-subject-to-a-1-mib-size-limit)

<a id="upgrade-to-1810"></a>

### 升级到 18.10

升级到极狐GitLab 18.10 之前，请查看以下内容：

- [18.10.0 - 18.10.3] - [SLES 12.5 RPM 软件包安装失败](#sles-125-rpm-package-installation-failure) (Linux package)
- [18.10.0 - 18.10.5] - [文件存储上 Geo blob 同步失败并出现 `log_error` NoMethodError](#geo-blob-sync-failures-with-log_error-nomethoderror-on-file-storage) (Geo)
- [18.10.0 - 18.10.7] - [Geo 容器仓库同步静默跳过 OCI 镜像索引标签](#geo-container-repository-sync-silently-skips-oci-image-index-tags) (Geo)
- [18.10.0 - 18.10.3] - [使用出站过滤时 Geo 站点 URL 被阻止](#geo-site-url-blocked-when-using-outbound-filtering) (Geo)
- [18.10.0 - 18.10.4] - [Geo blob 下载失败](#geo-blob-download-failures) (Geo)
- [18.10.0 - 18.10.3] - [Geo 从站点限流作业无法排空](#geo-secondary-throttled-jobs-not-draining) (Geo)
- [18.10.0 - 18.10.3] - [Sidekiq 并发限制器导致 Helm chart 和 Operator 部署出现作业积压](#sidekiq-concurrency-limiter-causes-job-backlogs-on-helm-chart-and-operator-deployments) (Helm chart, Operator)
- [18.10.0] - [所有项目默认启用密钥检测误报检测](#secret-detection-false-positive-detection-enabled-by-default-on-all-projects)
- [18.10.0] - [带有未加引号占位符的自定义 Webhook 模板无法保存](#custom-webhook-template-with-unquoted-placeholders-cannot-be-saved)
- [18.10.0] - [流水线执行策略中的 Dotenv 变量遵循 `variables_override`](#dotenv-variables-in-pipeline-execution-policies-respect-variables_override)

<a id="upgrade-to-189"></a>

### 升级到 18.9

升级到极狐GitLab 18.9 之前，请查看以下内容：

- [18.9.1 - 18.9.5] - [SLES 12.5 RPM 软件包安装失败](#sles-125-rpm-package-installation-failure) (Linux package)
- [18.9.0 - 18.9.5] - [使用出站过滤时 Geo 站点 URL 被阻止](#geo-site-url-blocked-when-using-outbound-filtering) (Geo)
- [18.9.0 - 18.9.5] - [Geo 从站点限流作业无法排空](#geo-secondary-throttled-jobs-not-draining) (Geo)
- [18.9.0 - 18.9.5] - [Sidekiq 并发限制器导致 Helm chart 和 Operator 部署出现作业积压](#sidekiq-concurrency-limiter-causes-job-backlogs-on-helm-chart-and-operator-deployments) (Helm chart, Operator)
- [18.9.0] - [升级到 18.9 失败并出现 PostgreSQL CheckViolation](#upgrade-to-189-fails-with-postgresql-checkviolation)
- [18.9.0] - [带有未加引号占位符的自定义 Webhook 模板无法保存](#custom-webhook-template-with-unquoted-placeholders-cannot-be-saved)

<a id="upgrade-to-188"></a>

### 升级到 18.8

升级到极狐GitLab 18.8 之前，请查看以下内容：

- [18.8.2] - [被阻止用户的部署密钥和个人访问令牌已失效](#deploy-keys-and-personal-access-tokens-for-blocked-users-invalidated)
- [18.8.0] - [合并请求合并数据的批量后台迁移](#batched-background-migration-for-merge-request-merge-data)
- [18.8.0] - [ClickHouse 字典创建错误](#clickhouse-dictionary-creation-error)
- [18.8.0] - [重新引入 CI 数据的批量后台迁移](#batched-background-migration-for-ci-data-reintroduced)
- [18.8.0] - [带有未加引号占位符的自定义 Webhook 模板无法保存](#custom-webhook-template-with-unquoted-placeholders-cannot-be-saved)

<a id="upgrade-to-187"></a>

### 升级到 18.7

升级到极狐GitLab 18.7 之前，请查看以下内容：

- [18.7.2] - [被阻止用户的部署密钥和个人访问令牌已失效](#deploy-keys-and-personal-access-tokens-for-blocked-users-invalidated)
- [18.7.0] - [CI 构建元数据迁移](#ci-builds-metadata-migration)
- [18.7.0] - [Geo ActionCable 允许来源设置](#geo-actioncable-allowed-origins-setting) (Geo)

<a id="upgrade-to-186"></a>

### 升级到 18.6

升级到极狐GitLab 18.6 之前，请查看以下内容：

- [18.6.5] - [Geo VerificationStateBackfillWorker 慢查询修复](#geo-verificationstatebackfillworker-slow-queries-fix) (Geo)
- [18.6.4] - [被阻止用户的部署密钥和个人访问令牌已失效](#deploy-keys-and-personal-access-tokens-for-blocked-users-invalidated)
- [18.6.2] - [Commits 和 Files API 大小与速率限制](#commits-and-files-api-size-and-rate-limits)
- [18.6.2] - [Duo Agent Platform Runner 限制](#duo-agent-platform-runner-restrictions)

<a id="upgrade-to-185"></a>

### 升级到 18.5

升级到极狐GitLab 18.5 之前，请查看以下内容：

- [18.5.4] - [Commits 和 Files API 大小与速率限制](#commits-and-files-api-size-and-rate-limits)
- [18.5.0 - 18.5.1] - [Geo 日志游标迁移修复](#geo-log-cursor-migration-fix) (Geo)
- [18.5.0] - [完成设计管理设计回填](#finalize-design-management-designs-backfill)
- [18.5.0] - [NGINX 路由变更导致 404 错误](#nginx-routing-changes-cause-404-errors) (Linux package)

<a id="upgrade-to-184"></a>

### 升级到 18.4

升级到极狐GitLab 18.4 之前，请查看以下内容：

- [18.4.6] - [Commits 和 Files API 大小与速率限制](#commits-and-files-api-size-and-rate-limits)
- [18.4.2 - 18.4.3] - [批量后台迁移 nil 错误](#batched-background-migration-nil-error)
- [18.4.1] - [用于防止拒绝服务的 JSON 输入限制](#json-input-limits-for-denial-of-service-prevention)
- [18.4.0 - 18.4.3] - [Geo 日志游标迁移修复](#geo-log-cursor-migration-fix) (Geo)
- [18.4.0 - 18.4.1] - [Geo 复制 TypeError](#geo-replication-typeerror) (Geo)

<a id="upgrade-to-183"></a>

### 升级到 18.3

升级到极狐GitLab 18.3 之前，请查看以下内容：

- [18.3.3] - [用于防止拒绝服务的 JSON 输入限制](#json-input-limits-for-denial-of-service-prevention)
- [18.3.0] - [LdapAddOnSeatSyncWorker 移除 Duo 席位](#ldapaddonseatsyncworker-removes-duo-seats)
- [18.3.0] - [Geo Rake 检查修复](#geo-rake-check-fix) (Geo)
- [18.3.0 - 18.3.2] - [Geo Pages 文件名修复](#geo-pages-filename-fix) (Geo)

<a id="upgrade-to-182"></a>

### 升级到 18.2

升级到极狐GitLab 18.2 之前，请查看以下内容：

- [18.2.7] - [用于防止拒绝服务的 JSON 输入限制](#json-input-limits-for-denial-of-service-prevention)
- [18.2.0] - [18.1 与 18.2 之间零停机升级推送错误](#zero-downtime-upgrade-push-errors-between-181-and-182)
- [18.2.0 - 18.2.1] - [Geo VerificationStateBackfillService `ci_job_artifact_states`](#geo-verificationstatebackfillservice-ci_job_artifact_states) (Geo)
- [18.2.0 - 18.2.6] - [Geo Pages 文件名修复](#geo-pages-filename-fix) (Geo)

<a id="upgrade-to-181"></a>

### 升级到 18.1

升级到极狐GitLab 18.1 之前，请查看以下内容：

- [18.1.0] - [Elasticsearch `strict_dynamic_mapping_exception`](#elasticsearch-strict_dynamic_mapping_exception)
- [18.1.0 - 18.1.1] - [PostgreSQL `ci_job_artifacts` 错误](#postgresql-ci_job_artifacts-error)
- [18.1.0] - [合并请求“即将就绪”错误](#merge-request-almost-ready-bug)
- [18.1.0] - [Geo HTTP 500 代理错误](#geo-http-500-proxy-errors) (Geo)
- [18.1.0 - 18.1.3] - [Geo VerificationStateBackfillService `ci_job_artifact_states`](#geo-verificationstatebackfillservice-ci_job_artifact_states) (Geo)
- [18.1.0] - [Geo Pages 文件名修复](#geo-pages-filename-fix) (Geo)

<a id="upgrade-to-180"></a>

### 升级到 18.0

升级到极狐GitLab 18.0 之前，请查看以下内容：

- [18.0.0] - [不再支持 PostgreSQL 14](#postgresql-14-not-supported)
- [18.0.0] - [`pg_dump` 二进制兼容性](#pg_dump-binary-compatibility)
- [18.0.0] - [从 17.11 零停机升级期间的流水线失败](#pipeline-failures-during-zero-downtime-upgrades-from-1711)
- [18.0.0] - [将 Gitaly 配置从 `git_data_dirs` 迁移到 storage](#migrate-gitaly-configuration-from-git_data_dirs-to-storage) (Linux package)
- [18.0.0 - 18.0.1] - [Geo 基础版到企业版回退迁移错误](#geo-ce-to-ee-revert-migration-errors) (Geo)
- [18.0.0 - 18.0.2] - [Geo HTTP 500 代理错误](#geo-http-500-proxy-errors) (Geo)
- [18.0.0 - 18.0.5] - [Geo VerificationStateBackfillService `ci_job_artifact_states`](#geo-verificationstatebackfillservice-ci_job_artifact_states) (Geo)
- [18.0.0] - [Docker 安装上出现 PRNG 未播种错误](#prng-is-not-seeded-error-on-docker-installations) (Docker)
- [17.11.0] - [Bitnami PostgreSQL 和 Redis 镜像弃用](#bitnami-postgresql-and-redis-image-deprecation) (Helm chart)

<a id="upgrade-notes"></a>

## 升级说明

极狐GitLab 18 的具体升级说明。

<a id="dotenv-variables-in-pipeline-execution-policies-respect-variables_override"></a>

### 流水线执行策略中的 Dotenv 变量遵循 `variables_override`

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

- 影响：流水线执行策略
- 受影响版本：

  | 版本     | 受影响的补丁版本 |
  | ----------- | ----------------------- |
  | 18.10       | 18.10.0 及更高版本       |

在极狐GitLab 18.10 及更高版本中，来自 dotenv 产物
(`artifacts:reports:dotenv`) 的变量与流水线执行策略中的其他变量一样，
遵循相同的 `variables_override` 规则（默认安全）。
此前，dotenv 变量可以绕过 `variables_override` 限制，
从而削弱了策略的安全控制。

如果某个流水线依赖 dotenv 变量来覆盖策略定义的变量，
那么当设置了 `variables_override.allowed: false` 时，该行为将不再生效。
要恢复之前的行为，请将新的 `dotenv` 选项设置为
`allow_override`：

```yaml
variables_override:
  allowed: false
  exceptions: []
  dotenv: allow_override
```

更多信息，请参见
[流水线执行策略](../../user/application_security/policies/pipeline_execution_policies.md)
和 [合并请求 214991](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/214991)。

<a id="geo-blob-sync-failures-with-log_error-nomethoderror-on-file-storage"></a>

### 文件存储上 Geo blob 同步失败并出现 `log_error` NoMethodError

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo（仅限文件存储）
- 受影响版本：

  | 版本           | 受影响的补丁版本 | 已修复补丁级别 |
  | ----------------- |-------------------------|-------------------|
  | 18.11             | 18.11.0 - 18.11.2       | 18.11.3           |
  | 18.10             | 18.10.0 - 18.10.5       | 18.10.6           |
  | 18.0 - 18.9       | 所有补丁版本      | 未修复         |

在将 blob 存储在**文件存储**（而非对象存储）上的 Geo 从站点上，
blob 复制（例如流水线产物、LFS 对象、上传文件和作业产物）可能会失败，并出现误导性错误：

```plaintext
Error while attempting to sync: undefined method `log_error' for an instance of Gitlab::Geo::Replication::BlobDownloader
```

更多信息，请参见 [议题 598565](https://gitlab.com/gitlab-org/gitlab/-/work_items/598565)。

<a id="geo-container-repository-sync-silently-skips-oci-image-index-tags"></a>

### Geo 容器仓库同步静默跳过 OCI 镜像索引标签

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo（容器镜像仓库）
- 受影响版本：

  | 版本     | 受影响的补丁版本 | 已修复补丁级别 |
  | ----------- | ----------------------- | ----------------- |
  | 18.11       | 18.11.0 - 18.11.4       | 18.11.5           |
  | 18.10       | 18.10.0 - 18.10.7       | 18.10.8           |
  | 18.0 - 18.9 | 所有补丁版本      | 未修复         |

在 Geo 从站点上，容器仓库同步会静默跳过其清单为 OCI 镜像索引
(`application/vnd.oci.image.index.v1+json`) 的标签。
多架构镜像和 BuildKit 缓存标签通常使用此清单类型。不会引发错误，
标签数量也匹配，但从从站点对受影响标签执行 `docker pull`
会返回 `manifest unknown`。同样的根本原因还会在从站点上留下同步无法移除的孤立标签。

在您将主站点和从站点都升级到已修复版本后，新同步的标签将是正确的。
之前受影响的代码仓库会在下一个验证周期中收敛，最长可能需要重新验证间隔
（默认 90 天）。要立即修复受影响的代码仓库，
请[在从站点上重新同步容器仓库](../../administration/geo/replication/container_registry.md#manually-trigger-a-container-registry-sync-event)。

更多信息，请参见 [议题 600486](https://gitlab.com/gitlab-org/gitlab/-/work_items/600486)。

<a id="ci-job-token-regression-pulling-container-images-from-internal-and-public-projects"></a>

### CI 作业令牌回归问题：从内部和公开项目拉取容器镜像

- 影响：所有安装方式
- 受影响版本：

  | 版本 | 受影响的补丁版本 | 已修复补丁级别 |
  | ------- | ----------------------- | ----------------- |
  | 18.11   | 18.11.0 - 18.11.1       | 18.11.2           |

> [!warning]
> 如果 CI 作业依赖 `CI_JOB_TOKEN` 从内部或公开项目拉取容器镜像，
> 请勿升级到极狐GitLab 18.11.0 或 18.11.1。

极狐GitLab 18.11.0 中的一个回归问题导致 CI 作业无法使用
`CI_JOB_TOKEN` 从内部或公开项目拉取容器镜像。受影响的流水线会失败，
并出现 `denied: requested access to the resource is denied`。该修复已向后移植到
`18-11-stable-ee`，但在 18.11.1 标签创建之后才合入，因此
18.11.0 和 18.11.1 均受影响。

对于已经升级的运维人员，可用的变通方法：

1. 将每个使用方项目添加到源项目的 CI 作业令牌允许列表中。
   请参见 [CI/CD 作业令牌安全](../../ci/jobs/ci_job_token.md#gitlab-cicd-job-token-security)。
1. 使用个人、群组或项目访问令牌代替 `CI_JOB_TOKEN` 对容器拉取进行身份验证。
1. 将向后移植提交
   [`e3c0f308`](https://gitlab.com/gitlab-org/gitlab/-/commit/e3c0f30800f803b8f519e9b937296b068d8f4cca)
   应用到极狐GitLab 实例。

更多信息，请参见 [议题 597223](https://gitlab.com/gitlab-org/gitlab/-/work_items/597223)。

<a id="sles-125-rpm-package-installation-failure"></a>

### SLES 12.5 RPM 软件包安装失败

- 影响：Linux package
- 受影响版本：

  | 版本 | 受影响的补丁版本          | 可安装补丁级别 |
  | ------- | -------------------------------- | ----------------------- |
  | 18.10   | 18.10.0 - 18.10.3                | 18.10.4 - 18.10.5       |
  | 18.9    | 18.9.1 - 18.9.5                  | 18.9.0, 18.9.6          |

> [!warning]
> 在 SLES 12.5 上，只有极狐GitLab 18.9.0、18.10.4 和 18.11.2 可以成功安装。
> 受影响范围内的所有其他补丁版本均无法安装。

使用 `rpm` 或 `zypper` 命令安装适用于 SLES 12.5 的极狐GitLab Linux 软件包时，
会失败并出现 `error: install failed`。根本原因是 RPM 4.11.2 中的
16 MiB RPM 头数据大小限制 (`HEADER_DATA_MAX`)，而 RPM 4.11.2 是
SLES 12 SP5 自带的版本。随着极狐GitLab 软件包中文件数量的增长，
序列化的 RPM 头超过了此限制，导致 RPM 数据库事务在安装过程中静默失败。

该问题已在特定补丁版本中通过减少 Linux 软件包中的文件数量得到解决
（参见 [合并请求 9215](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9215)）。
但是，如果文件数量再次增长，后续补丁版本可能会再次出现此问题。
要在 SLES 12.5 上安装极狐GitLab，请仅使用上面列出的可安装补丁级别。

SUSE 发行版
[在极狐GitLab 18.9 中已弃用，并计划在极狐GitLab 19.0 中移除](../deprecations.md#linux-package-support-for-suse-distributions)。
请考虑迁移到受支持的操作系统。

更多信息，请参见 [议题 9647](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/9647)。

<a id="mattermost-and-spamcheck-removed-from-sles-125-packages"></a>

### Mattermost 和 Spamcheck 已从 SLES 12.5 软件包中移除

- 影响：Linux package
- 受影响版本：18.11.0 及更高版本

由于 [RPM 软件包大小限制](https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/9716)，
Mattermost 和 Spamcheck 已从 SLES 12.5 Linux 软件包中移除。

SUSE 发行版
[在极狐GitLab 18.9 中已弃用，并计划在极狐GitLab 19.0 中移除](../deprecations.md#linux-package-support-for-suse-distributions)，
并且 [Mattermost](../deprecations.md#mattermost-bundled-with-linux-package) 和
[Spamcheck](../deprecations.md#spamcheck-support-in-the-linux-package-and-gitlab-helm-chart)
都计划在极狐GitLab 19.0 中从所有发行版中移除。

如果您在 SLES 12.5 上依赖 Mattermost，可以
[将 Mattermost 迁移到独立部署](https://docs.mattermost.com/administration-guide/onboard/migrate-gitlab-omnibus.html)。
如果您在 SLES 12.5 上使用 Spamcheck，可以
[使用 Docker 部署它](../../administration/reporting/spamcheck.md)。

<a id="geo-secondary-throttled-jobs-not-draining"></a>

### Geo 从站点限流作业无法排空

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo
- 受影响版本：

  | 版本 | 受影响的补丁版本 | 已修复补丁级别 |
  | ------- | ----------------------- | ----------------- |
  | 18.10   | 18.10.0 - 18.10.3       | 18.10.4           |
  | 18.9    | 18.9.0 - 18.9.5         | 18.9.6            |

Geo 从站点禁用了 `ConcurrencyLimit::ResumeWorker`，导致被限流的
`Geo::EventWorker` 和 `Geo::SyncWorker` 作业在 Redis 中累积而无法排空。
这可能会使 Geo 复制停滞并增加 Redis 内存使用量。

更多信息，请参见 [议题 595824](https://gitlab.com/gitlab-org/gitlab/-/work_items/595824)。

<a id="geo-site-url-blocked-when-using-outbound-filtering"></a>

### 使用出站过滤时 Geo 站点 URL 被阻止

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo
- 受影响版本：

  | 版本 | 受影响的补丁版本 | 已修复补丁级别 |
  | ------- | ----------------------- | ----------------- |
  | 18.10   | 18.10.0 - 18.10.3       | 18.10.4           |
  | 18.9    | 18.9.0 - 18.9.5         | 18.9.6            |

启用出站请求过滤后，Geo 站点 URL 会被错误地阻止。
这会导致保存 Geo 站点时出现验证错误，并显示类似以下消息：
`Url is blocked: Requests to hosts and IP addresses not on the Allow List are denied`。

出现此问题的原因是，配置出站过滤时，Geo 站点 URL 不会自动添加到出站
本地请求允许列表中。

更多信息，请参见 [议题 544821](https://gitlab.com/gitlab-org/gitlab/-/issues/544821)。

<a id="geo-blob-download-timeout-setting"></a>

### Geo blob 下载超时设置

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo
- 受影响版本：18.10.0

当前硬编码的 8 小时（28,800 秒）Geo blob 下载超时会导致需要更长传输时间的
超大 LFS 对象（5 GB 以上）同步失败，使其一直停留在“已开始”状态。新的
`blob_download_timeout` 设置控制每个站点的 blob 复制（LFS 对象、上传文件、
作业产物等）超时时间（以秒为单位）。可通过 [Geo Sites API](../../api/geo_sites.md) 进行配置。

- 默认值：`28800`（8 小时）。
- 最大值：`86400`（24 小时）。

<a id="geo-blob-download-failures"></a>

### Geo blob 下载失败

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo
- 受影响版本：

  | 版本 | 受影响的补丁版本 | 已修复补丁级别 |
  | ------- | ----------------------- | ----------------- |
  | 18.10   |  18.10.0 - 18.10.4      | 18.10.5           |

所有 Geo blob 类型（上传文件、LFS 对象、作业产物等）可能会在从站点上持续同步失败。
与瞬时网络错误不同，这些失败会影响所有 blob 记录，并且重试后无法恢复。
受影响的从站点会显示处于“失败”状态的 blob，Sidekiq 日志可能包含
段错误、`HPE_USER Span callback error in on_header_field`
错误或意外的 HTTP 状态码（例如 `status_code: 32`
或 `status_code: 34`）。

根本原因是 `rugged` 1.9.0（在极狐GitLab 18.10 中升级）与
`llhttp-ffi` gem 之间的符号冲突。`rugged.so` 中静态链接的
`llhttp` 符号覆盖了 `llhttp-ffi` 回调，从而破坏了 HTTP
响应解析。更多信息，请参见
[议题 598564](https://gitlab.com/gitlab-org/gitlab/-/issues/598564)。

在极狐GitLab 18.10.5 中，`rugged` 已降级到 1.7.2，该版本不包含
冲突的符号。升级后无需执行任何操作。

<a id="feature-flag-workaround-for-gitlab-18104"></a>

#### 极狐GitLab 18.10.4 的功能标志变通方法

如果您使用的是极狐GitLab 18.10.4 且无法升级到极狐GitLab 18.10.5，请启用
`geo_blob_download_with_gitlab_http` 功能标志。此标志会将
blob 下载切换为使用 `Gitlab::HTTP` (`Net::HTTP`)，而不是
依赖 FFI 的 `http` gem：

1. 启用功能标志：

   ```shell
   sudo gitlab-rails console
   Feature.enable(:geo_blob_download_with_gitlab_http)
   exit
   ```

1. 重启 Sidekiq：

   ```shell
   sudo gitlab-ctl restart sidekiq
   ```

> [!note]
> 功能标志变通方法存在已知限制：
>
> - 超过 60 秒的大 blob 传输可能会超时
>   （[议题 598020](https://gitlab.com/gitlab-org/gitlab/-/issues/598020)）。
> - 容器镜像仓库复制不受此标志影响。
> - 具有出站请求过滤 (`deny_all_requests_except_allowed`) 的环境
>   可能需要额外配置
>   （[议题 598514](https://gitlab.com/gitlab-org/gitlab/-/issues/598514)）。

更多信息，请参见 [议题 595139](https://gitlab.com/gitlab-org/gitlab/-/issues/595139)。

<a id="upgrade-to-189-fails-with-postgresql-checkviolation"></a>

### 升级到 18.9 失败并出现 PostgreSQL CheckViolation

- 影响：所有安装方式
- 受影响版本：18.9.0、18.9.1

将私有化部署的极狐GitLab 实例升级到极狐GitLab 18.9.0 或 18.9.1 时，升级会在数据库迁移期间失败，并出现：

```plaintext
PG::CheckViolation: ERROR: check constraint "check_xxxxxxxx" of relation "tablename" is violated by some row
```

此问题由极狐GitLab 18.10 中修复的一个错误引起（参见 [合并请求 224446](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/224446)）。该修复也已向后移植，应包含在下一个极狐GitLab 18.9 补丁版本中（参见 [合并请求 225026](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/225026)）。

但是，由于单记录错误，该错误可能导致批量后台迁移被静默跳过。升级到 v18.8 时，针对只有一条记录的表的批量后台迁移会被错误地标记为 `finished`，而从未实际执行。这导致数据未回填，从而在私有化部署实例上升级失败。

一项提议的修复（参见 [合并请求 225461](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/225461)）会将受影响的批量后台迁移从 `finished`/`finalized` 重置回 `paused`，以便调度程序重新执行它们。其范围是 `queued_migration_version` 在 18.5 和 18.8 之间且 `min_value = max_value` 或 `min_cursor = max_cursor` 的迁移。

您有两个选择：

- 立即应用变通方法以完成升级。
- 等待完整修复，并在包含该修复的版本发布后再升级。

以下知识库文章介绍了五种已知症状的变通方法：

- [`PG::CheckViolation: ERROR: check constraint "check_96233d37c0" of relation "pool_repositories" is violated by some row`](https://support.gitlab.com/hc/en-us/articles/25929006135068-PG-CheckViolation-ERROR-check-constraint-check-96233d37c0-of-relation-pool-repositories-is-violated-by-some-row)
- [`PG::CheckViolation: ERROR: check constraint "check_f6590fe2c1" of relation "gpg_key_subkeys" is violated by some row`](https://support.gitlab.com/hc/en-us/articles/25756021007004-Upgrade-to-18-9-0-fails-with-PG-CheckViolation-on-gpg-key-subkeys)
- [`PG::CheckViolation: ERROR: check constraint "check_17a3a18e31" of relation "user_agent_details" is violated by some row`](https://support.gitlab.com/hc/en-us/articles/25994671144348-Upgrade-to-18-9-0-fails-with-PG-CheckViolation-on-user-agent-details)
- [`PG::CheckViolation: ERROR: check constraint "check_ddd6f289f4" of relation "commit_user_mentions" is violated by some row`](https://support.gitlab.com/hc/en-us/articles/25992549646364-Upgrade-to-18-9-0-fails-with-PG-CheckViolation-on-commit-user-mentions)
- [`PG::CheckViolation: ERROR: check constraint "check_e69372e45f" of relation "suggestions" is violated by some row`](https://support.gitlab.com/hc/en-us/articles/25771198648732-Upgrade-to-18-9-0-fails-with-PG-CheckViolation-on-suggestions)

<a id="deploy-keys-and-personal-access-tokens-for-blocked-users-invalidated"></a>

### 被阻止用户的部署密钥和个人访问令牌已失效

- 影响：所有安装方式
- 受影响版本：

  | 版本 | 受影响的补丁级别 | 已修复补丁级别        |
  |---------|-----------------------|--------------------------|
  | 18.8    | 18.8.2 及更高版本      | 不适用（有意变更） |
  | 18.7    | 18.7.2 及更高版本      | 不适用（有意变更） |
  | 18.6    | 18.6.4 及更高版本      | 不适用（有意变更） |

极狐GitLab 18.8.2、18.7.2 和 18.6.4 现在会拒绝使用与被阻止用户关联的部署密钥的 API 请求。
如果您有与被阻止用户关联的部署密钥，升级到上述版本后这些密钥将不再有效。
这是一项安全修复，旨在防止被阻止用户通过其密钥和令牌访问极狐GitLab 资源。

您必须：

1. 识别被阻止用户拥有的任何部署密钥或个人访问令牌。
1. 将它们重新分配给可计费用户，或者删除它们并使用可计费用户或服务账号创建新的密钥/令牌。

可以使用以下查询来识别所有与被阻止账号关联且在过去 365 天内至少使用过一次的部署密钥：

```sql
SELECT
  k.id,
  k.user_id,
  u.username,
  u.state as user_state,
  k.title,
  k.fingerprint,
  k.fingerprint_sha256,
  k.usage_type,
  k.last_used_at,
  k.created_at,
  k.updated_at
FROM keys k
INNER JOIN users u ON k.user_id = u.id
WHERE u.state IN ('blocked', 'ldap_blocked', 'blocked_pending_approval', 'banned')
  AND k.type = 'DeployKey'
  AND k.last_used_at >= NOW() - INTERVAL '365 days'
ORDER BY u.state, u.username, k.last_used_at DESC;
```

<a id="clickhouse-dictionary-creation-error"></a>

### ClickHouse 字典创建错误

- 影响：所有安装方式
- 受影响版本：18.8.0

启用了 [ClickHouse 集成](../../integration/clickhouse.md) 的极狐GitLab 私有化部署客户
在升级过程中可能会遇到 ClickHouse 数据库迁移错误，原因是缺少权限
(`DB::Exception: gitlab: Not enough privileges`)。要解决此错误，请参见
[数据库字典读取支持故障排查文档](../../integration/clickhouse.md#database-dictionary-read-support)。

<a id="batched-background-migration-for-ci-data-reintroduced"></a>

### 重新引入 CI 数据的批量后台迁移

- 影响：所有安装方式
- 受影响版本：18.8.0

在 [CI 构建元数据迁移](#ci-builds-metadata-migration) 中引入的
[批量后台迁移](../background_migrations.md)必须重新引入，
以处理数据结构中的一种边缘情况，并确保它们能够完成。

<a id="custom-webhook-template-with-unquoted-placeholders-cannot-be-saved"></a>

### 带有未加引号占位符的自定义 Webhook 模板无法保存

- 影响：所有安装方式
- 受影响版本：

  | 版本 | 受影响的补丁版本 | 已修复补丁级别 |
  | ------- | ----------------------- | ----------------- |
  | 18.10   | 所有补丁版本      | 未修复         |
  | 18.9    | 所有补丁版本      | 未修复         |
  | 18.8    | 所有补丁版本      | 未修复         |

在极狐GitLab 18.8 到 18.10 中，带有未加引号负载字段的
[自定义 Webhook 模板](../../user/project/integrations/webhooks.md#custom-webhook-template)
无法保存。此问题已在极狐GitLab 18.11 中解决。

作为变通方法，请将字段用引号括起来。例如，
`{"value": {{id}}}` 应改为 `{"value": "{{id}}"}`。

带引号的字段会生成字符串值而不是数值。如果这与您的 Webhook 不兼容，
请升级到极狐GitLab 18.11 或更高版本。

更多信息，请参见
[Webhook 故障排查文档](../../user/project/integrations/webhooks_troubleshooting.md#custom-webhook-template-with-unquoted-placeholders-cannot-be-saved)。

<a id="ci-builds-metadata-migration"></a>

### CI 构建元数据迁移

- 影响：所有安装方式
- 受影响版本：18.7.0

一个 [部署后迁移](../../development/database/post_deployment_migrations.md)
会调度批量[后台迁移](../background_migrations.md)，将 CI 构建元数据复制到
新的优化表 (`p_ci_job_definitions`)。此迁移是最终缩减 CI 数据库大小
计划的一部分（参见 [史诗 13886](https://gitlab.com/groups/gitlab-org/-/work_items/13886)）。
如果您的实例有数百万个作业并希望加快迁移速度，
可以[选择要迁移的数据](#ci-builds-metadata-migration-details)。

<a id="geo-actioncable-allowed-origins-setting"></a>

### Geo ActionCable 允许来源设置

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo
- 受影响版本：18.7.0

新增了 `action_cable_allowed_origins` 设置，用于配置 ActionCable WebSocket 请求的允许来源。
在配置主站点时指定允许的 URL，以确保正确的跨站点 WebSocket 连接：

- [Linux package 的 Geo 文档](../../administration/geo/replication/configuration.md#add-primary-and-secondary-urls-as-allowed-actioncable-origins)
- [Helm chart 的 Geo 文档](https://gitlab.cn/docs/charts/advanced/geo/#configure-primary-database)

<a id="geo-verificationstatebackfillworker-slow-queries-fix"></a>

### Geo VerificationStateBackfillWorker 慢查询修复

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo
- 受影响版本：18.6.5

修复了 Geo [议题 587407](https://gitlab.com/gitlab-org/gitlab/-/work_items/587407)，其中
`Geo::VerificationStateBackfillWorker` 为 `merge_request_diff_details` 表生成了大型慢查询。

<a id="commits-and-files-api-size-and-rate-limits"></a>

### Commits 和 Files API 大小与速率限制

- 影响：所有安装方式
- 受影响版本：

  | 版本 | 受影响的补丁级别 | 已修复补丁级别        |
  |---------|-----------------------|--------------------------|
  | 18.6    | 18.6.2 及更高版本      | 不适用（有意变更） |
  | 18.5    | 18.5.4 及更高版本      | 不适用（有意变更） |
  | 18.4    | 18.4.6 及更高版本      | 不适用（有意变更） |

极狐GitLab 18.6.2、18.5.4 和 18.4.6 对发往以下端点的请求引入了大小和速率限制：

- `POST /projects/:id/repository/commits` - [创建提交](../../api/commits.md#create-a-commit)
- `POST /projects/:id/repository/files/:file_path` - [在代码仓库中创建文件](../../api/repository_files.md#create-a-file-in-a-repository)
- `PUT /projects/:id/repository/files/:file_path` - [在代码仓库中更新文件](../../api/repository_files.md#update-a-file-in-a-repository)

对于超过大小限制的请求，极狐GitLab 会返回 `413 Entity Too large` 状态；对于超过速率限制的请求，会返回 `429 Too Many Requests` 状态。更多信息，请参见 [Commits 和 Files API 限制](../../administration/instance_limits.md#commits-and-files-api-limits)

<a id="duo-agent-platform-runner-restrictions"></a>

### Duo Agent Platform Runner 限制

- 影响：所有安装方式
- 受影响版本：18.6.2

引入了一些与哪些 Runner 可用于 Duo Agent Platform 相关的
[Runner 限制](../../user/duo_agent_platform/flows/execution/_index.md#configure-runners-to-execute-flows)。

<a id="geo-log-cursor-migration-fix"></a>

### Geo 日志游标迁移修复

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo
- 受影响版本：

  | 版本 | 受影响的补丁版本 | 已修复补丁级别 |
  |---------|-------------------------|-------------------|
  | 18.5    | 18.5.0 - 18.5.1         | 18.5.2            |
  | 18.4    | 18.4.0 - 18.4.3         | 18.4.4            |

已修复缺失的 Geo [迁移](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/210512)，该迁移导致从站点上的 Geo 日志游标无法启动。

<a id="finalize-design-management-designs-backfill"></a>

### 完成设计管理设计回填

- 影响：所有安装方式
- 受影响版本：18.5.0

一个 [部署后迁移](../../development/database/post_deployment_migrations.md)
`20250922202128_finalize_correct_design_management_designs_backfill` 会完成
在 18.4 中调度的批量[后台迁移](../background_migrations.md)。
如果您在升级路径中跳过了 18.4，则在运行部署后迁移时会完整执行该迁移。
执行时间与您的 `design_management_designs` 表的大小直接相关。
对于大多数实例，迁移不应超过 2 分钟，但对于某些较大的实例，
可能需要长达 10 分钟。
请耐心等待，不要中断迁移过程。

<a id="nginx-routing-changes-cause-404-errors"></a>

### NGINX 路由变更导致 404 错误

- 影响：Linux package
- 受影响版本：18.5.0

极狐GitLab 18.5.0 中引入的 NGINX 路由变更可能会导致服务在使用不匹配的主机名
（例如 `localhost` 或备用域名）时无法访问。
此问题会导致：

- 健康检查端点（例如 `/-/health`）返回 `404` 错误，而不是正确的响应。
- 使用已配置 FQDN 以外的主机名访问时，极狐GitLab Web 界面显示 `404` 错误页面。
- GitLab Pages 可能会收到本应发往其他服务的流量。
- 任何使用以前可用的备用主机名的请求出现问题。

此问题已在 Linux package 中通过 [合并请求 8805](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/8805) 解决，该修复将
在极狐GitLab 18.5.2 和 18.6.0 中提供。

克隆、推送和拉取等 Git 操作不受此问题影响。

<a id="batched-background-migration-nil-error"></a>

### 批量后台迁移 nil 错误

- 影响：所有安装方式
- 受影响版本：18.4.2、18.4.3

升级到 `18.4.2` 或 `18.4.3` 时，以下批量后台迁移可能会失败，
并出现 `no implicit conversion of nil into String` 错误：

- `FixIncompleteInstanceExternalAuditDestinations`
- `FinalizeAuditEventDestinationMigrations`

要解决此问题，请升级到最新的补丁版本，或使用 [议题 578938 中的变通方法](https://gitlab.com/gitlab-org/gitlab/-/issues/578938#workaround)。

<a id="geo-replication-typeerror"></a>

### Geo 复制 TypeError

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo
- 受影响版本：

  | 版本 | 受影响的补丁版本 | 已修复补丁级别 |
  |---------|-------------------------|-------------------|
  | 18.4    | 18.4.0 - 18.4.1         | 18.4.2            |

在 Geo 从站点中，[一个错误](https://gitlab.com/gitlab-org/gitlab/-/issues/571455)会导致复制事件失败，并出现错误消息 `no implicit conversion of String into Array (TypeError)`。重新验证等冗余机制可确保最终一致性，但 RPO 会显著增加。

<a id="json-input-limits-for-denial-of-service-prevention"></a>

### 用于防止拒绝服务的 JSON 输入限制

- 影响：所有安装方式
- 受影响版本：

  | 版本 | 受影响的补丁级别 | 已修复补丁级别        |
  |---------|-----------------------|--------------------------|
  | 18.4    | 18.4.1 及更高版本      | 不适用（有意变更） |
  | 18.3    | 18.3.3 及更高版本      | 不适用（有意变更） |
  | 18.2    | 18.2.7 及更高版本      | 不适用（有意变更） |

极狐GitLab 18.4.1、18.3.3 和 18.2.7 引入了对 JSON 输入的限制，以防止拒绝服务攻击。
对于超过这些限制的 HTTP 请求，极狐GitLab 会返回 `400 Bad Request` 状态。
更多信息，请参见 [HTTP 请求限制](../../administration/instance_limits.md#http-request-limits)。

<a id="ldapaddonseatsyncworker-removes-duo-seats"></a>

### LdapAddOnSeatSyncWorker 移除 Duo 席位

- 影响：所有安装方式
- 受影响版本：18.3.0

引入了一个新的工作进程 `LdapAddOnSeatSyncWorker`，启用 LDAP 时，它可能会在每晚无意中从
极狐GitLab Duo 席位中移除所有用户。此问题已在极狐GitLab 18.4.0 和 18.3.2 中修复。详情请参见
[议题 565064](https://gitlab.com/gitlab-org/gitlab/-/issues/565064)。

<a id="geo-rake-check-fix"></a>

### Geo Rake 检查修复

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo
- 受影响版本：18.3.0

导致 `rake gitlab:geo:check` 在安装 Geo 从站点时错误报告失败的
[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/545533)已在 18.3.0 中修复。

<a id="geo-pages-filename-fix"></a>

### Geo Pages 文件名修复

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo
- 受影响版本：

  | 版本 | 受影响的补丁级别  | 已修复补丁级别 |
  |---------|------------------------|-------------------|
  | 18.3    | 18.3.0 - 18.3.2        | 18.3.3            |
  | 18.2    | 18.2.0 - 18.2.6        | 18.2.7            |
  | 18.1    | 18.1.0 及更高版本       | 18.1 中未修复 |

极狐GitLab 18.3.3 和 18.2.7 及更高版本包含对 [议题 559196](https://gitlab.com/gitlab-org/gitlab/-/issues/559196) 的修复，该问题中，具有长文件名的 Pages 部署的 Geo 验证可能会失败。该修复可防止在 Geo 从站点上截断文件名，以在复制和验证期间保持一致性。

<a id="zero-downtime-upgrade-push-errors-between-181-and-182"></a>

### 18.1 与 18.2 之间零停机升级推送错误

- 影响：所有安装方式
- 受影响版本：18.2.0

18.1.x 与 18.2.x 之间的升级受 [已知议题 567543](https://gitlab.com/gitlab-org/gitlab/-/issues/567543) 影响，
该问题会导致升级期间向现有项目推送代码时出错。为确保在 18.1.x 和 18.2.x 版本之间升级时零停机，
请直接升级到包含修复的 18.2.6 版本。

<a id="geo-verificationstatebackfillservice-ci_job_artifact_states"></a>

### Geo VerificationStateBackfillService `ci_job_artifact_states`

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo
- 受影响版本：

  | 版本 | 受影响的补丁级别 | 已修复补丁级别 |
  |---------|------------------------|-------------------|
  | 18.2    | 18.2.0 - 18.2.1        | 18.2.2            |
  | 18.1    | 18.1.0 - 18.1.3        | 18.1.4            |
  | 18.0    | 18.0.0 - 18.0.5        | 18.0.6            |

受影响的版本存在一个已知问题，当 `VerificationStateBackfillService` 运行时，由于
`ci_job_artifact_states` 的主键发生变化而出现该问题。要解决此问题，请升级到已修复的补丁级别版本。

<a id="elasticsearch-strict_dynamic_mapping_exception"></a>

### Elasticsearch `strict_dynamic_mapping_exception`

- 影响：所有安装方式
- 受影响版本：18.1.0

对于 Elasticsearch 版本 7，Elasticsearch 索引可能会失败并出现
`strict_dynamic_mapping_exception` 错误。要解决此问题，请参见
[议题 566413](https://gitlab.com/gitlab-org/gitlab/-/issues/566413) 中的“Possible fixes”部分。

<a id="postgresql-ci_job_artifacts-error"></a>

### PostgreSQL `ci_job_artifacts` 错误

- 影响：所有安装方式
- 受影响版本：18.1.0、18.1.1

极狐GitLab 18.1.0 和 18.1.1 版本会在 PostgreSQL 日志中显示错误，例如
`ERROR:  relation "ci_job_artifacts" does not exist at ...`。
日志中的这些错误可以安全地忽略，但可能会触发监控告警，包括在 Geo 站点上。要解决此问题，请更新到极狐GitLab 18.1.2 或更高版本。

<a id="merge-request-almost-ready-bug"></a>

### 合并请求“即将就绪”错误

- 影响：所有安装方式
- 受影响版本：18.1.0

包含某些用户提交的合并请求可能无法继续，并持续显示
`Your merge request is almost ready`。请参见 [议题 554613](https://gitlab.com/gitlab-org/gitlab/-/issues/554613)。
此外，[`sidekiq/current` 日志](../../administration/logs/_index.md#sidekiq-logs)会显示
`undefined method 'id' for nil:NilClass` 错误，涉及 `merge_request_diff_commit.rb`。
要修复此问题：

1. 启动[数据库控制台](../../administration/troubleshooting/postgresql.md#start-a-database-console)。
1. 运行以下命令：

   ```sql
   REINDEX TABLE CONCURRENTLY public.merge_request_diff_commit_users;
   ```

1. 关闭并重新打开受影响的合并请求。

<a id="geo-http-500-proxy-errors"></a>

### Geo HTTP 500 代理错误

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo
- 受影响版本：

  | 版本 | 受影响的补丁版本 | 已修复补丁级别 |
  |---------|-------------------------|-------------------|
  | 18.1    | 18.1.0                  | 18.1.1            |
  | 18.0    | 18.0.0 - 18.0.2         | 18.0.3            |

上表中的极狐GitLab 版本存在一个已知问题，即从 Geo 从站点代理的 Git 操作会失败并出现 HTTP 500 错误。要解决此问题，请升级到已修复的补丁级别版本。

<a id="postgresql-14-not-supported"></a>

### 不再支持 PostgreSQL 14

- 影响：所有安装方式
- 受影响版本：18.0.0

[从极狐GitLab 18 开始不再支持 PostgreSQL 14](../deprecations.md#postgresql-14-and-15-no-longer-supported)。
在升级到极狐GitLab 18.0 或更高版本之前，请将 PostgreSQL 至少升级到 16.5 版本。更多信息，请参见
[安装要求](../../install/requirements.md#postgresql)。

> [!warning]
> 自动数据库版本升级仅适用于使用 Linux package 的单节点实例。
> 在所有其他情况下，例如 Geo 实例、使用 Linux package 的高可用 PostgreSQL，
> 或使用外部 PostgreSQL 数据库（如 Amazon RDS），您必须手动升级 PostgreSQL。详细步骤请参见[升级 Geo 实例](https://gitlab.cn/docs/omnibus/settings/database/#upgrading-a-geo-instance)。

<a id="pg_dump-binary-compatibility"></a>

### `pg_dump` 二进制兼容性

- 影响：所有安装方式
- 受影响版本：18.0.0

极狐GitLab 捆绑了 `pg_dump` 二进制文件。使用外部 PostgreSQL 服务器时，请确保
`pg_dump` 客户端版本与 PostgreSQL 服务器兼容，以便创建和恢复极狐GitLab 数据库备份。

<a id="bitnami-postgresql-and-redis-image-deprecation"></a>

### Bitnami PostgreSQL 和 Redis 镜像弃用

- 影响：Helm chart
- 受影响版本：17.11.0 及更早版本

从 2025 年 9 月 29 日起，Bitnami 将停止提供带标签的 PostgreSQL 和 Redis 镜像。如果您使用
GitLab chart 部署极狐GitLab 17.11 或更早版本，并使用捆绑的 Redis 或 Postgres，则必须手动更新您的值以使用旧版仓库，以防止意外停机。更多信息，请参见 [议题 6089](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/6089)。

<a id="pipeline-failures-during-zero-downtime-upgrades-from-1711"></a>

### 从 17.11 零停机升级期间的流水线失败

- 影响：所有安装方式
- 受影响版本：18.0.0

当 Rails 已升级但 Sidekiq 仍停留在 17.11 版本时，功能标志
`ci_only_one_persistent_ref_creation` 会导致零停机升级期间出现流水线失败
（详情请参见 [议题 558808](https://gitlab.com/gitlab-org/gitlab/-/issues/558808)）。

**预防措施：** 打开 Rails 控制台并在升级前启用功能标志：

```shell
$ sudo gitlab-rails console
Feature.enable(:ci_only_one_persistent_ref_creation)
```

**如果已受影响：** 运行此命令并重试失败的流水线：

```shell
$ sudo gitlab-rails console
Rails.cache.delete_matched("pipeline:*:create_persistent_ref_service")
```

<a id="migrate-gitaly-configuration-from-git_data_dirs-to-storage"></a>

### 将 Gitaly 配置从 `git_data_dirs` 迁移到 storage

- 影响：Linux package
- 受影响版本：18.0.0

在极狐GitLab 18.0 及更高版本中，您不能再使用 `git_data_dirs` 设置来配置 Gitaly 存储位置。

如果您仍在使用 `git_data_dirs`，则必须在升级到极狐GitLab 18.0 之前
[迁移您的 Gitaly 配置](https://gitlab.cn/docs/omnibus/settings/configuration/#migrating-from-git_data_dirs)。

<a id="geo-ce-to-ee-revert-migration-errors"></a>

### Geo 基础版到企业版回退迁移错误

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

- 影响：Geo
- 受影响版本：18.0.0

如果您部署了极狐GitLab 企业版，然后又回退到极狐GitLab 基础版，
您的数据库模式可能会偏离极狐GitLab 应用程序所期望的模式，
从而导致迁移错误。升级到 18.0.0 时可能会遇到四个特定错误，
因为该版本中添加了一个迁移，更改了这些列的默认值。

错误如下：

- `No such column: geo_nodes.verification_max_capacity`
- `No such column: geo_nodes.minimum_reverification_interval`
- `No such column: geo_nodes.repos_max_capacity`
- `No such column: geo_nodes.container_repositories_max_capacity`

此迁移已在极狐GitLab 18.0.2 中修补，如果缺少这些列，则会添加它们。
请参见 [议题 #543146](https://gitlab.com/gitlab-org/gitlab/-/issues/543146)。

**受影响版本**：

| 受影响的次要版本 | 受影响的补丁版本 | 已修复于 |
| ----------------------- | ----------------------- | -------- |
| 18.0                    |  18.0.0 - 18.0.1        | 18.0.2   |

<a id="prng-is-not-seeded-error-on-docker-installations"></a>

### Docker 安装上出现 PRNG 未播种错误

- 影响：Docker
- 受影响版本：18.0.0

如果您在启用了 FIPS 的主机上通过 Docker 安装运行极狐GitLab，
您可能会看到 SSH 密钥生成或 OpenSSH 服务器 (`sshd`) 无法启动，
并出现错误消息：

```plaintext
PRNG is not seeded
```

极狐GitLab 18.0 [将基础镜像从 Ubuntu 22.04 更新到了 24.04](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8928)。
出现此错误的原因是 Ubuntu 24.04 不再[允许 FIPS 主机使用非 FIPS OpenSSL 提供程序](https://github.com/dotnet/dotnet-docker/issues/5849#issuecomment-2324943811)。

要修复此问题，您有几种选择：

- 在主机系统上禁用 FIPS。
- 在极狐GitLab Docker 容器中禁用基于 FIPS 内核的自动检测。
  这可以通过在极狐GitLab 18.0.2 或更高版本中设置 `OPENSSL_FORCE_FIPS_MODE=0` 环境变量来实现。
- 不使用极狐GitLab Docker 镜像，而是在主机上安装[原生 FIPS 软件包](https://packages.gitlab.com/ui/browse/gitlab/gitlab-fips)。

最后一个选项是满足 FIPS 要求的推荐选项。对于旧版安装，
前两个选项可以作为临时措施使用。

<a id="ci-builds-metadata-migration-details"></a>

### CI 构建元数据迁移详情

- 影响：所有安装方式
- 受影响版本：18.7.0

> [!note]
> 自极狐GitLab 18.6 起，新的流水线会专门以新格式写入数据
> （参见 [议题 552065](https://gitlab.com/gitlab-org/gitlab/-/issues/552065)）。
> 此迁移仅将现有数据从旧格式复制到新格式。
> 不会删除任何数据。

未迁移的数据将在未来版本中移除（参见 [史诗 18271](https://gitlab.com/groups/gitlab-org/-/work_items/18271)）。

迁移持续时间与实例中 CI 作业的总数成正比。
作业按从最新到最旧的分区顺序处理，以优先处理近期数据。

您可以通过在较大项目上启用
[自动流水线清理](../../ci/pipelines/settings.md#automatic-pipeline-cleanup)
来减少要迁移的作业数量，以便在升级前删除旧的流水线。

迁移会复制两类数据：

- **作业处理数据**：来自 `.gitlab-ci.yml` 的作业执行配置（例如 `script`、`variables`），
  仅在 Runner 执行作业时需要，UI 或 API 不需要。
- **用户可见的作业数据**：在所有作业数据中，此迁移仅影响作业超时值、
  作业退出代码值、[暴露的产物](../../ci/jobs/job_artifacts.md#link-to-job-artifacts-in-the-merge-request-ui)
  和[环境关联](../../ci/yaml/_index.md#environment)。

对于具有大型 CI 数据集的极狐GitLab 私有化部署实例，您可以通过
缩小要迁移的数据范围来加快迁移速度。要控制范围，请使用下面定义的设置。

<a id="controlling-the-scope-for-jobs-processing-data"></a>

#### 控制作业处理数据的范围

默认情况下，迁移会复制所有现有作业的处理数据。
您可以使用下面描述的设置之一来缩小范围。

该设置的值控制您希望保留多少作业处理数据。
例如，如果您只期望执行最近 6 个月内创建的作业
（通过[重试](../../ci/jobs/_index.md#retry-jobs)、
[执行手动作业](../../ci/jobs/job_control.md#create-a-job-that-must-be-run-manually)、
[环境自动停止](../../ci/environments/_index.md#stopping-an-environment)），
请将其设置为 `6mo`。

极狐GitLab 按以下优先级顺序查找设置：

1. [流水线归档](../../administration/settings/continuous_integration.md#archive-pipelines)设置（推荐的最佳实践）。
   已归档的流水线表示作业无法手动重试或重新运行。
   如果启用了此设置，则无需迁移已归档作业的处理数据。

   > [!note]
   > 如果流水线归档范围后来被延长，
   > 没有处理数据的作业将保持不可执行状态。
1. `GITLAB_DB_CI_JOBS_PROCESSING_DATA_CUTOFF` [环境变量](../../administration/environment_variables.md)，
   如果未配置流水线归档，或需要为此迁移覆盖该设置。它接受持续时间字符串，
   例如 `1y`（1 年）、`6mo`（6 个月）、`90d`（90 天）。
1. `GITLAB_DB_CI_JOBS_MIGRATION_CUTOFF` 环境变量，如果以上均未设置。它接受持续时间
   字符串，例如 `1y`（1 年）、`6mo`（6 个月）、`90d`（90 天）。
   请参见[控制用户可见作业数据的范围](#controlling-the-scope-for-job-data-visible-to-users)。
1. 如果未找到任何配置，则复制所有数据。

<a id="controlling-the-scope-for-job-data-visible-to-users"></a>

#### 控制用户可见作业数据的范围

环境变量 `GITLAB_DB_CI_JOBS_MIGRATION_CUTOFF` 控制哪些作业的
可见数据将被迁移。

例如，`GITLAB_DB_CI_JOBS_MIGRATION_CUTOFF=1y` 会复制最近一年内作业的
受影响可见数据（超时值、环境、退出代码和暴露产物的元数据）。

默认情况下，没有截止日期，所有作业的数据都会被迁移。

<a id="estimating-migration-impact"></a>

#### 估算迁移影响

作为参考，对于 JihuLab.com，我们预计在约 2 个月内迁移 4 亿行数据。

要估算迁移对您实例的影响，您可以在
[PostgreSQL 控制台](../../administration/troubleshooting/postgresql.md#start-a-database-console)中运行以下查询：

{{< tabs >}}

{{< tab title="Table size" >}}

```sql
SELECT n.nspname AS schema_name, c.relname AS partition_name,
       pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_inherits i
JOIN pg_class c ON c.oid = i.inhrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_class p ON p.oid = i.inhparent
WHERE p.relname = 'p_ci_builds_metadata'
ORDER BY pg_total_relation_size(c.oid) DESC;
```

新表大约需要此空间的 20%。

{{< /tab >}}

{{< tab title="Job count estimate" >}}

这是来自 PostgreSQL 统计表的估算值。

```sql
SELECT SUM(c.reltuples)::bigint AS estimated_jobs_count
FROM pg_class c
JOIN pg_inherits i ON c.oid = i.inhrelid
WHERE i.inhparent = 'p_ci_builds'::regclass;
```

{{< /tab >}}

{{< tab title="Jobs by timeframe" >}}

要查找在特定时间范围内创建的作业数量，我们需要查询这些表：

```sql
SELECT COUNT(*) FROM p_ci_builds WHERE created_at >= now() - '1 year'::interval;
```

如果查询超时，请使用 [Rails 控制台](../../administration/operations/rails_console.md)
对数据进行批量处理：

```ruby
counts = []
CommitStatus.each_batch(of: 25000) do |batch|
  counts << batch.where(created_at: 1.year.ago...).count
end
counts.sum
```

{{< /tab >}}

{{< /tabs >}}

<a id="batched-background-migration-for-merge-request-merge-data"></a>

### 合并请求合并数据的批量后台迁移

- 影响：所有安装方式
- 受影响版本：18.8.0

一个[批量后台迁移](../background_migrations.md)会将合并请求合并相关数据
从 `merge_requests` 表复制到新的专用 `merge_requests_merge_data` 表。

此迁移是数据库模式优化计划的一部分，旨在将合并特定属性规范化到
单独的表中，从而提高查询性能和可维护性。

<a id="what-data-is-migrated"></a>

#### 迁移哪些数据

迁移会将以下列从 `merge_requests` 复制到 `merge_requests_merge_data`：

- `merge_commit_sha`
- `merged_commit_sha`
- `merge_ref_sha`
- `squash_commit_sha`
- `in_progress_merge_commit_sha`
- `merge_status`
- `auto_merge_enabled`
- `squash`
- `merge_user_id`
- `merge_params`
- `merge_error`
- `merge_jid`

迁移会处理 `merge_requests` 表，仅复制在
`merge_requests_merge_data` 中还没有对应条目的合并请求的数据。

自极狐GitLab 18.7 起，新的合并请求会通过应用程序级别的双写机制
同时写入两个表（参见 [议题](https://gitlab.com/gitlab-org/gitlab/-/issues/560933)）。
此迁移仅复制在双写实现后尚未创建或修改的现有数据。

此迁移期间不会从 `merge_requests` 表中删除任何数据。

该迁移计划在极狐GitLab 18.9 中完成。更多信息，请参见
[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/584459)。

<a id="estimating-migration-duration"></a>

#### 估算迁移持续时间

迁移持续时间与实例中合并请求的数量成正比。

要估算影响：

**PostgreSQL 查询：**

```sql
-- Count total merge requests
SELECT COUNT(*) FROM merge_requests;

-- Estimate table size
SELECT pg_size_pretty(pg_total_relation_size('merge_requests')) AS table_size;
```

**Rails 控制台：**

```ruby
# Count total merge requests
MergeRequest.count

# Count remaining merge requests to migrate
MergeRequest.left_joins(:merge_data)
  .where(merge_requests_merge_data: { merge_request_id: nil })
  .count
```

迁移会分批处理合并请求，对于大多数实例，应在数小时到数天内完成。

<a id="postgresql-version-177-upgrade-on-gitlab-1811"></a>

### 极狐GitLab 18.11 上的 PostgreSQL 17.7 版本升级

- 影响：Linux package、Docker、Geo
- 受影响版本：18.11.0

升级到极狐GitLab 18.11 会触发单节点 Linux package 安装自动升级到
[PostgreSQL 17.7](../../administration/package_information/postgresql_versions.md)。

> [!warning]
> 自动数据库版本升级仅适用于使用 Linux package 的单节点实例。
> 对于 Geo 部署，PostgreSQL 升级必须[经过周密计划和安排](../../administration/geo/replication/upgrading_the_geo_sites.md)，
> 因为主要版本升级需要重新初始化到 Geo 从站点的 PostgreSQL 复制。
> 这可能会导致比预期更长的停机时间。

<a id="sidekiq-concurrency-limiter-causes-job-backlogs-on-helm-chart-and-operator-deployments"></a>

### Sidekiq 并发限制器导致 Helm chart 和 Operator 部署出现作业积压

- 影响：Helm chart、Operator
- 受影响版本：

  | 版本 | 受影响的补丁版本 | 已修复补丁级别 |
  | ------- | ----------------------- | ----------------- |
  | 18.10   | 18.10.0 - 18.10.3      | 18.10.4           |
  | 18.9    | 18.9.0 - 18.9.5        | 18.9.6            |

在极狐GitLab 18.9 中，GitLab Helm chart 开始默认设置
`GITLAB_SIDEKIQ_MAX_REPLICAS`
（[charts/GitLab 合并请求 4348](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/4348)）。
在不使用基于 KEDA 的自动扩缩的极狐GitLab 私有化部署环境中，
这会导致 Sidekiq 并发限制器意外激活，并将作业推迟到
由 Redis 支持的限流队列中。

这可能导致：

- Sidekiq 作业积压。
- Redis 内存增长。
- 作业执行延迟。
- 影响诸如 `WebHookWorker`、`AuditEvents::AuditEventStreamingWorker`
  和 Geo 复制工作进程（`Geo::EventWorker`、`Geo::SyncWorker`）等工作进程。

如果您受到影响，在升级到已修复版本之前，可以使用以下临时缓解措施之一：

- 通过启用功能标志来禁用特定工作进程的并发限制器。
  通过在 Sidekiq Pod 上运行 `exec` 打开 Rails 控制台：

  ```shell
  kubectl exec -it <sidekiq-pod-name> -- gitlab-rails console
  ```

  然后为受影响的工作进程启用标志：

  ```ruby
  Feature.enable(:"disable_sidekiq_concurrency_limit_middleware_<WorkerClass>")
  ```

  将 `<WorkerClass>` 替换为受影响的工作进程名称（例如 `WebHookWorker`）。

- 通过在 Sidekiq Pod 环境配置中设置 `GITLAB_SIDEKIQ_MAX_REPLICAS=0`
  来禁用所有默认并发限制。这会完全禁用默认并发限制计算。

> [!warning]
> 如果您使用 Geo，从站点上已被限流的作业可能无法自动排空，
> 因为 `ConcurrencyLimit::ResumeWorker` 不会在 Geo 从站点上运行。您可能需要
> 手动干预以清除限流队列。

将默认并发限制计算置于功能标志之后的修复已合入
[合并请求 230713](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/230713)，并
向后移植到 18.10.4（[合并请求 231085](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/231085)）
和 18.9.6（[合并请求 231297](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/231297)）。

<a id="secret-detection-false-positive-detection-enabled-by-default-on-all-projects"></a>

### 所有项目默认启用密钥检测误报检测

- 影响：所有安装方式
- 受影响版本：18.10.x

为[密钥误报检测](../../user/application_security/vulnerabilities/false_positive_detection.md)
启用内置任务流通常需要两个步骤：

1. 为群组允许内置任务流。
1. 为各个项目启用内置任务流。

但是，升级到任何极狐GitLab 18.10 版本都会为所有项目启用密钥误报检测的内置任务流。
在为群组允许内置任务流后，它已经为该群组中的所有项目启用。

在为群组允许密钥误报检测的内置任务流之前，您应该检查该群组中项目的设置。

<a id="compiled-per-job-config-is-subject-to-a-1-mib-size-limit"></a>

### 编译后的单作业配置受 1 MiB 大小限制

- 影响：所有安装方式
- 受影响版本：

  | 版本 | 受影响的补丁版本 | 已修复补丁级别 |
  | ------- | ----------------------- | ----------------- |
  | 18.11   | 18.11.x                 | 未修复         |
  | 19.0    | 19.0.0 至 19.0.5         | 19.0.6            |
  | 19.1    | 19.1.0 至 19.1.3         | 19.1.4            |
  | 19.2    | 19.2.0 至 19.2.1         | 19.2.2            |

[一项强制执行 JSON 模式验证的变更现在也强制执行编译后的单作业配置的 1 MiB 大小限制](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/218219)。当作业的编译后配置（其选项、YAML 变量、令牌、密钥等）超过此限制时，流水线创建会失败，并出现：`Failed to persist the pipeline: Validation failed: Config is too large. Maximum size allowed is 1 MiB`。变通方法是将作业配置的大小减小到 1 MiB 以下。

升级到已修复版本后，[大小限制](../../administration/cicd/limits.md#maximum-size-of-the-entire-cicd-configuration)可通过 `ci_max_total_yaml_size_bytes` 应用程序设置进行配置。
