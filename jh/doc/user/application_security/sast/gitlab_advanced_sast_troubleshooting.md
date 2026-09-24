---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 高级 SAST 故障排查
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在使用极狐GitLab 高级 SAST 时，你可能会遇到以下问题。

<a id="advanced-sast-scan-running-longer-than-expected"></a>

## 高级 SAST 扫描运行时间超出预期

如果你已经按照优化步骤操作，但高级 SAST 扫描仍然运行时间超出预期，请联系极狐GitLab 支持团队以获取进一步帮助，并提供以下信息：

- [极狐GitLab 高级 SAST 分析器版本](#identify-the-gitlab-advanced-sast-analyzer-version)
- 仓库中使用的编程语言
- [调试日志](../troubleshooting_application_security.md#turn-on-debug-level-logging)
- [性能调试产物](#generate-a-performance-debugging-artifact)

<a id="identify-the-gitlab-advanced-sast-analyzer-version"></a>

### 识别极狐GitLab 高级 SAST 分析器版本

要识别极狐GitLab 高级 SAST 分析器版本：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **构建** > **作业**。
1. 找到 `gitlab-advanced-sast` 作业。
1. 在作业的输出中，搜索字符串 `GitLab GitLab Advanced SAST analyzer`。

你应该会在该字符串所在行的末尾找到版本号。例如：

```plaintext
[INFO] [GitLab Advanced SAST] [2025-01-24T15:51:03Z] ▶ GitLab GitLab Advanced SAST analyzer v1.1.1
```

在此例中，版本为 `1.1.1`。

<a id="generate-a-performance-debugging-artifact"></a>

### 生成性能调试产物

要在非 C/C++ 项目中生成 `trace.ctf` 产物，请将以下内容添加到你的 `.gitlab-ci.yml` 中。

将 `RUNNER_SCRIPT_TIMEOUT` 设置为至少比 `timeout` 短 10 分钟，以确保产物有足够时间上传。

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  GITLAB_ADVANCED_SAST_ENABLED: 'true'
  MEMTRACE: 'trace.ctf'
  DISABLE_MULTI_CORE: true # 收集 memtrace 时禁用多核

gitlab-advanced-sast:
  artifacts:
    paths:
      - '**/trace.ctf'  # 收集此作业生成的所有 trace.ctf 文件
    expire_in: 1 week   # 设置产物的保留时间
    when: always        # 即使作业失败也确保导出产物
  variables:
    RUNNER_SCRIPT_TIMEOUT: 50m
  timeout: 1h
```