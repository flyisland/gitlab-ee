---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: How to configure GitLab when running in a Docker container.
title: 配置运行在 Docker 容器中的极狐GitLab
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

This container uses the official Linux package, so you can use
the unique configuration file `/etc/gitlab/gitlab.rb` to configure the instance.

## 编辑配置文件

<a id="edit-the-configuration-file"></a>

To access the GitLab configuration file, you can start a shell session in the
context of a running container.

1. Start the session:

   ```shell
   sudo docker exec -it gitlab /bin/bash
   ```

   Alternatively, you can open `/etc/gitlab/gitlab.rb` in an editor directly:

   ```shell
   sudo docker exec -it gitlab editor /etc/gitlab/gitlab.rb
   ```

1. In your preferred text editor, open `/etc/gitlab/gitlab.rb` and update the following fields:

   1. Set the `external_url` field to
      a valid URL for your GitLab instance.

   1. To receive emails from GitLab, configure the
      [SMTP 设置](https://gitlab.cn/docs/omnibus/settings/smtp/)。极狐GitLab Docker 镜像
      没有预装 SMTP 服务器。

   1. If desired [启用 HTTPS](https://gitlab.cn/docs/omnibus/settings/ssl/)。

1. Save the file and restart the container to reconfigure GitLab:

   ```shell
   sudo docker restart gitlab
   ```

GitLab reconfigures itself each time the container starts.
For more configuration options in GitLab, see the
[配置文档](https://gitlab.cn/docs/omnibus/settings/configuration/)。

## 预配置 Docker 容器

<a id="pre-configure-docker-container"></a>

你可以在 Docker 运行命令中添加环境变量 `GITLAB_OMNIBUS_CONFIG` 来预配置极狐GitLab Docker 镜像。该变量可以包含任何 `gitlab.rb` 设置，并在加载容器的 `gitlab.rb` 文件之前被评估。此行为允许你配置外部极狐GitLab URL，并进行数据库配置或使用 [Linux 软件包模板](https://jihulab.com/gitlab-cn/omnibus-gitlab/blob/master/files/gitlab-config-template/gitlab.rb.template) 中的任何其他选项。
`GITLAB_OMNIBUS_CONFIG` 中包含的设置不会被写入 `gitlab.rb` 配置文件，而是在加载时评估。若要提供多个设置，请使用分号 (`;`) 分隔。

以下示例设置了外部 URL，启用了 LFS，并以 [Prometheus 所需的最小 shm 大小](troubleshooting.md#devshm-mount-not-having-enough-space-in-docker-container) 启动容器：

```shell
sudo docker run --detach \
  --hostname gitlab.example.com \
  --env GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.example.com'; gitlab_rails['lfs_enabled'] = true;" \
  --publish 443:443 --publish 80:80 --publish 22:22 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --shm-size 256m \
  registry.gitlab.cn/omnibus/gitlab-jh:<version>-jh.0
```

每次执行 `docker run` 命令时，都需要提供 `GITLAB_OMNIBUS_CONFIG` 选项。`GITLAB_OMNIBUS_CONFIG` 的内容 _不会_ 在后续运行中保留。

### 在公网 IP 上运行极狐GitLab

<a id="run-gitlab-on-a-public-ip-address"></a>

你可以通过修改 `--publish` 标志，让 Docker 使用你的 IP 地址并将所有流量转发到极狐GitLab 容器。

在 IP `198.51.100.1` 上公开极狐GitLab：

```shell
sudo docker run --detach \
  --hostname gitlab.example.com \
  --env GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.example.com'" \
  --publish 198.51.100.1:443:443 \
  --publish 198.51.100.1:80:80 \
  --publish 198.51.100.1:22:22 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --shm-size 256m \
  registry.gitlab.cn/omnibus/gitlab-jh:<version>-jh.0
```

然后你可以通过 `http://198.51.100.1/` 和 `https://198.51.100.1/` 访问你的极狐GitLab 实例。

## 在不同端口上公开极狐GitLab

<a id="expose-gitlab-on-different-ports"></a>

极狐GitLab 在容器内占用 [特定端口](../../administration/package_information/defaults.md)。

如果你想使用与默认端口 `80`（HTTP）、`443`（HTTPS）或 `22`（SSH）不同的主机端口，需要在 `docker run` 命令中添加单独的 `--publish` 指令。

例如，要在主机端口 `8929` 上公开 Web 界面，并在端口 `2424` 上公开 SSH 服务：

1. 使用以下 `docker run` 命令：

   ```shell
   sudo docker run --detach \
     --hostname gitlab.example.com \
     --env GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.example.com:8929'; gitlab_rails['gitlab_shell_ssh_port'] = 2424" \
     --publish 8929:8929 --publish 2424:22 \
     --name gitlab \
     --restart always \
     --volume $GITLAB_HOME/config:/etc/gitlab \
     --volume $GITLAB_HOME/logs:/var/log/gitlab \
     --volume $GITLAB_HOME/data:/var/opt/gitlab \
     --shm-size 256m \
     registry.gitlab.cn/omnibus/gitlab-jh:<version>-jh.0
   ```

   > [!note]
   > 发布端口的格式为 `hostPort:containerPort`。更多信息请参见 Docker 文档中关于
   > [暴露入站端口](https://docs.docker.com/network/#published-ports) 的部分。

1. 进入运行中的容器：

   ```shell
   sudo docker exec -it gitlab /bin/bash
   ```

1. 在编辑器中打开 `/etc/gitlab/gitlab.rb` 并设置 `external_url`：

   ```ruby
   # For HTTP
   external_url "http://gitlab.example.com:8929"

   or

   # For HTTPS (notice the https)
   external_url "https://gitlab.example.com:8929"
   ```

   此 URL 中指定的端口必须与 Docker 发布到主机的端口匹配。
   此外，如果未在 `nginx['listen_port']` 中显式设置 NGINX 监听端口，则会使用 `external_url`。
   更多信息，请参见 [NGINX 文档](https://gitlab.cn/docs/omnibus/settings/nginx/)。

1. 设置 SSH 端口：

   ```ruby
   gitlab_rails['gitlab_shell_ssh_port'] = 2424
   ```

1. 最后，重新配置极狐GitLab：

   ```shell
   gitlab-ctl reconfigure
   ```

按照上述示例，你的 Web 浏览器可以通过 `<hostIP>:8929` 访问极狐GitLab 实例，并通过 `2424` 端口进行 SSH 推送。

你可以在 [Docker compose](installation.md#install-gitlab-by-using-docker-compose) 部分查看使用不同端口的 `docker-compose.yml` 示例。

## 配置多个数据库连接

<a id="configure-multiple-database-connections"></a>

从 [极狐GitLab 16.0](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/merge_requests/6850) 开始，极狐GitLab 默认使用指向同一 PostgreSQL 数据库的两个数据库连接。

如果出于任何原因，你希望切换回单个数据库连接：

1. 编辑容器内的 `/etc/gitlab/gitlab.rb`：

   ```shell
   sudo docker exec -it gitlab editor /etc/gitlab/gitlab.rb
   ```

1. 添加以下行：

   ```ruby
   gitlab_rails['databases']['ci']['enable'] = false
   ```

1. 重启容器：

   ```shell
   sudo docker restart gitlab
   ```

## 后续步骤

<a id="next-steps"></a>

配置完你的安装后，请考虑执行 [推荐的后续步骤](../next_steps.md)，包括身份验证选项和新用户账户限制。