---
stage: Security Platform
group: Secrets Manager OpenBao
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 维护 OpenBao
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Status: 测试版

{{< /details >}}

有关 Geo 故障转移，请参阅 [Geo 灾难恢复](../geo/disaster_recovery/_index.md#step-4-optional-promote-the-openbao-ha-cluster)。

<a id="back-up-and-restore-openbao"></a>

## 备份和恢复 OpenBao

OpenBao 将数据存储在 PostgreSQL 上独立的逻辑数据库中。请将此数据库与常规的极狐GitLab 备份一起备份，以便在发生故障后恢复密钥。

有关 OpenBao 专用的详细备份和恢复步骤，请参阅
[OpenBao 备份文档](https://gitlab.cn/docs/charts/charts/openbao/#back-up-openbao)。

<a id="recovery-key-management"></a>

## 恢复密钥管理

有关管理 OpenBao 恢复密钥的信息，包括存储、查看以及使用它生成根令牌，请参阅[恢复密钥管理](recovery_key.md)。

<a id="recover-openbao-authentication"></a>

## 恢复 OpenBao 认证

极狐GitLab 使用 JSON Web Token (JWT) 向 OpenBao 进行认证。只有当 JWT 的
`iss`（签发者）和 `aud`（受众）声明与 OpenBao 存储的值匹配时，OpenBao 才会接受该 JWT。OpenBao 会在初始化时，以及您为每个项目和群组开启密钥管理器时存储这些值。当您之后更改配置时，OpenBao 不会更新已存储的值。

在以下情况下认证会失败：

- JWT 受众不匹配：极狐GitLab 发送的受众与 OpenBao 存储的受众不同，例如在 OpenBao URL 更改之后。要修复此不匹配，请[恢复 JWT 受众](#restore-the-jwt-audience)。
- JWT 签发者不匹配：在 OpenBao 初始化之后极狐GitLab URL 发生了更改。要修复此不匹配，请[恢复 JWT 签发者](#restore-the-jwt-issuer)。

根令牌无法修复认证问题，因为
`gitlab:secrets_management:openbao:root_token:generate` 是使用极狐GitLab JWT 向 OpenBao 进行认证的。

如果您无法恢复受众或签发者，请[重置 OpenBao 数据](#reset-openbao-data)。重置会删除所有已存储的密钥。

<a id="find-the-stored-jwt-audience"></a>

### 查找已存储的 JWT 受众

已存储的受众是 OpenBao 首次初始化时的 OpenBao URL。

要查找已存储的 JWT 受众：

1. 查找候选值。如果您在之前的恢复中设置了 `global.openbao.jwt_audience`，该值就是已存储的受众。请在下一步中检查该值。

   否则，请列出候选值。Helm 会保留近期 chart 修订版本的渲染配置，因此请列出每个修订版本的 `bound_audiences` 值：

   ```shell
   for revision in $(helm history gitlab -n gitlab | awk 'NR > 1 { print $1 }'); do
     echo "$revision: $(helm get manifest gitlab -n gitlab --revision "$revision" | grep -o '"bound_audiences": "[^"]*"')"
   done
   ```

   每个不同的值都是一个候选值。默认情况下，Helm 会保留最近 10 个修订版本。如果 OpenBao 是在更早的修订版本中首次初始化的，该列表可能不包含已存储的受众。

1. 检查每个候选值。在 [Rails 控制台](../operations/rails_console.md)中，将
   `<candidate_audience>` 替换为候选值并运行：

   ```ruby
   jwt = SecretsManagement::GlobalSecretsManagerJwt.new(aud: '<candidate_audience>').encoded
   SecretsManagement::SecretsManagerClient.new(jwt: jwt).generate_root_token_status
   ```

   如果 OpenBao 存储了此受众，第二条命令会无错误返回。否则，OpenBao 会以 `invalid audience (aud) claim` 拒绝该 JWT。如果 OpenBao 改为以
   `invalid issuer (iss) claim` 拒绝该 JWT，请先[恢复 JWT 签发者](#restore-the-jwt-issuer)。

<a id="restore-the-jwt-audience"></a>

### 恢复 JWT 受众

当极狐GitLab 发送的受众与 OpenBao 存储的受众不同时，请恢复 JWT 受众。

先决条件：

- OpenBao 存储的受众。有关更多信息，请参阅
  [查找已存储的 JWT 受众](#find-the-stored-jwt-audience)。

要恢复 JWT 受众：

1. 在您的 Helm values 文件中，将 `global.openbao.jwt_audience` 设置为已存储的受众。例如：

   ```yaml
   global:
     openbao:
       jwt_audience: https://openbao.example.com
   ```

1. 重新部署极狐GitLab：

   ```shell
   helm upgrade --install --version <chart-version> gitlab gitlab/gitlab \
     -n gitlab -f gitlab.yaml
   ```

极狐GitLab pod 重启后，极狐GitLab 会再次向 OpenBao 进行认证。

<a id="restore-the-jwt-issuer"></a>

### 恢复 JWT 签发者

当 OpenBao 初始化之后极狐GitLab URL 发生更改时，请恢复 JWT 签发者。OpenBao 期望以当时的极狐GitLab URL 作为签发者，因此您必须将极狐GitLab URL 改回。

要恢复 JWT 签发者：

1. 在您的 Helm values 文件中，将极狐GitLab 主机设置改回 OpenBao 首次初始化时的值。有关更多信息，请参阅
   [配置主机设置](https://gitlab.cn/docs/charts/charts/globals/#configure-host-settings)。

1. 重新部署极狐GitLab：

   ```shell
   helm upgrade --install --version <chart-version> gitlab gitlab/gitlab \
     -n gitlab -f gitlab.yaml
   ```

极狐GitLab pod 重启后，极狐GitLab 会再次向 OpenBao 进行认证。

<a id="reset-openbao-data"></a>

## 重置 OpenBao 数据

> [!warning]
> 此过程会永久删除 OpenBao 中存储的所有密钥和密钥权限，并关闭每个项目和群组的密钥管理器。

重置 OpenBao 数据会清空 OpenBao 数据库，以便 OpenBao 使用您的 Helm values 中的配置自行初始化。

先决条件：

- 配置中正确的 OpenBao URL。OpenBao 在自行初始化期间会从该 URL 推导出 `bound_audiences`。
- `global.openbao.jwt_audience` 设置为相同的 URL，或未设置。

要重置 OpenBao 数据：

1. 将 OpenBao 缩容到零个副本：

   ```shell
   kubectl -n gitlab scale deployment gitlab-openbao --replicas=0
   kubectl -n gitlab wait --for=delete pod -l app.kubernetes.io/name=openbao --timeout=120s
   ```

1. 获取 toolbox pod 名称：

   ```shell
   kubectl -n gitlab get pods -l app=toolbox -o jsonpath='{.items[0].metadata.name}'
   ```

1. 清空 OpenBao 存储表。将占位符替换为您的 OpenBao 数据库密码和主机：

   ```shell
   kubectl -n gitlab exec -ti <toolbox-pod-name> -- \
     env PGPASSWORD='<openbao_database_password>' \
     psql -h <postgres_host> -U openbao -d openbao \
     -c "TRUNCATE TABLE openbao_kv_store; TRUNCATE TABLE openbao_ha_locks;"
   ```

1. 从极狐GitLab 数据库中删除密钥管理器记录和已存储的恢复密钥。旧的恢复密钥将不再有效，并且在旧密钥仍被存储时您无法创建新密钥。
   在 [Rails 控制台](../operations/rails_console.md)中，运行：

   ```ruby
   ApplicationRecord.connection.execute(<<~SQL)
     TRUNCATE TABLE project_secrets_managers, project_secrets_manager_maintenance_tasks,
       group_secrets_managers, group_secrets_manager_maintenance_tasks,
       secret_rotation_infos, group_secret_rotation_infos, namespace_secret_counts
   SQL
   SecretsManagement::RecoveryKey.active.destroy_all
   ```

   请使用 `TRUNCATE`，而不是逐个关闭密钥管理器。关闭密钥管理器会调用 OpenBao 删除上一步已经删除的数据。

1. 在将自动扩缩设置为单个 OpenBao 副本的情况下重新部署 OpenBao。`openbao.autoscaling`
   设置会阻止 Horizontal Pod Autoscaler 在初始化完成之前添加第二个副本：

   ```shell
   helm upgrade --install --version <chart-version> gitlab gitlab/gitlab \
     -n gitlab -f gitlab.yaml \
     --set openbao.autoscaling.minReplicas=1 --set openbao.autoscaling.maxReplicas=1
   ```

1. 将 OpenBao 扩容到一个副本。重新部署 chart 不会恢复您手动缩容的部署：

   ```shell
   kubectl -n gitlab scale deployment gitlab-openbao --replicas=1
   kubectl -n gitlab rollout status deployment gitlab-openbao --timeout=120s
   ```

1. 验证 OpenBao 已初始化且已解封。将 `https://openbao.example.com` 替换为您的
   OpenBao URL：

   ```shell
   curl "https://openbao.example.com/v1/sys/health"
   ```

   响应中包含 `"initialized":true` 和 `"sealed":false`。

1. 在不使用单副本设置的情况下重新部署，然后将 OpenBao 扩容到您通常的副本数。将 `<replica_count>` 替换为 `openbao.autoscaling.minReplicas`的值，该值默认为
   `2`：

   ```shell
   helm upgrade --install --version <chart-version> gitlab gitlab/gitlab \
     -n gitlab -f gitlab.yaml
   kubectl -n gitlab scale deployment gitlab-openbao --replicas=<replica_count>
   kubectl -n gitlab rollout status deployment gitlab-openbao --timeout=120s
   ```

1. 创建新的[恢复密钥](recovery_key.md)。

重置后，请为每个需要它的项目和群组重新开启密钥管理器。

<a id="enable-secrets-access-from-external-requests"></a>

## 启用来自外部请求的密钥访问

在极狐GitLab 19.2 及更高版本中预配的密钥管理器支持[来自外部服务和工具的密钥访问](../../ci/secrets/secrets_manager/non_cicd_access.md)。如果密钥管理器是在极狐GitLab 19.1 或更早版本中为项目或群组预配的，则不支持此访问。

要为在极狐GitLab 19.2 之前预配的密钥管理器启用此访问，您可以：

- 为群组或项目禁用并[重新启用密钥管理器](../../ci/secrets/secrets_manager/_index.md#enable-gitlab-secrets-manager)。

  > [!warning]
  > 如果您禁用群组或项目的密钥管理器，该群组或项目的所有密钥都会被永久删除。这些密钥无法恢复。

- 让管理员运行 `backfill_api_auth` Rake 任务。在 Rake 任务运行期间，密钥管理器会保持活动状态，并且现有密钥会得到保留。

  先决条件：

  - 管理员访问权限。

  要为实例上的每个群组和项目密钥管理器执行回填：

  ```shell
  # Linux package (Omnibus) and Helm chart (Kubernetes)
  sudo gitlab-rake gitlab:secrets_management:backfill_api_auth

  # Self-compiled (source)
  bundle exec rake gitlab:secrets_management:backfill_api_auth RAILS_ENV=production
  ```

  要将回填范围限定为单个顶级群组或用户命名空间，请传入其 ID：

  ```shell
  sudo gitlab-rake "gitlab:secrets_management:backfill_api_auth[<root_namespace_id>]"
  ```

  该任务是幂等的，可以安全地多次运行。如果它报告失败，请修复根本原因（例如，无法访问的 OpenBao 服务器）并再次运行该任务。
