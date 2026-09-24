---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从企业版回退至基础版
---

您可以将您的企业版（EE）实例回退至基础版（CE），但必须首先：

1. 禁用仅 EE 版本可用的认证机制。
1. 从数据库中删除仅 EE 版本可用的集成。
1. 调整使用了环境范围的配置。

<a id="turn-off-ee-only-authentication-mechanisms"></a>

## 关闭仅 EE 版本可用的认证机制

Kerberos 仅在企业版实例上可用。您必须：

- 在回退前关闭这些机制。
- 为您的用户提供另一种认证方法。

<a id="remove-ee-only-integrations-from-the-database"></a>

## 从数据库中删除仅 EE 版本可用的集成

以下集成仅在 EE 代码库中可用：

- [GitHub](../../user/project/integrations/github.md)
- [Git Guardian](../../user/project/integrations/git_guardian.md)
- [Google Artifact Management](../../user/project/integrations/google_artifact_management.md)
- [Google Cloud IAM](../../integration/google_cloud_iam.md)

如果您降级到 CE 版本，您可能会遇到类似以下的错误：

```plaintext
Completed 500 Internal Server Error in 497ms (ActiveRecord: 32.2ms)

ActionView::Template::Error (The single-table inheritance mechanism failed to locate the subclass: 'Integrations::Github'. This
error is raised because the column 'type_new' is reserved for storing the class in case of inheritance. Please rename this
column if you didn't intend it to be used for storing the inheritance class or overwrite Integration.inheritance_column to
use another column for that information.)
```

错误消息中的 `subclass` 可能是以下任意一种：

- `Integrations::Github`
- `Integrations::GitGuardian`
- `Integrations::GoogleCloudPlatform::ArtifactRegistry`
- `Integrations::GoogleCloudPlatform::WorkloadIdentityFederation`

所有集成都会自动为您的每个项目创建。
为避免出现此错误，您必须从数据库中删除所有仅 EE 版本的集成记录。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

```shell
sudo gitlab-rails runner "Integration.where(type_new: ['Integrations::Github']).delete_all"
sudo gitlab-rails runner "Integration.where(type_new: ['Integrations::GitGuardian']).delete_all"
sudo gitlab-rails runner "Integration.where(type_new: ['Integrations::GoogleCloudPlatform::ArtifactRegistry']).delete_all"
sudo gitlab-rails runner "Integration.where(type_new: ['Integrations::GoogleCloudPlatform::WorkloadIdentityFederation']).delete_all"
```

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

```shell
bundle exec rails runner "Integration.where(type_new: ['Integrations::Github']).delete_all" production
bundle exec rails runner "Integration.where(type_new: ['Integrations::GitGuardian']).delete_all" production
bundle exec rails runner "Integration.where(type_new: ['Integrations::GoogleCloudPlatform::ArtifactRegistry']).delete_all" production
bundle exec rails runner "Integration.where(type_new: ['Integrations::GoogleCloudPlatform::WorkloadIdentityFederation']).delete_all" production
```

{{< /tab >}}

{{< /tabs >}}

<a id="adjust-configuration-that-uses-environment-scopes"></a>

## 调整使用了环境范围的配置

如果您使用了[环境范围](../../user/group/clusters/_index.md#environment-scopes)，您可能需要调整您的配置，特别是当配置变量共享相同的键，但具有不同的范围时。
环境范围在 CE 版本中会被完全忽略。

对于共享相同键但范围不同的配置变量，您可能会在特定环境中意外获取到一个您不期望的变量。在这种情况下，请确保您拥有正确的变量。

您的数据在转换过程中会被完全保留，因此您可以随时改回 EE 版本并恢复原有行为。

<a id="revert-to-ce"></a>

## 回退到 CE 版本

在完成必要的步骤后，您可以将您的 极狐GitLab 实例回退至 CE 版本。

请遵循正确的[更新指南](../_index.md)以确保所有依赖项都是最新的。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

按照[适用于您发行版的安装说明](../../install/package/_index.md#supported-platforms)，安装基础版软件包。

{{< /tab >}}

{{< tab title="Self-compiled (source)" >}}

1. 将您的 极狐GitLab 安装的当前 Git 远程仓库替换为 CE 版本的 Git 远程仓库。
1. 获取最新的更改并检出最新的稳定分支。例如：

   ```shell
   git remote set-url origin git@jihulab.com:gitlab-cn/gitlab-foss.git
   git fetch --all
   git checkout 17-8-stable
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="troubleshooting"></a>

## 故障排除

本节包含您可能遇到的问题的潜在解决方案。

<a id="error-cookbook-gitlab-ee-not-found"></a>

### 错误：`Cookbook gitlab-ee not found`

在 极狐GitLab EE 实例上安装 极狐GitLab CE 版本的 Linux 包时，您可能会遇到 `Cookbook gitlab-ee not found` 错误。要解决此问题：

1. 删除 `gitlab-ee` cookbook：

   ```shell
   sudo rm -rf /opt/gitlab/embedded/cookbooks/cache/cookbooks/gitlab-ee
   ```

1. 重新安装 极狐GitLab CE 版本。
1. 检查所有服务是否都已启动：

   ```shell
   sudo gitlab-ctl status
   ```

   如果没有，请重启 极狐GitLab：

   ```shell
   sudo gitlab-ctl restart
   ```
