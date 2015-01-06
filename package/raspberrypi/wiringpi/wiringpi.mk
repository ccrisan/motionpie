#############################################################
#
# wiringpi
#
#############################################################

WIRINGPI_VERSION = f18c8f7204d6354220fd6754578b3daa43734e1b
WIRINGPI_SITE = git://git.drogon.net/wiringPi
WIRINGPI_LICENSE = LGPLv3+
WIRINGPI_LICENSE_FILES = COPYING.LESSER
WIRINGPI_INSTALL_STAGING = YES
WIRINGPI_CONF_OPTS = -DCMAKE_BUILD_TYPE=Release

$(eval $(cmake-package))
