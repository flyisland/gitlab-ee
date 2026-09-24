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

由于许多应用程序依赖 Redis 作为其键值存储，你必须使用它来运行测试。

<a id="use-redis-with-the-docker-executor"></a>

## 在 Docker 执行器中使用 Redis

如果你正在使用带有 Docker 执行器的 [极狐GitLab Runner](../runners/_index.md)，你基本上已经设置好了一切。

首先，在你的 `.gitlab-ci.yml` 中添加：

```yaml
services:
  - redis:latest
```

然后你需要配置你的应用程序以使用 Redis 数据库，例如：

```yaml
Host: redis
```

就是这样。Redis 现在可以在你的测试框架中使用了。

你也可以使用 [Docker Hub](https://hub.docker.com/_/redis) 上可用的任何其他 Docker 镜像。例如，要使用 Redis 6.0，服务将变为 `redis:6.0`。

<a id="use-redis-with-the-shell-executor"></a>

## 在 Shell 执行器中使用 Redis

Redis 也可以在手动配置的服务器上使用，这些服务器使用带有 Shell 执行器的极狐GitLab Runner。

在你的构建机器上安装 Redis 服务器：

```shell
sudo apt-get install redis-server
```

验证你可以使用 `gitlab-runner` 用户连接到服务器：

```shell
# 尝试连接 Redis 服务器
sudo -u gitlab-runner -H redis-cli

# 退出会话
127.0.0.1:6379> quit
```

最后，配置你的应用程序以使用数据库，例如：

```yaml
Host: localhost
```

<a id="example-project"></a>

## 示例项目

为了方便起见，我们设置了一个 [示例 Redis 项目](https://gitlab.com/gitlab-examples/redis)，该项目在 [JihuLab.com](https://gitlab.com) 上运行，使用我们公开可用的 [实例 runners](../runners/_index.md)。

想要动手试试？Fork 它，提交并推送你的更改。片刻之后，更改会被公共 runner 获取，作业便会开始。