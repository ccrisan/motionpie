################################################################################
#
# motion
#
################################################################################

MOTION_SITE = http://www.lavrsen.dk/svn/motion/trunk/
MOTION_SITE_METHOD = svn
MOTION_VERSION = r561
MOTION_CONF_OPTS = --without-pgsql --without-sdl --without-sqlite3 --without-mysql --with-ffmpeg=$(STAGING_DIR)/usr/lib --with-ffmpeg-headers=$(STAGING_DIR)/usr/include

$(eval $(autotools-package))
