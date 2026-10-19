---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: howto
---

# 禁用极狐GitLab CI/CD **(BASIC ALL)**

极狐GitLab CI/CD 默认在所有新项目上启用。

如果您使用外部 CI/CD 服务器，如 Jenkins 或 Drone CI，您可以禁用极狐GitLab CI/CD 以避免与提交状态 API 发生冲突。

您可以禁用极狐GitLab CI/CD：

- [为每个项目](#disable-cicd-in-a-project)。
- [为所有实例上的新项目](../administration/cicd.md)。

这些更改不适用于[外部集成](../user/project/integrations/index.md#available-integrations)中的项目。

## 禁用项目中的 CI/CD

当您禁用了极狐GitLab CI/CD：

- 删除了左侧边栏中的 **CI/CD** 项目。
- `/pipelines` 和 `/jobs` 页面不再可用。
- 现有的作业和流水线是隐藏的，不会删除。

要在项目中禁用极狐GitLab CI/CD：

1. 在左侧边栏中，选择 **搜索或转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置 > 通用**。
1. 展开 **可见性，项目功能，权限**。
1. 在 **仓库** 部分，关闭 **CI/CD**。
1. 选择 **保存更改**。

<a id="enable-cicd-in-a-project"></a>

## 在项目中启用 CI/CD

要在项目中启用极狐GitLab CI/CD：

1. 在左侧边栏中，选择 **搜索或转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置 > 通用**。
1. 展开 **可见性、项目功能、权限**。
1. 在 **仓库** 部分，打开 **CI/CD**。
1. 选择 **保存更改**。

<!-- ## Troubleshooting

Include any troubleshooting steps that you can foresee. If you know beforehand what issues
one might have when setting this up, or when something is changed, or on upgrading, it's
important to describe those, too. Think of things that may go wrong and include them here.
This is important to minimize requests for support, and to avoid doc comments with
questions that you know someone might ask.

Each scenario can be a third-level heading, e.g. `### Getting error message X`.
If you have none to add when creating a doc, leave this section in place
but commented out to help encourage others to add to it in the future. -->
