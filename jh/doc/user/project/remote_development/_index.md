---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use your web browser to write code in a secure environment.
title: 极狐GitLab 远程开发
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

远程开发是一组功能，你可以在无需安装任何依赖项或克隆任何仓库到本地的情况下进行代码更改。这些功能包括：

- [Web IDE](#web-ide)
- [Workspaces](#workspaces)

<a id="web-ide"></a>

## Web IDE

你可以使用 [Web IDE](../web_ide/_index.md) 直接从网络浏览器对项目进行更改、提交和推送。这样，你无需安装任何依赖项或克隆仓库到本地即可更新任何项目。然而，Web IDE 缺少原生运行时环境，无法编译代码、运行测试或生成实时反馈。

<a id="workspaces"></a>

## Workspaces

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

你可以使用 [workspaces](../../workspace/_index.md) 直接从极狐GitLab 创建功能齐全的开发环境。此环境运行在远程服务器上，并为你提供完整的 IDE 体验，而无需安装任何依赖项或克隆仓库到本地。通过工作空间，你可以：

- 创建新的开发环境。
- 访问功能齐全的 IDE，包括代码编辑器、终端和构建工具。
- 将你的工作空间与极狐GitLab 的其他部分集成，包括合并请求和 CI/CD 流水线。