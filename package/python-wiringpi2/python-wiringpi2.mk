#############################################################
#
# python-wiringPI2
#
#############################################################
# stable 0.13.8 release requires V4L which has been wiped out of recent Linux
# kernels, so use latest mercurial revision until next stable release is out.

PYTHON_WIRINGPI2_VERSION = master
PYTHON_WIRINGPI2_SITE = https://github.com/WiringPi/WiringPi2-Python.git
PYTHON_WIRINGPI2_SITE_METHOD = git

PYTHON_WIRINGPI2_DEPENDENCIES = python
#export PYTHONPATH=/home/razvan/rpi-buildroot/output/target/usr/lib/python2.7/site-packages/

define PYTHON_WIRINGPI2_BUILD_CMDS
	(export PYTHONPATH=$(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION)/site-packages/)
	(cd $(@D); swig -python wiringpi.i)
	(cd $(@D); CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)" \
		LDSHARED="$(TARGET_CROSS)gcc -shared" \
		CROSS_COMPILING=yes PYTHONPATH=$(TARGET_DIR)/usr\
		_python_sysroot=$(STAGING_DIR) \
		_python_srcdir=$(BUILD_DIR)/python$(PYTHON_VERSION) \
		_python_prefix=/usr \
		_python_exec_prefix=/usr \
		$(HOST_DIR)/usr/bin/python setup.py build)
endef

define PYTHON_WIRINGPI2_INSTALL_TARGET_CMDS
	(cd $(@D); $(HOST_DIR)/usr/bin/python setup.py install \
		--prefix=$(TARGET_DIR)/usr)
endef

define PYTHON_WIRINGPI2_UNINSTALL_TARGET_CMDS
	rm -rf $(TARGET_DIR)/usr/lib/python*/site-packages/gevent*
endef

$(eval $(generic-package))
