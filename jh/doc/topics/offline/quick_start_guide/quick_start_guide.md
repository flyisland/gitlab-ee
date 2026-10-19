---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 安装离线的极狐GitLab 私有化部署实例
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: 私有化部署

{{< /details >}}

这是一份逐步指南，帮助您在完全离线的情况下安装、配置和使用一个极狐GitLab私有化部署实例。

<a id="installation"></a>

## 安装

{{< alert type="note" >}}

此指南假设服务器是 Ubuntu 20.04，使用 [Linux 软件包安装方法](https://gitlab.cn/docs/omnibus/)，并运行极狐GitLab [企业版](https://gitlab.cn/install/)。其他服务器的说明可能有所不同。此指南还假设服务器主机解析为 `my-host.internal`，您应该将其替换为您服务器的 FQDN，并且您可以访问另一台具有互联网访问权限的服务器以下载所需的软件包文件。

{{< /alert >}}

<a id="download-the-gitlab-package"></a>

### 下载极狐GitLab软件包

您应该使用具有互联网访问权限的相同操作系统类型的服务器[手动下载极狐GitLab软件包](../../../update/package/_index.md#by-using-a-downloaded-package)和相关依赖项。

如果您的离线环境没有本地网络访问，您必须通过物理介质（如 USB 驱动器）手动传输相关软件包。

在 Ubuntu 中，这可以在具有互联网访问权限的服务器上使用以下命令执行：

```shell
# 下载 bash 脚本以准备存储库
curl --silent "https://packages.gitlab.cn/repository/raw/scripts/setup.sh" | sudo bash

# 下载 gitlab-ee 软件包和依赖项到 /var/cache/apt/archives
sudo apt-get install --download-only gitlab-ee

# 将 apt 下载文件夹的内容复制到已挂载的媒体设备
sudo cp /var/cache/apt/archives/*.deb /path/to/mount
```

<a id="install-the-gitlab-package"></a>

### 安装极狐GitLab软件包

先决条件：

- 在离线环境中安装极狐GitLab软件包之前，请确保您已安装所有必需的依赖项。

如果您使用的是 Ubuntu，可以使用 `dpkg` 安装您复制过来的依赖项 `.deb` 软件包。暂时不要安装极狐GitLab软件包。

```shell
# 进入物理媒体设备
sudo cd /path/to/mount

# 安装依赖软件包
sudo dpkg -i <package_name>.deb
```

[使用适合您的操作系统的相关命令安装软件包](../../../update/package/_index.md#by-using-a-downloaded-package)，但请确保在 `EXTERNAL_URL` 安装步骤中指定一个 `http` URL。安装后，我们可以手动配置 SSL。

强烈建议设置一个用于 IP 解析的域名，而不是绑定到服务器的 IP 地址。这可以更好地确保我们的证书的 CN 的稳定目标，并简化长期解析。

以下是针对 Ubuntu 的示例，使用 HTTP 指定 `EXTERNAL_URL` 并安装极狐GitLab软件包：

```shell
sudo EXTERNAL_URL="http://my-host.internal" dpkg -i <gitlab_package_name>.deb
```

<a id="enabling-ssl"></a>

## 启用 SSL

按照以下步骤为您的新实例启用 SSL。这些步骤与[在 NGINX 配置中手动配置 SSL](https://gitlab.cn/docs/omnibus/settings/ssl/#configure-https-manually)的步骤相符：

1. 对 `/etc/gitlab/gitlab.rb` 进行以下更改：

   ```ruby
   # 将 external_url 从 "http" 更新为 "https"
   external_url "https://my-host.internal"

   # 设置 Let's Encrypt 为 false
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

<a id="enabling-the-gitlab-container-registry"></a>

## 启用极狐GitLab容器镜像仓库

按照以下步骤启用容器镜像仓库。这些步骤与[在现有域下配置容器镜像仓库](../../../administration/packages/container_registry.md#configure-container-registry-under-an-existing-gitlab-domain)的步骤相符：

1. 对 `/etc/gitlab/gitlab.rb` 进行以下更改：

   ```ruby
   # 更改 external_registry_url 以匹配 external_url，但附加端口 4567
   external_url "https://gitlab.example.com"
   registry_external_url "https://gitlab.example.com:4567"
   ```

1. 重新配置您的实例以应用更改：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="allow-the-docker-daemon-to-trust-the-registry-and-gitlab-runner"></a>

## 允许 Docker 守护程序信任注册表和极狐GitLab Runner

通过[遵循在注册表中使用受信任证书的步骤](../../../administration/packages/container_registry_troubleshooting.md#using-self-signed-certificates-with-container-registry)，为您的 Docker 守护程序提供您的证书：

```shell
sudo mkdir -p /etc/docker/certs.d/my-host.internal:5000

sudo cp /etc/gitlab/ssl/my-host.internal.crt /etc/docker/certs.d/my-host.internal:5000/ca.crt
```

通过[遵循在 runner 中使用受信任证书的步骤](https://gitlab.cn/docs/runner/install/docker.html#installing-trusted-ssl-server-certificates)，为您的极狐GitLab Runner（接下来要安装）提供您的证书：

```shell
sudo mkdir -p /etc/gitlab-runner/certs

sudo cp /etc/gitlab/ssl/my-host.internal.crt /etc/gitlab-runner/certs/ca.crt
```

<a id="enabling-gitlab-runner"></a>

## 启用极狐GitLab Runner

[按照类似于将极狐GitLab Runner 作为 Docker 服务安装的步骤](https://gitlab.cn/docs/runner/install/docker.html#install-the-docker-image-and-start-the-container)，我们必须首先注册我们的 runner：

```shell
$ sudo docker run --rm -it -v /etc/gitlab-runner:/etc/gitlab-runner registry.gitlab.cn/jihulab/gitlab-runner:latest register
Updating CA certificates...
Runtime platform                                    arch=amd64 os=linux pid=7 revision=1b659122 version=12.8.0
Running in system-mode.

Enter the GitLab instance URL (for example, https://gitlab.com/):
https://my-host.internal
Enter the registration token:
XXXXXXXXXXX
Enter a description for the runner:
[eb18856e13c0]:
Enter tags for the runner (comma-separated):
Enter optional maintenance note for the runner:

Registering runner... succeeded                     runner=FSMwkvLZ
Please enter the executor: custom, docker, virtualbox, kubernetes, docker+machine, docker-ssh+machine, docker-ssh, parallels, shell, ssh:
docker
Please enter the default Docker image (for example, ruby:2.6):
ruby:2.6
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```

现在我们必须为我们的 runner 添加一些额外的配置：

对 `/etc/gitlab-runner/config.toml` 进行以下更改：

- 将 Docker socket 添加到 volumes `volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]`
- 将 `pull_policy = "if-not-present"` 添加到执行器配置

现在我们可以启动我们的 runner：

```shell
sudo docker run -d --restart always --name gitlab-runner -v /etc/gitlab-runner:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock registry.gitlab.cn/jihulab/gitlab-runner:latest
90646b6587127906a4ee3f2e51454c6e1f10f26fc7a0b03d9928d8d0d5897b64
```

<a id="authenticating-the-registry-against-the-host-os"></a>

### 针对主机操作系统进行注册表身份验证

在 Ubuntu 的情况下，这涉及到使用 `update-ca-certificates`：

```shell
sudo cp /etc/docker/certs.d/my-host.internal\:5000/ca.crt /usr/local/share/ca-certificates/my-host.internal.crt

sudo update-ca-certificates
```

如果一切顺利，您应该会看到：

```plaintext
1 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d...
done.
```

<a id="disable-version-check-and-service-ping"></a>

### 禁用版本检查和服务 Ping

版本检查和服务 Ping 改善了极狐GitLab 用户体验，并确保用户处于极狐GitLab 的最新实例。这两个服务可以为离线环境关闭，以便它们不会尝试并无法联系极狐GitLab 服务。

有关详细信息，请参见[启用或禁用服务 Ping](../../../administration/settings/usage_statistics.md#enable-or-disable-service-ping)。

<a id="disable-runner-version-management"></a>

### 禁用 runner 版本管理

Runner 版本管理从极狐GitLab 检索最新的 runner 版本，以[确定您环境中的哪些 runner 已过时](../../../ci/runners/runners_scope.md#determine-which-runners-need-to-be-upgraded)。您必须为离线环境[禁用 runner 版本管理](../../../administration/settings/continuous_integration.md#disable-runner-version-management)。

<a id="configure-ntp"></a>

### 配置 NTP

在极狐GitLab 15.4 和 15.5 中，Gitaly 集群假设 `pool.ntp.org` 是可访问的。如果 `pool.ntp.org` 不可访问，请在 Gitaly 和 Praefect 服务器上[自定义时间服务器设置](../../../administration/gitaly/praefect.md#customize-time-server-setting)，以便它们可以使用可访问的 NTP 服务器。

在离线实例上，[极狐GitLab Geo 检查 Rake 任务](../../../administration/geo/replication/troubleshooting/common.md#can-geo-detect-the-current-site-correctly)总是失败，因为它使用 `pool.ntp.org`。此错误可以忽略，但您可以[阅读有关如何解决此问题的更多信息](../../../administration/geo/replication/troubleshooting/common.md#message-machine-clock-is-synchronized--exception)。

<a id="enabling-the-package-metadata-database"></a>

## 启用软件包元数据数据库

启用软件包元数据数据库是启用[持续漏洞扫描](../../../user/application_security/continuous_vulnerability_scanning/_index.md)和[对 CycloneDX 文件的许可证扫描](../../../user/compliance/license_scanning_of_cyclonedx_files/_index.md)所必需的。此过程需要使用被统称为软件包元数据数据库的许可证和/或建议数据，该数据库根据企业版许可证授权。请注意以下与使用软件包元数据数据库相关的内容：

- 我们可能会在任何时间且不另行通知的情况下更改或停止软件包元数据数据库的全部或任何部分，完全由我们自行决定。
- 软件包元数据数据库可能包含指向第三方网站或资源的链接。我们仅提供这些链接作为方便之用，不对这些网站或资源或在这些网站上显示的链接的任何第三方数据、内容、产品或服务负责。
- 软件包元数据数据库部分基于第三方提供的信息，极狐GitLab 对所提供内容的准确性或完整性不承担责任。

软件包元数据存储在以下 Google Cloud Provider (GCP) 存储桶中：

- 许可证扫描 - prod-export-license-bucket-1a6c642fc4de57d4
- 依赖性扫描 - prod-export-advisory-bucket-1a6c642fc4de57d4

<a id="using-the-gsutil-tool-to-download-the-package-metadata-exports"></a>

### 使用 gsutil 工具下载软件包元数据导出

1. 安装 `gsutil` 工具。
1. 找到极狐GitLab Rails 目录的根目录。

   ```shell
   export GITLAB_RAILS_ROOT_DIR="$(gitlab-rails runner 'puts Rails.root.to_s')"
   echo $GITLAB_RAILS_ROOT_DIR
   ```

1. 设置您希望同步的数据类型。

   ```shell
   # 对于许可证扫描
   export PKG_METADATA_BUCKET=prod-export-license-bucket-1a6c642fc4de57d4
   export DATA_DIR="licenses"

   # 对于依赖性扫描
   export PKG_METADATA_BUCKET=prod-export-advisory-bucket-1a6c642fc4de57d4
   export DATA_DIR="advisories"
   ```

1. 下载软件包元数据导出。

   ```shell
   # 要下载软件包元数据导出，必须允许与 Google Cloud Storage 存储桶的出站连接。
   # 使用 -y "^v1\/" 跳过 v1 对象，只下载 v2 对象。v1 数据不再使用，并自 16.3 起被弃用。
   mkdir -p "$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/$DATA_DIR"
   gsutil -m rsync -r -d -y "^v1\/" gs://$PKG_METADATA_BUCKET "$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/$DATA_DIR"

   # 或者，如果极狐GitLab 实例不允许连接到 Google Cloud Storage 存储桶，可以使用具有允许访问权限的机器下载软件包元数据导出，然后复制到极狐GitLab Rails 目录的根目录。
   rsync rsync://example_username@gitlab.example.com/package_metadata/$DATA_DIR "$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/$DATA_DIR"
   ```

<a id="automatic-synchronization"></a>

### 自动同步

您的极狐GitLab 实例会定期与 `package_metadata` 目录的内容同步。为了自动将本地副本更新为上游更改，可以添加一个 cron 作业以定期下载新的导出。例如，可以添加以下 crontabs 来设置每 30 分钟运行一次的 cron 作业。

对于许可证扫描：

```plaintext
*/30 * * * * gsutil -m rsync -r -d -y "^v1\/" gs://prod-export-license-bucket-1a6c642fc4de57d4 $GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/licenses
```

对于依赖性扫描：

```plaintext
*/30 * * * * gsutil -m rsync -r -d gs://prod-export-advisory-bucket-1a6c642fc4de57d4 $GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/advisories
```

<a id="change-note"></a>

### 变更说明

软件包元数据目录随 16.2 版本从 `vendor/package_metadata_db` 更改为 `vendor/package_metadata/licenses`。如果此目录已存在于实例上，并且需要添加依赖性扫描，则需要执行以下步骤。

1. 重命名许可证目录：`mv vendor/package_metadata_db vendor/package_metadata/licenses`。
1. 更新任何自动化脚本或保存的命令，将 `vendor/package_metadata_db` 更改为 `vendor/package_metadata/licenses`。
1. 更新任何 cron 条目，将 `vendor/package_metadata_db` 更改为 `vendor/package_metadata/licenses`。

   ```shell
   sed -i '.bckup' -e 's#vendor/package_metadata_db#vendor/package_metadata/licenses#g' [FILE ...]
   ```

<a id="troubleshooting"></a>

### 故障排除

#### 缺少数据库数据

如果许可证或建议数据在依赖列表或 MR 页面上缺失，可能的原因之一是数据库尚未与导出数据同步。

`package_metadata` 同步是通过使用 cron 作业和许可证同步触发的，并且仅导入在[管理员设置](../../../administration/settings/security_and_compliance.md#choose-package-registry-metadata-to-sync)中启用的软件包仓库类型。

`vendor/package_metadata` 中的文件结构必须与上面启用的软件包仓库类型一致。例如，要同步 `maven` 许可证或建议数据，Rails 目录下的软件包元数据目录必须具有以下结构：

- 对于许可证：`$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/licenses/v2/maven/**/*.ndjson`。
- 对于建议：`$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/advisories/v2/maven/**/*.ndjson`。

成功运行后，数据库中的 `pm_` 表下的数据应该被填充（使用 [Rails 控制台](../../../administration/operations/rails_console.md) 检查）：

- 对于许可证：`sudo gitlab-rails runner "puts \"Package model has #{PackageMetadata::Package.where(purl_type: 'maven').size} packages\""`
- 对于建议：`sudo gitlab-rails runner "puts \"Advisory model has #{PackageMetadata::AffectedPackage.where(purl_type: 'maven').size} packages\""`

此外，应存在针对正在同步的特定软件包仓库的检查点数据。例如，对于 Maven，应该在成功同步运行后创建一个检查点：

- 对于许可证：`sudo gitlab-rails runner "puts \"maven data has been synced up to #{PackageMetadata::Checkpoint.where(data_type: 'licenses', purl_type: 'maven')}\""`
- 对于建议：`sudo gitlab-rails runner "puts \"maven data has been synced up to #{PackageMetadata::Checkpoint.where(data_type: 'advisories', purl_type: 'maven')}\""`

最后，您可以检查 [`application_json.log`](../../../administration/logs/_index.md#application_jsonlog) 日志，以验证同步作业是否已运行且没有错误，方法是搜索类为 `PackageMetadata::SyncService` 的 `DEBUG` 消息。例如：`{"severity":"DEBUG","time":"2023-06-22T16:41:00.825Z","correlation_id":"a6e80150836b4bb317313a3fe6d0bbd6","class":"PackageMetadata::SyncService","message":"Evaluating data for licenses:gcp/prod-export-license-bucket-1a6c642fc4de57d4/v2/pypi/1694703741/0.ndjson"}`。
