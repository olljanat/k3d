#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

#########################################################################################################################################
# DISCLAIMER																																																														#
# Copied from https://github.com/moby/moby/blob/ed89041433a031cafc0a0f19cfe573c31688d377/hack/dind#L28-L37															#
# Permission granted by Akihiro Suda <akihiro.suda.cz@hco.ntt.co.jp> (https://github.com/rancher/k3d/issues/493#issuecomment-827405962)	#
# Moby License Apache 2.0: https://github.com/moby/moby/blob/ed89041433a031cafc0a0f19cfe573c31688d377/LICENSE														#
#########################################################################################################################################
if [ -f /sys/fs/cgroup/cgroup.controllers ]; then
	# move the processes from the root group to the /init group,
  # otherwise writing subtree_control fails with EBUSY.
  mkdir -p /sys/fs/cgroup/init
  busybox xargs -rn1 < /sys/fs/cgroup/cgroup.procs > /sys/fs/cgroup/init/cgroup.procs || :
  # enable controllers
  sed -e 's/ / +/g' -e 's/^/+/' <"/sys/fs/cgroup/cgroup.controllers" >"/sys/fs/cgroup/cgroup.subtree_control"
fi

# TODO: Move to better place
# Only run when longhorn support is enabled
if [ ! -d "/var/lib/longhorn" ]; then
  mkdir /var/lib/longhorn
fi
mount --bind /var/lib/longhorn /var/lib/longhorn
mount --make-shared /var/lib/longhorn

mkdir -p /host/proc
mount -t proc none /host/proc
mount --make-shared /
mount --bind /var/lib/kubelet/pods /var/lib/kubelet/pods
mount --make-shared /var/lib/kubelet/pods

exec /bin/k3s "$@"