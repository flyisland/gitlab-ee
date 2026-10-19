---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
description: Guide to integrating Snyk with GitLab CI/CD for application security, including workflow setup, SARIF scanning, and vulnerability reporting.
title: 极狐GitLab 应用安全集成 Snyk 工作流
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="getting-started"></a>

## 入门

<a id="download-the-solution-component"></a>

### 下载解决方案组件

1. 从您的客户团队获取邀请码。
1. 使用邀请码从[解决方案组件商店](https://cloud.gitlab-accelerator-marketplace.com)下载解决方案组件。

<a id="snyk-integration"></a>

## Snyk 集成

这是通过极狐GitLab CI/CD 组件实现 Snyk 与极狐GitLab CI 之间的集成。

<a id="snyk-workflow"></a>

## Snyk 工作流

此项目包含一个组件，该组件运行 Snyk CLI 并以 SARIF 格式输出扫描报告。它调用另一个组件，该组件使用基于 semgrep 基础镜像的作业将 SARIF 转换为极狐GitLab 漏洞记录格式。

容器镜像仓库中有一个带版本的容器，该容器基于 node 基础镜像并在其上安装了 Snyk CLI。这是 Snyk 组件作业中使用的镜像。
`.gitlab-ci.yml` 文件构建容器镜像、进行测试并对组件进行版本管理。

<a id="versioning"></a>

### 版本管理

此项目遵循语义化版本管理。