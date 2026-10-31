# 2026-10-30 23:54:55 by RouterOS 7.18.2
# software id = 9QKH-ZSQX
#
# model = CRS354-48G-4S+2Q+
# serial number = D8520E5308A3
/interface bridge
add frame-types=admit-only-vlan-tagged name=bridge1 vlan-filtering=yes
/interface vlan
add interface=bridge1 name=vlan160-management vlan-id=160
/interface bonding
add lacp-rate=1sec mode=802.3ad name=bond-truenas slaves=ether5,ether6 \
    transmit-hash-policy=layer-2-and-3
/port
set 0 name=serial0
/interface bridge port
add bridge=bridge1 comment="Datto Switch Trunk" interface=sfp-sfpplus1
add bridge=bridge1 comment="Desk Switch" interface=ether1 pvid=160
add bridge=bridge1 comment=Desktop interface=sfp-sfpplus2 pvid=110
add bridge=bridge1 comment="Desk Switch Trunk" interface=sfp-sfpplus3
add bridge=bridge1 interface=ether2 pvid=120
add bridge=bridge1 comment="pve01 trunk" interface=ether3 pvid=160
add bridge=bridge1 comment="TrueNAS LACP" interface=bond-truenas pvid=120
/ip firewall connection tracking
set generic-timeout=1m
/ipv6 settings
set accept-router-advertisements=yes forward=no
/interface bridge vlan
add bridge=bridge1 comment=Trusted tagged=sfp-sfpplus1,ether3 vlan-ids=110
add bridge=bridge1 comment=Servers tagged=sfp-sfpplus1,ether3 untagged=\
    ether2,bond-truenas vlan-ids=120
add bridge=bridge1 comment=IoT tagged=sfp-sfpplus1,ether3 vlan-ids=130
add bridge=bridge1 comment=Lab tagged=sfp-sfpplus1,ether3 vlan-ids=140
add bridge=bridge1 comment=Guest tagged=sfp-sfpplus1,ether3 vlan-ids=150
add bridge=bridge1 comment=Management tagged=sfp-sfpplus1 vlan-ids=160
/ip address
add address=10.0.254.2/24 comment="emergency mgmt" interface=ether49 network=\
    10.0.254.0
add address=10.0.60.11/24 comment="switch mgmt" interface=vlan160-management \
    network=10.0.60.0
/ip dns
set servers=9.9.9.9
/ip route
add dst-address=0.0.0.0/0 gateway=10.0.60.1
/ipv6 address
add address=2603:7083:4600:103c::b advertise=no comment="switch mgmt" \
    interface=vlan160-management
/ipv6 nd
set [ find default=yes ] disabled=yes
/system clock
set time-zone-name=America/New_York
/system identity
set name=PTXE-HME-SW-01
/system note
set show-at-login=no
