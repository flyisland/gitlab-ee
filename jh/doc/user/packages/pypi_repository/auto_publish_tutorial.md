---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用 CI/CD 自动构建并发布软件包'
---

您可以使用 CI/CD 构建并发布您的 PyPI 软件包。自动构建可以帮助您保持软件包及时更新并可供他人使用。

在本教程中，您将创建一个新的 CI/CD 配置来构建、测试并发布一个示例 PyPI 软件包。完成后，您将更好地了解流水线中每个步骤的工作原理，并能够轻松地将 CI/CD 集成到您自己的软件包仓库工作流程中。

要使用 CI/CD 自动构建并发布软件包：

1. [创建 `.gitlab-ci.yml` 文件](#create-a-gitlab-ciyml-file)
   1. 可选。[无需 CI/CD 变量进行身份验证](#authenticate-without-a-cicd-variable)
1. [检查流水线](#check-the-pipeline)

## 准备工作

在开始本教程之前，请确保具备以下条件：

- 一个测试项目。您可以使用任何喜欢的 Python 项目，但建议专门为本教程创建一个项目。
- 熟悉 PyPI 和极狐GitLab 软件包仓库。

## 创建 `.gitlab-ci.yml` 文件

每个 CI/CD 配置都需要一个 `.gitlab-ci.yml` 文件。该文件定义了 CI/CD 流水线中的每个阶段。在本例中，阶段包括：

- `build` - 构建 PyPI 软件包。
- `test` - 使用测试框架 `pytest` 验证软件包。
- `publish` - 将软件包发布到软件包仓库。

要创建 `.gitlab-ci.yml` 文件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **代码** > **仓库**。
1. 在文件列表上方，选择要提交到的分支。
1. 在右上角，选择 **新建** ({{< icon name="plus" >}})。
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

1. 选择 **提交更改**。

以下是所提交代码的简要说明：

- `image` - 指定要使用的 Docker 镜像。
- `stages` - 定义此流水线的三个阶段。
- `variables` 和 `cache` - 配置 PIP 使用缓存，这可以使后续流水线运行得更快一些。
- `before_script` - 安装完成三个阶段所需的工具。
- `build` - 构建软件包并将结果存储为产物。
- `test` - 安装并运行 pytest 以验证软件包。
- `publish` - 仅当推送新标签时，使用 twine 将软件包上传到软件包仓库。使用 `CI_JOB_TOKEN` 向软件包仓库进行身份验证。

### 无需 CI/CD 变量进行身份验证

为了向软件包仓库进行身份验证，示例配置使用了 `CI_JOB_TOKEN`，该令牌由极狐GitLab CI/CD 自动提供。要发布到外部 PyPI 仓库，您必须在项目设置中配置一个密钥变量：

1. 在左侧边栏中，选择 **设置** > **CI/CD** > **变量**。
1. 添加一个名为 `PYPI_TOKEN` 的新变量，并将其值设为您的 PyPI API 令牌。
1. 在您的 `.gitlab-ci.yml` 文件中，将 `publish:script` 替换为：

   ```yaml
   script:
   - TWINE_PASSWORD=${PYPI_TOKEN} TWINE_USERNAME=__token__ python -m twine upload dist/*
   ```

## 检查流水线

提交更改后，您应该检查以确保流水线正确运行：

- 在左侧边栏中，选择 **构建** > **流水线**。最新的流水线应包含之前定义的三个阶段。

如果流水线未运行，请手动运行一个新的流水线，并确保其成功完成。

## 最佳实践

为确保软件包的安全性和稳定性，您应遵循向软件包仓库发布的最佳实践。您添加的配置：

- 实现了缓存以加快流水线速度。
- 使用产物在各阶段之间传递构建好的软件包。
- 包含一个测试阶段，在发布前验证软件包。
- 使用极狐GitLab CI/CD 变量处理身份验证令牌等敏感信息。
- 仅在推送新的 Git 标签时发布。这确保了只有版本正确的发布包才会被发布。

恭喜！您已成功使用极狐GitLab CI/CD 构建、测试并发布了软件包。您现在应该能够使用类似的配置来简化自己的开发流程。