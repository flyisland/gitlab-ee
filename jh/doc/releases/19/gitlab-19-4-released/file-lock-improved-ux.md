---
title: 查看谁锁定了文件或目录
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: create
documentation_link: "../../../user/project/file_lock"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/13019
categories: [ Source Code Management ]
level: secondary
weight: 50
---

当文件被锁定时，您现在无需离开 blob 查看器，即可看到是谁锁定了它以及您有哪些选项。

此前，只会显示一个**已锁定**标记，无法判断是谁锁定了该文件，也无法判断您是否可以自行解锁。现在，标记旁边的弹出框会显示是谁锁定了它。如果您有权限解锁该文件，弹出框中会包含解锁操作。如果您没有权限，弹出框会说明原因。对于已锁定的目录，弹出框会直接链接到阻止您更改的那个具体文件。
