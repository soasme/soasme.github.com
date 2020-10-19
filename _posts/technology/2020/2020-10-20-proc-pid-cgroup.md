---
title: /proc/[pid]/cgroup
category: technology
tags: container
---

## `/proc/[pid]/cgroup`

If you want to know what cgroups a given process belongs to, check the content of `/proc/[pid]/cgroup`.

File `/proc/[pid]/cgroup` has zero or more lines. Each line has such a form:

    hierarchy_id:controller_list:cgroup_path

Program `proc_cgroup_file.py` shows how to obtain such information from `/proc/[pid]/cgroup`.

```python
from pathlib import Path
from collections import namedtuple

ProcCgroupEntry = namedtuple('ProcCgroupEntry', [
    'hierarchy_id',
    'controller_list',
    'cgroup_path',
])

def parse_proc_cgroup_file(pid):
    path = Path('/proc') / str(pid) / 'cgroup'
    with open(path, 'r') as f:
        for line in f.readlines():
            hierarchy_id, controller_list, cgroup_path = line.strip().split(':')

            yield ProcCgroupEntry(
                int(hierarchy_id),
                controller_list.split(',') if controller_list else [],
                cgroup_path,
            )

if __name__ == '__main__':
    import sys, json
    pid = sys.argv[1]
    print(json.dumps([
        entry._asdict()
        for entry in parse_proc_cgroup_file(pid)
    ]))
```

Line 0-2, import modules.

Line 3-7, the namedtuple `ProcCgroupEntry` holds the information of each line in the file `/proc/[pid]/cgroup`. Each line is comprised of three fields: `hierarchy_id`, `controller_list` and `cgroup_path`.

Line 10, for a given pid, the path to the cgroup proc file is always `/proc/[pid]/cgroup`.

Line 11-12, to obtain the information from the file `/proc/[pid]/cgroup`, open it and read line by line.

Line 13-19, each line in the file `/proc/[pid]/cgroup` is a string of three fields split by commas. After parsing three fields, construct a `ProcCgroupEntry` object.

Line 21-27, the script can be run with a command-line argument. The output is a list of `ProcCgroupEntry` objects in JSON format.

The below example demonstrates when you start a container, the process in the container has a corresponding file `/proc/[pid]/proc` on the host describing the cgroup setup.

    # Run the command in one shell.
    # It creates a container that has a `bash` process running inside.
    $ podman run --rm sleep 86400

    # Run the commands in another shell.
    # Find the bash process PID and output the cgroup file.
    $ ps -ef|grep 'sleep 86400'
    cloud_u+   51948   51824  0 08:23 pts/2    00:00:00 podman run -it --rm bash -c sleep 86400
    cloud_u+   51979   51969  0 08:23 pts/0    00:00:00 sleep 86400
    $ cat /proc/51979/cgroup
    12:freezer:/
    11:perf_event:/
    10:pids:/user.slice/user-1001.slice/session-5.scope
    9:cpuset:/
    8:net_cls,net_prio:/
    7:hugetlb:/
    6:blkio:/system.slice/sshd.service
    5:devices:/user.slice
    4:rdma:/
    3:cpu,cpuacct:/
    2:memory:/user.slice/user-1001.slice/session-5.scope
    1:name=systemd:/user.slice/user-1001.slice/user@1001.service/user.slice/podman-51948.scope/2b32e61640d984fcd7795f83e615d4e495ac382b62e0cd47eb32e70fb0d69248

Execute the script:

```bash
$ python -mpyoci.cgroup.proc_cgroup_file 51979
[{"hierarchy_id": 12, "controller_list": ["freezer"], "cgroup_path": "/"}, {"hierarchy_id": 11, "controller_list": ["perf_event"], "cgroup_path": "/"}, {"hierarchy_id": 10, "controller_list": ["pids"], "cgroup_path": "/user.slice/user-1001.slice/session-5.scope"}, {"hierarchy_id": 9, "controller_list": ["cpuset"], "cgroup_path": "/"}, {"hierarchy_id": 8, "controller_list": ["net_cls", "net_prio"], "cgroup_path": "/"}, {"hierarchy_id": 7, "controller_list": ["hugetlb"], "cgroup_path": "/"}, {"hierarchy_id": 6, "controller_list": ["blkio"], "cgroup_path": "/system.slice/sshd.service"}, {"hierarchy_id": 5, "controller_list": ["devices"], "cgroup_path": "/user.slice"}, {"hierarchy_id": 4, "controller_list": ["rdma"], "cgroup_path": "/"}, {"hierarchy_id": 3, "controller_list": ["cpu", "cpuacct"], "cgroup_path": "/"}, {"hierarchy_id": 2, "controller_list": ["memory"], "cgroup_path": "/user.slice/user-1001.slice/session-5.scope"}, {"hierarchy_id": 1, "controller_list": ["name=systemd"], "cgroup_path": "/user.slice/user-1001.slice/user@1001.service/user.slice/podman-51948.scope/2b32e61640d984fcd7795f83e615d4e495ac382b62e0cd47eb32e70fb0d69248"}]
```

There are some caveats.

Cgroups can be created in various ways. They can be even totally irrelevant to containers. The cgroups in the given example were created by Podman and systemd.

For cgroups v2, `hiearchy_id` is always 0, and `controller_list` is always empty, as these two fields are no longer needed.

The field `cgroup_path` is the pathname relative to the mount point of the hierarchy. For example, for the controller `pids` and cgroup path `/user.slice/user-1001.slice/session-5.scope`, we have a mount point in the cgroupfs.

```
$ ls /sys/fs/cgroup/user.slice/user-1001.slice/session-5.scope
```
