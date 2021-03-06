#############################################################
#
# Virtual package for libGLES
#
#############################################################

LIBGLES_SOURCE =

ifeq ($(BR2_PACKAGE_DAWN_SDK),y)
LIBGLES_DEPENDENCIES += dawn-sdk
endif

ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)
LIBGLES_DEPENDENCIES += rpi-userland
endif

ifeq ($(LIBGLES_DEPENDENCIES),)
define LIBGLES_CONFIGURE_CMDS
	echo "No libGLES implementation selected. Configuration error."
	exit 1
endef
endif

$(eval $(generic-package))
