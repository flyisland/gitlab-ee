---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 重写 DAST 作业
---

要重写作业定义（例如，更改诸如 `变量`、`依赖` 或 [`规则`](../../../../../ci/yaml/_index.md#rules) 等属性），声明一个与要重写的 DAST 作业同名的作业。将此新作业放在模板包含之后，并在其下指定任何额外的键。例如，这会为分析器启用身份验证调试日志记录，该日志将显示在日志文件产物中：

```yaml
include:
  - template: Security/DAST.gitlab-ci.yml

dast:
  variables:
    DAST_LOG_FILE_CONFIG: auth:debug
```