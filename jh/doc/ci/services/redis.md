---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Redis
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

由于许多应用依赖 Redis 作为其键值存储，您必须使用它来运行测试。

<a id="use-redis-with-the-docker-executor"></a>

## 将 Redis 与 Docker 执行器配合使用

如果您将[极狐GitLab Runner](../runners/_index.md) 与 Docker 执行器配合使用，
那么基本上一切都已经设置好了。

首先，在您的 `.gitlab-ci.yml`中添加：

```yaml
services:
  - redis:latest
```

然后，您需要配置应用以使用 Redis 数据库，例如：

```yaml
Host: redis
```

就是这样。现在可以在测试框架中使用 Redis 了。

您也可以使用 [Docker Hub](https://hub.docker.com/_/redis) 上提供的任何其他 Docker 镜像。例如，要使用 Redis 6.0，服务将变为 `redis:6.0`。

<a id="use-redis-with-the-shell-executor"></a>

## 将 Redis 与 Shell 执行器配合使用

Redis 也可以用于使用极狐GitLab Runner 与 Shell 执行器的手动配置服务器上。

在您的构建机器上安装 Redis 服务器：

```shell
sudo apt-get install redis-server
```

验证您能否使用 `gitlab-runner` 用户连接到该服务器：

```shell
# Try connecting the Redis server
sudo -u gitlab-runner -H redis-cli

# Quit the session
127.0.0.1:6379> quit
```

最后，配置您的应用以使用该数据库，例如：

```yaml
Host: localhost
```

<a id="example-project"></a>

## 示例项目

我们为您设置了一个[示例 Redis 项目](https://gitlab.com/gitlab-examples/redis)，它运行在 [GitLab.com](https://gitlab.com) 上，使用我们公开可用的
[实例 Runner](../runners/_index.md)。

想要修改它吗？Fork 它、提交并推送您的更改。片刻之后，公共 Runner 会获取这些更改，作业随即开始。
