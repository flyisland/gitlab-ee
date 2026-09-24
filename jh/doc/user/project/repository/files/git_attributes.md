---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Define custom Git attributes for your GitLab project to set options for file handling, display, locking, and storage.
title: Git 属性
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="git-attributes"></a>

# Git 属性

极狐GitLab 支持在仓库根目录的 `.gitattributes` 文件中定义自定义 Git 属性。使用 `.gitattributes` 文件声明文件处理和显示的更改，例如：

- 在差异中[折叠生成文件](../../merge_requests/changes.md#collapse-generated-files)。
- 创建[自定义合并驱动程序](#custom-merge-drivers)。
- 创建[排他锁定文件](../../file_lock.md) 将文件标记为只读。
- 更改差异中的[语法高亮](highlighting.md)。
- 使用 [Git LFS](../../../../topics/git/lfs/_index.md) 声明二进制文件处理。
- [声明仓库中使用的语言](../_index.md#add-repository-languages)。

<a id="encoding-requirements"></a>

## 编码要求

`.gitattributes` 文件必须采用 UTF-8 编码，并且不得包含字节顺序标记(Byte Order Mark)。如果使用了其他编码，文件内容将被忽略。

<a id="support-for-mixed-file-encodings"></a>

## 支持混合文件编码

极狐GitLab 尝试自动检测文件编码，但除非检测器确信是不同类型（例如 `ISO-8859-1`），否则默认为 UTF-8。错误的编码检测可能导致某些字符在文本中无法显示，例如非 UTF-8 编码中的带重音符号的字符。

Git 内置了处理这种情况的支持，能够自动在指定的编码和仓库本身的 UTF-8 之间转换文件。在 `.gitattributes` 文件中使用 `working-tree-encoding` 属性配置混合文件编码支持。

示例：

```plaintext
*.xhtml text working-tree-encoding=ISO-8859-1
```

通过此示例配置，Git 在本地工作树中以 ISO-8859-1 编码维护仓库中的所有 `.xhtml` 文件，但在提交到仓库时进行与 UTF-8 之间的转换。极狐GitLab 能够准确地渲染文件，因为它只看到正确编码的 UTF-8。

如果将此配置应用于现有仓库，当本地副本具有正确的编码但仓库没有时，可能需要重新触摸并重新提交文件。可以通过对整个仓库运行 `git add --renormalize .` 来执行此操作。

有关更多信息，请参阅 [working-tree-encoding](https://git-scm.com/docs/gitattributes#_working_tree_encoding)。

<a id="syntax-highlighting"></a>

## 语法高亮

`.gitattributes` 文件可用于定义文件和差异语法高亮时使用的语言。有关更多信息，请参阅 [语法高亮](highlighting.md)。

<a id="custom-merge-drivers"></a>

## 自定义合并驱动程序

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 私有化部署的管理员可以在极狐GitLab 配置文件中定义[自定义合并驱动程序](https://git-scm.com/docs/gitattributes#_defining_a_custom_merge_driver)，然后在 Git `.gitattributes` 文件中使用这些自定义合并驱动程序。自定义合并驱动程序在 JihuLab.com 上不受支持。

自定义合并驱动程序是一项 Git 功能，可让您对冲突解决进行高级控制。自定义合并驱动程序仅在有非平凡合并冲突时调用，因此不是防止某些文件被合并的可靠方法。

<a id="configure-a-custom-merge-driver"></a>

### 配置自定义合并驱动程序

以下示例说明了如何在极狐GitLab 中定义和使用自定义合并驱动程序。

如何配置自定义合并驱动程序取决于安装类型。

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`。
1. 添加类似于以下的配置：

   ```ruby
   gitaly['configuration'] = {
     # ...
     git: {
       # ...
       config: [
         # ...
         { key: "merge.foo.driver", value: "true" },
       ],
     },
   }
   ```

{{< /tab >}}

{{< tab title="自行编译 (source)" >}}

1. 编辑 `gitaly.toml`。
1. 添加类似于以下的配置：

   ```toml
   [[git.config]]
   key = "merge.foo.driver"
   value = "true"
   ```

{{< /tab >}}

{{< /tabs >}}

在这个例子中，在合并期间，Git 将 `driver` 值用作要执行的命令。由于示例使用没有参数的 [`true`](https://man7.org/linux/man-pages/man1/true.1.html)，它总是返回一个非零返回码。这意味着对于在 `.gitattributes` 中指定的文件，合并操作不会执行任何操作。

要使用您自己的合并驱动程序，请将 `driver` 中的值替换为指向可执行文件。有关如何调用此命令的更多详细信息，请参阅 Git 文档中的 [自定义合并驱动程序](https://git-scm.com/docs/gitattributes#_defining_a_custom_merge_driver)。

<a id="use-gitattributes-to-set-files-custom-merge-driver-applies-to"></a>

### 使用 `.gitattributes` 设置自定义合并驱动程序适用的文件

在 `.gitattributes` 文件中，您可以设置要与自定义合并驱动程序一起使用的文件路径。例如：

```plaintext
config/* merge=foo
```

在这种情况下，`config/` 文件夹下的每个文件都使用在极狐GitLab 配置中定义的名为 `foo` 的自定义合并驱动程序。

<a id="resources"></a>

## 资源

- 有关 [Git 属性](https://git-scm.com/docs/gitattributes) 的官方 Git 文档
