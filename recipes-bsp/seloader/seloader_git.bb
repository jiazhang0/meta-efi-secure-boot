#
# Copyright (C) 2017 Wind River Systems, Inc.
#

SUMMARY = "The bootloader capable of authenticating the PE and non-PE files."
DESCRIPTION = "The SELoader is designed to authenticate the non-PE files, \
such as grub configuration, initrd, grub modules, which cannot be verified \
by the MOK Verify Protocol registered by shim loader. \
\
In order to conveniently authenticate the PE file with gBS->LoadImage() \
and gBS->StartImage(), the SELoader hooks EFI Security2 Architectural \
Protocol and employs MOK Verify Protocol to verify the PE file. If only \
UEFI Secure Boot is enabled, the SELoader just simplily calls \
gBS->LoadImage() and gBS->StartImage() to allow BIOS to verify PE file. \
\
The SELoader publishes MOK2 Verify Protocol which provides a flexible \
interface to allow the bootloader to verify the file, file buffer or \
memory buffer without knowing the file format. \
"
HOMEPAGE = "https://github.com/jiazhang0/SELoader.git"
SECTION = "bootloaders"

LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=8cdfce2a54b8b37c990425e4a8a84f66"
PR = "r0"
SRC_URI = " \
    git://github.com/jiazhang0/SELoader.git \
"
SRCREV = "cdb6b1ec73dae02be960dbe10b75ff60863cd265"
PV = "0.4.4+git${SRCPV}"

COMPATIBLE_HOST = '(i.86|x86_64).*-linux'

inherit deploy user-key-store

S = "${WORKDIR}/git"
DEPENDS += " \
    gnu-efi sbsigntool-native \
"

EFI_ARCH_x86 = "ia32"
EFI_ARCH_x86-64 = "x64"

EXTRA_OEMAKE = " \
    CROSS_COMPILE="${TARGET_PREFIX}" \
    SBSIGN=${STAGING_BINDIR_NATIVE}/sbsign \
    gnuefi_libdir=${STAGING_LIBDIR} \
    LIB_GCC="`${CC} -print-libgcc-file-name`" \
    GNU_EFI_VERSION=303 \
"

PARALLEL_MAKE = ""

EFI_TARGET = "/boot/efi/EFI/BOOT"
FILES_${PN} += "${EFI_TARGET}"

python do_sign() {
    sb_sign('${B}/Src/Efi/SELoader.efi', '${B}/Src/Efi/SELoader.efi.signed', d)
    sb_sign('${B}/Bin/Hash2DxeCrypto.efi', '${B}/Bin/Hash2DxeCrypto.efi.signed', d)
    sb_sign('${B}/Bin/Pkcs7VerifyDxe.efi', '${B}/Bin/Pkcs7VerifyDxe.efi.signed', d)
}
addtask sign after do_compile before do_install

do_install() {
    install -d ${D}${EFI_TARGET}

    oe_runmake install EFI_DESTDIR=${D}${EFI_TARGET}

    if [ x"${UEFI_SB}" = x"1" ]; then
        if [ x"${MOK_SB}" != x"1" ]; then
            mv ${D}${EFI_TARGET}/SELoader${EFI_ARCH}.efi \
                ${D}${EFI_TARGET}/boot${EFI_ARCH}.efi
        fi
    fi
}

do_deploy() {
    # Deploy the unsigned images for manual signing
    install -d ${DEPLOYDIR}/efi-unsigned

    install -m 0600 ${B}/Src/Efi/SELoader.efi \
        ${DEPLOYDIR}/efi-unsigned/SELoader${EFI_ARCH}.efi
    install -m 0600 ${B}/Bin/Hash2DxeCrypto.efi ${DEPLOYDIR}/efi-unsigned/
    install -m 0600 ${B}/Bin/Pkcs7VerifyDxe.efi ${DEPLOYDIR}/efi-unsigned/

    # Deploy the signed images
    if [ x"${UEFI_SB}" = x"1" -a x"${MOK_SB}" != x"1" ]; then
        SEL_NAME=boot
    else
        SEL_NAME=SELoader
    fi
    install -m 0600 ${D}${EFI_TARGET}/${SEL_NAME}${EFI_ARCH}.efi \
        ${DEPLOYDIR}/${SEL_NAME}${EFI_ARCH}.efi
    install -m 0600 ${D}${EFI_TARGET}/Hash2DxeCrypto.efi \
        ${DEPLOYDIR}/Hash2DxeCrypto.efi
    install -m 0600 ${D}${EFI_TARGET}/Pkcs7VerifyDxe.efi \
        ${DEPLOYDIR}/Pkcs7VerifyDxe.efi
}
addtask deploy after do_install before do_build
