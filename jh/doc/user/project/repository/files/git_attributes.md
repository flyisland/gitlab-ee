---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为您的极狐GitLab 项目定义自定义 Git 属性，以设置文件处理、显示、锁定和存储的选项。
title: Git 属性
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 支持在代码仓库根目录的 `.gitattributes` 文件中定义自定义 Git 属性。使用 `.gitattributes` 文件可以声明对文件处理和显示的更改，例如：

- 在差异中[折叠生成的文件](../../merge_requests/changes.md#collapse-generated-files)。
- 创建[自定义合并驱动程序](#custom-merge-drivers)。
- 创建[独占锁定文件](../../file_lock.md)，将文件标记为只读。
- 更改差异中的[语法高亮](highlighting.md)。
- 使用 [Git LFS](../../../../topics/git/lfs/_index.md) 声明二进制文件处理方式。
- 声明[代码仓库中使用的语言](../_index.md#add-repository-languages)。

<a id="encoding-requirements"></a>

## 编码要求

`.gitattributes` 文件必须使用 UTF-8 编码，且不得包含字节顺序标记。如果使用了其他编码，该文件的内容将被忽略。

<a id="support-for-mixed-file-encodings"></a>

## 支持混合文件编码

极狐GitLab 会尝试自动检测文件的编码，但除非检测器确信文件属于其他类型（例如 `ISO-8859-1`），否则默认使用 UTF-8。编码检测错误可能导致某些字符无法在文本中显示，例如非 UTF-8 编码中的重音字符。

Git 内置了对这种情况的支持，会在指定编码与代码仓库本身的 UTF-8 之间自动转换文件。在 `.gitattributes` 文件中使用 `working-tree-encoding` 属性来配置对混合文件编码的支持。

示例：

```plaintext
*.xhtml text working-tree-encoding=ISO-8859-1
```

使用此示例配置，Git 会在本地工作树中以 ISO-8859-1 编码维护代码仓库中的所有 `.xhtml` 文件，但在提交到代码仓库时会与 UTF-8 相互转换。极狐GitLab 只会看到正确编码的 UTF-8，因此能够准确渲染这些文件。

如果将此配置应用于现有代码仓库，而本地副本的编码正确但代码仓库中的编码不正确，则可能需要重新触碰并重新提交这些文件。可以通过运行 `git add --renormalize .` 对整个代码仓库执行此操作。

有关更多信息，请参阅 [working-tree-encoding](https://git-scm.com/docs/gitattributes#_working_tree_encoding)。

<a id="syntax-highlighting"></a>

## 语法高亮

`.gitattributes` 文件可用于定义对文件和差异进行语法高亮时使用的语言。有关更多信息，请参阅[语法高亮](highlighting.md)。

<a id="custom-merge-drivers"></a>

## 自定义合并驱动程序

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 私有化部署管理员可以在极狐GitLab 配置文件中定义[自定义合并驱动程序](https://git-scm.com/docs/gitattributes#_defining_a_custom_merge_driver)，然后在 Git `.gitattributes` 文件中使用这些自定义合并驱动程序。JihuLab.com 不支持自定义合并驱动程序。

自定义合并驱动程序是 Git 的一项功能，可让您对冲突解决进行高级控制。自定义合并驱动程序仅在发生非平凡的[合并冲突](../../merge_requests/conflicts.md)时才会被调用，因此它并不是阻止某些文件被合并的可靠方法。

<a id="configure-a-custom-merge-driver"></a>

### 配置自定义合并驱动程序

以下示例说明了如何在极狐GitLab 中定义和使用自定义合并驱动程序。

如何配置自定义合并驱动程序取决于安装类型。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`。
1. 添加类似如下的配置：

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

{{< tab title="自行编译（源代码）" >}}

1. 编辑 `gitaly.toml`。
1. 添加类似如下的配置：

   ```toml
   [[git.config]]
   key = "merge.foo.driver"
   value = "true"
   ```

{{< /tab >}}

{{< /tabs >}}

在此示例中，合并期间 Git 使用 `driver` 值作为要执行的命令。由于该示例使用了不带参数的 [`true`](https://man7.org/linux/man-pages/man1/true.1.html)，因此它始终返回非零返回码。这意味着对于 `.gitattributes`中指定的文件，合并不会执行任何操作。

要使用您自己的合并驱动程序，请替换 `driver`中的值，使其指向一个可执行文件。有关此命令如何被调用的更多详细信息，请参阅 Git 文档中关于[自定义合并驱动程序](https://git-scm.com/docs/gitattributes#_defining_a_custom_merge_driver)的内容。

<a id="use-gitattributes-to-set-files-custom-merge-driver-applies-to"></a>

### 使用 `.gitattributes` 设置自定义合并驱动程序适用的文件

在 `.gitattributes` 文件中，您可以设置希望使用自定义合并驱动程序的文件路径。例如：

```plaintext
config/* merge=foo
```

在这种情况下，`config/` 文件夹下的每个文件都会使用极狐GitLab 配置中定义的名为 `foo`的自定义合并驱动程序。

<a id="resources"></a>

## 相关资源

- Git 官方文档中关于 [Git 属性](https://git-scm.com/docs/gitattributes)的内容
