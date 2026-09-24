---
stage: Create
group: Source Code
info: 要确定与此页面关联的 Stage/Group 的技术文档作者，请参阅 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 语法高亮可帮助你阅读极狐GitLab 项目中的文件，并识别文件内容。
title: 语法高亮
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 通过两个互补的系统为文件提供语法高亮：

- [Rouge](https://rubygems.org/gems/rouge) (Ruby gem)：在极狐GitLab 服务器上处理文件的服务器端高亮。用于：
  - 仓库文件查看
  - 合并请求差异
  - 提交差异
  - 比较视图
  - 追溯视图
- [Highlight.js](https://github.com/highlightjs/highlight.js/)：在浏览器中运行的客户端高亮。用于在浏览器中查看受支持语言的仓库文件。

此处路径使用 Git 中的 [`.gitattributes` 接口](https://git-scm.com/docs/gitattributes)。

> [!note]
> [Web IDE](../../web_ide/_index.md) 和 [代码片段](../../../snippets.md) 使用
> [Monaco Editor](https://microsoft.github.io/monaco-editor/) 进行文本编辑，
> 它内部使用 [Monarch library](https://microsoft.github.io/monaco-editor/monarch.html)
> 进行语法高亮。

## 覆盖文件类型的语法高亮

<a id="override-syntax-highlighting-for-a-file-type"></a>

> [!note]
> Web IDE 不支持 `.gitattributes` 文件。
> 更多信息，请参阅[史诗 18651](https://gitlab.com/groups/gitlab-org/-/work_items/18651)。

要覆盖文件类型的语法高亮：

1. 如果项目根目录中不存在 `.gitattributes` 文件，请创建一个同名的空白文件。
1. 对于要修改的每种文件类型，在 `.gitattributes` 文件中添加一行，声明文件扩展名和你所需的高亮语言：

   ```conf
   # 此扩展名通常会获得 Perl 语法高亮。
   # 如果你也使用 Prolog，则可以覆盖此文件扩展名的高亮：
   *.pl gitlab-language=prolog
   ```

1. 提交、推送你的更改，并将其合并到默认分支中。

在更改合并到你的[默认分支](../branches/default.md)后，项目中所有的 `*.pl` 文件都会以你选择的语言进行高亮显示。

你还可以使用通用网关接口（CGI）选项扩展高亮，例如：

``` conf
# 包含 .erb 的 JSON 文件
/my-cool-file gitlab-language=erb?parent=json

# 整个文件都是高亮错误！
/other-file gitlab-language=text?token=Error
```

## 禁用文件类型的语法高亮

<a id="disable-syntax-highlighting-for-a-file-type"></a>

要完全禁用某种文件类型的高亮，请按照覆盖文件类型高亮的说明操作，并使用 `gitlab-language=text`：

```conf
# 禁用此文件类型的语法高亮
*.module gitlab-language=text
```

## 配置高亮的最大文件大小

<a id="configure-maximum-file-size-for-highlighting"></a>

以下文件大小限制适用于语法高亮器：

- Rouge（服务器端）：默认 512 KB（可配置）
  - 大于此限制的文件将以纯文本形式呈现，不进行语法高亮。
- Highlight.js（客户端）：2 MB（不可配置）
  - 如果某种语言不受支持，则会回退到 Rouge 高亮。
  - 大于此限制的文件无法在前端进行高亮，必须以原始内容形式查看。

要更改 Rouge 高亮限制：

1. 打开你项目的 [`gitlab.yml`](https://gitlab.com/gitlab-org/gitlab-foss/blob/master/config/gitlab.yml.example) 配置文件。

1. 添加此部分，将 `maximum_text_highlight_size_kilobytes` 替换为你想要的值。

   ```yaml
   gitlab:
     extra:
       ## 语法高亮的最大文件大小
       ## https://gitlab.cn/docs/user/project/repository/files/highlighting/#configure-maximum-file-size-for-highlighting
       maximum_text_highlight_size_kilobytes: 512
   ```

1. 提交、推送你的更改，并将其合并到默认分支中。