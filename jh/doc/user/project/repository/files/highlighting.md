---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 语法高亮可帮助您阅读极狐GitLab 项目中的文件，并识别文件包含的内容。
title: 语法高亮
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 通过两个互补的系统为文件提供语法高亮：

- [Rouge](https://rubygems.org/gems/rouge)（Ruby gem）：服务端高亮，在极狐GitLab 服务器上处理文件。它用于：
  - 代码仓库文件查看
  - 合并请求差异
  - 提交差异
  - 比较视图
  - 追溯视图
- [Highlight.js](https://github.com/highlightjs/highlight.js/)：客户端高亮，在您的浏览器中运行。它用于在浏览器中查看受支持语言的代码仓库文件。

此处的路径使用 Git 中的 [`.gitattributes` 接口](https://git-scm.com/docs/gitattributes)。

> [!note]
> [Web IDE](../../web_ide/_index.md) 和[代码片段](../../../snippets.md)使用
> [Monaco Editor](https://microsoft.github.io/monaco-editor/) 进行文本编辑，
> 其内部使用 [Monarch 库](https://microsoft.github.io/monaco-editor/monarch.html)
> 实现语法高亮。

<a id="override-syntax-highlighting-for-a-file-type"></a>

## 覆盖文件类型的语法高亮

> [!note]
> Web IDE 不支持 `.gitattributes` 文件。
> 更多信息，请参见[史诗 18651](https://gitlab.com/groups/gitlab-org/-/work_items/18651)。

要覆盖文件类型的语法高亮：

1. 如果项目的根目录中不存在 `.gitattributes` 文件，
   请创建一个使用该名称的空白文件。
1. 对于您要修改的每种文件类型，在 `.gitattributes` 文件中添加一行，
   声明文件扩展名和您想要的高亮语言：

   ```conf
   # This extension typically receives Perl syntax highlighting. If you
   # also use Prolog, you can override highlighting for this file extension:
   *.pl gitlab-language=prolog
   ```

1. 提交、推送并将更改合并到您的默认分支。

更改合并到您的[默认分支](../branches/default.md)后，项目中的所有 `*.pl` 文件都会以您首选的语言高亮显示。

您还可以使用通用网关接口（CGI）选项扩展高亮，例如：

``` conf
# JSON file with .erb in it
/my-cool-file gitlab-language=erb?parent=json

# An entire file of highlighting errors!
/other-file gitlab-language=text?token=Error
```

<a id="disable-syntax-highlighting-for-a-file-type"></a>

## 禁用文件类型的语法高亮

要完全禁用某种文件类型的高亮，请按照覆盖文件类型高亮的说明操作，并使用 `gitlab-language=text`：

```conf
# Disable syntax highlighting for this file type
*.module gitlab-language=text
```

<a id="configure-maximum-file-size-for-highlighting"></a>

## 配置高亮的最大文件大小

以下文件大小限制适用于语法高亮器：

- Rouge（服务端）：默认 512 KB（可配置）
  - 大于此限制的文件将以纯文本形式呈现，不进行语法高亮。
- Highlight.js（客户端）：2 MB（不可配置）
  - 如果不支持某种语言，则回退到 Rouge 高亮。
  - 大于此限制的文件无法在前端高亮，必须以原始内容查看。

要更改 Rouge 高亮限制：

1. 打开项目的 [`gitlab.yml`](https://jihulab.com/gitlab-cn/gitlab-foss/-/blob/master/config/gitlab.yml.example)
   配置文件。

1. 添加以下部分，将 `maximum_text_highlight_size_kilobytes` 替换为您想要的值。

   ```yaml
   gitlab:
     extra:
       ## Maximum file size for syntax highlighting
       ## https://docs.gitlab.com/user/project/repository/files/highlighting/#configure-maximum-file-size-for-highlighting
       maximum_text_highlight_size_kilobytes: 512
   ```

1. 提交、推送并将更改合并到您的默认分支。
