---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 徽章
description: 流水线状态、群组、项目和自定义徽章。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

徽章是一种统一的方式来展示关于项目的简要信息片段。一个徽章由一个小图片和一个该图片指向的 URL 组成。在极狐GitLab 中，徽章会显示在项目概览页面上，位于项目描述的下方。您可以在[项目](#project-badges)和[群组](#group-badges)级别使用徽章。

<a id="available-badges"></a>

## 可用徽章

极狐GitLab 提供了以下流水线徽章：

- [流水线状态徽章](#pipeline-status-badges)
- [测试覆盖率报告徽章](#test-coverage-report-badges)
- [最新发布徽章](#latest-release-badges)

极狐GitLab 还支持[调整徽章样式](#customize-badges)。

<a id="pipeline-status-badges"></a>

## 流水线状态徽章

流水线状态徽章指示项目中最新流水线的状态。根据流水线的状态，徽章可以具有以下值之一：

- `pending`
- `running`
- `passed`
- `failed`
- `skipped`
- `manual`
- `canceled`
- `unknown`

您可以通过以下链接访问流水线状态徽章图片：

```plaintext
https://gitlab.example.com/<namespace>/<project>/badges/<branch>/pipeline.svg
```

<a id="display-only-non-skipped-status"></a>

### 仅显示非跳过状态

要使流水线状态徽章仅显示最后一个非跳过状态，请使用 `?ignore_skipped=true` 查询参数：

```plaintext
https://gitlab.example.com/<namespace>/<project>/badges/<branch>/pipeline.svg?ignore_skipped=true
```

<a id="test-coverage-report-badges"></a>

## 测试覆盖率报告徽章

测试覆盖率报告徽章指示项目中已测试代码的百分比。该值基于最新的成功流水线计算得出。

您可以通过以下链接访问测试覆盖率报告徽章图片：

```plaintext
https://gitlab.example.com/<namespace>/<project>/badges/<branch>/coverage.svg
```

您可以为每个作业日志匹配的[代码覆盖率](../../ci/testing/code_coverage/_index.md#configure-coverage-reporting)定义正则表达式。这意味着流水线中的每个作业都可以定义测试覆盖率百分比值。

要从特定作业获取覆盖率报告，请向 URL 添加 `job=coverage_job_name` 参数。例如，您可以使用类似以下代码将 `coverage` 作业的测试覆盖率报告徽章添加到 Markdown 文件中：

```markdown
![覆盖率](https://gitlab.example.com/<namespace>/<project>/badges/<branch>/coverage.svg?job=coverage)
```

<a id="test-coverage-limits-and-badge-colors"></a>

### 测试覆盖率限制和徽章颜色

以下表格显示了默认的测试覆盖率限制和徽章颜色：

| 测试覆盖率 | 百分比限制                    | 徽章颜色 |
|------------|-------------------------------|----------|
| 良好       | 95% 至 100%（含）             | <span style="color: #4c1">■</span> `#4c1` |
| 可接受     | 90% 至 95%（不含）            | <span style="color:#a3c51c"> ■</span> `#a3c51c` |
| 中等       | 75% 至 90%（不含）            | <span style="color: #dfb317">■</span> `#dfb317` |
| 低         | 0% 至 75%（不含）             | <span style="color: #e05d44">■</span> `#e05d44` |
| 未知       | 无覆盖率                      | <span style="color: #9f9f9f">■</span> `#9f9f9f` |

> [!note]
> _至_ 表示达到但不包括上限。

<a id="change-the-default-limits"></a>

### 更改默认限制

您可以通过在覆盖率报告徽章 URL 中传递以下查询参数来覆盖默认限制：

| 查询参数        | 可接受的值                                  | 默认值 |
|-----------------|---------------------------------------------|--------|
| `min_good`      | 介于 `3` 和 `100` 之间的任何值              | `95`   |
| `min_acceptable`| 介于 `2` 和 `min_good`−1 之间的任何值        | `90`   |
| `min_medium`    | 介于 `1` 和 `min_acceptable`−1 之间的任何值  | `75`   |

例如：

```plaintext
https://gitlab.example.com/<namespace>/<project>/badges/<branch>/coverage.svg?min_good=98&min_acceptable=75
```

如果您设置了无效的边界，极狐GitLab 会自动将其调整为有效边界。例如，如果您将 `min_good` 设置为 `80` 并将 `min_acceptable` 设置为 `85`，极狐GitLab 会将 `min_acceptable` 设置为 `79` (`min_good - 1`)，因为最低可接受值不能高于最低良好值。

<a id="latest-release-badges"></a>

## 最新发布徽章

最新发布徽章显示项目的最新发布标签名称。如果没有发布，则显示 `none`。

您可以通过以下链接访问最新发布徽章图片：

```plaintext
https://gitlab.example.com/<namespace>/<project>/-/badges/release.svg
```

默认情况下，徽章使用 `?order_by` 查询参数按 [`released_at`](../../api/releases/_index.md#create-a-release) 时间排序获取发布。

```plaintext
https://gitlab.example.com/<namespace>/<project>/-/badges/release.svg?order_by=release_at
```

您可以使用 `value_width` 参数（于极狐GitLab 15.10 [引入](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/113615)）更改发布名称字段的宽度。该值必须在 1 到 200 之间，默认值为 54。如果您设置了超出范围的值，极狐GitLab 会自动将其调整为默认值。

<a id="project-badges"></a>

## 项目徽章

具有维护者或所有者角色的用户可以向项目添加徽章，徽章会显示在项目的 **概览** 页面。如果您发现需要在多个项目中添加相同的徽章，则可能需要[在群组级别](#group-badges)添加它们。

<a id="example-project-badge-pipeline-status"></a>

### 项目徽章示例：流水线状态

一个常见的项目徽章展示极狐GitLab CI 流水线状态。

要将此徽章添加到项目：

1. 在顶栏中，选择 **搜索或跳转到** 并找到您的项目。
2. 在左侧边栏中，选择 **设置** > **通用**。
3. 展开 **徽章**。
4. 在 **名称** 下，输入 _流水线状态_。
5. 在 **链接** 下，输入以下 URL：
   `https://gitlab.example.com/%{project_path}/-/commits/%{default_branch}`
6. 在 **徽章图片 URL** 下，输入以下 URL：
   `https://gitlab.example.com/%{project_path}/badges/%{default_branch}/pipeline.svg`
7. 选择 **添加徽章**。

<a id="group-badges"></a>

## 群组徽章

群组所有者可以向群组添加徽章，这些徽章会显示在属于该群组的任何项目的 **概览** 页面上。通过向群组添加徽章，您可以为群组中的所有项目添加并强制执行项目级别的徽章。

> [!note]
> 虽然这些徽章在代码库中显示为项目级徽章，但它们无法在项目级别进行编辑或删除。

如果您需要每个项目都有单独的徽章，可以：

- 在[项目级别](#project-badges)添加徽章。
- 使用[占位符](#placeholders)。

<a id="view-badges"></a>

## 查看徽章

要查看项目或群组中可用的徽章：

1. 在顶栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
2. 在左侧边栏中，选择 **设置** > **通用**。
3. 展开 **徽章**。

<a id="add-a-badge"></a>

## 添加徽章

要向项目或群组添加新徽章：

1. 在顶栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
2. 在左侧边栏中，选择 **设置** > **通用**。
3. 展开 **徽章**。
4. 选择 **添加徽章**。
5. 在 **名称** 文本框中，输入您的徽章名称。
6. 在 **链接** 文本框中，输入徽章应指向的 URL。
7. 在 **徽章图片 URL** 文本框中，输入您想要为徽章显示的图片 URL。
8. 选择 **添加徽章**。

<a id="view-the-url-of-pipeline-badges"></a>

## 查看流水线徽章的 URL

您可以查看徽章的确切链接。然后，您可以使用这些链接将徽章嵌入到您的 HTML 或 Markdown 页面中。

1. 在顶栏中，选择 **搜索或跳转到** 并找到您的项目。
2. 在左侧边栏中，选择 **设置** > **CI/CD**。
3. 展开 **通用流水线**。
4. 在 **流水线状态**、**覆盖率报告** 或 **最新发布** 部分，查看图片的 URL。

> [!note]
> 流水线状态徽章基于特定的 Git 修订版本（分支）。请确保选择适当的分支以查看正确的流水线状态。

<a id="customize-badges"></a>

## 自定义徽章

{{< details >}}

- 状态：测试版

{{< /details >}}

{{< history >}}

- 于极狐GitLab 18.5 [带有功能标志](../../administration/feature_flags/_index.md) 名为 `custom_project_badges` 引入，默认禁用。
- 于极狐GitLab 18.6 在 JihuLab.com、私有化部署 上启用。

{{< /history >}}

您可以自定义徽章在项目中的显示方式：

- [基本自定义](#basic-customization) 适用于所有徽章类型。
- [高级自定义](#custom-badges) 仅适用于自定义徽章。

<a id="basic-customization"></a>

### 基本自定义

您可以自定义所有徽章类型的以下方面：

- [样式](#style)
- [键文本](#key-text)
- [键宽度](#key-width)
- [值宽度](#value-width)

<a id="style"></a>

#### 样式

通过向 URL 添加 `style=style_name` 参数，流水线、覆盖率、发布和自定义徽章可以以不同样式呈现。提供两种样式：

- 扁平（默认）：

  ```plaintext
  https://gitlab.example.com/<namespace>/<project>/badges/<branch>/coverage.svg?style=flat
  ```

  ![扁平样式渲染的徽章。](img/badge_flat.svg)

- 扁平方形：

  ```plaintext
  https://gitlab.example.com/<namespace>/<project>/badges/<branch>/coverage.svg?style=flat-square
  ```

  ![扁平方形样式渲染的徽章。](img/badge_flat_square.svg)

<a id="key-text"></a>

#### 键文本

徽章左侧的文本可以自定义。例如，区分在同一流水线中运行的多个覆盖率作业。

通过向 URL 添加 `key_text=custom_text` 参数来自定义徽章键文本：

```plaintext
https://gitlab.example.com/gitlab-org/gitlab/badges/main/coverage.svg?job=karma&key_text=Frontend+Coverage&key_width=130
```

![具有自定义文本和调整后宽度的徽章。](img/badge_custom_text.svg)

<a id="key-width"></a>

#### 键宽度

通过向 URL 添加 `key_width=width` 参数来自定义徽章键宽度：

```plaintext
https://gitlab.example.com/%{project_path}/-/badges/coverage.svg?key_width=130
```

<a id="value-width"></a>

#### 值宽度

通过向 URL 添加 `value_width=width` 参数来自定义徽章值宽度：

```plaintext
https://gitlab.example.com/%{project_path}/-/badges/coverage.svg?value_width=130
```

<a id="custom-badges"></a>

### 自定义徽章

自定义徽章让您完全控制徽章的两侧。与显示预定义信息（如流水线状态）的标准徽章不同，自定义徽章允许您：

- 在徽章的任一侧显示任意文本
- 使用自定义颜色
- 显示项目特定信息
- 使用[占位符](#placeholders)创建动态徽章

除了[基本自定义选项](#basic-customization)外，自定义徽章还支持以下附加自定义选项：

- [键颜色](#key-color)
- [值颜色](#value-color)
- [值文本](#value-text)

您可以通过以下链接添加自定义徽章：

```plaintext
https://gitlab.example.com/%{project_path}/-/badges/custom.svg
```

例如，您可以使用[占位符](#placeholders)为最新标签创建徽章：

```plaintext
https://gitlab.example.com/%{project_path}/-/badges/custom.svg?key_text=Latest_tag&value_text=%{latest_tag}&key_color=white&value_color=7bc043
```

> [!warning]
> 占位符允许徽章暴露原本私有的信息，例如当项目配置为私有仓库时的默认分支或提交 SHA。此行为是有意为之，因为徽章旨在公开使用。如果信息敏感，请避免使用这些占位符。

<a id="value-text"></a>

#### 值文本

通过向 URL 添加 `value_text=text` 参数来自定义右侧显示的文本：

```plaintext
https://gitlab.example.com/%{project_path}/-/badges/custom.svg?value_text=badge
```

<a id="value-color"></a>

#### 值颜色

通过向 URL 添加 `value_color=color` 参数来自定义右侧的背景颜色：

颜色可以以下列形式传递：

- [命名颜色](https://developer.mozilla.org/en-US/docs/Web/CSS/named-color)，例如 `blue`
- 十六进制表示，如 `fff` 或 `7bc043`（不带前导 `#`）

```plaintext
https://gitlab.example.com/%{project_path}/-/badges/custom.svg?value_color=red
```

<a id="key-color"></a>

#### 键颜色

通过向 URL 添加 `value_color=color` 参数来自定义左侧的背景颜色：

颜色可以以下列形式传递：

- [命名颜色](https://developer.mozilla.org/en-US/docs/Web/CSS/named-color)，例如 `blue`
- 十六进制表示，如 `fff` 或 `7bc043`（不带前导 `#`）

```plaintext
https://gitlab.example.com/%{project_path}/-/badges/custom.svg?key_color=green
```

<a id="add-a-custom-badge-image"></a>

### 添加自定义徽章图片

前提条件：

- 您必须具有项目或群组的 开发者、维护者 或 所有者 角色。
- 您必须拥有一个直接指向所需徽章图片的有效 URL。如果图片位于极狐GitLab 仓库中，请使用图片的原始链接。

要添加带有自定义图片的徽章：

1. 在顶栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
2. 在左侧边栏中，选择 **设置** > **通用**。
3. 展开 **徽章**。
4. 在 **名称** 下，输入徽章的名称。
5. 在 **链接** 下，输入徽章应指向的 URL。
6. 在 **徽章图片 URL** 下，输入自定义图片的 URL。例如，要使用仓库中的图片：

   ```plaintext
   https://gitlab.example.com/<project_path>/-/raw/<default_branch>/custom-image.svg
   ```

7. 选择 **添加徽章**。

要使用通过流水线生成的自定义图片，请参阅[通过 URL 访问最新作业产物](../../ci/jobs/job_artifacts.md#from-a-url)。

<a id="edit-a-badge"></a>

## 编辑徽章

要编辑项目或群组中的徽章：

1. 在顶栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
2. 在左侧边栏中，选择 **设置** > **通用**。
3. 展开 **徽章**。
4. 在要编辑的徽章旁边，选择 **编辑**（{{< icon name="pencil" >}}）。
5. 编辑 **名称**、**链接** 或 **徽章图片 URL**。
6. 选择 **保存更改**。

<a id="delete-a-badge"></a>

## 删除徽章

要删除项目或群组中的徽章：

1. 在顶栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
2. 在左侧边栏中，选择 **设置** > **通用**。
3. 展开 **徽章**。
4. 在要删除的徽章旁边，选择 **删除**（{{< icon name="remove" >}}）。
5. 在确认对话框中，选择 **删除徽章**。

> [!note]
> 与群组关联的徽章只能在[群组级别](#group-badges)进行编辑或删除。

<a id="placeholders"></a>

## 占位符

徽章指向的 URL 和图片 URL 都可以包含占位符，这些占位符在显示徽章时进行求值。以下占位符可用：

- `%{project_path}`：包含父群组的项目路径
- `%{project_title}`：项目标题
- `%{project_name}`：项目名称
- `%{project_id}`：与项目关联的数据库 ID
- `%{project_namespace}`：项目的项目命名空间
- `%{group_name}`：项目所属群组
- `%{gitlab_server}`：项目服务器
- `%{gitlab_pages_domain}`：托管极狐GitLab Pages 的域
- `%{default_branch}`：为项目仓库配置的默认分支名称
- `%{commit_sha}`：项目仓库默认分支上最新提交的 ID
- `%{latest_tag}`：添加到项目仓库的最新标签

> [!warning]
> 占位符允许徽章暴露原本私有的信息，例如当项目配置为私有仓库时的默认分支或提交 SHA。此行为是有意为之，因为徽章旨在公开使用。如果信息敏感，请避免使用这些占位符。

> [!warning]
> `%{gitlab_server}` 和 `%{gitlab_pages_domain}` 不能用于指定 URL 中的主机名，仅可用于其他参数。

<!-- -->

