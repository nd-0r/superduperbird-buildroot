################################################################################
#
# libffi-old
#
################################################################################

LIBFFI_OLD_VERSION = 3.2.1
LIBFFI_OLD_SITE = ftp://sourceware.org/pub/libffi
LIBFFI_OLD_LICENSE = MIT
LIBFFI_OLD_LICENSE_FILES = LICENSE
LIBFFI_OLD_INSTALL_STAGING = YES
LIBFFI_OLD_AUTORECONF = YES

# Move the headers to the usual location, and adjust the .pc file
# accordingly.
define LIBFFI_OLD_MOVE_STAGING_HEADERS
	mv $(STAGING_DIR)/usr/lib/libffi-$(LIBFFI_VERSION)/include/*.h $(STAGING_DIR)/usr/include/
	$(SED) '/^includedir.*/d' -e '/^Cflags:.*/d' \
		$(STAGING_DIR)/usr/lib/pkgconfig/libffi.pc
	rm -rf $(TARGET_DIR)/usr/lib/libffi-*
endef

LIBFFI_OLD_POST_INSTALL_STAGING_HOOKS += LIBFFI_OLD_MOVE_STAGING_HEADERS

# Remove headers that are not at the usual location from the target
define LIBFFI_OLD_REMOVE_TARGET_HEADERS
	$(RM) -rf $(TARGET_DIR)/usr/lib/libffi-$(LIBFFI_VERSION)
endef

LIBFFI_OLD_POST_INSTALL_TARGET_HOOKS += LIBFFI_OLD_REMOVE_TARGET_HEADERS

$(eval $(autotools-package))
$(eval $(host-autotools-package))
