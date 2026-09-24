---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 MySQL
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

许多应用程序依赖 MySQL 作为其数据库，您可能需要在测试中使用它。

<a id="use-mysql-with-the-docker-executor"></a>

## 使用 MySQL 与 Docker 执行器

如果您想使用 MySQL 容器，可以使用 [极狐GitLab Runner](../runners/_index.md) 与 Docker 执行器。

此示例展示了如何设置极狐GitLab 用于访问 MySQL 容器的用户名和密码。如果不设置用户名和密码，则必须使用 `root`。

> [!note]
> 在极狐GitLab UI 中设置的变量不会传递到服务容器。
> 更多信息，请参见 [极狐GitLab CI/CD 变量](../variables/_index.md)。

1. 要指定 MySQL 镜像，请将以下内容添加到 `.gitlab-ci.yml` 文件中：

   ```yaml
   services:
     - mysql:latest
   ```

   - 您可以使用 [Docker Hub](https://hub.docker.com/_/mysql/) 上提供的任何 Docker 镜像。
     例如，要使用 MySQL 5.5，请使用 `mysql:5.5`。
   - `mysql` 镜像可以接受环境变量。更多信息，请查看 [Docker Hub 文档](https://hub.docker.com/_/mysql/)。

1. 要包含数据库名称和密码，请将以下内容添加到 `.gitlab-ci.yml` 文件中：

   ```yaml
   variables:
     # 配置 mysql 环境变量 (https://hub.docker.com/_/mysql/)
     MYSQL_DATABASE: $MYSQL_DB
     MYSQL_ROOT_PASSWORD: $MYSQL_PASS
   ```

   MySQL 容器使用 `MYSQL_DATABASE` 和 `MYSQL_ROOT_PASSWORD` 连接数据库。
   通过使用 [极狐GitLab CI/CD 变量](../variables/_index.md)（上例中的 `$MYSQL_DB` 和 `$MYSQL_PASS`）传递这些值，[而不是直接调用它们](https://jihulab.com/gitlab-cn/gitlab/-/issues/30178)。

1. 配置您的应用程序以使用数据库，例如：

   ```yaml
   Host: mysql
   User: runner
   Password: <your_mysql_password>
   Database: <your_mysql_database>
   ```

   在此示例中，用户是 `runner`。您应该使用有权访问数据库的用户。

<a id="use-mysql-with-the-shell-executor"></a>

## 使用 MySQL 与 Shell 执行器

您也可以在手动配置的服务器上使用 MySQL，这些服务器使用带有 Shell 执行器的极狐GitLab Runner。

1. 安装 MySQL 服务器：

   ```shell
   sudo apt-get install -y mysql-server mysql-client libmysqlclient-dev
   ```

1. 选择一个 MySQL root 密码，并在提示时输入两次。

   > [!note]
   > 作为一项安全措施，您可以运行 `mysql_secure_installation` 来
   > 删除匿名用户、删除测试数据库并禁用 root 用户的
   > 远程登录。

1. 以 root 身份登录 MySQL 来创建用户：

   ```shell
   mysql -u root -p
   ```

1. 创建一个用户（本例中为 `runner`），供您的应用程序使用。将命令中的 `$password` 更改为强密码。

   在 `mysql>` 提示符下，键入：

   ```sql
   CREATE USER 'runner'@'localhost' IDENTIFIED BY '$password';
   ```

1. 创建数据库：

   ```sql
   CREATE DATABASE IF NOT EXISTS `<your_mysql_database>` DEFAULT CHARACTER SET `utf8` \
   COLLATE `utf8_unicode_ci`;
   ```

1. 授予数据库的必要权限：

   ```sql
   GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, DROP, INDEX, ALTER, LOCK TABLES ON `<your_mysql_database>`.* TO 'runner'@'localhost';
   ```

1. 如果一切顺利，您可以退出数据库会话：

   ```shell
   \q
   ```

1. 连接到新创建的数据库以检查一切是否就绪：

   ```shell
   mysql -u runner -p -D <your_mysql_database>
   ```

1. 配置您的应用程序以使用数据库，例如：

   ```shell
   Host: localhost
   User: runner
   Password: $password
   Database: <your_mysql_database>
   ```

<a id="example-project"></a>

## 示例项目

要查看 MySQL 示例，请派生此 [示例项目](https://jihulab.com/gitlab-cn/gitlab-examples/mysql)。
此项目使用 [JihuLab.com](https://jihulab.com) 上公开可用的 [实例 runners](../runners/_index.md)。
更新 README.md 文件，提交更改，并查看 CI/CD 流水线以查看其运行情况。