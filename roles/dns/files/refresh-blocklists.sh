#!/bin/sh

cd $( dirname $0 )

# grb some configs
wget https://raw.githubusercontent.com/acidwars/AdBlock-Lists/master/adblock.conf -O dnsmasq.conf.d/20-adblock.conf
wget https://raw.githubusercontent.com/acidwars/AdBlock-Lists/master/ads01.conf -O dnsmasq.conf.d/21-ads01.conf
wget https://raw.githubusercontent.com/notracking/hosts-blocklists/master/domains.txt -O dnsmasq.conf.d/22-blocklists.conf

# grab some hosts
wget https://raw.githubusercontent.com/r-a-y/mobile-hosts/master/AdguardDNS.txt -O hosts.d/adguard
wget https://raw.githubusercontent.com/r-a-y/mobile-hosts/master/AdguardMobileAds.txt -O hosts.d/adguard-mobilea

