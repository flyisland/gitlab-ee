---
stage: Software Supply Chain Security
group: Compliance
info: 如需获取本教程帮助，请参阅 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>。
title: '教程：创建合规流水线（已弃用）'
---

<!--- start_remove The following content will be removed on remove_date: '2026-08-15' -->

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能已在极狐GitLab 17.3 中[弃用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/159841)，
> 并计划在 19.0 中移除。请改用[流水线执行策略类型](../../user/application_security/policies/pipeline_execution_policies.md)。
> 此变更为重大变更。更多信息请参阅[迁移指南](../../user/compliance/compliance_pipelines.md#pipeline-execution-policies-migration)。

<!-- vale gitlab_base.FutureTense = NO -->

你可以使用[合规流水线](../../user/compliance/compliance_pipelines.md)来确保特定群组中所有项目的流水线都会运行特定的合规相关作业。合规流水线通过[合规框架](../../user/compliance/compliance_frameworks/_index.md)应用于项目。

在本教程中，你将：

1.  创建一个[新群组](#create-a-new-group)。
2.  为合规流水线配置创建一个[新项目](#create-a-new-compliance-pipeline-project)。
3.  配置一个[合规框架](#configure-compliance-framework)以应用于其他项目。
4.  创建一个[新项目并应用合规框架](#create-a-new-project-and-apply-the-compliance-framework)。
5.  结合[合规流水线配置和常规流水线配置](#combine-pipeline-configurations)。

## 准备工作

- 你需要有创建新的顶级群组的权限。

## 创建一个新群组

合规框架是在顶级群组中配置的。在本教程中，你将创建一个顶级群组，该群组：

-   包含两个项目：
    -   用于存储合规流水线配置的合规流水线项目。
    -   另一个项目，其流水线必须运行由合规流水线配置定义的作业。
-   拥有要应用于项目的合规框架。

要创建新群组：

1.  在右上角,选择 **创建新...** ({{< icon name="plus" >}}) 和 **新建群组**。
2.  选择 **创建群组**。
3.  在 **群组名称** 字段中，输入 `Tutorial group`。
4.  选择 **创建群组**。

## 创建一个新的合规流水线项目

现在，你可以创建合规流水线项目了。此项目包含要应用于所有应用了合规框架的项目的[合规流水线配置](../../user/compliance/compliance_pipelines.md#example-configuration)。

要创建合规流水线项目：

1.  在顶部栏中，选择 **搜索或跳转到** 并找到 `Tutorial group` 群组。
2.  选择 **新建项目**。
3.  选择 **创建空白项目**。
4.  在 **项目名称** 字段中，输入 `Tutorial compliance project`。
5.  选择 **创建项目**。

要向 `Tutorial compliance project` 添加合规流水线配置：

1.  在顶部栏中，选择 **搜索或跳转到** 并找到 `Tutorial compliance project` 项目。
2.  选择 **构建** > **流水线编辑器**。
3.  选择 **配置流水线**。
4.  在流水线编辑器中，将默认配置替换为：

    ```yaml
    ---
    compliance-job:
      script:
        - echo "正在运行此群组中每个项目都必需的合规作业..."
    ```

5.  选择 **提交更改**。

## 配置合规框架

合规框架在[新群组](#create-a-new-group)中配置。

要配置合规框架：

1.  在顶部栏中，选择 **搜索或跳转到** 并找到 `Tutorial group` 群组。
2.  选择 **安全** > **合规中心**。
3.  在页面上，选择 **框架** 选项卡。
4.  选择 **新建框架**。
5.  在 **名称** 字段中，输入 `Tutorial compliance framework`。
6.  在 **描述** 字段中，输入 `Compliance framework for tutorial`。
7.  在 **合规流水线配置（可选）** 字段中，输入 `.gitlab-ci.yml@tutorial-group/tutorial-compliance-project`。
8.  在 **背景颜色** 字段中，选择一个你喜欢的颜色。
9.  选择 **添加框架**。

为了方便起见，将新的合规框架设为群组中所有新项目的默认框架：

1.  在顶部栏中，选择 **搜索或跳转到** 并找到 `Tutorial group` 群组。
2.  选择 **安全** > **合规中心**。
3.  在页面上，选择 **框架** 选项卡。
4.  选择 `Tutorial compliance framework`，然后选择 **编辑框架**。
5.  选择 **设为默认**。
6.  选择 **保存更改**。

## 创建一个新项目并应用合规框架

你的合规框架已准备就绪，现在你可以在群组中创建项目，这些项目将自动在其流水线中运行合规流水线配置。

要创建一个用于运行合规流水线配置的新项目：

1.  在顶部栏中，选择 **搜索或跳转到** 并找到 `Tutorial group` 群组。
2.  在右上角，选择 **创建新...** ({{< icon name="plus" >}}) 和 **新建项目/代码仓**。
3.  选择 **创建空白项目**。
4.  在 **项目名称** 字段中，输入 `Tutorial project`。
5.  选择 **创建项目**。

在项目页面上，你会注意到 `Tutorial compliance framework` 标签出现，因为它被设置为此群组的默认合规框架。

无需任何其他流水线配置，`Tutorial project` 即可运行 `Tutorial compliance project` 中合规流水线配置定义的作业。

要在 `Tutorial project` 中运行合规流水线配置：

1.  在顶部栏中，选择 **搜索或跳转到** 并找到 `Tutorial project` 项目。
2.  选择 **构建** > **流水线**。
3.  选择 **新建流水线**。
4.  在 **新建流水线** 页面上，选择 **运行流水线**。

你会注意到流水线在 **test** 阶段运行了一个名为 `compliance-job` 的作业。做得好，你已经运行了你的第一个合规作业！

## 结合流水线配置

如果你希望项目不仅运行合规流水线作业，也运行自己的作业，则必须将合规流水线配置与项目的常规流水线配置结合起来。

要结合流水线配置，你必须先定义常规流水线配置，然后更新合规流水线配置以引用它。

要创建常规流水线配置：

1.  在顶部栏中，选择 **搜索或跳转到** 并找到 `Tutorial project` 项目。
2.  选择 **构建** > **流水线编辑器**。
3.  选择 **配置流水线**。
4.  在流水线编辑器中，将默认配置替换为：

    ```yaml
    ---
    project-job:
      script:
        - echo "正在运行项目作业..."
    ```

5.  选择 **提交更改**。

要将新的项目流水线配置与合规流水线配置结合：

1.  在顶部栏中，选择 **搜索或跳转到** 并找到 `Tutorial compliance project` 项目。
2.  选择 **构建** > **流水线编辑器**。
3.  在现有配置中，添加：

    ```yaml
    include:
      - project: 'tutorial-group/tutorial-project'
        file: '.gitlab-ci.yml'
    ```

4.  选择 **提交更改**。

要确认常规流水线配置已与合规流水线配置结合：

1.  在顶部栏中，选择 **搜索或跳转到** 并找到 `Tutorial project` 项目。
2.  选择 **构建** > **流水线**。
3.  选择 **新建流水线**。
4.  在 **新建流水线** 页面上，选择 **运行流水线**。

请注意，流水线在 **test** 阶段运行了两个作业：

-   `compliance-job`。
-   `project-job`。

恭喜你，你已经创建并配置了一个合规流水线！

查看更多[合规流水线配置示例](../../user/compliance/compliance_pipelines.md#example-configuration)。

<!--- end_remove -->