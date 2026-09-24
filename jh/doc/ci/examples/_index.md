---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Examples and community-contributed guides for implementing GitLab CI/CD across languages, frameworks, and deployment targets.
title: CI/CD 示例
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用这些示例为您的特定用例实施 [极狐GitLab CI/CD](../_index.md)。

## 示例

| 用例 | 资源 |
| ----------------------------- | -------- |
| 使用 Dpl 进行部署 | [使用 Dpl 工具部署应用程序](deployment/_index.md) |
| 极狐GitLab Pages | [通过自动 CI/CD 部署发布静态网站](../../user/project/pages/_index.md) |
| 多项目流水线 | [使用多项目流水线进行构建、测试和部署](https://jihulab.com/gitlab-examples/upstream-project) |
| 使用 semantic-release 的 npm | [将 npm 软件包发布到极狐GitLab 软件包仓库](semantic-release.md) |
| 使用 SCP 的 Composer 和 npm | [使用 SCP 部署 Composer 和 npm 脚本](deployment/composer-npm-deploy.md) |
| 使用 PHPUnit 和 `atoum` 的 PHP | [测试 PHP 项目](php.md) |
| 使用 Vault 进行密钥管理 | [使用 HashiCorp Vault 进行身份验证并读取密钥](../secrets/hashicorp_vault_tutorial.md) |

## 社区贡献的示例

这些示例由社区维护，而非 极狐GitLab。
大多数示例项目托管在 极狐GitLab 上，您可以派生并调整它们以满足自己的需求。

| 用例 | 资源 |
| -------------------------- | -------- |
| Clojure | [测试 Clojure 应用程序](https://jihulab.com/gitlab-examples/clojure-web-application) |
| 游戏开发 | [为游戏开发设置 CI/CD](https://jihulab.com/gitlab-examples/gitlab-game-demo/) |
| 使用 Maven 的 Java | [将 Maven 项目部署到 Artifactory](https://jihulab.com/gitlab-examples/maven/simple-maven-example) |
| 使用 Spring Boot 的 Java | [将 Spring Boot 应用程序部署到 Cloud Foundry](https://jihulab.com/gitlab-examples/spring-gitlab-cf-deploy-demo) |
| Ruby 和 JS 的并行测试 | [为 Ruby 和 JavaScript 运行并行测试](https://docs.knapsackpro.com/2019/how-to-run-parallel-jobs-for-rspec-tests-on-gitlab-ci-pipeline-and-speed-up-ruby-javascript-testing) |
| 在 Heroku 上的 Python | [测试 Python 应用程序并将其部署到 Heroku](https://jihulab.com/gitlab-examples/python-getting-started) |
| 使用 NGINX 的审查应用 | [使用 NGINX 设置审查应用](https://jihulab.com/gitlab-examples/review-apps-nginx/) |
| 在 Heroku 上的 Ruby | [测试 Ruby 应用程序并将其部署到 Heroku](https://jihulab.com/gitlab-examples/ruby-getting-started) |
| 在 Heroku 上的 Scala | [测试 Scala 应用程序并将其部署到 Heroku](https://jihulab.com/gitlab-examples/scala-sbt) |

## CI/CD 迁移示例

- [Bamboo](../migration/bamboo.md)
- [CircleCI](../migration/circleci.md)
- [GitHub Actions](../migration/github_actions.md)
- [Jenkins](../migration/jenkins.md)
- [TeamCity](../migration/teamcity.md)

## 相关主题

- [CI/CD 目录](../components/_index.md#cicd-catalog)
- [教程：构建您的应用程序](../../tutorials/build_application.md)
- [示例项目](https://jihulab.com/gitlab-examples)