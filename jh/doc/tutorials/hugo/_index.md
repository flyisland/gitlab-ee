---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用极狐GitLab 构建、测试和部署您的 Hugo 站点'
---

<!-- vale gitlab_base.FutureTense = NO -->

本教程将引导您创建一个 CI/CD 流水线，用于构建、测试和部署 Hugo 站点。

完成本教程后，您将拥有一个可运行的流水线以及一个部署在极狐GitLab Pages 上的 Hugo 站点。

以下是您将要完成的操作概览：

1. 准备您的 Hugo 站点。
1. 创建一个极狐GitLab 项目。
1. 将您的 Hugo 站点推送到极狐GitLab。
1. 使用 CI/CD 流水线构建您的 Hugo 站点。
1. 使用极狐GitLab Pages 部署您的 Hugo 站点。

<a id="before-you-begin"></a>

## 准备工作

- 一个 JihuLab.com 账号。
- 熟悉 Git。
- 一个 Hugo 站点（如果您还没有，可以按照 [Hugo 快速入门](https://gohugo.io/getting-started/quick-start/) 进行操作）。

<a id="prepare-your-hugo-site"></a>

## 准备您的 Hugo 站点

首先，确保您的 Hugo 站点已准备好推送到极狐GitLab。您需要准备好内容、主题和 Hugo 配置文件。

不要构建您的站点，极狐GitLab 会为您完成这项工作。事实上，**不要**上传您的 `public` 文件夹非常重要，因为这可能会在后续引发冲突。

排除 `public` 文件夹的最简单方法是创建一个 `.gitignore` 文件，并添加一行 `public/` 文本。

您可以在 Hugo 项目的顶层目录中使用以下命令来完成此操作：

```shell
echo "public/" >> .gitignore
```

这会将 `public/` 添加到新的 `.gitignore` 文件中，或追加到现有文件中。

好的，在您创建极狐GitLab 项目后，您的 Hugo 站点就可以推送了。

<a id="create-a-gitlab-project"></a>

## 创建极狐GitLab 项目

如果您还没有这样做，请为您的 Hugo 站点创建一个空白的极狐GitLab 项目。

要创建空白项目，在极狐GitLab 中：

1. 在右上角，选择 **新建**（{{< icon name="plus" >}}）和 **新建项目/仓库**。
1. 选择 **创建空白项目**。
1. 输入项目详细信息：
   - 在 **项目名称** 字段中，输入您的项目名称。名称必须以小写或大写字母（`a-zA-Z`）、数字（`0-9`）、表情符号或下划线（`_`）开头。它还可以包含点（`.`）、加号（`+`）、短横线（`-`）或空格。
   - 在 **项目路径** 字段中，输入项目的路径。极狐GitLab 实例使用此路径作为项目的 URL 路径。要更改路径，请先输入项目名称，然后更改路径。
   - **可见性级别** 可以是私有或公开。如果您选择私有，您的网站仍然可以公开访问，但您的代码保持私有。
   - 因为您正在推送一个现有仓库，请取消选中 **使用 README 初始化仓库** 复选框。
1. 准备好后，选择 **创建项目**。
1. 您应该会看到将代码推送到这个新项目的说明。在下一步中您将需要这些说明。

现在，您的 Hugo 站点有了一个家！

<a id="push-your-hugo-site-to-gitlab"></a>

## 将您的 Hugo 站点推送到极狐GitLab

接下来，您需要将本地的 Hugo 站点推送到远程的极狐GitLab 项目。

如果您在上一步中创建了一个新的极狐GitLab 项目，您会看到初始化仓库、然后提交和推送文件的说明。

否则，请确保本地 Git 仓库的远程 origin 与您的极狐GitLab 项目匹配。

假设您的默认分支是 `main`，您可以使用以下命令推送您的 Hugo 站点：

```shell
git push origin main
```

推送站点后，您应该会看到除了 `public` 文件夹之外的所有内容。`public` 文件夹已被 `.gitignore` 文件排除。

在下一步中，您将使用 CI/CD 流水线来构建您的站点并重新生成 `public` 文件夹。

<a id="build-your-hugo-site-with-a-cicd-pipeline"></a>

## 使用 CI/CD 流水线构建您的 Hugo 站点

要使用极狐GitLab 构建 Hugo 站点，您首先需要创建一个 `.gitlab-ci.yml` 文件来指定 CI/CD 流水线的指令。如果您以前没有这样做过，这可能听起来令人生畏。但是，极狐GitLab 提供了您所需的一切。

要使用下面显示的 `.gitlab-ci.yml` 文件，请确保您的 `hugo.toml` 文件也指示了匹配的主题路径。下面的示例 `hugo.toml` 文件还显示了极狐GitLab Pages 项目的 `baseURL` 设置。

```yaml
baseURL = 'https://<your-namespace>.jihulab.io/<project-path>'
languageCode = 'en-us'
title = 'Hugo on GitLab'
[module]
[[module.imports]]
  path = 'github.com/adityatelange/hugo-PaperMod'
```

<a id="add-your-gitlab-configuration-options"></a>

### 添加您的极狐GitLab 配置选项

您可以在一个名为 `.gitlab-ci.yml` 的特殊文件中指定配置选项。

要使用 Hugo 模板创建 `.gitlab-ci.yml` 文件：

1. 在左侧边栏中，选择 **代码** > **仓库**。
1. 在文件列表上方，选择加号图标（+），然后从下拉列表中选择 **新建文件**。
1. 对于文件名，输入 `.gitlab-ci.yml`。不要省略开头的句点。
1. 选择 **应用模板** 下拉列表，然后在过滤框中输入 "Hugo"。
1. 选择结果 **Hugo**，您的文件将被填充所有使用 CI/CD 构建 Hugo 站点所需的代码。

让我们仔细看看这个 `.gitlab-ci.yml` 文件中发生了什么。

```yaml
default:
  image: "hugomods/hugo:exts"

variables:
  GIT_SUBMODULE_STRATEGY: recursive
  THEME_URL: "github.com/adityatelange/hugo-PaperMod"

test:  # 构建并测试您的站点
  script:
    - hugo
  rules:
    - if: $CI_COMMIT_BRANCH != $CI_DEFAULT_BRANCH

create-pages:  # 一个用户自定义作业，用于构建页面并将其保存到指定路径。
  script:
    - hugo
  pages: true  # 指定这是一个 Pages 作业
  artifacts:
    paths:
      - public
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
  environment: production
```

- `image` 指定了来自极狐GitLab 镜像仓库的一个包含 Hugo 的镜像。该镜像用于创建构建站点的环境。
- `GIT_SUBMODULE_STRATEGY` 变量确保极狐GitLab 也会查看您的 Git 子模块，这些子模块有时用于 Hugo 主题。
- `test` 是一个作业，您可以在部署站点之前对其运行测试。测试作业在所有情况下都会运行，除非您正在向默认分支提交更改。您可以将任何命令放在 `script` 下。此作业中的命令 `hugo` 会构建您的站点以便进行测试。
- `create-pages` 是一个用户自定义作业，用于从静态站点生成器创建页面。同样，此作业使用
  [用户自定义作业名称](../../user/project/pages/_index.md#user-defined-job-names) 并运行 `hugo` 命令来
  构建您的站点。然后 `pages: true` 指定这是一个 Pages 作业，`artifacts` 指定生成的页面被添加到名为 `public` 的目录中。通过
  `rules`，您正在检查此提交是否是在默认分支上进行的。通常，您不会希望从其他分支构建和
  部署生产站点。

您无需在此文件中添加任何其他内容。准备好后，选择页面顶部的 **提交更改**。

您刚刚触发了一个流水线来构建您的 Hugo 站点！

<a id="deploy-your-hugo-site-with-gitlab-pages"></a>

## 使用极狐GitLab Pages 部署您的 Hugo 站点

如果您动作够快，可以看到极狐GitLab 构建和部署您的站点。

从左侧导航栏中，选择 **构建** > **流水线**。

您会看到极狐GitLab 已经运行了您的 `test` 和 `create-pages` 作业。

要查看您的站点，当流水线完成后，在左侧导航栏中，选择 **部署** > **Pages** 以找到您的 Pages 网站链接。

<a id="add-your-hugo-configuration-options"></a>

### 添加您的 Hugo 配置选项

当您第一次查看 Hugo 站点时，样式表将无法正常工作。别担心，您需要在 Hugo 配置文件中做一个小改动。Hugo 需要知道您的极狐GitLab Pages 站点的 URL，以便它可以构建指向样式表和其他资源的相对链接：

1. 在您的本地 Hugo 站点中，拉取最新更改，然后打开您的 `config.yaml` 或 `config.toml` 文件。
1. 将 `BaseURL` 参数的值更改为与极狐GitLab Pages 设置中显示的 URL 匹配。
1. 将更改后的文件推送到极狐GitLab，您的流水线将再次被触发。

<a id="find-your-gitlab-pages-url"></a>

### 查找您的极狐GitLab Pages URL

当流水线完成后，转到 **部署** > **Pages** 以找到您的 Pages 网站链接。

流水线中的 `pages` 作业已将您的 `public` 目录的内容部署到极狐GitLab Pages。在 **访问 Pages** 下，您应该会看到格式为 `https://<your-namespace>.jihulab.io/<project-path>` 的链接。

如果您还没有运行流水线，则不会看到此链接。

选择显示的链接来查看您的站点。您需要更改 Hugo 配置中的 `BaseURL` 设置以匹配极狐GitLab 部署 URL。

<a id="set-your-gitlab-pages-visibility"></a>

### 设置您的极狐GitLab Pages 可见性

如果您的 Hugo 站点存储在私有仓库中，您需要更改权限以使 Pages 站点可见。否则，它仅对项目成员可见。要更改站点权限：

1. 转到 **设置** > **通用** > **可见性、项目功能、权限**。
1. 向下滚动到 **Pages** 部分，然后从下拉列表中选择 **所有人**。
1. 选择 **保存更改**。

现在，每个人都可以通过该 URL 看到站点。

您已经使用极狐GitLab 构建、测试并部署了您的 Hugo 站点。干得漂亮！

每次您更改站点并将其推送到极狐GitLab 时，您的站点都会根据 `.gitlab-ci.yml` 文件中的规则自动构建、测试和部署。

要了解更多关于 CI/CD 流水线的信息，请尝试 [这个关于如何创建复杂流水线的教程](../../ci/quick_start/tutorial.md)。您还可以了解更多关于 [可用的不同测试类型](../../ci/testing/_index.md) 的信息。