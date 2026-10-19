---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: JUnit XML configuration examples for Ruby, Go, Java, Python, JavaScript, and other languages.
title: 单元测试报告示例
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用这些示例作为配置不同语言和测试框架的单元测试报告的指南。
单元测试报告要求您的测试框架生成 JUnit XML 格式输出，并要求您的 CI/CD 作业将结果作为产物上传。

以下示例展示了要添加到 `.gitlab-ci.yml` 文件中的各个作业配置。
所有示例均使用：

- `artifacts:when: always` 以在测试失败时也上传报告。
- `artifacts:reports:junit` 以指定 JUnit XML 文件位置。
- 必要时在 `before_script` 中进行软件包安装。

每个示例都是一个功能齐全的作业，您可以复制并适配到您的项目中。
您可能需要：

- 添加或修改环境的 `image:` 规范。
- 修改依赖项的软件包安装命令。
- 更改文件路径以匹配您的项目结构。
- 更新测试命令以匹配您的测试设置。

有关设置说明和故障排除，请参见[单元测试报告](unit_test_reports.md)。

<a id="junit-output-configuration-by-tool"></a>

## 按工具划分的 JUnit 输出配置

| 语言         | 工具                    | JUnit 输出标志 |
| ------------ | ----------------------- | ----------------- |
| .NET         | `JunitXML.TestLogger`   | `--logger:"junit;LogFilePath=report.xml"` |
| C/C++        | GoogleTest              | `--gtest_output="xml:report.xml"` |
| C/C++        | CUnit                   | 使用 `CUnitCI.h` 宏自动生成 |
| Flutter/Dart | `junitreport`           | `\| tojunit -o report.xml` |
| Go           | `gotestsum`             | `--junitfile report.xml` |
| Helm         | `helm-unittest`         | `-t JUnit -o report.xml` |
| Java         | Gradle                  | 在 `build/test-results/test/` 中自动生成 |
| Java         | Maven                   | 在 `target/surefire-reports/` 和 `target/failsafe-reports/` 中自动生成 |
| JavaScript   | `jest-junit`            | `--reporters=jest-junit` |
| JavaScript   | `karma-junit-reporter`  | `--reporters junit` |
| JavaScript   | `mocha-gitlab-reporter` | `--reporter mocha-gitlab-reporter` |
| PHP          | PHPUnit                 | `--log-junit report.xml` |
| Python       | `pytest`                | `--junitxml=report.xml` |
| Ruby         | `rspec_junit_formatter` | `--format RspecJunitFormatter --out report.xml` |
| Rust         | `cargo2junit`           | `\| cargo2junit > report.xml` |

<a id="net"></a>

## .NET

使用 .NET 和 [`JunitXML.TestLogger`](https://www.nuget.org/packages/JunitXml.TestLogger/) NuGet 软件包生成 JUnit XML 报告：

```yaml
Test:
  stage: test
  script:
    - 'dotnet test --test-adapter-path:. --logger:"junit;LogFilePath=..\artifacts\{assembly}-test-result.xml;MethodFormat=Class;FailureBodyFormat=Verbose"'
  artifacts:
    when: always
    paths:
      - ./**/*test-result.xml
    reports:
      junit:
        - ./**/*test-result.xml
```

此示例期望在仓库的根文件夹中有一个解决方案，且子文件夹中有一个或多个项目文件。
每个测试项目生成一个结果文件，每个文件放在产物文件夹中。
格式化参数提高了测试小部件中测试数据的可读性。

<a id="cc"></a>

## C/C++

<a id="googletest"></a>

### GoogleTest

使用内置 XML 输出的 [GoogleTest](https://github.com/google/googletest) 生成 JUnit XML 报告：

```yaml
cpp:
  stage: test
  script:
    - gtest.exe --gtest_output="xml:report.xml"
  artifacts:
    when: always
    reports:
      junit: report.xml
```

如果为不同架构（`x86`、`x64` 或 `arm`）创建了多个 `gtest` 可执行文件，请确保每个测试都有唯一的文件名。然后，结果会被聚合在一起。

<a id="cunit"></a>

### CUnit

使用 CUnit 和 [`CUnitCI.h` 宏](https://cunity.gitlab.io/cunit/group__CI.html) 生成 JUnit XML 报告：

```yaml
cunit:
  stage: test
  script:
    - ./my-cunit-test
  artifacts:
    when: always
    reports:
      junit: ./my-cunit-test.xml
```

<a id="flutter-or-dart"></a>

## Flutter 或 Dart

使用 Flutter 或 Dart 和 [`junitreport`](https://pub.dev/packages/junitreport) 软件包生成 JUnit XML 报告：

```yaml
test:
  stage: test
  script:
    - flutter test --machine | tojunit -o report.xml
  artifacts:
    when: always
    reports:
      junit:
        - report.xml
```

此示例使用 `junitreport` 软件包将 `flutter test` 输出转换为 JUnit 报告 XML 格式。

<a id="go"></a>

## Go

使用 Go 和 [`gotestsum`](https://github.com/gotestyourself/gotestsum) 生成 JUnit XML 报告：

```yaml
golang:
  stage: test
  script:
    - go install gotest.tools/gotestsum@latest
    - gotestsum --junitfile report.xml --format testname
  artifacts:
    when: always
    reports:
      junit: report.xml
```

<a id="helm"></a>

## Helm

使用 Helm 和 [`Helm Unittest`](https://github.com/helm-unittest/helm-unittest#docker-usage) 插件生成 JUnit XML 报告：

```yaml
helm:
  image: helmunittest/helm-unittest:latest
  stage: test
  script:
    - '-t JUnit -o report.xml -f tests/*[._]test.yaml .'
  artifacts:
    when: always
    reports:
      junit: report.xml
```

`-f tests/*[._]test.yaml` 标志配置 `helm-unittest` 在 `tests/` 目录中查找以 `.test.yaml` 或 `_test.yaml` 结尾的文件。

<a id="java"></a>

## Java

<a id="gradle"></a>

### Gradle

使用内置测试报告的 [Gradle](https://gradle.org/) 生成 JUnit XML 报告：

```yaml
java:
  stage: test
  script:
    - gradle test
  artifacts:
    when: always
    reports:
      junit: build/test-results/test/**/TEST-*.xml
```

如果定义了多个测试任务，`gradle` 会在 `build/test-results/` 下生成多个目录。
这种情况下，您可以通过定义以下路径来利用 glob 匹配：`build/test-results/test/**/TEST-*.xml`。

<a id="maven"></a>

### Maven

使用 Maven 的 [Surefire](https://maven.apache.org/surefire/maven-surefire-plugin/) 和 [Failsafe](https://maven.apache.org/surefire/maven-failsafe-plugin/) 测试报告生成 JUnit XML 报告：

```yaml
java:
  stage: test
  script:
    - mvn verify
  artifacts:
    when: always
    reports:
      junit:
        - target/surefire-reports/TEST-*.xml
        - target/failsafe-reports/TEST-*.xml
```

<a id="javascript"></a>

## JavaScript

<a id="jest"></a>

### Jest

使用 Jest 和 [`jest-junit`](https://github.com/jest-community/jest-junit) npm 软件包生成 JUnit XML 报告：

```yaml
javascript:
  image: node:latest
  stage: test
  before_script:
    - 'yarn global add jest'
    - 'yarn add --dev jest-junit'
  script:
    - 'jest --ci --reporters=default --reporters=jest-junit'
  artifacts:
    when: always
    reports:
      junit:
        - junit.xml
```

当没有包含单元测试的 `.test.js` 文件时，为了让作业通过，可以在 `script:` 部分的 `jest` 命令末尾添加 `--passWithNoTests` 标志。

<a id="karma"></a>

### Karma

使用 Karma 和 [`karma-junit-reporter`](https://github.com/karma-runner/karma-junit-reporter) npm 软件包生成 JUnit XML 报告：

```yaml
javascript:
  stage: test
  script:
    - karma start --reporters junit
  artifacts:
    when: always
    reports:
      junit:
        - junit.xml
```

<a id="mocha"></a>

### Mocha

有关 Mocha 配置示例，请参见 [`mocha-gitlab-reporter`](https://github.com/X-Guardian/mocha-gitlab-reporter?tab=readme-ov-file#gitlab-ci-configuration)。

<a id="php"></a>

## PHP

使用 PHP 和 [`PHPUnit`](https://phpunit.de/index.html) 生成 JUnit XML 报告：

```yaml
phpunit:
  stage: test
  script:
    - composer install
    - vendor/bin/phpunit --log-junit report.xml
  artifacts:
    when: always
    reports:
      junit: report.xml
```

您也可以在 `phpunit.xml` 配置文件中通过 [XML](https://docs.phpunit.de/en/11.0/configuration.html#the-junit-element) 设置此选项。

<a id="python"></a>

## Python

使用 Python 和 [`pytest`](https://pytest.org/) 生成 JUnit XML 报告：

```yaml
pytest:
  stage: test
  script:
    - pytest --junitxml=report.xml
  artifacts:
    when: always
    reports:
      junit: report.xml
```

<a id="ruby"></a>

## Ruby

使用 RSpec 和 [`rspec_junit_formatter`](https://github.com/sj26/rspec_junit_formatter) gem 生成 JUnit XML 报告：

```yaml
ruby:
  image: ruby:3.0.4
  stage: test
  before_script:
    - apt-get update -y && apt-get install -y bundler
  script:
    - bundle install
    - bundle exec rspec --format progress --format RspecJunitFormatter --out rspec.xml
  artifacts:
    when: always
    paths:
      - rspec.xml
    reports:
      junit: rspec.xml
```

<a id="rust"></a>

## Rust

使用 Rust 和 [`cargo2junit`](https://crates.io/crates/cargo2junit) 生成 JUnit XML 报告：

```yaml
run unittests:
  image: rust:latest
  stage: test
  before_script:
    - cargo install --root . cargo2junit
  script:
    - cargo test -- -Z unstable-options --format json --report-time | bin/cargo2junit > report.xml
  artifacts:
    when: always
    reports:
      junit:
        - report.xml
```

要从 `cargo test` 获取 JSON 输出，您必须启用 nightly 编译器。
该工具安装在当前目录。