---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 覆盖 API 模糊测试作业
---

<a id="overriding-api-fuzzing-jobs"></a>

# 覆盖 API 模糊测试作业

要覆盖作业定义（例如，更改诸如 `variables`、`dependencies` 或 [`规则`](../../../../ci/yaml/_index.md#rules) 等属性），需要声明一个与要覆盖的 DAST 作业同名的新作业。将此新作业放在模板引入之后，并在其下指定任何其他键。例如，执行以下操作可以设置目标 API 的基础 URL：

```yaml
include:
  - template: Security/API-Fuzzing.gitlab-ci.yml

apifuzzing_fuzz:
  variables:
    FUZZAPI_TARGET_URL: https://target/api
```