################################################################################
#
# motioneye
#
################################################################################

MOTIONEYE_VERSION = 0.13
MOTIONPIE_VERSION = 20140705
MOTIONEYE_SITE = $(TOPDIR)/package/motioneye
MOTIONEYE_SITE_METHOD = local
SRC_DIR = /media/data/projects/motioneye/
DST_DIR = $(TARGET_DIR)/programs/motioneye

define MOTIONEYE_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/S95motioneye $(TARGET_DIR)/etc/init.d/S95motioneye
    mkdir -p $(DST_DIR)
    cd $(SRC_DIR) && find $(SRC_DIR) \(\
        -name '*.py' -o \
        -name '*.sh' -o \
        -name '*.js' -o \
        -name '*.html' -o \
        -name '*.css' -o \
        -name '*.ttf' -o \
        -name '*.woff' -o \
        -name '*.svg' -o \
        -name '*.eot' -o \
        -name '*.png' -o \
        -name '*.jpg' -o \
        -name '*.gif' \) \
        \! -path '$(SRC_DIR)run*' \
        \! -path '$(SRC_DIR)conf*' \
        | cut -c $$(echo $(SRC_DIR) | wc -c)- | xargs -I xxx cp -p --parents xxx $(DST_DIR)
    $(INSTALL) -D -m 0644 $(@D)/update.py $(DST_DIR)/src/update.py

    # settings
    mv $(DST_DIR)/settings_default.py $(DST_DIR)/settings.py
    sed -r -i "s%os.path.abspath(os.path.join(PROJECT_PATH, 'conf'))%'/data/etc'%" $(DST_DIR)/settings.py
    sed -r -i "s%os.path.abspath(os.path.join(PROJECT_PATH, 'run'))%'/tmp'%" $(DST_DIR)/settings.py
    sed -r -i "s%REPO = ('ccrisan', 'motioneye')%REPO = ('ccrisan', 'motionPie')%" $(DST_DIR)/settings.py
    sed -r -i "s%LOG_LEVEL = logging.INFO%LOG_LEVEL = logging.DEBUG%" $(DST_DIR)/settings.py
    sed -r -i "s%8765%80%" $(DST_DIR)/settings.py
    sed -r -i "s%WPA_SUPPLICANT_CONF = None%WPA_SUPPLICANT_CONF = '/data/etc/wpa_supplicant.conf'%" $(DST_DIR)/settings.py
    sed -r -i "s%SMB_SHARES = False%SMB_SHARES = True%" $(DST_DIR)/settings.py
    sed -r -i "s%SMB_MOUNT_ROOT = '/media'%SMB_MOUNT_ROOT = '/data/media'%" $(DST_DIR)/settings.py
    sed -r -i "s%ENABLE_REBOOT = False%ENABLE_REBOOT = True%" $(DST_DIR)/settings.py

    # version & name
    sed -r -i "s%VERSION = '[a-bA-B0-9.]+'%VERSION = '$(MOTIONPIE_VERSION)'%" $(DST_DIR)/motioneye.py
    sed -r -i "s%motionEye is up to date%motionPie is up to date%" $(DST_DIR)/static/js/main.js
    sed -r -i "s%motionEye was successfully updated%motionPie was successfully updated%" $(DST_DIR)/static/js/main.js

    # update timeout
    sed -r -i "s%setTimeout\(checkServerUpdate, 2000\)%setTimeout(checkServerUpdate, 7000)%" $(DST_DIR)/static/js/main.js
endef

$(eval $(generic-package))

