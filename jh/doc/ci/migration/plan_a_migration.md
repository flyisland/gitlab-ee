---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 规划从其他工具迁移到极狐GitLab CI/CD
description: 从 Jenkins、GitHub Actions 等工具迁移。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在开始从其他工具迁移到极狐GitLab CI/CD 之前，您应该先制定一份迁移计划。

首先查看[管理组织变更](#manage-organizational-changes)的建议，了解大型迁移的初始步骤。

参与迁移的用户应阅读[开始迁移前要问的技术问题](#technical-questions-to-ask-before-starting-a-migration)，这是设定预期的重要技术步骤。CI/CD 工具在方法、结构和技术细节上各有不同。虽然有些概念可以一一对应，但其他概念则需要交互式转换。

重要的是要专注于您期望的最终状态，而不是严格地照搬旧工具的行为。

<a id="manage-organizational-changes"></a>

## 管理组织变更

过渡到极狐GitLab CI/CD 的一个重要部分是随之而来的文化和组织变革，以及如何成功地管理它们。

一些组织报告的有帮助的做法：

- 设定并传达清晰的迁移目标愿景，这有助于用户理解这项努力的价值。完成后的价值显而易见，但在进行过程中也需要让人们了解。
- 相关领导团队的支持和协调有助于实现前一点。
- 花时间教育用户有哪些不同之处，并将本指南分享给他们。
- 想办法将部分迁移分段或延迟会有很大帮助。但重要的是，尽量不要让事物长期处于未迁移（或部分迁移）的状态。
- 要获得极狐GitLab的全部收益，仅仅将现有配置原封不动地搬过来（包括任何现有问题）是不够的。要利用极狐GitLab CI/CD 提供的改进，在过渡过程中更新您的实现。

<a id="technical-questions-to-ask-before-starting-a-migration"></a>

## 开始迁移前要问的技术问题

提出一些关于 CI/CD 需求的初始技术问题有助于快速确定迁移要求：

- 有多少项目使用此流水线？
- 使用什么分支策略？功能分支？主线分支？发布分支？
- 您使用什么工具来构建代码？例如 Maven、Gradle 或 NPM？
- 您使用什么工具来测试代码？例如 JUnit、Pytest 或 Jest？
- 您是否使用任何安全扫描器？
- 您将构建的软件包存储在哪里？
- 您如何部署代码？
- 您将代码部署在哪里？

## 相关主题

- 如何将 Atlassian Bamboo Server 的 CI/CD 基础设施迁移到极狐GitLab CI/CD，[第一部分](https://about.gitlab.com/blog/migration-from-atlassian-bamboo-server-to-gitlab-ci/)和[第二部分](https://about.gitlab.com/blog/how-to-migrate-atlassians-bamboo-servers-ci-cd-infrastructure-to-gitlab-ci-part-two/)
