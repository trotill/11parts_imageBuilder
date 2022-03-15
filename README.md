![](https://11-parts.com/sites/default/files/logo_11p_2_2.gif)
## 11parts Image builder 
Framework 11-parts (eleven parts) for the development of complexes and devices based on Linux OS.
This repository contains 11 parts firmware builder. All code of this repository is written in Javascript and bash.

The build instructions for the project are not ready, the source codes are presented for informational purposes only. In addition to the instructions, a start-up project is also required, it is not here either, it is not ready.

### The firmware builder can create 3 types of firmware
- debug image on SD /SSD/HDD,
- debug image on NFS,
- protected image from power off to the production device (TMPFS+OverlayFs),

Implemented support for firmware updates. After building, 2 firmware are created, one for updating via the WEB, the other for updating to a bare device

In addition to creating firmware, the builder compiles the C++ part and kernel modules using docker

If you are interested in the project please contact me at:
- e-mail: info@11-parts.com
- telegramm: @develinux