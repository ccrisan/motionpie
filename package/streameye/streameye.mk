################################################################################
#
# streameye
#
################################################################################

STREAMEYE_VERSION = d7be2253af460fbfd2a2cc11daea1321404f022e
STREAMEYE_SITE = $(call github,ccrisan,streameye,$(STREAMEYE_VERSION))
STREAMEYE_LICENSE = GPLv3

define STREAMEYE_BUILD_CMDS
    make CC="$(TARGET_CC)" -C "$(@D)"
endef

define STREAMEYE_INSTALL_TARGET_CMDS
    cp $(@D)/streameye $(TARGET_DIR)/usr/bin/
    cp $(@D)/extras/raspimjpeg.py $(TARGET_DIR)/usr/bin/
endef

$(eval $(generic-package))

