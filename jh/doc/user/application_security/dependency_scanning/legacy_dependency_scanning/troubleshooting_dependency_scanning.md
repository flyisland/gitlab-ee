---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 依赖扫描故障排查
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用依赖扫描时，您可能会遇到以下问题。

<a id="debug-level-logging"></a>

## 调试级别日志

调试级别日志有助于故障排查。有关详细信息，请参阅
[调试级别日志](../../troubleshooting_application_security.md#turn-on-debug-level-logging)。

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

此命令使用调试级别日志运行分析器，并挂载您的本地代码仓库以分析依赖项。
您可以将 `registry.gitlab.com/security-products/gemnasium-python:5` 替换为适合您项目语言和依赖管理器的扫描器 `image:tag` 组合。

<a id="working-around-missing-support-for-certain-languages-or-package-managers"></a>

### 解决对某些语言或包管理器支持缺失的问题

如[支持的语言](_index.md#supported-languages-and-package-managers)中所述，某些
依赖定义文件尚不受支持。但是，如果该语言、包管理器或第三方工具可以将定义文件转换为
受支持的格式，则可以实现依赖扫描。

通常，方法如下：

1. 在您的 `.gitlab-ci.yml` 文件中定义一个专用的转换器作业。
   使用合适的 Docker 镜像、脚本或两者来促进转换。
1. 让该作业将转换后的受支持文件作为产物上传。
1. 将 [`dependencies: [<your-converter-job>]`](../../../../ci/yaml/_index.md#dependencies)
   添加到您的 `dependency_scanning` 作业，以使用转换后的定义文件。

例如，仅有 `pyproject.toml` 文件的 Poetry 项目可以按如下方式生成 `poetry.lock` 文件。

```yaml
include:
  - template: Jobs/Dependency-Scanning.gitlab-ci.yml

stages:
  - test

gemnasium-python-dependency_scanning:
  # Work around https://gitlab.com/gitlab-org/gitlab/-/issues/32774
  before_script:
    - pip install "poetry>=1,<2"  # Or via another method: https://python-poetry.org/docs/#installation
    - poetry update --lock # Generates the lockfile to be analyzed.
```

<a id="dependency-scanning-jobs-are-running-unexpectedly"></a>

## 依赖扫描作业意外运行

[依赖扫描 CI 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Dependency-Scanning.gitlab-ci.yml)
使用 [`rules:exists`](../../../../ci/yaml/_index.md#rulesexists)
语法。此指令限制为 10000 次检查，并且在达到此数量后始终返回 `true`。
因此，根据您代码仓库中的文件数量，即使扫描器不支持您的项目，也可能会触发依赖扫描作业。有关此限制的更多详细信息，请参阅 [`rules:exists` 文档](../../../../ci/yaml/_index.md#rulesexists)。

<a id="error-dependency_scanning-is-used-for-configuration-only-and-its-script-should-not-be-executed"></a>

## 错误：`dependency_scanning is used for configuration only, and its script should not be executed`

有关信息，请参阅[应用程序安全测试故障排查](../../troubleshooting_application_security.md#error-job-is-used-for-configuration-only-and-its-script-should-not-be-executed)。

<a id="import-multiple-certificates-for-java-based-projects"></a>

## 为基于 Java 的项目导入多个证书

`gemnasium-maven` 分析器使用 `keytool` 读取 `ADDITIONAL_CA_CERT_BUNDLE` 变量的内容，该工具会导入单个证书或证书链。多个不相关的证书会被忽略，`keytool` 仅导入第一个证书。

要向分析器添加多个不相关的证书，您可以在 `gemnasium-maven-dependency_scanning` 作业的定义中声明一个 `before_script`，如下所示：

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

## 依赖扫描作业失败并显示消息 `strconv.ParseUint: parsing "0.0": invalid syntax`

不支持 Docker-in-Docker，尝试调用它很可能是此错误的原因。

要修复此错误，请为依赖扫描禁用 Docker-in-Docker。在您的 CI/CD 流水线中运行的每个分析器都会创建单独的 `<analyzer-name>-dependency_scanning` 作业。

```yaml
include:
  - template: Dependency-Scanning.gitlab-ci.yml

variables:
  DS_DISABLE_DIND: "true"
```

<a id="message--does-not-exist-in-"></a>

## 消息 `<file> does not exist in <commit SHA>`

当显示文件中依赖项的 `Location` 时，链接中的路径指向特定的 Git SHA。

但是，如果依赖扫描工具审查的锁文件被缓存，选择该链接会将您重定向到代码仓库根目录，并显示消息：
`<file> does not exist in <commit SHA>`。

锁文件在构建阶段被缓存，并在扫描发生前传递给依赖扫描作业。由于缓存是在分析器运行前下载的，因此 `CI_BUILDS_DIR` 目录中存在锁文件会触发依赖扫描作业。

为防止此警告，应提交锁文件。

<a id="you-no-longer-get-the-latest-docker-image-after-setting-ds_major_version-or-ds_analyzer_image"></a>

## 设置 `DS_MAJOR_VERSION` 或 `DS_ANALYZER_IMAGE` 后不再获取最新的 Docker 镜像

如果您出于特定原因手动设置了 `DS_MAJOR_VERSION` 或 `DS_ANALYZER_IMAGE`，
现在必须更新配置以再次获取分析器的最新修补版本，请编辑您的 `.gitlab-ci.yml` 文件，然后执行以下任一操作：

- 将 `DS_MAJOR_VERSION` 设置为与
  [依赖扫描模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Dependency-Scanning.gitlab-ci.yml#L17) 中引用的版本匹配。
- 如果您直接硬编码了 `DS_ANALYZER_IMAGE` 变量，请将其更改为与 [依赖扫描模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Dependency-Scanning.gitlab-ci.yml) 中找到的最新行匹配。
  行号取决于您编辑了哪个扫描作业。

  例如，`gemnasium-maven-dependency_scanning` 作业会拉取最新的
  `gemnasium-maven` Docker 镜像，因为 `DS_ANALYZER_IMAGE` 设置为
  `"$SECURE_ANALYZERS_PREFIX/gemnasium-maven:$DS_MAJOR_VERSION"`。

<a id="dependency-scanning-of-setuptools-project-fails-with-use_2to3-is-invalid-error"></a>

## setuptools 项目的依赖扫描失败并显示 `use_2to3 is invalid` 错误

对 [2to3](https://docs.python.org/3.12/library/2to3.html) 的支持已在
`setuptools` 版本 `v58.0.0` 中[移除](https://setuptools.pypa.io/en/latest/history.html#v58-0-0)。依赖扫描（运行 `python 3.9`）使用 `setuptools`
版本 `58.1.0+`，该版本不支持 `2to3`。因此，依赖 `lib2to3` 的 `setuptools` 依赖项会失败并显示此消息：

```plaintext
error in <dependency name> setup command: use_2to3 is invalid
```

要解决此错误，请降级分析器的 `setuptools` 版本（例如，`v57.5.0`）：

```yaml
gemnasium-python-dependency_scanning:
  before_script:
    - pip install setuptools==57.5.0
```

<a id="dependency-scanning-of-projects-using-psycopg2-fails-with-pg_config-executable-not-found-error"></a>

## 使用 psycopg2 的项目的依赖扫描失败并显示 `pg_config executable not found` 错误

扫描依赖 `psycopg2` 的 Python 项目可能会失败并显示此消息：

```plaintext
Error: pg_config executable not found.
```

[psycopg2](https://pypi.org/project/psycopg2/) 依赖 `libpq-dev` Debian 软件包，
该软件包未安装在 `gemnasium-python` Docker 镜像中。要解决此错误，
请在 `before_script` 中安装 `libpq-dev` 软件包：

```yaml
gemnasium-python-dependency_scanning:
  before_script:
    - apt-get update && apt-get install -y libpq-dev
```

<a id="nosuchoptionexception-when-using-poetry-config-http-basic-with-ci_job_token"></a>

## 将 `poetry config http-basic` 与 `CI_JOB_TOKEN` 一起使用时出现 `NoSuchOptionException`

当自动生成的 `CI_JOB_TOKEN` 以连字符（`-`）开头时，可能会发生此错误。
为避免此错误，请遵循 [Poetry 的配置建议](https://python-poetry.org/docs/repositories/#configuring-credentials)。

<a id="error-project-has-unresolved-dependencies"></a>

## 错误：项目存在未解析的依赖项

以下错误消息指示由您的 `build.gradle` 或 `build.gradle.kts` 文件引起的 Gradle 依赖解析问题：

- `project has unresolved dependencies: ["dependency_name:version"]`

`gemnasium-maven` 支持 `DS_GRADLE_RESOLUTION_POLICY` 环境变量，您可以使用它来控制如何处理未解析的依赖项。默认情况下，遇到未解析的依赖项时扫描会失败。但是，您可以将环境变量 `DS_GRADLE_RESOLUTION_POLICY` 设置为 `"none"`，以允许扫描继续并产生部分结果。

有关修复 `build.gradle` 文件的指导，请参阅 [Gradle 依赖解析文档](https://docs.gradle.org/current/userguide/dependency_resolution.html)。有关更多详细信息，请参阅 [议题 482650](https://gitlab.com/gitlab-org/gitlab/-/issues/482650)。

此外，Kotlin 2.0.0 中存在一个影响依赖解析的已知问题，计划在 Kotlin 2.0.20 中修复。
有关更多信息，请参阅[此议题](https://github.com/gradle/github-dependency-graph-gradle-plugin/issues/140#issuecomment-2230255380)。

<a id="setting-build-constraints-when-scanning-go-projects"></a>

## 扫描 Go 项目时设置构建约束

依赖扫描在 `linux/amd64` 容器中运行。因此，为 Go 项目生成的构建列表包含与此环境兼容的依赖项。如果您的部署环境不是
`linux/amd64`，最终的依赖项列表可能包含额外的不兼容模块。依赖项列表也可能省略仅与您的部署环境兼容的模块。为防止
此问题，您可以通过在 `.gitlab-ci.yml` 文件中设置 `GOOS` 和 `GOARCH` [环境变量](https://go.dev/ref/mod#minimal-version-selection) 来配置构建过程以针对部署环境的操作系统和架构。

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

`go.sum` 文件包含生成项目[构建列表](https://go.dev/ref/mod#glos-build-list)时考虑过的每个模块的条目。
`go.sum` 文件中包含模块的多个版本，但 `go build` 使用的 [MVS](https://go.dev/ref/mod#minimal-version-selection)
算法仅选择一个。因此，当依赖扫描使用 `go.sum` 时，可能会报告误报。

为防止误报，Gemnasium 仅在无法为 Go 项目生成构建列表时才使用 `go.sum`。如果选择了 `go.sum`，则会出现警告：

```shell
[WARN] [Gemnasium] [2022-09-14T20:59:38Z] ▶ Selecting "go.sum" parser for "/test-projects/gitlab-shell/go.sum". False positives may occur. See https://gitlab.com/gitlab-org/gitlab/-/issues/321081.
```

<a id="host-key-verification-failed-when-trying-to-use-ssh"></a>

## 尝试使用 `ssh` 时出现 `Host key verification failed`

在任何 `gemnasium` 镜像上安装 `openssh-client` 后，使用 `ssh` 可能会导致 `Host key verification failed` 消息。如果在设置过程中使用 `~` 表示用户目录，则可能发生此情况，因为在构建镜像时将 `$HOME` 设置为 `/tmp`。此问题在[使用 `gemnasium-python` 镜像时通过 SSH 克隆项目失败](https://gitlab.com/gitlab-org/gitlab/-/issues/374571)中有所描述。`openssh-client` 期望找到 `/root/.ssh/known_hosts`，但此路径不存在；存在的是 `/tmp/.ssh/known_hosts`。

此问题已在 `gemnasium-python` 中解决，其中预装了 `openssh-client`，但在其他镜像上从头安装 `openssh-client` 时可能会出现问题。要解决此问题，您可以：

1. 在设置密钥和主机时使用绝对路径（`/root/.ssh/known_hosts` 而不是 `~/.ssh/known_hosts`）。
1. 将 `UserKnownHostsFile` 添加到您的 `ssh` 配置中，指定相关的 `known_hosts` 文件，例如：`echo 'UserKnownHostsFile /tmp/.ssh/known_hosts' >> /etc/ssh/ssh_config`。

<a id="error-these-packages-do-not-match-the-hashes-from-the-requirements-file"></a>

## `ERROR: THESE PACKAGES DO NOT MATCH THE HASHES FROM THE REQUIREMENTS FILE`

当 `requirements.txt` 文件中软件包的哈希与下载的软件包的哈希不匹配时，会发生此错误。
作为安全措施，`pip` 将假定该软件包已被篡改并拒绝安装它。
要解决此问题，请确保 requirements 文件中包含的哈希是正确的。
对于由 [`pip-compile`](https://pip-tools.readthedocs.io/en/stable/) 生成的 requirements 文件，请运行 `pip-compile --generate-hashes` 以确保哈希是最新的。
如果使用由 [`pipenv`](https://pipenv.pypa.io/en/latest/) 生成的 `Pipfile.lock`，请运行 `pipenv verify` 以验证锁文件包含最新的软件包哈希。

<a id="error-in---require-hashes-mode-all-requirements-must-have-their-versions-pinned-with-"></a>

## `ERROR: In --require-hashes mode, all requirements must have their versions pinned with ==`

如果 requirements 文件是在与极狐GitLab Runner 使用的平台不同的平台上生成的，则会发生此错误。
对其他平台的支持在 [议题 416376](https://gitlab.com/gitlab-org/gitlab/-/issues/416376) 中跟踪。

<a id="editable-flags-can-cause-dependency-scanning-for-python-to-hang"></a>

## 可编辑标志可能导致 Python 依赖扫描挂起

如果您在 `requirements.txt` 文件中使用 [`-e/--editable`](https://pip.pypa.io/en/stable/cli/pip_install/#install-editable) 标志来定位当前目录，您可能会遇到导致 Gemnasium Python 依赖扫描器在运行 `pip3 download` 时挂起的问题。
此命令是构建目标项目所必需的。

要解决此问题，请在为 Python 运行依赖扫描时不要使用 `-e/--editable` 标志。

<a id="handling-out-of-memory-errors-with-sbt"></a>

## 使用 SBT 处理内存不足错误

如果您在对 Scala 项目使用依赖扫描时遇到 SBT 内存不足错误，可以通过设置 [`SBT_CLI_OPTS`](_index.md#analyzer-specific-settings) 环境变量来解决。示例配置为：

```yaml
variables:
  SBT_CLI_OPTS: "-J-Xmx8192m -J-Xms4192m -J-Xss2M"
```

如果您使用 Kubernetes 执行器，则可能需要覆盖默认的 Kubernetes 资源设置。有关如何调整容器资源以防止内存问题的详细信息，请参阅 [Kubernetes 执行器文档](https://gitlab.cn/docs/runner/executors/kubernetes/#overwrite-container-resources)。

<a id="no-package-lockjson-file-in-npm-projects"></a>

## NPM 项目中没有 `package-lock.json` 文件

默认情况下，仅当代码仓库中存在 `package-lock.json` 文件时，依赖扫描作业才会运行。但是，某些 NPM 项目在构建过程中生成 `package-lock.json` 文件，而不是将它们存储在 Git 代码仓库中。

要扫描这些项目中的依赖项：

1. 在构建作业中生成 `package-lock.json` 文件。
1. 将生成的文件存储为产物。
1. 修改依赖扫描作业以使用该产物并调整其规则。

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

<a id="no-dependency-scanning-job-added-to-the-pipeline"></a>

## 未将依赖扫描作业添加到流水线

依赖扫描作业使用规则来检查是否存在包含依赖项的锁文件或与构建工具相关的文件。如果未检测到这些文件中的任何一个，则不会将该作业添加到流水线，即使锁文件是由流水线中的另一个作业生成的。

如果您遇到这种情况，请确保您的代码仓库包含一个
[受支持的文件](https://gitlab.com/gitlab-org/security-products/analyzers/dependency-scanning#supported-files)，
或一个指示在运行时生成受支持文件的文件。请考虑是否可以将此类文件添加到您的代码仓库以触发依赖扫描作业。

如果您认为您的代码仓库确实包含此类文件但作业仍未触发，请[打开一个议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/new)并提供以下信息：

- 您使用的语言和构建工具。
- 您提供哪种锁文件以及它在何处生成。

您也可以直接为[依赖扫描模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Dependency-Scanning.latest.gitlab-ci.yml#L269-270)做出贡献。

<a id="dependency-scanning-fails-with-gradlew-permission-denied"></a>

## 依赖扫描失败并显示 `gradlew: permission denied`

`gradlew` 上的 `permission denied` 错误通常表示 `gradlew` 在未设置可执行位的情况下被检入代码仓库。该错误可能会在您的作业中显示为以下消息：

```plaintext
[FATA] [gemnasium-maven] [2024-11-14T21:55:59Z] [/go/src/app/cmd/gemnasium-maven/main.go:65] ▶ fork/exec /builds/path/to/gradlew: permission denied
```

通过在本地运行 `chmod +ux gradlew` 并将文件推送到您的 Git 代码仓库来使文件可执行。

<a id="dependency-scanning-nebula-lock-creation-fails-due-to-unsupported-gradle-version"></a>

## 由于不支持的 Gradle 版本，依赖扫描 nebula 锁创建失败

当尝试使用不支持的 Gradle 版本（9.0 或更高版本）创建 [dependency.lockfiles](../dependency_scanning_sbom/_index.md#dependency-lock-plugin) 时，会发生以下错误：

```plaintext
FAILURE: Build failed with an exception.
* Where:
Initialization script '/builds/gitlab-org/app/app/nebula.gradle' line: 11
* What went wrong:
Failed to notify build listener.
> org/gradle/util/NameMatcher
```

尝试将您的 gradle 构建降级到 Gradle 8.10.2。

<a id="dependency-scanning-scanner-is-no-longer-gemnasium"></a>

## 依赖扫描扫描器不再是 `Gemnasium`

历史上，依赖扫描使用的扫描器是 `Gemnasium`，这是用户在[漏洞页面](../../vulnerabilities/_index.md)上可以看到的。

随着[使用 SBOM 进行依赖扫描](../dependency_scanning_sbom/_index.md)的推出，`Gemnasium` 扫描器被内置的 `GitLab SBoM Vulnerability Scanner` 取代。这个新扫描器不再在 CI/CD 作业中执行，而是在极狐GitLab 平台内执行。虽然预计两个扫描器会提供相同的结果，但由于 SBOM 扫描发生在现有的依赖扫描 CI/CD 作业之后，现有漏洞的扫描器值会更新为新的 `GitLab SBoM Vulnerability Scanner`。

`GitLab SBoM Vulnerability Scanner` 是极狐GitLab 内置依赖扫描功能的唯一预期值。

<a id="dependency-list-for-project-not-being-updated-based-on-latest-sbom"></a>

## 项目依赖列表未根据最新 SBOM 更新

当流水线中有一个会生成 SBOM 的作业失败时，`DeleteNotPresentOccurrencesService` 不会执行，这会阻止依赖列表被更改或更新。即使有其他成功上传 SBOM 的作业，并且流水线整体成功，也可能发生这种情况。这是为了防止在相关安全扫描作业失败时意外地从依赖列表中移除依赖项。如果项目依赖列表未按预期更新，请检查流水线中是否有任何与 SBOM 相关的作业可能失败，并修复或移除它们。

<a id="dependency-scanning-fails-with-open-etcsslcertsca-certificatescrt-permission-denied"></a>

## 依赖扫描失败并显示 `open /etc/ssl/certs/ca-certificates.crt: permission denied`

此错误通常表示运行容器的用户不属于 `root` 组。
通过运行 `id` 确保用户属于该组。

```shell
$ id
uid=1000(node) gid=0(root) groups=0(root),1000(node)
```

如果您运行 OpenShift 或使用 Kubernetes 执行器，请确保将 Runner 配置为使用组 ID (GID) 0 运行。

```toml
[[runners]]
[runners.kubernetes]
    [runners.kubernetes.pod_security_context]
    run_as_non_root = true
    run_as_group = 0
```

<a id="vulnerability-scanning-produces-no-results-for-custom-or-merged-cyclonedx-sboms"></a>

## 自定义或合并的 CycloneDX SBOM 的漏洞扫描不产生结果

依赖扫描 CI/CD 作业成功，SBOM 组件出现在依赖列表中，
但流水线安全选项卡中未报告漏洞。

在极狐GitLab 18.10 及更高版本上，安全选项卡显示消息：“SBOM 报告缺少漏洞扫描所需的 GitLab 元数据属性。”

当 SBOM 缺少所需的 [GitLab CycloneDX 属性](../../../../development/sec/cyclonedx_property_taxonomy.md) 时，会发生此问题。
没有这些属性，漏洞扫描器无法为 SBOM 的组件构建发现结果。依赖列表仍会填充，但不会报告漏洞。

这通常发生在以下情况：

- 使用 `cyclonedx merge` 合并多个 SBOM，这会剥离元数据属性。
- 第三方 SBOM 生成器不包含 GitLab 特定的属性。
- `metadata.properties` 中缺少 `gitlab:meta:schema_version` 属性（必须为 `1`）。

<a id="required-properties-for-vulnerability-scanning"></a>

### 漏洞扫描所需的属性

| 属性 | 位置 | 描述 |
|---|---|---|
| `gitlab:meta:schema_version` | `metadata.properties` | 必须设置为 `1`。 |
| `gitlab:dependency_scanning:input_file:path` | `metadata.properties` 或每个组件的 `properties` | 为生成依赖项而分析的锁文件的路径。如果两者都不存在，则不会为这些组件生成漏洞发现结果。在极狐GitLab 18.10 及更高版本上，流水线安全选项卡中会显示错误。 |

要解决此问题，请选择以下方法之一：

- 分别上传每个 SBOM。

  不要合并，而是将每个 SBOM 作为单独的
  [`artifacts: reports: cyclonedx:`](../../../../ci/yaml/artifacts_reports.md#artifactsreportscyclonedx) 条目上传。
  这会在每个文件中保留 GitLab 特定的属性。
- 向第三方 SBOM 添加属性。

  由第三方工具生成的 SBOM 通常
  不包含 GitLab 特定的属性。要启用漏洞扫描，请确保您的
  SBOM 在 `metadata.properties` 中包含以下内容：

  - `gitlab:meta:schema_version` 设置为 `1`
  - `gitlab:dependency_scanning:input_file:path` 设置为锁文件的代码仓库相对路径（例如，`package-lock.json` 或 `src/Gemfile.lock`）

  如果您的 SBOM 包含来自多个锁文件的组件，请在每个组件的 `properties` 数组中设置 `input_file:path`，而不是在元数据中设置，以便每个组件指向其正确的源文件。有关受支持属性的完整列表，请参阅
  [GitLab CycloneDX 属性分类](../../../../development/sec/cyclonedx_property_taxonomy.md)。

有关更多信息，请参阅 [议题 542813](https://gitlab.com/gitlab-org/gitlab/-/work_items/542813)
和 [合并请求 221549](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/221549)。

<a id="vulnerability-scanning-shows-wrong-input-file-for-all-dependencies"></a>

## 漏洞扫描为所有依赖项显示错误的输入文件

漏洞报告或依赖列表中的所有依赖项都显示相同的输入文件路径，
即使它们来自不同的锁文件。

当 `gitlab:dependency_scanning:input_file:path` 属性在 `metadata.properties` 中设置而不是按组件设置时，会发生此问题。根据
[属性分类](../../../../development/sec/cyclonedx_property_taxonomy.md)，元数据级别的
属性适用于文档中的所有对象，因此单个值会覆盖所有组件。

要解决此问题，请在每个组件的 `properties` 数组中单独设置 `input_file:path`，而不是在顶层元数据中设置。对于包含来自不同锁文件的组件的合并 SBOM，`input_file:path` 属性尤其重要。

<a id="error-node-with-package-name--does-not-exist"></a>

## 错误：`node with package name <package_name> does not exist`

当包管理器（通常是 nuget）无法找到该软件包时，会发生此问题。这可能
是因为用于构建应用程序的镜像与用于运行依赖扫描的镜像不同。

要解决此问题，请使用依赖扫描器用于构建应用程序的相同 .NET SDK 镜像。您可以通过运行以下命令找到确切的镜像：

```shell
curl --silent "https://gitlab.com/gitlab-org/security-products/analyzers/gemnasium/-/raw/master/build/gemnasium/alpine/Dockerfile" | grep "vrange-nuget-build" | grep "FROM"
```

检查上面链接的 Dockerfile 以获取当前镜像版本。
