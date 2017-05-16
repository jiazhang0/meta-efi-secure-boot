#
# Copyright (C) 2015-2017 Wind River Systems, Inc.
#

inherit user-key-store

fakeroot python do_sign() {
    import re

    if ('${TARGET_ARCH}' != 'x86_64') and (not re.match('i.86', '${TARGET_ARCH}')):
        return

    if '${UEFI_SB}' != '1':
        return

    import shutil

    for type in '${KERNEL_IMAGETYPES}'.split():
        kernel = '${B}/${KERNEL_OUTPUT}/' + type

        # Prepare the unsigned kernel image for manual signing.
        shutil.copy(kernel, '${B}/' + type + '.unsigned')

        sb_sign(kernel, kernel, d)

        # SELoader signature is always based on the signed kernel image,
        # allowing chainloader to kernel image.
        uks_sel_sign(kernel, d)

        shutil.copyfile(kernel, '${D}/boot/' + type + '-${KERNEL_RELEASE}')
        shutil.copyfile(kernel + '.p7b', '${D}/boot/' + type + '-${KERNEL_RELEASE}.p7b')
}

# Make sure the kernel image has been signed before kernel_do_deploy()
# which prepares the kernel image for creating usb/iso.
addtask sign after do_install before do_package do_populate_sysroot do_deploy

fakeroot python do_sign_bundled_kernel() {
    import re

    if ('${TARGET_ARCH}' != 'x86_64') and (not re.match('i.86', '${TARGET_ARCH}')):
        return

    if '${UEFI_SB}' != '1':
        return

    if ('${INITRAMFS_IMAGE}' == '') or ('${INITRAMFS_IMAGE_BUNDLE}' != '1'):
        return

    import shutil

    for type in '${KERNEL_IMAGETYPES}'.split():
        kernel = '${B}/${KERNEL_OUTPUT}/' + type + '.initramfs'

        # Prepare the unsigned kernel image for manual signing.
        shutil.copy(kernel, '${B}/' + type + '.initramfs.unsigned')

        sb_sign(kernel, kernel, d)

        # SELoader signature is always based on the signed kernel image,
        # allowing chainloader to kernel image.
        uks_sel_sign(kernel, d)

        shutil.copyfile(kernel, '${D}/boot/' + type + '-initramfs-${MACHINE}.bin')
        shutil.copyfile(kernel + '.p7b', '${D}/boot/' + type + '-initramfs-${MACHINE}.bin.p7b')
}
addtask sign_bundled_kernel after do_bundle_initramfs before do_deploy

do_deploy_append() {
    install -d "${DEPLOYDIR}/efi-unsigned"

    for type in ${KERNEL_IMAGETYPES}; do
        if [ -f "${B}/$type.unsigned" ]; then
            install -m 0644 "${B}/$type.unsigned" "${DEPLOYDIR}/efi-unsigned/$type"
        fi

        if [ -f "${B}/$type.initramfs.unsigned" ]; then
            install -m 0644 "${B}/$type.initramfs.unsigned" "${DEPLOYDIR}/efi-unsigned/type.initramfs"
        fi

        if [ -f "${D}/boot/$type-initramfs-${MACHINE}.bin.p7b" ]; then
            install -m 0644 "${D}/boot/$type-initramfs-${MACHINE}.bin.p7b" "${DEPLOYDIR}"
        fi

        if [ -f "${B}/${KERNEL_OUTPUT}/$type.p7b" ]; then
            base_name="${type}-${KERNEL_IMAGE_BASE_NAME}.bin.p7b"

            install -m 0644 "${B}/${KERNEL_OUTPUT}/$type.p7b" "${DEPLOYDIR}/$base_name"
            ln -sf "$base_name" "${DEPLOYDIR}/$type-${KERNEL_IMAGE_SYMLINK_NAME}.bin.p7b"
            ln -sf "$base_name" "${DEPLOYDIR}/$type.p7b"
        fi
    done
}

# Ship *.p7b files to related packages
python do_package_prepend() {
    for type in d.expand('${KERNEL_IMAGETYPES}').split():
        typelower = type.lower()
        d.appendVar('FILES_kernel-image-' + typelower, ' /boot/' + type + d.expand('-${KERNEL_VERSION_NAME}.p7b'))
}
