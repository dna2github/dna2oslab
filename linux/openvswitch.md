# Configure Open vSwitch for QEMU Virtual Machine

### Kernel Config:

```
INET                TCP/IP networking
NETFILTER           Network packet filtering framework (Netfilter)
NETFILTER_ADVANCED  Advanced netfilter configuration
NF_CONNTRACK        Netfilter connection tracking support
NF_NAT
NF_NAT_IPV4         IPv4 NAT
NF_NAT_IPV6         IPv6 NAT
NF_CONNTRACK_IPV6   IPv6 connection tracking support
NF_DEFRAG_IPV6
OPENVSWITCH         Open vSwitch

# GRE
NET_IPGRE_DEMUX     IP: GRE demultiplexer
NET_IPGRE           IP: GRE tunnels over IP
OPENVSWITCH_GRE     Open vSwitch GRE tunneling support
# VXLAN
VXLAN               Virtual eXtensible Local Area Network (VXLAN)
OPENVSWITCH_VXLAN   Open vSwitch VXLAN tunneling support
# GENEVE
GENEVE              Generic Network Virtualization Encapsulation
OPENVSWITCH_GENEVE  Open vSwitch Geneve tunneling support
```

### Open vSwitch

```
openvswitch-xxx/share/openvswitch/scripts/ovs-ctl start
openvswitch-xxx/bin/ovs-vsctl add-br br0
openvswitch-xxx/bin/ovs-vsctl add-port br0 eth0
ifconfig br0 <eth0_ip> netmask 255.255.255.0 up
ifconfig eth0 0.0.0.0
ping -c 1 8.8.8.8
```

ref: http://docs.openvswitch.org/en/latest/howto/kvm/

```
#!/bin/sh
# ovs-ifup

switch='br0'
eth=$1
ip link set $eth up
openvswitch-xxx/bin/ovs-vsctl add-port $switch $eth
```

```
#!/bin/sh
# ovs-ifdown

switch='br0'
eth=$1
ip addr flush dev $eth
ip link set $eth down
openvswitch-xxx/bin/ovs-vsctl del-port $switch $eth
```

```
qemu-system-x86_64 -m 512 -curses -hda disk.vmdk -net nic,mac=52:54:00:12:34:56 -net tap,script=ovs-ifup,downscript=ovs=ifdown

>>> ifconfig eth0 <ip> netmask 255.255.255.0 up
>>> ip route add default via <gateway_ip> dev eth0
>>> ping 8.8.8.8
```


