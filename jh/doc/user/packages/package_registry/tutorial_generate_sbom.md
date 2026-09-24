---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用极狐GitLab 软件包仓库生成软件物料清单'
---

本教程将向你展示如何使用 CI/CD 流水线生成 CycloneDX 格式的软件物料清单（SBOM）。你将构建的流水线会收集群组中多个项目的软件包，为你提供相关项目中依赖项的全面视图。

为完成本教程，你将创建一个 Python 虚拟环境，但你也可以将相同的方法应用于其他支持的软件包类型。

## 什么是软件物料清单？

SBOM 是一种机器可读的清单，列出了构成软件产品的所有软件组件。SBOM 可能包括：

- 直接和间接依赖项
- 开源组件及其许可证
- 软件包版本及其来源

有意向使用某个软件产品的组织在采用该产品前，可能会要求提供 SBOM 以确定其安全程度。

如果你熟悉极狐GitLab 软件包仓库，你或许会想知道 SBOM 与[依赖列表](../../application_security/dependency_list/_index.md)之间有什么区别。下表重点说明了它们的主要差异：

| 差异 | 依赖列表 | SBOM |
|------|----------|------|
| 范围 | 显示单个项目或群组的依赖项。 | 创建群组中所有已发布软件包的清单。 |
| 方向 | 跟踪你的项目依赖于什么（传入依赖项）。 | 跟踪你的群组发布了什么（传出软件包）。 |
| 覆盖范围 | 基于软件包清单文件，如 `package.json` 或 `pom.xml`。 | 覆盖软件包仓库中实际已发布的产物。 |

## 什么是 CycloneDX？

CycloneDX 是一种用于创建 SBOM 的轻量级、标准化格式。CycloneDX 提供了定义良好的模式，可帮助组织：

- 记录软件组件及其关系。
- 在整个软件供应链中追踪漏洞。
- 验证开源依赖项的许可证合规性。
- 建立一致且机器可读的 SBOM 格式。

CycloneDX 支持多种输出格式，包括 JSON、XML 和 Protocol Buffers，使其能够灵活地满足不同的集成需求。该规范设计得全面且高效，涵盖了从基础组件标识到有关软件来源详细元数据的方方面面。

## 准备工作

要完成本教程，你需要：

- 一个拥有维护者或所有者角色的群组。
- 访问极狐GitLab CI/CD。
- 如果你使用的是私有化部署实例，则需要一个已配置的 [极狐GitLab Runner](../../../ci/runners/_index.md#runner-categories)。如果你使用的是 JihuLab.com，则可以跳过此要求。
- 可选。一个[群组部署令牌](../../project/deploy_tokens/_index.md) 用于对软件包仓库的请求进行身份认证。

## 步骤

本教程包含两组步骤来完成：

- 配置一个用于生成 CycloneDX 格式 SBOM 的 CI/CD 流水线
- 访问并处理生成的 SBOM 和软件包统计文件

以下是你要做的事情的概述：

1. [添加基础流水线配置](#add-the-base-pipeline-configuration)。
1. [配置 `prepare` 阶段](#configure-the-prepare-stage)。
1. [配置 `collect` 阶段](#configure-the-collect-stage)。
1. [配置 `aggregate` 阶段](#configure-the-aggregate-stage)。
1. [配置 `publish` 阶段](#configure-the-publish-stage)。
1. [访问生成的 SBOM 和统计文件](#access-the-generated-files)。

> [!note]
> 在实施此解决方案之前，请注意：
>
> - 软件包依赖关系不会被解析（仅列出直接软件包）。
> - 包含了软件包版本，但不会分析漏洞。

<a id="add-the-base-pipeline-configuration"></a>

### 添加基础流水线配置

首先，设置基础镜像，该镜像定义了整个流水线中使用的变量和阶段。

在接下来的小节中，你将通过为每个阶段添加配置来构建流水线。

在你的项目中：

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
     AUTH_HEADER: "${GROUP_DEPLOY_TOKEN:+Deploy-Token: $GROUP_DEPLOY_TOKEN}"

   before_script:
     - apk add --no-cache curl jq ca-certificates

   stages:
     - prepare
     - collect
     - aggregate
     - publish
   ```

此配置：

- 使用 Alpine Linux，因为它占用空间小且作业启动速度快
- 支持使用群组部署令牌进行身份认证
- 安装 `curl` 用于 API 请求，`jq` 用于 JSON 处理，以及 `ca-certificates` 以确保安全的 HTTPS 连接
- 将所有输出存储在 `sbom-output` 目录中
- 生成 CycloneDX JSON 格式的 SBOM

<a id="configure-the-prepare-stage"></a>

### 配置 `prepare` 阶段

`prepare` 阶段用于设置 Python 环境并安装所需的依赖项。

在你的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
# Set up Python virtual environment and install required packages
prepare_environment:
  stage: prepare
  script: |
    mkdir -p ${SBOM_OUTPUT_DIR}
    apk add --no-cache python3 py3-pip py3-virtualenv
    python3 -m venv venv
    source venv/bin/activate
    pip3 install cyclonedx-bom
  artifacts:
    paths:
      - ${SBOM_OUTPUT_DIR}/
      - venv/
    expire_in: 1 week
```

此阶段：

- 创建一个 Python 虚拟环境以实现隔离
- 安装用于生成 SBOM 的 CycloneDX 库
- 为产物创建输出目录
- 保留虚拟环境以供后续阶段使用
- 将产物过期时间设置为一周，以管理存储空间

<a id="configure-the-collect-stage"></a>

### 配置 `collect` 阶段

`collect` 阶段从群组的软件包仓库收集软件包信息。

在你的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
# Collect package information and versions from GitLab registry
collect_group_packages:
  stage: collect
  script: |
    echo "[]" > "${SBOM_OUTPUT_DIR}/packages.json"

    GROUP_PATH_ENCODED=$(echo "${GROUP_PATH}" | sed 's|/|%2F|g')
    PACKAGES_URL="${CI_API_V4_URL}/groups/${GROUP_PATH_ENCODED}/packages"

    # Optional exclusion list - you can add package types you want to exclude
    # EXCLUDE_TYPES="terraform"

    page=1
    while true; do
      # Fetch all packages without specifying type, with pagination
      response=$(curl --silent --header "${AUTH_HEADER:-"JOB-TOKEN: $CI_JOB_TOKEN"}" \
                    "${PACKAGES_URL}?per_page=100&page=${page}")

      if ! echo "$response" | jq 'type == "array"' > /dev/null 2>&1; then
        echo "Error in API response for page $page"
        break
      fi

      count=$(echo "$response" | jq '. | length')
      if [ "$count" -eq 0 ]; then
        break
      fi

      # Filter packages if EXCLUDE_TYPES is set
      if [ -n "${EXCLUDE_TYPES:-}" ]; then
        filtered_response=$(echo "$response" | jq --arg types "$EXCLUDE_TYPES" '[.[] | select(.package_type | inside($types | split(" ")) | not)]')
        response="$filtered_response"
        count=$(echo "$response" | jq '. | length')
      fi

      # Merge this page of results with existing data
      jq -s '.[0] + .[1]' "${SBOM_OUTPUT_DIR}/packages.json" <(echo "$response") > "${SBOM_OUTPUT_DIR}/packages.tmp.json"
      mv "${SBOM_OUTPUT_DIR}/packages.tmp.json" "${SBOM_OUTPUT_DIR}/packages.json"

      # Move to next page if we got a full page of results
      if [ "$count" -lt 100 ]; then
        break
      fi

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

- 进行一次 API 调用来一次性获取所有软件包类型（而不是按类型分别调用）
- 支持一个可选排除列表，用于过滤掉不需要的软件包类型
- 实现了分页来处理拥有大量软件包（每页 100 个）的群组
- 对群组路径进行 URL 编码，以正确处理子群组
- 通过跳过无效响应来优雅地处理 API 错误

<a id="configure-the-aggregate-stage"></a>

### 配置 `aggregate` 阶段

`aggregate` 阶段处理收集到的数据并生成 SBOM。

在你的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
# Generate SBOM by aggregating package data
aggregate_sboms:
  stage: aggregate
  before_script:
    - apk add --no-cache python3 py3-pip py3-virtualenv
    - python3 -m venv venv
    - source venv/bin/activate
    - pip3 install --no-cache-dir cyclonedx-bom
  script: |
    cat > process_sbom.py << 'EOL'
    import json
    import os
    from datetime import datetime

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

                    component = {
                        'type': 'library',
                        'name': package['name'],
                        'version': package.get('version', 'unknown'),
                        'purl': f"pkg:gitlab/{package['name']}@{package.get('version', 'unknown')}",
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
    - collect_group_packages
```

此阶段：

- 使用优化过的版本历史分析，直接作用于 `packages.json` 文件
- 按名称和类型对软件包进行分组，以识别同一软件包的不同版本
- 创建符合 CycloneDX 规范的 JSON 格式 SBOM
- 计算软件包统计信息，包括：
  - 按类型统计的软件包总数
  - 每个软件包的版本历史
  - 首发日期和最后更新日期
- 为每个组件生成软件包 URL（`purl`）
- 通过适当的异常处理，优雅地处理缺失或无效的数据
- 创建 SBOM 文件和一个单独的统计文件

<a id="configure-the-publish-stage"></a>

### 配置 `publish` 阶段

`publish` 阶段将生成的 SBOM 和统计文件上传到极狐GitLab。

在你的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
# Publish SBOM files to GitLab package registry
publish_sbom:
  stage: publish
  script: |
    STATS=$(cat "${SBOM_OUTPUT_DIR}/package_stats.json")

    # Upload generated files
    curl --header "${AUTH_HEADER:-"JOB-TOKEN: $CI_JOB_TOKEN"}" \
         --upload-file "${SBOM_OUTPUT_DIR}/merged_sbom.${OUTPUT_TYPE}" \
         "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/sbom/${CI_COMMIT_SHA}/merged_sbom.${OUTPUT_TYPE}"

    curl --header "${AUTH_HEADER:-"JOB-TOKEN: $CI_JOB_TOKEN"}" \
         --upload-file "${SBOM_OUTPUT_DIR}/package_stats.json" \
         "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/sbom/${CI_COMMIT_SHA}/package_stats.json"

    # Add package description
    curl --header "${AUTH_HEADER:-"JOB-TOKEN: $CI_JOB_TOKEN"}" \
         --header "Content-Type: application/json" \
         --request PUT \
         --data @- \
         "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/sbom/${CI_COMMIT_SHA}" << EOF
    {
      "description": "Group Package Registry SBOM generated on $(date -u)\nStats: ${STATS}"
    }
    EOF
  dependencies:
    - aggregate_sboms
```

此阶段：

- 将 SBOM 和统计文件发布到你的项目软件包仓库
- 使用通用软件包类型进行存储
- 使用提交 SHA 作为软件包版本，以实现可追溯性
- 在软件包描述中添加生成时间戳和统计信息

<a id="access-the-generated-files"></a>

### 访问生成的文件

当流水线完成后，会生成以下文件：

- `merged_sbom.json`：CycloneDX 格式的完整 SBOM
- `package_stats.json`：有关软件包的统计信息

要访问生成的文件：

1. 在你的项目中，选择 **部署** > **软件包仓库**。
1. 找到名为 `sbom` 的软件包。
1. 下载 SBOM 和统计文件。

<a id="using-the-sbom-file"></a>

#### 使用 SBOM 文件

SBOM 文件遵循 [CycloneDX 1.4 JSON 规范](https://cyclonedx.org/docs/1.4/json/)，并提供有关群组软件包仓库中已发布软件包、软件包版本和产物的详细信息。

你还可以将 SBOM 文件用于合规和审计目的，例如：

- 生成已发布软件包的报告
- 记录群组软件包仓库的内容
- 跟踪一段时间内的发布活动

在处理 CycloneDX 文件时，可考虑使用以下工具：

- [OWASP Dependency-Track](https://dependencytrack.org/)
- [CycloneDX CLI](https://github.com/CycloneDX/cyclonedx-cli)
- [OWASP CycloneDX Sunshine](https://cyclonedx.github.io/Sunshine/)
- [SBOM 分析工具](https://cyclonedx.org/tool-center/)

<a id="using-the-statistics-file"></a>

#### 使用统计文件

统计文件提供软件包仓库的分析和活动跟踪。

例如，要分析你的软件包仓库，你可以：

- 查看按类型统计的已发布软件包总数。
- 查看每个软件包的版本数量。
- 跟踪首发日期和最后更新日期。

要跟踪软件包仓库活动，你可以：

- 监控软件包发布模式。
- 识别更新最频繁的软件包。
- 跟踪软件包仓库随时间推移的增长情况。

你可以将 `jq` 这样的 CLI 工具与统计文件结合使用，以可读的 JSON 格式生成分析结果或活动信息。

以下代码块列出了几个 `jq` 命令的示例，你可以对统计文件运行这些命令以进行一般分析或报告：

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

如果你频繁更新软件包仓库，则应相应地更新你的 SBOM。你可以配置流水线计划，以根据你的发布活动生成更新的 SBOM。

考虑以下建议：

- 每日更新：如果你频繁发布软件包或需要最新的报告，建议每日更新。
- 每周更新：适用于大多数软件包发布活动适中的团队。
- 每月更新：对于软件包更新不频繁的群组来说足够。

若要安排流水线：

1. 在你的项目中，进入 **构建** > **流水线计划**。
1. 选择 **创建新流水线计划** 并填写表单：
   - 从 **Cron 时区** 下拉列表中选择一个时区。
   - 选择一个 **间隔模式**，或使用 [cron 语法](../../../ci/pipelines/schedules.md) 添加一个 **自定义** 模式。
   - 选择要运行流水线的分支或标签。
   - 在 **变量** 下，向计划中添加任意数量的 CI/CD 变量。
1. 选择 **创建流水线计划**。

<a id="troubleshooting"></a>

## 故障排除

在完成本教程时，你可能会遇到以下问题。

<a id="authentication-errors"></a>

### 认证错误

如果遇到认证错误：

- 检查你的群组部署令牌权限。
- 确保该令牌同时具有 `read_package_registry` 和 `write_package_registry` 范围。
- 验证令牌是否过期。

<a id="missing-package-types"></a>

### 缺少软件包类型

如果缺少软件包类型：

- 确保你的[部署令牌有权访问](../../project/deploy_tokens/_index.md#pull-packages-from-a-package-registry)所有软件包类型。
- 检查该软件包类型是否在你的群组设置中已启用。

<a id="memory-issues-in-the-aggregate-stage"></a>

### `aggregate` 阶段的内存问题

如果遇到内存问题：

- 使用具有更多内存的 Runner。
- 通过过滤软件包类型来一次处理更少的软件包。

<a id="resource-recommendations"></a>

### 资源建议

为了获得最佳性能：

- 使用至少具有 2 GB RAM 的 Runner。
- 每处理 1000 个软件包，预留 5-10 分钟。
- 对于拥有大量软件包的群组，增加作业超时时间。

<a id="getting-help"></a>

### 获取帮助

如果遇到其他问题：

- 检查作业日志以获取具体的错误消息。
- 直接使用 `curl` 命令验证 API 访问。
- 首先使用一小部分软件包类型进行测试。