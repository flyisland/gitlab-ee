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

本教程通过小步迭代的方式，引导你逐步配置一个越来越复杂的 CI/CD 流水线。流水线始终保持完全可用，但每一步都会增加更多功能。目标是构建、测试并部署一个文档站点。

完成本教程后，你将在 JihuLab.com 上拥有一个新项目，以及一个使用 [Docusaurus](https://docusaurus.io/) 搭建的可用文档站点。

要完成本教程，你将：

1. 创建一个项目来存放 Docusaurus 文件
1. 创建初始流水线配置文件
1. 添加构建站点的作业
1. 添加部署站点的作业
1. 添加测试作业
1. 开始使用合并请求流水线
1. 减少重复配置

<a id="prerequisites"></a>

## 前提条件

- 你需要一个 JihuLab.com 账号。
- 你应该熟悉 Git。
- 本地机器上必须安装 Node.js。例如，在 macOS 上，你可以使用 `brew install node` [安装 node](https://formulae.brew.sh/formula/node)。

<a id="create-a-project-to-hold-the-docusaurus-files"></a>

## 创建一个项目来存放 Docusaurus 文件

在添加流水线配置之前，你必须先在 JihuLab.com 上设置一个 Docusaurus 项目：

1. 在你的用户名下创建一个新项目（而不是群组）：
   1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建项目/代码仓**。
   1. 选择 **创建空白项目**。
   1. 输入项目详细信息：
      - 在 **项目名称** 字段中，输入你的项目名称，例如 `My Pipeline Tutorial Project`。
      - 选择 **使用 README 初始化代码仓**。
   1. 选择 **创建项目**。
1. 在项目概览页面的右上角，选择 **代码** 以查找项目的克隆路径。复制 SSH 或 HTTP 路径，并使用该路径将项目克隆到本地。

   例如，使用 SSH 将项目克隆到你计算机上的 `pipeline-tutorial` 目录：

   ```shell
   git clone git@gitlab.com:my-username/my-pipeline-tutorial-project.git pipeline-tutorial
   ```

1. 切换到项目目录，然后生成一个新的 Docusaurus 站点：

   ```shell
   cd pipeline-tutorial
   npm init docusaurus
   ```

   Docusaurus 初始化向导会询问你一些关于站点的问题。全部使用默认选项。

1. 初始化向导将站点设置在 `website/` 中，但站点应该位于项目的根目录。将文件上移到根目录并删除旧目录：

   ```shell
   mv website/* .
   rm -r website
   ```

1. 使用你的 GitLab 项目详细信息更新 Docusaurus 配置文件。在 `docusaurus.config.js` 中：

   - 将 `url:` 设置为格式为 `https://<my-username>.gitlab.io/` 的路径。
   - 将 `baseUrl:` 设置为你的项目名称，如 `/my-pipeline-tutorial-project/`。

1. 提交更改，并将它们推送到极狐GitLab：

   ```shell
   git add .
   git commit -m "Add simple generated Docusaurus site"
   git push origin
   ```

<a id="create-the-initial-cicd-configuration-file"></a>

## 创建初始 CI/CD 配置文件

从最简单的流水线配置文件开始，以确保项目中启用了 CI/CD，并且有 Runner 可用于运行作业。

此步骤引入了：

- [作业](../jobs/_index.md)：它们是流水线中自包含的部分，用于运行你的命令。作业在 [Runner](../runners/_index.md) 上运行，与极狐GitLab 实例分离。
- [`script`](../yaml/_index.md#script)：作业配置的这一部分用于定义作业的命令。如果有多个命令（在数组中），它们会按顺序运行。每个命令的执行方式就像作为 CLI 命令运行一样。默认情况下，如果命令失败或返回错误，作业将被标记为失败，并且不再运行更多命令。

在此步骤中，在项目根目录创建一个包含以下配置的 `.gitlab-ci.yml` 文件：

```yaml
test-job:
  script:
    - echo "这是我的第一个作业！"
    - date
```

提交并将此更改推送到极狐GitLab，然后：

1. 转到 **构建** > **流水线**，确保极狐GitLab 中运行了一个包含此单个作业的流水线。
1. 选择该流水线，然后选择作业以查看作业日志，并看到 `这是我的第一个作业！` 消息以及紧随其后的日期。

现在你的项目中有了一个 `.gitlab-ci.yml` 文件，你可以使用 [流水线编辑器](../pipeline_editor/_index.md) 对流水线配置进行所有后续更改。

<a id="add-a-job-to-build-the-site"></a>

## 添加构建站点的作业

CI/CD 流水线的一个常见任务是构建项目中的代码，然后部署它。首先添加一个构建站点的作业。

此步骤引入了：

- [`image`](../yaml/_index.md#image)：告诉 Runner 使用哪个 Docker 容器来运行作业。Runner 会：
  1. 下载容器镜像并启动它。
  1. 将你的极狐GitLab 项目克隆到正在运行的容器中。
  1. 逐一运行 `script` 命令。
- [`artifacts`](../yaml/_index.md#artifacts)：作业是自包含的，彼此之间不共享资源。如果你想在一个作业中生成的文件被另一个作业使用，你必须首先将它们保存为产物。然后，后续作业可以检索产物并使用生成的文件。

在此步骤中，将 `test-job` 替换为 `build-job`：

- 使用 `image` 配置作业以使用最新的 `node` 镜像运行。Docusaurus 是一个 Node.js 项目，`node` 镜像内置了所需的 `npm` 命令。
- 运行 `npm install` 将 Docusaurus 安装到正在运行的 `node` 容器中，然后运行 `npm run build` 来构建站点。
- Docusaurus 将构建后的站点保存在 `build/` 中，因此使用 `artifacts` 保存这些文件。

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

使用流水线编辑器将此流水线配置提交到默认分支，并检查作业日志。你可以：

- 看到 `npm` 命令运行并构建站点。
- 验证产物在最后被保存。
- 在作业完成后，通过选择作业日志右侧的 **浏览** 来浏览产物文件的内容。

<a id="add-a-job-to-deploy-the-site"></a>

## 添加部署站点的作业

在验证了 Docusaurus 站点在 `build-job` 中构建成功后，你可以添加一个部署它的作业。

此步骤引入了：

- [`stage`](../yaml/_index.md#stage) 和 [`stages`](../yaml/_index.md#stage)：最常见的流水线配置将作业分组到阶段中。同一阶段的作业可以并行运行，而后一阶段的作业会等待前一阶段的作业完成。如果某个作业失败，则整个阶段被视为失败，并且后续阶段的作业不会开始运行。
- [极狐GitLab Pages](../../user/project/pages/_index.md)：为了托管你的静态站点，你将使用极狐GitLab Pages。

在此步骤中：

- 添加一个获取构建后站点并进行部署的作业。使用极狐GitLab Pages 时，该作业始终命名为 `pages`。`build-job` 的产物会被自动获取并解压到作业中。但是，Pages 会在 `public/` 目录中查找站点，因此添加一个 `script` 命令将站点移动到该目录。
- 添加一个 `stages` 部分，并为每个作业定义阶段。`build-job` 首先在 `build` 阶段运行，`pages` 随后在 `deploy` 阶段运行。

```yaml
stages:          # 作业的阶段列表及其执行顺序
  - build
  - deploy

build-job:
  stage: build   # 将此作业设置为在 `build` 阶段运行
  image: node
  script:
    - npm install
    - npm run build
  artifacts:
    paths:
      - "build/"

pages:
  stage: deploy  # 将此新作业设置为在 `deploy` 阶段运行
  script:
    - mv build/ public/
  artifacts:
    paths:
      - "public/"
```

使用流水线编辑器将此流水线配置提交到默认分支，并从 **流水线** 列表中查看流水线详细信息。验证：

- 两个作业在不同的阶段运行，`build` 和 `deploy`。
- `pages` 作业完成后，会出现一个 `pages:deploy` 作业，这是部署 Pages 站点的极狐GitLab 进程。当该作业完成后，你就可以访问你的新 Docusaurus 站点了。

要查看你的站点：

- 在左侧边栏中，选择 **部署** > **Pages**。
- 确保 **使用唯一域名** 处于关闭状态。
- 在 **访问 Pages** 下，选择链接。URL 格式应类似于：`https://<my-username>.gitlab.io/<project-name>`。有关更多信息，请参见 [极狐GitLab Pages 默认域名](../../user/project/pages/getting_started_part_one.md#gitlab-pages-default-domain-names)。

> [!note]
> 如果你需要 [使用唯一域名](../../user/project/pages/_index.md#unique-domains)，请在 `docusaurus.config.js` 中将 `baseUrl:` 设置为 `/`。

<a id="add-test-jobs"></a>

## 添加测试作业

现在站点可以按预期构建和部署，你可以添加测试和代码检查。例如，一个 Ruby 项目可能会运行 RSpec 测试作业。Docusaurus 是一个使用 Markdown 和生成的 HTML 的静态站点，因此本教程添加作业来测试 Markdown 和 HTML。

此步骤引入了：

- [`allow_failure`](../yaml/_index.md#allow_failure)：间歇性失败或预期会失败的作业可能会降低生产力或难以排查。使用 `allow_failure` 允许作业失败，而不会停止流水线的执行。
- [`dependencies`](../yaml/_index.md#dependencies)：使用 `dependencies` 通过列出要从哪些作业获取产物，来控制单个作业中的产物下载。

在此步骤中：

- 添加一个新的 `test` 阶段，它在 `build` 和 `deploy` 之间运行。这三个阶段是配置中未定义 `stages` 时的默认阶段。
- 添加一个 `lint-markdown` 作业来运行 [markdownlint](https://github.com/DavidAnson/markdownlint)，并检查项目中的 Markdown。markdownlint 是一个静态分析工具，用于检查你的 Markdown 文件是否符合格式标准。
  - Docusaurus 生成的示例 Markdown 文件位于 `blog/` 和 `docs/` 中。
  - 此工具仅扫描原始 Markdown 文件，不需要 `build-job` 产物中保存的生成 HTML。使用 `dependencies: []` 加速作业，使其不获取任何产物。
  - 一些示例 Markdown 文件违反了默认的 markdownlint 规则，因此添加 `allow_failure: true` 以允许流水线在违反规则的情况下继续运行。
- 添加一个 `test-html` 作业来运行 [HTMLHint](https://htmlhint.com/)，并检查生成的 HTML。HTMLHint 是一个静态分析工具，用于扫描生成的 HTML 以查找已知问题。
- `test-html` 和 `pages` 都需要 `build-job` 产物中的生成 HTML。默认情况下，作业会获取早期阶段所有作业的产物，但添加 `dependencies:` 以确保作业在未来的流水线更改后不会意外下载其他产物。

```yaml
stages:
  - build
  - test               # 为测试作业添加一个 `test` 阶段
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
  dependencies: []     # 不获取任何产物
  script:
    - npm install markdownlint-cli2 --global           # 将 markdownlint 安装到容器中
    - markdownlint-cli2 -v                             # 验证版本，有助于排查问题
    - markdownlint-cli2 "blog/**/*.md" "docs/**/*.md"  # 检查 blog/ 和 docs/ 中的所有 markdown 文件
  allow_failure: true  # 此作业目前会失败，但不要让它停止流水线。

test-html:
  stage: test
  image: node
  dependencies:
    - build-job        # 仅从 `build-job` 获取产物
  script:
    - npm install --save-dev htmlhint                  # 将 HTMLHint 安装到容器中
    - npx htmlhint --version                           # 验证版本，有助于排查问题
    - npx htmlhint build/                              # 检查 blog/ 和 docs/ 中的所有 markdown 文件

pages:
  stage: deploy
  dependencies:
    - build-job        # 仅从 `build-job` 获取产物
  script:
    - mv build/ public/
  artifacts:
    paths:
      - "public/"
```

将此流水线配置提交到默认分支，并查看流水线详细信息。

- `lint-markdown` 作业因为示例 Markdown 违反了默认的 markdownlint 规则而失败，但被允许失败。你可以：
  - 暂时忽略这些违规。作为教程的一部分，它们不需要被修复。
  - 修复 Markdown 文件的违规。然后你可以将 `allow_failure` 更改为 `false`，或者完全移除 `allow_failure`，因为 `allow_failure: false` 是未定义时的默认行为。
  - 添加一个 markdownlint 配置文件来限制要警告的规则违规。
- 你还可以更改 Markdown 文件的内容，并在下一次部署后在站点上看到更改。

<a id="start-using-merge-request-pipelines"></a>

## 开始使用合并请求流水线

使用之前的流水线配置，每次流水线成功完成时站点都会部署，但这并不是理想的开发工作流程。更好的做法是从功能分支和合并请求进行工作，并且仅在更改合并到默认分支时才部署站点。

此步骤引入了：

- [`rules`](../yaml/_index.md#rules)：为每个作业添加规则，以配置它们在哪些流水线中运行。你可以配置作业在 [合并请求流水线](../pipelines/merge_request_pipelines.md)、[计划流水线](../pipelines/schedules.md) 或其他特定情况下运行。规则从上到下评估，如果规则匹配，则该作业被添加到流水线中。
- [CI/CD 变量](../variables/_index.md)：使用这些环境变量在配置文件和脚本命令中配置作业行为。[预定义 CI/CD 变量](../variables/predefined_variables.md) 是你无需手动定义的变量。它们会自动注入到流水线中，因此你可以使用它们来配置你的流水线。变量通常格式为 `$VARIABLE_NAME`，而预定义变量通常以 `$CI_` 为前缀。

在此步骤中：

- 创建一个新的功能分支，并在该分支而不是默认分支中进行更改。
- 为每个作业添加 `rules`：
  - 站点应仅针对默认分支的更改进行部署。
  - 其他作业应针对合并请求或默认分支中的所有更改运行。
- 使用此流水线配置，你可以从功能分支工作而无需运行任何作业，从而节省资源。当你准备好验证更改时，创建一个合并请求，并且一个流水线会运行，其中包含配置为在合并请求中运行的作业。
- 当你的合并请求被接受并且更改合并到默认分支时，会运行一个新的流水线，其中也包含 `pages` 部署作业。如果没有作业失败，站点就会部署。

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
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'  # 针对合并请求源分支的所有更改运行
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH       # 针对默认分支的所有更改运行

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
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'  # 针对合并请求源分支的所有更改运行
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH       # 针对默认分支的所有更改运行

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
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'  # 针对合并请求源分支的所有更改运行
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH       # 针对默认分支的所有更改运行

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
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH      # 仅针对默认分支的所有更改运行
```

在你的合并请求中合并更改。此操作会更新默认分支。验证新的流水线是否包含部署站点的 `pages` 作业。

务必使用功能分支和合并请求来进行所有未来的流水线配置更改。其他项目更改，例如创建 Git 标签或添加流水线计划，不会触发流水线，除非你也为这些情况添加规则。

<a id="reduce-duplicated-configuration"></a>

## 减少重复配置

流水线现在包含三个作业，它们都具有相同的 `rules` 和 `image` 配置。与其重复这些规则，不如使用 `extends` 和 `default` 来创建单一事实来源。

此步骤引入了：

- [隐藏作业](../jobs/_index.md#hide-a-job)：以 `.` 开头的作业永远不会被添加到流水线中。使用它们来保存你想要重用的配置。
- [`extends`](../yaml/_index.md#extends)：使用 extends 在多个地方重复配置，通常来自隐藏作业。如果你更新隐藏作业的配置，所有扩展该隐藏作业的作业都会使用更新后的配置。
- [`default`](../yaml/_index.md#default)：设置关键字默认值，当未定义时，这些默认值将应用于所有作业。
- YAML 覆盖：当使用 `extends` 或 `default` 重用配置时，你可以在作业中显式定义一个关键字来覆盖 `extends` 或 `default` 的配置。

在此步骤中：

- 添加一个 `.standard-rules` 隐藏作业，以保存在 `build-job`、`lint-markdown` 和 `test-html` 中重复的规则。
- 使用 `extends` 在这三个作业中重用 `.standard-rules` 配置。
- 添加一个 `default` 部分，将 `image` 默认值定义为 `node`。
- `pages` 部署作业不需要默认的 `node` 镜像，因此显式使用 [`busybox`](https://hub.docker.com/_/busybox)，这是一个极其小巧且快速的镜像。

```yaml
stages:
  - build
  - test
  - deploy

default:               # 添加一个 default 部分来定义 `image` 关键字的默认值
  image: node

.standard-rules:       # 创建一个隐藏作业来保存通用规则
  rules:
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

build-job:
  extends:
    - .standard-rules  # 在这里重用 `.standard-rules` 中的配置
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
    - .standard-rules  # 在这里重用 `.standard-rules` 中的配置
  dependencies: []
  script:
    - npm install markdownlint-cli2 --global
    - markdownlint-cli2 -v
    - markdownlint-cli2 "blog/**/*.md" "docs/**/*.md"
  allow_failure: true

test-html:
  stage: test
  extends:
    - .standard-rules  # 在这里重用 `.standard-rules` 中的配置
  dependencies:
    - build-job
  script:
    - npm install --save-dev htmlhint
    - npx htmlhint --version
    - npx htmlhint build/

pages:
  stage: deploy
  image: busybox       # 使用 `busybox` 覆盖默认的 `image` 值
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

使用合并请求将此流水线配置提交到默认分支。该文件更简洁，但其行为应与上一步相同。

你刚刚创建了一个完整的流水线，并对其进行了精简以提高效率。干得好！现在你可以运用这些知识，在 [CI/CD YAML 语法参考](../yaml/_index.md) 中了解 `.gitlab-ci.yml` 的其他关键字，并构建你自己的流水线。