---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Bundle URIs
---

{{< details >}}

Tier: 基础版，专业版，旗舰版

Offering: 私有化部署

{{< /details >}}

Gitaly 支持 Git [bundle URIs](https://git-scm.com/docs/bundle-uri)。Bundle URI 是 Git 可以下载一个或多个 bundle 的位置，用于在从远程获取剩余对象之前引导对象数据库。Bundle URI 内置于 Git 协议中。

使用 Bundle URI 可以：

- 为与极狐GitLab 服务器网络连接较差的用户加快克隆和获取速度。bundle 可以存储在 CDN 上，使其在全球范围内可用。
- 降低运行 CI/CD 作业的服务器的负载。如果 CI/CD 作业可以从其他地方预加载 bundle，那么增量获取缺失对象和引用的剩余工作将大大减少服务器负载。

<a id="prerequisites"></a>

## 先决条件

使用 bundle URI 的先决条件取决于您是在 CI/CD 作业中克隆，还是在终端本地克隆。

<a id="cloning-in-cicd-jobs"></a>

### 在 CI/CD 作业中克隆

要在 CI/CD 作业中使用 bundle URI，请做好以下准备：

1. 将极狐GitLab Runner 使用的 [极狐GitLab Runner helper 镜像](https://gitlab.com/gitlab-org/gitlab-runner/container_registry/1472754)更新到运行以下内容的版本：

   - Git 2.49.0 或更高版本。
   - 极狐GitLab Runner helper 18.0 或更高版本。

   此步骤是必需的，因为 bundle URI 是一种旨在降低 `git clone` 期间 Git 服务器负载的机制。因此，当 CI/CD 流水线运行时，发起 `git clone` 命令的 `git` 客户端是极狐GitLab Runner。`git` 进程在 helper 镜像内运行。

   请确保选择与您的极狐GitLab Runner 所使用的操作系统发行版和架构相对应的镜像。

   您可以通过运行以下命令来验证镜像是否满足要求：

   ```shell
   docker run -it <image:tag>
   $ git version
   $ gitlab-runner-helper -v
   ```

   我们依赖操作系统发行版的软件包管理器来管理 `gitlab-runner-helper` 镜像中的 Git 版本。因此，一些最新的可用镜像可能仍未运行 Git 2.49。

   如果找不到满足要求的镜像，可以将 `gitlab-runner-helper` 作为基础镜像，构建您自己的自定义镜像。您可以使用 [极狐GitLab 容器镜像仓库](../../user/packages/container_registry/_index.md)托管您的自定义镜像。

1. 通过更新 `config.toml` 文件，将您的极狐GitLab Runner 实例配置为使用所选镜像：

   ```toml
   [[runners]]
     (...)
     executor = "docker"
     [runners.docker]
       (...)
       helper_image = "image:tag" ## <-- put the image name and tag here
   ```

   有关更多详细信息，请参阅 [helper 镜像的相关信息](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#helper-image)。

1. 重启 Runner 以使新配置生效。
1. 在您的 `.gitlab-ci.yml` 文件中，将 `FF_USE_GIT_NATIVE_CLONE` [极狐GitLab Runner 功能标志](https://gitlab.cn/docs/runner/configuration/feature-flags/)设置为 `true` 以启用它：

   ```yaml
   variables:
     FF_USE_GIT_NATIVE_CLONE: "true"
   ```

<a id="cloning-locally-in-your-terminal"></a>

### 在终端本地克隆

要在终端本地克隆时使用 bundle URI，请在本地 Git 配置中启用 `bundle-uri`：

```shell
git config --global transfer.bundleuri true
```

<a id="server-configuration"></a>

## 服务器配置

您必须配置 bundle 的存储位置。Gitaly 支持以下存储服务：

- Google Cloud Storage
- AWS S3（或兼容服务）
- Azure Blob Storage
- 本地文件存储（不推荐）

<a id="configure-azure-blob-storage"></a>

### 配置 Azure Blob 存储

如何为 Bundle URI 配置 Azure Blob 存储取决于您的安装类型。对于自编译安装，您必须在极狐GitLab 之外设置 `AZURE_STORAGE_ACCOUNT` 和 `AZURE_STORAGE_KEY` 环境变量。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

编辑 `/etc/gitlab/gitlab.rb` 并配置 `bundle_uri.go_cloud_url`：

```ruby
gitaly['env'] = {
    'AZURE_STORAGE_ACCOUNT' => 'azure_storage_account',
    'AZURE_STORAGE_KEY' => 'azure_storage_key' # or 'AZURE_STORAGE_SAS_TOKEN'
}
gitaly['configuration'] = {
    bundle_uri: {
        go_cloud_url: 'azblob://<bucket>'
    }
}
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

编辑 `/home/git/gitaly/config.toml` 并配置 `go_cloud_url`：

```toml
[bundle_uri]
go_cloud_url = "azblob://<bucket>"
```

{{< /tab >}}

{{< /tabs >}}

<a id="configure-google-cloud-storage"></a>

### 配置 Google Cloud 存储

Google Cloud 存储（GCP）使用 Application Default Credentials 进行身份验证。在每个 Gitaly 服务器上使用以下任一方式设置 Application Default Credentials：

- [`gcloud auth application-default login`](https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login) 命令。
- `GOOGLE_APPLICATION_CREDENTIALS` 环境变量。对于自编译安装，请在极狐GitLab 之外设置该环境变量。

有关更多信息，请参阅 [Application Default Credentials](https://cloud.google.com/docs/authentication/provide-credentials-adc)。

目标存储桶使用 `go_cloud_url` 选项进行配置。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

编辑 `/etc/gitlab/gitlab.rb` 并配置 `go_cloud_url`：

```ruby
gitaly['env'] = {
    'GOOGLE_APPLICATION_CREDENTIALS' => '/path/to/service.json'
}
gitaly['configuration'] = {
    bundle_uri: {
        go_cloud_url: 'gs://<bucket>'
    }
}
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

编辑 `/home/git/gitaly/config.toml` 并配置 `go_cloud_url`：

```toml
[bundle_uri]
go_cloud_url = "gs://<bucket>"
```

{{< /tab >}}

{{< /tabs >}}

<a id="configure-s3-storage"></a>

### 配置 S3 存储

要配置 S3 存储身份验证：

- 如果您使用 AWS CLI 进行身份验证，则可以使用默认 AWS 会话。
- 否则，您可以使用 `AWS_ACCESS_KEY_ID` 和 `AWS_SECRET_ACCESS_KEY` 环境变量。对于自编译安装，请在极狐GitLab 之外设置这些环境变量。

有关更多信息，请参阅 [AWS Session 文档](https://docs.aws.amazon.com/sdk-for-go/api/aws/session/)。

目标存储桶和区域使用 `go_cloud_url` 选项进行配置。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

编辑 `/etc/gitlab/gitlab.rb` 并配置 `go_cloud_url`：

```ruby
gitaly['env'] = {
    'AWS_ACCESS_KEY_ID' => 'aws_access_key_id',
    'AWS_SECRET_ACCESS_KEY' => 'aws_secret_access_key'
}
gitaly['configuration'] = {
    bundle_uri: {
        go_cloud_url: 's3://<bucket>?region=us-west-1'
    }
}
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

编辑 `/home/git/gitaly/config.toml` 并配置 `go_cloud_url`：

```toml
[bundle_uri]
go_cloud_url = "s3://<bucket>?region=us-west-1"
```

{{< /tab >}}

{{< /tabs >}}

<a id="configure-s3-compatible-servers"></a>

#### 配置 S3 兼容服务器

S3 兼容服务器的配置方式与 S3 类似，但需要额外添加 `endpoint` 参数。

支持以下参数：

- `region`：AWS 区域。
- `endpoint`：端点 URL。
- `disableSSL`：设置为 `true` 以禁用 SSL。适用于极狐GitLab 17.4.0 及更早版本。对于 17.4.0 之后的极狐GitLab 版本，请使用 `disable_https`。
- `disable_https`：设置为 `true` 以在端点选项中禁用 HTTPS。
- `s3ForcePathStyle`：设置为 `true` 以对 S3 对象强制使用路径样式 URL。在极狐GitLab 17.4.0 至 17.4.3 版本中不可用。在这些版本中，请改用 `use_path_style`。
- `use_path_style`：设置为 `true` 以启用路径样式 S3 URL（`https://<host>/<bucket>` 而非 `https://<bucket>.<host>`）。
- `awssdk`：强制使用特定版本的 AWS SDK。设置为 `v1` 以强制使用 AWS SDK v1，或设置为 `v2` 以强制使用 AWS SDK v2。如果：
  - 设置为 `v1`，则必须使用 `disableSSL` 而非 `disable_https`。
  - 未设置，则默认为 `v2`。

`use_path_style` 是在 Go Cloud Development Kit 依赖从 v0.38.0 更新到 v0.39.0 时引入的，该更新将 AWS SDK 从 v1 切换到了 v2。不过，在 gocloud.dev 维护者添加向后兼容支持后，`s3ForcePathStyle` 参数在极狐GitLab 17.4.4 中得以恢复。有关更多信息，请参阅 [议题 6489](https://gitlab.com/gitlab-org/gitaly/-/issues/6489)。

`disable_https` 是在 Go Cloud Development Kit v0.40.0（AWS SDK v2）中引入的。

`awssdk` 是在 Go Cloud Development Kit v0.24.0 中引入的。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

编辑 `/etc/gitlab/gitlab.rb` 并配置 `go_cloud_url`：

```ruby
gitaly['env'] = {
    'AWS_ACCESS_KEY_ID' => '<your_access_key_id>',
    'AWS_SECRET_ACCESS_KEY' => '<your_secret_access_key>'
}
gitaly['configuration'] = {
    bundle_uri: {
        go_cloud_url: 's3://<bucket>?region=us-east-1&endpoint=s3.example.com:9000&disable_https=true&use_path_style=true'
    }
}
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

编辑 `/home/git/gitaly/config.toml` 并配置 `go_cloud_url`：

```toml
[bundle_uri]
go_cloud_url = "s3://<bucket>?region=us-east-1&endpoint=s3.example.com:9000&disable_https=true&use_path_style=true"
```

{{< /tab >}}

{{< /tabs >}}

<a id="generating-bundles"></a>

## 生成 bundle

配置 Gitaly 后，Gitaly 可以手动或自动生成 bundle。

<a id="manual-generation"></a>

### 手动生成

此命令会生成 bundle 并将其存储在已配置的存储服务上。

```shell
sudo -u git -- /opt/gitlab/embedded/bin/gitaly bundle-uri \
                                               --config=<config-file> \
                                               --storage=<storage-name> \
                                               --repository=<relative-path>
```

Gitaly 不会自动刷新已生成的 bundle。当您想要生成更新版本的 bundle 时，必须再次运行该命令。

您可以使用 `cron(8)` 之类的工具来调度此命令。

<a id="automatic-generation"></a>

### 自动生成

> [!flag]
> 此功能的可用性由功能标志控制。

Gitaly 可以通过判断是否正在为同一代码仓库处理频繁的克隆来自动生成 bundle。当前的启发式方法会跟踪每个代码仓库发出 `git fetch` 请求的次数。如果请求数量在给定时间间隔内达到特定阈值，Gitaly 就会自动生成 bundle。

Gitaly 还会跟踪上次为某个代码仓库生成 bundle 的时间。当需要根据 `threshold` 和 `interval` 重新生成新 bundle 时，Gitaly 会查看上次为该代码仓库生成 bundle 的时间。只有当现有 bundle 的存留时间超过 `maxBundleAge` 配置值时，Gitaly 才会生成新 bundle，此时旧 bundle 会被覆盖。云存储中每个代码仓库只能有一个 bundle。

<a id="bundle-uri-example"></a>

## Bundle URI 示例

在以下示例中，我们演示了使用和不使用 bundle URI 克隆 `gitlab.com/gitlab-org/gitlab.git` 的区别。

```shell
$ git -c transfer.bundleURI=false clone https://gitlab.com/gitlab-org/gitlab.git
Cloning into 'gitlab'...
remote: Enumerating objects: 5271177, done.
remote: Total 5271177 (delta 0), reused 0 (delta 0), pack-reused 5271177
Receiving objects: 100% (5271177/5271177), 1.93 GiB | 32.93 MiB/s, done.
Resolving deltas: 100% (4140349/4140349), done.
Updating files: 100% (71304/71304), done.

$ git -c transfer.bundleURI=true clone https://gitlab.com/gitlab-org/gitlab.git
Cloning into 'gitlab'...
remote: Enumerating objects: 1322255, done.
remote: Counting objects: 100% (611708/611708), done.
remote: Total 1322255 (delta 611708), reused 611708 (delta 611708), pack-reused 710547
Receiving objects: 100% (1322255/1322255), 539.66 MiB | 22.98 MiB/s, done.
Resolving deltas: 100% (1026890/1026890), completed with 223946 local objects.
Checking objects: 100% (8388608/8388608), done.
Checking connectivity: 1381139, done.
Updating files: 100% (71304/71304), done.
```

在上一个示例中：

- 不使用 Bundle URI 时，从极狐GitLab 服务器接收了 5,271,177 个对象。
- 使用 Bundle URI 时，从极狐GitLab 服务器接收了 1,322,255 个对象。

这种减少意味着极狐GitLab 需要打包的对象更少（在上一个示例中，大约是对象数量的四分之一），因为客户端首先从存储服务器下载了 bundle。

<a id="securing-bundles"></a>

## 保护 bundle

bundle 通过签名 URL 提供给客户端访问。签名 URL 是一种提供有限权限和有限请求时间的 URL。要了解您的存储服务是否支持签名 URL，请参阅您的存储服务文档。
