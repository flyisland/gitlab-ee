---
stage: AI-powered
group: Agent Foundations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 转换为极狐GitLab CI/CD 流程
---

{{< details >}}

- Tier: [基础版](../../../../subscriptions/gitlab_credits.md#for-the-free-tier-on-gitlabcom)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 作为 [测试版](../../../../policy/development_stages_support.md) 引入于极狐GitLab 18.3，[带有一个功能标志](../../../../administration/feature_flags/_index.md) 名为 `duo_workflow_in_ci`。默认禁用，但可以为实例或用户启用。
- 功能标志 `duo_workflow_in_ci` 在极狐GitLab 18.4 中默认启用。功能标志 `duo_workflow` 也必须启用，但它是默认启用的。
- 在极狐GitLab 18.8 GA。
- 功能标志 `duo_workflow_in_ci` 和 `duo_workflow` 在极狐GitLab 18.9 中被移除。
- 在极狐GitLab 18.10，在 JihuLab.com 的基础版上通过极狐GitLab 积分可用。

{{< /history >}}

转换为极狐GitLab CI/CD 流程可帮助您将 Jenkins 流水线迁移到极狐GitLab CI/CD。此流程：

- 分析您现有的 Jenkins 流水线配置。
- 将 Jenkins 流水线语法转换为极狐GitLab CI/CD YAML。
- 推荐极狐GitLab CI/CD 实施的最佳实践。
- 创建一个包含转换后流水线配置的合并请求。
- 提供有关将 Jenkins 插件迁移到极狐GitLab 功能的指导。

此流程仅在极狐GitLab UI 中可用。

<a id="prerequisites"></a>

## 先决条件

要转换 Jenkinsfile，您必须：

- 有权访问您的 Jenkins 流水线配置。
- 在目标极狐GitLab 项目中具有开发者、维护者或所有者角色。
- 满足 [其他先决条件](../../_index.md#prerequisites)。
- [确保极狐GitLab Duo 服务账号可以创建提交和分支](../../troubleshooting.md#session-is-stuck-in-created-state)。
- 确保 **允许内置任务流** 和 **转换为极狐GitLab CI/CD** 在顶级群组中已 [开启](_index.md#turn-foundational-flows-on-or-off)。

<a id="use-the-flow"></a>

## 使用流程

要将您的 Jenkinsfile 转换为极狐GitLab CI/CD：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 打开您的 Jenkinsfile。
1. 在文件上方，选择 **转换为极狐GitLab CI/CD**。
1. 通过选择 **AI** > **会话** 监控进度。
1. 当流水线成功执行后，在左侧边栏中，选择 **代码** > **合并请求**。
   将显示一个标题为 `Duo Workflow: Convert to GitLab CI` 的合并请求。
1. 查看合并请求并根据需要做出更改。

<a id="conversion-process"></a>

### 转换过程

该过程转换：

- 流水线阶段和步骤。
- 环境变量。
- 构建触发器和参数。
- 产物和依赖项。
- 并行执行。
- 条件逻辑。
- 构建后操作。

<a id="example"></a>

## 示例

Jenkinsfile 输入：

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm build'
            }
        }
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        stage('Deploy') {
            when { branch 'main' }
            steps {
                sh './deploy.sh'
            }
        }
    }
}
```

极狐GitLab 输出：

```yaml
stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - npm install
    - npm build
  artifacts:
    paths:
      - node_modules/
      - dist/

test:
  stage: test
  script:
    - npm test

deploy:
  stage: deploy
  script:
    - ./deploy.sh
  only:
    - main
```
