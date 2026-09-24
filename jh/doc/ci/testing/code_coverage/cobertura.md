---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 Cobertura XML 报告，在合并请求差异中显示逐行测试覆盖率注释。
title: Cobertura 覆盖率可视化
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 Cobertura XML 报告，在合并请求差异中显示逐行覆盖率注释。极狐GitLab 读取 Cobertura XML 报告，并将每个更改的行注释为已覆盖（绿色）、未覆盖（红色）或已加载但从未执行（橙色）。极狐GitLab 会包含流水线中任何阶段、任何作业的报告。

覆盖率可视化使用 [`artifacts:reports:coverage_report`](../../yaml/artifacts_reports.md#artifactsreportscoverage_report)
关键字。它不会在合并请求小组件中显示覆盖率百分比，也不会填充覆盖率历史图表。要显示覆盖率百分比，请单独配置
[`coverage`](../../yaml/_index.md#coverage) 关键字。

[Cobertura XML](https://cobertura.github.io/cobertura/) 格式最初
是为 Java 开发的，但大多数覆盖率框架都通过插件或内置导出器支持它：

- [`simplecov-cobertura`](https://rubygems.org/gems/simplecov-cobertura) (Ruby)
- [`gocover-cobertura`](https://github.com/boumenot/gocover-cobertura) (Go)
- [`cobertura`](https://www.npmjs.com/package/cobertura) (Node.js)
- [Istanbul](https://istanbul.js.org/docs/advanced/alternative-reporters/#cobertura) (JavaScript)
- [Coverage.py](https://coverage.readthedocs.io/en/coverage-5.0.4/cmd.html#xml-reporting) (Python)
- [PHPUnit](https://github.com/sebastianbergmann/phpunit-documentation-english/blob/master/src/textui.rst#command-line-options) (PHP)

<a id="example-cicd-configurations"></a>

## CI/CD 配置示例

以下示例展示了如何为不同编程语言配置 CI/CD 作业。
您也可以在 [`coverage-report`](https://gitlab.com/gitlab-org/ci-sample-projects/coverage-report/)
演示项目中查看可运行的示例。

<a id="javascript-example"></a>

### JavaScript 示例

以下 `.gitlab-ci.yml` 示例使用 [Mocha](https://mochajs.org/) 和
[nyc](https://github.com/istanbuljs/nyc) 生成覆盖率产物：

```yaml
test:
  script:
    - npm install
    - npx nyc --reporter cobertura mocha
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
```

<a id="java-and-kotlin-examples"></a>

### Java 和 Kotlin 示例

极狐GitLab 17.6 及更高版本原生支持 JaCoCo 格式。
对于新项目，请使用[原生 JaCoCo 报告](jacoco.md)。

以下示例使用 [jacoco2cobertura](https://gitlab.com/haynes/jacoco2cobertura)
Docker 镜像将 JaCoCo 报告转换为 Cobertura 格式。

<a id="maven-example"></a>

#### Maven 示例

`test-jdk11` 作业使用 [Maven](https://maven.apache.org/) 生成 JaCoCo XML
产物。`coverage-jdk11` 作业将其转换为 Cobertura 格式：

```yaml
test-jdk11:
  stage: test
  image: maven:3.6.3-jdk-11
  script:
    - mvn $MAVEN_CLI_OPTS clean org.jacoco:jacoco-maven-plugin:prepare-agent test jacoco:report
  artifacts:
    paths:
      - target/site/jacoco/jacoco.xml

coverage-jdk11:
  # The `visualize` stage does not exist by default.
  # Define it first, or use an existing stage like `deploy`.
  stage: visualize
  image: registry.gitlab.com/haynes/jacoco2cobertura:1.0.11
  script:
    # Convert report from JaCoCo to Cobertura, using relative project path
    - python /opt/cover2cover.py target/site/jacoco/jacoco.xml $CI_PROJECT_DIR/src/main/java/
        > target/site/cobertura.xml
  needs: ["test-jdk11"]
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: target/site/cobertura.xml
```

<a id="gradle-example"></a>

#### Gradle 示例

`test-jdk11` 作业使用 [Gradle](https://gradle.org/) 生成 JaCoCo XML 产物。
`coverage-jdk11` 作业将其转换为 Cobertura 格式：

```yaml
test-jdk11:
  stage: test
  image: gradle:6.6.1-jdk11
  script:
    - gradle test jacocoTestReport # JaCoCo must be configured to create an XML report
  artifacts:
    paths:
      - build/jacoco/jacoco.xml

coverage-jdk11:
  # The `visualize` stage does not exist by default.
  # Define it first, or use an existing stage like `deploy`.
  stage: visualize
  image: registry.gitlab.com/haynes/jacoco2cobertura:1.0.11
  script:
    # Convert report from JaCoCo to Cobertura, using relative project path
    - python /opt/cover2cover.py build/jacoco/jacoco.xml $CI_PROJECT_DIR/src/main/java/
        > build/cobertura.xml
  needs: ["test-jdk11"]
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: build/cobertura.xml
```

<a id="python-example"></a>

### Python 示例

以下 `.gitlab-ci.yml` 示例使用 [pytest-cov](https://pytest-cov.readthedocs.io/en/latest/)
收集测试覆盖率数据：

```yaml
run tests:
  stage: test
  image: python:3
  script:
    - pip install pytest pytest-cov
    - pytest --cov --cov-report term --cov-report xml:coverage.xml
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
```

<a id="php-example"></a>

### PHP 示例

以下 `.gitlab-ci.yml` 示例使用 [PHPUnit](https://phpunit.readthedocs.io/)
收集测试覆盖率数据并生成报告。

使用一个最小的 [`phpunit.xml`](https://docs.phpunit.de/en/11.0/configuration.html) 文件
（您可以参考
[此示例代码仓库](https://gitlab.com/yookoala/code-coverage-visualization-with-php/)），
即可运行测试并生成 `coverage.xml`：

```yaml
run tests:
  stage: test
  image: php:latest
  variables:
    XDEBUG_MODE: coverage
  before_script:
    - apt-get update && apt-get -yq install git unzip zip libzip-dev zlib1g-dev
    - docker-php-ext-install zip
    - pecl install xdebug && docker-php-ext-enable xdebug
    - php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    - php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    - composer install
    - composer require --dev phpunit/phpunit phpunit/php-code-coverage
  script:
    - php ./vendor/bin/phpunit --coverage-text --coverage-cobertura=coverage.cobertura.xml
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.cobertura.xml
```

[Codeception](https://codeception.com/) 通过 PHPUnit，也支持使用 [`run`](https://codeception.com/docs/reference/Commands#run) 生成
Cobertura 报告。
生成文件的路径取决于 `--coverage-cobertura` 选项和
[`paths`](https://codeception.com/docs/reference/Configuration#paths) 配置
中的[单元测试套件](https://codeception.com/docs/05-UnitTests)。配置
`.gitlab-ci.yml` 以在相应路径中找到 Cobertura。

<a id="cc-example"></a>

### C/C++ 示例

以下针对 C/C++ 并使用 `gcc` 或 `g++` 的 `.gitlab-ci.yml` 示例使用
[`gcovr`](https://gcovr.com/en/stable/) 生成 Cobertura XML 格式的覆盖率输出文件。

此示例假设：

- `Makefile` 由前一阶段的另一个作业中的 `cmake` 在 `build` 目录中创建。如果您使用 `automake` 生成 `Makefile`，请调用 `make check`
  而不是 `make test`。
- `cmake`（或 `automake`）已设置编译器选项 `--coverage`。

```yaml
run tests:
  stage: test
  script:
    - cd build
    - make test
    - gcovr --xml-pretty --exclude-unreachable-branches --print-summary -o coverage.xml --root ${CI_PROJECT_DIR}
  artifacts:
    name: ${CI_JOB_NAME}-${CI_COMMIT_REF_NAME}-${CI_COMMIT_SHA}
    expire_in: 2 days
    reports:
      coverage_report:
        coverage_format: cobertura
        path: build/coverage.xml
```

<a id="go-example"></a>

### Go 示例

以下 `.gitlab-ci.yml` 示例使用：

- [`go test`](https://go.dev/doc/tutorial/add-a-test) 运行测试。
- [`gocover-cobertura`](https://github.com/boumenot/gocover-cobertura) 将 Go 的
  覆盖率配置文件转换为 Cobertura XML 格式。

此示例假设正在使用 [Go modules](https://go.dev/ref/mod)。`-covermode count`
选项不适用于 `-race` 标志。要在使用 `-race` 的同时生成代码覆盖率，请切换到 `-covermode atomic`，但速度会较慢。

```yaml
run tests:
  stage: test
  image: golang:1.17
  script:
    - go install
    - go test ./... -coverprofile=coverage.txt -covermode count
    - go get github.com/boumenot/gocover-cobertura
    - go run github.com/boumenot/gocover-cobertura < coverage.txt > coverage.xml
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
```

<a id="ruby-example"></a>

### Ruby 示例

以下 `.gitlab-ci.yml` 示例使用：

- [`rspec`](https://rspec.info/) 运行测试。
- [`simplecov`](https://github.com/simplecov-ruby/simplecov) 和
  [`simplecov-cobertura`](https://github.com/jessebs/simplecov-cobertura) 记录
  覆盖率配置文件并以 Cobertura XML 格式创建报告。

此示例假设：

- [`bundler`](https://bundler.io/) 用于依赖管理，并且 `rspec`、
  `simplecov` 和 `simplecov-cobertura` 已添加到您的 `Gemfile` 中。
- `CoberturaFormatter` 已添加到 `spec_helper.rb` 中的 `SimpleCov.formatters` 配置中。

```yaml
run tests:
  stage: test
  image: ruby:3.1
  script:
    - bundle install
    - bundle exec rspec
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/coverage.xml
```

<a id="troubleshooting"></a>

## 故障排除

有关覆盖率可视化的故障排除，包括路径解析失败、文件大小限制和注释不显示等问题，请参阅
[覆盖率可视化故障排除](coverage_visualization.md#troubleshooting)。
