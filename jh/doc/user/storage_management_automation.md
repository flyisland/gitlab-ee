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

本页介绍如何使用极狐GitLab REST API 自动化存储分析和清理，以管理您的存储用量。

您还可以通过提升[流水线效率](../ci/pipelines/pipeline_efficiency.md)来管理存储用量。

如需 API 自动化的更多帮助，您还可以使用 [GitLab 社区论坛和 Discord](https://about.gitlab.com/community/)。

> [!warning]
> 本页中的脚本示例仅用于演示目的，不应在生产环境中使用。您可以使用这些示例来设计和测试您自己的存储自动化脚本。

<a id="api-requirements"></a>

## API 要求

要自动化存储管理，您的 JihuLab.com 或极狐GitLab 私有化部署实例必须能够访问[极狐GitLab REST API](../api/api_resources.md)。

<a id="api-authentication-scope"></a>

### API 身份验证范围

使用以下范围通过 API 进行[身份验证](../api/rest/authentication.md)：

- 存储分析：
  - 使用 `read_api` 范围进行读取 API 访问。
  - 在所有项目上具有开发者、维护者或所有者角色。
- 存储清理：
  - 使用 `api` 范围进行完整 API 访问。
  - 在所有项目上具有维护者或所有者角色。

您可以使用命令行工具或编程语言与 REST API 交互。

<a id="command-line-tools"></a>

### 命令行工具

要发送 API 请求，请安装以下任一工具：

- 使用您首选的软件包管理器安装 curl。
- [GitLab CLI](https://gitlab.cn/docs/cli/)，并使用 `glab api` 子命令。

要格式化 JSON 响应，请安装 `jq`。更多信息，请参见[高效 DevOps 工作流技巧：使用 jq 进行 JSON 格式化以及 CI/CD lint 自动化](https://about.gitlab.com/blog/devops-workflows-json-format-jq-ci-cd-lint/)。

要将这些工具与 REST API 配合使用：

{{< tabs >}}

{{< tab title="curl" >}}

```shell
export GITLAB_TOKEN=xxx

curl --silent --header "Authorization: Bearer $GITLAB_TOKEN" "https://jihulab.com/api/v4/user" | jq
```

{{< /tab >}}

{{< tab title="GitLab CLI" >}}

```shell
glab auth login

glab api groups/YOURGROUPNAME/projects
```

{{< /tab >}}

{{< /tabs >}}

<a id="using-the-gitlab-cli"></a>

#### 使用 GitLab CLI

某些 API 端点需要[分页](../api/rest/_index.md#pagination)并获取后续页面才能检索所有结果。GitLab CLI 提供了 `--paginate` 标志。

需要以 JSON 数据格式提供 POST 请求正文的请求，可以写成传递给 `--raw-field` 参数的 `key=value` 键值对。

更多信息，请参见 [GitLab CLI 端点文档](https://gitlab.cn/docs/cli/#commands)。

<a id="api-client-libraries"></a>

### API 客户端库

本页介绍的存储管理和清理自动化方法使用：

- [`python-gitlab`](https://python-gitlab.readthedocs.io/en/stable/) 库，它提供了功能丰富的编程接口。
- [极狐GitLab API with Python](https://gitlab.com/gitlab-da/use-cases/gitlab-api/gitlab-api-python/) 项目中的 `get_all_projects_top_level_namespace_storage_analysis_cleanup_example.py` 脚本。

有关 `python-gitlab` 库用例的更多信息，请参见[高效 DevSecOps 工作流：动手实践 `python-gitlab` API 自动化](https://about.gitlab.com/blog/efficient-devsecops-workflows-hands-on-python-gitlab-api-automation/)。

有关其他 API 客户端库的更多信息，请参见[第三方客户端](../api/rest/third_party_clients.md)。

> [!note]
> 使用极狐GitLab Duo 代码建议更高效地编写代码。

<a id="storage-analysis"></a>

## 存储分析

<a id="identify-storage-types"></a>

### 识别存储类型

[项目 API 端点](../api/projects.md#list-all-projects)提供极狐GitLab 实例中项目的统计数据。要使用项目 API 端点，请将 `statistics` 键设置为布尔值 `true`。这些数据可让您了解项目按以下存储类型的存储消耗情况：

- `storage_size`：总存储
- `lfs_objects_size`：LFS 对象存储
- `job_artifacts_size`：作业产物存储
- `packages_size`：软件包存储
- `repository_size`：Git 代码仓库存储
- `snippets_size`：代码片段存储
- `uploads_size`：上传文件存储
- `wiki_size`：Wiki 存储

要识别存储类型：

{{< tabs >}}

{{< tab title="curl" >}}

```shell
curl --silent --header "Authorization: Bearer $GITLAB_TOKEN" "https://jihulab.com/api/v4/projects/$GL_PROJECT_ID?statistics=true" | jq --compact-output '.id,.statistics' | jq
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

要将项目的统计数据打印到终端，请导出 `GL_GROUP_ID` 环境变量并运行脚本：

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

<a id="analyze-storage-in-projects-and-groups"></a>

### 分析项目和群组中的存储

您可以自动化分析多个项目和群组。例如，您可以从顶层命名空间开始，递归分析所有子群组和项目。您还可以分析不同的存储类型。

以下是一个分析多个子群组和项目的算法示例：

1. 获取顶层命名空间 ID。您可以从[命名空间/群组概览](namespace/_index.md#types-of-namespaces)中复制 ID 值。
1. 从顶层群组获取所有[子群组](../api/groups.md#list-subgroups)，并将 ID 保存到列表中。
1. 遍历所有群组，获取[每个群组中的所有项目](../api/groups.md#list-projects)，并将 ID 保存到列表中。
1. 确定要分析的存储类型，并从项目属性（如项目统计信息和作业产物）中收集信息。
1. 打印所有项目的概览，按群组分组，并显示其存储信息。

使用 `glab`的 shell 方法可能更适合较小的分析。对于较大的分析，您应使用基于 API 客户端库的脚本。这类脚本可以提高可读性、数据存储、流程控制、测试和可复用性。

为确保脚本不会触及 [API 速率限制](../rate_limits/_index.md)，以下示例代码未针对并行 API 请求进行优化。

要实现此算法：

{{< tabs >}}

{{< tab title="GitLab CLI" >}}

```shell
export GROUP_NAME="gitlab-da"

# Return subgroup IDs
glab api groups/$GROUP_NAME/subgroups | jq --compact-output '.[]' | jq --compact-output '.id'
12034712
67218622
67162711
67640130
16058698
12034604

# Loop over all subgroups to get subgroups, until the result set is empty. Example group: 12034712
glab api groups/12034712/subgroups | jq --compact-output '.[]' | jq --compact-output '.id'
56595735
70677315
67218606
70812167

# Lowest group level
glab api groups/56595735/subgroups | jq --compact-output '.[]' | jq --compact-output '.id'
# empty result, return and continue with analysis

# Fetch projects from all collected groups. Example group: 56595735
glab api groups/56595735/projects | jq --compact-output '.[]' | jq --compact-output '.id'
48349590
48349263
38520467
38520405

# Fetch storage types from a project (ID 48349590): Job artifacts in the `artifacts` key
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
GITLAB_TOKEN = os.environ.get('GL_TOKEN') # token requires developer permissions
PROJECT_ID = os.environ.get('GL_PROJECT_ID') #optional
GROUP_ID = os.environ.get('GL_GROUP_ID') #optional

if __name__ == "__main__":
    if not GITLAB_TOKEN:
        print("🤔 Please set the GL_TOKEN env variable.")
        sys.exit(1)

    gl = gitlab.Gitlab(GITLAB_SERVER, private_token=GITLAB_TOKEN, pagination="keyset", order_by="id", per_page=100)

    # Collect all projects, or prefer projects from a group id, or a project id
    projects = []

    # Direct project ID
    if PROJECT_ID:
        projects.append(gl.projects.get(PROJECT_ID))
    # Groups and projects inside
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

该脚本以 JSON 格式的列表输出项目作业产物：

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

<a id="manage-cicd-pipeline-storage"></a>

## 管理 CI/CD 流水线存储

作业产物占用了大部分流水线存储，作业日志也可能产生数百 KB 的数据。您应先删除不必要的作业产物，然后在分析后清理作业日志。

> [!warning]
> 删除作业日志和产物是不可逆的破坏性操作。请谨慎使用。删除某些文件（包括报告产物、作业日志和元数据文件）会影响将这些文件用作数据源的极狐GitLab 功能。

<a id="list-job-artifacts"></a>

### 列出作业产物

要分析流水线存储，您可以使用[作业 API 端点](../api/jobs.md#list-all-jobs-for-a-project)检索作业产物列表。该端点在 `artifacts` 属性中返回作业产物的 `file_type` 键。`file_type` 键表示产物类型：

- `archive` 用于生成的作业产物，为 zip 文件。
- `metadata` 用于 Gzip 文件中的附加元数据。
- `trace` 用于原始文件形式的 `job.log`。

作业产物提供了一种数据结构，可以将其作为缓存文件写入磁盘，您可以用它来测试实现。

基于获取所有项目的示例代码，您可以扩展 Python 脚本以进行更多分析。

以下示例显示了查询项目中作业产物的响应：

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

根据您实现脚本的方式，您可以：

- 收集所有作业产物，并在脚本末尾打印汇总表。
- 立即打印信息。

在以下示例中，作业产物被收集到 `ci_job_artifacts` 列表中。该脚本遍历所有项目，并获取：

- 包含所有属性的 `project_obj` 对象变量。
- `job` 对象中的 `artifacts` 属性。

您可以使用[键集分页](https://python-gitlab.readthedocs.io/en/stable/api-usage.html#pagination)来遍历大量的流水线和作业。

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

    print("\nDone collecting data.")

    if len(ci_job_artifacts) > 0:
        print("| Project | Job | Artifact name | Artifact type | Artifact size |\n|---------|-----|---------------|---------------|---------------|") # Start markdown friendly table
        for artifact in ci_job_artifacts:
            print('| [{project_name}]({project_web_url}) | {job_name} | {artifact_name} | {artifact_type} | {artifact_size} |'.format(project_name=artifact['project_path_with_namespace'], project_web_url=artifact['project_web_url'], job_name=artifact['job_id'], artifact_name=artifact['artifact_filename'], artifact_type=artifact['artifact_file_type'], artifact_size=render_size_mb(artifact['artifact_size'])))
    else:
        print("No artifacts found.")
```

在脚本末尾，作业产物以 Markdown 格式的表格打印。您可以将表格内容复制到议题评论或描述中，或填充到极狐GitLab 代码仓库中的 Markdown 文件。

```shell
$ python3 get_all_projects_top_level_namespace_storage_analysis_cleanup_example.py

| Project | Job | Artifact name | Artifact type | Artifact size |
|---------|-----|---------------|---------------|---------------|
| [gitlab-da/playground/artifact-gen-group/gen-job-artifacts-4](Gen Job Artifacts 4) | 4828297946 | artifacts.zip | archive | 50.0154 |
| [gitlab-da/playground/artifact-gen-group/gen-job-artifacts-4](Gen Job Artifacts 4) | 4828297946 | metadata.gz | metadata | 0.0001 |
| [gitlab-da/playground/artifact-gen-group/gen-job-artifacts-4](Gen Job Artifacts 4) | 4828297946 | job.log | trace | 0.0030 |
| [gitlab-da/playground/artifact-gen-group/gen-job-artifacts-4](Gen Job Artifacts 4) | 4828297945 | artifacts.zip | archive | 20.0063 |
| [gitlab-da/playground/artifact-gen-group/gen-job-artifacts-4](Gen Job Artifacts 4) | 4828297945 | metadata.gz | metadata | 0.0001 |
| [gitlab-da/playground/artifact-gen-group/gen-job-artifacts-4](Gen Job Artifacts 4) | 4828297945 | job.log | trace | 0.0030 |
```

<a id="delete-job-artifacts-in-bulk"></a>

### 批量删除作业产物

您可以使用 Python 脚本筛选要批量删除的作业产物类型。

筛选 API 查询结果以比较：

- `created_at` 值，以计算产物存在时长。
- `size` 属性，以确定产物是否达到大小阈值。

典型请求：

- 删除早于指定天数的作业产物。
- 删除超过指定存储量的作业产物。例如 100 MB。

在以下示例中，脚本遍历作业属性并将其标记为待删除。当集合遍历移除对象锁后，脚本会删除标记为待删除的作业产物。

```python
   for project in projects:
        project_obj = gl.projects.get(project.id)

        jobs = project.jobs.list(pagination="keyset", order_by="id", per_page=100, iterator=True)

        for job in jobs:
            artifacts = job.attributes['artifacts']
            if not artifacts:
                continue

            # Advanced filtering: Age and Size
            # Example: 90 days, 10 MB threshold (TODO: Make this configurable)
            threshold_age = 90 * 24 * 60 * 60
            threshold_size = 10 * 1024 * 1024

            # job age, need to parse API format: 2023-08-08T22:41:08.270Z
            created_at = datetime.datetime.strptime(job.created_at, '%Y-%m-%dT%H:%M:%S.%fZ')
            now = datetime.datetime.now()
            age = (now - created_at).total_seconds()
            # Shorter: Use a function
            # age = calculate_age(job.created_at)

            for a in artifacts:
                # Analysis collection code removed for readability

                # Advanced filtering: match job artifacts age and size against thresholds
                if (float(age) > float(threshold_age)) or (float(a['size']) > float(threshold_size)):
                    # mark job for deletion (cannot delete inside the loop)
                    jobs_marked_delete_artifacts.append(job)

    print("\nDone collecting data.")

    # Advanced filtering: Delete all job artifacts marked to being deleted.
    for job in jobs_marked_delete_artifacts:
        # delete the artifact
        print("DEBUG", job)
        job.delete_artifacts()

    # Print collection summary (removed for readability)
```

<a id="delete-all-job-artifacts-for-a-project"></a>

### 删除项目的所有作业产物

如果您不需要项目的[作业产物](../ci/jobs/job_artifacts.md)，可以使用以下命令删除所有作业产物。此操作不可逆。

产物删除可能需要几分钟到几小时，具体取决于要删除的产物数量。后续针对 API 的分析查询可能会将这些产物作为误报结果返回。为避免结果混淆，请不要立即运行其他 API 请求。

默认情况下会保留[最近成功作业的产物](../ci/jobs/job_artifacts.md#keep-artifacts-from-most-recent-successful-jobs)。

要删除项目的所有作业产物：

{{< tabs >}}

{{< tab title="curl" >}}

```shell
export GL_PROJECT_ID=48349590

curl --silent --header "Authorization: Bearer $GITLAB_TOKEN" --request DELETE "https://jihulab.com/api/v4/projects/$GL_PROJECT_ID/artifacts"
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

<a id="delete-job-logs"></a>

### 删除作业日志

删除作业日志时，您也会[擦除整个作业](../api/jobs.md#erase-a-job)。

使用 GitLab CLI 的示例：

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

在 `python-gitlab` API 库中，请使用 [`job.erase()`](https://python-gitlab.readthedocs.io/en/stable/gl_objects/pipelines_and_jobs.html#jobs) 而不是 `job.delete_artifacts()`。为避免此 API 调用被阻止，请将脚本设置为在删除作业产物的调用之间短暂休眠：

```python
    for job in jobs_marked_delete_artifacts:
        # delete the artifacts and job log
        print("DEBUG", job)
        #job.delete_artifacts()
        job.erase()
        # Sleep for 1 second
        time.sleep(1)
```

为作业日志创建保留策略的支持已在[议题 374717](https://gitlab.com/gitlab-org/gitlab/-/issues/374717)中提出。

<a id="delete-old-pipelines"></a>

### 删除旧流水线

流水线不会增加总体存储用量，但如有需要，您可以[自动化删除它们](../ci/pipelines/settings.md#automatic-pipeline-cleanup)。

要根据特定日期删除流水线，请指定 `created_at` 键。您可以使用该日期计算当前日期与流水线创建时间之间的差值。如果存在时长大于阈值，则删除该流水线。

> [!note]
> `created_at` 键必须从时间戳转换为 Unix 纪元时间，
> 例如使用 `date -d '2023-08-08T18:59:47.581Z' +%s`。

使用 GitLab CLI 的示例：

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

- 已安装并授权 `jq` 和 GitLab CLI。
- 已导出环境变量 `GL_PROJECT_ID`。默认为极狐GitLab 预定义变量 `CI_PROJECT_ID`。
- 已导出环境变量 `CI_SERVER_HOST`，指向极狐GitLab 实例 URL。

{{< tabs >}}

{{< tab title="Using the API with glab" >}}

完整脚本 `get_cicd_pipelines_compare_age_threshold_example.sh` 位于 [极狐GitLab API with Linux Shell](https://gitlab.com/gitlab-da/use-cases/gitlab-api/gitlab-api-linux-shell) 项目中。

```shell
#!/bin/bash

# Required programs:
# - GitLab CLI (glab): https://docs.gitlab.com/cli/
# - jq: https://jqlang.github.io/jq/

# Required variables:
# - PAT: Project Access Token with API scope and Owner role, or Personal Access Token with API scope
# - GL_PROJECT_ID: ID of the project where pipelines must be cleaned
# - AGE_THRESHOLD (optional): Maximum age in days of pipelines to keep (default: 90)

set -euo pipefail

# Constants
DEFAULT_AGE_THRESHOLD=90
SECONDS_PER_DAY=$((24 * 60 * 60))

# Functions
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
        log_info "Deleted pipeline ID $pipeline_id"
    else
        log_error "Failed to delete pipeline ID $pipeline_id"
    fi
}

# Main script
main() {
    # Authenticate
    if ! glab auth login --hostname "$CI_SERVER_HOST" --token "$PAT"; then
        log_error "Authentication failed"
        exit 1
    fi

    # Set variables
    AGE_THRESHOLD=${AGE_THRESHOLD:-$DEFAULT_AGE_THRESHOLD}
    AGE_THRESHOLD_IN_SECONDS=$((AGE_THRESHOLD * SECONDS_PER_DAY))
    GL_PROJECT_ID=${GL_PROJECT_ID:-$CI_PROJECT_ID}

    # Fetch pipelines
    PIPELINES=$(glab api --method GET "projects/$GL_PROJECT_ID/pipelines")
    if [ -z "$PIPELINES" ]; then
        log_error "Failed to fetch pipelines or no pipelines found"
        exit 1
    fi

    # Process pipelines
    echo "$PIPELINES" | jq -r '.[] | [.id, .created_at] | @tsv' | while IFS=$'\t' read -r id created_at; do
        CREATED_AT_TS=$(date -d "$created_at" +%s)
        NOW=$(date +%s)
        AGE=$((NOW - CREATED_AT_TS))

        if [ "$AGE" -gt "$AGE_THRESHOLD_IN_SECONDS" ]; then
            log_info "Pipeline ID $id created at $created_at is older than threshold $AGE_THRESHOLD days, deleting..."
            delete_pipeline "$GL_PROJECT_ID" "$id"
        else
            log_info "Pipeline ID $id created at $created_at is not older than threshold $AGE_THRESHOLD days. Ignoring."
        fi
    done
}

main
```

{{< /tab >}}

{{< tab title="Using the glab CLI" >}}

完整脚本 `cleanup-old-pipelines.sh` 位于 [极狐GitLab API with Linux Shell](https://gitlab.com/gitlab-da/use-cases/gitlab-api/gitlab-api-linux-shell) 项目中。

```shell
#!/bin/bash

set -euo pipefail

# Required environment variables:
# PAT: Project Access Token with API scope and Owner role, or Personal Access Token with API scope.
# Optional environment variables:
# AGE_THRESHOLD: Maximum age (in days) of pipelines to keep. Default: 90 days.
# REPO: Repository to clean up. If not set, the current repository will be used.
# CI_SERVER_HOST: GitLab server hostname.

# Function to display error message and exit
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Validate required environment variables
[[ -z "${PAT:-}" ]] && error_exit "PAT (Project Access Token or Personal Access Token) is not set."
[[ -z "${CI_SERVER_HOST:-}" ]] && error_exit "CI_SERVER_HOST is not set."

# Set and validate AGE_THRESHOLD
AGE_THRESHOLD=${AGE_THRESHOLD:-90}
[[ ! "$AGE_THRESHOLD" =~ ^[0-9]+$ ]] && error_exit "AGE_THRESHOLD must be a positive integer."

AGE_THRESHOLD_IN_HOURS=$((AGE_THRESHOLD * 24))

echo "Deleting pipelines older than $AGE_THRESHOLD days"

# Authenticate with GitLab
glab auth login --hostname "$CI_SERVER_HOST" --token "$PAT" || error_exit "Authentication failed"

# Delete old pipelines
delete_cmd="glab ci delete --older-than ${AGE_THRESHOLD_IN_HOURS}h"
if [[ -n "${REPO:-}" ]]; then
    delete_cmd+=" --repo $REPO"
fi

$delete_cmd || error_exit "Pipeline deletion failed"

echo "Pipeline cleanup completed."
```

{{< /tab >}}

{{< tab title="Using the API with Python" >}}

您还可以使用 [`python-gitlab` API 库](https://python-gitlab.readthedocs.io/en/stable/gl_objects/pipelines_and_jobs.html#project-pipelines)和 `created_at` 属性来实现类似的算法，比较作业产物的存在时长：

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
                print("Deleting pipeline", pipeline.id)
                pipeline_obj.delete()
```

{{< /tab >}}

{{< /tabs >}}

<a id="list-expiry-settings-for-job-artifacts"></a>

### 列出作业产物的过期设置

要管理产物存储，您可以更新或配置产物的过期时间。产物的过期设置在每个作业配置的 `.gitlab-ci.yml`中配置。

如果有多个项目，并且根据作业定义在 CI/CD 配置中的组织方式，可能很难定位过期设置。您可以使用脚本搜索整个 CI/CD 配置。这包括访问在继承值后解析的对象，例如 `extends` 或 `!reference`。

该脚本检索合并后的 CI/CD 配置文件，并搜索 artifacts 键以：

- 识别没有过期设置的作业。
- 返回已配置产物过期的作业的过期设置。

以下流程描述了脚本如何搜索产物过期设置：

1. 为生成合并后的 CI/CD 配置，脚本遍历所有项目并调用 [`ci_lint()`](https://python-gitlab.readthedocs.io/en/stable/gl_objects/ci_lint.html) 方法。
1. `yaml_load` 函数将合并后的配置加载到 Python 数据结构中，以便进一步分析。
1. 同时具有 `script` 键的字典标识自身为作业定义，其中可能存在 `artifacts` 键。
1. 如果存在，脚本会解析子键 `expire_in`，并存储详细信息以便稍后在 Markdown 表格摘要中打印。

```python
    ci_job_artifacts_expiry = {}

    # Loop over projects, fetch .gitlab-ci.yml, run the linter to get the full translated config, and extract the `artifacts:` setting
    # https://python-gitlab.readthedocs.io/en/stable/gl_objects/ci_lint.html
    for project in projects:
            project_obj = gl.projects.get(project.id)
            project_name = project_obj.name
            project_web_url = project_obj.web_url
            try:
                lint_result = project_obj.ci_lint.get()
                if lint_result.merged_yaml is None:
                    continue

                ci_pipeline = yaml.safe_load(lint_result.merged_yaml)
                #print("Project {p} Config\n{c}\n\n".format(p=project_name, c=json.dumps(ci_pipeline, indent=4)))

                for k in ci_pipeline:
                    v = ci_pipeline[k]
                    # This is a job object with `script` attribute
                    if isinstance(v, dict) and 'script' in v:
                        print(".", end="", flush=True) # Get some feedback that it is still looping
                        artifacts = v['artifacts'] if 'artifacts' in v else {}

                        print("Project {p} job {j} artifacts {a}".format(p=project_name, j=k, a=json.dumps(artifacts, indent=4)))

                        expire_in = None
                        if 'expire_in' in artifacts:
                            expire_in = artifacts['expire_in']

                        store_key = project_web_url + '_' + k
                        ci_job_artifacts_expiry[store_key] = { 'project_web_url': project_web_url,
                                                        'project_name': project_name,
                                                        'job_name': k,
                                                        'artifacts_expiry': expire_in}

            except Exception as e:
                 print(f"Exception searching artifacts on ci_pipelines: {e}".format(e=e))

    if len(ci_job_artifacts_expiry) > 0:
        print("| Project | Job | Artifact expiry |\n|---------|-----|-----------------|") #Start markdown friendly table
        for k, details in ci_job_artifacts_expiry.items():
            if details['job_name'][0] == '.':
                continue # ignore job templates that start with a '.'
            print(f'| [{ details["project_name"] }]({details["project_web_url"]}) | { details["job_name"] } | { details["artifacts_expiry"] if details["artifacts_expiry"] is not None else "❌ N/A" } |')
```

该脚本生成一个 Markdown 摘要表格，包含：

- 项目名称和 URL。
- 作业名称。
- `artifacts:expire_in` 设置，如果没有设置则为 `N/A`。

该脚本不会打印以下作业模板：

- 以 `.` 字符开头。
- 未实例化为生成产物的运行时作业对象。

```shell
export GL_GROUP_ID=56595735

# Install script dependencies
python3 -m pip install 'python-gitlab[yaml]'

python3 get_all_cicd_config_artifacts_expiry.py

| Project | Job | Artifact expiry |
|---------|-----|-----------------|
| [Gen Job Artifacts 4](https://gitlab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-4) | generator | 30 days |
| [Gen Job Artifacts with expiry and included jobs](https://gitlab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-expiry-included-jobs) | included-job10 | 10 days |
| [Gen Job Artifacts with expiry and included jobs](https://gitlab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-expiry-included-jobs) | included-job1 | 1 days |
| [Gen Job Artifacts with expiry and included jobs](https://gitlab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-expiry-included-jobs) | included-job30 | 30 days |
| [Gen Job Artifacts with expiry and included jobs](https://gitlab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-expiry-included-jobs) | generator | 30 days |
| [Gen Job Artifacts 2](https://gitlab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-2) | generator | ❌ N/A |
| [Gen Job Artifacts 1](https://gitlab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-1) | generator | ❌ N/A |
```

`get_all_cicd_config_artifacts_expiry.py` 脚本位于 [极狐GitLab API with Python 项目](https://gitlab.com/gitlab-da/use-cases/gitlab-api/gitlab-api-python/)中。

或者，您可以将[高级搜索](search/advanced_search.md)与 API 请求结合使用。以下示例使用 [scope: blobs](../api/search.md#scope-blobs) 在所有 `*.yml` 文件中搜索字符串 `artifacts`：

```shell
# https://gitlab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-expiry-included-jobs
export GL_PROJECT_ID=48349263

glab api --method GET projects/$GL_PROJECT_ID/search --field "scope=blobs" --field "search=expire_in filename:*.yml"
```

有关清单方法的更多信息，请参见[极狐GitLab 如何帮助缓解 Docker Hub 上开源容器镜像被删除的问题](https://about.gitlab.com/blog/how-gitlab-can-help-mitigate-deletion-open-source-images-docker-hub/)。

<a id="set-default-expiry-for-job-artifacts"></a>

### 设置作业产物的默认过期时间

要设置项目中作业产物的默认过期时间，请在 `.gitlab-ci.yml` 文件中指定 `expire_in` 值：

```yaml
default:
    artifacts:
        expire_in: 1 week
```

<a id="manage-container-registries-storage"></a>

## 管理容器镜像仓库存储

容器镜像仓库可用于[项目](../api/container_registry.md#within-a-project)或[群组](../api/container_registry.md#within-a-group)。您可以分析这两个位置以实施清理策略。

<a id="list-container-registries"></a>

### 列出容器镜像仓库

要列出项目中的容器镜像仓库：

{{< tabs >}}

{{< tab title="curl" >}}

```shell
export GL_PROJECT_ID=48057080

curl --silent --header "Authorization: Bearer $GITLAB_TOKEN" "https://jihulab.com/api/v4/projects/$GL_PROJECT_ID/registry/repositories" | jq --compact-output '.[]' | jq --compact-output '.id,.location' | jq
4435617
"registry.gitlab.com/gitlab-da/playground/container-package-gen-group/docker-alpine-generator"

curl --silent --header "Authorization: Bearer $GITLAB_TOKEN" "https://jihulab.com/api/v4/registry/repositories/4435617?size=true" | jq --compact-output '.id,.location,.size'
4435617
"registry.gitlab.com/gitlab-da/playground/container-package-gen-group/docker-alpine-generator"
3401613
```

{{< /tab >}}

{{< tab title="GitLab CLI" >}}

```shell
export GL_PROJECT_ID=48057080

glab api --method GET projects/$GL_PROJECT_ID/registry/repositories | jq --compact-output '.[]' | jq --compact-output '.id,.location'
4435617
"registry.gitlab.com/gitlab-da/playground/container-package-gen-group/docker-alpine-generator"

glab api --method GET registry/repositories/4435617 --field='size=true' | jq --compact-output '.id,.location,.size'
4435617
"registry.gitlab.com/gitlab-da/playground/container-package-gen-group/docker-alpine-generator"
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

<a id="delete-container-images-in-bulk"></a>

### 批量删除容器镜像

当您[批量删除容器镜像标签](../api/container_registry.md#delete-registry-repository-tags-in-bulk)时，您可以配置：

- 要保留（`name_regex_keep`）或删除（`name_regex_delete`）的标签名称和镜像的匹配正则表达式
- 要保留的匹配标签名称的镜像标签数量（`keep_n`）
- 镜像标签可被删除之前的天数（`older_than`）

> [!warning]
> 在 JihuLab.com 上，由于容器镜像仓库的规模，此 API 删除的标签数量是有限的。
> 如果您的容器镜像仓库有大量标签要删除，只会删除其中一部分。您可能需要
> 多次调用 API。要安排标签自动删除，请改用[清理策略](#create-a-cleanup-policy-for-containers)。

以下示例使用 [`python-gitlab` API 库](https://python-gitlab.readthedocs.io/en/stable/gl_objects/repository_tags.html)获取标签列表，并使用筛选参数调用 `delete_in_bulk()` 方法。

```python
        repositories = project.repositories.list(iterator=True, size=True)
        if len(repositories) > 0:
            repository = repositories.pop()
            tags = repository.tags.list()

            # Cleanup: Keep only the latest tag
            repository.tags.delete_in_bulk(keep_n=1)
            # Cleanup: Delete all tags older than 1 month
            repository.tags.delete_in_bulk(older_than="1m")
            # Cleanup: Delete all tags matching the regex `v.*`, and keep the latest 2 tags
            repository.tags.delete_in_bulk(name_regex_delete="v.+", keep_n=2)
```

<a id="create-a-cleanup-policy-for-containers"></a>

### 为容器创建清理策略

使用项目 REST API 端点为容器[创建清理策略](packages/container_registry/reduce_container_registry_storage.md#use-the-cleanup-policy-api)。设置清理策略后，所有符合您规格的容器镜像都会自动删除。您不需要额外的 API 自动化脚本。

要将属性作为正文参数发送：

- 使用 `--input -` 参数从标准输入读取。
- 设置 `Content-Type` 请求头。

以下示例使用 GitLab CLI 创建清理策略：

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

<a id="optimize-container-images"></a>

### 优化容器镜像

您可以优化容器镜像，以减小镜像大小和容器镜像仓库的总体存储消耗。更多信息，请参见[流水线效率文档](../ci/pipelines/pipeline_efficiency.md#optimize-docker-images)。

<a id="manage-package-registry-storage"></a>

## 管理软件包仓库存储

软件包仓库可用于[项目](../api/packages.md#for-a-project)或[群组](../api/packages.md#for-a-group)。

<a id="list-packages-and-files"></a>

### 列出软件包和文件

以下示例显示使用 GitLab CLI 从指定项目 ID 获取软件包。结果集是一个字典项数组，可以使用 `jq` 命令链进行筛选。

```shell
# https://gitlab.com/gitlab-da/playground/container-package-gen-group/generic-package-generator
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

在[删除旧流水线](#delete-old-pipelines)部分创建了类似的自动化 shell 脚本。

以下脚本示例使用 `python-gitlab` 库在循环中获取所有软件包，并遍历其软件包文件以打印 `file_name` 和 `size` 属性。

```python
        packages = project.packages.list(order_by="created_at")

        for package in packages:

            package_files = package.package_files.list()
            for package_file in package_files:
                print("Package name: {p} File name: {f} Size {s}".format(
                    p=package.name, f=package_file.file_name, s=render_size_mb(package_file.size)))
```

<a id="delete-packages"></a>

### 删除软件包

[删除软件包中的文件](../api/packages.md#delete-a-package-file)可能会损坏软件包。在执行自动化清理维护时，您应删除整个软件包。

要删除软件包，请使用 GitLab CLI 将 `--method` 参数改为 `DELETE`：

```shell
glab api --method DELETE projects/$GL_PROJECT_ID/packages/16669383
```

要计算软件包大小并将其与大小阈值进行比较，您可以使用 `python-gitlab` 库扩展[列出软件包和文件](#list-packages-and-files)部分中描述的代码。

以下代码示例还会计算软件包存在时长，并在条件匹配时删除该软件包：

```python
        packages = project.packages.list(order_by="created_at")
        for package in packages:
            package_size = 0.0

            package_files = package.package_files.list()
            for package_file in package_files:
                print("Package name: {p} File name: {f} Size {s}".format(
                    p=package.name, f=package_file.file_name, s=render_size_mb(package_file.size)))

                package_size =+ package_file.size

            print("Package size: {s}\n\n".format(s=render_size_mb(package_size)))

            threshold_size = 10 * 1024 * 1024

            if (package_size > float(threshold_size)):
                print("Package size {s} > threshold {t}, deleting package.".format(
                    s=render_size_mb(package_size), t=render_size_mb(threshold_size)))
                package.delete()

            threshold_age = 90 * 24 * 60 * 60
            package_age = created_at = calculate_age(package.created_at)

            if (float(package_age > float(threshold_age))):
                print("Package age {a} > threshold {t}, deleting package.".format(
                    a=render_age_time(package_age), t=render_age_time(threshold_age)))
                package.delete()
```

该代码生成以下输出，您可以用它进行进一步分析：

```shell
Package name: generator File name: nighly.tar.gz Size 10.0017
Package size: 10.0017
Package size 10.0017 > threshold 10.0000, deleting package.

Package name: generator File name: 1-nightly.tar.gz Size 1.0004
Package size: 1.0004

Package name: generator File name: 10-nightly.tar.gz Size 10.0018
Package name: generator File name: 20-nightly.tar.gz Size 20.0033
Package size: 20.0033
Package size 20.0033 > threshold 10.0000, deleting package.
```

<a id="dependency-proxy"></a>

### 依赖代理

查看[清理策略](packages/dependency_proxy/reduce_dependency_proxy_storage.md#cleanup-policies)以及如何[使用 API 清除缓存](packages/dependency_proxy/reduce_dependency_proxy_storage.md#use-the-api-to-clear-the-cache)

<a id="improve-output-readability"></a>

## 提高输出可读性

您可能需要将时间戳秒数转换为时长格式，或以更具代表性的格式打印原始字节。您可以使用以下辅助函数转换值以提高可读性：

```shell
# Current Unix timestamp
date +%s

# Convert `created_at` date time with timezone to Unix timestamp
date -d '2023-08-08T18:59:47.581Z' +%s
```

使用 `python-gitlab` API 库的 Python 示例：

```python
def render_size_mb(v):
    return "%.4f" % (v / 1024 / 1024)

def render_age_time(v):
    return str(datetime.timedelta(seconds = v))

# Convert `created_at` date time with timezone to Unix timestamp
def calculate_age(created_at_datetime):
    created_at_ts = datetime.datetime.strptime(created_at_datetime, '%Y-%m-%dT%H:%M:%S.%fZ')
    now = datetime.datetime.now()
    return (now - created_at_ts).total_seconds()
```

<a id="testing-for-storage-management-automation"></a>

## 测试存储管理自动化

要测试存储管理自动化，您可能需要生成测试数据，或填充存储以验证分析和删除是否按预期工作。以下部分提供了在短时间内测试和生成存储 blob 的工具和技巧。

<a id="generate-job-artifacts"></a>

### 生成作业产物

创建一个测试项目，使用 CI/CD 作业矩阵构建生成伪造的产物 blob。添加一个 CI/CD 流水线以每天生成产物

1. 创建一个新项目。
1. 将以下代码片段添加到 `.gitlab-ci.yml`中，以包含作业产物生成器配置。

   ```yaml
   include:
       - remote: https://gitlab.com/gitlab-da/use-cases/efficiency/job-artifact-generator/-/raw/main/.gitlab-ci.yml
   ```

1. [配置流水线计划](../ci/pipelines/schedules.md#create-a-pipeline-schedule)。
1. [手动触发流水线](../ci/pipelines/schedules.md#run-manually)。

或者，在 `MB_COUNT` 变量中将每天生成的 86 MB 减少为不同的值。

```yaml
include:
    - remote: https://gitlab.com/gitlab-da/use-cases/efficiency/job-artifact-generator/-/raw/main/.gitlab-ci.yml

generator:
    parallel:
        matrix:
            - MB_COUNT: [1, 5, 10, 20, 50]

```

更多信息，请参见[作业产物生成器 README](https://gitlab.com/gitlab-da/use-cases/efficiency/job-artifact-generator)，以及[示例群组](https://gitlab.com/gitlab-da/playground/artifact-gen-group)。

<a id="generate-job-artifacts-with-expiry"></a>

### 生成带过期时间的作业产物

项目 CI/CD 配置在以下位置指定作业定义：

- 主 `.gitlab-ci.yml` 配置文件。
- `artifacts:expire_in` 设置。
- 项目文件和模板。

要测试分析脚本，[`gen-job-artifacts-expiry-included-jobs`](https://gitlab.com/gitlab-da/playground/artifact-gen-group/gen-job-artifacts-expiry-included-jobs) 项目提供了一个示例配置。

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

<a id="generate-container-images"></a>

### 生成容器镜像

示例群组 [`container-package-gen-group`](https://gitlab.com/gitlab-da/playground/container-package-gen-group) 提供了以下项目：

- 在 Dockerfile 中使用基础镜像构建新镜像。
- 包含 `Docker.gitlab-ci.yml` 模板以在 JihuLab.com 上构建镜像。
- 配置流水线计划以每天生成新镜像。

可供 fork 的示例项目：

- [`docker-alpine-generator`](https://gitlab.com/gitlab-da/playground/container-package-gen-group/docker-alpine-generator)
- [`docker-python-generator`](https://gitlab.com/gitlab-da/playground/container-package-gen-group/docker-python-generator)

<a id="generate-generic-packages"></a>

### 生成通用软件包

示例项目 [`generic-package-generator`](https://gitlab.com/gitlab-da/playground/container-package-gen-group/generic-package-generator) 提供了以下项目：

- 生成随机文本 blob，并使用当前 Unix 时间戳作为发布版本创建 tarball。
- 将 tarball 上传到通用软件包仓库，使用 Unix 时间戳作为发布版本。

要生成通用软件包，您可以使用以下独立的 `.gitlab-ci.yml` 配置：

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

<a id="generate-storage-usage-with-forks"></a>

### 使用 forks 生成存储用量

使用以下项目测试[forks 的成本因子](storage_usage_quotas.md#view-project-fork-storage-usage)带来的存储用量：

- 将 [`gitlab-org/gitlab`](https://jihulab.com/gitlab-cn/gitlab) fork 到新的命名空间或群组（包括 LFS、Git 代码仓库）。
- 将 [`gitlab-com/www-gitlab-com`](https://gitlab.com/gitlab-com/www-gitlab-com) fork 到新的命名空间或群组。

<a id="community-resources"></a>

## 社区资源

以下资源不受官方支持。在运行可能无法恢复的破坏性清理命令之前，请务必测试脚本和教程。

- 论坛主题：[存储管理自动化资源](https://forum.gitlab.com/t/storage-management-automation-resources/91184)
- 脚本：[GitLab Storage Analyzer](https://gitlab.com/gitlab-da/use-cases/gitlab-api/gitlab-storage-analyzer)，由 [GitLab Developer Evangelism 团队](https://gitlab.com/gitlab-da/)维护的非官方项目。您可以在此处的文档操作指南中找到类似的代码示例。
