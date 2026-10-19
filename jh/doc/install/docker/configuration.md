---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 如何在 Docker 容器中运行极狐GitLab 时进行配置。
title: 配置在 Docker 容器中运行的极狐GitLab
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

此容器使用官方 Linux 软件包，因此您可以使用统一的配置文件 `/etc/gitlab/gitlab.rb` 来配置该实例。

<a id="edit-the-configuration-file"></a>

## 编辑配置文件

要访问极狐GitLab 配置文件，您可以在正在运行的容器上下文中启动一个 shell 会话。

1. 启动会话：

   ```shell
   sudo docker exec -it gitlab /bin/bash
   ```

   或者，您也可以直接在编辑器中打开 `/etc/gitlab/gitlab.rb`：

   ```shell
   sudo docker exec -it gitlab editor /etc/gitlab/gitlab.rb
   ```

1. 在您常用的文本编辑器中，打开 `/etc/gitlab/gitlab.rb` 并更新以下字段：

   1. 将 `external_url` 字段设置为
      极狐GitLab 实例的有效 URL。

   1. 要接收来自极狐GitLab 的电子邮件，请配置
      [SMTP 设置](https://gitlab.cn/docs/omnibus/settings/smtp/)。极狐GitLab Docker 镜像
      未预装 SMTP 服务器。

   1. 如有需要，[启用 HTTPS](https://gitlab.cn/docs/omnibus/settings/ssl/)。

1. 保存文件并重启容器以重新配置极狐GitLab：

   ```shell
   sudo docker restart gitlab
   ```

每次容器启动时，极狐GitLab 都会重新配置自身。有关极狐GitLab 的更多配置选项，请参阅[配置文档](https://gitlab.cn/docs/omnibus/settings/configuration/)。

<a id="pre-configure-docker-container"></a>

## 预配置 Docker 容器

您可以通过在 Docker run 命令中添加环境变量 `GITLAB_OMNIBUS_CONFIG` 来预配置极狐GitLab Docker 镜像。此变量可以包含任何 `gitlab.rb` 设置，并会在加载容器的 `gitlab.rb` 文件之前进行求值。通过此行为，您可以配置外部极狐GitLab URL、数据库配置，或 [Linux 软件包模板](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/blob/master/files/gitlab-config-template/gitlab.rb.template)中的任何其他选项。`GITLAB_OMNIBUS_CONFIG`中包含的设置不会写入 `gitlab.rb` 配置文件，而是在加载时进行求值。要提供多个设置，请用分号（`;`）分隔。

以下示例设置了外部 URL、启用了 LFS，并以
[Prometheus 所需的最小 shm 大小](troubleshooting.md#devshm-mount-not-having-enough-space-in-docker-container)启动
容器：

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

每次执行 `docker run` 命令时，您都需要提供 `GITLAB_OMNIBUS_CONFIG` 选项。`GITLAB_OMNIBUS_CONFIG`的内容*不会*在后续运行之间保留。

<a id="run-gitlab-on-a-public-ip-address"></a>

### 在公网 IP 地址上运行极狐GitLab

您可以通过修改 `--publish` 标志，让 Docker 使用您的 IP 地址并将所有流量转发到极狐GitLab 容器。

要在 IP `198.51.100.1` 上公开极狐GitLab：

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

然后，您可以通过 `http://198.51.100.1/` 和 `https://198.51.100.1/` 访问您的极狐GitLab 实例。

<a id="expose-gitlab-on-different-ports"></a>

## 在不同端口上公开极狐GitLab

极狐GitLab 会占用容器内部的[特定端口](../../administration/package_information/defaults.md)。

如果您想使用不同于默认端口 `80`（HTTP）、`443`（HTTPS）或 `22`（SSH）的主机端口，则需要向 `docker run` 命令添加单独的 `--publish` 指令。

例如，要在主机的端口 `8929` 上公开 Web 界面，并在端口 `2424` 上公开 SSH 服务：

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
   > 发布端口的格式为 `hostPort:containerPort`。有关更多信息，请阅读
   > Docker 文档中关于
   > [公开传入端口](https://docs.docker.com/network/#published-ports)的内容。

1. 进入正在运行的容器：

   ```shell
   sudo docker exec -it gitlab /bin/bash
   ```

1. 使用您的编辑器打开 `/etc/gitlab/gitlab.rb` 并设置 `external_url`：

   ```ruby
   # For HTTP
   external_url "http://gitlab.example.com:8929"

   or

   # For HTTPS (notice the https)
   external_url "https://gitlab.example.com:8929"
   ```

   此 URL 中指定的端口必须与 Docker 发布到主机的端口一致。
   此外，如果未在
   `nginx['listen_port']` 中显式设置 NGINX 监听端口，则会改用 `external_url`。
   有关更多信息，请参阅 [NGINX 文档](https://gitlab.cn/docs/omnibus/settings/nginx/)。

1. 设置 SSH 端口：

   ```ruby
   gitlab_rails['gitlab_shell_ssh_port'] = 2424
   ```

1. 最后，重新配置极狐GitLab：

   ```shell
   gitlab-ctl reconfigure
   ```

按照前面的示例，您的 Web 浏览器可以通过 `<hostIP>:8929` 访问您的极狐GitLab 实例，并通过端口 `2424` 进行 SSH 推送。

您可以在 [Docker compose](installation.md#install-gitlab-by-using-docker-compose) 部分看到一个使用不同端口的 `docker-compose.yml` 示例。

<a id="configure-multiple-database-connections"></a>

## 配置多个数据库连接

极狐GitLab 默认使用两个指向同一 PostgreSQL 数据库的数据库连接。

如果出于任何原因，您希望切换回单个数据库连接：

1. 在容器内编辑 `/etc/gitlab/gitlab.rb`：

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

<a id="next-steps"></a>

## 后续步骤

配置完安装后，请考虑执行[推荐的后续步骤](../next_steps.md)，包括身份验证选项和新用户账号限制。
