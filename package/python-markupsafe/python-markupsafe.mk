################################################################################
#
# python-markupsafe
#
################################################################################

PYTHON_MARKUPSAFE_VERSION = 0.23
PYTHON_MARKUPSAFE_SOURCE = MarkupSafe-$(PYTHON_MARKUPSAFE_VERSION).tar.gz
PYTHON_MARKUPSAFE_SITE = https://pypi.python.org/packages/source/M/MarkupSafe
PYTHON_MARKUPSAFE_SETUP_TYPE = setuptools

$(eval $(python-package))
