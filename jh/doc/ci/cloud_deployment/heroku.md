---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Deploy a GitLab project to Heroku by using GitLab CI/CD.
title: 使用极狐GitLab CI/CD 部署到 Heroku
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以使用极狐GitLab CI/CD 将应用程序部署到 Heroku。

<a id="prerequisites"></a>

## 先决条件

- 一个 [Heroku](https://id.heroku.com/login) 账户。使用现有 Heroku 账户登录或创建一个新账户。

<a id="deploy-to-heroku"></a>

## 部署到 Heroku

1. 在 Heroku 中：
   1. 创建一个应用程序并复制应用程序名称。
   1. 浏览到 **账户设置** 并复制 API 密钥。
1. 在你的极狐GitLab 项目中，创建两个 [变量](../variables/_index.md)：
   - `HEROKU_APP_NAME` 用于应用程序名称。
   - `HEROKU_PRODUCTION_KEY` 用于 API 密钥
1. 编辑你的 `.gitlab-ci.yml` 文件，添加 Heroku 部署命令。此示例使用 Ruby 的 `dpl` gem：

   ```yaml
   heroku_deploy:
     stage: production
     script:
       - gem install dpl
       - dpl --provider=heroku --app=$HEROKU_APP_NAME --api-key=$HEROKU_PRODUCTION_KEY
   ```

