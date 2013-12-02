#############################################################
#
# qt5base
#
#############################################################

QT5BASE_VERSION = $(QT5_VERSION)
QT5BASE_SITE = $(QT5_SITE)
QT5BASE_SOURCE = qtbase-opensource-src-$(QT5BASE_VERSION).tar.xz

QT5BASE_DEPENDENCIES = host-pkgconf zlib pcre
QT5BASE_INSTALL_STAGING = YES

# A few comments:
#  * -no-pch to workaround the issue described at
#     http://comments.gmane.org/gmane.comp.lib.qt.devel/5933.
#  * -system-zlib because zlib is mandatory for Qt build, and we
#     want to use the Buildroot packaged zlib
#  * -system-pcre because pcre is mandatory to build Qt, and we
#    want to use the one packaged in Buildroot
QT5BASE_CONFIGURE_OPTS += \
	-optimized-qmake \
	-no-qml-debug \
	-no-kms \
	-no-cups \
	-no-nis \
	-no-iconv \
	-no-gtkstyle \
	-system-zlib \
	-system-pcre \
	-no-pch

ifeq ($(BR2_PACKAGE_FONTCONFIG),y)
QT5BASE_DEPENDENCIES += fontconfig
endif

ifeq ($(BR2_PACKAGE_UDEV),y)
QT5BASE_DEPENDENCIES += udev
else
QT5BASE_CONFIGURE_OPTS += -no-libudev
endif

ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)
QT5BASE_DEPENDENCIES += gst-omx
endif

ifeq ($(BR2_ENABLE_DEBUG),y)
QT5BASE_CONFIGURE_OPTS += -debug
else
QT5BASE_CONFIGURE_OPTS += -release
endif

ifeq ($(BR2_PREFER_STATIC_LIB),y)
QT5BASE_CONFIGURE_OPTS += -static
else
# We apparently can't build both the shared and static variants of the
# library.
QT5BASE_CONFIGURE_OPTS += -shared
endif

ifeq ($(BR2_LARGEFILE),y)
QT5BASE_CONFIGURE_OPTS += -largefile
else
QT5BASE_CONFIGURE_OPTS += -no-largefile
endif

ifeq ($(BR2_PACKAGE_QT5BASE_LICENSE_APPROVED),y)
QT5BASE_CONFIGURE_OPTS += -opensource -confirm-license
QT5BASE_LICENSE = LGPLv2.1 or GPLv3.0
QT5BASE_LICENSE_FILES = LICENSE.GPL LICENSE.LGPL LGPL_EXCEPTION.txt
else
QT5BASE_LICENSE = Commercial license
QT5BASE_REDISTRIBUTE = NO
endif

# We have to use --enable-linuxfb, otherwise Qt thinks that -linuxfb
# is to add a link against the "inuxfb" library.
QT5BASE_CONFIGURE_OPTS += $(if $(BR2_PACKAGE_QT5BASE_GUI),-gui,-no-gui)
QT5BASE_CONFIGURE_OPTS += $(if $(BR2_PACKAGE_QT5BASE_WIDGETS),-widgets,-no-widgets)
QT5BASE_CONFIGURE_OPTS += $(if $(BR2_PACKAGE_QT5BASE_LINUXFB),--enable-linuxfb,-no-linuxfb)
ifeq ($(BR2_PACKAGE_DAWN_SDK),y)
QT5BASE_CONFIGURE_OPTS += -directfb
else
QT5BASE_CONFIGURE_OPTS += $(if $(BR2_PACKAGE_QT5BASE_DIRECTFB),-directfb,-no-directfb)
endif
QT5BASE_DEPENDENCIES   += $(if $(BR2_PACKAGE_QT5BASE_DIRECTFB),directfb)

ifeq ($(BR2_PACKAGE_QT5BASE_XCB),y)
QT5BASE_CONFIGURE_OPTS += -xcb
QT5BASE_DEPENDENCIES   += \
	libxcb \
	xcb-util-wm \
	xcb-util-image \
	xcb-util-keysyms \
	xlib_libX11
else
QT5BASE_CONFIGURE_OPTS += -no-xcb
endif

ifeq ($(BR2_PACKAGE_QT5BASE_EGLFS),y)
QT5BASE_CONFIGURE_OPTS += -opengl es2 -eglfs
QT5BASE_INSTALL_LIBS_y += Qt5OpenGL
ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)
QT5BASE_CONFIGURE_OPTS += \
	-no-neon \
	-no-xinerama \
	-no-xshape \
	-no-xvideo \
	-no-xsync \
	-no-xinput2 \
	-no-xinput \
	-no-xcursor \
	-no-xfixes \
	-no-xrandr \
	-no-xrender
QT5BASE_DEPENDENCIES   += rpi-userland
QT5BASE_DEPENDENCIES   += $(if $(BR2_PACKAGE_OPENSSL),ca-certificates)
QT5BASE_EGL_LIBS        = -lEGL
QT5BASE_OPENGL_ES2_LIBS = -lEGL -lGLESv2
QT5BASE_EGLFS_PLATFORM_HOOKS_SOURCES = \
	$(@D)/mkspecs/devices/linux-rasp-pi-g++/qeglfshooks_pi.cpp
else
ifeq ($(BR2_PACKAGE_DAWN_SDK),y)
QT5BASE_CONFIGURE_OPTS += \
	-no-neon \
	-no-xinerama \
	-no-xshape \
	-no-xvideo \
	-no-xsync \
	-no-xinput2 \
	-no-xinput \
	-no-xcursor \
	-no-xfixes \
	-no-xrandr \
	-no-xrender
TARGET_CFLAGS          += -D__FORCE_NOGLIBC
TARGET_CXXFLAGS        += -D__FORCE_NOGLIBC
QT5BASE_DEPENDENCIES   += dawn-sdk
QT5BASE_DEPENDENCIES   += $(if $(BR2_PACKAGE_OPENSSL),ca-certificates)
QT5BASE_EGL_LIBS        = -lrt
QT5BASE_OPENGL_ES2_LIBS = -lrt
QT5BASE_EGLFS_PLATFORM_HOOKS_SOURCES = \
	$(@D)/mkspecs/devices/linux-mipsel-broadcom-97425-g++/qdirectfbeglhooks_bcm97425.cpp
else
QT5BASE_DEPENDENCIES   += libgles libegl
endif
endif
else
QT5BASE_CONFIGURE_OPTS += -no-opengl -no-eglfs
endif

QT5BASE_CONFIGURE_OPTS += $(if $(BR2_PACKAGE_OPENSSL),-openssl,-no-openssl)
QT5BASE_DEPENDENCIES   += $(if $(BR2_PACKAGE_OPENSSL),openssl)

QT5BASE_CONFIGURE_OPTS += $(if $(BR2_PACKAGE_QT5BASE_FONTCONFIG),-fontconfig,-no-fontconfig)
QT5BASE_DEPENDENCIES   += $(if $(BR2_PACKAGE_QT5BASE_FONTCONFIG),fontconfig)
QT5BASE_CONFIGURE_OPTS += $(if $(BR2_PACKAGE_QT5BASE_GIF),,-no-gif)
QT5BASE_CONFIGURE_OPTS += $(if $(BR2_PACKAGE_QT5BASE_JPEG),-system-libjpeg,-no-libjpeg)
QT5BASE_DEPENDENCIES   += $(if $(BR2_PACKAGE_QT5BASE_JPEG),jpeg)
QT5BASE_CONFIGURE_OPTS += $(if $(BR2_PACKAGE_QT5BASE_PNG),-system-libpng,-no-libpng)
QT5BASE_DEPENDENCIES   += $(if $(BR2_PACKAGE_QT5BASE_PNG),libpng)

QT5BASE_CONFIGURE_OPTS += $(if $(BR2_PACKAGE_SQLITE),-system-sqlite)
QT5BASE_DEPENDENCIES   += $(if $(BR2_PACKAGE_SQLITE),sqlite)

QT5BASE_CONFIGURE_OPTS += $(if $(BR2_PACKAGE_QT5BASE_DBUS),-dbus,-no-dbus)
QT5BASE_DEPENDENCIES   += $(if $(BR2_PACKAGE_QT5BASE_DBUS),dbus)

QT5BASE_CONFIGURE_OPTS += $(if $(BR2_PACKAGE_LIBGLIB2),-glib,-no-glib)
QT5BASE_DEPENDENCIES   += $(if $(BR2_PACKAGE_LIBGLIB2),libglib2)

QT5BASE_CONFIGURE_OPTS += $(if $(BR2_PACKAGE_QT5BASE_ICU),-icu,-no-icu)
QT5BASE_DEPENDENCIES   += $(if $(BR2_PACKAGE_QT5BASE_ICU),icu)

# Build the list of libraries to be installed on the target
QT5BASE_INSTALL_LIBS_y                                 += Qt5Core
QT5BASE_INSTALL_LIBS_$(BR2_PACKAGE_QT5BASE_NETWORK)    += Qt5Network
QT5BASE_INSTALL_LIBS_$(BR2_PACKAGE_QT5BASE_CONCURRENT) += Qt5Concurrent
QT5BASE_INSTALL_LIBS_$(BR2_PACKAGE_QT5BASE_SQL)        += Qt5Sql
QT5BASE_INSTALL_LIBS_$(BR2_PACKAGE_QT5BASE_TEST)       += Qt5Test
QT5BASE_INSTALL_LIBS_$(BR2_PACKAGE_QT5BASE_XML)        += Qt5Xml

QT5BASE_INSTALL_LIBS_$(BR2_PACKAGE_QT5BASE_GUI)          += Qt5Gui
QT5BASE_INSTALL_LIBS_$(BR2_PACKAGE_QT5BASE_WIDGETS)      += Qt5Widgets
QT5BASE_INSTALL_LIBS_$(BR2_PACKAGE_QT5BASE_PRINTSUPPORT) += Qt5PrintSupport

QT5BASE_INSTALL_LIBS_$(BR2_PACKAGE_QT5BASE_DBUS) += Qt5DBus

# Ideally, we could use -device-option to substitute variable values
# in our linux-buildroot-g++/qmake.config, but this mechanism doesn't
# nicely support variable values that contain spaces. So we use the
# good old sed solution here.
define QT5BASE_CONFIG_SET
	$(SED) 's%^$(1).*%$(1) = $(2)%g' $(@D)/mkspecs/devices/linux-buildroot-g++/qmake.conf
endef

define QT5BASE_CONFIG_COMMON_SET
	$(SED) 's%^$(1).*%$(1) = $(2)%g' $(@D)/mkspecs/common/linux.conf
endef

define QT5BASE_CONFIGURE_CMDS
	$(call QT5BASE_CONFIG_SET,BUILDROOT_CROSS_COMPILE,$(TARGET_CROSS))
	$(call QT5BASE_CONFIG_SET,BUILDROOT_COMPILER_CFLAGS,$(TARGET_CFLAGS))
	$(call QT5BASE_CONFIG_SET,BUILDROOT_COMPILER_CXXFLAGS,$(TARGET_CXXFLAGS))
	$(call QT5BASE_CONFIG_SET,BUILDROOT_INCLUDE_PATH,$(STAGING_DIR)/usr/include)
	$(call QT5BASE_CONFIG_SET,EGLFS_PLATFORM_HOOKS_SOURCES, \
		$(QT5BASE_EGLFS_PLATFORM_HOOKS_SOURCES))
	$(call QT5BASE_CONFIG_COMMON_SET,QMAKE_LIBS_EGL,$(QT5BASE_EGL_LIBS))
	$(call QT5BASE_CONFIG_COMMON_SET,QMAKE_LIBS_OPENGL_ES2,$(QT5BASE_OPENGL_ES2_LIBS))
	$(call QT5BASE_CONFIG_COMMON_SET,QMAKE_WAYLAND_SCANNER,$(HOST_DIR)/usr/bin/wayland-scanner)
	(cd $(@D); \
		PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
		PKG_CONFIG_LIBDIR="$(STAGING_DIR)/usr/lib/pkgconfig" \
		PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
		MAKEFLAGS="$(MAKEFLAGS) -j$(PARALLEL_JOBS)" \
		./configure \
		-v \
		-prefix /usr \
		-hostprefix $(HOST_DIR)/usr \
		-sysroot $(STAGING_DIR) \
		-plugindir /usr/lib/qt/plugins \
		-no-rpath \
		-nomake examples -nomake tests \
		-device buildroot \
		-no-c++11 \
		$(QT5BASE_CONFIGURE_OPTS) \
	)
endef

define QT5BASE_BUILD_CMDS
	$(MAKE) -C $(@D)
endef

define QT5BASE_INSTALL_STAGING_CMDS
	$(MAKE) -C $(@D) install
	$(QT5_LA_PRL_FILES_FIXUP)
endef

define QT5BASE_INSTALL_TARGET_LIBS
	for lib in $(QT5BASE_INSTALL_LIBS_y); do \
		cp -dpf $(STAGING_DIR)/usr/lib/lib$${lib}.so.* $(TARGET_DIR)/usr/lib ; \
	done
endef

define QT5BASE_INSTALL_TARGET_PLUGINS
	if [ -d $(STAGING_DIR)/usr/lib/qt/plugins/ ] ; then \
		mkdir -p $(TARGET_DIR)/usr/lib/qt/plugins ; \
		cp -dpfr $(STAGING_DIR)/usr/lib/qt/plugins/* $(TARGET_DIR)/usr/lib/qt/plugins ; \
	fi
endef

ifeq ($(BR2_PACKAGE_FONTCONFIG),y)
define QT5BASE_INSTALL_TARGET_FONTS
	mkdir -p $(TARGET_DIR)/usr/share/fonts
	cp -dpfr $(@D)/lib/fonts/* $(TARGET_DIR)/usr/share/fonts
endef
else
define QT5BASE_INSTALL_TARGET_FONTS
	if [ -d $(STAGING_DIR)/usr/lib/fonts/ ] ; then \
		mkdir -p $(TARGET_DIR)/usr/lib/fonts ; \
		cp -dpfr $(STAGING_DIR)/usr/lib/fonts/* $(TARGET_DIR)/usr/lib/fonts ; \
	fi
endef
endif

ifeq ($(BR2_PREFER_STATIC_LIB),y)
define QT5BASE_INSTALL_TARGET_CMDS
	$(QT5BASE_INSTALL_TARGET_FONTS)
endef
else
define QT5BASE_INSTALL_TARGET_CMDS
	$(QT5BASE_INSTALL_TARGET_LIBS)
	$(QT5BASE_INSTALL_TARGET_PLUGINS)
	$(QT5BASE_INSTALL_TARGET_FONTS)
endef
endif

$(eval $(generic-package))
