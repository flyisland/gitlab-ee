---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 Web 浏览器在安全环境中编写代码。
title: 远程开发
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

远程开发是一组功能，您可以使用这些功能修改代码，而无需在本地安装任何依赖项或克隆任何代码仓库。这些功能包括：

- [Web IDE](#web-ide)
- [工作区](#workspaces)

<a id="web-ide"></a>

## Web IDE

您可以使用 [Web IDE](../web_ide/_index.md) 直接从 Web 浏览器对项目进行更改、提交和推送。这样，您无需在本地安装任何依赖项或克隆任何代码仓库，即可更新任何项目。

不过，Web IDE 缺少原生运行时环境，无法在其中编译代码、运行测试或生成实时反馈。

<a id="workspaces"></a>

## 工作区

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

您可以使用[工作区](../../workspace/_index.md)直接从极狐GitLab 创建功能完备的开发环境。该环境在远程服务器上运行，为您提供完整的 IDE 体验，而无需在本地安装任何依赖项或克隆代码仓库。

使用工作区，您可以：

- 创建新的开发环境。
- 访问功能完备的 IDE，包括代码编辑器、终端和构建工具。
- 将工作区与极狐GitLab 的其他功能集成，包括合并请求和 CI/CD 流水线。
