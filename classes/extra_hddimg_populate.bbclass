#
# Copyright (C) 2017 Wind River Systems, Inc.
#

inherit grub-efi
# Override the efi_hddimg_populate() from grub-efi.bbclass for copying
# signed efi/kernel images and their *.p7b files to hddimg:
#   ${IMAGE_ROOTFS}/boot/efi/EFI/   -> hddimg/
#   ${DEPLOY_DIR_IMAGE}/bzImage     -> hddimg/
#   ${DEPLOY_DIR_IMAGE}/bzImage.p7b -> hddimg/

efi_hddimg_populate() {
    DEST=$1

    install -d ${DEST}${EFIDIR}

    bbnote "Trying to install ${IMAGE_ROOTFS}/boot/efi${EFIDIR} as ${DEST}/${EFIDIR}"
    if [ -d ${IMAGE_ROOTFS}/boot/efi${EFIDIR} ]; then
        cp -af ${IMAGE_ROOTFS}/boot/efi${EFIDIR}/* ${DEST}${EFIDIR}
    else
        bbwarn "${IMAGE_ROOTFS}/boot/efi${EFIDIR} doesn't exist"
    fi

    bbnote "Trying to install ${DEPLOY_DIR_IMAGE}/${VM_DEFAULT_KERNEL} as ${DEST}/${VM_DEFAULT_KERNEL}"
    if [ -e ${DEPLOY_DIR_IMAGE}/${VM_DEFAULT_KERNEL} ]; then
        install -m 0644 ${DEPLOY_DIR_IMAGE}/${VM_DEFAULT_KERNEL} ${DEST}/${VM_DEFAULT_KERNEL}
        install -m 0644 ${DEPLOY_DIR_IMAGE}/${VM_DEFAULT_KERNEL}.p7b ${DEST}/${VM_DEFAULT_KERNEL}.p7b
    else
        bbwarn "${DEPLOY_DIR_IMAGE}/${VM_DEFAULT_KERNEL} doesn't exist"
    fi
}
