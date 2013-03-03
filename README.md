# OVERVIEW

Netdev is a vendor-neutral network abstraction framework developed by Juniper Networks 
and contributed freely to the DevOps community

# EXAMPLE USAGE

This module has been tested against Puppet agent 2.7.19.  Here is a short example of a static manifest for a Junos EX switch.  This example assumes that you've also installed the Puppet _stdlib_ module as this example uses the _keys_ function.

~~~~
node "myswitch1234.mycorp.com" {
     
  netdev_device { $hostname: }
    
  $vlans = {
    'Blue'    => { vlan_id => 100, description => "This is a Blue vlan" },
    'Green'   => { vlan_id => 101, description => "This is a Green vLAN" },
    'Purple'  => { vlan_id => 102, description => "This is a Puple vlan" },
    'Red'     => { vlan_id => 103, description => "This is a Red vlan" },
    'Yellow'  => { vlan_id => 104, description => "This is a Yellow vlan" }   
  }
    
  create_resources( netdev_vlan, $vlans )
    
  $access_ports = [
    'ge-0/0/0',
    'ge-0/0/1',
    'ge-0/0/2'
  ]
    
  $uplink_ports = [
    'xe-0/0/0',
    'xe-0/0/2'
  ]
      
  netdev_l2_interface { $access_ports:
    untagged_vlan => Blue
  }
          
  netdev_l2_interface { $uplink_ports:
    tagged_vlans => keys( $vlans )
  }
}
~~~~
  
# DEPENDENCIES

  * Puppet 2.7.19
  * Ruby Gem netconf 0.2.5

# INSTALLATION ON PUPPET-MASTER

  * gem install netconf
  * puppet module install jeremyschulman-netdev 

# RESOURCE TYPES

See RESOURCE-TYPES.md for documentation and usage examples

# LICENSE

Copyright (c) 2013  Juniper Networks. All Rights Reserved.

YOU MUST ACCEPT THE TERMS OF THIS DISCLAIMER TO USE THIS SOFTWARE, 
IN ADDITION TO ANY OTHER LICENSES AND TERMS REQUIRED BY JUNIPER NETWORKS.
 
JUNIPER IS WILLING TO MAKE THE INCLUDED SCRIPTING SOFTWARE AVAILABLE TO YOU
ONLY UPON THE CONDITION THAT YOU ACCEPT ALL OF THE TERMS CONTAINED IN THIS
DISCLAIMER. PLEASE READ THE TERMS AND CONDITIONS OF THIS DISCLAIMER
CAREFULLY.

THE SOFTWARE CONTAINED IN THIS FILE IS PROVIDED "AS IS." JUNIPER MAKES NO
WARRANTIES OF ANY KIND WHATSOEVER WITH RESPECT TO SOFTWARE. ALL EXPRESS OR
IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY WARRANTY
OF NON-INFRINGEMENT OR WARRANTY OF MERCHANTABILITY OR FITNESS FOR A
PARTICULAR PURPOSE, ARE HEREBY DISCLAIMED AND EXCLUDED TO THE EXTENT
ALLOWED BY APPLICABLE LAW.

IN NO EVENT WILL JUNIPER BE LIABLE FOR ANY DIRECT OR INDIRECT DAMAGES, 
INCLUDING BUT NOT LIMITED TO LOST REVENUE, PROFIT OR DATA, OR
FOR DIRECT, SPECIAL, INDIRECT, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES
HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY ARISING OUT OF THE 
USE OF OR INABILITY TO USE THE SOFTWARE, EVEN IF JUNIPER HAS BEEN ADVISED OF 
THE POSSIBILITY OF SUCH DAMAGES.
