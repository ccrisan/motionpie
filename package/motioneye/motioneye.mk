################################################################################
#
# motioneye
#
################################################################################

MOTIONEYE_VERSION = 0.1
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
    mv $(DST_DIR)/settings_default.py $(DST_DIR)/settings.py
    sed -i "s%os.path.abspath(os.path.join(PROJECT_PATH, 'conf'))%'/data/etc'%" $(DST_DIR)/settings.py
    sed -i "s%os.path.abspath(os.path.join(PROJECT_PATH, 'run'))%'/tmp'%" $(DST_DIR)/settings.py
    sed -i "s%LOG_LEVEL = logging.INFO%LOG_LEVEL = logging.DEBUG%" $(DST_DIR)/settings.py
    sed -i "s%8765%80%" $(DST_DIR)/settings.py
    sed -i "s%WPA_SUPPLICANT_CONF = None%WPA_SUPPLICANT_CONF = '/data/etc/wpa_supplicant.conf'%" $(DST_DIR)/settings.py
    sed -i "s%SMB_SHARES = False%SMB_SHARES = True%" $(DST_DIR)/settings.py
    sed -i "s%SMB_MOUNT_ROOT = '/media'%SMB_MOUNT_ROOT = '/data/media'%" $(DST_DIR)/settings.py
    sed -i "s%ENABLE_REBOOT = False%ENABLE_REBOOT = True%" $(DST_DIR)/settings.py
endef

$(eval $(generic-package))
