################################################################################
#
# wayland-old
#
################################################################################

WAYLAND_OLD_VERSION = 1.8.1
WAYLAND_OLD_SITE = http://wayland.freedesktop.org/releases
WAYLAND_OLD_SOURCE = wayland-$(WAYLAND_VERSION).tar.xz
WAYLAND_OLD_LICENSE = MIT
WAYLAND_OLD_LICENSE_FILES = COPYING

WAYLAND_OLD_INSTALL_STAGING = YES
WAYLAND_OLD_DEPENDENCIES = libffi-old host-pkgconf host-wayland-old expat

# wayland-scanner is only needed for building, not on the target
WAYLAND_OLD_CONF_OPTS = --disable-scanner

# We must provide a specialy-crafted wayland-scanner .pc file
# which we vampirise and adapt from the host-wayland copy
define WAYLAND_OLD_SCANNER_PC
	$(INSTALL) -m 0644 -D $(HOST_DIR)/usr/lib/pkgconfig/wayland-scanner.pc \
		$(STAGING_DIR)/usr/lib/pkgconfig/wayland-scanner.pc
	$(SED) 's:^prefix=.*:prefix=/usr:' \
		-e 's:^wayland_scanner=.*:wayland_scanner=$(HOST_DIR)/usr/bin/wayland-scanner:' \
		$(STAGING_DIR)/usr/lib/pkgconfig/wayland-scanner.pc
endef
WAYLAND_OLD_POST_INSTALL_STAGING_HOOKS += WAYLAND_OLD_SCANNER_PC

# Remove the DTD from the target, it's not needed at runtime
define WAYLAND_OLD_TARGET_CLEANUP
	rm -rf $(TARGET_DIR)/usr/share/wayland
endef
WAYLAND_OLD_POST_INSTALL_TARGET_HOOKS += WAYLAND_OLD_TARGET_CLEANUP

$(eval $(autotools-package))
$(eval $(host-autotools-package))
