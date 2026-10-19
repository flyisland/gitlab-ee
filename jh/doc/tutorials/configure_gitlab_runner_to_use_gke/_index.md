---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何配置极狐GitLab Runner，以使用 Kubernetes Operator 在 Google Kubernetes Engine 中运行 CI/CD 作业。
title: '教程：配置极狐GitLab Runner 以使用 Google Kubernetes Engine'
---

本教程介绍如何配置极狐GitLab Runner 以使用 Google Kubernetes Engine (GKE) 来运行作业。

在本教程中，您将配置极狐GitLab Runner，以在[标准集群模式](https://docs.cloud.google.com/kubernetes-engine/docs/concepts/configuration-overview)下运行作业。

要将极狐GitLab Runner 配置为使用 GKE：

1. [设置您的环境](#set-up-your-environment)。
1. [创建并连接到集群](#create-and-connect-to-a-cluster)。
1. [安装并配置 Kubernetes Operator](#install-and-configure-the-kubernetes-operator)。
1. 可选。[验证配置是否成功](#verify-your-configuration)。

<a id="before-you-begin"></a>

## 开始之前

在将极狐GitLab Runner 配置为使用 GKE 之前，您必须：

- 拥有一个您在其中具有维护者或所有者角色的项目。如果您没有项目，可以[创建项目](../../user/project/_index.md)。
- [获取项目 Runner 认证令牌](../../ci/runners/runners_scope.md#create-a-project-runner-with-a-runner-authentication-token)。
- 安装极狐GitLab Runner。

<a id="set-up-your-environment"></a>

## 设置您的环境

安装相关工具，以便在 GKE 中配置和使用极狐GitLab Runner。

1. [安装并配置 Google Cloud CLI](https://cloud.google.com/sdk/docs/install)。您可以使用 Google Cloud CLI 连接到集群。
1. [安装并配置 kubectl](https://kubernetes.io/docs/tasks/tools/)。您可以使用 kubectl 从本地环境与远程集群通信。

<a id="create-and-connect-to-a-cluster"></a>

## 创建并连接到集群

本步骤介绍如何创建集群并连接到该集群。连接到集群后，您可以使用 kubectl 与其交互。

1. 在 Google Cloud Platform 中，创建一个[标准](https://docs.cloud.google.com/kubernetes-engine/docs/how-to/creating-a-zonal-cluster)集群。
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

1. 验证您已连接到集群：

   ```shell
   kubectl config current-context
   ```

<a id="install-and-configure-the-kubernetes-operator"></a>

## 安装并配置 Kubernetes Operator

现在您已经有了一个集群，可以开始安装并配置 Kubernetes Operator 了。

1. 安装 `cert-manager`。如果您已经安装了证书管理器，请跳过此步骤：

   ```shell
   kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.yaml
   ```

1. 安装 Operator Lifecycle Manager (OLM)，这是一个用于管理集群上运行的 Kubernetes Operator 的工具：

   ```shell
   curl --silent --location "https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.24.0/install.sh" \
    | bash -s v0.24.0
   ```

1. 安装 Kubernetes Operator：

   ```shell
   kubectl create -f https://operatorhub.io/install/gitlab-runner-operator.yaml
   ```

1. 仅适用于 Operator Lifecycle Manager v0.25.0 及更高版本。添加您自己的证书管理器，或使用 `cert-manager`。

   - 要添加您自己的证书提供商：

     1. 在 `gitlab-runner-operator.yaml`中，在 `env` 设置中定义证书命名空间和证书名称：

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

   - 要使用 `cert-manager`：

     1. 除了安装 Operator 之外，还要使用 `certificate-issuer-install.yaml` 在默认命名空间中安装 `Certificate` 和 `Issuer`：

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

1. 创建一个密钥，其中包含来自您极狐GitLab 项目的 `runner-registration-token`：

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

1. 应用该密钥：

   ```shell
   kubectl apply -f gitlab-runner-secret.yml
   ```

1. 创建自定义资源定义文件，并包含以下信息：

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

1. 应用该自定义资源定义文件：

   ```shell
   kubectl apply -f gitlab-runner.yml
   ```

就是这样！您已将极狐GitLab Runner 配置为使用 GKE。
在下一步中，您可以检查配置是否正常工作。

<a id="verify-your-configuration"></a>

## 验证您的配置

要检查 Runner 是否在 GKE 集群中运行，您可以：

- 使用以下命令：

  ```shell
  kubectl get pods
  ```

  您应该会看到以下输出。这表明您的 Runner 正在 GKE 集群中运行：

  ```plaintext
  NAME                             READY   STATUS    RESTARTS   AGE
  gitlab-runner-hash-short_hash    1/1     Running   0          5m
  ```

- 在极狐GitLab 中查看作业日志：
  1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
  1. 选择**构建** > **作业**，然后找到该作业。
  1. 要查看作业日志，请选择该作业状态。
