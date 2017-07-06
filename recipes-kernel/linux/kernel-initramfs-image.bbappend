#
# Copyright (C) 2017 Wind River Systems, Inc.
#

inherit user-key-store deploy

# Always fetch the latest initramfs image
do_install[nostamp] = "1"

fakeroot python do_sign() {
    initramfs = None

    if d.expand('${INSTALL_INITRAMFS}') == '1':
        initramfs = d.expand('${D}/boot/${INITRAMFS_IMAGE}${INITRAMFS_EXT_NAME}.cpio.gz')
    elif d.expand('${INSTALL_BUNDLE}') == '1':
        initramfs = d.expand('${D}/boot/${KERNEL_IMAGETYPE}-initramfs${INITRAMFS_EXT_NAME}')

    if initramfs == None or not os.path.exists(initramfs):
        return

    uks_sel_sign(initramfs, d)
}
addtask sign after do_install before do_deploy do_package

do_deploy() {
    initramfs=""
    initramfs_dest=""

    if [ x"${INSTALL_INITRAMFS}" = x"1" ]; then
        initramfs="${D}/boot/${INITRAMFS_IMAGE}${INITRAMFS_EXT_NAME}.cpio.gz"
        initramfs_dest="${DEPLOYDIR}/${INITRAMFS_IMAGE}-${MACHINE}.cpio.gz"
    elif [ x"${INSTALL_BUNDLE}" = x"1" ]; then
        initramfs="${D}/boot/${KERNEL_IMAGETYPE}-initramfs${INITRAMFS_EXT_NAME}"
        initramfs_dest="${DEPLOYDIR}/${KERNEL_IMAGETYPE}-initramfs-${MACHINE}.bin"
    fi

    if [ -n "$initramfs" -a -f "$initramfs.p7b" ]; then
        install -d "${DEPLOYDIR}"

        install -m 0644 "$initramfs.p7b" "$initramfs_dest.p7b"
    fi
}
addtask deploy after do_install before do_build

pkg_postinst_${PN}_append () {
    if [ x"${INSTALL_BUNDLE}" = x"1" ] ; then
        update-alternatives --install /boot/${KERNEL_IMAGETYPE}.p7b ${KERNEL_IMAGETYPE}.p7b /boot/${KERNEL_IMAGETYPE}-initramfs${INITRAMFS_EXT_NAME}.p7b 50101 || true
    fi
}

pkg_prerm_${PN}_append () {
    if [ x"${INSTALL_BUNDLE}" = x"1" ] ; then
        update-alternatives --remove ${KERNEL_IMAGETYPE}.p7b ${KERNEL_IMAGETYPE}-initramfs${INITRAMFS_EXT_NAME}.p7b || true
    fi
}
