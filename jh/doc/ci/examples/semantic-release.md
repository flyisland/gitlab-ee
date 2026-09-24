---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 semantic-release 将 npm 软件包发布至极狐GitLab 软件包仓库
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本指南演示如何使用 [semantic-release](https://github.com/semantic-release/semantic-release) 自动将 npm 软件包发布到 [极狐GitLab 软件包仓库](../../user/packages/npm_registry/_index.md)。

您也可以查看或派生完整的 [示例源代码](https://jihulab.com/gitlab-examples/semantic-release-npm)。

<a id="initialize-the-module"></a>

## 初始化模块

1. 打开终端并进入项目仓库。
1. 运行 `npm init`。根据 [软件包仓库的命名约定](../../user/packages/npm_registry/_index.md#naming-convention) 命名模块。例如，如果项目路径为 `gitlab-examples/semantic-release-npm`，则将模块命名为 `@gitlab-examples/semantic-release-npm`。
1. 安装以下 npm 软件包：

   ```shell
   npm install semantic-release @semantic-release/git @semantic-release/gitlab @semantic-release/npm --save-dev
   ```

1. 将以下属性添加到模块的 `package.json` 中：

   ```json
   {
     "scripts": {
       "semantic-release": "semantic-release"
     },
     "publishConfig": {
       "access": "public"
     },
     "files": [ <path(s) to files here> ]
   }
   ```

1. 使用 glob 模式更新 `files` 键，以选择应包含在已发布模块中的所有文件。有关 `files` 的更多信息，请参阅 [npm 文档](https://docs.npmjs.com/cli/v6/configuring-npm/package-json/#files)。
1. 将 `.gitignore` 文件添加到项目中，以避免提交 `node_modules`：

   ```plaintext
   node_modules
   ```

<a id="configure-the-pipeline"></a>

## 配置流水线

创建包含以下内容的 `.gitlab-ci.yml` 文件：

```yaml
default:
  image: node:latest
  before_script:
    - npm ci --cache .npm --prefer-offline
    - |
      {
        echo "@${CI_PROJECT_ROOT_NAMESPACE}:registry=${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/npm/"
        echo "${CI_API_V4_URL#https?}/projects/${CI_PROJECT_ID}/packages/npm/:_authToken=\${CI_JOB_TOKEN}"
      } | tee -a .npmrc
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - .npm/

workflow:
  rules:
    - if: $CI_COMMIT_BRANCH

variables:
  NPM_TOKEN: ${CI_JOB_TOKEN}

stages:
  - release

publish:
  stage: release
  script:
    - npm run semantic-release
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

此示例配置了一个包含单个作业 `publish` 的流水线，该作业运行 `semantic-release`。semantic-release 库会发布 npm 软件包的新版本，并创建新的极狐GitLab 版本（如有必要）。

默认的 `before_script` 会生成一个临时 `.npmrc`，用于在 `publish` 作业期间向软件包仓库进行身份验证。

<a id="set-up-cicd-variables"></a>

## 设置 CI/CD 变量

作为发布软件包的一部分，semantic-release 会增加 `package.json` 中的版本号。为了让 semantic-release 提交此更改并将其推送回极狐GitLab，流水线需要一个名为 `GITLAB_TOKEN` 的自定义 CI/CD 变量。要创建此变量：

1. 打开左侧边栏。
1. 选择 **设置** > **访问令牌**。
1. 在您的项目中，选择 **添加新令牌**。
1. 在 **令牌名称** 框中，输入令牌名称。
   <!-- markdownlint-disable MD044 -->
1. 在 **选择范围** 下，选中 **api** 复选框。
   <!-- markdownlint-enable MD044 -->
1. 选择 **创建项目访问令牌**。
1. 复制令牌值。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **变量**。
1. 选择 **添加变量**。
1. 在 **可见性** 下，选择 **掩码**。
1. 在 **键** 框中，输入 `GITLAB_TOKEN`。
1. 在 **值** 框中，输入令牌值。
1. 选择 **添加变量**。

<a id="configure-semantic-release"></a>

## 配置 semantic-release

semantic-release 从项目中的 `.releaserc.json` 文件获取其配置信息。在仓库根目录创建 `.releaserc.json` 文件：

```json
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/gitlab",
    "@semantic-release/npm",
    [
      "@semantic-release/git",
      {
        "assets": ["package.json"],
        "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
      }
    ]
  ]
}
```

在上面的 semantic-release 配置示例中，您可以将分支名称更改为项目的默认分支。

<a id="begin-publishing-releases"></a>

## 开始发布版本

通过创建一条类似以下内容的提交消息来测试流水线：

```plaintext
fix: 测试补丁版本
```

将提交推送到默认分支。流水线应在项目的 **版本发布** 页面上创建一个新版本（`v1.0.0`），并将软件包的新版本发布到项目的 **软件包仓库** 页面。

要创建次要版本，请使用类似以下的提交消息：

```plaintext
feat: 测试次要版本
```

或者，对于破坏性变更：

```plaintext
feat: 测试主要版本

BREAKING CHANGE: 这是一个破坏性变更。
```

有关提交消息如何映射到版本的更多信息，请参阅 [semantic-release 的文档](https://github.com/semantic-release/semantic-release#how-does-it-work)。

<a id="use-the-module-in-a-project"></a>

## 在项目中使用该模块

要使用已发布的模块，请在依赖该模块的项目中添加一个 `.npmrc` 文件。例如，要使用 [示例项目](https://jihulab.com/gitlab-examples/semantic-release-npm) 的模块：

```plaintext
@gitlab-examples:registry=https://jihulab.com/api/v4/packages/npm/
```

然后，安装该模块：

```shell
npm install --save @gitlab-examples/semantic-release-npm
```

<a id="troubleshooting"></a>

## 故障排除

<a id="deleted-git-tags-reappear"></a>

### 删除的 Git 标签重新出现

从仓库中删除的 [Git 标签](../../user/project/repository/tags/_index.md) 有时可能会被 `semantic-release` 重新创建，当极狐GitLab Runner 使用仓库的缓存版本时。如果作业在具有仍包含该标签的缓存仓库的 Runner 上运行，`semantic-release` 会在主仓库中重新创建该标签。

为避免此行为，您可以：

- 使用 [`GIT_STRATEGY: clone`](../runners/configure_runners.md#git-strategy) 配置 Runner。
- 在 CI/CD 脚本中包含 [`git fetch --prune-tags` 命令](https://git-scm.com/docs/git-fetch#Documentation/git-fetch.txt---prune-tags)。