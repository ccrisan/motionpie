################################################################################
#
# motion-mrdave
#
################################################################################

MOTION_MRDAVE_SITE = $(call github,mrdave,motion,$(MOTION_MRDAVE_VERSION))
MOTION_MRDAVE_VERSION = 5c6f4be9e6

define MOTION_MMAL_BUILD_CMDS
    cd $(@D); \
    TOOLPREFIX="arm-linux-" TOOLPATH="$(HOST_DIR)/usr" ROOTFSPATH="$(STAGING_DIR)" cmake .; \
    make
endef

define MOTION_MRDAVE_INSTALL_TARGET_CMDS
    cp $(@D)/motion $(TARGET_DIR)/usr/bin/motion-mrdave
endef

$(eval $(generic-package))
