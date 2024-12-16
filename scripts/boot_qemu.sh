#!/bin/bash

source vars

output_dir=$root_dir/working/output

extra_args=""

exec qemu-system-riscv64 -M virt -cpu rv64,svnapot=true -m 8G \
-bios $output_dir/fw_jump.elf \
-kernel $output_dir/Image -append "console=ttyS0 root=/dev/vda rw $extra_args" \
-drive file=$output_dir/rootfs.ext2,format=raw \
-netdev user,id=net0 -device virtio-net-device,netdev=net0 \
-nographic
