#############################################################
#
# rpi-firmware
#
#############################################################

RPI_FIRMWARE_VERSION = 5711461a
RPI_FIRMWARE_SITE = $(call github,raspberrypi,firmware,$(RPI_FIRMWARE_VERSION))
RPI_FIRMWARE_LICENSE = BSD-3c
RPI_FIRMWARE_LICENSE_FILES = boot/LICENCE.broadcom

define RPI_FIRMWARE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/boot/bootcode.bin $(BINARIES_DIR)/boot/bootcode.bin
	$(INSTALL) -D -m 0644 $(@D)/boot/start$(BR2_TARGET_RPI_FIRMWARE_BOOT).elf $(BINARIES_DIR)/boot/start.elf
	$(INSTALL) -D -m 0644 $(@D)/boot/fixup$(BR2_TARGET_RPI_FIRMWARE_BOOT).dat $(BINARIES_DIR)/boot/fixup.dat
	$(INSTALL) -D -m 0644 boot/rpi-firmware/config.txt $(BINARIES_DIR)/boot/config.txt
endef

$(eval $(generic-package))
