#############################################################
#
# qt5webkit
#
#############################################################

QT5WEBKIT_VERSION = $(QT5_VERSION)
QT5WEBKIT_SITE = $(QT5_SITE)
QT5WEBKIT_SOURCE = qtwebkit-opensource-src-$(QT5WEBKIT_VERSION).tar.xz
QT5WEBKIT_DEPENDENCIES = qt5base qt5declarative sqlite host-ruby host-gperf
QT5WEBKIT_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_QT5BASE_LICENSE_APPROVED),y)
QT5WEBKIT_CONFIGURE_OPTS += -opensource -confirm-license
QT5WEBKIT_LICENSE = LGPLv2.1 or GPLv3.0
# Here we would like to get license files from qt5base, but qt5base
# may not be extracted at the time we get the legal-info for
# qt5script.
else
QT5WEBKIT_LICENSE = Commercial license
QT5WEBKIT_REDISTRIBUTE = NO
endif

ifeq ($(BR2_ENABLE_DEBUG),y)
	DEBUG_CONFIG="CONFIG+=debug"
else
	DEBUG_CONFIG="CONFIG-=debug"
endif

define QT5WEBKIT_CONFIGURE_CMDS
	(cd $(@D); \
		$(TARGET_MAKE_ENV) \
		$(HOST_DIR)/usr/bin/qmake \
			WEBKIT_CONFIG-=svg \
			WEBKIT_CONFIG+=accelerated_2d_canvas \
			CONFIG+=release \
			$(DEBUG_CONFIG)\
			DEFINES+=_GSTREAMER_QOS_ \
	)
endef

define QT5WEBKIT_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define QT5WEBKIT_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) install
	$(QT5_LA_PRL_FILES_FIXUP)
endef

define QT5WEBKIT_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/root/.cache
	cp -dpf $(STAGING_DIR)/usr/lib/libQt5WebKit*.so.* $(TARGET_DIR)/usr/lib
	cp -dpf $(@D)/bin/* $(TARGET_DIR)/usr/bin/
	cp -dpfr $(STAGING_DIR)/usr/qml/QtWebKit $(TARGET_DIR)/usr/qml/
endef

$(eval $(generic-package))
