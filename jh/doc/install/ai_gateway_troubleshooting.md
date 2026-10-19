---
stage: AI Platform
group: AI Core Infra
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 排查 AI 网关的问题。
title: AI 网关故障排除
---

使用 [AI 网关](install_ai_gateway.md)时，您可能会遇到以下问题。

<a id="openshift-permission-issues"></a>

## OpenShift 权限问题

在 OpenShift 上部署 AI 网关时，您可能会因 OpenShift 安全模型而遇到权限错误。

<a id="read-only-file-system-at-tmp"></a>

### `/tmp` 处的只读文件系统

AI 网关会写入 `/tmp`。但是，在受安全限制的 OpenShift 环境中，`/tmp` 可能是只读的。

要解决此问题，请创建一个新的 `EmptyDir` 卷并将其挂载到 `/tmp`，可通过以下任一方式：

- 从命令行：

  ```shell
  oc set volume <object_type>/<name> --add --name=tmpVol --type=emptyDir --mountPoint=/tmp
  ```

- 在您的 `values.yaml`中：

  ```yaml
  volumes:
  - name: tmp-volume
    emptyDir: {}

  volumeMounts:
  - name: tmp-volume
    mountPath: "/tmp"
  ```

<a id="huggingface-models"></a>

### HuggingFace 模型

默认情况下，AI 网关使用 `/home/aigateway/.hf` 缓存 HuggingFace 模型，而在 OpenShift 的
受安全限制环境中，该目录可能不可写。可能会出现如下权限错误：

```shell
[Errno 13] Permission denied: '/home/aigateway/.hf/...'
```

要解决此问题，请将 `HF_HOME` 环境变量设置为可写位置。您可以使用 `/var/tmp/huggingface` 或容器可写入的任何其他目录，可通过以下任一方式：

- 在您的 `values.yaml`中：

  ```yaml
  extraEnvironmentVariables:
    - name: HF_HOME
      value: /var/tmp/huggingface  # Use any writable directory
  ```

- 在您的 Helm 升级命令中：

  ```shell
  --set "extraEnvironmentVariables[0].name=HF_HOME" \
  --set "extraEnvironmentVariables[0].value=/var/tmp/huggingface"  # Use any writable directory
  ```

此配置可确保 AI 网关能够正确缓存 HuggingFace 模型，同时遵守 OpenShift 安全约束。您选择的具体目录可能取决于您的特定 OpenShift 配置和安全策略。

<a id="tokenizer-cache-shadowed-by-a-volume-mount"></a>

## Tokenizer 缓存被卷挂载遮蔽

在以下情况下，AI 网关镜像中预缓存的 tokenizer 文件可能会被卷挂载遮蔽：

- 代码补全请求返回 `500` 错误。
- AI 网关日志显示来自 `transformers/utils/hub.py`的 `OSError`，
  尝试从 `huggingface.co` 下载 `Salesforce/codegen2-16B`。

自部署的 AI 网关镜像（`self-hosted-vX.Y.Z-ee`）设置了
`HF_HUB_OFFLINE=true` 并在构建时预缓存 tokenizer，
因此运行时不应访问 `huggingface.co`。如果发生网络访问，可能是您的 Helm values 中的某个空目录被挂载到了 `/home/aigateway/.hf`，覆盖了缓存文件。

不要试图通过授予对 `huggingface.co`的出站访问权限来解决此问题。如需诊断此问题，请改为在 AI 网关 pod 中运行以下命令：

```shell
ls -la /home/aigateway/.hf/hub/ 2>/dev/null || echo "NO_CACHE_DIR"
env | grep -E '^(HF_|TRANSFORMERS_)'
```

如果缓存目录缺失或为空，请执行以下操作：

1. 检查您的 `values.yaml`中是否有任何针对
   `/home/aigateway/.hf` 或 `HF_HOME` 所设路径的 `volumeMounts`。
1. 移除该挂载，或将其重新映射到不与镜像内置缓存
   重叠的目录。

<a id="self-signed-certificate-error"></a>

## 自签名证书错误

当 AI 网关尝试连接到使用自定义证书颁发机构（CA）签名的证书或自签名证书的极狐GitLab 实例或模型端点时，可能会出现以下错误：

```plaintext
[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: self-signed certificate in certificate chain
```

要解决此问题，请参阅[使用自签名 SSL 证书连接到极狐GitLab 实例或模型端点](install_ai_gateway.md#connect-to-a-gitlab-instance-or-model-endpoint-with-a-self-signed-ssl-certificate)。

<a id="token-creation-failed"></a>

## 令牌创建失败

如果您在使用极狐GitLab Duo Chat 等功能时遇到 `Token creation failed` 错误，则可能是未在 AI 网关上设置 `AIGW_SELF_SIGNED_JWT__SIGNING_KEY` 和 `AIGW_SELF_SIGNED_JWT__VALIDATION_KEY` 环境变量。

这些密钥是 AI 网关签发短期用户 JWT 所必需的。没有这些密钥，AI 网关无法对令牌签名，从而导致 JWK 反序列化失败。

要解决此问题：

1. 生成所需的密钥：

   ```shell
   openssl genrsa -out aigw_signing.key 2048
   openssl genrsa -out aigw_validation.key 2048
   ```

1. 通过将密钥作为环境变量传递，将其添加到您的 AI 网关容器中：

   ```shell
   -e AIGW_SELF_SIGNED_JWT__SIGNING_KEY="$(cat aigw_signing.key)" \
   -e AIGW_SELF_SIGNED_JWT__VALIDATION_KEY="$(cat aigw_validation.key)"
   ```

1. 重启 AI 网关容器。

<a id="ssl-certificate-errors-when-loading-pem-files"></a>

## 加载 PEM 文件时的 SSL 证书错误

如果您在将 PEM 文件加载到 Docker 容器时收到 `JWKError` 错误，则可能需要解决 SSL 证书错误。

要解决此问题，请使用以下环境变量在 Docker 容器中设置相应的证书包路径：

- `SSL_CERT_FILE=/path/to/ca-bundle.pem`
- `REQUESTS_CA_BUNDLE=/path/to/ca-bundle.pem`

将 `/path/to/ca-bundle.pem` 替换为您的证书包路径。
