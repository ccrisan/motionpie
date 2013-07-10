#############################################################
#
# wiringpi
#
#############################################################

WIRINGPI_VERSION = 02a3bd8d8f2ae5c873e63875a8faef5b627f9db6
WIRINGPI_SITE = git://git.drogon.net/wiringPi
WIRINGPI_LICENSE = LGPLv3+
WIRINGPI_LICENSE_FILES = COPYING.LESSER
WIRINGPI_INSTALL_STAGING = YES
WIRINGPI_CONF_OPT = -DCMAKE_BUILD_TYPE=Release

$(eval $(cmake-package))
