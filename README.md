## Gem5 & QEMU RISC-V image utilities

This repo includes scripts in order to make it easier to setup and run QEMU and Gem5 simulations.

#### Projects included:
* Linux kernel
* Opensbi
* Buildroot

Running `make` setups everything you need for a simulation, you can find the required binaries/images/rootfs in the `working/output` directory. Run `scripts/apply_overlay.sh` in order to setup Gem5 specific stuff such as the `m5` binary and init scripts. Finally, you can test the processed binaries/images with QEMU by running `./scripts/boot_qemu.sh`.