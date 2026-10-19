---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用 CI/CD 自动构建并发布软件包'
---

您可以使用 CI/CD 构建并发布您的 PyPI 软件包。自动构建有助于让您的软件包保持最新，并可供他人使用。

在本教程中，您将创建一个新的 CI/CD 配置，用于构建、测试并发布一个示例 PyPI 软件包。完成之后，您应该能更好地理解流水线中每个步骤的工作方式，并能自如地将 CI/CD 集成到您自己的软件包仓库工作流中。

要使用 CI/CD 自动构建并发布软件包：

1. [创建 `.gitlab-ci.yml` 文件](#create-a-gitlab-ciyml-file)
   1. 可选。[不使用 CI/CD 变量进行身份验证](#authenticate-without-a-cicd-variable)
1. [检查流水线](#check-the-pipeline)

<a id="before-you-begin"></a>

## 开始之前

在完成本教程之前，请确保您具备以下条件：

- 一个测试项目。您可以使用任何您喜欢的 Python 项目，但建议专门为本教程创建一个项目。
- 熟悉 PyPI 和极狐GitLab 软件包仓库。

<a id="create-a-gitlab-ciyml-file"></a>

## 创建 `.gitlab-ci.yml` 文件

每个 CI/CD 配置都需要一个 `.gitlab-ci.yml`。该文件定义 CI/CD 流水线中的每个阶段。在本例中，这些阶段是：

- `build` - 构建 PyPI 软件包。
- `test` - 使用测试框架 `pytest` 验证软件包。
- `publish` - 将软件包发布到软件包仓库。

要创建 `.gitlab-ci.yml` 文件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**代码** > **代码仓库**。
1. 在文件列表上方，选择您要提交到的分支。
1. 在右上角，选择**创建新的** ({{< icon name="plus" >}})。
1. 将文件命名为 `.gitlab-ci.yml`。在较大的窗口中，粘贴以下示例配置：

   ```yaml
   default:
     image: python:3.9
     cache:
       paths:
         - .pip-cache/
     before_script:
       - python --version
       - pip install --upgrade pip
       - pip install build twine

   stages:
     - build
     - test
     - publish

   variables:
     PIP_CACHE_DIR: "$CI_PROJECT_DIR/.pip-cache"

   build:
     stage: build
     script:
       - python -m build
     artifacts:
       paths:
         - dist/

   test:
     stage: test
     script:
       - pip install pytest
       - pip install dist/*.whl
       - pytest

   publish:
     stage: publish
     script:
       - TWINE_PASSWORD=${CI_JOB_TOKEN} TWINE_USERNAME=gitlab-ci-token python -m twine upload --repository-url ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/pypi dist/*
     rules:
       - if: $CI_COMMIT_TAG
   ```

1. 选择**提交更改**。

以下是所提交代码的简要说明：

- `image` - 指定要使用的 Docker 镜像。
- `stages` - 定义此流水线的三个阶段。
- `variables` 和 `cache` - 配置 PIP 以使用缓存。这可以让后续流水线运行得稍快一些。
- `before_script` - 安装完成这三个阶段所需的工具。
- `build` - 构建软件包并将结果存储为产物。
- `test` - 安装并运行 pytest 以验证软件包。
- `publish` - 仅在推送新标签时，使用 twine 将软件包上传到软件包仓库。
  使用 `CI_JOB_TOKEN` 向软件包仓库进行身份验证。

<a id="authenticate-without-a-cicd-variable"></a>

### 不使用 CI/CD 变量进行身份验证

要向软件包仓库进行身份验证，示例配置使用 `CI_JOB_TOKEN`，该令牌由极狐GitLab CI/CD 自动提供。要发布到外部 PyPI 仓库，您必须在项目设置中配置一个密钥变量：

1. 在左侧边栏中，选择**设置** > **CI/CD** > **变量**。
1. 添加一个名为 `PYPI_TOKEN`的新变量，其值为您的 PyPI API 令牌。
1. 在您的 `.gitlab-ci.yml` 文件中，将 `publish:script` 替换为：

   ```yaml
   script:
   - TWINE_PASSWORD=${PYPI_TOKEN} TWINE_USERNAME=__token__ python -m twine upload dist/*
   ```

<a id="check-the-pipeline"></a>

## 检查流水线

提交更改后，您应检查以确保流水线正确运行：

- 在左侧边栏中，选择**构建** > **流水线**。最近的流水线应包含前面定义的三个阶段。

如果流水线尚未运行，请手动运行一条新的流水线，并确保其成功完成。

<a id="best-practices"></a>

## 最佳实践

为确保软件包的安全性和稳定性，您应遵循发布到软件包仓库的最佳实践。您添加的配置：

- 实现缓存以加速您的流水线。
- 使用产物在阶段之间传递构建好的软件包。
- 包含一个测试阶段，在发布前验证软件包。
- 对身份验证令牌等敏感信息使用极狐GitLab CI/CD 变量。
- 仅在推送新的 Git 标签时发布。这可确保只发布版本号正确的版本。

恭喜！您已成功使用极狐GitLab CI/CD 构建、测试并发布了一个软件包。您应该能够使用类似的配置来简化您自己的开发流程。
