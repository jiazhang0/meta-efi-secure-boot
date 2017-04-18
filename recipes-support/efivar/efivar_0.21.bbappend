#
# Copyright (C) 2016 Wind River Systems, Inc.
#

FILESEXTRAPATHS_prepend := "${THISDIR}/efivar:"

SRC_URI += "\
    file://Allow-to-override-the-pkg-config-from-the-external.patch \
    file://efivar-fix-build-failure-due-to-removing-std-gnu11.patch \
    file://Multiple-fixes-for-compilation-with-gcc-6.patch \
    file://Workaround-rename-of-linux-nvme.h.patch \
    file://Remove-use-of-deprecated-readdir_r.patch \
"

# In dp.h, 'for' loop initial declarations are used
CFLAGS_append = " -std=gnu99"

# In order to install headers and libraries to sysroot
do_install_append() {
    oe_runmake DESTDIR=${D} install
}
