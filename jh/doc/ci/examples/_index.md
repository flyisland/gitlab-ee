---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 跨语言、框架和部署目标实施极狐GitLab CI/CD 的示例和社区贡献指南。
title: CI/CD 示例
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用这些示例为您的特定用例实施[极狐GitLab CI/CD](../_index.md)。

<a id="examples"></a>

## 示例

| 用例                          | 资源 |
| ----------------------------- | -------- |
| 使用 Dpl 部署                 | [使用 Dpl 工具部署应用](deployment/_index.md) |
| GitLab Pages                  | [通过自动 CI/CD 部署发布静态网站](../../user/project/pages/_index.md) |
| 多项目流水线        | [使用多项目流水线构建、测试和部署](https://gitlab.com/gitlab-examples/upstream-project) |
| 使用 semantic-release 的 npm  | [将 npm 软件包发布到极狐GitLab 软件包仓库](semantic-release.md) |
| 使用 SCP 的 Composer 和 npm   | [使用 SCP 部署 Composer 和 npm 脚本](deployment/composer-npm-deploy.md) |
| 使用 PHPUnit 和 `atoum`的 PHP  | [测试 PHP 项目](php.md) |
| 使用 Vault 的密钥管理         | [使用 HashiCorp Vault 进行身份验证并读取密钥](../secrets/hashicorp_vault_tutorial.md) |

<a id="community-contributed-examples"></a>

## 社区贡献的示例

这些示例由社区而非 GitLab 维护。大多数示例项目托管在 GitLab 上，您可以 forked 并根据自己的需求进行调整。

| 用例                       | 资源 |
| -------------------------- | -------- |
| Clojure                    | [测试 Clojure 应用](https://gitlab.com/gitlab-examples/clojure-web-application) |
| 游戏开发                   | [为游戏开发设置 CI/CD](https://gitlab.com/gitlab-examples/gitlab-game-demo/) |
| 使用 Maven 的 Java         | [将 Maven 项目部署到 Artifactory](https://gitlab.com/gitlab-examples/maven/simple-maven-example) |
| 使用 Spring Boot 的 Java   | [将 Spring Boot 应用部署到 Cloud Foundry](https://gitlab.com/gitlab-examples/spring-gitlab-cf-deploy-demo) |
| Ruby 和 JS 的并行测试      | [为 Ruby 和 JavaScript 运行并行测试](https://docs.knapsackpro.com/2019/how-to-run-parallel-jobs-for-rspec-tests-on-gitlab-ci-pipeline-and-speed-up-ruby-javascript-testing) |
| Heroku 上的 Python         | [测试 Python 应用并将其部署到 Heroku](https://gitlab.com/gitlab-examples/python-getting-started) |
| 使用 NGINX 的审查应用      | [使用 NGINX 设置审查应用](https://gitlab.com/gitlab-examples/review-apps-nginx/) |
| Heroku 上的 Ruby           | [测试 Ruby 应用并将其部署到 Heroku](https://gitlab.com/gitlab-examples/ruby-getting-started) |
| Heroku 上的 Scala          | [测试 Scala 应用并将其部署到 Heroku](https://gitlab.com/gitlab-examples/scala-sbt) |

<a id="cicd-migration-examples"></a>

## CI/CD 迁移示例

- [Bamboo](../migration/bamboo.md)
- [CircleCI](../migration/circleci.md)
- [GitHub Actions](../migration/github_actions.md)
- [Jenkins](../migration/jenkins.md)
- [TeamCity](../migration/teamcity.md)
