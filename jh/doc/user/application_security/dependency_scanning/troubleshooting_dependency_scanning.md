---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 依赖扫描故障排查
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

在使用依赖扫描时，您可能会遇到以下问题。

<a id="debug-level-logging"></a>

## 调试级日志记录

调试级日志记录可以帮助进行故障排除。有关详细信息，请参阅[调试级日志记录](../troubleshooting_application_security.md#debug-level-logging)。

<a id="run-the-analyzer-in-a-local-environment"></a>

## 在本地环境中运行分析器

您可以在本地运行依赖扫描分析器来调试问题或验证行为，而无需运行流水线。

例如，要运行 Python 分析器：

```shell
cd project-git-repository

docker run \
   --interactive --tty --rm \
   --volume "$PWD":/tmp/app \
   --env CI_PROJECT_DIR=/tmp/app \
   --env SECURE_LOG_LEVEL=debug \
   -w /tmp/app \
   registry.gitlab.com/security-products/gemnasium-python:5 /analyzer run
```

此命令使用调试级日志记录运行分析器，并挂载您的本地存储库以分析依赖项。您可以将 `registry.gitlab.com/security-products/gemnasium-python:5` 替换为适合您的项目语言和依赖项管理器的扫描器 `image:tag` 组合。

<a id="working-around-missing-support-for-certain-languages-or-package-managers"></a>

### 解决某些语言或软件包管理器缺乏支持的问题

如在 ["支持的语言" 部分](_index.md#supported-languages-and-package-managers) 中所述，有些依赖定义文件尚未支持。但是，如果语言、软件包管理器或第三方工具可以将定义文件转换为支持的格式，则可以实现依赖扫描。

通常，方法如下：

1. 在您的 `.gitlab-ci.yml` 文件中定义一个专用转换器工作。使用合适的 Docker 镜像、脚本或两者来促进转换。
1. 让该工作上传转换后的支持文件作为产物。
1. 将 [`dependencies: [<your-converter-job>]`](../../../ci/yaml/_index.md#dependencies) 添加到您的 `dependency_scanning` 工作中，以使用转换后的定义文件。

例如，只有 `pyproject.toml` 文件的 Poetry 项目可以生成 `poetry.lock` 文件，如下所示。

```yaml
include:
  - template: Jobs/Dependency-Scanning.gitlab-ci.yml

stages:
  - test

gemnasium-python-dependency_scanning:
  # Work around https://gitlab.com/gitlab-org/gitlab/-/issues/32774
  before_script:
    - pip install "poetry>=1,<2"  # Or via another method: https://python-poetry.org/docs/#installation
    - poetry update --lock # Generates the lock file to be analyzed.
```

<a id="error-response-from-daemon-error-processing-tar-file-docker-tar-relocation-error"></a>

### `Error response from daemon: error processing tar file: docker-tar: relocation error`

此错误发生在运行依赖扫描作业的 Docker 版本为 `19.03.0` 时。考虑更新到 Docker `19.03.1` 或更高版本。旧版本不受影响。

<a id="getting-warning-message-gl-dependency-scanning-reportjson-no-matching-files"></a>

### 接收到警告消息 `gl-dependency-scanning-report.json: no matching files`

有关此信息，请参阅[一般应用程序安全故障排除部分](../troubleshooting_application_security.md#getting-warning-messages--reportjson-no-matching-files)。

<a id="dependency-scanning-jobs-are-running-unexpectedly"></a>

## 依赖扫描作业意外运行

[依赖扫描 CI 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Dependency-Scanning.gitlab-ci.yml) 使用了 [`rules:exists`](../../../ci/yaml/_index.md#rulesexists) 语法。此指令限制为 10000 次检查，并在达到此数量后始终返回 `true`。因此，根据您存储库中的文件数量，依赖扫描作业可能会被触发，即使扫描器不支持您的项目。有关此限制的更多详细信息，请参阅 [`rules:exists` 文档](../../../ci/yaml/_index.md#rulesexists)。

<a id="error-dependency-scanning-is-used-for-configuration-only-and-its-script-should-not-be-executed"></a>

## 错误：`dependency_scanning is used for configuration only, and its script should not be executed`

有关信息，请参阅[极狐GitLab Secure 故障排除部分](../troubleshooting_application_security.md#error-job-is-used-for-configuration-only-and-its-script-should-not-be-executed)。

<a id="import-multiple-certificates-for-java-based-projects"></a>

## 为基于 Java 的项目导入多个证书

`gemnasium-maven` 分析器使用 `keytool` 读取 `ADDITIONAL_CA_CERT_BUNDLE` 变量的内容，该工具导入单个证书或证书链。多个不相关的证书被忽略，`keytool` 仅导入第一个证书。

要向分析器添加多个不相关的证书，您可以在 `gemnasium-maven-dependency_scanning` 作业的定义中声明一个这样的 `before_script`：

```yaml
gemnasium-maven-dependency_scanning:
  before_script:
    - . $HOME/.bashrc # make the java tools available to the script
    - OIFS="$IFS"; IFS=""; echo $ADDITIONAL_CA_CERT_BUNDLE > multi.pem; IFS="$OIFS" # write ADDITIONAL_CA_CERT_BUNDLE variable to a PEM file
    - csplit -z --digits=2 --prefix=cert multi.pem "/-----END CERTIFICATE-----/+1" "{*}" # split the file into individual certificates
    - for i in `ls cert*`; do keytool -v -importcert -alias "custom-cert-$i" -file $i -trustcacerts -noprompt -storepass changeit -keystore /opt/asdf/installs/java/adoptopenjdk-11.0.7+10.1/lib/security/cacerts 1>/dev/null 2>&1 || true; done # import each certificate using keytool (note the keystore location is related to the Java version being used and should be changed accordingly for other versions)
    - unset ADDITIONAL_CA_CERT_BUNDLE # unset the variable so that the analyzer doesn't duplicate the import
```

<a id="dependency-scanning-job-fails-with-message-strconvparseuint-parsing-00-invalid-syntax"></a>

## 依赖扫描作业因消息 `strconv.ParseUint: parsing "0.0": invalid syntax` 失败

Docker-in-Docker 是不支持的，尝试调用它可能是此错误的原因。

要修复此错误，请禁用 Docker-in-Docker 以进行依赖扫描。每个分析器在您的 CI/CD 流水线中运行时都会创建单独的 `<analyzer-name>-dependency_scanning` 作业。

```yaml
include:
  - template: Dependency-Scanning.gitlab-ci.yml

variables:
  DS_DISABLE_DIND: "true"
```

<a id="message-file-does-not-exist-in-commit-sha"></a>

## 消息 `<file> does not exist in <commit SHA>`

当依赖项在文件中的 `Location` 显示时，链接中的路径指向特定的 Git SHA。

然而，如果我们的依赖扫描工具审查的锁文件已被缓存，则选择该链接会重定向到存储库根目录，并显示消息： `<file> does not exist in <commit SHA>`。

锁文件在构建阶段被缓存，并在扫描发生之前传递给依赖扫描作业。由于在分析器运行之前下载了缓存，因此锁文件在 `CI_BUILDS_DIR` 目录中的存在会触发依赖扫描作业。

为了防止此警告，锁文件应被提交。

<a id="you-no-longer-get-the-latest-docker-image-after-setting-ds_major_version-or-ds_analyzer_image"></a>

## 设置 `DS_MAJOR_VERSION` 或 `DS_ANALYZER_IMAGE` 后不再获取最新 Docker 镜像

如果您出于特定原因手动设置了 `DS_MAJOR_VERSION` 或 `DS_ANALYZER_IMAGE`，现在必须更新您的配置以再次获取我们分析器的最新修补版本，请编辑您的 `.gitlab-ci.yml` 文件并执行以下操作：

- 将您的 `DS_MAJOR_VERSION` 设置为与我们当前的依赖扫描模板中看到的最新版本相匹配。
- 如果您直接硬编码了 `DS_ANALYZER_IMAGE` 变量，请将其更改为与我们当前的依赖扫描模板中找到的最新行相匹配。行号因您编辑的扫描作业而异。

例如，`gemnasium-maven-dependency_scanning` 作业会拉取最新的 `gemnasium-maven` Docker 镜像，因为 `DS_ANALYZER_IMAGE` 被设置为 `"$SECURE_ANALYZERS_PREFIX/gemnasium-maven:$DS_MAJOR_VERSION"`。

<a id="dependency-scanning-of-setuptools-project-fails-with-use_2to3-is-invalid-error"></a>

## `setuptools` 项目的依赖扫描因 `use_2to3 is invalid` 错误失败

对 2to3 的支持已在 `setuptools` 版本 `v58.0.0` 中被移除。依赖扫描（运行 `python 3.9`）使用 `setuptools` 版本 `58.1.0+`，不支持 `2to3`。因此，依赖于 `lib2to3` 的 `setuptools` 依赖项会因以下消息而失败：

```plaintext
error in <dependency name> setup command: use_2to3 is invalid
```

要解决此错误，请将分析器的 `setuptools` 版本降级（例如 `v57.5.0`）：

```yaml
gemnasium-python-dependency_scanning:
  before_script:
    - pip install setuptools==57.5.0
```

<a id="dependency-scanning-of-projects-using-psycopg2-fails-with-pg_config-executable-not-found-error"></a>

## 使用 `psycopg2` 的项目的依赖扫描因 `pg_config executable not found` 错误失败

扫描依赖于 `psycopg2` 的 Python 项目可能会因以下消息而失败：

```plaintext
Error: pg_config executable not found.
```

psycopg2 依赖于 `libpq-dev` Debian 软件包，该软件包未安装在 `gemnasium-python` Docker 镜像中。要解决此错误，请在 `before_script` 中安装 `libpq-dev` 软件包：

```yaml
gemnasium-python-dependency_scanning:
  before_script:
    - apt-get update && apt-get install -y libpq-dev
```

<a id="nosuchoptionexception-when-using-poetry-config-http-basic-with-ci_job_token"></a>

## 使用 `poetry config http-basic` 和 `CI_JOB_TOKEN` 时出现 `NoSuchOptionException`

当自动生成的 `CI_JOB_TOKEN` 以连字符（`-`）开头时，可能会出现此错误。

<a id="error-project-has-unresolved-dependencies"></a>

## 错误：项目有未解决的依赖项

以下错误消息指示由您的 `build.gradle` 或 `build.gradle.kts` 文件引起的 Gradle 依赖解析问题：

- `Project has <number> unresolved dependencies`（极狐GitLab 16.7 至 16.9）
- `project has unresolved dependencies: ["dependency_name:version"]`（极狐GitLab 17.0 及更高版本）

在极狐GitLab 16.7 至 16.9 中，`gemnasium-maven` 在遇到未解决的依赖项时无法继续处理。

在极狐GitLab 17.0 及更高版本中，`gemnasium-maven` 支持环境变量 `DS_GRADLE_RESOLUTION_POLICY`，您可以使用该变量来控制未解决的依赖项的处理方式。默认情况下，当遇到未解决的依赖项时，扫描会失败。但是，您可以将环境变量 `DS_GRADLE_RESOLUTION_POLICY` 设置为 `"none"`，以允许扫描继续并生成部分结果。

此外，在 `Kotlin 2.0.0` 中存在一个影响依赖解析的已知问题，计划在 `Kotlin 2.0.20` 中修复。

<a id="setting-build-constraints-when-scanning-go-projects"></a>

## 扫描 Go 项目时设置构建约束

依赖扫描在 `linux/amd64` 容器中运行。因此，为 Go 项目生成的构建列表包含与此环境兼容的依赖项。如果您的部署环境不是 `linux/amd64`，则最终的依赖项列表可能包含额外的、不兼容的模块。依赖项列表可能还会省略仅与您的部署环境兼容的模块。为了防止此问题，您可以通过设置 `.gitlab-ci.yml` 文件的 `GOOS` 和 `GOARCH` 环境变量来将构建过程配置为针对部署环境的操作系统和架构。

例如：

```yaml
variables:
  GOOS: "darwin"
  GOARCH: "arm64"
```

您还可以使用 `GOFLAGS` 变量提供构建标签约束：

```yaml
variables:
  GOFLAGS: "-tags=test_feature"
```

<a id="dependency-scanning-of-go-projects-returns-false-positives"></a>

## Go 项目的依赖扫描返回误报

`go.sum` 文件包含生成项目构建列表时考虑的每个模块的条目。多个版本的模块包含在 `go.sum` 文件中，但 `go build` 使用的 MVS 算法仅选择一个版本。因此，当依赖扫描使用 `go.sum` 时，可能会报告误报。

为了防止误报，Gemnasium 仅在无法为 Go 项目生成构建列表时使用 `go.sum`。如果选择了 `go.sum`，则会出现警告：

```shell
[WARN] [Gemnasium] [2022-09-14T20:59:38Z] ▶ Selecting "go.sum" parser for "/test-projects/gitlab-shell/go.sum". False positives may occur. See https://gitlab.com/gitlab-org/gitlab/-/issues/321081.
```

<a id="host-key-verification-failed-when-trying-to-use-ssh"></a>

## 尝试使用 `ssh` 时出现 `Host key verification failed`

在任何 `gemnasium` 镜像上安装 `openssh-client` 后，使用 `ssh` 可能会导致 `Host key verification failed` 消息。如果您在设置期间使用 `~` 来表示用户目录，由于在构建镜像时将 `$HOME` 设置为 `/tmp`，可能会发生此问题。`openssh-client` 期望找到 `/root/.ssh/known_hosts`，但此路径不存在；而 `/tmp/.ssh/known_hosts` 存在。

此问题已在预安装 `openssh-client` 的 `gemnasium-python` 中解决，但在其他镜像上从头安装 `openssh-client` 时可能会发生。要解决此问题，您可以：

1. 在设置密钥和主机时使用绝对路径（`/root/.ssh/known_hosts` 而不是 `~/.ssh/known_hosts`）。
1. 在您的 `ssh` 配置中添加 `UserKnownHostsFile`，指定相关的 `known_hosts` 文件，例如：`echo 'UserKnownHostsFile /tmp/.ssh/known_hosts' >> /etc/ssh/ssh_config`。

<a id="error-these-packages-do-not-match-the-hashes-from-the-requirements-file"></a>

## `ERROR: THESE PACKAGES DO NOT MATCH THE HASHES FROM THE REQUIREMENTS FILE`

当 `requirements.txt` 文件中的软件包哈希与下载的软件包哈希不匹配时，会发生此错误。作为安全措施，`pip` 会假定软件包已被篡改，并拒绝安装它。要解决此问题，请确保要求文件中包含的哈希是正确的。对于由 `pip-compile` 生成的要求文件，运行 `pip-compile --generate-hashes` 以确保哈希是最新的。如果使用由 `pipenv` 生成的 `Pipfile.lock`，运行 `pipenv verify` 以验证锁定文件包含最新的软件包哈希。

<a id="error-in-require-hashes-mode-all-requirements-must-have-their-versions-pinned-with"></a>

## `ERROR: In --require-hashes mode, all requirements must have their versions pinned with ==`

如果要求文件是在与极狐GitLab Runner 使用的平台不同的平台上生成的，则会出现此错误。

<a id="editable-flags-can-cause-dependency-scanning-for-python-to-hang"></a>

## 可编辑标志可能导致 Python 的依赖扫描挂起

如果您在 `requirements.txt` 文件中使用 `-e/--editable` 标志来定位当前目录，则可能会遇到一个导致 Gemnasium Python 依赖扫描器在运行 `pip3 download` 时挂起的问题。此命令是构建目标项目所必需的。

要解决此问题，请在运行 Python 的依赖扫描时不要使用 `-e/--editable` 标志。

<a id="handling-out-of-memory-errors-with-sbt"></a>

## 使用 SBT 处理内存不足错误

如果在 Scala 项目上使用依赖扫描时遇到 SBT 的内存不足错误，您可以通过设置 [`SBT_CLI_OPTS`](_index.md#analyzer-specific-settings) 环境变量来解决此问题。示例配置为：

```yaml
variables:
  SBT_CLI_OPTS: "-J-Xmx8192m -J-Xms4192m -J-Xss2M"
```

如果您使用的是 Kubernetes runner ，则可能需要覆盖默认的 Kubernetes 资源设置。有关如何调整容器资源以防止内存问题的详细信息，请参阅 [Kubernetes runner 文档](https://gitlab.cn/docs/runner/executors/kubernetes/#overwrite-container-resources)。

<a id="no-package-lockjson-file-in-npm-projects"></a>

## NPM 项目中没有 `package-lock.json` 文件

默认情况下，依赖扫描作业仅在存储库中有 `package-lock.json` 文件时运行。但是，有些 NPM 项目在构建过程中生成 `package-lock.json` 文件，而不是将它们存储在 Git 存储库中。

要扫描这些项目中的依赖项：

1. 在构建作业中生成 `package-lock.json` 文件。
1. 将生成的文件存储为产物。
1. 修改依赖扫描作业以使用产物并调整其规则。

例如，您的配置可能如下所示：

```yaml
include:
  - template: Dependency-Scanning.gitlab-ci.yml

build:
  script:
    - npm i
  artifacts:
    paths:
      - package-lock.json  # Store the generated package-lock.json as an artifact

gemnasium-dependency_scanning:
  needs: ["build"]
  rules:
    - if: "$DEPENDENCY_SCANNING_DISABLED == 'true' || $DEPENDENCY_SCANNING_DISABLED == '1'"
      when: never
    - if: "$DS_EXCLUDED_ANALYZERS =~ /gemnasium([^-]|$)/"
      when: never
    - if: $CI_COMMIT_BRANCH && $GITLAB_FEATURES =~ /\bdependency_scanning\b/ && $CI_GITLAB_FIPS_MODE == "true"
      variables:
        DS_IMAGE_SUFFIX: "-fips"
        DS_REMEDIATE: 'false'
    - if: "$CI_COMMIT_BRANCH && $GITLAB_FEATURES =~ /\\bdependency_scanning\\b/"
```

<a id="dependency-scanning-fails-with-gradlew-permission-denied"></a>

## 依赖扫描因 `gradlew: permission denied` 失败

`gradlew` 上的 `permission denied` 错误通常表明 `gradlew` 在未设置可执行位的情况下被检查到存储库中。错误可能会在您的作业中显示以下消息：

```plaintext
[FATA] [gemnasium-maven] [2024-11-14T21:55:59Z] [/go/src/app/cmd/gemnasium-maven/main.go:65] ▶ fork/exec /builds/path/to/gradlew: permission denied
```

通过在本地运行 `chmod +ux gradlew` 并将其推送到您的 Git 存储库来使文件可执行。

<a id="dependency-scanning-scanner-is-no-longer-gemnasium"></a>

## 依赖扫描扫描器不再是 `Gemnasium`

历史上，依赖扫描使用的扫描器是 `Gemnasium`，用户可以在[漏洞页面](../vulnerabilities/_index.md)中看到这一点。

随着[使用 SBOM 进行依赖扫描](dependency_scanning_sbom/_index.md)的推出，我们正在用内置的 `极狐GitLab SBoM Vulnerability Scanner` 替换 `Gemnasium` 扫描器。此新扫描器不再在 CI/CD 作业中执行，而是在极狐GitLab 平台内执行。虽然预计两个扫描器提供相同的结果，但由于 SBOM 扫描发生在现有依赖扫描 CI/CD 作业之后，现有漏洞的扫描器值会更新为新的 `极狐GitLab SBoM Vulnerability Scanner`。

随着我们继续推出并最终替换现有的 Gemnasium 分析器，`极狐GitLab SBoM Vulnerability Scanner` 将成为极狐GitLab 内置依赖扫描功能的唯一预期值。

<a id="dependency-list-for-project-not-being-updated-based-on-latest-sbom"></a>

## 项目的依赖列表未根据最新 SBOM 更新

当流水线有一个生成 SBOM 的失败作业时，`DeleteNotPresentOccurrencesService` 不会执行，这会阻止依赖列表被更改或更新。即使有其他成功的作业上传 SBOM，整个流水线成功，也可能发生这种情况。这是为了防止在相关安全扫描作业失败时意外删除依赖列表中的依赖项。如果项目依赖列表未按预期更新，请检查流水线中是否有任何与 SBOM 相关的作业可能失败，并修复或删除它们。
