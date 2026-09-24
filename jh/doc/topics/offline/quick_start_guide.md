---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Install, configure, and use a GitLab Self-Managed instance in an environment with no internet access.
title: 安装离线极狐GitLab私有化部署实例
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

这是一个分步指南，帮助你完全离线安装、配置和使用极狐GitLab 私有化部署实例。

## 安装

> [!note]
> 本指南假设服务器为 Ubuntu 20.04，使用 [Linux 软件包安装方式](https://gitlab.cn/docs/omnibus/) 并运行极狐GitLab [企业版](https://gitlab.cn/install/ce-or-ee/)。其他服务器的说明可能有所不同。
> 本指南还假设服务器主机解析为 `my-host.internal`，你应该将其替换为你服务器的 FQDN，并且你可以访问另一台具有互联网访问权限的服务器以下载所需的软件包文件。

### 下载极狐GitLab 软件包

你应该使用一台相同操作系统类型且具有互联网访问权限的服务器来[下载极狐GitLab 软件包](../../update/package/_index.md#upgrade-with-a-downloaded-package)和相关依赖项。

如果你的离线环境没有本地网络访问权限，则必须通过物理介质（如 USB 驱动器）手动传输相关软件包。

在 Ubuntu 中，可以在具有互联网访问权限的服务器上使用以下命令执行此操作：

```shell
# 下载 bash 脚本以准备仓库
curl --silent "https://packages.gitlab.cn/repository/raw/scripts/setup.sh" | sudo bash

# 将 gitlab-ee 软件包和依赖项下载到 /var/cache/apt/archives
sudo apt-get install --download-only gitlab-ee

# 将 apt 下载文件夹的内容复制到已挂载的媒体设备
sudo cp /var/cache/apt/archives/*.deb /path/to/mount
```

### 安装极狐GitLab 软件包

前提条件：

- 在离线环境中安装极狐GitLab 软件包之前，请确保已首先安装所有必需的依赖项。

如果你使用的是 Ubuntu，则可以使用 `dpkg` 安装你复制过来的依赖项 `.deb` 软件包。暂时不要安装极狐GitLab 软件包。

```shell
# 进入物理媒体设备
sudo cd /path/to/mount

# 安装依赖包
sudo dpkg -i <package_name>.deb
```

[使用与你操作系统相关的命令来安装软件包](../../update/package/_index.md#upgrade-with-a-downloaded-package)，但务必在 `EXTERNAL_URL` 安装步骤中指定一个 `http` URL。安装完成后，你可以稍后手动配置 SSL。

你应该为 IP 解析设置一个域名，而不是绑定到服务器的 IP 地址。域名会为证书的通用名称 (CN) 提供一个稳定的目标，并简化长期解析。

以下 Ubuntu 示例使用 HTTP 指定 `EXTERNAL_URL` 并安装极狐GitLab 软件包：

```shell
sudo EXTERNAL_URL="http://my-host.internal" dpkg -i <gitlab_package_name>.deb
```

## 启用 SSL

按照以下步骤为你的新实例启用 SSL。这些步骤类似于[在 NGINX 配置中手动配置 SSL](https://gitlab.cn/docs/omnibus/settings/ssl/#configure-https-manually) 的步骤：

1. 对 `/etc/gitlab/gitlab.rb` 进行以下更改：

   ```ruby
   # 将 external_url 从 "http" 更新为 "https"
   external_url "https://my-host.internal"

   # 将 Let's Encrypt 设置为 false
   letsencrypt['enable'] = false
   ```

1. 创建具有适当权限的以下目录，用于生成自签名证书：

   ```shell
   sudo mkdir -p /etc/gitlab/ssl
   sudo chmod 755 /etc/gitlab/ssl
   sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/gitlab/ssl/my-host.internal.key -out /etc/gitlab/ssl/my-host.internal.crt
   ```

1. 重新配置你的实例以应用更改：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

## 启用极狐GitLab 容器镜像仓库

按照以下步骤启用容器镜像仓库。这些步骤类似于[在现有域名下配置容器镜像仓库](../../administration/packages/container_registry.md#configure-container-registry-under-an-existing-gitlab-domain) 的步骤：

<a id="allow-the-docker-daemon-to-trust-the-registry-and-gitlab-runner"></a>

1. 对 `/etc/gitlab/gitlab.rb` 进行以下更改：

   ```ruby
   # 更改 external_registry_url 以匹配 external_url，但附加端口 4567
   external_url "https://gitlab.example.com"
   registry_external_url "https://gitlab.example.com:4567"
   ```

1. 重新配置你的实例以应用更改：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

## 允许 Docker 守护进程信任镜像仓库和极狐GitLab Runner

通过[按照对镜像仓库使用可信证书的步骤](../../administration/packages/container_registry.md#configure-self-signed-certificates) 为你的 Docker 守护进程提供证书：

```shell
sudo mkdir -p /etc/docker/certs.d/my-host.internal:5000

sudo cp /etc/gitlab/ssl/my-host.internal.crt /etc/docker/certs.d/my-host.internal:5000/ca.crt
```

通过[按照对 runner 使用可信证书的步骤](https://gitlab.cn/docs/runner/install/docker/#installing-trusted-ssl-server-certificates) 为你的极狐GitLab Runner（下一步安装）提供证书：

```shell
sudo mkdir -p /etc/gitlab-runner/certs

sudo cp /etc/gitlab/ssl/my-host.internal.crt /etc/gitlab-runner/certs/ca.crt
```

## 启用极狐GitLab Runner

[遵循与将极狐GitLab Runner 安装为 Docker 服务的步骤类似的过程](https://gitlab.cn/docs/runner/install/docker/#install-the-docker-image-and-start-the-container)，你必须首先注册你的 runner：

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

接下来，你必须向你的 runner 添加一些额外的配置。

对 `/etc/gitlab-runner/config.toml` 进行以下更改：

- 将 Docker 套接字添加到卷 `volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]`
- 向执行器配置添加 `pull_policy = "if-not-present"`

现在你可以启动你的 runner：

```shell
sudo docker run -d --restart always --name gitlab-runner -v /etc/gitlab-runner:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock registry.gitlab.cn/jihulab/gitlab-runner:latest
90646b6587127906a4ee3f2e51454c6e1f10f26fc7a0b03d9928d8d0d5897b64
```

<a id="authenticating-the-registry-against-the-host-os"></a>

### 针对主机操作系统认证镜像仓库

正如 [Docker 镜像仓库身份验证文档](https://distribution.github.io/distribution/about/insecure/#docker-still-complains-about-the-certificate-when-using-authentication) 中所指出的，某些版本的 Docker 要求在操作系统级别信任证书链。

在 Ubuntu 中，这涉及使用 `update-ca-certificates`：

```shell
sudo cp /etc/docker/certs.d/my-host.internal\:5000/ca.crt /usr/local/share/ca-certificates/my-host.internal.crt

sudo update-ca-certificates
```

如果一切顺利，你应该会看到以下内容：

```plaintext
1 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d...
done.
```

<a id="disable-version-check-and-service-ping"></a>

### 禁用版本检查和服务 Ping

版本检查和服务 Ping 可以改善极狐GitLab 用户体验，并确保用户使用的是最新版本的极狐GitLab。对于离线环境，可以关闭这两项服务，以免它们尝试连接极狐GitLab 服务但连接失败。

更多信息，请参见[启用或禁用服务 ping](../../administration/settings/usage_statistics.md#enable-or-disable-service-ping)。

<a id="disable-runner-version-management"></a>

### 禁用 runner 版本管理

Runner 版本管理从极狐GitLab 获取最新的 runner 版本，以[确定你的环境中哪些 runner 已过时](../../ci/runners/runners_scope.md#determine-which-runners-need-to-be-upgraded)。对于离线环境，你必须[禁用 runner 版本管理](../../administration/settings/continuous_integration.md#control-runner-version-management)。

<a id="configure-ntp"></a>

### 配置 NTP

Gitaly 集群 (Praefect) 假定 `pool.ntp.org` 是可访问的。如果 `pool.ntp.org` 不可访问，请在 Gitaly 和 Praefect 服务器上[自定义时间服务器设置](../../administration/gitaly/praefect/configure.md#customize-time-server-setting)，以便它们可以使用可访问的 NTP 服务器。

在离线实例上，[极狐GitLab Geo 检查 Rake 任务](../../administration/geo/replication/troubleshooting/common.md#can-geo-detect-the-current-site-correctly) 总是会失败，因为它使用了 `pool.ntp.org`。此错误可以忽略，但你可以[阅读更多关于如何解决它的信息](../../administration/geo/replication/troubleshooting/common.md#message-machine-clock-is-synchronized--exception)。

## 启用软件包元数据数据库

启用软件包元数据数据库是启用[持续漏洞扫描](../../user/application_security/continuous_vulnerability_scanning/_index.md) 和 [CycloneDX 文件的许可证扫描](../../user/compliance/license_scanning_of_cyclonedx_files/_index.md) 所必需的。此过程需要使用许可证和/或公告数据，这些数据统称为软件包元数据数据库，其许可依据为 [EE 许可证](https://storage.googleapis.com/prod-export-license-bucket-1a6c642fc4de57d4/LICENSE)。关于使用软件包元数据数据库，请注意以下事项：

- 我们可能随时自行决定更改或终止软件包元数据数据库的全部或任何部分，恕不另行通知。
- 软件包元数据数据库可能包含指向第三方网站或资源的链接。我们提供这些链接仅为方便起见，不对这些网站或资源上的任何第三方数据、内容、产品或服务或此类网站上显示的链接负责。
- 软件包元数据数据库部分基于第三方提供的信息，极狐GitLab 不对所提供内容的准确性或完整性负责。

软件包元数据存储在以下由极狐GitLab 维护和拥有的 GCP 存储桶中：

- 许可证扫描 - `prod-export-license-bucket-1a6c642fc4de57d4`
- 依赖项扫描 - `prod-export-advisory-bucket-1a6c642fc4de57d4`

<a id="using-the-gsutil-tool-to-download-the-package-metadata-exports"></a>

### 使用 gsutil 工具下载软件包元数据导出

1. 安装 [`gsutil`](https://cloud.google.com/storage/docs/gsutil_install) 工具。
1. 找到极狐GitLab Rails 目录的根目录。

   ```shell
   export GITLAB_RAILS_ROOT_DIR="$(gitlab-rails runner 'puts Rails.root.to_s')"
   echo $GITLAB_RAILS_ROOT_DIR
   ```

1. 设置你想要同步的数据类型。

   ```shell
   # 用于许可证扫描
   export PKG_METADATA_BUCKET=prod-export-license-bucket-1a6c642fc4de57d4
   export DATA_DIR="licenses"

   # 用于依赖项扫描
   export PKG_METADATA_BUCKET=prod-export-advisory-bucket-1a6c642fc4de57d4
   export DATA_DIR="advisories"
   ```

1. 下载软件包元数据导出。

   ```shell
   # 要下载软件包元数据导出，必须允许到 Google Cloud Storage 存储桶的出站连接。
   mkdir -p "$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/$DATA_DIR"
   gsutil -m rsync -r -d gs://$PKG_METADATA_BUCKET "$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/$DATA_DIR"

   # 或者，如果不允许极狐GitLab 实例连接到 Google Cloud Storage 存储桶，则可以使用具有允许访问权限的机器下载软件包元数据导出，然后将其复制到极狐GitLab Rails 目录的根目录。
   rsync rsync://example_username@gitlab.example.com/package_metadata/$DATA_DIR "$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/$DATA_DIR"
   ```

<a id="using-the-google-cloud-storage-rest-api-to-download-the-package-metadata-exports"></a>

### 使用 Google Cloud Storage REST API 下载软件包元数据导出

软件包元数据导出也可以使用 Google Cloud Storage API 下载。内容可在 <https://storage.googleapis.com/storage/v1/b/prod-export-license-bucket-1a6c642fc4de57d4/o> 和 <https://storage.googleapis.com/storage/v1/b/prod-export-advisory-bucket-1a6c642fc4de57d4/o> 获取。以下是使用 [cURL](https://curl.se/) 和 [jq](https://stedolan.github.io/jq/) 下载的示例。

```shell
#!/bin/bash

set -euo pipefail

DATA_TYPE=$1

GITLAB_RAILS_ROOT_DIR="$(gitlab-rails runner 'puts Rails.root.to_s')"

if [ "$DATA_TYPE" == "license" ]; then
  PKG_METADATA_DIR="$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/licenses"
elif [ "$DATA_TYPE" == "advisory" ]; then
  PKG_METADATA_DIR="$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/advisories"
else
  echo "Usage: import_script.sh [license|advisory]"
  exit 1
fi

PKG_METADATA_BUCKET="prod-export-$DATA_TYPE-bucket-1a6c642fc4de57d4"
PKG_METADATA_DOWNLOADS_OUTPUT_FILE="/tmp/package_metadata_${DATA_TYPE}_object_links.tsv"

# 下载存储桶的内容
# 该脚本下载所有对象，并创建每个文件最多包含 1000 个对象的 JSON 格式文件。

MAX_RESULTS=1000
TEMP_FILE="out.json"

curl --silent --show-error --request GET "https://storage.googleapis.com/storage/v1/b/$PKG_METADATA_BUCKET/o?maxResults=$MAX_RESULTS" >"$TEMP_FILE"
NEXT_PAGE_TOKEN="$(jq -r '.nextPageToken' $TEMP_FILE)"
jq -r '.items[] | [.name, .mediaLink] | @tsv' "$TEMP_FILE" >"$PKG_METADATA_DOWNLOADS_OUTPUT_FILE"

while [ "$NEXT_PAGE_TOKEN" != "null" ]; do
  curl --silent --show-error --request GET "https://storage.googleapis.com/storage/v1/b/$PKG_METADATA_BUCKET/o?maxResults=$MAX_RESULTS&pageToken=$NEXT_PAGE_TOKEN" >"$TEMP_FILE"
  NEXT_PAGE_TOKEN="$(jq -r '.nextPageToken' $TEMP_FILE)"
  jq -r '.items[] | [.name, .mediaLink] | @tsv' "$TEMP_FILE" >>"$PKG_METADATA_DOWNLOADS_OUTPUT_FILE"
  #用于 API 速率限制
  sleep 1
done

trap 'rm -f "$TEMP_FILE"' EXIT

echo "Fetched $DATA_TYPE export manifest"

# 解析存储桶对象的链接和名称，并将它们输出到 tsv 文件

echo -e "Saving package metadata exports to $PKG_METADATA_DIR\n"

# 跟踪将下载多少个对象
INDEX=1
TOTAL_OBJECT_COUNT="$(wc -l "$PKG_METADATA_DOWNLOADS_OUTPUT_FILE" | awk '{print $1}')"

# 下载对象
while IFS= read -r line; do
  FILE="$(echo -n "$line" | awk '{print $1}')"
  URL="$(echo -n "$line" | awk '{print $2}')"
  OUTPUT_PATH="$PKG_METADATA_DIR/$FILE"

  echo "Downloading $FILE"

  if [ ! -f "$OUTPUT_PATH" ]; then
    curl --progress-bar --create-dirs --output "$OUTPUT_PATH" --request "GET" "$URL"
  else
    echo "Existing file found"
  fi

  echo -e "$INDEX of $TOTAL_OBJECT_COUNT objects downloaded\n"

  INDEX=$((INDEX + 1))
done <"$PKG_METADATA_DOWNLOADS_OUTPUT_FILE"

echo "All objects saved to $PKG_METADATA_DIR"
```

<a id="automatic-synchronization"></a>

### 自动同步

你的极狐GitLab 实例会[定期](https://gitlab.com/gitlab-org/gitlab/-/blob/63a187d47f6da353ba4514650bbbbeb99c356325/config/initializers/1_settings.rb#L840-842) 与 `package_metadata` 目录的内容同步。
为了自动使用上游更改更新你的本地副本，可以添加一个 cron 作业来定期下载新的导出。例如，可以添加以下 crontab 来设置每 30 分钟运行一次的 cron 作业。

用于许可证扫描：

```plaintext
*/30 * * * * gsutil -m rsync -r -d -y "^v1\/" gs://prod-export-license-bucket-1a6c642fc4de57d4 $GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/licenses
```

用于依赖项扫描：

```plaintext
*/30 * * * * gsutil -m rsync -r -d gs://prod-export-advisory-bucket-1a6c642fc4de57d4 $GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/advisories
```

<a id="change-note"></a>

### 更改说明

随着 16.2 版本的发布，软件包元数据的目录从 `vendor/package_metadata_db` 更改为 `vendor/package_metadata/licenses`。如果此目录已存在于实例上，并且需要添加依赖项扫描，那么你需要执行以下步骤。

1. 重命名许可证目录：`mv vendor/package_metadata_db vendor/package_metadata/licenses`。
1. 更新所有已保存的自动化脚本或命令，将 `vendor/package_metadata_db` 更改为 `vendor/package_metadata/licenses`。
1. 更新所有 cron 条目，将 `vendor/package_metadata_db` 更改为 `vendor/package_metadata/licenses`。

   ```shell
   sed -i '.bckup' -e 's#vendor/package_metadata_db#vendor/package_metadata/licenses#g' [FILE ...]
   ```

<a id="troubleshooting"></a>

### 故障排除

<a id="missing-database-data"></a>

#### 缺少数据库数据

如果依赖项列表、漏洞报告或合并请求页面中缺少许可证或公告数据，则数据库可能尚未与导出数据同步。

##### 确认已启用的软件包仓库类型

`package_metadata` 同步通过使用 cron 作业触发（[公告同步](https://gitlab.com/gitlab-org/gitlab/-/blob/16-3-stable-ee/config/initializers/1_settings.rb#L864-866) 和 [许可证同步](https://gitlab.com/gitlab-org/gitlab/-/blob/16-3-stable-ee/config/initializers/1_settings.rb#L855-857)）。只有在[管理员设置](../../administration/settings/security_and_compliance.md#choose-package-registry-metadata-to-sync) 中启用的软件包仓库类型才会被导入。

例如，如果选择了 `maven`，但没有选择 `golang`，你将只能看到 Maven 的公告和许可证信息。

##### 确认正确的文件结构

`vendor/package_metadata` 中的文件结构必须与之前启用的软件包仓库类型一致。例如，要同步 `maven` 许可证或公告数据，Rails 目录下的软件包元数据目录必须具有以下结构，其中 `$GITLAB_RAILS_ROOT_DIR` 与命令 `gitlab-rails runner 'puts Rails.root.to_s'` 的输出相匹配：

- 对于许可证：`$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/licenses/v2/maven/**/*.ndjson`。
- 对于公告：`$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/advisories/v2/maven/**/*.ndjson`。

你可以在 [Rails 控制台](../../administration/operations/rails_console.md) 中检查极狐GitLab 是否识别文件路径：

- 对于许可证：`sudo gitlab-rails runner "puts File.exist?(PackageMetadata::SyncConfiguration::Location::LICENSES_PATH)"`
- 对于公告：`sudo gitlab-rails runner "puts File.exist?(PackageMetadata::SyncConfiguration::Location::ADVISORIES_PATH)"`

如果上述命令返回 `false`，则极狐GitLab 无法找到预期的软件包路径。路径中的所有文件夹和文件必须具有 `755` 权限。要更新权限：

`sudo chmod -R 755 $GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/`

##### 验证数据

同步作业成功运行后，数据库中 `pm_` 表下的数据应该已被填充。

你可以通过使用 [Rails 控制台](../../administration/operations/rails_console.md) 检查某个供应商存在多少软件包来确认。例如，要确认 Maven 许可证和公告数据已加载，请运行：

- 对于许可证：`sudo gitlab-rails runner "puts \"Package model has #{PackageMetadata::Package.where(purl_type: 'maven').size} packages\""`
- 对于公告：`sudo gitlab-rails runner "puts \"Advisory model has #{PackageMetadata::AffectedPackage.where(purl_type: 'maven').size} packages\""`

此外，正在同步的特定软件包仓库应存在检查点数据。例如，对于 Maven，在成功同步运行后应创建一个检查点：

- 对于许可证：`sudo gitlab-rails runner "puts \"maven data has been synced up to #{PackageMetadata::Checkpoint.where(data_type: 'licenses', purl_type: 'maven')}\""`
- 对于公告：`sudo gitlab-rails runner "puts \"maven data has been synced up to #{PackageMetadata::Checkpoint.where(data_type: 'advisories', purl_type: 'maven')}\""`

##### 日志

[`application_json.log`](../../administration/logs/_index.md#application_jsonlog) 文件将有助于验证同步作业是否已运行且没有错误。与同步相关的事件的严重性级别为 `DEBUG`，类为 `PackageMetadata::SyncService`。
示例：
`{"severity":"DEBUG","time":"2026-01-07T02:15:49.618Z","meta.caller_id":"PackageMetadata::AdvisoriesSyncWorker","correlation_id":"43008e30dd708eadbe1ab16ad7fa953f","meta.root_caller_id":"Cronjob","meta.feature_category":"software_composition_analysis","meta.client_id":"ip/","class":"PackageMetadata::SyncService","message":"Evaluating data for advisories:offline//opt/gitlab/embedded/service/gitlab-rails/vendor/package_metadata/advisories/v2/maven/1761761049/0.ndjson"}`

[`sidekiq`](../../administration/logs/_index.md#sidekiq-logs) 日志将显示同步作业期间是否发生任何错误。为同步记录的事件将提及相关的类：

- 对于许可证：`PackageMetadata::LicensesSyncWorker`
- 对于公告：`PackageMetadata::AdvisoriesSyncWorker`