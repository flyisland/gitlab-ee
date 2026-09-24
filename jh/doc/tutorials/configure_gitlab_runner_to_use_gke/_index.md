---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn how to configure GitLab Runner to run CI/CD jobs in Google Kubernetes Engine using the Kubernetes Operator.
title: '教程：配置极狐GitLab Runner 使用 Google Kubernetes Engine'
---

本教程描述了如何配置极狐GitLab Runner 使用 Google Kubernetes Engine（GKE）来运行作业。

在本教程中，你将配置极狐GitLab Runner 在[标准集群模式](https://cloud.google.com/kubernetes-engine/docs/concepts/types-of-clusters)下运行作业。

配置极狐GitLab Runner 使用 GKE 的步骤如下：

1. [设置你的环境](#set-up-your-environment)。
1. [创建并连接到集群](#create-and-connect-to-a-cluster)。
1. [安装并配置 Kubernetes Operator](#install-and-configure-the-kubernetes-operator)。
1. 可选。[验证配置是否成功](#verify-your-configuration)。

<a id="set-up-your-environment"></a>

## 设置你的环境

在配置极狐GitLab Runner 使用 GKE 之前，你必须：

- 拥有一个你具有维护者或所有者角色的项目。如果你没有项目，可以[创建一个](../../user/project/_index.md)。
- [获取项目 runner 认证令牌](../../ci/runners/runners_scope.md#create-a-project-runner-with-a-runner-authentication-token)。
- 安装极狐GitLab Runner。

<a id="set-up-your-environment"></a>

## 设置你的环境

安装用于在 GKE 中配置和使用极狐GitLab Runner 的工具。

1. [安装并配置 Google Cloud CLI](https://cloud.google.com/sdk/docs/install)。你使用 Google Cloud CLI 连接到集群。
1. [安装并配置 kubectl](https://kubernetes.io/docs/tasks/tools/)。你使用 kubectl 从本地环境与远程集群进行通信。

<a id="create-and-connect-to-a-cluster"></a>

## 创建并连接到集群

此步骤描述如何创建集群并连接到它。连接集群后，你使用 kubectl 与其进行交互。

1. 在 Google Cloud Platform 中，创建一个[标准](https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-zonal-cluster)集群。
1. 安装 kubectl 认证插件：

   ```shell
   gcloud components install gke-gcloud-auth-plugin
   ```

1. 连接到集群：

   ```shell
   gcloud container clusters get-credentials CLUSTER_NAME --zone=CLUSTER_LOCATION
   ```

1. 查看集群配置：

   ```shell
   kubectl config view
   ```

1. 验证你已连接到集群：

   ```shell
   kubectl config current-context
   ```

<a id="install-and-configure-the-kubernetes-operator"></a>

## 安装并配置 Kubernetes Operator

现在你有了一个集群，可以安装并配置 Kubernetes Operator 了。

1. 安装 `cert-manager`。如果你已经安装了证书管理器，请跳过此步骤：

   ```shell
   kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.yaml
   ```

1. 安装 Operator Lifecycle Manager（OLM），这是一个管理在集群上运行的 Kubernetes Operator 的工具：

   ```shell
   curl --silent --location "https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.24.0/install.sh" \
    | bash -s v0.24.0
   ```

1. 安装 Kubernetes Operator：

   ```shell
   kubectl create -f https://operatorhub.io/install/gitlab-runner-operator.yaml
   ```

1. 仅适用于 Operator Lifecycle Manager v0.25.0 及更高版本。添加你自己的证书管理器或使用 `cert-manager`。

   - 要添加你自己的证书提供程序：

     1. 在 `gitlab-runner-operator.yaml` 中，在 `env` 设置中定义证书命名空间和证书名称：

        ```shell
        cat > gitlab-runner-operator.yaml << EOF
        apiVersion: operators.coreos.com/v1alpha1
        kind: Subscription
        metadata:
          name: gitlab-runner-operator
          namespace: gitlab-ns
        spec:
          channel: stable
          name: gitlab-runner-operator
          source: operatorhubio-catalog
          ca: webhook-server-cert
          sourceNamespace: olm
        config:
          env:
            - name: CERTIFICATE_NAMESPACE
              value: cert_namespace_desired_value
            - name: CERTIFICATE_NAME
              value: cert_name_desired_value
        EOF
        ```

     1. 将 `gitlab-runner-operator.yaml` 应用到 Kubernetes 集群：

        ```shell
        kubectl apply -f gitlab-runner-operator.yaml
        ```

   - 使用 `cert-manager`：

     1. 使用 `certificate-issuer-install.yaml` 在默认命名空间中安装 `Certificate` 和 `Issuer`，作为 Operator 安装的补充：

        ```shell
        cat > certificate-issuer-install.yaml << EOF
        apiVersion: v1
        kind: Namespace
        metadata:
          labels:
            app.kubernetes.io/component: controller-manager
            app.kubernetes.io/managed-by: olm
            app.kubernetes.io/name: gitlab-runner-operator
          name: gitlab-runner-system
        ---
        apiVersion: cert-manager.io/v1
        kind: Certificate
        metadata:
          name: gitlab-runner-serving-cert
          namespace: gitlab-runner-system
        spec:
          dnsNames:
            - gitlab-runner-webhook-service.gitlab-runner-system.svc
            - gitlab-runner-webhook-service.gitlab-runner-system.svc.cluster.local
          issuerRef:
            kind: Issuer
            name: gitlab-runner-selfsigned-issuer
          secretName: webhook-server-cert
        ---
        apiVersion: cert-manager.io/v1
        kind: Issuer
        metadata:
          name: gitlab-runner-selfsigned-issuer
          namespace: gitlab-runner-system
        spec:
          selfSigned: {}
        EOF
        ```

     1. 将 `certificate-issuer-install.yaml` 应用到 Kubernetes 集群：

        ```shell
        kubectl create -f certificate-issuer-install.yaml
        ```

1. 创建一个包含你极狐GitLab 项目中的 `runner-registration-token` 的秘密：

   ```shell
    cat > gitlab-runner-secret.yml << EOF
    apiVersion: v1
    kind: Secret
    metadata:
      name: gitlab-runner-secret
    type: Opaque
    stringData:
      runner-token: YOUR_RUNNER_AUTHENTICATION_TOKEN
    EOF
   ```

1. 应用该秘密：

   ```shell
   kubectl apply -f gitlab-runner-secret.yml
   ```

1. 创建自定义资源定义文件并包含以下信息：

   ```shell
    cat > gitlab-runner.yml << EOF
    apiVersion: apps.gitlab.com/v1beta2
    kind: Runner
    metadata:
      name: gitlab-runner
    spec:
      gitlabUrl: https://gitlab.example.com
      buildImage: alpine
      token: gitlab-runner-secret
    EOF
   ```

1. 应用自定义资源定义文件：

   ```shell
   kubectl apply -f gitlab-runner.yml
   ```

就是这样！你已经配置了极狐GitLab Runner 使用 GKE。接下来，你可以检查配置是否正常工作。

<a id="verify-your-configuration"></a>

## 验证你的配置

要检查 runner 是否在 GKE 集群中运行，你可以执行以下操作之一：

- 使用以下命令：

  ```shell
  kubectl get pods
  ```

  你应该会看到以下输出。这表明你的 runner 正在 GKE 集群中运行：

  ```plaintext
  NAME                             READY   STATUS    RESTARTS   AGE
  gitlab-runner-hash-short_hash    1/1     Running   0          5m
  ```

- 在极狐GitLab 中查看作业日志：
  1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
  1. 选择 **构建** > **作业** 并找到作业。
  1. 要查看作业日志，选择作业状态。