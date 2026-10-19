---
stage: Agent Foundations
group: Agent Developer
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 转换为极狐GitLab CI/CD 任务流
---

{{< details >}}

- Tier: [基础版](../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

转换为极狐GitLab CI/CD 任务流可帮助您将 Jenkins 流水线迁移到极狐GitLab CI/CD。此任务流可以：

- 分析您现有的 Jenkins 流水线配置。
- 将 Jenkins 流水线语法转换为极狐GitLab CI/CD YAML。
- 为极狐GitLab CI/CD 实施提供最佳实践建议。
- 创建一个包含转换后流水线配置的合并请求。
- 提供将 Jenkins 插件迁移到极狐GitLab 功能的指导。

此任务流仅在极狐GitLab UI 中可用。

<a id="prerequisites"></a>

## 先决条件

- 满足[极狐GitLab Duo Agent Platform 的先决条件](../../user/duo_agent_platform/_index.md#prerequisites)。
- 为顶级群组[开启**允许内置任务流**和**转换为极狐GitLab CI/CD**](../../user/duo_agent_platform/flows/foundational_flows/_index.md#turn-foundational-flows-on-or-off)。
- 拥有目标极狐GitLab 项目的开发者、维护者或所有者角色。
- 有权访问您的 Jenkins 流水线配置。
- [配置推送规则以允许服务账号](../../user/duo_agent_platform/troubleshooting.md#configure-push-rules-to-allow-a-service-account)。
- [配置您自己的 Runner](../../user/duo_agent_platform/flows/execution/_index.md#configure-runners-to-execute-flows)，或为您的项目开启[极狐GitLab 托管 Runner](../../ci/runners/hosted_runners/_index.md)。
- 建议：创建 [Agent 配置文件](../../user/duo_agent_platform/flows/execution/_index.md#create-the-agent-configuration-file)，以便该任务流可以访问您项目的工具链和依赖项。

<a id="use-the-flow"></a>

## 使用该任务流

要将您的 Jenkinsfile 转换为极狐GitLab CI/CD：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 打开您的 Jenkinsfile。
1. 在文件上方，选择**转换为极狐GitLab CI/CD**。
1. 通过选择 **AI** > **会话**来监控进度。
1. 当流水线成功执行后，在左侧边栏中，选择**代码** > **合并请求**。
   此时会显示一个标题为 `Duo Workflow: Convert to GitLab CI`的合并请求。
1. 审阅该合并请求，并根据需要进行更改。

<a id="conversion-process"></a>

### 转换过程

该过程会转换：

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
