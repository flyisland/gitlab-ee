---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 跟踪外部部署工具的部署
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

虽然极狐GitLab 提供了[内置部署方案](_index.md)，但你可能会偏向使用外部部署工具（例如 Heroku 或 ArgoCD）。
极狐GitLab 可以接收来自这些外部工具的部署事件，并让你在极狐GitLab 内跟踪部署。
例如，通过设置跟踪，你可以使用以下功能：

- [查看合并请求何时被部署，以及部署到哪个环境](../../user/project/merge_requests/widgets.md#post-merge-pipeline-status)
- [按环境或部署日期过滤合并请求](../../user/project/merge_requests/_index.md#by-environment-or-deployment-date)
- [DevOps Research and Assessment (DORA) 指标](../../user/analytics/dora_metrics.md)
- [查看环境和部署](_index.md#view-environments-and-deployments)
- [跟踪每个部署中新增的合并请求](deployments.md#track-newly-included-merge-requests-per-deployment)

> [!note]
> 因为极狐GitLab 无法授权并利用那些外部部署，所以某些功能不可用，包括
> [受保护的环境](protected_environments.md)、[部署审批](deployment_approvals.md)、[部署安全](deployment_safety.md) 和 [部署回滚](deployments.md#deployment-rollback)。

<a id="how-to-set-up-deployment-tracking"></a>

## 如何设置部署跟踪

外部部署工具通常提供 [webhook](https://en.wikipedia.org/wiki/Webhook) 以在部署状态更改时执行额外的 API 请求。
你可以将工具配置为向极狐GitLab [部署 API](../../api/deployments.md) 发起请求。以下是事件和 API 请求流程概览：

- 当部署开始运行时，[创建一个状态为 `running` 的部署](../../api/deployments.md#create-a-deployment)。
- 当部署成功时，[将部署状态更新为 `success`](../../api/deployments.md#update-a-deployment)。
- 当部署失败时，[将部署状态更新为 `failed`](../../api/deployments.md#update-a-deployment)。

> [!note]
> 你可以创建一个[项目访问令牌](../../user/project/settings/project_access_tokens.md)用于极狐GitLab API 认证。

<a id="example-track-deployments-of-argocd"></a>

### 示例：跟踪 ArgoCD 的部署

你可以使用 [ArgoCD webhook](https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/services/webhook/) 将部署事件发送到极狐GitLab 部署 API。
以下示例设置在 ArgoCD 成功部署新版本时，在极狐GitLab 中创建一条 `success` 状态的部署记录：

1. 创建一个新的 webhook。你可以保存以下清单文件，并通过 `kubectl apply -n argocd -f <清单文件路径>` 应用它：

   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: argocd-notifications-cm
   data:
     trigger.on-deployed: |
       - description: Application is synced and healthy. Triggered once per commit.
         oncePer: app.status.sync.revision
         send:
         - gitlab-deployment-status
         when: app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'
     template.gitlab-deployment-status: |
       webhook:
         gitlab:
           method: POST
           path: /projects/<your-project-id>/deployments
           body: |
             {
               "status": "success",
               "environment": "production",
               "sha": "{{.app.status.operationState.operation.sync.revision}}",
               "ref": "main",
               "tag": "false"
             }
     service.webhook.gitlab: |
       url: https://gitlab.com/api/v4
       headers:
       - name: PRIVATE-TOKEN
         value: <your-access-token>
       - name: Content-type
         value: application/json
   ```

1. 在你的应用中创建一个新的订阅：

   ```shell
   kubectl patch app <your-app-name> -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-deployed.gitlab":""}}}' --type merge
   ```

> [!note]
> 如果部署未按预期创建，你可以使用 [`argocd-notifications` 工具](https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/troubleshooting/) 进行故障排除。
> 例如，`argocd-notifications template notify gitlab-deployment-status <your-app-name> --recipient gitlab:argocd-notifications`
> 会立即触发 API 请求，并呈现来自极狐GitLab API 服务器的错误消息（如果有）。
