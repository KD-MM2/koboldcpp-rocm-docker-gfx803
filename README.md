# Koboldcpp LLM on AMD RX570 8GB

##

## 1. Downgrade linux kernel(if using HWE kernel)

```
kaotd@dpt-t5810:~$ cat /etc/lsb-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=22.04
DISTRIB_CODENAME=jammy
DISTRIB_DESCRIPTION="Ubuntu 22.04.5 LTS"

root@dpt-t5810:/home/kaotd# apt list --installed | grep linux-image
WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
linux-image-6.8.0-45-generic/jammy-updates,jammy-security,now 6.8.0-45.45~22.04.1 amd64 [installed,automatic]
linux-image-6.8.0-47-generic/jammy-updates,jammy-security,now 6.8.0-47.47~22.04.1 amd64 [installed,automatic]
linux-image-generic-hwe-22.04/jammy-updates,jammy-security,now 6.8.0-47.47~22.04.1 amd64 [installed,automatic
```

```
kaotd@dpt-t5810:~$ sudo lshw -c display
  *-display
       description: VGA compatible controller
       product: Ellesmere [Radeon RX 470/480/570/570X/580/580X/590]
       vendor: Advanced Micro Devices, Inc. [AMD/ATI]
       physical id: 0
       bus info: pci@0000:02:00.0
       logical name: /dev/fb0
       version: ef
       width: 64 bits
       clock: 33MHz
       capabilities: pm pciexpress msi vga_controller bus_master cap_list rom fb
       configuration: depth=32 driver=amdgpu latency=0 resolution=1920,1080
       resources: irq:51 memory:e0000000-efffffff memory:f0000000-f01fffff ioport:e000(size=256) memory:f7d00000-f7d3ffff memory:f7d40000-f7d5ffff
```

```
sudo apt install --install-suggests linux-generic

>> The following additional packages will be installed:
  linux-headers-5.15.0-124 linux-headers-5.15.0-124-generic linux-headers-generic linux-image-5.15.0-124-generic...

>> installing version will be 5.15.0-124
```

get the grub boot string from `/boot/grub/grub.cfg`:

```
# look at
submenu 'Advanced options for Ubuntu' $menuentry_id_option 'gnulinux-advanced-36690054-f07f-436d-91d2-7952e2f81468' {

# and
Ubuntu, with Linux 5.15.0-124-generic
```

edit default boot kernel:

```
nano /etc/default/grub

# GRUB_DEFAULT will look like this
GRUB_DEFAULT="Advanced options for Ubuntu>Ubuntu, with Linux 5.15.0-124-generic"
# save the file

update-grub
# reboot
```

after reboot:

```
uname -a
Linux dpt-t5810 5.15.0-124-generic #134-Ubuntu SMP Fri Sep 27 20:20:17 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
```



## Install ROCm

```
curl -O https://repo.radeon.com/amdgpu-install/5.5/ubuntu/jammy/amdgpu-install_5.5.50500-1_all.deb
sudo dpkg -i amdgpu-install_5.5.50500-1_all.deb
sudo amdgpu-install --usecase=rocm,mllib,mlsdk,hip --no-dkms
sudo usermod -aG video $USER
sudo usermod -aG render $USER
# (Reboot Ubuntu)
sudo rocminfo
rocm-smi
```

```
sudo apt update && sudo apt install libclblast-dev libopenblas-dev
```

## Install KoboldCpp-ROCm

```
git clone https://github.com/YellowRoseCx/koboldcpp-rocm.git -b main --depth 1 && \
cd koboldcpp-rocm && \
make LLAMA_OPENBLAS=1 LLAMA_CLBLAST=1 LLAMA_HIPBLAS=1 -j8 && \
# python 3.10.11

# run a server
python koboldcpp.py --model ~/path/to/model/model.gguf --layers 40 --host 0.0.0.0 --port 9988


```

https://github.com/YellowRoseCx/koboldcpp-rocm

```
kaotd@dpt-t5810:~/koboldcpp-rocmpython koboldcpp.py --model ~/selfhosted/llama.cpp/models/library-mistral-7b/model-ff82381e2bea.gguf --gpulayers 40 --host 0.0.0.0 --port 9988
```
