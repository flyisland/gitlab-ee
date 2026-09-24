---
stage: none
group: Embody
info: This page is owned by <https://handbook.gitlab.com/handbook/engineering/embody-team/>
description: Monitor application performance and troubleshoot performance issues.
ignore_in_report: true
title: 设置私有化部署的可观测性
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- Status: 实验

{{< /details >}}

可观测性数据是在你的 JihuLab.com 实例外的独立应用程序中收集的。你的 极狐GitLab 实例的问题不会影响可观测性数据的收集或查看，反之亦然。

对于私有化部署，你控制数据的存储位置。

<a id="workflow"></a>

## 工作流

要在你的私有化部署实例上设置可观测性，你需要：

1. 确保满足前提条件。
1. 配置服务器和存储。
1. 配置 Docker 并在容器中安装可观测性。
1. 配置网络访问。
1. 为你的群组配置 URL。

<a id="prerequisites"></a>

## 前提条件

- 你必须有一个 EC2 实例或类似的虚拟机，满足：
  - 最低要求：`t3.large`（2 vCPU，8 GB RAM）。
  - 推荐：用于生产环境的 `t3.xlarge`（4 vCPU，16 GB RAM）。
  - 至少 100 GB 存储空间。
- 必须安装 Docker 和 Docker Compose。
- 你的 极狐GitLab 版本必须为 18.1 或更高。
- 你的 极狐GitLab 实例必须连接到可观测性实例。

<a id="provision-server-and-storage"></a>

### 配置服务器和存储

对于 AWS EC2：

1. 启动一个至少包含 2 vCPU 和 8 GB RAM 的 EC2 实例。
1. 添加至少 100 GB 的 EBS 卷。
1. 使用 SSH 连接到你的实例。

<a id="mount-storage-volume"></a>

#### 挂载存储卷

```shell
sudo mkdir -p /mnt/data
sudo mount /dev/xvdbb /mnt/data  # Replace xvdbb with your volume name
sudo chown -R $(whoami):$(whoami) /mnt/data
```

要永久挂载，请添加到 `/etc/fstab`：

```shell
echo '/dev/xvdbb /mnt/data ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab
```

<a id="install-docker"></a>

### 安装 Docker

对于 Ubuntu/Debian：

```shell
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $(whoami)
```

对于 Amazon Linux：

```shell
sudo dnf update
sudo dnf install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $(whoami)
```

注销并重新登录，或运行：

```shell
newgrp docker
```

<a id="configure-docker-to-use-the-mounted-volume"></a>

#### 配置 Docker 使用挂载卷

```shell
sudo mkdir -p /mnt/data/docker
sudo bash -c 'cat > /etc/docker/daemon.json << EOF
{
  "data-root": "/mnt/data/docker"
}
EOF'
sudo systemctl restart docker
```

使用以下命令验证：

```shell
docker info | grep "Docker Root Dir"
```

<a id="install-gitlab-observability"></a>

#### 安装极狐GitLab 可观测性

```shell
cd /mnt/data
git clone -b main https://jihulab.com/gitlab-cn/embody-team/experimental-observability/gitlab_o11y.git
cd gitlab_o11y/deploy/docker
docker-compose up -d
```

如果遇到超时错误，请使用：

```shell
COMPOSE_HTTP_TIMEOUT=300 docker-compose up -d
```

<a id="optional-use-an-external-clickhouse-database"></a>

#### 可选：使用外部 ClickHouse 数据库

如果你愿意，可以使用自己的 ClickHouse 数据库。

前提条件：

- 确保你的外部 ClickHouse 实例可访问，并正确配置所需的认证凭据。

在运行 `docker-compose up -d` 之前，请完成以下步骤：

1. 打开 `docker-compose.yml` 文件。
1. 注释掉：
   - `clickhouse` 和 `zookeeper` 服务。
   - `x-clickhouse-defaults` 和 `x-clickhouse-depend` 部分。
1. 将以下文件中所有出现的 `clickhouse:9000` 替换为你的 ClickHouse 端点和 TCP 端口（例如，`my-clickhouse.example.com:9000`）。如果你的 ClickHouse 实例需要认证，可能还需要更新连接字符串以包含凭据：
   - `docker-compose.yml`
   - `otel-collector-config.yaml`
   - `prometheus-config.yml`

<a id="configure-network-access-for-gitlab-observability"></a>

### 配置极狐GitLab 可观测性的网络访问

要正确接收遥测数据，你需要在极狐GitLab 可观测性实例的安全组中打开特定的端口：

1. 进入 **AWS 控制台** > **EC2** > **安全组**。
1. 选择附加到你的极狐GitLab 可观测性实例的安全组。
1. 选择 **编辑入站规则**。
1. 添加以下规则：
   - 类型：自定义 TCP，端口：8080，来源：你的 IP 或 0.0.0.0/0（用于 UI 访问）
   - 类型：自定义 TCP，端口：4317，来源：你的 IP 或 0.0.0.0/0（用于 OTLP gRPC）
   - 类型：自定义 TCP，端口：4318，来源：你的 IP 或 0.0.0.0/0（用于 OTLP HTTP）
   - 类型：自定义 TCP，端口：9411，来源：你的 IP 或 0.0.0.0/0（用于 Zipkin - 可选）
   - 类型：自定义 TCP，端口：14268，来源：你的 IP 或 0.0.0.0/0（用于 Jaeger HTTP - 可选）
   - 类型：自定义 TCP，端口：14250，来源：你的 IP 或 0.0.0.0/0（用于 Jaeger gRPC - 可选）
1. 选择 **保存规则**。

现在通过以下地址访问极狐GitLab 可观测性 UI：

```plaintext
http://[your-instance-ip]:8080
```

<a id="configure-the-url-for-your-group"></a>

### 为你的群组配置 URL

使用 Rails 控制台为你的群组配置极狐GitLab 可观测性 URL：

1. 访问 Rails 控制台：

   ```shell
   docker exec -it gitlab gitlab-rails console
   ```

1. 为你的群组配置可观测性设置：

   ```ruby
   group = Group.find_by_path('your-group-name')

   Observability::GroupO11ySetting.create!(
     group_id: group.id,
     o11y_service_url: 'your-o11y-instance-url',
     o11y_service_user_email: 'your-email@example.com',
     o11y_service_password: 'your-secure-password',
     o11y_service_post_message_encryption_key: 'your-super-secret-encryption-key-here-32-chars-minimum'
   )
   ```

   替换：
   - `your-group-name` 为你的实际群组路径。
   - `your-o11y-instance-url` 为你的极狐GitLab 可观测性实例 URL（例如：`http://192.168.1.100:8080`）。
   - 电子邮件和密码为你偏好的凭据。
   - 加密密钥为一个安全的 32 位以上的字符串。

<a id="next-steps"></a>

## 后续步骤

- [将遥测数据发送到极狐GitLab 可观测性](send.md)。
- [显示 CI/CD 流水线遥测](ci_cd.md)。
- [获取故障排除信息](troubleshooting.md)。