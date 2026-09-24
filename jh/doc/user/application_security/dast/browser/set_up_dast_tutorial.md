---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: '教程：设置 DAST 以扫描您的 Web 应用'
---

<!-- vale gitlab_base.FutureTense = NO -->

了解如何将动态应用程序安全测试（DAST）集成到您的 CI/CD 流水线中。

静态分析发现源代码中的漏洞。DAST 则识别仅在您的应用在真实环境中运行并与服务和用户工作流交互时才会出现的运行时安全问题。通过极狐GitLab 集成的 DAST 解决方案，您可以设置极狐GitLab DAST，在每次将代码部署到测试环境时自动检查这些问题。

在本教程中，您将学习如何：

1. [设置 Tanuki Shop 应用](#set-up-the-tanuki-shop-application)
1. [定义构建作业](#define-the-build-job)
1. [定义 DAST 作业](#define-the-dast-job)
1. [配置被动和主动扫描](#configure-passive-and-active-scanning)
1. [验证您的设置](#verify-your-setup)

> [!note]
> 本教程中的 Tanuki Shop 应用无需认证。如果您的应用需要登录，请参见 [DAST 认证](configuration/authentication.md)。

## 准备工作

- 极狐GitLab 旗舰版订阅。
- 对您的项目具有维护者角色。

<a id="set-up-the-tanuki-shop-application"></a>

## 设置 Tanuki Shop 应用

您将首先派生 Tanuki Shop。

1. 前往 [Tanuki Shop 仓库](https://jihulab.com/gitlab-cn/tutorials/security-and-governance/tanuki-shop)。
1. 在右上角，选择 **派生**。
1. 选择您的命名空间（个人或群组）并选择 **派生项目**。

   派生的仓库包含本教程所需的所有文件，包括应用代码和初始 CI/CD 配置。我们将在后续步骤中修改此配置。

1. 前往 **设置** > **通用**。
1. 展开 **可见性，项目功能，权限**。
1. 确保 **容器镜像仓库** 开关已开启。
1. 验证容器镜像仓库是否正常工作：
   1. 前往 **部署** > **容器镜像仓库**。
   1. 您应该会看到一个空仓库。如果看到错误，请检查您的项目权限。

   > [!note]
   > 容器镜像仓库存储您流水线中构建的 Docker 镜像。如果此步骤失败，后续的构建作业也将失败。

<a id="define-the-build-job"></a>

## 定义构建作业

现在您将配置构建作业，以创建包含您应用的 Docker 镜像并将其推送到容器镜像仓库。

1. 在您的项目中，编辑 `.gitlab-ci.yml` 文件。
1. 将现有内容替换为以下 CI/CD 配置：

   ```yaml
   stages:
     - build
     - dast

   include:
     - template: Security/DAST.gitlab-ci.yml

   # 构建：创建 Docker 镜像并推送到容器镜像仓库
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

既然您已经配置了构建作业，现在来配置 DAST 作业。

此配置使用 services 功能，使应用容器与 DAST 作业并行运行。`dast` 作业可通过 URL `http://yourapp:3000` 访问应用。

要配置 DAST 作业：

- 在 `.gitlab-ci.yml` 文件末尾添加以下内容：

  ```yaml
  # DAST：扫描在 Docker 容器中运行的应用
  dast:
    services:
      - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
        alias: yourapp
    variables:
      DAST_TARGET_URL: http://yourapp:3000
  ```

<a id="configure-passive-and-active-scanning"></a>

## 配置被动和主动扫描

DAST 支持两种扫描模式，以在安全覆盖范围和扫描时间之间取得平衡。被动扫描提供快速反馈。主动扫描发现仅在通过构造的请求测试应用时才会出现的漏洞，在代码进入生产环境前提供更彻底的安全验证。

被动扫描（默认，约 2-5 分钟）：

- 分析应用响应，不发送可能有害的请求
- 检查 HTTP 标头、Cookie、响应内容以及 SSL/TLS 配置
- 可在任何环境安全运行
- 适合在 CI/CD 流水线中快速获得反馈

主动扫描（约 10-30 分钟，取决于应用大小）：

- 发送旨在触发漏洞的构造请求
- 测试注入缺陷、认证问题和业务逻辑漏洞
- 更彻底但速度较慢
- 最适合在功能分支合并到主分支前运行

> [!note]
> 不要对生产服务器运行 DAST 扫描。它不仅会执行用户可能执行的任何功能（例如点击按钮或提交表单），还可能触发错误，导致生产数据被修改或丢失。请仅针对测试服务器运行 DAST 扫描。

要配置被动和主动扫描：

- 在 `.gitlab-ci.yml` 文件末尾添加以下内容：

  ```yaml
    rules:
      - if: $CI_COMMIT_REF_NAME == $CI_DEFAULT_BRANCH
        variables:
          DAST_FULL_SCAN: "false"  # 仅对主分支进行被动扫描（约 2-5 分钟）
      - if: $CI_COMMIT_REF_NAME != $CI_DEFAULT_BRANCH
        variables:
          DAST_FULL_SCAN: "true"   # 对功能分支进行主动扫描（约 10-30 分钟）
  ```

<a id="verify-your-setup"></a>

## 验证您的设置

验证 DAST 能否成功发现正在运行的应用中的漏洞。

1. 在流水线编辑器中，选择 **提交更改** 并提交到 `gitlab` 分支。

   一条流水线会立即启动。
1. 前往 **构建** > **流水线**，验证您最新的流水线已成功完成。

   预期时间线：
   - 构建阶段：2-3 分钟（构建 Docker 镜像）
   - DAST 阶段：2-5 分钟（被动扫描）

1. 流水线成功完成后，前往 **安全** > **漏洞报告**。
1. 审查这些漏洞。关于如何处理每个漏洞，请参见[如何修复漏洞](../../remediate/_index.md)。

> [!note]
> 出于演示目的，Tanuki Shop 应用特意留有漏洞。您应该会看到与安全策略、个人身份信息 (PII) 暴露以及其他常见 Web 漏洞相关的发现项。

## 后续步骤

完成本教程后，您可以：

- 为您的特定需求配置[高级 DAST 设置](configuration/customize_settings.md)。
- 为临时测试设置[按需 DAST 扫描](../on-demand_scan.md)。
- 将 DAST 与[漏洞管理工作流](../../vulnerabilities/_index.md)集成。
- 探索 [DAST 演示仓库](https://gitlab.com/gitlab-org/security-products/demos/dast/)以获取更多示例。

## 故障排除

### 构建作业因认证错误而失败

当容器镜像仓库凭据不可用时，会发生认证错误。

要解决此问题：

1. 验证容器镜像仓库是否已启用：
   1. 前往 **设置** > **通用**。
   1. 展开 **可见性，项目功能，权限**。
   1. 确保 **容器镜像仓库** 开关已开启。

1. 检查您的项目是否有有效的 CI/CD 令牌。极狐GitLab 会自动提供 `$CI_REGISTRY_USER` 和 `$CI_REGISTRY_PASSWORD`。

### DAST 作业完成但未发现漏洞

当 DAST 无法访问应用，或应用没有漏洞时，会发生此问题。

要解决此问题：

1. 验证应用是否正在运行：

   ```shell
   curl "http://yourapp:3000"
   ```

1. 检查 DAST 作业日志中是否有与连接性相关的错误。
1. 验证 `DAST_TARGET_URL` 变量是否设置正确（应为 `http://yourapp:3000`）。
1. Tanuki Shop 应用本应有漏洞。如果未发现任何漏洞，请检查您是否使用了正确的派生仓库。