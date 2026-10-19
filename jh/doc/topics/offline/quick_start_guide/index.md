---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# 在离线自托管极狐GitLab 实例中安装 **(FREE SELF)**

这是一份详细指南，帮助您在完全离线的情况下安装、配置和使用自托管的极狐GitLab 实例。

## 安装

注意：
此指南假设服务器使用 [Omnibus 安装方法](https://docs.gitlab.cn/omnibus/) 在 Ubuntu 20.04 上运行极狐GitLab [企业版](https://gitlab.cn/install/ce-or-ee/)。其他服务器的操作步骤可能有所不同。
此指南还假设服务器主机解析为 `my-host.internal`，您应该将其替换为服务器的 FQDN，并且您可以访问另一台具有互联网访问权限的服务器以下载所需的软件包文件。

有关此过程的视频演示，请参见 [离线极狐GitLab 安装：下载与安装](https://www.bilibili.com/video/BV16h411s7vx)。

### 下载极狐GitLab 软件包

您应该使用相同操作系统类型的服务器（具有互联网访问权限）[手动下载极狐GitLab 软件包](../../../update/package/index.md#upgrade-using-a-manually-downloaded-package) 及相关依赖项。

如果您的离线环境没有本地网络访问权限，则必须通过物理介质（如 USB 驱动器）手动传输相关软件包。在 Ubuntu 上，可以在具有互联网访问权限的服务器上使用以下命令执行此操作：

```shell
# Download the bash script to prepare the repository
curl -fsSL https://packages.gitlab.cn/repository/raw/scripts/setup.sh | /bin/bash

# Download the gitlab-jh package and dependencies to /var/cache/apt/archives
sudo apt-get install --download-only gitlab-jh

# Copy the contents of the apt download folder to a mounted media device
sudo cp /var/cache/apt/archives/*.deb /path/to/mount
```

### 安装极狐GitLab 软件包

先决条件：

- 在离线环境中安装极狐GitLab 软件包之前，请确保您先安装了所有必需的依赖项。

如果您使用的是 Ubuntu，可以使用 `dpkg` 安装您复制的 `.deb` 软件包依赖项。但是不要立即安装极狐GitLab 软件包。

```shell
# Navigate to the physical media device
sudo cd /path/to/mount

# Install the dependency packages
sudo dpkg -i <package_name>.deb
```

[使用适用于您操作系统的相关命令安装软件包](../../../update/package/index.md#upgrade-using-a-manually-downloaded-package)，但在 `EXTERNAL_URL` 安装步骤中确保指定一个 `http` URL。安装完成后，我们可以手动配置 SSL。

强烈建议设置一个用于 IP 解析的域，而不是绑定到服务器的 IP 地址。这样更有利于确保我们的证书 CN 的稳定目标，并使长期解析变得更加简单。

以下是 Ubuntu 的示例，使用 HTTP 指定 `EXTERNAL_URL` 并安装极狐GitLab 软件包：

```shell
sudo EXTERNAL_URL="http://my-host.internal" dpkg -i <gitlab_package_name>.deb
```

## 启用 SSL

按照以下步骤为您的新实例启用 SSL。这些步骤反映了 [手动配置 Omnibus 的 NGINX 配置中的 SSL](https://docs.gitlab.cn/omnibus/settings/ssl/index.html#configure-https-manually) 的步骤：

1. 对 `/etc/gitlab/gitlab.rb` 进行以下更改：

   ```ruby
   # Update external_url from "http" to "https"
   external_url "https://my-host.internal"

   # Set Let's Encrypt to false
   letsencrypt['enable'] = false
   ```

1. 使用适当的权限创建以下目录以生成自签名证书：

   ```shell
   sudo mkdir -p /etc/gitlab/ssl
   sudo chmod 755 /etc/gitlab/ssl
   sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/gitlab/ssl/my-host.internal.key -out /etc/gitlab/ssl/my-host.internal.crt
   ```

1. 重新配置您的实例以应用更改：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

## 启用极狐GitLab 容器镜像库

按照以下步骤启用容器镜像库。这些步骤反映了[在现有域下配置容器镜像库](../../../administration/packages/container_registry.md#configure-container-registry-under-an-existing-gitlab-domain)的步骤：

1. 对 `/etc/gitlab/gitlab.rb` 进行以下更改：

   ```ruby
   # Change external_registry_url to match external_url, but append the port 4567
   external_url "https://gitlab.example.com"
   registry_external_url "https://gitlab.example.com:4567"
   ```

1. 重新配置您的实例以应用更改：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

## 允许 Docker 守护程序信任镜像库和极狐GitLab Runner

通过[在镜像库中使用受信任证书](../../../administration/packages/container_registry.md#using-self-signed-certificates-with-container-registry) 为您的 Docker 守护程序提供证书：

```shell
sudo mkdir -p /etc/docker/certs.d/my-host.internal:5000

sudo cp /etc/gitlab/ssl/my-host.internal.crt /etc/docker/certs.d/my-host.internal:5000/ca.crt
```

通过[在 Runner 中使用受信任证书](https://docs.gitlab.cn/runner/install/docker.html#installing-trusted-ssl-server-certificates) 为您的极狐GitLab Runner 提供证书：

```shell
sudo mkdir -p /etc/gitlab-runner/certs

sudo cp /etc/gitlab/ssl/my-host.internal.crt /etc/gitlab-runner/certs/ca.crt
```

## 启用极狐GitLab Runner

[按照与将极狐GitLab Runner 安装为 Docker 服务的步骤类似的过程](https://docs.gitlab.cn/runner/install/docker.html#install-the-docker-image-and-start-the-container)，我们首先必须注册我们的 Runner：

```shell
$ sudo docker run --rm -it -v /etc/gitlab-runner:/etc/gitlab-runner registry.gitlab.cn/jihulab/gitlab-runner:latest register
Updating CA certificates...
Runtime platform                                    arch=amd64 os=linux pid=7 revision=1b659122 version=12.8.0
Running in system-mode.

Please enter the gitlab-ci coordinator URL (for example, https://gitlab.com/):
https://my-host.internal
Please enter the gitlab-ci token for this runner:
XXXXXXXXXXX
Please enter the gitlab-ci description for this runner:
[eb18856e13c0]:
Please enter the gitlab-ci tags for this runner (comma separated):

Registering runner... succeeded                     runner=FSMwkvLZ
Please enter the executor: custom, docker, virtualbox, kubernetes, docker+machine, docker-ssh+machine, docker-ssh, parallels, shell, ssh:
docker
Please enter the default Docker image (for example, ruby:2.6):
ruby:2.6
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```

现在我们必须向我们的 Runner 添加一些额外的配置：

对 `/etc/gitlab-runner/config.toml` 进行以下更改：

- 将 Docker socket 添加到卷 `volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]`
- 在执行者配置中添加 `pull_policy = "if-not-present"`

现在我们可以启动我们的 Runner：

```shell
sudo docker run -d --restart always --name gitlab-runner -v /etc/gitlab-runner:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock registry.gitlab.cn/jihulab/gitlab-runner:latest
90646b6587127906a4ee3f2e51454c6e1f10f26fc7a0b03d9928d8d0d5897b64
```

### 对主机操作系统进行镜像库身份验证

正如[Docker 镜像库身份验证文档](https://docs.docker.com/registry/insecure/#docker-still-complains-about-the-certificate-when-using-authentication) 中所指出的，
某些版本的 Docker 需要在操作系统级别信任证书链。

在 Ubuntu 的情况下，这涉及使用 `update-ca-certificates`：

```shell
sudo cp /etc/docker/certs.d/my-host.internal\:5000/ca.crt /usr/local/share/ca-certificates/my-host.internal.crt

sudo update-ca-certificates
```

如果一切顺利，您应该看到以下内容：

```plaintext
1 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d...
done.
```

### 禁用版本检查和服务 Ping

版本检查和服务 Ping 改进了极狐GitLab 用户体验，并确保用户使用的是最新版本的极狐GitLab。可以在离线环境中关闭这两项服务，以防它们试图并失败地访问极狐GitLab 服务。

有关更多信息，请参见 [启用或禁用服务 ping](../../../administration/settings/usage_statistics.md#enable-or-disable-service-ping)。

### 配置 NTP

在极狐GitLab 15.4 和 15.5 中，Gitaly Cluster 假定 `pool.ntp.org` 是可访问的。如果 `pool.ntp.org` 不可访问，[自定义 Gitaly 和 Praefect 服务器的时间服务器设置](../../../administration/gitaly/praefect.md#customize-time-server-setting)，
以便它们可以使用可访问的 NTP 服务器。

在离线实例上，[极狐GitLab Geo 检查 Rake 任务](../../../administration/geo/replication/troubleshooting.md#can-geo-detect-the-current-site-correctly)
始终失败，因为它使用 `pool.ntp.org`。可以忽略此错误，但是您可以[了解如何解决此问题的更多信息](../../../administration/geo/replication/troubleshooting.md#message-machine-clock-is-synchronized--exception)。

## 启用包元数据数据库

启用包元数据数据库是启用 [持续漏洞扫描](https://docs.gitlab.com/ee/user/application_security/continuous_vulnerability_scanning/index.html)
和 [CycloneDX 文件的 license 扫描](../../../user/compliance/license_scanning_of_cyclonedx_files/index.md) 所必需的。此过程需要使用 license 或 advisory 数据，
统称为包元数据数据库，其在 [EE 许可证](https://aliyun-package-metadata-licenses-bucket.oss-cn-beijing.aliyuncs.com/LICENSE) 下许可。请注意以下与包元数据数据库使用有关的事项：

- 我们可能会在任何时间自行决定更改或停止包元数据数据库的全部或任何部分，恕不另行通知，恕不受任何限制。
- 包元数据数据库可能包含指向第三方网站或资源的链接。我们仅提供这些链接作为方便，不对这些网站或资源的任何第三方数据、内容、产品或服务或显示在这些网站上的链接负责。
- 包元数据数据库部分基于第三方提供的信息，极狐GitLab 不对所提供内容的准确性或完整性负责。

包元数据存储在以下阿里云对象存储桶中：

- license 扫描 - aliyun-package-metadata-advisories-bucket
- advisory 扫描 - aliyun-package-metadata-advisories-bucket

### 使用 rclone 工具下载包元数据导出

1. 安装 [`rclone`](https://rclone.org/install) 工具。
1. 配置 rclone 数据源。其中 `ALI_ACCESS_KEY_ID` 和 `ALI_SECRET_ACCESS_KEY` 可通过[阿里云文档](https://help.aliyun.com/zh/ram/user-guide/create-an-accesskey-pair-1)获取 AccessKey ID 和 AccessKey Secret

    ```shell
      rclone config create ali s3 provider=Alibaba access_key_id=$ALI_ACCESS_KEY_ID secret_access_key=$ALI_SECRET_ACCESS_KEY endpoint=oss-cn-beijing.aliyuncs.com acl=public-read --non-interactive 
    ```

1. 找到极狐GitLab Rails 目录的根目录。

   ```shell
   export GITLAB_RAILS_ROOT_DIR="$(gitlab-rails runner 'puts Rails.root.to_s')"
   echo $GITLAB_RAILS_ROOT_DIR
   ```

1. 设置您希望同步的数据类型。

   ```shell
   # For License Scanning
   export PKG_METADATA_BUCKET=aliyun-package-metadata-licenses-bucket
   export DATA_DIR="licenses"

   # For Dependency Scanning
   export PKG_METADATA_BUCKET=aliyun-package-metadata-advisories-bucket
   export DATA_DIR="advisories"
   ```

1. 下载包元数据导出。请注意下列命令不能同时下载 `licenses` 和 `advisories` 数据。

   ```shell
   # To download the package metadata exports, an outbound connection to AliYun Cloud Storage bucket must be allowed.
   mkdir -p "$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/$DATA_DIR"
   rclone sync --progress --verbose ali:$PKG_METADATA_BUCKET "$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/$DATA_DIR" --exclude v1/
   ```

### 自动同步

您的极狐GitLab 实例定期与 `package_metadata` 目录的内容进行[同步](https://gitlab.com/gitlab-org/gitlab/-/blob/63a187d47f6da353ba4514650bbbbeb99c356325/config/initializers/1_settings.rb#L840-842)。
要使用上游更改自动更新本地副本，可以添加一个 cron 作业以定期下载新的导出文件。例如，可以添加以下 crontabs 以设置每 4 小时运行一次的 cron 作业。

对于许可扫描：

```plaintext
* */4 * * * rclone sync --progress ali:aliyun-package-metadata-licenses-bucket $GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/licenses
```

对于依赖扫描：

```plaintext
* */4 * * * rclone sync --progress ali:aliyun-package-metadata-advisories-bucket $GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/advisories
```

### 变更说明

随着16.2版本的发布，包元数据的目录已从 `vendor/package_metadata_db` 更改为 `vendor/package_metadata/licenses`。如果此目录已存在于实例中且需要添加Dependency Scanning，则需要执行以下步骤。

1. 重命名 licenses 目录：`mv vendor/package_metadata_db vendor/package_metadata/licenses`。
1. 更新任何自动化脚本或保存的命令，将 `vendor/package_metadata_db` 更改为 `vendor/package_metadata/licenses`。
1. 更新任何cron条目，将 `vendor/package_metadata_db` 更改为 `vendor/package_metadata/licenses`。

    ```shell
    sed -i '.bckup' -e 's#vendor/package_metadata_db#vendor/package_metadata/licenses#g' [FILE ...]
    ```

### 故障排除

#### 缺失的数据库数据

如果依赖列表或合并请求页面缺少许可证或建议数据，可能的原因之一是数据库未与导出数据同步。

`package_metadata` 同步是通过使用 cron 作业触发的（[同步 advisory](https://gitlab.com/gitlab-org/gitlab/-/blob/16-3-stable-ee/config/initializers/1_settings.rb#L864-866) 和 [同步 license](https://gitlab.com/gitlab-org/gitlab/-/blob/16-3-stable-ee/config/initializers/1_settings.rb#L855-857)），仅导入在[管理设置](../../../administration/settings/security_and_compliance.md#choose-package-registry-metadata-to-sync)中启用的包注册类型。

`vendor/package_metadata` 中的文件结构必须与上述启用的软件包仓库类型一致。例如，要同步 `maven` 许可证或建议数据，Rails 目录下的包元数据目录必须具有以下结构：

- 对于 license：`$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/licenses/v2/maven/**/*.ndjson`。
- 对于 advisory：`$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/advisories/v2/maven/**/*.ndjson`。

成功运行后，数据库中的 `pm_` 表下的数据应该已填充（使用[Rails控制台](../../../administration/operations/rails_console.md)检查）：

- 对于 license：`sudo gitlab-rails runner "puts \"Package model has #{PackageMetadata::Package.where(purl_type: 'maven').size} packages\""`。
- 对于 advisory：`sudo gitlab-rails runner "puts \"Advisory model has #{PackageMetadata::AffectedPackage.where(purl_type: 'maven').size} packages\""`。

此外，特定包注册的同步之后应存在检查点数据。例如，对于Maven，成功同步运行后应创建一个检查点：

- 对于 license：`sudo gitlab-rails runner "puts \"maven data has been synced up to #{PackageMetadata::Checkpoint.where(data_type: 'licenses', purl_type: 'maven')}\""`。
- 对于 advisory：`sudo gitlab-rails runner "puts \"maven data has been synced up to #{PackageMetadata::Checkpoint.where(data_type: 'advisories', purl_type: 'maven')}\""`。

最后，您可以通过搜索 `DEBUG` 消息的 `PackageMetadata::SyncService` 类来检查 [`application_json.log`](../../../administration/logs/index.md#application_jsonlog) 日志，以验证同步作业是否已运行且无错误。例如：`{"severity":"DEBUG","time":"2024-01-04T07:53:58.730Z","class":"PackageMetadata::SyncService","message":"Evaluating data for licenses:ali/aliyun-package-metadata-licenses-bucket/v2/composer/1690298433/2.ndjson"}`。
