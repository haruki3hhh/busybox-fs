#!/bin/bash
PWD=$(pwd)
IMAGE_DIR="${IMAGE_DIR:-$PWD}"
KERNEL_DIR="${KERNEL_DIR:-$PWD}"
PORT=$(python3 -c "import socket; s=socket.socket(socket.AF_INET, socket.SOCK_STREAM); s.bind(('', 0)); print(s.getsockname()[1]); s.close()")
if [ ! -d "$IMAGE_DIR/chroot" ]; then
    mkdir -p $IMAGE_DIR/chroot
fi
if [ ! -f "$IMAGE_DIR/rootfs.img" ]; then
    cp ../../../skyset_kernel_image/rootfs.img $IMAGE_DIR
fi
if [ ! -f "$IMAGE_DIR/rootfs-poc.img" ]; then
    pushd $IMAGE_DIR/chroot
    cpio -idm < $IMAGE_DIR/rootfs.img
    cp $IMAGE_DIR/../@POC@ $IMAGE_DIR/chroot/root/
    find .| cpio -o --format=newc > $IMAGE_DIR/rootfs-poc.img
    popd
fi
echo "qemu instance boot on port: $PORT"
echo "KERNEL_DIR: $KERNEL_DIR/arch/x86/boot/bzImage"
echo "IMAGE_DIR: $IMAGE_DIR/rootfs-poc.img"
qemu-system-x86_64 -kernel $KERNEL_DIR/arch/x86/boot/bzImage \
    -initrd $IMAGE_DIR/rootfs.img \
    -append "console=ttyS0 root=/dev/ram rdinit=/sbin/init earlyprintk=serial oops=panic panic_on_warn=1 nokaslr nosmap nosmep" \
    -net nic \
    -net user,hostfwd=tcp::$PORT-:22 \
    -nographic \
    -m 2G \
    -smp cores=2,threads=2 \
    -enable-kvm \
    -cpu host
