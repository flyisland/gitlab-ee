---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Run only relevant RSpec tests using the fail-fast template to get faster feedback on code changes.
title: 快速失败测试
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

对于使用 RSpec 运行测试的应用程序，你可以根据合并请求中的更改，使用 `Verify/Failfast` [模板运行测试套件子集](https://jihulab.com/gitlab-cn/gitlab/-/tree/master/lib/gitlab/ci/templates/Verify/FailFast.gitlab-ci.yml)。

该模板使用 [`test_file_finder` (`tff`) gem](https://jihulab.com/gitlab-cn/ruby/gems/test_file_finder)，该 gem 接受文件列表作为输入，并返回它认为与输入文件相关的 spec（测试）文件列表。

`tff` 专为 Ruby on Rails 项目而设计，因此 `Verify/FailFast` 模板被配置为在检测到 Ruby 文件更改时运行。默认情况下，它在极狐GitLab CI/CD 流水线的 [`.pre` 阶段](../yaml/_index.md#stage-pre) 中运行，位于所有其他阶段之前。

<a id="example-use-case"></a>

## 示例用例

快速失败测试在向项目添加新功能并添加新自动化测试时非常有用。

你的项目可能有成千上万个测试，需要很长时间才能完成。你可能期望某个新测试通过，但必须等待所有测试完成才能验证。即使使用并行化，这可能需要一个小时或更长时间。

快速失败测试让你能够从流水线中获得更快的反馈循环。它可以让你快速知道新测试是否通过，以及新功能没有破坏其他测试。

<a id="prerequisites"></a>

## 先决条件

该模板需要：

- 一个使用 RSpec 进行测试的 Rails 项目。
- 配置 CI/CD 以：
  - 使用包含 Ruby 的 Docker 镜像。
  - 使用[合并请求流水线](../pipelines/merge_request_pipelines.md#prerequisites)
- 在项目设置中启用[合并结果流水线](../pipelines/merged_results_pipelines.md#enable-merged-results-pipelines)。
- 一个包含 Ruby 的 Docker 镜像。模板默认使用 `image: ruby:2.6`，但你可以[覆盖此设置](../yaml/includes.md#override-included-configuration-values)。

<a id="configuring-fast-rspec-failure"></a>

## 配置快速 RSpec 失败检测

你可以使用以下简单的 RSpec 配置作为起点。它安装所有项目 gem 并仅在合并请求流水线中执行 `rspec`。

```yaml
rspec-complete:
  stage: test
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
  script:
    - bundle install
    - bundle exec rspec
```

要首先运行最相关的 spec 而不是整个套件，请将以下内容添加到你的 CI/CD 配置中，以 [`include`](../yaml/_index.md#include) 模板：

```yaml
include:
  - template: Verify/FailFast.gitlab-ci.yml
```

要自定义作业，可以设置特定选项来覆盖模板。例如，覆盖默认的 Docker 镜像：

```yaml
include:
  - template: Verify/FailFast.gitlab-ci.yml

rspec-rails-modified-path-specs:
  image: custom-docker-image-with-ruby
```

<a id="example-test-loads"></a>

### 示例测试负载

为了说明，我们的 Rails 应用 spec 套件为十个模型每个模型包含 100 个 spec。

如果没有更改任何 Ruby 文件：

- `rspec-rails-modified-paths-specs` 不会运行任何测试。
- `rspec-complete` 运行完整的 1000 个测试。

如果更改了一个 Ruby 模型，例如 `app/models/example.rb`，那么 `rspec-rails-modified-paths-specs` 会运行 `example.rb` 的 100 个测试：

- 如果这 100 个测试全部通过，则允许运行完整的 `rspec-complete` 1000 个测试套件。
- 如果这 100 个测试中有任何一个失败，它们会快速失败，并且 `rspec-complete` 不会运行任何测试。

最后一种情况节省了资源和时间，因为完整的 1000 测试套件没有运行。