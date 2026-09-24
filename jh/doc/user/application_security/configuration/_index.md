---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 安全配置
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

<a id="security-configuration"></a>

## 安全配置

**安全配置**页面列出了用于安全测试和合规工具的以下内容：

- 名称、描述和文档链接。
- 是否可用。
- 配置按钮或其配置指南的链接。

为了确定每个安全控制的状态，极狐GitLab 会检查默认分支上最新提交中的 [CI/CD 流水线](../../../ci/pipelines/_index.md)。

如果极狐GitLab 找到 CI/CD 流水线，则会检查 `.gitlab-ci.yml` 文件中的每个作业。

- 如果作业为安全扫描器定义了[`artifacts:reports`关键字](../../../ci/yaml/artifacts_reports.md)，则极狐GitLab 认为安全扫描器已启用并显示**启用**状态。
- 如果没有作业为安全扫描器定义`artifacts:reports`关键字，则极狐GitLab 认为安全扫描器未启用并显示**未启用**状态。

如果极狐GitLab 未找到 CI/CD 流水线，则认为所有安全扫描器未启用并显示**未启用**状态。

失败的流水线和作业也包括在此过程中。如果扫描器已配置但作业失败，该扫描器仍被视为启用。此过程还通过[API](../../../api/graphql/reference/_index.md#securityscanners)确定返回的扫描器和状态。

如果最新的流水线使用[自动 DevOps](../../../topics/autodevops/_index.md)，则所有安全功能默认配置。

要查看项目的安全配置：

1. 在左侧边栏中，选择**搜索或转到**并找到您的项目。
1. 选择**安全 > 安全配置**。

选择**配置历史记录**查看 `.gitlab-ci.yml` 文件的历史。

<a id="security-testing"></a>

## 安全测试

您可以配置以下安全控制：

- [静态应用程序安全测试](../sast/_index.md) (SAST)
  - 选择**启用 SAST**为当前项目配置 SAST。有关更多详细信息，请阅读[在 UI 中配置 SAST](../sast/_index.md#configure-sast-by-using-the-ui)。
- [动态应用程序安全测试](../dast/_index.md) (DAST)
  - 选择**启用 DAST**为当前项目配置 DAST。
  - 选择**管理扫描**管理保存的 DAST 扫描、站点配置文件和扫描器配置文件。有关更多详细信息，请阅读[DAST 按需扫描](../dast/on-demand_scan.md)。
- [依赖项扫描](../dependency_scanning/_index.md)
  - 选择**通过合并请求配置**创建合并请求以进行启用依赖项扫描所需的更改。有关更多信息，请参阅[使用预配置的合并请求](../dependency_scanning/_index.md#use-a-preconfigured-merge-request)。
- [容器扫描](../container_scanning/_index.md)
  - 选择**通过合并请求配置**创建合并请求以进行启用容器扫描所需的更改。有关更多详细信息，请参阅[通过自动合并请求启用容器扫描](../container_scanning/_index.md#use-a-preconfigured-merge-request)。
- [用于注册表的容器扫描](../container_scanning/_index.md#container-scanning-for-registry)
  - 启用切换为当前项目配置**用于注册表的容器扫描**。
- [操作性容器扫描](../../clusters/agent/vulnerabilities.md)
  - 可以通过在代理配置中添加配置块来配置。有关更多详细信息，请阅读[操作性容器扫描](../../clusters/agent/vulnerabilities.md#enable-operational-container-scanning)。
- [密钥检测](../secret_detection/pipeline/_index.md)
  - 选择**通过合并请求配置**创建合并请求以进行启用密钥检测所需的更改。有关更多详细信息，请阅读[使用自动配置的合并请求](../secret_detection/pipeline/_index.md#use-an-automatically-configured-merge-request)。
- [API 模糊测试](../api_fuzzing/_index.md)
  - 选择**启用 API 模糊测试**为当前项目使用 API 模糊测试。有关更多详细信息，请阅读[API 模糊测试](../api_fuzzing/configuration/enabling_the_analyzer.md)。
- [覆盖率模糊测试](../coverage_fuzzing/_index.md)
  - 可以使用 `.gitlab-ci.yml` 进行配置。有关更多详细信息，请阅读[覆盖率模糊测试](../coverage_fuzzing/_index.md#enable-coverage-guided-fuzz-testing)。

<a id="compliance"></a>

## 合规

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

您可以配置以下安全控制：

- [安全培训](../vulnerabilities/_index.md#enable-security-training-for-vulnerabilities)
  - 为当前项目启用**安全培训**。有关更多详细信息，请阅读[安全培训](../vulnerabilities/_index.md#enable-security-training-for-vulnerabilities)。
