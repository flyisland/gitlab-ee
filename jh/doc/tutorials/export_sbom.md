---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn how to generate and export a Software Bill of Materials (SBOM) in CycloneDX format for your project dependencies and save it as a CI/CD artifact.
title: '教程：以 SBOM 格式导出依赖项列表'
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

依赖项扫描输出可以导出为 CycloneDX JSON 格式。

本教程将向你展示如何为流水线生成 CycloneDX JSON SBOM，然后将其作为 CI 作业产物上传。

<a id="before-you-begin"></a>

## 准备工作

设置依赖项扫描。有关详细说明，请参阅[依赖项扫描教程](dependency_scanning.md)。

<a id="create-configuration-files"></a>

## 创建配置文件

1. 创建一个具有 `api` 范围和 `开发者` 角色的个人访问令牌。
1. 将令牌值添加为名为 `PRIVATE_TOKEN` 的 CI/CD 变量。
1. 创建一个包含以下代码的[代码片段](../api/snippets.md)。

   文件名：`export.sh`

   ```shell
   #! /bin/sh

   function create_export {
     curl --silent \
     --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" \
     -X 'POST' --data "export_type=sbom" \
     "https://jihulab.com/api/v4/pipelines/$CI_PIPELINE_ID/dependency_list_exports" \
     | jq '.id'
   }

   function check_status {
     curl --silent \
       --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" \
       --write-out "%{http_code}" --output /dev/null \
       https://jihulab.com/api/v4/dependency_list_exports/$1
   }

   function download {
     curl --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" \
       --output "gl-sbom-merged-$CI_PIPELINE_ID.cdx.json" \
       "https://jihulab.com/api/v4/dependency_list_exports/$1/download"
   }

   function export_sbom {
     local ID=$(create_export)

     for run in $(seq 0 3); do
       local STATUS=$(check_status $ID)
       # 生成 JSON 时状态码为 200。
       # 生成 JSON 的作业正在运行时状态码为 202。
       if [ $STATUS -eq "200" ]; then
         download $ID

         exit 0
       elif [ $STATUS -ne "202" ]; then
         exit 1
       fi

       echo "等待 JSON 生成"
       sleep 5
     done

     exit 1
   }

   export_sbom
   ```

   此 `export.sh` 脚本按以下步骤工作：

   1. 为当前流水线创建 CycloneDX SBOM 导出。
   1. 检查该导出的状态，并在就绪时停止。
   1. 下载 CycloneDX SBOM 文件。

1. 使用以下代码更新 `.gitlab-ci.yml`。

   ```yaml
   export-merged-sbom:
     image: alpine
     before_script:
       - apk add --update jq curl
     stage: .post
     script:
       - |
         curl --header "Authorization: Bearer $PRIVATE_TOKEN" --output export.sh --url "https://jihulab.com/api/v4/snippets/<SNIPPET_ID>/raw"
       - /bin/sh export.sh
     artifacts:
       paths:
         - "gl-sbom-merged-*.cdx.json"

   ```

1. 转到 **构建** > **流水线**，确认最新流水线已成功完成。

在作业产物中，应存在 `gl-sbom-merged-<pipeline_id>.cdx.json` 文件。