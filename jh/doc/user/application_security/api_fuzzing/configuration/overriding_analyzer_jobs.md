---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 覆盖 API 模糊测试作业
---

要覆盖作业定义（例如更改 `variables`、`dependencies` 或 [`rules`](../../../../ci/yaml/_index.md#rules) 等属性），请声明一个与 DAST 作业同名的作业来进行覆盖。将此新作业放在模板引入之后，并在其下指定任何其他键。例如，以下设置目标 API 基础 URL：

```yaml
include:
  - template: Security/API-Fuzzing.gitlab-ci.yml

apifuzzer_fuzz:
  variables:
    FUZZAPI_TARGET_URL: https://target/api
```
