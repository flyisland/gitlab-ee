---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在无互联网访问的环境中安装、配置并使用极狐GitLab 私有化部署实例。
title: 安装离线极狐GitLab 私有化部署实例
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本指南分步介绍如何完全离线地安装、配置并使用极狐GitLab 私有化部署实例。

<a id="installation"></a>

## 安装

> [!note]
> 本指南假设服务器为 Ubuntu 20.04，使用 [Linux 软件包安装方式](../../install/package/_index.md)，并运行 GitLab 企业版。其他服务器的操作说明可能有所不同。
> 本指南还假设服务器主机名解析为 `my-host.internal`，您应将其替换为
> 服务器的 FQDN，并且您可以访问另一台可访问互联网的服务器来下载所需的软件包文件。


<a id="download-the-gitlab-package"></a>

### 下载极狐GitLab 软件包

您应使用一台操作系统类型相同且可访问互联网的服务器，[下载极狐GitLab 软件包](../../update/package/_index.md#upgrade-with-a-downloaded-package)及相关依赖项。

如果您的离线环境没有本地网络访问，则必须通过物理介质（例如 USB 驱动器）手动传输相关软件包。

在 Ubuntu 中，可以在可访问互联网的服务器上使用以下命令完成此操作：

```shell
# Download the bash script to prepare the repository
curl --silent "https://packages.gitlab.cn/repository/raw/scripts/setup.sh" | sudo bash

# Download the gitlab-jh package and dependencies to /var/cache/apt/archives
sudo apt-get install --download-only gitlab-jh

# Copy the contents of the apt download folder to a mounted media device
sudo cp /var/cache/apt/archives/*.deb /path/to/mount
```

<a id="install-the-gitlab-package"></a>

### 安装极狐GitLab 软件包

先决条件：

- 在离线环境中安装极狐GitLab 软件包之前，请确保已先安装所有必需的依赖项。

如果您使用 Ubuntu，可以使用 `dpkg` 安装您复制过来的依赖 `.deb` 软件包。此时请勿安装极狐GitLab 软件包。

```shell
# Go to the physical media device
sudo cd /path/to/mount

# Install the dependency packages
sudo dpkg -i <package_name>.deb
```

[使用适用于您操作系统的相关命令安装软件包](../../update/package/_index.md#upgrade-with-a-downloaded-package)，但请确保在 `EXTERNAL_URL` 安装步骤中指定 `http` URL。安装完成后，您可以自行手动
配置 SSL。

您应为 IP 解析设置一个域名，而不是绑定到服务器的 IP 地址。域名可为证书的通用名称（CN）提供稳定的目标，并简化长期的解析。

以下 Ubuntu 示例使用 HTTP 指定 `EXTERNAL_URL` 并安装极狐GitLab 软件包：

```shell
sudo EXTERNAL_URL="http://my-host.internal" dpkg -i <gitlab_package_name>.deb
```

<a id="enabling-ssl"></a>

## 启用 SSL

按照以下步骤为您的新实例启用 SSL。这些步骤与[在 NGINX 配置中手动配置 SSL](https://gitlab.cn/docs/omnibus/settings/ssl/#configure-https-manually)的步骤一致：

1. 对 `/etc/gitlab/gitlab.rb` 进行以下更改：

   ```ruby
   # Update external_url from "http" to "https"
   external_url "https://my-host.internal"

   # Set Let's Encrypt to false
   letsencrypt['enable'] = false
   ```

1. 创建以下目录并设置适当的权限，以生成自签名
   证书：

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

## 启用极狐GitLab 容器镜像仓库

按照以下步骤启用容器镜像仓库。这些步骤与[在现有域名下配置容器镜像仓库](../../administration/packages/container_registry.md#configure-container-registry-under-an-existing-gitlab-domain)的步骤一致：

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

<a id="allow-the-docker-daemon-to-trust-the-registry-and-gitlab-runner"></a>

## 允许 Docker 守护进程信任该镜像仓库和极狐GitLab Runner

通过[按照为镜像仓库使用受信任证书的步骤](../../administration/packages/container_registry.md#configure-self-signed-certificates)，为您的 Docker 守护进程提供证书：

```shell
sudo mkdir -p /etc/docker/certs.d/my-host.internal:5000

sudo cp /etc/gitlab/ssl/my-host.internal.crt /etc/docker/certs.d/my-host.internal:5000/ca.crt
```

通过[按照为 runner 使用受信任证书的步骤](https://gitlab.cn/docs/runner/install/docker/#installing-trusted-ssl-server-certificates)，为您的极狐GitLab Runner（将在下一步安装）提供证书：

```shell
sudo mkdir -p /etc/gitlab-runner/certs

sudo cp /etc/gitlab/ssl/my-host.internal.crt /etc/gitlab-runner/certs/ca.crt
```

<a id="enabling-gitlab-runner"></a>

## 启用极狐GitLab Runner

[按照与我们以 Docker 服务方式安装极狐GitLab Runner 的步骤类似的流程](https://gitlab.cn/docs/runner/install/docker/#install-the-docker-image-and-start-the-container)，您必须先注册您的 runner：

```shell
$ sudo docker run --rm -it -v /etc/gitlab-runner:/etc/gitlab-runner registry.gitlab.cn/jihulab/gitlab-runner register
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

接下来，您必须为 runner 添加一些额外的配置。

对 `/etc/gitlab-runner/config.toml` 进行以下更改：

- 将 Docker socket 添加到 volumes `volumes = ["/var/run/docker.sock:/var/run/docker.sock", "/cache"]`
- 将 `pull_policy = "if-not-present"` 添加到执行器配置

现在您可以启动您的 runner：

```shell
sudo docker run -d --restart always --name gitlab-runner -v /etc/gitlab-runner:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock registry.gitlab.cn/jihulab/gitlab-runner:latest
90646b6587127906a4ee3f2e51454c6e1f10f26fc7a0b03d9928d8d0d5897b64
```

<a id="authenticating-the-registry-against-the-host-os"></a>

### 针对主机操作系统对镜像仓库进行身份验证

如 [Docker 镜像仓库身份验证文档](https://distribution.github.io/distribution/about/insecure/#docker-still-complains-about-the-certificate-when-using-authentication)所述，某些版本的 Docker 要求在操作系统级别信任证书链。

对于 Ubuntu，这涉及使用 `update-ca-certificates`：

```shell
sudo cp /etc/docker/certs.d/my-host.internal\:5000/ca.crt /usr/local/share/ca-certificates/my-host.internal.crt

sudo update-ca-certificates
```

如果一切顺利，您应该会看到以下内容：

```plaintext
1 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d...
done.
```

<a id="disable-version-check-and-service-ping"></a>

### 禁用版本检查和服务 Ping

版本检查和服务 Ping 可改善极狐GitLab 用户体验，并确保用户使用最新版本的极狐GitLab 实例。对于离线环境，可以关闭这两项服务，使其不会尝试连接极狐GitLab 服务并失败。

更多信息，请参见[启用或禁用服务 Ping](../../administration/settings/usage_statistics.md#enable-or-disable-service-ping)。

<a id="disable-runner-version-management"></a>

### 禁用 runner 版本管理

Runner 版本管理会从极狐GitLab 获取最新的 runner 版本，以
[确定您环境中有哪些 runner 已过期](../../ci/runners/runners_scope.md#determine-which-runners-need-to-be-upgraded)。对于离线环境，您必须[禁用 runner 版本管理](../../administration/settings/continuous_integration.md#control-runner-version-management)。

<a id="configure-ntp"></a>

### 配置 NTP

Gitaly 集群（Praefect）假设 `pool.ntp.org` 可访问。如果 `pool.ntp.org` 不可访问，请在 Gitaly
和 Praefect 服务器上[自定义时间服务器设置](../../administration/gitaly/praefect/configure.md#customize-time-server-setting)，以便它们可以使用可访问的 NTP 服务器。

在离线实例上，[极狐GitLab Geo 检查 Rake 任务](../../administration/geo/replication/troubleshooting/common.md#can-geo-detect-the-current-site-correctly)
总是失败，因为它使用 `pool.ntp.org`。可以忽略此错误，但您可以[进一步了解如何规避它](../../administration/geo/replication/troubleshooting/common.md#message-machine-clock-is-synchronized--exception)。

<a id="enabling-the-package-metadata-database"></a>

## 启用软件包元数据数据库

启用软件包元数据数据库是启用[持续漏洞扫描](../../user/application_security/continuous_vulnerability_scanning/_index.md)和 [CycloneDX 文件的许可证扫描](../../user/compliance/license_scanning_of_cyclonedx_files/_index.md)所必需的。此过程需要使用统称为软件包元数据数据库的许可证数据和/或公告数据，其依据 [EE 许可证](https://storage.googleapis.com/prod-export-license-bucket-1a6c642fc4de57d4/LICENSE)授权。关于软件包元数据数据库的使用，请注意以下事项：

- 我们可自行决定随时更改或停止软件包元数据数据库的全部或任何部分，且无需通知。
- 软件包元数据数据库可能包含指向第三方网站或资源的链接。我们提供这些链接仅为方便起见，对来自这些网站或资源的任何第三方数据、内容、产品或服务，或此类网站上显示的链接概不负责。
- 软件包元数据数据库部分基于第三方提供的信息，GitLab 对所提供的准确性或完整性概不负责。

软件包元数据以两种格式版本发布：v2 和 v3，每个数据集使用其中一种：

| 格式版本 | 数据集            | 读取方                 | 下载来源                        |
|----------------|--------------------|-------------------------|----------------------------------------|
| v2             | 许可证           | 极狐GitLab 19.3 及更早版本 | 公共 GCP 存储桶                      |
| v2             | 公告         | 所有极狐GitLab 版本     | 公共 GCP 存储桶                      |
| v2             | CVE 增强     | 所有极狐GitLab 版本     | 公共 GCP 存储桶                      |
| v3             | 许可证           | 极狐GitLab 19.4 及更高版本   | 软件包元数据数据库分发服务 |
| v3             | 恶意软件公告 | 极狐GitLab 19.3 及更高版本   | 软件包元数据数据库分发服务 |

这两种格式版本保存的数据不同，下载方式也不同，因此下面各自有独立的操作步骤。有关许可证布局的详细信息，请参见 [v3 许可证数据格式版本](#v3-license-data-format-version)。

v2 数据存储在以下 Google Cloud Provider (GCP) 存储桶中，这些存储桶由
GitLab 维护和拥有，无需凭据即可读取：

- 许可证扫描：`prod-export-license-bucket-1a6c642fc4de57d4`
- 依赖项扫描：`prod-export-advisory-bucket-1a6c642fc4de57d4`
- CVE 增强：`prod-export-cve-enrichment-bucket-1a6c642fc4de57d4`

v3 数据没有公共存储桶。它由经过身份验证的极狐GitLab 服务分发，因此下载它需要许可证密钥。请参见[下载 v3 软件包元数据数据库数据](#download-v3-package-metadata-database-data)。

CVE 增强包含漏洞上显示的
[EPSS 评分和 KEV 状态](../../user/application_security/vulnerabilities/risk_assessment_data.md)。
仅同步许可证和公告存储桶的实例具有依赖项扫描和许可证数据，但没有风险评估数据。

> [!note]
> 对于每个数据集，只要 `vendor/package_metadata` 下的目录存在，极狐GitLab 就会读取它，
> 优先于自行下载数据。
> 存在的目录始终优先，不会回退到存储桶或分发服务。
> 因此，保存过期数据的目录会提供过期数据，且不会报告错误。
> [恶意软件公告](#confirm-gitlab-detects-the-offline-directory)遵循相同的规则。

<a id="before-the-first-load"></a>

### 首次加载之前

在下载任何内容之前，请先决定要同步哪些软件包仓库类型。只有[管理员设置](../../administration/settings/security_and_compliance.md#choose-package-registry-metadata-to-sync)中启用的类型才会被导入。如果您下载了已禁用的类型，只会浪费时间和磁盘空间，且不会有任何数据进入数据库。

同步作业中的限流设置的是导入速率，而不是实例的资源，因此更大的实例并不会导入得更快。每次运行还会在固定时长后停止，并在下次运行时从其检查点继续。首次加载时如果启用了所有仓库类型，可能需要大约一天。要缩短时间，请减少启用的类型。

<a id="v2-using-the-gsutil-tool-to-download-the-package-metadata-exports"></a>

### v2：使用 gsutil 工具下载软件包元数据导出文件

本节介绍如何下载 v2 数据。

1. 安装 [`gsutil`](https://docs.cloud.google.com/storage/docs/gsutil_install) 工具。
1. 找到 GitLab Rails 目录的根目录。

   ```shell
   export GITLAB_RAILS_ROOT_DIR="$(gitlab-rails runner 'puts Rails.root.to_s')"
   echo $GITLAB_RAILS_ROOT_DIR
   ```

1. 设置您希望同步的数据类型。

   ```shell
   # For License Scanning
   export PKG_METADATA_BUCKET=prod-export-license-bucket-1a6c642fc4de57d4
   export DATA_DIR="licenses"

   # For dependency scanning
   export PKG_METADATA_BUCKET=prod-export-advisory-bucket-1a6c642fc4de57d4
   export DATA_DIR="advisories"

   # For CVE enrichment
   export PKG_METADATA_BUCKET=prod-export-cve-enrichment-bucket-1a6c642fc4de57d4
   export DATA_DIR="cve_enrichment"
   ```

1. 下载软件包元数据导出文件。

   ```shell
   # To download the package metadata exports, an outbound connection to Google Cloud Storage bucket must be allowed.
   mkdir -p "$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/$DATA_DIR"
   gsutil -m rsync -r -d gs://$PKG_METADATA_BUCKET "$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/$DATA_DIR"

   # Alternatively, if the GitLab instance is not allowed to connect to the Google Cloud Storage bucket, the package metadata
   # exports can be downloaded using a machine with the allowed access, and then copied to the root of the GitLab Rails directory.
   rsync rsync://example_username@gitlab.example.com/package_metadata/$DATA_DIR "$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/$DATA_DIR"
   ```

1. 仅对于 CVE 增强，将下载的文件上移一级目录。

   许可证和公告存储桶在 `v2/` 下为每个软件包仓库保存一个目录，极狐GitLab
   会按原样读取它们的副本。
   CVE 增强没有软件包仓库，其存储桶在该位置只有一个 `cve_enrichment` 目录。
   极狐GitLab 从 `cve_enrichment/v2/<sequence>/<chunk>.ndjson` 读取 CVE 增强数据，深度必须
   完全一致。按原样复制会使文件多出一级目录。
   极狐GitLab 随后不会导入任何内容，也不会记录任何日志。

   ```shell
   cd "$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/cve_enrichment/v2"
   cp -a cve_enrichment/. . && rm -r cve_enrichment
   ```

   每次下载 CVE 增强导出文件后都要重复此步骤。
   `cp -a` 会将新文件合并到已存在的序列目录中，而 `mv` 会停止。

<a id="v2-using-the-google-cloud-storage-rest-api-to-download-the-package-metadata-exports"></a>

### v2：使用 Google Cloud Storage REST API 下载软件包元数据导出文件

本节介绍下载 v2 软件包元数据的另一种方式。

软件包元数据导出文件也可以使用 Google Cloud Storage API 下载。内容可在 <https://storage.googleapis.com/storage/v1/b/prod-export-license-bucket-1a6c642fc4de57d4/o> 和 <https://storage.googleapis.com/storage/v1/b/prod-export-advisory-bucket-1a6c642fc4de57d4/o> 获取。以下示例展示如何使用 [cURL](https://curl.se/) 和 [jq](https://stedolan.github.io/jq/) 下载。

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

# Download the contents of the bucket
# The script downloads all the objects and creates files with a maximum 1000 objects per file in JSON format.

MAX_RESULTS=1000
TEMP_FILE="out.json"

curl --silent --show-error --request GET "https://storage.googleapis.com/storage/v1/b/$PKG_METADATA_BUCKET/o?maxResults=$MAX_RESULTS" >"$TEMP_FILE"
NEXT_PAGE_TOKEN="$(jq -r '.nextPageToken' $TEMP_FILE)"
jq -r '.items[] | [.name, .mediaLink] | @tsv' "$TEMP_FILE" >"$PKG_METADATA_DOWNLOADS_OUTPUT_FILE"

while [ "$NEXT_PAGE_TOKEN" != "null" ]; do
  curl --silent --show-error --request GET "https://storage.googleapis.com/storage/v1/b/$PKG_METADATA_BUCKET/o?maxResults=$MAX_RESULTS&pageToken=$NEXT_PAGE_TOKEN" >"$TEMP_FILE"
  NEXT_PAGE_TOKEN="$(jq -r '.nextPageToken' $TEMP_FILE)"
  jq -r '.items[] | [.name, .mediaLink] | @tsv' "$TEMP_FILE" >>"$PKG_METADATA_DOWNLOADS_OUTPUT_FILE"
  #use for API rate-limiting
  sleep 1
done

trap 'rm -f "$TEMP_FILE"' EXIT

echo "Fetched $DATA_TYPE export manifest"

# Parse the links and names for the bucket objects and output them into a tsv file

echo -e "Saving package metadata exports to $PKG_METADATA_DIR\n"

# Track how many objects will be downloaded
INDEX=1
TOTAL_OBJECT_COUNT="$(wc -l "$PKG_METADATA_DOWNLOADS_OUTPUT_FILE" | awk '{print $1}')"

# Download the objects
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

<a id="download-v3-package-metadata-database-data"></a>

### 下载 v3 软件包元数据数据库数据

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

与使用前述 `gsutil` 流程从公共存储桶镜像的 v2 许可证和公告导出文件不同，v3 上的许可证和恶意软件公告由经过身份验证的极狐GitLab 服务（软件包元数据数据库分发服务，PDS）分发，因此离线实例无法自行下载其中任何一种。您需要在可访问互联网的机器上下载数据，然后将其复制到离线实例。该脚本以数据集作为第一个参数，除此之外两者相同，因为这两个数据集仅在读取的分发服务路径和复制到的 vendor 目录上有所不同。

该脚本会向分发服务询问当前快照由哪些归档组成，这与在线实例同步时发出的请求相同，并且只有在所有归档都下载完成后才写入每个仓库的检查点。它会用您的许可证密钥换取一个有效期为三天的令牌。可访问互联网的机器需要您的许可证文件副本，但不需要访问离线实例。

先决条件：

- 管理员访问权限。
- 离线许可证。旧版许可证文件不可用：令牌请求会失败并返回 `Invalid cloud license`，脚本随即停止。**管理员**区域仪表板会在**许可证概览**下显示您的许可证类型。
- 在可访问互联网的机器上，需要 cURL、jq 1.6 或更高版本，以及对 `customers.gitlab.com`、`pmdb-dist-svc.runway.gitlab.net` 和 `storage.googleapis.com`的出站访问权限。分发服务位于 `gitlab.net` 域，因此仅限 `gitlab.com`的允许名单无法访问它。
- 在离线实例上，需要 rsync。

要获取离线许可证，您必须获得[云许可的退出豁免](https://about.gitlab.com/pricing/licensing-faq/cloud-licensing/#offline-cloud-licensing)，这需要审批。更多详情，请联系您的 GitLab 销售代表。如果您已有离线许可证，可以从[客户门户](https://customers.jihulab.com)再次下载该文件。

该脚本需要许可证密钥，即许可证文件中包含的那一大段文本。要将其写入文件，请在离线实例上运行以下命令：

```shell
sudo gitlab-rails runner 'puts License.current.data' > Gitlab.gitlab-license
```

激活码不是许可证密钥。激活码是一个短字符串，令牌请求会拒绝它。

这些步骤适用于 Linux 软件包安装。在 Kubernetes 安装中，数据必须位于 Sidekiq pod 可读取的卷上，相关进展记录在[议题 561085](https://gitlab.com/gitlab-org/gitlab/-/issues/561085)中。

> [!warning]
> 在 Docker 安装中，Rails 目录不在挂载的卷上。
> 请在复制数据之前绑定挂载 `vendor/package_metadata`，否则升级容器时数据会丢失。

将以下脚本保存为 `download_pmdb_data.sh`，并使用 `chmod +x download_pmdb_data.sh` 使其可执行。

```shell
#!/bin/bash

set -euo pipefail

CDOT_URL="${CDOT_URL:-https://customers.gitlab.com}"
PDS_URL="${PDS_URL:-https://pmdb-dist-svc.runway.gitlab.net}"

if [ $# -lt 5 ]; then
  echo "Usage: download_pmdb_data.sh <license_file> <gitlab_version> <dataset> <output_dir> <registry>..."
  echo "dataset is licenses or malware_advisories."
  echo "Pass the package registries to download, or 'all' for every supported registry."
  exit 1
fi

LICENSE_FILE=$1
GITLAB_VERSION=$2
DATASET=$3
OUTPUT_DIR=$4
shift 4
REQUESTED_REGISTRIES="$*"

# The two datasets differ only in their distribution service path and the name
# used in the closing message. Everything after this point is common to both.
case "$DATASET" in
licenses)
  DATASET_PATH="licenses"
  DATASET_LABEL="License data"
  ;;
malware_advisories)
  DATASET_PATH="malware/advisories"
  DATASET_LABEL="Advisories"
  ;;
*)
  echo "dataset must be licenses or malware_advisories"
  exit 1
  ;;
esac

if [ -z "$OUTPUT_DIR" ]; then
  echo "output_dir must not be empty"
  exit 1
fi

if [ ! -r "$LICENSE_FILE" ]; then
  echo "Cannot read $LICENSE_FILE"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Serialize runs against this output directory. Two concurrent runs would race
# on the same dataset directory: one can write checkpoint.json while the other
# has deleted and re-created the directory, leaving a partial shard set that
# GitLab imports as a complete snapshot. mkdir either creates the directory or
# fails, in one step, so it needs nothing beyond the shell.
LOCK_DIR="$OUTPUT_DIR/.download.lock"

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  echo "Another download is already running for $OUTPUT_DIR"
  echo "If no other run is active, remove $LOCK_DIR and try again."
  exit 1
fi

REQUEST_FILE="$(mktemp)"
RESPONSE_FILE="$(mktemp)"
SHARDS_FILE="$(mktemp)"
HEADER_FILE="$(mktemp)"
trap 'rm -f "$REQUEST_FILE" "$RESPONSE_FILE" "$SHARDS_FILE" "$HEADER_FILE"; rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT
chmod 600 "$HEADER_FILE"

# Exchange the license key for a Cloud Connector token.
GRAPHQL_QUERY='query($licenseKey: String!, $gitlabVersion: String!) {
  cloudConnectorAccess(licenseKey: $licenseKey, gitlabVersion: $gitlabVersion) {
    serviceToken { token }
  }
}'

jq --null-input --arg query "$GRAPHQL_QUERY" --rawfile licenseKey "$LICENSE_FILE" \
  --arg gitlabVersion "$GITLAB_VERSION" \
  '{query: $query, variables: {licenseKey: $licenseKey, gitlabVersion: $gitlabVersion}}' >"$REQUEST_FILE"

HTTP_STATUS="$(curl --silent --show-error --request POST "$CDOT_URL/graphql" \
  --header 'Content-Type: application/json' --data @"$REQUEST_FILE" \
  --output "$RESPONSE_FILE" --write-out '%{http_code}')"

if [ "$HTTP_STATUS" != "200" ]; then
  echo "Token request to $CDOT_URL failed with HTTP $HTTP_STATUS"
  head -c 500 "$RESPONSE_FILE"
  exit 1
fi

TOKEN="$(jq --raw-output '.data.cloudConnectorAccess.serviceToken.token // empty' "$RESPONSE_FILE")"

if [ -z "$TOKEN" ]; then
  echo "$CDOT_URL refused to issue a token for $LICENSE_FILE"
  echo "It must hold the license key, the output of: gitlab-rails runner 'puts License.current.data'"
  echo "An activation code is not a license key, and a legacy license is not accepted."
  echo "The customer portal reported:"
  jq --raw-output '.errors[]?.message // "no reason given"' "$RESPONSE_FILE"
  exit 1
fi

# The distribution service requires X-Gitlab-Instance-Id to equal the token's
# subject claim and X-Gitlab-Realm to equal its realm claim. Both are in the
# payload, which is the second dot-separated segment of the token.
CLAIMS="$(printf '%s' "$TOKEN" |
  jq --raw-input 'split(".")[1] | gsub("-"; "+") | gsub("_"; "/") | @base64d | fromjson')"

INSTANCE_ID="$(jq --raw-output '.sub // empty' <<<"$CLAIMS")"
REALM="$(jq --raw-output '.gitlab_realm // empty' <<<"$CLAIMS")"

if [ -z "$INSTANCE_ID" ] || [ -z "$REALM" ]; then
  echo "The token is missing its subject or realm claim"
  exit 1
fi

# Pass the headers through a file so the token never appears in a process
# list. It is readable there by any local user for the download's duration.
{
  printf 'header = "Authorization: Bearer %s"\n' "$TOKEN"
  printf 'header = "X-Gitlab-Instance-Id: %s"\n' "$INSTANCE_ID"
  printf 'header = "X-Gitlab-Realm: %s"\n' "$REALM"
} >"$HEADER_FILE"

# Writes the response body to $2 and returns the HTTP status.
pds_request() {
  curl --silent --show-error --config "$HEADER_FILE" \
    --output "$2" --write-out '%{http_code}' "$1"
}

HTTP_STATUS="$(pds_request "$PDS_URL/v1/$DATASET_PATH/supported" "$RESPONSE_FILE")"

if [ "$HTTP_STATUS" != "200" ]; then
  echo "Request for the supported package registries failed with HTTP $HTTP_STATUS"
  head -c 500 "$RESPONSE_FILE"
  exit 1
fi

SUPPORTED="$(jq --raw-output '.registries[]' "$RESPONSE_FILE")"
SKIPPED=""

if [ -z "$SUPPORTED" ]; then
  echo "No package registries are available"
  exit 1
fi

echo "Available package registries: $(echo "$SUPPORTED" | tr '\n' ' ')"

# Disable filename expansion so a registry name is never treated as a glob.
set -f

if [ "$REQUESTED_REGISTRIES" = "all" ]; then
  REGISTRIES="$SUPPORTED"
else
  REGISTRIES="$REQUESTED_REGISTRIES"

  for REGISTRY in $REGISTRIES; do
    if ! grep --quiet --fixed-strings --line-regexp "$REGISTRY" <<<"$SUPPORTED"; then
      echo "$REGISTRY is not a supported package registry"
      exit 1
    fi
  done
fi

for REGISTRY in $REGISTRIES; do
  HTTP_STATUS="$(pds_request "$PDS_URL/v1/$DATASET_PATH/all?purl_type=$REGISTRY" "$RESPONSE_FILE")"

  # A pending snapshot is the only skippable outcome. Every other 503 is
  # transient, and treating it as "no data" would delete a registry that the
  # instance already has.
  if [ "$HTTP_STATUS" = "503" ]; then
    # A 503 from in front of the service has no JSON body, so keep the reason
    # empty rather than letting jq abort the script.
    REASON="$(jq --raw-output '.reason // empty' "$RESPONSE_FILE" 2>/dev/null || true)"

    if [ "$REASON" = "snapshot_not_yet_published" ]; then
      echo "Skipping $REGISTRY, no snapshot is published yet"
      SKIPPED="$SKIPPED $REGISTRY"
      continue
    fi

    echo "Request for $REGISTRY failed with HTTP 503, try again later ($REASON)"
    exit 1
  fi

  if [ "$HTTP_STATUS" != "200" ]; then
    echo "Request for $REGISTRY failed with HTTP $HTTP_STATUS"
    head -c 500 "$RESPONSE_FILE"
    exit 1
  fi

  UNTIL="$(jq --raw-output '.until // empty' "$RESPONSE_FILE")"

  if [ -z "$UNTIL" ]; then
    echo "The response for $REGISTRY has no snapshot timestamp"
    exit 1
  fi
  DATASET_DIR="$OUTPUT_DIR/v3/$REGISTRY/full_dataset"

  # Skip the download when this snapshot is already on disk. Every archive in a
  # snapshot shares one `until`, so an unchanged value means no archive changed.
  if [ -r "$DATASET_DIR/checkpoint.json" ] &&
    [ "$(jq --raw-output '.until // empty' "$DATASET_DIR/checkpoint.json" 2>/dev/null)" = "$UNTIL" ]; then
    echo "Skipping $REGISTRY, snapshot $UNTIL is already downloaded"
    continue
  fi

  # Remove any previous snapshot. GitLab reads every archive in this directory,
  # so archives left over from an earlier snapshot would be imported alongside
  # the new ones, restoring data that changed since.
  rm -rf "$DATASET_DIR"
  mkdir -p "$DATASET_DIR"

  jq --raw-output '.shards[] | [.shard, (.signed_url // .url)] | @tsv' "$RESPONSE_FILE" >"$SHARDS_FILE"
  SHARD_COUNT="$(wc -l <"$SHARDS_FILE" | tr -d ' ')"

  while IFS=$'\t' read -r SHARD URL; do
    echo "Downloading $REGISTRY archive $SHARD"
    curl --fail --silent --show-error --location --output "$DATASET_DIR/$SHARD.tar.zst.part" "$URL"
    mv "$DATASET_DIR/$SHARD.tar.zst.part" "$DATASET_DIR/$SHARD.tar.zst"
  done <"$SHARDS_FILE"

  # Write the checkpoint last. GitLab ignores a directory that has no
  # checkpoint, so an interrupted download is never imported as a snapshot.
  jq --null-input --argjson until "$UNTIL" --argjson shards "$SHARD_COUNT" \
    '{until: $until, shards: $shards}' >"$DATASET_DIR/checkpoint.json"
done

set +f

if [ -n "$SKIPPED" ]; then
  echo "Warning: no snapshot is published yet for:$SKIPPED"
  echo "The downloaded registries are complete and safe to copy. Run the script again later to pick up the rest."
fi

echo "$DATASET_LABEL saved to $OUTPUT_DIR"
```

按如下方式调用该脚本：

```shell
./download_pmdb_data.sh <license_file> <gitlab_version> <dataset> <output_dir> <registry>...
```

| 参数         | 描述 |
|------------------|-------------|
| `license_file`   | 保存实例许可证密钥的文件路径，即 `sudo gitlab-rails runner 'puts License.current.data'` 的输出。激活码不是许可证密钥。 |
| `gitlab_version` | 导入数据的极狐GitLab 实例版本，即 `sudo gitlab-rails runner 'puts Gitlab::VERSION'` 的输出。例如 `19.4.0-ee`。 |
| `dataset`        | `licenses` 或 `malware_advisories`。 |
| `output_dir`     | 要写入的目录。如果不存在则创建。每次运行都使用同一目录，这样未更改的快照会被跳过。 |
| `registry`...    | 一个或多个软件包仓库，例如 `npm` 或 `pypi`，或使用 `all` 表示所有受支持的仓库。请传入在[管理员设置](../../administration/settings/security_and_compliance.md#choose-package-registry-metadata-to-sync)中已启用其类型的仓库。脚本会在下载任何内容之前打印受支持的列表。 |

该脚本会为每个软件包仓库创建一个目录，目录名使用仓库标识符而非软件包类型，例如：

```plaintext
licenses/
└── v3/
    └── npm/
        └── full_dataset/
            ├── 00.tar.zst
            ├── 01.tar.zst
            ├── ...
            ├── 7f.tar.zst
            └── checkpoint.json
```

每个归档都以其十六进制分片标识符命名。每个仓库的归档数量由服务设定，某个归档不包含任何数据是正常的。

该脚本会在输出目录上创建锁，因此如果您在第一次运行仍在写入数据时再次运行它，脚本会退出，而不会损坏该目录。当服务上的快照与输出目录中已有的快照一致时，脚本会跳过该仓库的下载，因此可以安全地按计划运行。

按照各自章节中的步骤将每个数据集复制到位：[许可证数据](#download-v3-license-data)和[恶意软件公告](#download-gitlab-v3-malware-advisories)。

<a id="download-gitlab-v3-malware-advisories"></a>

### 下载极狐GitLab v3 恶意软件公告

{{< details >}}

- Tier: 旗舰版
- Status: 测试版

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 除旗舰版外，此功能还提供给购买了依赖项防火墙附加组件的专业版客户。

[极狐GitLab 恶意软件公告](../../user/application_security/gitlab_advisory_database/_index.md#gitlab-malware-advisories)涵盖软件包仓库中发现的已知恶意软件包。它们由软件包元数据数据库分发服务分发，因此您需要在可访问互联网的机器上下载，然后复制到离线实例。使用共享脚本及其先决条件下载它们，详见[下载 v3 软件包元数据数据库数据](#download-v3-package-metadata-database-data)：

```shell
./download_pmdb_data.sh ./Gitlab.gitlab-license 19.3.0-ee malware_advisories ./malware_advisories npm pypi
```

要将公告复制到离线实例：

1. 将输出目录传输到离线实例。

1. 在离线实例上，找到 GitLab Rails 目录的根目录，然后将公告复制到位并更新权限。

   ```shell
   export GITLAB_RAILS_ROOT_DIR="$(sudo gitlab-rails runner 'puts Rails.root.to_s')"
   echo $GITLAB_RAILS_ROOT_DIR
   sudo mkdir -p "$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/malware_advisories"
   sudo rsync --recursive --delete ./malware_advisories/ "$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/malware_advisories/"
   sudo chmod -R 755 "$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/"
   ```

`PackageMetadata::MalwareAdvisoriesSyncWorker` cron 作业每五分钟运行一次，并在下次运行时导入公告。在极狐GitLab 私有化部署上，该作业会添加最多五分钟的偏移量，以分散各实例的负载，因此导入可能在您复制文件后最多十分钟才开始。只有[管理员设置](../../administration/settings/security_and_compliance.md#choose-package-registry-metadata-to-sync)中启用的软件包仓库类型才会被导入，因此实例可能保存着它从不导入的仓库的数据。

重复此过程以更新公告。每次运行都会下载完整快照，而不是一组变更。必须使用 `rsync --delete`，以免较早快照中的归档与新归档一起被导入。每次运行都复用同一输出目录：`rsync --delete` 会删除其中缺失的任何仓库，包括因快照尚未发布而被跳过的仓库。

当服务上的快照与输出目录中已有的快照一致时，脚本会跳过该仓库的下载。

<a id="download-v3-license-data"></a>

### 下载 v3 许可证数据

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
>
> 如果您关闭该标志，实例会回退到 v2 布局并丢弃其 v3 检查点。
> 如果您重新打开该标志，实例会从头重新导入 v3 数据，而不是从上次同步的快照继续。

v3 许可证数据布局使用软件包数据交换（SPDX）许可证表达式，而不是单个许可证标识符。例如 `MIT OR Apache-2.0`。

软件包元数据数据库分发服务分发 v3 许可证数据，因此您需要在可访问互联网的机器上下载，然后复制到离线实例。它只下载您已启用的仓库的当前快照，而不是许可证存储桶中保存的每种格式和增量。它不需要 `gsutil`。使用共享脚本及其先决条件下载它，详见[下载 v3 软件包元数据数据库数据](#download-v3-package-metadata-database-data)：

```shell
./download_pmdb_data.sh ./Gitlab.gitlab-license 19.4.0-ee licenses ./licenses npm pypi
```

当 `vendor/package_metadata/licenses` 下存在 `v3` 目录时，实例会从该目录同步许可证，而不是从 `v2` 目录。请在同步作业运行之前完成下面的复制步骤。

要将许可证数据复制到离线实例：

1. 将输出目录传输到离线实例。

1. 在离线实例上，找到 GitLab Rails 目录的根目录，然后将许可证数据复制到位并更新权限。

   ```shell
   export GITLAB_RAILS_ROOT_DIR="$(sudo gitlab-rails runner 'puts Rails.root.to_s')"
   echo $GITLAB_RAILS_ROOT_DIR
   export LICENSES_DIR="$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/licenses"
   sudo rm -rf "$LICENSES_DIR/v3.old" "$LICENSES_DIR/v3.incoming"
   sudo mkdir -p "$LICENSES_DIR/v3" "$LICENSES_DIR/v3.incoming"
   sudo rsync --recursive ./licenses/v3/ "$LICENSES_DIR/v3.incoming/"
   sudo mv "$LICENSES_DIR/v3" "$LICENSES_DIR/v3.old" && \
     sudo mv "$LICENSES_DIR/v3.incoming" "$LICENSES_DIR/v3" && \
     sudo rm -rf "$LICENSES_DIR/v3.old"
   sudo chmod -R 755 "$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/"
   ```

   这些命令只写入 `v3` 目录，因此已有的 `v2` 目录会保留在磁盘上，但不会被使用。

   实例会在 `v3` 目录存在后立即从该目录读取许可证。
   同步作业每五分钟运行一次，因此如果您直接复制到 `v3`，同步作业可能会读取
   一个仍在写入的目录，导致 `v3` 缺失或写入不完整。
   请改为复制到 `v3.incoming` 并通过重命名发布。

`PackageMetadata::LicensesSyncWorker` cron 作业每五分钟运行一次，并在下次运行时导入许可证数据。与公告一样，该作业只导入**管理员**区域中启用的软件包仓库类型，因此实例可能保存着它从不导入的仓库的数据。

要更新许可证数据，请重复此过程。每次运行都会下载完整快照，而不是一组变更。发布操作会替换整个 `v3` 目录，因此后续运行中遗漏的仓库将不再收到更新。该仓库已导入的许可证数据会保留在数据库中，下次您在运行中包含它时会恢复更新。

当服务上的快照与输出目录中已有的快照一致时，脚本会跳过该仓库的下载，因此可以安全地按计划运行。

<a id="automatic-synchronization"></a>

### 自动同步

您的极狐GitLab 实例会[定期](https://gitlab.com/gitlab-org/gitlab/-/blob/63a187d47f6da353ba4514650bbbbeb99c356325/config/initializers/1_settings.rb#L840-842)与 `package_metadata` 目录的内容同步。要使用上游变更自动更新本地副本，可以添加一个 cron 作业来定期下载新的导出文件。例如，可以添加以下 crontab 来设置每 30 分钟运行一次的 cron 作业。

许可证和公告作业会传入 `-y "^(v1|v3)\/"` 以排除 `v1/` 和 `v3/` 文件夹，因此它们只镜像 v2 格式版本。

对于 v2 许可证扫描（极狐GitLab 19.3 及更早版本）：

```plaintext
*/30 * * * * gsutil -m rsync -r -d -y "^(v1|v3)\/" gs://prod-export-license-bucket-1a6c642fc4de57d4 $GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/licenses
```

对于 v2 依赖项扫描：

```plaintext
*/30 * * * * gsutil -m rsync -r -d -y "^(v1|v3)\/" gs://prod-export-advisory-bucket-1a6c642fc4de57d4 $GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/advisories
```

对于 CVE 增强，省略 `-d` 并串联下载过程中的移动步骤：

```plaintext
*/30 * * * * gsutil -m rsync -r gs://prod-export-cve-enrichment-bucket-1a6c642fc4de57d4 $GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/cve_enrichment && cd $GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/cve_enrichment/v2 && cp -a cve_enrichment/. . && rm -r cve_enrichment
```

移动步骤之后，本地布局不再与存储桶匹配，因此 `-d` 会删除已移动的文件。移动操作还会删除 `gsutil rsync` 用于比较的目录，因此每次运行都会重新下载整个导出文件，无论是否使用 `-d`。

> [!warning]
> 许可证和公告示例中的 `-d` 标志会删除存储桶中已不存在的本地文件，
> 这可能会丢弃正在进行的导入。
> 极狐GitLab 会记录每种数据类型和软件包仓库最后导入的文件，并从
> 该文件之后继续。
> 如果清理删除了该记录指向的序列目录，极狐GitLab 将无法找到该记录。
> 随后它会从头重新导入整个数据类型。
> 在清理之前，请确认每种数据类型记录的序列仍在磁盘上。
> 要读取记录的序列，请参见[验证数据](#verify-data)。
> 对于多个实例读取的目录，请只清理早于其中任何实例所记录的最旧序列的部分。
>
> 此行为适用于许可证、公告和 CVE 增强导出文件，极狐GitLab 会逐个文件导入它们。
> 前面介绍的恶意软件公告过程有所不同。
> 它每次运行都会替换完整快照，并且必须使用 `rsync --delete`。

<a id="v3-license-data-format-version"></a>

### v3 许可证数据格式版本

`v2` 和 `v3` 是许可证导出的格式版本，各自发布在自己的文件夹中，保存不同类型的许可证数据：

| 格式版本 | 文件夹                                 | 许可证数据                                      | 读取方 |
|----------------|----------------------------------------|---------------------------------------------------|---------|
| v2             | `licenses/v2/<registry>/`              | `.ndjson` 文件中的单个 SPDX 标识符。      | 极狐GitLab 19.3 及更早版本 |
| v3             | `licenses/v3/<registry>/full_dataset/` | 压缩归档中的 SPDX 许可证表达式。 | 极狐GitLab 19.4 及更高版本 |

格式版本不是由您选择，而是由极狐GitLab 决定。一个实例可以同时保存两个文件夹，但极狐GitLab 只读取其中一个。

在极狐GitLab 19.4 及更高版本中，当 `sync_v3_license_expressions` 标志已启用且 `vendor/package_metadata/licenses` 下存在 `v3/` 文件夹时，极狐GitLab 会读取 v3。当两个文件夹都存在时，v3 优先，`v2/` 会被忽略。关闭该标志则改为读取 v2。更早的版本始终读取 v2。

关于 v3 文件夹结构：

- 极狐GitLab 将数据组织在 `v3/<registry>` 下，其中 `<registry>` 是诸如 `go`、`rubygem` 或
  `packagist` 之类的名称。
- 每个仓库文件夹都在 `full_dataset/` 中存储该仓库的完整数据集。完整数据集分为
  多个分片：一个包含快照时间戳的 `checkpoint.json`，以及每个分片一个 `.tar.zst` 归档，
  以分片 ID 命名，例如 `00.tar.zst`：

  ```plaintext
  $GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/licenses/v3/rubygem/full_dataset/checkpoint.json
  $GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/licenses/v3/rubygem/full_dataset/00.tar.zst
  $GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/licenses/v3/rubygem/full_dataset/01.tar.zst
  $GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/licenses/v3/rubygem/full_dataset/...
  ```

- 存储桶中的仓库文件夹还包含一个 `deltas/` 文件夹。
  请勿复制它。
  离线实例只读取 `full_dataset/`，并且它下载的每个快照都是完整的。
  离线读取增量（即快照只下载一次，后续运行只获取变更）的相关进展记录在
  [议题 616703](https://gitlab.com/gitlab-org/gitlab/-/issues/616703)中。

<a id="change-note"></a>

### 变更说明

随着 16.2 的发布，软件包元数据的目录从 `vendor/package_metadata_db` 更改为 `vendor/package_metadata/licenses`。如果实例上已存在该目录，并且需要添加依赖项扫描，则需要执行以下步骤。

1. 重命名 licenses 目录：`mv vendor/package_metadata_db vendor/package_metadata/licenses`。
1. 更新任何已保存的自动化脚本或命令，将 `vendor/package_metadata_db` 更改为 `vendor/package_metadata/licenses`。
1. 更新任何 cron 条目，将 `vendor/package_metadata_db` 更改为 `vendor/package_metadata/licenses`。

   ```shell
   sed -i '.bckup' -e 's#vendor/package_metadata_db#vendor/package_metadata/licenses#g' [FILE ...]
   ```

<a id="instances-installed-with-the-helm-chart"></a>

### 使用 Helm chart 安装的实例

这些过程会写入 Linux 软件包安装的 Rails 目录。同步作业在 Sidekiq 中运行。在使用 GitLab Helm chart 的安装中，相同的文件必须位于
Sidekiq pod 在 `/srv/gitlab/vendor/package_metadata` 可读取的卷上。
仅挂载到 toolbox pod 的卷是不够的。同步仍会在 Sidekiq 中运行，仍找不到目录，并且每次运行仍会尝试网络路径。

在 chart values 中的 `gitlab.sidekiq` 下声明该卷：

```yaml
gitlab:
  sidekiq:
    extraVolumes: |
      - name: package-metadata
        persistentVolumeClaim:
          claimName: gitlab-package-metadata
          readOnly: true
    extraVolumeMounts: |
      - name: package-metadata
        mountPath: /srv/gitlab/vendor/package_metadata
        readOnly: true
```

无需其他设置。极狐GitLab 会根据目录是否存在来选择离线路径。更改会在下次同步运行时生效，无需重启，也无需 Rake 任务。

每个 Sidekiq pod 都会挂载该声明，因此请为卷设置允许此操作的访问模式，例如
`ReadOnlyMany`。
极狐GitLab 只读取这些文件。

请注意 values 中的两个错误：

- 将 `extraVolumes` 和 `extraVolumeMounts` 写为
  [字符串，而不是 YAML 列表](https://gitlab.cn/docs/charts/charts/gitlab/sidekiq/)。
  列表会在渲染时失败，并报出指明模板的类型错误。
  而将键放在错误层级的 values 文件则会静默失败。
  Helm 会忽略它无法识别的键，Deployment 渲染时不会包含该挂载，而
  命令却会成功。
  渲染成功并不能作为证明。
  请确认该挂载已到达 Deployment：

  ```shell
  kubectl get deployment -l app=sidekiq -o yaml | grep -c 'vendor/package_metadata'
  ```

  chart 会将这些字符串传入 Helm 模板引擎，因此请对卷
  名称或挂载路径中的任何 `{{` 进行转义。

- 该挂载应放在 values 中，而不是通过 `kubectl set env` 或 `kubectl patch` 设置。
  下一次 `helm upgrade` 会覆盖它。
  在从存储的配置进行协调的部署中，下一次协调会使
  实例回到网络路径。
  在离线环境中，这意味着完全没有漏洞数据。

要跟踪导入情况，请读取 Sidekiq pod 上记录的序列和日志，而不是 Webservice pod 上的，详见[故障排除](#troubleshooting)。

<a id="troubleshooting"></a>

### 故障排除

<a id="missing-database-data"></a>

#### 数据库数据缺失

如果依赖项列表、漏洞报告或合并请求页面中缺少许可证或公告数据，则数据库可能尚未与导出数据同步。

<a id="confirm-enabled-package-registry-types"></a>

##### 确认已启用的软件包仓库类型

`package_metadata` 同步通过 cron 作业触发（[公告同步](https://gitlab.com/gitlab-org/gitlab/-/blob/16-3-stable-ee/config/initializers/1_settings.rb#L864-866)和[许可证同步](https://gitlab.com/gitlab-org/gitlab/-/blob/16-3-stable-ee/config/initializers/1_settings.rb#L855-857)）。只有[管理员设置](../../administration/settings/security_and_compliance.md#choose-package-registry-metadata-to-sync)中启用的软件包仓库类型才会被导入。

例如，如果选择了 `maven`，但没有选择 `golang`，您将只能看到 Maven 的公告和许可证信息。

<a id="confirm-correct-file-structure"></a>

##### 确认文件结构正确

`vendor/package_metadata`中的文件结构必须与之前启用的软件包仓库类型一致。例如，要同步 `maven` 许可证或公告数据，Rails 目录下的软件包元数据目录必须具有以下结构，其中 `$GITLAB_RAILS_ROOT_DIR` 与命令 `gitlab-rails runner 'puts Rails.root.to_s'` 的输出一致：

- 对于 v2 上的许可证（极狐GitLab 19.3 及更早版本）：`$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/licenses/v2/maven/**/*.ndjson`。
- 对于 v3 上的许可证（极狐GitLab 19.4 及更高版本）：`$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/licenses/v3/maven/full_dataset/*`。请参见 [v3 许可证数据格式版本](#v3-license-data-format-version)。
- 对于 v2 上的公告：`$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/advisories/v2/maven/**/*.ndjson`。

CVE 增强不按软件包仓库类型划分，其文件必须正好位于版本目录下两级：

- 对于 CVE 增强：`$GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/cve_enrichment/v2/*/*.ndjson`。

按原样复制 CVE 增强存储桶会使文件比此深度多一级，极狐GitLab 将不会读取其中任何文件。要更正，请参见[下载过程中的 CVE 增强步骤](#v2-using-the-gsutil-tool-to-download-the-package-metadata-exports)。

您可以在 [Rails 控制台](../../administration/operations/rails_console.md)中检查 极狐GitLab 是否能识别该文件路径：

- 对于许可证：`sudo gitlab-rails runner "puts File.exist?(PackageMetadata::SyncConfiguration::Location::LICENSES_PATH)"`
- 对于公告：`sudo gitlab-rails runner "puts File.exist?(PackageMetadata::SyncConfiguration::Location::ADVISORIES_PATH)"`
- 对于 CVE 增强：`sudo gitlab-rails runner "puts File.exist?(PackageMetadata::SyncConfiguration::Location::CVE_ENRICHMENT_PATH)"`

如果上述命令返回 `false`，则 极狐GitLab 无法找到预期的软件包路径。路径中的所有文件夹和文件都必须具有 `755` 权限。要更新权限：

`sudo chmod -R 755 $GITLAB_RAILS_ROOT_DIR/vendor/package_metadata/`

<a id="verify-data"></a>

##### 验证数据

同步作业成功运行后，数据库中 `pm_` 表下的数据应已填充。

您可以使用 [Rails 控制台](../../administration/operations/rails_console.md)检查某个供应商有多少个软件包来确认。例如，要确认 Maven 许可证和公告数据已加载，请运行：

- 对于许可证：`sudo gitlab-rails runner "puts \"Package model has #{PackageMetadata::Package.where(purl_type: 'maven').size} packages\""`
- 对于公告：`sudo gitlab-rails runner "puts \"Advisory model has #{PackageMetadata::AffectedPackage.where(purl_type: 'maven').size} packages\""`

此外，正在同步的特定软件包仓库应存在检查点数据。例如对于 Maven，成功同步运行后应创建检查点：

- 对于许可证：`sudo gitlab-rails runner "puts \"maven data has been synced up to #{PackageMetadata::Checkpoint.where(data_type: 'licenses', purl_type: 'maven')}\""`
- 对于公告：`sudo gitlab-rails runner "puts \"maven data has been synced up to #{PackageMetadata::Checkpoint.where(data_type: 'advisories', purl_type: 'maven')}\""`

<a id="logs"></a>

##### 日志

[`application_json.log`](../../administration/logs/_index.md#application_jsonlog) 文件有助于验证同步作业已运行且没有错误。与同步相关的事件具有 `DEBUG` 严重级别，类为 `PackageMetadata::SyncService`。示例：
`{"severity":"DEBUG","time":"2026-01-07T02:15:49.618Z","meta.caller_id":"PackageMetadata::AdvisoriesSyncWorker","correlation_id":"43008e30dd708eadbe1ab16ad7fa953f","meta.root_caller_id":"Cronjob","meta.feature_category":"software_composition_analysis","meta.client_id":"ip/","class":"PackageMetadata::SyncService","message":"Evaluating data for advisories:offline//opt/gitlab/embedded/service/gitlab-rails/vendor/package_metadata/advisories/v2/maven/1761761049/0.ndjson"}`

[`sidekiq`](../../administration/logs/_index.md#sidekiq-logs) 日志会显示同步作业期间是否发生任何错误。为同步记录的事件会提及相关类：

- 对于许可证：`PackageMetadata::LicensesSyncWorker`
- 对于公告：`PackageMetadata::AdvisoriesSyncWorker`

<a id="missing-v3-license-data"></a>

#### v3 许可证数据缺失

如果您将许可证数据复制到实例后仍缺少该数据，则同步作业要么没有找到该目录，要么没有找到可导入的新内容。这两种情况都是静默的，因此请按以下检查逐项排查，而不是寻找错误。

开始之前：

- 遵循[数据库数据缺失](#missing-database-data)的故障排除指南，特别是检查已启用的软件包仓库类型和许可证的文件结构。
- 确认 v3 许可证文件结构。它应与[恶意软件公告文件结构](#confirm-the-malware-advisory-file-structure)一致。

<a id="verify-v3-license-data"></a>

##### 验证 v3 许可证数据

表达式存储在许可证记录上。要验证已同步的 v3 快照，请查找至少一个带表达式的许可证。您可以在 Rails 控制台中确认：

- `sudo gitlab-rails runner "puts \"#{PackageMetadata::License.where.not(spdx_expression: nil).count} licenses have an expression\""`

如果软件包和检查点存在，但没有带表达式的许可证，则实例同步的是 v2 布局而不是 v3。请检查磁盘上的数据是否位于 `v3/` 下。

只有当快照比记录的检查点更新时才会导入，因此第二次复制同一快照不会产生任何效果。要获取更新的许可证数据，请再次运行下载脚本以获取当前快照。

<a id="missing-malware-advisory-data"></a>

#### 恶意软件公告数据缺失

如果您将恶意软件公告复制到实例后仍缺少该数据，则同步作业要么没有找到该目录，要么没有找到可导入的新内容。这两种情况都是静默的，因此请按以下检查逐项排查，而不是寻找错误。

<a id="confirm-enabled-package-registry-types-for-malware-advisories"></a>

##### 确认恶意软件公告已启用的软件包仓库类型

只有[管理员设置](../../administration/settings/security_and_compliance.md#choose-package-registry-metadata-to-sync)中启用的软件包仓库类型才会被导入。您复制但未启用的仓库永远不会被读取，也不会记录任何日志。

<a id="confirm-gitlab-detects-the-offline-directory"></a>

##### 确认 极狐GitLab 检测到离线目录

当 vendor 目录存在时，极狐GitLab 会从磁盘读取恶意软件公告；当它不存在时，则从分发服务读取。您可以在 [Rails 控制台](../../administration/operations/rails_console.md)中检查 极狐GitLab 是否能识别该文件路径：

- `sudo gitlab-rails runner "puts File.exist?(PackageMetadata::SyncConfiguration::Location::MALWARE_ADVISORIES_PATH)"`

如果该命令返回 `false`，则 极狐GitLab 无法找到预期路径。路径中的所有文件夹和文件都必须具有 `755` 权限。在 Kubernetes 安装中，请在挂载了与 Sidekiq 相同卷的 pod 中运行该命令，否则结果无法反映同步作业实际读取的内容。

<a id="confirm-the-malware-advisory-file-structure"></a>

##### 确认恶意软件公告文件结构

目录以软件包仓库标识符命名，而不是软件包类型。这些标识符并不总是相同：`gem` 公告存储在 `rubygem` 下，`golang` 存储在 `go` 下，`composer` 存储在 `packagist` 下。以软件包类型命名的目录会被忽略，且不会记录任何错误。

每个 `full_dataset` 目录还必须包含一个 `checkpoint.json`。极狐GitLab 会忽略没有检查点的目录，从而防止导入被中断的下载。

<a id="verify-malware-advisory-data"></a>

##### 验证恶意软件公告数据

同步作业成功运行后，恶意软件公告应已填充。您可以在 [Rails 控制台](../../administration/operations/rails_console.md)中统计公告数量来确认：

- `sudo gitlab-rails runner "puts \"Malware advisory model has #{PackageMetadata::MalwareAdvisory.count} advisories\""`

您复制的软件包仓库也应存在检查点数据：

- `sudo gitlab-rails runner "puts PackageMetadata::Checkpoint.where(data_type: 'malware_advisories').pluck(:purl_type, :sequence).to_h"`

只有当快照比记录的检查点更新时才会导入，因此第二次复制同一快照不会产生任何效果。

<a id="malware-advisory-logs"></a>

##### 恶意软件公告日志

与恶意软件公告同步相关的事件记录在 [`application_json.log`](../../administration/logs/_index.md#application_jsonlog)中，严重级别为 `INFO`。同步本身的类为 `PackageMetadata::MalwareAdvisorySyncService`，导入的类为 `PackageMetadata::MalwareAdvisoryIngestionService`。
同步在 Sidekiq 中运行，因此在 Kubernetes 安装中，这些事件位于 Sidekiq pod 上
`subcomponent="application_json"` 键下，而不是 Webservice pod 上。

[`sidekiq`](../../administration/logs/_index.md#sidekiq-logs) 日志会显示发生的任何错误，记录在 `PackageMetadata::MalwareAdvisoriesSyncWorker` 类下。

每个仓库每次运行都会记录一个 `started` 和一个 `completed` 事件。带有 `files_ingested: 0`的 `completed` 事件表示该次运行没有找到可导入的内容。该事件上的 `storage_type` 字段会告诉您属于哪种情况：`offline` 表示 极狐GitLab 读取了 vendor 目录，`pds` 表示它没有找到该目录，转而尝试了分发服务。在 Kubernetes 上，此字段比前面的 `File.exist?` 检查更可靠，因为它来自运行同步的进程。

如果完全没有出现 `PackageMetadata::MalwareAdvisorySyncService` 事件，请查找严重级别为 `DEBUG`的 `PackageMetadata::MalwareAdvisoriesSyncWorker` 事件。它会指出该次运行未启动的原因，例如 `sync_malware_advisories` 功能标志被禁用。

`Malware advisory upsert skipped: ingest_malware_advisories disabled` 事件表示 `ingest_malware_advisories` 功能标志已关闭。同步每次运行都会读取文件，但不写入任何内容，检查点也不会推进。

大型仓库的首次导入可能运行数分钟，在此期间 cron 每五分钟会再次触发。每个重叠的运行都会以 `ERROR` 严重级别将 `Cannot obtain an exclusive lease. There must be another instance already in execution.` 记录到 `application_json.log`，然后退出。租约正是阻止两个同步同时运行的原因，因此这些事件在长时间导入期间是预期内的，并不意味着同步失败。
