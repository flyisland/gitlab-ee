---
stage: Verify
group: Runner
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# 极狐GitLab SaaS Runner（Linux）

当您在 Linux 的 SaaS Runner 上运行作业时，Runner 位于弹性伸缩的临时虚拟机实例上。
虚拟机的默认区域是 `ap-shanghai`，并且多可用区实现高可用。

## 私有项目可用的 Runner 类型（x86-64）

对于 Linux 上的 SaaS Runner，极狐GitLab 提供了一系列用于私有项目的 Runner 类型。
对于基础版、专业版和旗舰版的用户，这些实例上的作业会消耗分配给您的命名空间的 CI/CD 分钟数。

|                   | 小型 Runner                | 中型 Runner                 | 大型 Runner                |
|:------------------|:-------------------------|---------------------------|--------------------------|
| 规格                | 2 VCPU，4 GB RAM          | 2 VCPU，8 GB RAM           | 4 VCPU，16 GB RAM         |
| 极狐GitLab CI/CD 标签 | `saas-linux-small-amd64` | `saas-linux-medium-amd64` | `saas-linux-large-amd64` |
| 订阅版本              | 基础版、专业版和旗舰版              | 基础版、专业版和旗舰版               | 专业版和旗舰版                  |

如果您在 `.gitlab-ci.yml` 中未指定 [tags:](../../yaml/index.md#tags) 关键字，则默认使用 `small` Runner 类型。
在中型和大型 Runner 上运行的 CI/CD 作业所消耗的 CI 分钟数会多于小型 Runner 上运行的 CI/CD 作业所消耗的 CI 分钟数。
有关不同类型的 Runner 所使用的消耗系数，请参阅[极狐GitLab SaaS Runner 消耗系数](#cost-factor)。

<a id="cost-factor"></a>

## 消耗系数

默认情况下，单个作业的一分钟执行时间使用 1 CI/CD 分钟。流水线使用的 CI/CD 分钟总数是所有作业持续时间的总和。

公开项目和私有项目都启用了 CI/CD 分钟数配额。命名空间中每个月的基本 CI/CD 分钟数配额由许可证级别确定。

在 JihuLab.com 的共享 Runner 上运行作业的默认消耗系数为：

- `1`：内部、私有和公开项目。

<a id="cost_factor"></a>

## 极狐GitLab SaaS Runner 消耗系数

在上述消耗系数的基础上，使用不同类型的 Runner 还需要计算额外的消耗系数。有关 CI/CD 分钟数的更多内容，请参见[如何计算 CI/CD 分钟数](https://docs.gitlab.cn/jh/ci/pipelines/cicd_minutes.html#how-cicd-minute-usage-is-calculated)。

|                      | `saas-linux-small-amd64` | `saas-linux-medium-amd64` | `saas-linux-large-amd64` |
|:---------------------|:-------------------------|---------------------------|--------------------------|
| CI/CD 分钟数消耗系数    | 1    | 2    | 3     |

## 为作业打标签示例

如果您想使用 `small` 之外的其他 Runner 类型，您可以在作业中添加 `tags:` 关键字。
例如：

```yaml
stages:
  - Prebuild
  - Build
  - Unit Test

job_001:
 stage: Prebuild
 script:
  - echo "this job runs on the default (small) instance"

job_002:
 tags: [ saas-linux-medium-amd64 ]
 stage: Build
 script:
  - echo "this job runs on the medium instance"


job_003:
 tags: [ saas-linux-large-amd64 ]
 stage: Unit Test
 script:
  - echo "this job runs on the large instance"

```

## Linux 设置上的 SaaS Runner

以下是 Linux 上的 SaaS Runner 的设置：

| 设置                                                                    | JihuLab.com      | 默认      |
|-----------------------------------------------------------------------|------------------|---------|
| 执行器                                                                   | `docker+machine` | -       |
| 默认 Docker 镜像                                                          | `ruby:3.1`       | -       |
| `privileged`（运行 [Docker in Docker](https://hub.docker.com/_/docker/)） | `true`           | `false` |

- **缓存**：这些 Runner 共享一个存储在 Tencent Cloud Object Storage（COS）存储桶中的[分布式缓存](https://docs.gitlab.cn/runner/configuration/autoscale.html#distributed-runners-caching)。
14 天内未更新的缓存内容会基于[对象生命周期管理策略](https://cloud.tencent.com/document/product/436/14605)进行自动删除。

- **超时设置**：无论在项目中配置的超时时间是多少，由 Linux 上的 SaaS Runner 处理的作业都会在 **3 小时后超时**。

NOTE:
SaaS runner 实例配备了 25 GB 的存储卷。存储卷的底层磁盘空间由操作系统、Docker 镜像和已克隆仓库的副本共享。这意味着您的作业可以使用的可用磁盘空间**少于 25 GB**。

## 预克隆脚本（已废弃）

WARNING:
此功能废弃于 15.9 版本，并计划删除于 16.0 版本。使用 [`pre_get_sources_script`](../../../ci/yaml/index.md#hookspre_get_sources_script) 代替。此变更是一个突破性的变化。使用 Linux 上的 SaaS runner，您可以在 runner 上尝试运行 `git init` 和 `git fetch`，下载极狐GitLab 仓库之前在 CI/CD 作业中运行命令。[`pre_clone_script`](https://docs.gitlab.cn/runner/configuration/advanced-configuration.html#the-runners-section) 可用于：

- 使用代码库数据播种构建目录
- 向服务器发送请求
- 从 CDN 下载 assets
- 任何其他必须在 `git init` 之前运行的命令

要使用此功能，请定义一个名为 `CI_PRE_CLONE_SCRIPT` 的 [CI/CD 变量](../../../ci/variables/index.md)，其中包含一个 bash 脚本。

NOTE:
`CI_PRE_CLONE_SCRIPT` 变量在极狐GitLab SaaS Windows 或 macOS runner 上无效。

<!--
### 预克隆脚本示例

This example was used in the `gitlab-org/gitlab` project until November 2021.
The project no longer uses this optimization because the
[pack-objects cache](../../../administration/gitaly/configure_gitaly.md#pack-objects-cache)
lets Gitaly serve the full CI/CD fetch traffic. See [Git fetch caching](../../../development/pipelines/performance.md#git-fetch-caching).

The `CI_PRE_CLONE_SCRIPT` was defined as a project CI/CD variable:

```shell
(
  echo "Downloading archived master..."
  wget -O /tmp/gitlab.tar.gz https://storage.googleapis.com/gitlab-ci-git-repo-cache/project-278964/gitlab-master-shallow.tar.gz

  if [ ! -f /tmp/gitlab.tar.gz ]; then
      echo "Repository cache not available, cloning a new directory..."
      exit
  fi

  rm -rf $CI_PROJECT_DIR
  echo "Extracting tarball into $CI_PROJECT_DIR..."
  mkdir -p $CI_PROJECT_DIR
  cd $CI_PROJECT_DIR
  tar xzf /tmp/gitlab.tar.gz
  rm -f /tmp/gitlab.tar.gz
  chmod a+w $CI_PROJECT_DIR
)
```

The first step of the script downloads `gitlab-master.tar.gz` from Google Cloud Storage.
There was a [GitLab CI/CD job named `cache-repo`](https://gitlab.com/gitlab-org/gitlab/-/blob/5fb40526c8c8aaafc5f92eab36d5bbddaca3893d/.gitlab/ci/cache-repo.gitlab-ci.yml)
that was responsible for keeping that archive up-to-date. Every two hours on a scheduled pipeline,
it did the following:

1. Create a fresh clone of the `gitlab-org/gitlab` repository on GitLab.com.
1. Save the data as a `.tar.gz`.
1. Upload it into the Google Cloud Storage bucket.

When a job ran with this configuration, the output looked similar to:

```shell
$ eval "$CI_PRE_CLONE_SCRIPT"
Downloading archived master...
Extracting tarball into /builds/gitlab-org/gitlab...
Fetching changes...
Reinitialized existing Git repository in /builds/gitlab-org/gitlab/.git/
```

The `Reinitialized existing Git repository` message shows that
the pre-clone step worked. The runner runs `git init`, which
overwrites the Git configuration with the appropriate settings to fetch
from the GitLab repository.

`CI_REPO_CACHE_CREDENTIALS` must contain the Google Cloud service account
JSON for uploading to the `gitlab-ci-git-repo-cache` bucket.

This bucket should be located in the same continent as the
runner, or [you can incur network egress charges](https://cloud.google.com/storage/pricing).
-->

## `config.toml`

`config.toml` 的完整内容为：

NOTE:
不公开的设置显示为 `X`。

**Google Cloud Platform**

```toml
concurrent = X
check_interval = 1
metrics_server = "X"
sentry_dsn = "X"

[[runners]]
  name = "docker-auto-scale"
  request_concurrency = X
  url = "https://gitlab.com/"
  token = "SHARED_RUNNER_TOKEN"
  pre_clone_script = "eval \"$CI_PRE_CLONE_SCRIPT\""
  executor = "docker+machine"
  environment = [
    "DOCKER_DRIVER=overlay2",
    "DOCKER_TLS_CERTDIR="
  ]
  limit = X
  [runners.docker]
    image = "ruby:3.1"
    privileged = true
    volumes = [
      "/certs/client",
      "/dummy-sys-class-dmi-id:/sys/class/dmi/id:ro" # Make kaniko builds work on GCP.
    ]
  [runners.machine]
    IdleCount = 50
    IdleTime = 3600
    MaxBuilds = 1 # For security reasons we delete the VM after job has finished so it's not reused.
    MachineName = "srm-%s"
    MachineDriver = "google"
    MachineOptions = [
      "google-project=PROJECT",
      "google-disk-size=25",
      "google-machine-type=n1-standard-1",
      "google-username=core",
      "google-tags=gitlab-com,srm",
      "google-use-internal-ip",
      "google-zone=us-east1-d",
      "engine-opt=mtu=1460", # Set MTU for container interface, for more information check https://gitlab.com/gitlab-org/gitlab-runner/-/issues/3214#note_82892928
      "google-machine-image=PROJECT/global/images/IMAGE",
      "engine-opt=ipv6", # This will create IPv6 interfaces in the containers.
      "engine-opt=fixed-cidr-v6=fc00::/7",
      "google-operation-backoff-initial-interval=2" # Custom flag from forked docker-machine, for more information check https://github.com/docker/machine/pull/4600
    ]
    [[runners.machine.autoscaling]]
      Periods = ["* * * * * sat,sun *"]
      Timezone = "UTC"
      IdleCount = 70
      IdleTime = 3600
    [[runners.machine.autoscaling]]
      Periods = ["* 30-59 3 * * * *", "* 0-30 4 * * * *"]
      Timezone = "UTC"
      IdleCount = 700
      IdleTime = 3600
  [runners.cache]
    Type = "gcs"
    Shared = true
    [runners.cache.gcs]
      CredentialsFile = "/path/to/file"
      BucketName = "bucket-name"
```
