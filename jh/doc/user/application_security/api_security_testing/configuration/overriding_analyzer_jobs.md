---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 覆盖 API 安全测试作业
---

要覆盖一个作业定义，（例如，更改 `variables`、`dependencies` 或 [`rules`](../../../../ci/yaml/_index.md#rules) 等属性），声明一个与要覆盖的 DAST 作业同名的新作业。将新作业放在模板引入之后，并在其下指定任何附加的键。例如，这将设置目标 APIs 基础 URL：

```yaml
include:
  - template: Security/API-Security.gitlab-ci.yml

api_security:
  variables:
    APISEC_TARGET_URL: https://target/api
```