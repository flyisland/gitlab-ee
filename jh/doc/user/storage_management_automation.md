---
stage: Fulfillment
group: Utilization
info: This page is maintained by Developer Relations, author @dnsmichi, see <https://handbook.gitlab.com/handbook/marketing/developer-relations/developer-advocacy/content/#maintained-documentation>
title: 自动化存储管理
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本页面介绍如何使用极狐GitLab REST API 自动化存储分析与清理，以管理您的存储用量。

您也可以通过提升[流水线效率](../ci/pipelines/pipeline_efficiency.md)来管理存储用量。

如需更多 API 自动化帮助，您也可以访问[极狐GitLab 社区论坛和 Discord](https://about.gitlab.com/community/)。

> [!warning]
> 本页面中的脚本示例仅用于演示，不应直接用于生产环境。您可以参考这些示例，设计并测试自己的存储自动化脚本。

## API 要求

要自动化存储管理，您的 JihuLab.com 或私有化部署实例必须能够访问[极狐GitLab REST API](../api/api_resources.md)。

### API 认证范围

使用以下范围进行[认证](../api/rest/authentication.md)：

- 存储分析：
  - 具有 `read_api` 范围的读取 API 访问权限。
  - 在所有项目上具有开发者、维护者或所有者角色。
- 存储清理：
  - 具有 `api` 范围的完整 API 访问权限。
  - 在所有项目上具有维护者或所有者角色。

您可以使用命令行工具或编程语言与 REST API 交互。

### 命令行工具

要发送 API 请求，请安装以下任一工具：

- 使用您偏好的包管理器安装 curl。
- [极狐GitLab CLI](https://gitlab.cn/docs/cli/) 并使用 `glab api` 子命令。

要格式化 JSON 响应，请安装 `jq`。更多信息，请参阅[高效 DevOps 工作流技巧：使用 jq 格式化 JSON 及 CI/CD 自动检查](https://about.gitlab.com/blog/2021/04/21/devops-workflows-json-format-jq-ci-cd-lint/)。

使用这些工具与 REST API 交互：

{{< tabs >}}

{{< tab title="curl" >}}

```shell
export GITLAB_TOKEN=xxx

curl --silent --header "Authorization: Bearer $GITLAB_TOKEN" "https://gitlab.com/api/v4/user" | jq
```

{{< /tab >}}

{{< tab title="GitLab CLI" >}}

```shell
glab auth login

glab api groups/YOURGROUPNAME/projects
```

{{< /tab >}}

{{< /tabs >}}

#### 使用极狐GitLab CLI

某些 API 端点需要[分页](../api/rest/_index.md#pagination)并获取后续页面才能检索所有结果。极狐GitLab CLI 提供了 `--paginate` 标志。

需要以 JSON 数据格式提交 POST 正文的请求，可以写成 `key=value` 对，传递给 `--raw-field` 参数。

更多信息，请参阅[极狐GitLab CLI 端点文档](https://gitlab.cn/docs/cli/#commands)。

### API 客户端库

本页面描述的存储管理和清理自动化方法使用了：

- [`python-gitlab`](https://python-gitlab.readthedocs.io/en/stable/) 库，它提供了功能丰富的编程接口。
- [极狐GitLab API with Python](https://gitlab.com/gitlab-da/use-cases/gitlab-api/gitlab-api-python/) 项目中的 `get_all_projects_top_level_namespace_storage_analysis_cleanup_example.py` 脚本。

有关 `python-gitlab` 库的更多用例，请参阅[高效 DevSecOps 工作流：动手实践 `python-gitlab` API 自动化](https://about.gitlab.com/blog/efficient-devsecops-workflows-hands-on-python-gitlab-api-automation/)。

有关其他 API 客户端库的更多信息，请参阅[第三方客户端](../api/rest/third_party_clients.md)。

> [!note]
> 使用 CodeRider 代码建议更高效地编写代码。

## 存储分析

### 识别存储类型

[项目 API 端点](../api/projects.md#list-all-projects) 提供了极狐GitLab 实例中项目的统计信息。要使用项目 API 端点，请将 `statistics` 键设置为布尔值 `true`。
这些数据提供了项目在以下存储类型上的存储消耗洞察：

- `storage_size`：总存储
- `lfs_objects_size`：LFS 对象存储
- `job_artifacts_size`：任务产物存储
- `packages_size`：软件包存储
- `repository_size`：Git 仓库存储
- `snippets_size`：代码片段存储
- `uploads_size`：上传文件存储
- `wiki_size`：Wiki 存储

要识别存储类型：

{{< tabs >}}

{{< tab title="curl" >}}

```shell
curl --silent --header "Authorization: Bearer $GITLAB_TOKEN" "https://gitlab.com/api/v4/projects/$GL_PROJECT_ID?statistics=true" | jq --compact-output '.id,.statistics' | jq
48349590
{
  "commit_count": 2,
  "storage_size": 90241770,
  "repository_size": 3521,
  "wiki_size": 0,
  "lfs_objects_size": 0,
  "job_artifacts_size": 90238249,
  "pipeline_artifacts_size": 0,
  "packages_size": 0,
  "snippets_size": 0,
  "uploads_size": 0
}
```

{{< /tab >}}

{{< tab title="GitLab CLI" >}}

```shell
export GL_PROJECT_ID=48349590
glab api --method GET projects/$GL_PROJECT_ID --field 'statistics=true' | jq --compact-output '.id,.statistics' | jq
48349590
{
  "commit_count": 2,
  "storage_size": 90241770,
  "repository_size": 3521,
  "wiki_size": 0,
  "lfs_objects_size": 0,
  "job_artifacts_size": 90238249,
  "pipeline_artifacts_size": 0,
  "packages_size": 0,
  "snippets_size": 0,
  "uploads_size": 0
}
```

{{< /tab >}}

{{< tab title="Python" >}}

```python
project_obj = gl.projects.get(project.id, statistics=True)

print("Project {n} statistics: {s}".format(n=project_obj.name_with_namespace, s=json.dump(project_obj.statistics, indent=4)))
```

{{< /tab >}}

{{< /tabs >}}

要将项目统计信息打印到终端，请导出 `GL_GROUP_ID` 环境变量并运行脚本：

```shell
export GL_TOKEN=xxx
export GL_GROUP_ID=56595735

pip3 install python-gitlab
python3 get_all_projects_top_level_namespace_storage_analysis_cleanup_example.py

Project Developer Evangelism and Technical Marketing at GitLab  / playground / Artifact generator group / Gen Job Artifacts 4 statistics: {
    "commit_count": 2,
    "storage_size": 90241770,
    "repository_size": 3521,
    "wiki_size": 0,
    "lfs_objects_size": 0,
    "job_artifacts_size": 90238249,
    "pipeline_artifacts_size": 0,
    "packages_size": 0,
    "snippets_size": 0,
    "uploads_size": 0
}
```

### 分析项目与群组中的存储

您可以自动化分析多个项目和群组。例如，您可以从顶级命名空间开始，递归分析所有子群组和项目。您也可以分析不同的存储类型。

以下是一个分析多个子群组和项目的算法示例：

1. 获取顶级命名空间 ID。您可以从[命名空间/群组概览](namespace/_index.md#types-of-namespaces)复制 ID 值。
1. 从顶级群组获取所有[子群组](../api/groups.md#list-subgroups)，并将 ID 保存到列表中。
1. 遍历所有群组，从[每个群组获取所有项目](../api/groups.md#list-projects)并将 ID 保存到列表中。
1. 确定要分析的存储类型，并从项目属性（如项目统计信息和任务产物）中收集信息。
1. 打印所有项目的概览，按群组分组，并显示其存储信息。

使用 `glab` 的 Shell 方式可能更适合较小规模的分析。对于较大规模的分析，应使用基于 API 客户端库的脚本。这种脚本可以提高可读性、数据存储、流程控制、可测试性和可重用性。

为确保脚本不触及 [API 速率限制](../security/rate_limits.md)，以下示例代码未针对并行 API 请求进行优化。

要实现此算法：

{{< tabs >}}

{{< tab title="GitLab CLI" >}}

```shell
export GROUP_NAME="gitlab-da"

# 返回子群组 ID
glab api groups/$GROUP_NAME/subgroups | jq --compact-output '.[]' | jq --compact-output '.id'
12034712
67218622
67162711
67640130
16058698
12034604

# 遍历所有子群组以获取子群组，直到结果集为空。示例群组：12034712
glab api groups/12034712/subgroups | jq --compact-output '.[]' | jq --compact-output '.id'
56595735
70677315
67218606
70812167

# 最低层级群组
glab api groups/56595735/subgroups | jq --compact-output '.[]' | jq --compact-output '.id'
# 空结果，返回并继续分析

# 从所有收集到的群组中获取项目。示例群组：56595735
glab api groups/56595735/projects | jq --compact-output '.[]' | jq --compact-output '.id'
48349590
48349263
38520467
38520405

# 从项目（ID 48349590）获取存储类型：`artifacts` 键中的任务产物
glab api projects/48349590/jobs | jq --compact-output '.[]' | jq --compact-output '.id, .artifacts'
4828297946
[{"file_type":"archive","size":52444993,"filename":"artifacts.zip","file_format":"zip"},{"file_type":"metadata","size":156,"filename":"metadata.gz","file_format":"gzip"},{"file_type":"trace","size":3140,"filename":"job.log","file_format":null}]
4828297945
[{"file_type":"archive","size":20978113,"filename":"artifacts.zip","file_format":"zip"},{"file_type":"metadata","size":157,"filename":"metadata.gz","file_format":"gzip"},{"file_type":"trace","size":3147,"filename":"job.log","file_format":null}]
4828297944
[{"file_type":"archive","size":10489153,"filename":"artifacts.zip","file_format":"zip"},{"file_type":"metadata","size":158,"filename":"metadata.gz","file_format":"gzip"},{"file_type":"trace","size":3146,"filename":"job.log","file_format":null}]
4828297943
[{"file_type":"archive","size":5244673,"filename":"artifacts.zip","file_format":"zip"},{"file_type":"metadata","size":157,"filename":"metadata.gz","file_format":"gzip"},{"file_type":"trace","size":3145,"filename":"job.log","file_format":null}]
4828297940
[{"file_type":"archive","size":1049089,"filename":"artifacts.zip","file_format":"zip"},{"file_type":"metadata","size":157,"filename":"metadata.gz","file_format":"gzip"},{"file_type":"trace","size":3140,"filename":"job.log","file_format":null}]
```

{{< /tab >}}

{{< tab title="Python" >}}

```python
#!/usr/bin/env python

import datetime
import gitlab
import os
import sys

GITLAB_SERVER = os.environ.get('GL_SERVER', 'https://gitlab.com')
GITLAB_TOKEN = os.environ.get('GL_TOKEN') # token 需要开发者权限
PROJECT_ID = os.environ.get('GL_PROJECT_ID') # 可选
GROUP_ID = os.environ.get('GL_GROUP_ID') # 可选

if __name__ == "__main__":
    if not GITLAB_TOKEN:
        print("🤔 请设置 GL_TOKEN 环境变量。")
        sys.exit(1)

    gl = gitlab.Gitlab(GITLAB_SERVER, private_token=GITLAB_TOKEN, pagination="keyset", order_by="id", per_page=100)

    # 收集所有项目，或优先从群组 ID 或项目 ID 获取项目
    projects = []

    # 直接使用项目 ID
    if PROJECT_ID:
        projects.append(gl.projects.get(PROJECT_ID))
    # 群组及其内部项目
    elif GROUP_ID:
        group = gl.groups.get(GROUP_ID)

        for project in group.projects.list(include_subgroups=True, get_all=True):
            manageable_project = gl.projects.get(project.id , lazy=True)
            projects.append(manageable_project)

    for project in projects:
        jobs = project.jobs.list(pagination="keyset", order_by="id", per_page=100, iterator=True)
        for job in jobs:
            print("DEBUG: ID {i}: {a}".format(i=job.id, a=job.attributes['artifacts']))
```

{{< /tab >}}

{{< /tabs >}}

脚本以 JSON 格式列表输出项目任务产物：

```json
[
    {
        "file_type": "archive",
        "size": 1049089,
        "filename": "artifacts.zip",
        "file_format": "zip"
    },
    {
        "file_type": "metadata",
        "size": 157,
        "filename": "metadata.gz",
        "file_format": "gzip"
    },
    {
        "file_type": "trace",
        "size": 3146,
        "filename": "job.log",
        "file_format": null
    }
]
```

## 管理 CI/CD 流水线存储

任务产物占用了大部分流水线存储，任务日志也可能产生数百 KB。您应先删除不必要的任务产物，然后在分析后清理任务日志。

> [!warning]
> 删除任务日志和产物是不可逆的破坏性操作。请谨慎使用。删除某些文件（包括报告产物、任务日志和元数据文件）会影响使用这些文件作为数据源的极狐GitLab 功能。

### 列出任务产物

要分析流水线存储，您可以使用[任务 API 端点](../api/jobs.md#list-all-jobs-for-a-project) 获取任务产物列表。该端点返回 `artifacts` 属性中的 `file_type` 键。
`file_type` 键指示产物类型：

- `archive` 用于生成的 zip 文件任务产物。
- `metadata` 用于 Gzip 文件中的额外元数据。
- `trace` 用于原始文件的 `job.log`。

任务产物提供了一种数据结构，可以将其作为缓存文件写入磁盘，用于测试实现。

基于获取所有项目的示例代码，您可以扩展 Python 脚本以进行更多分析。

以下示例显示了查询项目中任务产物的响应：

```json
[
    {
        "file_type": "archive",
        "size": 1049089,
        "filename": "artifacts.zip",
        "file_format": "zip"
    },
    {
        "file_type": "metadata",
        "size": 157,
        "filename": "metadata.gz",
        "file_format": "gzip"
    },
    {
        "file_type": "trace",
        "size": 3146,
        "filename": "job.log",
        "file_format": null
    }
]
```

根据脚本的实现方式，您可以：

- 收集所有任务产物并在脚本末尾打印汇总表。
- 立即打印信息。

在以下示例中，任务产物收集在 `ci_job_artifacts` 列表中。脚本遍历所有项目，并获取：

- 包含所有属性的 `project_obj` 对象变量。
- `job` 对象中的 `artifacts` 属性。

您可以使用[键集分页](https://python-gitlab.readthedocs.io/en/stable/api-usage.html#pagination) 遍历大型流水线和任务列表。

```python
   ci_job_artifacts = []

    for project in projects:
        project_obj = gl.projects.get(project.id)

        jobs = project.jobs.list(pagination="keyset", order_by="id", per_page=100, iterator=True)

        for job in jobs:
            artifacts = job.attributes['artifacts']
            #print("DEBUG: ID {i}: {a}".format(i=job.id, a=json.dumps(artifacts, indent=4)))
            if not artifacts:
                continue

            for a in artifacts:
                data = {
                    "project_id": project_obj.id,
                    "project_web_url": project_obj.name,
                    "project_path_with_namespace": project_obj.path_with_namespace,
                    "job_id": job.id,
                    "artifact_filename": a['filename'],
                    "artifact_file_type": a['file_type'],
                    "artifact_size": a['size']
                }

                ci_job_artifacts.append(data)

    print("\n数据收集完成。")

    if len(ci_job_artifacts) > 0:
        print("| 项目 | 任务 | 产物名称 | 产物类型 | 产物大小 |\n|---------|-----|---------------|---------------|---------------|") # 开始 Markdown 友好表格
        for artifact in ci_job_artifacts:
            print('| [{project_name}]({project_web_url}) | {job_name} | {artifact_name} | {artifact_type} | {artifact_size} |'.format(project_name=artifact['project_path_with_namespace'], project_web_url=artifact['project_web_url'], job_name=artifact['job_id'], artifact_name=artifact['artifact_filename'], artifact_type=artifact['artifact_file_type'], artifact_size=render_size_mb(artifact['artifact_size'])))
    else:
        print("未找到产物。")
```

脚本末尾，任务产物以 Markdown 格式表格打印。您可以将表格内容复制到议题评论或描述中，或填充到极狐GitLab 仓库的 Markdown 文件中。

```shell
$ python3 get_all_projects_top_level_namespace_storage_analysis_cleanup_example.py

| 项目 | 任务 | 产物名称 | 产物类型 | 产物大小 |
|---------|-----|---------------|---------------|---------------|
| [gitlab-da/playground/artifact-gen-group/gen-job-artifacts-4](Gen Job Artifacts 4) | 4828297946 | artifacts.zip | archive | 50.0154 |
| [gitlab-da/playground/artifact-gen-group/gen-job-artifacts-4](Gen Job Artifacts 4) | 4828297946 | metadata.gz | metadata | 0.0001 |
| [gitlab-da/playground/artifact-gen-group/gen-job-artifacts-4](Gen Job Artifacts 4) | 4828297946 | job.log | trace | 0.0030 |
| [gitlab-da/playground/artifact-gen-group/gen-job-artifacts-4](Gen Job Artifacts 4) | 4828297945 | artifacts.zip | archive | 20.0063 |
| [gitlab-da/playground/artifact-gen-group/gen-job-artifacts-4](Gen Job Artifacts 4) | 4828297945 | metadata.gz | metadata | 0.0001 |
| [gitlab-da/playground/artifact-gen-group/gen-job-artifacts-4](Gen Job Artifacts 4) | 4828297945 | job.log | trace | 0.0030 |
```

### 批量删除任务产物

您可以使用 Python 脚本筛选要批量删除的任务产物类型。

过滤 API 查询结果以比较：

- `created_at` 值以计算产物年龄。
- `size` 属性以确定产物是否达到大小阈值。

一个典型的请求：

- 删除超过指定天数的任务产物。
- 删除超过指定存储量的任务产物。例如，100 MB。

在以下示例中，脚本遍历任务属性并将其标记为待删除。当集合循环移除对象锁后，脚本将删除标记为待删除的任务产物。

```python
   for project in projects:
        project_obj = gl.projects.get(project.id)

        jobs = project.jobs.list(pagination="keyset", order_by="id", per_page=100, iterator=True)

        for job in jobs:
            artifacts = job.attributes['artifacts']
            if not artifacts:
                continue

            # 高级过滤：年龄和大小
            # 示例：90 天，10 MB 阈值（TODO：使其可配置）
            threshold_age = 90 * 24 * 60 * 60
            threshold_size = 10 * 1024 * 1024

            # 任务年龄，需要解析 API 格式：2023-08-08T22:41:08.270Z
            created_at = datetime.datetime.strptime(job.created_at, '%Y-%m-%dT%H:%M:%S.%fZ')
            now = datetime.datetime.now()
            age = (now - created_at).total_seconds()
            # 更简短：使用函数
            # age = calculate_age(job.created_at)

            for a in artifacts:
                # 为可读性省略分析收集代码

                # 高级过滤：将任务产物年龄和大小与阈值进行匹配
                if (float(age) > float(threshold_age)) or (float(a['size']) > float(threshold_size)):
                    # 将任务标记为待删除（不能在循环内删除）
                    jobs_marked_delete_artifacts.append(job)

    print("\n数据收集完成。")

    # 高级过滤：删除所有标记为待删除的任务产物。
    for job in jobs_marked_delete_artifacts:
        # 删除产物
        print("DEBUG", job)
        job.delete_artifacts()

    # 打印收集摘要（为可读性省略）
```

### 删除项目的所有任务产物

如果您不需要项目的[任务产物](../ci/jobs/job_artifacts.md)，可以使用以下命令删除所有任务产物。此操作不可逆。

产物删除可能需要几分钟或几小时，具体取决于要删除的产物数量。后续针对 API 的分析查询可能会将产物作为误报结果返回。为避免结果混淆，请勿立即运行额外的 API 请求。

默认情况下会[保留最近成功任务的任务产物](../ci/jobs/job_artifacts.md#keep-artifacts-from-most-recent-successful-jobs)。

要删除项目的所有任务产物：

{{< tabs >}}

{{< tab title="curl" >}}

```shell
export GL_PROJECT_ID=48349590

curl --silent --header "Authorization: Bearer $GITLAB_TOKEN" --request DELETE "https://gitlab.com/api/v4/projects/$GL_PROJECT_ID/artifacts"
```

{{< /tab >}}

{{< tab title="GitLab CLI" >}}

```shell
glab api --method GET projects/$GL_PROJECT_ID/jobs | jq --compact-output '.[]' | jq --compact-output '.id, .artifacts'

glab api --method DELETE projects/$GL_PROJECT_ID/artifacts
```

{{< /tab >}}

{{< tab title="Python" >}}

```python
        project.artifacts.delete()
```

{{< /tab >}}

{{< /tabs >}}

### 删除任务日志

删除任务日志时，您也会[清除整个任务](../api/jobs.md#erase-a-job)。

使用极狐GitLab CLI 的示例：

```shell
glab api --method GET projects/$GL_PROJECT_ID/jobs | jq --compact-output '.[]' | jq --compact-output '.id'

4836226184
4836226183
4836226181
4836226180

glab api --method POST projects/$GL_PROJECT_ID/jobs/4836226180/erase | jq --compact-output '.name,.status'
"generate-package: [1]"
"success"
```

在 `python-gitlab` API 库中，使用 [`job.erase()`](https://python-gitlab.readthedocs.io/en/stable/gl_objects/pipelines_and_jobs.html#jobs) 代替 `job.delete_artifacts()`。
为避免此 API 调用被阻止，请在删除任务产物的调用之间设置脚本短暂休眠：

```python
    for job in jobs_marked_delete_artifacts:
        # 删除产物和任务日志
        print("DEBUG", job)
        #job.delete_artifacts()
        job.erase()
        # 休眠 1 秒
        time.sleep(1)
```

为任务日志创建保留策略的支持已在 [issue 374717](https://gitlab.com/gitlab-org/gitlab/-/issues/374717) 中提出。

### 删除旧流水线

流水线不会增加整体存储用量，但如果需要，您可以[自动化其删除](../ci/pipelines/settings.md#automatic-pipeline-cleanup)。

要根据特定日期删除流水线，请指定 `created_at` 键。您可以使用该日期计算当前日期与流水线创建日期之间的差值。如果年龄大于阈值，则删除流水线。

> [!note]
> `created_at` 键必须从时间戳转换为 Unix 纪元时间，
> 例如使用 `date -d '2023-08-08T18:59:47.581Z' +%s`。

使用极狐GitLab CLI 的示例：

```shell
export GL_PROJECT_ID=48349590

glab api --method GET projects/$GL_PROJECT_ID/pipelines | jq --compact-output '.[]' | jq --compact-output '.id,.created_at'
960031926
"2023-08-08T22:09:52.745Z"
959884072
"2023-08-08T18:59:47.581Z"

glab api --method DELETE projects/$GL_PROJECT_ID/pipelines/960031926

glab api --method GET projects/$GL_PROJECT_ID/pipelines | jq --compact-output '.[]' | jq --compact-output '.id,.created_at'
959884072
"2023-08-08T18:59:47.581Z"
```

在以下使用 Bash 脚本的示例中：

- 已安装并授权 `jq` 和极狐GitLab CLI。
- 已导出环境变量 `GL_PROJECT_ID`。默认为极狐GitLab 预定义变量 `CI_PROJECT_ID`。
- 已导出环境变量 `CI_SERVER_HOST`，指向极狐GitLab 实例 URL。

{{< tabs >}}

{{< tab title="使用 glab 调用 API" >}}

完整脚本 `get_cicd_pipelines_compare_age_threshold_example.sh` 位于 [极狐GitLab API with Linux Shell](https://gitlab.com/gitlab-da/use-cases/gitlab-api/gitlab-api-linux-shell) 项目中。

```shell
#!/bin/bash

# 必需程序：
# - GitLab CLI (glab)：https://gitlab.cn/docs/cli/
# - jq：https://jqlang.github.io/jq/

# 必需变量：
# - PAT：具有 api 范围和所有者角色的项目访问令牌，或具有 api 范围的个人访问令牌
# - GL_PROJECT_ID：需要清理流水线的项目 ID
# - AGE_THRESHOLD（可选）：保留流水线的最大天数（默认：90）

set -euo pipefail

# 常量
DEFAULT_AGE_THRESHOLD=90
SECONDS_PER_DAY=$((24 * 60 * 60))

# 函数
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

delete_pipeline() {
    local project_id=$1
    local pipeline_id=$2
    if glab api --method DELETE "projects/$project_id/pipelines/$pipeline_id"; then
        log_info "已删除流水线 ID $pipeline_id"
    else
        log_error "删除流水线 ID $pipeline_id 失败"
    fi
}

# 主脚本
main() {
    # 认证
    if ! glab auth login --hostname "$CI_SERVER_HOST" --token "$PAT"; then
        log_error "认证失败"
        exit 1
    fi

    # 设置变量
    AGE_THRESHOLD=${AGE_THRESHOLD:-$DEFAULT_AGE_THRESHOLD}
    AGE_THRESHOLD_IN_SECONDS=$((AGE_THRESHOLD * SECONDS_PER_DAY))
    GL_PROJECT_ID=${GL_PROJECT_ID:-$CI_PROJECT_ID}
```
     # 获取流水线
    PIPELINES=$(glab api --method GET "projects/$GL_PROJECT_ID/pipelines")
    if [ -z "$PIPELINES" ]; then
        log_error "未能获取流水线或未找到任何流水线"
        exit 1
    fi

    # 处理流水线
    echo "$PIPELINES" | jq -r '.[] | [.id, .created_at] | @tsv' | while IFS=$'\t' read -r id created_at; do
        CREATED_AT_TS=$(date -d "$created_at" +%s)
        NOW=$(date +%s)
        AGE=$((NOW - CREATED_AT_TS))

        if [ "$AGE" -gt "$AGE_THRESHOLD_IN_SECONDS" ]; then
            log_info "流水线 ID $id 创建于 $created_at，超过阈值 $AGE_THRESHOLD 天，正在删除..."
            delete_pipeline "$GL_PROJECT_ID" "$id"
        else
            log_info "流水线 ID $id 创建于 $created_at，未超过阈值 $AGE_THRESHOLD 天，忽略。"
        fi
    done
}

main
```

{{< /tab >}}

{{< tab title="使用 glab CLI" >}}

完整脚本 `cleanup-old-pipelines.sh` 位于 [极狐GitLab API 与 Linux Shell](https://jihulab.com/gitlab-da/use-cases/gitlab-api/gitlab-api-linux-shell) 项目中。

```shell
#!/bin/bash

set -euo pipefail

# 必需的环境变量：
# PAT：具有 API 范围和所有者角色的项目访问令牌，或具有 API 范围的个人访问令牌。
# 可选的环境变量：
# AGE_THRESHOLD：要保留的流水线的最大保留天数。默认值：90 天。
# REPO：要清理的仓库。如果未设置，将使用当前仓库。
# CI_SERVER_HOST：极狐GitLab 服务器主机名。

# 用于显示错误信息并退出的函数
error_exit() {
    echo "错误：$1" >&2
    exit 1
}

# 验证必需的环境变量
[[ -z "${PAT:-}" ]] && error_exit "PAT（项目访问令牌或个人访问令牌）未设置。"
[[ -z "${CI_SERVER_HOST:-}" ]] && error_exit "CI_SERVER_HOST 未设置。"

# 设置并验证 AGE_THRESHOLD
AGE_THRESHOLD=${AGE_THRESHOLD:-90}
[[ ! "$AGE_THRESHOLD" =~ ^[0-9]+$ ]] && error_exit "AGE_THRESHOLD 必须为正整数。"

AGE_THRESHOLD_IN_HOURS=$((AGE_THRESHOLD * 24))

echo "正在删除超过 $AGE_THRESHOLD 天的流水线"

# 向极狐GitLab 认证
glab auth login --hostname "$CI_SERVER_HOST" --token "$PAT" || error_exit "认证失败"

# 删除旧流水线
delete_cmd="glab ci delete --older-than ${AGE_THRESHOLD_IN_HOURS}h"
if [[ -n "${REPO:-}" ]]; then
    delete_cmd+=" --repo $REPO"
fi

$delete_cmd || error_exit "流水线删除失败"

echo "流水线清理完成。"
```

{{< /tab >}}

{{< tab title="使用 Python API" >}}

你还可以使用 [`python-gitlab` API 库](https://python-gitlab.readthedocs.io/en/stable/gl_objects/pipelines_and_jobs.html#project-pipelines)和 `created_at` 属性来实现类似的算法，比较作业产物年龄：

```python
        # ...

        for pipeline in project.pipelines.list(iterator=True):
            pipeline_obj = project.pipelines.get(pipeline.id)
            print("DEBUG: {p}".format(p=json.dumps(pipeline_obj.attributes, indent=4)))

            created_at = datetime.datetime.strptime(pipeline.created_at, '%Y-%m-%dT%H:%M:%S.%fZ')
            now = datetime.datetime.now()
            age = (now - created_at).total_seconds()

            threshold_age = 90 * 24 * 60 * 60

            if (float(age) > float(threshold_age)):
                print("正在删除流水线", pipeline.id)
                pipeline_obj.delete()
```

{{< /tab >}}

{{< /tabs >}}

### 列出作业产物的过期设置

为了管理产物存储，你可以更新或配置产物的过期时间。
产物的过期设置是在每个作业配置中的 `.gitlab-ci.yml` 文件中进行的。

如果有多个项目，并且根据 CI/CD 配置中作业定义的组织方式，可能很难找到过期设置。你可以使用脚本搜索整个 CI/CD 配置。这包括访问继承值后解析的对象，例如 `extends` 或 `!reference`。

该脚本检索合并后的 CI/CD 配置文件，并搜索 `artifacts` 键，以：

- 识别没有过期设置的作业。
- 为已配置了产物过期的作业返回过期设置。

以下过程描述了脚本如何搜索产物的过期设置：

1. 为了生成合并后的 CI/CD 配置，脚本循环遍历所有项目，并调用 [`ci_lint()`](https://python-gitlab.readthedocs.io/en/stable/gl_objects/ci_lint.html) 方法。
1. `yaml_load` 函数将合并后的配置加载到 Python 数据结构中进行进一步分析。
1. 同时拥有 `script` 键的字典会被标识为作业定义，其中可能存在 `artifacts` 键。
1. 如果是，脚本会解析子键 `expire_in`，并存储详细信息，以便稍后以 Markdown 表格摘要的形式打印出来。

```python
    ci_job_artifacts_expiry = {}

    # 循环遍历项目，获取 .gitlab-ci.yml，运行 linter 以获得完整的转换配置，并提取 `artifacts:` 设置
    # https://python-gitlab.readthedocs.io/en/stable/gl_objects/ci_lint.html
    for project in projects:
            project_obj = gl.projects.get(project.id)
            project_name = project_obj.name
            project_web_url = project_obj.web_url
            try:
                lint_result = project.ci_lint.get()
                if lint_result.merged_yaml is None:
                    continue

                ci_pipeline = yaml.safe_load(lint_result.merged_yaml)
                #print("项目 {p} 配置\n{c}\n\n".format(p=project_name, c=json.dumps(ci_pipeline, indent=4)))

                for k in ci_pipeline:
                    v = ci_pipeline[k]
                    # 这是一个带有 `script` 属性的作业对象
                    if isinstance(v, dict) and 'script' in v:
                        print(".", end="", flush=True)  # 获取一些反馈表明仍在循环中
                        artifacts = v['artifacts'] if 'artifacts' in v else {}

                        print("项目 {p} 作业 {j} 产物 {a}".format(p=project_name, j=k, a=json.dumps(artifacts, indent=4)))

                        expire_in = None
                        if 'expire_in' in artifacts:
                            expire_in = artifacts['expire_in']

                        store_key = project_web_url + '_' + k
                        ci_job_artifacts_expiry[store_key] = { 'project_web_url': project_web_url,
                                                        'project_name': project_name,
                                                        'job_name': k,
                                                        'artifacts_expiry': expire_in}

            except Exception as e:
                 print(f"搜索 CI 流水线中的产物时发生异常：{e}".format(e=e))

    if len(ci_job_artifacts_expiry) > 0:
        print("| 项目 | 作业 | 产物过期 |\n|---------|-----|-----------------|")  # 开始 Markdown 友好的表格
        for k, details in ci_job_artifacts_expiry.items():
            if details['job_name'][0] == '.':
                continue  # 忽略以 '.' 开头的作业模板
            print(f'| [{ details["project_name"] }]({details["project_web_url"]}) | { details["job_name"] } | { details["artifacts_expiry"] if details["artifacts_expiry"] is not None else "❌ N/A" } |')
```

脚本会生成一个 Markdown 摘要表格，包含：

- 项目名称和 URL。
- 作业名称。
- `artifacts:expire_in` 设置，如果未设置则显示 `N/A`。

脚本不会打印以下作业模板：

- 以 `.` 字符开头的。
- 未作为运行时作业对象实例化并生成产物的。

```shell
export GL_GROUP_ID=56595735

# 安装脚本依赖项
python3 -m pip install 'python-gitlab[yaml]'

python3 get_all_cicd_config_artifacts_expiry.py

| 项目 | 作业 | 产物过期 |
|---------|-----|-----------------|
| [Gen Job Artifacts 4](https://jihulab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-4) | generator | 30 天 |
| [Gen Job Artifacts with expiry and included jobs](https://jihulab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-expiry-included-jobs) | included-job10 | 10 天 |
| [Gen Job Artifacts with expiry and included jobs](https://jihulab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-expiry-included-jobs) | included-job1 | 1 天 |
| [Gen Job Artifacts with expiry and included jobs](https://jihulab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-expiry-included-jobs) | included-job30 | 30 天 |
| [Gen Job Artifacts with expiry and included jobs](https://jihulab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-expiry-included-jobs) | generator | 30 天 |
| [Gen Job Artifacts 2](https://jihulab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-2) | generator | ❌ N/A |
| [Gen Job Artifacts 1](https://jihulab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-1) | generator | ❌ N/A |
```

`get_all_cicd_config_artifacts_expiry.py` 脚本位于 [极狐GitLab API with Python 项目](https://jihulab.com/gitlab-da/use-cases/gitlab-api/gitlab-api-python/) 中。

或者，你也可以使用具有 API 请求的 [高级搜索](search/advanced_search.md)。以下示例使用 [scope: blobs](../api/search.md#scope-blobs) 在所有的 `*.yml` 文件中搜索字符串 `artifacts`：

```shell
# https://jihulab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-expiry-included-jobs
export GL_PROJECT_ID=48349263

glab api --method GET projects/$GL_PROJECT_ID/search --field "scope=blobs" --field "search=expire_in filename:*.yml"
```

有关清单方法的更多信息，请参阅 [极狐GitLab 如何帮助缓解 Docker Hub 上开源容器镜像的删除问题](https://gitlab.cn/blog/how-gitlab-can-help-mitigate-deletion-open-source-images-docker-hub/)。

### 设置作业产物的默认过期时间

要为项目中的作业产物设置默认过期时间，请在 `.gitlab-ci.yml` 文件中指定 `expire_in` 值：

```yaml
default:
    artifacts:
        expire_in: 1 week
```

## 管理容器镜像仓库存储

容器镜像仓库可用于 [项目](../api/container_registry.md#within-a-project) 或 [群组](../api/container_registry.md#within-a-group)。你可以分析这两者以实现清理策略。

### 列出容器镜像仓库

列出项目中的容器镜像仓库：

{{< tabs >}}

{{< tab title="curl" >}}

```shell
export GL_PROJECT_ID=48057080

curl --silent --header "Authorization: Bearer $GITLAB_TOKEN" "https://jihulab.com/api/v4/projects/$GL_PROJECT_ID/registry/repositories" | jq --compact-output '.[]' | jq --compact-output '.id,.location' | jq
4435617
"registry.jihulab.com/gitlab-da/playground/container-package-gen-group/docker-alpine-generator"

curl --silent --header "Authorization: Bearer $GITLAB_TOKEN" "https://jihulab.com/api/v4/registry/repositories/4435617?size=true" | jq --compact-output '.id,.location,.size'
4435617
"registry.jihulab.com/gitlab-da/playground/container-package-gen-group/docker-alpine-generator"
3401613
```

{{< /tab >}}

{{< tab title="极狐GitLab CLI" >}}

```shell
export GL_PROJECT_ID=48057080

glab api --method GET projects/$GL_PROJECT_ID/registry/repositories | jq --compact-output '.[]' | jq --compact-output '.id,.location'
4435617
"registry.jihulab.com/gitlab-da/playground/container-package-gen-group/docker-alpine-generator"

glab api --method GET registry/repositories/4435617 --field='size=true' | jq --compact-output '.id,.location,.size'
4435617
"registry.jihulab.com/gitlab-da/playground/container-package-gen-group/docker-alpine-generator"
3401613

glab api --method GET projects/$GL_PROJECT_ID/registry/repositories/4435617/tags | jq --compact-output '.[]' | jq --compact-output '.name'
"latest"

glab api --method GET projects/$GL_PROJECT_ID/registry/repositories/4435617/tags/latest | jq --compact-output '.name,.created_at,.total_size'
"latest"
"2023-08-07T19:20:20.894+00:00"
3401613
```

{{< /tab >}}

{{< /tabs >}}

### 批量删除容器镜像

当你 [批量删除容器镜像标签](../api/container_registry.md#delete-registry-repository-tags-in-bulk) 时，你可以配置：

- 用于匹配标签名称和要保留（`name_regex_keep`）或删除（`name_regex_delete`）的镜像的正则表达式
- 要保留的与标签名称匹配的镜像标签数量（`keep_n`）
- 镜像标签可以被删除之前的天数（`older_than`）

> [!warning]
> 在 JihuLab.com 上，由于容器镜像仓库的规模，该 API 删除的标签数量是有限的。
> 如果你的容器镜像仓库有大量要删除的标签，则只会删除其中的一部分。你可能需要多次调用 API。要安排标签自动删除，请改用 [清理策略](#create-a-cleanup-policy-for-containers)。

以下示例使用 [`python-gitlab` API 库](https://python-gitlab.readthedocs.io/en/stable/gl_objects/repository_tags.html) 获取标签列表，并使用过滤参数调用 `delete_in_bulk()` 方法。

```python
        repositories = project.repositories.list(iterator=True, size=True)
        if len(repositories) > 0:
            repository = repositories.pop()
            tags = repository.tags.list()

            # 清理：只保留最新的标签
            repository.tags.delete_in_bulk(keep_n=1)
            # 清理：删除所有超过1个月的标签
            repository.tags.delete_in_bulk(older_than="1m")
            # 清理：删除所有匹配正则表达式 `v.*` 的标签，并保留最新的2个标签
            repository.tags.delete_in_bulk(name_regex_delete="v.+", keep_n=2)
```

### 为容器创建清理策略

使用项目 REST API 端点 [为容器创建清理策略](packages/container_registry/reduce_container_registry_storage.md#use-the-cleanup-policy-api)。设置清理策略后，所有符合你规范的容器镜像将自动删除。你不再需要额外的 API 自动化脚本。

要将属性作为正文参数发送：

- 使用 `--input -` 参数从标准输入读取。
- 设置 `Content-Type` 头。

以下示例使用极狐GitLab CLI 创建清理策略：

```shell
export GL_PROJECT_ID=48057080

echo '{"container_expiration_policy_attributes":{"cadence":"1month","enabled":true,"keep_n":1,"older_than":"14d","name_regex":".*","name_regex_keep":".*-main"}}' | glab api --method PUT --header 'Content-Type: application/json;charset=UTF-8' projects/$GL_PROJECT_ID --input -

...

  "container_expiration_policy": {
    "cadence": "1month",
    "enabled": true,
    "keep_n": 1,
    "older_than": "14d",
    "name_regex": ".*",
    "name_regex_keep": ".*-main",
    "next_run_at": "2023-09-08T21:16:25.354Z"
  },

```

### 优化容器镜像

你可以优化容器镜像，以减少镜像大小和容器镜像仓库中的整体存储消耗。在 [流水线效率文档](../ci/pipelines/pipeline_efficiency.md#optimize-docker-images) 中了解更多信息。

## 管理软件包仓库存储

软件包仓库可用于 [项目](../api/packages.md#for-a-project) 或 [群组](../api/packages.md#for-a-group)。

### 列出软件包和文件

以下示例展示了使用极狐GitLab CLI 从定义的项目 ID 获取软件包。结果集是一个字典项数组，可以使用 `jq` 命令链进行过滤。

```shell
# https://jihulab.com/gitlab-da/playground/container-package-gen-group/generic-package-generator
export GL_PROJECT_ID=48377643

glab api --method GET projects/$GL_PROJECT_ID/packages | jq --compact-output '.[]' | jq --compact-output '.id,.name,.package_type'
16669383
"generator"
"generic"
16671352
"generator"
"generic"
16672235
"generator"
"generic"
16672237
"generator"
"generic"
```

使用软件包 ID 检查软件包中的文件及其大小。

```shell
glab api --method GET projects/$GL_PROJECT_ID/packages/16669383/package_files | jq --compact-output '.[]' |
 jq --compact-output '.package_id,.file_name,.size'

16669383
"nighly.tar.gz"
10487563
```

[删除旧流水线](#delete-old-pipelines) 部分中创建了一个类似的自动化 Shell 脚本。

以下脚本示例使用 `python-gitlab` 库在循环中获取所有软件包，并遍历其软件包文件以打印 `file_name` 和 `size` 属性。

```python
        packages = project.packages.list(order_by="created_at")

        for package in packages:

            package_files = package.package_files.list()
            for package_file in package_files:
                print("软件包名称：{p} 文件名：{f} 大小 {s}".format(
                    p=package.name, f=package_file.file_name, s=render_size_mb(package_file.size)))
```

### 删除软件包

[删除软件包中的文件](../api/packages.md#delete-a-package-file) 可能会损坏软件包。在执行自动化清理维护时，你应该删除整个软件包。

要删除软件包，请使用极狐GitLab CLI 将 `--method` 参数更改为 `DELETE`：

```shell
glab api --method DELETE projects/$GL_PROJECT_ID/packages/16669383
```

要计算软件包大小并将其与大小阈值进行比较，你可以使用 `python-gitlab` 库扩展 [列出软件包和文件](#list-packages-and-files) 部分中描述的代码。

以下代码示例还计算了软件包的年龄，并在条件匹配时删除软件包：

```python
        packages = project.packages.list(order_by="created_at")
        for package in packages:
            package_size = 0.0

            package_files = package.package_files.list()
            for package_file in package_files:
                print("软件包名称：{p} 文件名：{f} 大小 {s}".format(
                    p=package.name, f=package_file.file_name, s=render_size_mb(package_file.size)))

                package_size =+ package_file.size

            print("软件包大小：{s}\n\n".format(s=render_size_mb(package_size)))

            threshold_size = 10 * 1024 * 1024

            if (package_size > float(threshold_size)):
                print("软件包大小 {s} > 阈值 {t}，正在删除软件包。".format(
                    s=render_size_mb(package_size), t=render_size_mb(threshold_size)))
                package.delete()

            threshold_age = 90 * 24 * 60 * 60
            package_age = created_at = calculate_age(package.created_at)

            if (float(package_age > float(threshold_age))):
                print("软件包年龄 {a} > 阈值 {t}，正在删除软件包。".format(
                    a=render_age_time(package_age), t=render_age_time(threshold_age)))
                package.delete()
```

代码生成以下输出，可用于进一步分析：

```shell
软件包名称：generator 文件名：nighly.tar.gz 大小 10.0017
软件包大小：10.0017
软件包大小 10.0017 > 阈值 10.0000，正在删除软件包。

软件包名称：generator 文件名：1-nightly.tar.gz 大小 1.0004
软件包大小：1.0004

软件包名称：generator 文件名：10-nightly.tar.gz 大小 10.0018
软件包名称：generator 文件名：20-nightly.tar.gz 大小 20.0033
软件包大小：20.0033
软件包大小 20.0033 > 阈值 10.0000，正在删除软件包。
```

### 依赖代理

查看 [清理策略](packages/dependency_proxy/reduce_dependency_proxy_storage.md#cleanup-policies) 以及如何 [使用 API 清除缓存](packages/dependency_proxy/reduce_dependency_proxy_storage.md#use-the-api-to-clear-the-cache)。

## 提高输出的可读性

你可能需要将时间戳秒数转换为持续时间格式，或以更具代表性的格式打印原始字节。你可以使用以下辅助函数来转换值，以提高可读性：

```shell
# 当前 Unix 时间戳
date +%s

# 将带时区的 `created_at` 日期时间转换为 Unix 时间戳
date -d '2023-08-08T18:59:47.581Z' +%s
```

使用 `python-gitlab` API 库的 Python 示例：

```python
def render_size_mb(v):
    return "%.4f" % (v / 1024 / 1024)

def render_age_time(v):
    return str(datetime.timedelta(seconds = v))

# 将带时区的 `created_at` 日期时间转换为 Unix 时间戳
def calculate_age(created_at_datetime):
    created_at_ts = datetime.datetime.strptime(created_at_datetime, '%Y-%m-%dT%H:%M:%S.%fZ')
    now = datetime.datetime.now()
    return (now - created_at_ts).total_seconds()
```

## 测试存储管理自动化

为了测试存储管理自动化，你可能需要生成测试数据，或填充存储以验证分析和删除是否按预期工作。以下部分提供了关于在短时间内测试和生成存储数据的工具和技巧。

### 生成作业产物

创建一个测试项目，使用 CI/CD 作业矩阵构建生成伪产物数据。添加一个 CI/CD 流水线以每日生成产物。

1. 创建一个新项目。
1. 将以下代码段添加到 `.gitlab-ci.yml` 中，以包含作业产物生成器配置。

   ```yaml
   include:
       - remote: https://jihulab.com/gitlab-da/use-cases/efficiency/job-artifact-generator/-/raw/main/.gitlab-ci.yml
   ```

1. [配置流水线计划](../ci/pipelines/schedules.md#create-a-pipeline-schedule)。
1. [手动触发流水线](../ci/pipelines/schedules.md#run-manually)。

或者，将每日生成的 86 MB 数据减少到 `MB_COUNT` 变量中的不同值。

```yaml
include:
    - remote: https://jihulab.com/gitlab-da/use-cases/efficiency/job-artifact-generator/-/raw/main/.gitlab-ci.yml

generator:
    parallel:
        matrix:
            - MB_COUNT: [1, 5, 10, 20, 50]

```

更多信息，请参阅 [作业产物生成器 README](https://jihulab.com/gitlab-da/use-cases/efficiency/job-artifact-generator)，并附有 [示例群组](https://jihulab.com/gitlab-da/playground/artifact-gen-group)。

### 生成带过期时间的作业产物

项目 CI/CD 配置在以下位置指定作业定义：

- 主 `.gitlab-ci.yml` 配置文件。
- `artifacts:expire_in` 设置。
- 项目文件和模板。

为了测试分析脚本，[`gen-job-artifacts-expiry-included-jobs`](https://jihulab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-expiry-included-jobs) 项目提供了一个示例配置。

```yaml
# .gitlab-ci.yml
include:
    - include_jobs.yml

default:
  artifacts:
      paths:
          - '*.txt'

.gen-tmpl:
    script:
        - dd if=/dev/urandom of=${$MB_COUNT}.txt bs=1048576 count=${$MB_COUNT}

generator:
    extends: [.gen-tmpl]
    parallel:
        matrix:
            - MB_COUNT: [1, 5, 10, 20, 50]
    artifacts:
        untracked: false
        when: on_success
        expire_in: 30 days

# include_jobs.yml
.includeme:
    script:
        - dd if=/dev/urandom of=1.txt bs=1048576 count=1

included-job10:
    script:
        - echo "Servus"
        - !reference [.includeme, script]
    artifacts:
        untracked: false
        when: on_success
        expire_in: 10 days

included-job1:
    script:
        - echo "Gruezi"
        - !reference [.includeme, script]
    artifacts:
        untracked: false
        when: on_success
        expire_in: 1 days

included-job30:
    script:
        - echo "Grias di"
        - !reference [.includeme, script]
    artifacts:
        untracked: false
        when: on_success
        expire_in: 30 days
```

### 生成容器镜像

示例群组 [`container-package-gen-group`](https://jihulab.com/gitlab-da/playground/container-package-gen-group) 提供了以下项目：

- 使用 Dockerfile 中的基础镜像构建新镜像。
- 包含 `Docker.gitlab-ci.yml` 模板，以便在 JihuLab.com 上构建镜像。
- 配置流水线计划以每日生成新镜像。

可供 Fork 的示例项目：

- [`docker-alpine-generator`](https://jihulab.com/gitlab-da/playground/container-package-gen-group/docker-alpine-generator)
- [`docker-python-generator`](https://jihulab.com/gitlab-da/playground/container-package-gen-group/docker-python-generator)

### 生成通用软件包

示例项目 [`generic-package-generator`](https://jihulab.com/gitlab-da/playground/container-package-gen-group/generic-package-generator) 提供了以下功能：

- 生成一个随机文本块，并使用当前 Unix 时间戳作为发布版本创建一个 tarball。
- 将 tarball 上传到通用软件包仓库，使用 Unix 时间戳作为发布版本。

要生成通用软件包，你可以使用这个独立的 `.gitlab-ci.yml` 配置：
```yaml
generate-package:
  parallel:
    matrix:
      - MB_COUNT: [1, 5, 10, 20]
  before_script:
    - apt update && apt -y install curl
  script:
    - dd if=/dev/urandom of="${MB_COUNT}.txt" bs=1048576 count=${MB_COUNT}
    - tar czf "generated-$MB_COUNT-nighly-`date +%s`.tar.gz" "${MB_COUNT}.txt"
    - 'curl --header "JOB-TOKEN: $CI_JOB_TOKEN" --upload-file "generated-$MB_COUNT-nighly-`date +%s`.tar.gz" "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/generator/`date +%s`/${MB_COUNT}-nightly.tar.gz"'

  artifacts:
    paths:
      - '*.tar.gz'

```

### 通过 Fork 生成存储使用量

使用以下项目，结合 [Fork 的成本系数](storage_usage_quotas.md#view-project-fork-storage-usage) 来测试存储使用情况：

- 将 [`gitlab-org/gitlab`](https://jihulab.com/gitlab-cn/gitlab) Fork 到一个新的命名空间或群组中（包括 LFS、Git 代码仓）。
- 将 [`gitlab-com/www-gitlab-com`](https://jihulab.com/gitlab-com/www-gitlab-com) Fork 到一个新的命名空间或群组中。

## 社区资源

以下资源并非官方支持。在执行可能无法撤销的破坏性清理命令之前，请务必测试相关脚本和教程。

- 论坛主题：[存储管理自动化资源](https://forum.gitlab.com/t/storage-management-automation-resources/91184)
- 脚本：[GitLab 存储分析器](https://jihulab.com/gitlab-da/use-cases/gitlab-api/gitlab-storage-analyzer)，由 [GitLab 开发者布道团队](https://jihulab.com/gitlab-da/) 维护的非官方项目。你可以在本文档的此操作方法中找到类似的代码示例。