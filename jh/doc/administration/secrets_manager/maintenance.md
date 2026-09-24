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

有关 Geo 故障转移，请参阅
[Geo 灾难恢复](../geo/disaster_recovery/_index.md#step-4-optional-promote-the-openbao-ha-cluster)。

<a id="back-up-and-restore-openbao"></a>

## 备份和恢复 OpenBao

OpenBao 将数据存储在 PostgreSQL 上一个独立的逻辑数据库中。请将此数据库与常规的极狐GitLab 备份一起备份，以便在发生故障后还原其中的密钥。

有关 OpenBao 特定的详细备份和恢复流程，请参阅
[OpenBao 备份文档](https://gitlab.cn/docs/charts/charts/openbao/#back-up-openbao)。

<a id="recovery-key-management"></a>

## 恢复密钥管理

有关管理 OpenBao 恢复密钥的信息，包括存储、查看和使用它来生成根令牌，请参阅[恢复密钥管理](recovery_key.md)。

<a id="recover-openbao-authentication"></a>

## 恢复 OpenBao 身份验证

如果 JWT `aud`（受众）声明与存储的 `bound_audiences` 值发生偏离，您可能需要恢复 OpenBao 身份验证。

首先使用恢复密钥重新配置身份验证，因为它会保留已存储的密钥。仅在万不得已时才重置 OpenBao 数据，因为它会删除所有已存储的密钥。

<a id="reconfigure-authentication-with-a-recovery-key"></a>

### 使用恢复密钥重新配置身份验证

此方法会保留所有已存储的密钥，但需要恢复密钥。

1. 从恢复密钥生成临时根令牌。有关流程，请参阅
   [从恢复密钥生成根令牌](recovery_key.md#generate-a-root-token-from-the-recovery-key)。

1. 读取当前身份验证角色，以便获得其完整配置：

   ```shell
   OPENBAO_POD=$(kubectl get pods -n gitlab -l app.kubernetes.io/name=openbao -o name | head -1)
   kubectl exec -n gitlab "$OPENBAO_POD" -c openbao-server -- \
     sh -c "BAO_ADDR=http://127.0.0.1:8200 BAO_TOKEN=<root_token> bao read auth/gitlab_rails_jwt/role/app"
   ```

1. 使用修正后的 `bound_audiences` 以及上一步中的其他所有字段重新应用该角色。更新时，OpenBao 会将省略的字段重置为其默认值，因此请求必须包含完整配置。重要的是：

   - `role_type` 字段默认为 `oidc`，因此您必须包含 `role_type=jwt`，否则角色会损坏。
   - 如果省略 `claim_mappings` 字段，它会被重置为空，这会破坏授权。请包含上一步返回的相同映射。

   `bound_claims` 和 `claim_mappings` 是映射，因此请使用 `bao write <path> -` 以 JSON 格式在标准输入中提供配置。将 `<your-domain>` 替换为您的 OpenBao 域名，并将 `claim_mappings` 和其他值替换为上一步返回的值：

   ```shell
   kubectl exec -i -n gitlab "$OPENBAO_POD" -c openbao-server -- \
     sh -c "BAO_ADDR=http://127.0.0.1:8200 BAO_TOKEN=<root_token> bao write auth/gitlab_rails_jwt/role/app -" <<'JSON'
   {
     "role_type": "jwt",
     "user_claim": "user_id",
     "bound_subject": "gitlab_secrets_manager",
     "bound_audiences": ["https://openbao.<your-domain>"],
     "token_policies": ["secrets_manager"],
     "bound_claims": {"secrets_manager_scope": "privileged"},
     "claim_mappings": {
       "user_id": "user_id",
       "project_id": "project_id",
       "group_id": "group_id",
       "namespace_id": "namespace_id",
       "correlation_id": "correlation_id"
     }
   }
   JSON
   ```

1. 撤销根令牌。第一步中的流程包含撤销命令。

此流程仅修正根级别的受众。不支持 Geo 故障转移到具有不同域名的从站点，因为这还需要为每个项目和群组重新预配 JWT 身份验证。相反，请更新 DNS，使主域名指向已提升的从站点。有关更多信息，请参阅 [Geo 部署](_index.md#geo-deployment)。

<a id="reset-openbao-data"></a>

### 重置 OpenBao 数据

> [!warning]
> 此流程会永久删除 OpenBao 中存储的所有密钥。完成后，请重新创建所有 Secrets Manager 密钥。

当您没有恢复密钥且 `bound_audiences` 与 JWT `aud` 声明不同步，导致身份验证失败时，请重置 OpenBao 数据。当 OpenBao 使用错误的 URL 初始化时，可能会发生不匹配。重置会清空 OpenBao 数据库，以便 OpenBao 使用正确的配置自行初始化。

如果您有恢复密钥，请改用[使用恢复密钥重新配置身份验证](#reconfigure-authentication-with-a-recovery-key)。该方法会保留已存储的密钥。

开始之前，请在配置中设置正确的受众：

- 对于极狐GitLab 18.10 及更高版本，将 `global.openbao.jwt_audience` 设置为您想要的受众。
- 对于更早的版本，请设置 OpenBao 外部 URL。OpenBao 在自初始化期间会从该 URL 派生 `bound_audiences`。

要重置 OpenBao 数据：

1. 将 OpenBao 缩减到零个副本：

   ```shell
   kubectl -n gitlab scale deployment gitlab-openbao --replicas=0
   kubectl -n gitlab rollout status deployment gitlab-openbao --timeout=60s
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

1. 使用修正后的配置重新部署 OpenBao：

   ```shell
   helm upgrade --install --version <chart-version> gitlab gitlab/gitlab \
     -n gitlab -f gitlab.yaml
   ```

1. 重新扩展 OpenBao。chart 重新部署不会恢复您手动缩减的部署：

   ```shell
   kubectl -n gitlab scale deployment gitlab-openbao --replicas=2
   kubectl -n gitlab rollout status deployment gitlab-openbao --timeout=120s
   ```

1. 验证 OpenBao 已初始化、已解除封印，并使用正确的受众：

   ```shell
   OPENBAO_POD=$(kubectl -n gitlab get pods -l app.kubernetes.io/name=openbao \
     -l openbao-active=true -o jsonpath='{.items[0].metadata.name}')
   kubectl -n gitlab exec -ti "$OPENBAO_POD" -c openbao-server -- \
     sh -c "BAO_ADDR=http://127.0.0.1:8200 bao status"
   kubectl -n gitlab get configmap gitlab-openbao-config -o yaml | grep bound_audiences
   ```

   状态显示 `Initialized   true` 和 `Sealed   false`，并且 `bound_audiences` 值与极狐GitLab 发送的受众匹配。

<a id="enable-secrets-access-from-external-requests"></a>

## 从外部请求启用密钥访问

在极狐GitLab 19.2 及更高版本中预配的 Secrets Manager 支持[从外部服务和工具访问密钥](../../ci/secrets/secrets_manager/non_cicd_access.md)。如果 Secrets Manager 是在极狐GitLab 19.1 或更早版本中为项目或群组预配的，则不支持此访问。

要为在极狐GitLab 19.2 之前预配的 Secrets Manager 启用此访问，您可以：

- 为群组或项目禁用并[重新启用 Secrets Manager](../../ci/secrets/secrets_manager/_index.md#enable-gitlab-secrets-manager)。

  > [!warning]
  > 如果您禁用群组或项目 Secrets Manager，则该群组或项目的所有密钥都将被永久删除。这些密钥无法恢复。

- 让管理员运行 `backfill_api_auth` Rake 任务。Rake 任务运行时 Secrets Manager 保持活动状态，并且现有密钥会被保留。

  先决条件：

  - 管理员访问权限。

  要为实例上的所有群组和项目 Secrets Manager 执行回填：

  ```shell
  # Linux package (Omnibus) and Helm chart (Kubernetes)
  sudo gitlab-rake gitlab:secrets_management:backfill_api_auth

  # Self-compiled (source)
  bundle exec rake gitlab:secrets_management:backfill_api_auth RAILS_ENV=production
  ```

  要将回填范围限定到单个顶级群组或用户命名空间，请传递其 ID：

  ```shell
  sudo gitlab-rake "gitlab:secrets_management:backfill_api_auth[<root_namespace_id>]"
  ```

  该任务是幂等的，可以安全地多次运行。如果它报告失败，请修复根本原因（例如，OpenBao 服务器不可达），然后再次运行该任务。
