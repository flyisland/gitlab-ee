---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Atlassian Bamboo 集成
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当您将变更推送到极狐GitLab 中的项目时，可以自动触发 Atlassian Bamboo 中的构建。

在接受 webhook 和提交数据时，Bamboo 并不提供与传统构建系统相同的功能。您必须先配置 Bamboo 构建计划，然后才能在极狐GitLab 中配置该集成。

<a id="configure-bamboo"></a>

## 配置 Bamboo

1. 在 Bamboo 中，前往某个构建计划，然后选择 **操作** > **配置计划**。
1. 选择 **触发器** 标签页。
1. 选择 **添加触发器**。
1. 输入描述，例如 `GitLab trigger`。
1. 选择 **提交更改时由代码仓库触发构建**。
1. 选中一个或多个代码仓库对应的复选框。
1. 在 **触发器 IP 地址**中输入极狐GitLab IP 地址。这些 IP 地址
   可以触发 Bamboo 构建。
1. 保存该触发器。
1. 在左侧窗格中，选择一个构建阶段。如果您有多个构建阶段，
   请选择包含 Git checkout 任务的最后一个阶段。
1. 选择 **杂项** 标签页。
1. 在 **模式匹配标签** 下的 **标签**中输入 `${bamboo.repository.revision.number}`。
1. 选择 **保存**。

Bamboo 已准备好接受来自极狐GitLab 的触发器。接下来，在极狐GitLab 中设置 Bamboo 集成。

<a id="configure-gitlab"></a>

## 配置极狐GitLab

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Atlassian Bamboo**。
1. 确保已选中**活跃**复选框。
1. 输入 Bamboo 服务器的基础 URL。例如，`https://bamboo.example.com`。
1. 可选。清除 **启用 SSL 验证** 复选框以禁用 [SSL 验证](_index.md#ssl-verification)。
1. 输入 Bamboo 构建计划中的[构建键](#identify-the-bamboo-build-plan-build-key)。
1. 如有必要，输入有权触发该构建计划的 Bamboo 用户的用户名和密码。
   如果不需要身份验证，请将这些字段留空。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

<a id="identify-the-bamboo-build-plan-build-key"></a>

### 识别 Bamboo 构建计划的构建键

构建键是唯一标识符，通常由项目键和计划键组成。构建键较短，全部为大写字母，并以短横线（`-`）分隔，例如 `PROJ-PLAN`。

当您在 Bamboo 中查看计划时，构建键会包含在浏览器 URL 中。例如，`https://bamboo.example.com/browse/PROJ-PLAN`。

<a id="update-bamboo-build-status-in-gitlab"></a>

## 在极狐GitLab 中更新 Bamboo 构建状态

您可以使用一个脚本，结合[提交状态 API](../../../api/commits.md#set-commit-pipeline-status) 和 Bamboo 构建变量来：

- 使用构建状态更新提交。
- 将 Bamboo 构建计划 URL 添加为提交的 `target_url`。

例如：

1. 创建一个[个人访问令牌](../../profile/personal_access_tokens.md)，并将范围设置为 `api`。
1. 将该令牌保存为 Bamboo 中的 `$GITLAB_TOKEN` 变量。
1. 将以下脚本作为最终任务添加到 Bamboo 计划的作业中：

   ```shell
   #!/bin/bash

   # Script to update CI status on GitLab.
   # Add this script as final inline script task in a Bamboo job.
   #
   # General documentation: https://docs.gitlab.com/user/project/integrations/bamboo/
   # Fix inspired from https://gitlab.com/gitlab-org/gitlab/-/issues/34744

   # Stop at first error
   set -e

   # Access token. Set this as a CI variable in Bamboo.
   #GITLAB_TOKEN=

   # Status
   cistatus="failed"
   if [ "${bamboo_buildFailed}" = "false" ]; then
     cistatus="success"
   fi

   repo_url="${bamboo_planRepository_repositoryUrl}"

   # Check if SSH or HTTPS is in use
   protocol=${repo_url::4}
   if [ "$protocol" == "git@" ]; then
     repo=${repo_url:${#protocol}};
     gitlab_url=${repo%%:*};
   else
     protocol="https://"
     repo=${repo_url:${#protocol}};
     gitlab_url=${repo%%/*};
   fi

   start=$((${#gitlab_url} + 1)) # +1 for the / (https) or : (ssh)
   end=$((${#repo} - $start -4)) # -4 for the .git
   repo=${repo:$start:$end}
   repo=$(echo "$repo" | sed "s/\//%2F/g")

   # Send request
   url="https://${gitlab_url}/api/v4/projects/${repo}/statuses/${bamboo_planRepository_revision}?state=${cistatus}&target_url=${bamboo_buildResultsUrl}"
   echo "Sending request to $url"
   curl --fail --request POST --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$url"
   ```

<a id="troubleshooting"></a>

## 故障排除

<a id="builds-not-triggered"></a>

### 构建未触发

如果构建未触发，请确保您在 Bamboo 的 **触发器 IP 地址** 下输入了正确的极狐GitLab IP 地址。此外，请检查集成 webhook 日志中是否有请求失败。

<a id="advanced-atlassian-bamboo-features-not-available-in-gitlab-ui"></a>

### 极狐GitLab UI 中不提供高级 Atlassian Bamboo 功能

高级 Atlassian Bamboo 功能与极狐GitLab 不兼容。这些功能
包括但不限于从极狐GitLab UI 查看构建日志的能力。
