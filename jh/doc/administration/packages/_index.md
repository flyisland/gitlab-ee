---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 软件包仓库管理
description: 管理软件包仓库。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要将极狐GitLab 用作各种常见包管理器的私有仓库，请使用软件包仓库。您可以构建并发布软件包，供下游项目作为依赖项使用。

<a id="supported-formats"></a>

## 支持的格式

软件包仓库支持以下格式：

| 软件包类型                                                       | 极狐GitLab 版本 |
|--------------------------------------------------------------------|----------------|
| [Composer](../../user/packages/composer_repository/_index.md)      | 13.2+          |
| [Conan 1](../../user/packages/conan_1_repository/_index.md)        | 12.6+          |
| [Conan 2](../../user/packages/conan_2_repository/_index.md)        | 18.1+          |
| [Go](../../user/packages/go_proxy/_index.md)                       | 13.1+          |
| [Maven](../../user/packages/maven_repository/_index.md)            | 11.3+          |
| [npm](../../user/packages/npm_registry/_index.md)                  | 11.7+          |
| [NuGet](../../user/packages/nuget_repository/_index.md)            | 12.8+          |
| [PyPI](../../user/packages/pypi_repository/_index.md)              | 12.10+         |
| [通用软件包](../../user/packages/generic_packages/_index.md) | 13.5+          |
| [Helm Charts](../../user/packages/helm_repository/_index.md)       | 14.1+          |

软件包仓库还用于存储[模型注册表数据](../../user/project/ml/model_registry/_index.md)。

<a id="accepting-contributions"></a>

## 接受贡献

下表列出了不受支持的软件包格式。您可以考虑为 GitLab 贡献代码，以添加对这些格式的支持。

<!-- vale gitlab_base.Spelling = NO -->

| 格式 | 状态 |
| ------ | ------ |
| Chef      | [#36889](https://gitlab.com/gitlab-org/gitlab/-/issues/36889) |
| CocoaPods | [#36890](https://gitlab.com/gitlab-org/gitlab/-/issues/36890) |
| Conda     | [#36891](https://gitlab.com/gitlab-org/gitlab/-/issues/36891) |
| CRAN      | [#36892](https://gitlab.com/gitlab-org/gitlab/-/issues/36892) |
| Debian    | [草稿：合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/50438) |
| Opkg      | [#36894](https://gitlab.com/gitlab-org/gitlab/-/issues/36894) |
| P2        | [#36895](https://gitlab.com/gitlab-org/gitlab/-/issues/36895) |
| Puppet    | [#36897](https://gitlab.com/gitlab-org/gitlab/-/issues/36897) |
| RPM       | [#5932](https://gitlab.com/gitlab-org/gitlab/-/issues/5932) |
| RubyGems  | [#803](https://gitlab.com/gitlab-org/gitlab/-/issues/803) |
| SBT       | [#36898](https://gitlab.com/gitlab-org/gitlab/-/issues/36898) |
| Terraform | [草稿：合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/18834) |
| Vagrant   | [#36899](https://gitlab.com/gitlab-org/gitlab/-/issues/36899) |

<!-- vale gitlab_base.Spelling = YES -->

<a id="rate-limits"></a>

## 速率限制

在下游项目中作为依赖项下载软件包时，会通过软件包 API 发出大量请求。因此，您可能会达到强制执行的用户和 IP 速率限制。要解决此问题，您可以为软件包 API 定义特定的速率限制。更多详情，请参阅[软件包仓库速率限制](../../rate_limits/api/package-registry.md)。

<a id="enable-or-disable-the-package-registry"></a>

## 启用或禁用软件包仓库

软件包仓库默认启用。要禁用它：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   # Change to true to enable packages - enabled by default if not defined
   gitlab_rails['packages_enabled'] = false
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       packages:
         enabled: false
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml`：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['packages_enabled'] = false
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     packages:
       enabled: false
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # For systems running systemd
   sudo systemctl restart gitlab.target

   # For systems running SysV init
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="change-the-storage-path"></a>

## 更改存储路径

默认情况下，软件包存储在本地，但您可以更改默认的本地位置，甚至可以使用对象存储。

<a id="change-the-local-storage-path"></a>

### 更改本地存储路径

默认情况下，软件包存储在相对于极狐GitLab 安装目录的本地路径中：

- Linux 软件包（Omnibus）：`/var/opt/gitlab/gitlab-rails/shared/packages/`
- 自行编译（源代码）：`/home/git/gitlab/shared/packages/`

要更改本地存储路径：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['packages_storage_path'] = "/mnt/packages"
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml`：

   ```yaml
   production: &base
     packages:
       enabled: true
       storage_path: /mnt/packages
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # For systems running systemd
   sudo systemctl restart gitlab.target

   # For systems running SysV init
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

如果您已有软件包存储在旧的存储路径中，请将所有内容从旧位置移动到新位置，以确保现有软件包仍可访问：

```shell
mv /var/opt/gitlab/gitlab-rails/shared/packages/* /mnt/packages/
```

Docker 和 Kubernetes 不使用本地存储。

- 对于 Helm chart（Kubernetes）：请改用对象存储。
- 对于 Docker：`/var/opt/gitlab/` 目录已挂载到主机上的某个目录中。无需更改容器内的本地存储路径。

<a id="use-object-storage"></a>

### 使用对象存储

您可以使用对象存储来存储软件包，而不必依赖本地存储。

更多信息，请参阅如何使用[整合对象存储设置](../object_storage.md#configure-a-single-storage-connection-for-all-object-types-consolidated-form)。

<a id="migrate-packages-between-object-storage-and-local-storage"></a>

### 在对象存储和本地存储之间迁移软件包

配置对象存储后，您可以使用以下任务在本地存储和远程存储之间迁移软件包。处理在后台工作进程中完成，无需停机。

<a id="migrate-to-object-storage"></a>

#### 迁移到对象存储

迁移任务会将软件包文件和元数据缓存移动到对象存储：软件包文件（`packages_package_files`）、Helm 元数据缓存（`packages_helm_metadata_caches`）、NPM 元数据缓存（`packages_npm_metadata_caches`）和 NuGet 符号（`packages_nuget_symbols`）。如果您之前运行过迁移，并且这些类型中仍有残留文件，请再次运行该任务；它会迁移所有剩余的本地文件。

1. 将软件包迁移到对象存储：

   {{< tabs >}}
   {{< tab title="Linux 软件包（Omnibus）" >}}

   ```shell
   sudo gitlab-rake "gitlab:packages:migrate"
   ```

   {{< /tab >}}
   {{< tab title="自行编译（源代码）" >}}

   ```shell
   RAILS_ENV=production sudo -u git -H bundle exec rake gitlab:packages:migrate
   ```

   {{< /tab >}}
   {{< /tabs >}}

1. 使用 PostgreSQL 控制台跟踪进度并验证所有软件包均已成功迁移：

   {{< tabs >}}
   {{< tab title="Linux package (Omnibus) 14.1 and earlier" >}}

   ```shell
   sudo gitlab-rails dbconsole
   ```

   {{< /tab >}}
   {{< tab title="Linux package (Omnibus) 14.2 and later" >}}

   ```shell
   sudo gitlab-rails dbconsole --database main
   ```

   {{< /tab >}}
   {{< tab title="自行编译（源代码）" >}}

   ```shell
   RAILS_ENV=production sudo -u git -H psql -d gitlabhq_production
   ```

   {{< /tab >}}
   {{< /tabs >}}

1. 使用以下 SQL 查询验证所有软件包均已迁移到对象存储。`objectstg`的数量应与 `total` 相同：

   ```sql
   SELECT count(*) AS total,
          sum(case when file_store = '1' then 1 else 0 end) AS filesystem,
          sum(case when file_store = '2' then 1 else 0 end) AS objectstg
   FROM packages_package_files;
   ```

   示例输出：

   ```plaintext
   total | filesystem | objectstg
   ------+------------+-----------
    34   |          0 |        34
   ```

1. 最后，验证 `packages` 目录中磁盘上没有任何文件：

   {{< tabs >}}
   {{< tab title="Linux 软件包（Omnibus）" >}}

   ```shell
   sudo find /var/opt/gitlab/gitlab-rails/shared/packages -type f | grep -v tmp | wc -l
   ```

   {{< /tab >}}
   {{< tab title="自行编译（源代码）" >}}

   ```shell
   sudo -u git find /home/git/gitlab/shared/packages -type f | grep -v tmp | wc -l
   ```

   {{< /tab >}}
   {{< /tabs >}}

<a id="migrate-from-object-storage-to-local-storage"></a>

#### 从对象存储迁移到本地存储

迁移的类型与迁移到对象存储时相同（软件包文件、Helm 元数据缓存、NPM 元数据缓存和 NuGet 符号）。

1. 将软件包从对象存储迁移到本地存储：

   {{< tabs >}}
   {{< tab title="Linux 软件包（Omnibus）" >}}

   ```shell
   sudo gitlab-rake "gitlab:packages:migrate[local]"
   ```

   {{< /tab >}}
   {{< tab title="自行编译（源代码）" >}}

   ```shell
   RAILS_ENV=production sudo -u git -H bundle exec rake "gitlab:packages:migrate[local]"
   ```

   {{< /tab >}}
   {{< /tabs >}}

1. 使用 PostgreSQL 控制台跟踪进度并验证所有软件包均已成功迁移：

   {{< tabs >}}
   {{< tab title="Linux package (Omnibus) 14.1 and earlier" >}}

   ```shell
   sudo gitlab-rails dbconsole
   ```

   {{< /tab >}}
   {{< tab title="Linux package (Omnibus) 14.2 and later" >}}

   ```shell
   sudo gitlab-rails dbconsole --database main
   ```

   {{< /tab >}}
   {{< tab title="自行编译（源代码）" >}}

   ```shell
   RAILS_ENV=production sudo -u git -H psql -d gitlabhq_production
   ```

   {{< /tab >}}
   {{< /tabs >}}

1. 使用以下 SQL 查询验证所有软件包均已迁移到本地存储。`filesystem`的数量应与 `total` 相同：

   ```sql
   SELECT count(*) AS total,
          sum(case when file_store = '1' then 1 else 0 end) AS filesystem,
          sum(case when file_store = '2' then 1 else 0 end) AS objectstg
   FROM packages_package_files;
   ```

   示例输出：

   ```plaintext
   total | filesystem | objectstg
   ------+------------+-----------
    34   |         34 |         0
   ```

1. 最后，验证文件存在于 `packages` 目录中：

   {{< tabs >}}
   {{< tab title="Linux 软件包（Omnibus）" >}}

   ```shell
   sudo find /var/opt/gitlab/gitlab-rails/shared/packages -type f | grep -v tmp | wc -l
   ```

   {{< /tab >}}
   {{< tab title="自行编译（源代码）" >}}

   ```shell
   sudo -u git find /home/git/gitlab/shared/packages -type f | grep -v tmp | wc -l
   ```

   {{< /tab >}}
   {{< /tabs >}}
