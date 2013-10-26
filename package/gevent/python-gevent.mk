#############################################################
#
# gevent
#
#############################################################
# stable 0.13.8 release requires V4L which has been wiped out of recent Linux
# kernels, so use latest mercurial revision until next stable release is out.

GEVENT_VERSION = 0.13.8
GEVENT_SOURCE  = gevent-$(GEVENT_VERSION).tar.gz
GEVENT_SITE = https://pypi.python.org/packages/source/g/gevent/
GEVENT_SITE_METHOD = wget

GEVENT_DEPENDENCIES = python libevent greenlet $(GEVENT_OPT_DEPENDS)

define GEVENT_BUILD_CMDS
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
define GEVENT_REMOVE_DOC
	rm -rf $(TARGET_DIR)/usr/lib/python*/site-packages/gevent/docs
endef
endif

define GEVENT_INSTALL_TARGET_CMDS
	(cd $(@D); $(HOST_DIR)/usr/bin/python setup.py install \
		--prefix=$(TARGET_DIR)/usr)
	rm -rf $(TARGET_DIR)/usr/lib/python*/site-packages/gevent/tests
	$(PYTHON_GEVENT_REMOVE_DOC)
endef

define GEVENT_UNINSTALL_TARGET_CMDS
	rm -rf $(TARGET_DIR)/usr/lib/python*/site-packages/gevent*
endef

$(eval $(generic-package))
