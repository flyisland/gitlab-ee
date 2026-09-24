---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 为 Auto DevOps 升级 PostgreSQL
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当 `POSTGRES_ENABLED` 为 `true` 时，Auto DevOps 会为你的应用提供一个[集群内 PostgreSQL 数据库](customize.md#postgresql-database-support)。

用于供应 PostgreSQL 的 chart 版本：

- 可以从 0.7.1 设置到 8.2.1。

极狐GitLab 鼓励用户将其数据库迁移到更新的 PostgreSQL chart。

本指南提供了如何迁移 PostgreSQL 数据库的说明，其中包括：

1. 对你的数据进行数据库转储。
1. 使用较新的 chart 版本 8.2.1 安装新的 PostgreSQL 数据库，并移除旧的 PostgreSQL 安装。
1. 将数据库转储恢复到新的 PostgreSQL 中。

<a id="prerequisites"></a>

## 前提条件

1. 安装 [`kubectl`](https://kubernetes.io/docs/tasks/tools/)。
1. 确保你可以使用 `kubectl` 访问 Kubernetes 集群。具体操作因 Kubernetes 提供商而异。
1. 准备停机时间。以下步骤包括将应用下线，以便在创建数据库转储后，集群内数据库不会被修改。
1. 确保未将 `POSTGRES_ENABLED` 设置为 `false`，因为此设置会删除任何现有的通道 1 数据库。

> [!note]
> 如果你已将 Auto DevOps 配置为具有预发布环境，
> 考虑先在预发布环境上尝试备份和恢复步骤，或者
> 在测试应用上尝试。

<a id="take-your-application-offline"></a>

## 将应用下线

如果需要，将应用下线以阻止在创建数据库转储后数据库被修改。

1. 获取环境的 Kubernetes 命名空间。通常格式为 `<项目名>-<项目ID>-<环境>`。
   在本例中，命名空间名为 `minimal-ruby-app-4349298-production`。

   ```shell
   $ kubectl get ns

   NAME                                                  STATUS   AGE
   minimal-ruby-app-4349298-production                   Active   7d14h
   ```

1. 为方便使用，导出命名空间名称：

   ```shell
   export APP_NAMESPACE=minimal-ruby-app-4349298-production
   ```

1. 使用以下命令获取应用的部署名称。在本例中，部署名称为 `production`。

   ```shell
   $ kubectl get deployment --namespace "$APP_NAMESPACE"
   NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
   production            2/2     2            2           7d21h
   production-postgres   1/1     1            1           7d21h
   ```

1. 要阻止数据库被修改，请使用以下命令将部署的副本数设置为 0。
   我们使用上一步中的部署名称（`deployments/<DEPLOYMENT_NAME>`）。

   ```shell
   $ kubectl scale --replicas=0 deployments/production --namespace "$APP_NAMESPACE"
   deployment.extensions/production scaled
   ```

1. 如果有 worker，也必须将它们的副本数设置为零。

<a id="backup"></a>

## 备份

1. 获取 PostgreSQL 的服务名称。服务名称应以 `-postgres` 结尾。在本例中，服务名为 `production-postgres`。

   ```shell
   $ kubectl get svc --namespace "$APP_NAMESPACE"
   NAME                     TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
   production-auto-deploy   ClusterIP   10.30.13.90   <none>        5000/TCP   7d14h
   production-postgres      ClusterIP   10.30.4.57    <none>        5432/TCP   7d14h
   ```

1. 使用以下命令获取 PostgreSQL 的 Pod 名称。在本例中，Pod 名称为 `production-postgres-5db86568d7-qxlxv`。

   ```shell
   $ kubectl get pod --namespace "$APP_NAMESPACE" -l app=production-postgres
   NAME                                   READY   STATUS    RESTARTS   AGE
   production-postgres-5db86568d7-qxlxv   1/1     Running   0          7d14h
   ```

1. 连接到 Pod：

   ```shell
   kubectl exec -it production-postgres-5db86568d7-qxlxv --namespace "$APP_NAMESPACE" -- bash
   ```

1. 连接后，使用以下命令创建转储文件。

   - `SERVICE_NAME` 是前面步骤中获取的服务名称。
   - `USERNAME` 是你为 PostgreSQL 配置的用户名，默认为 `user`。
   - `DATABASE_NAME` 通常是环境名称。

   - 当提示输入数据库密码时，默认密码为 `testing-password`。

     ```shell
     ## 格式为：
     # pg_dump -h SERVICE_NAME -U USERNAME DATABASE_NAME > /tmp/backup.sql

     pg_dump -h production-postgres -U user production > /tmp/backup.sql
     ```

1. 备份转储完成后，按 <kbd>Control</kbd>-<kbd>D</kbd> 或输入 `exit` 退出 Kubernetes exec 进程。
1. 使用以下命令下载转储文件：

   ```shell
   kubectl cp --namespace "$APP_NAMESPACE" production-postgres-5db86568d7-qxlxv:/tmp/backup.sql backup.sql
   ```

<a id="retain-persistent-volumes"></a>

## 保留持久卷

默认情况下，当使用卷的 Pod 和 Pod 声明被删除时，用于存储 PostgreSQL 底层数据的[持久卷](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)会被标记为 `Delete`。

这一点很重要，因为当你选择使用较新的 8.2.1 PostgreSQL 时，旧的 0.7.1 PostgreSQL 会被删除，从而导致持久卷也被删除。

你可以使用以下命令验证这一点：

```shell
$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                                     STORAGECLASS   REASON   AGE
pvc-0da80c08-5239-11ea-9c8d-42010a8e0096   8Gi        RWO            Delete           Bound    minimal-ruby-app-4349298-staging/staging-postgres         standard                7d22h
pvc-9085e3d3-5239-11ea-9c8d-42010a8e0096   8Gi        RWO            Delete           Bound    minimal-ruby-app-4349298-production/production-postgres   standard                7d22h
```

要保留持久卷，即使旧的 0.7.1 PostgreSQL 被删除，也将保留策略更改为 `Retain`。在本例中，通过查看声明名称来找到持久卷名称。要保留 `minimal-ruby-app-4349298` 应用的预发布环境和生产环境的卷，卷名称为 `pvc-0da80c08-5239-11ea-9c8d-42010a8e0096` 和 `pvc-9085e3d3-5239-11ea-9c8d-42010a8e0096`：

```shell
$ kubectl patch pv  pvc-0da80c08-5239-11ea-9c8d-42010a8e0096 -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
persistentvolume/pvc-0da80c08-5239-11ea-9c8d-42010a8e0096 patched
$ kubectl patch pv  pvc-9085e3d3-5239-11ea-9c8d-42010a8e0096 -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
persistentvolume/pvc-9085e3d3-5239-11ea-9c8d-42010a8e0096 patched
$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                                     STORAGECLASS   REASON   AGE
pvc-0da80c08-5239-11ea-9c8d-42010a8e0096   8Gi        RWO            Retain           Bound    minimal-ruby-app-4349298-staging/staging-postgres         standard                7d22h
pvc-9085e3d3-5239-11ea-9c8d-42010a8e0096   8Gi        RWO            Retain           Bound    minimal-ruby-app-4349298-production/production-postgres   standard                7d22h
```

<a id="install-new-postgresql"></a>

## 安装新 PostgreSQL

> [!warning]
> 使用较新版本的 PostgreSQL 会删除
> 旧的 0.7.1 PostgreSQL。要防止底层数据被
> 删除，你可以选择[保留持久卷](#retain-persistent-volumes)。

你还可以修改以下步骤，将 `AUTO_DEVOPS_POSTGRES_CHANNEL`、`AUTO_DEVOPS_POSTGRES_DELETE_V1` 和
`POSTGRES_VERSION` 变量的作用域[限定](../../ci/environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)到特定环境，例如 `staging`。

1. 将 `AUTO_DEVOPS_POSTGRES_CHANNEL` 设置为 `2`。这将选择使用
   较新的基于 8.2.1 的 PostgreSQL，并移除旧的基于 0.7.1 的
   PostgreSQL。
1. 将 `AUTO_DEVOPS_POSTGRES_DELETE_V1` 设置为非空值。此标志是一个
   安全措施，以防止意外删除数据库。
   <!-- 升级极狐GitLab支持版本时请勿替换此处。这与极狐GitLab的PostgreSQL版本支持无关，而是与Auto DevOps部署的版本有关。 -->
1. 如果已设置 `POSTGRES_VERSION`，请确保它设置为 `9.6.16` 或更高版本。这是
   Auto DevOps 支持的最低 PostgreSQL 版本。另请参阅[可用标签](https://hub.docker.com/r/bitnami/postgresql/tags)列表。
1. 将 `PRODUCTION_REPLICAS` 设置为 `0`。对于其他环境，使用带有[环境作用域](../../ci/environments/_index.md#limit-the-environment-scope-of-a-cicd-variable)的 `REPLICAS`。
1. 如果已设置 `DB_INITIALIZE` 或 `DB_MIGRATE` 变量，请
   移除这些变量，或将变量名称临时更改为
   `XDB_INITIALIZE` 或 `XDB_MIGRATE` 以有效禁用它们。
1. 为分支运行新的 CI 流水线。在本例中，为 `main` 分支运行新的 CI
   流水线。
1. 流水线成功后，你的应用已升级，
   并安装了新的 PostgreSQL。此时副本数为零，因此
   你的应用不会提供任何流量（以防止
   新数据进入）。

<a id="restore"></a>

## 恢复

1. 获取新 PostgreSQL 的 Pod 名称，在本例中，Pod 名称为
   `production-postgresql-0`：

   ```shell
   $ kubectl get pod --namespace "$APP_NAMESPACE" -l app=postgresql
   NAME                      READY   STATUS    RESTARTS   AGE
   production-postgresql-0   1/1     Running   0          19m
   ```

1. 将备份步骤中的转储文件复制到 Pod：

   ```shell
   kubectl cp --namespace "$APP_NAMESPACE" backup.sql production-postgresql-0:/tmp/backup.sql
   ```

1. 连接到 Pod：

   ```shell
   kubectl exec -it production-postgresql-0 --namespace "$APP_NAMESPACE" -- bash
   ```

1. 连接到 Pod 后，运行以下命令恢复数据库。

   - 当要求输入数据库密码时，默认密码是 `testing-password`。
   - `USERNAME` 是你为 PostgreSQL 配置的用户名，默认为 `user`。
   - `DATABASE_NAME` 通常是环境名称。

   ```shell
   ## 格式为：
   # psql -U USERNAME -d DATABASE_NAME < /tmp/backup.sql

   psql -U user -d production < /tmp/backup.sql
   ```

1. 恢复完成后，你现在可以检查数据是否正确恢复。你可以使用
   `psql` 对数据进行抽查。

<a id="reinstate-your-application"></a>

## 恢复应用运行

一旦你对数据库已恢复感到满意，运行以下
步骤以恢复应用运行：

1. 如果之前移除或禁用了 `DB_INITIALIZE` 和 `DB_MIGRATE` 变量，请恢复它们。
1. 将 `PRODUCTION_REPLICAS` 或 `REPLICAS` 变量恢复为其原始值。
1. 为分支运行新的 CI 流水线。在本例中，为 `main` 分支运行新的 CI
   流水线。流水线成功后，你的
   应用应该像以前一样正常提供服务。