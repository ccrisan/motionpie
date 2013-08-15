#############################################################
#
# rpi
#
#############################################################

RPI_VERSION = master
RPI_SITE = git://github.com/raspberrypi/firmware.git
RPI_LICENSE = BSD-3c
RPI_LICENSE_FILE = boot/LICENCE.broadcom

define RPI_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/boot/bootcode.bin $(BINARIES_DIR)/boot/bootcode.bin
	$(INSTALL) -D -m 0644 $(@D)/boot/start*.elf $(BINARIES_DIR)/boot/
	$(INSTALL) -D -m 0644 $(@D)/boot/fixup*.dat $(BINARIES_DIR)/boot/
	$(INSTALL) -D -m 0644 boot/rpi/config.txt $(BINARIES_DIR)/boot/config.txt
endef

$(eval $(generic-package))
