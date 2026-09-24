---
stage: Application Security Testing
group: Secret Detection
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 密钥检测排除项
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Experiment

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.5 中作为[实验功能](../../../policy/development_stages_support.md)引入，[带有功能标志](../../../administration/feature_flags/list.md) `secret_detection_project_level_exclusions`。默认启用。
- 功能标志 `secret_detection_project_level_exclusions` 在极狐GitLab 17.7 中[移除](https://gitlab.com/gitlab-org/gitlab/-/issues/499059)。

{{< /history >}}

密钥检测可能会检测到并非真正密钥的内容。例如，如果您在代码中使用一个假值作为占位符，它可能会被检测到并可能被阻止。

为避免误报并[优化性能](secret_push_protection/_index.md#optimize-performance)，您可以从密钥检测中排除以下内容：

- 路径。
- 原始值。
- 默认规则集中的规则。

您可以为项目定义多个排除项。

<a id="restrictions"></a>

## 限制

以下限制适用：

- 排除项只能为每个项目定义。
- 排除项仅适用于[密钥推送保护](secret_push_protection/_index.md)。
- 每个项目的基于路径的排除项最大数量为 10。
- 基于路径的排除项最大深度为 20。

<a id="add-an-exclusion"></a>

## 添加排除项

定义排除项以避免密钥检测的误报。

前提条件：

- 您必须对项目具有安全经理、维护者或所有者角色。

要定义排除项：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目或群组。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 向下滚动到 **密钥推送保护**。
1. 打开 **密钥推送保护** 切换开关。
1. 选择 **配置密钥检测**（{{< icon name="settings" >}}）。
1. 选择 **添加排除项** 以打开排除项表单。
1. 输入排除项的详细信息，然后选择 **添加排除项**。

路径排除项支持 glob 模式，这些模式通过 Ruby 方法 [`File.fnmatch`](https://docs.ruby-lang.org/en/master/File.html#method-c-fnmatch) 使用标志 [`File::FNM_PATHNAME | File::FNM_DOTMATCH | File::FNM_EXTGLOB`](https://docs.ruby-lang.org/en/master/File/Constants.html#module-File::Constants-label-Filename+Globbing+Constants+-28File-3A-3AFNM_-2A-29) 进行支持和解释。

规则排除项支持[默认规则集](https://gitlab.com/gitlab-org/security-products/secret-detection/secret-detection-rules)中列出的任何 ID。例如，`gitlab_personal_access_token` 是极狐GitLab 个人访问令牌的规则 ID。