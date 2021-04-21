# home-network

A reboot of an old project from about 7 years ago,
https://github.com/CraigJPerry/home-network - I lost access to that github
account after an unfortunate mistake with 2FA :-)

# Instructions

1. Install Ansible on the bootstrap host (a WSL2 VM in my case) `pip3 install --user ansible`
1. Install FreeBSD pkgng support `ansible-galaxy collection install community.general`
1. Configure the host details in `hosts`
1. Read the comments in `bootstrap.yml` and decide which strategy you'll run

