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

在开始从其他工具迁移到极狐GitLab CI/CD 之前，您应当先制定迁移计划。

请先阅读关于[管理组织变更](#manage-organizational-changes)的建议，了解较大规模迁移的初始步骤。

参与迁移的用户应阅读[开始迁移前要问的问题](#technical-questions-to-ask-before-starting-a-migration)，这是设定预期的重要技术步骤。CI/CD 工具在方法、结构和技术细节上各不相同。有些概念可以一一对应，另一些则需要交互式转换。

重要的是关注您期望的最终状态，而不是严格照搬旧工具的行为。

<a id="manage-organizational-changes"></a>

## 管理组织变更

迁移到极狐GitLab CI/CD 的一个重要部分是随之而来的文化和组织变更，以及如何成功管理这些变更。

各组织反馈过一些有帮助的做法：

- 设定并传达清晰的迁移目标愿景，这有助于您的用户理解为什么这项工作值得投入。
  工作完成时价值显而易见，但在进行过程中也需要让大家知晓。
- 相关领导团队的支持和协调有助于实现上一点。
- 花时间教育您的用户了解有哪些不同之处，并与他们分享本指南。
- 找到对迁移的某些部分进行排序或延后的方法会很有帮助。但重要的是，
  尽量不要让内容长时间处于未迁移（或部分迁移）的状态。
- 要获得极狐GitLab 的全部优势，仅将现有配置原样迁移过来，
  包括当前存在的问题，是不够的。请利用极狐GitLab CI/CD 提供的改进，
  并在迁移过程中更新您的实现。

<a id="technical-questions-to-ask-before-starting-a-migration"></a>

## 开始迁移前要问的技术问题

就您的 CI/CD 需求提出一些初始技术问题，有助于快速确定迁移需求：

- 有多少项目使用此流水线？
- 使用什么分支策略？功能分支？主线？发布分支？
- 您使用什么工具构建代码？例如 Maven、Gradle 或 NPM？
- 您使用什么工具测试代码？例如 JUnit、Pytest 或 Jest？
- 您是否使用安全扫描器？
- 您将构建的软件包存储在哪里？
- 您如何部署代码？
- 您将代码部署到哪里？
