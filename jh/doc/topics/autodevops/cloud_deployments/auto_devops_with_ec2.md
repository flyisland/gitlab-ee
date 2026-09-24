---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Auto DevOps 部署到 EC2
---

要使用 [Auto DevOps](../_index.md) 部署到 EC2：

1. 将 [您的 AWS 凭证定义为 CI/CD 变量](../../../ci/cloud_deployment/_index.md#authenticate-gitlab-with-aws)。
1. 在您的 `.gitlab-ci.yml` 文件中引用 `Auto-Devops.gitlab-ci.yml` 模板。
1. 为 `build` 阶段定义一个名为 `build_artifact` 的作业。例如：

   ```yaml
   # .gitlab-ci.yml

   include:
     - template: Auto-DevOps.gitlab-ci.yml

   variables:
     AUTO_DEVOPS_PLATFORM_TARGET: EC2

   build_artifact:
     stage: build
     script:
       - <你的构建脚本放在这里>
     artifacts:
       paths:
         - <构建产物>
   ```