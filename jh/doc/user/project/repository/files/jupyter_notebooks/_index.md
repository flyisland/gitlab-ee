---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab 项目会将 Jupyter Notebook 文件显示为整洁、易于阅读的文件，而不是原始文件。
title: Jupyter Notebook 文件
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[Jupyter Notebook](https://jupyter.org/)（以前称为 IPython Notebook）文件用于许多领域的交互式计算。它们包含用户会话的完整记录，并包括：

- 代码。
- 叙述性文本。
- 方程式。
- 丰富的输出。

当您将 Jupyter Notebook（扩展名为 `.ipynb`）添加到代码仓库时，查看它时会将其渲染为 HTML：

![Jupyter Notebook 丰富的输出](img/jupyter_notebook_v17_10.png)

在极狐GitLab 中查看时，包括 JavaScript 图表在内的交互式功能无法正常工作。

<a id="cleaner-diffs-and-raw-diffs"></a>

## 更整洁的差异和原始差异

当提交包含对 Jupyter Notebook 文件的更改时，极狐GitLab 会：

- 将机器可读的 `.ipynb` 文件转换为人类可读的 Markdown 文件。
- 显示包含语法高亮的更整洁版本的差异。
- 允许在提交和比较页面上在原始差异和渲染差异之间切换。（在合并请求页面上不可用。）
- 在差异中渲染图像。

代码建议不适用于 `.ipynb` 文件的差异和合并请求。

当 notebook 过大时，不会生成更整洁的 notebook 差异。

<a id="jupyter-git-integration"></a>

## Jupyter Git 集成

Jupyter 可以配置为具有代码仓库访问权限的 OAuth 应用程序，代表已认证用户执行操作。有关配置示例，请参见 [runbooks](../../../clusters/runbooks/_index.md)。
