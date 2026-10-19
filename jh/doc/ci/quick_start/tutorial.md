---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：创建复杂的流水线'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本教程将引导您通过一系列小步骤，逐步配置一个越来越复杂的 CI/CD 流水线。该流水线始终完全可用，但每完成一步都会增加更多功能。目标是构建、测试并部署一个文档站点。

完成本教程后，您将在 JihuLab.com 上拥有一个新项目，以及一个使用 [Docusaurus](https://docusaurus.io/)的可正常运行的文档站点。

要完成本教程：

1. 创建一个用于存放 Docusaurus 文件的项目
1. 创建初始流水线配置文件
1. 添加一个用于构建站点的作业
1. 添加一个用于部署站点的作业
1. 添加测试作业
1. 开始使用合并请求流水线
1. 减少重复配置

<a id="prerequisites"></a>

## 先决条件

- 您需要一个 JihuLab.com 账号。
- 您应熟悉 Git。
- 您的本地计算机上必须安装 Node.js。例如，在 macOS 上，您可以使用 `brew install node`
  [安装 node](https://formulae.brew.sh/formula/node)。

<a id="create-a-project-to-hold-the-docusaurus-files"></a>

## 创建一个用于存放 Docusaurus 文件的项目

在添加流水线配置之前，您必须先在 JihuLab.com 上设置一个 Docusaurus 项目：

1. 在您的用户名下（而不是群组下）创建一个新项目：
   1. 在右上角，选择**创建新的** ({{< icon name="plus" >}}) 和**新建项目/代码仓库**。
   1. 选择**创建空白项目**。
   1. 输入项目详情：
      - 在**项目名称**字段中，输入您的项目名称，例如 `My Pipeline Tutorial Project`。
      - 选择**使用 README 初始化代码仓库**。
   1. 选择**创建项目**。
1. 在项目概览页面的右上角，选择**代码**
   以查找项目的克隆路径。复制 SSH 或 HTTP 路径，并使用该路径
   将项目克隆到本地。

   例如，要通过 SSH 克隆到您计算机上的 `pipeline-tutorial` 目录：

   ```shell
   git clone git@gitlab.com:my-username/my-pipeline-tutorial-project.git pipeline-tutorial
   ```

1. 切换到项目目录，然后生成一个新的 Docusaurus 站点：

   ```shell
   cd pipeline-tutorial
   npm init docusaurus
   ```

   Docusaurus 初始化向导会向您询问有关站点的问题。
   请使用所有默认选项。

1. 初始化向导会将站点设置在 `website/` 中，但站点应位于
   项目的根目录。将文件移到根目录并删除旧目录：

   ```shell
   mv website/* .
   rm -r website
   ```

1. 使用您的极狐GitLab 项目详情更新 Docusaurus 配置文件。
   在 `docusaurus.config.js`中：

   - 将 `url:` 设置为以下格式的路径：`https://<my-username>.gitlab.io/`。
   - 将 `baseUrl:` 设置为您的项目名称，例如 `/my-pipeline-tutorial-project/`。

1. 提交更改，并将它们推送到极狐GitLab：

   ```shell
   git add .
   git commit -m "Add simple generated Docusaurus site"
   git push origin
   ```

<a id="create-the-initial-cicd-configuration-file"></a>

## 创建初始 CI/CD 配置文件

从尽可能简单的流水线配置文件开始，以确保项目中已启用 CI/CD，并且有可用的 runner 来运行作业。

本步骤介绍：

- [作业](../jobs/_index.md)：作业是流水线中运行您的命令的自包含部分。
  作业在 [runner](../runners/_index.md) 上运行，与极狐GitLab 实例分离。
- [`script`](../yaml/_index.md#script)：作业配置的这一部分
  用于定义作业的命令。如果有多个命令（在数组中），
  它们会按顺序运行。每个命令的执行方式就像作为 CLI 命令运行一样。
  默认情况下，如果某个命令失败或返回错误，该作业会被标记为失败，
  并且不再运行更多命令。

在本步骤中，在项目根目录创建一个包含以下配置的 `.gitlab-ci.yml` 文件：

```yaml
test-job:
  script:
    - echo "This is my first job!"
    - date
```

提交并将此更改推送到极狐GitLab，然后：

1. 转到**构建** > **流水线**，并确保极狐GitLab 中运行了一个包含此单个作业的流水线。
1. 选择该流水线，然后选择该作业以查看作业日志，并看到 `This is my first job!` 消息
   以及其后的日期。

现在您的项目中有了 `.gitlab-ci.yml` 文件，您可以在以后使用[流水线编辑器](../pipeline_editor/_index.md)对流水线配置进行所有更改。

<a id="add-a-job-to-build-the-site"></a>

## 添加一个用于构建站点的作业

CI/CD 流水线的一个常见任务是构建项目中的代码，然后将其部署。首先添加一个用于构建站点的作业。

本步骤介绍：

- [`image`](../yaml/_index.md#image)：告诉 runner 使用哪个 Docker
  容器来运行作业。runner 会：
  1. 下载容器镜像并启动它。
  1. 将您的极狐GitLab 项目克隆到正在运行的容器中。
  1. 逐个运行 `script` 命令。
- [`artifacts`](../yaml/_index.md#artifacts)：作业是自包含的，彼此之间不共享
  资源。如果您希望在一个作业中生成的文件用于
  另一个作业，必须先将其保存为产物。之后，后续作业可以检索这些
  产物并使用生成的文件。

在本步骤中，将 `test-job` 替换为 `build-job`：

- 使用 `image` 将作业配置为使用最新的 `node` 镜像运行。Docusaurus
  是一个 Node.js 项目，`node` 镜像内置了所需的 `npm` 命令。
- 运行 `npm install` 将 Docusaurus 安装到正在运行的 `node` 容器中，然后运行
  `npm run build` 来构建站点。
- Docusaurus 将构建好的站点保存在 `build/` 中，因此使用 `artifacts` 保存这些文件。

```yaml
build-job:
  image: node
  script:
    - npm install
    - npm run build
  artifacts:
    paths:
      - "build/"
```

使用流水线编辑器将此流水线配置提交到默认分支，并检查作业日志。您可以：

- 看到 `npm` 命令运行并构建站点。
- 验证产物在结束时已保存。
- 在作业完成后，通过选择作业日志右侧的**浏览**来浏览产物文件的内容。

<a id="add-a-job-to-deploy-the-site"></a>

## 添加一个用于部署站点的作业

在验证 Docusaurus 站点可在 `build-job`中构建后，您可以添加一个用于部署它的作业。

本步骤介绍：

- [`stage`](../yaml/_index.md#stage) 和 [`stages`](../yaml/_index.md#stage)：最常见的
  流水线配置会将作业分组到阶段中。同一阶段中的作业可以并行运行，
  而后续阶段中的作业会等待较早阶段中的作业完成。如果某个作业失败，
  整个阶段会被视为失败，后续阶段中的作业不会开始运行。
- [GitLab Pages](../../user/project/pages/_index.md)：要托管您的静态站点，您
  可以使用 GitLab Pages。

在本步骤中：

- 添加一个作业，用于获取构建好的站点并部署它。使用 GitLab Pages 时，
  该作业始终命名为 `pages`。来自 `build-job`的产物会自动获取
  并解压到该作业中。不过 Pages 会在 `public/` 目录中查找站点，
  因此添加一个 `script` 命令将站点移动到该目录。
- 添加一个 `stages` 部分，并为每个作业定义阶段。`build-job` 首先
  在 `build` 阶段运行，`pages` 随后在 `deploy` 阶段运行。

```yaml
stages:          # List of stages for jobs and their order of execution
  - build
  - deploy

build-job:
  stage: build   # Set this job to run in the `build` stage
  image: node
  script:
    - npm install
    - npm run build
  artifacts:
    paths:
      - "build/"

pages:
  stage: deploy  # Set this new job to run in the `deploy` stage
  script:
    - mv build/ public/
  artifacts:
    paths:
      - "public/"
```

使用流水线编辑器将此流水线配置提交到默认分支，并从**流水线**列表查看流水线详情。验证：

- 这两个作业在不同的阶段运行，即 `build` 和 `deploy`。
- 在 `pages` 作业完成后，会出现一个 `pages:deploy` 作业，这是极狐GitLab
  部署 Pages 站点的过程。当该作业完成后，您可以访问您的新 Docusaurus
  站点。

要查看您的站点：

- 在左侧边栏中，选择**部署** > **Pages**。
- 确保**使用唯一域名**已关闭。
- 在**访问页面**下，选择该链接。URL 格式应类似于：`https://<my-username>.gitlab.io/<project-name>`。有关更多信息，请参阅 [GitLab Pages 默认域名](../../user/project/pages/getting_started_part_one.md#gitlab-pages-default-domain-names)。

> [!note]
> 如果您需要[使用唯一域名](../../user/project/pages/_index.md#unique-domains)，请在 `docusaurus.config.js`中将 `baseUrl`: 设置为 `/`。

<a id="add-test-jobs"></a>

## 添加测试作业

现在站点可以按预期构建和部署，您可以添加测试和 lint 检查。
例如，Ruby 项目可能会运行 RSpec 测试作业。Docusaurus 是一个使用 Markdown 和生成的 HTML 的静态站点，
因此本教程添加用于测试 Markdown 和 HTML 的作业。

本步骤介绍：

- [`allow_failure`](../yaml/_index.md#allow_failure)：间歇性失败
  或预期会失败的作业可能会降低工作效率或难以排查。
  使用 `allow_failure` 让作业失败而不中止流水线执行。
- [`dependencies`](../yaml/_index.md#dependencies)：使用 `dependencies` 通过列出要从哪些作业获取产物，
  来控制各个作业中的产物下载。

在本步骤中：

- 添加一个新的 `test` 阶段，在 `build` 和 `deploy` 之间运行。当配置中未定义 `stages` 时，
  这三个阶段是默认阶段。
- 添加一个 `lint-markdown` 作业来运行 [markdownlint](https://github.com/DavidAnson/markdownlint)
  并检查您项目中的 Markdown。markdownlint 是一个静态分析工具，
  用于检查您的 Markdown 文件是否遵循格式标准。
  - Docusaurus 生成的示例 Markdown 文件位于 `blog/` 和 `docs/` 中。
  - 此工具仅扫描原始 Markdown 文件，不需要保存在 `build-job` 产物中的生成的 HTML。
    使用 `dependencies: []` 加快该作业的速度，
    使其不获取任何产物。
  - 少数示例 Markdown 文件违反了默认的 markdownlint 规则，因此添加
    `allow_failure: true` 以让流水线在存在规则违规的情况下继续运行。
- 添加一个 `test-html` 作业来运行 [HTMLHint](https://htmlhint.com/) 并检查生成的 HTML。
  HTMLHint 是一个静态分析工具，用于扫描生成的 HTML 以查找已知问题。
- `test-html` 和 `pages` 都需要 `build-job` 产物中生成的 HTML。
  默认情况下，作业会从较早阶段的所有作业获取产物，但添加 `dependencies:`
  以确保在未来的流水线更改后，这些作业不会意外下载其他产物。

```yaml
stages:
  - build
  - test               # Add a `test` stage for the test jobs
  - deploy

build-job:
  stage: build
  image: node
  script:
    - npm install
    - npm run build
  artifacts:
    paths:
      - "build/"

lint-markdown:
  stage: test
  image: node
  dependencies: []     # Don't fetch any artifacts
  script:
    - npm install markdownlint-cli2 --global           # Install markdownlint into the container
    - markdownlint-cli2 -v                             # Verify the version, useful for troubleshooting
    - markdownlint-cli2 "blog/**/*.md" "docs/**/*.md"  # Lint all markdown files in blog/ and docs/
  allow_failure: true  # This job fails right now, but don't let it stop the pipeline.

test-html:
  stage: test
  image: node
  dependencies:
    - build-job        # Only fetch artifacts from `build-job`
  script:
    - npm install --save-dev htmlhint                  # Install HTMLHint into the container
    - npx htmlhint --version                           # Verify the version, useful for troubleshooting
    - npx htmlhint build/                              # Lint all markdown files in blog/ and docs/

pages:
  stage: deploy
  dependencies:
    - build-job        # Only fetch artifacts from `build-job`
  script:
    - mv build/ public/
  artifacts:
    paths:
      - "public/"
```

将此流水线配置提交到默认分支，并查看流水线详情。

- `lint-markdown` 作业会失败，因为示例 Markdown 违反了默认的
  markdownlint 规则，但允许其失败。您可以：
  - 暂时忽略这些违规。它们不需要作为本教程的一部分来修复。
  - 修复 Markdown 文件违规。然后您可以将 `allow_failure` 更改为 `false`，
    或完全移除 `allow_failure`，因为未定义时 `allow_failure: false` 是默认行为。
  - 添加一个 markdownlint 配置文件，以限制要针对哪些规则违规发出提醒。
- 您还可以更改 Markdown 文件内容，并在下一次部署后
  在站点上看到这些更改。

<a id="start-using-merge-request-pipelines"></a>

## 开始使用合并请求流水线

使用之前的流水线配置，每次流水线成功完成时站点都会部署，但这并不是理想的开发工作流。更好的做法是从功能分支和合并请求开展工作，并且仅在更改合并到默认分支时才部署站点。

本步骤介绍：

- [`rules`](../yaml/_index.md#rules)：为每个作业添加规则，以配置它们在哪些
  流水线中运行。您可以将作业配置为在[合并请求流水线](../pipelines/merge_request_pipelines.md)、
  [定时流水线](../pipelines/schedules.md)或其他特定情况下运行。
  规则会从上到下进行评估，如果某个规则匹配，该作业就会被
  添加到流水线中。
- [CI/CD 变量](../variables/_index.md)：使用这些环境变量
  在配置文件和脚本命令中配置作业行为。
  [预定义 CI/CD 变量](../variables/predefined_variables.md)是您无需手动定义的变量。
  它们会自动注入到流水线中，
  因此您可以使用它们来配置您的流水线。变量通常格式为 `$VARIABLE_NAME`，
  而预定义变量通常以 `$CI_` 为前缀。

在本步骤中：

- 创建一个新的功能分支，并在该分支中进行更改，而不是在默认分支中。
- 为每个作业添加 `rules`：
  - 站点应仅在默认分支发生更改时部署。
  - 其他作业应在合并请求或默认分支中的所有更改时运行。
- 使用此流水线配置，您可以在功能分支中工作而不运行任何作业，
  从而节省资源。当您准备好验证更改时，创建一个合并请求，
  就会运行一个流水线，其中包含配置为在合并请求中运行的作业。
- 当您的合并请求被接受且更改合并到默认分支后，
  会运行一个新的流水线，其中也包含 `pages` 部署作业。如果没有作业失败，
  站点就会部署。

```yaml
stages:
  - build
  - test
  - deploy

build-job:
  stage: build
  image: node
  script:
    - npm install
    - npm run build
  artifacts:
    paths:
      - "build/"
  rules:
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'  # Run for all changes to a merge request's source branch
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH       # Run for all changes to the default branch

lint-markdown:
  stage: test
  image: node
  dependencies: []
  script:
    - npm install markdownlint-cli2 --global
    - markdownlint-cli2 -v
    - markdownlint-cli2 "blog/**/*.md" "docs/**/*.md"
  allow_failure: true
  rules:
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'  # Run for all changes to a merge request's source branch
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH       # Run for all changes to the default branch

test-html:
  stage: test
  image: node
  dependencies:
    - build-job
  script:
    - npm install --save-dev htmlhint
    - npx htmlhint --version
    - npx htmlhint build/
  rules:
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'  # Run for all changes to a merge request's source branch
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH       # Run for all changes to the default branch

pages:
  stage: deploy
  dependencies:
    - build-job
  script:
    - mv build/ public/
  artifacts:
    paths:
      - "public/"
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH      # Run for all changes to the default branch only
```

在您的合并请求中合并更改。此操作会更新默认分支。验证新的流水线包含部署站点的 `pages` 作业。

请务必在以后对流水线配置的所有更改中使用功能分支和合并请求。其他项目更改（例如创建 Git 标签或添加流水线计划）不会触发流水线，除非您也为这些情况添加规则。

<a id="reduce-duplicated-configuration"></a>

## 减少重复配置

该流水线现在包含三个作业，它们都具有相同的 `rules` 和 `image` 配置。与其重复这些规则，不如使用 `extends` 和 `default` 来创建单一事实来源。

本步骤介绍：

- [隐藏作业](../jobs/_index.md#hide-a-job)：以 `.` 开头的作业永远不会
  被添加到流水线中。使用它们来保存您想要复用的配置。
- [`extends`](../yaml/_index.md#extends)：使用 extends 在
  多个位置重复配置，通常来自隐藏作业。如果您更新隐藏作业的配置，
  所有扩展该隐藏作业的作业都会使用更新后的配置。
- [`default`](../yaml/_index.md#default)：设置适用于所有作业的关键字默认值
  （在未定义时）。
- YAML 覆盖：使用 `extends` 或 `default` 复用配置时，您可以在作业中显式
  定义关键字，以覆盖 `extends` 或 `default` 配置。

在本步骤中：

- 添加一个 `.standard-rules` 隐藏作业，以保存 `build-job`、
  `lint-markdown` 和 `test-html`中重复的规则。
- 使用 `extends` 在这三个作业中复用 `.standard-rules` 配置。
- 添加一个 `default` 部分，将 `image` 默认值定义为 `node`。
- `pages` 部署作业不需要默认的 `node` 镜像，因此显式使用
  [`busybox`](https://hub.docker.com/_/busybox)，这是一个极其小巧且快速的镜像。

```yaml
stages:
  - build
  - test
  - deploy

default:               # Add a default section to define the `image` keyword's default value
  image: node

.standard-rules:       # Make a hidden job to hold the common rules
  rules:
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

build-job:
  extends:
    - .standard-rules  # Reuse the configuration in `.standard-rules` here
  stage: build
  script:
    - npm install
    - npm run build
  artifacts:
    paths:
      - "build/"

lint-markdown:
  stage: test
  extends:
    - .standard-rules  # Reuse the configuration in `.standard-rules` here
  dependencies: []
  script:
    - npm install markdownlint-cli2 --global
    - markdownlint-cli2 -v
    - markdownlint-cli2 "blog/**/*.md" "docs/**/*.md"
  allow_failure: true

test-html:
  stage: test
  extends:
    - .standard-rules  # Reuse the configuration in `.standard-rules` here
  dependencies:
    - build-job
  script:
    - npm install --save-dev htmlhint
    - npx htmlhint --version
    - npx htmlhint build/

pages:
  stage: deploy
  image: busybox       # Override the default `image` value with `busybox`
  dependencies:
    - build-job
  script:
    - mv build/ public/
  artifacts:
    paths:
      - "public/"
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

使用合并请求将此流水线配置提交到默认分支。该文件更简单，但其行为应与上一步相同。

您刚刚创建了一个完整的流水线，并对其进行了精简以提高效率。做得好！现在您可以运用这些知识，在 [CI/CD YAML 语法参考](../yaml/_index.md)中了解其余的 `.gitlab-ci.yml` 关键字，并构建您自己的流水线。
