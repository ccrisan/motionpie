#############################################################
#
# rpi-userland
#
#############################################################
RPI_USERLAND_VERSION = rpi-buildroot
RPI_USERLAND_SITE = git://github.com/gamaral/rpi-userland.git
RPI_USERLAND_INSTALL_STAGING = YES
RPI_USERLAND_INSTALL_TARGET = YES

define RPI_USERLAND_POST_STAGING_CLEANUP
    rm -f  $(STAGING_DIR)/etc/init.d/vcfiled
    rm -Rf $(STAGING_DIR)/opt/vc/{bin,sbin}
    rmdir -p $(STAGING_DIR)/etc/init.d || true
endef

define RPI_USERLAND_POST_TARGET_CLEANUP
    rm -Rf $(TARGET_DIR)/opt/vc/include
    rm -Rf $(TARGET_DIR)/opt/vc/share
    rm -Rf $(TARGET_DIR)/opt/vc/src
    rm -f  $(TARGET_DIR)/etc/init.d/vcfiled
    rm -f  $(TARGET_DIR)/opt/vc/lib/*.a
    rmdir -p $(TARGET_DIR_DIR)/etc/init.d || true
    grep -q "/opt/vc/lib" $(TARGET_DIR)/etc/ld.so.conf || \
        echo "/opt/vc/lib" >> $(TARGET_DIR)/etc/ld.so.conf
endef

RPI_USERLAND_POST_INSTALL_STAGING_HOOKS += RPI_USERLAND_POST_STAGING_CLEANUP
RPI_USERLAND_POST_INSTALL_TARGET_HOOKS  += RPI_USERLAND_POST_TARGET_CLEANUP

$(eval $(cmake-package))
