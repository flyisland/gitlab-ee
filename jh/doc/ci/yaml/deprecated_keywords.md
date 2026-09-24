---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 已弃用的关键字
---

一些 CI/CD 关键字已被弃用，不再推荐使用。

> [!warning]
> 这些关键字仍然可用以确保向后兼容，
> 但可能会在未来的重要里程碑中被移除。

<a id="globally-defined-image-services-cache-before_script-after_script"></a>

## 全局定义的 `image`、`services`、`cache`、`before_script`、`after_script`

不推荐在全局范围内定义 `image`、`services`、`cache`、`before_script` 和 `after_script`。
请使用 [`default`](_index.md#default) 代替。

例如：

```yaml
default:
  image: ruby:3.0
  services:
    - docker:dind
  cache:
    paths: [vendor/]
  before_script:
    - bundle config set path vendor/bundle
    - bundle install
  after_script:
    - rm -rf tmp/
```

<a id="only--except"></a>

## `only` / `except`

> [!note]
> `only` 和 `except` 已弃用。要控制何时将作业添加到流水线，请使用 [`rules`](_index.md#rules) 代替。

你可以使用 `only` 和 `except` 来控制何时将作业添加到流水线。

- 使用 `only` 来定义作业何时运行。
- 使用 `except` 来定义作业 **不** 运行的时间。

<a id="onlyrefs--exceptrefs"></a>

### `only:refs` / `except:refs`

> [!note]
> `only:refs` 和 `except:refs` 已弃用。要使用 refs、正则表达式或变量来控制何时将作业添加到流水线，请使用 [`rules:if`](_index.md#rulesif) 代替。

你可以使用 `only:refs` 和 `except:refs` 关键字来根据分支名称或流水线类型控制作业何时添加到流水线中。

**关键字类型**：作业关键字。你只能将其用作作业的一部分。

**支持的值**：一个数组，包含任意数量的：

- 分支名称，例如 `main` 或 `my-feature-branch`。
- 与分支名称匹配的正则表达式，例如 `/^feature-.*/`。
- 以下关键字：

  | **值**                    | **描述** |
  | -------------------------|-----------------|
  | `api`                    | 针对由 [流水线 API](../../api/pipelines.md#create-a-new-pipeline) 触发的流水线。 |
  | `branches`               | 当流水线的 Git 引用是分支时。 |
  | `chat`                   | 针对使用 [极狐GitLab ChatOps](../chatops/_index.md) 命令创建的流水线。 |
  | `external`               | 当你使用 极狐GitLab 以外的 CI 服务时。 |
  | `external_pull_requests` | 当在 GitHub 上创建或更新外部拉取请求时（请参见[针对外部拉取请求的流水线](../ci_cd_for_external_repos/_index.md#pipelines-for-external-pull-requests)）。 |
  | `merge_requests`         | 针对在创建或更新合并请求时创建的流水线。启用[合并请求流水线](../pipelines/merge_request_pipelines.md)、[合并结果流水线](../pipelines/merged_results_pipelines.md)和[合并队列](../pipelines/merge_trains.md)。 |
  | `pipelines`              | 针对由[使用 API 并使用 `CI_JOB_TOKEN`](../pipelines/downstream_pipelines.md#trigger-a-multi-project-pipeline-by-using-the-api) 或 [`trigger`](_index.md#trigger) 关键字创建的[多项目流水线](../pipelines/downstream_pipelines.md#multi-project-pipelines)。 |
  | `pushes`                 | 针对由 `git push` 事件触发的流水线，包括分支和标签。 |
  | `schedules`              | 针对[计划流水线](../pipelines/schedules.md)。 |
  | `tags`                   | 当流水线的 Git 引用是标签时。 |
  | `triggers`               | 针对使用[触发器令牌](../triggers/_index.md#configure-cicd-jobs-to-run-in-triggered-pipelines)创建的流水线。 |
  | `web`                    | 针对在 极狐GitLab UI 中，从项目的 **构建** > **流水线** 部分选择 **新建流水线** 创建的流水线。 |

**`only:refs` 和 `except:refs` 示例**：

```yaml
job1:
  script: echo
  only:
    - main
    - /^issue-.*$/
    - merge_requests

job2:
  script: echo
  except:
    - main
    - /^stable-branch.*$/
    - schedules
```

**其他详细信息**：

- 计划流水线在特定分支上运行，因此配置了 `only: branches` 的作业也会在计划流水线上运行。添加 `except: schedules` 可防止带有 `only: branches` 的作业在计划流水线上运行。
- 未与其他任何关键字一起使用的 `only` 或 `except` 等效于 `only: refs` 或 `except: refs`。例如，以下两个作业配置具有相同的行为：

  ```yaml
  job1:
    script: echo
    only:
      - branches

  job2:
    script: echo
    only:
      refs:
        - branches
  ```

- 如果作业不使用 `only`、`except` 或 [`rules`](_index.md#rules)，则默认情况下 `only` 设置为 `branches` 和 `tags`。

  例如，`job1` 和 `job2` 是等效的：

  ```yaml
  job1:
    script: echo "test"

  job2:
    script: echo "test"
    only:
      - branches
      - tags
  ```

<a id="onlyvariables--exceptvariables"></a>

### `only:variables` / `except:variables`

> [!note]
> `only:variables` 和 `except:variables` 已弃用。要使用 refs、正则表达式或变量来控制何时将作业添加到流水线，请使用 [`rules:if`](_index.md#rulesif) 代替。

你可以使用 `only:variables` 或 `except:variables` 关键字，根据 [CI/CD 变量](../variables/_index.md) 的状态来控制何时将作业添加到流水线。

**关键字类型**：作业关键字。你只能将其用作作业的一部分。

**支持的值**：

- 一个 [CI/CD 变量表达式](../jobs/job_rules.md#cicd-variable-expressions) 的数组。

**`only:variables` 示例**：

```yaml
deploy:
  script: cap staging deploy
  only:
    variables:
      - $RELEASE == "staging"
      - $STAGING
```

<a id="onlychanges--exceptchanges"></a>

### `only:changes` / `except:changes`

> [!note]
> `only:changes` 和 `except:changes` 已弃用。要使用已更改的文件来控制何时将作业添加到流水线，请使用 [`rules:changes`](_index.md#ruleschanges) 代替。

当 `git push` 事件修改文件时，将 `changes` 关键字与 `only` 一起使用来运行作业，或与 `except` 一起使用来跳过作业。

在以下引用的流水线中使用 `changes`：

- `branches`
- `external_pull_requests`
- `merge_requests`

**关键字类型**：作业关键字。你只能将其用作作业的一部分。

**支持的值**：一个数组，包含任意数量的：

- 文件路径。
- 通配符路径：
  - 单个目录，例如 `path/to/directory/*`。
  - 一个目录及其所有子目录，例如 `path/to/directory/**/*`。
- 用于匹配具有相同扩展名或多个扩展名的所有文件的通配符 [glob](https://en.wikipedia.org/wiki/Glob_(programming)) 路径，例如 `*.md` 或 `path/to/directory/*.{rb,py,sh}`。
- 用于匹配根目录或所有目录中文件的通配符路径，并用双引号引起来。例如 `"*.json"` 或 `"**/*.json"`。

**`only:changes` 示例**：

```yaml
docker build:
  script: docker build -t my-image:$CI_COMMIT_REF_SLUG .
  only:
    refs:
      - branches
    changes:
      - Dockerfile
      - docker/scripts/*
      - dockerfiles/**/*
      - more_scripts/*.{rb,py,sh}
      - "**/*.json"
```

**其他详细信息**：

- 如果任何匹配的文件发生了更改（`OR` 操作），`changes` 会解析为 `true`。
- Glob 模式使用 Ruby 的 [`File.fnmatch`](https://docs.ruby-lang.org/en/master/File.html#method-c-fnmatch) 以及 [标志](https://docs.ruby-lang.org/en/master/File/Constants.html#module-File::Constants-label-Filename+Globbing+Constants+-28File-3A-3AFNM_-2A-29) `File::FNM_PATHNAME | File::FNM_DOTMATCH | File::FNM_EXTGLOB` 进行解释。
- 如果你使用 `branches`、`external_pull_requests` 或 `merge_requests` 以外的引用，`changes` 无法确定给定文件是新文件还是旧文件，并且始终返回 `true`。
- 如果你将 `only: changes` 与其他引用一起使用，作业将忽略更改并始终运行。
- 如果你将 `except: changes` 与其他引用一起使用，作业将忽略更改并且从不运行。

<a id="onlykubernetes--exceptkubernetes"></a>

### `only:kubernetes` / `except:kubernetes`

> [!note]
> `only:kubernetes` 和 `except:kubernetes` 已弃用。要在项目中 Kubernetes 服务处于活动状态时控制是否将作业添加到流水线，请使用带有 [`CI_KUBERNETES_ACTIVE`](../variables/predefined_variables.md) 预定义 CI/CD 变量的 [`rules:if`](_index.md#rulesif) 代替。

使用 `only:kubernetes` 或 `except:kubernetes` 来控制当项目中 Kubernetes 服务处于活动状态时是否将作业添加到流水线。

**关键字类型**：特定于作业。你只能将其用作作业的一部分。

**支持的值**：

- `kubernetes` 策略仅接受 `active` 关键字。

**`only:kubernetes` 示例**：

```yaml
deploy:
  only:
    kubernetes: active
```

在此示例中，仅当项目中 Kubernetes 服务处于活动状态时，`deploy` 作业才会运行。

<a id="publish-keyword-and-pages-job-name-for-gitlab-pages"></a>

## `publish` 关键字和用于 极狐GitLab Pages 的 `pages` 作业名称

作业级别的 `publish` 关键字以及用于 极狐GitLab Pages 部署作业的 `pages` 作业名称已弃用。

要控制 pages 部署，请改用 [`pages`](_index.md#pages) 和 [`pages.publish`](_index.md#pagespublish) 关键字。

<a id="environmentkubernetesnamespace-and-environmentkubernetesflux_resource_path"></a>

## `environment:kubernetes:namespace` 和 `environment:kubernetes:flux_resource_path`

> [!note]
> 在 `kubernetes` 下直接使用 `environment:kubernetes:namespace` 和 `environment:kubernetes:flux_resource_path` 已弃用。要配置仪表盘设置，请改用 `environment:kubernetes:dashboard:namespace` 和 `environment:kubernetes:dashboard:flux_resource_path`。有关更多信息，请参见 [`environment:kubernetes`](_index.md#environmentkubernetes)。

你可以使用 `environment:kubernetes:namespace` 和 `environment:kubernetes:flux_resource_path` 来配置 Kubernetes 仪表盘设置，但在 `kubernetes` 部分下直接使用它们已弃用。

**关键字类型**：作业关键字。你只能将其用作作业的一部分。

**`environment:kubernetes:namespace` 和 `environment:kubernetes:flux_resource_path` 示例**：

```yaml
deploy:
  environment:
    name: production
    kubernetes:
      agent: path/to/agent/project:agent-name
      namespace: my-namespace
      flux_resource_path: helm.toolkit.fluxcd.io/v2/namespaces/flux-system/helmreleases/helm-release
```

**`environment:kubernetes:dashboard:namespace` 和 `environment:kubernetes:dashboard:flux_resource_path` 示例**：

```yaml
deploy:
  environment:
    name: production
    kubernetes:
      agent: path/to/agent/project:agent-name
      dashboard:
        namespace: my-namespace
        flux_resource_path: helm.toolkit.fluxcd.io/v2/namespaces/flux-system/helmreleases/helm-release
```