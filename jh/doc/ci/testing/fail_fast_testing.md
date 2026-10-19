---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 仅运行与您的合并请求更改相关的 RSpec 测试用例，以便更快获得流水线反馈。
title: 快速失败测试
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

快速失败测试会在其余测试套件运行之前，先运行与您的合并请求更改最相关的测试用例。如果这些测试用例失败，流水线会立即停止，以节省时间和计算资源。

对于使用 RSpec 的 Ruby on Rails 项目，
[`Verify/FailFast` CI/CD 模板](https://jihulab.com/gitlab-cn/gitlab/-/blob/main-jh/lib/gitlab/ci/templates/Verify/FailFast.gitlab-ci.yml)
会选择并仅运行相关的测试用例。它使用
[`test_file_finder`（`tff`）gem](https://gitlab.com/gitlab-org/ruby/gems/test_file_finder)，
该 gem 会将更改的文件映射到其相关的测试用例文件。

默认情况下，该模板在[`.pre` 阶段](../yaml/_index.md#stage-pre)运行，即所有其他流水线阶段之前。

<a id="configure-fail-fast-testing"></a>

## 配置快速失败测试

配置快速失败测试，以便在完整测试套件运行之前，更快地获得关于合并请求更改的反馈。

先决条件：

- 使用 RSpec 的 Ruby on Rails 项目。
- 在项目设置中启用[合并结果流水线](../pipelines/merged_results_pipelines.md#enable-merged-results-pipelines)。
  这还要求启用
  [合并请求流水线](../pipelines/merge_request_pipelines.md#prerequisites)。

要配置快速失败测试：

1. 添加一个 RSpec 作业，在合并请求流水线上运行完整测试套件：

   ```yaml
   rspec-complete:
     stage: test
     rules:
       - if: $CI_PIPELINE_SOURCE == "merge_request_event"
     script:
       - bundle install
       - bundle exec rspec
   ```

1. 在您的 CI/CD 配置中包含 `Verify/FailFast` 模板：

   ```yaml
   include:
     - template: Verify/FailFast.gitlab-ci.yml
   ```

1. 可选。要使用其他 Docker 镜像，请在 CI/CD 配置文件中为
   `rspec-rails-modified-path-specs` 作业设置镜像：

   ```yaml
   include:
     - template: Verify/FailFast.gitlab-ci.yml

   rspec-rails-modified-path-specs:
     image: custom-docker-image-with-ruby
   ```

<a id="fail-fast-test-results"></a>

## 快速失败测试结果

以下示例假设每个模型有 100 个测试用例，共 10 个模型（总计 1000 个测试用例）。

| 更改的文件                            | `rspec-rails-modified-path-specs` | `rspec-complete` |
| ---------------------------------------- | --------------------------------- | ---------------- |
| 没有 Ruby 文件                            | 不运行                      | 运行全部 1000 个测试用例 |
| `app/models/example.rb`（所有测试用例通过） | 为 `example.rb` 运行 100 个测试用例   | 运行全部 1000 个测试用例 |
| `app/models/example.rb`（任一测试用例失败） | 为 `example.rb` 运行 100 个测试用例   | 已跳过          |
