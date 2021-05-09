# Fedora Core OS

Installing FCOS is designed to leverage automation, it doesn't use kickstart files though, it uses "ignition" files which are json files created from a yaml file by the "butane" tool.

I network book my lab hosts to a menu which defaults to local boot from HDD but with a menu option to install FCOS. This gets the kernel and initrd image via tftp then gets the rootfs (which is around 700mb) over http because that's much faster than tftp.

The only special thing to note is that the worker nodes in the lab each have 2 x HDDs to be used as a mirror for /boot and / partitions but a stripe for /var.

## Steps

1. Edit `fedore-core-os-ignition.yml`
1. To generate the ignition file, run from this directory: `docker run --interactive --rm -v $(pwd):/pwd --workdir /pwd quay.io/coreos/butane:release --pretty --strict < fedora-core-os-ignition.yaml > config.ign`
1. Make the file available as `config.ign` on the web server
1. Make sure the FCOS kernel, initrd & rootfs are available over tftp / http. You can run this command to download all 3 to the current directory: `docker run --pull=always --rm -v $(pwd):/data -w /data quay.io/coreos/coreos-installer:release download -s stable -p metal -f iso`

