---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用极狐GitLab 软件包仓库生成软件物料清单'
---

本教程介绍如何使用 CI/CD 流水线生成 CycloneDX 格式的软件物料清单（SBOM）。您将构建的流水线会收集群组中多个项目的软件包，让您全面了解相关项目中的依赖项。

完成本教程需要创建一个虚拟 Python 环境，但您也可以将同样的方法应用于其他受支持的软件包类型。

<a id="what-is-a-software-bill-of-materials"></a>

## 什么是软件物料清单？

SBOM 是构成软件产品的所有软件组件的机器可读清单。SBOM 可能包含：

- 直接依赖项和间接依赖项
- 开源组件及其许可证
- 软件包版本及其来源

有意使用某软件产品的组织可能会要求提供 SBOM，以便在采用该产品之前确定其安全性。

如果您熟悉极狐GitLab 软件包仓库，可能会想知道 SBOM 与[依赖项列表](../../application_security/dependency_list/_index.md)有何区别。下表列出了主要区别：

| 区别   | 依赖项列表                                               | SBOM |
|---------------|---------------------------------------------------------------|------|
| 范围     | 显示单个项目或群组的依赖项。         | 创建群组中发布的所有软件包的清单。 |
| 方向 | 跟踪您的项目依赖什么（传入依赖项）。  | 跟踪您的群组发布什么（传出软件包）。 |
| 覆盖范围  | 基于软件包清单文件，例如 `package.json` 或 `pom.xml`。 | 覆盖软件包仓库中实际发布的产物。 |

<a id="what-is-cyclonedx"></a>

## 什么是 CycloneDX？

CycloneDX 是一种轻量级、标准化的 SBOM 创建格式。CycloneDX 提供了定义完善的模式，可帮助组织：

- 记录软件组件及其关系。
- 跟踪软件供应链中的漏洞。
- 验证开源依赖项的许可证合规性。
- 建立一致且机器可读的 SBOM 格式。

CycloneDX 支持多种输出格式，包括 JSON、XML 和 Protocol Buffers，因此可灵活满足不同的集成需求。该规范设计得既全面又高效，涵盖从基本组件标识到软件来源详细元数据的所有内容。

<a id="before-you-begin"></a>

## 先决条件

要完成本教程，您需要：

- 一个具有维护者或所有者角色的群组。
- 对极狐GitLab CI/CD 的访问权限。
- 如果您使用的是极狐GitLab 私有化部署实例，则需要配置好的[极狐GitLab Runner](../../../ci/runners/_index.md#runner-categories)。如果您使用的是 JihuLab.com，则可以跳过此要求。
- 可选。[群组部署令牌](../../project/deploy_tokens/_index.md)，用于对软件包仓库的请求进行身份验证。

<a id="steps"></a>

## 步骤

本教程包含两组需要完成的步骤：

- 配置一个生成 CycloneDX 格式 SBOM 的 CI/CD 流水线
- 访问并使用生成的 SBOM 和软件包统计文件

以下是您将要执行的操作概览：

1. [添加基础流水线配置](#add-the-base-pipeline-configuration)。
1. [配置 `prepare` 阶段](#configure-the-prepare-stage)。
1. [配置 `collect` 阶段](#configure-the-collect-stage)。
1. [配置 `aggregate` 阶段](#configure-the-aggregate-stage)。
1. [配置 `publish` 阶段](#configure-the-publish-stage)。
1. [访问生成的 SBOM 和统计文件](#access-the-generated-files)。

> [!note]
> 在实施此解决方案之前，请注意：
>
> - 不会解析软件包依赖项（仅列出直接软件包）。
> - 会包含软件包版本，但不会分析漏洞。

<a id="add-the-base-pipeline-configuration"></a>

### 添加基础流水线配置

首先，设置基础镜像，它定义了整个流水线中使用的变量和阶段。

在以下各节中，您将通过为每个阶段添加配置来构建流水线。

在您的项目中：

1. 创建一个 `.gitlab-ci.yml` 文件。
1. 在该文件中，添加以下基础配置：

   ```yaml
   # Base image for all jobs
   image: alpine:latest

   variables:
     SBOM_OUTPUT_DIR: "sbom-output"
     SBOM_FORMAT: "cyclonedx"
     OUTPUT_TYPE: "json"
     GROUP_PATH: ${CI_PROJECT_NAMESPACE}

   before_script:
     - apk add --no-cache curl jq ca-certificates

   stages:
     - prepare
     - collect
     - aggregate
     - publish
   ```

此配置：

- 使用 Alpine Linux，因为它占用空间小且作业启动快
- 支持群组部署令牌进行身份验证
- 安装 `curl` 用于 API 请求、`jq` 用于 JSON 处理，以及 `ca-certificates` 以确保安全的 HTTPS 连接
- 将所有输出存储在 `sbom-output` 目录中
- 生成 CycloneDX JSON 格式的 SBOM

<a id="configure-the-prepare-stage"></a>

### 配置 `prepare` 阶段

`prepare` 阶段会设置 Python 环境并安装所需的依赖项。

在您的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
# Set up Python virtual environment and install required packages
prepare_environment:
  stage: prepare
  script: |
    mkdir -p ${SBOM_OUTPUT_DIR}
    apk add --no-cache python3 py3-pip py3-virtualenv
    python3 -m venv venv
    . venv/bin/activate
    pip3 install cyclonedx-bom
  artifacts:
    paths:
      - ${SBOM_OUTPUT_DIR}/
      - venv/
    expire_in: 1 week
```

此阶段：

- 创建 Python 虚拟环境以实现隔离
- 安装 CycloneDX 库以生成 SBOM
- 创建用于存放产物的输出目录
- 为后续阶段保留虚拟环境
- 将产物过期时间设置为一周，以便管理存储空间

<a id="configure-the-collect-stage"></a>

### 配置 `collect` 阶段

`collect` 阶段会从群组的软件包仓库中收集软件包信息。

在您的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
# Collect package information and versions from GitLab registry
collect_group_packages:
  stage: collect
  script: |
    mkdir -p "${SBOM_OUTPUT_DIR}"
    echo "[]" > "${SBOM_OUTPUT_DIR}/packages.json"

    # Resolve the auth header at runtime: use the group deploy token if set,
    # otherwise fall back to the CI job token.
    if [ -n "${GROUP_DEPLOY_TOKEN:-}" ]; then
      AUTH="Deploy-Token: ${GROUP_DEPLOY_TOKEN}"
    else
      AUTH="JOB-TOKEN: ${CI_JOB_TOKEN}"
    fi

    GROUP_PATH_ENCODED=$(echo "${GROUP_PATH}" | sed 's|/|%2F|g')
    PACKAGES_URL="${CI_API_V4_URL}/groups/${GROUP_PATH_ENCODED}/packages"

    # Optional exclusion list - you can add package types you want to exclude
    # EXCLUDE_TYPES="terraform npm"

    page=1
    while true; do
      # Fetch all packages without specifying type, with pagination
      http_status=$(curl --silent \
                      --output /tmp/api_response.json \
                      --write-out "%{http_code}" \
                      --header "$AUTH" \
                      "${PACKAGES_URL}?per_page=100&page=${page}")
      response=$(cat /tmp/api_response.json)

      if [ "$http_status" -lt 200 ] || [ "$http_status" -ge 300 ]; then
        echo "ERROR: HTTP ${http_status}"; echo "$response" | jq . 2>/dev/null || echo "$response"; exit 1
      fi

      response_type=$(echo "$response" | jq -r 'type' 2>/dev/null || echo "invalid")
      if [ "$response_type" != "array" ]; then
        echo "ERROR: Expected array, got ${response_type}"; echo "$response" | jq . 2>/dev/null || echo "$response"; exit 1
      fi

      count=$(echo "$response" | jq '. | length')
      [ "$count" -eq 0 ] && break

      # Filter packages if EXCLUDE_TYPES is set, using exact type matching
      if [ -n "${EXCLUDE_TYPES:-}" ]; then
        response=$(echo "$response" | jq --argjson types \
          "$(echo "${EXCLUDE_TYPES}" | tr ' ' '\n' | jq -R . | jq -s .)" \
          '[.[] | select(.package_type as $t | $types | any(. == $t) | not)]')
        count=$(echo "$response" | jq '. | length')
      fi

      # Merge this page of results with existing data
      jq -s '.[0] + .[1]' "${SBOM_OUTPUT_DIR}/packages.json" <(echo "$response") > "${SBOM_OUTPUT_DIR}/packages.tmp.json"
      mv "${SBOM_OUTPUT_DIR}/packages.tmp.json" "${SBOM_OUTPUT_DIR}/packages.json"

      # Move to next page if we got a full page of results
      [ "$count" -lt 100 ] && break
      page=$((page + 1))
    done
  artifacts:
    paths:
      - ${SBOM_OUTPUT_DIR}/
    expire_in: 1 week
  dependencies:
    - prepare_environment
```

此阶段：

- 在运行时解析身份验证请求头：如果可用则使用群组部署令牌，否则使用 CI/CD 作业令牌
- 通过一次 API 调用一次性获取所有软件包类型（而不是按类型分别调用）
- 支持可选的排除列表，通过精确匹配过滤掉软件包类型
- 实现分页以处理包含大量软件包的群组（每页 100 个）
- 对群组路径进行 URL 编码，以正确处理子群组
- 检查 HTTP 状态码和响应类型，并在出错时停止作业

<a id="configure-the-aggregate-stage"></a>

### 配置 `aggregate` 阶段

`aggregate` 阶段会处理收集到的数据并生成 SBOM。

在您的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
# Generate SBOM by aggregating package data
aggregate_sboms:
  stage: aggregate
  before_script:
    - apk add --no-cache python3 py3-virtualenv
    - . venv/bin/activate
  script: |
    cat > process_sbom.py << 'EOL'
    import json
    import os
    from datetime import datetime
    from urllib.parse import quote

    # Map GitLab package types to valid PURL types. Defaults to "generic".
    PURL_TYPE_MAP = {
        "pypi": "pypi", "npm": "npm", "maven": "maven", "nuget": "nuget",
        "composer": "composer", "conan": "conan", "conda": "conda",
        "golang": "golang", "helm": "helm", "rubygems": "gem",
        "generic": "generic", "debian": "deb", "rpm": "rpm", "terraform": "terraform",
    }

    def make_purl(package_type, name, version):
        """Build a spec-compliant PURL with percent-encoded name and version."""
        purl_type = PURL_TYPE_MAP.get(package_type, "generic")
        # Maven names use a "/" namespace separator that the PURL spec requires,
        # so keep it unencoded for that type.
        safe_name = quote(name, safe='/') if purl_type == "maven" else quote(name, safe='')
        safe_version = quote(version, safe='')
        return f"pkg:{purl_type}/{safe_name}@{safe_version}"

    def analyze_version_history(packages_file):
        """Process version information by aggregating packages with same name and type"""
        version_history = {}
        package_versions = {}  # Dict to group packages by name and type

        try:
            with open(packages_file, 'r') as f:
                packages = json.load(f)
                if not isinstance(packages, list):
                    return version_history

                # First, group packages by name and type
                for package in packages:
                    key = f"{package.get('name')}:{package.get('package_type')}"
                    if key not in package_versions:
                        package_versions[key] = []

                    package_versions[key].append({
                        'id': package.get('id'),
                        'version': package.get('version', 'unknown'),
                        'created_at': package.get('created_at')
                    })

                # Then process each group to create version history
                for package_key, versions in package_versions.items():
                    # Sort versions by creation date, newest first
                    versions.sort(key=lambda x: x.get('created_at', ''), reverse=True)

                    # Use the first package's ID as the key (newest version)
                    if versions:
                        package_id = str(versions[0]['id'])
                        version_history[package_id] = {
                            'versions': [v['version'] for v in versions],
                            'latest_version': versions[0]['version'] if versions else None,
                            'version_count': len(versions),
                            'first_published': min((v.get('created_at') for v in versions if v.get('created_at')), default=None),
                            'last_updated': max((v.get('created_at') for v in versions if v.get('created_at')), default=None)
                        }
        except Exception as e:
            print(f"Error processing version history: {e}")
        return version_history

    def merge_package_data(package_file):
        """Combine package data and generate component list"""
        merged_components = {}
        package_stats = {
            'total_packages': 0,
            'package_types': {}
        }

        try:
            with open(package_file, 'r') as f:
                packages = json.load(f)
                if not isinstance(packages, list):
                    return [], package_stats

                for package in packages:
                    package_stats['total_packages'] += 1
                    pkg_type = package.get('package_type', 'unknown')
                    package_stats['package_types'][pkg_type] = package_stats['package_types'].get(pkg_type, 0) + 1

                    version = package.get('version', 'unknown')
                    component = {
                        'type': 'library',
                        'name': package['name'],
                        'version': version,
                        'purl': make_purl(pkg_type, package['name'], version),
                        'package_type': pkg_type,
                        'properties': [{
                            'name': 'registry_url',
                            'value': package.get('_links', {}).get('web_path', '')
                        }]
                    }

                    key = f"{component['name']}:{component['version']}"
                    if key not in merged_components:
                        merged_components[key] = component
        except Exception as e:
            print(f"Error merging package data: {e}")
            return [], package_stats

        return list(merged_components.values()), package_stats

    # Main processing
    version_history = analyze_version_history(f"{os.environ['SBOM_OUTPUT_DIR']}/packages.json")
    components, stats = merge_package_data(f"{os.environ['SBOM_OUTPUT_DIR']}/packages.json")
    stats['version_history'] = version_history

    # Create final SBOM document
    sbom = {
        "bomFormat": os.environ['SBOM_FORMAT'],
        "specVersion": "1.4",
        "version": 1,
        "metadata": {
            "timestamp": datetime.utcnow().isoformat(),
            "tools": [{
                "vendor": "GitLab",
                "name": "Package Registry SBOM Generator",
                "version": "1.0.0"
            }],
            "properties": [{
                "name": "package_stats",
                "value": json.dumps(stats)
            }]
        },
        "components": components
    }

    # Write results to files
    with open(f"{os.environ['SBOM_OUTPUT_DIR']}/merged_sbom.{os.environ['OUTPUT_TYPE']}", 'w') as f:
        json.dump(sbom, f, indent=2)

    with open(f"{os.environ['SBOM_OUTPUT_DIR']}/package_stats.json", 'w') as f:
        json.dump(stats, f, indent=2)
    EOL

    python3 process_sbom.py
  artifacts:
    paths:
      - ${SBOM_OUTPUT_DIR}/
    expire_in: 1 week
  dependencies:
    - prepare_environment
    - collect_group_packages
```

此阶段：

- 使用优化的版本历史分析，直接处理 `packages.json` 文件
- 按名称和类型对软件包进行分组，以识别同一软件包的不同版本
- 创建符合 CycloneDX 规范的 JSON 格式 SBOM
- 计算软件包统计信息，包括：
  - 按类型统计的软件包总数
  - 每个软件包的版本历史
  - 首次发布日期和最后更新日期
- 复用 `prepare` 阶段生成的虚拟环境产物，而不是创建新的虚拟环境
- 为每个组件生成符合规范的软件包 URL（`purl`），将软件包类型映射到有效的 PURL 类型，并对名称和版本进行百分号编码
- 通过适当的异常处理，妥善处理缺失或无效的数据
- 同时创建 SBOM 和单独的统计文件

<a id="configure-the-publish-stage"></a>

### 配置 `publish` 阶段

`publish` 阶段会将生成的 SBOM 和统计文件上传到极狐GitLab。

在您的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
# Publish SBOM files to GitLab package registry
publish_sbom:
  stage: publish
  script: |
    # Resolve the auth header at runtime, as in the collect stage.
    if [ -n "${GROUP_DEPLOY_TOKEN:-}" ]; then
      AUTH="Deploy-Token: ${GROUP_DEPLOY_TOKEN}"
    else
      AUTH="JOB-TOKEN: ${CI_JOB_TOKEN}"
    fi

    # Upload generated files
    curl --header "$AUTH" \
         --upload-file "${SBOM_OUTPUT_DIR}/merged_sbom.${OUTPUT_TYPE}" \
         "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/sbom/${CI_COMMIT_SHA}/merged_sbom.${OUTPUT_TYPE}"

    curl --header "$AUTH" \
         --upload-file "${SBOM_OUTPUT_DIR}/package_stats.json" \
         "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/sbom/${CI_COMMIT_SHA}/package_stats.json"
  dependencies:
    - aggregate_sboms
```

此阶段：

- 将 SBOM 和统计文件发布到项目的软件包仓库
- 使用通用软件包类型进行存储
- 使用提交 SHA 作为软件包版本，以便追溯

SBOM 文件已在 `metadata.timestamp`中记录生成时间戳，流水线会将软件包统计信息保存在 `package_stats.json`中。

<a id="access-the-generated-files"></a>

## 访问生成的文件

流水线完成后，会生成以下文件：

- `merged_sbom.json`：CycloneDX 格式的完整 SBOM
- `package_stats.json`：有关软件包的统计信息

要访问生成的文件：

1. 在您的项目中，选择**部署** > **软件包仓库**。
1. 找到名为 `sbom`的软件包。
1. 下载 SBOM 和统计文件。

<a id="using-the-sbom-file"></a>

### 使用 SBOM 文件

SBOM 文件遵循 [CycloneDX 1.4 JSON 规范](https://cyclonedx.org/docs/1.4/json/)，提供有关群组软件包仓库中已发布软件包、软件包版本和产物的详细信息。

您还可以将 SBOM 文件用于合规和审计目的，例如：

- 生成已发布软件包的报告
- 记录群组软件包仓库的内容
- 跟踪一段时间内的发布活动

处理 CycloneDX 文件时，可以考虑使用以下工具：

- [OWASP Dependency-Track](https://dependencytrack.org/)
- [CycloneDX CLI](https://github.com/CycloneDX/cyclonedx-cli)
- [OWASP CycloneDX Sunshine](https://cyclonedx.github.io/Sunshine/)
- [SBOM 分析工具](https://cyclonedx.org/tool-center/)

<a id="using-the-statistics-file"></a>

### 使用统计文件

统计文件提供软件包仓库分析和活动跟踪。

例如，要分析您的软件包仓库，您可以：

- 查看按类型统计的已发布软件包总数。
- 查看每个软件包的版本数量。
- 跟踪首次发布日期和最后更新日期。

要跟踪软件包仓库活动，您可以：

- 监控软件包发布模式。
- 识别更新最频繁的软件包。
- 跟踪软件包仓库随时间的增长情况。

您可以使用 `jq` 等 CLI 工具处理统计文件，以可读的 JSON 格式生成分析或活动信息。

以下代码块列出了若干 `jq` 命令示例，您可以针对统计文件运行这些命令，用于常规分析或报告目的：

```shell
# Get total package count in registry
jq '.total_packages' package_stats.json

# List package types and their counts
jq '.package_types' package_stats.json

# Find packages with most versions published
jq '.version_history | to_entries | sort_by(.value.version_count) | reverse | .[0:5]' package_stats.json
```

<a id="pipeline-scheduling"></a>

## 流水线计划

如果您经常更新软件包仓库，应相应地更新 SBOM。您可以配置流水线计划，根据您的发布活动生成更新的 SBOM。

请考虑以下建议：

- 每日更新：如果您频繁发布软件包或需要最新的报告，建议采用
- 每周更新：适合大多数软件包发布活动适中的团队
- 每月更新：对于软件包更新不频繁的群组已经足够

要调度流水线：

1. 在您的项目中，转到**构建** > **流水线计划**。
1. 选择**创建新的流水线计划**并填写表单：
   - 从 **Cron 时区**下拉列表中，选择一个时区。
   - 选择一个**间隔模式**，或使用 [cron 语法](../../../ci/pipelines/schedules.md)添加**自定义**模式。
   - 为流水线选择分支或标签。
   - 在**变量**下，为调度输入任意数量的 CI/CD 变量。
1. 选择**创建流水线计划**。

<a id="troubleshooting"></a>

## 故障排除

在完成本教程时，您可能会遇到以下问题。

<a id="authentication-errors"></a>

### 身份验证错误

如果您遇到身份验证错误：

- 检查您的群组部署令牌权限。
- 确保该令牌同时具有 `read_package_registry` 和 `write_package_registry` 范围。
- 验证该令牌尚未过期。

<a id="missing-package-types"></a>

### 缺少软件包类型

如果您缺少软件包类型：

- 确保您的[部署令牌有权访问](../../project/deploy_tokens/_index.md#pull-packages-from-a-package-registry)所有软件包类型。
- 检查群组设置中是否启用了该软件包类型。

<a id="memory-issues-in-the-aggregate-stage"></a>

### `aggregate` 阶段中的内存问题

如果您遇到内存问题：

- 使用内存更大的 runner。
- 通过过滤软件包类型，一次处理更少的软件包。

<a id="resource-recommendations"></a>

### 资源建议

为获得最佳性能：

- 使用至少具有 2 GB 内存的 runner。
- 每 1,000 个软件包预留 5-10 分钟。
- 对于包含大量软件包的群组，增加作业超时时间。

<a id="getting-help"></a>

### 获取帮助

如果您遇到其他问题：

- 检查作业日志以获取具体的错误消息。
- 直接使用 `curl` 命令验证 API 访问。
- 先使用较少的软件包类型子集进行测试。
