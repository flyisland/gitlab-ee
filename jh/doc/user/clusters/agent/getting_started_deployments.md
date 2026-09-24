---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 开始部署到 Kubernetes
---

本页介绍如何使用极狐GitLab 支持的方法部署到 Kubernetes。
最后，您将了解：

- 如何使用 Flux 进行部署
- 如何从极狐GitLab CI/CD 流水线部署或对您的集群运行命令
- 如何结合 Flux 和极狐GitLab CI/CD 以获得最佳结果

<a id="before-you-begin"></a>

## 开始之前

本教程基于您在[开始将 Kubernetes 集群连接到极狐GitLab](getting_started.md)中创建的项目继续。您将使用在该教程中创建的同一个项目。不过，您也可以使用任何已连接 Kubernetes 集群并完成 Flux 引导安装的项目。

<a id="run-commands-against-your-cluster-from-gitlab-cicd"></a>

## 对您的集群从极狐GitLab CI/CD 运行命令

Kubernetes 代理与极狐GitLab CI/CD 流水线集成。您可以使用 CI/CD 以安全且可扩展的方式对集群运行诸如 `kubectl apply` 和 `helm upgrade` 等命令。

在本节中，您将使用极狐GitLab 流水线集成在集群中创建一个密钥，并用其访问极狐GitLab 容器镜像仓库。本教程的其余部分将使用已部署的密钥。

1. 创建一个具有 `read_registry` 范围的[部署令牌](../../project/deploy_tokens/_index.md#create-a-deploy-token)。
1. 将您的部署令牌和用户名保存为名为 `CONTAINER_REGISTRY_ACCESS_TOKEN` 和 `CONTAINER_REGISTRY_ACCESS_USERNAME` 的 CI/CD 变量。
   - 对于这两个变量，将环境设置为 `container-registry-secret*`。
   - 对于 `CONTAINER_REGISTRY_ACCESS_TOKEN`：
     - [掩盖变量](../../../ci/variables/_index.md#mask-a-cicd-variable)。
     - [保护变量](../../../ci/variables/_index.md#protect-a-cicd-variable)。
1. 将以下代码片段添加到您的 `.gitlab-ci.yml` 文件中，并更新两个 `AGENT_KUBECONTEXT` 变量以匹配您的项目路径：

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
       # 可用的代理会自动注入到 Runner 环境中
       # 您需要选择要使用的代理
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
       # 可用的代理会自动注入到 Runner 环境中
       # 您需要选择要使用的代理
       - kubectl config use-context $AGENT_KUBECONTEXT
     script:
       - kubectl delete secret -n flux-system gitlab-registry-auth
     environment:
       name: container-registry-secret
       action: stop
     when: manual
   ```

在继续之前，思考一下如何使用 CI/CD 运行其他命令。

<a id="build-a-simple-manifest-into-an-oci-image-and-deploy-it-to-the-cluster"></a>

## 将简单的清单构建为 OCI 镜像并部署到集群

对于生产环境，最佳实践是使用 OCI 仓库作为 Git 仓库与 FluxCD 之间的缓存层。
FluxCD 检查 OCI 仓库中的新镜像，而极狐GitLab 流水线构建符合 Flux 标准的 OCI 镜像。
要了解更多企业最佳实践，请参阅[企业考虑因素](enterprise_considerations.md)。

在本节中，您将构建一个简单的 Kubernetes 清单作为 OCI 制品，然后将其部署到您的集群。

1. 运行以下 `flux` CLI 命令，告知 Flux 从哪里获取指定的 OCI 镜像并部署其内容。
   根据您的极狐GitLab 实例调整 `--url` 值。您可以在 **部署** > **容器镜像仓库** 下找到容器镜像仓库 URL。
   您可以检查创建的 `clusters/testing/nginx.yaml` 文件，以更好地理解 Flux 如何查找要部署的清单。

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

1. 现在，我们将之前的 YAML 打包成 OCI 镜像。
   通过以下代码片段扩展您的 `.gitlab-ci.yml` 文件，并再次更新 `AGENT_KUBECONTEXT` 变量：

   ```yaml
    nginx-deployment:
        stage: deploy
        variables:
            IMAGE_NAME: nginx-example   # 要推送的镜像名称
            IMAGE_TAG: latest
            MANIFEST_PATH: "./clusters/applications/nginx"
            IMAGE_TITLE: NGINX example   # OCI 注解使用的镜像标题
            AGENT_KUBECONTEXT: my-group/optional-subgroup/my-repository:testing
            FLUX_OCI_REPO_NAME: nginx-example  # 要协调的 Flux OCIRepository
            NAMESPACE: flux-system  # OCIRepository 资源的命名空间
        # 本部分专门为 nginx 部署配置极狐GitLab 环境
        environment:
            name: applications/nginx
            kubernetes:
                agent: $AGENT_KUBECONTEXT
                dashboard:
                  namespace: default
                  flux_resource_path: kustomize.toolkit.fluxcd.io/v1/namespaces/flux-system/kustomizations/nginx-example  # 您将在下一步中部署此资源
        image:
            name: "fluxcd/flux-cli:v2.4.0"
            entrypoint: [""]
        before_script:
            - kubectl config use-context $AGENT_KUBECONTEXT
        script:
            # 这一行构建 OCI 容器并将其推送到极狐GitLab 容器镜像仓库。
            # 您可以在 https://fluxcd.io/flux/cmd/flux_push_artifact/ 中了解有关此命令的更多信息。
            - flux push artifact oci://${CI_REGISTRY_IMAGE}/${IMAGE_NAME}:${IMAGE_TAG}
                --source="${CI_REPOSITORY_URL}"
                --path="${MANIFEST_PATH}"
                --revision="${CI_COMMIT_SHORT_SHA}"
                --creds="${CI_REGISTRY_USER}:${CI_REGISTRY_PASSWORD}"
                --annotations="org.opencontainers.image.url=${CI_PROJECT_URL}"
                --annotations="org.opencontainers.image.title=${IMAGE_TITLE}"
                --annotations="com.gitlab.job.id=${CI_JOB_ID}"
                --annotations="com.gitlab.job.url=${CI_JOB_URL}"
            # 这一行立即触发资源协调。否则 Flux 会按照其配置的协调周期进行协调。
            # 您可以在 https://fluxcd.io/flux/cmd/flux_reconcile/ 中了解各种协调命令的更多信息。
            - flux reconcile source oci -n ${NAMESPACE} ${FLUX_OCI_REPO_NAME}
   ```

1. 提交并推送更改到您的项目，然后等待构建流水线完成。
1. 在左侧边栏中，选择 **运维** > **环境** 并查看可用的 [Kubernetes 仪表盘](../../../ci/environments/kubernetes_dashboard.md)。
   `applications/nginx` 环境应该运行正常。

<a id="secure-the-gitlab-pipeline-access"></a>

## 保护极狐GitLab 流水线访问

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

先前部署的代理是通过 `.gitlab/agents/testing/config.yaml` 文件配置的。
默认情况下，该配置允许访问运行极狐GitLab 流水线的项目中所配置的集群。
默认情况下，此访问使用已部署代理的服务账户对集群运行命令。
此访问可以限制为静态服务账户身份，也可以使用 CI/CD 作业作为集群中的身份。
最后，可以使用常规 Kubernetes RBAC 限制集群中 CI/CD 作业的访问。

本节展示了如何通过为每个 CI/CD 作业添加身份并在集群中模拟该作业来限制 CI/CD 访问。

1. 要配置 CI/CD 作业模拟，编辑 `.gitlab/agents/testing/config.yaml` 文件，并将以下代码片段添加到其中（将 `path/to/project` 替换为您的项目路径）：

   ```yaml
   ci_access:
      projects:
         - id: my-group/optional-subgroup/my-repository
           access_as:
              ci_job: {}
   ```

1. 由于 CI/CD 作业尚未与集群绑定，您无法从极狐GitLab CI/CD 运行任何 Kubernetes 命令。
   现在我们来启用 CI/CD 作业在 `flux-system` 命名空间中创建 `Secret` 对象。
   创建 `clusters/testing/gitlab-ci-job-secret-write.yaml` 文件，内容如下：

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

1. 我们还要启用 CI/CD 作业来触发 FluxCD 协调。
   创建 `clusters/testing/gitlab-ci-job-flux-reconciler.yaml` 文件，内容如下：

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

有关 CI/CD 访问的更多信息，请参阅[将极狐GitLab CI/CD 与 Kubernetes 集群搭配使用](ci_cd_workflow.md)。

<a id="clean-up-resources"></a>

## 清理资源

最后，移除已部署的资源并删除您用于访问容器镜像仓库的密钥：

1. 删除 `clusters/testing/nginx.yaml` 文件。
   Flux 将负责从集群中删除相关资源。
1. 停止 `container-registry-secret` 环境。
   停止环境将触发其 `on_stop` 作业，从集群中删除密钥。

<a id="next-steps"></a>

## 后续步骤

您可以将本教程中的技术用于跨项目的规模部署。OCI 镜像可以在不同的项目中构建，只要 Flux 指向正确的仓库，Flux 就会获取它。此练习留给读者。

要进一步练习，请尝试将 `/clusters/testing/flux-system/gotk-sync.yaml` 中的原始 Flux `GitRepository` 更改为 `OCIRepository`。

最后，有关 Flux 和极狐GitLab 与 Kubernetes 集成的更多信息，请参阅以下资源：

- Kubernetes 集成的[企业考虑因素](enterprise_considerations.md)
- 使用代理进行[运维容器扫描](vulnerabilities.md)
- 使用代理为您的工程师提供[远程工作区](../../workspace/_index.md)