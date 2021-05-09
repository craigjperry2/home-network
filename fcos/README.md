# Fedora Core OS

Installing FCOS is designed to leverage automation, it doesn't use kickstart files though, it uses "ignition" files which are json files created from a yaml file by the "butane" tool.

I network book my hosts to a menu (defaults to local boot from HDD) with an option to install FCOS. This gets the kernel and initrd image via tftp then gets the rootfs (which is around 700mb) over http because that's much faster than tftp.

## Steps

1. Edit `worker-node.yaml`
1. To generate the ignition file, run `docker run --interactive --rm -v $(pwd):/pwd --workdir /pwd quay.io/coreos/butane:release --pretty --strict < worker-node.yaml > config.ign`
1. Make the file available as `config.ign` on the web server
1. Make sure the FCOS kernel, initrd & rootfs are available over tftp / http. You can run this command to download all 3: `docker run --pull=always --rm -v $(pwd):/data -w /data quay.io/coreos/coreos-installer:release download -s stable -p metal -f iso`

