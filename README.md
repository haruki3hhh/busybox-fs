# busybox-fs
rootfs
```
root@jupiter:/busybox-fs/rootfs# l
bin/  dev/  etc/  linuxrc@  mnt/  proc/  root/  sbin/  sys/  tmp/  usr/  var/
```
pack:

```sh
find . | cpio -o -H newc > ../rootfs.img
```

unpack:

```sh
cpio -idm < ../rootfs.img
```
