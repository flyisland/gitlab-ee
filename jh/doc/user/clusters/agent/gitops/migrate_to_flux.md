---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从传统 GitOps 迁移到 Flux
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

大多数用户可以从他们传统的基于代理的 GitOps 解决方案迁移到 Flux，无需额外工作或停机。在大多数情况下，Flux 可以接管现有工作负载，无需任何重启。

<a id="example-gitops-configuration"></a>

## 示例 GitOps 配置

你的传统 GitOps 设置可能包含如下代理配置：

```yaml
gitops:
  manifest_projects:
  - id: <your-group>/<your-repository>
    paths:
    - glob: 'manifests/*.yaml'
```

`paths.glob` 中引用的 `manifests` 目录可能有两个清单。一个清单定义了一个 `Namespace`：

```yaml
# /manifests/namespace.yaml

---
apiVersion: v1
kind: Namespace
metadata:
  name: production
```

另一个清单定义了一个 `Deployment`：

```yaml
# /manifests/deployment.yaml

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: production
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

本页的主题使用此配置来演示向 Flux 的迁移。

<a id="disable-legacy-gitops-functionality-in-the-agent"></a>

## 禁用代理中的传统 GitOps 功能

当 GitOps 配置被移除时，代理不会删除它已应用的任何运行中的工作负载。
要从代理中移除 GitOps 功能：

- 从代理配置文件中删除 `gitops` 部分。

你仍然需要一个正常工作的代理，
因此不要删除整个 `config.yaml` 文件。

如果你在 `gitops.manifest_projects` 或 `paths` 列表下有多个条目，可以通过仅移除特定项目或路径来一次迁移一部分。

<a id="bootstrap-flux"></a>

## 引导 Flux

开始之前：

- 你已在代理中禁用了 GitOps 功能。
- 你已在可访问集群的终端中安装了 Flux CLI。

要引导 Flux：

- 在你的终端中，运行 `flux bootstrap gitlab` 命令。例如：

  ```shell
  flux bootstrap gitlab \
  --owner=<your-group> \
  --repository=<your-repository> \
  --branch=main \
  --path=manifests/ \
  --deploy-token-auth
  ```

Flux 将安装到你的集群上，必要的 Flux 配置文件将被提交到 `manifests/flux-system`，
该目录会同步 Flux 和整个 `manifests` 目录。

由于工作负载（`Namespace` 和 `Deployment` 清单）
已在 `manifests` 目录中声明，因此无需额外工作。

有关使用极狐GitLab 配置 Flux 的更多信息，请参见
[教程：为 GitOps 设置 Flux](../getting_started.md)。

<a id="troubleshooting"></a>

## 故障排除

<a id="flux-bootstrap-doesnt-reconcile-manifests-correctly"></a>

### `flux bootstrap` 未能正确协调清单

`flux bootstrap` 命令会创建一个指向 `manifests` 目录的 `kustomizations.kustomize.toolkit.fluxcd.io` 资源。
该资源会应用到目录中的所有 Kubernetes 清单，
无需 [Kustomization 文件](https://kubectl.docs.kubernetes.io/references/kustomize/glossary/#kustomization)。

此过程可能不适用于你的配置。
要进行故障排除，请查看 Flux Kustomization 状态以发现潜在问题：

```shell
kubectl get kustomizations.kustomize.toolkit.fluxcd.io -n flux-system
```

<a id="use-a-default-namespace-in-the-agent-configuration"></a>

### 在代理配置中使用 `default_namespace`

如果你的传统基于代理的 GitOps 设置在代理配置中引用了 `default_namespace`，但在清单本身中省略了该命名空间，则可能会遇到问题。这会导致引导后的 Flux 不知道你的现有清单已应用到 `default_namespace`，从而引发错误。

要解决此问题，你可以选择：

- 在先前存在的资源 YAML 中手动设置命名空间。
- 将你的资源移动到一个专用目录，并使用 `kustomize.toolkit.fluxcd.io/Kustomization` 将 Flux 指向该目录，其中 `spec.targetNamespace` 指定命名空间。
- 将资源移动到一个子目录，并添加一个设置 `spec.namespace` 属性的 `kustomization.yaml` 文件。

如果你希望将资源移出已为 Flux 配置的路径，
则应使用 `kustomize.toolkit.fluxcd.io/Kustomization`。
如果你希望将资源移动到 Flux 已监视路径的子目录中，
则应使用 `kustomize.config.k8s.io/Kustomization`。