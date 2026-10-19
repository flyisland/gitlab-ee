---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
title: Rust 语言及生态系统解决方案索引
---

除非另有说明，这些内容均适用于 JihuLab.com 和极狐GitLab 私有化部署实例。

| 文本标签                 | 配置 / 内置 / 解决方案                             | 支持 / 维护                                          |
| ------------------------ | ------------------------------------------------------ | ------------------------------------------------------ |
| `[Rust Configuration]`    | 通过配置现有 Rust 功能实现的集成       | Rust                                                          |
| `[GitLab Configuration]` | 通过配置现有极狐GitLab 功能实现的集成    | 极狐GitLab                                                       |
| `[Rust Partner Built]`         | 由产品团队为满足 Rust 集成需求而内置到极狐GitLab 中 | 极狐GitLab                                                       |
| `[Rust Partner Solution]`         | 由 Rust 或 Rust 合作伙伴构建的解决方案示例             | 社区 / 示例                                            |
| `[GitLab Solution]`      | 由极狐GitLab 或极狐GitLab 合作伙伴构建的解决方案示例       | 社区 / 示例                                            |
| `[CI Solution]`          | 使用极狐GitLab CI 构建，因此更便于客户自定义。 | 标记为 `[CI Solution]` 的项也将<br />携带其他表示维护状态的标签。 |

<a id="rust-scm"></a>

## Rust 源代码管理

- 极狐GitLab Duo 代码建议 `[GitLab Built]`

<a id="rust-ci"></a>

## Rust CI

- [单元测试结果](../../../ci/testing/unit_test_report_examples.md#rust) `[GitLab Built]`
- [极狐GitLab CI/CD Rust 组件](https://gitlab.com/explore/catalog/components/rust) `[GitLab Built]`
  - [使用 Rust 组件](../../../ci/components/examples.md#example-test-a-rust-language-cicd-component) `[GitLab Built]`

<a id="rust-cd"></a>

## Rust CD

- [极狐GitLab CI/CD Rust 组件（当前处于预发布阶段）](https://gitlab.com/explore/catalog/components/rust) `[GitLab Built]`
  - [如何使用 Rust 组件](../../../ci/components/examples.md#example-test-a-rust-language-cicd-component) `[GitLab Built]`

<a id="rust-security-and-sbom"></a>

## Rust 安全与 SBOM

- [测试代码覆盖率](../../../ci/testing/code_coverage/_index.md#coverage-regex-patterns) `[GitLab Built]`
- [极狐GitLab SAST 扫描](../../../user/application_security/sast/_index.md#supported-languages-and-frameworks) `[GitLab Built]` - 需要创建自定义规则集。
- [Rust 许可证扫描（当前处于预发布阶段）](https://jihulab.com/groups/gitlab-cn/-/epics/13093) `[GitLab Built]`
- [CodeSecure CodeSonar 嵌入式 C 深度 SAST 扫描器作为极狐GitLab CI/CD 组件](https://gitlab.com/explore/catalog/codesonar/components/codesonar-ci) `[Rust Partner Built]` `[CI Solution]` - 通过监控编译过程支持深度抽象执行分析。支持极狐GitLab 的 SAST JSON 格式，使分析结果可在极狐GitLab 旗舰版安全功能中使用。支持 MISRA，并直接支持多种嵌入式系统编译器。

