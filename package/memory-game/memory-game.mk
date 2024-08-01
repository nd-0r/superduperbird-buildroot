################################################################################
#
# memorygame
#
################################################################################

MEMORY_GAME_VERSION = 0.1.0
MEMORY_GAME_SITE = https://github.com/nd-0r/slint-demo/archive/refs/heads
MEMORY_GAME_SOURCE = main.tar.gz
MEMORY_GAME_LICENSE = MIT
MEMORY_GAME_LICENSE_FILES = LICENSE
MEMORY_GAME_CPE_ID_VALID = YES

MEMORY_GAME_DEPENDENCIES += host-pkgconf eudev libgbm libxkbcommon

$(eval $(cargo-package))
