---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Sigstore 进行无密钥签名和验证
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

[Sigstore](https://www.sigstore.dev/) 项目提供了一个名为 [Cosign](https://docs.sigstore.dev/quickstart/quickstart-cosign/) 的 CLI，可用于对使用 GitLab CI/CD 构建的容器镜像进行无密钥签名。无密钥签名具有许多优势，包括无需管理、保护和轮换私钥。Cosign 会请求一个短生命周期的密钥对用于签名，将其记录在证书透明度日志上，然后将其丢弃。该密钥是通过从极狐GitLab 服务器获取的令牌生成的，该令牌使用运行流水线的用户的 OIDC 身份。此令牌包含唯一声明，证明该令牌是由 CI/CD 流水线生成的。要了解更多信息，请参见 Cosign 关于无密钥签名的[文档](https://docs.sigstore.dev/quickstart/quickstart-cosign/#example-working-with-containers)。

有关极狐GitLab OIDC 声明和 Fulcio 证书扩展之间的映射的详细信息，请参见[映射 OIDC 令牌声明到 Fulcio OID](https://github.com/sigstore/fulcio/blob/main/docs/oid-info.md#mapping-oidc-token-claims-to-fulcio-oids) 中的 GitLab 列。

前提条件：

- 你必须使用 JihuLab.com。
- 你的项目的 CI/CD 配置必须位于该项目中。

<a id="sign-or-verify-container-images-and-build-artifacts-by-using-cosign"></a>

## 使用 Cosign 签名或验证容器镜像和构建产物

你可以使用 Cosign 签名和验证容器镜像和构建产物。

前提条件：

- 你必须使用版本 `>= 2.0.1` 的 Cosign。

**已知问题**

- CI/CD 配置文件中的 `id_tokens` 部分必须位于正在构建和签名的项目中。不支持 AutoDevOps、从其他仓库包含的 CI 文件以及子流水线。移除该限制的工作正在史诗 11637 中跟踪。

**最佳实践**：

- 在同一作业中构建和签名镜像/产物，以防止在签名前被篡改。
- 签名容器镜像时，对摘要（不可变）进行签名，而非标签。

Cosign 可以使用 极狐GitLab [ID 令牌](../secrets/id_token_authentication.md) 进行 [无密钥签名](https://docs.sigstore.dev/quickstart/quickstart-cosign/#keyless-signing-of-a-container)。令牌必须将 `sigstore` 设置为 [`aud`](../secrets/id_token_authentication.md#token-payload) 声明。当令牌设置在 `SIGSTORE_ID_TOKEN` 环境变量中时，Cosign 可以自动使用它。

要了解更多关于如何安装 Cosign 的信息，请参见 [Cosign 安装文档](https://docs.sigstore.dev/cosign/system_config/installation/)。

<a id="signing"></a>

### 签名

<a id="container-images"></a>

#### 容器镜像

可以使用 [`Cosign.gitlab-ci.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Cosign.gitlab-ci.yml) 模板在 GitLab CI 中构建和签名容器镜像。签名会自动存储在与镜像相同的容器仓库中。

```yaml
include:
- template: Cosign.gitlab-ci.yml
```

要了解更多关于签名容器的信息，请参见 [Cosign 签名容器文档](https://docs.sigstore.dev/cosign/signing/signing_with_containers/)。

<a id="build-artifacts"></a>

#### 构建产物

以下示例演示了如何在 GitLab CI 中签名构建产物。你应保存由 `cosign sign-blob` 生成的 `cosign.bundle` 文件，该文件用于签名验证。

要了解更多关于签名产物的信息，请参见 [Cosign 签名 Blob 文档](https://docs.sigstore.dev/cosign/signing/signing_with_blobs/)。

```yaml
build_and_sign_artifact:
  stage: build
  image: alpine:latest
  variables:
    COSIGN_YES: "true"
  id_tokens:
    SIGSTORE_ID_TOKEN:
      aud: sigstore
  before_script:
    - apk add --update cosign
  script:
    - echo "This is a build artifact" > artifact.txt
    - cosign sign-blob artifact.txt --bundle cosign.bundle
  artifacts:
    paths:
      - artifact.txt
      - cosign.bundle
```

<a id="verification"></a>

### 验证

**命令行参数**

| 名称                        | 值 |
|-----------------------------|-------|
| `--certificate-identity`    | Fulcio 颁发的签名证书中的 SAN 域名。可使用签名镜像/产物所在项目的以下信息构建：GitLab 实例 URL + 项目路径 + `//` + CI 配置路径 + `@` + 引用路径。 |
| `--certificate-oidc-issuer` | 签名镜像/产物所在的 GitLab 实例 URL。例如 `https://jihulab.com`。 |
| `--bundle`                  | `cosign sign-blob` 生成的 `bundle` 文件。仅用于验证构建产物。 |

要了解更多关于验证已签名镜像/产物的信息，请参见 [Cosign 验证文档](https://docs.sigstore.dev/cosign/verifying/verify/)。

<a id="container-images"></a>

#### 容器镜像

以下示例演示了如何在 GitLab CI 中验证已签名的容器镜像。使用之前描述的 [命令行参数](#verification)。

```yaml
verify_image:
  image: alpine:3.20
  stage: verify
  before_script:
    - apk add --update cosign docker
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY
  script:
    - cosign verify "$CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG" --certificate-identity "https://jihulab.com/my-group/my-project//path/to/.gitlab-ci.yml@refs/heads/main" --certificate-oidc-issuer "https://jihulab.com"
```

**附加细节**：

- 项目路径和 `.gitlab-ci.yml` 路径之间的双反斜杠并非错误，而是验证成功所必需的。使用单反斜杠的典型错误是 `Error: none of the expected identities matched what was in the certificate, got subjects`，之后是签名 URL，其中项目路径和 `.gitlab-ci.yml` 路径之间有两个斜杠。
- 如果验证与签名在同一流水线中进行，则可以使用此路径：`"${CI_PROJECT_URL}//.gitlab-ci.yml@refs/heads/${CI_COMMIT_REF_NAME}"`。

<a id="build-artifacts"></a>

#### 构建产物

以下示例演示了如何在 GitLab CI 中验证已签名的构建产物。验证产物既需要产物本身，也需要由 `cosign sign-blob` 生成的 `cosign.bundle` 文件。使用之前描述的 [命令行参数](#verification)。

```yaml
verify_artifact:
  stage: verify
  image: alpine:latest
  before_script:
    - apk add --update cosign
  script:
    - cosign verify-blob artifact.txt --bundle cosign.bundle --certificate-identity "https://jihulab.com/my-group/my-project//path/to/.gitlab-ci.yml@refs/heads/main" --certificate-oidc-issuer "https://jihulab.com"
```

**附加细节**：

- 项目路径和 `.gitlab-ci.yml` 路径之间的双反斜杠并非错误，而是验证成功所必需的。使用单反斜杠的典型错误是 `Error: none of the expected identities matched what was in the certificate, got subjects`，之后是签名 URL，其中项目路径和 `.gitlab-ci.yml` 路径之间有两个斜杠。
- 如果验证与签名在同一流水线中进行，则可以使用此路径：`"${CI_PROJECT_URL}//.gitlab-ci.yml@refs/heads/${CI_COMMIT_REF_NAME}"`。

<a id="use-sigstore-and-npm-to-generate-keyless-provenance"></a>

## 使用 Sigstore 和 npm 生成无密钥来源证明

你可以将 Sigstore 和 npm 与 GitLab CI/CD 结合使用，在不管理密钥的情况下对构建产物进行数字签名。

<a id="about-npm-provenance"></a>

### 关于 npm 来源证明

[npm CLI](https://docs.npmjs.com/cli/) 允许软件包维护者向用户提供来源证明。使用 npm CLI 来源证明生成功能，用户可以信任并验证他们下载和使用的软件包确实来自你以及构建它的构建系统。

有关如何发布 npm 软件包的更多信息，请参见 [极狐GitLab npm 软件包仓库](../../user/packages/npm_registry/_index.md)。

<a id="sigstore"></a>

### Sigstore

[Sigstore](https://www.sigstore.dev/) 是一套工具，软件包管理器和安全专家可以使用它来保护其软件供应链免受攻击。它集成了 Fulcio、Cosign 和 Rekor 等免费使用的开源技术，处理数字签名、验证和来源检查，使分发和使用开源软件更加安全。

<a id="generating-provenance-in-gitlab-cicd"></a>

### 在 GitLab CI/CD 中生成来源证明

既然 Sigstore 如前所述支持 GitLab OIDC，你可以在 GitLab CI/CD 流水线中结合 npm 来源证明、GitLab CI/CD 和 Sigstore，为你的 npm 软件包生成并签名来源证明。

<a id="prerequisites"></a>

#### 前提条件

1. 将你的 GitLab [ID 令牌](../secrets/id_token_authentication.md) 的 `aud` 设置为 `sigstore`。
2. 添加 `--provenance` 标志以让 npm 执行发布。

要添加到 `.gitlab-ci.yml` 文件中的示例内容：

```yaml
build:
  image: node:latest
  id_tokens:
    SIGSTORE_ID_TOKEN:
      aud: sigstore
  script:
    - npm publish --provenance --access public
```

npm 极狐GitLab 模板也提供了此功能，示例见 [模板文档](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/npm.gitlab-ci.yml)。

<a id="verifying-npm-provenance"></a>

## 验证 npm 来源证明

npm CLI 也为最终用户提供了验证软件包来源证明的功能。

```plaintext
npm audit signatures
审计了 1 个软件包，耗时 0s
1 个软件包已验证注册表签名
```

<a id="inspecting-the-provenance-metadata"></a>

### 检查来源证明元数据

Rekor 透明日志存储了每个带有来源证明发布的软件包的证书和证明。例如，这里有 [以下示例的对应条目](https://search.sigstore.dev/?logIndex=21076013)。

由 npm 生成的示例来源证明文档：

```yaml
_type: https://in-toto.io/Statement/v0.1
subject:
  - name: pkg:npm/%40strongjz/strongcoin@0.0.13
    digest:
      sha512: >-
        924a134a0fd4fe6a7c87b4687bf0ac898b9153218ce9ad75798cc27ab2cddbeff77541f3847049bd5e3dfd74cea0a83754e7686852f34b185c3621d3932bc3c8
predicateType: https://slsa.dev/provenance/v0.2
predicate:
  buildType: https://github.com/npm/CLI/gitlab/v0alpha1
  builder:
    id: https://jihulab.com/strongjz/npm-provenance-example/-/runners/12270835
  invocation:
    configSource:
      uri: git+https://jihulab.com/strongjz/npm-provenance-example
      digest:
        sha1: 6e02e901e936bfac3d4691984dff8c505410cbc3
      entryPoint: deploy
    parameters:
      CI: 'true'
      CI_API_GRAPHQL_URL: https://jihulab.com/api/graphql
      CI_API_V4_URL: https://jihulab.com/api/v4
      CI_COMMIT_BEFORE_SHA: 7d3e913e5375f68700e0c34aa90b0be7843edf6c
      CI_COMMIT_BRANCH: main
      CI_COMMIT_REF_NAME: main
      CI_COMMIT_REF_PROTECTED: 'true'
      CI_COMMIT_REF_SLUG: main
      CI_COMMIT_SHA: 6e02e901e936bfac3d4691984dff8c505410cbc3
      CI_COMMIT_SHORT_SHA: 6e02e901
      CI_COMMIT_TIMESTAMP: '2023-05-19T10:17:12-04:00'
      CI_COMMIT_TITLE: trying to publish to gitlab reg
      CI_CONFIG_PATH: .gitlab-ci.yml
      CI_DEFAULT_BRANCH: main
      CI_DEPENDENCY_PROXY_DIRECT_GROUP_IMAGE_PREFIX: jihulab.com:443/strongjz/dependency_proxy/containers
      CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX: jihulab.com:443/strongjz/dependency_proxy/containers
      CI_DEPENDENCY_PROXY_SERVER: jihulab.com:443
      CI_DEPENDENCY_PROXY_USER: gitlab-ci-token
      CI_JOB_ID: '4316132595'
      CI_JOB_NAME: deploy
      CI_JOB_NAME_SLUG: deploy
      CI_JOB_STAGE: deploy
      CI_JOB_STARTED_AT: '2023-05-19T14:17:23Z'
      CI_JOB_URL: https://jihulab.com/strongjz/npm-provenance-example/-/jobs/4316132595
      CI_NODE_TOTAL: '1'
      CI_PAGES_DOMAIN: gitlab.io
      CI_PAGES_URL: https://strongjz.gitlab.io/npm-provenance-example
      CI_PIPELINE_CREATED_AT: '2023-05-19T14:17:21Z'
      CI_PIPELINE_ID: '872773336'
      CI_PIPELINE_IID: '40'
      CI_PIPELINE_SOURCE: push
      CI_PIPELINE_URL: https://jihulab.com/strongjz/npm-provenance-example/-/pipelines/872773336
      CI_PROJECT_CLASSIFICATION_LABEL: ''
      CI_PROJECT_DESCRIPTION: ''
      CI_PROJECT_ID: '45821955'
      CI_PROJECT_NAME: npm-provenance-example
      CI_PROJECT_NAMESPACE: strongjz
      CI_PROJECT_NAMESPACE_SLUG: strongjz
      CI_PROJECT_NAMESPACE_ID: '36018'
      CI_PROJECT_PATH: strongjz/npm-provenance-example
      CI_PROJECT_PATH_SLUG: strongjz-npm-provenance-example
      CI_PROJECT_REPOSITORY_LANGUAGES: javascript,dockerfile
      CI_PROJECT_ROOT_NAMESPACE: strongjz
      CI_PROJECT_TITLE: npm-provenance-example
      CI_PROJECT_URL: https://jihulab.com/strongjz/npm-provenance-example
      CI_PROJECT_VISIBILITY: public
      CI_REGISTRY: registry.jihulab.com
      CI_REGISTRY_IMAGE: registry.jihulab.com/strongjz/npm-provenance-example
      CI_REGISTRY_USER: gitlab-ci-token
      CI_RUNNER_DESCRIPTION: 3-blue.shared.runners-manager.jihulab.com/default
      CI_RUNNER_ID: '12270835'
      CI_RUNNER_TAGS: >-
        ["gce", "east-c", "linux", "ruby", "mysql", "postgres", "mongo",
        "git-annex", "shared", "docker", "saas-linux-small-amd64"]
      CI_SERVER_HOST: jihulab.com
      CI_SERVER_NAME: GitLab
      CI_SERVER_PORT: '443'
      CI_SERVER_PROTOCOL: https
      CI_SERVER_REVISION: 9d4873fd3c5
      CI_SERVER_SHELL_SSH_HOST: jihulab.com
      CI_SERVER_SHELL_SSH_PORT: '22'
      CI_SERVER_URL: https://jihulab.com
      CI_SERVER_VERSION: 16.1.0-pre
      CI_SERVER_VERSION_MAJOR: '16'
      CI_SERVER_VERSION_MINOR: '1'
      CI_SERVER_VERSION_PATCH: '0'
      CI_TEMPLATE_REGISTRY_HOST: registry.jihulab.com
      GITLAB_CI: 'true'
      GITLAB_FEATURES: >-
        elastic_search,ldap_group_sync,multiple_ldap_servers,seat_link,usage_quotas,zoekt_code_search,repository_size_limit,admin_audit_log,auditor_user,custom_file_templates,custom_project_templates,db_load_balancing,default_branch_protection_restriction_in_groups,extended_audit_events,external_authorization_service_api_management,geo,instance_level_scim,ldap_group_sync_filter,object_storage,pages_size_limit,project_aliases,password_complexity,enterprise_templates,git_abuse_rate_limit,required_ci_templates,runner_maintenance_note,runner_performance_insights,runner_upgrade_management,runner_jobs_statistics
      GITLAB_USER_ID: '31705'
      GITLAB_USER_LOGIN: strongjz
    environment:
      name: 3-blue.shared.runners-manager.jihulab.com/default
      architecture: linux/amd64
      server: https://jihulab.com
      project: strongjz/npm-provenance-example
      job:
        id: '4316132595'
      pipeline:
        id: '872773336'
        ref: .gitlab-ci.yml
  metadata:
    buildInvocationId: https://jihulab.com/strongjz/npm-provenance-example/-/jobs/4316132595
    completeness:
      parameters: true
      environment: true
      materials: false
    reproducible: false
  materials:
    - uri: git+https://jihulab.com/strongjz/npm-provenance-example
      digest:
        sha1: 6e02e901e936bfac3d4691984dff8c505410cbc3
```