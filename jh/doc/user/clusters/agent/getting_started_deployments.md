---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 开始部署到 Kubernetes
---

本页介绍如何使用极狐GitLab 支持的方法部署到 Kubernetes。最后，您将了解：

- 如何使用 Flux 进行部署
- 如何从极狐GitLab CI/CD 流水线针对您的集群部署或运行命令
- 如何结合使用 Flux 和极狐GitLab CI/CD 以获得最佳效果

<a id="before-you-begin"></a>

## 开始之前

本教程基于您在[开始将 Kubernetes 集群连接到极狐GitLab](getting_started.md)中创建的项目。您将使用在该教程中创建的同一个项目。不过，您也可以使用任何已连接 Kubernetes 集群并已引导 Flux 安装的项目。

<a id="run-commands-against-your-cluster-from-gitlab-cicd"></a>

## 从极狐GitLab CI/CD 针对您的集群运行命令

极狐GitLab Kubernetes Agent[与极狐GitLab CI/CD 流水线集成](ci_cd_workflow.md)。您可以使用 CI/CD 以安全且可扩展的方式，针对您的集群运行 `kubectl apply` 和 `helm upgrade` 等命令。

在本节中，您将使用极狐GitLab 流水线集成在集群中创建密钥，并使用它访问极狐GitLab 容器镜像仓库。本教程的其余部分将使用已部署的密钥。

1. [创建部署令牌](../../project/deploy_tokens/_index.md#create-a-deploy-token)，并为其设置 `read_registry` 范围。
1. 将您的部署令牌和用户名保存为名为 `CONTAINER_REGISTRY_ACCESS_TOKEN` 和 `CONTAINER_REGISTRY_ACCESS_USERNAME`的 CI/CD 变量。
   - 对于这两个变量，将环境设置为 `container-registry-secret*`。
   - 对于 `CONTAINER_REGISTRY_ACCESS_TOKEN`：
     - [屏蔽该变量](../../../ci/variables/_index.md#mask-a-cicd-variable)。
     - [保护该变量](../../../ci/variables/_index.md#protect-a-cicd-variable)。
1. 将以下代码片段添加到您的 `.gitlab-ci.yml` 文件中，并更新两个 `AGENT_KUBECONTEXT` 变量，使其与您项目的路径匹配：

   ```yaml
   stages:
   - setup
   - deploy
   - stop

   create-registry-secret:
     stage: setup
     image: "portainer/kubectl-shell:latest"
     variables:
       AGENT_KUBECONTEXT: my-group/optional-subgroup/my-repository:testing
     before_script:
       # The available agents are automatically injected into the runner environment
       # You need to select the agent to use
       - kubectl config use-context $AGENT_KUBECONTEXT
     script:
       - kubectl delete secret gitlab-registry-auth -n flux-system --ignore-not-found
       - kubectl create secret docker-registry gitlab-registry-auth -n flux-system
         --docker-password="${CONTAINER_REGISTRY_ACCESS_TOKEN}" --docker-username="${CONTAINER_REGISTRY_ACCESS_USERNAME}" --docker-server="${CI_REGISTRY}"
     environment:
       name: container-registry-secret
       on_stop: delete-registry-secret

   delete-registry-secret:
     stage: stop
     image: ""
     variables:
       AGENT_KUBECONTEXT: my-group/optional-subgroup/my-repository:testing
     before_script:
       # The available agents are automatically injected into the runner environment
       # You need to select the agent to use
       - kubectl config use-context $AGENT_KUBECONTEXT
     script:
       - kubectl delete secret -n flux-system gitlab-registry-auth
     environment:
       name: container-registry-secret
       action: stop
     when: manual
   ```

在继续之前，请考虑您还可以使用 CI/CD 运行哪些其他命令。

<a id="build-a-simple-manifest-into-an-oci-image-and-deploy-it-to-the-cluster"></a>

## 将简单清单构建为 OCI 镜像并部署到集群

对于生产用例，最佳实践是使用 OCI 仓库作为 Git 代码仓库与 FluxCD 之间的缓存层。FluxCD 在 OCI 仓库中检查新镜像，而极狐GitLab 流水线则构建符合 Flux 规范的 OCI 镜像。要详细了解企业最佳实践，请参阅[企业注意事项](enterprise_considerations.md)。

在本节中，您将把一个简单的 Kubernetes 清单构建为 OCI 产物，然后将其部署到您的集群。

1. 运行以下 `flux` CLI 命令，告知 Flux 从何处获取指定的 OCI 镜像并部署其内容。
   请根据您的极狐GitLab 实例调整 `--url` 值。您可以在**部署** > **容器镜像仓库**下找到容器镜像仓库 URL。
   您可以查看创建的 `clusters/testing/nginx.yaml` 文件，以更好地了解 Flux 如何找到要部署的清单。

   ```shell
   flux create source oci nginx-example \
    --url oci://registry.gitlab.example.org/my-group/optional-subgroup/my-repository/nginx-example \
    --tag latest \
    --secret-ref gitlab-registry-auth \
    --interval 1m \
    --namespace flux-system \
    --export > clusters/testing/nginx.yaml
    flux create kustomization nginx-example \
    --source OCIRepository/nginx-example \
    --path "." \
    --prune true \
    --target-namespace default \
    --interval 1m \
    --namespace flux-system \
    --export >> clusters/testing/nginx.yaml
   ```

1. 以部署 NGINX 为例。将以下 YAML 添加到 `clusters/applications/nginx/nginx.yaml`：

   ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-example
      namespace: default
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: nginx-example
      template:
        metadata:
          labels:
            app: nginx-example
        spec:
          containers:
            - name: nginx
              image: nginx:1.25
              ports:
                - containerPort: 80
                  protocol: TCP
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: nginx-example
      namespace: default
    spec:
      ports:
        - port: 80
          targetPort: 80
          protocol: TCP
      selector:
        app: nginx-example
   ```

1. 现在，将前面的 YAML 打包为 OCI 镜像。
   使用以下代码片段扩展您的 `.gitlab-ci.yml` 文件，并再次更新 `AGENT_KUBECONTEXT` 变量：

   ```yaml
    nginx-deployment:
        stage: deploy
        variables:
            IMAGE_NAME: nginx-example   # Image name to push
            IMAGE_TAG: latest
            MANIFEST_PATH: "./clusters/applications/nginx"
            IMAGE_TITLE: NGINX example   # Image title to use in OCI annotation
            AGENT_KUBECONTEXT: my-group/optional-subgroup/my-repository:testing
            FLUX_OCI_REPO_NAME: nginx-example  # Flux OCIRepository to reconcile
            NAMESPACE: flux-system  # Namespace for the OCIRepository resource
        # This section configures a GitLab environment for the nginx deployment specifically
        environment:
            name: applications/nginx
            kubernetes:
                agent: $AGENT_KUBECONTEXT
                dashboard:
                  namespace: default
                  flux_resource_path: kustomize.toolkit.fluxcd.io/v1/namespaces/flux-system/kustomizations/nginx-example  # You will deploy this resource in the next step
        image:
            name: "fluxcd/flux-cli:v2.4.0"
            entrypoint: [""]
        before_script:
            - kubectl config use-context $AGENT_KUBECONTEXT
        script:
            # This line builds and pushes the OCI container to the GitLab container registry.
            # You can read more about this command in https://fluxcd.io/flux/cmd/flux_push_artifact/
            - flux push artifact oci://${CI_REGISTRY_IMAGE}/${IMAGE_NAME}:${IMAGE_TAG}
                --source="${CI_REPOSITORY_URL}"
                --path="${MANIFEST_PATH}"
                --revision="${CI_COMMIT_SHORT_SHA}"
                --creds="${CI_REGISTRY_USER}:${CI_REGISTRY_PASSWORD}"
                --annotations="org.opencontainers.image.url=${CI_PROJECT_URL}"
                --annotations="org.opencontainers.image.title=${IMAGE_TITLE}"
                --annotations="com.gitlab.job.id=${CI_JOB_ID}"
                --annotations="com.gitlab.job.url=${CI_JOB_URL}"
            # This line triggers an immediate reconciliation of the resource. Otherwise Flux would reconcile following its configured reconciliation period.
            # You can read more about the various reconcile commands in https://fluxcd.io/flux/cmd/flux_reconcile/
            - flux reconcile source oci -n ${NAMESPACE} ${FLUX_OCI_REPO_NAME}
   ```

1. 提交并将更改推送到您的项目，然后等待构建流水线完成。
1. 在左侧边栏中，选择**运维** > **环境**，并查看可用的 [Kubernetes 仪表板](../../../ci/environments/kubernetes_dashboard.md)。
   `applications/nginx` 环境应处于健康状态。

<a id="secure-the-gitlab-pipeline-access"></a>

## 保护极狐GitLab 流水线访问

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

之前部署的 Agent 使用 `.gitlab/agents/testing/config.yaml` 文件进行配置。默认情况下，该配置允许访问运行极狐GitLab 流水线的项目中所配置的集群。默认情况下，此访问使用已部署 Agent 的服务账号针对集群运行命令。可以将此访问限制为静态服务账号身份，也可以使用 CI/CD 作业作为集群中的身份。最后，可以使用常规 Kubernetes RBAC 来限制 CI/CD 作业在集群中的访问。

本节介绍如何通过为每个 CI/CD 作业添加身份，并在集群中模拟该作业，来限制 CI/CD 访问。

1. 要配置 CI/CD 作业模拟，请编辑 `.gitlab/agents/testing/config.yaml` 文件，并向其中添加以下代码片段（替换 `path/to/project`）：

   ```yaml
   ci_access:
      projects:
         - id: my-group/optional-subgroup/my-repository
           access_as:
              ci_job: {}
   ```

1. 由于 CI/CD 作业还没有任何集群绑定，您无法从极狐GitLab CI/CD 运行任何 Kubernetes 命令。
   让我们允许 CI/CD 作业在 `flux-system` 命名空间中创建 `Secret` 对象。
   创建包含以下内容的 `clusters/testing/gitlab-ci-job-secret-write.yaml` 文件：

   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: Role
   metadata:
      name: secret-manager
      namespace: default
   rules:
      - apiGroups: [""]
        resources: ["secrets"]
        verbs: ["create", "delete"]
   ---
   apiVersion: rbac.authorization.k8s.io/v1
   kind: RoleBinding
   metadata:
      name: gitlab-ci-secrets-binding
      namespace: default
   subjects:
      - kind: Group
        name: gitlab:ci_job
        apiGroup: rbac.authorization.k8s.io
   roleRef:
      kind: Role
      name: secret-manager
      apiGroup: rbac.authorization.k8s.io
   ```

1. 让我们也允许 CI/CD 作业触发 FluxCD 协调。
   创建包含以下内容的 `clusters/testing/gitlab-ci-job-flux-reconciler.yaml` 文件：

   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
       name: ci-job-admin
   roleRef:
       name: flux-edit-flux-system
       kind: ClusterRole
       apiGroup: rbac.authorization.k8s.io
   subjects:
       - name: gitlab:ci_job
         kind: Group
   ---
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
       name: ci-job-view
   roleRef:
       name: flux-view-flux-system
       kind: ClusterRole
       apiGroup: rbac.authorization.k8s.io
   subjects:
       - name: gitlab:ci_job
         kind: Group
   ```

有关 CI/CD 访问的更多信息，请参阅[将极狐GitLab CI/CD 与 Kubernetes 集群配合使用](ci_cd_workflow.md)。

<a id="clean-up-resources"></a>

## 清理资源

最后，移除已部署的资源，并删除您用于访问容器镜像仓库的密钥：

1. 删除 `clusters/testing/nginx.yaml` 文件。
   Flux 将负责从集群中移除相关资源。
1. 停止 `container-registry-secret` 环境。
   停止环境将触发其 `on_stop` 作业，从而从集群中移除该密钥。

<a id="next-steps"></a>

## 后续步骤

您可以使用本教程中的技巧跨项目扩展部署。OCI 镜像可以在另一个项目中构建，只要 Flux 指向正确的仓库，Flux 就会获取它。此练习留给读者完成。

如需更多练习，请尝试将 `/clusters/testing/flux-system/gotk-sync.yaml`中原始的 Flux `GitRepository` 更改为 `OCIRepository`。

最后，请参阅以下资源，了解有关 Flux 以及极狐GitLab 与 Kubernetes 集成的更多信息：

- Kubernetes 集成的[企业注意事项](enterprise_considerations.md)
- 使用 Agent 进行[运维容器扫描](vulnerabilities.md)
- 使用 Agent 为您的工程师提供[远程工作区](../../workspace/_index.md)
