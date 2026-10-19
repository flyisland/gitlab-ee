---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: 使用自托管 Sigstore 技术栈对 CI/CD 产物和容器镜像进行签名，包括 Fulcio 配置和故障排除。
title: 使用自托管 Sigstore 对产物和容器镜像进行签名
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您运行的是极狐GitLab 私有化部署，则无法使用公共 [Sigstore 服务](signing_examples.md)来对 CI/CD 产物和容器镜像进行签名。该服务只信任 `GitLab.com` 流水线，而不信任您自己实例中的流水线。
您可以改为将自己的 Sigstore 基础设施（Fulcio、Rekor 和一个
证书透明度日志）连接到极狐GitLab 实例，这样就能使用 Cosign 对产物进行签名和验证，而无需依赖 `GitLab.com` 或互联网。

极狐GitLab OpenID Connect (OIDC) 提供商证明您的身份，
Cosign 在使用签名密钥后立即将其丢弃，Rekor 则在其透明度日志中记录每一次签名事件。

Fulcio 颁发的证书会嵌入签名中，同时还会包含究竟是哪个流水线创建了它的详细信息，包括项目路径、提交 SHA、流水线来源、runner 环境和作业 URL。

先决条件：

- 有权配置您的 Sigstore 基础设施（Fulcio、Rekor）和极狐GitLab CI/CD runner。
- 在您的网络中运行的自托管 Sigstore 技术栈，包括 Fulcio、Rekor 和一个证书
  透明度日志。证书透明度日志是必需的。
  Cosign 在验证期间会验证签名证书时间戳，因此未部署
  证书透明度日志的 Fulcio 所颁发的证书，Cosign 无法验证。
  有关部署说明，请参阅：
  - [Sigstore 透明度日志安装指南](https://docs.sigstore.dev/logging/installation/)
    了解 Rekor 及其 Trillian 后端
  - [Fulcio 仓库](https://github.com/sigstore/fulcio)了解 Fulcio 和证书
    透明度日志
- Rekor 配置了持久签名密钥。
- 如果您的极狐GitLab 实例使用 HTTPS 和私有证书颁发机构，则该证书
  颁发机构必须同时受到 Fulcio 和您的 CI/CD runner 的信任：
  - 将证书颁发机构证书挂载到 Fulcio 容器中，并将 `SSL_CERT_FILE`
    设置为其路径。
  - 在每个 runner 的操作系统信任存储中安装该证书颁发机构证书。
- 在您的 CI/CD runner 上安装 [Cosign](https://docs.sigstore.dev/cosign/system_config/installation/) v2.x 或更高版本。
- 将 Sigstore 技术栈中的信任材料文件放在 runner 上的共享位置，
  例如 `/etc/sigstore/`：
  - Fulcio 根 CA 证书（`fulcio-root.pem`）
  - Rekor 透明度日志公钥（`rekor-pub.pem`）
  - 证书透明度日志公钥（`ctfe-pub.pem`）

<a id="configure-fulcio-to-trust-your-gitlab-instance"></a>

## 配置 Fulcio 以信任您的极狐GitLab 实例

配置 Fulcio 以信任您的极狐GitLab 实例，使其能够在无密钥签名期间验证来自
极狐GitLab CI/CD 作业的 OIDC 令牌。Fulcio 会将令牌中的声明映射到
签名证书中的字段。该配置文件需要同时包含 `oidc-issuers` 部分和 `ci-issuer-metadata` 部分。

要配置 Fulcio：

1. 使用以下命令获取确切的 OIDC 颁发者 URL。
   将 `https://gitlab.example.com` 替换为您极狐GitLab 实例的 URL。
   Fulcio 要求完全匹配。
   协议方案以及是否带有末尾斜杠都很重要。

   ```shell
   curl --silent "https://gitlab.example.com/.well-known/openid-configuration" | jq --raw-output .issuer
   ```

1. 创建一个 Fulcio OIDC 配置文件，其中包含您极狐GitLab 实例的 `oidc-issuers` 条目。
   将 `<gitlab_issuer_url>` 替换为上一步的输出：

   ```yaml
   oidc-issuers:
     <gitlab_issuer_url>:
       issuer-url: <gitlab_issuer_url>
       client-id: sigstore
       type: ci-provider
       ci-provider: gitlab-pipeline
       contact: admin@example.com
       description: "GitLab Self-Managed OIDC"
   ```

1. 在同一文件中，添加一个 `ci-issuer-metadata` 部分，其中包含 GitLab 声明模板，
   这些模板复制自[上游 Fulcio 配置](https://github.com/sigstore/fulcio/blob/main/config/identity/config.yaml)。
   将 `<gitlab_issuer_url>` 替换为您在上一步中使用的相同值。

   有关每个声明映射到的内容，请参阅
   [将 OIDC 令牌声明映射到 Fulcio OID](https://github.com/sigstore/fulcio/blob/main/docs/oid-info.md#mapping-oidc-token-claims-to-fulcio-oids)的 GitLab 列。

   ```yaml
   ci-issuer-metadata:
     gitlab-pipeline:
       default-template-values:
         url: "<gitlab_issuer_url>"
         environment: ""
       extension-templates:
         build-signer-uri: "https://{{ .ci_config_ref_uri }}"
         build-signer-digest: "ci_config_sha"
         runner-environment: "runner_environment"
         source-repository-uri: "{{ .url }}/{{ .project_path }}"
         source-repository-digest: "sha"
         source-repository-ref: >-
           refs/{{if eq .ref_type "branch"}}heads/{{ else }}tags/{{end}}{{ .ref }}
         source-repository-identifier: "project_id"
         source-repository-owner-uri: "{{ .url }}/{{ .namespace_path }}"
         source-repository-owner-identifier: "namespace_id"
         build-config-uri: "https://{{ .ci_config_ref_uri }}"
         build-config-digest: "ci_config_sha"
         build-trigger: "pipeline_source"
         run-invocation-uri: >-
           {{ .url }}/{{ .project_path }}/-/jobs/{{ .job_id }}
         source-repository-visibility-at-signing: "project_visibility"
         deployment-environment: "environment"
       subject-alternative-name-template: "https://{{ .ci_config_ref_uri }}"
   ```

   > [!note]
   > 本部分由 Sigstore 项目维护，而非 GitLab。请定期检查
   > 上游文件是否有变更，并更新您的副本以保持一致。

<a id="sign-artifacts-and-container-images"></a>

## 对产物和容器镜像进行签名

使用 `id_tokens` 关键字为该作业生成 OIDC 令牌。Cosign 将此令牌提交给 Fulcio，由 Fulcio 颁发一个临时签名证书。

Cosign v3 使用签名配置文件来指定您的 Sigstore 服务端点和信任材料。请生成这些文件一次并分发到各 runner，或者像以下示例所示在每个作业中生成它们。

```yaml
sign-artifact:
  stage: sign
  id_tokens:
    SIGSTORE_ID_TOKEN:
      aud: sigstore
  variables:
    COSIGN_YES: "true"
  script:
    - cosign signing-config create
        --fulcio="url=http://<sigstore-host>:5555,api-version=1,start-time=2024-01-01T00:00:00Z,operator=my-org"
        --rekor="url=http://<sigstore-host>:3000,api-version=1,start-time=2024-01-01T00:00:00Z,operator=my-org"
        --rekor-config="ANY"
        --oidc-provider="url=https://gitlab.example.com,api-version=1,start-time=2024-01-01T00:00:00Z,operator=my-org"
        --out signing-config.json
    - cosign trusted-root create
        --fulcio="url=http://<sigstore-host>:5555,certificate-chain=/etc/sigstore/fulcio-root.pem,start-time=2024-01-01T00:00:00Z"
        --rekor="url=http://<sigstore-host>:3000,public-key=/etc/sigstore/rekor-pub.pem,start-time=2024-01-01T00:00:00Z"
        --ctfe="url=http://<sigstore-host>:6962,public-key=/etc/sigstore/ctfe-pub.pem,start-time=2024-01-01T00:00:00Z"
        --out trusted-root.json
    - cosign sign-blob
        --signing-config=signing-config.json
        --trusted-root=trusted-root.json
        --oidc-client-id=sigstore
        --identity-token=$SIGSTORE_ID_TOKEN
        --bundle=artifact.bundle
        artifact.txt
```

`start-time` 值是服务端点被视为有效的最早时间，其定义见
[Sigstore protobuf 规范](https://github.com/sigstore/protobuf-specs)。
请使用您的 Sigstore 技术栈部署的日期。

将 `--oidc-client-id`中的 `sigstore` 替换为您在 Fulcio OIDC
颁发者条目中配置的客户端 ID。

`--oidc-provider` 请使用与您在 Fulcio `oidc-issuers` 配置中注册的相同的颁发者 URL。

<a id="sign-container-images"></a>

### 对容器镜像进行签名

要对容器镜像进行签名，请使用 `cosign sign`，并以镜像引用代替文件路径。签名配置相同。

容器镜像仓库必须可通过 HTTPS 在可解析的主机名上访问。该镜像仓库会在其自身的外部 URL 上公布认证领域。Cosign 会拒绝主机为字面私有地址或链路本地地址的领域。如果某个实例的 `registry_external_url` 是裸 IP 地址，则它可以对文件进行签名，但无法对容器镜像进行签名。

<a id="for-cosign-v2x"></a>

### 对于 Cosign v2.x

如果您使用 Cosign v2.x，请使用 URL 标志和环境变量来代替配置文件：

```yaml
sign-artifact:
  stage: sign
  id_tokens:
    SIGSTORE_ID_TOKEN:
      aud: sigstore
  variables:
    COSIGN_YES: "true"
    SIGSTORE_ROOT_FILE: /etc/sigstore/fulcio-root.pem
    SIGSTORE_REKOR_PUBLIC_KEY: /etc/sigstore/rekor-pub.pem
    SIGSTORE_CT_LOG_PUBLIC_KEY_FILE: /etc/sigstore/ctfe-pub.pem
  script:
    - cosign sign-blob
        --fulcio-url=http://<sigstore-host>:5555
        --rekor-url=http://<sigstore-host>:3000
        --oidc-issuer=https://gitlab.example.com
        --identity-token=$SIGSTORE_ID_TOKEN
        --output-signature=artifact.sig
        --output-certificate=artifact.crt
        artifact.txt
```

对于容器镜像，请按[对容器镜像进行签名](#sign-container-images)中所述使用 Cosign v3。

Cosign v2 会将证书写为 base64 编码的 PEM。
在将其传递给其他工具之前，请先进行解码。

`--oidc-issuer` 请使用与您在 Fulcio `oidc-issuers` 配置中注册的相同的颁发者 URL。

<a id="verify-signatures"></a>

## 验证签名

使用 Cosign v3 bundle 进行验证时，会使用信任材料和预期的签名者身份：

```shell
cosign verify-blob \
  --trusted-root=trusted-root.json \
  --bundle=artifact.bundle \
  --certificate-oidc-issuer=https://gitlab.example.com \
  --certificate-identity=https://gitlab.example.com/my-group/my-project//.gitlab-ci.yml@refs/heads/main \
  artifact.txt
```

`--certificate-identity` 值是签名证书的主题备用名称，它由 CI/CD 配置路径构建而成：

```plaintext
https://<CI_SERVER_HOST>/<CI_PROJECT_PATH>//.gitlab-ci.yml@<full ref>
```

该模式中有三个细节很重要：

- 协议方案始终是 `https://`，因为 Fulcio 配置中的
  `subject-alternative-name-template` 设置了它。
  即使您的实例可通过 HTTP 访问，这一点也成立。
- `.gitlab-ci.yml` 前面的双斜杠是正确的。
  它前面的路径段是项目，其后的空段承载
  默认的 CI/CD 配置位置。
- 对于分支流水线，完整 ref 是 `refs/heads/<branch>`；对于
  标签流水线，则是 `refs/tags/<tag>`。

要验证使用 Cosign v2 签名的产物，请传入分离式签名和证书：

```shell
cosign verify-blob \
  --signature=artifact.sig \
  --certificate=artifact.crt \
  --certificate-oidc-issuer=https://gitlab.example.com \
  --certificate-identity=https://gitlab.example.com/my-group/my-project//.gitlab-ci.yml@refs/heads/main \
  artifact.txt
```

<a id="troubleshooting"></a>

## 故障排除

使用自托管 Sigstore 基础设施对产物进行签名时，您可能会遇到以下问题。

<a id="error-metadata-not-found-for-ci-provider-gitlab-pipeline"></a>

### 错误：`metadata not found for ci provider gitlab-pipeline`

当您的 Fulcio 配置中缺少 `ci-issuer-metadata` 部分时，会出现此错误。

要解决此问题，请按[配置 Fulcio 以信任您的极狐GitLab 实例](#configure-fulcio-to-trust-your-gitlab-instance)中所述添加完整的 `ci-issuer-metadata` 块。

<a id="error-ctfe-public-key-not-found-for-payload"></a>

### 错误：`ctfe public key not found for payload`

当 Cosign 找不到您自托管技术栈的证书透明度日志公钥时，会出现此错误。

要解决此问题，请在 Cosign v3 的 `cosign trusted-root create` 命令中包含 `--ctfe`，或者为 Cosign v2 设置 `SIGSTORE_CT_LOG_PUBLIC_KEY_FILE` 环境变量。

<a id="error-not-enough-verified-log-entries-from-transparency-log"></a>

### 错误：`not enough verified log entries from transparency log`

当 `trusted-root.json`中的 Rekor 公钥不再与 Rekor 实例正在使用的密钥匹配时，会出现此错误。内存签名器会在每次重启时生成新密钥和新的空 Merkle 树（Rekor 的防篡改日志结构）。因此，任何重启都会使信任材料失效，并且在重建之前，每个作业的签名都会失败。

要解决此问题，请从正在运行的实例中读取当前密钥，并重新生成受信任根：

```shell
curl --silent --fail "http://<sigstore-host>:3000/api/v1/log/publicKey" --output /etc/sigstore/rekor-pub.pem
cosign trusted-root create \
  --fulcio="url=http://<sigstore-host>:5555,certificate-chain=/etc/sigstore/fulcio-root.pem,start-time=2024-01-01T00:00:00Z" \
  --rekor="url=http://<sigstore-host>:3000,public-key=/etc/sigstore/rekor-pub.pem,start-time=2024-01-01T00:00:00Z" \
  --ctfe="url=http://<sigstore-host>:6962,public-key=/etc/sigstore/ctfe-pub.pem,start-time=2024-01-01T00:00:00Z" \
  --out trusted-root.json
```

将重新生成的 `trusted-root.json` 分发到每个 runner。

要防止此问题，请为 Rekor 配置持久签名密钥和固定的树标识符。

<a id="error-failed-to-verify-signed-certificate-timestamp"></a>

### 错误：`failed to verify signed certificate timestamp`

当证书不包含签名证书时间戳时，会出现此错误，这种情况发生在 Fulcio 未运行证书透明度日志时。在此配置下签名会成功，只有验证会失败。

要解决此问题，请为 Fulcio 配置 `--ct-log-url` 指向您的证书透明度日志，并在创建受信任根时包含 `--ctfe`。

<a id="error-x509-certificate-signed-by-unknown-authority"></a>

### 错误：`x509: certificate signed by unknown authority`

当 Fulcio 无法验证您极狐GitLab 实例提供的 TLS 证书时，会出现此错误。

要解决此问题，请将您的私有证书颁发机构证书挂载到 Fulcio 容器中，并将 `SSL_CERT_FILE` 设置为其路径。

即使 OIDC 提供商初始化失败，Fulcio 的 `/healthz` 端点也会报告 `SERVING`。请使用容器日志确认提供商已加载。
