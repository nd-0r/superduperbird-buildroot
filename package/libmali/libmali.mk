################################################################################
#
# libmali
#
################################################################################

#   This just copies the proprietary GBM, EGL, and OpenGLES libraries
# to the target. Unfortunately, the FOSS Panfrost driver of Mesa
# doesn't have a backport to the Linux 4.9.113 kernel that the board
# drivers require. The `libMali.so` library (to which all the above
# libraries are symlink'd) comes directly from the Superbird rootfs.

#   Note: This requires the `mali.ko` module to be installed. This
# is included in the rootfs so that `modprobe` finds it when the
# kernel modules are installed.

LIBMALI_VERSION = 1.0
LIBMALI_SITE = $(BR2_EXTERNAL_SUPERDUPERBIRD_PATH)/board/graphics
LIBMALI_SITE_METHOD = local
LIBMALI_INSTALL_STAGING = YES
LIBMALI_DEPENDENCIES = \
    host-pkgconf

define LIBMALI_INSTALL_TARGET_CMDS
    cp -P -f --preserve=links,mode $(@D)/lib/*.so* $(TARGET_DIR)/usr/lib
endef

define LIBMALI_INSTALL_STAGING_CMDS
    cp -P -f --preserve=links,mode $(@D)/lib/*.so* $(STAGING_DIR)/usr/lib
    cp -P -f --preserve=links,mode $(@D)/lib/*.pc* $(STAGING_DIR)/usr/lib/pkgconfig

    # Install header directories
    for dir in $$(find $(@D)/include -mindepth 1 -maxdepth 1 -type d); do \
        $(INSTALL) -D -m 0755 -t $(STAGING_DIR)/usr/include/"$$(basename $${dir})" "$${dir}"/*.h; \
    done

    # Install top-level headers
    for file in $$(find $(@D)/include -mindepth 1 -maxdepth 1 -type f -name '*.h'); do \
        $(INSTALL) -m 0755 "$${file}" $(STAGING_DIR)/usr/include/"$$(basename $${file})"; \
    done
endef

$(eval $(generic-package))
