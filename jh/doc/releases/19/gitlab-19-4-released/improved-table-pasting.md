---
title: 改进了富文本编辑器中的表格粘贴
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: plan
documentation_link: "../../../user/rich_text_editor/#paste-into-a-table-cell"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/627112
categories: [ Text Editors ]
level: secondary
---

此前，将复制的表格粘贴到表格单元格中时，复制的单元格总是会合并到现有表格中，这使得创建嵌套表格变得困难。

现在，您可以选择粘贴表格的行为方式：

- 选择**粘贴到单元格中**，将复制的表格作为嵌套表格插入到该单元格中。
- 选择**粘贴并合并到表格中**，将复制的单元格分布到现有表格中，这仍是默认行为。

您还可以使用键盘快捷键将表格作为嵌套表格粘贴到单元格中：在 macOS 上使用 <kbd>Command</kbd>+<kbd>Option</kbd>+<kbd>V</kbd>，在 Windows 和 Linux 上使用 <kbd>Control</kbd>+<kbd>Alt</kbd>+<kbd>V</kbd>。

使用 <kbd>Control</kbd>+<kbd>V</kbd> 或 <kbd>Command</kbd>+<kbd>V</kbd> 进行的标准粘贴与之前一样。
