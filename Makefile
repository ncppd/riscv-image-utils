OPENSBI_VERSION ?= 1.3.1
LINUX_VERSION ?= 6.9
BUILDROOT_REPO ?= https://git.buildroot.net/buildroot
LINUX_REPO ?= https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
OPENSBI_REPO ?= https://github.com/riscv-software-src/opensbi.git

CURRENT_DIR := $(shell pwd)
WORKING_DIR := $(CURRENT_DIR)/working
OPENSBI_DIR := $(WORKING_DIR)/opensbi
LINUX_DIR := $(WORKING_DIR)/linux
BUILDROOT_DIR := $(WORKING_DIR)/buildroot
OUTPUT_DIR := $(WORKING_DIR)/output
MOUNT_DIR := $(OUTPUT_DIR)/mountpoint

ARCH := riscv
CROSS_COMPILE ?= riscv64-linux-gnu-
BUILDROOT_CONFIG ?= qemu_riscv64_virt_defconfig

SETUP_DONE := .setup_done

.PHONY: all clean clean-opensbi clean-linux clean-buildroot clean-dist linux-menuconfig linux-build

all: deps opensbi buildroot linux 

$(OPENSBI_DIR):
	git clone --branch v$(OPENSBI_VERSION) $(OPENSBI_REPO) $(OPENSBI_DIR)

$(BUILDROOT_DIR):
	git clone $(BUILDROOT_REPO) $(BUILDROOT_DIR)

$(LINUX_DIR):
	git clone --branch v$(LINUX_VERSION) $(LINUX_REPO) $(LINUX_DIR)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

opensbi: $(OPENSBI_DIR)
	$(MAKE) -C $(OPENSBI_DIR) PLATFORM=generic CROSS_COMPILE=$(CROSS_COMPILE)
	cp $(OPENSBI_DIR)/build/platform/generic/firmware/fw_jump.elf $(OUTPUT_DIR)

buildroot: $(BUILDROOT_DIR)
	$(MAKE) -C $(BUILDROOT_DIR) $(BUILDROOT_CONFIG)
	$(MAKE) -C $(BUILDROOT_DIR) 
	cp $(BUILDROOT_DIR)/output/images/rootfs.ext2 $(OUTPUT_DIR)


linux-menuconfig: $(LINUX_DIR)
	$(MAKE) -C $(LINUX_DIR) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) menuconfig

linux: $(LINUX_DIR)
	if [ ! -f $(LINUX_DIR)/.config ]; then $(MAKE) -C $(LINUX_DIR) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) defconfig; fi
	$(MAKE) -C $(LINUX_DIR) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)
	cp $(LINUX_DIR)/vmlinux $(OUTPUT_DIR)/vmlinux
	cp $(LINUX_DIR)/arch/riscv/boot/Image $(OUTPUT_DIR)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

clean-opensbi:
	if [ -d $(OPENSBI_DIR) ]; then $(MAKE) -C $(OPENSBI_DIR) clean; fi

clean-linux:
	if [ -d $(LINUX_DIR) ]; then $(MAKE) -C $(LINUX_DIR) clean; fi

clean-buildroot:
	if [ -d $(BUILDROOT_DIR) ]; then $(MAKE) -C $(BUILDROOT_DIR) clean; fi

dist-clean: clean-opensbi clean-linux clean-buildroot

clean:
	@echo "Use 'dist-clean' to clean all builds  and 'veryclean' to reset everything."
	rm -rvf $(OUTPUT_DIR)/*

veryclean:
	rm -rf $(WORKING_DIR) vars .setup-complete


deps: $(SETUP_DONE)

$(SETUP_DONE):
	mkdir -p $(WORKING_DIR)
	mkdir -p $(OUTPUT_DIR)
	mkdir -p $(MOUNT_DIR)
	echo "root_dir=$(CURRENT_DIR)" > vars
	touch $(SETUP_DONE)
