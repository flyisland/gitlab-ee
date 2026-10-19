---
title: 为流水线输入选择多个值
stage: verify
level: secondary
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
documentation_link: "../../../ci/inputs/#array-inputs-with-options"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/566155"
categories: [ Pipeline Composition ]
weight: 70
---

此前，在界面中选择输入选项时，您只能选择单个值，
这限制了具有更复杂选项的流水线的灵活性。

现在，当您从界面运行带有输入的流水线时，您可以从下拉列表中选择多个值，
所选值会合并为一个数组，例如 `["option1","option2"]`。
这使得在单次流水线运行中，可以轻松地在多个实例上重启服务、构建多个 Docker 镜像、
使用多种标签组合运行测试，或对多个目标执行任何操作。
