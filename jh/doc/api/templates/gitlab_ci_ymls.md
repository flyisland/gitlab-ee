---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: CI/CD 模板 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 可获取内置的 [CI/CD 模板](https://jihulab.com/gitlab-cn/gitlab/-/tree/master/lib/gitlab/ci/templates)。自定义模板不可用。

拥有访客角色的用户无法访问 CI/CD 模板。更多信息，请参阅[项目和群组可见性](../../user/public_access.md)。

<a id="list-all-ci-cd-templates"></a>

列出所有 CI/CD 模板

列出所有极狐GitLab CI/CD YAML 模板。

```plaintext
GET /templates/gitlab_ci_ymls
```

示例请求：

```shell
curl "https://gitlab.example.com/api/v4/templates/gitlab_ci_ymls"
```

示例响应：

```json
[
  {
    "key": "5-Minute-Production-App",
    "name": "5-Minute-Production-App"
  },
  {
    "key": "Android",
    "name": "Android"
  },
  {
    "key": "Android-Fastlane",
    "name": "Android-Fastlane"
  },
  {
    "key": "Auto-DevOps",
    "name": "Auto-DevOps"
  },
  {
    "key": "Bash",
    "name": "Bash"
  },
  {
    "key": "C++",
    "name": "C++"
  },
  {
    "key": "Chef",
    "name": "Chef"
  },
  {
    "key": "Clojure",
    "name": "Clojure"
  },
  {
    "key": "Code-Quality",
    "name": "Code-Quality"
  },
  {
    "key": "Composer",
    "name": "Composer"
  },
  {
    "key": "Cosign",
    "name": "Cosign"
  },
  {
    "key": "Crystal",
    "name": "Crystal"
  },
  {
    "key": "Dart",
    "name": "Dart"
  },
  {
    "key": "Deploy-ECS",
    "name": "Deploy-ECS"
  },
  {
    "key": "Diffblue-Cover",
    "name": "Diffblue-Cover"
  },
  {
    "key": "Django",
    "name": "Django"
  },
  {
    "key": "Docker",
    "name": "Docker"
  },
  {
    "key": "Elixir",
    "name": "Elixir"
  },
  {
    "key": "Flutter",
    "name": "Flutter"
  },
  {
    "key": "Getting-Started",
    "name": "Getting-Started"
  }
]
```

<a id="retrieve-details-of-a-ci-cd-template"></a>

检索 CI/CD 模板的详细信息

检索特定 CI/CD 模板的详细信息。

```plaintext
GET /templates/gitlab_ci_ymls/:key
```

| 属性 | 类型   | 是否必需 | 描述 |
|-----------|--------|----------|-------------|
| `key`     | string | 是      | 极狐GitLab CI/CD YAML 模板的 key |

示例请求：

```shell
curl "https://gitlab.example.com/api/v4/templates/gitlab_ci_ymls/Ruby"
```

示例响应：

```json
{
  "name": "Ruby",
  "content": "# 此文件是一个模板，可能需要在您的项目中编辑后才能正常使用。\n# 您可以将此模板复制并粘贴到新的 `.gitlab-ci.yml` 文件中。\n# 您不应使用 `include:` 关键字将此模板添加到现有的 `.gitlab-ci.yml` 文件。\n#\n# 若要对 CI/CD 模板贡献改进，请遵循位于以下地址的开发指南：\n# https://gitlab.cn/docs/development/cicd/templates/\n# 此特定模板位于：\n# https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Ruby.gitlab-ci.yml\n\n# 官方语言镜像。查找不同标记版本，请访问：\n# https://hub.docker.com/r/library/ruby/tags/\nimage: ruby:latest\n\n# 选择零个或多个服务用于所有构建。\n# 仅在使用 Docker 容器运行测试时需要。\n# 查阅：https://gitlab.cn/docs/ci/services/\nservices:\n  - mysql:latest\n  - redis:latest\n  - postgres:latest\n\nvariables:\n  POSTGRES_DB: database_name\n\n# 在构建之间缓存 gems\ncache:\n  key:\n    files:\n      - Gemfile.lock\n  paths:\n    - vendor/ruby\n\n# 这是一个基本示例，适用于不使用 redis 或 postgres 等服务的 gem 或脚本\nbefore_script:\n  - ruby -v  # 输出 Ruby 版本以进行调试\n  # 如果您的 Rails 应用需要 JS 运行时，请取消注释下一行：\n  # - apt-get update -q && apt-get install nodejs -yqq\n  - bundle config set --local deployment true\n  - bundle config set --local path './vendor/ruby' # 将依赖项安装到 ./vendor/ruby\n  - bundle install -j $(nproc)\n\n# 可选 - 如果不使用 `rubocop`，请删除\nrubocop:\n  script:\n    - rubocop\n\nrspec:\n  script:\n    - rspec spec\n\nrails:\n  variables:\n    DATABASE_URL: \"postgresql://postgres:postgres@postgres:5432/$POSTGRES_DB\"\n  script:\n    - rails db:migrate\n    - rails db:seed\n    - rails test\n\n# 此部署任务使用简单的部署流程到 Heroku，其他提供商（例如 AWS Elastic Beanstalk）也受支持：https://github.com/travis-ci/dpl\ndeploy:\n  stage: deploy\n  environment: production\n  script:\n    - gem install dpl\n    - dpl --provider=heroku --app=$HEROKU_APP_NAME --api-key=$HEROKU_PRODUCTION_KEY\n"
}
```