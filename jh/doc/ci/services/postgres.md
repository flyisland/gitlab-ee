---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 PostgreSQL
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

由于许多应用都依赖 PostgreSQL 作为其数据库，您必须使用它来运行测试。

<a id="use-postgresql-with-the-docker-executor"></a>

## 将 PostgreSQL 与 Docker 执行器配合使用

要将极狐GitLab UI 中设置的变量传递给服务容器，您必须[定义变量](../variables/_index.md#define-a-cicd-variable-in-the-ui)。您必须将变量定义为群组或项目变量，然后在作业中调用这些变量，如下面的变通方法所示。

Postgres 15.4 及更高版本在扩展脚本包含引号（"）、反斜杠（\）或美元符号（$）时，不会将 schema 或所有者名称替换到扩展脚本中。如果未配置 CI 变量，则该值会改用环境变量名称作为字符串。例如，`POSTGRES_USER: $USER` 会导致 `POSTGRES_USER` 变量被设置为 '$USER'，从而使 Postgres 显示以下错误：

```shell
Fatal: invalid character in extension
```

变通方法是在[极狐GitLab CI/CD 变量](../variables/_index.md)中设置变量，或以字符串形式设置变量：

1. [在极狐GitLab 中设置 Postgres 变量](../variables/_index.md#for-a-project)。在极狐GitLab UI 中设置的变量不会传递给服务容器。
1. 在 `.gitlab-ci.yml` 文件中，指定一个 Postgres 镜像：

   ```yaml
   default:
      services:
        - postgres
   ```

1. 在 `.gitlab-ci.yml` 文件中，添加您定义的变量：

   ```yaml
   variables:
     POSTGRES_DB: $POSTGRES_DB
     POSTGRES_USER: $POSTGRES_USER
     POSTGRES_PASSWORD: $POSTGRES_PASSWORD
     POSTGRES_HOST_AUTH_METHOD: trust
   ```

   有关将 `postgres` 用作 `Host`的更多信息，请参阅[服务如何链接到作业](_index.md#how-services-are-linked-to-the-job)。

1. 配置您的应用以使用该数据库，例如：

   ```yaml
   Host: postgres
   User: $POSTGRES_USER
   Password: $POSTGRES_PASSWORD
   Database: $POSTGRES_DB
   ```

或者，您可以在 `.gitlab-ci.yml` 文件中以字符串形式设置变量：

```yaml
variables:
  POSTGRES_DB: DB_name
  POSTGRES_USER: username
  POSTGRES_PASSWORD: password
  POSTGRES_HOST_AUTH_METHOD: trust
```

您可以使用 [Docker Hub](https://hub.docker.com/_/postgres) 上提供的任何其他 Docker 镜像。例如，要使用 PostgreSQL 16.10，服务应改为 `postgres:16.10`。

`postgres` 镜像可以接受一些环境变量。有关更多详细信息，
请参阅 [Docker Hub](https://hub.docker.com/_/postgres) 上的文档。

<a id="use-postgresql-with-the-shell-executor"></a>

## 将 PostgreSQL 与 Shell 执行器配合使用

您也可以在使用极狐GitLab Runner 和 Shell 执行器的手动配置服务器上使用 PostgreSQL。

首先安装 PostgreSQL 服务器：

```shell
sudo apt-get install -y postgresql postgresql-client libpq-dev
```

下一步是创建用户，因此请登录 PostgreSQL：

```shell
sudo -u postgres psql -d template1
```

然后创建一个用户（在本例中为 `runner`），供您的应用使用。将以下命令中的 `$password` 更改为强密码。

> [!note]
> 请务必不要在以下命令中输入 `template1=#`，因为它是
> PostgreSQL 提示符的一部分。

```shell
template1=# CREATE USER runner WITH PASSWORD '$password' CREATEDB;
```

创建的用户具有创建数据库的权限（`CREATEDB`）。以下步骤介绍如何为该用户显式创建数据库。这些权限允许您的测试框架按需创建和删除数据库。

创建数据库并将该数据库的所有权限授予用户 `runner`：

```shell
template1=# CREATE DATABASE nice_marmot OWNER runner;
```

如果一切顺利，您现在可以退出数据库会话：

```shell
template1=# \q
```

现在，尝试使用用户 `runner` 连接到新创建的数据库，以检查一切是否就绪。

```shell
psql -U runner -h localhost -d nice_marmot -W
```

此命令显式指示 `psql` 连接到 localhost 以使用 md5 认证。如果省略此步骤，您将被拒绝访问。

最后，配置您的应用以使用该数据库，例如：

```yaml
Host: localhost
User: runner
Password: $password
Database: nice_marmot
```

<a id="example-project"></a>

## 示例项目

我们为您设置了一个[示例 PostgreSQL 项目](https://gitlab.com/gitlab-examples/postgres)，它使用我们公开可用的[实例 Runner](../runners/_index.md) 在 [GitLab.com](https://gitlab.com) 上运行。

想要参与改进它吗？Fork 它、提交并推送您的更改。片刻之后，公共 Runner 会获取这些更改，作业随即开始。
