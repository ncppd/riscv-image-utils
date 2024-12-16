#!/bin/bash

set -e
set -x

echo "Make sure that you have run \"make\" first"
source vars

overlay=$root_dir/rootfs-overlay
output=$root_dir/working/output

pushd $output
mkdir -p mountdir
sudo mount rootfs.ext2 mountdir
sudo cp -r $overlay/* $output/mountdir/
sudo umount $output/mountdir/
popd

