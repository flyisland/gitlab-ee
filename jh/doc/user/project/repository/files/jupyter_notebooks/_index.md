---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab projects display Jupyter Notebook files as clean, human-readable files instead of raw files.
title: Jupyter Notebook 文件
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[Jupyter Notebook](https://jupyter.org/)（以前是 IPython Notebook）文件用于许多领域的交互式计算。它们包含用户会话的完整记录，包括：

- 代码。
- 叙事文本。
- 方程式。
- 丰富输出。

当你将 Jupyter Notebook（扩展名为 `.ipynb`）添加到仓库时，查看它时会渲染成 HTML：

![Jupyter Notebook 丰富输出](img/jupyter_notebook_v17_10.png)

交互功能（包括 JavaScript 图表）在极狐GitLab 中查看时不可用。

<a id="cleaner-diffs-and-raw-diffs"></a>

## 更清晰的差异和原始差异

当提交包含对 Jupyter Notebook 文件的更改时，极狐GitLab 会：

- 将机器可读的 `.ipynb` 文件转换为人类可读的 Markdown 文件。
- 显示包含语法高亮的更清晰的差异版本。
- 允许在提交和比较页面上切换原始差异和渲染后的差异。（在合并请求页面上不可用。）
- 在差异上渲染图片。

对于 `.ipynb` 文件，差异和合并请求中代码建议不可用。

笔记本太大时，不会生成更清晰的笔记本差异。

<a id="jupyter-git-integration"></a>

## Jupyter Git 集成

Jupyter 可以配置为具有仓库访问权限的 OAuth 应用程序，代表已认证用户执行操作。有关配置示例，请参见 [runbooks](../../../clusters/runbooks/_index.md)。