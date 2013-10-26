#############################################################
#
# greenlet
#
#############################################################
# stable 0.13.8 release requires V4L which has been wiped out of recent Linux
# kernels, so use latest mercurial revision until next stable release is out.

GREENLET_VERSION = 0.4.0
GREENLET_SOURCE  = greenlet-$(GREENLET_VERSION).zip
GREENLET_SITE = https://pypi.python.org/packages/source/g/greenlet/
GREENLET_SITE_METHOD = wget


GREENLET_DEPENDENCIES = python $(GREENLET_OPT_DEPENDS)

# Pygame needs a Setup file where options should be commented out if
# dependencies are not available
#define PYTHON_PYGAME_CONFIGURE_CMDS
#	cp -f $(@D)/Setup.in $(@D)/Setup
#	$(SED) 's~^SDL = ~SDL = $(PYTHON_PYGAME_SDL_FLAGS) \n#~' $(@D)/Setup
#	$(SED) 's/^pypm/#pypm/' $(@D)/Setup
#	$(PYTHON_PYGAME_UNCONFIGURE_IMAGE)
#	$(PYTHON_PYGAME_UNCONFIGURE_FONT)
#	$(PYTHON_PYGAME_UNCONFIGURE_MIXER)
#	$(PYTHON_PYGAME_UNCONFIGURE_SNDARRAY)
#	$(PYTHON_PYGAME_UNCONFIGURE_SURFARRAY)
#	$(PYTHON_PYGAME_UNCONFIGURE_MOVIE)
#	$(PYTHON_PYGAME_UNCONFIGURE_SCRAP)
#endef

define GREENLET_EXTRACT_CMDS
    unzip -d $(BUILD_DIR) $(DL_DIR)/$(GREENLET_SOURCE)
endef

define GREENLET_BUILD_CMDS
	(cd $(@D); CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)" \
		LDSHARED="$(TARGET_CROSS)gcc -shared" \
		CROSS_COMPILING=yes \
		_python_sysroot=$(STAGING_DIR) \
		_python_srcdir=$(BUILD_DIR)/python$(PYTHON_VERSION) \
		_python_prefix=/usr \
		_python_exec_prefix=/usr \
		$(HOST_DIR)/usr/bin/python setup.py build)
endef


ifneq ($(BR2_HAVE_DOCUMENTATION),y)
define GREENLET_REMOVE_DOC
	rm -rf $(TARGET_DIR)/usr/lib/python*/site-packages/greenlet/docs
endef
endif

define GREENLET_INSTALL_TARGET_CMDS
	(cd $(@D); $(HOST_DIR)/usr/bin/python setup.py install \
		--prefix=$(TARGET_DIR)/usr)
	rm -rf $(TARGET_DIR)/usr/lib/python*/site-packages/greenlet/tests
	$(GREENLET_REMOVE_DOC)
endef

define GREENLET_UNINSTALL_TARGET_CMDS
	rm -rf $(TARGET_DIR)/usr/lib/python*/site-packages/greenlet*
endef

$(eval $(generic-package))
