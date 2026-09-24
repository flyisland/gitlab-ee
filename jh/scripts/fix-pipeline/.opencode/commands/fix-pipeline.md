---
name: fix
description: 执行完整的当前 pipeline 修复流程
---

请加载 **pipeline-fix** skill，并严格按该 skill 的完整流程修复当前 CI pipeline（`CI_PIPELINE_ID`）。

细则（验证矩阵、rubocop 命令、MR 规则等）以 `skills/pipeline-fix/SKILL.md` 为准；本命令不重复步骤。
