qemu-system-aarch64 -m 2048 -cpu cortex-a57 \
  -smp 4 -M virt -bios QEMU_EFI.fd \
  -drive if=none,file=$1,id=hd0  \
  -device virtio-blk-device,drive=hd0 \
  -nographic \
  -nic user \
  -kernel Image -initrd initramfs-linux-fallback.img \
  -append "root=/dev/vda1 rw"
#qemu-system-aarch64 \
#-machine virt -machine virtualization=true \
#   -cpu cortex-a57 -machine type=virt -nographic \
#   -smp 4 -m 4000 \
#   -kernel Image.gz --append "console=ttyAMA0 root=/dev/hda0 init=/bin/sh" \
#   -drive file=$1,if=virtio