---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 信息排除
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

<a id="git-is-a-distributed-version-control-system-dvcs"></a>

## Git 是一个分布式版本控制系统 (DVCS)

这意味着每个与源代码一起工作的人都拥有完整的本地存储库副本。

在极狐GitLab 中，每个项目成员（访客除外，如报告者、开发人员和维护者）都可以克隆存储库以创建本地副本。获得本地副本后，用户可以将完整的存储库上传到任何地方，包括他们控制下的另一个项目或另一台服务器。

因此，无法构建访问控制来阻止用户有意共享源代码。

这是 DVCS 的固有特性。所有 Git 管理系统都有此限制。

您可以采取措施防止无意共享和信息破坏。此限制是为什么只有特定人员被允许[向项目添加用户](../user/project/members/_index.md)，以及为什么只有极狐GitLab 管理员可以[强制推送受保护的分支](../user/project/repository/branches/protected.md)的原因。
