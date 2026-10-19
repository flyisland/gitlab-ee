---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: '教程：设置 DAST 以扫描您的 Web 应用程序'
---

<!-- vale gitlab_base.FutureTense = NO -->

了解如何将动态应用程序安全测试（DAST）集成到您的 CI/CD 流水线中。

静态分析会查找源代码中的漏洞。DAST 可识别仅在应用程序于真实环境中运行并与服务和用户工作流交互时才会出现的运行时安全问题。借助与极狐GitLab 集成的 DAST 解决方案，您可以设置极狐GitLab DAST，在每次将代码部署到测试环境时自动检查这些问题。

在本教程中，您将学习如何：

1. [设置 Tanuki Shop 应用程序](#set-up-the-tanuki-shop-application)
1. [定义构建作业](#define-the-build-job)
1. [定义 DAST 作业](#define-the-dast-job)
1. [配置被动扫描和主动扫描](#configure-passive-and-active-scanning)
1. [验证您的设置](#verify-your-setup)

> [!note]
> 本教程中的 Tanuki Shop 应用程序不需要身份验证。如果您的应用程序需要登录，
> 请参阅 [DAST 身份验证](configuration/authentication.md)。

<a id="before-you-begin"></a>

## 先决条件

- 极狐GitLab 旗舰版订阅。
- 您项目的维护者角色。

<a id="set-up-the-tanuki-shop-application"></a>

## 设置 Tanuki Shop 应用程序

您将首先 forking Tanuki Shop。

1. 转到 [Tanuki Shop 代码仓库](https://gitlab.com/gitlab-da/tutorials/security-and-governance/tanuki-shop)。
1. 在右上角，选择 **Fork**。
1. 选择您的命名空间（个人或群组），然后选择 **Fork 项目**。

   forked 代码仓库包含本教程所需的所有文件，包括应用程序代码和初始 CI/CD 配置。我们将在后续步骤中修改该配置。

1. 转到**设置** > **通用**。
1. 展开**可见性、项目功能、权限**。
1. 确保**容器镜像仓库**开关已打开。
1. 验证容器镜像仓库是否正常工作：
   1. 转到**部署** > **容器镜像仓库**。
   1. 您应该会看到一个空的镜像仓库。如果看到错误，请检查您的项目权限。

   > [!note]
   > 容器镜像仓库用于存储您在流水线中构建的 Docker 镜像。如果此步骤失败，
   > 构建作业稍后也会失败。

<a id="define-the-build-job"></a>

## 定义构建作业

现在，您将配置构建作业，以创建包含应用程序的 Docker 镜像并将其推送到容器镜像仓库。

1. 在您的项目中，编辑 `.gitlab-ci.yml` 文件。
1. 将现有内容替换为以下 CI/CD 配置：

   ```yaml
   stages:
     - build
     - dast

   include:
     - template: Security/DAST.gitlab-ci.yml

   # Build: Create the Docker image and push to the container registry
   build:
     services:
       - name: docker:dind
         alias: dind
     image: docker:20.10.16
     stage: build
     script:
       - docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY
       - docker pull $CI_REGISTRY_IMAGE:latest || true
       - docker build --tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA --tag $CI_REGISTRY_IMAGE:latest .
       - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
       - docker push $CI_REGISTRY_IMAGE:latest
   ```

<a id="define-the-dast-job"></a>

## 定义 DAST 作业

现在您已经配置好构建作业，接下来将配置 DAST 作业。

此配置使用 services 功能，使应用程序容器与 DAST 作业并行运行。`dast` 作业可通过 URL `http://yourapp:3000` 访问该应用程序。

要配置 DAST 作业：

- 在 `.gitlab-ci.yml` 文件末尾添加以下内容：

  ```yaml
  # DAST: Scan the application running in a Docker container
  dast:
    services:
      - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
        alias: yourapp
    variables:
      DAST_TARGET_URL: http://yourapp:3000
  ```

<a id="configure-passive-and-active-scanning"></a>

## 配置被动扫描和主动扫描

DAST 支持两种扫描模式，可在安全覆盖范围与扫描时间之间取得平衡。被动扫描可提供快速反馈。主动扫描可发现仅在应用程序接受精心构造的请求测试时才会出现的漏洞，从而在代码进入生产环境之前提供更全面的安全验证。

被动扫描（默认，约 2-5 分钟）：

- 分析应用程序响应，而不发送可能有害的请求
- 检查 HTTP 请求头、Cookie、响应内容和 SSL/TLS 配置
- 可在任何环境中安全运行
- 适合在 CI/CD 流水线中快速获得反馈

主动扫描（约 10-30 分钟，具体取决于应用程序规模）：

- 发送旨在触发漏洞的精心构造的请求
- 测试注入缺陷、身份验证问题和业务逻辑漏洞
- 更全面，但速度更慢
- 最适合在合并到主分支之前对功能分支使用

> [!note]
> 请勿对生产服务器运行 DAST 扫描。它不仅可能执行用户可以执行的任何操作，例如选择按钮或提交表单，还可能触发缺陷，导致生产数据被修改或丢失。请仅对测试服务器运行 DAST 扫描。

要配置被动扫描和主动扫描：

- 在 `.gitlab-ci.yml` 文件末尾添加以下内容：

  ```yaml
    rules:
      - if: $CI_COMMIT_REF_NAME == $CI_DEFAULT_BRANCH
        variables:
          DAST_FULL_SCAN: "false"  # Passive scan only for main branch (~2-5 mins)
      - if: $CI_COMMIT_REF_NAME != $CI_DEFAULT_BRANCH
        variables:
          DAST_FULL_SCAN: "true"   # Active scan for feature branches (~10-30 mins)
  ```

<a id="verify-your-setup"></a>

## 验证您的设置

验证 DAST 能否成功发现正在运行的应用程序中的漏洞。

1. 在流水线编辑器中，选择**提交更改**并提交到 `gitlab` 分支。

   流水线会立即启动。
1. 转到**构建** > **流水线**，并验证您最新的流水线已成功完成。

   预期时间线：
   - 构建阶段：2-3 分钟（构建 Docker 镜像）
   - DAST 阶段：2-5 分钟（被动扫描）

1. 流水线成功完成后，转到**安全** > **漏洞报告**。
1. 查看这些漏洞。有关如何处理每个漏洞的帮助，请参阅
   [如何修复漏洞](../../remediate/_index.md)。

> [!note]
> Tanuki Shop 应用程序出于演示目的而有意包含漏洞。您应该会看到与安全策略、个人可识别信息（PII）泄露以及其他常见 Web 漏洞相关的发现结果。

<a id="next-steps"></a>

## 后续步骤

完成本教程后，您可以：

- 根据您的具体需求配置[高级 DAST 设置](configuration/customize_settings.md)。
- 设置[按需 DAST 扫描](../on-demand_scan.md)以进行临时测试。
- 将 DAST 与[漏洞管理工作流](../../vulnerabilities/_index.md)集成。
- 浏览 [DAST 演示代码仓库](https://gitlab.com/gitlab-org/security-products/demos/dast/)以获取更多示例。

<a id="troubleshooting"></a>

## 故障排除

<a id="build-job-fails-with-authentication-errors"></a>

### 构建作业因身份验证错误而失败

当容器镜像仓库凭据不可用时，会发生身份验证错误。

要解决此问题：

1. 验证容器镜像仓库已启用：
   1. 转到**设置** > **通用**。
   1. 展开**可见性、项目功能、权限**。
   1. 确保**容器镜像仓库**开关已打开。

1. 检查您的项目是否具有有效的 CI/CD 令牌。极狐GitLab 会自动提供 `$CI_REGISTRY_USER` 和 `$CI_REGISTRY_PASSWORD`。

<a id="dast-job-completes-but-no-vulnerabilities-are-found"></a>

### DAST 作业已完成但未发现任何漏洞

当 DAST 无法访问应用程序，或应用程序不存在漏洞时，会出现此问题。

要解决此问题：

1. 验证应用程序正在运行：

   ```shell
   curl "http://yourapp:3000"
   ```

1. 检查 DAST 作业日志中是否有与连接相关的错误。
1. 验证 `DAST_TARGET_URL` 变量设置正确（应为 `http://yourapp:3000`）。
1. Tanuki Shop 应用程序应该存在漏洞。如果未发现任何漏洞，请检查您使用的是否是正确的 forked 代码仓库。
