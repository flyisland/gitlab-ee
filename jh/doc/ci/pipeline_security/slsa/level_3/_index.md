---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: SLSA 3 级来源证明
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Status: 实验性

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 18.3 [带有功能标志](../../../../administration/feature_flags/_index.md) 名为 `slsa_provenance_statement`。默认禁用。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史记录。
> 此功能可用于测试，但尚未准备好用于生产环境。

极狐GitLab 可以生成 SLSA 3 级兼容的来源证明。
2 级和 3 级来源证明之间的主要区别在于[隔离和“不可伪造”要求](https://slsa.dev/spec/v1.2/build-requirements#isolated)。

有关证明的详细信息，请参见极狐GitLab [SLSA 来源规范](provenance_v1.md)。

<a id="prerequisites"></a>

## 先决条件

要对任何容器或产物进行证明，需要满足以下条件：

- 与构建关联的项目必须是公开的。强制执行此要求是为了防止信息意外泄露给 [Rekor](https://docs.sigstore.dev/logging/overview/)。
- 构建必须使用 `build` 阶段。
- 项目的 `slsa_provenance_statement` 功能标志必须启用。

<a id="generate-an-attestation-for-artifacts"></a>

## 为产物生成证明

要为构建生成的所有产物生成证明：

- 将 `ATTEST_BUILD_ARTIFACTS` CI/CD 变量设置为 `true`。
- 产物不得超过 100 MB。

例如，极狐GitLab 为此 CI/CD 作业中的产物生成证明：

```yaml
build-job:
  stage: build
  variables:
    ATTEST_BUILD_ARTIFACTS: true
  script:
    - echo "Hello, $GITLAB_USER_LOGIN!"
    - echo "Hello, $GITLAB_USER_LOGIN!" > test.txt
  artifacts:
    paths:
      - test.txt
```

<a id="generate-an-attestation-for-a-container"></a>

## 为容器生成证明

要为容器生成证明：

- 将 CI/CD 变量 `ATTEST_CONTAINER_IMAGES` 设置为 `true`。
- 将 `IMAGE_DIGEST` 变量设置为有效的 SHA256 引用，格式如下：

  ```plaintext
  sha256:9bf00f5090086aba643d21f8ed663576855add63b7b780b4eaffc5124812c3c9
  org/project-name@sha256:9bf00f5090086aba643d21f8ed663576855add63b7b780b4eaffc5124812c3c9
  9bf00f5090086aba643d21f8ed663576855add63b7b780b4eaffc5124812c3c9
  ```

例如，极狐GitLab 为此 CI/CD 作业中创建的镜像生成证明：

```yaml
build-dockerhub:
  stage: build
  variables:
    ATTEST_CONTAINER_IMAGES: true
    CI_REGISTRY: docker.io
    DOCKER_IMAGE_NAME: sroqueworcel/test-slsa-sbom:stable
  script:
    - echo $DOCKER_REGISTRY_PASSWORD | docker login $CI_REGISTRY -u $DOCKER_REGISTRY_USER --password-stdin
    - docker build -t $DOCKER_IMAGE_NAME .
    - docker push $DOCKER_IMAGE_NAME
    - IMAGE_DIGEST="$(docker inspect --format='{{index .Id}}' "$DOCKER_IMAGE_NAME")"
    - echo "IMAGE_DIGEST=$IMAGE_DIGEST" >> build.env
  artifacts:
    reports:
      dotenv: build.env
```

<a id="view-attestations"></a>

## 查看证明

成功的证明存储在证明页面中。要查看证明：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **构建** > **证明**。

如果证明不成功，CI/CD 作业日志会显示错误。

您也可以使用 [证明 API](../../../../api/attestations.md) 获取成功的证明。

<a id="verifying-attestations"></a>

## 验证证明

您可以使用 `glab` 命令行界面验证产物和容器。例如：

- 一个成功验证：

  ```shell
  % glab attestation verify ~/file-or-container -p org/project-name
  产物来源已成功验证。签名确认 file.txt 由 org/project-name 进行了证明
  ```

- 一个失败验证：

  ```shell
  % glab attestation verify ~/file.txt -p org/project-name

     ERROR

    无法找到 1f9e5808a340916aa5618ee13a893dcf9d4f7e2d42a254be0f7eb06a094ab8ea 的来源声明。
  ```