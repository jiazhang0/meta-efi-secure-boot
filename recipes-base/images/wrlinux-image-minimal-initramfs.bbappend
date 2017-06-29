#
# Copyright (C) 2017 Wind River Systems, Inc.
#

inherit user-key-store deploy

fakeroot python do_sign() {
    initramfs_symlink = d.expand('wrlinux-image-minimal-initramfs-${MACHINE}.cpio.gz')
    initramfs = os.path.basename(os.path.realpath(initramfs_symlink))

    print("initramfs: " + initramfs)
    if os.path.exists(initramfs):
        uks_sel_sign(initramfs, d)

    import shutil
    shutil.copyfile(initramfs + '.p7b', initramfs_symlink + '.p7b')
}

do_sign[dirs] = "${DEPLOYDIR}-image-complete"
addtask sign after do_image_cpio before do_image_complete
