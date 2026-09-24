---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn about the prerequisites, strategies, and steps for installing GitLab in a Docker container.
title: 在 Docker 容器中安装极狐GitLab
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要在 Docker 容器中安装极狐GitLab，可以使用 Docker Compose、Docker Engine 或 Docker Swarm 模式。

先决条件：

- 您必须拥有一个可运行的 [Docker 安装](https://docs.docker.com/engine/install/#server)，而不是 Docker for Windows。Docker for Windows 不受官方支持，因为这些镜像存在已知的兼容性问题（如卷权限等）以及其他潜在未知问题。如果您尝试在 Docker for Windows 上运行，请参阅[获取帮助页面](https://gitlab.cn/get-help/)。该页面包含社区资源（例如 IRC 或论坛）的链接，您可以从其他用户那里寻求帮助。
- 您必须拥有一个邮件传输代理 (MTA)，例如 Postfix 或 Sendmail。极狐GitLab 镜像不包含 MTA。您可以在单独的容器中安装 MTA。虽然您可以在极狐GitLab 所在的同一容器中安装 MTA，但您可能需要在每次升级或重启后重新安装 MTA。
- 您不应计划在 Kubernetes 中部署极狐GitLab Docker 镜像，因为它会创建单点故障。如果您想在 Kubernetes 中部署极狐GitLab，请改用[极狐GitLab Helm Chart](https://gitlab.cn/docs/charts) 或 [GitLab Operator](https://gitlab.cn/docs/operator/)。
- 您必须为您的 Docker 安装准备一个有效的、外部可访问的主机名。不要使用 `localhost`。

<a id="configure-the-ssh-port"></a>

## 配置 SSH 端口

默认情况下，极狐GitLab 使用端口 `22` 通过 SSH 与 Git 交互。
要使用端口 `22`，请跳过此部分。

要使用其他端口，您可以：

- 现在更改服务器的 SSH 端口（推荐）。这样，SSH 克隆 URL 就不需要包含新端口号：

  ```plaintext
  ssh://git@gitlab.example.com/user/project.git
  ```

- [安装后更改极狐GitLab Shell SSH 端口](configuration.md#expose-gitlab-on-different-ports)。然后 SSH 克隆 URL 将包含配置的端口号：

  ```plaintext
  ssh://git@gitlab.example.com:<portNumber>/user/project.git
  ```

更改服务器的 SSH 端口：

1. 用编辑器打开 `/etc/ssh/sshd_config`，并更改 SSH 端口：

   ```conf
   Port = 2424
   ```

1. 保存文件并重启 SSH 服务：

   ```shell
   sudo systemctl restart ssh
   ```

1. 验证您可以通过 SSH 连接。打开一个新的终端会话，并使用新端口通过 SSH 连接到服务器。

<a id="create-a-directory-for-the-volumes"></a>

## 为卷创建目录

> [!warning]
> 针对托管 Gitalia 数据的卷，存在特定的建议。基于 NFS 的文件系统可能导致性能问题，因此[不建议使用 EFS](../aws/_index.md#elastic-file-system-efs)。

为配置文件、日志和数据文件创建一个目录。该目录可以位于用户的主目录中（例如 `~/gitlab-docker`），或者像 `/srv/gitlab` 这样的目录中。

1. 创建目录：

   ```shell
   sudo mkdir -p /srv/gitlab
   ```

1. 如果您使用非 `root` 用户运行 Docker，请为该用户授予新目录的适当权限。

1. 配置一个新的环境变量 `$GITLAB_HOME`，将其设置为指向您创建的目录的路径：

   ```shell
   export GITLAB_HOME=/srv/gitlab
   ```

1. 可选地，您可以将 `GITLAB_HOME` 环境变量添加到您的 shell 配置文件中，以便它在所有未来的终端会话中生效：

   - Bash：`~/.bash_profile`
   - ZSH：`~/.zshrc`

极狐GitLab 容器使用主机挂载的卷来存储持久化数据：

| 本地位置             | 容器位置           | 用途                               |
|----------------------|--------------------|------------------------------------|
| `$GITLAB_HOME/data`  | `/var/opt/gitlab`  | 存储应用程序数据。                 |
| `$GITLAB_HOME/logs`  | `/var/log/gitlab`  | 存储日志。                         |
| `$GITLAB_HOME/config`| `/etc/gitlab`      | 存储极狐GitLab 配置文件。         |

<a id="find-the-gitlab-version-and-edition-to-use"></a>

## 查找要使用的极狐GitLab 版本

在生产环境中，您应该将部署固定到特定的极狐GitLab 版本。在极狐GitLab Docker 镜像标签页面中查看可用的版本，并选择您想要使用的版本：

- [极狐GitLab Docker 镜像标签](https://hub.gitlab.cn/gitlab-jh)

标签名称由以下部分组成：

```plaintext
registry.gitlab.cn/omnibus/gitlab-jh:<version>-jh.0
```

其中 `<version>` 是极狐GitLab 版本，例如 `16.5.3`。版本号始终包含 `<major>.<minor>.<patch>`。

出于测试目的，您可以使用 `latest` 标签，例如 `registry.gitlab.cn/omnibus/gitlab-jh:latest`，它指向最新的稳定版本。

以下示例使用稳定的极狐版版本。
如果您想使用候选版本 (RC) 或 nightly 镜像，请改用 `registry.gitlab.cn/omnibus/gitlab-jh:rc` 或 `registry.gitlab.cn/omnibus/gitlab-jh:nightly`。

<a id="installation"></a>

## 安装

您可以通过以下几种方式运行极狐GitLab Docker 镜像：

- [Docker Compose](#install-gitlab-by-using-docker-compose)（推荐）
- [Docker Engine](#install-gitlab-by-using-docker-engine)
- [Docker Swarm 模式](#install-gitlab-by-using-docker-swarm-mode)

<a id="install-gitlab-by-using-docker-compose"></a>

### 使用 Docker Compose 安装极狐GitLab

使用 [Docker Compose](https://docs.docker.com/compose/) 您可以配置、安装和升级基于 Docker 的极狐GitLab 安装：

1. [安装 Docker Compose](https://docs.docker.com/compose/install/linux/)。
1. 创建一个 `docker-compose.yml` 文件。 例如：

   ```yaml
   services:
     gitlab:
       image: registry.gitlab.cn/omnibus/gitlab-jh:<version>-jh.0
       container_name: gitlab
       restart: always
       hostname: 'gitlab.example.com'
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           # 在此添加其他 gitlab.rb 配置，每行一条
           external_url 'https://gitlab.example.com'
       ports:
         - '80:80'
         - '443:443'
         - '22:22'
       volumes:
         - '$GITLAB_HOME/config:/etc/gitlab'
         - '$GITLAB_HOME/logs:/var/log/gitlab'
         - '$GITLAB_HOME/data:/var/opt/gitlab'
       shm_size: '256m'
   ```

   > [!note]
   > 请阅读[预配置 Docker 容器](configuration.md#pre-configure-docker-container)部分，以了解 `GITLAB_OMNIBUS_CONFIG` 变量的工作原理。

   这是另一个 `docker-compose.yml` 示例，其中极狐GitLab 运行在自定义的 HTTP 和 SSH 端口上。 请注意 `GITLAB_OMNIBUS_CONFIG` 变量与 `ports` 部分相匹配：

   ```yaml
   services:
     gitlab:
       image: registry.gitlab.cn/omnibus/gitlab-jh:<version>-jh.0
       container_name: gitlab
       restart: always
       hostname: 'gitlab.example.com'
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           external_url 'http://gitlab.example.com:8929'
           gitlab_rails['gitlab_shell_ssh_port'] = 2424
       ports:
         - '8929:8929'
         - '443:443'
         - '2424:22'
       volumes:
         - '$GITLAB_HOME/config:/etc/gitlab'
         - '$GITLAB_HOME/logs:/var/log/gitlab'
         - '$GITLAB_HOME/data:/var/opt/gitlab'
       shm_size: '256m'
   ```

   此配置与使用 `--publish 8929:8929 --publish 2424:22` 的效果相同。

1. 在 `docker-compose.yml` 所在的目录中，启动极狐GitLab：

   ```shell
   docker compose up -d
   ```

<a id="install-gitlab-by-using-docker-engine"></a>

### 使用 Docker Engine 安装极狐GitLab

或者，您也可以使用 Docker Engine 安装极狐GitLab。

1. 如果您已设置 `GITLAB_HOME` 变量，请根据您的需求调整目录，然后运行镜像：

   - 如果您未使用 SELinux，请运行此命令：

     ```shell
     sudo docker run --detach \
       --hostname gitlab.example.com \
       --env GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.example.com'" \
       --publish 443:443 --publish 80:80 --publish 22:22 \
       --name gitlab \
       --restart always \
       --volume $GITLAB_HOME/config:/etc/gitlab \
       --volume $GITLAB_HOME/logs:/var/log/gitlab \
       --volume $GITLAB_HOME/data:/var/opt/gitlab \
       --shm-size 256m \
       registry.gitlab.cn/omnibus/gitlab-jh:<version>-jh.0
     ```

     此命令会下载并启动一个极狐GitLab 容器，并[发布端口](https://docs.docker.com/network/#published-ports)以访问 SSH、HTTP 和 HTTPS。所有极狐GitLab 数据都存储为 `$GITLAB_HOME` 的子目录。容器会在系统重启后自动重启。

   - 如果您正在使用 SELinux，请改用此命令：

     ```shell
     sudo docker run --detach \
       --hostname gitlab.example.com \
       --env GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.example.com'" \
       --publish 443:443 --publish 80:80 --publish 22:22 \
       --name gitlab \
       --restart always \
       --volume $GITLAB_HOME/config:/etc/gitlab:Z \
       --volume $GITLAB_HOME/logs:/var/log/gitlab:Z \
       --volume $GITLAB_HOME/data:/var/opt/gitlab:Z \
       --shm-size 256m \
       registry.gitlab.cn/omnibus/gitlab-jh:<version>-jh.0
     ```

     此命令确保 Docker 进程有足够的权限在挂载的卷中创建配置文件。

1. 如果您使用 [Kerberos 集成](../../integration/kerberos.md)，您还必须发布您的 Kerberos 端口（例如，`--publish 8443:8443`）。 如果不这样做，将阻止通过 Kerberos 进行 Git 操作。
   初始化过程可能需要很长时间。 您可以使用以下命令跟踪此过程：

   ```shell
   sudo docker logs -f gitlab
   ```

   启动容器后，您可以访问 `gitlab.example.com`。 Docker 容器可能需要一段时间才能开始响应查询。

1. 访问极狐GitLab URL，并使用用户名 `root` 和以下命令中的密码登录：

   ```shell
   sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
   ```

> [!note]
> 密码文件会在首次重启容器 24 小时后自动删除。

<a id="install-gitlab-by-using-docker-swarm-mode"></a>

### 使用 Docker Swarm 模式安装极狐GitLab

使用 [Docker Swarm 模式](https://docs.docker.com/engine/swarm/)，您可以在 swarm 集群中使用 Docker 配置和部署极狐GitLab 安装。

在 swarm 模式下，您可以利用 [Docker secrets](https://docs.docker.com/engine/swarm/secrets/) 和 [Docker configurations](https://docs.docker.com/engine/swarm/configs/) 高效、安全地部署您的极狐GitLab 实例。Secrets 可用于安全地传递您的初始 root 密码，而无需将其作为环境变量暴露。Configurations 可以帮助您保持极狐GitLab 镜像尽可能通用。

以下是使用 secrets 和 configurations 作为[stack](https://docs.docker.com/get-started/swarm-deploy/#describe-apps-using-stack-files) 部署带有四个 Runner 的极狐GitLab 的示例：

1. [设置 Docker swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/)。
1. 创建一个 `docker-compose.yml` 文件：

   ```yaml
   services:
     gitlab:
       image: registry.gitlab.cn/omnibus/gitlab-jh:<version>-jh.0
       container_name: gitlab
       restart: always
       hostname: 'gitlab.example.com'
       ports:
         - "22:22"
         - "80:80"
         - "443:443"
       volumes:
         - $GITLAB_HOME/data:/var/opt/gitlab
         - $GITLAB_HOME/logs:/var/log/gitlab
         - $GITLAB_HOME/config:/etc/gitlab
       shm_size: '256m'
       environment:
         GITLAB_OMNIBUS_CONFIG: "from_file('/omnibus_config.rb')"
       configs:
         - source: gitlab
           target: /omnibus_config.rb
       secrets:
         - gitlab_root_password
     gitlab-runner:
       image: registry.gitlab.cn/jihulab/gitlab-runner:alpine-v<runner-version>
       deploy:
         mode: replicated
         replicas: 4
   configs:
     gitlab:
       file: ./gitlab.rb
   secrets:
     gitlab_root_password:
       file: ./root_password.txt
   ```

   在 `gitlab-runner` 镜像标签中，`<runner-version>` 表示极狐GitLab Runner 版本，而不是极狐GitLab 版本。
   请从[极狐GitLab Runner 镜像标签](https://hub.gitlab.cn/gitlab-runner)中选择版本。

   为降低复杂性，前面的示例排除了 `network` 配置。您可以在官方的 [Compose 文件参考](https://docs.docker.com/compose/compose-file/)中找到更多信息。

1. 创建一个 `gitlab.rb` 文件：

   ```ruby
   external_url 'https://my.domain.com/'
   gitlab_rails['initial_root_password'] = File.read('/run/secrets/gitlab_root_password').gsub("\n", "")
   ```

1. 创建一个名为 `root_password.txt` 的文件，其中包含密码：

   ```plaintext
   MySuperSecretAndSecurePassw0rd!
   ```

1. 确保您与 `docker-compose.yml` 在同一个目录中，并运行：

   ```shell
   docker stack deploy --compose-file docker-compose.yml mystack
   ```

安装 Docker 后，您需要[配置您的极狐GitLab 实例](configuration.md)。
