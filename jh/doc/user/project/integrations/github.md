---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GitHub
description: 将极狐GitLab CI/CD 流水线状态更新发送到 GitHub。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用极狐GitLab 的流水线状态更新来更新 GitHub。如果您使用极狐GitLab 进行 CI/CD，GitHub 集成可以为您提供帮助。

![GitHub 上的流水线状态更新](img/github_status_check_pipeline_update_v10_6.png)

此项目集成与[实例级 GitHub 集成](../import/github.md#mirror-a-repository-and-share-pipeline-status)相互独立，当您导入 [GitHub 项目](../../../integration/github.md)时会自动配置。

<a id="configure-the-integration"></a>

## 配置集成

此集成需要一个已授予 `repo:status` 访问权限的 [GitHub API 令牌](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)。

在 GitHub 上完成以下步骤：

1. 前往您的**个人访问令牌**页面：<https://github.com/settings/tokens>。
1. 选择**生成新令牌**。
1. 在**备注**下，为新令牌输入名称。
1. 确保已选中 `repo:status`，然后选择**生成令牌**。
1. 复制生成的令牌，以便在极狐GitLab 中使用。

在极狐GitLab 中完成以下步骤：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **GitHub**。
1. 确保已选中**活跃**复选框。
1. 在**令牌**中，粘贴您在 GitHub 上生成的令牌。
1. 在**仓库 URL**中，输入您在 GitHub 上的项目路径，例如 `https://github.com/username/repository`。
1. 可选。要禁用[静态状态检查名称](#static-or-dynamic-status-check-names)，请清除**启用静态状态检查名称**复选框。
1. 可选。选择**测试设置**。
1. 选择**保存更改**。

配置集成后，请参阅[外部拉取请求的流水线](../../../ci/ci_cd_for_external_repos/_index.md#pipelines-for-external-pull-requests)，以配置流水线为打开的拉取请求运行。

<a id="static-or-dynamic-status-check-names"></a>

### 静态或动态状态检查名称

状态检查名称可以是静态或动态的：

- **静态**：您的极狐GitLab 实例的主机名会附加到状态检查名称中。

- **动态**：分支名称会附加到状态检查名称中。

**启用静态状态检查名称**选项使您能够在 GitHub 中配置
必需的状态检查，这些检查需要一个一致（静态）的名称才能正常工作。

如果您[禁用此选项](#configure-the-integration)，极狐GitLab 将改用动态状态检查名称。
