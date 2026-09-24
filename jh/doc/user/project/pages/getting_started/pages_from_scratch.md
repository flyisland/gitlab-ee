---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：从零开始创建 GitLab Pages 网站'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本教程向您展示如何使用 [Jekyll](https://jekyllrb.com/) 静态站点生成器（SSG）从零开始创建 Pages 站点。您从一个空白项目开始，创建自己的 CI/CD 配置文件，该文件为 [runner](https://gitlab.cn/docs/runner/) 提供指令。当您的 CI/CD [流水线](../../../../ci/pipelines/_index.md) 运行时，就会创建 Pages 站点。

此示例使用 Jekyll，但其他 SSG 的步骤类似。您无需熟悉 Jekyll 或 SSG 即可完成本教程。

> [!note]
> 要使用纯 HTML 创建 Pages 站点，请参阅[从 CI/CD 模板创建 GitLab Pages 网站](pages_ci_cd_template.md)教程。有关可用模板的列表，请参阅[项目模板](pages_new_project_template.md#project-templates)。

要创建 GitLab Pages 网站：

- [步骤 1：创建项目文件](#create-the-project-files)
- [步骤 2：选择 Docker 镜像](#choose-a-docker-image)
- [步骤 3：安装 Jekyll](#install-jekyll)
- [步骤 4：为输出指定 `public` 目录](#specify-the-public-directory-for-output)
- [步骤 5：为产物指定 `public` 目录](#specify-the-public-directory-for-artifacts)
- [步骤 6：部署并查看您的网站](#deploy-and-view-your-website)

<a id="prerequisites"></a>

## 先决条件

您必须在极狐GitLab 中拥有一个[空白项目](../../_index.md#create-a-blank-project)。

<a id="create-the-project-files"></a>

## 创建项目文件

在根（顶层）目录中创建三个文件：

- `.gitlab-ci.yml`：一个 YAML 文件，包含您要运行的命令。目前，请将该文件的内容留空。

- `index.html`：一个非空的 HTML 文件，您可以填充任何您想要的 HTML 内容，例如：

  ```html
  <html>
  <head>
    <title>Home</title>
  </head>
  <body>
    <h1>Hello World!</h1>
  </body>
  </html>
  ```

- [`Gemfile`](https://bundler.io/gemfile.html)：一个描述 Ruby 程序依赖关系的文件。

  使用以下内容填充它：

  ```ruby
  source "https://rubygems.org"

  gem "jekyll"
  ```

<a id="choose-a-docker-image"></a>

## 选择 Docker 镜像

在此示例中，runner 使用 [Docker 镜像](../../../../ci/docker/using_docker_images.md) 来运行脚本并部署站点。

这个特定的 Ruby 镜像在 [DockerHub](https://hub.docker.com/_/ruby) 上维护。

通过将以下 CI/CD 配置添加到 `.gitlab-ci.yml` 文件开头，为您的流水线添加默认镜像：

```yaml
default:
  image: ruby:3.2
```

如果您的 SSG 需要 [NodeJS](https://nodejs.org/) 来构建，您必须指定一个文件系统中包含 NodeJS 的镜像。例如，对于 [Hexo](https://gitlab.com/pages/hexo) 站点，您可以使用 `image: node:12.17.0`。

<a id="install-jekyll"></a>

## 安装 Jekyll

要在本地运行 [Jekyll](https://jekyllrb.com/)，您必须安装它：

1. 打开您的终端。
1. 通过运行 `gem install bundler` 安装 [Bundler](https://bundler.io/)。
1. 通过运行 `bundle install` 创建 `Gemfile.lock`。
1. 通过运行 `bundle exec jekyll build` 安装 Jekyll。

要在您的项目中运行 Jekyll，请编辑 `.gitlab-ci.yml` 文件并添加安装命令：

```yaml
script:
  - gem install bundler
  - bundle install
  - bundle exec jekyll build
```

此外，在 `.gitlab-ci.yml` 文件中，每个 `script` 都由一个 `job` 组织。一个 `job` 包含您要应用于该特定任务的脚本和设置。

```yaml
job:
  script:
    - gem install bundler
    - bundle install
    - bundle exec jekyll build
```

对于 GitLab Pages，此 `job` 必须包含一个名为 `pages` 的属性。此设置告诉 runner 您希望该作业使用 GitLab Pages 部署您的网站：

```yaml
create-pages:
  script:
    - gem install bundler
    - bundle install
    - bundle exec jekyll build
  pages: true  # specifies that this is a Pages job
```

此页面中的示例使用[用户定义的作业名称](../_index.md#user-defined-job-names)。

<a id="specify-the-public-directory-for-output"></a>

## 为输出指定 `public` 目录

Jekyll 需要知道在哪里生成其输出。GitLab Pages 只考虑名为 `public` 的目录中的文件。

Jekyll 使用目标标志（`-d`）来为构建的网站指定输出目录。将目标添加到您的 `.gitlab-ci.yml` 文件中：

```yaml
create-pages:
  script:
    - gem install bundler
    - bundle install
    - bundle exec jekyll build -d public
  pages: true  # specifies that this is a Pages job
```

<a id="specify-the-public-directory-for-artifacts"></a>

## 为产物指定 `public` 目录

现在 Jekyll 已将文件输出到 `public` 目录，runner 需要知道从哪里获取它们。在极狐GitLab 17.10 及更高版本中，仅对于 Pages 作业，当未明确指定 [`pages.publish`](../../../../ci/yaml/_index.md#pagespublish) 路径时，`public` 目录会自动附加到 [`artifacts:paths`](../../../../ci/yaml/_index.md#artifactspaths)：

```yaml
create-pages:
  script:
    - gem install bundler
    - bundle install
    - bundle exec jekyll build -d public
  pages: true  # specifies that this is a Pages job and publishes the default public directory
```

您的 `.gitlab-ci.yml` 文件现在应该如下所示：

```yaml
default:
  image: ruby:3.2

create-pages:
  script:
    - gem install bundler
    - bundle install
    - bundle exec jekyll build -d public
  pages: true  # specifies that this is a Pages job and publishes the default public directory
```

<a id="deploy-and-view-your-website"></a>

## 部署并查看您的网站

完成上述步骤后，部署您的网站：

1. 保存并提交 `.gitlab-ci.yml` 文件。
1. 转到 **构建** > **流水线** 以查看流水线。
1. 当流水线完成后，转到 **部署** > **Pages** 以找到您的 Pages 网站的链接。

当此 `pages` 作业成功完成时，一个特殊的 `pages:deploy` 作业会出现在流水线视图中。它为 GitLab Pages 守护进程准备网站内容。极狐GitLab 在后台运行它，不使用 runner。

<a id="other-options-for-your-cicd-file"></a>

## CI/CD 文件的其他选项

如果您想执行更高级的任务，可以使用[其他 CI/CD YAML 关键字](../../../../ci/yaml/_index.md)更新您的 `.gitlab-ci.yml` 文件。您可以使用极狐GitLab 附带的 [CI Lint](../../../../ci/yaml/lint.md) 工具验证您的 `.gitlab-ci.yml` 文件。

以下部分展示了您可以添加到 CI/CD 文件中的其他选项。

<a id="deploy-specific-branches-to-a-pages-site"></a>

### 将特定分支部署到 Pages 站点

您可能只想从特定分支部署到 Pages 站点。

首先，添加一个 `workflow` 部分，以强制流水线仅在更改推送到分支时运行：

```yaml
default:
  image: ruby:3.2

workflow:
  rules:
    - if: $CI_COMMIT_BRANCH

create-pages:
  script:
    - gem install bundler
    - bundle install
    - bundle exec jekyll build -d public
  pages: true  # specifies that this is a Pages job and publishes the default public directory
```

然后配置流水线，使其仅针对[默认分支](../../repository/branches/default.md)（此处为 `main`）运行该作业。

```yaml
default:
  image: ruby:3.2

workflow:
  rules:
    - if: $CI_COMMIT_BRANCH

create-pages:
  script:
    - gem install bundler
    - bundle install
    - bundle exec jekyll build -d public
  pages: true  # specifies that this is a Pages job and publishes the default public directory
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```

<a id="specify-a-stage-to-deploy"></a>

### 指定部署阶段

极狐GitLab CI/CD 的三个默认阶段是构建、测试和部署。

如果您想在部署到生产环境之前测试您的脚本并检查构建的站点，您可以像推送到[默认分支](../../repository/branches/default.md)（此处为 `main`）时一样运行测试。

要为您的作业指定运行阶段，请在 CI 文件中添加一行 `stage`：

```yaml
default:
  image: ruby:3.2

workflow:
  rules:
    - if: $CI_COMMIT_BRANCH

create-pages:
  stage: deploy
  script:
    - gem install bundler
    - bundle install
    - bundle exec jekyll build -d public
  pages: true  # specifies that this is a Pages job and publishes the default public directory
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
  environment: production
```

现在向 CI 文件添加另一个作业，告诉它测试对除 `main` 分支之外的所有分支的每次推送：

```yaml
default:
  image: ruby:3.2

workflow:
  rules:
    - if: $CI_COMMIT_BRANCH

create-pages:
  stage: deploy
  script:
    - gem install bundler
    - bundle install
    - bundle exec jekyll build -d public
  pages: true  # specifies that this is a Pages job and publishes the default public directory
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
  environment: production

test:
  stage: test
  script:
    - gem install bundler
    - bundle install
    - bundle exec jekyll build -d test
  artifacts:
    paths:
      - test
  rules:
    - if: $CI_COMMIT_BRANCH != "main"
```

当 `test` 作业在 `test` 阶段运行时，Jekyll 会在名为 `test` 的目录中构建站点。该作业影响除 `main` 之外的所有分支。

当您将阶段应用于不同的作业时，同一阶段中的每个作业都会并行构建。如果您的 Web 应用程序在部署前需要多次测试，您可以同时运行所有测试。

<a id="remove-duplicate-commands"></a>

### 删除重复命令

为避免在每个作业中重复相同的 `before_script` 命令，您可以将它们添加到默认部分。

在示例中，`gem install bundler` 和 `bundle install` 为两个作业（`create-pages` 和 `test`）都运行了。

将这些命令移动到 `default` 部分：

```yaml
default:
  image: ruby:3.2
  before_script:
    - gem install bundler
    - bundle install

workflow:
  rules:
    - if: $CI_COMMIT_BRANCH

create-pages:
  stage: deploy
  script:
    - bundle exec jekyll build -d public
  pages: true  # specifies that this is a Pages job and publishes the default public directory
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
  environment: production

test:
  stage: test
  script:
    - bundle exec jekyll build -d test
  artifacts:
    paths:
      - test
  rules:
    - if: $CI_COMMIT_BRANCH != "main"
```

<a id="build-faster-with-cached-dependencies"></a>

### 使用缓存依赖项加快构建速度

为了加快构建速度，您可以使用 `cache` 参数缓存项目依赖项的安装文件。

此示例在您运行 `bundle install` 时将 Jekyll 依赖项缓存到 `vendor` 目录中：

```yaml
default:
  image: ruby:3.2
  before_script:
    - gem install bundler
    - bundle install --path vendor
  cache:
    paths:
      - vendor/

workflow:
  rules:
    - if: $CI_COMMIT_BRANCH


create-pages:
  stage: deploy
  script:
    - bundle exec jekyll build -d public
  pages: true  # specifies that this is a Pages job and publishes the default public directory
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
  environment: production

test:
  stage: test
  script:
    - bundle exec jekyll build -d test
  artifacts:
    paths:
      - test
  rules:
    - if: $CI_COMMIT_BRANCH != "main"
```

在这种情况下，您需要将 `/vendor` 目录从 Jekyll 构建的文件夹列表中排除。否则，Jekyll 会尝试将目录内容与站点一起构建。

在根目录中，创建一个名为 `_config.yml` 的文件并添加以下内容：

```yaml
exclude:
  - vendor
```

现在，极狐GitLab CI/CD 不仅构建网站，还：

- 向功能分支推送时进行**持续测试**。
- **缓存**使用 Bundler 安装的依赖项。
- **持续部署**每次推送到 `main` 分支。

要查看为站点创建的 HTML 和其他资源，请[下载作业产物](../../../../ci/jobs/job_artifacts.md#download-job-artifacts)。

此页面中的示例使用[用户定义的作业名称](../_index.md#user-defined-job-names)。
