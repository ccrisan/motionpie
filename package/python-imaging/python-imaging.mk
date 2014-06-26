#############################################################
#
# python-imaging
#
#############################################################

PYTHON_IMAGING_VERSION = 1.1.7
PYTHON_IMAGING_SOURCE = Imaging-$(PYTHON_IMAGING_VERSION).tar.gz
PYTHON_IMAGING_SITE = http://effbot.org/downloads
PYTHON_IMAGING_INSTALL_TARGET = YES
PYTHON_IMAGING_BUILD_OPKG = YES
PYTHON_IMAGING_SECTION = python
PYTHON_IMAGING_DESCRIPTION = Imaging handling/processing for Python
PYTHON_IMAGING_OPKG_DEPENDENCIES = python,distribute,zlib,freetype,$(call qstrip,$(BR2_JPEG_LIBRARY))
PYTHON_IMAGING_DEPENDENCIES = host-python python zlib freetype $(call qstrip,$(BR2_JPEG_LIBRARY))

IMAGINGXCPREFIX=$(STAGING_DIR)/usr
PYTHON_IMAGING_LDFLAGS="$(TARGET_LDFLAGS) -L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib"

#PYTHON_IMAGING_CONF_ENV = 
#PYTHON_IMAGING_CONF_OPT = 
define PYTHON_IMAGING_BUILD_CMDS
    (cd $(@D) && \
    $(HOST_MAKE_ENV) PYTHONXCPREFIX=$(IMAGINGXCPREFIX) LDFLAGS=$(PYTHON_IMAGING_LDFLAGS) python setup.py build --cross-compile && \
    $(HOST_MAKE_ENV) PYTHONXCPREFIX=$(IMAGINGXCPREFIX) LDFLAGS=$(PYTHON_IMAGING_LDFLAGS) python setup.py install -O0 --skip-build --prefix /usr --root .install)
    find $(@D)/.install -name "*.py" -exec rm -rf "{}" ";"
    find $(@D)/.install -name "*.pyo" -exec rm -rf "{}" ";"
    rm -rf $(@D)/.install/usr/bin
endef

define PYTHON_IMAGING_INSTALL_TARGET_CMDS
    cp -PR $(@D)/.install/* $(TARGET_DIR)/
endef

$(eval $(generic-package))
