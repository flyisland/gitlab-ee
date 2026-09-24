---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Require approvals prior to deploying to a Protected Environment
title: 部署审批
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以要求对受保护环境的部署进行额外审批。部署将被阻止，直到所有必需的审批都完成。

使用部署审批可满足测试、安全或合规流程。例如，您可能希望对生产环境的部署进行审批。

<a id="configure-deployment-approvals"></a>

## 配置部署审批

您可以在项目中要求对受保护环境的部署进行审批。

先决条件：

- 要更新环境，您必须具备维护者或所有者角色。

要为项目配置部署审批：

1. 在项目的 `.gitlab-ci.yml` 文件中创建部署作业：

   ```yaml
   stages:
     - deploy

   production:
     stage: deploy
     script:
       - 'echo "Deploying to ${CI_ENVIRONMENT_NAME}"'
     environment:
       name: ${CI_JOB_NAME}
       action: start
   ```

   该作业不必是手动作业（`when: manual`）。

1. 添加所需的[审批规则](#add-multiple-approval-rules)。

您项目中的环境在部署前需要审批。

<a id="add-multiple-approval-rules"></a>

### 添加多个审批规则

{{< history >}}

- 在极狐GitLab 15.0 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/issues/345678)。功能标志 `deployment_approval_rules` 已移除。
- UI 配置在极狐GitLab 15.11 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/378445)。

{{< /history >}}

添加多个审批规则以控制谁可以批准和执行部署作业。

要添加多个审批规则，您必须具备项目的开发者角色。
要将群组添加为审批者，您必须[邀请该群组到项目](../../user/project/members/sharing_projects_groups.md#invite-a-group-to-a-project)。
仅被邀请的群组会出现在审批者列表中。

要配置多个审批规则，请使用[CI/CD 设置](protected_environments.md#protecting-environments)。
您也可以[使用 API](../../api/group_protected_environments.md#protect-a-single-environment)。

所有部署到该环境的作业都会被阻止，并在运行前等待审批。
请确保所需的审批数量少于允许部署的用户数量。

每次部署，一个用户只能给出一次审批，
即使用户是多个审批者群组的成员也是如此。该行为可能在未来发生更改，以便同一用户可以从不同审批者群组为每次部署给出多次审批。

部署作业被批准后，您必须[手动运行该作业](../jobs/job_control.md#run-a-manual-job)。

<a id="allow-self-approval"></a>

### 允许自我审批

{{< history >}}

- 在极狐GitLab 15.8 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/381418)。
- 因[可用性问题](https://gitlab.com/gitlab-org/gitlab/-/issues/391258)，自动审批在极狐GitLab 16.2 中被[移除](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/124638)。

{{< /history >}}

默认情况下，触发部署流水线的用户也无法批准部署作业。

极狐GitLab 管理员可以批准或拒绝所有部署。

要允许部署作业的自我审批：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **受保护环境**。
1. 从 **审批选项** 中，选中 **允许流水线触发者审批部署** 复选框。

<a id="approve-or-reject-a-deployment"></a>

## 批准或拒绝部署

在具有多个审批规则的环境中，您可以：

- 批准部署以允许其继续进行。
- 拒绝部署以防止其进行。

先决条件：

- 您具有部署到受保护环境的权限。

要批准或拒绝部署：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **运维** > **环境**。
1. 选择环境的名称。
1. 找到部署并选择其 **状态标志**。
1. 可选。添加一条评论，描述您批准或拒绝部署的原因。
1. 选择 **批准** 或 **拒绝**。

您也可以[使用 API](../../api/deployments.md#approve-or-reject-a-deployment)。

每次部署，您只能给出一次审批，即使您是多个审批者群组的成员也是如此。
该行为可能在未来发生更改，以便同一用户可以从不同审批者群组为每次部署给出多次审批。

部署审批不会自动启动相应的部署作业。您必须[手动运行该作业](../jobs/job_control.md#run-a-manual-job)。

<a id="view-the-approval-details-of-a-deployment"></a>

### 查看部署的审批详情

先决条件：

- 您具有部署到受保护环境的权限。

向受保护环境的部署只有在所有必需的审批均获得后才能继续进行。

要查看部署的审批详情：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **运维** > **环境**。
1. 选择环境的名称。
1. 找到部署并选择其 **状态标志**。

审批状态详情将显示：

- 合格的审批者
- 已授予的审批数量和所需的审批数量
- 已授予审批的用户
- 审批或拒绝的历史记录

<a id="view-blocked-deployments"></a>

## 查看被阻止的部署

查看您的部署状态，包括部署是否被阻止。

要查看您的部署：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **运维** > **环境**。
1. 选择要部署到的环境。

带有 **已阻止** 标签的部署即被阻止。

您也可以[使用 API](../../api/deployments.md#retrieve-a-deployment) 获取部署的审批状态。
`status` 字段指示部署是否被阻止。