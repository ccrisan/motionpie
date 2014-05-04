#############################################################
#
# rpi-firmware
#
#############################################################

RPI_FIRMWARE_VERSION = c888199
RPI_FIRMWARE_SITE = http://github.com/raspberrypi/firmware/tarball/$(RPI_FIRMWARE_VERSION)
RPI_FIRMWARE_LICENSE = BSD-3c
RPI_FIRMWARE_LICENSE_FILES = boot/LICENCE.broadcom

define RPI_FIRMWARE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/boot/bootcode.bin $(BINARIES_DIR)/boot/bootcode.bin
	$(INSTALL) -D -m 0644 $(@D)/boot/start*.elf $(BINARIES_DIR)/boot/
	$(INSTALL) -D -m 0644 $(@D)/boot/fixup*.dat $(BINARIES_DIR)/boot/
	$(INSTALL) -D -m 0644 boot/rpi-firmware/config.txt $(BINARIES_DIR)/boot/config.txt
endef

$(eval $(generic-package))
